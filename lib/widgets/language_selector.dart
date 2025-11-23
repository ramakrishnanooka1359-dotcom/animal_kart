import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animal_kart_demo2/controllers/locale_provider.dart';
import 'package:animal_kart_demo2/l10n/app_localizations.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      tooltip: context.loc.translate('changeLanguage'),
      onSelected: (Locale locale) {
        ref.read(localeProvider.notifier).setLocale(locale);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
        PopupMenuItem<Locale>(
          value: const Locale('en'),
          child: Text(context.loc.translate('english')),
        ),
        PopupMenuItem<Locale>(
          value: const Locale('hi'),
          child: Text(context.loc.translate('hindi')),
        ),
        PopupMenuItem<Locale>(
          value: const Locale('te'),
          child: Text(context.loc.translate('telugu')),
        ),
      ],
    );
  }
}
