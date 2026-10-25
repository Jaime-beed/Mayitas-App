import 'dart:async';

import 'package:flutter/material.dart';

import '../estilo/estilos_mi_info.dart';
import '../estilo/paleta_mi_info.dart';

/// Panel superior de "Mi Info": flecha de regreso, la hora del teléfono,
/// icono de notificaciones e icono de perfil con lazo rosa.
///
/// El fondo es jade tallado y lleva una greca maya grabada como cenefa.
class BarraSuperiorMiInfo extends StatefulWidget implements PreferredSizeWidget {
  const BarraSuperiorMiInfo({
    super.key,
    this.hora,
    this.onRegresar,
    this.onActivity,
    required this.avatar,
  });

  /// Hora escrita a mano. Si es null (lo normal) se usa la hora real del
  /// teléfono, que se va actualizando sola cada minuto.
  final String? hora;

  final VoidCallback? onRegresar;
  final VoidCallback? onActivity;

  /// Icono de perfil del usuario (con su lazo rosa).
  final Widget avatar;

  @override
  Size get preferredSize => const Size.fromHeight(78);

  @override
  State<BarraSuperiorMiInfo> createState() => _BarraSuperiorMiInfoState();
}

class _BarraSuperiorMiInfoState extends State<BarraSuperiorMiInfo> {
  /// Hora que se está mostrando.
  TimeOfDay _ahora = TimeOfDay.now();

  /// Temporizador que despierta a la barra cuando cambia el minuto.
  Timer? _reloj;

  @override
  void initState() {
    super.initState();
    _programarReloj();
  }

  @override
  void dispose() {
    _reloj?.cancel();
    super.dispose();
  }

  /// Espera a que cambie el minuto y, a partir de ahí, revisa cada minuto.
  void _programarReloj() {
    _reloj?.cancel();

    final DateTime ahora = DateTime.now();
    // Lo que falta para el siguiente minuto exacto.
    final Duration espera = Duration(
      seconds: 59 - ahora.second,
      milliseconds: 1000 - ahora.millisecond,
    );

    _reloj = Timer(espera, () {
      _actualizarHora();
      _reloj = Timer.periodic(
        const Duration(minutes: 1),
        (_) => _actualizarHora(),
      );
    });
  }

  void _actualizarHora() {
    if (!mounted) return;
    setState(() => _ahora = TimeOfDay.now());
  }

  /// Texto de la hora: el escrito a mano o el del teléfono.
  String _textoHora(BuildContext context) {
    final String? manual = widget.hora;
    if (manual != null) return manual;

    return MaterialLocalizations.of(context).formatTimeOfDay(
      _ahora,
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [PaletaMiInfo.jadeMedio, PaletaMiInfo.jadeOscuro],
        ),
        boxShadow: [
          BoxShadow(
            color: PaletaMiInfo.jadeNoche.withValues(alpha: 0.7),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CustomPaint(
        painter: const _PintorBarraSuperior(),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 12, 12),
            child: Row(
              children: [
                _BotonPiedra(
                  icono: Icons.arrow_back_ios_new,
                  onTap: widget.onRegresar,
                  tooltip: 'Regresar',
                ),
                const SizedBox(width: 8),
                // Hora del teléfono grabada en una plaquita de piedra.
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: PaletaMiInfo.jadeNoche.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: PaletaMiInfo.piedra.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(_textoHora(context), style: EstilosMiInfo.hora),
                ),
                const Spacer(),

                // Icono de notificaciones.
                _BotonPiedra(
                  icono: Icons.notifications_none,
                  onTap: widget.onActivity,
                  tooltip: 'Activity',
                  insignia: true,
                ),
                const SizedBox(width: 10),

                // Icono de perfil del usuario.
                widget.avatar,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón redondo tallado en piedra.
class _BotonPiedra extends StatelessWidget {
  const _BotonPiedra({
    required this.icono,
    this.onTap,
    this.tooltip,
    this.insignia = false,
  });

  final IconData icono;
  final VoidCallback? onTap;
  final String? tooltip;

  /// Punto dorado de "hay novedades".
  final bool insignia;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                PaletaMiInfo.piedraBrillo,
                PaletaMiInfo.piedra,
                PaletaMiInfo.piedraOscura,
              ],
            ),
            border: Border.all(
              color: PaletaMiInfo.oro.withValues(alpha: 0.75),
              width: 1.6,
            ),
            boxShadow: [
              BoxShadow(
                color: PaletaMiInfo.jadeNoche.withValues(alpha: 0.6),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icono, size: 19, color: PaletaMiInfo.jadeNoche),
              if (insignia)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: PaletaMiInfo.amarilloSol,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PintorBarraSuperior extends CustomPainter {
  const _PintorBarraSuperior();

  @override
  void paint(Canvas canvas, Size size) {
    // Sin greca decorativa.
  }

  @override
  bool shouldRepaint(covariant _PintorBarraSuperior anterior) => false;
}
