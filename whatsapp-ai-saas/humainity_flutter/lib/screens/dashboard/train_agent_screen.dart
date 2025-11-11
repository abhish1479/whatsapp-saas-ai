import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/core/providers/chat_provider.dart';
import 'package:humainity_flutter/core/providers/supabase_provider.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart'; // FIX: Added import
import 'package:humainity_flutter/models/guardrail.dart';
// FIX: Removed conflicting import
// import 'package:humainity_flutter/screens/dashboard/widgets/chat_message_bubble.dart';
import 'package:humainity_flutter/widgets/ui/app_badge.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:humainity_flutter/widgets/ui/app_dialog.dart';
import 'package:humainity_flutter/widgets/ui/app_dropdown.dart';
import 'package:humainity_flutter/widgets/ui/app_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:humainity_flutter/widgets/ui/app_avatar.dart';

// FIX: Added missing GuardrailsNotifier class
class GuardrailsNotifier extends StateNotifier<List<Guardrail>> {
  final Ref _ref;
  GuardrailsNotifier(this._ref) : super([]);

  Future<void> fetchGuardrails() async {
    try {
      final data = await _ref
          .read(supabaseClientProvider)
          .from('guardrails')
          .select()
          .order('created_at', ascending: false);
      state = data.map((json) => Guardrail.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching guardrails: $e');
    }
  }

  Future<void> createGuardrail({
    required String type,
    required String description,
    required List<String> keywords,
    required String redirectMessage,
  }) async {
    try {
      final data = await _ref
          .read(supabaseClientProvider)
          .from('guardrails')
          .insert({
            'guardrail_type': type,
            'description': description,
            'keywords': keywords,
            'redirect_message':
                redirectMessage.isEmpty ? null : redirectMessage,
          })
          .select()
          .single();
      state = [Guardrail.fromJson(data), ...state];
    } catch (e) {
      print('Error creating guardrail: $e');
      rethrow;
    }
  }

  Future<void> updateGuardrail(
    String id, {
    required String type,
    required String description,
    required List<String> keywords,
    required String redirectMessage,
  }) async {
    try {
      final data = await _ref
          .read(supabaseClientProvider)
          .from('guardrails')
          .update({
            'guardrail_type': type,
            'description': description,
            'keywords': keywords,
            'redirect_message':
                redirectMessage.isEmpty ? null : redirectMessage,
          })
          .eq('id', id)
          .select()
          .single();
      final updatedGuardrail = Guardrail.fromJson(data);
      state = state.map((g) => g.id == id ? updatedGuardrail : g).toList();
    } catch (e) {
      print('Error updating guardrail: $e');
      rethrow;
    }
  }

  Future<void> deleteGuardrail(String id) async {
    try {
      await _ref
          .read(supabaseClientProvider)
          .from('guardrails')
          .delete()
          .eq('id', id);
      state = state.where((g) => g.id != id).toList();
    } catch (e) {
      print('Error deleting guardrail: $e');
    }
  }
}

final guardrailsProvider =
    StateNotifierProvider<GuardrailsNotifier, List<Guardrail>>((ref) {
  return GuardrailsNotifier(ref);
});

class TrainAgentScreen extends ConsumerStatefulWidget {
  const TrainAgentScreen({super.key});

  @override
  ConsumerState<TrainAgentScreen> createState() => _TrainAgentScreenState();
}

class _TrainAgentScreenState extends ConsumerState<TrainAgentScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _sessionNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sessionNameController.text =
        "Training Session ${DateFormat.yMd().format(DateTime.now())}";
    Future.microtask(
        () => ref.read(guardrailsProvider.notifier).fetchGuardrails());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _sessionNameController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;

    ref.read(chatProvider.notifier).sendMessage(text);
    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    ref.listen(chatProvider, (_, __) => _scrollToBottom());

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ResponsiveLayout(
        // FIX: ResponsiveLayout is now defined
        mobile: _buildMobileLayout(chatState),
        desktop: _buildDesktopLayout(chatState),
      ),
    );
  }

  Widget _buildMobileLayout(ChatState chatState) {
    return Column(
      children: [
        _buildTrainingInfoPanel(chatState),
        const SizedBox(height: 16),
        Expanded(child: _buildChatInterface(chatState)),
      ],
    );
  }

  Widget _buildDesktopLayout(ChatState chatState) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: _buildTrainingInfoPanel(chatState),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: _buildChatInterface(chatState)),
      ],
    );
  }

  Widget _buildTrainingInfoPanel(ChatState chatState) {
    final guardrails = ref.watch(guardrailsProvider);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            labelText: "Session Name",
            controller: _sessionNameController,
          ),
          const SizedBox(height: 16),
          const Text("Training Stats",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Messages:",
                  style: TextStyle(color: AppColors.mutedForeground)),
              Text("${chatState.messages.length}",
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Your messages:",
                  style: TextStyle(color: AppColors.mutedForeground)),
              Text(
                  "${chatState.messages.where((m) => m.role == 'user').length}",
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Agent responses:",
                  style: TextStyle(color: AppColors.mutedForeground)),
              Text(
                  "${chatState.messages.where((m) => m.role == 'assistant').length}",
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const Divider(height: 32),
          _buildGuardrailsSection(guardrails),
          const Divider(height: 32),
          _buildGuardrailExamples(),
          const Divider(height: 32),
          const Text("Training Tips",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          const Text(
              "• Test edge cases and difficult scenarios\n• Provide feedback on responses\n• Try different conversation styles\n• Save successful interactions",
              style: TextStyle(color: AppColors.mutedForeground, fontSize: 14)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: "Clear Chat",
              // FIX: Replaced variant: AppButtonVariant.destructive with setting the destructive color
              color: AppColors.destructive,
              icon: const Icon(LucideIcons.trash2), // FIX: Wrapped in Icon()
              onPressed: () => ref.read(chatProvider.notifier).clearChat(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuardrailsSection(List<Guardrail> guardrails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(LucideIcons.shield, size: 16),
                SizedBox(width: 8),
                Text("Guardrails",
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              ],
            ),
            IconButton(
              icon: const Icon(LucideIcons.plus, size: 16),
              onPressed: () => _showGuardrailDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (guardrails.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text("No guardrails set",
                  style: TextStyle(color: AppColors.mutedForeground)),
            ),
          )
        else
          ...guardrails.map((g) => _buildGuardrailCard(g)),
      ],
    );
  }

  Widget _buildGuardrailCard(Guardrail guardrail) {
    return Card(
      elevation: 0,
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.alertTriangle,
                          size: 12, color: AppColors.destructive),
                      const SizedBox(width: 4),
                      Text(guardrail.description,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  if (guardrail.keywords.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: guardrail.keywords
                          .take(2)
                          .map((kw) => AppBadge(
                              text: kw,
                              color: AppColors.muted)) // FIX: Removed variant
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 14),
              onPressed: () => _showGuardrailDialog(context, guardrail),
            ),
            IconButton(
              icon: const Icon(LucideIcons.x, size: 14),
              onPressed: () => ref
                  .read(guardrailsProvider.notifier)
                  .deleteGuardrail(guardrail.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuardrailExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Guardrail Examples",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        _buildExampleCard(
            "Medical Advice",
            "I'm not qualified to provide medical advice...",
            ["diagnosis", "prescription"]),
        const SizedBox(height: 8),
        _buildExampleCard("Pricing Inquiries",
            "Let me connect you with our sales team...", ["price", "cost"]),
      ],
    );
  }

  Widget _buildExampleCard(String title, String subtitle, List<String> tags) {
    return Card(
      elevation: 0,
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.mutedForeground)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              // FIX: Removed variant, specified colors
              children: tags
                  .map((tag) => AppBadge(
                      text: tag,
                      color: AppColors.muted,
                      textColor: AppColors.mutedForeground))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showGuardrailDialog(BuildContext context, [Guardrail? guardrail]) {
    showAppDialog(
      context: context,
      title: guardrail == null ? "Add Guardrail" : "Edit Guardrail",
      description:
          const Text("Set boundaries for what your agent should never answer."),
      content: GuardrailForm(
        guardrail: guardrail,
        onSubmit: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildChatInterface(ChatState chatState) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(bottom: BorderSide(color: AppColors.border)),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(LucideIcons.bot,
                      color: AppColors.primaryForeground, size: 20),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Training Mode",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    Text("Test and improve your agent's capabilities",
                        style: TextStyle(
                            color: AppColors.mutedForeground, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          // Messages
          SizedBox(
            height: 600, // Fixed height for chat
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final message = chatState.messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  // FIX: ChatMessageBubble is now defined
                  child: ChatMessageBubble(
                    message: message.content,
                    isUser: message.role == 'user',
                    timestamp: message.timestamp,
                  ),
                );
              },
            ),
          ),
          if (chatState.isLoading)
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
              child: Row(
                children: [
                  SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text("Agent is typing...",
                      style: TextStyle(color: AppColors.mutedForeground)),
                ],
              ),
            ),
          // Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.border)),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    labelText: "Training Message", // FIX: Added labelText
                    controller: _messageController,
                    hintText: "Type your training message...",
                    onChanged: (val) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                AppButton(
                  text: 'Send',
                  onPressed: _messageController.text.trim().isEmpty ||
                          chatState.isLoading
                      ? null
                      : _sendMessage,
                  icon: const Icon(LucideIcons.send), // FIX: Wrapped in Icon()
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Separate Form widget for the dialog
class GuardrailForm extends ConsumerStatefulWidget {
  final Guardrail? guardrail;
  final VoidCallback onSubmit;

  const GuardrailForm({this.guardrail, required this.onSubmit, super.key});

  @override
  ConsumerState<GuardrailForm> createState() => _GuardrailFormState();
}

class _GuardrailFormState extends ConsumerState<GuardrailForm> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late TextEditingController _descriptionController;
  late TextEditingController _keywordsController;
  late TextEditingController _redirectMessageController;

  @override
  void initState() {
    super.initState();
    _type = widget.guardrail?.guardrailType ?? 'never_answer';
    _descriptionController =
        TextEditingController(text: widget.guardrail?.description ?? '');
    _keywordsController = TextEditingController(
        text: widget.guardrail?.keywords.join(', ') ?? '');
    _redirectMessageController =
        TextEditingController(text: widget.guardrail?.redirectMessage ?? '');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _keywordsController.dispose();
    _redirectMessageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(guardrailsProvider.notifier);
    final keywords = _keywordsController.text
        .split(',')
        .map((k) => k.trim())
        .where((k) => k.isNotEmpty)
        .toList();

    try {
      if (widget.guardrail == null) {
        await notifier.createGuardrail(
          type: _type,
          description: _descriptionController.text,
          keywords: keywords,
          redirectMessage: _redirectMessageController.text,
        );
      } else {
        await notifier.updateGuardrail(
          widget.guardrail!.id,
          type: _type,
          description: _descriptionController.text,
          keywords: keywords,
          redirectMessage: _redirectMessageController.text,
        );
      }
      widget.onSubmit();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: $e'), backgroundColor: AppColors.destructive),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDropdown<String>(
            labelText: 'Type',
            value: _type,
            onChanged: (val) => setState(() => _type = val!),
            items: const [
              DropdownMenuItem(
                  value: 'never_answer', child: Text('Never Answer')),
              DropdownMenuItem(
                  value: 'always_redirect', child: Text('Always Redirect')),
              DropdownMenuItem(
                  value: 'sensitive_topic', child: Text('Sensitive Topic')),
            ],
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _descriptionController,
            labelText: 'Description',
            hintText: 'e.g., Medical advice questions',
            validator: (val) => val!.isEmpty ? 'Description is required' : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _keywordsController,
            labelText: 'Keywords (comma-separated)',
            hintText: 'diagnosis, prescription, symptoms',
            maxLines: 3,
            validator: (val) => val!.isEmpty ? 'Keywords are required' : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _redirectMessageController,
            labelText: 'Redirect Message (optional)',
            hintText: "I'm not qualified to provide...",
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                text: 'Cancel',
                // FIX: Replaced variant: AppButtonVariant.outline with style: AppButtonStyle.tertiary
                style: AppButtonStyle.tertiary,
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              AppButton(
                text: widget.guardrail == null ? 'Create' : 'Update',
                onPressed: _handleSubmit,
              ),
            ],
          )
        ],
      ),
    );
  }
}

// FIX: Added the missing ChatMessageBubble widget
class ChatMessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final String? agentAvatar;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.agentAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final alignment =
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isUser ? AppColors.primary : AppColors.card;
    final textColor =
        isUser ? AppColors.primaryForeground : AppColors.cardForeground;

    return Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser) ...[
          AppAvatar(
            imageUrl: agentAvatar,
            fallbackText: 'AI',
            radius: 16,
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: alignment,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: isUser
                        ? const Radius.circular(12)
                        : const Radius.circular(0),
                    bottomRight: isUser
                        ? const Radius.circular(0)
                        : const Radius.circular(12),
                  ),
                  border: isUser ? null : Border.all(color: AppColors.border),
                ),
                child: Text(
                  message,
                  style: TextStyle(color: textColor, fontSize: 14),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat.jm().format(timestamp),
                style: const TextStyle(
                    color: AppColors.mutedForeground, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
