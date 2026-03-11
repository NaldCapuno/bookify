/// Shared inset/padding constants for consistent layout across the app.
/// Use these so Save, Cancel, and other action buttons have the same space below.
class AppInsets {
  AppInsets._();

  /// Minimum space below Save/Cancel/primary action buttons in forms and bottom sheets.
  /// Use with [MediaQuery.viewInsets.bottom] for keyboard-aware padding:
  /// `bottom: MediaQuery.viewInsets.bottom + AppInsets.formBottom`
  static const double formBottom = 24.0;

  /// Horizontal padding for form content (e.g. left/right of form body).
  static const double formHorizontal = 24.0;

  /// Top padding for form content when shown in a sheet.
  static const double formTop = 24.0;
}
