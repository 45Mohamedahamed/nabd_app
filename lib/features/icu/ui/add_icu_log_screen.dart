import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

// 👇 استدعاء الخدمة (تأكد من المسار الصحيح)
import '../Service/IcuService.dart'; 

class AddIcuLogScreen extends StatefulWidget {
  final String patientId;
  const AddIcuLogScreen({super.key, required this.patientId});

  @override
  State<AddIcuLogScreen> createState() => _AddIcuLogScreenState();
}

class _AddIcuLogScreenState extends State<AddIcuLogScreen> {
  // 🎨 Palette (لوحة الألوان)
  final Color mainColor = const Color(0xFF005DA3);
  final Color criticalColor = const Color(0xFFD32F2F);
  final Color stableColor = const Color(0xFF388E3C);
  final Color medicationColor = const Color(0xFF1976D2);
  final Color noteColor = const Color(0xFFF57C00);

  // ⚙️ Variables
  String _selectedType = 'vital'; // vital, medication, note
  
  // Vitals Data
  double _heartRate = 75;
  double _oxygenLevel = 98;
  final TextEditingController _bpSystolicController = TextEditingController(text: "120");
  final TextEditingController _bpDiastolicController = TextEditingController(text: "80");
  
  // Note Data
  final TextEditingController _noteController = TextEditingController();
  
  bool _isLoading = false;
  
  // Quick Tags
  final List<String> _quickTags = ["مستقر", "نائم", "ألم بسيط", "ضيق تنفس", "تغيير محاليل", "إفاقة"];
  String _selectedTag = "";

  @override
  void dispose() {
    _bpSystolicController.dispose();
    _bpDiastolicController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // 🚀 المحرك الرئيسي: إرسال البيانات
  Future<void> _submitLog() async {
    if (_selectedType != 'vital' && _noteController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى كتابة التفاصيل")));
       return;
    }

    setState(() => _isLoading = true);
    
    // جلب بيانات المستخدم الحالي
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String doctorId = currentUser?.uid ?? 'unknown';
    // نحاول جلب الاسم، وإلا نضع اسم افتراضي
    final String nurseName = currentUser?.displayName ?? 'تمريض مناوب'; 

    try {
      // 1️⃣ حساب حالة الخطورة (Logic)
      String status = 'Stable';
      if (_selectedType == 'vital') {
        // قواعد طبية بسيطة للإنذار
        if (_oxygenLevel < 90 || _heartRate > 120 || _heartRate < 50) {
          status = 'Critical';
        }
        // يمكن إضافة فحص للضغط هنا أيضاً
      } else {
        status = 'Info'; // الملاحظات والأدوية تأخذ حالة معلوماتية
      }

      // 2️⃣ بناء الـ Map بدقة لتتوافق مع IcuLogModel
      final Map<String, dynamic> logData = {
        'patientId': widget.patientId,
        'doctorId': doctorId,
        'nurseName': nurseName,
        'type': _selectedType,
        'status': status,
        'timestamp': FieldValue.serverTimestamp(), // الوقت من السيرفر حصراً
      };

      // 3️⃣ تعبئة البيانات حسب النوع
      if (_selectedType == 'vital') {
        logData['title'] = 'فحص علامات حيوية';
        logData['description'] = 'تسجيل دوري للعلامات الحيوية ($status)';
        
        // تحويل الأرقام لـ int لضمان التوافق مع المودل
        logData['heartRate'] = _heartRate.toInt();
        logData['oxygenLevel'] = _oxygenLevel.toInt();
        logData['bpSystolic'] = int.tryParse(_bpSystolicController.text) ?? 120;
        logData['bpDiastolic'] = int.tryParse(_bpDiastolicController.text) ?? 80;
      } else {
        // للأدوية والملاحظات
        logData['title'] = _selectedType == 'medication' ? 'إعطاء دواء' : 'ملاحظة تمريضية';
        logData['description'] = _noteController.text;
        // لا نرسل heartRate وغيره هنا ليكونوا null في المودل
      }

      // 4️⃣ الإرسال عبر الخدمة
      await IcuService.addLog(logData);

      if (mounted) {
        Navigator.pop(context);
        _showSuccessFeedback(status == 'Critical');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("⚠️ خطأ: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessFeedback(bool isCritical) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isCritical ? criticalColor : stableColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            Icon(isCritical ? Icons.warning_amber_rounded : Icons.check_circle, color: Colors.white),
            SizedBox(width: 10.w),
            Expanded(child: Text(isCritical ? "⚠️ تنبيه: تم تسجيل حالة حرجة!" : "✅ تم الحفظ بنجاح")),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 30.h),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildTimeHeader(),
            SizedBox(height: 20.h),
            
            FadeInDown(duration: Duration(milliseconds: 400), child: _buildTypeSelector()),
            SizedBox(height: 25.h),
            
            // التبديل السلس بين الواجهات
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: Offset(0, 0.1), end: Offset.zero).animate(animation), child: child)),
              child: _selectedType == 'vital' 
                  ? _buildVitalsSection() 
                  : _buildNotesSection(), // نستخدم نفس الواجهة للملاحظات والأدوية
            ),
            
            SizedBox(height: 30.h),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  // --- 🛠️ المكونات (Widgets) ---

  Widget _buildTimeHeader() {
    return Center(
      child: FadeInDown(
        delay: Duration(milliseconds: 200),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time, size: 14.sp, color: Colors.grey),
              SizedBox(width: 5.w),
              Text(DateFormat('EEEE, hh:mm a').format(DateTime.now()), style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: 12.sp)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          _buildTabItem("علامات حيوية", "vital", Icons.monitor_heart, stableColor),
          _buildTabItem("أدوية", "medication", Icons.medication, medicationColor),
          _buildTabItem("ملاحظات", "note", Icons.edit_note, noteColor),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, String value, IconData icon, Color activeColor) {
    bool isSelected = _selectedType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 22.sp),
              SizedBox(height: 4.h),
              Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 11.sp, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  // 🩸 قسم العلامات الحيوية
  Widget _buildVitalsSection() {
    return Column(
      key: const ValueKey('vital'),
      children: [
        _buildVitalSlider("نبض القلب", _heartRate, 40, 180, "BPM", Icons.favorite, (v) => setState(() => _heartRate = v)),
        SizedBox(height: 15.h),
        _buildVitalSlider("نسبة الأكسجين", _oxygenLevel, 70, 100, "%", Icons.air, (v) => setState(() => _oxygenLevel = v)),
        SizedBox(height: 15.h),
        _buildBPInput(),
      ],
    );
  }

  Widget _buildVitalSlider(String label, double val, double min, double max, String unit, IconData icon, Function(double) onChanged) {
    // تحديد لون الخطورة ديناميكياً
    Color color;
    if (label == "نبض القلب") {
        color = (val > 120 || val < 50) ? criticalColor : stableColor;
    } else {
        color = (val < 90) ? criticalColor : stableColor;
    }

    return FadeInUp(
      child: Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: color.withOpacity(0.3))),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                  ],
                ),
                Text("${val.toInt()} $unit", style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18.sp)),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(trackHeight: 4, thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8), overlayShape: RoundSliderOverlayShape(overlayRadius: 16)),
              child: Slider(value: val, min: min, max: max, activeColor: color, inactiveColor: color.withOpacity(0.1), onChanged: onChanged),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBPInput() {
    return FadeInUp(
      delay: Duration(milliseconds: 100),
      child: Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(Icons.compress, color: Colors.purple), SizedBox(width: 8.w), Text("ضغط الدم (BP)", style: TextStyle(fontWeight: FontWeight.bold))]),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(child: _bpTextField(_bpSystolicController, "Systolic (120)")),
                Padding(padding: EdgeInsets.symmetric(horizontal: 10.w), child: Text("/", style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(child: _bpTextField(_bpDiastolicController, "Diastolic (80)")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bpTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
      decoration: InputDecoration(
        hintText: hint,
        filled: true, fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(vertical: 10.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
      ),
    );
  }

  // 📝 قسم الملاحظات والأدوية
  Widget _buildNotesSection() {
    return Column(
      key: const ValueKey('notes'),
      children: [
        // وسوم سريعة
        FadeInUp(
          child: Wrap(
            spacing: 8.w,
            children: _quickTags.map((tag) => ChoiceChip(
              label: Text(tag),
              selected: _selectedTag == tag,
              selectedColor: (_selectedType == 'medication' ? medicationColor : noteColor).withOpacity(0.2),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(color: _selectedTag == tag ? (_selectedType == 'medication' ? medicationColor : noteColor) : Colors.black87),
              side: BorderSide(color: Colors.grey.shade200),
              onSelected: (val) {
                setState(() {
                  _selectedTag = val ? tag : "";
                  if (val) _noteController.text = _noteController.text.isEmpty ? tag : "${_noteController.text}، $tag";
                });
              },
            )).toList(),
          ),
        ),
        SizedBox(height: 15.h),
        
        // حقل الإدخال
        FadeInUp(
          delay: Duration(milliseconds: 100),
          child: TextField(
            controller: _noteController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: _selectedType == 'medication' ? "اسم الدواء، الجرعة، طريقة الإعطاء..." : "سجل ملاحظات التمريض، شكوى المريض، التغييرات...",
              fillColor: Colors.white, filled: true,
              prefixIcon: Icon(_selectedType == 'medication' ? Icons.medication_liquid : Icons.edit_note, color: Colors.grey),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: _selectedType == 'medication' ? medicationColor : noteColor)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    Color btnColor = _selectedType == 'vital' 
        ? ((_oxygenLevel < 90 || _heartRate > 120) ? criticalColor : mainColor) 
        : (_selectedType == 'medication' ? medicationColor : noteColor);

    return FadeInUp(
      delay: Duration(milliseconds: 200),
      child: SizedBox(
        width: double.infinity,
        height: 55.h,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitLog,
          style: ElevatedButton.styleFrom(
            backgroundColor: btnColor,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            shadowColor: btnColor.withOpacity(0.4),
          ),
          child: _isLoading 
            ? const CircularProgressIndicator(color: Colors.white) 
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_as, color: Colors.white),
                  SizedBox(width: 8.w),
                  const Text("حفظ السجل", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("إضافة سجل جديد", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      leading: IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
    );
  }
}