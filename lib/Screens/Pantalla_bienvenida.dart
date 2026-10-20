import 'package:flutter/material.dart'; // Widgets de Material Design (Scaffold, Text, Button...)
import 'package:firebase_auth/firebase_auth.dart'; // Autenticación de Firebase (login con correo)
import '../services/auth_SigIng_Google.dart'; // Tu servicio de Google (revisa que el nombre del archivo sea EXACTAMENTE este)
import 'pantalla_principal.dart'; // Pantalla a la que se va tras iniciar sesión
import 'pantalla_editar_perfil.dart';
import '../Screen_temporal/pantalla_carga.dart'; // Pantalla de carga que decide a dónde ir

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

  // Los controllers son campos de la clase para poder liberarlos en dispose()
  final TextEditingController _emailController = TextEditingController(); // Lee lo escrito en el campo de correo
  final TextEditingController _passwordController = TextEditingController(); // Lee lo escrito en el campo de contraseña

  // Expresión regular para validar correos (se usa en el validator y en restablecer contraseña)
  static final RegExp _regexCorreo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

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

  // ------------------------------------------------------------
  // TRADUCTOR DE ERRORES: convierte cualquier error en un mensaje claro en español
  // Sirve tanto para Google como para correo/contraseña
  // ------------------------------------------------------------
  String _mensajeError(Object e) {
    if (e is FirebaseAuthException) {
      // Ayuda para depurar: muestra en consola el código real que llega
      debugPrint('FirebaseAuth code: ${e.code} | message: ${e.message}');

      // Política de contraseñas: se detecta por el texto del mensaje, no solo por el código
      if (_esErrorDeRequisitos(e)) {
        return _requisitosFaltantes(e.message);
      }

      switch (e.code) {
        case 'invalid-email':
          return 'El correo no tiene un formato válido.';
        case 'user-disabled':
          return 'Esta cuenta ha sido deshabilitada.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Correo o contraseña incorrectos.';
        case 'email-already-in-use':
          return 'Ese correo ya está registrado. Revisa tu contraseña.';
        case 'operation-not-allowed':
          return 'Este método de acceso no está habilitado.';
        case 'too-many-requests':
          return 'Demasiados intentos. Espera unos minutos e inténtalo de nuevo.';
        case 'network-request-failed':
          return 'Sin conexión a internet.';
        case 'account-exists-with-different-credential':
          return 'Ya existe una cuenta con ese correo usando otro método de acceso.';
        default:
          return e.message ?? 'Ocurrió un error (${e.code}).';
      }
    }

    // Errores que no son de Firebase (por ejemplo, del plugin de Google)
    final t = e.toString().toLowerCase();
    if (t.contains('cancel')) return 'Inicio de sesión cancelado.';
    if (t.contains('network')) return 'Sin conexión a internet.';
    if (t.contains('apiexception: 10') || t.contains('developer_error')) {
      return 'Google Sign-In mal configurado (falta el SHA-1 en Firebase).';
    }
    return 'Ocurrió un error inesperado. Inténtalo de nuevo.';
  }

  // ¿El error es porque la contraseña no cumple la política de seguridad?
  bool _esErrorDeRequisitos(FirebaseAuthException e) {
    final texto = (e.message ?? '').toLowerCase();
    return e.code == 'password-does-not-meet-requirements' ||
        e.code == 'weak-password' ||
        texto.contains('password must') ||
        texto.contains('password does not meet');
  }

  // Traduce los requisitos de contraseña que manda Firebase (en inglés) a español
  String _requisitosFaltantes(String? mensaje) {
    final m = (mensaje ?? '').toLowerCase();
    final faltan = <String>[];

    if (m.contains('upper case')) faltan.add('una mayúscula');
    if (m.contains('lower case')) faltan.add('una minúscula');
    if (m.contains('numeric')) faltan.add('un número');
    if (m.contains('non-alphanumeric')) faltan.add('un símbolo (por ejemplo !@#)');
    if (m.contains('at least')) faltan.add('más caracteres (mínimo exigido)');
    if (m.contains('at most')) faltan.add('menos caracteres (máximo excedido)');

    if (faltan.isEmpty) {
      return 'La contraseña no cumple con los requisitos de seguridad (usa al menos 8 caracteres y una mayúscula).';
    }
    return 'La contraseña necesita: ${faltan.join(', ')}.';
  }

  // Construye un botón reutilizable (icono + texto)
  Widget _botonCircular({
    required IconData icono,
    required Color colorIcono,
    required VoidCallback? onTap,
    required Color colortexto,
    required String texto,
  }) {
    return InkWell(
      onTap: onTap, // Acción al tocar (null = deshabilitado)
      customBorder: const StadiumBorder(), // Efecto de toque redondeado
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, color: colorIcono),
            Text(texto, style: TextStyle(fontSize: 12, color: colortexto)),
          ],
        ),
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
      // NOTA: si tu servicio devuelve null cuando el usuario cancela (en vez de lanzar
      // excepción), guarda el resultado en una variable y valida:
      //   final user = await AuthService.entrarConGoogle();
      //   if (user == null) { _mostrarMensaje('Inicio de sesión cancelado.', color: Colors.grey); return; }
      if (!mounted) return;
      // Reutilizamos la misma pantalla de carga para que decida a dónde ir
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PantallaCarga()),
        (route) => false,
      );
    } catch (e) {
      final msg = _mensajeError(e);
      // Si solo canceló, no es un "error": mensaje neutro en gris
      final cancelo = msg == 'Inicio de sesión cancelado.';
      _mostrarMensaje(msg, color: cancelo ? Colors.grey : Colors.red);
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
    String? mensajeModal; // Mensaje que se muestra DENTRO de la ventana (un SnackBar quedaría tapado)
    Color colorMensajeModal = Colors.red; // Rojo = error, verde = éxito

    showModalBottomSheet(
      context: context, // Contexto de la pantalla
      isScrollControlled: true, // Permite que la ventana suba con el teclado
      backgroundColor: Colors.grey[900], // Fondo gris muy oscuro
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)), // Esquinas superiores redondeadas
      ),
      builder: (context) {
        // StatefulBuilder permite redibujar SOLO esta ventana (para el "ojito" y los mensajes)
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // Envía el correo para restablecer la contraseña
            Future<void> restablecer() async {
              final email = _emailController.text.trim();
              if (!_regexCorreo.hasMatch(email)) {
                setModalState(() {
                  mensajeModal = 'Escribe tu correo arriba para restablecer la contraseña.';
                  colorMensajeModal = Colors.red;
                });
                return;
              }
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                setModalState(() {
                  mensajeModal =
                      'Si el correo está registrado, te enviamos un enlace para restablecer tu contraseña. Revisa también spam.';
                  colorMensajeModal = Colors.green;
                });
              } catch (e) {
                setModalState(() {
                  mensajeModal = _mensajeError(e);
                  colorMensajeModal = Colors.red;
                });
              }
            }

            return SingleChildScrollView(
              child: Padding(
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
                        'Crea una cuenta o inicia sesión',
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
                          // Acepta cualquier correo válido (no solo @gmail.com)
                          final texto = value?.trim() ?? '';
                          if (!_regexCorreo.hasMatch(texto)) {
                            return 'Debes usar un correo electrónico válido';
                          }
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

                      // ---------- RESTABLECER CONTRASEÑA ----------
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: restablecer,
                          child: const Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(color: Colors.orange, fontSize: 13),
                          ),
                        ),
                      ),

                      // Mensaje de éxito/error del restablecimiento (solo aparece si hay uno)
                      if (mensajeModal != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            mensajeModal!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colorMensajeModal, fontSize: 13),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // ---------- BOTÓN "SIGUIENTE" CON DEGRADADO ----------
                      Container(
                        width: double.infinity, // Ocupa todo el ancho
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0a7600), Color(0xFF75dd00)], // Verde oscuro a verde claro
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
              ),
            );
          },
        );
      },
    );
  }

  // ------------------------------------------------------------
  // LÓGICA DE LOGIN / REGISTRO CON CORREO
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
            _mostrarMensaje('La contraseña es incorrecta. Puedes restablecerla con "¿Olvidaste tu contraseña?".');
          } else if (_esErrorDeRequisitos(e2)) {
            // Firebase valida los requisitos ANTES de saber si el correo existe,
            // así que no podemos distinguir cuenta nueva de cuenta existente: damos ambos mensajes
            final req = _requisitosFaltantes(e2.message);
            _mostrarMensaje('Si ya tienes cuenta, la contraseña es incorrecta. Si eres nuevo: $req');
          } else {
            _mostrarMensaje(_mensajeError(e2));
          }
        } catch (e2) {
          _mostrarMensaje(_mensajeError(e2));
        }
      } else {
        _mostrarMensaje(_mensajeError(e)); // Otro tipo de error de Firebase
      }
    } catch (e) {
      _mostrarMensaje(_mensajeError(e)); // Errores que no son de Firebase
    } finally {
      if (mounted) setState(() => _cargando = false); // Apaga el spinner siempre
    }
  }

  // ------------------------------------------------------------
  // INTERFAZ
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
                image: AssetImage('assets/Fondos/fondo_principal.jpg'), // Debe existir y estar declarada en pubspec.yaml
                fit: BoxFit.cover, // Cubre toda la pantalla
              ),
            ),
          ),

          // CAPA 2: filtro oscuro para que el texto se lea mejor
          Container(color: Colors.black.withValues(alpha: 0.4)),

          // CAPA 3: contenido, dentro de SafeArea para evitar notch y barras del sistema
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0), // Margen de 24 en todos los lados
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Spacer(), // Empuja el logo hacia el centro

                  // Logo desde Firebase Storage (con respaldo local si falla)
                  Image.network(
                    "https://firebasestorage.googleapis.com/v0/b/mayitas-9bde2.firebasestorage.app/o/Logos%2FLogo_letras.png?alt=media&token=6fe7bf41-21ac-47db-9d9b-20498305ada5",
                    height: 380,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const SizedBox(
                        height: 380,
                        child: Center(child: CircularProgressIndicator(color: Colors.orange)),
                      );
                    },
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/Logos/logo_principal.png',
                      height: 280,
                      fit: BoxFit.contain,
                    ),
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
                      "Unete usando Google",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botón del correo, centrado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _botonCircular(
                        icono: Icons.email,
                        colorIcono: Colors.black,
                        texto: " Unete a mayitas",
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