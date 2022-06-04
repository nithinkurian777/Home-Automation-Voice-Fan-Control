import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:home_automation/models/mqt_model.dart';

import 'package:home_automation/screens/voice_to_text.dart';
import 'package:home_automation/services/mqtt_service.dart';
import 'package:home_automation/widgets/clicky_button.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

class LogInfoScreen extends StatefulWidget {
  const LogInfoScreen({Key? key}) : super(key: key);

  @override
  State<LogInfoScreen> createState() => _LogInfoScreenState();
}

class _LogInfoScreenState extends State<LogInfoScreen> {
  bool _waterPumpState = false;
  bool _pestPumpState = false;

  late MQTTService _service;

  @override
  void initState() {
    final state = Provider.of<MQTTModel>(context, listen: false);
    _service = MQTTService(
      host: "broker.hivemq.com",
      port: 1883,
      topic: 'carmel_homeautomation_outTopic',
      model: state,
    );

    _service.initializeMQTTClient();
    _service.connectMQTT();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<MQTTModel>(context);

    var message = state.log.msg ?? "{}";

    print("message is");
    print(message);
    print("finish");

    var messageJson = json.decode(message);

    String temperature = (messageJson["temp"] ?? 0).toString();
    String humidity = (messageJson["hum"] ?? 0).toString();

    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Card(
                  color: Colors.green,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Home Monitoring",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              dataWidget("Temprature", temperature, "°C"),
              dataWidget("Humidity", humidity, "%"),
              Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 20),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                child: Text(
                                  'Fan',
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClickyButton(
                                color:
                                    _pestPumpState ? Colors.red : Colors.green,
                                child: Text(
                                  _pestPumpState ? "Turn OFF" : "Turn ON",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _pestPumpState = !_pestPumpState;
                                    _service.publish(
                                        "${_pestPumpState ? "1" : "0"}");
                                  });
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  _pestPumpState
                                      ? Icons.power_rounded
                                      : Icons.power_off_rounded,
                                  color: Colors.blue,
                                  size: 50,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: Icon(Icons.mic),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SpeechToTextPage()));
        },
      ),
    );
  }

  Padding dataWidget(String name, String value, String symbol) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Text(
                      name,
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '$value $symbol',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
