import 'package:flutter/material.dart';

class AIAgentScreen extends StatefulWidget {
  const AIAgentScreen({super.key});

  @override
  State<AIAgentScreen> createState() => _AIAgentScreenState();
}

class _AIAgentScreenState extends State<AIAgentScreen> {
  // Personalize
  int selectedAgent = 0;
  final descCtrl = TextEditingController(
      text:
          'Create a customer support agent that promptly answers questions, resolves issues and provides helpful solutions.');
  final pills = [
    'Customer Support',
    'Recruitment',
    'Feedback',
    'Appointment',
    'Sales Enquiry',
    'Outbound Sales'
  ];
  final Set<String> selectedPills = {'Customer Support'};

  // Configuration
  final agentNameCtrl = TextEditingController(text: 'OmniBot');
  final greetingCtrl = TextEditingController(
      text: "Hi! I'm your virtual assistant. How can I assist you today?");
  String language = 'English';
  String tone = 'Friendly';
  String voice = 'Sarah - Professional & Clear';
  String accent = 'Neutral / Standard';
  Color primaryColor = const Color(0xFF0EA5E9);

  final agents = const [
    _Agent('Sarah', 'Professional & Reliable', 'assets/agents/agent-sarah.jpg'),
    _Agent('Alex', 'Friendly & Approachable', 'assets/agents/agent-alex.jpg'),
    _Agent('Maya', 'Tech-Savvy & Helpful', 'assets/agents/agent-maya.jpg'),
    _Agent('David', 'Formal & Executive', 'assets/agents/agent-david.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 1200;

    return ScrollConfiguration(
      behavior: const _NoGlow(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text('Personalize Your AI Agent',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                  "Customize your AI assistant's appearance, personality, and behavior",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),

                // Choose Preconfigured Agent
                _SectionCard(
                  title: 'Choose a Preconfigured Agent',
                  subtitle:
                      'Select from our expertly designed AI personalities or customize your own below',
                  child: LayoutBuilder(
                    builder: (_, c) {
                      final cross = c.maxWidth >= 900 ? 4 : 2;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cross,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.86,
                        ),
                        itemCount: agents.length,
                        itemBuilder: (_, i) {
                          final a = agents[i];
                          final sel = i == selectedAgent;
                          return InkWell(
                            onTap: () => setState(() => selectedAgent = i),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: sel
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .outlineVariant,
                                  width: sel ? 1.6 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12)),
                                      child: Image.asset(a.image,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outlineVariant,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(a.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w600)),
                                        const SizedBox(height: 2),
                                        Text(a.subtitle,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),

                // Describe the agent
                _SectionCard(
                  title: 'Describe the agent',
                  subtitle: 'Briefly describe the AI Agent you want to create',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: descCtrl,
                        maxLines: 5,
                        decoration: _filledInput(context),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: pills.map((p) {
                          final s = selectedPills.contains(p);
                          return FilterChip(
                            label: Text(p),
                            selected: s,
                            onSelected: (v) {
                              setState(() {
                                if (v) {
                                  selectedPills.add(p);
                                } else {
                                  selectedPills.remove(p);
                                }
                              });
                            },
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: s
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .outlineVariant,
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Configuration + Live Preview (2 cols desktop)
                isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildConfig(context)),
                          const SizedBox(width: 20),
                          Expanded(child: _buildPreview(context)),
                        ],
                      )
                    : Column(
                        children: [
                          _buildConfig(context),
                          const SizedBox(height: 20),
                          _buildPreview(context),
                        ],
                      ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Cards ---

  Widget _buildConfig(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          title: 'Agent Configuration',
          child: Column(
            children: [
              _formField(
                  'Agent Name',
                  TextField(
                      controller: agentNameCtrl,
                      decoration: _outline(context))),
              _formField(
                  'Greeting Message',
                  TextField(
                      controller: greetingCtrl,
                      maxLines: 3,
                      decoration: _outline(context))),
              _formField(
                  'Language',
                  _dropdown(context, language, ['English', 'Spanish', 'French'],
                      (v) => setState(() => language = v!))),
              _formField(
                  'Conversation Tone',
                  _dropdown(context, tone, ['Friendly', 'Formal', 'Casual'],
                      (v) => setState(() => tone = v!))),
              _formField(
                'Voice Model (for calls)',
                Row(
                  children: [
                    Expanded(
                        child: _dropdown(
                            context,
                            voice,
                            [
                              'Sarah - Professional & Clear',
                              'Alex - Friendly & Warm',
                              'Maya - Tech-Savvy & Helpful',
                              'David - Formal & Executive'
                            ],
                            (v) => setState(() => voice = v!))),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: () {},
                      icon: const Icon(Icons.volume_up_rounded),
                      tooltip: 'Preview voice',
                    ),
                  ],
                ),
                help: 'Click the speaker icon to preview the voice',
              ),
              _formField(
                  'Voice Accent',
                  _dropdown(
                      context,
                      accent,
                      [
                        'Neutral / Standard',
                        'US English',
                        'UK English',
                        'Australian'
                      ],
                      (v) => setState(() => accent = v!))),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _SectionCard(
          title: 'Avatar & Branding',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upload Avatar',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 10),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child:
                        const Icon(Icons.emoji_emotions, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.upload_rounded),
                    label: const Text('Upload Image'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Primary Color',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextField(
                readOnly: true,
                controller: TextEditingController(
                    text:
                        '#${primaryColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}'),
                decoration: _outline(context)
                    .copyWith(prefixIcon: _ColorSwatch(color: primaryColor)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreview(BuildContext context) {
    return _SectionCard(
      title: 'Live Preview',
      child: Column(
        children: [
          // Chat header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.smart_toy, color: Colors.white),
                const SizedBox(width: 8),
                Text(agentNameCtrl.text,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                const Spacer(),
                const Text('Online', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Messages
          _MessageBubble.left(
              "Hi! I'm your virtual assistant. How can I assist you today?"),
          const SizedBox(height: 8),
          Align(
              alignment: Alignment.centerRight,
              child: _MessageBubble.right("I need help with my order")),
          const SizedBox(height: 8),
          _MessageBubble.left(
              "I'd be happy to help you with your order! Could you please share your order number?"),

          const SizedBox(height: 12),
          TextField(
            decoration:
                _outline(context).copyWith(hintText: 'Type your message...'),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {},
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- helpers ---

  Widget _formField(String label, Widget field, {String? help}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 8),
          field,
          if (help != null) ...[
            const SizedBox(height: 6),
            Text(
              help,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _filledInput(BuildContext context) => InputDecoration(
        hintText: 'Write a short description…',
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.all(16),
      );

  InputDecoration _outline(BuildContext context) => InputDecoration(
        border: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      );

  Widget _dropdown<T>(BuildContext ctx, T value, List<T> items,
          ValueChanged<T?> onChanged) =>
      DropdownButtonFormField<T>(
        value: value,
        items: items
            .map(
                (e) => DropdownMenuItem<T>(value: e, child: Text(e.toString())))
            .toList(),
        onChanged: onChanged,
        decoration: _outline(ctx),
      );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.auto_awesome_mosaic_outlined,
                  size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble._(this.text, this.isRight);
  const _MessageBubble.left(String text) : this._(text, false);
  const _MessageBubble.right(String text) : this._(text, true);

  final String text;
  final bool isRight;

  @override
  Widget build(BuildContext context) {
    final bg = isRight
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final fg = isRight ? Colors.white : Theme.of(context).colorScheme.onSurface;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: Radius.circular(isRight ? 12 : 2),
      bottomRight: Radius.circular(isRight ? 2 : 12),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: radius),
      child: Text(text, style: TextStyle(color: fg)),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black12),
      ),
    );
  }
}

class _Agent {
  final String name, subtitle, image;
  const _Agent(this.name, this.subtitle, this.image);
}

class _NoGlow extends ScrollBehavior {
  const _NoGlow();
  @override
  Widget buildViewportChrome(
          BuildContext context, Widget child, AxisDirection axisDirection) =>
      child;
}
