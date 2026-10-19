import 'package:app_message/constants/app_colors.dart';
import 'package:app_message/screens/login_screen.dart';
import 'package:app_message/utils/validators.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureRePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _accountController.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () {}),
        title: Text("Đăng ký"),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                AnimatedPadding(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.only(
                    top: isKeyboardOpen ? 20 : 60,
                    left: 20,
                    right: 20,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.chat, size: 70, color: AppColors.primary),
                        const Text(
                          'Tạo tài khoản mới',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "Đăng ký để có thể bắt đầu kết nối với bạn bè, ngườ thân",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //họ và tên
                SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Họ và tên",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: Icon(Icons.person),
                          labelText: 'Họ và tên',
                        ),
                        validator: (value) =>
                            Validators.required(value, "Họ và tên"),
                      ),
                      // Số điện thoại
                      Text(
                        "Email hoặc Số điện thoại",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: _accountController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: Icon(Icons.email),
                          labelText: 'Email hoặc Số điện thoại',
                        ),
                        validator: (value) => Validators.account(value),
                      ),
                      // Mật khẩu
                      Text(
                        "Mật khẩu",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: Icon(Icons.lock),
                          labelText: 'Mật khẩu',
                          suffixIcon: IconButton(
                            icon: _obscurePassword
                                ? Icon(Icons.visibility_off)
                                : Icon(Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) => Validators.password(value),
                      ),
                      // Xác nhận mật khẩu
                      Text(
                        "Xác nhận mật khẩu",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: _rePasswordController,
                        obscureText: _obscureRePassword,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: Icon(Icons.lock),
                          labelText: 'Xác nhận mật khẩu',
                          suffixIcon: IconButton(
                            icon: _obscureRePassword
                                ? Icon(Icons.visibility_off)
                                : Icon(Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscureRePassword = !_obscureRePassword;
                              });
                            },
                          ),
                        ),

                        validator: (value) => Validators.confirmPassoword(
                          value,
                          _passwordController.text,
                        ),
                      ),

                      // Nút đăng ký
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final name = _nameController.text.trim();
                              final account = _accountController.text.trim();
                              final password = _passwordController.text.trim();

                              String authEmail = account;
                              if (Validators.isPhoneNumber(account)) {
                                authEmail = '$account@appmessage.local';
                              }
                              print(
                                'Sẵn sàng đăng ký: Name: $name, AuthEmail: $authEmail, SĐT/Email gốc: $account, Password: $password',
                              );
                            }
                          },
                          child: Text(
                            "Đăng ký",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.background,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      //chưa có tài khoản
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Bạn đã có tài khoản? '),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Đăng nhập',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
