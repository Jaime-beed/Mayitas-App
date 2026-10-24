import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// =====================================================
// JUEGO: ¿CUÁNTOS HAY? (números del 1 al 10 en maya)
// Proyecto: Mayitas
//
// En cada ronda aparecen varios dibujos. El niño los cuenta y toca
// la opción correcta. Cada opción muestra:
//   - el número normal (3)
//   - el número maya con puntos y barras (• • •)
//   - su nombre en maya (Óox)
// Son 10 rondas; cada número del 1 al 10 sale una vez.
// =====================================================

class NumeroMaya {
  final int valor;
  final String maya;
  const NumeroMaya(this.valor, this.maya);
}

class JuegoNumeros extends StatefulWidget {
  const JuegoNumeros({super.key});

  @override
  State<JuegoNumeros> createState() => _JuegoNumerosState();
}

class _JuegoNumerosState extends State<JuegoNumeros> {
  // ---------- Configuración ----------

  static const String imagenFondo = 'assets/Fondos/FondoJuego.png';
  static const String imagenBorde = 'assets/Fondos/borde.png';

  // Números del 1 al 10 en maya.
  // Revisar la escritura con una fuente lingüística antes de publicar.
  static const List<NumeroMaya> numeros = [
    NumeroMaya(1, 'Jun'),
    NumeroMaya(2, "Ka'a"),
    NumeroMaya(3, 'Óox'),
    NumeroMaya(4, 'Kan'),
    NumeroMaya(5, "Jo'"),
    NumeroMaya(6, 'Wak'),
    NumeroMaya(7, 'Uk'),
    NumeroMaya(8, 'Waxak'),
    NumeroMaya(9, 'Bolon'),
    NumeroMaya(10, 'Lajun'),
  ];

  // Dibujos que se pueden contar (en cada ronda sale uno al azar).
  static const List<String> dibujos = [
    '🐢', '🍎', '⭐', '🐟', '🌻', '🐤', '🦋', '🍌', '🐸', '🌽', '🐝', '🌸',
  ];

  static const String instruccion = 'Cuenta los dibujos y toca el número.';

  // ---------- Estado ----------

  final Random _random = Random();
  List<int> _rondas = []; // orden de los números (1..10 revueltos)
  int _ronda = 0; // índice de la ronda actual
  List<int> _opciones = []; // 3 opciones de la ronda
  String _dibujo = '🐢';
  final Set<int> _descartadas = {}; // opciones incorrectas ya tocadas
  int? _acertada; // opción correcta tocada (para pintarla de verde)
  bool _bloqueado = false; // evita toques mientras cambia de ronda

  int _puntos = 0;
  int _errores = 0;

  String _mensaje = instruccion;
  Color _colorMensaje = const Color(0xFF3D2918);
  Timer? _timerRonda;
  Timer? _timerMensaje;

  int get _numeroActual => _rondas[_ronda];
  int get _totalRondas => _rondas.length;

  @override
  void initState() {
    super.initState();
    _prepararPartida();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _timerRonda?.cancel();
    _timerMensaje?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  // ---------- Lógica ----------

  void _prepararPartida() {
    _rondas = [for (final n in numeros) n.valor]..shuffle(_random);
    _ronda = 0;
    _puntos = 0;
    _errores = 0;
    _prepararRonda();
  }

  void _prepararRonda() {
    final n = _numeroActual;

    // Distractores cercanos (±3) para que el niño realmente cuente.
    final cercanos = [
      for (final x in numeros)
        if (x.valor != n && (x.valor - n).abs() <= 3) x.valor
    ]..shuffle(_random);

    _opciones = [n, ...cercanos.take(2)]..shuffle(_random);
    _dibujo = dibujos[_random.nextInt(dibujos.length)];
    _descartadas.clear();
    _acertada = null;
    _bloqueado = false;
    _mensaje = instruccion;
    _colorMensaje = const Color(0xFF3D2918);
  }

  void _reiniciar() {
    _timerRonda?.cancel();
    _timerMensaje?.cancel();
    setState(_prepararPartida);
  }

  NumeroMaya _datos(int valor) => numeros.firstWhere((x) => x.valor == valor);

  void _elegir(int valor) {
    if (_bloqueado || _descartadas.contains(valor)) return;

    if (valor == _numeroActual) {
      HapticFeedback.lightImpact();
      final maya = _datos(valor).maya;
      setState(() {
        _acertada = valor;
        _bloqueado = true;
        _puntos += _descartadas.isEmpty ? 10 : 5; // menos puntos si falló antes
      });
      _ponerMensaje(
        '¡Muy bien! Son $valor: $maya.',
        const Color(0xFF1B5E20),
        temporal: false,
      );

      _timerRonda?.cancel();
      _timerRonda = Timer(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        if (_ronda + 1 >= _totalRondas) {
          _mostrarResultado();
        } else {
          setState(() {
            _ronda++;
            _prepararRonda();
          });
        }
      });
    } else {
      HapticFeedback.mediumImpact();
      setState(() {
        _errores++;
        _descartadas.add(valor);
      });
      _ponerMensaje(
        '¡Casi! No son $valor. Cuenta otra vez.',
        const Color(0xFFB71C1C),
      );
    }
  }

  void _ponerMensaje(String texto, Color color, {bool temporal = true}) {
    _timerMensaje?.cancel();
    setState(() {
      _mensaje = texto;
      _colorMensaje = color;
    });
    if (!temporal) return;
    _timerMensaje = Timer(const Duration(milliseconds: 2500), () {
      if (!mounted || _bloqueado) return;
      setState(() {
        _mensaje = instruccion;
        _colorMensaje = const Color(0xFF3D2918);
      });
    });
  }

  int get _estrellas {
    if (_errores == 0) return 3;
    if (_errores <= 3) return 2;
    return 1;
  }

  void _mostrarResultado() {
    final estrellas = _estrellas;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contexto) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF7E0B0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            estrellas == 3 ? '¡Felicidades!' : '¡Muy bien!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF59371E),
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < 3; i++)
                    Icon(
                      i < estrellas
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: Colors.amber.shade700,
                      size: 48,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '¡Contaste del 1 al 10 en maya!\n'
                'Puntos: $_puntos   ·   Errores: $_errores',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, color: Color(0xFF3D2918)),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(contexto); // cierra el diálogo
                Navigator.pop(context); // regresa al menú
              },
              child: const Text('Salir'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2FA4F5),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(contexto);
                _reiniciar();
              },
              child: const Text('Jugar otra vez'),
            ),
          ],
        );
      },
    );
  }

  // ---------- Widgets ----------

  // Encabezado: regresar, título, mensaje y puntos.
  Widget _encabezado(double alto) {
    return Container(
      height: alto,
      padding: EdgeInsets.symmetric(horizontal: alto * 0.15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE0BE86), Color(0xFFC9A56F), Color(0xFFB0874B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(alto * 0.25),
        border: Border.all(color: const Color(0xFF7A5327), width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            customBorder: const CircleBorder(),
            child: Container(
              width: alto * 0.7,
              height: alto * 0.7,
              decoration: BoxDecoration(
                color: const Color(0xFF3B2A1A),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFD98A), width: 1.5),
              ),
              child: Icon(Icons.arrow_back_rounded,
                  color: const Color(0xFFFFE3A2), size: alto * 0.42),
            ),
          ),
          SizedBox(width: alto * 0.15),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: alto * 0.2, vertical: alto * 0.08),
            decoration: BoxDecoration(
              color: const Color(0xFF3B2A1A),
              borderRadius: BorderRadius.circular(alto * 0.2),
              border: Border.all(color: const Color(0xFFFFD98A), width: 1.5),
            ),
            child: Text(
              '¿Cuántos hay?',
              style: TextStyle(
                fontSize: alto * 0.32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFFE3A2),
              ),
            ),
          ),
          SizedBox(width: alto * 0.15),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                _mensaje,
                key: ValueKey(_mensaje),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: alto * 0.24,
                  fontWeight: FontWeight.w700,
                  color: _colorMensaje,
                  height: 1.15,
                ),
              ),
            ),
          ),
          SizedBox(width: alto * 0.15),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: alto * 0.2, vertical: alto * 0.08),
            decoration: BoxDecoration(
              color: const Color(0xFF3B2A1A),
              borderRadius: BorderRadius.circular(alto * 0.2),
              border: Border.all(color: const Color(0xFFFFD98A), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded,
                    color: Colors.amber, size: alto * 0.4),
                SizedBox(width: alto * 0.06),
                Text(
                  '$_puntos',
                  style: TextStyle(
                    fontSize: alto * 0.3,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFE3A2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta grande con los dibujos a contar.
  Widget _tarjetaDibujos() {
    final n = _numeroActual;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF8A6238), width: 4),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final ancho = c.maxWidth;
          final alto = c.maxHeight;

          // Se acomodan en filas de 5 para que sea fácil contar
          // (igual que en el sistema maya, donde 5 es una barra).
          final filas = (n / 5).ceil();
          final lado = min(ancho / (5 * 1.3), (alto * 0.78) / (filas * 1.3));

          return Column(
            children: [
              // Ronda actual
              Padding(
                padding: EdgeInsets.only(top: alto * 0.04),
                child: Text(
                  'Ronda ${_ronda + 1} de $_totalRondas',
                  style: TextStyle(
                    fontSize: alto * 0.07,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8A6238),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Column(
                      key: ValueKey('ronda$_ronda'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int f = 0; f < filas; f++)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (int i = 0; i < min(5, n - f * 5); i++)
                                SizedBox(
                                  width: lado * 1.25,
                                  height: lado * 1.25,
                                  child: Center(
                                    child: SizedBox(
                                      width: lado,
                                      height: lado,
                                      child: FittedBox(
                                        child: Text(
                                          _dibujo,
                                          style:
                                              const TextStyle(fontSize: 48),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
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

  // Botón de opción: número + número maya (puntos y barras) + nombre.
  Widget _opcion(int valor, double alto) {
    final datos = _datos(valor);
    final acertada = _acertada == valor;
    final descartada = _descartadas.contains(valor);

    Color fondo = const Color(0xFFFFF8E7);
    Color borde = const Color(0xFF8A6238);
    if (acertada) {
      fondo = const Color(0xFFD7F5D3);
      borde = Colors.green.shade600;
    } else if (descartada) {
      fondo = const Color(0xFFFFD6D6);
      borde = Colors.red.shade400;
    }

    const colorNumero = Color(0xFF3D2918);

    return GestureDetector(
      onTap: () => _elegir(valor),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: descartada ? 0.5 : 1,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: acertada ? 1.06 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: alto * 0.15),
            decoration: BoxDecoration(
              color: fondo,
              borderRadius: BorderRadius.circular(alto * 0.25),
              border: Border.all(color: borde, width: acertada ? 5 : 3),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black38, blurRadius: 5, offset: Offset(0, 3)),
              ],
            ),
            child: Row(
              children: [
                // Número normal
                SizedBox(
                  width: alto * 0.75,
                  child: FittedBox(
                    child: Text(
                      '$valor',
                      style: const TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2FA4F5),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: alto * 0.1),
                // Número maya
                SizedBox(
                  width: alto * 0.9,
                  height: alto * 0.7,
                  child: CustomPaint(
                    painter: PintorNumeroMaya(valor, color: colorNumero),
                  ),
                ),
                SizedBox(width: alto * 0.15),
                // Nombre en maya
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      datos.maya,
                      style: TextStyle(
                        fontSize: alto * 0.4,
                        fontWeight: FontWeight.bold,
                        color: colorNumero,
                      ),
                    ),
                  ),
                ),
                if (acertada)
                  Icon(Icons.check_circle_rounded,
                      color: Colors.green.shade600, size: alto * 0.45),
                if (descartada)
                  Icon(Icons.cancel_rounded,
                      color: Colors.red.shade400, size: alto * 0.45),
              ],
            ),
          ),
        ),
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
          Image.asset(imagenFondo, fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.10)),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 28,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imagenBorde),
                  fit: BoxFit.fitHeight,
                  repeat: ImageRepeat.repeatX,
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final h = c.maxHeight;
                final altoEncabezado = h * 0.16;
                final altoZona = h - altoEncabezado - h * 0.1;
                final altoOpcion = (altoZona - h * 0.06) / 3;

                return Padding(
                  padding: EdgeInsets.fromLTRB(
                      w * 0.02, h * 0.02, w * 0.02, h * 0.06),
                  child: Column(
                    children: [
                      _encabezado(altoEncabezado),
                      SizedBox(height: h * 0.02),
                      SizedBox(
                        height: altoZona,
                        child: Row(
                          children: [
                            Expanded(flex: 3, child: _tarjetaDibujos()),
                            SizedBox(width: w * 0.025),
                            Expanded(
                              flex: 2,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  for (final v in _opciones)
                                    SizedBox(
                                      height: altoOpcion,
                                      child: _opcion(v, altoOpcion),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
// NÚMERO MAYA CON PUNTOS Y BARRAS
// Punto = 1, barra = 5. Las barras van abajo y los puntos arriba.
// Ejemplo: 7 = una barra y dos puntos encima.
// =====================================================

class PintorNumeroMaya extends CustomPainter {
  final int valor;
  final Color color;

  PintorNumeroMaya(this.valor, {this.color = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    final barras = valor ~/ 5;
    final puntos = valor % 5;
    final pintura = Paint()..color = color;

    final altoBarra = size.height * 0.17;
    final espacio = size.height * 0.08;
    final radio = size.height * 0.1;
    final anchoBarra = size.width * 0.92;

    // Alto total del dibujo, para centrarlo verticalmente.
    double total = 0;
    if (puntos > 0) total += radio * 2;
    if (puntos > 0 && barras > 0) total += espacio;
    if (barras > 0) total += barras * altoBarra + (barras - 1) * espacio;

    double y = (size.height - total) / 2;

    // Puntos (arriba)
    if (puntos > 0) {
      final separacion = radio * 2.6;
      final anchoPuntos = (puntos - 1) * separacion;
      final x0 = (size.width - anchoPuntos) / 2;
      for (int i = 0; i < puntos; i++) {
        canvas.drawCircle(Offset(x0 + i * separacion, y + radio), radio, pintura);
      }
      y += radio * 2 + (barras > 0 ? espacio : 0);
    }

    // Barras (abajo)
    for (int i = 0; i < barras; i++) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH((size.width - anchoBarra) / 2, y, anchoBarra, altoBarra),
        Radius.circular(altoBarra / 2),
      );
      canvas.drawRRect(rect, pintura);
      y += altoBarra + espacio;
    }
  }

  @override
  bool shouldRepaint(covariant PintorNumeroMaya old) =>
      old.valor != valor || old.color != color;
}
