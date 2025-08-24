// lib/features/chat/chat_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_message.dart';
import 'chat_service.dart';

const String kProxyBaseUrl = "http://10.0.2.2:8081";

final chatServiceProvider = Provider<ChatService>(
  (ref) => ChatService(kProxyBaseUrl),
);
final chatControllerProvider = ChangeNotifierProvider<ChatController>((ref) {
  final api = ref.read(chatServiceProvider);
  return ChatController(api);
});

class ChatController extends ChangeNotifier {
  final ChatService api;
  final List<ChatMessage> messages = [];

  ChatController(this.api) {
    messages.add(
      ChatMessage(
        role: ChatRole.assistant,
        content:
            "Buradayım. Nasıl hissediyorsun? Kısa kısa yazabilirsin; birlikte ilerleyelim.",
      ),
    );
  }

  Future<({String action, String reply, String? sentiment})> send(
    String text,
  ) async {
    if (text.trim().isEmpty)
      return (action: "reply", reply: "", sentiment: null);

    messages.add(ChatMessage(role: ChatRole.user, content: text));
    notifyListeners();

    try {
      final res = await api.send(messages);
      messages.add(ChatMessage.assistant(res.reply, sentiment: res.sentiment));
      notifyListeners();
      return res;
    } catch (_) {
      const fallback = "Şu an yanıt veremiyorum. Biraz sonra tekrar deneriz.";
      messages.add(ChatMessage.assistant(fallback, sentiment: "neutral"));
      notifyListeners();
      return (action: "reply", reply: fallback, sentiment: "neutral");
    }
  }
}
