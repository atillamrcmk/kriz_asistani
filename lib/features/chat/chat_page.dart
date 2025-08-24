// lib/features/chat/chat_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

import 'chat_controller.dart';
import 'chat_message.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});
  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _tc = TextEditingController();
  final _listCtrl = ScrollController();

  // --- SES ---
  late final stt.SpeechToText _stt;
  bool _sttAvailable = false;
  bool _isListening = false;

  late final FlutterTts _tts;

  @override
  void initState() {
    super.initState();
    _initSTT();
    _initTTS();
  }

  Future<void> _initSTT() async {
    _stt = stt.SpeechToText();
    _sttAvailable = await _stt.initialize(
      onStatus: (s) => setState(() => _isListening = s == 'listening'),
      onError: (e) => debugPrint("STT error: $e"),
    );
    setState(() {});
  }

  Future<void> _initTTS() async {
    _tts = FlutterTts();
    // Türkçe için:
    await _tts.setLanguage('tr-TR'); // gerekirse 'tr_TR'
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.45); // okunabilir hız
    await _tts.setVolume(1.0);
  }

  @override
  void dispose() {
    _tc.dispose();
    _listCtrl.dispose();
    _stt.stop();
    _tts.stop();
    super.dispose();
  }

  Future<void> _scrollToEnd() async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (_listCtrl.hasClients) {
      _listCtrl.animateTo(
        _listCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  // --- TTS ---
  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _tts.stop(); // çakışma olmasın
      await _tts.speak(text);
    } catch (_) {}
  }

  // --- STT ---
  Future<void> _toggleListen() async {
    if (!_sttAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cihazda konuşma tanıma kullanılamıyor.")),
      );
      return;
    }

    if (_isListening) {
      await _stt.stop();
      setState(() => _isListening = false);
      return;
    }

    final ok = await _stt.listen(
      localeId: 'tr_TR', // cihaz diline göre 'tr-TR' de olabilir
      partialResults: true,
      onResult: (res) {
        // geçici sonuçları da input alanına yaz
        if (res.recognizedWords.isNotEmpty) {
          setState(() => _tc.text = res.recognizedWords);
          _tc.selection = TextSelection.fromPosition(
            TextPosition(offset: _tc.text.length),
          );
        }
        if (res.finalResult) {
          setState(() => _isListening = false);
        }
      },
    );
    if (ok) setState(() => _isListening = true);
  }

  Future<void> _handleSend() async {
    final txt = _tc.text.trim();
    if (txt.isEmpty) return;
    _tc.clear();
    final res = await ref.read(chatControllerProvider).send(txt);
    await _scrollToEnd();

    // Asistan yanıtını seslendir
    _speak(res.reply);

    if (res.action == "emergency" && mounted) {
      final cs = Theme.of(context).colorScheme;
      // ignore: use_build_context_synchronously
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        backgroundColor: cs.surface,
        builder: (_) => Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Text(
              res.reply,
              style: TextStyle(color: cs.onSurface, fontSize: 16, height: 1.4),
            ),
          ),
        ),
      );
    }
  }

  // renkler (senin önceki sürüm)
  (Color bg, Color fg) _bubbleColors(BuildContext context, ChatMessage m) {
    final cs = Theme.of(context).colorScheme;
    if (m.isUser) return (cs.primaryContainer, cs.onPrimaryContainer);

    switch (m.sentiment) {
      case Sentiment.sad:
        return (Colors.indigo.shade200, Colors.indigo.shade900);
      case Sentiment.anxious:
        return (Colors.orange.shade200, Colors.orange.shade900);
      case Sentiment.angry:
        return (Colors.red.shade300, Colors.red.shade900);
      case Sentiment.panicked:
        return (Colors.redAccent.shade100, Colors.red.shade900);
      case Sentiment.positive:
        return (Colors.green.shade200, Colors.green.shade900);
      case Sentiment.calm:
        return (Colors.blueGrey.shade200, Colors.blueGrey.shade900);
      case Sentiment.neutral:
      default:
        return (
          Theme.of(context).colorScheme.surfaceVariant,
          Theme.of(context).colorScheme.onSurfaceVariant,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(chatControllerProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kriz Sohbet Asistanı"),
        actions: [
          IconButton(
            tooltip: _isListening ? "Dinlemeyi durdur" : "Konuşarak yaz",
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
            onPressed: _toggleListen,
          ),
          IconButton(
            tooltip: "Son cevabı seslendir",
            icon: const Icon(Icons.volume_up),
            onPressed: () {
              // son asistan mesajını oku
              final last = controller.messages.lastWhere(
                (m) => m.role == ChatRole.assistant,
                orElse: () =>
                    ChatMessage(role: ChatRole.assistant, content: ""),
              );
              _speak(last.content);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _listCtrl,
              padding: const EdgeInsets.all(12),
              itemCount: controller.messages.length,
              itemBuilder: (c, i) {
                final m = controller.messages[i];
                final isUser = m.isUser;
                final (bg, fg) = _bubbleColors(context, m);

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.85,
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(14),
                          topRight: const Radius.circular(14),
                          bottomLeft: Radius.circular(isUser ? 14 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 14),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        m.content,
                        style: TextStyle(color: fg, fontSize: 16, height: 1.35),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tc,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSend(),
                      decoration: InputDecoration(
                        hintText: _isListening
                            ? "Dinleniyor..."
                            : "Bir şeyler yaz...",
                        filled: true,
                        fillColor: cs.surfaceVariant.withOpacity(0.60),
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: cs.primary, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: cs.primary,
                    onPressed: _handleSend,
                    tooltip: "Gönder",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
