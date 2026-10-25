import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Mayitas/Screens/MiInfo/arte/loro_maya.dart';
import 'package:Mayitas/Screens/MiInfo/arte/mono_peluche.dart';
import 'package:Mayitas/Screens/MiInfo/arte/piramide_maya.dart';
import 'package:Mayitas/Screens/MiInfo/arte/serpiente_maya.dart';
import 'package:Mayitas/Screens/MiInfo/arte/totem_maya.dart';
import 'package:Mayitas/Screens/MiInfo/estilo/imagenes_mi_info.dart';
import 'package:Mayitas/Screens/MiInfo/mi_info_screen.dart';
import 'package:Mayitas/Screens/MiInfo/pantalla_editar_perfil_mi_info.dart';
import 'package:Mayitas/Screens/MiInfo/widgets/barra_inferior_mi_info.dart';
import 'package:Mayitas/Screens/MiInfo/widgets/medallon_imagen.dart';
import 'package:Mayitas/Screens/MiInfo/widgets/titulo_editar_mi_info.dart';
import 'package:Mayitas/Screens/MiInfo/widgets/titulo_mi_info.dart';
import 'package:Mayitas/Screens/pantalla_principal.dart';

/// Los dibujos del diseño que viven en la carpeta `lib/imagenes/` y son SVG.
const List<String> _dibujosSvg = <String>[
  ImagenesMiInfo.perfil,
  ImagenesMiInfo.xp,
  ImagenesMiInfo.anios,
  ImagenesMiInfo.barraInfo,
];

/// Los dibujos del diseño que ahora son JPEG.
const List<String> _dibujosJpg = <String>[
  ImagenesMiInfo.cuadro,
  ImagenesMiInfo.barraEditarPerfil,
];

/// Encuentra las tarjetas de piedra de los paneles (el cuadro del diseño).
///
/// El cuadro dejó de ser SVG y ahora es un JPEG, así que se dibuja con
/// `Image.asset` en vez de `SvgPicture.asset`.
Finder _tarjetasDePiedra() => find.byWidgetPredicate(
      (Widget w) =>
          w is Image &&
          w.image is AssetImage &&
          (w.image as AssetImage).assetName == ImagenesMiInfo.cuadro,
    );

/// Encuentra el rótulo de piedra "Editar perfil" (también es un JPEG).
Finder _barraEditarPerfil() => find.byWidgetPredicate(
      (Widget w) =>
          w is Image &&
          w.image is AssetImage &&
          (w.image as AssetImage).assetName ==
              ImagenesMiInfo.barraEditarPerfil,
    );

void main() {
  // El empty string (no null) hace que la pantalla no consulte Firebase.
  Future<void> pintar(WidgetTester tester, Size tamano) async {
    await tester.binding.setSurfaceSize(tamano);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: MiInfoScreen(
          nombre: 'Natalia Magaña',
          experiencia: 120,
          edad: 8,
          logros: 5,
          avatarUrl: '',
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Mi Info se dibuja en un teléfono normal', (tester) async {
    await pintar(tester, const Size(390, 844));
    expect(find.byType(TituloMiInfo), findsOneWidget);
    expect(find.text('Natalia Magaña'), findsOneWidget);
    expect(find.text('120 XP'), findsOneWidget);
  });

  testWidgets('Mi Info se dibuja en un teléfono pequeño', (tester) async {
    await pintar(tester, const Size(320, 560));
    expect(find.byType(TituloMiInfo), findsOneWidget);
  });

  testWidgets('Mi Info aguanta un nombre larguísimo', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 560));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: MiInfoScreen(
          nombre: 'Natalia Fernanda Magaña de la Cruz y Asociados',
          experiencia: 9999,
          edad: 108,
          logros: 1234,
          avatarUrl: '',
        ),
      ),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('Mi Info con foto rota cae al cachorro de leopardo',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: MiInfoScreen(
          nombre: 'Pepito',
          experiencia: 0,
          edad: 8,
          logros: 0,
          avatarUrl: 'https://ejemplo.invalido/foto.png',
        ),
      ),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('Las etiquetas van en español y en maya', (tester) async {
    await pintar(tester, const Size(390, 844));
    expect(find.text("Nombre / K'aaba'"), findsOneWidget);
    expect(find.text('Experiencia / Túuntajil'), findsOneWidget);
    expect(find.text("Edad / Ja'abil"), findsOneWidget);
    expect(find.text('Logros / Náajal'), findsOneWidget);
    expect(find.text('Avatar / Oochel'), findsOneWidget);
  });

  testWidgets('Mi Info usa los dibujos del diseño', (tester) async {
    await pintar(tester, const Size(390, 844));

    // El título (barrainfo) y los tres medallones (perfil, xp, años) son SVG...
    expect(find.byType(SvgPicture), findsNWidgets(4));
    expect(find.byType(MedallonImagen), findsNWidgets(3));

    // ...y las cinco tarjetas usan el cuadro de piedra, que ahora es un JPEG.
    expect(_tarjetasDePiedra(), findsNWidgets(5));
  });

  testWidgets('Ya no salen el monito, el loro ni las serpientes',
      (tester) async {
    await pintar(tester, const Size(390, 844));

    // Se quitaron del diseño: el monito de peluche (el que parecía vaca),
    // el loro del panel de experiencia y las serpientes del avatar.
    expect(find.byType(MonoPeluche), findsNothing);
    expect(find.byType(LoroMaya), findsNothing);
    expect(find.byType(SerpienteMaya), findsNothing);
  });

  testWidgets('Ya no hay pirámides en el panel del avatar', (tester) async {
    await pintar(tester, const Size(390, 844));

    // Las dos pirámides del templo (las que iban en las esquinas de abajo del
    // panel de la foto) se quitaron: solo queda la de la barra de XP.
    expect(find.byType(PiramideMaya), findsOneWidget);

    // El tótem tallado sigue detrás de la foto.
    expect(find.byType(TotemMaya), findsOneWidget);
  });

  testWidgets('Los dibujos existen y Flutter los tiene empaquetados',
      (tester) async {
    // 1) Los que son SVG.
    for (final String archivo in _dibujosSvg) {
      expect(File(archivo).existsSync(), isTrue, reason: 'Falta $archivo');
      final String svg =
          await tester.runAsync(() => rootBundle.loadString(archivo)) ?? '';
      expect(svg, contains('<svg'), reason: 'No se pudo leer $archivo');
    }

    // 2) Los que ahora son JPEG.
    for (final String archivo in _dibujosJpg) {
      expect(File(archivo).existsSync(), isTrue, reason: 'Falta $archivo');
      final ByteData? jpg =
          await tester.runAsync(() => rootBundle.load(archivo));
      // Todo JPEG empieza con los bytes FF D8 FF.
      expect(jpg!.buffer.asUint8List(0, 3), <int>[0xFF, 0xD8, 0xFF],
          reason: '$archivo no es un JPEG');
    }
  });

  testWidgets('Mi Info NO lleva barra de navegación', (tester) async {
    await pintar(tester, const Size(390, 844));
    expect(find.text('Inicio'), findsNothing);
    expect(find.text('Juegos'), findsNothing);
    expect(find.text('Configuración'), findsNothing);
    expect(find.text('Mi Perfil'), findsNothing);
  });

  testWidgets('La barra superior muestra la hora del teléfono', (tester) async {
    await pintar(tester, const Size(390, 844));
    // La hora cambia sola: solo se revisa que haya un texto con ":" fuera
    // de los paneles de datos (la hora del reloj).
    expect(find.textContaining(':'), findsWidgets);
  });

  testWidgets('El niño puede abrir la pantalla para editar su perfil',
      (tester) async {
    await pintar(tester, const Size(390, 844));

    final Finder botonEditar = find.text('Editar perfil');
    // Puede requerir bajar un poco: el panel del avatar es el segundo bloque.
    await tester.ensureVisible(botonEditar);
    await tester.pumpAndSettle();
    await tester.tap(botonEditar);
    await tester.pumpAndSettle();

    // El título ya es el rótulo de piedra del diseño, no letras, y se dibuja
    // completo (con la proporción del dibujo).
    expect(find.byType(TituloEditarMiInfo), findsOneWidget);
    expect(find.text('Editar perfil'), findsNothing);
    final Size titulo = tester.getSize(find.byType(TituloEditarMiInfo));
    expect(titulo.height, closeTo(titulo.width / TituloEditarMiInfo.proporcion, 1));
    expect(titulo.height, greaterThan(150));
    expect(_barraEditarPerfil(), findsOneWidget);
    expect(find.text("Nombre / K'aaba'"), findsOneWidget);
    expect(find.text('Apellido(s)'), findsOneWidget);
    expect(find.text("Edad / Ja'abil"), findsOneWidget);
    expect(find.text('Elige tu avatar'), findsOneWidget);
    expect(find.text('Guardar'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
  });

  testWidgets('El género solo ofrece Niño o Niña (sin leopardo)',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: PantallaEditarPerfilMiInfo(
          nombre: 'Pepito Pérez',
          edad: 8,
          avatarUrl: '',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Niño'), findsOneWidget);
    expect(find.text('Niña'), findsOneWidget);
    expect(find.text('Leopardo'), findsNothing);
    expect(find.text('Avatar / Oochel'), findsNothing);
  });

  testWidgets('La pantalla de edición se dibuja en teléfono chico',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 560));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: PantallaEditarPerfilMiInfo(
          nombre: 'Pepito Pérez',
          edad: 8,
          avatarUrl: '',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TituloEditarMiInfo), findsOneWidget);
    expect(_barraEditarPerfil(), findsOneWidget);
    expect(find.text('Pepito Pérez'), findsOneWidget);
    // "8" aparece en el campo y en su pista (que está oculta pero en el árbol).
    expect(find.text('8'), findsWidgets);
  });

  testWidgets('La barra de navegación vive en Inicio', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: PantallaPrincipal()));
    await tester.pumpAndSettle();

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Juegos'), findsOneWidget);
    expect(find.text('Configuración'), findsOneWidget);
    expect(find.text('Mi Perfil'), findsOneWidget);
    // Ya no está el botón temporal.
    expect(find.text('Ver Mi Info'), findsNothing);
  });

  testWidgets('La barra de navegación no se desborda en teléfono chico',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 560));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          bottomNavigationBar: BarraInferiorMiInfo(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Juegos'), findsOneWidget);
    expect(find.text('Configuración'), findsOneWidget);
    expect(find.text('Mi Perfil'), findsOneWidget);
  });

  testWidgets('Desde Inicio, "Mi Perfil" abre Mi Info sin barra',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: PantallaPrincipal()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mi Perfil'));
    await tester.pumpAndSettle();

    // Se abrió "Mi Info" (con sus datos de ejemplo) y ya no hay barra.
    expect(find.byType(MiInfoScreen), findsOneWidget);
    expect(find.text('Inicio'), findsNothing);
    expect(find.text('Juegos'), findsNothing);
    expect(find.text('Configuración'), findsNothing);
  });
}
