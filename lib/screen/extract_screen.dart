
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../db/database.dart';

class ExtractScreen extends StatefulWidget {
  final String imagePath;
  final int userId;

  const ExtractScreen({
    Key? key,
    required this.imagePath,
    required this.userId,
  }) : super(key: key);

  @override
  State<ExtractScreen> createState() => _ExtractScreenState();
}

class _ExtractScreenState extends State<ExtractScreen> {
  final TextEditingController _textController = TextEditingController();

  bool _isProcessing = false;
  bool _showSummary = false;

  String? _summary;

  // ===============================
  // نظام ألوان جديد - أزرق داكن مع لمسات ذهبية
  // ===============================
  final Color _primaryColor = Color(0xFF0F1C35);      // أزرق داكن راقي
  final Color _secondaryColor = Color(0xFF1E2B47);    // أزرق متوسط
  final Color _accentColor = Color(0xFFFFC107);       // ذهبي أنيق
  final Color _backgroundColor = Color(0xFFF8FAFF);   // أبيض مزرق فاتح
  final Color _surfaceColor = Color(0xFFFFFFFF);      // أبيض نقي
  final Color _textColor = Color(0xFF1A1A2E);         // أسود مزرق
  final Color _textLightColor = Color(0xFF6B7280);    // رمادي
  final Color _successColor = Color(0xFF10B981);      // أخضر فاتح
  final Color _warningColor = Color(0xFFF59E0B);      // برتقالي ذهبي
  
  // ظلال عميقة وناعمة
  final List<BoxShadow> _softShadow = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 25,
      offset: Offset(0, 8),
      spreadRadius: -5,
    ),
  ];
  
  final List<BoxShadow> _cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 15,
      offset: Offset(0, 4),
    ),
  ];

  @override
  void initState() {
    super.initState();
    extractTextFromImage();
  }

  // ===============================
  // OCR استخراج النص من الصورة
  // ===============================
  Future<void> extractTextFromImage() async {
    setState(() => _isProcessing = true);

    final inputImage = InputImage.fromFilePath(widget.imagePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      _textController.text = recognizedText.text;
      
      if (recognizedText.text.isNotEmpty) {
        Future.delayed(Duration(milliseconds: 300), () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text("تم استخراج النص بنجاح"),
                ],
              ),
              backgroundColor: _successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: Duration(seconds: 2),
            ),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text("خطأ في استخراج النص"),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      textRecognizer.close();
      setState(() => _isProcessing = false);
    }
  }

  // ===============================
  // التلخيص الذكي (بسيط)
  // ===============================
  void _summarizeText() {
    String text = _textController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text("لا يوجد نص للتلخيص"),
            ],
          ),
          backgroundColor: _warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    List<String> sentences = text.split(RegExp(r'[.!؟\n]'));
    sentences.removeWhere((s) => s.trim().isEmpty);

    setState(() {
      _summary = sentences.take(3).join(' • ');
      _showSummary = true;
    });
  }

  // ===============================
  // حفظ الملخص في قاعدة البيانات
  // ===============================
  Future<void> _saveSummary() async {
    if (_summary == null || _summary!.isEmpty) return;

    await AppDatabase.instance.addSummary(
      userId: widget.userId,
      originalText: _textController.text,
      summaryText: _summary!,
      imagePath: widget.imagePath,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.save_alt, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text("تم حفظ الملخص بنجاح"),
          ],
        ),
        backgroundColor: _successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // ====== AppBar معدل ======
          SliverAppBar(
            expandedHeight: 180,
            collapsedHeight: 70,
            floating: false,
            pinned: true,
            backgroundColor: _primaryColor,
            elevation: 0,
            leading: Container(
              margin: EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: EdgeInsets.only(left: 85, bottom: 16, right: 20),
              title: Text(
                "استخراج وتلخيص النص",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryColor, _secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: _isProcessing
                ? _buildLoadingState()
                : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: _softShadow,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 3,
                  color: _primaryColor,
                  backgroundColor: _primaryColor.withOpacity(0.1),
                ),
                Icon(
                  Icons.document_scanner,
                  size: 40,
                  color: _primaryColor,
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          Text(
            "جاري استخراج النص",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "نقوم بتحليل الصورة واستخراج النص منها",
            style: TextStyle(
              color: _textLightColor,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 40),
          LinearProgressIndicator(
            backgroundColor: _backgroundColor,
            color: _primaryColor,
            minHeight: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ====== بطاقة الصورة ======
          Container(
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: _cardShadow,
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "الصورة الأصلية",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _textColor,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.image, size: 16, color: _accentColor),
                            SizedBox(width: 6),
                            Text(
                              "مصدر",
                              style: TextStyle(
                                color: _accentColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    child: Image.file(
                      File(widget.imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: _backgroundColor,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image, size: 50, color: _textLightColor),
                                SizedBox(height: 10),
                                Text("تعذر تحميل الصورة", style: TextStyle(color: _textLightColor)),

                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 30),

          // ====== عنوان النص المستخرج ======
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 12),
              Text(
                "النص المستخرج",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _textColor,
                ),
              ),
              Spacer(),
              Icon(Icons.text_snippet, color: _primaryColor, size: 24),
            ],
          ),

          SizedBox(height: 8),

          Text(
            "يمكنك تعديل النص قبل المتابعة للتلخيص",
            style: TextStyle(
              color: _textLightColor,
              fontSize: 14,
            ),
          ),

          SizedBox(height: 20),

          // ====== حقل النص ======
          Container(
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: _softShadow,
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: TextField(
              controller: _textController,
              maxLines: 8,
              minLines: 6,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 15,
                color: _textColor,
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: "سيظهر النص المستخرج هنا...",
                hintStyle: TextStyle(
                  color: _textLightColor.withOpacity(0.7),
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(20),
                filled: false,
              ),
              cursorColor: _primaryColor,
            ),
          ),

          SizedBox(height: 30),

          // ====== زر التلخيص ======
          Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [_primaryColor, _secondaryColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _summarizeText,
                borderRadius: BorderRadius.circular(15),
                splashColor: Colors.white.withOpacity(0.2),
                highlightColor: Colors.white.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome_motion, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Text(
                      "تلخيص النص",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
// ====== عرض الملخص ======
          if (_showSummary && _summary != null) ...[
            SizedBox(height: 30),

            Container(
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: _cardShadow,
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _successColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              "الملخص المولد",
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: _textColor,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "جاهز للحفظ",
                            style: TextStyle(
                              color: _successColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _backgroundColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: _successColor.withOpacity(0.2)),
                      ),
                      child: Text(
                        _summary!,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 15,
                          color: _textColor,
                          height: 1.7,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(height: 25),

                    // ====== زر الحفظ ======
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [_successColor, Color(0xFF34D399)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _successColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _saveSummary,
                                borderRadius: BorderRadius.circular(15),
                                splashColor: Colors.white.withOpacity(0.2),
                                highlightColor: Colors.white.withOpacity(0.1),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save_alt, color: Colors.white, size: 22),
                                    SizedBox(width: 10),
                                    Text(
                                      "حفظ الملخص",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: _backgroundColor,
                            border: Border.all(color: Colors.black.withOpacity(0.1)),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _showSummary = false;
                                  _summary = null;
                                });
                              },
                              borderRadius: BorderRadius.circular(15),
                              child: Icon(Icons.refresh, color: _textLightColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),
          ],

          SizedBox(height: 40),
        ],
      ),
    );
  }
}