import 'package:flutter/material.dart'; // Importa el catálogo de diseño visual de Flutter.

// Crea una pantalla estática (StatelessWidget), su diseño no cambiará por sí solo.
class PantallaLogin extends StatelessWidget {
  const PantallaLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( // El lienzo en blanco base de la pantalla.
      body: SafeArea( // Escudo invisible que evita que el diseño choque con la cámara frontal o los bordes.
        child: Padding(
          // Da un margen de 24 píxeles por los 4 lados para que los botones no toquen las orillas.
          padding: const EdgeInsets.all(24.0), 
          child: Column( // Apilador vertical de elementos.
            mainAxisAlignment: MainAxisAlignment.center, // Centra todos los botones a la mitad de la pantalla.
            crossAxisAlignment: CrossAxisAlignment.stretch, // Obliga a los botones a estirarse a lo ancho.
            children: [
              // Texto principal, centrado, tamaño 28, en negritas (bold) y color naranja.
              const Text('¡Bienvenido a Mayitas!', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange)),
              const SizedBox(height: 40), // Espaciador invisible grande.
              
              // Caja donde el usuario escribirá. InputDecoration le pone el borde redondeado de 12px.
              TextField(decoration: InputDecoration(labelText: 'Correo electrónico', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 16), // Espaciador invisible pequeño.
              
              // Caja de texto. El 'obscureText: true' es el truco para cambiar letras por puntitos de contraseña.
              TextField(obscureText: true, decoration: InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 24), // Espaciador invisible mediano.
              
              // Botón principal con relleno sólido y sombra.
              ElevatedButton(
                onPressed: () {}, // Aquí programaremos la función de Firebase para entrar.
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), // Le da relleno interno y bordes redondos.
                child: const Text('Iniciar Sesión', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 16), // Espaciador invisible pequeño.
              
              // Botón secundario que solo tiene contorno, ideal para iniciar con Google.
              OutlinedButton.icon(
                onPressed: () {}, // Aquí conectaremos Google Sign-In.
                icon: const Icon(Icons.g_mobiledata, size: 32), // Ícono precargado de Google.
                label: const Text('Entrar con Google'), // Texto al lado del ícono.
              )
            ],
          ),
        ),
      ),
    );
  }
}