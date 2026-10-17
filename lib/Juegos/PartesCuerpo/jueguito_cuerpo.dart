import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// =====================================================
// JUEGO: PARTES DEL CUERPO EN MAYA (arrastrar y soltar)
// Proyecto: Mayitas
// =====================================================

class JuegoPartesCuerpo extends StatefulWidget {
  const JuegoPartesCuerpo({super.key});

  @override
  State<JuegoPartesCuerpo> createState() => _JuegoPartesCuerpoState();
}

// Una parte del cuerpo y su palabra en maya.
// fx / fy = posición del punto sobre la niña, en proporción (0 a 1)
// del cuadro donde está la imagen. Así es fácil ajustarlos.
class ParteCuerpo {
  final String id;
  final String palabra;
  final String significado;
  final double fx;
  final double fy;
  final bool izquierda; // lado donde está su cuadro vacío
  final int fila; // 0 a 4, de arriba hacia abajo

  const ParteCuerpo({
    required this.id,
    required this.palabra,
    required this.significado,
    required this.fx,
    required this.fy,
    required this.izquierda,
    required this.fila,
  });
}

class _JuegoPartesCuerpoState extends State<JuegoPartesCuerpo> {
  // Escenario de referencia (para calcular proporciones).
  static const double anchoJuego = 1000;
  static const double altoJuego = 650;

  // Relación de aspecto real de la imagen de la niña (255 x 442).
  static const double ratioNina = 255 / 442;

  // Imágenes.
  static const String imagenFondo = 'assets/Fondos/FondoJuego.png';
  static const String imagenBorde = 'assets/Fondos/borde.png';
  static const String imagenNina = 'assets/Personajes/nina.png';
  static const String imagenInicio = 'assets/Botones/boton_inicio.png';
  static const String imagenVerificar = 'assets/Botones/boton_verificar.png';

  // Dónde está la niña (proporción del escenario de referencia).
  static const double ninaIzq = 350;
  static const double ninaArriba = 94;
  static const double ninaAncho = 300;
  static const double ninaAlto = 520;

  // true = la ficha muestra también el significado en español.
  static const bool mostrarSignificado = true;

  // Tamaño real de pantalla y escalas (se rellenan en build).
  double _w = anchoJuego;
  double _h = altoJuego;
  double _sx = 1; // ancho real / ancho de referencia
  double _sy = 1; // alto real / alto de referencia
  double _k = 1; // escala uniforme para tipografías

  // Palabras de ejemplo (luego vendrán de la base de datos).
  // Revisar su escritura con una fuente lingüística antes de publicar.
  final List<ParteCuerpo> partes = const [
    // ---- Lado izquierdo ----
    ParteCuerpo(id: 'cabeza', palabra: 'Pool', significado: 'Cabeza', fx: 0.50, fy: 0.06, izquierda: true, fila: 0),
    ParteCuerpo(id: 'ojo', palabra: 'Ich', significado: 'Ojo', fx: 0.43, fy: 0.195, izquierda: true, fila: 1),
    ParteCuerpo(id: 'brazo', palabra: "K'ab", significado: 'Brazo', fx: 0.20, fy: 0.43, izquierda: true, fila: 2),
    ParteCuerpo(id: 'mano', palabra: "K'ab", significado: 'Mano', fx: 0.07, fy: 0.58, izquierda: true, fila: 3),
    ParteCuerpo(id: 'pierna', palabra: 'Ook', significado: 'Pierna', fx: 0.43, fy: 0.71, izquierda: true, fila: 4),
    // ---- Lado derecho ----
    ParteCuerpo(id: 'oreja', palabra: 'Xikin', significado: 'Oreja', fx: 0.74, fy: 0.20, izquierda: false, fila: 0),
    ParteCuerpo(id: 'nariz', palabra: 'Ni', significado: 'Nariz', fx: 0.515, fy: 0.225, izquierda: false, fila: 1),
    ParteCuerpo(id: 'boca', palabra: 'Chi', significado: 'Boca', fx: 0.515, fy: 0.255, izquierda: false, fila: 2),
    ParteCuerpo(id: 'barriga', palabra: 'Nak', significado: 'Barriga', fx: 0.50, fy: 0.465, izquierda: false, fila: 3),
    ParteCuerpo(id: 'pie', palabra: 'Ook', significado: 'Pie', fx: 0.55, fy: 0.94, izquierda: false, fila: 4),
  ];

  // slotId -> fichaId (qué palabra puso el jugador en cada cuadro).
  final Map<String, String> colocadas = {};

  // Orden (revuelto) de las fichas en la banca.
  late final List<String> orden;

  bool juegoVerificado = false;
  int puntos = 0;

  @override
  void initState() {
    super.initState();
    orden = partes.map((p) => p.id).toList()..shuffle(Random());
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Regresamos a la pantalla principal en horizontal (igual que ella pidió).
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  // ---------- Utilidades de layout ----------
  double _sx10(double v) => v * _sx; // ancho
  double _sy10(double v) => v * _sy; // alto
  double _fs(double v) => v * _k; // tipografía (escala uniforme)

  ParteCuerpo parte(String id) => partes.firstWhere((p) => p.id == id);

  // Rectángulo del cuadro vacío (ya escalado a pantalla real).
  Rect rectCuadro(ParteCuerpo p) => Rect.fromLTWH(
        _sx10(p.izquierda ? 198 : 650),
        _sy10(120 + p.fila * 87.0),
        _sx10(152),
        _sy10(58),
      );

  // Rectángulo real donde se dibuja la niña (BoxFit.contain dentro de su caja).
  Rect get rectNina {
    final box = Rect.fromLTWH(
      _sx10(ninaIzq),
      _sy10(ninaArriba),
      _sx10(ninaAncho),
      _sy10(ninaAlto),
    );
    double iw = box.width;
    double ih = iw / ratioNina;
    if (ih > box.height) {
      ih = box.height;
      iw = ih * ratioNina;
    }
    return Rect.fromLTWH(
      box.left + (box.width - iw) / 2,
      box.top + (box.height - ih) / 2,
      iw,
      ih,
    );
  }

  // fx / fy se mapean al rectángulo real de la imagen (no a la caja),
  // así los puntos caen exactamente donde deben.
  Offset puntoCuerpo(ParteCuerpo p) {
    final r = rectNina;
    return Offset(r.left + p.fx * r.width, r.top + p.fy * r.height);
  }

  // Correcta si la palabra es la misma (Brazo/Mano = K'ab, Pierna/Pie = Ook).
  bool esCorrecta(String slotId) {
    final ficha = colocadas[slotId];
    if (ficha == null) return false;
    return parte(ficha).palabra == parte(slotId).palabra;
  }

  void colocar(String slotId, String fichaId) {
    if (juegoVerificado) return;
    setState(() {
      colocadas.removeWhere((slot, ficha) => ficha == fichaId);
      colocadas[slotId] = fichaId;
    });
  }

  void devolverABanca(String fichaId) {
    if (juegoVerificado) return;
    setState(() {
      colocadas.removeWhere((slot, ficha) => ficha == fichaId);
    });
  }

  void verificarJuego() {
    if (juegoVerificado) return;

    if (colocadas.length < partes.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Coloca todas las palabras antes de verificar!'),
          backgroundColor: const Color(0xFF80552C),
        ),
      );
      return;
    }

    int correctas = 0;
    for (final p in partes) {
      if (esCorrecta(p.id)) correctas++;
    }

    setState(() {
      puntos = correctas * 10;
      juegoVerificado = true;
    });

    showDialog(
      context: context,
      builder: (contexto) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF7E0B0),
          title: Text(
            correctas == partes.length ? '¡Felicidades!' : '¡Buen intento!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF59371E),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Respuestas correctas: $correctas de ${partes.length}\n\n'
            'Puntuación: $puntos puntos',
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
              child: const Text('Ver respuestas'),
            ),
          ],
        );
      },
    );
  }

  void reiniciarJuego() {
    setState(() {
      colocadas.clear();
      orden.shuffle(Random());
      puntos = 0;
      juegoVerificado = false;
    });
  }

  // ---------- Widgets ----------

  // Ficha con la palabra maya.
  Widget ficha(
    ParteCuerpo p, {
    required double ancho,
    required double alto,
    Color borde = const Color(0xFF754A25),
  }) {
    return Container(
      width: ancho,
      height: alto,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF2D6A1),
        borderRadius: BorderRadius.circular(_fs(12)),
        border: Border.all(color: borde, width: 2 + _k),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(2, 3)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            p.palabra,
            style: TextStyle(
              fontSize: _fs(26),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3D2918),
              height: 1.1,
            ),
          ),
          if (mostrarSignificado)
            Text(
              '(${p.significado})',
              style: TextStyle(
                fontSize: _fs(16),
                color: const Color(0xFF64462E),
                height: 1.1,
              ),
            ),
        ],
      ),
    );
  }

  // Ficha que se puede arrastrar.
  Widget fichaArrastrable(
    ParteCuerpo p, {
    required double ancho,
    required double alto,
    Color borde = const Color(0xFF754A25),
    VoidCallback? alTocar,
  }) {
    final hija = ficha(p, ancho: ancho, alto: alto, borde: borde);
    return Draggable<String>(
      data: p.id,
      maxSimultaneousDrags: juegoVerificado ? 0 : 1,
      feedback: Material(
        color: Colors.transparent,
        child: ficha(p, ancho: ancho, alto: alto),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: hija),
      child: GestureDetector(onTap: alTocar, child: hija),
    );
  }

  // Cuadro vacío junto a la niña.
  Widget crearCuadro(ParteCuerpo p) {
    final r = rectCuadro(p);

    Color borde = const Color(0xFF8A6238);
    if (juegoVerificado) {
      borde = esCorrecta(p.id) ? Colors.green.shade700 : Colors.red.shade700;
    }

    return Positioned(
      left: r.left,
      top: r.top,
      width: r.width,
      height: r.height,
      child: DragTarget<String>(
        onWillAcceptWithDetails: (_) => !juegoVerificado,
        onAcceptWithDetails: (d) => colocar(p.id, d.data),
        builder: (context, candidatos, rechazados) {
          final fichaId = colocadas[p.id];

          if (fichaId != null) {
            return fichaArrastrable(
              parte(fichaId),
              ancho: r.width,
              alto: r.height,
              borde: juegoVerificado ? borde : const Color(0xFF277B50),
              alTocar: () => devolverABanca(fichaId),
            );
          }

          final resaltado = candidatos.isNotEmpty;
          return Container(
            decoration: BoxDecoration(
              color: resaltado
                  ? const Color(0xFFFFE08A)
                  : const Color(0xCCF7E9CB),
              borderRadius: BorderRadius.circular(_fs(12)),
              border: Border.all(
                color: resaltado ? Colors.orange.shade800 : borde,
                width: (resaltado ? 4 : 2) * _k,
              ),
            ),
          );
        },
      ),
    );
  }

  // Columna lateral con las palabras (izquierda o derecha).
  Widget crearColumna(bool izquierda) {
    // Las primeras 5 fichas van a la izquierda y las otras 5 a la derecha.
    final indices = <int>[
      for (int i = 0; i < orden.length; i++)
        if ((i < 5) == izquierda) i
    ];

    return Positioned(
      left: _sx10(izquierda ? 8 : 810),
      top: _sy10(114),
      width: _sx10(182),
      height: _sy10(415),
      child: DragTarget<String>(
        onWillAcceptWithDetails: (_) => !juegoVerificado,
        onAcceptWithDetails: (d) => devolverABanca(d.data),
        builder: (context, candidatos, rechazados) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0x8853361F),
              borderRadius: BorderRadius.circular(_fs(16)),
              border: Border.all(color: const Color(0xFFC49A61), width: 2 + _k),
            ),
            child: Stack(
              children: [
                for (final i in indices)
                  if (!colocadas.containsValue(orden[i]))
                    Positioned(
                      left: _sx10(6),
                      top: _sy10(6 + (i % 5) * 87.0),
                      child: fichaArrastrable(
                        parte(orden[i]),
                        ancho: _sx10(170),
                        alto: _sy10(58),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Botón hecho con una imagen.
  Widget crearBoton({
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
          // ===== FONDO (llena toda la pantalla) =====
          Image.asset(imagenFondo, fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.10)),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, c) {
                _w = c.maxWidth;
                _h = c.maxHeight;
                _sx = _w / anchoJuego;
                _sy = _h / altoJuego;
                _k = _sx < _sy ? _sx : _sy;

                return Stack(
                  children: [
                    // ===== BORDE INFERIOR =====
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: _sy10(36),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: const AssetImage(imagenBorde),
                            fit: BoxFit.fitHeight,
                            repeat: ImageRepeat.repeatX,
                          ),
                        ),
                      ),
                    ),

                    // ===== NIÑA =====
                    Positioned(
                      left: _sx10(ninaIzq),
                      top: _sy10(ninaArriba),
                      width: _sx10(ninaAncho),
                      height: _sy10(ninaAlto),
                      child: Image.asset(imagenNina, fit: BoxFit.contain),
                    ),

                    // ===== LÍNEAS Y PUNTOS =====
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: PintorLineas(
                            partes: partes,
                            rectCuadro: rectCuadro,
                            puntoCuerpo: puntoCuerpo,
                            juegoVerificado: juegoVerificado,
                            esCorrecta: esCorrecta,
                            escala: _k,
                          ),
                        ),
                      ),
                    ),

                    // ===== CUADROS VACÍOS =====
                    ...partes.map(crearCuadro),

                    // ===== BANCA DE PALABRAS (a los lados) =====
                    crearColumna(true),
                    crearColumna(false),

                    // ===== ENCABEZADO =====
                    Positioned(
                      left: _sx10(20),
                      top: _sy10(12),
                      width: _sx10(960),
                      height: _sy10(80),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: _fs(12), vertical: _fs(8)),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFE0BE86),
                              Color(0xFFC9A56F),
                              Color(0xFFB0874B),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(_fs(20)),
                          border: Border.all(
                            color: const Color(0xFF7A5327),
                            width: 2 + _k * 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black45,
                                blurRadius: 12,
                                offset: Offset(0, 5)),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Título
                            Expanded(
                              flex: 4,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: _fs(14), vertical: _fs(4)),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B2A1A),
                                  borderRadius:
                                      BorderRadius.circular(_fs(16)),
                                  border: Border.all(
                                      color: const Color(0xFFFFD98A),
                                      width: 1.5),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black38,
                                        blurRadius: 6,
                                        offset: Offset(0, 3)),
                                  ],
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Partes del cuerpo en maya',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: _fs(28),
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFFFE3A2),
                                      letterSpacing: 0.5,
                                      height: 1.05,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: _fs(14)),
                            // Instrucción
                            Expanded(
                              flex: 4,
                              child: Row(
                                children: [
                                  Icon(Icons.touch_app_rounded,
                                      color: const Color(0xFF5B3A1E),
                                      size: _fs(34)),
                                  SizedBox(width: _fs(8)),
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Arrastra cada palabra al cuadro\nde la parte del cuerpo que corresponde.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: _fs(19),
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF3D2918),
                                          height: 1.15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: _fs(14)),
                            // Puntos
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: _fs(18), vertical: _fs(10)),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4A3520),
                                    Color(0xFF2E2013),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(_fs(16)),
                                border: Border.all(
                                    color: const Color(0xFFFFD98A),
                                    width: 1.5),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black38,
                                      blurRadius: 6,
                                      offset: Offset(0, 3)),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star_rounded,
                                      color: Colors.amber, size: _fs(32)),
                                  SizedBox(width: _fs(8)),
                                  Text(
                                    'Puntos: $puntos / 100',
                                    style: TextStyle(
                                      fontSize: _fs(19),
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFFFE3A2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ===== BOTÓN INICIO =====
                    crearBoton(
                      imagen: imagenInicio,
                      accion: () {
                        reiniciarJuego();
                        Navigator.pop(context);
                      },
                      izquierda: 8,
                      arriba: 545,
                      ancho: 182,
                      alto: 60,
                    ),

                    // ===== BOTÓN VERIFICAR =====
                    crearBoton(
                      imagen: imagenVerificar,
                      accion: verificarJuego,
                      izquierda: 810,
                      arriba: 545,
                      ancho: 182,
                      alto: 60,
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

// =====================================================
// PINTOR DE LÍNEAS
// =====================================================

class PintorLineas extends CustomPainter {
  final List<ParteCuerpo> partes;
  final Rect Function(ParteCuerpo) rectCuadro;
  final Offset Function(ParteCuerpo) puntoCuerpo;
  final bool juegoVerificado;
  final bool Function(String) esCorrecta;
  final double escala;

  PintorLineas({
    required this.partes,
    required this.rectCuadro,
    required this.puntoCuerpo,
    required this.juegoVerificado,
    required this.esCorrecta,
    this.escala = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in partes) {
      final r = rectCuadro(p);
      final inicio = Offset(p.izquierda ? r.right : r.left, r.center.dy);
      final fin = puntoCuerpo(p);

      Color color = const Color(0xFF5B3A1E);
      if (juegoVerificado) {
        color = esCorrecta(p.id) ? Colors.green.shade700 : Colors.red.shade700;
      }

      // Línea con contorno claro para que se vea sobre la selva.
      canvas.drawLine(
        inicio,
        fin,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 6 * escala
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        inicio,
        fin,
        Paint()
          ..color = color
          ..strokeWidth = 3 * escala
          ..strokeCap = StrokeCap.round,
      );

      // Punto sobre el cuerpo.
      canvas.drawCircle(fin, 9 * escala, Paint()..color = Colors.white);
      canvas.drawCircle(fin, 6 * escala, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant PintorLineas oldDelegate) => true;
}
