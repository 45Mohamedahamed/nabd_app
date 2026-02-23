import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';

// 👇 تأكد من المسارات الصحيحة
import '../../medications/logic/medications_cubit.dart';
import '../../../../core/models/medication_model.dart';

class MyMedicationsScreen extends StatelessWidget {
  const MyMedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ حقن الكيوبت في الشجرة
    return BlocProvider(
      create: (context) => MedicationsCubit(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          title: const Text("جدول أدويتي", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
        ),
        
        body: BlocBuilder<MedicationsCubit, MedicationsState>(
          builder: (context, state) {
            // القيم الافتراضية
            List<MedicationModel> meds = [];
            DateTime selectedDate = DateTime.now();
            bool isLoading = false;

            if (state is MedicationsLoading) {
              isLoading = true;
            } else if (state is MedicationsUpdated) {
              meds = state.medications;
              selectedDate = state.selectedDate;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                
                // 1. عنوان التاريخ
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(selectedDate),
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const Icon(Icons.calendar_month, color: Colors.grey),
                    ],
                  ),
                ),

                SizedBox(height: 15.h),

                // 2. شريط التقويم
                _CalendarStrip(selectedDate: selectedDate),

                SizedBox(height: 20.h),

                // 3. المحتوى
                Expanded(
                  child: isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : meds.isEmpty 
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          itemCount: meds.length,
                          itemBuilder: (context, index) {
                            return FadeInUp(
                              delay: Duration(milliseconds: index * 100),
                              child: _MedicationCard(med: meds[index]),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_services_outlined, size: 60.sp, color: Colors.grey.shade300),
          SizedBox(height: 10.h),
          Text("لا توجد أدوية لهذا اليوم", style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
        ],
      ),
    );
  }
}

// --- 📅 ويدجت شريط التقويم ---
class _CalendarStrip extends StatelessWidget {
  final DateTime selectedDate;
  const _CalendarStrip({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 85.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        scrollDirection: Axis.horizontal,
        itemCount: 30, 
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = date.day == selectedDate.day && date.month == selectedDate.month;

          return GestureDetector(
            onTap: () => context.read<MedicationsCubit>().selectDate(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 60.w,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF005DA3) : Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: isSelected 
                  ? [BoxShadow(color: const Color(0xFF005DA3).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                  : [BoxShadow(color: Colors.grey.shade200, blurRadius: 5)],
                border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade200),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date)[0],
                    style: TextStyle(fontSize: 13.sp, color: isSelected ? Colors.white70 : Colors.grey),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    date.day.toString(),
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- 💊 ويدجت كارت الدواء ---
class _MedicationCard extends StatelessWidget {
  final MedicationModel med;
  const _MedicationCard({required this.med});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (med.status == 'taken') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = "Taken";
    } else if (med.status == 'missed') {
      statusColor = Colors.red;
      statusIcon = Icons.warning_amber_rounded;
      statusText = "Missed";
    } else {
      statusColor = const Color(0xFF005DA3);
      statusIcon = Icons.access_time_filled;
      statusText = "Pending";
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Icon(Icons.medication, color: statusColor, size: 26.sp),
          ),
          SizedBox(width: 16.w),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14.sp, color: Colors.grey),
                    SizedBox(width: 4.w),
                    Text(med.time, style: TextStyle(fontSize: 12.sp, color: Colors.grey[700], fontWeight: FontWeight.w500)),
                    SizedBox(width: 8.w),
                    Text("• ${med.dose}", style: TextStyle(fontSize: 12.sp, color: Colors.grey[500])),
                  ],
                ),
              ],
            ),
          ),

          med.status == 'pending'
            ? InkWell(
                onTap: () => context.read<MedicationsCubit>().takeMedication(med.id),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF005DA3), Color(0xFF007AD9)]),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [BoxShadow(color: const Color(0xFF005DA3).withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
                  ),
                  child: Text("Take", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.sp)),
                ),
              )
            : Column(
                children: [
                  Icon(statusIcon, color: statusColor, size: 28.sp),
                  Text(statusText, style: TextStyle(color: statusColor, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                ],
              ),
        ],
      ),
    );
  }
}