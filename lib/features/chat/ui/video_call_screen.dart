import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/services/agora_service.dart'; // 👈 تأكد من وجود الخدمة التي أنشأناها

class VideoCallScreen extends StatefulWidget {
  final String receiverName;
  final String receiverImage;
  final String chatId; // 👈 المعرف الموحد لدخول القناة

  const VideoCallScreen({
    super.key,
    this.receiverName = "Dr. Marcus Horizon",
    this.receiverImage = 'assets/images/doctor1.png',
    required this.chatId, 
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  // --- 🛠️ متغيرات Agora ---
  late RtcEngine _engine;
  int? _remoteUid; 
  bool _localUserJoined = false;
  bool isMicOff = false;
  bool isCameraOff = false;

  @override
  void initState() {
    super.initState();
    setupVideoSDKEngine(); // 👈 بدء محرك البث فور فتح الشاشة
  }

  @override
  void dispose() {
    _disposeAgora(); // 👈 تنظيف الذاكرة وإغلاق الكاميرا
    super.dispose();
  }

  Future<void> _disposeAgora() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  // --- 🚀 محرك البث (Precise Integration) ---
  Future<void> setupVideoSDKEngine() async {
    _engine = await AgoraService.initAgora();

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("✅ Local user joined successfully: ${connection.localUid}");
          setState(() => _localUserJoined = true);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("👨‍⚕️ Doctor joined: $remoteUid");
          setState(() => _remoteUid = remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("🚫 Doctor left the call");
          setState(() => _remoteUid = null);
          Navigator.pop(context); // إغلاق الشاشة عند خروج الطبيب
        },
      ),
    );

    await _engine.joinChannel(
      token: '', // Testing Mode
      channelId: widget.chatId,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. فيديو الدكتور (Full Screen Remote View)
          Positioned.fill(
            child: _remoteUid == null
                ? _buildWaitingPlaceholder() // واجهة الانتظار
                : AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: _engine,
                      canvas: VideoCanvas(uid: _remoteUid),
                      connection: RtcConnection(channelId: widget.chatId),
                    ),
                  ),
          ),

          // التدرج العلوي
          _buildTopOverlay(),

          // 2. فيديو المستخدم (Floating Local View)
          Positioned(
            right: 20.w,
            top: 100.h,
            child: FadeInRight(
              child: Container(
                width: 110.w,
                height: 160.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.white30, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 15)],
                  color: Colors.black,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: _localUserJoined && !isCameraOff
                      ? AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: _engine,
                            canvas: const VideoCanvas(uid: 0), // 0 تعني الفيديو المحلي
                          ),
                        )
                      : const Center(child: Icon(Icons.videocam_off, color: Colors.white24)),
                ),
              ),
            ),
          ),

          // 3. أزرار التحكم
          _buildControlPanel(),
        ],
      ),
    );
  }

  // --- 🎨 مكونات الواجهة ---

  Widget _buildWaitingPlaceholder() {
    return Container(
      color: Colors.grey.shade900,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(radius: 60.r, backgroundImage: AssetImage(widget.receiverImage)),
          SizedBox(height: 20.h),
          const CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 20.h),
          Text("بانتظار انضمام ${widget.receiverName}...", 
              style: TextStyle(color: Colors.white70, fontSize: 16.sp)),
        ],
      ),
    );
  }

  Widget _buildTopOverlay() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        height: 150.h,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black54, Colors.transparent],
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 50.h),
        child: Text(widget.receiverName, 
            style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Positioned(
      bottom: 50.h, left: 30.w, right: 30.w,
      child: FadeInUp(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15.h),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(40.r),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionBtn(isCameraOff ? Icons.videocam_off : Icons.videocam, isCameraOff, () {
                setState(() => isCameraOff = !isCameraOff);
                _engine.muteLocalVideoStream(isCameraOff);
              }),
              _buildEndCallBtn(),
              _buildActionBtn(isMicOff ? Icons.mic_off : Icons.mic, isMicOff, () {
                setState(() => isMicOff = !isMicOff);
                _engine.muteLocalAudioStream(isMicOff);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28.r,
        backgroundColor: isActive ? Colors.red : Colors.white12,
        child: Icon(icon, color: Colors.white, size: 24.sp),
      ),
    );
  }

  Widget _buildEndCallBtn() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 70.r, height: 70.r,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.redAccent, blurRadius: 20)],
        ),
        child: Icon(Icons.call_end, color: Colors.white, size: 30.sp),
      ),
    );
  }
}