import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'firebase/inicializador_firebase.dart';
import 'routes/rotas_app.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  await InicializadorFirebase.inicializar();
  runApp(const ProviderScope(child: AppRedatorDeElite()));
}

class AppRedatorDeElite extends ConsumerWidget {
  const AppRedatorDeElite({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roteador = ref.watch(roteadorProvider);
    return MaterialApp.router(
      title: AppConstants.nomeApp,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.tema,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('pt', 'BR'),
      routerConfig: roteador,
    );
  }
}
