
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mayitasapp/Screens/pantalla_login.dart';
import '../services/auth_SigIng_Google.dart';
import 'pantalla_principal.dart'; // Importamos la pantalla principal para la navegación después del login
import "pantalla_edad.dart";
import 'pantalla_anonimo.dart'; // Importamos la pantalla principal para la navegación después del login

class Pantallaregistro extends StatefulWidget {
  const Pantallaregistro({super.key});

  @override
  State<Pantallaregistro> createState() => _PantallaregistroState();
}

class _PantallaregistroState extends State<Pantallaregistro> {
  final _formKey = GlobalKey<FormState>();
  bool _ocultarPassword = true;
  bool _ocultarPasswordConfirmar = true;
  bool _cargando = false;

  final _emailController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _edadController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarPasswordController = TextEditingController();

  // ---------------------------------------------------------------------------
  // LÓGICA
  // ---------------------------------------------------------------------------

  void _mostrarMensaje(String texto, {Color color = Colors.red}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: color),
    );
  }

  Future<void> _registrarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);
    UserCredential? credenciales;

    try {
      // 1. Crear usuario en Firebase Auth (esto inicia sesión automáticamente)
      credenciales = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text, // sin trim, igual que el validador
      );

      final String idUsuario = credenciales.user!.uid;

      // 2. Guardar los datos en Realtime Database
      final DatabaseReference ref =
          FirebaseDatabase.instance.ref("usuarios/$idUsuario");

      await ref.set({
        'correo': _emailController.text.trim(),
        'nombre': _nombreController.text.trim(),
        'apellido': _apellidoController.text.trim(),
        'edad': int.parse(_edadController.text.trim()),

        // DATOS SILENCIOSOS
        'nivel': 0,
        'experiencia': 0,
        'monedas': 0,
        'skins': "",
        'fecha_creacion': DateTime.now().toIso8601String(),
      });
      _mostrarMensaje('Cuenta creada Correctamente.',
          color: Colors.green);

      if (!mounted) return;
     Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const PantallaPrincipal()),
                  (route) => false,
                  );
    } on FirebaseAuthException catch (e) {
      _mostrarMensaje('Error al registrar: ${e.message}');
    } catch (e) {
      // Si falló la base de datos, borramos la cuenta de Auth
      // para no dejar un usuario sin datos.
      try {
        await credenciales?.user?.delete();
      } catch (_) {}
      await FirebaseAuth.instance.signOut();

      _mostrarMensaje('Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _entrarConGoogle() async {
  try {
    await AuthService.entrarConGoogle();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PantallaEdad()),
      (route) => false,
    );
  } on GoogleSignInException catch (e) {
    if (e.code == GoogleSignInExceptionCode.canceled) return;
    _mostrarMensaje('Error al iniciar sesión con Google: ${e.description}');
  } catch (e) {
    _mostrarMensaje('Error: $e');
  }
}

  @override
  void dispose() {
    _emailController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _edadController.dispose();
    _passwordController.dispose();
    _confirmarPasswordController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // DISEÑO
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "kʼáat u kʼáat chiʼil tʼáan",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange),
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    'Crea tu cuenta Mayitas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 40),

                  // Nombre
                  TextFormField(
                    keyboardType: TextInputType.text,
                    maxLength: 150,
                    controller: _nombreController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nombre(s)',
                      labelStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      counterText: "",
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa tu(s) nombre(s)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Apellido
                  TextFormField(
                    keyboardType: TextInputType.text,
                    maxLength: 150,
                    controller: _apellidoController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Apellido(s)',
                      labelStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      counterText: "",
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa tu(s) apellido(s)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Edad
                  TextFormField(
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    controller: _edadController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Edad',
                      labelStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      counterText: "",
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu edad';
                      }
                      final edad = int.tryParse(value);
                      if (edad == null || edad <= 0) {
                        return 'Ingresa una edad válida';
                      }

                      if(edad>8){
                        return 'El niño debe de tener de 4 a 8 años para registrarse';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Correo
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    maxLength: 150,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      labelStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      counterText: "",
                    ),
                    validator: (value) {
                      if (value == null ||
                          !value.trim().endsWith('@gmail.com')) {
                        return 'Debes usar un correo electrónico válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Contraseña
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _ocultarPassword,
                    maxLength: 20,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      counterText: "",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _ocultarPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() => _ocultarPassword = !_ocultarPassword);
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

                  // Confirmar contraseña
                  TextFormField(
                    obscureText: _ocultarPasswordConfirmar,
                    controller: _confirmarPasswordController,
                    maxLength: 20,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Confirmar Contraseña',
                      labelStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      counterText: "",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _ocultarPasswordConfirmar
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() => _ocultarPasswordConfirmar =
                              !_ocultarPasswordConfirmar);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 8) {
                        return 'La contraseña debe tener al menos 8 caracteres';
                      }
                      if (value != _passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Botón crear cuenta (solo llama a la lógica)
                  ElevatedButton(
                    onPressed: _cargando ? null : _registrarUsuario,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _cargando
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'Crea tu cuenta',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Ya tengo cuenta
                 ElevatedButton(
                  onPressed: _cargando
                  ? null
                  : () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const PantallaLogin()),
                  (route) => false,
                  ),
                   style: ElevatedButton.styleFrom(
                   padding: const EdgeInsets.all(16),
                   backgroundColor: Colors.orange,
                   shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                  'Ya tengo cuenta',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                 ),
                  ),
                  const SizedBox(height: 16),

                  // Google
                  OutlinedButton.icon(
                    onPressed: _cargando ? null : _entrarConGoogle,
                    icon: const Icon(Icons.g_mobiledata,
                        size: 32, color: Colors.white),
                    label: const Text('Registrar con Google',
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 16),

                  // Invitado (pendiente de programar)
                  OutlinedButton.icon(
                    onPressed: _cargando ? null : () {
                     Navigator.of(context).pushAndRemoveUntil(
                     MaterialPageRoute(builder: (_) => const PantallaAnonimo()),
                     (route) => false,
                     );
                    },
                    icon: const Icon(Icons.person,
                        size: 32, color: Colors.white),
                    label: const Text('Entrar como invitado',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}