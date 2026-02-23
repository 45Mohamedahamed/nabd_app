import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart'; // 👈 إضافة مكتبة التشغيل
import 'video_call_screen.dart';
import 'audio_call_screen.dart';
import '../ui/video_call_screen.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String receiverName;
  final String receiverImage;
  final bool isOnline;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.receiverName,
    required this.receiverImage,
    this.isOnline = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final Color mainColor = const Color(0xFF005DA3);
  
  bool _isRecording = false;
  bool _isUploading = false;

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------
  // 🚀 محرك الرفع والرسائل (Core Logic)
  // -------------------------------------------------------------------

  Future<String> _uploadFile(File file, String folder) async {
    setState(() => _isUploading = true);
    try {
      String fileName = "${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";
      var ref = FirebaseStorage.instance.ref().child('chats/${widget.chatId}/$folder').child(fileName);
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _sendFirebaseMessage(String content, String type) async {
    if (content.isEmpty) return;
    
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'senderId': currentUserId,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'type': type,
      'status': 'sent',
    });

    await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).update({
      'lastMessage': type == 'text' ? content : (type == 'audio' ? '🎙️ Voice Message' : '📎 Attachment'),
      'lastTime': FieldValue.serverTimestamp(),
    });

    _scrollToBottom();
  }

  // -------------------------------------------------------------------
  // 🎤 منطق الوسائط (Media Actions)
  // -------------------------------------------------------------------

  Future<void> _pickMedia(String type) async {
    if (type == 'image') {
      final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image != null) {
        String url = await _uploadFile(File(image.path), 'images');
        _sendFirebaseMessage(url, 'image');
      }
    } else if (type == 'file') {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        String url = await _uploadFile(File(result.files.single.path!), 'files');
        _sendFirebaseMessage(url, 'file');
      }
    }
  }

  void _handleVoiceRecording() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);
      if (path != null) {
        String url = await _uploadFile(File(path), 'voice');
        _sendFirebaseMessage(url, 'audio');
      }
    } else {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        String path = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() => _isRecording = true);
      }
    }
  }

  // -------------------------------------------------------------------
  // 🎨 بناء واجهة المستخدم (UI Components)
  // -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_isUploading) const LinearProgressIndicator(minHeight: 2, color: Colors.orange),
          Expanded(child: _buildMessagesList()),
          _buildInputSection(),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var docs = snapshot.data!.docs;
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(20.w),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            return _buildMessageBubble(data, data['senderId'] == currentUserId);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> data, bool isMe) {
    String type = data['type'] ?? 'text';
    String content = data['content'] ?? '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: type == 'text' ? EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h) : EdgeInsets.all(8.w),
        constraints: BoxConstraints(maxWidth: 0.75.sw),
        decoration: BoxDecoration(
          color: isMe ? mainColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: _buildMessageContent(type, content, isMe),
      ),
    );
  }

  // 🔥 وظيفة بناء المحتوى المحدثة بدقة
  Widget _buildMessageContent(String type, String content, bool isMe) {
    switch (type) {
      case 'image':
        return ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.network(content, loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          }),
        );

      case 'audio':
        return VoiceMessageBubble(url: content, isMe: isMe); // 👈 استدعاء المشغل

      case 'file':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file, color: isMe ? Colors.white : Colors.grey),
            SizedBox(width: 8.w),
            Text("Document", style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
          ],
        );

      default:
        return Text(
          content,
          style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14.sp),
        );
    }
  }

  Widget _buildInputSection() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.grey), onPressed: () => _pickMedia('file')),
          IconButton(icon: const Icon(Icons.camera_alt_outlined, color: Colors.grey), onPressed: () => _pickMedia('image')),
          Expanded(
            child: TextField(
              controller: _msgController,
              decoration: InputDecoration(
                hintText: _isRecording ? "جاري التسجيل..." : "اكتب رسالتك...",
                filled: true, fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.r), borderSide: BorderSide.none),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onLongPress: _handleVoiceRecording,
            onTap: _isRecording ? _handleVoiceRecording : () => _sendFirebaseMessage(_msgController.text.trim(), 'text'),
            child: CircleAvatar(
              backgroundColor: _isRecording ? Colors.red : mainColor,
              child: Icon(_isRecording ? Icons.stop : (_msgController.text.isEmpty ? Icons.mic : Icons.send), color: Colors.white, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white, elevation: 1,
      title: Row(
        children: [
          CircleAvatar(backgroundImage: AssetImage(widget.receiverImage), radius: 18.r),
          SizedBox(width: 10.w),
          Text(widget.receiverName, style: TextStyle(color: Colors.black, fontSize: 15.sp, fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        IconButton(icon: Icon(Icons.videocam, color: mainColor), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => VideoCallScreen(receiverName: widget.receiverName, receiverImage: widget.receiverImage, chatId: widget.chatId)))),
        IconButton(icon: Icon(Icons.call, color: mainColor), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => AudioCallScreen()))),
      ],
    );
  }
}

// -------------------------------------------------------------------
// 🎧 ويدجت مشغل الرسائل الصوتية (The Creative Player)
// -------------------------------------------------------------------
class VoiceMessageBubble extends StatefulWidget {
  final String url;
  final bool isMe;
  const VoiceMessageBubble({super.key, required this.url, required this.isMe});

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.onPositionChanged.listen((p) => setState(() => position = p));
    _player.onDurationChanged.listen((d) => setState(() => duration = d));
    _player.onPlayerStateChanged.listen((state) => setState(() => isPlaying = state == PlayerState.playing));
  }

  @override
  void dispose() {
    _player.dispose(); // إغلاق المحرك عند الخروج لمنع تسريب الذاكرة
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.w,
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => isPlaying ? _player.pause() : _player.play(UrlSource(widget.url)),
            child: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: widget.isMe ? Colors.white : const Color(0xFF005DA3),
              size: 35.sp,
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 12.r),
                trackHeight: 2.h,
              ),
              child: Slider(
                activeColor: widget.isMe ? Colors.white : const Color(0xFF005DA3),
                inactiveColor: widget.isMe ? Colors.white24 : Colors.grey.shade300,
                value: position.inSeconds.toDouble(),
                max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
                onChanged: (val) => _player.seek(Duration(seconds: val.toInt())),
              ),
            ),
          ),
        ],
      ),
    );
  }
}