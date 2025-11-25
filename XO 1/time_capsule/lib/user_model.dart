// lib/user_model.dart

class User {
  int? id;
  String email;
  String password; // Note: storing plaintext is simple but not secure for production.

  User({this.id, required this.email, required this.password});

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      email: map['email'] as String,
      password: map['password'] as String,
    );
  }
}
