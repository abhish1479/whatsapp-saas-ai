import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:humainity_flutter/core/providers/auth_provider.dart';
import 'package:humainity_flutter/screens/auth/auth_screen.dart';
import 'package:humainity_flutter/screens/dashboard/actions_screen.dart';
import 'package:humainity_flutter/screens/dashboard/agent_preview_screen.dart';
import 'package:humainity_flutter/screens/dashboard/ai_agent_screen.dart';
import 'package:humainity_flutter/screens/dashboard/campaign_detail_screen.dart';
import 'package:humainity_flutter/screens/dashboard/campaign_screen.dart';
import 'package:humainity_flutter/screens/dashboard/crm_screen.dart';
import 'package:humainity_flutter/screens/dashboard/customer_detail_screen.dart';
import 'package:humainity_flutter/screens/dashboard/dashboard_home_screen.dart';
import 'package:humainity_flutter/screens/dashboard/dashboard_screen.dart';
import 'package:humainity_flutter/screens/dashboard/forms_screen.dart';
import 'package:humainity_flutter/screens/dashboard/integrations_screen.dart';
import 'package:humainity_flutter/screens/dashboard/knowledge_screen.dart';
import 'package:humainity_flutter/screens/dashboard/settings_screen.dart';
import 'package:humainity_flutter/screens/dashboard/templates_screen.dart';
import 'package:humainity_flutter/screens/dashboard/train_agent_screen.dart';
import 'package:humainity_flutter/screens/home/home_screen.dart';
import 'package:humainity_flutter/screens/industries/industries_screen.dart';
import 'package:humainity_flutter/screens/industries/industry_detail_screen.dart';
import 'package:humainity_flutter/screens/not_found_screen.dart';

final _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'DashboardShell');

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => const NotFoundScreen(),

    /// Refresh router whenever auth state changes
   refreshListenable: GoRouterRefreshStream(
  ref.watch(authNotifierProvider.notifier).streamController.stream,
),

    redirect: (BuildContext context, GoRouterState state) {
      final bool isLoggedIn = authState.isAuthenticated;
      final bool isAuthRoute = state.matchedLocation == '/auth';
      final bool isDashboardRoute =
          state.matchedLocation.startsWith('/dashboard');

      // If not logged in, redirect away from dashboard routes
      if (!isLoggedIn && isDashboardRoute) return '/auth';

      // If logged in and at /auth, redirect to dashboard
      if (isLoggedIn && isAuthRoute) return '/dashboard';

      return null; // No redirect needed
    },

    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/industries',
        builder: (context, state) => const IndustriesScreen(),
      ),
      GoRoute(
        path: '/industries/:industryId',
        builder: (context, state) => IndustryDetailScreen(
          industryId: state.pathParameters['industryId']!,
        ),
      ),

      // ----- Dashboard Shell -----
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return DashboardScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardHomeScreen(),
            routes: [
              GoRoute(
                path: 'ai-agent',
                builder: (context, state) => const AIAgentScreen(),
              ),
              GoRoute(
                path: 'agent-preview',
                builder: (context, state) => const AgentPreviewScreen(),
              ),
              GoRoute(
                path: 'train-agent',
                builder: (context, state) => const TrainAgentScreen(),
              ),
              GoRoute(
                path: 'knowledge',
                builder: (context, state) => const KnowledgeScreen(),
              ),
              GoRoute(
                path: 'actions',
                builder: (context, state) => const ActionsScreen(),
              ),
              GoRoute(
                path: 'forms',
                builder: (context, state) => const FormsScreen(),
              ),
              GoRoute(
                path: 'templates',
                builder: (context, state) => const TemplatesScreen(),
              ),
              GoRoute(
                path: 'campaigns',
                builder: (context, state) => const CampaignScreen(),
              ),
              GoRoute(
                path: 'campaigns/:id',
                builder: (context, state) => CampaignDetailScreen(
                  campaignId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: 'crm',
                builder: (context, state) => const CRMScreen(),
              ),
              GoRoute(
                path: 'crm/:id',
                builder: (context, state) => CustomerDetailScreen(
                  customerId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: 'integrations',
                builder: (context, state) => const IntegrationsScreen(),
              ),
              GoRoute(
                path: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// ✅ Helper to rebuild GoRouter when Riverpod provider emits new state
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
