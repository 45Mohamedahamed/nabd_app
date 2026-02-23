import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  static const String appId = "077d8456ea5d48c1bec823c896125811"; // 👈 حط الـ ID بتاعك هنا

  static Future<RtcEngine> initAgora() async {
    // 1. طلب الأذونات
    await [Permission.microphone, Permission.camera].request();

    // 2. إنشاء المحرك
    RtcEngine engine = createAgoraRtcEngine();
    await engine.initialize(const RtcEngineContext(appId: appId));

    // 3. تفعيل الفيديو
    await engine.enableVideo();
    await engine.startPreview();

    return engine;
  }
}