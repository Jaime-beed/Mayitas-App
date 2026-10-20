import 'package:flutter/material.dart'; // Importa el catálogo de diseño (botones, textos, colores).
import 'package:firebase_auth/firebase_auth.dart'; // Herramientas de Firebase para leer sesiones.
import 'package:firebase_database/firebase_database.dart'; // CORRECCIÓN: faltaba, se necesita para revisar el perfil
import '../Screens/Pantalla_bienvenida.dart'; // Pantalla a la que vamos si NO hay sesión.
import '../Screens/pantalla_principal.dart'; // CORRECCIÓN: faltaba, pantalla si ya tiene perfil completo
import '../Screens/pantalla_editar_perfil.dart'; // CORRECCIÓN: faltaba, pantalla si el perfil no existe aún
import 'dart:async';
import 'dart:math';

// Pantalla dinámica (StatefulWidget) que puede realizar acciones con el tiempo.
class PantallaCarga extends StatefulWidget {
  const PantallaCarga({super.key});

  @override
  State<PantallaCarga> createState() => _PantallaCargaState();
}

class _PantallaCargaState extends State<PantallaCarga> {
  @override
  void initState() {
    super.initState();
    _mensajeActual = _mensajes[_random.nextInt(_mensajes.length)];
    _iniciarRotacionMensajes(); // Configuración base y obligatoria de Flutter.
    _verificarSesion(); // Ejecutamos nuestra función de revisión ANTES de dibujar la pantalla.
  }

  final List<String> _mensajes =[
   'La palabra del día es: Bix a beel (¿Cómo estás?)',
   "La palabra del día es: Yuum bo'otik (Gracias)",
   "La palabra del día es: Mix ba'al (De nada)",
   'La palabra del día es: Jaaj (Sí)',
   "La palabra del día es: Ma' (No)",
   "La palabra del día es: Ma'alob (Bien)",
   "La palabra del día es: Ma'alob k'iin (Buenos días)",
   "La palabra del día es: Ja' (Buenos días)",
   'La palabra del día es: Janal (Janal)',
   'La palabra del día es: Naj (Casa)',
   "La palabra del día es: Máak (Persona)",
   "La palabra del día es: K'iin (Sol)",
   "La palabra del día es: Tak tu laak' k'iin (Adios)",
   "La palabra del día es: Na'(Mamá)",
   "La palabra del día es: Taata'(Papá)",

  ];

  
  final Random _random = Random();
  late String _mensajeActual;
  Timer? _timer;

 void _iniciarRotacionMensajes(){
     _timer = Timer.periodic (const Duration(milliseconds: 3000),(_)
     {
      if (!mounted) return;
      String nuevo;
      do {
        nuevo = _mensajes [_random.nextInt(_mensajes.length)];
      } while (nuevo ==  _mensajeActual);
      setState(() => _mensajeActual = nuevo
        
      );
     });
  }

  @override
  void dispose(){
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verificarSesion() async {
    // Pausa el código para que el usuario alcance a ver el logo de la app.
    await Future.delayed(const Duration(seconds: 6));

    // Le pregunta a Firebase: "¿Hay algún usuario guardado en la memoria del celular?".
    final usuario = FirebaseAuth.instance.currentUser;

    // Regla de seguridad: verifica si la pantalla sigue existiendo antes de cambiar a otra.
    if (!mounted) return;

    // CORRECCIÓN: ahora sí se usa la variable "usuario" para decidir a dónde ir
    if (usuario == null) {
      // No hay sesión activa: manda al login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PantallaBienvenida()),
        (route) => false,
      );
      return; // Corta aquí para no seguir revisando la base de datos sin usuario
    }

    // Sí hay sesión: revisamos si ya completó su perfil en la base de datos
    final ref = FirebaseDatabase.instance.ref("usuarios/${usuario.uid}"); // Nodo de este usuario
    final snapshot = await ref.get(); 
    final int edadGuardada = snapshot.exists
     ? (snapshot.child('edad').value as int? ?? 0) :0 ;// Consulta si el nodo existe

    // Regla de seguridad: volvemos a verificar que la pantalla siga activa
    // después del segundo await, antes de usar "context".
    if (!mounted) return;

    if (edadGuardada >0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PantallaPrincipal()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => PantallaEditarPerfil(correo: usuario.email ?? '')),
        (route) => false, 
      );
    }

  // Vuelve a chequear tras el segundo await

   
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack( // NUEVO: apila el fondo debajo y el contenido encima
      children: [
        // CAPA 1: imagen de fondo, cubre toda la pantalla
        Positioned.fill(
          child: Image.asset(
            'assets/Fondos/fondo_carga.jpg', // Cambia esto por tu imagen de fondo
            fit: BoxFit.cover, // Cubre toda la pantalla, recortando si es necesario
          ),
        ),

        // CAPA 2: tu contenido original (logo + spinner), sin cambios
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/Logos/logo_principal.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),

             
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Container(
                  key: ValueKey(_mensajeActual),
                  padding: const EdgeInsets.symmetric(horizontal:15, vertical:6),
                  decoration: BoxDecoration(
                  color:Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(14),
                  ),
                child: Text (_mensajeActual,
                key: ValueKey (_mensajeActual),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  shadows: [Shadow(blurRadius: 6, color: Colors.green)],
                  )
                )
              ),
            ),
                
              ), 
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: Colors.orange), // Spinner de carga
            ],
          ),
        ),
      ],
    ),
  );
}
}