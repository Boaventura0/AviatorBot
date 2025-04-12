import 'package:flutter/material.dart';
import 'dart:math';
import 'bot.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final List<double> voosAnteriores = [1.5, 2.3, 3.1, 1.9, 2.5, 3.0, 4.2, 2.7];

  @override
  Widget build(BuildContext context) {
    double previsao = preverProximoVoo(voosAnteriores);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Bot Aviator')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Previsão do próximo voo:'),
              SizedBox(height: 10),
              Text(
                '${previsao.toStringAsFixed(2)}x',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
