import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';

class AudioCallScreen extends StatefulWidget {
  final String receiverName;
  final String receiverImage;

  const AudioCallScreen({
    super.key, 
    this.receiverName = "Dr. Marcus Horizon", 
    this.receiverImage = 'assets/images/doctor1.png'
  });

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  Duration duration = Duration.zero;
  Timer? timer;
  bool isMuted = false;
  bool isSpeaker = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => duration = Duration(seconds: duration.inSeconds + 1));
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // خلفية مشوشة بصورة الطبيب
          Image.asset(widget.receiverImage, fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),
          
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 80.h),
              // صورة الطبيب مع أنيميشن نبضي
              Pulse(
                infinite: true,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 2)),
                  child: CircleAvatar(radius: 90.r, backgroundImage: AssetImage(widget.receiverImage)),
                ),
              ),
              SizedBox(height: 25.h),
              FadeInDown(
                child: Text(widget.receiverName, style: TextStyle(color: Colors.white, fontSize: 26.sp, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 10.h),
              Text(formatTime(duration), style: TextStyle(color: Colors.white70, fontSize: 20.sp, letterSpacing: 2, fontWeight: FontWeight.w300)),
              
              const Spacer(),
              
              // لوحة التحكم السفلية
              Container(
                padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF005DA3).withOpacity(0.8),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, spreadRadius: 5)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCallAction(isSpeaker ? Icons.volume_up : Icons.volume_off, "Speaker", isSpeaker, () => setState(() => isSpeaker = !isSpeaker)),
                    _buildEndCallButton(),
                    _buildCallAction(isMuted ? Icons.mic_off : Icons.mic, "Mute", isMuted, () => setState(() => isMuted = !isMuted)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCallAction(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 30.r,
            backgroundColor: isActive ? Colors.white : Colors.white10,
            child: Icon(icon, color: isActive ? Colors.black : Colors.white, size: 28.sp),
          ),
        ),
        SizedBox(height: 8.h),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
      ],
    );
  }

  Widget _buildEndCallButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.redAccent, blurRadius: 15)]),
        child: Icon(Icons.call_end, color: Colors.white, size: 35.sp),
      ),
    );
  }
}