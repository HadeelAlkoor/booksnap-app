
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../db/database.dart';
import 'extract_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final int userId;

  const HomeScreen({
    Key? key,
    required this.userName,
    required this.userId,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> summaries = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;

  // ===============================
  // نظام ألوان احترافي - داكن وأنيق
  // ===============================
  final Color _primaryColor = Color(0xFF1E3A8A);       // أزرق داكن احترافي
  final Color _secondaryColor = Color(0xFF3B82F6);     // أزرق متوسط
  final Color _accentColor = Color(0xFFEF4444);        // أحمر أنيق
  final Color _backgroundColor = Color(0xFFF9FAFB);    // رمادي فاتح جداً
  final Color _surfaceColor = Color(0xFFFFFFFF);       // أبيض
  final Color _textColor = Color(0xFF111827);          // أسود مزرق داكن
  final Color _textLightColor = Color(0xFF6B7280);     // رمادي متوسط
  final Color _successColor = Color(0xFF10B981);       // أخضر فاتح
  final Color _cardGradient1 = Color(0xFF4F46E5);      // إنديجو داكن
  final Color _cardGradient2 = Color(0xFF7C3AED);      // بنفسجي
  
  // ظلال احترافية
  final List<BoxShadow> _cardShadow = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 20,
      offset: Offset(0, 4),
      spreadRadius: -5,
    ),
  ];
  
  final List<BoxShadow> _floatingShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 25,
      offset: Offset(0, 8),
      spreadRadius: -8,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadSummaries();
  }

  // ===============================
  // تحميل الملخصات
  // ===============================
  void _loadSummaries() async {
    final data = await AppDatabase.instance.getUserSummaries(widget.userId);
    setState(() {
      summaries = data;
      _isLoading = false;
    });
  }

  // ===============================
  // حذف ملخص
  // ===============================
  void _deleteSummary(int id) async {
    await AppDatabase.instance.deleteSummary(id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, size: 16, color: _successColor),
            ),
            SizedBox(width: 12),
            Text("تم حذف الملخص بنجاح"),
          ],
        ),
        backgroundColor: _textColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: Duration(seconds: 2),
      ),
    );

    _loadSummaries();
  }

  // ===============================
  // تسجيل الخروج
  // ===============================
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: _surfaceColor,
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.logout_rounded, color: _accentColor, size: 24),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "تسجيل الخروج",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _textColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                "هل أنت متأكد من تسجيل الخروج؟",
                style: TextStyle(
                  color: _textLightColor,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text(
                      "إلغاء",
                      style: TextStyle(
                        color: _textLightColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_accentColor, Color(0xFFF87171)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        splashColor: Colors.white.withOpacity(0.2),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          child: Text(
                            "تسجيل الخروج",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openExtractScreen(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExtractScreen(
          imagePath: imagePath,
          userId: widget.userId,
        ),
      ),
    ).then((_) => _loadSummaries());
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      _openExtractScreen(picked.path);
    }
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _surfaceColor,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "مرحباً،",
              style: TextStyle(
                fontSize: 14,
                color: _textLightColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2),
            Text(
              widget.userName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _textColor,
              ),
            ),
          ],
        ),
        actions: [
  // زر تسجيل الخروج
  IconButton(
    icon: Icon(
      Icons.logout_rounded,
      color: _accentColor,
    ),
    tooltip: "تسجيل الخروج",
    onPressed: _logout,
  ),

  Padding(
    padding: EdgeInsets.only(right: 16),
    child: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _backgroundColor, width: 2),
      ),
      child: CircleAvatar(
        backgroundColor: _primaryColor,
        radius: 20,
        child: Text(
          widget.userName.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  ),
],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(
            color: _backgroundColor,
            height: 1,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_cardGradient1, _cardGradient2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: _floatingShadow,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.document_scanner_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    "جاري تحميل الملخصات",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "يرجى الانتظار قليلاً",
                    style: TextStyle(
                      color: _textLightColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // ====== بطاقة الإحصائيات ======
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_cardGradient1, _cardGradient2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: _floatingShadow,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "إجمالي الملخصات",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              summaries.length.toString(),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "ملخص ${summaries.length == 1 ? 'واحد' : summaries.length == 2 ? 'اثنان' : 'متعدد'}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.auto_awesome_motion_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ====== أزرار الإجراءات السريعة ======
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.camera_alt_rounded,
                          text: "التقاط صورة",
                          color: _successColor,
                          onTap: () => _pickImage(ImageSource.camera),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.photo_library_rounded,
                          text: "من المعرض",
                          color: _secondaryColor,
                          onTap: () => _pickImage(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // ====== عنوان قائمة الملخصات ======
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "الملخصات السابقة",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _textColor,
                        ),
                      ),
                      Spacer(),
                      if (summaries.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.list_alt_rounded, size: 16, color: _primaryColor),
                              SizedBox(width: 6),
                              Text(
                                summaries.length.toString(),
                                style: TextStyle(
                                  color: _primaryColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // ====== قائمة الملخصات ======
                Expanded(
                  child: summaries.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: _cardShadow,
                                ),
                                child: Icon(
                                  Icons.document_scanner_outlined,
                                  size: 48,
                                  color: _textLightColor.withOpacity(0.4),
                                ),
                              ),
                              SizedBox(height: 24),
                              Text(
                                "لا توجد ملخصات بعد",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: _textColor,
                                ),
                              ),
                              SizedBox(height: 8),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  "التقط صورة أو اختر من المعرض لإنشاء أول ملخص",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _textLightColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          physics: BouncingScrollPhysics(),
                          itemCount: summaries.length,
                          itemBuilder: (context, index) {
                            return _buildSummaryCard(summaries[index], index);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 15,
            offset: Offset(0, 6),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> summary, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _cardShadow,
        border: Border.all(
          color: _backgroundColor,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openExtractScreen(summary['imagePath']),
          borderRadius: BorderRadius.circular(16),
          splashColor: _primaryColor.withOpacity(0.05),
          highlightColor: _primaryColor.withOpacity(0.02),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // ====== صورة المصدر ======
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    image: summary['imagePath'] != null
                        ? DecorationImage(
                            image: FileImage(File(summary['imagePath'])),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: summary['imagePath'] == null
                      ? Center(
                          child: Icon(
                            Icons.photo_size_select_actual_rounded,
                            color: _textLightColor,
                            size: 24,
                          ),
                        )
                      : null,
                ),

                SizedBox(width: 16),

                // ====== محتوى الملخص ======
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary['summaryText'] ?? "ملخص بدون نص",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textColor,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_filled_rounded,
                            size: 14,
                            color: _textLightColor,
                          ),
                          SizedBox(width: 6),
                          Text(
                            summary['createdAt'] ?? "بدون تاريخ",
                            style: TextStyle(
                              fontSize: 12,
                              color: _textLightColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 12),

                // ====== زر الحذف ======
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: _accentColor,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: _surfaceColor,
                          child: Container(
                            padding: EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _accentColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.warning_amber_rounded,
                                        color: _accentColor,
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "حذف الملخص",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: _textColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "هل أنت متأكد من حذف هذا الملخص؟ لا يمكن التراجع عن هذه العملية.",
                                  style: TextStyle(
                                    color: _textLightColor,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      ),
                                      child: Text(
                                        "إلغاء",
                                        style: TextStyle(
                                          color: _textLightColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [_accentColor, Color(0xFFF87171)],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.pop(context);
                                            _deleteSummary(summary['id']);
                                          },
                                          borderRadius: BorderRadius.circular(12),
                                          splashColor: Colors.white.withOpacity(0.2),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                            child: Text(
                                              "حذف",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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