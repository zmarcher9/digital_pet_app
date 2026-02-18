import 'package:flutter/material.dart';
import 'dart:async'; // Required for Timer

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  // --- PART 1 & 2 STATE VARIABLES ---
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;
  double energyLevel = 1.0; // Part 2: Energy Feature
  String selectedActivity = 'Play'; // Part 2: Activity Feature
  
  TextEditingController _nameController = TextEditingController();
  Timer? _hungerTimer;
  Timer? _winTimer;
  int _winSeconds = 0;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    // PART 1: Auto-increasing hunger every 30 seconds
    _hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (!_isGameOver) _updateHunger();
    });

    // PART 1: Win Condition check (Happiness > 80 for 3 mins / 180s)
    _winTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (happinessLevel > 80 && !_isGameOver) {
        _winSeconds++;
        if (_winSeconds >= 180) _showEndDialog("You Win! Your pet is super happy!");
      } else {
        _winSeconds = 0;
      }
    });
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _winTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  // PART 1: Dynamic Color Logic
  Color _getPetColor() {
    if (happinessLevel > 70) return Colors.green;
    if (happinessLevel >= 30) return Colors.yellow;
    return Colors.red;
  }

  // PART 1: Mood Indicator Logic
  String _getMoodText() {
    if (happinessLevel > 70) return "Happy";
    if (happinessLevel >= 30) return "Neutral";
    return "Unhappy";
  }

  // PART 2: Activity Logic (Updates Happiness/Energy/Hunger)
  void _executeActivity() {
    if (_isGameOver) return;
    setState(() {
      if (selectedActivity == 'Play') {
        happinessLevel = (happinessLevel + 10).clamp(0, 100);
        energyLevel = (energyLevel - 0.15).clamp(0.0, 1.0);
        _updateHunger();
      } else if (selectedActivity == 'Sleep') {
        energyLevel = (energyLevel + 0.3).clamp(0.0, 1.0);
        hungerLevel = (hungerLevel + 10).clamp(0, 100);
      } else if (selectedActivity == 'Run') {
        happinessLevel = (happinessLevel + 15).clamp(0, 100);
        energyLevel = (energyLevel - 0.25).clamp(0.0, 1.0);
        hungerLevel = (hungerLevel + 15).clamp(0, 100);
      }
      _checkLossCondition();
    });
  }

  void _feedPet() {
    if (_isGameOver) return;
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      _updateHappiness();
      _checkLossCondition();
    });
  }

  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
    } else {
      happinessLevel = (happinessLevel - 5).clamp(0, 100);
    }
  }

  void _updateHunger() {
    setState(() {
      hungerLevel = (hungerLevel + 5).clamp(0, 100);
      if (hungerLevel >= 100) {
        happinessLevel = (happinessLevel - 20).clamp(0, 100);
      }
      _checkLossCondition();
    });
  }

  // PART 1: Loss Condition
  void _checkLossCondition() {
    if (hungerLevel >= 100 && happinessLevel <= 10) {
      _showEndDialog("Game Over! Hunger reached 100 and Happiness hit 10.");
    }
  }

  void _showEndDialog(String message) {
    _isGameOver = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Game Status"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Digital Pet')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // PART 1: Name Customization
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Enter Pet Name'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => petName = _nameController.text),
                      child: Text('Set Name'),
                    ),
                  ],
                ),
              ),

              // PART 1: Pet Image with ColorFiltered
              ColorFiltered(
                colorFilter: ColorFilter.mode(_getPetColor(), BlendMode.modulate),
                child: Image.asset('assets/images/image1.png', height: 150, errorBuilder: (c, e, s) => Icon(Icons.pets, size: 100, color: _getPetColor())),
              ),

              Text('Name: $petName', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
              
              // PART 1: Mood Indicator
              Text('Mood: ${_getMoodText()}', style: TextStyle(fontSize: 18.0)),
              
              SizedBox(height: 16.0),
              Text('Happiness Level: $happinessLevel', style: TextStyle(fontSize: 20.0)),
              Text('Hunger Level: $hungerLevel', style: TextStyle(fontSize: 20.0)),

              // PART 2: Energy Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10),
                child: Column(
                  children: [
                    Text("Energy Level"),
                    LinearProgressIndicator(value: energyLevel, color: Colors.blue, backgroundColor: Colors.grey[300]),
                  ],
                ),
              ),

              // PART 2: Activity Selection Dropdown
              DropdownButton<String>(
                value: selectedActivity,
                items: <String>['Play', 'Sleep', 'Run'].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (newValue) => setState(() => selectedActivity = newValue!),
              ),

              ElevatedButton(
                onPressed: _executeActivity,
                child: Text('Perform Activity: $selectedActivity'),
              ),
              
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _feedPet,
                child: Text('Feed Your Pet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}