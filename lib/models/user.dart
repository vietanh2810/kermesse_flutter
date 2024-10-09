

class Organizer {
  final int userId;
  final User? user;

  Organizer({required this.userId, this.user});

  factory Organizer.fromJson(Map<String, dynamic> json) {
    return Organizer(
      userId: json['UserID'],
      user: json['User'] != null ? User.fromJson(json['User']) : null,
    );
  }
}

class Student {
  final int userId;
  final User? user;
  final int points;
  final int tokens;
  final int? parentId;
  final bool isActive;

  Student({
    required this.userId,
    this.user,
    required this.points,
    required this.tokens,
    this.parentId,
    required this.isActive,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      userId: json['UserID'],
      user: json['User'] != null ? User.fromJson(json['User']) : null,
      points: json['points'],
      tokens: json['tokens'],
      parentId: json['parent_id'],
      isActive: json['is_active'],
    );
  }
}

class User {
  final int id;
  final String email;
  final String name;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? tokens;
  final List<Student>? students;
  final int? standId;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.tokens,
    this.students,
    this.standId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      tokens: json['tokens'],
      students: json['students'] != null
          ? List<Student>.from(json['students'].map((x) => Student.fromJson(x)))
          : null,
      standId: json['stand_id'],
    );
  }
}