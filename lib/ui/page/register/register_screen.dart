import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../utils/sizes_manager.dart';
import '../../../utils/gaps_manager.dart';
import '../login/widget/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;

  void _register() async {
    setState(() {
      _emailError = _emailController.text.isEmpty ? 'Email không được trống' : null;
      _passwordError = _passwordController.text.length < 6
          ? 'Mật khẩu tối thiểu 6 ký tự'
          : null;
    });

    if (_emailError == null && _passwordError == null) {
      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Gửi email xác thực
        await credential.user!.sendEmailVerification();

        // Đăng xuất để tránh user chưa xác thực tiếp tục sử dụng
        await FirebaseAuth.instance.signOut();

        // Hiển thị thông báo xác thực
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Xác thực Email'),
            content: Text('Tài khoản đã được tạo. Vui lòng xác nhận email để hoàn tất đăng ký.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // đóng dialog
                  Navigator.pop(context); // quay lại màn hình trước
                },
                child: Text('OK'),
              )
            ],
          ),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Đăng ký thất bại';
        if (e.code == 'email-already-in-use') {
          errorMessage = 'Email đã tồn tại';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Email không hợp lệ';
        }

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Lỗi đăng ký'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              )
            ],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white
      ,title: Text("Đăng ký")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _emailController,
              labelText: "Email",
              icon: Icons.email,
              errorText: _emailError,
              onChanged: (value) {
                setState(() {
                  _emailError = value.isEmpty ? 'Email không được trống' : null;
                });
              },
            ),
            GapsManager.h20,
            CustomTextField(
              controller: _passwordController,
              labelText: "Mật khẩu",
              icon: Icons.lock,
              obscureText: true,
              errorText: _passwordError,
              onChanged: (value) {
                setState(() {
                  _passwordError = value.length < 6 ? 'Mật khẩu tối thiểu 6 ký tự' : null;
                });
              },
            ),
            GapsManager.h20,
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: PaddingSizes.p16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RadiusSizes.r10),
                ),
              ),
              child: Text(
                'Đăng ký',
                style: TextStyle(
                  fontSize: TextSizes.s16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}