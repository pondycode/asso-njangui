import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'member.g.dart';

@HiveType(typeId: 0)
enum MemberStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  inactive,
  @HiveField(2)
  suspended,
  @HiveField(3)
  pending,
}

@HiveType(typeId: 1)
class Member extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final String? email;

  @HiveField(4)
  final String phoneNumber;

  @HiveField(5)
  final String? address;

  @HiveField(6)
  final DateTime dateOfBirth;

  @HiveField(7)
  final DateTime joinDate;

  @HiveField(8)
  final MemberStatus status;

  @HiveField(9)
  final String? profileImagePath;

  @HiveField(10)
  final String? nationalId;

  @HiveField(11)
  final String? occupation;

  @HiveField(12)
  final double totalSavings;

  @HiveField(13)
  final double totalInvestments;

  @HiveField(14)
  final double emergencyFund;

  @HiveField(15)
  final double outstandingLoans;

  @HiveField(16)
  final DateTime lastActivityDate;

  @HiveField(17)
  final Map<String, dynamic> metadata;

  const Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    required this.phoneNumber,
    this.address,
    required this.dateOfBirth,
    required this.joinDate,
    required this.status,
    this.profileImagePath,
    this.nationalId,
    this.occupation,
    this.totalSavings = 0.0,
    this.totalInvestments = 0.0,
    this.emergencyFund = 0.0,
    this.outstandingLoans = 0.0,
    required this.lastActivityDate,
    this.metadata = const {},
  });

  String get fullName => '$firstName $lastName';

  double get totalBalance => totalSavings + totalInvestments + emergencyFund;

  double get netWorth => totalBalance - outstandingLoans;

  bool get isActive => status == MemberStatus.active;

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  int get membershipDuration {
    final now = DateTime.now();
    return now.difference(joinDate).inDays;
  }

  Member copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? address,
    DateTime? dateOfBirth,
    DateTime? joinDate,
    MemberStatus? status,
    String? profileImagePath,
    String? nationalId,
    String? occupation,
    double? totalSavings,
    double? totalInvestments,
    double? emergencyFund,
    double? outstandingLoans,
    DateTime? lastActivityDate,
    Map<String, dynamic>? metadata,
  }) {
    return Member(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      joinDate: joinDate ?? this.joinDate,
      status: status ?? this.status,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      nationalId: nationalId ?? this.nationalId,
      occupation: occupation ?? this.occupation,
      totalSavings: totalSavings ?? this.totalSavings,
      totalInvestments: totalInvestments ?? this.totalInvestments,
      emergencyFund: emergencyFund ?? this.emergencyFund,
      outstandingLoans: outstandingLoans ?? this.outstandingLoans,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    phoneNumber,
    address,
    dateOfBirth,
    joinDate,
    status,
    profileImagePath,
    nationalId,
    occupation,
    totalSavings,
    totalInvestments,
    emergencyFund,
    outstandingLoans,
    lastActivityDate,
    metadata,
  ];

  @override
  String toString() {
    return 'Member(id: $id, name: $fullName, status: $status, totalBalance: $totalBalance)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'joinDate': joinDate.toIso8601String(),
      'status': status.name,
      'profileImagePath': profileImagePath,
      'nationalId': nationalId,
      'occupation': occupation,
      'totalSavings': totalSavings,
      'totalInvestments': totalInvestments,
      'emergencyFund': emergencyFund,
      'outstandingLoans': outstandingLoans,
      'lastActivityDate': lastActivityDate.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      joinDate: DateTime.parse(json['joinDate']),
      status: MemberStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MemberStatus.pending,
      ),
      profileImagePath: json['profileImagePath'],
      nationalId: json['nationalId'],
      occupation: json['occupation'],
      totalSavings: (json['totalSavings'] ?? 0.0).toDouble(),
      totalInvestments: (json['totalInvestments'] ?? 0.0).toDouble(),
      emergencyFund: (json['emergencyFund'] ?? 0.0).toDouble(),
      outstandingLoans: (json['outstandingLoans'] ?? 0.0).toDouble(),
      lastActivityDate: DateTime.parse(json['lastActivityDate']),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}
