import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart'; // 👈 تأكد من إضافة qr_flutter في pubspec.yaml
import 'package:intl/intl.dart';

class PrescriptionViewScreen extends StatelessWidget {
  final String patientId;
  final String doctorName;
  // ⚠️ تم تعديل النوع لـ dynamic ليكون مرناً مع بيانات Firebase
  final List<Map<String, dynamic>> medications; 

  const PrescriptionViewScreen({
    super.key,
    required this.patientId,
    required this.doctorName,
    required this.medications,
  });

  @override
  Widget build(BuildContext context) {
    // توليد رقم مرجعي وتاريخ للروشتة
    String prescriptionId = "RX-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
    String date = DateFormat('dd MMM yyyy - hh:mm a').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text("Digital Prescription", 
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_rounded)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.print_rounded)),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 📄 كارت الروشتة الرئيسي
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  // 1️⃣ رأس الروشتة (المستشفى)
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF005DA3),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Smart Hospital", 
                                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                            Text("E-Prescription System", 
                                style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                          ],
                        ),
                        Icon(Icons.local_hospital, color: Colors.white, size: 35.sp),
                      ],
                    ),
                  ),

                  // 2️⃣ بيانات المريض والدكتور
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      children: [
                        _buildInfoRow("Doctor:", doctorName),
                        _buildInfoRow("Patient ID:", "#$patientId"),
                        _buildInfoRow("Date:", date),
                        _buildInfoRow("Ref No:", prescriptionId, isBold: true),
                        SizedBox(height: 10.h),
                        const Divider(thickness: 1, color: Colors.grey),
                      ],
                    ),
                  ),

                  // 3️⃣ قائمة الأدوية (Rx)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("Rx", 
                                style: TextStyle(fontFamily: 'Serif', fontSize: 30.sp, fontWeight: FontWeight.bold, color: const Color(0xFF005DA3))),
                            SizedBox(width: 10.w),
                            Text("Medications List", 
                                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        
                        // توليد القائمة
                        if (medications.isEmpty)
                          Padding(
                            padding: EdgeInsets.all(20.h),
                            child: const Center(child: Text("No medications listed.")),
                          )
                        else
                          ...medications.map((med) => _buildMedicineItem(med)).toList(),
                        
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),

                  // 4️⃣ الختم الرقمي والباركود (Footer)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // التوقيع
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Digital Signature", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                            SizedBox(height: 8.h),
                            // محاكاة للتوقيع (نص مزخرف أو صورة)
                            Text("Dr. ${doctorName.split(' ').first}", 
                                style: TextStyle(fontFamily: 'Cursive', fontSize: 24.sp, color: const Color(0xFF005DA3), fontWeight: FontWeight.bold)),
                            Text("Verified by Smart System", style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
                          ],
                        ),
                        
                        // QR Code
                        Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                              child: QrImageView(
                                data: "RX:$prescriptionId|PAT:$patientId|DR:$doctorName", 
                                version: QrVersions.auto,
                                size: 80.0,
                                foregroundColor: const Color(0xFF005DA3),
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text("Scan to Dispense", style: TextStyle(fontSize: 9.sp, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30.h),

            // زر الخروج النهائي
            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005DA3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                  elevation: 5,
                ),
                child: const Text("Done & Back to Home", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  // --- 🛠️ Helper Widgets ---

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
          Text(value, 
              style: TextStyle(fontSize: 14.sp, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildMedicineItem(Map<String, dynamic> med) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.08), shape: BoxShape.circle),
            child: const Icon(Icons.medication_liquid, color: Color(0xFF005DA3), size: 22),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med['name'] ?? 'Unknown Drug', 
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                SizedBox(height: 4.h),
                // استخدام Safe Access للبيانات
                Text("${med['dose'] ?? ''}  •  ${med['freq'] ?? ''}  •  ${med['duration'] ?? ''}", 
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[700], fontWeight: FontWeight.w500)),
                
                if (med['notes'] != null && med['notes'].toString().isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text("Note: ${med['notes']}", 
                        style: TextStyle(fontSize: 11.sp, color: Colors.orange[800], fontStyle: FontStyle.italic)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}