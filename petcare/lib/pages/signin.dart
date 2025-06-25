import 'package:flutter/material.dart';
import 'package:petcare/pages/regis.dart';
import 'package:petcare/pages/dassboard.dart';
import 'package:petcare/services/supabase_auth_service.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final SupabaseAuthService _authService = SupabaseAuthService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _showSuccessAnimation = false;

  // Animation controllers
  late AnimationController _successAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _successAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null && mounted) {
        // Show success animation
        setState(() {
          _showSuccessAnimation = true;
          _isLoading = false;
        });

        // Start animations
        _scaleAnimationController.forward();
        _successAnimationController.forward();

        // Wait for animation to complete then navigate
        await Future.delayed(const Duration(milliseconds: 2000));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) => HomeScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOutCubic;

                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_authService.getErrorMessage(e)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithGoogle();
      if (mounted) {
        // Show success animation for Google sign in too
        setState(() {
          _showSuccessAnimation = true;
          _isLoading = false;
        });

        _scaleAnimationController.forward();
        _successAnimationController.forward();

        await Future.delayed(const Duration(milliseconds: 2000));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) => HomeScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 600),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_authService.getErrorMessage(e)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Masukkan email terlebih dahulu'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    try {
      await _authService.resetPassword(_emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Link reset password telah dikirim ke email Anda',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_authService.getErrorMessage(e)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Header
            Positioned(
              top: 30,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const Text(
                    "PetCare",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Rawat Hewan Kesayangan dengan\nLebih Mudah",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            // Main Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.75,
                  color: const Color(0xFF2686C2),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.login_rounded,
                              size: 40,
                              color: Color(0xFF2686C2),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 30),
                          buildInputField(
                            label: "Email",
                            icon: Icons.email,
                            hintText: "Email",
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email wajib diisi';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          buildInputField(
                            label: "Password",
                            icon: Icons.lock,
                            hintText: "Password",
                            controller: _passwordController,
                            isPassword: true,
                            isPasswordVisible: _isPasswordVisible,
                            onTogglePassword: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _forgotPassword,
                              child: const Text(
                                "Lupa password?",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed:
                                (_isLoading || _showSuccessAnimation)
                                    ? null
                                    : _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child:
                                _isLoading
                                    ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          "Signing In...",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    )
                                    : const Text(
                                      "Sign In",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Belum Punya Akun?",
                                style: TextStyle(color: Colors.white),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const RegisterPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Register",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildSocialButton(
                                "lib/images/Google.png",
                                40,
                                _signInWithGoogle,
                              ),
                              const SizedBox(width: 15),
                              buildSocialButton(
                                "lib/images/facebook.png",
                                40,
                                null,
                              ),
                              const SizedBox(width: 15),
                              buildSocialButton(
                                "lib/images/instagram.png",
                                40,
                                null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Success Animation Overlay
            // if (_showSuccessAnimation)
            //   Container(
            //     color: Colors.black.withOpacity(0.8),
            //     child: Center(
            //       child: FadeTransition(
            //         opacity: _fadeAnimation,
            //         child: Column(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             ScaleTransition(
            //               scale: _scaleAnimation,
            //               child: Container(
            //                 width: 120,
            //                 height: 120,
            //                 decoration: const BoxDecoration(
            //                   color: Colors.green,
            //                   shape: BoxShape.circle,
            //                 ),
            //                 child: const Icon(
            //                   Icons.check,
            //                   color: Colors.white,
            //                   size: 60,
            //                 ),
            //               ),
            //             ),
            //             const SizedBox(height: 30),
            //             FadeTransition(
            //               opacity: _fadeAnimation,
            //               child: const Text(
            //                 "Login Berhasil!",
            //                 style: TextStyle(
            //                   color: Colors.white,
            //                   fontSize: 24,
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //               ),
            //             ),
            //             const SizedBox(height: 10),
            //             FadeTransition(
            //               opacity: _fadeAnimation,
            //               child: const Text(
            //                 "Mengarahkan ke dashboard...",
            //                 style: TextStyle(
            //                   color: Colors.white70,
            //                   fontSize: 16,
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  Widget buildInputField({
    required String label,
    required IconData icon,
    required String hintText,
    required TextEditingController controller,
    bool isPassword = false,
    bool? isPasswordVisible,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !(isPasswordVisible ?? false),
          validator: validator,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(icon, color: Colors.grey),
            suffixIcon:
                isPassword
                    ? IconButton(
                      icon: Icon(
                        (isPasswordVisible ?? false)
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: onTogglePassword,
                    )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSocialButton(String imagePath, double size, VoidCallback? onTap) {
    return GestureDetector(
      onTap: (_isLoading || _showSuccessAnimation) ? null : onTap,
      child: Opacity(
        opacity: (_isLoading || _showSuccessAnimation) ? 0.5 : 1.0,
        child: Image.asset(
          imagePath,
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
