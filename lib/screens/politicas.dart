import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:patimovil_rider/utils/brand_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PoliticasDePrivacidadPage extends StatefulWidget {
  PoliticasDePrivacidadPage({Key key}) : super(key: key);

  @override
  _PoliticasDePrivacidadPageState createState() =>
      _PoliticasDePrivacidadPageState();
}

class _PoliticasDePrivacidadPageState extends State<PoliticasDePrivacidadPage> {
  Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Politicas de Privacidad'),
        backgroundColor: BrandColors.patiSecundary,
      ),
      body: WebView(
        initialUrl: 'https://patimovil.net/legal/POLITICAS_DE_PRIVACIDAD.html',
      ),
    );
  }
}
