import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart'; // 1️⃣ لجلب بيانات الطبيب الحالي

// 👇 استيراد الخدمات والموديل (تأكد من صحة المسارات في مشروعك)
import '../../notification_services/services/notification_service.dart';
import '../model/medical_record_model.dart'; // 2️⃣ الموديل الموحد
import '../services/medical_record_service.dart'; // 3️⃣ خدمة الفايربيز

class AddTreatmentScreen extends StatefulWidget {
  final String? patientId;
  const AddTreatmentScreen({super.key, this.patientId});

  @override
  State<AddTreatmentScreen> createState() => _AddTreatmentScreenState();
}

class _AddTreatmentScreenState extends State<AddTreatmentScreen> {
  // Colors & Design
  final Color mainColor = const Color(0xFF005DA3);
  final Color accentColor = const Color(0xFF4FC3F7);

  // Controllers
  final TextEditingController _drugNameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Data
  final List<Map<String, String>> _medications = [];

  // Dropdowns
  String _selectedFrequency = 'Twice daily';
  final List<String> _frequencies = ['Once daily', 'Twice daily', '3 times daily', 'Every 8 hours', 'Every 6 hours', 'When needed'];

  String _selectedTiming = 'After meal';
  final List<String> _timings = ['Before meal', 'After meal', 'During meal', 'Before sleep', 'Empty stomach'];

  // Speech Logic
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _activeField = ''; 
  
  // 🔄 Loading State (حالة التحميل أثناء الحفظ)
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    // تهيئة خدمة الإشعارات المحلية
    NotificationService().init();
  }

  // ---------------------------------------------------------
  // 🧠 Logic: Helper Functions
  // ---------------------------------------------------------
  int _getIntervalInHours(String frequency) {
    switch (frequency) {
      case 'Once daily': return 24;
      case 'Twice daily': return 12;
      case '3 times daily': return 8;
      case 'Every 8 hours': return 8;
      case 'Every 6 hours': return 6;
      default: return 24; 
    }
  }

  int _getDurationInDays(String durationText) {
    if (durationText.isEmpty) return 5;
    return int.tryParse(durationText.split(' ')[0]) ?? 5;
  }

  // ---------------------------------------------------------
  // ➕ Add Medication to Local List (UI & Local Notification)
  // ---------------------------------------------------------
  void _addMedicationToList() async {
    if (_drugNameController.text.isEmpty || _dosageController.text.isEmpty) {
      _showToast("Please enter Drug Name and Dosage", isError: true);
      return;
    }

    // جدولة التنبيه محلياً على جهاز المريض/المستخدم
    int interval = _getIntervalInHours(_selectedFrequency);
    int days = _getDurationInDays(_durationController.text.isNotEmpty ? _durationController.text : "5 Days");
    int uniqueId = DateTime.now().millisecondsSinceEpoch ~/ 1000; 

    if (!_selectedFrequency.contains("When needed")) { 
      await NotificationService().scheduleMedication(
        baseId: uniqueId,
        medicineName: _drugNameController.text,
        dosage: _dosageController.text,
        intervalHours: interval,
        totalDays: days,
      );
    }

    setState(() {
      _medications.add({
        "name": _drugNameController.text,
        "dose": _dosageController.text,
        "duration": _durationController.text.isNotEmpty ? _durationController.text : "5 Days",
        "freq": _selectedFrequency,
        "time": _selectedTiming,
        "notes": _notesController.text,
      });
      
      _drugNameController.clear();
      _dosageController.clear();
      _durationController.clear();
      _notesController.clear();
      
      FocusScope.of(context).unfocus();
    });
    
    _showToast("تمت إضافة الدواء للقائمة 💊");
  }

  // ---------------------------------------------------------
  // 🚀 Submit to Firebase (الربط الحقيقي مع قاعدة البيانات) ✅
  // ---------------------------------------------------------
  void _submitPrescription() async {
    // 1. التحقق من وجود أدوية
    if (_medications.isEmpty) return;

    // 2. تفعيل وضع التحميل
    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      // 3. إنشاء سجل طبي موحد (UnifiedMedicalRecord)
      final newRecord = UnifiedMedicalRecord(
        id: '', // سيقوم الفايربيز بتوليد ID تلقائي
        patientId: widget.patientId ?? 'unknown',
        type: RecordType.prescription, // تحديد النوع كـ روشتة
        title: "وصفة علاجية جديدة",
        doctorName: user?.displayName ?? "د. غير محدد",
        doctorId: user?.uid ?? '',
        date: DateTime.now(),
        summary: "تم وصف ${_medications.length} أدوية (انظر التفاصيل).",
        details: {
          'medications': _medications, // تخزين قائمة الأدوية بالكامل
        },
      );

      // 4. الإرسال إلى الفايربيز باستخدام السيرفر الذي أنشأناه
      await MedicalRecordService().addRecord(newRecord);

      if (!mounted) return;

      _showToast("✅ تم حفظ الروشتة في ملف المريض");
      
      // 5. العودة للشاشة السابقة (ستتحدث تلقائياً بفضل StreamBuilder)
      Navigator.pop(context);

    } catch (e) {
      _showToast("❌ حدث خطأ أثناء الحفظ: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ---------------------------------------------------------
  // 🎙️ Voice Input Logic
  // ---------------------------------------------------------
  void _listen(TextEditingController controller, String fieldName) async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            setState(() { _isListening = false; _activeField = ''; });
          }
        },
        onError: (val) => debugPrint('Voice Error: $val'),
      );

      if (!mounted) return;

      if (available) {
        setState(() { _isListening = true; _activeField = fieldName; });
        _speech.listen(
          onResult: (val) => setState(() => controller.text = val.recognizedWords),
          localeId: 'en_US',
        );
      } else {
        _showToast("Voice input not available", isError: true);
      }
    } else {
      setState(() { _isListening = false; _activeField = ''; });
      _speech.stop();
    }
  }

  void _showToast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [Icon(isError ? Icons.error : Icons.check_circle, color: Colors.white), SizedBox(width: 10.w), Expanded(child: Text(msg))]),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text("Compose Prescription", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context)),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: _isSubmitting 
              ? Center(child: SizedBox(width: 20.w, height: 20.w, child: CircularProgressIndicator(color: mainColor, strokeWidth: 2)))
              : TextButton.icon(
                  onPressed: _medications.isEmpty ? null : _submitPrescription, // 👈 استدعاء الدالة الجديدة
                  icon: Icon(Icons.send_rounded, size: 18.sp, color: _medications.isEmpty ? Colors.grey : mainColor),
                  label: Text("ISSUE", style: TextStyle(color: _medications.isEmpty ? Colors.grey : mainColor, fontWeight: FontWeight.bold)),
                ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // 1. Patient Card
            FadeInDown(duration: const Duration(milliseconds: 400), child: _buildPatientHeader()),
            SizedBox(height: 25.h),
            
            // 2. Drug Entry Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Medication Details", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    Icon(Icons.auto_awesome, size: 12.sp, color: Colors.purple),
                    SizedBox(width: 4.w),
                    Text("AI Check Active", style: TextStyle(fontSize: 10.sp, color: Colors.purple, fontWeight: FontWeight.bold))
                  ]),
                )
              ],
            ),
            SizedBox(height: 15.h),

            // Drug Name Input
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: _buildVoiceTextField(
                controller: _drugNameController,
                label: "Trade Name / Generic Name",
                icon: Icons.medication_liquid_rounded,
                fieldName: 'drug',
                hint: "e.g. Panadol Advance 500",
              ),
            ),
            SizedBox(height: 15.h),

            // Dose & Duration Row
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildVoiceTextField(
                      controller: _dosageController,
                      label: "Dose",
                      icon: Icons.vaccines,
                      fieldName: 'dose',
                      hint: "500mg",
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 2,
                    child: _buildVoiceTextField(
                      controller: _durationController,
                      label: "Duration",
                      icon: Icons.timer_outlined,
                      fieldName: 'duration',
                      hint: "5 Days",
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15.h),

            // Frequency Dropdown
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFrequency,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: mainColor),
                    items: _frequencies.map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value, style: TextStyle(fontSize: 14.sp)));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedFrequency = val!),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Timings
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Instructions", style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _timings.map((timing) {
                      bool isSelected = _selectedTiming == timing;
                      return ChoiceChip(
                        label: Text(timing),
                        selected: isSelected,
                        selectedColor: mainColor,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12.sp,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                          side: BorderSide(color: isSelected ? mainColor : Colors.grey.shade300),
                        ),
                        onSelected: (val) => setState(() => _selectedTiming = timing),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Notes
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: _buildVoiceTextField(
                controller: _notesController,
                label: "Additional Notes",
                icon: Icons.note_alt_outlined,
                fieldName: 'notes',
                hint: "Specific instructions...",
                maxLines: 2,
              ),
            ),
            SizedBox(height: 25.h),

            // Add Button
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: SizedBox(
                width: double.infinity,
                height: 55.h,
                child: ElevatedButton.icon(
                  onPressed: _addMedicationToList,
                  icon: const Icon(Icons.add_circle, color: Colors.white),
                  label: const Text("ADD TO LIST", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                    elevation: 8,
                    shadowColor: mainColor.withOpacity(0.4),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30.h),
            
            // 3. Preview List
            if (_medications.isNotEmpty) ...[
              Divider(thickness: 1, color: Colors.grey[300]),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Prescription Preview", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                      child: Text("${_medications.length} Items", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _medications.length,
                itemBuilder: (context, index) => _buildMedicationCard(index),
              ),
            ],
            SizedBox(height: 50.h),
          ],
        ),
      ),
    );
  }

  // --- Widgets (UI) ---

  Widget _buildPatientHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [mainColor, const Color(0xFF1E88E5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: mainColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: CircleAvatar(radius: 25.r, backgroundColor: Colors.grey[200], child: Icon(Icons.person, color: mainColor, size: 30.sp)),
          ),
          SizedBox(width: 15.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Patient ID", style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
              Text("#${widget.patientId ?? 'WALK-IN'}", style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: Text("Active", style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String fieldName,
    String? hint,
    int maxLines = 1,
  }) {
    bool isListening = _isListening && _activeField == fieldName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(label.isNotEmpty) Padding(padding: EdgeInsets.only(bottom: 6.h, left: 5.w), child: Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.grey[700]))),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
            border: Border.all(color: isListening ? Colors.red.withOpacity(0.5) : Colors.grey.shade100),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
              prefixIcon: Icon(icon, color: isListening ? Colors.red : mainColor.withOpacity(0.7)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r), borderSide: BorderSide.none),
              contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
              suffixIcon: GestureDetector(
                onTap: () => _listen(controller, fieldName),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(10.w),
                  margin: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color: isListening ? Colors.red : Colors.grey[100],
                    shape: BoxShape.circle,
                    boxShadow: isListening ? [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)] : [],
                  ),
                  child: Icon(isListening ? Icons.mic : Icons.mic_none_rounded, color: isListening ? Colors.white : Colors.grey[600], size: 20.sp),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationCard(int index) {
    final item = _medications[index];
    return SlideInLeft(
      duration: const Duration(milliseconds: 300),
      child: Dismissible(
        key: Key("${item['name']}_$index"),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20.w),
          margin: EdgeInsets.only(bottom: 10.h),
          decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(15.r)),
          child: const Icon(Icons.delete_forever, color: Colors.red),
        ),
        onDismissed: (_) => setState(() => _medications.removeAt(index)),
        child: Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(color: mainColor.withOpacity(0.08), borderRadius: BorderRadius.circular(12.r)),
                child: Icon(Icons.medication, color: mainColor, size: 24.sp),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.black87)),
                    SizedBox(height: 4.h),
                    Wrap(
                      spacing: 5.w,
                      children: [
                        _buildMiniTag(item['dose']!),
                        _buildMiniTag(item['freq']!),
                        _buildMiniTag(item['time']!),
                        if(item['duration'] != null) _buildMiniTag("${item['duration']} Days", color: Colors.orange),
                      ],
                    ),
                    if (item['notes'] != null && item['notes']!.isNotEmpty)
                      Padding(padding: EdgeInsets.only(top: 5.h), child: Text("Note: ${item['notes']}", style: TextStyle(fontSize: 11.sp, color: Colors.grey[600], fontStyle: FontStyle.italic))),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                onPressed: () => setState(() => _medications.removeAt(index)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniTag(String text, {Color color = const Color(0xFF005DA3)}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(text, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: color)),
    );
  }
}