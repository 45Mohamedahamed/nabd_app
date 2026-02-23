import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import "success_reset_screen.dart"; 

class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final Color mainColor = const Color(0xFF005DA3);
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();
  bool isObscure1 = true;
  bool isObscure2 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("كلمة مرور جديدة"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Text(
              "أنشئ كلمة المرور الجديدة، يجب أن تكون مختلفة عن السابقة.",
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
            SizedBox(height: 30.h),

            // ✅ التصحيح هنا: الأقواس فاضية () بدل (val)
            _buildPassField("كلمة المرور الجديدة", passController, isObscure1, () {
              setState(() => isObscure1 = !isObscure1);
            }),
            
            SizedBox(height: 20.h),

            // ✅ وهنا كمان نفس التصحيح
            _buildPassField("تأكيد كلمة المرور", confirmPassController, isObscure2, () {
              setState(() => isObscure2 = !isObscure2);
            }),

            SizedBox(height: 40.h),
// ... نفس الكود بتاعك بس تأكد من زر الحفظ ...

           SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
            onPressed: () {
            if (passController.text.isEmpty || confirmPassController.text.isEmpty) return;
      
             // 👇 الانتقال لصفحة النجاح
                Navigator.pushReplacement(
                  context, 
                MaterialPageRoute(builder: (c) => const SuccessResetScreen())
                   );
                   },
                    style: ElevatedButton.styleFrom(
                     backgroundColor: mainColor,
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text("حفظ وتغيير", style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                ),
          ],
        ),
      ),
    );
  }

  // الدالة دي بتستقبل VoidCallback وده معناه دالة بدون مدخلات ()
  Widget _buildPassField(String hint, TextEditingController controller, bool obscure, VoidCallback toggle) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: mainColor)),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: toggle,
        ),
      ),
    );
  }
}