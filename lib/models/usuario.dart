//import 'dart:math';

enum UserRole { cliente, proveedor }

class Usuario {
  String username;
  String fullname;
  String email;
  String password;
  String gender;
  UserRole role;
  String? profilePicture;
  String? uid;

  Usuario({
    this.profilePicture,
    required this.username,
    required this.fullname,
    required this.email,
    required this.password,
    required this.gender,
    required this.role,
    this.uid,
  });

  Usuario.withoutPassword({
    required this.username,
    required this.fullname,
    required this.email,
    required this.gender,
    required this.role,
    this.profilePicture,
    this.password = '',
    this.uid,
  });

  void setProfilePicture() {
    // Usamos la imagen proporcionada como imagen de perfil por defecto
    profilePicture = "https://picsum.photos/200/300/?blur";
  }

  void setUid(String uid) {
    this.uid = uid;
  }

  String toStringMap() {
    return """
      {
        "username": "$username",
        "fullname": "$fullname",
        "email": "$email",
        "gender": "$gender",
        "profilePicture": "$profilePicture",
        "uid": "$uid",
        "role": "${role.toString().split('.').last}"
      }
      """;
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'fullname': fullname,
      'email': email,
      'gender': gender,
      'profilePicture': profilePicture,
      'uid': uid,
      'role': role.toString().split('.').last,
    };
  }

  Map<String, dynamic> toFirestoreRestMap() {
    return {
      'fields': {
        'username': {'stringValue': username},
        'fullname': {'stringValue': fullname},
        'email': {'stringValue': email},
        'gender': {'stringValue': gender},
        'profilePicture': {'stringValue': profilePicture},
        'uid': {'stringValue': uid},
        'role': {'stringValue': role.toString().split('.').last},
      },
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> json) {
    final fields = json['fields'] as Map<String, dynamic>;
    return Usuario.withoutPassword(
      username: fields['username']['stringValue'] as String,
      fullname: fields['fullname']['stringValue'] as String,
      email: fields['email']['stringValue'] as String,
      gender: fields['gender']['stringValue'] as String,
      profilePicture: fields['profilePicture'] != null
          ? fields['profilePicture']['stringValue'] as String
          : null,
      uid: fields['uid']['stringValue'] as String,
      role: fields['role']['stringValue'] == 'cliente'
          ? UserRole.cliente
          : UserRole.proveedor,
    );
  }

  factory Usuario.fromFirebaseMap(Map<String, dynamic> json) {
    return Usuario.withoutPassword(
      username: json['username'],
      fullname: json['fullname'],
      email: json['email'],
      gender: json['gender'],
      profilePicture: json['profilePicture'],
      uid: json['uid'],
      role: json['role'] == 'cliente' ? UserRole.cliente : UserRole.proveedor,
    );
  }
}