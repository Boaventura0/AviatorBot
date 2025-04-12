import 'package:flutter/material.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(FlyVisionApp());
}

class FlyVisionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlyVision',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: FlyVisionHome(),
    );
  }
}

class FlyVisionHome extends StatefulWidget {
  @override
  _FlyVisionHomeState createState() => _FlyVisionHomeState();
}

class _FlyVisionHomeState extends State<FlyVisionHome> {
  final TextEditingController _controller = TextEditingController();
  final List<double> _entries = [];
  String _suggestion = '';
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
    _loadData();
  }

  void _initializeNotifications() {
    final InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: IOSInitializationSettings(),
    );
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _showNotification(String title, String body) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'default_channel_id',
        'Default Channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
  }

  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _entries.addAll(prefs.getStringList('multipliers')?.map((e) => double.parse(e)) ?? []);
    });
  }

  void _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('multipliers', _entries.map((e) => e.toString()).toList());
  }

  void _analyze() {
    if (_controller.text.isEmpty) return;

    try {
      final value = double.parse(_controller.text.replaceAll(',', '.'));
      setState(() {
        _entries.add(value);
        _controller.clear();
        _generateSuggestion();
        _saveData();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Digite um número válido.')),
      );
    }
  }

  void _generateSuggestion() {
    if (_entries.isEmpty) return;
    final recent = _entries.takeLast(5);
    final lowCount = recent.where((x) => x < 2).length;
    final highCount = recent.where((x) => x > 10).length;

    if (lowCount >= 3) {
      _suggestion = 'Possível voo alto se padrão se repetir';
      _showNotification('Alerta de Tendência', 'Possível voo alto se padrão se repetir');
    } else if (highCount >= 3) {
      _suggestion = 'Evite apostar agora. Muitas altas recentes';
      _showNotification('Alerta de Tendência', 'Evite apostar agora. Muitas altas recentes');
    } else {
      _suggestion = 'Padrão instável. Aposte com cautela';
    }
  }

  double get _average =>
      _entries.isEmpty ? 0.0 : _entries.reduce((a, b) => a + b) / _entries.length;

  List<FlSpot> _generateSpots() {
    return List.generate(
      _entries.length,
      (index) => FlSpot(index.toDouble(), _entries[index]),
    );
  }

  Widget _buildChart() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _generateSpots(),
              isCurved: true,
              colors: [Colors.deepPurple],
              barWidth: 3,
              belowBarData: BarAreaData(show: false),
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FlyVision – Aviator Stats')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _controller,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Digite o multiplicador do voo',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _analyze(),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _analyze,
                child: Text('Analisar'),
              ),
              SizedBox(height: 20),
              Text('Média: ${_average.toStringAsFixed(2)}'),
              Text('Total de voos: ${_entries.length}'),
              Text('Sugestão: $_suggestion'),
              SizedBox(height: 20),
              if (_entries.isNotEmpty) _buildChart(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _entries.clear();
                    _suggestion = '';
                  });
                  _saveData();
                },
                child: Text('Limpar Dados'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension LastN<T> on List<T> {
  Iterable<T> takeLast(int n) => skip(length - min(length, n));
}
