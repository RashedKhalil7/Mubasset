class SignUpData {
  String fullName = '';
  DateTime? dateOfBirth;
  bool acceptedTerms = false;

  bool acceptedOffers = false;

  String email = '';
  String password = '';
  String confirmPassword = '';

  String? avatarPath; // local or network path

  String player_avatar="";

  List<int> players=[];

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'acceptedTerms': acceptedTerms,
    'avatarPath': avatarPath,
  };
}