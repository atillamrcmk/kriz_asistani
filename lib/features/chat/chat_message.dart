// lib/features/chat/chat_message.dart
enum ChatRole { user, assistant }

enum Sentiment { calm, sad, anxious, angry, panicked, neutral, positive }

Sentiment _parseSentiment(String? s) {
  switch ((s ?? "neutral").toLowerCase()) {
    case "calm":
      return Sentiment.calm;
    case "sad":
      return Sentiment.sad;
    case "anxious":
      return Sentiment.anxious;
    case "angry":
      return Sentiment.angry;
    case "panicked":
      return Sentiment.panicked;
    case "positive":
      return Sentiment.positive;
    default:
      return Sentiment.neutral;
  }
}

class ChatMessage {
  final ChatRole role;
  final String content;
  final DateTime createdAt;
  final Sentiment? sentiment; // assistant cevabında kullanacağız

  ChatMessage({
    required this.role,
    required this.content,
    this.sentiment,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isUser => role == ChatRole.user;

  Map<String, dynamic> toJson() => {
    "role": role == ChatRole.user ? "user" : "assistant",
    "content": content,
  };

  factory ChatMessage.assistant(String text, {String? sentiment}) =>
      ChatMessage(
        role: ChatRole.assistant,
        content: text,
        sentiment: _parseSentiment(sentiment),
      );
}
