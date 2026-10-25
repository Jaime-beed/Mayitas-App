import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../estilo/estilos_mi_info.dart';
import '../estilo/paleta_mi_info.dart';
import '../estilo/textos_mi_info.dart';

/// Las cuatro secciones de la barra de navegación.
enum SeccionMiInfo { inicio, juegos, configuracion, miPerfil }

/// Barra de navegación inferior de metal grabado en relieve, con un patrón
/// de filigrana maya y esquinas superiores redondeadas.
///
/// Vive en la pantalla de Inicio y tiene cuatro secciones: Inicio, Juegos,
/// Configuración y Mi Perfil. La sección activa ([seleccion]) se marca con
/// una placa de jade; en "Mi Perfil" esa placa lleva el avatar del usuario.
class BarraInferiorMiInfo extends StatelessWidget {
  const BarraInferiorMiInfo({
    super.key,
    this.seleccion = SeccionMiInfo.inicio,
    this.avatar,
    this.onSeccion,
  });

  /// Sección que está activa.
  final SeccionMiInfo seleccion;

  /// Avatar del usuario (para la sección "Mi Perfil").
  final Widget? avatar;

  /// Avisa cuando tocan otra sección.
  final ValueChanged<SeccionMiInfo>? onSeccion;

  @override
  Widget build(BuildContext context) {
    // Hueco del gesto/nav del sistema para que el metal llegue al borde.
    final double safeBottom = MediaQuery.of(context).viewPadding.bottom;

    const List<_Seccion> secciones = [
      _Seccion(SeccionMiInfo.inicio, Icons.home_rounded, TextosMiInfo.inicio),
      _Seccion(
        SeccionMiInfo.juegos,
        Icons.sports_esports_rounded,
        TextosMiInfo.juegos,
      ),
      _Seccion(
        SeccionMiInfo.configuracion,
        Icons.settings_rounded,
        TextosMiInfo.configuracion,
      ),
      _Seccion(
        SeccionMiInfo.miPerfil,
        Icons.person_rounded,
        TextosMiInfo.miPerfil,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(10, 12, 10, 12 + safeBottom),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PaletaMiInfo.oroClaro,
            PaletaMiInfo.oro,
            PaletaMiInfo.oroOscuro,
          ],
          stops: [0.0, 0.45, 1.0],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 16,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: CustomPaint(
        painter: const _PintorFiligrana(),
        child: Row(
          children: [
            for (final _Seccion seccion in secciones)
              Expanded(
                // Solo "Mi Perfil" (la que lleva el avatar) ocupa el doble,
                // para que el nombre y la cara quepan bien.
                flex: seccion.seccion == seleccion && avatar != null ? 2 : 1,
                child: _Pestana(
                  icono: seccion.icono,
                  texto: seccion.titulo,
                  avatar: seccion.seccion == SeccionMiInfo.miPerfil
                      ? avatar
                      : null,
                  activa: seccion.seccion == seleccion,
                  onTap: () => onSeccion?.call(seccion.seccion),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Una sección de la barra (icono + nombre).
class _Seccion {
  const _Seccion(this.seccion, this.icono, this.titulo);

  final SeccionMiInfo seccion;
  final IconData icono;
  final String titulo;
}

/// Pestaña de la barra: se ve normal o como placa de jade si está activa.
class _Pestana extends StatelessWidget {
  const _Pestana({
    required this.icono,
    required this.texto,
    required this.activa,
    this.avatar,
    this.onTap,
  });

  final IconData icono;
  final String texto;
  final bool activa;

  /// Si viene, se dibuja en lugar del icono (es el avatar del usuario).
  final Widget? avatar;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget marca = _marca();

    return InkWell(
      onTap: onTap,
      customBorder: const StadiumBorder(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: activa
            ? BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [PaletaMiInfo.jadeMedio, PaletaMiInfo.jadeOscuro],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: PaletaMiInfo.piedraClara, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: PaletaMiInfo.piedraBrillo.withValues(alpha: 0.35),
                    blurRadius: 10,
                  ),
                  BoxShadow(
                    color: PaletaMiInfo.oroOscuro.withValues(alpha: 0.6),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Todas las pestañas reservan el mismo alto para que los
            // nombres queden alineados aunque una lleve avatar.
            SizedBox(height: 29, child: Center(child: marca)),
            const SizedBox(height: 2),
            // FittedBox: si el nombre es largo ("Configuración") se encoge
            // un poco en lugar de desbordarse en teléfonos chicos.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                texto,
                maxLines: 1,
                style: activa
                    ? EstilosMiInfo.pestanaSeleccionada
                    : EstilosMiInfo.pestana,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// El avatar (si lo hay) o el icono de la sección.
  Widget _marca() {
    final Widget? foto = avatar;
    if (foto == null) {
      return Icon(
        icono,
        color: activa ? PaletaMiInfo.oroClaro : PaletaMiInfo.tinta,
        size: activa ? 22 : 24,
      );
    }

    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: PaletaMiInfo.piedraClara,
        border: activa
            ? Border.all(color: PaletaMiInfo.oroClaro, width: 1.4)
            : null,
      ),
      child: foto,
    );
  }
}

/// Filigrana grabada en el metal de la barra (volutas y rosetas).
class _PintorFiligrana extends CustomPainter {
  const _PintorFiligrana();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint luz = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = PaletaMiInfo.piedraBrillo.withValues(alpha: 0.55);
    final Paint sombra = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = PaletaMiInfo.oroOscuro.withValues(alpha: 0.5);

    // Doble filete superior.
    canvas.drawLine(const Offset(0, 1.5), Offset(size.width, 1.5), sombra);
    canvas.drawLine(const Offset(0, 4), Offset(size.width, 4), luz);

    // Volutas repetidas: círculo + dos arcos que salen de él.
    for (double x = 18; x < size.width - 6; x += 34) {
      canvas.drawCircle(Offset(x + 1, 12), 2.6, sombra);
      canvas.drawCircle(Offset(x, 11), 2.6, luz);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(x - 7, 13), radius: 5),
        math.pi * 0.75,
        math.pi * 0.9,
        false,
        luz,
      );
      canvas.drawArc(
        Rect.fromCircle(center: Offset(x + 7, 13), radius: 5),
        math.pi * 1.35,
        math.pi * 0.9,
        false,
        luz,
      );
    }

    // Rosetas de las esquinas.
    for (final Offset centro in [
      const Offset(14, 14),
      Offset(size.width - 14, 14),
      Offset(14, size.height - 10),
      Offset(size.width - 14, size.height - 10),
    ]) {
      for (int i = 0; i < 6; i++) {
        final double angulo = i * math.pi / 3;
        canvas.drawCircle(
          centro + Offset(math.cos(angulo) * 5, math.sin(angulo) * 5),
          2,
          sombra,
        );
      }
      canvas.drawCircle(centro, 2.4, luz);
    }
  }

  @override
  bool shouldRepaint(covariant _PintorFiligrana anterior) => false;
}
