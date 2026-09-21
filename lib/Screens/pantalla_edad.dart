//importaciones de librerias
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/auth_SigIng_Google.dart';
import 'pantalla_login.dart';

class PantallaEdad extends StatefulWidget {
  const PantallaEdad({super.key});

  @override
  State<PantallaEdad> createState() => _PantallaEdadState();
}

class _PantallaEdadState extends State<PantallaEdad> {
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Pantalla confrmacion datos'),
    
      actions: [
        IconButton(icon: const Icon(Icons.logout,color: Colors.white),
        tooltip: 'Cerrar sesión',
        onPressed:()async {
          await AuthService.cerrarSesion();
          Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const PantallaLogin()),
                  (route) => false,
                  );
        },
       ),
      ],
     ),
    );
  }
  
}