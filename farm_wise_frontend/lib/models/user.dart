class User {
  String userId = '',
  userName = '',
      avatarUrl = '',
      mobile = '',
      userType = '',
      email = '',
      houseNoStreetName = '',
      locality = '',
      city = '',
      state = '';
  num pincode = 0, ratings = 0;
  bool verifiedProfile = false, verifyMobile = false;
  List ratedUser = [],favoriteProducts = [];

  User({
    required this.userId,
    required this.userName,
    required this.avatarUrl,
    required this.mobile,
    required this.userType,
    required this.email,
    required this.houseNoStreetName,
    required this.locality,
    required this.city,
    required this.state,
    required this.pincode,
    required this.ratings,
    required this.verifiedProfile,
    required this.verifyMobile,
    required this.ratedUser,
    required this.favoriteProducts,
  });
}
