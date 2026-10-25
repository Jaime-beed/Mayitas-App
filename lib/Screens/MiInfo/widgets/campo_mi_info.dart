import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../estilo/estilos_mi_info.dart';
import '../estilo/paleta_mi_info.dart';

/// Campo de texto con el estilo de "Mi Info": letra tallada sobre una
/// placa de jade y marco de piedra que se enciende en dorado al escribir.
class CampoMiInfo extends StatelessWidget {
  const CampoMiInfo({
    super.key,
    required this.controlador,
    required this.etiqueta,
    this.pista,
    this.teclado,
    this.formateadores,
    this.validador,
    this.maxLargo,
  });

  /// Quién guarda lo que se escribe.
  final TextEditingController controlador;

  /// Nombre del campo ("Nombre / K'aaba'").
  final String etiqueta;

  /// Texto de ayuda que se ve cuando el campo está vacío.
  final String? pista;

  /// Tipo de teclado (por ejemplo, numérico para la edad).
  final TextInputType? teclado;

  /// Filtros de lo que se puede escribir (por ejemplo, solo dígitos).
  final List<TextInputFormatter>? formateadores;

  /// Revisa el contenido y devuelve el mensaje de error, o null si está bien.
  final String? Function(String?)? validador;

  /// Máximo de caracteres permitidos.
  final int? maxLargo;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      keyboardType: teclado,
      inputFormatters: formateadores,
      maxLength: maxLargo,
      validator: validador,
      style: EstilosMiInfo.campo,
      cursorColor: PaletaMiInfo.oroClaro,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: etiqueta,
        hintText: pista,
        hintStyle: EstilosMiInfo.etiquetaCampo,
        labelStyle: EstilosMiInfo.etiquetaCampo,
        floatingLabelStyle: EstilosMiInfo.etiquetaCampo,
        errorStyle: EstilosMiInfo.errorCampo,
        counterText: '', // Oculta el contador "0/2" de Flutter
        filled: true,
        fillColor: PaletaMiInfo.jadeNoche.withValues(alpha: 0.55),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: PaletaMiInfo.piedra.withValues(alpha: 0.8),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: PaletaMiInfo.oroClaro,
            width: 2.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: PaletaMiInfo.rosa, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: PaletaMiInfo.rosa, width: 2.4),
        ),
      ),
    );
  }
}
