// ============================================================
// IMPORTS: traen código de otros archivos/paquetes
// ============================================================
import 'package:flutter/material.dart'; // Widgets de Material Design (Scaffold, Text, Button...)
import 'package:firebase_auth/firebase_auth.dart'; // Autenticación de Firebase (login con correo)
import '../services/auth_SigIng_Google.dart'; // Tu servicio de Google (revisa que el nombre del archivo sea EXACTAMENTE este)
import 'pantalla_principal.dart'; // Pantalla a la que se va tras iniciar sesión
import 'pantalla_editar_perfil.dart'; 
import '../Screen_temporal/pantalla_carga.dart';// Pantalla para completar nombre/edad tras registrarse

// ============================================================
// WIDGET PRINCIPAL (StatefulWidget = pantalla que cambia con el tiempo)
// ============================================================
class PantallaBienvenida extends StatefulWidget {
  const PantallaBienvenida({super.key}); // Constructor constante; "key" ayuda a Flutter a identificar el widget

  @override
  State<PantallaBienvenida> createState() => _PantallaBienvenidaState(); // Crea el objeto que guarda el estado
}

// Clase de estado: aquí viven las variables y la lógica (el "_" la hace privada)
class _PantallaBienvenidaState extends State<PantallaBienvenida> {
  bool _aceptoTerminos = false; // ¿Marcó el checkbox de términos?
  bool _cargando = false; // ¿Hay una operación en curso? (muestra el spinner)

  // CORRECCIÓN: los controllers ahora son campos de la clase para poder liberarlos en dispose()
  final TextEditingController _emailController = TextEditingController(); // Lee lo escrito en el campo de correo
  final TextEditingController _passwordController = TextEditingController(); // Lee lo escrito en el campo de contraseña
  

  @override
  void dispose() {
    _emailController.dispose(); // Libera memoria del controller del correo
    _passwordController.dispose(); // Libera memoria del controller de la contraseña
    super.dispose(); // Siempre se llama al dispose del padre
  }

  // Muestra un SnackBar (mensaje inferior). "color" es opcional y por defecto rojo
  void _mostrarMensaje(String texto, {Color color = Colors.red}) {
    if (!mounted) return; // Si la pantalla ya no existe, no hacemos nada (evita errores)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: color), // El mensaje y su color
    );
  }


  // Construye un botón circular reutilizable
Widget _botonCircular({required IconData icono, required Color colorIcono, required VoidCallback? onTap,required Color colortexto, required String texto}) {
  return InkWell(
    onTap: onTap, // Acción al tocar (null = deshabilitado)
    customBorder: const StadiumBorder(), // Efecto de toque circular
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.rectangle,borderRadius: BorderRadius.all(Radius.circular(50))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
      Icon(icono, color: colorIcono),
      Text (texto,style: TextStyle(fontSize:10,color: colortexto)),
      ],
    ) ,
    ),
  );
}

  // ------------------------------------------------------------
  // LOGIN CON GOOGLE
  // ------------------------------------------------------------
Future<void> _entrarConGoogle() async {
  setState(() => _cargando = true);
  try {
    await AuthService.entrarConGoogle(); // Autentica
    if (!mounted) return;
    // Reutilizamos la misma pantalla de carga para que decida a dónde ir
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PantallaCarga()),
      (route) => false,
    );
  } catch (e) {
    _mostrarMensaje('Error: $e');
  } finally {
    if (mounted) setState(() => _cargando = false);
  }
}
  // ------------------------------------------------------------
  // VENTANA INFERIOR PARA CORREO Y CONTRASEÑA
  // ------------------------------------------------------------
  void _mostrarVentanaCorreo() {
    if (!_aceptoTerminos) {
      _mostrarMensaje('Debes aceptar los Términos y Condiciones'); // Exige términos antes de abrir
      return;
    }

    final formKey = GlobalKey<FormState>(); // Llave para validar el formulario completo
    bool ocultarPassword = true; // true = contraseña oculta (puntitos)

    showModalBottomSheet(
      context: context, // Contexto de la pantalla
      isScrollControlled: true, // Permite que la ventana suba con el teclado
      backgroundColor: Colors.grey[900], // Fondo gris muy oscuro
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)), // Esquinas superiores redondeadas
      ),
      builder: (context) {
        // StatefulBuilder permite redibujar SOLO esta ventana (para el "ojito")
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, // Deja espacio para el teclado
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Form(
                key: formKey, // Conecta el formulario con la llave
                child: Column(
                  mainAxisSize: MainAxisSize.min, // La columna ocupa solo lo necesario
                  children: [
                    // Barrita gris decorativa de arriba
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 24), // Espacio vertical
                    const Text(
                      'Ingresa tu correo y contraseña',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    // ---------- CAMPO DE CORREO ----------
                    TextFormField(
                      controller: _emailController, // Guarda lo que escribe el usuario
                      keyboardType: TextInputType.emailAddress, // Teclado con "@"
                      style: const TextStyle(color: Colors.white), // Color del texto escrito
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico', // Etiqueta flotante
                        labelStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[800]!), // Borde normal
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green), // Borde al escribir
                        ),
                      ),
                      validator: (value) {
                        // CORRECCIÓN: antes solo aceptaba @gmail.com; ahora acepta cualquier correo válido
                        final texto = value?.trim() ?? '';
                        final esValido = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(texto);
                        if (!esValido) return 'Debes usar un correo electrónico válido';
                        return null; // null = sin error
                      },
                    ),
                    const SizedBox(height: 16),

                    // ---------- CAMPO DE CONTRASEÑA ----------
                    TextFormField(
                      controller: _passwordController,
                      obscureText: ocultarPassword, // Oculta o muestra el texto
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[800]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green),
                        ),
                        suffixIcon: IconButton(
                          // Cambia el icono según si está oculta o visible
                          icon: Icon(
                            ocultarPassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white,
                          ),
                          // Invierte el valor y redibuja solo el modal
                          onPressed: () => setModalState(() => ocultarPassword = !ocultarPassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 8) {
                          return 'La contraseña debe tener al menos 8 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // ---------- BOTÓN "SIGUIENTE" CON DEGRADADO ----------
                    Container(
                      width: double.infinity, // Ocupa todo el ancho
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0a7600), Color(0xFF75dd00)], // Azul a rojo
                        ),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, // Transparente para que se vea el degradado
                          shadowColor: Colors.transparent, // Sin sombra
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          // Si todos los validator devuelven null, el formulario es válido
                          if (formKey.currentState!.validate()) {
                            _procesarAutenticacion(
                              _emailController.text.trim(), // trim() quita espacios sobrantes
                              _passwordController.text,
                            );
                          }
                        },
                        child: const Text(
                          'Siguiente',
                          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        );
      },
    ); // CORRECCIÓN: faltaba cerrar showModalBottomSheet con ");"
  } // CORRECCIÓN: faltaba cerrar el método _mostrarVentanaCorreo con "}"

  // ------------------------------------------------------------
  // LÓGICA DE LOGIN / REGISTRO CON CORREO
  // (CORRECCIÓN: antes estaba metida DENTRO de otro método; ahora es un método de la clase)
  // ------------------------------------------------------------
  Future<void> _procesarAutenticacion(String email, String password) async {
    Navigator.pop(context); // Cierra la ventana inferior
    setState(() => _cargando = true); // Muestra el spinner

    try {
      // 1) Intenta iniciar sesión con una cuenta existente
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PantallaPrincipal()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      // 2) Si falló porque no existe la cuenta (o credenciales inválidas), intenta crearla
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
          if (!mounted) return;
          // Cuenta nueva: manda a completar perfil, pasando el correo
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => PantallaEditarPerfil(correo: email)),
          );
        } on FirebaseAuthException catch (e2) {
          if (e2.code == 'email-already-in-use') {
            // La cuenta ya existía, así que el fallo del paso 1 era la contraseña
            _mostrarMensaje('La contraseña es incorrecta.');
          } else {
            _mostrarMensaje('Error al crear cuenta: ${e2.message}');
          }
        }
      } else {
        _mostrarMensaje('Error al iniciar sesión: ${e.message}'); // Otro tipo de error
      }
    } finally {
      if (mounted) setState(() => _cargando = false); // Apaga el spinner siempre
    }
  }

  // ------------------------------------------------------------
  // INTERFAZ (CORRECCIÓN: build ahora es un método de la clase, no estaba anidado)
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Estructura base de la pantalla
      body: Stack(
        // Stack apila widgets uno encima de otro
        children: [
          // CAPA 1: imagen de fondo
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Fondos/fondot.png'), // Debe existir y estar declarada en pubspec.yaml
                fit: BoxFit.cover, // Cubre toda la pantalla
              ),
            ),
          ),

          // CAPA 2: filtro oscuro para que el texto se lea mejor
          // CORRECCIÓN: withOpacity está obsoleto; se usa withValues(alpha: ...)
          Container(color: Colors.black.withValues(alpha: 0.4)),

          // CAPA 3: contenido, dentro de SafeArea para evitar notch y barras del sistema
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0), // Margen de 24 en todos los lados
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Spacer(), // Empuja el título hacia el centro
                  const Text(
                    "Mayitas",
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const Spacer(), // Empuja los botones hacia abajo

                  // Botón de Google
                  ElevatedButton.icon(
                    onPressed: _cargando ? null : _entrarConGoogle, // null = botón deshabilitado mientras carga
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 56), // Ancho completo, alto 56
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.g_mobiledata, size: 36, color: Colors.black),
                    label: const Text(
                      'Continuar con Google',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botón circular del correo
                 // Fila con los dos botones circulares, centrados y con espacio entre ellos
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    _botonCircular(
      icono: Icons.email,
      colorIcono: Colors.black,
      texto:'Empezar',
      colortexto: Colors.black,
      onTap: _cargando ? null : _mostrarVentanaCorreo,
    ),
  ],
),
const SizedBox(height: 32),
                  // Checkbox de términos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _aceptoTerminos, // Estado actual
                        onChanged: (val) => setState(() => _aceptoTerminos = val ?? false), // Actualiza al tocar
                        side: const BorderSide(color: Colors.grey),
                        activeColor: Colors.blue,
                      ),
                      const Expanded(
                        // Expanded evita que el texto se salga de la pantalla
                        child: Text(
                          'Acepto compartir los datos de mi hijo(a)\nAl continuar, acepto la Política de Privacidad',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // CAPA 4: spinner de carga (solo aparece si _cargando es true)
          if (_cargando) const Center(child: CircularProgressIndicator(color: Colors.orange)),
        ],
      ),
    );
  }
}