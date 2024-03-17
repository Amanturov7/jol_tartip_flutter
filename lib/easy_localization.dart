import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

class EasyLocalizationController {
  late Locale _deviceLocale;

  Locale get deviceLocale => _deviceLocale;

  void setLocale(Locale locale) {
    _deviceLocale = locale;
  }
}

class _EasyLocalizationState extends State<EasyLocalization> {
  late EasyLocalizationController _controller;

  @override
  void initState() {
    _controller = EasyLocalizationController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: widget.startLocale ?? Locale('ru', 'RU'),
      child: widget.child,
    );
  }
}
