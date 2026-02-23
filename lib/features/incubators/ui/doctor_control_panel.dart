import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../incubators/model/IncubatorModel.dart';
import '../../incubators/Service/IncubatorService.dart';

class DoctorControlPanel extends StatelessWidget {
  const DoctorControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة تحكم الطبيب والاستشاري", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.indigo, size: 30),
            onPressed: () => _showAddIncubatorDialog(context),
          )
        ],
      ),
      body: StreamBuilder<List<IncubatorModel>>(
        stream: IncubatorService().getAllIncubatorsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final list = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: list.length,
            itemBuilder: (context, index) => _buildControlCard(context, list[index]),
          );
        },
      ),
    );
  }

  Widget _buildControlCard(BuildContext context, IncubatorModel unit) {
    return Card(
      margin: EdgeInsets.only(bottom: 15.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child: ListTile(
        title: Text("وحدة: ${unit.name}", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("الحالة الحالية: ${unit.status}"),
        trailing: const Icon(Icons.settings_suggest, color: Colors.indigo),
        onTap: () => _showSensorAdjustmentDialog(context, unit),
      ),
    );
  }

  // 🛠️ ديالوج تعديل الحساسات
  void _showSensorAdjustmentDialog(BuildContext context, IncubatorModel unit) {
    final tempController = TextEditingController(text: unit.temperature.toString());
    final heartController = TextEditingController(text: unit.heartRate.toString());
    final oxygenController = TextEditingController(text: unit.oxygenLevel.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("معايرة حساسات ${unit.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(tempController, "درجة الحرارة", Icons.thermostat),
            _buildDialogField(heartController, "نبض القلب", Icons.favorite),
            _buildDialogField(oxygenController, "نسبة الأكسجين", Icons.air),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () async {
              await IncubatorService().updateSensorsManually(
                unit.id,
                double.parse(tempController.text),
                int.parse(heartController.text),
                int.parse(oxygenController.text),
              );
              Navigator.pop(context);
            },
            child: const Text("حفظ التعديلات"),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder()),
      ),
    );
  }

  // ➕ ديالوج إضافة حضانة جديدة
  void _showAddIncubatorDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("إضافة وحدة حضانة جديدة"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "مثال: D-04", border: OutlineInputBorder()),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await IncubatorService().addNewIncubator(nameController.text);
                Navigator.pop(context);
              }
            },
            child: const Text("إضافة"),
          ),
        ],
      ),
    );
  }
}