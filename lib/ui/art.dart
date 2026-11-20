import 'package:material_ui/material_ui.dart';

/// A small round picture shown beside a question or a topic. Decoration
/// only: it carries no text and nothing a screen reader needs, so the same
/// file serves every language (CLAUDE.md, rule 11).
///
/// The files are in `assets/art/`, one per value, named after it.
enum Art {
  body,
  calendar,
  cramps,
  cycle,
  energy,
  guide,
  journal,
  lotus,
  private,
  progress,
  reminder,
  sleep,
  trend,
  uterus,
  warmth,
  woman;

  String get asset => 'assets/art/$name.png';
}

class ArtImage extends StatelessWidget {
  const ArtImage(this.art, {super.key, this.size = 72});

  final Art art;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Image.asset(
      art.asset,
      key: ValueKey('art-${art.name}'),
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
    ),
  );
}
