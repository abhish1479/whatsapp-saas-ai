import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    this.isDrawer = false,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool isDrawer; // true when used as a drawer (mobile)

  @override
  Widget build(BuildContext context) {
    final items = const [
      _Nav(Icons.space_dashboard_outlined, 'Dashboard'),
      _Nav(Icons.smart_toy_outlined, 'AI Agent'),
      _Nav(Icons.menu_book_outlined, 'Knowledge'),
      _Nav(Icons.school_outlined, 'Train Agent'),
      _Nav(Icons.chat_bubble_outline, 'Templates'),
      _Nav(Icons.campaign_outlined, 'Campaigns'),
      _Nav(Icons.people_alt_outlined, 'CRM'),
      _Nav(Icons.extension_outlined, 'Integrations'),
      _Nav(Icons.settings_outlined, 'Settings'),
    ];

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right:
              BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // === Header ===
            if (isDrawer)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'H',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'HumAInity.ai',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    // Show close button only in drawer mode
                    if (isDrawer)
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 20),
                        tooltip: 'Close menu',
                      ),
                  ],
                ),
              ),

            const Divider(height: 1),

            SizedBox(height: 10),

            // === Navigation Items ===
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final item = items[i];
                  final isSelected = i == selectedIndex;

                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => onSelect(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue // e.g., #2563EB
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color:
                                  isSelected ? Colors.white : Colors.grey[700],
                              size: 20,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // === Footer (User Profile) ===
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    child: Text(
                      'U',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'User Name',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'user@example.com',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Nav {
  final IconData icon;
  final String label;
  const _Nav(this.icon, this.label);
}
