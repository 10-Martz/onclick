import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/usuario.dart';
import '../adapters/local_storage.dart';
import '../adapters/auth.dart';
import '../adapters/db.dart';
import 'register.dart';
import 'cliente_screen.dart';
import 'proveedor_screen.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _error = '';
  LocalStorage _localStorage = LocalStorage();
  Db _db = Db();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1050),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF87CEEB), // Azul cielo
              Color(0xFFF8BBD0), // Rosa suave
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
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
            child: _isLoading
                ? AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _animation.value,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                        ),
                      );
                    },
                  )
                : Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Click',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Pacifico',
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _userController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu email';
                            }
                            if (!value.contains('@')) {
                              return 'Por favor ingresa un email válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu contraseña';
                            }
                            if (value.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        if (_error.isNotEmpty) ...[
                          SizedBox(height: 10),
                          Text(_error, style: TextStyle(color: Colors.red)),
                        ],
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => _login(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Iniciar Sesión', style: TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Register()),
                            );
                          },
                          child: const Text('Registrarse', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      try {
        UserCredential userCredential = await Auth.signInWithEmailAndPassword(
          _userController.text,
          _passwordController.text,
        );
        User? user = userCredential.user;
        if (user == null) {
          setState(() {
            _error = 'Email o contraseña inválidos.';
            _isLoading = false;
            _animationController.stop();
          });
          return;
        }

        Map<String, dynamic>? userData = await _db.getUserData(user.uid);
        if (userData == null) {
          setState(() {
            _error = 'Usuario no encontrado.';
            _isLoading = false;
            _animationController.stop();
          });
          return;
        }
        Usuario loggedInUser = Usuario.fromFirebaseMap(userData);
        await _localStorage.setUser(loggedInUser.toStringMap());
        await _localStorage.setLoginStatus(true);
        setState(() {
          _isLoading = false;
          _animationController.stop();
        });
        _redirectToUserScreen(loggedInUser, context);
      } catch (e) {
        if (e.toString().contains('The supplied auth credential is incorrect')) {
          setState(() {
            _error = 'Email o contraseña inválidos.';
            _isLoading = false;
            _animationController.stop();
          });
          return;
        }
        setState(() {
          _error = 'Ocurrió un error desconocido.';
          _isLoading = false;
          _animationController.stop();
        });
        print(e);
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
          MaterialPageRoute(builder: (context) => ProveedorScreen(user: user)),
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