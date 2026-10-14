import 'package:flutter/material.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> occasions = [
      {'date': '1 رجب', 'event': 'ولادة الإمام محمد الباقر (ع)'},
      {'date': '3 رجب', 'event': 'شهادة الإمام علي الهادي (ع)'},
      {'date': '13 رجب', 'event': 'ولادة أمير المؤمنين الإمام علي (ع)'},
      {'date': '15 رجب', 'event': 'وفاة السيدة زينب (ع)'},
      {'date': '25 رجب', 'event': 'شهادة الإمام موسى الكاظم (ع)'},
      {'date': '27 رجب', 'event': 'المبعث النبوي الشريف'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('التقويم الهجري والمناسبات الإسلامية')),
      body: ListView.builder(
        itemCount: occasions.length,
        itemBuilder: (context, index) {
          final item = occasions[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal,
                child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
              ),
              title: Text(item['event']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['date']!),
            ),
          );
        },
      ),
    );
  }
}
