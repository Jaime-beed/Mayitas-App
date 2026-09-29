//importaciones de librerias
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:Mayitas/Screens/Pantalla_bienvenida.dart';
import '../services/auth_SigIng_Google.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Pantalla Principal'),
    
      actions: [
        IconButton(icon: const Icon(Icons.logout,color: Colors.white),
        tooltip: 'Cerrar sesión',
        onPressed:()async {
          await AuthService.cerrarSesion();
          Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const PantallaBienvenida()),
                  (route) => false,
                  );
        },
       ),
      ],
     ),
    );
  }
  
}