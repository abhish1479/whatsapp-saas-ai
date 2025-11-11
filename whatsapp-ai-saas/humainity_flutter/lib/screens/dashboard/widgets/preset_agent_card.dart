import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/models/ai_agent.dart';
import 'package:lucide_icons/lucide_icons.dart';

// NOTE: Assuming AppColors.foreground and AppColors.mutedForeground are correctly defined.

/// A card widget to display and allow selection of a pre-configured AI agent.
class PresetAgentCard extends StatelessWidget {
  final AiAgent agent;
  final bool isSelected;
  final VoidCallback onTap;

  const PresetAgentCard({
    super.key,
    required this.agent,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Define breakpoints for Web/Desktop view
    final isDesktop = screenWidth >= 1024;

    // Define dimensions and FLEX based on screen size
    // Desktop: Fixed height 500.0
    // FIX: Mobile/Tablet: Must have a fixed height to satisfy the inner Column's Expanded widgets.
    // 'null' was causing the "unbounded height" error on the web (tablet) view.
    final double cardHeight = isDesktop ? 400.0 : 350.0;

    // FLEX RATIOS:
    // Desktop: 4 for image, 1 for text (4:1 ratio)
    // Mobile/Tablet: 3 for image, 2 for text (3:2 ratio)
    final imageFlex = isDesktop ? 4 : 3;
    final textFlex = isDesktop ? 1 : 2;

    // The InkWell wrapper ensures the tap gesture and visual feedback (cursor/splash).
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        // Use fixed height for both desktop and mobile/tablet
        height: cardHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            // Highlight border based on selection
            color: isSelected ? agent.primaryColor : AppColors.border,
            width: isSelected ? 2.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: agent.primaryColor.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        // This Column requires a bounded height from its parent (the Container)
        // because it uses Expanded children.
        child: Column(
          children: [
            // 1. Image Area (Dynamic Height via Flex)
            Expanded(
              flex: imageFlex,
              child: Stack(
                fit: StackFit.expand, // Ensure stack fills the Expanded area
                children: [
                  // Background Image/Color
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: agent.primaryColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(11.0),
                        topRight: Radius.circular(11.0),
                      ),
                      image: DecorationImage(
                        image: AssetImage(agent.imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Selection Tick (Right Top Section of the Image)
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: agent.primaryColor,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // 2. Text/Content Area (Dynamic Height via Flex)
            Expanded(
              flex: textFlex,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Agent Name (Centered)
                    Text(
                      agent.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isDesktop ? 18 : 14,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Agent Persona (Centered and Muted)
                    Text(
                      agent.persona,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.mutedForeground,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
