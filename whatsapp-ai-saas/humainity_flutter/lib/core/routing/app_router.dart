import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:humainise_ai/core/providers/auth_provider.dart';
import 'package:humainise_ai/screens/auth/auth_screen.dart';
import 'package:humainise_ai/screens/dashboard/actions_screen.dart';
import 'package:humainise_ai/screens/dashboard/agent_preview_screen.dart';
import 'package:humainise_ai/screens/dashboard/ai_agent_screen.dart';
import 'package:humainise_ai/screens/dashboard/campaign_detail_screen.dart';
import 'package:humainise_ai/screens/dashboard/campaign_screen.dart';
import 'package:humainise_ai/screens/dashboard/crm_screen.dart';
import 'package:humainise_ai/screens/dashboard/customer_detail_screen.dart';
import 'package:humainise_ai/screens/dashboard/dashboard_home_screen.dart';
import 'package:humainise_ai/screens/dashboard/dashboard_screen.dart';
import 'package:humainise_ai/screens/dashboard/forms_screen.dart';
import 'package:humainise_ai/screens/dashboard/integrations_screen.dart';
import 'package:humainise_ai/screens/dashboard/knowledge_screen.dart';
import 'package:humainise_ai/screens/dashboard/settings_screen.dart';
import 'package:humainise_ai/screens/dashboard/templates_screen.dart';
import 'package:humainise_ai/screens/dashboard/train_agent_screen.dart';
import 'package:humainise_ai/screens/dashboard/widgets/iframe_view.dart.dart';
import 'package:humainise_ai/screens/home/home_screen.dart';
import 'package:humainise_ai/screens/home/widgets/experience_demo_screen.dart';
import 'package:humainise_ai/screens/industries/industries_screen.dart';
import 'package:humainise_ai/screens/industries/industry_detail_screen.dart';
import 'package:humainise_ai/screens/not_found_screen.dart';
import 'package:humainise_ai/screens/dashboard/mini_crm_screen.dart';
import 'package:humainise_ai/screens/demo/demo_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'DashboardShell');

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  String initialLoc;
  if (kIsWeb) {
    initialLoc = Uri.base.fragment.isEmpty ? '/' : Uri.base.fragment;
  } else {
    initialLoc = '/';
  }

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLoc,
    errorBuilder: (context, state) => const NotFoundScreen(),

    /// Refresh router whenever auth state changes
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authNotifierProvider.notifier).streamController.stream,
    ),

    redirect: (BuildContext context, GoRouterState state) {
      if (!authState.isInitialized) return null;
      final bool isLoggedIn = authState.isAuthenticated;
      final String location = state.matchedLocation;

      final bool isPublicRoute = location == '/' ||
          location == '/auth' ||
          location == '/industries';
      final bool isDashboardRoute = location.startsWith('/dashboard');

      if (!isLoggedIn && isDashboardRoute) {
        return '/auth';
      }
      if (isLoggedIn && isPublicRoute) {
        return '/dashboard/ai-agent';
      }
  if (!isLoggedIn && location == '/demo') {
        return '/demo';
      }
      return null;
    },

    routes: [
      GoRoute(
        path: '/demo',
        builder: (context, state) => const DemoPage(),
      ),
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
        path: '/industries/:id',
        builder: (context, state) =>
            IndustryDetailScreen.fromRoute(context, state),
      ),
      GoRoute(
        path: '/experience-demo',
        builder: (context, state) => const ExperienceDemoScreen(),
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
                path: 'mini-crm',
                builder: (context, state) => const CommonIframeView(
                  title: 'Mini CRM',
                  targetUrl: 'http://localhost:8788/app/customer',
                ),
              ),
              GoRoute(
                path: 'leads',
                builder: (context, state) => const CommonIframeView(
                  title: 'Leads',
                  targetUrl: 'http://localhost:8788/app/lead',
                ),
              ),
              GoRoute(
                path: 'ext-campaigns',
                builder: (context, state) => const CommonIframeView(
                  title: 'External Campaigns',
                  targetUrl: 'http://localhost:8788/app/campaign',
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
