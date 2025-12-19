
import 'package:flutter/material.dart';
import '../db/database.dart';
import '../screen/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  // ألوان مخصصة
  final Color _primaryColor = Color(0xFF6C63FF);
  final Color _secondaryColor = Color(0xFF4A44C6);
  //final Color _accentColor = Color(0xFFFF6584);
  final Color _backgroundColor = Color(0xFFF9F9FF);

  void _register() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("الرجاء تعبئة جميع الحقول"),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AppDatabase.instance.registerUser(name, email, password);
      setState(() => _isLoading = false);

      // رسالة نجاح جميلة
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text("تم إنشاء الحساب بنجاح!")),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );

      // انتقال سلس
      await Future.delayed(Duration(milliseconds: 800));
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => LoginScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 500),
        ),
      );

    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text("حدث خطأ أو البريد مستخدم من قبل")),
            ],
          ),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // زر العودة
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4), 
                    ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: _primaryColor,
                      size: 20,
                    ),
                  ),
                ),

                SizedBox(height: 30),

                // العنوان
                Text(
                  "إنشاء حساب جديد",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _secondaryColor,
                    height: 1.3,
                  ),
                ),

                SizedBox(height: 10),

                // النص التوضيحي
                Text(
                  "انضم إلينا وابدأ رحلتك",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),

                SizedBox(height: 40),

                // حقل الاسم مع تأثيرات
                _buildTextField(
                  controller: _nameController,
                  label: "الاسم الكامل",
                  icon: Icons.person_outline_rounded,
                  hint: "أدخل اسمك الثلاثي",
                ),

                SizedBox(height: 25),

                // حقل البريد الإلكتروني
                _buildTextField(
                  controller: _emailController,
                  label: "البريد الإلكتروني",
                  icon: Icons.email_outlined,
                  hint: "example@email.com",
                  keyboardType: TextInputType.emailAddress,
                ),

                SizedBox(height: 25),

                // حقل كلمة المرور
                _buildPasswordField(),

                SizedBox(height: 40),

                // زر التسجيل
                _isLoading
                    ? Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(_primaryColor),
                            strokeWidth: 3,
                          ),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_primaryColor, _secondaryColor],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _register,
                            borderRadius: BorderRadius.circular(15),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_add_alt_1_rounded,
                                      color: Colors.white),
                                  SizedBox(width: 10),
                                  Text(
                                    "إنشاء الحساب",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                SizedBox(height: 30),

                // خط فاصل
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        "أو",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 25),

                // رابط تسجيل الدخول
                Center(
                  child: InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => LoginScreen(),
                          transitionsBuilder: (_, animation, __, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset(1, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOut,
                              )),
                              child: child,
                            );
                          },
                          transitionDuration: Duration(milliseconds: 500),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "لديك حساب بالفعل؟ ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            "تسجيل الدخول",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: _primaryColor,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30),

                // الشعار أو الصورة (اختياري)
                Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                      image: AssetImage('assets/images/welcome.png'), // ضع صورتك هنا
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _secondaryColor,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Container(
                width: 60,
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: _primaryColor,
                  size: 22,
                ),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "كلمة المرور",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _secondaryColor,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: "أدخل كلمة مرور قوية",
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Container(
                width: 60,
                alignment: Alignment.center,
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: _primaryColor,
                  size: 22,
                ),
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                child: Container(
                  width: 60,
                  alignment: Alignment.center,
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey[500],
                    size: 22,
                  ),
                ),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            ),
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: Colors.grey[500],
              size: 16,
            ),
            SizedBox(width: 5),
            Text(
              "استخدم 8 أحرف على الأقل مع مزيج من الأرقام والحروف",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ],
    );
  }
}