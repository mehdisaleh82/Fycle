import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/data/fycle_data.dart';
import 'package:fycle/data/fycle_database.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/pain_level.dart';
import 'package:fycle/domain/start_profile.dart';
import 'package:fycle/domain/symptom.dart';

import 'fakes.dart';

void main() {
  test('what she says of herself is kept, and can be forgotten', () {
    final database = FycleDatabase.inMemory();
    addTearDown(database.close);
    expect(database.firstName, isNull);
    expect(database.goals, isEmpty);
    expect(database.regularity, isNull);
    expect(database.usualPeriodLength, isNull);
    expect(database.recentChanges, isEmpty);

    database
      ..firstName = '  Lina '
      ..goals = {Goal.conceive, Goal.trackPeriods}
      ..regularity = CycleRegularity.irregular
      ..usualPeriodLength = 6
      ..recentChanges = {RecentChange.lessRegular};
    expect(database.firstName, 'Lina');
    expect(database.goals, {Goal.conceive, Goal.trackPeriods});
    expect(database.regularity, CycleRegularity.irregular);
    expect(database.usualPeriodLength, 6);
    expect(database.recentChanges, {RecentChange.lessRegular});

    database
      ..firstName = ' '
      ..goals = {}
      ..regularity = null
      ..usualPeriodLength = null
      ..recentChanges = {};
    expect(database.firstName, isNull);
    expect(database.goals, isEmpty);
    expect(database.regularity, isNull);
    expect(database.usualPeriodLength, isNull);
    expect(database.recentChanges, isEmpty);
  });

  test('the other answers of the setup are kept on the phone', () {
    final database = FycleDatabase.inMemory();
    addTearDown(database.close);
    expect(database.wishes, isEmpty);
    expect(database.contraception, isNull);
    expect(database.tracked, isEmpty);
    expect(database.usualFlow, isNull);
    expect(database.usualPain, isNull);
    expect(database.startSigns, isEmpty);

    database
      ..wishes = {Wish.fertileWindow, Wish.knowWhen}
      ..contraception = Contraception.hormonal
      ..tracked = {Tracked.libido, Tracked.sleep}
      ..usualFlow = FlowIntensity.heavy
      ..usualPain = PainLevel.moderate
      ..startSigns = {Symptom.hotFlashes, Symptom.brainFog};
    expect(database.wishes, {Wish.fertileWindow, Wish.knowWhen});
    expect(database.contraception, Contraception.hormonal);
    expect(database.tracked, {Tracked.libido, Tracked.sleep});
    expect(database.usualFlow, FlowIntensity.heavy);
    expect(database.usualPain, PainLevel.moderate);
    expect(database.startSigns, {Symptom.hotFlashes, Symptom.brainFog});

    database
      ..wishes = {}
      ..contraception = null
      ..tracked = {}
      ..usualFlow = null
      ..usualPain = null
      ..startSigns = {};
    expect(database.wishes, isEmpty);
    expect(database.contraception, isNull);
    expect(database.tracked, isEmpty);
    expect(database.usualFlow, isNull);
    expect(database.usualPain, isNull);
    expect(database.startSigns, isEmpty);
  });

  test('a period length that cannot be is refused', () {
    final database = FycleDatabase.inMemory();
    addTearDown(database.close);
    expect(() => database.usualPeriodLength = 0, throwsArgumentError);
    expect(() => database.usualPeriodLength = 15, throwsArgumentError);
  });

  test(
    'what changes the estimate travels with a backup; the rest stays',
    () async {
      final source = FycleDatabase.inMemory();
      addTearDown(source.close);
      source
        ..firstName = 'Lina'
        ..goals = {Goal.conceive}
        ..regularity = CycleRegularity.irregular
        ..usualPeriodLength = 6;

      final bytes = await fastCodec.encode(
        source.readAll(),
        'made-up password',
      );
      final data = await fastCodec.decode(bytes, 'made-up password');
      expect(data.regularity, CycleRegularity.irregular);
      expect(data.usualPeriodLength, 6);

      final target = FycleDatabase.inMemory();
      addTearDown(target.close);
      target.replaceAll(data);
      expect(target.regularity, CycleRegularity.irregular);
      expect(target.usualPeriodLength, 6);
      // Her first name and her goals are settings of the phone.
      expect(target.firstName, isNull);
      expect(target.goals, isEmpty);
    },
  );

  test('a backup made before these questions restores without them', () async {
    final bytes = await fastCodec.encode(sampleData(), 'made-up password');
    final data = await fastCodec.decode(bytes, 'made-up password');
    expect(data.regularity, isNull);
    expect(data.usualPeriodLength, isNull);
    expect(FycleData().regularity, isNull);
  });
}
