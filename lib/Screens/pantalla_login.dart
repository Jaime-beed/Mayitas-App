import 'package:flutter/material.dart';
import 'package:mayitasapp/Screens/pantalla_anonimo.dart';
import 'pantalla_registro.dart'; // Importamos la pantalla de registro para la navegación
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/auth_SigIng_Google.dart';
import 'pantalla_principal.dart'; // Importamos la pantalla principal para la navegación después del login

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  
  final _formKey = GlobalKey<FormState>(); 
  bool _ocultarPassword = true;
  bool _cargando = false; // Variable para controlar el estado de carga
  final _emailController = TextEditingController();
  final _passwordController= TextEditingController();
   @override
   void dispose() {
     _emailController.dispose();
     _passwordController.dispose();
     super.dispose();
   }
   void _mostrarMensaje(String texto, {Color color = Colors.red}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: color),
    );
  }
   

   Future<void> _entrarConGoogle() async {
  try {
    await AuthService.entrarConGoogle();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PantallaPrincipal()),
      (route) => false,
    );
  } on GoogleSignInException catch (e) {
    if (e.code == GoogleSignInExceptionCode.canceled) return;
    _mostrarMensaje('Error al iniciar sesión con Google: ${e.description}');
  } catch (e) {
    _mostrarMensaje('Error: $e');
  }
}

Future<void> _restablecerPassword() async {
  final correo = _emailController.text.trim();

  if (correo.isEmpty || !correo.contains('@')) {
    _mostrarMensaje('Escribe tu correo en el campo de arriba para enviarte el enlace.');
    return;
  }

  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: correo);
    _mostrarMensaje(
      'Si el correo está registrado, recibirás un enlace para restablecer tu contraseña (verifica la carpeta de Spam).',
      color: Colors.green,
    );
  } on FirebaseAuthException catch (e) {
    final mensaje = e.code == 'network-request-failed'
        ? 'Sin conexión. Revisa tu internet.'
        : 'No se pudo enviar el correo: ${e.message}';
    _mostrarMensaje(mensaje);
  }
}

    Future<void>_inciarSesion() async {
     if (!_formKey.currentState!.validate()) return;
     setState(() {
       _cargando = true; // Inicia el estado de carga
     });
      try{
        await FirebaseAuth.instance.signInWithEmailAndPassword(email:_emailController.text.trim(),
        password:_passwordController.text.trim());

        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute (builder:(_) => const PantallaPrincipal()),
        (route) =>false,
        );

      }on FirebaseAuthException catch (e) {
       String mensaje;
       switch (e.code) {
            case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        mensaje = 'Correo o contraseña incorrectos.';
        break;
      case 'too-many-requests':
        mensaje = 'Demasiados intentos. Espera un momento.';
        break;
      case 'network-request-failed':
        mensaje = 'Sin conexión. Revisa tu internet.';
        break;
      default:
        mensaje = 'Error al iniciar sesión: ${e.message}';
    } if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
        );
       }catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );

      }finally { if (mounted) setState(() => _cargando =false);
      
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
                          controller: _emailController,
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
                          controller: _passwordController,
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

                        Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                        onPressed: _cargando ? null : _restablecerPassword,
                        child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(color: Colors.orange),
                        ),
                        ),
                        ),
                        
                        // Botón de Iniciar Sesión
                        ElevatedButton(
                          onPressed: _cargando ? null : _inciarSesion , 
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16), 
                            backgroundColor: Colors.orange, 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ), 
                          child: _cargando
                              ? const SizedBox(
                                 height: 22,
                                 width: 22,
                                 child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                          
                           :const Text('Iniciar Sesión', style: TextStyle(fontSize: 18, color: Colors.black)),
                        ),
                        const SizedBox(height: 16), 
                        
                        // Botón para ir al Registro
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const Pantallaregistro()),
                            (route) => false,
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
                          onPressed: () {
                           Navigator.of(context).pushAndRemoveUntil(
                           MaterialPageRoute(builder: (_) => const PantallaAnonimo()),
                           (route) => false,
                           );
                          }, 
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