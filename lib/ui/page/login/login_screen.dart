import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nutrients_manager/data/repository/user_repository.dart';
import 'package:nutrients_manager/ui/page/home/home_screen.dart';
import 'package:nutrients_manager/utils/app_navigator.dart';
import 'package:nutrients_manager/ui/page/login/widget/custom_text_field.dart';
import 'package:nutrients_manager/ui/page/user_information/user_information_screen.dart';
import 'package:nutrients_manager/utils/gaps_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/controller/share_pref_controller.dart';
import '../../../utils/app_validator.dart';
import '../../../utils/sizes_manager.dart';
import '../register/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _nameError;
  String? _passwordError;

  void _login() async {
    setState(() {
      _nameError = AppValidator.validateName(_nameController.text);
      _passwordError = AppValidator.validatePassword(_passwordController.text);
    });

    if (_nameError == null && _passwordError == null) {
      try {
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _nameController.text.trim(),
              password: _passwordController.text.trim(),
            );

        if (credential.user != null) {
          if (!credential.user!.emailVerified) {
            await FirebaseAuth.instance.signOut();
            showLoginErrorDialog(
              context,
              'Bạn chưa xác thực email. Vui lòng kiểm tra hộp thư và xác thực trước khi đăng nhập.',
            );
            return;
          }

          final email = credential.user!.email;
          final uid = credential.user!.uid;

          await SharedPrefsController.getInstance().setUserId(uid);
          final prefs = await UserRepositoryImpl.instance.fetchUserById(uid);
          if (prefs == null) {
            final isRegister = await UserRepositoryImpl.instance.createUser(
              uid: uid,
              email: email!,
            );
          }

          prefs!.name == null
              ? AppNavigator.push(context, UserInformationScreen())
              : AppNavigator.push(context, HomeScreen());
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Đăng nhập thất bại';
        if (e.code == 'user-not-found') {
          errorMessage = 'Không tìm thấy tài khoản';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Sai mật khẩu';
        }
        if (e.code == 'invalid-email') {
          errorMessage = 'Email không hợp lệ';
        }
        showLoginErrorDialog(context, errorMessage);
      }
    }
  }

  void showLoginErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error Login"),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Quên mật khẩu'),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Nhập email của bạn',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Huỷ'),
          ),
          TextButton(
            onPressed: () async {
              final email = emailController.text.trim();

              if (email.isEmpty || !email.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Vui lòng nhập email hợp lệ')),
                );
                return;
              }

              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã gửi email đặt lại mật khẩu')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: ${e.toString()}')),
                );
              }
            },
            child: Text('Gửi'),
          ),
        ],
      ),
    );
  }


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(PaddingSizes.p24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Đăng nhập',
                    style: TextStyle(
                      fontSize: TextSizes.s24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  GapsManager.h40,
                  CustomTextField(
                    controller: _nameController,
                    labelText: 'Email',
                    icon: Icons.email,
                    errorText: _nameError,
                    onChanged: (value) {
                      setState(() {
                        _nameError = AppValidator.validateName(value);
                      });
                    },
                  ),
                  GapsManager.h20,
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Mật khẩu',
                    icon: Icons.lock,
                    errorText: _passwordError,
                    obscureText: true,
                    onChanged: (value) {
                      setState(() {
                        _passwordError = AppValidator.validatePassword(value);
                      });
                    },
                  ),
                  GapsManager.h20,
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: PaddingSizes.p16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(RadiusSizes.r10),
                      ),
                    ),
                    child: Text(
                      'Đăng nhập',
                      style: TextStyle(
                        fontSize: TextSizes.s16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GapsManager.h20,
                  TextButton(
                    onPressed: () {
                      _showForgotPasswordDialog(context);
                    },
                    child: Text("Quên mật khẩu?"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterScreen()),
                      );
                    },
                    child: Text("Chưa có tài khoản? Đăng ký ngay"),
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
