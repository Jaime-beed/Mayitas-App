import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static Future<void> entrarConGoogle() async {
    final googleUser = await GoogleSignIn.instance.authenticate();
    final credential = GoogleAuthProvider.credential(
      idToken: googleUser.authentication.idToken,
    );
    final credenciales =
        await FirebaseAuth.instance.signInWithCredential(credential);

    final ref =
        FirebaseDatabase.instance.ref("usuarios/${credenciales.user!.uid}");
    final snapshot = await ref.get();
    if (!snapshot.exists) {
      await ref.set({
        'correo': credenciales.user!.email,
        'nombre': credenciales.user!.displayName ?? 'Usuario',
        'apellido': '',
        'edad': 0,
        'nivel': 0,
        'experiencia': 0,
        'monedas': 0,
        'skins': '',
        'fecha_creacion': DateTime.now().toIso8601String(),
      });
    }
  }

  static Future<void> cerrarSesion() async {
    await GoogleSignIn.instance.signOut();
    await FirebaseAuth.instance.signOut();
  }
}