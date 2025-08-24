// lib/features/chat/chat_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'chat_message.dart';

class ChatService {
  final String baseUrl; // Emülatör: http://10.0.2.2:8081
  ChatService(this.baseUrl);

  Future<({String action, String reply, String? sentiment})> send(
    List<ChatMessage> history,
  ) async {
    final body = {"messages": history.map((m) => m.toJson()).toList()};

    final res = await http.post(
      Uri.parse("$baseUrl/chat"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception("Chat error ${res.statusCode}: ${res.body}");
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final action = data["action"] as String? ?? "reply";
    final reply = data["reply"] as String? ?? "";
    final sentiment = (data["sentiment"] as Map?)?["label"] as String?;
    return (action: action, reply: reply, sentiment: sentiment);
  }
}
