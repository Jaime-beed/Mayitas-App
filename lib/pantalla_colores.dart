import 'package:flutter/material.dart';

class PantallaColores extends StatelessWidget {
  const PantallaColores({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Colores en Maya', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Cuadrícula de 2 columnas para botones grandes
        child: GridView.count(
          crossAxisCount: 2, 
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: const [
            BotonColor(colorFondo: Colors.red, maya: 'Chak', espanol: 'Rojo'),
            BotonColor(colorFondo: Colors.blue, maya: "Ch'ooj", espanol: 'Azul'),
            BotonColor(colorFondo: Colors.yellow, maya: "K'an", espanol: 'Amarillo', textoOscuro: true),
            BotonColor(colorFondo: Colors.green, maya: "Ya'ax", espanol: 'Verde'),
          ],
        ),
      ),
    );
  }
}

// Este es nuestro molde para construir botones rápidamente
class BotonColor extends StatelessWidget {
  final Color colorFondo;
  final String maya;
  final String espanol;
  final bool textoOscuro; 

  const BotonColor({
    super.key,
    required this.colorFondo,
    required this.maya,
    required this.espanol,
    this.textoOscuro = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorTexto = textoOscuro ? Colors.black87 : Colors.white;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorFondo,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), // Bordes redondos infantiles
        elevation: 4,
      ),
      onPressed: () {
        // Más adelante aquí conectaremos Firebase
        print("El niño presionó el color $maya");
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            maya,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colorTexto),
          ),
          const SizedBox(height: 8),
          Text(
            espanol,
            style: TextStyle(fontSize: 18, color: colorTexto.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}