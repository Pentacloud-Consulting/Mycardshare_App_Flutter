import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_strings.dart';
import 'features/auth/font style/font_style.dart';
import 'providers/auth_provider.dart';
import 'features/internet/no_internet_screen.dart';

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final isOnline = ref.watch(internetConnectionProvider);
    final splashCompleted = ref.watch(splashCompletedProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final scaledChild = AppFontStyle.preventSystemFontScaling(context, child);
        // Show NoInternetScreen only after splash animation finishes and when there is no internet
        final showOfflineScreen = splashCompleted && !isOnline;

        return Stack(
          children: [
            scaledChild,
            if (showOfflineScreen)
              const Positioned.fill(
                child: NoInternetScreen(),
              ),
          ],
        );
      },
    );
  }
}


