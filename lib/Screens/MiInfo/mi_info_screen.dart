// ============================================================
//  MI INFO  →  lib/Screens/MiInfo/mi_info_screen.dart
//
//  Pantalla con la ficha del usuario: foto, nombre, experiencia,
//  edad y logros, con el estilo maya del diseño (jade acolchado,
//  relieves de piedra tallada y metal con filigrana).
//
//  CÓMO USARLA:
//    • Leyendo Firebase (usuario con sesión):
//        Navigator.push(context,
//          MaterialPageRoute(builder: (_) => const MiInfoScreen()));
//    • Con datos por parámetro (o mezclando ambos):
//        const MiInfoScreen(
//          nombre: 'Pepito', experiencia: 120, edad: 8, logros: 5,
//        );
//
//  ORDEN DE PRIORIDAD DE CADA DATO:
//    1) Parámetro del widget.
//    2) Valor del usuario en Firebase (usuarios/<uid>).
//    3) Valor de ejemplo del diseño.
//
//  ESTRUCTURA DEL MÓDULO:
//    arte/      → ilustraciones mayas dibujadas con Canvas
//    estilo/    → paleta, materiales, textos y estilos de letra
//    modelo/    → clases de datos
//    servicio/  → lectura y guardado en Firebase
//    widgets/   → piezas de interfaz reutilizables
//
//  BARRA DE NAVEGACIÓN: vive en la pantalla de Inicio (pantalla_principal.dart)
//  y tiene cuatro secciones: Inicio, Juegos, Configuración y Mi Perfil.
//  "Mi Perfil" abre esta pantalla, que a propósito NO tiene barra: se ve
//  nada más la ficha del usuario.
//
//  EDITAR EL PERFIL: el botón "Editar perfil" (en el panel del avatar) abre
//  pantalla_editar_perfil_mi_info.dart, donde el niño cambia nombre,
//  apellido, edad y avatar sin perder su experiencia.
// ============================================================

import 'package:flutter/material.dart';

import 'estilo/estilos_mi_info.dart';
import 'estilo/imagenes_mi_info.dart';
import 'estilo/paleta_mi_info.dart';
import 'estilo/textos_mi_info.dart';
import 'modelo/datos_perfil.dart';
import 'modelo/perfil_firebase.dart';
import 'pantalla_editar_perfil_mi_info.dart';
import 'servicio/perfil_servicio.dart';
import 'widgets/aviso_mi_info.dart';
import 'widgets/avatar_usuario.dart';
import 'widgets/barra_superior_mi_info.dart';
import 'widgets/medallon_imagen.dart';
import 'widgets/panel_avatar.dart';
import 'widgets/panel_dato.dart';
import 'widgets/titulo_mi_info.dart';

/// Datos de ejemplo del diseño: se usan cuando no llega un parámetro
/// ni existe el dato en Firebase.
const DatosPerfil _datosDeEjemplo = DatosPerfil(
  nombre: 'Pepito',
  experiencia: 120,
  edad: 8,
  logros: 5,
);

// ============================================================
// WIDGET PRINCIPAL
// ============================================================
class MiInfoScreen extends StatefulWidget {
  const MiInfoScreen({
    super.key,
    this.nombre,
    this.experiencia,
    this.edad,
    this.logros,
    this.avatarUrl,
  });

  /// Nombre completo. Si es null se lee de Firebase ('nombre' + 'apellido').
  final String? nombre;

  /// Puntos de experiencia. Si es null se lee de Firebase ('experiencia').
  final int? experiencia;

  /// Edad. Si es null se lee de Firebase ('edad').
  final int? edad;

  /// Cantidad de logros. Si es null se lee de Firebase ('logros').
  final int? logros;

  /// Foto de perfil. Si es null se lee de Firebase ('avatar_url').
  final String? avatarUrl;

  @override
  State<MiInfoScreen> createState() => _MiInfoScreenState();
}

// ============================================================
// ESTADO
// ============================================================
class _MiInfoScreenState extends State<MiInfoScreen> {
  /// Datos que se están mostrando en pantalla.
  DatosPerfil _datos = _datosDeEjemplo;

  /// ¿Todavía se están leyendo los datos de Firebase?
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    // Los parámetros se aplican de inmediato (antes del primer dibujo)
    _datos = _combinar(_datosDeEjemplo, null);
    _cargarPerfil();
  }

  // ------------------------------------------------------------
  // DATOS
  // ------------------------------------------------------------
  /// ¿Ya nos dieron absolutamente todo por parámetro?
  bool get _todoPorParametro =>
      widget.nombre != null &&
      widget.experiencia != null &&
      widget.edad != null &&
      widget.logros != null &&
      widget.avatarUrl != null;

  /// Mezcla los datos aplicando el orden de prioridad:
  /// parámetro → Firebase ([remoto]) → valor de [base].
  DatosPerfil _combinar(DatosPerfil base, PerfilFirebase? remoto) {
    return DatosPerfil(
      nombre: widget.nombre ?? remoto?.nombre ?? base.nombre,
      experiencia: widget.experiencia ?? remoto?.experiencia ?? base.experiencia,
      edad: widget.edad ?? remoto?.edad ?? base.edad,
      logros: widget.logros ?? remoto?.logros ?? base.logros,
      avatarUrl: widget.avatarUrl ?? remoto?.avatarUrl ?? base.avatarUrl,
    );
  }

  Future<void> _cargarPerfil({bool forzar = false}) async {
    // Si ya tenemos todo por parámetro no hace falta consultar la base
    if (!forzar && _todoPorParametro) {
      if (mounted) setState(() => _cargando = false);
      return;
    }

    try {
      final PerfilFirebase? remoto = await PerfilServicio.leerPerfilActual();
      if (!mounted) return;

      setState(() {
        _datos = _combinar(_datosDeEjemplo, remoto);
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _cargando = false);
    }
  }

  // ------------------------------------------------------------
  // BOTONES
  // ------------------------------------------------------------
  /// Abre la pantalla para que el niño o la niña edite su perfil.
  /// Al volver, si guardó cambios, se relee el perfil.
  Future<void> _abrirEdicion() async {
    final bool? guardado = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => PantallaEditarPerfilMiInfo(
          nombre: _datos.nombre,
          edad: _datos.edad,
          avatarUrl: _datos.avatarUrl,
        ),
      ),
    );

    if (!mounted) return;
    if (guardado == true) {
      await _cargarPerfil(forzar: true);
    }
  }

  /// Aviso flotante para los botones que todavía no llevan a otra pantalla.
  void _pendiente(String texto) {
    if (!mounted) return;
    mostrarAvisoMiInfo(context, TextosMiInfo.enConstruccion(texto));
  }

  // ------------------------------------------------------------
  // INTERFAZ
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaMiInfo.jadeNoche,
      appBar: BarraSuperiorMiInfo(
        onRegresar: () => Navigator.of(context).maybePop(),
        onActivity: () => _pendiente('Activity'),
        avatar: AvatarUsuario(tamano: 38, url: _datos.avatarUrl, conLazo: true),
      ),
      body: Stack(
        children: [
          // CAPA 1: fondo
          Positioned.fill(
            child: Image.asset(
              ImagenesMiInfo.fondo,
              fit: BoxFit.cover,
            ),
          ),

          // CAPA 2: contenido
          Column(
            children: [
              // Línea fina de carga mientras se leen los datos
              if (_cargando)
                const SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: Colors.transparent,
                    color: PaletaMiInfo.oro,
                  ),
                ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const TituloMiInfo(),
                      const SizedBox(height: 14),
                      PanelAvatar(
                        url: _datos.avatarUrl,
                        onEditar: _abrirEdicion,
                      ),
                      PanelDato(
                        medallon: const MedallonImagen(
                          archivo: ImagenesMiInfo.perfil,
                        ),
                        titulo: TextosMiInfo.nombre,
                        valor: Text(_datos.nombre, style: EstilosMiInfo.valor),
                      ),
                      PanelDato(
                        medallon: const MedallonImagen(
                          archivo: ImagenesMiInfo.xp,
                        ),
                        titulo: TextosMiInfo.experiencia,
                        valor: _valorExperiencia(),
                      ),
                      PanelDato(
                        medallon: const MedallonImagen(
                          archivo: ImagenesMiInfo.anios,
                        ),
                        titulo: TextosMiInfo.edad,
                        valor: Text('${_datos.edad}', style: EstilosMiInfo.valor),
                      ),
                      PanelDato(
                        medallon: const MedallonImagen(
                          archivo: ImagenesMiInfo.logros,
                        ),
                        titulo: TextosMiInfo.logros,
                        valor: _valorLogros(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Valor de "Experiencia": solo el valor.
  Widget _valorExperiencia() {
    return Text('${_datos.experiencia} XP', style: EstilosMiInfo.valor);
  }

  // Valor de "Logros": cantidad.
  Widget _valorLogros() {
    return Row(
      children: [
        Text('${_datos.logros}', style: EstilosMiInfo.valor),
      ],
    );
  }
}
