import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
// import 'dart:typed_data';
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
  Uint8List? _webImageBytes;

  bool _enableOutgoingVoice = false;
  bool _enableIncomingVoice = false;
  bool _enableIncomingMedia = false;
  bool _enableOutgoingMedia = false;
  bool _enableAIImageAnalysis = false;

  bool _loading = false;
  String? _saveMessage;
  bool _isSuccess = false;
  String? _uploadedImagePath;

  static const List<String> _languages = [
    'English',
    'Hindi',
    'Spanish',
    'French',
    'German',
    'Urdu'
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
    if (image == null) return;
    setState(() => _loading = true);
    try {
    final bytes = await image.readAsBytes();
    final filename = image.name;
    final uploadedPath = await widget.api.uploadImage(bytes, filename);
    setState(() {
      if (kIsWeb) {
        _webImageBytes = bytes;
      } else {
        _profileImage = File(image.path);
      }
      _uploadedImagePath = uploadedPath;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image uploaded successfully'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image upload failed: $e'),
        backgroundColor: Colors.redAccent,
      ),
    );
  } finally {
    if (mounted) setState(() => _loading = false);
  }

    // if (image != null) {
    //   if (kIsWeb) {
    //     final bytes = await image.readAsBytes();
    //     setState(() => _webImageBytes = bytes);
    //   } else {
    //     setState(() => _profileImage = File(image.path));
    //   }
    // }
  }

  Future<void> _saveAndContinue() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agent name is required')));
      return;
    }
    if (_profileImage == null && _webImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar image is required')));
      return;
    }

    setState(() {
      _loading = true;
      _saveMessage = null;
    });

    try {
      final tenantId = await StoreUserData().getTenantId();
      // final String base64Image = kIsWeb
      //     ? base64Encode(_webImageBytes!)
      //     : base64Encode(await _profileImage!.readAsBytes());

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
        "agent_image": _uploadedImagePath,
      };

      await widget.api.postJson('/onboarding/agent-configurations', payload);

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
  final _testNameController = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Test WhatsApp Agent'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter details to test your WhatsApp agent',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _testNameController,
            decoration: InputDecoration(
              hintText: 'Name (optional)',
              prefixIcon: const Icon(Icons.person, color: Color(0xFF8B5CF6)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ✅ 10-digit phone number (without country code)
          TextField(
            controller: _testPhoneController,
            decoration: InputDecoration(
              hintText: '9876543210',
              prefixIcon: const Icon(Icons.phone, color: Color(0xFF3B82F6)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _testPhoneController.clear();
            _testNameController.clear();
            Navigator.of(ctx).pop();
          },
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
            onPressed: () async {
              FocusScope.of(context).unfocus();

              final phone = _testPhoneController.text.trim();
              final name = _testNameController.text.trim();
              final isValid = RegExp(r'^\d{10}$').hasMatch(phone);

              if (!isValid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid 10-digit WhatsApp number.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              Navigator.of(ctx).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sending test message...'),
                  backgroundColor: Color(0xFF3B82F6),
                ),
              );

              try {
                final tenantId = await StoreUserData().getTenantId();

                // ✅ Proper payload structure
                final Map<String, dynamic> payload = {
                  "tenant_id": 2,
                  "recipients": [
                    {
                      "to": "+91$phone",
                      "name": name.isEmpty ? "" : name,
                    }
                  ]
                };

                await widget.api.postJson('/conversation/conversations/talk_to_me', payload);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Test message sent to +91$phone'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to send test: $e'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              } finally {
                _testPhoneController.clear();
                _testNameController.clear();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: const Text('Send Test'),
          ),
        ),
      ],
    ),
  );
}

  // ---------- NEW MULTISELECT MODAL ----------
  Future<void> _showLanguageSelector(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Select up to 3 languages",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  ..._languages.map((lang) {
                    bool selected = _selectedLanguages.contains(lang);
                    bool canSelect = selected || _selectedLanguages.length < 3;
                    return CheckboxListTile(
                      title: Text(lang),
                      value: selected,
                      onChanged: canSelect
                          ? (val) {
                              setModalState(() {
                                setState(() {
                                  if (val == true) {
                                    _selectedLanguages.add(lang);
                                  } else {
                                    _selectedLanguages.remove(lang);
                                  }
                                });
                              });
                            }
                          : null,
                      activeColor: const Color(0xFF3B82F6),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Done"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMultiSelectDropdown() {
    return GestureDetector(
      onTap: () => _showLanguageSelector(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _selectedLanguages.isEmpty
                    ? "Select languages..."
                    : _selectedLanguages.join(", "),
                style: TextStyle(
                  color: _selectedLanguages.isEmpty
                      ? Colors.grey[600]
                      : Colors.black87,
                  fontSize: 16,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }
  // -------------------------------------------

  void _selectTone(String tone, bool selected) {
    setState(() {
      _selectedTone = selected ? tone : _selectedTone ?? 'Friendly';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
          ),
        ),
        child: Center(
          child: Scrollbar(
            thumbVisibility: kIsWeb, // ✅ visible scrollbar on web
            radius: const Radius.circular(12),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                 maxWidth: kIsWeb ? 1200 : 700, // ✅ stretch slightly on web
                  minHeight:
                      MediaQuery.of(context).size.height, // ✅ full height
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Configure WhatsApp Agent",
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                      _buildMainCard(),
                      const SizedBox(height: 24),
                      _buildButtonsRow(),
                    ],
                  ),
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
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        child: Image.file(_profileImage!, fit: BoxFit.cover))
                    : _webImageBytes != null
                        ? ClipOval(
                            child: Image.memory(_webImageBytes!,
                                fit: BoxFit.cover))
                        : Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFF1F5F9),
                            ),
                            child: const Icon(Icons.person,
                                color: Color(0xFF94A3B8), size: 40),
                          ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildLabel("Agent Name *"),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: _inputDecoration("e.g., Arjun - AI Support"),
          ),
          const SizedBox(height: 20),
          _buildLabel("Status Message"),
          const SizedBox(height: 8),
          TextField(
            controller: _statusController,
            decoration: _inputDecoration("Online • Ready to help!"),
          ),
          const SizedBox(height: 20),
          _buildLabel("Preferred Languages (Max 3)"),
          const SizedBox(height: 8),
          _buildMultiSelectDropdown(),
          const SizedBox(height: 12),
          if (_selectedLanguages.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedLanguages.map((lang) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(lang,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() => _selectedLanguages.remove(lang));
                        },
                        child: const Icon(Icons.close,
                            size: 14, color: Colors.white),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 20),
          _buildLabel("Tone of Conversation"),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _tones.map((tone) {
              return FilterChip(
                label: Text(tone),
                selected: _selectedTone == tone,
                onSelected: (selected) => _selectTone(tone, selected),
                selectedColor: const Color(0xFF3B82F6),
                backgroundColor: const Color(0xFFF1F5F9),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _buildLabel("Agent Capabilities"),
          const SizedBox(height: 12),
          _buildToggle(
              'Enable Incoming Voice Message Responses',
              _enableIncomingVoice,
              (v) => setState(() => _enableIncomingVoice = v)),
          _buildToggle(
              'Enable Outgoing Voice Message Responses',
              _enableOutgoingVoice,
              (v) => setState(() => _enableOutgoingVoice = v)),
          _buildToggle('Allow Incoming Media Messages', _enableIncomingMedia,
              (v) => setState(() => _enableIncomingMedia = v)),
          _buildToggle('Allow Outgoing Media Messages', _enableOutgoingMedia,
              (v) => setState(() => _enableOutgoingMedia = v)),
          _buildToggle(
              'Analyze User Images with AI (for complaints)',
              _enableAIImageAnalysis,
              (v) => setState(() => _enableAIImageAnalysis = v)),
          if (_saveMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? const Color(0xFFF0FDF4)
                      : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isSuccess
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFEF4444),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isSuccess ? Icons.check_circle : Icons.error,
                      color: _isSuccess
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFEF4444),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _saveMessage!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _isSuccess
                              ? const Color(0xFF166534)
                              : const Color(0xFFDC2626),
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
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      children: [
        OutlinedButton.icon(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text("Back"),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            foregroundColor: const Color(0xFF64748B),
          ),
        ),
        OutlinedButton(
          onPressed: _testAgent,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            side: const BorderSide(color: Color(0xFF3B82F6)),
            foregroundColor: const Color(0xFF3B82F6),
          ),
          child: const Text("Talk to Me"),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(12),
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
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
          fontSize: 16,
        ),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  Widget _buildToggle(String title, bool value, Function(bool) onChanged) =>
      SwitchListTile.adaptive(
        title: Text(title,
            style: const TextStyle(
                color: Color(0xFF1E293B), fontWeight: FontWeight.w500)),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF3B82F6),
        contentPadding: EdgeInsets.zero,
      );
}
