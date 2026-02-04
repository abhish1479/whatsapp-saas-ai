import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:humainise_ai/config.dart';
import 'package:humainise_ai/screens/home/widgets/navigation.dart';
import 'package:humainise_ai/screens/home/widgets/hero_section.dart';
import 'package:humainise_ai/screens/home/widgets/why_humainity_section.dart';
import 'package:humainise_ai/screens/home/widgets/solutions_section.dart';
import 'package:humainise_ai/screens/home/widgets/meet_agents_section.dart';
import 'package:humainise_ai/screens/home/widgets/experience_demo_screen.dart';
import 'package:humainise_ai/screens/home/widgets/how_it_works_section.dart';
import 'package:humainise_ai/screens/home/widgets/features_section.dart';
import 'package:humainise_ai/screens/home/widgets/dashboard_preview_section.dart';
import 'package:humainise_ai/screens/home/widgets/pricing_section.dart';
import 'package:humainise_ai/screens/home/widgets/testimonials_section.dart';
import 'package:humainise_ai/screens/home/widgets/footer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  final heroKey = GlobalKey();
  final whyKey = GlobalKey();
  final solutionsKey = GlobalKey();
  final agentsKey = GlobalKey();
  final experienceKey = GlobalKey();
  final howKey = GlobalKey();
  final featuresKey = GlobalKey();
  final dashboardKey = GlobalKey();
  final pricingKey = GlobalKey();
  final testimonialsKey = GlobalKey();
  final footerKey = GlobalKey();

  void scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;

    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: HomeNavigation(
          onFeaturesTap: () => scrollTo(featuresKey),
          onSolutionsTap: () => scrollTo(solutionsKey),
          onHowItWorksTap: () => scrollTo(howKey),
          onPricingTap: () => scrollTo(pricingKey),
          onTestimonialsTap: () => scrollTo(testimonialsKey),
          onAgentsTap: () => scrollTo(agentsKey),
          onExperienceTap: () => scrollTo(experienceKey),
        ),
      ),
      // -------------------------------
      // MOBILE DRAWER
      // -------------------------------
      endDrawer: isMobile(context)
          ? Drawer(
              child: SafeArea(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  children: [
                    const Text(
                      "HumAInise.ai",
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      title: const Text("Features"),
                      onTap: () {
                        Navigator.pop(context);
                        scrollTo(featuresKey);
                      },
                    ),
                    ListTile(
                      title: const Text("Solutions"),
                      onTap: () {
                        Navigator.pop(context);
                        scrollTo(solutionsKey);
                      },
                    ),
                    ListTile(
                      title: const Text("How It Works"),
                      onTap: () {
                        Navigator.pop(context);
                        scrollTo(howKey);
                      },
                    ),
                    // ListTile(
                    // simran
                    //   title: const Text("Pricing"),
                    //   onTap: () {
                    //     Navigator.pop(context);
                    //     scrollTo(pricingKey);
                    //   },
                    // ),
                    ListTile(
                      title: const Text("Testimonials"),
                      onTap: () {
                        Navigator.pop(context);
                        scrollTo(testimonialsKey);
                      },
                    ),
                    ListTile(
                      title: const Text("Industries"),
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/industries');
                      },
                    ),
                    if (AppConfig.isDemo) const Divider(height: 32),
                    if (AppConfig.isDemo)
                      ListTile(
                        title: const Text("Demo"),
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/demo');
                        },
                      ),
                    // const Divider(height: 32),
                    // ListTile(
                    //   title: const Text("Login"),
                    //   onTap: () {
                    //     Navigator.pop(context);
                    //     context.go('/dashboard/ai-agent');
                    //   },
                    // ),
                  ],
                ),
              ),
            )
          : null,

      // -------------------------------
      // MAIN SCROLL CONTENT
      // -------------------------------
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            HeroSection(key: heroKey),
            WhyHumainitySection(key: whyKey),
            SolutionsSection(key: solutionsKey),
            MeetAgentsSection(key: agentsKey),
            ExperienceDemoScreen(key: experienceKey),
            HowItWorksSection(key: howKey),
            FeaturesSection(key: featuresKey),
            DashboardPreviewSection(key: dashboardKey),
            // PricingSection(key: pricingKey),
            TestimonialsSection(key: testimonialsKey),
            FooterSection(
              key: footerKey,
              onFeaturesTap: () => scrollTo(featuresKey),
              onSolutionsTap: () => scrollTo(solutionsKey),
              onHowItWorksTap: () => scrollTo(howKey),
              onPricingTap: () => scrollTo(pricingKey),
              onTestimonialsTap: () => scrollTo(testimonialsKey),
              onExperienceTap: () => scrollTo(experienceKey),
            ),
          ],
        ),
      ),
    );
  }
}
