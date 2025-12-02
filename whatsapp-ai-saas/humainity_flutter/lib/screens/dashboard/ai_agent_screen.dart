import 'dart:io';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/core/providers/ai_agent_provider.dart';
import 'package:humainity_flutter/core/providers/auth_provider.dart';
import 'package:humainity_flutter/core/storage/store_user_data.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/models/agent_config_model.dart';
import 'package:humainity_flutter/models/ai_agent.dart'; // For presetAgents
import 'package:humainity_flutter/widgets/ui/app_badge.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:humainity_flutter/widgets/ui/app_dropdown.dart';
import 'package:humainity_flutter/widgets/ui/app_text_field.dart';
import 'package:humainity_flutter/screens/dashboard/widgets/chat_preview.dart';
import 'package:humainity_flutter/screens/dashboard/widgets/preset_agent_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

// --- Constants ---
const List<String> _kAccents = ['American', 'British', 'Australian', 'Indian', 'Other'];
const List<String> _kTones = ['Professional', 'Friendly', 'Formal', 'Casual'];
const List<String> _kLanguages = ['English', 'Spanish', 'French', 'Hindi'];
const List<String> _kVoiceModels = ['eleven_turbo_v2_5', 'eleven_multilingual_v2', 'eleven_monolingual_v1'];

class AIAgentScreen extends ConsumerStatefulWidget {
  const AIAgentScreen({super.key});

  @override
  ConsumerState<AIAgentScreen> createState() => _AIAgentScreenState();
}

class _AIAgentScreenState extends ConsumerState<AIAgentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _personaCtrl = TextEditingController();
  final _greetingCtrl = TextEditingController();
  final _accentOtherCtrl = TextEditingController();

  // Dropdown State
  String _selectedTone = 'Professional';
  String _selectedLanguage = 'English';
  String _selectedAccent = 'American';
  String _selectedVoiceModel = 'eleven_turbo_v2_5'; // Default
  String? _selectedPresetId;

  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    // Load agent data on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(agentConfigProvider.notifier).loadAgent();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _personaCtrl.dispose();
    _greetingCtrl.dispose();
    _accentOtherCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      if (kIsWeb) {
        // Web logic if needed later
      } else {
        ref.read(agentConfigProvider.notifier).setLocalImage(File(pickedFile.path));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final agentState = ref.watch(agentConfigProvider);
    final isEditing = agentState.isEditing;
    final agent = agentState.agent;

    // --- Pre-fill Logic (Once Data Arrives) ---
    if (agent != null && !_dataLoaded) {
      _nameCtrl.text = agent.agentName;
      _personaCtrl.text = agent.agentPersona ?? '';
      _greetingCtrl.text = agent.greetingMessage ?? '';

      if (_kTones.contains(agent.conversationTone)) {
        _selectedTone = agent.conversationTone;
      }

      if (_kLanguages.contains(agent.preferredLanguages)) {
        _selectedLanguage = agent.preferredLanguages;
      }

      if (agent.voiceModel != null && _kVoiceModels.contains(agent.voiceModel)) {
        _selectedVoiceModel = agent.voiceModel!;
      }

      if (agent.voiceAccent != null) {
        if (_kAccents.contains(agent.voiceAccent)) {
          _selectedAccent = agent.voiceAccent!;
        } else {
          _selectedAccent = 'Other';
          _accentOtherCtrl.text = agent.voiceAccent!;
        }
      }
      _dataLoaded = true;
    }

    if (agentState.isLoading) {
      return const Center(child: Padding(padding: EdgeInsets.all(64), child: CircularProgressIndicator()));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Title Header ---
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

          // --- Preset Selection (Only show if Creating or explicitly Editing) ---
          if (isEditing)
            _buildAgentSelectionCard(context),

          if (isEditing)
            const SizedBox(height: 24),

          // --- Main Form Area ---
          Form(
            key: _formKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Config Panels
                Expanded(
                  flex: Responsive.isDesktop(context) ? 2 : 1,
                  child: Column(
                    children: [
                      // 1. Avatar Upload (Square & Small)
                      _buildAvatarUploadCard(agentState, context, isEditing),
                      const SizedBox(height: 24),

                      // 2. Description
                      _buildAgentDescriptionCard(context, isEditing),
                      const SizedBox(height: 24),

                      // 3. Conversation Settings
                      _buildConversationSettingsCard(context, isEditing),
                      const SizedBox(height: 24),

                      // 4. Action Buttons
                      _buildActionButtons(agentState, isEditing),
                    ],
                  ),
                ),

                // Right Column: Live Preview (Desktop Only)
                if (Responsive.isDesktop(context)) ...[
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 700,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Live Preview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 16),
                          Expanded(
                            child: _buildLiveBrandingPreview(agentState),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. Agent Selection ---
  Widget _buildAgentSelectionCard(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.bot, color: AppColors.primary, size: 16),
              SizedBox(width: 8),
              Text('Choose a Preconfigured Agent', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: presetAgents.map((agent) {
                  return SizedBox(
                    width: isMobile(context) ? (constraints.maxWidth / 2) - 16 :(constraints.maxWidth / 4) - 16, // 2 items per row approx
                    child: PresetAgentCard(
                      agent: agent,
                      isSelected: agent.id == _selectedPresetId,
                      onTap: () {
                        setState(() {
                          _selectedPresetId = agent.id;
                          _nameCtrl.text = agent.name;
                          _personaCtrl.text = agent.role;

                          // Set Defaults based on Persona Logic
                          if (agent.id == 'agent-sarah') { // Sales
                            _selectedTone = 'Professional';
                            _selectedVoiceModel = 'eleven_turbo_v2_5';
                            _selectedAccent = 'American';
                            _greetingCtrl.text = "Hi, I'm Sarah! I noticed you're interested in our products. Would you like to schedule a quick demo?";
                          } else if (agent.id == 'agent-alex') { // Support
                            _selectedTone = 'Friendly';
                            _selectedVoiceModel = 'eleven_multilingual_v2';
                            _selectedAccent = 'British';
                            _greetingCtrl.text = "Hello there! I'm Alex. I'm here to help you get started or answer any questions you might have.";
                          } else if (agent.id == 'agent-maya') { // Tech
                            _selectedTone = 'Formal';
                            _selectedVoiceModel = 'eleven_monolingual_v1';
                            _selectedAccent = 'Indian';
                            _greetingCtrl.text = "Greetings. I am Maya, your technical support specialist. Please describe the issue you are facing.";
                          } else {
                            _selectedTone = 'Professional'; // Default
                            _selectedVoiceModel = 'eleven_turbo_v2_5';
                            _selectedAccent = 'American';
                            _greetingCtrl.text = "Hello! How can I assist you today?";
                          }
                        });
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

  // --- 2. Avatar Upload (Square & Small & Responsive) ---
  Widget _buildAvatarUploadCard(AgentState state, BuildContext context, bool isEditing) {
    ImageProvider imageProvider;
    if (state.localImageFile != null) {
      imageProvider = FileImage(state.localImageFile!);
    } else if (state.agent?.agentImage != null && state.agent!.agentImage!.isNotEmpty) {
      imageProvider = NetworkImage(state.agent!.agentImage!);
    } else {
      imageProvider = const AssetImage('assets/images/agent-sarah.jpg');
    }

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Square Avatar - Small & Rounded
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(40), // Rounded Square
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
              border: Border.all(color: AppColors.border),
            ),
          ),
          const SizedBox(width: 16),

          // Action / Label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Agent Avatar",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                if (isEditing) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 140,
                    child: AppButton(
                      text: 'Upload',
                      icon: const Icon(LucideIcons.upload, size: 14),
                      onPressed: _pickImage,
                      style: AppButtonStyle.tertiary,
                      isLg: false,
                    ),
                  ),
                ] else
                  const Text(
                    "Visible in chat.",
                    style: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. Description (Name, Persona) ---
  Widget _buildAgentDescriptionCard(BuildContext context, bool isEditing) {
    return Opacity(
      opacity: isEditing ? 1.0 : 0.8,
      child: IgnorePointer(
        ignoring: !isEditing,
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.pencil, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text('Describe Agent', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _nameCtrl,
                labelText: 'Agent Name',
                hintText: 'e.g., Alex, Sarah',
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _personaCtrl,
                labelText: 'Agent Persona / Role',
                hintText: 'Describe behavior and goals...',
                maxLines: 6,
                validator: (v) => v!.length < 10 ? 'Description too short' : null,
              ),
              if (isEditing) ...[
                const SizedBox(height: 16),
                _buildRoleTags(),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleTags() {
    final roleDescriptions = {
      'Sales Lead': 'Act as an aggressive sales lead qualification specialist.',
      'Customer Support': 'Act as a kind and patient customer support representative.',
      'Technical Expert': 'Act as a highly knowledgeable technical expert.',
    };

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: roleDescriptions.keys.map((tag) {
        return InkWell(
          onTap: () => _personaCtrl.text = roleDescriptions[tag]!,
          child: AppBadge(
            text: tag,
            color: AppColors.muted,
            textColor: AppColors.mutedForeground,
          ),
        );
      }).toList(),
    );
  }

  // --- 4. Settings (Greeting, Tone, Voice Model, Voice Accent) ---
  Widget _buildConversationSettingsCard(BuildContext context, bool isEditing) {
    return Opacity(
      opacity: isEditing ? 1.0 : 0.8,
      child: IgnorePointer(
        ignoring: !isEditing,
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.slidersHorizontal, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text('Conversation Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _greetingCtrl,
                labelText: 'Greeting Message',
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Row 1: Tone & Language
              Row(
                children: [
                  Expanded(
                    child: AppDropdown<String>(
                      labelText: 'Tone',
                      value: _selectedTone,
                      items: _kTones.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: isEditing ? (v) => setState(() => _selectedTone = v!) : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppDropdown<String>(
                      labelText: 'Language',
                      value: _selectedLanguage,
                      items: _kLanguages.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: isEditing ? (v) => setState(() => _selectedLanguage = v!) : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Row 2: Voice Model & Accent (New Field Added)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Voice Model
                  Expanded(
                    child: AppDropdown<String>(
                      labelText: 'Voice Model',
                      value: _selectedVoiceModel,
                      items: _kVoiceModels.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: isEditing ? (v) => setState(() => _selectedVoiceModel = v!) : null,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Voice Accent
                  Expanded(
                    child: Column(
                      children: [
                        AppDropdown<String>(
                          labelText: 'Voice Accent',
                          value: _selectedAccent,
                          items: _kAccents.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: isEditing ? (v) => setState(() => _selectedAccent = v!) : null,
                        ),
                        if (_selectedAccent == 'Other') ...[
                          const SizedBox(height: 8),
                          AppTextField(
                            controller: _accentOtherCtrl,
                            labelText: 'Specify Accent',
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 5. Live Preview ---
  Widget _buildLiveBrandingPreview(AgentState state) {
    ImageProvider? image;
    if (state.localImageFile != null) {
      image = FileImage(state.localImageFile!);
    } else if (state.agent?.agentImage != null && state.agent!.agentImage!.isNotEmpty) {
      image = NetworkImage(state.agent!.agentImage!);
    } else {
      image = const AssetImage('assets/images/agent-sarah.jpg');
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: ChatPreview(
        agentName: _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Agent',
        agentImage: image,
        primaryColor: AppColors.primary,
      ),
    );
  }

  // --- 6. Action Buttons ---
  Widget _buildActionButtons(AgentState state, bool isEditing) {
    return Row(
      children: [
        if (!isEditing)
          Expanded(
            child: AppButton(
              text: 'Edit Agent',
              onPressed: () => ref.read(agentConfigProvider.notifier).enableEditing(),
              style: AppButtonStyle.primary,
            ),
          )
        else ...[
          Expanded(
            child: AppButton(
              text: 'Cancel',
              onPressed: () {
                setState(() => _dataLoaded = false); // Allow reload
                ref.read(agentConfigProvider.notifier).cancelEditing();
              },
              style: AppButtonStyle.tertiary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AppButton(
              text: state.isSaving ? 'Saving...' : 'Save Changes',
              isLoading: state.isSaving,
              onPressed: state.isSaving ? null : _submit,
            ),
          ),
        ]
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final store = ref.read(storeUserDataProvider);
      final tenantIdStr = await store?.getTenantId();
      if (tenantIdStr == null) return;

      final finalAccent = _selectedAccent == 'Other' ? _accentOtherCtrl.text : _selectedAccent;

      final config = AgentConfiguration(
        id: ref.read(agentConfigProvider).agent?.id,
        tenantId: int.parse(tenantIdStr),
        agentName: _nameCtrl.text,
        agentPersona: _personaCtrl.text,
        greetingMessage: _greetingCtrl.text,
        conversationTone: _selectedTone,
        preferredLanguages: _selectedLanguage,
        voiceModel: _selectedVoiceModel, // Save new field
        voiceAccent: finalAccent,
        agentImage: ref.read(agentConfigProvider).agent?.agentImage,
      );

      await ref.read(agentConfigProvider.notifier).saveAgent(config);

      await ref.read(authNotifierProvider.notifier).maybeFetchOnboardingStatus();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }
}