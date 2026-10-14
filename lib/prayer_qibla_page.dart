import 'package:flutter/material.dart';

class PrayerQiblaPage extends StatelessWidget {
  const PrayerQiblaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مواقيت الصلاة واتجاه القبلة')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('مواقيت الصلاة لليوم', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Divider(),
                    ListTile(title: Text('الفجر'), trailing: Text('04:30 ص')),
                    ListTile(title: Text('الشروق'), trailing: Text('06:00 ص')),
                    ListTile(title: Text('الظهر'), trailing: Text('12:15 م')),
                    ListTile(title: Text('العصر'), trailing: Text('03:45 م')),
                    ListTile(title: Text('المغرب'), trailing: Text('06:30 م')),
                    ListTile(title: Text('العشاء'), trailing: Text('07:50 م')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('اتجاه القبلة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Icon(Icons.explore, size: 80, color: Colors.teal),
                    const SizedBox(height: 10),
                    const Text('البوصلة تشير نحو الكعبة المشرفة (مكة المكرمة)', textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
