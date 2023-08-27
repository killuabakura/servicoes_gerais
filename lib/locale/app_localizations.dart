import 'package:booking_system_flutter/locale/language_ar.dart';
import 'package:booking_system_flutter/locale/language_en.dart';
import 'package:booking_system_flutter/locale/language_hi.dart';
import 'package:booking_system_flutter/locale/languages.dart';
import 'package:booking_system_flutter/locale/language_pt.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import 'languages_de.dart';
import 'languages_fr.dart';

class AppLocalizations extends LocalizationsDelegate<BaseLanguage> {
  const AppLocalizations();

  @override
  Future<BaseLanguage> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'pt':
        return LanguagePt();
      case 'en':
        return LanguageEn();
      case 'ar':
        return LanguageAr();
      case 'hi':
        return LanguageHi();
      case 'fr':
        return LanguageFr();
      case 'de':
        return LanguageDe();

      default:
        return LanguagePt();
    }
  }

  @override
  bool isSupported(Locale locale) =>
      LanguageDataModel.languages().contains(locale.languageCode);

  @override
  bool shouldReload(LocalizationsDelegate<BaseLanguage> old) => false;
}
