import 'package:flutter/material.dart';
import 'pantalla_registro.dart'; // Importamos la pantalla de registro para la navegación
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/auth_SigIng_Google.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  
  final _formKey = GlobalKey<FormState>(); 
  bool _ocultarPassword = true;
   Future<void> _entrarConGoogle() async {
    try {
 await AuthService.entrarConGoogle();
    }on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión con Google: ${e.description}'), backgroundColor: Colors.red),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(('Error: $e')), backgroundColor: Colors.red),
      );
     }
     
    }
   
  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      backgroundColor: Colors.black, 
      resizeToAvoidBottomInset: false, // Evita los parpadeos blancos con el teclado
      body: SafeArea( 
        // Combinamos LayoutBuilder y ConstrainedBox para garantizar el centrado vertical con scroll
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0), 
                  child: Form(
                    key: _formKey,
                    child: Column( 
                      mainAxisAlignment: MainAxisAlignment.center, // Centra todo verticalmente
                      crossAxisAlignment: CrossAxisAlignment.stretch, 
                      children: [
                        const Text(
                          "Ma'lo'ob k'i'ik'el tumen Mayitas", 
                          textAlign: TextAlign.center, 
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange)
                        ),
                        const SizedBox(height: 1), 
                        
                        const Text(
                          'Bienvenido a Mayitas', 
                          textAlign: TextAlign.center, 
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)
                        ), 
                        const SizedBox(height: 40),
                        
                        // Campo de Correo Electrónico
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          maxLength:150,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(labelText: 'Correo electrónico',labelStyle:const TextStyle(color:Colors.white), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          counterText: ""),
                         validator: (value){
                         if(value==null || !value.endsWith('@gmail.com')) return 'Debes usar un correo electrónico válido';
                         return null;
                          },
              ),
               const SizedBox(height: 16), 
                        
                        // Campo de Contraseña con límite y ojito
                        TextFormField(
                          obscureText: _ocultarPassword, 
                          maxLength: 20,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Contraseña', 
                            labelStyle: const TextStyle(color: Colors.white), 
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            counterText: "", // Oculta el contador feo inferior
                            suffixIcon: IconButton(
                              icon: Icon(
                                _ocultarPassword ? Icons.visibility_off : Icons.visibility, 
                                color: Colors.white
                              ),
                              onPressed: () {
                                setState(() { 
                                  _ocultarPassword = !_ocultarPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.length < 8) {
                              return 'La contraseña debe tener al menos 8 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24), 
                        
                        // Botón de Iniciar Sesión
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Aquí programaremos la función de Firebase para entrar
                            }
                          }, 
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16), 
                            backgroundColor: Colors.orange, 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ), 
                          child: const Text('Iniciar Sesión', style: TextStyle(fontSize: 18, color: Colors.black)),
                        ),
                        const SizedBox(height: 16), 
                        
                        // Botón para ir al Registro
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => const Pantallaregistro())
                            );
                          }, 
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16), 
                            backgroundColor: Colors.orange, 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ), 
                          child: const Text('Registrarse', style: TextStyle(fontSize: 18, color: Colors.black)),
                        ),
                        const SizedBox(height: 16), 
                        
                        // Botón de Google
                        OutlinedButton.icon(
                          onPressed: () {
                            _entrarConGoogle();
                          }, 
                          icon: const Icon(Icons.g_mobiledata, size: 32, color: Colors.white), 
                          label: const Text('Entrar con Google', style: TextStyle(color: Colors.white)), 
                        ),
                        const SizedBox(height: 16), 

                        // Botón de Invitado
                        OutlinedButton.icon(
                          onPressed: () {}, 
                          icon: const Icon(Icons.person, size: 32, color: Colors.white), 
                          label: const Text('Entrar como invitado', style: TextStyle(color: Colors.white)), 
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}