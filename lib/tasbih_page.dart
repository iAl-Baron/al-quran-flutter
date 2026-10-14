import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TasbihPage extends StatefulWidget {
  const TasbihPage({Key? key}) : super(key: key);

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> {
  int _counter = 0;
  String _dhikr = 'سبحان الله';

  void _incrementCounter() {
    setState(() {
      _counter++;
      if (_counter == 34 && _dhikr == 'سبحان الله') {
        _dhikr = 'الحمد لله';
      } else if (_counter == 67 && _dhikr == 'الحمد لله') {
        _dhikr = 'الله أكبر';
      } else if (_counter > 100) {
        _counter = 1;
        _dhikr = 'سبحان الله';
      }
    });
    HapticFeedback.mediumImpact();
  }

  void _reset() {
    setState(() {
      _counter = 0;
      _dhikr = 'سبحان الله';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('السبحة الإلكترونية وتسبيح الزهراء (ع)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _dhikr,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _incrementCounter,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.teal.shade100,
                  border: Border.all(color: Colors.teal, width: 4),
                ),
                child: Center(
                  child: Text(
                    '$_counter',
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة ضبط'),
            ),
          ],
        ),
      ),
    );
  }
}
