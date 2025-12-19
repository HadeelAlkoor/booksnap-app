import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../db/database.dart';
import '../screen/home_screen.dart';
import '../screen/register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // ===============================
  // ألوان
  // ===============================
  final Color _primaryColor = Color(0xFF5D5FEF);      // أزرق بنفسجي ناعم
  final Color _secondaryColor = Color(0xFF8B8DF2);    // أزرق فاتح
  final Color _accentColor = Color(0xFFFF6B8B);       // وردي ناعم
  final Color _backgroundColor = Color(0xFFFAFAFF);   // أبيض مزرق شفاف
  final Color _surfaceColor = Color(0xFFFFFFFF);      // أبيض نقي
  final Color _textColor = Color(0xFF2D3748);         // رمادي داكن ناعم
  final Color _textLightColor = Color(0xFF718096);    // رمادي فاتح
  
  // ظلال ناعمة
  final List<BoxShadow> _softShadow = [
    BoxShadow(
      color: Color(0x11000000),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];
  
 /// final List<BoxShadow> _softShadowHover = [
   // BoxShadow(
   //   color: Color(0x22000000),
   //   blurRadius: 25,
   //   offset: Offset(0, 6),
  //  ),
  //];

  // ===============================
  // Dialog خطأ مع Animation (باكج)
  // ===============================
  void _showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: 'خطأ',
      desc: message,
      btnOkText: 'موافق',
      btnOkColor: _primaryColor,
      btnOkOnPress: () {},
    ).show();
  }

  // ===============================
  // تسجيل الدخول
  // ===============================
  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog("الرجاء تعبئة جميع الحقول");
      return;
    }

    setState(() => _isLoading = true);

    final user = await AppDatabase.instance.loginUser(email, password);

    setState(() => _isLoading = false);

    if (user != null) {
      await Future.delayed(Duration(milliseconds: 600));

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => HomeScreen(
            userId: user['id'],
            userName: user['name'],
          ),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 500),
        ),
      );
    } else {
      _showErrorDialog("البريد الإلكتروني أو كلمة المرور غير صحيحة");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                // ====== مساحة علوية ======
                SizedBox(height: 20),

                // ====== شعار التطبيق ======
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryColor, _secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: _softShadow,
                  ),
                  child: Icon(
                    Icons.document_scanner_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                ),

                SizedBox(height: 20),
                
                // ====== اسم التطبيق ======
                TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 500),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (_, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    "BookSnap",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: _primaryColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                SizedBox(height: 8),
                
                // ====== وصف التطبيق ======
                TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 700),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (_, value, child) {
                    return Opacity(
                      opacity: value,
                      child: child,
                    );
                  },
                  child: Text(
                    "استخرج ولخص النصوص من الصور بذكاء",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _textLightColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                SizedBox(height: 50),

                // ====== عنوان تسجيل الدخول ======
                Align(
                  alignment: Alignment.centerRight,
                  child: TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (_, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(20 * (1 - value), 0),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      "تسجيل الدخول",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: _textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30),

                // ====== حقل البريد الإلكتروني ======
                _buildInputField(
                  controller: _emailController,
                  hint: "example@email.com",
                  icon: Icons.email_outlined,
                ),

                SizedBox(height: 20),

                // ====== حقل كلمة المرور ======
                _buildInputField(
                  controller: _passwordController,
                  hint: "كلمة المرور",
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                ),

                SizedBox(height: 35),

                // ====== زر تسجيل الدخول ======
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_primaryColor, _secondaryColor],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _softShadow,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading ? null : _login,
                        borderRadius: BorderRadius.circular(16),
                        splashColor: Colors.white.withOpacity(0.2),
                        highlightColor: Colors.white.withOpacity(0.1),
                        onHover: (hovering) {
                          setState(() {
                            // تأثير hover بسيط
                          });
                        },
                        child: Center(
                          child: _isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  "تسجيل الدخول",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30),

                // ====== رابط إنشاء حساب ======
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "ليس لديك حساب؟ ",
                      style: TextStyle(
                        color: _textLightColor,
                        fontSize: 14,
                      ),
                    ),
                    TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 200),
                      tween: Tween(begin: 1.0, end: 1.0),
                      builder: (_, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => RegisterScreen(),
                              transitionsBuilder: (_, animation, __, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: Offset(1.0, 0.0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "إنشاء حساب",
                              style: TextStyle(
                                color: _accentColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===============================
  // دالة إنشاء حقول الإدخال - محسنة
  // ===============================
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.text,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _softShadow,
        ),
        child: TextField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          style: TextStyle(
            color: _textColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: _textLightColor,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              icon,
              color: _primaryColor,
              size: 22,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: _textLightColor,
                      size: 22,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.transparent,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: _primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
          ),
          cursorColor: _primaryColor,
        ),
      ),
    );
  }
}