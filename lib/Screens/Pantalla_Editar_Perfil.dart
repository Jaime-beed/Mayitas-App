// ============================================================
// IMPORTS
// ============================================================
import 'package:flutter/material.dart'; // Widgets de Material Design
import 'package:flutter/services.dart'; // Para "FilteringTextInputFormatter" (solo dígitos en edad)
import 'package:firebase_auth/firebase_auth.dart'; // Para obtener el UID del usuario actual
import 'package:firebase_database/firebase_database.dart'; // Realtime Database
import 'pantalla_principal.dart'; // Pantalla a la que se va tras guardar el perfil

// ============================================================
// WIDGET PRINCIPAL
// ============================================================
class PantallaEditarPerfil extends StatefulWidget {
  final String correo; // Correo que llega desde la pantalla anterior
  const PantallaEditarPerfil({super.key, required this.correo});

  @override
  State<PantallaEditarPerfil> createState() => _PantallaEditarPerfilState();
}

class _PantallaEditarPerfilState extends State<PantallaEditarPerfil> {
  final _formKey = GlobalKey<FormState>();
  String _generoSeleccionado = 'Niño'; // 'Niño' o 'Niña'
  bool _cargando = false;

  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _edadController = TextEditingController();

    // Fondo LOCAL: debe estar en la carpeta assets y declarado en pubspec.yaml
  final String _rutaFondo = "assets/Fondos/Fondo_EP.jpg";

  // ---- CONTROLES DE LA IMAGEN INFERIOR ----
  // Altura de la imagen (el ancho se calcula solo para mantener su proporción)
  static const double _altoImagenInferior = 180;

  // Posición horizontal: -1.0 = pegada a la izquierda, 0.0 = centro, 1.0 = pegada a la derecha
  // (acepta decimales, por ejemplo -0.5 o 0.7)
  static const double _posicionHorizontal = 0.0;

  // Separación entre la imagen y el borde inferior de la pantalla
  static const double _margenInferior = -9;

  // Imagen que se muestra en la parte de abajo (reemplaza con tu enlace)
  final String _urlImagenInferior = "https://firebasestorage.googleapis.com/v0/b/mayitas-9bde2.firebasestorage.app/o/Personajes%2Fjaguar_dormido.png?alt=media&token=fde5a9fa-5b13-4e36-bb64-c1496faa1c42";

  // Avatares para Niño
final List<String> _avataresNino = [
    "https://firebasestorage.googleapis.com/v0/b/mayitas-9bde2.firebasestorage.app/o/Logos%2FBalam.png?alt=media&token=02d927fe-72c7-41c6-9bd9-f9c454b7d025",
    "https://firebasestorage.googleapis.com/v0/b/mayitas-9bde2.firebasestorage.app/o/Logos%2FKeej.png?alt=media&token=abc8dc3a-0009-454e-8419-a20ba9cf89c4",
    "https://firebasestorage.googleapis.com/v0/b/mayitas-9bde2.firebasestorage.app/o/Logos%2FBaats.png?alt=media&token=46afb59d-6748-4f9c-9e25-b4ad57dfefa9",
    "https://firebasestorage.googleapis.com/v0/b/mayitas-9bde2.firebasestorage.app/o/Logos%2FMeekkoj.png?alt=media&token=10d8814d-54ae-45cc-aaef-f5fb79f06c0b",
  ];

  // Avatares para Niña (reemplaza con tus enlaces)
  final List<String> _avataresNina = [
    "https://firebasestorage.googleapis.com/v0/b/mayitas-9bde2.firebasestorage.app/o/Logos%2FBalam%20M.png.jpg?alt=media&token=0af7e536-330d-49b0-aebd-b716c2bc8c9c",
    "https://firebasestorage.googleapis.com/v0/b/mayitas-9bde2.firebasestorage.app/o/Logos%2FKeej%20M.png.jpg?alt=media&token=0bfe7d01-2352-40a8-944f-9da3ac986c9f",
    "https://firebasestorage.googleapis.com/v0/b/mayitas-9bde2.firebasestorage.app/o/Logos%2FBaats%20M.png.jpg?alt=media&token=c07b86b3-9829-4e21-a576-9aeedc30aa16",
    "https://firebasestorage.googleapis.com/v0/b/mayitas-9bde2.firebasestorage.app/o/Logos%2FMeekkoj%20M.png.jpg?alt=media&token=e70a0d1f-7eae-40d4-a6b0-467474247919",
  ];

  // Devuelve la lista que corresponde al género elegido
  List<String> get _avatares =>
      _generoSeleccionado == 'Niño' ? _avataresNino : _avataresNina;

  int _avatarIndex = 0; // Posición del avatar elegido dentro de la lista activa

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _edadController.dispose();
    super.dispose();
  }

  // Cambia el género y reinicia el avatar al primero de la nueva lista
  void _cambiarGenero(String genero) {
    setState(() {
      _generoSeleccionado = genero;
      _avatarIndex = 0;
    });
  }

  // ------------------------------------------------------------
  // AVATAR PRINCIPAL CON MARCO Y LÁPIZ
  // ------------------------------------------------------------
  Widget _selectorAvatar() {
    return Column(
      children: [
        GestureDetector(
          onTap: _abrirSelectorAvatar,
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
                    color: Color(0xFF141416),
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
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // PANEL INFERIOR PARA ELEGIR AVATAR
  // ------------------------------------------------------------
  void _abrirSelectorAvatar() {
    final lista = _avatares; // Lista activa según el género

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
                children: List.generate(lista.length, (i) {
                  final seleccionado = i == _avatarIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _avatarIndex = i);
                      Navigator.of(sheetContext).pop();
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
                            backgroundImage: NetworkImage(lista[i]),
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
  // BOTÓN DE GÉNERO (reutilizable para Niño y Niña)
  // ------------------------------------------------------------
  Widget _botonGenero({
    required String genero,
    required IconData icono,
    required Color colorActivo,
  }) {
    final activo = _generoSeleccionado == genero;
    return Expanded(
      child: GestureDetector(
        onTap: () => _cambiarGenero(genero),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: activo ? colorActivo : Colors.grey[800]!,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, color: activo ? colorActivo : Colors.grey[500]),
              const SizedBox(width: 8),
              Text(
                genero,
                style: TextStyle(
                  color: activo ? colorActivo : Colors.grey[500],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Decoración común para los campos de texto (legibles sobre el fondo)
  InputDecoration _decoracionCampo(String etiqueta) {
    return InputDecoration(
      labelText: etiqueta,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.black45,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // ------------------------------------------------------------
  // GUARDAR PERFIL EN REALTIME DATABASE
  // ------------------------------------------------------------
  Future<void> _guardarPerfil() async {
    if (!_formKey.currentState!.validate()) return;
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
    setState(() => _cargando = true);
    try {
      final String idUsuario = FirebaseAuth.instance.currentUser!.uid;
      final String avatarFinal = _avatares[_avatarIndex];

      final DatabaseReference ref = FirebaseDatabase.instance.ref("usuarios/$idUsuario");
      await ref.set({
        'correo': widget.correo,
        'nombre': _nombreController.text.trim(),
        'apellido': _apellidoController.text.trim(),
        'edad': edad,
        'genero': _generoSeleccionado,
        'avatar_url': avatarFinal,
        'experiencia': 0,
        'monedas': 0,
        'skins': "",
        'fecha_creacion': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PantallaPrincipal()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  // ------------------------------------------------------------
  // INTERFAZ
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // Si el teclado está abierto, se oculta la imagen inferior para que no estorbe
    final tecladoAbierto = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: const Color(0xFF141416),
      body: Stack(
        children: [
          // 1) FONDO
          Positioned.fill(
            child: Image.asset(
              _rutaFondo,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(), // Si falla, queda el color sólido
            ),
          ),

          // 2) CAPA OSCURA (sube o baja alpha para más o menos contraste)
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.55)),
          ),

          // 3) CONTENIDO (formulario)
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                // Padding inferior grande para que el formulario no quede tapado por la imagen de abajo
                padding: const EdgeInsets.fromLTRB(24, 24, 24, _altoImagenInferior + _margenInferior + 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'crea tu perfil',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                      const SizedBox(height: 32),

                      // ---------- SELECTOR DE AVATAR ----------
                      _selectorAvatar(),
                      const SizedBox(height: 32),

                      // ---------- SELECTOR NIÑO / NIÑA ----------
                      Row(
                        children: [
                          _botonGenero(
                            genero: 'Niño',
                            icono: Icons.face,
                            colorActivo: Colors.blue,
                          ),
                          const SizedBox(width: 16),
                          _botonGenero(
                            genero: 'Niña',
                            icono: Icons.face_3,
                            colorActivo: Colors.pink,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ---------- CAMPO NOMBRE ----------
                      TextFormField(
                        controller: _nombreController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoracionCampo('Nombre(s)'),
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
                        decoration: _decoracionCampo('Apellido(s)'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Por favor ingresa tu(s) apellido(s)';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ---------- CAMPO EDAD ----------
                      TextFormField(
                        controller: _edadController,
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoracionCampo('Edad').copyWith(counterText: ""),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Por favor ingresa tu edad';
                          final edad = int.tryParse(value);
                          if (edad == null || edad <= 0) return 'Ingresa una edad válida';
                          if (edad < 6 || edad > 10) return 'El niño debe tener de 6 a 10 años para registrarse';
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),

                      // ---------- BOTÓN GUARDAR ----------
                      ElevatedButton(
                        onPressed: _cargando ? null : _guardarPerfil,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _cargando
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text(
                                'Guardar y Entrar',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4) IMAGEN INFERIOR
                    // 4) IMAGEN INFERIOR (mantiene su proporción original)
          if (!tecladoAbierto)
            Positioned(
              left: 0,
              right: 0,
              bottom: _margenInferior,
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment(_posicionHorizontal, 0),
                  child: Image.network(
                    _urlImagenInferior,
                    height: _altoImagenInferior,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}