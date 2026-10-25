import 'package:flutter/material.dart';

/// Paleta, materiales y medidas del estilo maya de la pantalla "Mi Info".
///
/// Materiales del diseño:
///  • Jade acolchado (marroquinería de lujo) para fondo y paneles.
///  • Piedra tallada para los relieves (pirámides, glifos, árboles, tótems).
///  • Metal con filigrana grabada para la barra inferior.
class PaletaMiInfo {
  PaletaMiInfo._(); // Clase de solo constantes: no se instancia

  // ---------------- JADE ACOLCHADO ----------------
  static const Color jadeNoche = Color(0xFF052A20); // Sombra profunda
  static const Color jadeOscuro = Color(0xFF0A3B2C); // Panel
  static const Color jadeMedio = Color(0xFF10553C);
  static const Color jade = Color(0xFF17694A); // Piel acolchada
  static const Color jadeClaro = Color(0xFF2F9A73);
  static const Color jadeBrillo = Color(0xFF74DEB2); // Luz suave

  // ---------------- PIEDRA TALLADA (grabados) ----------------
  static const Color piedraOscura = Color(0xFF5F5238);
  static const Color piedra = Color(0xFF9C8A6B);
  static const Color piedraClara = Color(0xFFD6C6A2);
  static const Color piedraBrillo = Color(0xFFF4EBD2);

  // ---------------- METAL CON FILIGRANA ----------------
  static const Color oroOscuro = Color(0xFF6D4F16);
  static const Color oro = Color(0xFFC8A24B);
  static const Color oroClaro = Color(0xFFF2DE9C);

  // ---------------- ACENTOS DEL DISEÑO ----------------
  static const Color rosa = Color(0xFFFF8FBF); // Lazo rosa
  static const Color rosaOscuro = Color(0xFFC95F8E);
  static const Color rojoLoro = Color(0xFFD1373C); // Loro rojo y azul
  static const Color azulLoro = Color(0xFF2F6BD8);
  static const Color amarilloSol = Color(0xFFFFC93C); // Glifo del sol
  static const Color pelajeLeopardo = Color(0xFFE9B155); // Cachorro de leopardo
  static const Color pelajeOscuro = Color(0xFF7A4A16);
  static const Color crema = Color(0xFFF6E7C8);
  static const Color peluche = Color(0xFF8B5E3C); // Mono de peluche
  static const Color pelucheClaro = Color(0xFFC69C6D);

  /// Texto oscuro que va encima del metal (barra inferior).
  static const Color tinta = Color(0xFF0A231B);

  // ---------------- MEDIDAS DE LOS PANELES ----------------
  /// Radio de las esquinas de los paneles.
  static const double radioPanel = 22;

  /// Grosor del marco de piedra tallada.
  static const double marcoPiedra = 6;

  /// Separación entre un panel y el siguiente.
  static const double separacionPaneles = 14;

  /// Margen interior de los paneles.
  static const EdgeInsets rellenoPanel =
      EdgeInsets.symmetric(horizontal: 16, vertical: 14);
}
