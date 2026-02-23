import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  final String _apiKey = "YOUR_OPENAI_API_KEY_HERE"; // ⚠️ ضع مفتاحك هنا

  Future<String> analyzeSymptoms(String userMessage) async {
    try {
      final response = await http.post(
        
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          
        },
        
        body: jsonEncode({
          "model": "gpt-3.5-turbo", // أو gpt-4 للكفاءة القصوى
          "messages": [
            {
              "role": "system",
              "content": "You are a medical triage assistant. Analyze the user's symptoms. Ask clarifying questions if needed. If you have enough info, suggest the medical specialty (e.g., Cardiology, Neurology) and advise them to book an appointment. Keep answers concise."
            },
            {
              "role": "user",
              "content": userMessage
            }
          ],
          "max_tokens": 150,
        }),
        
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return "عذراً، لا يمكنني تحليل الأعراض الآن. يرجى المحاولة لاحقاً.";
      }
    } catch (e) {
      return "خطأ في الاتصال: $e";
    }
  }
}