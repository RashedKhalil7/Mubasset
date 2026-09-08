class SignUpData {
  String fullName = '';
  DateTime? dateOfBirth;

  bool acceptedTerms = false;
  bool acceptedOffers = false;

  String email = '';
  String password = '';
  String confirmPassword = '';

  String phoneNumber = '';
  String? avatarPath;

  String registrationToken = '';

  String player_avatar = "";

  List<int> players = [];

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'acceptedTerms': acceptedTerms,
    'acceptedOffers': acceptedOffers,
    'email': email,
    'password': password,
    'confirmPassword': confirmPassword,
    'avatarPath': avatarPath,
    'registrationToken': registrationToken,
  };
}