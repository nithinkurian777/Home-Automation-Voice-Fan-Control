import 'package:flutter/material.dart';
import 'package:home_automation/screens/welcome_screen.dart';

import 'package:provider/provider.dart';
import 'models/models.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InputModel()),
        ChangeNotifierProvider(create: (_) => MQTTModel()),
      ],
      child: MaterialApp(
        title: 'IoT Based Home Automation',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: WelcomeScreen(title: 'IoT Based Home Automation'),
      ),
    );
  }
}
