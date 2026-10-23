import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio global de audio: MÚSICA de fondo (una pista a la vez, en bucle)
/// y EFECTOS de sonido (cortos, pueden sonar varios a la vez).
///
/// Cada categoría tiene su propio volumen y su propio silencio, y todo se
/// guarda en el dispositivo. Como extiende [ChangeNotifier], cualquier widget
/// puede escucharlo (por ejemplo el diálogo de ajustes) y se redibuja solo.
///
/// ---------------------------------------------------------------------
/// USO RÁPIDO (desde cualquier parte de la app)
/// ---------------------------------------------------------------------
///   // 1) UNA sola vez, en main(), antes de runApp():
///   WidgetsFlutterBinding.ensureInitialized();
///   await AudioService.instance.iniciar();
///
///   // 2) Música (la ruta es relativa a la carpeta assets/):
///   AudioService.instance.reproducirMusica('Musica/menu.mp3');
///
///   // 3) Efecto corto:
///   AudioService.instance.reproducirEfecto('Sonidos/acierto.mp3');
///
///   // 4) Volumen / silencio:
///   AudioService.instance.setVolumenMusica(0.3);   // de 0.0 a 1.0
///   AudioService.instance.setMusicaSilenciada(true);
class AudioService extends ChangeNotifier with WidgetsBindingObserver {
  AudioService._();
  static final AudioService instance = AudioService._();

  // Claves con las que se guarda en el dispositivo
  static const _kVolMusica = 'audio_vol_musica';
  static const _kMuteMusica = 'audio_mute_musica';
  static const _kVolEfectos = 'audio_vol_efectos';
  static const _kMuteEfectos = 'audio_mute_efectos';

  final AudioPlayer _musica = AudioPlayer();

  double _volumenMusica = 0.5;
  bool _musicaSilenciada = false;
  double _volumenEfectos = 0.8;
  bool _efectosSilenciados = false;

  String? _pistaActual; // Ruta de la pista que está cargada
  bool _pausadaPorApp = false; // ¿Se pausó porque la app pasó a segundo plano?
  Future<void>? _inicio; // Evita iniciar dos veces aunque lo llamen en paralelo

  // ---------------- Lectura del estado (para la interfaz) ----------------
  double get volumenMusica => _volumenMusica;
  bool get musicaSilenciada => _musicaSilenciada;
  double get volumenEfectos => _volumenEfectos;
  bool get efectosSilenciados => _efectosSilenciados;
  String? get pistaActual => _pistaActual;
  bool get musicaSonando => _musica.state == PlayerState.playing;

  // Volumen real que se le manda al reproductor (0 si está silenciado)
  double get _volMusicaEfectivo => _musicaSilenciada ? 0 : _volumenMusica;

  // ---------------- Inicio ----------------
  /// Carga lo guardado. Llamar una vez en main(), antes de runApp().
  /// Es seguro llamarlo más veces: solo se ejecuta la primera.
  Future<void> iniciar() => _inicio ??= _iniciarInterno();

  Future<void> _iniciarInterno() async {
    final prefs = await SharedPreferences.getInstance();
    _volumenMusica = prefs.getDouble(_kVolMusica) ?? 0.5;
    _musicaSilenciada = prefs.getBool(_kMuteMusica) ?? false;
    _volumenEfectos = prefs.getDouble(_kVolEfectos) ?? 0.8;
    _efectosSilenciados = prefs.getBool(_kMuteEfectos) ?? false;

    await _musica.setReleaseMode(ReleaseMode.loop);
    await _musica.setVolume(_volMusicaEfectivo);

    // Pausa la música cuando la app se minimiza y la retoma al volver
    WidgetsBinding.instance.addObserver(this);
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (musicaSonando) {
        _pausadaPorApp = true;
        _musica.pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_pausadaPorApp) {
        _pausadaPorApp = false;
        _musica.resume();
      }
    }
  }

  // ---------------- Música ----------------
  /// Reproduce una pista de música. [ruta] es relativa a assets/
  /// (ejemplo: 'Musica/menu.mp3').
  ///
  /// - Si esa misma pista ya está sonando, no hace nada (no se reinicia).
  /// - Si suena otra, la reemplaza.
  Future<void> reproducirMusica(String ruta, {bool repetir = true}) async {
    await iniciar();

    if (_pistaActual == ruta) {
      if (musicaSonando) return;
      if (_musica.state == PlayerState.paused) {
        await _musica.resume();
        notifyListeners();
        return;
      }
    }

    try {
      await _musica
          .setReleaseMode(repetir ? ReleaseMode.loop : ReleaseMode.stop);
      await _musica.setVolume(_volMusicaEfectivo);
      await _musica.play(AssetSource(ruta));
      _pistaActual = ruta;
      _pausadaPorApp = false;
    } catch (e) {
      debugPrint('AudioService: no se pudo reproducir "$ruta": $e');
    }
    notifyListeners();
  }

  Future<void> pausarMusica() async {
    await _musica.pause();
    notifyListeners();
  }

  Future<void> reanudarMusica() async {
    if (_pistaActual == null) return;
    await _musica.resume();
    notifyListeners();
  }

  Future<void> detenerMusica() async {
    await _musica.stop();
    _pistaActual = null;
    notifyListeners();
  }

  // ---------------- Efectos ----------------
  /// Reproduce un sonido corto. Pueden sonar varios a la vez.
  /// No hace nada si los efectos están silenciados.
  Future<void> reproducirEfecto(String ruta) async {
    await iniciar();
    if (_efectosSilenciados || _volumenEfectos <= 0) return;

    final player = AudioPlayer();
    // Cuando termina, libera el reproductor para no gastar memoria
    player.onPlayerComplete.listen((_) => player.dispose());
    try {
      await player.play(AssetSource(ruta), volume: _volumenEfectos);
    } catch (e) {
      debugPrint('AudioService: no se pudo reproducir "$ruta": $e');
      await player.dispose();
    }
  }

  // ---------------- Volumen y silencio ----------------
  Future<void> setVolumenMusica(double v) async {
    _volumenMusica = v.clamp(0.0, 1.0).toDouble();
    notifyListeners();
    await _musica.setVolume(_volMusicaEfectivo);
    await _guardar();
  }

  Future<void> setMusicaSilenciada(bool silenciar) async {
    _musicaSilenciada = silenciar;
    notifyListeners();
    await _musica.setVolume(_volMusicaEfectivo);
    await _guardar();
  }

  Future<void> setVolumenEfectos(double v) async {
    _volumenEfectos = v.clamp(0.0, 1.0).toDouble();
    notifyListeners();
    await _guardar();
  }

  Future<void> setEfectosSilenciados(bool silenciar) async {
    _efectosSilenciados = silenciar;
    notifyListeners();
    await _guardar();
  }

  Future<void> _guardar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kVolMusica, _volumenMusica);
    await prefs.setBool(_kMuteMusica, _musicaSilenciada);
    await prefs.setDouble(_kVolEfectos, _volumenEfectos);
    await prefs.setBool(_kMuteEfectos, _efectosSilenciados);
  }
}