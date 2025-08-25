import 'package:flutter/material.dart';
import 'package:flutter_application_7/widgets/home_action.dart';
import 'hope_box_controller.dart';
import 'hope_box_view.dart';

class HopeBoxPage extends StatefulWidget {
  const HopeBoxPage({super.key});

  @override
  State<HopeBoxPage> createState() => _HopeBoxPageState();
}

class _HopeBoxPageState extends State<HopeBoxPage> {
  late final HopeBoxController c;

  @override
  void initState() {
    super.initState();
    c = HopeBoxController()..load();
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Umut Kutusu'),
        actions: const [HomeAction()],
      ),
      body: AnimatedBuilder(
        animation: c,
        builder: (_, __) => HopeBoxView(
          c: c,
          onAddPhoto: c.addPhoto,
          onAddAudio: c.addAudio,
          onAddReason: c.addReason,
          onAddMessage: c.addMessage,
          onRemove: c.remove,
        ),
      ),
    );
  }
}
