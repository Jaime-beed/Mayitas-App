import 'package:flutter/material.dart';

/// Foto de perfil redonda del usuario.
class AvatarUsuario extends StatelessWidget {
  const AvatarUsuario({
    super.key,
    required this.tamano,
    this.url,
    this.conLazo = false,
  });

  final double tamano;
  final String? url;
  final bool conLazo;

  @override
  Widget build(BuildContext context) {
    final String? enlace = url;

    final Widget retrato = Container(
      width: tamano,
      height: tamano,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: SizedBox(
          width: tamano,
          height: tamano,
          child: (enlace == null || enlace.isEmpty)
              ? Container(
                  color: Colors.white.withValues(alpha: 0.9),
                  child: Icon(
                    Icons.person,
                    color: Colors.black54,
                    size: tamano * 0.55,
                  ),
                )
              : Image.network(
                  enlace,
                  fit: BoxFit.cover,
                  width: tamano,
                  height: tamano,
                  errorBuilder: (_, _, _) => Container(
                    color: Colors.white.withValues(alpha: 0.9),
                    child: Icon(
                      Icons.person,
                      color: Colors.black54,
                      size: tamano * 0.55,
                    ),
                  ),
                ),
        ),
      ),
    );

    if (!conLazo) return retrato;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        retrato,
        Positioned(
          right: -tamano * 0.02,
          top: -tamano * 0.02,
          child: Icon(Icons.favorite, color: Colors.pinkAccent, size: tamano * 0.24),
        ),
      ],
    );
  }
}
