
import 'package:flutter/material.dart'; // Importa el catálogo de diseño visual de Flutter.
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
// Importa la pantalla de login para poder navegar hacia ella.

// Crea una pantalla estática (StatelessWidget), su diseño no cambiará por sí solo.
class Pantallaregistro extends StatefulWidget {
  const Pantallaregistro({super.key});

  @override
  State<Pantallaregistro> createState() => _PantallaregistroState();
}

class _PantallaregistroState extends State<Pantallaregistro> {
   final _formKey = GlobalKey<FormState>(); // Crea una llave para el formulario, que nos permitirá validar los campos.
   bool _ocultarPassword=true;
   bool _ocultarPasswordConfirmar = true;

   final _emailController = TextEditingController();
   final _nombreController = TextEditingController();
   final _apellidoController = TextEditingController();
   final _edadController = TextEditingController();
   final _passwordController = TextEditingController();
   final _confirmarPasswordController = TextEditingController();

  @override
   void dispose () {
     _emailController.dispose();
     _nombreController.dispose();
     _apellidoController.dispose();
     _edadController.dispose();
     _passwordController.dispose();
     _confirmarPasswordController.dispose();
    super.dispose();

   }
  @override
  Widget build(BuildContext context) {
    return Scaffold( // El lienzo en blanco base de la pantalla.
      backgroundColor:Colors.black, // Color de fondo de la pantalla.
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child:SingleChildScrollView( // Escudo invisible que evita que el diseño choque con la cámara frontal o los bordes.
        child: Padding(
          // Da un margen de 24 píxeles por los 4 lados para que los botones no toquen las orillas.
          padding: const EdgeInsets.all(24.0), 
         child: Form( 
          key:_formKey,
          child: Column( // Apilador vertical de elementos.
            mainAxisAlignment: MainAxisAlignment.center, // Centra todos los botones a la mitad de la pantalla.
            crossAxisAlignment: CrossAxisAlignment.stretch, // Obliga a los botones a estirarse a lo ancho.
            children: [
              // Texto principal, centrado, tamaño 28, en negritas (bold) y color naranja.
              const Text("kʼáat u kʼáat chiʼil tʼáan", textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange)),
              const SizedBox(height: 1), // Espaciador invisible grande.
              
              const Text('Crea tu cuenta Mayitas',textAlign:TextAlign.center,style:TextStyle(fontSize:20,fontWeight:FontWeight.bold,color:Colors.white)), // Texto secundario, centrado, tamaño 14, en negritas y color))
              const SizedBox(height:40),
              // Caja donde el usuario escribirá. InputDecoration le pone el borde redondeado de 12px.
              

               TextFormField(
                keyboardType: TextInputType.text,
                maxLength:150,
                controller: _nombreController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: 'Nombre(s)',labelStyle:const TextStyle(color:Colors.white), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                counterText: ""),
                validator: (value){
                  if(value==null || value.isEmpty) return 'Por favor ingresa tu(s) nombre(s)';
                  return null;
                },
              ),
               const SizedBox(height: 16),
                TextFormField(
                keyboardType: TextInputType.text,
                maxLength:150,
                controller: _apellidoController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: 'Apellido(s)',labelStyle:const TextStyle(color:Colors.white), 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                counterText: "",
                ),
                validator: (value){
                  if(value==null || value.isEmpty) return 'Por favor ingresa tu(s) apellido(s)';
                  return null;
                },
               ),
               const SizedBox(height: 16),
               
                TextFormField(
                keyboardType: TextInputType.number,
                maxLength:2,
                controller: _edadController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: 'Edad',labelStyle:const TextStyle(color:Colors.white), 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                counterText: "",
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Permite solo dígitos
                ],
                validator: (value){
                  if(value==null || value.isEmpty) return 'Por favor ingresa tu edad';
                  return null;
                },
               ),
               const SizedBox(height: 16), 
               
               TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                maxLength:150,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: 'Correo electrónico',labelStyle:const TextStyle(color:Colors.white), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                counterText: ""),
                validator: (value){
                  if(value==null || !value.endsWith('@gmail.com')) return 'Debes usar un correo electrónico válido';
                  return null;
                },
              ),
               const SizedBox(height: 16),  // Espaciador invisible pequeño.
              // Caja de texto. El 'obscureText: true' es el truco para cambiar letras por puntitos de contraseña.
              TextFormField(
                controller: _passwordController,
                obscureText: _ocultarPassword, 
                maxLength: 20,
                style:const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Contraseña', 
                  labelStyle: TextStyle(color: Colors.white), 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  counterText: "",
                  suffixIcon: IconButton(
                    icon: Icon(_ocultarPassword ? Icons.visibility_off: Icons.visibility, color:Colors.white),
                    onPressed:(){
                      setState((){ 
                        _ocultarPassword=!_ocultarPassword;
                      });
                    }
                    ),
                  ),
                 validator: (value){
                  if(value==null || value.length<8) return 'la contraseña debe tener al menos 8 caracteres';
                  return null;
                }
               
              ),
              const SizedBox(height: 24),
              
              TextFormField(
                obscureText: _ocultarPasswordConfirmar, 
                controller: _confirmarPasswordController,
                maxLength: 20,
                style:const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Confirmar Contraseña', 
                  labelStyle: TextStyle(color: Colors.white), 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: Icon(_ocultarPasswordConfirmar ? Icons.visibility_off: Icons.visibility, color:Colors.white),
                    onPressed:(){
                      setState((){ 
                        _ocultarPasswordConfirmar=!_ocultarPasswordConfirmar;
                      });
                    }
                    ),
                  ),
                 validator: (value){
                  if(value==null || value.length<8) return 'la contraseña debe tener al menos 8 caracteres';
                   if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                }
               
              ),
              const SizedBox(height: 24), // Espaciador invisible mediano.
              
              // Botón principal con relleno sólido y sombra.
              ElevatedButton(
                onPressed: () async {
                  if(_formKey.currentState!.validate() ) {
                    try {
                      UserCredential credenciales = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email:_emailController.text.trim(),
                        password:_passwordController.text.trim(),
                      ); 

                      String idUsuario = credenciales.user!.uid;
                        DatabaseReference ref=FirebaseDatabase.instance.ref("usuarios/$idUsuario");
                        await ref.set({
                        'correo': _emailController.text.trim(),
                        'nombre': _nombreController.text.trim(),
                        'apellido': _apellidoController.text.trim(),
                        'edad': int.parse(_edadController.text.trim()), 
                        
                        // DATOS SILENCIOSOS
                        'nivel': 0,
                        'experiencia': 0,
                        'monedas': 0, 
                        'skins': "",
                        // RTDB prefiere guardar las fechas como texto estructurado:
                        'fecha_creacion': DateTime.now().toIso8601String(), 
                      });

                      Navigator.pop(context);

                    } on FirebaseAuthException catch (e) { 
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al registrar: ${e.message}'), backgroundColor: Colors.red),
                      );
                    }
                  }
                 

                }, // Aquí programaremos la función de Firebase para entrar.
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16),backgroundColor:Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), // Le da relleno interno y bordes redondos.
                child: const Text('Crea tu cuenta', style: TextStyle(fontSize: 18,color:Colors.black)),
              ),
              const SizedBox(height: 16), // Espaciador invisible pequeño.
              ElevatedButton(
                onPressed: () {
                  Navigator.pop (context);
                }, // Aquí programaremos la función de Firebase para registrarse.
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16),backgroundColor:Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), // Le da relleno interno y bordes redondos.
                child: const Text('Ya tengo cuenta', style: TextStyle(fontSize: 18,color:Colors.black)),
              ),
             const SizedBox(height: 16), // Espaciador invisible pequeño.
              
              // Botón secundario que solo tiene contorno, ideal para iniciar con Google.
              OutlinedButton.icon(
                onPressed: () {}, // Aquí conectaremos Google Sign-In.
                icon: const Icon(Icons.g_mobiledata, size: 32, color: Colors.white), // Ícono precargado de Google.
                label: const Text('Registrar con Google', style: TextStyle(color: Colors.white)), // Texto al lado del ícono.
              ),
              const SizedBox(height: 16), // Espaciador invisible pequeño.

              OutlinedButton.icon(
                onPressed: () {}, // Aquí conectaremos Google Sign-In.
                icon: const Icon(Icons.person, size: 32, color: Colors.white), // Ícono precargado de Google.
                label: const Text('Entrar como invitado', style: TextStyle(color: Colors.white)), // Texto al lado del ícono.
              )
           ],
            
          ),
        ),
         
       ),
      ),
    ),
  );
 }
}