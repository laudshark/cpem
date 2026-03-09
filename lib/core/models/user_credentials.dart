class UserCredentials {
  const UserCredentials({
    required this.fullName,
    required this.businessName,
    required this.emailAddress,
    required this.phoneNumber,
    required this.roleTitle,
  });

  const UserCredentials.empty()
      : fullName = '',
        businessName = '',
        emailAddress = '',
        phoneNumber = '',
        roleTitle = '';

  final String fullName;
  final String businessName;
  final String emailAddress;
  final String phoneNumber;
  final String roleTitle;

  bool get isComplete {
    return fullName.trim().isNotEmpty &&
        businessName.trim().isNotEmpty &&
        emailAddress.trim().isNotEmpty &&
        phoneNumber.trim().isNotEmpty;
  }

  String get completionLabel => isComplete ? 'Ready' : 'Needs setup';

  UserCredentials copyWith({
    String? fullName,
    String? businessName,
    String? emailAddress,
    String? phoneNumber,
    String? roleTitle,
  }) {
    return UserCredentials(
      fullName: fullName ?? this.fullName,
      businessName: businessName ?? this.businessName,
      emailAddress: emailAddress ?? this.emailAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      roleTitle: roleTitle ?? this.roleTitle,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'fullName': fullName,
      'businessName': businessName,
      'emailAddress': emailAddress,
      'phoneNumber': phoneNumber,
      'roleTitle': roleTitle,
    };
  }

  factory UserCredentials.fromJson(Map<String, dynamic> json) {
    return UserCredentials(
      fullName: json['fullName'] as String? ?? '',
      businessName: json['businessName'] as String? ?? '',
      emailAddress: json['emailAddress'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      roleTitle: json['roleTitle'] as String? ?? '',
    );
  }
}
