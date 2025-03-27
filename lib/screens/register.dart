import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario.dart';
import 'cliente_screen.dart';
import 'proveedor_screen.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  String? _gender;
  UserRole? _role;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[100],
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Registro',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Pacifico',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _userController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre Completo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _gender,
                  items: <String>['Masculino', 'Femenino', 'Otro'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _gender = newValue;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Género',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<UserRole>(
                  value: _role,
                  items: UserRole.values.map((UserRole value) {
                    return DropdownMenuItem<UserRole>(
                      value: value,
                      child: Text(value.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (UserRole? newValue) {
                    setState(() {
                      _role = newValue;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Rol',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _registrar(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Registrarse', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _registrar(BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _userController.text,
        password: _passwordController.text,
      );
      User? user = userCredential.user;
      if (user != null) {
        Usuario newUser = Usuario(
          uid: user.uid,
          username: _userController.text.split('@')[0],
          fullname: _fullNameController.text,
          email: _userController.text,
          password: _passwordController.text,
          gender: _gender!,
          role: _role!,
        );
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(newUser.toMap());

        _redirectToUserScreen(newUser, context); // Usa newUser directamente
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error al registrarse';
      if (e.code == 'weak-password') {
        errorMessage = 'La contraseña es muy débil.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'El correo electrónico ya está en uso.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error desconocido')),
        );
      }
    }
  }

  void _redirectToUserScreen(Usuario user, BuildContext context) {
    try {
      if (user.role == UserRole.cliente) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ClienteScreen(user: user)),
        );
      } else if (user.role == UserRole.proveedor) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProveedorScreen(user: user)), // Corrección aquí
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rol de usuario desconocido.')),
          );
        }
      }
    } catch (e) {
      print('Error en la navegación: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al navegar a la pantalla del usuario.')),
        );
      }
    }
  }
}