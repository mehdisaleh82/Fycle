import 'dart:typed_data';

import 'package:fycle/data/backup_codec.dart';
import 'package:fycle/data/database_key_store.dart';
import 'package:fycle/data/fycle_data.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/mood.dart';
import 'package:fycle/domain/pain_level.dart';
import 'package:fycle/domain/symptom.dart';

/// Stands in for the Keychain / Keystore, which only exist on a phone.
final class InMemoryKeyStore implements DatabaseKeyStore {
  Uint8List? key;

  @override
  Future<Uint8List?> read() async => key;

  @override
  Future<void> write(Uint8List key) async => this.key = key;

  @override
  Future<void> delete() async => key = null;
}

/// Same file format as the app, with a key derivation cheap enough for tests.
const BackupCodec fastCodec = BackupCodec(memoryKib: 64, passes: 1);

/// Made-up data: three logged days and a declared cycle length.
FycleData sampleData() => FycleData(
  usualCycleLength: 29,
  days: [
    DayEntry(
      day: CalendarDay(2026, 3, 5),
      flow: FlowIntensity.medium,
      pain: PainLevel.moderate,
      mood: Mood.irritable,
      symptoms: {Symptom.cramps, Symptom.backPain},
      note: 'Stayed home, "slow" day',
    ),
    DayEntry(day: CalendarDay(2026, 3, 6), flow: FlowIntensity.heavy),
    DayEntry(
      day: CalendarDay(2026, 3, 20),
      mood: Mood.happy,
      note: 'Été, cœur léger',
    ),
  ],
);
