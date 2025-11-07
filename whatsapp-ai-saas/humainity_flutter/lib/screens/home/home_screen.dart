import 'package:flutter/material.dart';
import 'package:humainity_flutter/screens/home/widgets/dashboard_preview_section.dart';
import 'package:humainity_flutter/screens/home/widgets/features_section.dart';
import 'package:humainity_flutter/screens/home/widgets/footer.dart';
import 'package:humainity_flutter/screens/home/widgets/hero_section.dart';
import 'package:humainity_flutter/screens/home/widgets/how_it_works_section.dart';
import 'package:humainity_flutter/screens/home/widgets/meet_agents_section.dart';
import 'package:humainity_flutter/screens/home/widgets/navigation.dart';
import 'package:humainity_flutter/screens/home/widgets/pricing_section.dart';
import 'package:humainity_flutter/screens/home/widgets/solutions_section.dart';
import 'package:humainity_flutter/screens/home/widgets/testimonials_section.dart';
import 'package:humainity_flutter/screens/home/widgets/why_humainity_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: HomeNavigation(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeroSection(),
            WhyHumainitySection(),
            SolutionsSection(),
            MeetAgentsSection(),
            HowItWorksSection(),
            FeaturesSection(),
            DashboardPreviewSection(),
            PricingSection(),
            TestimonialsSection(),
            Footer(),
          ],
        ),
      ),
    );
  }
}