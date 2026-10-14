import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حول المطور والتطبيق'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تطبيق الأدعية والزيارات الشيعية (النسخة الشاملة)',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'يضم التطبيق 50 دعاءً و50 زيارة شيعية، مواقيت الصلاة، اتجاه القبلة، التقويم الهجري والمناسبات، السبحة الإلكترونية، وتعدد القُرّاء.',
              style: TextStyle(fontSize: 16),
            ),
            const Divider(height: 30),
            const Text(
              'تواصل مع المطور:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.send, color: Colors.blue),
              title: const Text('Telegram'),
              subtitle: const Text('@teq_33'),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.purple),
              title: const Text('Instagram'),
              subtitle: const Text('ig@ra_jc'),
            ),
          ],
        ),
      ),
    );
  }
}
