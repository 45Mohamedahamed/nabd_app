import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart'; 
import '../models/chat_models.dart';
import 'chat_screen.dart';
import '../../../core/widgets/smart_chat_button.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> with SingleTickerProviderStateMixin {
  final Color mainColor = const Color(0xFF005DA3);
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // إعادة بناء الواجهة لحظياً عند البحث أو تغيير التبويب
    _tabController.addListener(() => setState(() {}));
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("الرسائل", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            _buildSearchBar(),
            SizedBox(height: 20.h),
            _buildTabSection(),
            SizedBox(height: 20.h),
            Expanded(
              child: _buildFirebaseChatsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: const SmartChatButton(),
    );
  }

  // --- 📡 المحرك الحقيقي: جلب البيانات وتصفيتها ذكياً ---
  Widget _buildFirebaseChatsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .orderBy('lastTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState("لا توجد محادثات نشطة حالياً");
        }

        // تحويل الوثائق إلى موديلات مع تطبيق الفلترة (Search + Tabs)
        var chats = snapshot.data!.docs.map((doc) {
          return ChatPreviewModel.fromFirestore(doc, currentUserId);
        }).where((chat) {
          String query = _searchController.text.toLowerCase();
          String tabType = _tabController.index == 0 ? "All" : (_tabController.index == 1 ? "Group" : "Private");
          
          bool matchesSearch = chat.name.toLowerCase().contains(query);
          bool matchesTab = tabType == "All" || chat.type == tabType;
          return matchesSearch && matchesTab;
        }).toList();

        if (chats.isEmpty) return _buildEmptyState("لا توجد نتائج لبحثك");

        return ListView.builder(
          itemCount: chats.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) => _buildChatItem(chats[index]),
        );
      },
    );
  }

  // --- 💎 بناء كارت المحادثة الذكي (The Creative Part) ---
  Widget _buildChatItem(ChatPreviewModel chat) {
    // 🧠 منطق تحليل الرسالة: تحويل الروابط إلى نصوص وصفية
    String displayMessage = chat.lastMessage;
    bool isMedia = displayMessage.contains('https://firebasestorage');
    
    if (isMedia) {
      if (displayMessage.contains('chat_images')) {
        displayMessage = "📷 صورة";
      } else if (displayMessage.contains('chat_voice')) {
        displayMessage = "🎙️ رسالة صوتية";
      } else {
        displayMessage = "📁 ملف مرفق";
      }
    }

    return ListTile(
      onTap: () async {
        // 1. تصفير العداد فور الدخول (نظام احترافي)
        await FirebaseFirestore.instance.collection('chats').doc(chat.id).update({
          'unreadCount.$currentUserId': 0,
        });

        // 2. الانتقال للشاشة مع تمرير البيانات
        if (!mounted) return;
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (c) => ChatScreen(
              chatId: chat.id, 
              receiverName: chat.name, 
              receiverImage: chat.image,
              isOnline: chat.isOnline,
            )
          )
        );
      },
      contentPadding: EdgeInsets.symmetric(vertical: 8.h),
      leading: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade100, width: 2),
            ),
            child: CircleAvatar(
              radius: 28.r,
              backgroundImage: chat.image.startsWith('http') 
                  ? NetworkImage(chat.image) as ImageProvider
                  : AssetImage(chat.image.isEmpty ? 'assets/images/doctor1.png' : chat.image),
            ),
          ),
          if (chat.isOnline)
            Positioned(
              right: 2, bottom: 2,
              child: Container(
                width: 14.w, height: 14.h,
                decoration: BoxDecoration(
                  color: Colors.green, 
                  shape: BoxShape.circle, 
                  border: Border.all(color: Colors.white, width: 2.5)
                ),
              ),
            ),
        ],
      ),
      title: Text(chat.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 5.h),
        child: Text(
          displayMessage, 
          maxLines: 1, 
          overflow: TextOverflow.ellipsis, 
          style: TextStyle(
            color: chat.unreadCount > 0 ? Colors.black : Colors.grey.shade600, 
            fontWeight: chat.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
            fontSize: 13.sp,
          )
        ),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('hh:mm a').format(chat.time), 
            style: TextStyle(color: Colors.grey.shade500, fontSize: 10.sp)
          ),
          SizedBox(height: 8.h),
          if (chat.unreadCount > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: mainColor, 
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [BoxShadow(color: mainColor.withOpacity(0.3), blurRadius: 8)]
              ),
              child: Text(
                chat.unreadCount.toString(), 
                style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)
              ),
            ),
        ],
      ),
    );
  }

  // --- 🛠️ المكونات الثانوية ---
  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15.r)),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(border: InputBorder.none, hintText: "بحث عن طبيب أو مجموعة...", icon: Icon(Icons.search)),
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      height: 45.h,
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(25.r)),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(color: mainColor, borderRadius: BorderRadius.circular(25.r)),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [Tab(text: "الكل"), Tab(text: "مجموعات"), Tab(text: "خاص")],
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 70.sp, color: Colors.grey.shade200),
          SizedBox(height: 15.h),
          Text(text, style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
        ],
      ),
    );
  }
}