import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'providers/language_provider.dart';
import 'app_theme.dart';
import 'screens/splash_screen.dart';

class SalamtakApp extends StatelessWidget {
  const SalamtakApp({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final isArabic = langProvider.isArabic;

    final baseTheme = buildTheme();
    final theme = baseTheme.copyWith(
      textTheme: isArabic
          ? GoogleFonts.cairoTextTheme(baseTheme.textTheme)
          : GoogleFonts.nunitoTextTheme(baseTheme.textTheme),
    );

    return MaterialApp(
      title: 'Salamtak سلامتك',
      debugShowCheckedModeBanner: false,
      theme: theme,
      locale: langProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}
