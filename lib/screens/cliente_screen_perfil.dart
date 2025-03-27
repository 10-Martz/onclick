import 'package:flutter/material.dart';
import '../models/usuario.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClienteScreenPerfil extends StatelessWidget {
  final Usuario user;

  const ClienteScreenPerfil({super.key, required this.user});

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cerrar sesión.')),
      );
      print('Error al cerrar sesión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.lightGreen[100],
                        radius: constraints.maxWidth * 0.2,
                        child: Text(
                          user.fullname.isNotEmpty
                              ? user.fullname[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                              fontSize: constraints.maxWidth * 0.15,
                              color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Nombre: ${user.fullname}',
                          style: TextStyle(fontSize: constraints.maxWidth * 0.05)),
                      const SizedBox(height: 8),
                      Text('Email: ${user.email}',
                          style: TextStyle(fontSize: constraints.maxWidth * 0.05)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _logout(context),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Salir', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}