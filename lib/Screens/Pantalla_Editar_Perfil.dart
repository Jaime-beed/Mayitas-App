// ============================================================
// IMPORTS
// ============================================================
import 'package:flutter/material.dart'; // Widgets de Material Design
import 'package:flutter/services.dart'; // Para "FilteringTextInputFormatter" (solo dígitos en edad)
import 'package:firebase_auth/firebase_auth.dart'; // Para obtener el UID del usuario actual
import 'package:firebase_database/firebase_database.dart'; // Realtime Database
import 'pantalla_principal.dart'; // Pantalla a la que se va tras guardar el perfil
import 'package:firebase_storage/firebase_storage.dart';

// ============================================================
// WIDGET PRINCIPAL
// ============================================================
class PantallaEditarPerfil extends StatefulWidget {
  final String correo; // Correo que llega desde la pantalla anterior (registro con email)
  const PantallaEditarPerfil({super.key, required this.correo}); // "required" obliga a pasarlo siempre

  @override
  State<PantallaEditarPerfil> createState() => _PantallaEditarPerfilState();
}

class _PantallaEditarPerfilState extends State<PantallaEditarPerfil> {
  final _formKey = GlobalKey<FormState>(); // Llave para validar todo el formulario de golpe
  String _generoSeleccionado = 'Niño'; // Controla qué botón está activo y qué avatar se muestra
  bool _cargando = false; // Muestra el spinner dentro del botón mientras guarda

  // Controladores: leen lo que el usuario escribe en cada campo
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _edadController = TextEditingController();

  // Enlaces públicos de Firebase Storage para los avatares
 // Reemplaza _urlAvatarNino y _urlAvatarNina por esto:
final List<String> _avatares = [
  "https://firebasestorage.googleapis.com/v0/b/mayitas-9bde2.firebasestorage.app/o/Logos%2FMeekkoj.png?alt=media&token=10d8814d-54ae-45cc-aaef-f5fb79f06c0b",
   "https://firebasestorage.googleapis.com/v0/b/mayitas-9bde2.firebasestorage.app/o/Logos%2FKeej.png?alt=media&token=abc8dc3a-0009-454e-8419-a20ba9cf89c4",
   "https://firebasestorage.googleapis.com/v0/b/mayitas-9bde2.firebasestorage.app/o/Logos%2FBaats.png?alt=media&token=46afb59d-6748-4f9c-9e25-b4ad57dfefa9",
   "https://firebasestorage.googleapis.com/v0/b/mayitas-9bde2.firebasestorage.app/o/Logos%2FBalam.png?alt=media&token=02d927fe-72c7-41c6-9bd9-f9c454b7d025",
  // Agrega aquí más enlaces de Firebase Storage
];
int _avatarIndex = 0; // Avatar elegido (no depende del género)

  // CORRECCIÓN: se agregó dispose() para liberar los controllers y evitar fugas de memoria
  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _edadController.dispose();
    super.dispose();
  }

// ------------------------------------------------------------
// AVATAR PRINCIPAL CON MARCO Y LÁPIZ
// ------------------------------------------------------------
Widget _selectorAvatar() {
  return Column(
    children: [
      GestureDetector(
        onTap: _abrirSelectorAvatar, // Tocar la foto o el lápiz abre el selector
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Marco degradado con brillo
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.amber, Colors.deepOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.45),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF141416), // Separa el marco de la imagen
                ),
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: Colors.transparent,
                  backgroundImage: NetworkImage(_avatares[_avatarIndex]),
                  onBackgroundImageError: (e, _) => debugPrint('Error avatar: $e'),
                ),
              ),
            ),
            // Botón del lápiz
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF141416), width: 3),
                ),
                child: const Icon(Icons.edit, size: 18, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      const Text(
        'Toca el lápiz para cambiar tu foto',
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
    ],
  );
}

// ------------------------------------------------------------
// PANEL INFERIOR PARA ELEGIR AVATAR
// ------------------------------------------------------------
void _abrirSelectorAvatar() {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1C1C1E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Elige tu foto de perfil',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: List.generate(_avatares.length, (i) {
                final seleccionado = i == _avatarIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() => _avatarIndex = i);
                    Navigator.of(sheetContext).pop(); // Cierra el panel al elegir
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: seleccionado ? Colors.orange : Colors.grey[800]!,
                            width: seleccionado ? 4 : 2,
                          ),
                          boxShadow: seleccionado
                              ? [
                                  BoxShadow(
                                    color: Colors.orange.withValues(alpha: 0.5),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : [],
                        ),
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.transparent,
                          backgroundImage: NetworkImage(_avatares[i]),
                          onBackgroundImageError: (e, _) => debugPrint('Error avatar $i: $e'),
                        ),
                      ),
                      // Palomita en el avatar seleccionado
                      if (seleccionado)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, size: 14, color: Colors.black),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    ),
  );
}
  // ------------------------------------------------------------
  // GUARDAR PERFIL EN REALTIME DATABASE
  // ------------------------------------------------------------
  Future<void> _guardarPerfil() async {
    if (!_formKey.currentState!.validate()) return; // Si algún campo falla su validator, no continúa
    final edad = int.parse(_edadController.text.trim());

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('Confirma la edad', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Confirmas que el niño o niña tiene $edad años?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Corregir', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );

    if (confirmado != true) return;
    setState(() => _cargando = true); // Activa el spinner en el botón
    try {
      final String idUsuario = FirebaseAuth.instance.currentUser!.uid; // UID del usuario ya autenticado
      final String avatarFinal = _avatares[_avatarIndex]; // Elige avatar según selección

      // Referencia al nodo "usuarios/<uid>" dentro de Realtime Database
      final DatabaseReference ref = FirebaseDatabase.instance.ref("usuarios/$idUsuario");
      await ref.set({
        // set() reemplaza todo el contenido de ese nodo con este mapa
        'correo': widget.correo, // Correo recibido de la pantalla anterior
        'nombre': _nombreController.text.trim(), // trim() quita espacios sobrantes
        'apellido': _apellidoController.text.trim(),
        'edad': int.parse(_edadController.text.trim()), // Convierte el texto a número entero
        'genero': _generoSeleccionado,
        'avatar_url': avatarFinal,
        'nivel': 0, // Valores iniciales del juego/app
        'experiencia': 0,
        'monedas': 0,
        'skins': "",
        'fecha_creacion': DateTime.now().toIso8601String(), // Fecha actual en formato texto estándar
      });

      if (!mounted) return; // Verifica que la pantalla siga viva tras el await
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PantallaPrincipal()),
        (route) => false, // Borra el historial: no se puede volver atrás al formulario
      );
    } catch (e) {
      // CORRECCIÓN: se agregó "if (!mounted) return;" antes de usar context tras el await del try
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _cargando = false); // Apaga el spinner pase lo que pase
    }
  }

  // ------------------------------------------------------------
  // INTERFAZ
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141416), // Fondo oscuro de toda la pantalla
      body: SafeArea(
        // Evita que el contenido choque con notch/barras del sistema
        child: SingleChildScrollView(
          // Permite hacer scroll si el teclado tapa los campos
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey, // Conecta el formulario con la llave de validación
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Los hijos ocupan todo el ancho disponible
                children: [
                  const Text(
                    'crea tu perfil',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  const SizedBox(height: 32),

                  // ---------- AVATAR DINÁMICO ----------
                  _selectorAvatar(),
                  const SizedBox(height: 32),  

                  // ---------- SELECTOR NIÑO / NIÑA ----------
                  Row(
                    children: [
                      Expanded(
                        // Expanded reparte el ancho disponible entre los dos botones
                        child: GestureDetector(
                          onTap: () => setState(() => _generoSeleccionado = 'Niño'), // Cambia selección y redibuja
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              // Borde azul si está seleccionado, gris si no
                              border: Border.all(
                                color: _generoSeleccionado == 'Niño' ? Colors.blue : Colors.grey[800]!,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.face, color: _generoSeleccionado == 'Niño' ? Colors.blue : Colors.grey[600]),
                                const SizedBox(width: 8),
                                Text(
                                  'Niño',
                                  style: TextStyle(
                                    color: _generoSeleccionado == 'Niño' ? Colors.blue : Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16), // Separación entre los dos botones
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _generoSeleccionado = 'Niña'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _generoSeleccionado == 'Niña' ? Colors.pink : Colors.grey[800]!,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.face_3, color: _generoSeleccionado == 'Niña' ? Colors.pink : Colors.grey[600]),
                                const SizedBox(width: 8),
                                Text(
                                  'Niña',
                                  style: TextStyle(
                                    color: _generoSeleccionado == 'Niña' ? Colors.pink : Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ---------- CAMPO NOMBRE ----------
                  TextFormField(
                    controller: _nombreController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nombre(s)',
                      labelStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Por favor ingresa tu(s) nombre(s)';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ---------- CAMPO APELLIDO ----------
                  TextFormField(
                    controller: _apellidoController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Apellido(s)',
                      labelStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Por favor ingresa tu(s) apellido(s)';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ---------- CAMPO EDAD ----------
                  TextFormField(
                    controller: _edadController,
                    keyboardType: TextInputType.number, // Teclado numérico
                    maxLength: 2, // Máximo 2 dígitos
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Bloquea letras/símbolos
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Edad',
                      labelStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      counterText: "", // Oculta el contador "0/2" que Flutter muestra por defecto
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor ingresa tu edad';
                      final edad = int.tryParse(value); // Convierte sin lanzar error si no es número
                      if (edad == null || edad <= 0) return 'Ingresa una edad válida';
                      // CORRECCIÓN: el texto decía "de 4 a 8 años" pero solo se validaba el máximo;
                      // ahora también se valida el mínimo de 4 años
                      if (edad < 6 || edad > 10) return 'El niño debe tener de 6 a 10 años para registrarse';
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  // ---------- BOTÓN GUARDAR ----------
                  ElevatedButton(
                    onPressed: _cargando ? null : _guardarPerfil, // Deshabilitado mientras guarda
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _cargando
                        ? const CircularProgressIndicator(color: Colors.black) // Spinner mientras guarda
                        : const Text(
                            'Guardar y Entrar',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                  ), // Cierra ElevatedButton
                ], // Cierra children de Column
              ), // Cierra Column
            ), // Cierra Form
          ), // Cierra Padding
        ), // Cierra SingleChildScrollView
      ), // CORRECCIÓN: cierra SafeArea (antes decía "}" y le faltaba el paréntesis)
    ); // CORRECCIÓN: cierra Scaffold y el "return" con ";" (antes faltaba por completo)
  } // CORRECCIÓN: cierra el método build (antes faltaba esta llave)
} // CORRECCIÓN: cierra la clase _PantallaEditarPerfilState (antes faltaba esta llave)