//importaciones de librerias
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Screen_temporal/pantalla_carga.dart';
import 'package:Mayitas/Juegos/PartesCuerpo/jueguito_cuerpo.dart';
import 'package:Mayitas/Juegos/JuegosColores/jueguito_clasifica.dart';
import 'package:Mayitas/Juegos/Numeros/juego_numeros.dart';

import '../Services/auth_SigIng_Google.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Services/progreso_service.dart';
import '../Services/audio_service.dart'; // NUEVO: música y efectos
import 'MiInfo/mi_info_screen.dart';
import 'MiInfo/modelo/perfil_firebase.dart';
import 'MiInfo/servicio/perfil_servicio.dart';
import 'MiInfo/widgets/avatar_usuario.dart';

const _crema = Color(0xFFFBE9CB);
const _textoOscuro = Color(0xFF2E2E2E);

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final User? _usuario = FirebaseAuth.instance.currentUser;
  final _db = FirebaseDatabase.instance;

  // Se crea UNA sola vez (en initState) para que la barra no parpadee
  // ni se vuelva a conectar cada vez que la pantalla se redibuja.
  Stream<DatabaseEvent>? _perfilStream;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();

    final u = _usuario;
    if (u != null) {
      _perfilStream = _db.ref('usuarios/${u.uid}').onValue;
    }
    _leerAvatar();

    // Música del menú (si ya está sonando, no se reinicia)
    AudioService.instance.reproducirMusica('music/menu.mp3');

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _leerAvatar() async {
    final PerfilFirebase? perfil = await PerfilServicio.leerPerfilActual();
    if (!mounted || perfil == null) return;
    setState(() => _avatarUrl = perfil.avatarUrl);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  Future<void> _cerrarSesion() async {
    AudioService.instance.detenerMusica();
    await AuthService.cerrarSesion();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PantallaCarga()),
      (route) => false,
    );
  }

  // ------------------------------------------------------------
  // AJUSTES: volumen y silencio de música y efectos
  // ------------------------------------------------------------
  void _abrirAjustes() {
    showDialog(
      context: context,
      builder: (_) {
        // Texto oscuro sobre fondo crema fijo: siempre se lee, sin
        // importar el tema de la app
        const estilo = TextStyle(color: _textoOscuro);
        final audio = AudioService.instance;

        return ListenableBuilder(
          listenable: audio, // se redibuja solo cuando cambia el audio
          builder: (context, _) => AlertDialog(
            backgroundColor: _crema,
            title: const Text('Ajustes', style: estilo),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ---------- Música ----------
                  SwitchListTile(
                    title: const Text('Silenciar música', style: estilo),
                    value: audio.musicaSilenciada,
                    onChanged: audio.setMusicaSilenciada,
                  ),
                  const Text('Volumen de la música', style: estilo),
                  Slider(
                    value: audio.volumenMusica,
                    onChanged:
                        audio.musicaSilenciada ? null : audio.setVolumenMusica,
                  ),
                  const Divider(),

                  // ---------- Efectos ----------
                  SwitchListTile(
                    title: const Text('Silenciar efectos', style: estilo),
                    value: audio.efectosSilenciados,
                    onChanged: audio.setEfectosSilenciados,
                  ),
                  const Text('Volumen de los efectos', style: estilo),
                  Slider(
                    value: audio.volumenEfectos,
                    onChanged: audio.efectosSilenciados
                        ? null
                        : audio.setVolumenEfectos,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: _cerrarSesion,
                child: const Text('Cerrar sesión', style: estilo),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar', style: estilo),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Copia local: así Dart sabe que, dentro de los builders, no es null
    final usuario = _usuario;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo
          Image.asset('assets/Fondos/Fondo_Menu.jpg', fit: BoxFit.cover),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final h = c.maxHeight;

                return Stack(
                  children: [
                    // ---------- Logo (arriba izquierda) ----------
                    Positioned(
                      left: w * (0.05), //izquierda
                      top: h * (-0.05), //arriba
                      height: h * 0.44, //tamaño
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/Logos/Logo_letras_decorado.png',
                        ),
                      ),
                    ),

                    // ---------- Barra de perfil (centrada, con datos de Firebase) ----------
                    Positioned(
                      left: w * 0.27,
                      right: w * 0.27,
                      top: h * 0.035,
                      height: h * 0.125,
                      child: usuario == null
                          ? const SizedBox()
                          : StreamBuilder<DatabaseEvent>(
                              stream: _perfilStream,
                              builder: (context, snap) {
                                final raw = snap.data?.snapshot.value;
                                final datos =
                                    raw is Map ? raw : <dynamic, dynamic>{};

                                // Experiencia -> nivel y progreso
                                final info = ProgresoService.calcular(
                                    ProgresoService.leerExperiencia(raw));

                                // Nombre: el de la base de datos, y si no hay, el de Google
                                final guardado =
                                    (datos['nombre'] as String?)?.trim() ?? '';
                                final base = guardado.isNotEmpty
                                    ? guardado
                                    : (usuario.displayName ?? '');
                                final nombreBarra = base.trim().isEmpty
                                    ? 'amigo'
                                    : base.trim().split(' ').first;

                                // Foto: el avatar elegido, y si no hay, la de Google
                                final avatar = datos['avatar_url'] as String?;
                                final foto =
                                    (avatar != null && avatar.isNotEmpty)
                                        ? avatar
                                        : usuario.photoURL;

                                return _BarraPerfil(
                                  nombre: nombreBarra,
                                  fotoUrl: foto,
                                  nivel: info.nivel,
                                  progreso: info.progreso,
                                  h: h,
                                );
                              },
                            ),
                    ),

                    // ---------- Avatar (Mi Info) + Engrane (abre los ajustes) ----------
                    Positioned(
                      right: w * 0.025,
                      top: h * 0.045,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                    builder: (_) => const MiInfoScreen()),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: h * 0.015),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF3DC),
                                shape: BoxShape.circle,
                              ),
                              child: AvatarUsuario(tamano: h * 0.07, url: _avatarUrl),
                            ),
                          ),
                          SizedBox(
                            width: h * 0.1,
                            height: h * 0.1,
                            child: PopupMenuButton<String>(
                              onSelected: (v) {
                                if (v == 'salir') _cerrarSesion();
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'salir',
                                  child: Text(
                                    'Cerrar sesión',
                                    style: TextStyle(color: _textoOscuro),
                                  ),
                                ),
                              ],
                              child: GestureDetector(
                                onTap: _abrirAjustes,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFF3DC),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.settings,
                                    size: h * 0.06,
                                    color: const Color(0xFF5A5A5A),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ---------- Banner "Elige un módulo" ----------
                    Positioned(
                      left: w * 0.27,
                      right: w * 0.27,
                      top: h * 0.215,
                      height: h * 0.085,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6E3C0),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          '¿Qué vamos a aprender hoy?',
                          style: TextStyle(
                            fontSize: h * 0.05,
                            fontWeight: FontWeight.bold,
                            color: _textoOscuro,
                          ),
                        ),
                      ),
                    ),

                    // ---------- Tarjetas ----------
                    Positioned(
                      left: w * 0.045,
                      right: w * 0.045,
                      top: h * 0.34,
                      height: h * 0.41,
                      // ListView horizontal: permite DESLIZAR para ver más módulos.
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        children: [
                          // ---------- Módulo: Colores ----------
                          SizedBox(
                            width: w * 0.22,
                            child: ModuloCard(
                              titulo: 'Colores',
                              color: const Color(0xFFFFC928),
                              colorBorde: const Color(0xFFFFF0B3),
                              colorTitulo: const Color(0xFFB86E00),
                              colorPildora: const Color(0xFFD99A00),
                              hechas: 1,
                              total: 5,
                              h: h,
                              imagen: Icon(
                                Icons.palette,
                                color: Colors.white,
                                size: h * 0.2,
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const JuegoColores(),
                                  ),
                                );
                              },
                            ),
                          ),
                          // ---------- Módulo: Animales ----------
                          SizedBox(
                            width: w * 0.22,
                            child: ModuloCard(
                              titulo: 'Animales',
                              color: const Color(0xFF5CC33A),
                              colorBorde: const Color(0xFFD6F2C4),
                              colorTitulo: Colors.white,
                              colorPildora: const Color(0xFF3F9A24),
                              hechas: 0,
                              total: 5,
                              h: h,
                              imagen: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  'assets/Personajes/jaguar_sentado.png',
                                ),
                              ),
                              // TODO: Aquí mandas al juego de Animales.
                              onTap: () {},
                            ),
                          ),
                          // ---------- Módulo: Números ----------
                          SizedBox(
                            width: w * 0.22,
                            child: ModuloCard(
                              titulo: 'Números',
                              color: const Color(0xFF2FA4F5),
                              colorBorde: const Color(0xFFC4E6FF),
                              colorTitulo: Colors.white,
                              colorPildora: const Color(0xFF1C7FC4),
                              hechas: 0,
                              total: 5,
                              h: h,
                              imagen: const _Numeros123(),
                              // TODO: Aquí mandas al juego de Números.
                              onTap: () {
                                Navigator.of(context).push(
       MaterialPageRoute(builder: (_) => const JuegoNumeros()),
     );
                              },
                            ),
                          ),
                          // ---------- Módulo: Saludos ----------
                          SizedBox(
                            width: w * 0.22,
                            child: ModuloCard(
                              titulo: 'Saludos y expresiones comunes',
                              color: const Color(0xFF9B6BE0),
                              colorBorde: const Color(0xFFE3D4F7),
                              colorTitulo: Colors.white,
                              colorPildora: const Color(0xFF7448B8),
                              hechas: 0,
                              total: 5,
                              h: h,
                              imagen: Icon(
                                Icons.forum,
                                color: Colors.white,
                                size: h * 0.2,
                              ),
                              // TODO: Aquí mandas al juego de Saludos.
                              onTap: () {},
                            ),
                          ),
                          // ---------- Módulo: Partes del cuerpo ----------
                          SizedBox(
                            width: w * 0.22,
                            child: ModuloCard(
                              titulo: 'Partes del cuerpo',
                              color: const Color(0xFF00B0A0),
                              colorBorde: const Color(0xFFB8EEE8),
                              colorTitulo: Colors.white,
                              colorPildora: const Color(0xFF008577),
                              hechas: 0,
                              total: 5,
                              h: h,
                              imagen: Icon(
                                Icons.accessibility_new,
                                color: Colors.white,
                                size: h * 0.2,
                              ),
                              // AQUÍ se manda al juego de Partes del cuerpo.
                              // El widget JueguitoCuerpo vive en:
                              // lib/Juegos/PartesCuerpo/jueguito_cuerpo.dart
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const JuegoPartesCuerpo(),
                                  ),
                                );
                              },
                            ),
                          ),
                          // ---------- Apartado: Diccionario ----------
                          SizedBox(
                            width: w * 0.22,
                            child: ModuloCard(
                              titulo: 'Diccionario',
                              color: const Color(0xFFFF7A59),
                              colorBorde: const Color(0xFFFFD9CE),
                              colorTitulo: Colors.white,
                              colorPildora: const Color(0xFFD05636),
                              hechas: 0,
                              total: 50,
                              etiqueta: 'palabras',
                              h: h,
                              imagen: Icon(
                                Icons.menu_book,
                                color: Colors.white,
                                size: h * 0.2,
                              ),
                              // TODO: Aquí mandas a la pantalla de Diccionario. Ejemplo:
                              // Navigator.of(context).push(
                              //   MaterialPageRoute(builder: (_) => const Diccionario()),
                              // );
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ---------- Jaguar (abajo izquierda) ----------
                    Positioned(
                      left: (-14),
                      bottom: -17,
                      height: h * 0.40,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/Personajes/jaguar_saludando.png',
                        ),
                      ),
                    ),

                    // ---------- Mensaje inferior ----------
                    Positioned(
                      left: w * 0.30,
                      right: w * 0.30,
                      bottom: h * 0.05,
                      height: h * 0.12,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _crema,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          '¡Sigue aprendiendo y\ncompleta todos los juegos!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: h * 0.04,
                            fontWeight: FontWeight.bold,
                            color: _textoOscuro,
                          ),
                        ),
                      ),
                    ),

                    // ---------- Letrero de madera ----------
                    Positioned(
                      right: w * 0.02,
                      bottom: h * 0.02,
                      width: w * 0.19,
                      height: h * 0.15,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: w * 0.01),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF7A4E2B), Color(0xFF5B3A1E)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF3E2812),
                            width: 3,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E2C0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.filter_vintage,
                                size: h * 0.05,
                                color: const Color(0xFF8A5A2B),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  text: 'Pequeños pasos,\ngrandes raíces ',
                                  children: [
                                    TextSpan(
                                      text: '♥',
                                      style: TextStyle(
                                        color: Color(0xFFFF5C5C),
                                      ),
                                    ),
                                  ],
                                ),
                                style: TextStyle(
                                  fontSize: h * 0.032,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ======================= Barra de perfil =======================
class _BarraPerfil extends StatelessWidget {
  final String nombre;
  final String? fotoUrl;
  final int nivel;
  final double progreso;
  final double h;

  const _BarraPerfil({
    required this.nombre,
    required this.fotoUrl,
    required this.nivel,
    required this.progreso,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: h * 0.02),
      decoration: BoxDecoration(
        color: _crema,
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(blurRadius: 6, offset: Offset(0, 3), color: Colors.black26),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: h * 0.045,
            backgroundColor: const Color(0xFFBFE3F7),
            backgroundImage: fotoUrl != null ? NetworkImage(fotoUrl!) : null,
            child: fotoUrl == null
                ? Icon(Icons.person, size: h * 0.05, color: Colors.white)
                : null,
          ),
          SizedBox(width: h * 0.02),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, $nombre',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _textoOscuro,
                    fontWeight: FontWeight.bold,
                    fontSize: h * 0.04,
                  ),
                ),
                Text(
                  '¡Qué bueno verte de nuevo!',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF5A5A5A),
                    fontSize: h * 0.027,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1.5,
            height: h * 0.08,
            color: const Color(0xFFD9C29A),
            margin: EdgeInsets.symmetric(horizontal: h * 0.02),
          ),
          Icon(Icons.star, color: const Color(0xFFFFC928), size: h * 0.065),
          SizedBox(width: h * 0.01),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nivel $nivel',
                style: TextStyle(
                  color: _textoOscuro,
                  fontWeight: FontWeight.bold,
                  fontSize: h * 0.035,
                ),
              ),
              SizedBox(height: h * 0.01),
              SizedBox(
                width: h * 0.3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progreso,
                    minHeight: h * 0.025,
                    backgroundColor: Colors.white,
                    color: const Color(0xFF3FA535),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ======================= Tarjeta de módulo =======================
class ModuloCard extends StatelessWidget {
  final String titulo;
  final Color color;
  final Color colorBorde;
  final Color colorTitulo;
  final Color colorPildora;
  final Widget imagen;
  final int hechas;
  final int total;
  final String etiqueta;
  final double h;
  final VoidCallback onTap;

  const ModuloCard({
    super.key,
    required this.titulo,
    required this.color,
    required this.colorBorde,
    required this.colorTitulo,
    required this.colorPildora,
    required this.imagen,
    required this.hechas,
    required this.total,
    this.etiqueta = 'lecciones',
    required this.h,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: h * 0.012),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(h * 0.012),
          decoration: BoxDecoration(
            color: colorBorde,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                blurRadius: 8,
                offset: Offset(0, 4),
                color: Colors.black26,
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              h * 0.015,
              h * 0.02,
              h * 0.015,
              h * 0.02,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: FittedBox(fit: BoxFit.contain, child: imagen),
                  ),
                ),
                SizedBox(height: h * 0.01),
                Text(
                  titulo,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: h * 0.04,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                    color: colorTitulo,
                  ),
                ),
                SizedBox(height: h * 0.012),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: h * 0.03,
                    vertical: h * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: colorPildora,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: h * 0.035,
                        color: const Color(0xFFFFE07A),
                      ),
                      SizedBox(width: h * 0.01),
                      Text(
                        '$hechas/$total $etiqueta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: h * 0.028,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ======================= "1 2 3" con texto =======================
class _Numeros123 extends StatelessWidget {
  const _Numeros123();

  Widget _num(String t, Color c) {
    return Stack(
      children: [
        Text(
          t,
          style: TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 8
              ..color = Colors.white,
          ),
        ),
        Text(
          t,
          style: TextStyle(fontSize: 80, fontWeight: FontWeight.w900, color: c),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _num('1', const Color(0xFFFFC928)),
        _num('2', const Color(0xFFFF5C8A)),
        _num('3', const Color(0xFF4B3FC4)),
      ],
    );
  }
}
