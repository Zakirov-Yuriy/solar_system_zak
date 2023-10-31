import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const MyApp());

class Planet {
  final String name;
  final double radius;
  final Color color;
  final double distanceFromSun;
  final double rotationSpeed;
  double currentAngle;
  final double selfRotationSpeed;
  final double maxDistanceFromSun;

  Planet(this.name, this.radius, this.color, this.distanceFromSun,
      this.rotationSpeed, this.selfRotationSpeed, this.maxDistanceFromSun)
      : currentAngle = 0.0;

  Material get planetMaterial {
    return const Material(
      color: Colors.transparent,
      shadowColor: Colors.black,
      elevation: 5.0,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.purple, // Устанавливаем цвет темы на фиолетовый
        // Можете также настроить другие параметры темы, такие как шрифты и др.
      ),
      home: const SolarSystemPage(),
    );
  }
}

class SolarSystemPage extends StatefulWidget {
  const SolarSystemPage({super.key});

  @override
  _SolarSystemPageState createState() => _SolarSystemPageState();
}

class _SolarSystemPageState extends State<SolarSystemPage> {
  List<Planet> planets = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.center,
          child: Text('Солнечная система'),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: SolarSystem(planets: planets),
            ),
            // Updated button at the bottom center
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () async {
                  final newPlanet = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PlanetFormScreen(),
                    ),
                  );

                  if (newPlanet != null) {
                    setState(() {
                      planets.add(newPlanet);
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10), // Adjust the radius as needed
                  ),
                ),
                child: const Text('Добавить планету',
                    style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SolarSystem extends StatefulWidget {
  final List<Planet> planets;

  const SolarSystem({super.key, required this.planets});

  @override
  _SolarSystemState createState() => _SolarSystemState();
}

class _SolarSystemState extends State<SolarSystem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double sunPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _controller.addListener(() {
      for (final planet in widget.planets) {
        planet.currentAngle =
            (_controller.value * planet.rotationSpeed * 2 * pi) * -1;
      }

      sunPosition = _controller.value * 2 * pi;

      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(300, 300),
      painter:
          SolarSystemPainter(planets: widget.planets, sunPosition: sunPosition),
    );
  }
}

class SolarSystemPainter extends CustomPainter {
  final List<Planet> planets;
  final double sunPosition;

  SolarSystemPainter({required this.planets, required this.sunPosition});

  @override
  void paint(Canvas canvas, Size size) {
    const sunRadius = 30.0;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final sunPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Colors.yellow, Colors.orange],
      ).createShader(
          Rect.fromCircle(center: Offset(centerX, centerY), radius: sunRadius));

    canvas.drawCircle(
      Offset(centerX, centerY),
      sunRadius,
      sunPaint,
    );

    for (final planet in planets) {
      final planetRadius = planet.radius;
      final planetDistance = planet.distanceFromSun;
      final planetX = centerX + planetDistance * cos(planet.currentAngle);
      final planetY = centerY + planetDistance * sin(planet.currentAngle);

      final planetPaint = Paint()
        ..color = planet.color
        ..style = PaintingStyle.fill;

      final planetShadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

      canvas.drawCircle(
        Offset(planetX, planetY),
        planetRadius,
        planetShadowPaint,
      );

      canvas.drawCircle(
        Offset(planetX, planetY),
        planetRadius,
        planetPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class PlanetFormScreen extends StatefulWidget {
  const PlanetFormScreen({super.key});

  @override
  _PlanetFormScreenState createState() => _PlanetFormScreenState();
}

class _PlanetFormScreenState extends State<PlanetFormScreen> {
  Color selectedColor = Colors.blue;
  double rotationSpeed = 1.0;
  double selfRotationSpeed = 1.0;
  double radius = 1.0;
  double distance = 1.0;
  final double maxDistanceFromSun = 150.0;

  final List<Color> planetColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.amber,
    Colors.cyan,
    Colors.brown,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить планету'),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //  "Выберите цвет планеты"
                const Text('Выберите цвет планеты:',
                    style: TextStyle(fontSize: 16)),
                DropdownButton<Color>(
                  value: selectedColor,
                  items: planetColors.map((color) {
                    return DropdownMenuItem<Color>(
                      value: color,
                      child: Container(
                        width: 30.0,
                        height: 30.0,
                        color: color,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedColor = value!;
                    });
                  },
                ),
                Slider(
                  value: radius,
                  min: 1.0,
                  max: 50.0,
                  onChanged: (value) {
                    setState(() {
                      radius = value;
                    });
                  },
                  label: 'Радиус планеты: ${radius.toStringAsFixed(2)}',
                ),
                Text('Радиус планеты: ${radius.toStringAsFixed(2)}'),
                Slider(
                  value: distance,
                  min: 1.0,
                  max: maxDistanceFromSun,
                  onChanged: (value) {
                    setState(() {
                      distance = value;
                    });
                  },
                  label:
                      'Удаленность от Солнца: ${distance.toStringAsFixed(2)}',
                ),
                Text('Удаленность от Солнца: ${distance.toStringAsFixed(2)}'),
                Slider(
                  value: rotationSpeed,
                  min: 0.1,
                  max: 10.0,
                  onChanged: (value) {
                    setState(() {
                      rotationSpeed = value;
                    });
                  },
                  label:
                      'Скорость вращения вокруг солнца: ${rotationSpeed.toStringAsFixed(2)}',
                ),
                Text(
                    'Скорость вращения вокруг солнца: ${rotationSpeed.toStringAsFixed(2)}'),
                Slider(
                  value: selfRotationSpeed,
                  min: 0.1,
                  max: 10.0,
                  onChanged: (value) {
                    setState(() {
                      selfRotationSpeed = value;
                    });
                  },
                  label:
                      'Скорость собственного вращения: ${selfRotationSpeed.toStringAsFixed(2)}',
                ),
                Text(
                    'Скорость собственного вращения: ${selfRotationSpeed.toStringAsFixed(2)}'),
                ElevatedButton(
                  onPressed: () {
                    Planet planet = Planet(
                      "",
                      radius,
                      selectedColor,
                      distance,
                      rotationSpeed,
                      selfRotationSpeed,
                      maxDistanceFromSun,
                    );

                    Navigator.pop(context, planet);
                  },
                  child: const Text('Добавить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
