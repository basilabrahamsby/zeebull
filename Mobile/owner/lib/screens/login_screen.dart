import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  bool _hasSavedCredentials = false;
  bool _rememberMe = true;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    _checkBiometrics();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics || await auth.isDeviceSupported();
    } catch (e) {
      canCheckBiometrics = false;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool hasSavedCredentials = await authProvider.hasSavedCredentials();

    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
      _hasSavedCredentials = hasSavedCredentials;
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool authenticated = false;
    if (kIsWeb) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometrics not supported in web.')));
       return;
    }
    
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint or face to authenticate',
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Authentication Error')));
    }

    if (authenticated && mounted) {
      final success = await authProvider.loginWithSavedCredentials();
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to login with saved credentials.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F172A), Color(0xFF1B3D1B)],
              ),
            ),
          ),
          
          // Decorative Blurred Circles
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF8BC34A),
              ),
            ).blurred(sigma: 100),
          ),
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2D5016),
              ),
            ).blurred(sigma: 100),
          ),

          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Enhanced Logo
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B3D1B),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8BC34A).withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/zeebulllogo.png',
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Welcome Text
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to manage your properties',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Glassmorphism Form Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: const EdgeInsets.all(28.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (authProvider.error != null)
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      margin: const EdgeInsets.only(bottom: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                                      ),
                                      child: Text(
                                        authProvider.error!,
                                        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),

                                  // Email Field
                                  TextFormField(
                                    controller: _emailController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                      prefixIcon: Icon(Icons.email_outlined, color: Colors.white.withOpacity(0.7)),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: Color(0xFF8BC34A), width: 2),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: Colors.redAccent),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                                      ),
                                      fillColor: Colors.white.withOpacity(0.05),
                                      filled: true,
                                    ),
                                    validator: (value) =>
                                        value?.isEmpty ?? true ? 'Please enter your email' : null,
                                  ),
                                  const SizedBox(height: 20),

                                  // Password Field
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                      prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.7)),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: Color(0xFF8BC34A), width: 2),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: Colors.redAccent),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                                      ),
                                      fillColor: Colors.white.withOpacity(0.05),
                                      filled: true,
                                    ),
                                    validator: (value) =>
                                        value?.isEmpty ?? true ? 'Please enter your password' : null,
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Remember Me
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      unselectedWidgetColor: Colors.white.withOpacity(0.5),
                                    ),
                                    child: CheckboxListTile(
                                      title: Text(
                                        'Remember me (Enable Biometrics)',
                                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                                      ),
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      controlAffinity: ListTileControlAffinity.leading,
                                      contentPadding: EdgeInsets.zero,
                                      activeColor: const Color(0xFF8BC34A),
                                      checkColor: const Color(0xFF1B3D1B),
                                      dense: true,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Sign In Button
                                  Container(
                                    width: double.infinity,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF8BC34A), Color(0xFF689F38)],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF8BC34A).withOpacity(0.4),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: authProvider.isLoading
                                          ? null
                                          : () async {
                                              if (_formKey.currentState?.validate() ?? false) {
                                                final success = await authProvider.login(
                                                  _emailController.text,
                                                  _passwordController.text,
                                                  saveCredentials: _rememberMe,
                                                );
                                                if (success && mounted) {
                                                   // Navigation handled by AuthenticationWrapper
                                                }
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: authProvider.isLoading
                                          ? const SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                            )
                                          : const Text(
                                              'Sign In',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Biometrics Button
                      if (_canCheckBiometrics && _hasSavedCredentials) ...[
                        const SizedBox(height: 32),
                        const Text(
                          'OR',
                          style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        InkWell(
                          onTap: _authenticateWithBiometrics,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF8BC34A).withOpacity(0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.fingerprint, size: 28, color: Color(0xFF8BC34A)),
                                const SizedBox(width: 12),
                                Text(
                                  'Login with Biometrics',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Extension to easily apply blur to the decorative circles
extension BlurExtension on Widget {
  Widget blurred({double sigma = 10}) {
    return ImageFilterWidget(sigma: sigma, child: this);
  }
}

class ImageFilterWidget extends StatelessWidget {
  final double sigma;
  final Widget child;

  const ImageFilterWidget({super.key, required this.sigma, required this.child});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: child,
    );
  }
}
