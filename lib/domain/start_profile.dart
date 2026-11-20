/// What she says of herself when the app is set up, before her own dates
/// take over. Every answer is optional.
library;

/// Why she uses the app. Several may hold at once.
enum Goal { trackPeriods, understandBody, conceive, perimenopause }

/// What she wants to know, in more detail. Several may hold at once.
enum Wish {
  knowWhen,
  knowUsualRanges,
  fertileWindow,
  afterContraception,
  whatComesBack,
}

/// The contraception she uses, as far as it changes what the app shows.
/// With a hormonal one, bleeding does not follow a natural cycle and an
/// ovulation estimated from dates means nothing.
enum Contraception { none, hormonal, nonHormonal }

/// What she wants to follow day by day, besides her periods. It decides
/// what the journal and the home put first; nothing is ever hidden.
enum Tracked { pain, mood, sleep, libido, symptoms }

/// Whether the number of days between her periods stays about the same.
///
/// FIGO (Munro, Critchley, Fraser, 2018) calls cycles regular when the
/// shortest and the longest differ by no more than 7 to 9 days, depending
/// on age. Here it is her own word for it, not a measure.
enum CycleRegularity { regular, irregular, unknown, noPeriods }

/// A change she noticed in her periods lately.
enum RecentChange {
  heavierFlow,
  lighterFlow,
  lessRegular,
  lengthChanged,
  nothing,
}

/// A usual period length is accepted within this range, in days.
const int minPeriodLength = 1;
const int maxPeriodLength = 14;

/// From this age on, the question about recent changes is asked even when
/// she did not name the perimenopause among her goals. An assumption of the
/// app, set early on purpose: the question costs one tap to pass.
const int recentChangesFromAge = 40;

/// Whether the setup asks about recent changes in her periods.
bool asksAboutRecentChanges({required Set<Goal> goals, int? age}) =>
    goals.contains(Goal.perimenopause) ||
    (age != null && age >= recentChangesFromAge);

/// Whether the app follows what changes from one cycle to the next: the
/// signs to log, and the card of the review. Same condition as the
/// question of the setup.
bool followsCycleChanges({required Set<Goal> goals, int? age}) =>
    asksAboutRecentChanges(goals: goals, age: age);

/// Name under which the phone remembers that the estimate of the fertile
/// window was set from her answers once.
const String fertilityFromAnswers = 'fertility_from_answers';

/// Whether she said anything the estimate of the fertile window depends
/// on.
bool answeredAboutFertility(
  Set<Goal> goals, {
  Set<Wish> wishes = const {},
  Contraception? contraception,
}) => goals.isNotEmpty || wishes.isNotEmpty || contraception != null;

/// Whether the estimate of the fertile window is shown, going by what she
/// answered.
///
/// It is shown to the one who asks for it: she wants to conceive, or she
/// named her fertile window among what she wants to know. Never with a
/// hormonal contraception. Someone who answered and asked for neither does
/// not see it; only someone who answered nothing at all keeps it, as the
/// app shows it by default.
bool showsFertilityFor(
  Set<Goal> goals, {
  Set<Wish> wishes = const {},
  Contraception? contraception,
}) {
  if (contraception == Contraception.hormonal) {
    return false;
  }
  if (goals.isEmpty && wishes.isEmpty) {
    return true;
  }
  return goals.contains(Goal.conceive) || wishes.contains(Wish.fertileWindow);
}

/// Whether the setup asks for dates and lengths of periods at all.
bool hasPeriods(CycleRegularity? regularity) =>
    regularity != CycleRegularity.noPeriods;
