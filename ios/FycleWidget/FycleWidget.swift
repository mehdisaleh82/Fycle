import SwiftUI
import WidgetKit

// The home-screen widget: the cycle ring and the day of the cycle, nothing
// else. No word about periods, no name: it can be seen by anyone looking at
// the screen.
//
// It reads five values the app leaves in the shared area of the App Group
// (see lib/data/widget_gateway.dart) and counts the days by itself, so that
// it stays right on days when the app is not opened. No network.

private let appGroup = "group.app.fycle"

/// What the app left for the widget.
struct CycleValues {
  let cycleStart: Date
  let cycleLength: Int
  let periodLength: Int
  let nextEarliest: Date
  let nextLatest: Date

  static func read() -> CycleValues? {
    guard let defaults = UserDefaults(suiteName: appGroup),
      let start = day(defaults.string(forKey: "cycle_start")),
      let earliest = day(defaults.string(forKey: "next_earliest")),
      let latest = day(defaults.string(forKey: "next_latest"))
    else {
      return nil
    }
    let cycle = defaults.integer(forKey: "cycle_length")
    let period = defaults.integer(forKey: "period_length")
    guard cycle > 0 else {
      return nil
    }
    return CycleValues(
      cycleStart: start,
      cycleLength: cycle,
      periodLength: max(period, 0),
      nextEarliest: earliest,
      nextLatest: latest
    )
  }

  /// Reads a calendar day written as `2026-03-05`, at the start of that day
  /// on the clock of the phone.
  private static func day(_ text: String?) -> Date? {
    guard let text = text else {
      return nil
    }
    let parts = text.split(separator: "-").compactMap { Int($0) }
    guard parts.count == 3 else {
      return nil
    }
    var components = DateComponents()
    components.year = parts[0]
    components.month = parts[1]
    components.day = parts[2]
    return Calendar.current.date(from: components)
  }
}

struct CycleEntry: TimelineEntry {
  let date: Date
  let values: CycleValues?

  private func days(from start: Date, to end: Date) -> Int {
    let calendar = Calendar.current
    return calendar.dateComponents(
      [.day],
      from: calendar.startOfDay(for: start),
      to: calendar.startOfDay(for: end)
    ).day ?? 0
  }

  /// 1 on the first day of the cycle. Nil when there is nothing to show, or
  /// when the log has been left aside for so long that counting means
  /// nothing.
  var dayOfCycle: Int? {
    guard let values = values else {
      return nil
    }
    let day = days(from: values.cycleStart, to: date) + 1
    let late = days(from: values.nextLatest, to: date)
    return day >= 1 && late <= 90 ? day : nil
  }

  /// Days the whole ring stands for.
  var totalDays: Int {
    guard let values = values, let day = dayOfCycle else {
      return 28
    }
    let expectedEnd = days(from: values.cycleStart, to: values.nextLatest) + 1
    return max(values.cycleLength, day, expectedEnd, 1)
  }

  /// First and last day of the cycle in the expected range.
  var expectedDays: (Int, Int)? {
    guard let values = values, dayOfCycle != nil else {
      return nil
    }
    return (
      days(from: values.cycleStart, to: values.nextEarliest) + 1,
      days(from: values.cycleStart, to: values.nextLatest) + 1
    )
  }
}

struct CycleProvider: TimelineProvider {
  func placeholder(in context: Context) -> CycleEntry {
    CycleEntry(date: Date(), values: nil)
  }

  func getSnapshot(in context: Context, completion: @escaping (CycleEntry) -> Void) {
    completion(CycleEntry(date: Date(), values: CycleValues.read()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<CycleEntry>) -> Void) {
    let values = CycleValues.read()
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    // One entry a day for two weeks: the number changes at midnight even if
    // the app is never opened.
    let entries = (0..<14).compactMap { offset -> CycleEntry? in
      guard let date = calendar.date(byAdding: .day, value: offset, to: today) else {
        return nil
      }
      return CycleEntry(date: offset == 0 ? Date() : date, values: values)
    }
    completion(Timeline(entries: entries, policy: .atEnd))
  }
}

/// An arc of the ring, from one day of the cycle to another.
struct RingArc: Shape {
  let fromDay: Int
  let toDay: Int
  let totalDays: Int

  func path(in rect: CGRect) -> Path {
    let total = Double(max(totalDays, 1))
    let first = Double(min(max(fromDay, 1), totalDays))
    let last = Double(min(max(toDay, 1), totalDays))
    var path = Path()
    guard last >= first else {
      return path
    }
    path.addArc(
      center: CGPoint(x: rect.midX, y: rect.midY),
      radius: min(rect.width, rect.height) / 2,
      startAngle: .degrees(-90 + 360 * (first - 1) / total),
      endAngle: .degrees(-90 + 360 * last / total),
      clockwise: false
    )
    return path
  }
}

struct CycleRingView: View {
  let entry: CycleEntry

  // The colours of the app: night blue, amber for what is estimated, a quiet
  // burgundy for the period.
  private let ink = Color(red: 0.106, green: 0.165, blue: 0.290)
  private let amber = Color(red: 0.714, green: 0.478, blue: 0.078)
  private let burgundy = Color(red: 0.478, green: 0.180, blue: 0.231)
  private let paper = Color(red: 0.980, green: 0.941, blue: 0.855)

  private let stroke: CGFloat = 11

  var body: some View {
    let total = entry.totalDays
    ZStack {
      Circle().stroke(Color.white.opacity(0.9), lineWidth: stroke)
      if let day = entry.dayOfCycle {
        if let expected = entry.expectedDays {
          RingArc(fromDay: expected.0, toDay: expected.1, totalDays: total)
            .stroke(amber, lineWidth: stroke)
        }
        if let period = entry.values?.periodLength, period > 0 {
          RingArc(fromDay: 1, toDay: period, totalDays: total)
            .stroke(burgundy, lineWidth: stroke)
        }
        Text("\(day)")
          .font(.system(size: 40, weight: .heavy, design: .rounded))
          .foregroundColor(ink)
          .minimumScaleFactor(0.5)
          .lineLimit(1)
          .padding(18)
      } else {
        Text("–")
          .font(.system(size: 40, weight: .heavy, design: .rounded))
          .foregroundColor(ink)
      }
    }
    .padding(stroke / 2 + 6)
    .widgetBackground(paper)
  }
}

extension View {
  /// The background of a widget, in the way each version of iOS expects it.
  @ViewBuilder
  func widgetBackground(_ color: Color) -> some View {
    if #available(iOS 17.0, *) {
      containerBackground(for: .widget) { color }
    } else {
      background(color)
    }
  }
}

@main
struct FycleWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "FycleWidget", provider: CycleProvider()) { entry in
      CycleRingView(entry: entry)
    }
    .configurationDisplayName("Cycle")
    .description("")
    .supportedFamilies([.systemSmall])
  }
}
