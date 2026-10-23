import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// JUEGO: LOS COLORES (arrastrar objetos a la canasta)

class ColorCanasta {
  final String id;
  final String nombre;
  final String imagen;
  final Color color; // color del texto y de los íconos de esta canasta
  final List<IconData> iconos; // objetos posibles (azar)

  const ColorCanasta({
    required this.id,
    required this.nombre,
    required this.imagen,
    required this.color,
    required this.iconos,
  });
}

// Un objeto que el niño arrastra.
class ObjetoColor {
  final String id;
  final String colorId;
  final IconData icono;

  const ObjetoColor({
    required this.id,
    required this.colorId,
    required this.icono,
  });
}

class JuegoColores extends StatefulWidget {
  const JuegoColores({super.key});

  @override
  State<JuegoColores> createState() => _JuegoColoresState();
}

class _JuegoColoresState extends State<JuegoColores> {
  // Escenario de referencia
  static const double anchoJuego = 1000;
  static const double altoJuego = 562;

  static const String imagenFondo = 'assets/Fondos/FondoJuego.png';
  static const String imagenInicio = 'assets/Botones/boton_inicio.png';
  static const String imagenJaguar = 'assets/Personajes/jaguar_sentado.png';

  //objetos de cada color salen por partida (10).
  static const int porColor = 2;
  static const int espaciosBandeja = 5;

  // ---- TAMAÑO Y POSICIÓN DE LAS CANASTAS ----
  static const double canastaAncho = 220;
  static const double canastaAlto = 225;
  static const double canastaArriba = 95;
  static const int totalCanastas = 5;
  static const double canastaPaso = 190;

  static const double canastasAnchoTotal =
      (totalCanastas - 1.3) * canastaPaso + canastaAncho; // 988
  static const double canastasInicio =
      (anchoJuego - canastasAnchoTotal) / 2; // 6

  // ---- TAMAÑO Y POSICIÓN DEL JAGUAR ----
  static const double jaguarIzq = 45;
  static const double jaguarArriba = 303;
  static const double jaguarAncho = 150;
  static const double jaguarAlto = 165;

  // Canastas y sus objetos cotidianos.
  static const List<ColorCanasta> canastas = [
    ColorCanasta(
      id: 'rojo',
      nombre: 'Rojo',
      imagen: 'assets/Objetos_colores/canasta_roja.png',
      color: Color(0xFFD32F2F),
      iconos: [Icons.favorite, Icons.directions_car, Icons.flag],
    ),
    ColorCanasta(
      id: 'azul',
      nombre: 'Azul',
      imagen: 'assets/Objetos_colores/canasta_azul.png',
      color: Color(0xFF1E6FD9),
      iconos: [Icons.water_drop, Icons.umbrella, Icons.directions_boat],
    ),
    ColorCanasta(
      id: 'amarillo',
      nombre: 'Amarillo',
      imagen: 'assets/Objetos_colores/canasta_amarilla.png',
      color: Color(0xFFF2B600),
      iconos: [Icons.wb_sunny, Icons.star, Icons.lightbulb],
    ),
    ColorCanasta(
      id: 'verde',
      nombre: 'Verde',
      imagen: 'assets/Objetos_colores/canasta_verde.png',
      color: Color(0xFF3C9A2E),
      iconos: [Icons.eco, Icons.park, Icons.grass],
    ),
    ColorCanasta(
      id: 'naranja',
      nombre: 'Naranja',
      imagen: 'assets/Objetos_colores/canasta_naranja.png',
      color: Color(0xFFF57C00),
      iconos: [
        Icons.sports_basketball,
        Icons.local_fire_department,
        Icons.icecream,
      ],
    ),
  ];

  // Escalas (se rellenan en build).
  double _sx = 1;
  double _sy = 1;
  double _k = 1;

  late List<ColorCanasta> _ordenCanastas; // orden en que se dibujan
  late List<ObjetoColor?> _bandeja; // lo que se ve abajo
  final List<ObjetoColor> _cola = []; // los que aún no salen
  Map<String, List<ObjetoColor>> _recogidos =
      {}; // lo ya metido en cada canasta

  String? _canastaOk;
  String? _canastaError;
  Timer? _timerDestello;

  int puntos = 0;
  int errores = 0;

  int get total => canastas.length * porColor;

  @override
  void initState() {
    super.initState();
    _nuevaPartida();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _timerDestello?.cancel();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  // ---------- Utilidades de layout ----------
  double _sx10(double v) => v * _sx;
  double _sy10(double v) => v * _sy;
  double _fs(double v) => v * _k;

  ColorCanasta _canasta(String id) => canastas.firstWhere((c) => c.id == id);

  // ---------- Lógica ----------
  void _nuevaPartida() {
    final rnd = Random();

    // Las canastas cambian de lugar en cada partida.
    _ordenCanastas = [...canastas]..shuffle(rnd);

    final todos = <ObjetoColor>[];
    for (final c in canastas) {
      final iconos = [...c.iconos]..shuffle(rnd);
      for (int i = 0; i < porColor; i++) {
        todos.add(
          ObjetoColor(id: '${c.id}_$i', colorId: c.id, icono: iconos[i]),
        );
      }
    }
    todos.shuffle(rnd);

    _bandeja = List<ObjetoColor?>.generate(
      espaciosBandeja,
      (i) => i < todos.length ? todos[i] : null,
    );
    _cola
      ..clear()
      ..addAll(todos.skip(espaciosBandeja));
    _recogidos = {for (final c in canastas) c.id: <ObjetoColor>[]};
    puntos = 0;
    errores = 0;
    _canastaOk = null;
    _canastaError = null;
    _timerDestello?.cancel();
  }

  void reiniciarJuego() {
    setState(_nuevaPartida);
  }

  void _soltar(ColorCanasta c, ObjetoColor o) {
    final i = _bandeja.indexWhere((x) => x?.id == o.id);
    if (i == -1) return;

    if (o.colorId == c.id) {
      setState(() {
        _bandeja[i] = _cola.isNotEmpty ? _cola.removeAt(0) : null;
        _recogidos[c.id]!.add(o);
        puntos++;
        _canastaOk = c.id;
        _canastaError = null;
      });
      _limpiarDestello();
      if (puntos == total) {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) _mostrarResultado();
        });
      }
    } else {
      // Incorrecto: el objeto regresa solo a la bandeja.
      setState(() {
        errores++;
        _canastaError = c.id;
        _canastaOk = null;
      });
      _limpiarDestello();
    }
  }

  // Un solo temporizador: si se suelta otro objeto antes de que termine,
  // se cancela el anterior y no se corta el brillo a la mitad.

  void _limpiarDestello() {
    _timerDestello?.cancel();
    // Detiene el efecto después de 600 milisegundos.
    _timerDestello = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _canastaOk = null;
        _canastaError = null;
      });
    });
  }

  void _mostrarResultado() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contexto) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF7E0B0),
          title: const Text(
            '¡Felicidades!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF59371E),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            errores == 0
                ? '¡Todos correctos, sin errores!\n\nPuntos: $puntos / $total'
                : 'Puntos: $puntos / $total\n\nIntentos fallidos: $errores',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Color(0xFF3D2918)),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(contexto);
                reiniciarJuego();
              },
              child: const Text('Jugar otra vez'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(contexto),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // ---------- Widgets ----------

  // Aquí se dibuja un objeto. Si algún día quieres PNG en vez de íconos,
  // cámbialo solo en esta función.
  Widget _dibujoObjeto(ObjetoColor o, double tam) {
    return Icon(
      o.icono,
      size: tam,
      color: _canasta(o.colorId).color,
      shadows: const [
        Shadow(color: Colors.black26, blurRadius: 3, offset: Offset(1, 2)),
      ],
    );
  }

  Widget _objetoArrastrable(ObjetoColor o, double ancho, double alto) {
    return Draggable<ObjetoColor>(
      data: o,
      // El objeto queda centrado bajo el dedo.
      dragAnchorStrategy: (d, ctx, pos) => Offset(ancho / 2, alto / 2),
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: ancho,
          height: alto,
          child: Center(child: _dibujoObjeto(o, _fs(90))),
        ),
      ),

      child: SizedBox(
        width: ancho,
        height: alto,
        child: Center(child: _dibujoObjeto(o, _fs(64))),
      ),
    );
  }

  // ----- Canasta -----
  Widget _crearCanasta(int i) {
    final c = _ordenCanastas[i];

    final double xPos = canastasInicio + i * canastaPaso;
    final recogidos = _recogidos[c.id] ?? const <ObjetoColor>[];

    return Positioned(
      key: ValueKey('canasta_${c.id}'),
      left: _sx10(xPos),
      top: _sy10(canastaArriba),
      width: _sx10(canastaAncho),
      height: _sy10(canastaAlto),
      child: DragTarget<ObjetoColor>(
        onWillAcceptWithDetails: (_) => true,
        onAcceptWithDetails: (d) => _soltar(c, d.data),
        builder: (context, candidatos, rechazados) {
          final encima = candidatos.isNotEmpty;
          final ok = _canastaOk == c.id;
          final error = _canastaError == c.id;

          Color? brillo;
          if (error) {
            brillo = Colors.red.shade700;
          } else if (ok) {
            brillo = Colors.green.shade600;
          } else if (encima) {
            brillo = const Color(0xFFFFE08A);
          }
          // CAMBIO: ya no hay AnimatedScale, el Stack va directo.
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Resplandor (acierto / error / objeto encima).
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_fs(20)),
                      boxShadow: [
                        BoxShadow(
                          color: (brillo ?? Colors.transparent).withValues(
                            alpha: brillo == null ? 0.0 : 0.6,
                          ),
                          blurRadius: 6 * _k, // antes 20
                          spreadRadius: -20 * _k, // antes 4
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Imagen de la canasta.
              Positioned.fill(
                child: Image.asset(c.imagen, fit: BoxFit.contain),
              ),
              // Objetos ya metidos (no se mueven ni cambian de tamaño).
              Positioned(
                left: 0,
                right: 0,
                top: canastaAlto * 0.32 * _sy,
                height: canastaAlto * 0.32 * _sy,
                child: RepaintBoundary(
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Un espacio fijo por cada objeto posible: los iconos no se mueven.
                        for (int s = 0; s < porColor; s++)
                          SizedBox(
                            width: _fs(48),
                            height: _fs(48),
                            child: s < recogidos.length
                                ? Center(
                                    child: KeyedSubtree(
                                      key: ValueKey(
                                        'recogido_${recogidos[s].id}',
                                      ),
                                      child: _dibujoObjeto(
                                        recogidos[s],
                                        _fs(40),
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ----- Bandeja de objetos -----
  Widget _crearBandeja() {
    const double tileAncho = 103;
    const double tileAlto = 100;
    const double paso = 125.5;
    const double primerIzq = 228;
    const double tileArriba = 400;

    return Stack(
      children: [
        // Fondo de la bandeja.
        Positioned(
          left: _sx10(210),
          top: _sy10(384),
          width: _sx10(644),
          height: _sy10(131),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF2D6A1),
              borderRadius: BorderRadius.circular(_fs(24)),
              border: Border.all(color: const Color(0xFFC49A61), width: 2 + _k),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
        ),
        for (int i = 0; i < espaciosBandeja; i++) ...[
          Positioned(
            left: _sx10(primerIzq + i * paso),
            top: _sy10(tileArriba),
            width: _sx10(tileAncho),
            height: _sy10(tileAlto),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7E9CB),
                borderRadius: BorderRadius.circular(_fs(16)),
                border: Border.all(color: const Color(0x33754A25), width: 2),
              ),
            ),
          ),
          if (_bandeja[i] != null)
            Positioned(
              key: ValueKey(_bandeja[i]!.id),
              left: _sx10(primerIzq + i * paso),
              top: _sy10(tileArriba),
              width: _sx10(tileAncho),
              height: _sy10(tileAlto),
              child: _objetoArrastrable(
                _bandeja[i]!,
                _sx10(tileAncho),
                _sy10(tileAlto),
              ),
            ),
        ],
      ],
    );
  }

  // ----- Encabezado -----
  Widget _crearEncabezado() {
    final sombra = const [
      BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 3)),
    ];

    return Stack(
      children: [
        // Título (madera)
        Positioned(
          left: _sx10(30),
          top: _sy10(17),
          width: _sx10(230),
          height: _sy10(56),
          child: Container(
            padding: EdgeInsets.all(_fs(4)),
            decoration: BoxDecoration(
              color: const Color(0xFF754A25),
              borderRadius: BorderRadius.circular(_fs(18)),
              border: Border.all(color: const Color(0xFF3D2918), width: 2),
              boxShadow: sombra,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3B2A1A),
                borderRadius: BorderRadius.circular(_fs(14)),
              ),
              child: Row(
                children: [
                  SizedBox(width: _fs(6)),
                  Container(
                    padding: EdgeInsets.all(_fs(5)),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF7E0B0),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.palette_rounded,
                      color: const Color(0xFF754A25),
                      size: _fs(26),
                    ),
                  ),
                  SizedBox(width: _fs(8)),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Los colores',
                        style: TextStyle(
                          fontSize: _fs(28),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFE3A2),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: _fs(8)),
                ],
              ),
            ),
          ),
        ),

        // Instrucción (pergamino)
        Positioned(
          left: _sx10(284),
          top: _sy10(20),
          width: _sx10(443),
          height: _sy10(53),
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: _fs(14)),
            decoration: BoxDecoration(
              color: const Color(0xFFF7E0B0),
              borderRadius: BorderRadius.circular(_fs(10)),
              border: Border.all(color: const Color(0xFFC49A61), width: 2),
              boxShadow: sombra,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Arrastra cada objeto al color que le corresponde.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: _fs(19),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3D2918),
                ),
              ),
            ),
          ),
        ),

        // Puntos
        Positioned(
          left: _sx10(770),
          top: _sy10(22),
          width: _sx10(140),
          height: _sy10(47),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7E0B0),
              borderRadius: BorderRadius.circular(_fs(24)),
              border: Border.all(color: const Color(0xFFC49A61), width: 2),
              boxShadow: sombra,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_rounded, color: Colors.amber, size: _fs(32)),
                SizedBox(width: _fs(6)),
                Text(
                  '$puntos / $total',
                  style: TextStyle(
                    fontSize: _fs(19),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF59371E),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Ajustes
        Positioned(
          left: _sx10(933),
          top: _sy10(22),
          width: _sx10(46),
          height: _sy10(46),
          child: GestureDetector(
            onTap: () {
              // TODO: abrir ajustes (sonido, etc.)
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7E0B0),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC49A61), width: 2),
                boxShadow: sombra,
              ),
              child: Icon(
                Icons.settings_rounded,
                color: const Color(0xFF59371E),
                size: _fs(28),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _crearBoton({
    required String imagen,
    required VoidCallback accion,
    required double izquierda,
    required double arriba,
    required double ancho,
    required double alto,
  }) {
    return Positioned(
      left: _sx10(izquierda),
      top: _sy10(arriba),
      width: _sx10(ancho),
      height: _sy10(alto),
      child: GestureDetector(
        onTap: accion,
        child: Image.asset(imagen, fit: BoxFit.contain),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF29452A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ===== FONDO =====
          Image.asset(imagenFondo, fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.10)),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, c) {
                _sx = c.maxWidth / anchoJuego;
                _sy = c.maxHeight / altoJuego;
                _k = _sx < _sy ? _sx : _sy;

                return Stack(
                  children: [
                    // ===== JAGUAR =====
                    Positioned(
                      left: _sx10(jaguarIzq),
                      top: _sy10(jaguarArriba),
                      width: _sx10(jaguarAncho),
                      height: _sy10(jaguarAlto),
                      child: Image.asset(imagenJaguar, fit: BoxFit.contain),
                    ),

                    // ===== CANASTAS =====
                    for (int i = 0; i < _ordenCanastas.length; i++)
                      _crearCanasta(i),

                    // ===== BANDEJA =====
                    _crearBandeja(),

                    // ===== ENCABEZADO =====
                    _crearEncabezado(),

                    // ===== BOTÓN INICIO =====
                    _crearBoton(
                      imagen: imagenInicio,
                      accion: () {
                        Navigator.pop(context);
                      },
                      izquierda: 30,
                      arriba: 476,
                      ancho: 145,
                      alto: 59,
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
