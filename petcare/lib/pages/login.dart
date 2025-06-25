import 'package:flutter/material.dart';
// import 'package:petcare/pages/coba.dart';
import 'package:petcare/pages/signin.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Kotak warna biru (rectangle) dengan gambar
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 410,
                  height: 500,
                  color: const Color(0xFF2686C2),
                  child: Center(
                    child: Image.asset(
                      "lib/images/hewan.png",
                      width: 360,
                      height: 360,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 600,
              left: 0,
              right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "PetCare",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins",
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Rawat hewan kesayangan dengan\nlebih mudah",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                      fontFamily: "Poppins",
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2686C2),
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Get Started",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        fontFamily: "Poppins",
                        color: Colors.white,
                      ),
                    ),
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
