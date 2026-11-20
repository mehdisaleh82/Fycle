import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/device_readings.dart';
import '../l10n/app_localizations.dart';
import 'app_environment.dart';
import 'cycle_model.dart';

String _measureLabel(AppLocalizations l10n, DeviceMeasure measure) =>
    switch (measure) {
      DeviceMeasure.sleep => l10n.devicesSleep,
      DeviceMeasure.restingHeartRate => l10n.devicesHeartRate,
      DeviceMeasure.wristTemperature => l10n.devicesTemperature,
    };

IconData _measureIcon(DeviceMeasure measure) => switch (measure) {
  DeviceMeasure.sleep => Icons.bedtime_outlined,
  DeviceMeasure.restingHeartRate => Icons.monitor_heart_outlined,
  DeviceMeasure.wristTemperature => Icons.thermostat_outlined,
};

/// A value in the words and digits of her language.
String deviceValue(
  AppLocalizations l10n,
  DeviceMeasure measure,
  double value,
) => switch (measure) {
  DeviceMeasure.sleep => l10n.devicesSleepValue(
    value.round() ~/ 60,
    value.round() % 60,
  ),
  DeviceMeasure.restingHeartRate => l10n.devicesHeartRateValue(value.round()),
  DeviceMeasure.wristTemperature => l10n.devicesTemperatureValue(
    NumberFormat('0.0', l10n.localeName).format(value),
  ),
};

/// What her watch or her sensors measured, read from the health data of
/// the phone when she asks: sleep, heart rate at rest, temperature at the
/// wrist. Averages of the last days, then the two halves of her cycles
/// side by side.
///
/// Nothing is copied into the app and nothing is sent. The figures are
/// hers, shown as they are: they confirm nothing and explain nothing
/// (CLAUDE.md, rule 7).
class DevicesScreen extends StatefulWidget {
  const DevicesScreen({
    super.key,
    required this.model,
    required this.environment,
  });

  final CycleModel model;
  final AppEnvironment environment;

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  bool _busy = false;
  bool _asked = false;
  List<DeviceDay>? _days;

  Future<void> _read() async {
    setState(() => _busy = true);
    final days = await widget.environment.health.readDeviceDays(
      now: widget.environment.now(),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      _asked = true;
      _days = days;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final days = _days;
    final recent = days == null
        ? const <DeviceAverage>[]
        : recentDeviceAverages(widget.environment.today(), days);
    final halves = days == null
        ? const <HalvesComparison>[]
        : compareCycleHalves(cycles: widget.model.cycles, days: days);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.devicesTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.devicesIntro, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const ValueKey('devices-read'),
                onPressed: _busy ? null : _read,
                icon: const Icon(Icons.watch_outlined),
                label: Text(_asked ? l10n.devicesReadAgain : l10n.devicesRead),
              ),
              if (_asked && (days == null || recent.isEmpty)) ...[
                const SizedBox(height: 16),
                Text(
                  days == null ? l10n.devicesUnavailable : l10n.devicesNothing,
                  key: const ValueKey('devices-empty'),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              if (recent.isNotEmpty) ...[
                const SizedBox(height: 24),
                Semantics(
                  header: true,
                  child: Text(
                    l10n.devicesRecentTitle(deviceRecentDays),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  key: const ValueKey('devices-recent'),
                  child: Column(
                    children: [
                      for (final average in recent)
                        ListTile(
                          key: ValueKey(
                            'devices-recent-${average.measure.name}',
                          ),
                          leading: Icon(_measureIcon(average.measure)),
                          title: Text(
                            deviceValue(l10n, average.measure, average.value),
                          ),
                          subtitle: Text(
                            l10n.devicesAverageOf(
                              _measureLabel(l10n, average.measure),
                              average.days,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              if (halves.isNotEmpty) ...[
                const SizedBox(height: 24),
                Semantics(
                  header: true,
                  child: Text(
                    l10n.devicesHalvesTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  key: const ValueKey('devices-halves'),
                  child: Column(
                    children: [
                      for (final half in halves)
                        ListTile(
                          key: ValueKey('devices-halves-${half.measure.name}'),
                          leading: Icon(_measureIcon(half.measure)),
                          title: Text(_measureLabel(l10n, half.measure)),
                          subtitle: Text(
                            l10n.devicesHalvesLine(
                              deviceValue(
                                l10n,
                                half.measure,
                                half.firstHalf.value,
                              ),
                              deviceValue(
                                l10n,
                                half.measure,
                                half.secondHalf.value,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              if (recent.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.devicesNote,
                  key: const ValueKey('devices-note'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
