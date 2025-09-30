import 'package:flutter/material.dart';
import 'package:leadbot_client/helper/utils/shared_preference.dart';
import '../api/api.dart';
import '../theme/business_info_theme.dart';

class BusinessTypeScreen extends StatelessWidget {
  final Api api;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const BusinessTypeScreen({
    required this.api,
    required this.onNext,
    required this.onBack,
    super.key,
  });

  Future<void> _choose(BuildContext ctx, String type) async {
    final tid = await StoreUserData().getTenantId();
    await api.postForm('/onboarding/type', {
      'tenant_id': tid ?? '',
      'business_type': type,
    });
    onNext();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<BusinessInfoTheme>() ??
        BusinessInfoTheme.light;

    final tiles = [
      _TypeTile(
        icon: Icons.shopping_bag,
        label: "Products",
        onTap: () => _choose(context, 'products'),
        theme: theme,
      ),
      _TypeTile(
        icon: Icons.build,
        label: "Services",
        onTap: () => _choose(context, 'services'),
        theme: theme,
      ),
      _TypeTile(
        icon: Icons.school,
        label: "Professional",
        onTap: () => _choose(context, 'professional'),
        theme: theme,
      ),
      _TypeTile(
        icon: Icons.more_horiz,
        label: "Other",
        onTap: () => _choose(context, 'other'),
        theme: theme,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(gradient: theme.formGradient),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Padding(
                padding: theme.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: theme.borderRadius,
                      ),
                      child: Icon(Icons.category,
                          color: Colors.blue[700], size: 28),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Select Business Type",
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Choose the category that best describes your business",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              /// Responsive Grid with Animation
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 2;
                    if (constraints.maxWidth > 1200) {
                      crossAxisCount = 4;
                    } else if (constraints.maxWidth > 800) {
                      crossAxisCount = 3;
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.3,
                      ),
                      itemCount: tiles.length,
                      itemBuilder: (context, i) {
                        // Fade + scale animation when tiles load
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.8, end: 1),
                          duration: Duration(milliseconds: 300 + (i * 100)),
                          curve: Curves.easeOutBack,
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: Opacity(
                                opacity: scale.clamp(0.0, 1.0),
                                child: tiles[i],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              /// Sticky Footer
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_ios,color: Colors.black, size: 18),
                      label: const Text("Back"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final BusinessInfoTheme theme;

  const _TypeTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.theme,
  });

  @override
  State<_TypeTile> createState() => _TypeTileState();
}

class _TypeTileState extends State<_TypeTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Card(
          elevation: _hovering ? 6 : 3,
          shape: RoundedRectangleBorder(
            borderRadius: widget.theme.borderRadius,
          ),
          shadowColor: Colors.black.withOpacity(0.1),

          /// Prevent grey hover overlay
          color: Colors.white,

          child: InkWell(
            borderRadius: widget.theme.borderRadius,
            onTap: widget.onTap,

            /// Override hover & splash colors
            splashColor: Colors.blue.withOpacity(0.1),
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,

            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, size: 28, color: Colors.blue[600]),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
