import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/widgets/ui/app_avatar.dart';
import 'package:humainity_flutter/widgets/ui/app_badge.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MeetAgentsSection extends StatelessWidget {
  const MeetAgentsSection({super.key});

  static const agents = [
    {
      "name": "Sarah",
      "role": "Customer Support Specialist",
      "image": "assets/images/agent-sarah.jpg",
      "specialty": "Handles queries, complaints, and FAQs with empathy",
      "icon": LucideIcons.messageSquare,
      "badge": "Support",
      "color": AppColors.primary,
    },
    {
      "name": "Alex",
      "role": "Sales Outreach Expert",
      "image": "assets/images/agent-alex.jpg",
      "specialty": "Nurtures leads and converts prospects 24/7",
      "icon": LucideIcons.phone,
      "badge": "Sales",
      "color": AppColors.success,
    },
    {
      "name": "Maya",
      "role": "Campaign Manager",
      "image": "assets/images/agent-maya.jpg",
      "specialty": "Runs WhatsApp campaigns with personalization",
      "icon": LucideIcons.zap,
      "badge": "Marketing",
      "color": AppColors.warning,
    },
    {
      "name": "David",
      "role": "Appointment Coordinator",
      "image": "assets/images/agent-david.jpg",
      "specialty": "Schedules, reminds, and confirms bookings",
      "icon": LucideIcons.star,
      "badge": "Operations",
      "color": AppColors.destructive,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 96, horizontal: 16),
      child: WebContainer(
        child: Column(
          children: [
            const AppBadge(text: 'AI-Powered Team', icon: Icon(LucideIcons.zap)),
            const SizedBox(height: 16),
            const Text(
              'Meet Your AI Agents',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Every agent is trained on your business knowledge, working 24/7 to support and sell for you',
              style: TextStyle(fontSize: 18, color: AppColors.mutedForeground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 64),
            ResponsiveLayout(
              mobile: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: agents.length,
                itemBuilder: (context, index) => _buildAgentCard(agents[index]),
              ),
              desktop: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: agents.length,
                itemBuilder: (context, index) => _buildAgentCard(agents[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentCard(Map<String, dynamic> agent) {
    final color = agent['color'] as Color;
    return AppCard(
      border: Border.all(color: AppColors.border, width: 2),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AppAvatar(
                imageUrl: agent['image'] as String,
                fallbackText: agent['name'] as String,
                radius: 48,
              ),
              Positioned(
                bottom: -8,
                right: -8,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(agent['icon'] as IconData, color: color, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(agent['name'] as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              AppBadge(text: agent['badge'] as String, variant: AppBadgeVariant.secondary),
            ],
          ),
          const SizedBox(height: 8),
          Text(agent['role'] as String, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
            agent['specialty'] as String,
            style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}