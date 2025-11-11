import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/models/ai_agent.dart';
import 'package:humainity_flutter/screens/dashboard/widgets/chat_preview.dart';
import 'package:humainity_flutter/screens/dashboard/widgets/preset_agent_card.dart';
import 'package:humainity_flutter/widgets/ui/app_badge.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:humainity_flutter/widgets/ui/app_dropdown.dart';
import 'package:humainity_flutter/widgets/ui/app_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';

// --- Riverpod State Providers ---

// 1. Tracks the currently selected agent ID.
final selectedAgentIdProvider =
    StateProvider<String>((ref) => presetAgents.first.id);

// 2. Tracks the current persona/role text in the text field.
final personaTextProvider =
    StateProvider<String>((ref) => presetAgents.first.role);

// 3. Tracks the agent's name, used in the top text field.
final agentNameProvider =
    StateProvider<String>((ref) => presetAgents.first.name);

// 4. Tracks the custom image path (for custom agent). Using String for asset/network path.
final customImagePathProvider = StateProvider<String?>((ref) => null);

// --- AIAgentScreen Widget ---

class AIAgentScreen extends ConsumerWidget {
  const AIAgentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current state from Riverpod
    final selectedAgentId = ref.watch(selectedAgentIdProvider);
    final selectedAgent =
        presetAgents.firstWhere((agent) => agent.id == selectedAgentId);

    // Get the persona text and agent name (which can be customized regardless of preset)
    final personaText = ref.watch(personaTextProvider);
    final agentName = ref.watch(agentNameProvider);
    final customImagePath = ref.watch(customImagePathProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADING: Personalize Your AI Agent
          const Text(
            'Personalize Your AI Agent',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Configure your conversational AI assistant\'s appearance, personality, and core settings.',
            style: TextStyle(color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 24),

          // Responsive Layout (Two columns on desktop, one column on mobile/tablet)
          WebContainer(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Configuration Panels
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildAgentSelectionCard(ref, selectedAgentId),
                      const SizedBox(height: 24),
                      _buildAvatarBrandingCard(
                          ref, selectedAgent, customImagePath),
                      const SizedBox(height: 24),
                      _buildAgentDescriptionCard(
                          ref, selectedAgent, agentName, personaText),
                      const SizedBox(height: 24),
                      _buildLanguageAndToneCard(),
                      // Removed _buildAdvancedSettingsCard() as requested
                      const SizedBox(height: 24),
                      _buildActionButtons(ref),
                    ],
                  ),
                ),

                // Gap between columns on desktop
                if (Responsive.isDesktop(context)) const SizedBox(width: 24),

                // Right Column: Live Branding Preview (takes 1/3 space on desktop)
                if (Responsive.isDesktop(context))
                  Expanded(
                    flex: 1,
                    // FIX: Constrain height to stabilize layout
                    child: SizedBox(
                      height: 700,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Agent Configuration Preview',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: _buildLiveBrandingPreview(
                                selectedAgent, agentName, customImagePath),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Section 1: Agent Selection ---
  Widget _buildAgentSelectionCard(WidgetRef ref, String selectedAgentId) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose a Preconfigured Agent',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Start with a preset, or select "Custom Agent" to define your own avatar and persona.',
            style: TextStyle(color: AppColors.mutedForeground, fontSize: 14),
          ),
          const SizedBox(height: 16),
          // Grid/Wrap of PresetAgentCards
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate cross axis count based on constraints for responsiveness
              final double minWidth = 200;
              final int crossAxisCount =
                  (constraints.maxWidth / (minWidth + 16)).floor().clamp(1, 4);
              final double cardWidth = (constraints.maxWidth / crossAxisCount) -
                  (16 * (crossAxisCount - 1) / crossAxisCount);

              return Wrap(
                spacing: 16, // Horizontal space
                runSpacing: 16, // Vertical space
                children: presetAgents.map((agent) {
                  return SizedBox(
                    width: cardWidth,
                    child: PresetAgentCard(
                      agent: agent,
                      isSelected: agent.id == selectedAgentId,
                      onTap: () {
                        // Update state providers when a new agent is selected
                        ref.read(selectedAgentIdProvider.notifier).state =
                            agent.id;
                        ref.read(agentNameProvider.notifier).state = agent.name;
                        ref.read(personaTextProvider.notifier).state =
                            agent.role;
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- New Section: Avatar & Branding ---
  Widget _buildAvatarBrandingCard(
      WidgetRef ref, AiAgent selectedAgent, String? customImagePath) {
    // Determine the image source based on selection
    final imagePath = selectedAgent.id == 'custom'
        ? (customImagePath ?? 'assets/images/ai-sales-agent.jpg')
        : selectedAgent.imagePath;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.image, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('Avatar & Branding',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),

          // Image Preview
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage(imagePath),
                backgroundColor: AppColors.primary.withOpacity(0.1),
              ),
              const SizedBox(width: 16),

              // Custom Image Uploader (only visible for Custom Agent)
              if (selectedAgent.id == 'custom')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppButton(
                      text: 'Upload from Gallery',
                      icon: const Icon(LucideIcons.image),
                      // Mock action for gallery upload
                      onPressed: () => ref
                          .read(customImagePathProvider.notifier)
                          .state = 'assets/images/agent-david.jpg',
                      style: AppButtonStyle.tertiary,
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      text: 'Take Photo with Camera',
                      icon: const Icon(LucideIcons.camera),
                      // Mock action for camera upload
                      onPressed: () => ref
                          .read(customImagePathProvider.notifier)
                          .state = 'assets/images/agent-maya.jpg',
                      style: AppButtonStyle.tertiary,
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Section 2: Agent Description ---
  Widget _buildAgentDescriptionCard(WidgetRef ref, AiAgent selectedAgent,
      String agentName, String personaText) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.pencil,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text('Describe Agent',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const Spacer(),
              // Hint Button (Only load preset if not custom, as tags handle custom roles)
              if (selectedAgent.id != 'custom')
                AppButton(
                  text: 'Load Preset Role',
                  onPressed: () {
                    // Set the persona text to the selected preset's role description
                    ref.read(personaTextProvider.notifier).state =
                        selectedAgent.role;
                  },
                  color: AppColors.primary,
                  style: AppButtonStyle.tertiary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Agent Name Field
          AppTextField(
            labelText: 'Agent Name',
            hintText: 'e.g., Alex, Sarah',
            initialValue: agentName,
            onChanged: (val) {
              ref.read(agentNameProvider.notifier).state = val;
            },
          ),
          const SizedBox(height: 16),
          // Agent Persona/Role Description Field
          AppTextField(
            labelText: 'Agent Persona/Role Description',
            hintText:
                'Describe in detail how your agent should behave and what its core goal is.',
            maxLines: 8,
            initialValue: personaText,
            onChanged: (val) {
              ref.read(personaTextProvider.notifier).state = val;
            },
          ),
          const SizedBox(height: 16),
          // Dynamic Role Tags
          _buildRoleTags(ref),
        ],
      ),
    );
  }

  // --- New Section: Dynamic Role Tags ---
  Widget _buildRoleTags(WidgetRef ref) {
    final currentPersona = ref.watch(personaTextProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select a Pre-defined Role Tag (Optional)',
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: roleDescriptions.keys.map((tag) {
            // FIX: Accessing roleDescriptions directly now that it's globally available/imported.
            final isSelected = currentPersona == roleDescriptions[tag];
            return InkWell(
              onTap: () {
                // Set text box content to the role description for the selected tag
                ref.read(personaTextProvider.notifier).state =
                    roleDescriptions[tag]!;
              },
              child: AppBadge(
                text: tag,
                color: isSelected ? AppColors.primary : AppColors.muted,
                textColor: isSelected
                    ? AppColors.primaryForeground
                    : AppColors.mutedForeground,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- Section 3: Live Branding Preview ---
  Widget _buildLiveBrandingPreview(
      AiAgent selectedAgent, String agentName, String? customImagePath) {
    // Branding color is fixed based on selected agent/default if custom
    final brandingColor = selectedAgent.primaryColor;
    final imagePath = selectedAgent.id == 'custom'
        ? (customImagePath ?? 'assets/images/ai-sales-agent.jpg')
        : selectedAgent.imagePath;

    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Agent Branding',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
              const SizedBox(height: 12),
              // Chat Button Text
              AppTextField(
                labelText: 'Chat Button Text',
                hintText: 'e.g., Talk to Alex',
                // Using a generic variable name since provider storage is complex
                initialValue: 'Chat with $agentName',
                onChanged: (val) {
                  // TODO: Store button text in a separate provider
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Chat Preview Widget
        Expanded(
          child: AppCard(
            padding: EdgeInsets.zero,
            child: ChatPreview(
              agentName: agentName,
              agentImage: imagePath,
              primaryColor: brandingColor,
            ),
          ),
        ),
      ],
    );
  }

  // --- Utility Widgets (Reused from original) ---
  Widget _buildLanguageAndToneCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.slidersHorizontal,
                  color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('Conversation Settings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppDropdown<String>(
                  labelText: 'Default Language',
                  hint: const Text('Select a Language'),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'es', child: Text('Spanish')),
                  ],
                  onChanged: (val) {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppDropdown<String>(
                  labelText: 'Default Tone',
                  // hint: const Text('Select a Tone'),
                  items: const [
                    DropdownMenuItem(
                        value: 'friendly', child: Text('Friendly')),
                    DropdownMenuItem(value: 'formal', child: Text('Formal')),
                  ],
                  onChanged: (val) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // --- Action Buttons ---
  Widget _buildActionButtons(WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Reset Button
        AppButton(
          text: 'Reset to Default',
          onPressed: () {
            // Reset all state providers to their initial first-agent values
            ref.read(selectedAgentIdProvider.notifier).state =
                presetAgents.first.id;
            ref.read(agentNameProvider.notifier).state =
                presetAgents.first.name;
            ref.read(personaTextProvider.notifier).state =
                presetAgents.first.role;
          },
          // FIX: Use style: AppButtonStyle.tertiary
          style: AppButtonStyle.tertiary,
        ),
        const SizedBox(width: 16),
        // Save Button
        AppButton(
          text: 'Save Changes',
          onPressed: () {
            // TODO: Implement save logic here, likely calling an AgentRepository method
            final currentConfig = {
              'agentId': ref.read(selectedAgentIdProvider),
              'name': ref.read(agentNameProvider),
              'persona': ref.read(personaTextProvider),
            };
            print('Saving Agent Configuration: $currentConfig');
          },
        ),
      ],
    );
  }
}
