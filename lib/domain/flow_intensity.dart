/// How heavy the flow was on a logged day. A day with no flow has no entry.
enum FlowIntensity {
  /// Traces only. Never counts as the start of a period on its own.
  spotting,
  light,
  medium,
  heavy,
}
