import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';

/// Empty home screen for milestone 0. Replaced by the calendar in milestone 3.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(child: Text(l10n.homePlaceholder)),
    );
  }
}
