import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fth_admin/core/theme/theme_service.dart';
import 'package:fth_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fth_admin/features/auth/presentation/bloc/auth_state.dart';
import 'package:fth_admin/features/auth/presentation/pages/login_page.dart';
import 'package:fth_admin/features/home/presentation/pages/home_page.dart';
import 'package:fth_admin/features/about/presentation/pages/about_page.dart';
import 'package:fth_admin/features/splash/presentation/pages/splash_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final SideMenuController _sideMenuController = SideMenuController();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        if (authState is Authenticated) {
          return '/home';
        }
        return null;
      },
    ),
    GoRoute(
      path: '/giris',
      builder: (context, state) => const LoginPage(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const MainLayout(
              child: HomePage(),
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
          redirect: (context, state) {
            final authState = context.read<AuthBloc>().state;
            if (authState is! Authenticated) {
              return '/login';
            }
            return null;
          },
        ),
        GoRoute(
          path: '/about',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AboutPage(),
          ),
        ),
      ],
    ),
  ],
  debugLogDiagnostics: true,
  redirect: (context, state) {
    final isLoggedIn = context.read<AuthBloc>().state is Authenticated;
    final isLoginRoute = state.matchedLocation == '/login';
    
    if (!isLoggedIn && !isLoginRoute) {
      return '/login';
    }
    
    if (isLoggedIn && isLoginRoute) {
      return '/home';
    }
    
    return null;
  },
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Sayfa bulunamadı: ${state.uri}'),
    ),
  ),
);

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({Key? key, required this.child}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  void initState() {
    super.initState();
    _sideMenuController.addListener((index) {
      if (index == 0) {
        context.go('/home');
      } else if (index == 1) {
        context.go('/about');
      }
    });
  }


  @override
  void dispose() {
    _sideMenuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FTH Admin'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              if (Scaffold.of(context).isDrawerOpen) {
                Scaffold.of(context).closeDrawer();
              } else {
                Scaffold.of(context).openDrawer();
              }
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              ThemeService.toggleTheme();
              AdaptiveTheme.of(context).toggleThemeMode();
            },
          ),
        ],
      ),
      drawer: SizedBox(
        width: 250,
        child: Drawer(
          child: Column(
            children: [
              // AppBar yüksekliğinde boşluk ekleyerek menünün AppBar'ın altından başlamasını sağlıyoruz
              SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
              Expanded(
                child: SideMenu(
                  controller: _sideMenuController,
                  style: SideMenuStyle(
                    displayMode: SideMenuDisplayMode.open,
                    hoverColor: const Color(0x22FF6B00),
                    selectedColor: const Color(0xFFFF6B00),
                    selectedTitleTextStyle: const TextStyle(color: Colors.white),
                    selectedIconColor: Colors.white,
                    unselectedTitleTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    unselectedIconColor: Theme.of(context).colorScheme.onSurface,
                    decoration: BoxDecoration(
                      color: Theme.of(context).drawerTheme.backgroundColor,
                    ),
                    openSideMenuWidth: 250,
                    compactSideMenuWidth: 70,
                  ),
                  items: [
                    SideMenuItem(
                      title: 'Ana Sayfa',
                      icon: const Icon(Icons.home),
                      onTap: (index, controller) {
                        context.go('/home');
                        Navigator.of(context).pop(); // Drawer'ı kapat
                      },
                    ),
                    SideMenuItem(
                      title: 'Hakkında',
                      icon: const Icon(Icons.info),
                      onTap: (index, controller) {
                        context.go('/about');
                        Navigator.of(context).pop(); // Drawer'ı kapat
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: widget.child,
    );
  }
}
