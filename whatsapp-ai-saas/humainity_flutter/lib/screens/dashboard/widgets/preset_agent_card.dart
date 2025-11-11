import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/models/ai_agent.dart';

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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            // Highlight border based on selection and agent color
            color: isSelected ? agent.primaryColor : AppColors.border,
            width: isSelected ? 3.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: agent.primaryColor.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Agent Avatar (using AssetImage since you provided local paths)
            CircleAvatar(
              radius: 28,
              backgroundColor: agent.primaryColor.withOpacity(0.1),
              backgroundImage: AssetImage(agent.imagePath),
              // Use a placeholder icon for the "Custom" agent
              child: agent.id == 'custom'
                  ? const Icon(Icons.palette,
                      color: AppColors.mutedForeground, size: 28)
                  : null,
            ),
            const SizedBox(height: 12),
            // Agent Name
            Text(
              agent.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            // Agent Persona
            Text(
              agent.persona,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
