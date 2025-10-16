import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../api/api.dart';
import '../controller/onboarding_controller.dart';
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
  final controller = Get.find<OnboardingController>();

  final _nameController = TextEditingController();
  final _statusController = TextEditingController();
  final RxString selectedTone = 'Friendly'.obs;
  final RxList<String> selectedLanguages = ['English'].obs;
  final RxString uploadedImageUrl = ''.obs;

  final RxBool enableIncomingVoice = false.obs;
  final RxBool enableOutgoingVoice = false.obs;
  final RxBool enableIncomingMedia = false.obs;
  final RxBool enableOutgoingMedia = false.obs;
  final RxBool enableAIImageAnalysis = false.obs;
  final RxBool loading = false.obs;

  // For unsaved-change detection snapshot
  late Map<String, dynamic> _initialValues;

  @override
  void initState() {
    super.initState();
    _prefillFromController();
  }

  Future<void> _prefillFromController() async {
    loading.value = true;
    try {
      final tid = await StoreUserData().getTenantId();
      await controller.fetchOnboardingData(tid);

      final agent = controller.data?.agentConfiguration;
      if (agent == null) return;

      _nameController.text = agent.agentName;
      _statusController.text = agent.status;
      selectedTone.value = agent.conversationTone;
      uploadedImageUrl.value = agent.agentImage;
      selectedLanguages.value = agent.preferredLanguages
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      enableIncomingVoice.value = agent.incomingVoiceMessageEnabled;
      enableOutgoingVoice.value = agent.outgoingVoiceMessageEnabled;
      enableIncomingMedia.value = agent.incomingMediaMessageEnabled;
      enableOutgoingMedia.value = agent.outgoingMediaMessageEnabled;
      enableAIImageAnalysis.value = agent.imageAnalyzerEnabled;

      // snapshot for back handling
      _initialValues = _currentFormValues;
    } finally {
      loading.value = false;
    }
  }

  /// 🧠 Build a current snapshot of all editable fields
  Map<String, dynamic> get _currentFormValues => {
    'name': _nameController.text.trim(),
    'status': _statusController.text.trim(),
    'tone': selectedTone.value,
    'langs': selectedLanguages.join(','),
    'img': uploadedImageUrl.value,
    'inV': enableIncomingVoice.value,
    'outV': enableOutgoingVoice.value,
    'inM': enableIncomingMedia.value,
    'outM': enableOutgoingMedia.value,
    'ai': enableAIImageAnalysis.value,
  };

  /// ⚙️ Compare current vs initial to detect unsaved changes
  bool get _hasUnsavedChanges {
    final curr = _currentFormValues;
    return curr.toString() != _initialValues.toString();
  }

  Future<void> _saveAndContinue() async {
    if (_nameController.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Agent name is required');
      return;
    }
    if (uploadedImageUrl.value.isEmpty) {
      Get.snackbar('Validation', 'Avatar image is required');
      return;
    }

    loading.value = true;
    try {
      final tid = await StoreUserData().getTenantId();
      final result = await controller.saveAgentConfiguration(
        tenantId: tid,
        agentName: _nameController.text.trim(),
        status: _statusController.text.trim(),
        preferredLanguages: selectedLanguages.join(','),
        conversationTone: selectedTone.value,
        incomingVoiceMessageEnabled: enableIncomingVoice.value,
        outgoingVoiceMessageEnabled: enableOutgoingVoice.value,
        incomingMediaMessageEnabled: enableIncomingMedia.value,
        outgoingMediaMessageEnabled: enableOutgoingMedia.value,
        imageAnalyzerEnabled: enableAIImageAnalysis.value,
        agentImage: uploadedImageUrl.value,
      );

      if (result['status'] == 'error') {
        Get.snackbar('Error', result['detail'] ?? 'Failed to save');
        return;
      }

      _initialValues = _currentFormValues; // reset snapshot after save
      Get.snackbar('Success', 'Agent configuration saved');
      widget.onNext();
    } finally {
      loading.value = false;
    }
  }

  /// 📸 Uploads image and sets only the URL (no bytes)
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    loading.value = true;
    try {
      final bytes = await image.readAsBytes();
      final url = await widget.api.uploadImage(bytes, image.name);
      uploadedImageUrl.value = url;
      Get.snackbar('Success', 'Image uploaded successfully');
    } catch (e) {
      Get.snackbar('Error', 'Upload failed: $e');
    } finally {
      loading.value = false;
    }
  }

  /// 🧭 Handle back press (warn if unsaved)
  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      final shouldLeave = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text('You have unsaved changes. Discard them?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
      if (shouldLeave != true) return false;
    }
    widget.onBack();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Obx(() {
            if (loading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Configure WhatsApp Agent",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Avatar ---
                  Center(
                    child: GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: Obx(() {
                        final img = uploadedImageUrl.value;
                        return CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFFF1F5F9),
                          backgroundImage:
                          img.isNotEmpty ? NetworkImage(img) : null,
                          child: img.isEmpty
                              ? const Icon(Icons.add_a_photo_outlined,
                              color: Color(0xFF94A3B8), size: 36)
                              : null,
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildTextField("Agent Name *", _nameController,
                      "e.g., Arjun - AI Support"),
                  const SizedBox(height: 16),
                  _buildTextField(
                      "Status Message", _statusController, "Online • Ready"),
                  const SizedBox(height: 16),

                  // --- Tone ---
                  const Text("Tone of Conversation",
                      style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: ['Casual', 'Realistic', 'Professional', 'Friendly']
                        .map((tone) => Obx(() {
                      final selected = selectedTone.value == tone;
                      return ChoiceChip(
                        label: Text(tone),
                        selected: selected,
                        selectedColor: const Color(0xFF3B82F6),
                        onSelected: (v) =>
                        selectedTone.value = tone,
                      );
                    }))
                        .toList(),
                  ),

                  const SizedBox(height: 24),

                  // --- Capabilities ---
                  _buildSwitch("Incoming Voice Responses",
                      enableIncomingVoice.value, (v) => enableIncomingVoice(v)),
                  _buildSwitch("Outgoing Voice Responses",
                      enableOutgoingVoice.value, (v) => enableOutgoingVoice(v)),
                  _buildSwitch("Allow Incoming Media",
                      enableIncomingMedia.value, (v) => enableIncomingMedia(v)),
                  _buildSwitch("Allow Outgoing Media",
                      enableOutgoingMedia.value, (v) => enableOutgoingMedia(v)),
                  _buildSwitch(
                      "AI Image Analysis (Complaints)",
                      enableAIImageAnalysis.value,
                          (v) => enableAIImageAnalysis(v)),

                  const SizedBox(height: 30),

                  // --- Buttons ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: widget.onBack,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _saveAndContinue,
                        icon: const Icon(Icons.save),
                        label: const Text('Save & Continue'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile.adaptive(
      title: Text(label),
      value: value,
      onChanged: (v) => setState(() => onChanged(v)),
      activeColor: const Color(0xFF3B82F6),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF1F5F9),
      ),
      child: const Icon(Icons.photo_camera, color: Color(0xFF94A3B8), size: 40),
    );
  }
}
