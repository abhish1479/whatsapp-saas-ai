import 'package:flutter/material.dart';
import '../api.dart';

class ReviewActivateScreen extends StatefulWidget {
  final Api api;
  final String tenantId;
  final VoidCallback onBack;
  
  const ReviewActivateScreen({
    Key? key,
    required this.api,
    required this.tenantId,
    required this.onBack,
  }) : super(key: key);
  
  @override
  State<ReviewActivateScreen> createState() => _ReviewActivateScreenState();
}

class _ReviewActivateScreenState extends State<ReviewActivateScreen> {
  bool _loading = false;
  String? _msg;
  bool _isSuccess = false;

  Future<void> _activate() async {
    setState(() => _loading = true);
    try {
      final res = await widget.api.postForm('/onboarding/activate', {'tenant_id': widget.tenantId});
      setState(() {
        _msg = res['activated'] == true ? "Agent Activated & Test Message Sent!" : "Activation done";
        _isSuccess = true;
      });
    } catch (e) {
      setState(() {
        _msg = "Activation failed: $e";
        _isSuccess = false;
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Review & Activate",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Review your configuration and activate your WhatsApp Agent",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32.0),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.rocket_launch_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Text(
                      "Ready to Launch",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Text(
                      "Your WhatsApp Agent is configured and ready to go. Click the button below to activate it and start engaging with your customers.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    if (_msg != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _isSuccess 
                            ? const Color(0xFFF0FDF4) 
                            : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isSuccess 
                              ? const Color(0xFF22C55E) 
                              : const Color(0xFFEF4444),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isSuccess ? Icons.check_circle : Icons.error,
                              color: _isSuccess 
                                ? const Color(0xFF22C55E) 
                                : const Color(0xFFEF4444),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _msg!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _isSuccess 
                                    ? const Color(0xFF166534) 
                                    : const Color(0xFFDC2626),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text("Back"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: const Color(0xFF64748B),
                  ),
                ),
                
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
                    onPressed: _loading ? null : _activate,
                    icon: _loading 
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.rocket_launch, size: 18),
                    label: Text(_loading ? "Activating..." : "Activate Agent"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
