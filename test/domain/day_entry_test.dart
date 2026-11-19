import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/libido_level.dart';
import 'package:fycle/domain/mood.dart';
import 'package:fycle/domain/pain_level.dart';
import 'package:fycle/domain/sleep_quality.dart';
import 'package:fycle/domain/symptom.dart';

void main() {
  final day = CalendarDay(2026, 3, 5);

  group('DayEntry', () {
    test('is empty when nothing was logged', () {
      expect(DayEntry(day: day).isEmpty, isTrue);
      expect(DayEntry(day: day, note: '   ').isEmpty, isTrue);
    });

    test('is not empty as soon as one field is set', () {
      expect(DayEntry(day: day, flow: FlowIntensity.light).isEmpty, isFalse);
      expect(DayEntry(day: day, pain: PainLevel.none).isEmpty, isFalse);
      expect(DayEntry(day: day, mood: Mood.calm).isEmpty, isFalse);
      expect(DayEntry(day: day, sleep: SleepQuality.good).isEmpty, isFalse);
      expect(DayEntry(day: day, libido: LibidoLevel.low).isEmpty, isFalse);
      expect(DayEntry(day: day, symptoms: {Symptom.acne}).isEmpty, isFalse);
      expect(DayEntry(day: day, note: 'Tired').isEmpty, isFalse);
    });

    test('treats a blank note as no note', () {
      expect(DayEntry(day: day, note: ' \n').note, isNull);
    });

    test('compares by value, whatever the order of symptoms', () {
      final a = DayEntry(
        day: day,
        flow: FlowIntensity.heavy,
        symptoms: {Symptom.cramps, Symptom.fatigue},
      );
      final b = DayEntry(
        day: CalendarDay(2026, 3, 5),
        flow: FlowIntensity.heavy,
        symptoms: {Symptom.fatigue, Symptom.cramps},
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(DayEntry(day: day, flow: FlowIntensity.light)));
      expect(
        DayEntry(day: day, sleep: SleepQuality.poor),
        isNot(DayEntry(day: day, sleep: SleepQuality.good)),
      );
      expect(
        DayEntry(day: day, libido: LibidoLevel.low),
        isNot(DayEntry(day: day, libido: LibidoLevel.high)),
      );
    });

    test('changing the flow keeps everything else', () {
      final entry = DayEntry(
        day: day,
        flow: FlowIntensity.light,
        pain: PainLevel.mild,
        mood: Mood.calm,
        sleep: SleepQuality.fair,
        libido: LibidoLevel.high,
        symptoms: {Symptom.cramps},
        note: 'Tired',
      );
      final changed = entry.withFlow(null);
      expect(changed.flow, isNull);
      expect(changed.withFlow(FlowIntensity.light), entry);
    });

    test('does not let its symptoms be changed afterwards', () {
      final entry = DayEntry(day: day, symptoms: {Symptom.cramps});
      expect(() => entry.symptoms.add(Symptom.acne), throwsUnsupportedError);
    });
  });
}
