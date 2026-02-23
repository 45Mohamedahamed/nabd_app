import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:animate_do/animate_do.dart';

class ArMedicineScreen extends StatefulWidget {
  const ArMedicineScreen({super.key});

  @override
  State<ArMedicineScreen> createState() => _ArMedicineScreenState();
}

class _ArMedicineScreenState extends State<ArMedicineScreen> with SingleTickerProviderStateMixin {
  // للتحكم في الكاميرا
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  bool _isFlashOn = false;

  // أنيميشن خط المسح
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // إعداد أنيميشن الخط المتحرك (Scanner Line)
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _animationController.forward();
        }
      });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  // عند اكتشاف باركود الدواء
  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return; // لمنع الفتح المتكرر

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      setState(() {
        _isScanning = false; // إيقاف المسح مؤقتاً
      });
      
      // هز الهاتف (اختياري)
      // HapticFeedback.mediumImpact();

      // عرض بيانات الدواء
      String code = barcodes.first.rawValue ?? "Unknown";
      _showMedicineDetails(context, code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. طبقة الكاميرا الخلفية
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),

          // 2. طبقة التعتيم والتركيز (Overlay)
          _buildScannerOverlay(),

          // 3. واجهة المستخدم (UI Layer)
          SafeArea(
            child: Column(
              children: [
                // الهيدر العلوي
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildGlassButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.view_in_ar, color: Colors.purpleAccent, size: 20),
                            SizedBox(width: 8.w),
                            const Text("AR Pharmacy", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      _buildGlassButton(
                        icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: _isFlashOn ? Colors.yellow : Colors.white,
                        onTap: () {
                          cameraController.toggleTorch();
                          setState(() => _isFlashOn = !_isFlashOn);
                        },
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // النص السفلي
                FadeInUp(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 40.h),
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      "وجه الكاميرا نحو علبة الدواء للتعرف عليه",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widgets ---

  // تصميم طبقة الماسح (المربع الشفاف والخط المتحرك)
  Widget _buildScannerOverlay() {
    return Stack(
      children: [
        // تعتيم الخلفية ما عدا المربع
        ColorFiltered(
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.srcOut),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  width: 300.w,
                  height: 300.w,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ),
            ],
          ),
        ),

        // الزوايا والخط المتحرك
        Center(
          child: SizedBox(
            width: 300.w,
            height: 300.w,
            child: Stack(
              children: [
                // الزوايا (Corner Borders)
                ..._buildCorners(),

                // خط الليزر المتحرك
                if (_isScanning)
                  Positioned(
                    top: 300.w * _animation.value,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.purpleAccent,
                        boxShadow: [
                          BoxShadow(color: Colors.purpleAccent.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)
                        ],
                      ),
                    ),
                  ),
                  
                // شبكة AR وهمية (Grid)
                if (_isScanning)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: GridPainter(progress: _animation.value),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCorners() {
    double length = 30.w;
    double thickness = 4.w;
    Color color = Colors.purpleAccent;

    return [
      Positioned(top: 0, left: 0, child: Container(width: length, height: thickness, color: color)),
      Positioned(top: 0, left: 0, child: Container(width: thickness, height: length, color: color)),
      Positioned(top: 0, right: 0, child: Container(width: length, height: thickness, color: color)),
      Positioned(top: 0, right: 0, child: Container(width: thickness, height: length, color: color)),
      Positioned(bottom: 0, left: 0, child: Container(width: length, height: thickness, color: color)),
      Positioned(bottom: 0, left: 0, child: Container(width: thickness, height: length, color: color)),
      Positioned(bottom: 0, right: 0, child: Container(width: length, height: thickness, color: color)),
      Positioned(bottom: 0, right: 0, child: Container(width: thickness, height: length, color: color)),
    ];
  }

  Widget _buildGlassButton({required IconData icon, required VoidCallback onTap, Color color = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 45.w,
            height: 45.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
        ),
      ),
    );
  }

  // --- نافذة تفاصيل الدواء (Bottom Sheet) ---
  void _showMedicineDetails(BuildContext context, String code) {
    // محاكاة بيانات دواء (يمكنك ربطها بـ API لاحقاً)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MedicineDetailSheet(
        code: code,
        onClose: () {
          Navigator.pop(context);
          setState(() {
            _isScanning = true;
            _animationController.forward();
          });
        },
      ),
    );
  }
}

// 🖌️ رسام الشبكة (Grid Painter) لتأثير الـ Sci-Fi
class GridPainter extends CustomPainter {
  final double progress;
  GridPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purpleAccent.withOpacity(0.2 * (1 - progress)) // يختفي مع الحركة
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double step = size.width / 5;
    for (double i = 0; i <= size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 💊 تصميم كارت تفاصيل الدواء (Bottom Sheet)
class _MedicineDetailSheet extends StatelessWidget {
  final String code;
  final VoidCallback onClose;

  const _MedicineDetailSheet({required this.code, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.4,
      maxChildSize: 0.8,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: ListView(
          controller: controller,
          padding: EdgeInsets.all(25.w),
          children: [
            Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            SizedBox(height: 20.h),
            
            // صورة الدواء واسمه
            Row(
              children: [
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20.r),
                    image: const DecorationImage(image: NetworkImage("https://www.panadol.com/content/dam/cf-consumer-healthcare/panadol/en_me/product_detail/455x455/panadol-advance-455x455.jpg"), fit: BoxFit.cover), // صورة وهمية
                  ),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Panadol Advance", style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                      Text("Paracetamol 500mg", style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: Text("آمن للاستخدام ✅", style: TextStyle(color: Colors.green, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 30.h),
            
            // المعلومات التفصيلية
            _buildInfoRow(Icons.medical_services, "الاستخدام", "مسكن للآلام وخافض للحرارة"),
            _buildInfoRow(Icons.access_time, "الجرعة المقترحة", "قرص واحد كل 6 ساعات عند اللزوم"),
            _buildInfoRow(Icons.warning_amber_rounded, "التعارضات", "تجنب تناوله مع أدوية البرد الأخرى التي تحتوي على الباراسيتامول", isWarning: true),
            _buildInfoRow(Icons.monetization_on, "السعر التقريبي", "45.00 EGP"),

            SizedBox(height: 20.h),
            
            // زر الإغلاق
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005DA3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r))),
                child: const Text("مسح دواء آخر", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value, {bool isWarning = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(color: isWarning ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: isWarning ? Colors.red : Colors.blueGrey, size: 20.sp),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                SizedBox(height: 5.h),
                Text(value, style: TextStyle(fontSize: 13.sp, color: Colors.grey[700], height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}