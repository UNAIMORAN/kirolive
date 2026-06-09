import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../locale_controller.dart';
import '../theme.dart';

/// Idiomas disponibles, cada uno en su propio nombre (no se traducen).
const _languages = <(String, String)>[
  ('eu', 'Euskara'),
  ('es', 'Castellano'),
  ('en', 'English'),
];

/// Hoja inferior para elegir el idioma de la app. Aplica el cambio al instante
/// (la app se reconstruye sola) y lo recuerda.
Future<void> showLanguagePicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      final l = AppLocalizations.of(ctx);
      final current = localeController.locale.languageCode;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(l.language, style: Theme.of(ctx).textTheme.titleMedium),
            ),
            for (final (code, name) in _languages)
              ListTile(
                title: Text(name),
                trailing: code == current
                    ? const Icon(Icons.check_rounded, color: AppColors.accent)
                    : null,
                onTap: () {
                  localeController.setLocale(Locale(code));
                  Navigator.of(ctx).pop();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
