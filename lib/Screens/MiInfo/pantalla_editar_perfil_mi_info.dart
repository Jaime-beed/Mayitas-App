// ============================================================
//  EDITAR PERFIL  →  lib/Screens/MiInfo/pantalla_editar_perfil_mi_info.dart
//
//  Pantalla para que el niño o la niña cambien su nombre, su edad y su
//  avatar, con el mismo estilo maya de "Mi Info".
//
//  CÓMO USARLA:
//    final bool? guardado = await Navigator.push(
//      context,
//      MaterialPageRoute(
//        builder: (_) => PantallaEditarPerfilMiInfo(
//          nombre: 'Pepito Pérez',
//          edad: 8,
//          avatarUrl: '',
//        ),
//      ),
//    );
//    if (guardado == true) { /* volver a leer el perfil */ }
//
//  IMPORTANTE: al guardar solo se actualizan nombre, apellido, edad, género
//  y avatar_url. La experiencia, las monedas, el nivel y las skins del niño
//  NO se tocan.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'estilo/imagenes_mi_info.dart';
import 'estilo/estilos_mi_info.dart';
import 'estilo/paleta_mi_info.dart';
import 'estilo/textos_mi_info.dart';
import 'modelo/avatares.dart';
import 'modelo/perfil_editable.dart';
import 'servicio/perfil_servicio.dart';
import 'widgets/aviso_mi_info.dart';
import 'widgets/avatar_usuario.dart';
import 'widgets/barra_superior_mi_info.dart';
import 'widgets/boton_maya.dart';
import 'widgets/campo_mi_info.dart';
import 'widgets/panel_info.dart';
import 'widgets/selector_avatar_mi_info.dart';
import 'widgets/titulo_editar_mi_info.dart';

/// Edad mínima y máxima permitidas (las mismas del registro).
const int _edadMinima = 4;
const int _edadMaxima = 8;

class PantallaEditarPerfilMiInfo extends StatefulWidget {
  const PantallaEditarPerfilMiInfo({
    super.key,
    this.nombre,
    this.edad,
    this.avatarUrl,
  });

  /// Nombre completo que ya se está mostrando (se usa mientras llega
  /// lo que hay guardado en Firebase).
  final String? nombre;

  /// Edad que ya se está mostrando.
  final int? edad;

  /// Foto de perfil que ya se está mostrando.
  final String? avatarUrl;

  @override
  State<PantallaEditarPerfilMiInfo> createState() =>
      _PantallaEditarPerfilMiInfoState();
}

class _PantallaEditarPerfilMiInfoState
    extends State<PantallaEditarPerfilMiInfo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _apellido = TextEditingController();
  final TextEditingController _edad = TextEditingController();

  /// Avatar elegido: 'Niño' o 'Niña'.
  String _genero = Avatares.generoNino;

  /// ¿Todavía se está leyendo lo guardado en Firebase?
  bool _cargando = true;

  /// ¿Se está guardando?
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _prellenarConLoQueTenemos();
    _leerLoGuardado();
  }

  @override
  void dispose() {
    _nombre.dispose();
    _apellido.dispose();
    _edad.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // DATOS
  // ------------------------------------------------------------
  /// Llena los campos con lo que la pantalla anterior ya conocía.
  void _prellenarConLoQueTenemos() {
    _nombre.text = widget.nombre ?? '';

    final int? edad = widget.edad;
    if (edad != null) _edad.text = '$edad';

    _genero = Avatares.generoInicial(url: widget.avatarUrl);
  }

  /// Lee de Firebase y afina los campos (ahí sí viene el apellido aparte).
  Future<void> _leerLoGuardado() async {
    try {
      final PerfilEditable? guardado = await PerfilServicio.leerPerfilEditable();
      if (!mounted) return;

      setState(() {
        if (guardado != null) {
          final String? nombre = guardado.nombre;
          if (nombre != null) _nombre.text = nombre;

          _apellido.text = guardado.apellido ?? '';

          final int? edad = guardado.edad;
          if (edad != null) _edad.text = '$edad';

          _genero = Avatares.generoInicial(
            url: guardado.avatarUrl,
            genero: guardado.genero,
          );
        }
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _cargando = false);
    }
  }

  // ------------------------------------------------------------
  // GUARDAR
  // ------------------------------------------------------------
  Future<void> _guardar() async {
    final FormState? formulario = _formKey.currentState;
    if (formulario == null || !formulario.validate()) {
      mostrarAvisoMiInfo(context, TextosMiInfo.faltanDatos);
      return;
    }

    setState(() => _guardando = true);

    final bool listo = await PerfilServicio.guardarCambios(
      nombre: _nombre.text.trim(),
      apellido: _apellido.text.trim(),
      edad: int.tryParse(_edad.text.trim()) ?? 0,
      genero: _genero,
      avatarUrl: Avatares.urlDeGenero(_genero),
    );

    if (!mounted) return;
    setState(() => _guardando = false);

    if (!listo) {
      mostrarAvisoMiInfo(context, TextosMiInfo.errorGuardado);
      return;
    }

    mostrarAvisoMiInfo(context, TextosMiInfo.guardadoListo);
    // true = "sí hubo cambios": "Mi Info" vuelve a leer el perfil.
    Navigator.of(context).pop(true);
  }

  // ------------------------------------------------------------
  // INTERFAZ
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaMiInfo.jadeNoche,
      appBar: BarraSuperiorMiInfo(
        avatar: AvatarUsuario(tamano: 38, url: widget.avatarUrl, conLazo: true),
        onRegresar: () => Navigator.of(context).maybePop(),
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

          // CAPA 2: el formulario.
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              children: [
                // El rótulo del diseño.
                const TituloEditarMiInfo(),
                // Aviso mientras se lee lo guardado en la nube.
                if (_cargando) ...[
                  const SizedBox(height: 12),
                  const Center(
                    child: SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: PaletaMiInfo.oroClaro,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // -------- ELIGE SU AVATAR --------
                PanelInfo(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        TextosMiInfo.elegirAvatar,
                        style: EstilosMiInfo.etiqueta,
                      ),
                      const SizedBox(height: 12),
                      SelectorAvatarMiInfo(
                        seleccionado: _genero,
                        onCambio: (String genero) =>
                            setState(() => _genero = genero),
                      ),
                    ],
                  ),
                ),

                // -------- SUS DATOS --------
                PanelInfo(
                  child: Column(
                    children: [
                      CampoMiInfo(
                        controlador: _nombre,
                        etiqueta: TextosMiInfo.campoNombre,
                        pista: 'Pepito',
                        maxLargo: 40,
                        validador: (String? valor) {
                          if (valor == null || valor.trim().isEmpty) {
                            return 'Escribe tu nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      CampoMiInfo(
                        controlador: _apellido,
                        etiqueta: TextosMiInfo.campoApellido,
                        pista: 'Pérez',
                        maxLargo: 40,
                      ),
                      const SizedBox(height: 18),
                      CampoMiInfo(
                        controlador: _edad,
                        etiqueta: TextosMiInfo.campoEdad,
                        pista: '8',
                        teclado: TextInputType.number,
                        maxLargo: 2,
                        formateadores: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validador: (String? valor) {
                          final int? edad =
                              int.tryParse((valor ?? '').trim());
                          if (edad == null) return 'Escribe tu edad';
                          if (edad < _edadMinima || edad > _edadMaxima) {
                            return 'Tienes que tener de $_edadMinima a '
                                '$_edadMaxima años';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // -------- GUARDAR / CANCELAR --------
                Row(
                  children: [
                    Expanded(
                      child: BotonMaya(
                        texto: TextosMiInfo.cancelar,
                        icono: Icons.close_rounded,
                        onTap: _guardando
                            ? null
                            : () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BotonMaya(
                        texto: TextosMiInfo.guardar,
                        icono: Icons.check_rounded,
                        cargando: _guardando,
                        onTap: _guardar,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
