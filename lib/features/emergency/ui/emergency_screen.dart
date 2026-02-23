import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  // --- 1. متغيرات الحالة والتحكم ---
  final _formKey = GlobalKey<FormState>();
  String _selectedCase = "غير محدد";
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;
  String? _activeRequestId; // حفظ معرف الطلب النشط للتتبع

  // أنواع الحالات الطارئة
  final List<Map<String, dynamic>> _caseTypes = [
    {"name": "أزمة قلبية", "icon": Icons.favorite_rounded, "color": Colors.red},
    {"name": "حوادث/كسور", "icon": Icons.accessible_forward_rounded, "color": Colors.orange},
    {"name": "صعوبة تنفس", "icon": Icons.air_rounded, "color": Colors.blue},
    {"name": "نزيف حاد", "icon": Icons.bloodtype_rounded, "color": Colors.red.shade900},
    {"name": "حروق", "icon": Icons.local_fire_department_rounded, "color": Colors.deepOrange},
    {"name": "أخرى", "icon": Icons.medical_services_rounded, "color": Colors.grey},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F8),
      appBar: AppBar(
        title: const Text("خدمة الطوارئ العاجلة", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red.shade800,
        elevation: 0,
        centerTitle: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r))),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // 🚨 الجزء الأول: لو فيه طلب نشط، اعرض التتبع لايف فوق
            if (_activeRequestId != null) 
              FadeInDown(child: _buildLiveTrackingStatus(_activeRequestId!)),

            // 📝 الجزء الثاني: عرض الفورم فقط إذا لم يكن هناك طلب نشط
            if (_activeRequestId == null) 
              _buildEmergencyForm()
            else
              // زر لتقديم طلب جديد (اختياري)
              Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: TextButton.icon(
                  onPressed: () => setState(() => _activeRequestId = null),
                  icon: const Icon(Icons.add_alert, color: Colors.red),
                  label: const Text("تقديم بلاغ جديد", style: TextStyle(color: Colors.red)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- 🛠️ بناء واجهة الفورم ---
  Widget _buildEmergencyForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Pulse(
              infinite: true,
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.warning_amber_rounded, color: Colors.red, size: 60.sp),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text("1. حدد نوع الحالة الطارئة:", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 15.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 10.w, mainAxisSpacing: 10.h, childAspectRatio: 1,
            ),
            itemCount: _caseTypes.length,
            itemBuilder: (context, index) {
              bool isSelected = _selectedCase == _caseTypes[index]['name'];
              return GestureDetector(
                onTap: () => setState(() => _selectedCase = _caseTypes[index]['name']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: isSelected ? _caseTypes[index]['color'] : Colors.white,
                    borderRadius: BorderRadius.circular(15.r),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_caseTypes[index]['icon'], color: isSelected ? Colors.white : _caseTypes[index]['color'], size: 30.sp),
                      SizedBox(height: 5.h),
                      Text(_caseTypes[index]['name'], 
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87),
                        textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 30.h),
          Text("2. بيانات التواصل:", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 10.h),
          _buildInput(controller: _nameController, hint: "اسم المريض", icon: Icons.person),
          SizedBox(height: 10.h),
          _buildInput(controller: _phoneController, hint: "رقم تواصل سريع", icon: Icons.phone, type: TextInputType.phone),
          SizedBox(height: 10.h),
          _buildInput(controller: _notesController, hint: "وصف سريع للمكان (اختياري)", icon: Icons.description, lines: 2),
          SizedBox(height: 40.h),
          SizedBox(
            width: double.infinity,
            height: 60.h,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitEmergencyBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade800,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send_rounded, color: Colors.white),
                      SizedBox(width: 10.w),
                      Text("إرسال طلب استغاثة الآن", 
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 🔥 منطق التتبع الحي (Live Tracking Widgets) ---
  Widget _buildLiveTrackingStatus(String requestId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('emergency_bookings').doc(requestId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox();
        
        var data = snapshot.data!.data() as Map<String, dynamic>;
        String status = data['status'] ?? 'pending';

        return Container(
          margin: EdgeInsets.symmetric(vertical: 20.h),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.r),
            boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.15), blurRadius: 25, spreadRadius: 5)],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.emergency_share, color: Colors.red, size: 28),
                  SizedBox(width: 12.w),
                  Text("حالة طلب الاستغاثة", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.red.shade900)),
                  const Spacer(),
                  _buildPulsePoint(status == 'pending' ? Colors.orange : Colors.green),
                ],
              ),
              SizedBox(height: 25.h),
              _buildStatusTimeline(status),
              SizedBox(height: 20.h),
              if (status == 'pending')
                const Text("إشارتك وصلت، جاري تحديد أقرب مسعف...", 
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusTimeline(String currentStatus) {
    bool isResponding = currentStatus == 'responding' || currentStatus == 'reached';
    bool isReached = currentStatus == 'reached';

    return Row(
      children: [
        _buildStep("تم الطلب", true),
        _buildLine(isResponding),
        _buildStep("في الطريق", isResponding),
        _buildLine(isReached),
        _buildStep("وصلنا", isReached),
      ],
    );
  }

  Widget _buildStep(String title, bool isDone) {
    return Column(
      children: [
        Icon(isDone ? Icons.check_circle : Icons.radio_button_unchecked, 
          color: isDone ? Colors.green : Colors.grey, size: 24.sp),
        SizedBox(height: 4.h),
        Text(title, style: TextStyle(fontSize: 10.sp, 
          fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
          color: isDone ? Colors.black : Colors.grey)),
      ],
    );
  }

  Widget _buildLine(bool isDone) => Expanded(
    child: Container(height: 3.h, color: isDone ? Colors.green : Colors.grey.shade300, margin: EdgeInsets.only(bottom: 15.h))
  );

  Widget _buildPulsePoint(Color color) => Pulse(
    infinite: true,
    child: Container(width: 12.w, height: 12.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle))
  );

  // --- 🚀 منطق الحجز الفعلي ---
  void _submitEmergencyBooking() async {
    if (_selectedCase == "غير محدد") {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى اختيار نوع الحالة أولاً")));
       return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      Position position = await _determinePosition();
      String uid = FirebaseAuth.instance.currentUser?.uid ?? "guest";

      // إنشاء الوثيقة والحصول على الـ ID
      DocumentReference docRef = await FirebaseFirestore.instance.collection('emergency_bookings').add({
        'userId': uid,
        'patientName': _nameController.text,
        'phone': _phoneController.text,
        'caseType': _selectedCase,
        'notes': _notesController.text,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _activeRequestId = docRef.id; // حفظ المعرف للانتقال لواجهة التتبع
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم إرسال استغاثتك بنجاح ✅"), backgroundColor: Colors.green)
      );

    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("خطأ: $e")));
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('GPS مغلق، يرجى تفعيله');
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('تم رفض صلاحية الموقع');
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Widget _buildInput({required TextEditingController controller, required String hint, required IconData icon, int lines = 1, TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      maxLines: lines,
      keyboardType: type,
      validator: (val) => val!.isEmpty ? "مطلوب" : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.red.shade800),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r), borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
      ),
    );
  }
}