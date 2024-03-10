import '../models/user.dart';

var loggedInUserDetails = User(
    userId: '',
    userName: '',
    avatarUrl: '',
    mobile: '',
    userType: '',
    email: '',
    houseNoStreetName: '',
    locality: '',
    city: '',
    state: '',
    pincode: 0,
    ratings: 0,
    verifiedProfile: false,
    verifyMobile: false,
    ratedUser: [],
    favoriteProducts: []);

var loggedInUserAuthToken = '';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:farm_wise_frontend/models/user.dart';

// class UserDetailsNotifier extends StateNotifier<User> {
//   UserDetailsNotifier()
//       : super(
//           User(
//             userId: '',
//             userName: '',
//             avatarUrl: '',
//             mobile: '',
//             userType: '',
//             email: '',
//             houseNoStreetName: '',
//             locality: '',
//             city: '',
//             state: '',
//             pincode: 0,
//             ratings: 0,
//             verifiedProfile: false,
//             verifyMobile: false,
//           ),
//         );

  
// }

// final userAuthDetailsProvider = StateNotifierProvider((ref) {
//   return '64b3976c8d5d55f00fcc7754';
// });
