import 'package:flutter/material.dart'; // Importa el catálogo visual de Flutter.
import 'package:firebase_core/firebase_core.dart'; // Importa el núcleo de Firebase.
import 'Services/firebase_options.dart'; // Importa las llaves de tu base de datos generadas previamente.
import 'Screen_temporal/pantalla_carga.dart'; 
import 'package:google_sign_in/google_sign_in.dart';// ¡NUEVO! Importamos el archivo de la pantalla de carga.

void main() async {
  // Asegura que los motores de Flutter estén listos antes de ejecutar comandos externos.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Conecta la aplicación a tu proyecto de Firebase en la nube usando tus llaves.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await GoogleSignIn.instance.initialize(
    serverClientId: '70493263559-seg7t67pare8iv80vm0k9c90gu27ke6b.apps.googleusercontent.com', // Reemplaza con tu Client ID de Google
  ); 

 
  
  // Arranca la aplicación completa.
  runApp(const MayitasApp());
}

class MayitasApp extends StatelessWidget {
  const MayitasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mayitas',
      debugShowCheckedModeBanner: false, // Oculta la etiqueta roja de "DEBUG" en la esquina.
      theme: ThemeData(
        brightness: Brightness.dark, // Evita el destello blanco inicial
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black, // Fondo negro global para toda la app
        fontFamily: 'ComicNeue', // Tu fuente personalizada
),
      // EL CAMBIO ESTÁ AQUÍ:
      // En lugar del Scaffold con el texto, ahora arrancamos mostrando la Pantalla de Carga.
      
      home: const PantallaCarga(), 
    );
  }
} 