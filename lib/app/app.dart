import 'package:mydairy/app/config/di/di.dart';
import 'package:mydairy/app/config/l10n/arb/app_localizations.dart';
import 'package:mydairy/app/config/routes/app_router.dart';
import 'package:mydairy/app/core/cubit/appearance_cubit.dart';
import 'package:mydairy/app/core/services/storage_service.dart';
import 'package:mydairy/app/config/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyDairyApp extends StatelessWidget {
  const MyDairyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppearanceCubit>(
      create: (_) => AppearanceCubit(getIt<StorageService>()),
      child: const AppView(),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late final router = AppRouter().router;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppearanceCubit, AppearanceState>(
      builder: (context, state) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          theme: AppTheme.themeLight(state.language),
          darkTheme: AppTheme.darkTheme(state.language),
          themeMode: state.theme.mode,
          locale: state.language.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}
