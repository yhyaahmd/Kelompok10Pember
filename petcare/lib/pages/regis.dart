import 'package:flutter/material.dart';
import 'package:petcare/pages/signin.dart';
import 'package:petcare/services/supabase_auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final SupabaseAuthService _authService = SupabaseAuthService();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
      );

      if (response.user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi berhasil! Cek email untuk verifikasi.'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to sign in page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithGoogle();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi dengan Google berhasil!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
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
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 25,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF2686C2),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_add,
                            size: 40,
                            color: Color(0xFF2686C2),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Field Nama
                        buildInputField(
                          label: "Nama Lengkap",
                          icon: Icons.person,
                          hintText: "Nama Lengkap",
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama tidak boleh kosong';
                            }
                            if (value.trim().length < 2) {
                              return 'Nama minimal 2 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // Field Email
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
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // Field Password
                        buildInputField(
                          label: "Password",
                          icon: Icons.lock,
                          hintText: "Password",
                          isPassword: true,
                          controller: _passwordController,
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
                            if (value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // Field Confirm Password
                        buildInputField(
                          label: "Konfirmasi Password",
                          icon: Icons.lock_outline,
                          hintText: "Konfirmasi Password",
                          isPassword: true,
                          controller: _confirmPasswordController,
                          isPasswordVisible: _isConfirmPasswordVisible,
                          onTogglePassword: () {
                            setState(() {
                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Konfirmasi password wajib diisi';
                            }
                            if (value != _passwordController.text) {
                              return 'Password tidak sama';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),

                        // Tombol Register
                        ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Register",
                                  style: TextStyle(fontSize: 18, color: Colors.white),
                                ),
                        ),
                        const SizedBox(height: 20),

                        // Link ke Sign In
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Sudah Punya Akun? ",
                              style: TextStyle(color: Colors.white),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignInPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Sign In",
                                style: TextStyle(
                                  color: Colors.white,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Social Login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildSocialButton(
                              "lib/images/Google.png", 
                              40, 
                              _signInWithGoogle
                            ),
                            const SizedBox(width: 15),
                            buildSocialButton("lib/images/facebook.png", 40, null),
                            const SizedBox(width: 15),
                            buildSocialButton("lib/images/instagram.png", 40, null),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
    String? Function(String?)? validator,
    bool isPassword = false,
    bool? isPasswordVisible,
    VoidCallback? onTogglePassword,
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
            suffixIcon: isPassword
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
      onTap: onTap,
      child: Image.asset(
        imagePath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
