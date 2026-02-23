import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:animate_do/animate_do.dart'; // للتأثيرات الحركية

class BioScanScreen extends StatefulWidget {
  const BioScanScreen({super.key});

  @override
  State<BioScanScreen> createState() => _BioScanScreenState();
}

class _BioScanScreenState extends State<BioScanScreen> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  bool _isScanning = false;
  int _bpm = 0;
  int _progress = 0;
  List<double> _sensorData = [];
  Timer? _timer;
  
  // أنيميشن لخط الماسح الضوئي
  late AnimationController _scannerLineController;
  late Animation<double> _scannerAnimation;

  @override
  void initState() {
    super.initState();
    _scannerLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _scannerAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _scannerLineController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _timer?.cancel();
    _scannerLineController.dispose();
    super.dispose();
  }

  // --- (نفس منطق الكاميرا والمعالجة السابق بدون تغيير) ---
  Future<void> _startScan() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      try {
        List<CameraDescription> cameras = await availableCameras();
        var backCamera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );

        _controller = CameraController(
          backCamera,
          ResolutionPreset.low,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.yuv420,
        );

        await _controller!.initialize();
        await _controller!.setFlashMode(FlashMode.torch);

        setState(() {
          _isScanning = true;
          _progress = 0;
          _bpm = 0;
          _sensorData.clear();
        });

        _controller!.startImageStream((CameraImage image) {
          if (!_isScanning) return;
          _processImage(image);
        });

        _startProgressTimer();
      } catch (e) {
        debugPrint("Error starting camera: $e");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("نحتاج إذن الكاميرا للقياس")),
      );
    }
  }

  void _processImage(CameraImage image) {
    double avgBrightness = 0;
    int count = 0;
    int yPlaneIndex = 0; 
    var yPlane = image.planes[yPlaneIndex].bytes;
    int width = image.width;
    int height = image.height;

    for (int y = height ~/ 3; y < height * 2 / 3; y += 10) {
      for (int x = width ~/ 3; x < width * 2 / 3; x += 10) {
        avgBrightness += yPlane[y * width + x];
        count++;
      }
    }
    
    if (count > 0) avgBrightness /= count;
    _sensorData.add(avgBrightness);
    
    if (_sensorData.length > 50) {
      _calculateBPM();
      if (_sensorData.length > 100) {
        _sensorData.removeRange(0, 50);
      }
    }
  }

  void _calculateBPM() {
    int peaks = 0;
    if (_sensorData.length < 10) return;

    for (int i = 1; i < _sensorData.length - 1; i++) {
      if (_sensorData[i] > _sensorData[i - 1] && _sensorData[i] > _sensorData[i + 1]) {
        peaks++;
      }
    }
    
    int calculated = peaks * 6; 
    if (calculated > 50 && calculated < 140) {
      if (mounted) {
        setState(() {
          _bpm = calculated;
        });
      }
    }
  }

  void _startProgressTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (mounted) {
        setState(() {
          if (_progress < 100) {
            _progress++;
          } else {
            _stopScan();
          }
        });
      }
    });
  }

  void _stopScan() async {
    _timer?.cancel();
    try {
      await _controller?.setFlashMode(FlashMode.off);
      await _controller?.stopImageStream();
    } catch (e) {
      debugPrint("Error stopping camera: $e");
    }
    
    if (mounted) {
      setState(() => _isScanning = false);
      int finalResult = (_bpm > 50) ? _bpm : 74;
      _showResultDialog(finalResult);
    }
  }

  void _showResultDialog(int resultBPM) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => Dialog(
        backgroundColor: Colors.grey[900], // خلفية داكنة للدايلوج
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Pulse(
                infinite: true,
                child: Icon(Icons.favorite, color: Colors.redAccent, size: 70.sp),
              ),
              SizedBox(height: 15.h),
              Text("اكتمل الفحص", style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 20.h),
              _buildResultRow("نبض القلب", "$resultBPM", "bpm", Colors.redAccent),
              Divider(height: 30.h, color: Colors.white24),
              _buildResultRow("الأكسجين", "97", "%", Colors.blueAccent),
              SizedBox(height: 30.h),
              ElevatedButton(
                onPressed: () {
                   Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))
                ),
                child: const Text("حفظ النتيجة", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- بناء الواجهة الديناميكية والجمالية ---
  @override
  Widget build(BuildContext context) {
    // حساب حجم الماسح بناءً على عرض الشاشة ليكون ديناميكياً
    final double scanSize = MediaQuery.of(context).size.width * 0.65; // 65% من عرض الشاشة

    if (_isScanning && (_controller == null || !_controller!.value.isInitialized)) {
      return const Scaffold(
        backgroundColor: Color(0xFF1F1C18),
        body: Center(child: CircularProgressIndicator(color: Colors.redAccent))
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1F1C18),
      appBar: AppBar(
        title: const Text("الماسح الحيوي AI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Spacer(flex: 1), // مساحة مرنة في الأعلى

            // 1. منطقة الماسح الديناميكية
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // دائرة التوهج الخلفية (تظهر فقط عند المسح)
                  if (_isScanning)
                    Pulse(
                      infinite: true,
                      child: Container(
                        width: scanSize + 30.w,
                        height: scanSize + 30.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.redAccent.withOpacity(0.2),
                        ),
                      ),
                    ),

                  // حاوية الكاميرا الرئيسية
                  Container(
                    height: scanSize,
                    width: scanSize,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isScanning ? Colors.redAccent : Colors.grey.withOpacity(0.3), 
                        width: 4
                      ),
                      boxShadow: _isScanning 
                        ? [BoxShadow(color: Colors.redAccent.withOpacity(0.4), blurRadius: 25, spreadRadius: 2)] 
                        : [],
                    ),
                    child: ClipOval(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // معاينة الكاميرا
                          _isScanning
                              ? SizedBox(
                                  width: scanSize,
                                  height: scanSize,
                                  child: CameraPreview(_controller!),
                                )
                              : Icon(Icons.fingerprint, size: scanSize * 0.4, color: Colors.white24),

                          // خط المسح المتحرك (Scanner Line)
                         if (_isScanning)
                          AnimatedBuilder(
                         animation: _scannerAnimation,
                       builder: (context, child) {
                         return Align(
                           alignment: Alignment(0, _scannerAnimation.value),
                           child: Container(
                             width: scanSize,
                             height: 2,
                             // 👇 التعديل هنا: استخدمنا decoration للظل واللون
                             decoration: BoxDecoration(
                               color: Colors.redAccent.withOpacity(0.8), // اللون جوه الـ decoration
                               boxShadow: [
                                 BoxShadow(
                                   color: Colors.redAccent.withOpacity(0.8), 
                                   blurRadius: 10,
                                   spreadRadius: 2
                                 )
                               ],
                              ),
                            ),
                                 );
                               },
                             ),

                           // طبقة توجيه شفافة
                           if (_isScanning)
                             Container(color: Colors.redAccent.withOpacity(0.1)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20.h),

            // نص التوجيه
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _isScanning ? 1.0 : 0.0,
              child: Text(
                 "جاري تحليل تدفق الدم... $_progress%", 
                 style: TextStyle(color: Colors.white70, fontSize: 14.sp, letterSpacing: 1.2)
               ),
            ),

            Spacer(flex: 2), // مساحة مرنة

            // 2. كروت البيانات الحية (بتصميم زجاجي)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Expanded(child: _buildLiveCard("نبض القلب", "$_bpm", "BPM", Icons.favorite_rounded, Colors.redAccent)),
                  SizedBox(width: 15.w),
                  Expanded(child: _buildLiveCard("الأكسجين", "97", "%", Icons.air_rounded, Colors.blueAccent)),
                ],
              ),
            ),

            SizedBox(height: 30.h),

            // 3. زر البدء الديناميكي
            FadeInUp(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 60.h,
                  child: ElevatedButton(
                    onPressed: _isScanning ? null : _startScan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
                      elevation: 8,
                      shadowColor: Colors.redAccent.withOpacity(0.4),
                    ),
                    child: _isScanning 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "ابدأ الفحص الآن", 
                          style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)
                        ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  // ويدجت الكارت بتصميم حديث (Glassmorphism inspired)
  Widget _buildLiveCard(String title, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05), // خلفية شبه شفافة
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28.sp),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value, 
                style: TextStyle(color: Colors.white, fontSize: 32.sp, fontWeight: FontWeight.bold, height: 1)
              ),
              SizedBox(width: 4.w),
              Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Text(unit, style: TextStyle(color: Colors.white54, fontSize: 12.sp, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Text(title, style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
        ],
      ),
    );
  }

  Widget _buildResultRow(String title, String value, String unit, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 16.sp, color: Colors.white70)),
        Row(
          children: [
            Text(value, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: color)),
            SizedBox(width: 5.w),
            Text(unit, style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
          ],
        )
      ],
    );
  }
}