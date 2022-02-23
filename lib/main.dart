import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'news_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  // Muuttujat kiihdytysanturia varten
  List<double>? _accelerometerValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  // Muuttujat alasvetovalikoiden arvoille
  String gameDropdownValue = "Phasmophobia";
  String newsCountDropdownValue = "5";

  // Funktio, jolla napataan oikea tunnus parametrina saadun pelin nimen mukaan
  String getGameId(String gameName){
    switch (gameName) {
      case "Phasmophobia": 
        return "739630";
      case "CS GO": 
        return "730";
      case "Apex Legends":
        return "1172470";
      default:
        return "Oops, you should not be seeing this";
    }
  }

  // Tällä tarkastetaan onko puhelin täysin vaakatasossaja palautetaan väri sen mukaisesti.
  Color getLevelColor(){
      // Joskus buildatessa tulee null error, joten lisäsin tarkastuksen. 
      // Veikkaan, että sovelluksen käynnistyessä _accelerometer on null, 
      // kunnes kuuntelija päivittää muuttujan
      if (_accelerometerValues == null){
        return Colors.white70;
      }
      final yAxis = _accelerometerValues![1];

      if (yAxis < 0.2 && yAxis > -0.2) {
        return Colors.green;
      }
      else if(yAxis < 0.7 && yAxis > -0.7){
        return Colors.yellow;
      }
      else {
        return Colors.white70;
      }
    } 

  @override
  Widget build(BuildContext context) {
    final accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();
    
    

    return Scaffold(
      appBar: AppBar(
        title: const Text('Steam News App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 200,
              color: getLevelColor(),
              child: Text('Accelerometer: $accelerometer'),
              ),
            

            const Text("Select a game: ",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            DropdownButton<String>(
              value: gameDropdownValue,
              icon: const Icon(Icons.menu),
              elevation: 16,
              style: TextStyle(color: Colors.indigo[900]),
              underline: Container(
                height: 2,
                color: Colors.indigoAccent[700],
              ),
              onChanged: (String? newValue) {
                setState(() {
                  gameDropdownValue = newValue!;
                });
              },
              items: <String>['Phasmophobia', 'CS GO', 'Apex Legends']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),

            const Text("Select an amount of news topics:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            DropdownButton<String>(
              value: newsCountDropdownValue,
              icon: const Icon(Icons.menu),
              elevation: 16,
              style: TextStyle(color: Colors.indigo[800]),
              underline: Container(
                height: 2,
                color: Colors.indigoAccent[700],
              ),
              onChanged: (String? newValue) {
                setState(() {
                  newsCountDropdownValue = newValue!;
                });
              },
              items: <String>['5', '10', '20']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),

            /*
            Tällä painikkeella siirrytään toiseen näkymään ja välitetään
            samalla alasvetovalikkojen tiedot seuraavalle näkymälle, jossa
            tiedonhaku toteutetaan kyseisien tietojen perusteella
            */
            ElevatedButton(
              onPressed: (){
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsPageApp(
                    gameTitle: gameDropdownValue, 
                    gameId: getGameId(gameDropdownValue), 
                    newsCount: newsCountDropdownValue
                  )
                ),
                );
              }, 
              child: const Text('Get news'),
            ),
            ],
         ),
      ) 
    );
  }
  
  // Kun näkymä terminoidaan, pysäytetään samalla kaikki kuuntelijat
  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    // Tässä kytkeydytään kuuntelemaan kiihtyvysanturin dataa
    // lisäämällä se taulukkoon, johon on listattu käytettävät kuuntelijat
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          setState(() {
            _accelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    
  }
}

