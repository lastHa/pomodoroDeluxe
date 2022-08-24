import 'dart:async'; // For time management
import 'package:flutter/material.dart';


//TODO: Implementiere DropDownButtons für die Auswahl der zeitintervalle fuer Runden und Pausen
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro Deluxe',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Pomodoro Deluxe'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter_round = 0; // number of rounds done
  int _counter_pause = 0; // number of breaks done
  bool _isInRound = true;                 // This variable displays if the user is in a round or in a break -> import when "Next" Button ist used
  int _counter_for_a_long_break = 4;      // how many rounds until a long break
  int _default_duration_long_break = 20;  // how long is the break at the end of a complete circle
  int _default_duration_round = 25;        // how long do i have to work, before i can do the next break
  int _default_duration_break = 5;        // how long is my normal break


  // minutes & seconds: vars for calculations, digiMinutes/digiSeconds: strings for displaying minutes and seconds
  int minutes = 0;
  int seconds = 0;
  String digiMinutes = "00";
  String digiSeconds = "00";

  // This is our instance of the Timer class -> it will measure the time
  Timer? timer;
  // Our var that displays, if the time should be running or not (start/stop)
  bool start = false;


  void _startStopTime() {
    // Function for stopping the time when the time is running and for starting the time when the time is stopped
    // all functionalities for displaying the time and to register if an interval was completed

    if (start == false){

      setState(() {
        start = true;
      });

      // here the time instance is initialized
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        int localSecs = seconds + 1;
        int localMins = minutes;

        //Case 1: isInRound == True AND localMin >= _default_duration_round -> Stop round -> counter_round + 1
        if (_isInRound && (localMins >= _default_duration_round)){
          timer.cancel();
          localSecs = 0;
          localMins = 0;
          setState(() {
            seconds = localSecs;
            minutes = localMins;
            digiSeconds = (seconds >= 10) ? "$seconds" : "0$seconds";
            digiMinutes = (minutes>=10) ? "$minutes" : "0$minutes";

            _counter_round++;
            _isInRound = false;
            start = false;
          });
        }

        //Case 2: isInRound == False AND _counter_pause < _counter_for_a_long_break
        if (_isInRound == false && (localMins >= _default_duration_break && (_counter_pause < _counter_for_a_long_break-1))){
          timer.cancel();
          localSecs = 0;
          localMins = 0;
          setState(() {
            seconds = localSecs;
            minutes = localMins;
            digiSeconds = (seconds >= 10) ? "$seconds" : "0$seconds";
            digiMinutes = (minutes>=10) ? "$minutes" : "0$minutes";

            _counter_pause++;
            _isInRound = true;
            start = false;
          });
        }

        //Case 3: isInRound == FALSE AND _counter_pause >= __counter_for_a_long_break
        if (_isInRound == false && (localMins >= _default_duration_long_break && (_counter_pause >= _counter_for_a_long_break-1))){
          timer.cancel();
          localSecs = 0;
          localMins = 0;
          setState(() {
            seconds = localSecs;
            minutes = localMins;
            digiSeconds = (seconds >= 10) ? "$seconds" : "0$seconds";
            digiMinutes = (minutes>=10) ? "$minutes" : "0$minutes";

            _counter_pause = 0;
            _counter_round = 0;
            _isInRound = true;
            start = false;
          });
        }

        // without any special cases -> after 60 seconds, minutes will be increased, minutes and seconds will be reseted after 60 minutes
        if (localSecs > 59){
          if (localMins > 59){
             localMins = 0;
             localSecs = 0;
          }
          else{
            localMins++;
            localSecs = 0;
          }
        }
        setState(() {
          seconds = localSecs;
          minutes = localMins;
          digiSeconds = (seconds >= 10) ? "$seconds" : "0$seconds";
          digiMinutes = (minutes>=10) ? "$minutes" : "0$minutes";
        });

      });
    }
    else {
      timer!.cancel();
      setState(() {
        start = false;
      });
    }
  }

  void _skipRound(){
    // function for skipping the actual round and start the next one

    // 1: Stop the actual timer and reset the minutes and seconds to zero
    timer!.cancel();
    setState(() {
      minutes = 0;
      seconds = 0;
      digiMinutes = "00";
      digiSeconds = "00";
      start = false;
    });

    // 2. increase the actual counter for a round or a break by 1 (or if it was the last run: set round and pause to 0)
    if (_isInRound) {
      if (_counter_round < _counter_for_a_long_break){
        setState(() {
          _counter_round++;
          _isInRound = false;
        });
      }
      else{
        setState(() {
          _counter_round = 0;
          _isInRound = false;
        });
      }
    }
    else{
      if (_counter_pause < _counter_for_a_long_break){
        setState(() {
          _counter_pause++;
          _isInRound = true;
        });
      }
      else{
        setState(() {
          _counter_pause = 0;
          _counter_round = 0;
          _isInRound = true;
        });
      }
    }
  }

  //TODO: implement functions for the user settings via DropDownButtons in the Drawer menu -> combine the selection in the DropDownButtons and the functions "_safeSettings", "_resetSettings"
  void _safeSettings() {
    // function for saving the values in the menu
  }

  void _resetSettings(){
    // function for using the default values
    setState(() {
      _counter_for_a_long_break = 4;
      _default_duration_long_break = 20;
      _default_duration_break = 5;
      _default_duration_round = 25;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Deluxe'),
      ),
      // Menu for selecting the settings for the rounds, breaks and co.
      drawer: Drawer(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height:10),
              Text("Number of Round in a Session (default: $_counter_for_a_long_break)"),
              DropDownSelector(countervariable: _counter_for_a_long_break, defaultValue: 4),
              //DropDownSelector(_counter_for_a_long_break, 4),
              SizedBox(height:10),
              Text("Length of a Round (default: 25)"),
              DropDownSelector(countervariable: _default_duration_round, defaultValue: 25),
              //DropDownSelector(_default_duration_round, 25),
              SizedBox(height:10),
              Text("Length of a Break (default: 5)"),
              DropDownSelector(countervariable: _default_duration_break, defaultValue: 5),
              //DropDownSelector(_default_duration_break, 5),
              SizedBox(height:10),
              Text("Length of a Long Break (default: 20)"),
              DropDownSelector(countervariable: _default_duration_long_break, defaultValue: 20),
              //DropDownSelector(_default_duration_long_break, 20),
              SizedBox(height:20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center ,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _safeSettings,
                    child: const Text("Save"),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: _resetSettings,
                      child: const Text("Reset")
                  ),
                ]
              ),
            ],
          ),
        ),
      ),
      body:
        Column(
            children: <Widget>[
              SizedBox(height:30),
              Container(
                child: const Image(image: AssetImage("assets/images/tomato.png"), height: 100, ),
              ),
              Text("Pomodoro Round: $_counter_round Pause: $_counter_pause"),
              SizedBox(height:30),
              Container(
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                    color: Color.fromRGBO(100, 5, 5, 0.4),
                    borderRadius: BorderRadius.circular(8.0)
                ),
                child: Text("$digiMinutes:$digiSeconds", textAlign: TextAlign.center, textScaleFactor: 3,),
              ),
              SizedBox(height:10),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center ,
                  children: <Widget>[
                    ElevatedButton(onPressed: _startStopTime, child: const Text(">")),
                    SizedBox(width: 10,),
                    ElevatedButton(onPressed: _skipRound, child: const Text("Next")),
                ]
            ),
              Text("$_counter_for_a_long_break | $_default_duration_round | $_default_duration_break | $_default_duration_long_break")
          ]
        )
      );
  }
}


// This class will be used for implementing a core for using the Dropdown Buttons for duration selection
class DropDownSelector extends StatefulWidget{
  // Which counter shoud be manipulated?
  int? countervariable;
  // What is the default value of this?
  int? defaultValue;

  //TODO: The problem is to initialize an instance of their class with declared variable and default value
  DropDownSelector({Key? key, this.countervariable, this.defaultValue}): super(key: key);
  //DropDownSelector(int countervariable ,int defaultValue, {Key? key,}) : super(key: key);

  @override
  State<DropDownSelector> createState() => _DropDownSelectorState();
}

class _DropDownSelectorState extends State<DropDownSelector>{
  //int countervariable = DropDownSelector.defaultValue;
  int? countervariable = 4;

  @override
  Widget build(BuildContext context){
    return DropdownButton<String>(
      value: countervariable.toString(),
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.black),
      underline: Container(
        height: 2,
        color: Colors.deepOrangeAccent,
      ),
      onChanged: (String? newValue){
        setState(() {
          countervariable = int.parse(newValue!);
          //_counter_for_a_long_break = countervariable;
        });
      },
      items: <String>["1","2","3","4","5","6","7","8","9","10","15","20","25","30","45","60"].map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
      }).toList(),
    );
  }
}




/* // Versuch eines isolierten Buttons, ohne extra Klasse

DropdownButton(
                onChanged: (String? newValue){
                  setState(() {
                     //value = newValue;
                    _counter_for_a_long_break = int.parse(newValue!);
                  });
                },
                items: <String>["1","2","3","4","5","6","7","8","9","10","15","20","25","30","45","60"].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: _counter_for_a_long_break.toString(),
                      child: Text(value),
                    );
                  }).toList(),
                  ),
 */