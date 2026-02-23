import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 هذا هو السطر المنقذ!
enum ContentType { tip, article }
// 2. موديل التوعية (النصائح والمقالات)
class WellnessItem {
  final String id;
  final String title;
  final String content;
  final String author;
  final String category;
  final ContentType type;
  final DateTime date;
  final String? imageUrl;

  WellnessItem({
    required this.id, required this.title, required this.content, required this.author,
    required this.category, required this.type, required this.date, this.imageUrl,
  });

  // 📥 جلب من الفايربيز
  factory WellnessItem.fromMap(Map<String, dynamic> map, String docId) {
    return WellnessItem(
      id: docId,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      author: map['author'] ?? 'مجهول',
      category: map['category'] ?? 'عام',
      // تحويل النص المحفوظ في الفايربيز إلى Enum
      type: ContentType.values.firstWhere((e) => e.name == map['type'], orElse: () => ContentType.tip),
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: map['imageUrl'],
    );
  }

  // 📤 رفع للفايربيز
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'author': author,
      'category': category,
      'type': type.name, // حفظ الـ Enum كنص ('tip' أو 'article')
      'date': FieldValue.serverTimestamp(),
      'imageUrl': imageUrl,
    };
  }
}