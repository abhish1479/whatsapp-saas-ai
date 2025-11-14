import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/models/ai_agent.dart';
import 'package:humainity_flutter/screens/dashboard/widgets/preset_agent_card.dart';
import 'package:humainity_flutter/widgets/ui/app_badge.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:humainity_flutter/widgets/ui/app_dropdown.dart';
import 'package:humainity_flutter/widgets/ui/app_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:humainity_flutter/core/providers/ai_agent_provider.dart';
import 'package:humainity_flutter/models/agent_config_model.dart';
import 'package:humainity_flutter/screens/dashboard/widgets/chat_preview.dart';

// --- AIAgentScreen Widget ---
class AIAgentScreen extends ConsumerStatefulWidget {
  const AIAgentScreen({super.key});

  @override
  ConsumerState<AIAgentScreen> createState() => _AIAgentScreenState();
}

class _AIAgentScreenState extends ConsumerState<AIAgentScreen> {
  // --- ADD FORM KEY FOR VALIDATION ---
  final _formKey = GlobalKey<FormState>();

  // Utility function to handle image picking
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      // Call the notifier method to stage the file
      ref.read(aiAgentProvider.notifier).stageLocalImage(file, pickedFile.path);
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the single state provider
    final agentState = ref.watch(aiAgentProvider);
    final selectedPresetId = agentState.selectedPresetId;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADING
          const Text(
            'Personalize Your AI Agent',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Customize your AI assistant\'s appearance, personality, and behavior.',
            style: TextStyle(color: AppColors.mutedForeground, fontSize: 16),
          ),
          const SizedBox(height: 24),

          // AGENT SELECTION CARD
          _buildAgentSelectionCard(ref, selectedPresetId, context),
          const SizedBox(height: 24),

          // Main Content Area
          agentState.config.when(
            // --- LOADING STATE ---
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(64.0),
                child: CircularProgressIndicator(),
              ),
            ),
            // --- ERROR STATE ---
            error: (error, stack) => Center(
              child: AppCard(
                child: Column(
                  children: [
                    Text('Failed to load configuration: $error',
                        style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Retry',
                      onPressed: () =>
                          ref.read(aiAgentProvider.notifier).fetchAgentConfig(),
                    )
                  ],
                ),
              ),
            ),

            // --- DATA LOADED STATE ---
            data: (config) {
              // isSaving is true if the state is AsyncLoading but still has a value
              final isSaving =
                  agentState.config.isLoading && agentState.config.hasValue;

              return Column(
                children: [
                  // --- WRAP FORM FIELDS IN A FORM WIDGET ---
                  Form(
                    key: _formKey,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Configuration Panels
                        Expanded(
                          flex: Responsive.isDesktop(context) ? 2 : 1,
                          child: Column(
                            children: [
                              _buildAvatarUploadCard(
                                  config, agentState.localImageFile, context),
                              const SizedBox(height: 24),
                              _buildAgentDescriptionCard(ref, config, context),
                              const SizedBox(height: 24),
                              _buildConversationSettingsCard(
                                  ref, config, context),
                              const SizedBox(height: 24),
                              _buildActionButtons(ref, isSaving),
                            ],
                          ),
                        ),

                        // Right Column: Live Preview
                        if (Responsive.isDesktop(context))
                          const SizedBox(width: 24),
                        if (Responsive.isDesktop(context))
                          Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: 700,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Live Preview',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: _buildLiveBrandingPreview(
                                      config,
                                      agentState.localImageFile,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // --- NEW: Default Config Banner Widget ---
  Widget _buildDefaultConfigBanner() {
    return AppCard(
      padding: const EdgeInsets.all(16.0),
      color: AppColors.primary.withOpacity(0.1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.info, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome! Please configure your AI Agent.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your configuration was not found on the server. We have pre-filled the form with the default agent. Please customize the details and click "Save Changes" to activate your new AI assistant.',
                  style: TextStyle(
                    color: AppColors.primary.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. Agent Selection (Responsive Grid/Wrap) ---
  Widget _buildAgentSelectionCard(
      WidgetRef ref, String? selectedPresetId, BuildContext context) {
    // ... (This widget is identical to your provided file) ...
    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // ... (Header row remains the same) ...
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(LucideIcons.bot, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Choose a Preconfigured Agent',
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 18,
                      fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
              'Start with a preset to define your core avatar and persona.',
              style: TextStyle(color: AppColors.mutedForeground, fontSize: 14)),
          const SizedBox(height: 16),

          // Responsive layout implementation
          Builder(builder: (context) {
            // Mobile (2x2 Grid)
            if (Responsive.isMobile(context)) {
              return GridView.builder(
                padding: EdgeInsets.zero,
                itemCount: presetAgents.length,
                shrinkWrap: true,
                primary: false,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.5,
                ),
                itemBuilder: (context, index) {
                  final agent = presetAgents[index];
                  return PresetAgentCard(
                    agent: agent,
                    isSelected: agent.id == selectedPresetId,
                    onTap: () {
                      // Call notifier method
                      ref.read(aiAgentProvider.notifier).selectPreset(agent);
                    },
                  );
                },
              );
            }

            // Desktop / Tablet (Fluid Wrap)
            return LayoutBuilder(
              builder: (context, constraints) {
                // ... (LayoutBuilder logic remains the same) ...
                const double minWidth = 200;
                const double spacing = 16.0;
                final int crossAxisCount =
                    (constraints.maxWidth / (minWidth + spacing))
                        .floor()
                        .clamp(2, 4);

                final double totalSpacing = spacing * (crossAxisCount - 1);
                final double cardWidth =
                    (constraints.maxWidth - totalSpacing) / crossAxisCount;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: presetAgents.map((agent) {
                    return SizedBox(
                      width: cardWidth,
                      child: PresetAgentCard(
                        agent: agent,
                        isSelected: agent.id == selectedPresetId,
                        onTap: () {
                          // Call notifier method
                          ref
                              .read(aiAgentProvider.notifier)
                              .selectPreset(agent);
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  // --- 2. Avatar Upload ---
  Widget _buildAvatarUploadCard(
      AgentConfig config, File? localImageFile, BuildContext context) {
    // Determine the image source
    ImageProvider imageProvider;
    if (localImageFile != null) {
      // 1. Use local staged file
      imageProvider = FileImage(localImageFile);
    } else if (config.agentImage != null && config.agentImage!.isNotEmpty) {
      // 2. Use URL from API
      // Note: Use NetworkImage for http/https URLs, AssetImage for local assets
      if (config.agentImage!.startsWith('http')) {
        imageProvider = NetworkImage(config.agentImage!);
      } else {
        imageProvider = AssetImage(config.agentImage!);
      }
    } else {
      // 3. Fallback (e.g., custom agent 'agent-david' placeholder)
      imageProvider = const AssetImage('assets/images/agent-sarah.jpg');
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.user, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Agent Avatar Configuration',
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 18,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: imageProvider,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                onBackgroundImageError: (exception, stackTrace) =>
                    print('Failed to load image: $exception'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  text: 'Upload Agent Avatar',
                  icon: const Icon(LucideIcons.image),
                  onPressed: () => _pickImage(ImageSource.gallery),
                  style: AppButtonStyle.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 3. Agent Description (WITH VALIDATION) ---
  Widget _buildAgentDescriptionCard(
      WidgetRef ref, AgentConfig config, BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.pencil,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Describe Agent',
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 18,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),

          // Agent Name Field
          AppTextField(
            key: ValueKey('name_${config.agentName}'), // Keeps state in sync
            initialValue: config.agentName,
            labelText: 'Agent Name',
            hintText: 'e.g., Alex, Sarah',
            // --- ADD VALIDATION ---
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Agent Name cannot be empty';
              }
              return null;
            },
            onChanged: (val) =>
                ref.read(aiAgentProvider.notifier).updateAgentName(val),
          ),
          const SizedBox(height: 16),

          // Agent Persona/Role Description Field
          AppTextField(
            key: ValueKey('persona_${config.agentPersona.hashCode}'),
            initialValue: config.agentPersona,
            labelText: 'Agent Persona / Role Description',
            hintText:
                'Describe in detail how your agent should behave and what its core goal is.',
            maxLines: 8,
            // --- ADD VALIDATION ---
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Agent Persona cannot be empty';
              }
              if (value.length < 20) {
                return 'Persona must be at least 20 characters';
              }
              return null;
            },
            onChanged: (val) =>
                ref.read(aiAgentProvider.notifier).updateAgentPersona(val),
          ),
          const SizedBox(height: 16),
          _buildRoleTags(ref, config.agentPersona),
        ],
      ),
    );
  }

  Widget _buildRoleTags(WidgetRef ref, String currentPersona) {
    // ... (This widget remains unchanged) ...
    final roleDescriptions = {
      'Sales Lead':
          'Act as an aggressive sales lead qualification specialist, asking targeted questions.',
      'Customer Support':
          'Act as a kind and patient customer support representative, focusing on solutions.',
      'Technical Expert':
          'Act as a highly knowledgeable technical expert, using precise and detailed language.',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select a Pre-defined Role Tag ',
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: roleDescriptions.keys.map((tag) {
            final isSelected = currentPersona == roleDescriptions[tag];
            return InkWell(
              onTap: () {
                ref
                    .read(aiAgentProvider.notifier)
                    .updateAgentPersona(roleDescriptions[tag]!);
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

  // --- 4. Conversation Settings (WITH VALIDATION) ---
  Widget _buildConversationSettingsCard(
      WidgetRef ref, AgentConfig config, BuildContext context) {
    final selectedLanguageCode = config.preferredLanguages.isNotEmpty
        ? config.preferredLanguages.first
        : 'en';

    const List<Map<String, String>> availableLanguages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'es', 'name': 'Spanish'},
      {'code': 'fr', 'name': 'French'},
      {'code': 'hi', 'name': 'Hindi'},
      {'code': 'ja', 'name': 'Japanese'},
      {'code': 'pt', 'name': 'Portuguese'},
      {'code': 'de', 'name': 'German'},
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.slidersHorizontal,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Conversation Settings',
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 18,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),

          // Greeting Message
          AppTextField(
            key: ValueKey('greeting_${config.greetingMessage.hashCode}'),
            initialValue: config.greetingMessage,
            labelText: 'Agent Greeting Message',
            hintText: 'e.g., Hello! How can I assist you today?',
            maxLines: 2,
            // --- ADD VALIDATION ---
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Greeting Message cannot be empty';
              }
              return null;
            },
            onChanged: (val) =>
                ref.read(aiAgentProvider.notifier).updateGreetingMessage(val),
          ),
          const SizedBox(height: 16),

          // Language and Tone Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppDropdown<String>(
                  labelText: 'Primary Language',
                  value: selectedLanguageCode,
                  items: availableLanguages.map((lang) {
                    return DropdownMenuItem(
                      value: lang['code']!,
                      child: Text(lang['name']!),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(aiAgentProvider.notifier).updateLanguage(val);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppDropdown<String>(
                  labelText: 'Default Tone',
                  value: config.conversationTone,
                  items: const [
                    DropdownMenuItem(
                        value: 'friendly', child: Text('Friendly')),
                    DropdownMenuItem(
                        value: 'professional', child: Text('Professional')),
                    DropdownMenuItem(value: 'formal', child: Text('Formal')),
                    DropdownMenuItem(value: 'casual', child: Text('Casual')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(aiAgentProvider.notifier).updateTone(val);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 5. Live Branding Preview ---
  Widget _buildLiveBrandingPreview(AgentConfig config, File? localImageFile) {
    // Find the associated preset color, or use default
    final preset = presetAgents.firstWhere(
      (p) => p.name == config.agentName,
      orElse: () => presetAgents.last, // Fallback color
    );
    final brandingColor = preset.primaryColor;

    // FIX: Determine the correct STRING PATH for ChatPreview
    String imagePath;
    if (localImageFile != null) {
      // 1. Use the path from the locally staged file
      imagePath = localImageFile.path;
    } else if (config.agentImage != null && config.agentImage!.isNotEmpty) {
      // 2. Use the path from the config (could be asset or network URL)
      imagePath = config.agentImage!;
    } else {
      // 3. Fallback
      imagePath = 'assets/images/agent-david.jpg';
    }

    return Column(
      children: [
        Expanded(
          child: AppCard(
            padding: EdgeInsets.zero,
            child: ChatPreview(
              agentName: config.agentName,
              // FIX: Pass the 'agentImage' string path, not 'agentImageProvider'
              agentImage: imagePath,
              primaryColor: brandingColor,
            ),
          ),
        ),
      ],
    );
  }

  // --- 6. Action Buttons (WITH VALIDATION) ---
  Widget _buildActionButtons(WidgetRef ref, bool isSaving) {
    return Row(
      children: [
        // Reset Button
        Expanded(
          flex: 1,
          child: AppButton(
            text: 'Reset to Default',
            onPressed: isSaving
                ? null
                : () {
                    // A full reset should re-fetch from the server
                    ref.read(aiAgentProvider.notifier).fetchAgentConfig();
                  },
            style: AppButtonStyle.tertiary,
          ),
        ),
        const SizedBox(width: 16),
        // Save Button
        Expanded(
          flex: 1,
          child: AppButton(
            text: isSaving ? 'Saving...' : 'Save Changes',
            onPressed: isSaving
                ? null
                : () async {
                    // --- VALIDATE FORM BEFORE SAVING ---
                    if (!_formKey.currentState!.validate()) {
                      // If form is invalid, show error and stop.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('❌ Please fix errors in the form.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // --- Form is valid, proceed to save ---
                    final scaffoldMessenger = ScaffoldMessenger.of(ref.context);
                    try {
                      await ref
                          .read(aiAgentProvider.notifier)
                          .saveAgentConfig();
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('✅ Configuration Saved!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text('❌ Save failed: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
          ),
        ),
      ],
    );
  }
}
