import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../api/api.dart';
import '../helper/utils/shared_preference.dart';

class WhatsAppAgentScreen extends StatefulWidget {
  final Api api;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const WhatsAppAgentScreen({
    Key? key,
    required this.api,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  State<WhatsAppAgentScreen> createState() => _WhatsAppAgentScreenState();
}

class _WhatsAppAgentScreenState extends State<WhatsAppAgentScreen> {
  final _nameController = TextEditingController();
  final _statusController = TextEditingController();
  final _testPhoneController = TextEditingController();

  String? _selectedTone = 'Friendly';
  List<String> _selectedLanguages = ['English'];
  File? _profileImage;
  bool _enableOutgoingVoice = false;
  bool _enableIncomingVoice = false;
  bool _enableIncomingMedia = false;
  bool _enableOutgoingMedia = false;
  bool _enableAIImageAnalysis = false;

  bool _loading = false;
  String? _saveMessage;
  bool _isSuccess = false;

  static const List<String> _languages = [
    'English',
    'Hindi',
    'Spanish',
    'French',
    'German'
  ];

  static const List<String> _tones = [
    'Casual',
    'Realistic',
    'Professional',
    'Friendly'
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _saveAndContinue() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agent name is required')),
      );
      return;
    }

    if (_profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar image is required')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _saveMessage = null;
    });

    try {
      final tenantId = await StoreUserData().getTenantId();
      final Map<String, dynamic> payload = {
        "tenant_id": tenantId,
        "agent_name": _nameController.text.trim(),
        "status": _statusController.text.trim(),
        "preferred_languages": _selectedLanguages.join(","),
        "conversation_tone": _selectedTone ?? "Friendly",
        "incoming_voice_message_enabled": _enableIncomingVoice,
        "outgoing_voice_message_enabled": _enableOutgoingVoice,
        "incoming_media_message_enabled": _enableIncomingMedia,
        "outgoing_media_message_enabled": _enableOutgoingMedia,
        "image_analyzer_enabled": _enableAIImageAnalysis,
        "agent_image": _profileImage!.path,
      };

      await widget.api.postJson(
        '/onboarding/agent-configurations',
        payload,
      );

      setState(() {
        _isSuccess = true;
        _saveMessage = "Agent configuration saved!";
      });

      await Future.delayed(const Duration(milliseconds: 800));
      widget.onNext();
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _saveMessage = "Save failed: $e";
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _testAgent() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Test WhatsApp Agent'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter WhatsApp number to test with:'),
            const SizedBox(height: 12),
            TextField(
              controller: _testPhoneController,
              decoration: InputDecoration(
                hintText: '+1234567890',
                prefixIcon: const Icon(Icons.phone, color: Color(0xFF3B82F6)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(ctx).pop,
            child: const Text('Cancel'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () {
                if (_testPhoneController.text.trim().isNotEmpty) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Test message will be sent to ${_testPhoneController.text}'),
                      backgroundColor: const Color(0xFF3B82F6),
                    ),
                  );
                  _testPhoneController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              child: const Text('Send Test'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFE2E8F0),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: kIsWeb ? 700 : size.width * 0.95,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      "Configure WhatsApp Agent",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                            fontSize: 28,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Set up your AI agent's personality, language, and capabilities",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF64748B),
                            fontSize: 16,
                          ),
                    ),
                    const SizedBox(height: 24),

                    // Main Card (all fields)
                    _buildMainCard(),

                    const SizedBox(height: 24),

                    // Buttons Row
                    _buildButtonsRow(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile image
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                ),
                child: _profileImage != null
                    ? ClipOval(
                        child: Image.file(
                          _profileImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF1F5F9),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF94A3B8),
                          size: 40,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Agent Name
          _buildLabel("Agent Name *"),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: _inputDecoration("e.g., Alex - AI Support"),
          ),
          const SizedBox(height: 20),

          // Status
          _buildLabel("Status Message"),
          const SizedBox(height: 8),
          TextField(
            controller: _statusController,
            decoration: _inputDecoration("Online • Ready to help!"),
          ),
          const SizedBox(height: 20),

          // Languages
          _buildLabel("Preferred Languages (Max 3)"),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _languages.map((lang) {
              final isSelected = _selectedLanguages.contains(lang);
              return ChoiceChip(
                label: Text(lang),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      if (_selectedLanguages.length < 3) {
                        _selectedLanguages.add(lang);
                      }
                    } else {
                      _selectedLanguages.remove(lang);
                      if (_selectedLanguages.isEmpty) {
                        _selectedLanguages = ['English'];
                      }
                    }
                  });
                },
                selectedColor: const Color(0xFF3B82F6),
                backgroundColor: const Color(0xFFF1F5F9),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Tone
          _buildLabel("Tone of Conversation"),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _tones.map((tone) {
              return FilterChip(
                label: Text(tone),
                selected: _selectedTone == tone,
                onSelected: (selected) {
                  setState(() {
                    _selectedTone = selected ? tone : null;
                  });
                },
                selectedColor: const Color(0xFF3B82F6),
                backgroundColor: const Color(0xFFF1F5F9),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Capabilities
          _buildLabel("Agent Capabilities"),
          const SizedBox(height: 12),
          _buildToggle('Enable Incoming Voice Message Responses', _enableIncomingVoice,
              (value) => setState(() => _enableIncomingVoice = value)),
          _buildToggle('Enable Outgoing Voice Message Responses', _enableOutgoingVoice,
              (value) => setState(() => _enableOutgoingVoice = value)),
          _buildToggle('Allow Incoming Media Messages', _enableIncomingMedia,
              (value) => setState(() => _enableIncomingMedia = value)),
          _buildToggle('Allow Outgoing Media Messages', _enableOutgoingMedia,
              (value) => setState(() => _enableOutgoingMedia = value)),
          _buildToggle('Analyze User Images with AI (for complaints)', _enableAIImageAnalysis,
              (value) => setState(() => _enableAIImageAnalysis = value)),

          // Save Message
          if (_saveMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isSuccess ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isSuccess ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isSuccess ? Icons.check_circle : Icons.error,
                      color: _isSuccess ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _saveMessage!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _isSuccess ? const Color(0xFF166534) : const Color(0xFFDC2626),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

 Widget _buildButtonsRow() {
  return Wrap(
    spacing: 12, // horizontal gap
    runSpacing: 12, // vertical gap if buttons wrap
    alignment: WrapAlignment.spaceBetween,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      // Back button
      OutlinedButton.icon(
        onPressed: widget.onBack,
        icon: const Icon(Icons.arrow_back, size: 18),
        label: const Text("Back"),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          foregroundColor: const Color(0xFF64748B),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Talk to Me button
      OutlinedButton(
        onPressed: _testAgent,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: Color(0xFF3B82F6)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          foregroundColor: const Color(0xFF3B82F6),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: const Text("Talk to Me"),
      ),

      // Save & Continue button
      Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _loading ? null : _saveAndContinue,
          icon: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.save, size: 18),
          label: Text(_loading ? "Saving..." : "Save & Continue"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ],
  );
}

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E293B),
        fontSize: 16,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildToggle(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile.adaptive(
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontWeight: FontWeight.w500,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF3B82F6),
      contentPadding: EdgeInsets.zero,
    );
  }
}
