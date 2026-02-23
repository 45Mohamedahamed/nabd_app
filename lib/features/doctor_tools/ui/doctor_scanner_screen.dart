import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../doctor_tools/ui/add_treatment_screen.dart';

// 👇 هذا هو السطر الناقص الذي يسبب المشكلة
import 'patient_medical_record_screen.dart';

class DoctorScannerScreen extends StatefulWidget {
  const DoctorScannerScreen({super.key});

  @override
  State<DoctorScannerScreen> createState() => _DoctorScannerScreenState();
}

class _DoctorScannerScreenState extends State<DoctorScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanCompleted = false; // لمنع فتح الشاشة مرتين

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Scan Patient QR",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                return Icon(
                    state == TorchState.on ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white);
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. الكاميرا
          MobileScanner(
            controller: cameraController,
           onDetect: (capture) {
    if (isScanCompleted) return; // منع التكرار
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      setState(() => isScanCompleted = true); // قفل الماسح
      
      final String code = barcodes.first.rawValue!; // كود المريض
      
      // الانتقال لملف المريض
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PatientMedicalRecordScreen(
            patientId: code, // ✅ لازم تمرر الكود هنا
          ),
        ),
      );
    }
  },
          ),
          // 2. تصميم الـ Overlay (الإطار الشفاف)
          _buildOverlay(),

          // 3. نص توجيهي
          Positioned(
            bottom: 80.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text("Align QR code within the frame",
                    style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                SizedBox(height: 10.h),
                Text("Scanning will start automatically",
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: const Color(0xFF005DA3), // الأزرق الطبي
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 300.w, // حجم المربع
        ),
      ),
    );
  }
}

// كلاس مساعد لرسم الإطار المفرغ (Standard Pattern)
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 10.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getRectPath(Rect rect, double width) {
      return Path()..addRect(rect);
    }

    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(_getRectPath(rect, cutOutSize), Offset.zero)
      ..addRect(Rect.fromLTWH(
        rect.width / 2 - cutOutSize / 2,
        rect.height / 2 - cutOutSize / 2,
        cutOutSize,
        cutOutSize,
      ));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final _cutOutSize = cutOutSize;
    final _borderLength = borderLength;
    final _borderRadius = borderRadius;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;

    final cutOutRect = Rect.fromLTWH(
      rect.width / 2 - _cutOutSize / 2 + borderOffset,
      rect.height / 2 - _cutOutSize / 2 + borderOffset,
      _cutOutSize - borderWidth,
      _cutOutSize - borderWidth,
    );

    canvas
      ..saveLayer(
        rect,
        backgroundPaint,
      )
      ..drawRect(
        rect,
        backgroundPaint,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          cutOutRect,
          Radius.circular(_borderRadius),
        ),
        Paint()..blendMode = BlendMode.clear,
      )
      ..restore();

    final path = Path();

    // Top left
    path.moveTo(cutOutRect.left, cutOutRect.top + _borderLength);
    path.lineTo(cutOutRect.left, cutOutRect.top);
    path.lineTo(cutOutRect.left + _borderLength, cutOutRect.top);

    // Top right
    path.moveTo(cutOutRect.right - _borderLength, cutOutRect.top);
    path.lineTo(cutOutRect.right, cutOutRect.top);
    path.lineTo(cutOutRect.right, cutOutRect.top + _borderLength);

    // Bottom right
    path.moveTo(cutOutRect.right, cutOutRect.bottom - _borderLength);
    path.lineTo(cutOutRect.right, cutOutRect.bottom);
    path.lineTo(cutOutRect.right - _borderLength, cutOutRect.bottom);

    // Bottom left
    path.moveTo(cutOutRect.left + _borderLength, cutOutRect.bottom);
    path.lineTo(cutOutRect.left, cutOutRect.bottom);
    path.lineTo(cutOutRect.left, cutOutRect.bottom - _borderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
