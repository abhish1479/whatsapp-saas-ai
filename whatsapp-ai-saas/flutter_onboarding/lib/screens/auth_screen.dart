import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:leadbot_client/helper/utils/shared_preference.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:universal_html/html.dart' as html;
// Social login packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../api/api.dart';
import '../model/auth.dart';
import 'leads/leads_list_screen.dart';
import 'onboarding_wizard.dart';

class SignupScreen extends StatefulWidget {
  final Api api;

  const SignupScreen({
    Key? key,
    required this.api,
  }) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  // Video & animations
  late VideoPlayerController _videoController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Flow states
  bool _showPackSelection = false;
  bool _showSocialLogin = false;
  bool _isLogin = false;
  bool _isLoading = false;
  String? _selectedPlan;
  int? _selectedPlanId;
  // Social login instances
  late GoogleSignIn _googleSignIn;
  List<Map<String, dynamic>> _plans = [];
  bool _isLoadingPlans = false;
  String? _planError;

  @override
  void initState() {
    super.initState();

    String? clientId;
    if (kIsWeb) {
      clientId =
          "734195415255-lj07mf33edgkgec9j4e3od0acj635nvb.apps.googleusercontent.com";
    }

    _googleSignIn = GoogleSignIn(
      clientId: clientId,
      scopes: [
        'email',
        'profile',
      ],
    );

    _videoController = VideoPlayerController.network(
      'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    )..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _videoController.play();
          _videoController.setLooping(true);
        }
      });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _videoController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _isLoadingPlans = true;
      _planError = null;
    });

    try {
      final List<dynamic> rawList =
          await widget.api.getJsonList('/subscriptions/get_all_plans');

      final List<Map<String, dynamic>> validPlans =
          rawList.whereType<Map<String, dynamic>>().toList();

      if (validPlans.isEmpty) {
        throw Exception("No valid plans returned from server");
      }

      setState(() {
        _plans = validPlans;
        _isLoadingPlans = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPlans = false;
        _planError = 'Failed to load subscription plans: $e';
      });
    }
  }

  void _handleGetStarted() async {
    setState(() {
      _showPackSelection = true;
      _isLogin = false;
    });
    await _loadPlans();
  }

  void _handleLogin() {
    setState(() {
      _showSocialLogin = true;
      _isLogin = true;
    });
  }

  void _handlePackSelection(Map<String, dynamic> plan) {
    setState(() {
      _selectedPlan = plan['name'];
      _selectedPlanId = plan['id'];
      _showPackSelection = false;
      _showSocialLogin = true;
      _isLogin = false;
    });
  }

  void _selectPlan(Map<String, dynamic> plan) {
    setState(() {
      _selectedPlanId = plan['id'];
    });
  }

  /// Firebase-based Google + Facebook login
  Future<void> _handleSocialAuth(String provider) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (provider == "google") {

        var idToken = '';
        if (kIsWeb) {
          // For Web
          UserCredential? userCredential;
          final GoogleAuthProvider googleProvider = GoogleAuthProvider();
          googleProvider.addScope('email');
          googleProvider.addScope('profile');
          userCredential =
              await FirebaseAuth.instance.signInWithPopup(googleProvider);
          if (userCredential?.user == null) {
            throw Exception("Google sign-in failed");
          }
          final user = userCredential!.user!;
          idToken = await user.getIdToken() ?? '';
        } else {
          // 📱 Mobile: Use google_sign_in + Firebase
          final account = await _googleSignIn.signIn();
          if (account == null) {
            await _googleSignIn.signOut(); // Clean up
            if (mounted) setState(() => _isLoading = false);
            return;
          }
          final auth = await account.authentication;
          idToken = auth.idToken ?? '';
          if (idToken.isEmpty) {
            throw Exception("No ID token received from Google");
          }
        }

        final String _authEndpoint = "${widget.api.baseUrl}/social_auth/login";
        final response = await http.post(
          Uri.parse(_authEndpoint),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "id_token": idToken, // ← Send this to backend
            "provider": provider,
            "is_login": _isLogin,
            "plan_id": _isLogin ? null : _selectedPlanId,
          }),
        );

        _handleAuthResponse(response);
      } else if (provider == "facebook") {
        final LoginResult result =
            await FacebookAuth.instance.login(permissions: ['email']);
        if (result.status == LoginStatus.success) {
          final userData = await FacebookAuth.instance.getUserData();
          final email = userData["email"] ?? "${userData["id"]}@facebook.com";

          final String _authEndpoint =
              "${widget.api.baseUrl}/social_auth/login";
          final response = await http.post(
            Uri.parse(_authEndpoint),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "email": email,
              "provider": provider,
              "is_login": _isLogin,
              "plan_id": _isLogin ? null : _selectedPlanId,
            }),
          );

          _handleAuthResponse(response);
        } else {
          if (result.message != null) {
            throw Exception("Facebook login failed: ${result.message}");
          } else {
            throw Exception("Facebook login failed.");
          }
        }
      } else {
        throw Exception("Unsupported provider: $provider");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleAuthResponse(http.Response response) {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);

      final store = StoreUserData();
      store.setTenantId(authResponse.tenantId);
      store.setUserStatus(authResponse.onboardingProcess);
      store.setToken(authResponse.accessToken);
      store.setLoggedIn(true);
      store.setUserName(authResponse.user.name);
      store.setEmail(authResponse.user.email);
      store.setProfilePic(authResponse.user.picture);

      String message = _isLogin
          ? "Login successful!"
          : "Welcome ${authResponse.user.name}! Please complete onboarding process.";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );

      Widget nextScreen;
      if (authResponse.onboardingProcess.toLowerCase() == 'completed') {
        nextScreen = HomeScreen(/*api: widget.api*/);
      } else {
        nextScreen = OnboardingWizard(api: widget.api);
      }

      if (mounted) {
        Get.offAll(() => nextScreen);
      }
    } else {
      final errorData = jsonDecode(response.body);
      final errorMessage =
          errorData["error"] ?? "Authentication failed: ${response.statusCode}";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _goBack() {
    setState(() {
      if (_showSocialLogin) {
        _showSocialLogin = false;
        if (!_isLogin) {
          _showPackSelection = true;
        }
      } else if (_showPackSelection) {
        _showPackSelection = false;
      }
    });
  }

  // ----------------- UI SECTIONS -----------------

  Widget _buildVideoSection() {
    bool isWeb = MediaQuery.of(context).size.width > 800;

    return Container(
      height: isWeb ? 400 : 250,
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: isWeb ? 40 : 0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _videoController.value.isInitialized
            ? AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: VideoPlayer(_videoController),
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1E293B),
                      const Color(0xFF334155),
                    ],
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInitialOptions() {
    bool isWeb = MediaQuery.of(context).size.width > 800;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isWeb ? 40 : 0,
      ),
      child: Column(
        children: [
          SizedBox(height: isWeb ? 60 : 40),
          Text(
            'Transform Your Business with AI',
            style: TextStyle(
              fontSize: isWeb ? 42 : 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isWeb ? 24 : 16),
          Text(
            'Join thousands of businesses already using our AI-powered platform to automate workflows, enhance customer engagement, and drive growth.',
            style: TextStyle(
              fontSize: isWeb ? 18 : 16,
              color: const Color(0xFF64748B),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isWeb ? 60 : 40),

          // Get Started Button
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: _handleGetStarted,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: isWeb ? 20 : 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: 64,
            child: OutlinedButton(
              onPressed: _handleLogin,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF3B82F6), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Already have an account? Login',
                style: TextStyle(
                  fontSize: isWeb ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackSelection() {
    bool isWeb = MediaQuery.of(context).size.width > 800;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isWeb ? 40 : 0),
      child: Column(
        children: [
          SizedBox(height: isWeb ? 40 : 32),
          Text(
            'Choose Your Plan',
            style: TextStyle(
              fontSize: isWeb ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Select the perfect plan for your business needs',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isWeb ? 40 : 32),
          if (_isLoadingPlans)
            const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )
          else if (_planError != null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _planError!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          else if (_plans.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No plans available right now'),
            )
          else
            (isWeb)
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _plans
                        .map(
                          (plan) => Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: _buildPlanCard(plan),
                            ),
                          ),
                        )
                        .toList(),
                  )
                : Column(
                    children: _plans
                        .map(
                          (plan) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildPlanCard(plan),
                          ),
                        )
                        .toList(),
                  ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back, size: 20),
            label: const Text('Back'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              foregroundColor: const Color(0xFF64748B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLoginOptions() {
    bool isWeb = MediaQuery.of(context).size.width > 800;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isWeb ? 40 : 0,
      ),
      child: Column(
        children: [
          SizedBox(height: isWeb ? 40 : 32),
          Text(
            _isLogin ? 'Welcome Back!' : 'Almost There!',
            style: TextStyle(
              fontSize: isWeb ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _isLogin
                ? 'Choose your preferred login method'
                : 'Choose your preferred sign-up method for the $_selectedPlan plan',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isWeb ? 40 : 32),
          _buildSocialButton(
            'Google',
            Icons.g_mobiledata,
            const Color(0xFFDB4437),
            () => _handleSocialAuth('google'),
          ),
          const SizedBox(height: 16),
          _buildSocialButton(
            'Facebook',
            Icons.facebook,
            const Color(0xFF4267B2),
            () => _handleSocialAuth('facebook'),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back, size: 20),
            label: const Text('Back'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              foregroundColor: const Color(0xFF64748B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
      String provider, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: Icon(icon, color: Colors.white, size: 24),
        label: Text(
          '${_isLogin ? 'Login' : 'Continue'} with $provider',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          shadowColor: color.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final int planId = plan['id'] ?? -1;
    final bool isSelected = _selectedPlanId == planId; // 👈 highlight condition
    final bool isPopular = plan['is_popular'] ?? false;

    String name = plan['name'] ?? 'Unnamed Plan';
    String price = '₹${plan['price_per_month']?.toStringAsFixed(0) ?? 'N/A'}';
    String credits = '${plan['credits'] ?? '0'} credits';
    List<String> features = List<String>.from(plan['features'] ?? []);

    return GestureDetector(
      onTap: () => _selectPlan(plan),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF3B82F6).withOpacity(0.15)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 20 : 10,
              offset: Offset(0, isSelected ? 10 : 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (isPopular && !isSelected)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Popular',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                if (isSelected)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Selected',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$price/month',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              credits,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // Features List
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 14),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                              color: Color(0xFF64748B), fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  _selectPlan(plan);
                  _handlePackSelection(plan); // 👈 triggers next step
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: const Color(0xFF3B82F6),
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  isSelected ? 'Selected' : 'Select Plan',
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF3B82F6),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isWeb ? 40 : 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWeb ? 1200 : double.infinity,
                    ),
                    child: Column(
                      children: [
                        if (!_showPackSelection)
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: _buildVideoSection(),
                            ),
                          ),
                        const SizedBox(height: 20),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: _showSocialLogin
                                ? _buildSocialLoginOptions()
                                : _showPackSelection
                                    ? _buildPackSelection()
                                    : _buildInitialOptions(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
