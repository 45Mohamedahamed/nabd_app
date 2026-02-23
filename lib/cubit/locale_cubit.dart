import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// الحالة (State)
class LocaleState {
  final Locale locale;
  LocaleState(this.locale);
}

// الكيوبت (Logic)
class LocaleCubit extends Cubit<LocaleState> {
  // اللغة الافتراضية العربية
  LocaleCubit() : super(LocaleState(const Locale('ar')));

  void changeLanguage(String langCode) {
    emit(LocaleState(Locale(langCode)));
  }
}
