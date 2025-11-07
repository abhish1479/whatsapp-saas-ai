import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/widgets/ui/app_avatar.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  static const testimonials = [
    {
      "name": "Rajesh Kumar",
      "role": "CEO, TechStart Solutions",
      "content": "HumAInity.ai transformed how we handle customer support. Our response time dropped from hours to minutes, and customer satisfaction increased by 45%.",
      "image": "assets/images/agent-david.jpg",
    },
    {
      "name": "Priya Sharma",
      "role": "Marketing Director, EduLearn Academy",
      "content": "The WhatsApp automation is incredible. We're now reaching 10x more students with personalized messages, and our enrollment rate has skyrocketed.",
      "image": "assets/images/agent-maya.jpg",
    },
    {
      "name": "Amit Patel",
      "role": "Founder, HealthCare Plus",
      "content": "Setting up was so easy! Within days, we had an AI agent handling appointment bookings and patient queries. It's like having a 24/7 team member.",
      "image": "assets/images/agent-alex.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.muted.withOpacity(0.3),
      padding: const EdgeInsets.symmetric(vertical: 96, horizontal: 16),
      child: WebContainer(
        child: Column(
          children: [
            const Text(
              'Trusted by SMBs Nationwide',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'See how businesses like yours are growing with HumAInity.ai',
              style: TextStyle(fontSize: 18, color: AppColors.mutedForeground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 64),
            ResponsiveLayout(
              mobile: Column(
                children: testimonials.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildTestimonialCard(t),
                )).toList(),
              ),
              desktop: Row(
                children: testimonials.map((t) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildTestimonialCard(t),
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialCard(Map<String, dynamic> testimonial) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (_) => const Icon(LucideIcons.star, color: AppColors.primary, size: 20)),
          ),
          const SizedBox(height: 16),
          Text(
            '"${testimonial['content']}"',
            style: const TextStyle(color: AppColors.mutedForeground, fontStyle: FontStyle.italic, fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              AppAvatar(
                imageUrl: testimonial['image'] as String,
                fallbackText: testimonial['name'] as String,
                radius: 24,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(testimonial['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(testimonial['role'] as String, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}