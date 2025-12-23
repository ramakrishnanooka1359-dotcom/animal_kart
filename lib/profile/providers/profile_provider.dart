import 'package:animal_kart_demo2/auth/models/user_model.dart';
import 'package:animal_kart_demo2/network/api_services.dart';
import 'package:animal_kart_demo2/profile/models/%20create_user_request.dart';
import 'package:animal_kart_demo2/profile/models/create_user_response.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserManagementState {
  final bool isLoading;
  final UserModel? currentUser;
  final CreateUserResponse? createUserResponse;
  final String? error;

  UserManagementState({
    this.isLoading = false,
    this.currentUser,
    this.createUserResponse,
    this.error,
  });

  UserManagementState copyWith({
    bool? isLoading,
    UserModel? currentUser,
    CreateUserResponse? createUserResponse,
    String? error,
  }) {
    return UserManagementState(
      isLoading: isLoading ?? this.isLoading,
      currentUser: currentUser ?? this.currentUser,
      createUserResponse: createUserResponse ?? this.createUserResponse,
      error: error ?? this.error,
    );
  }
}

// Combined provider for both fetching and creating users
final userManagementProvider = StateNotifierProvider<UserManagementNotifier, UserManagementState>(
  (ref) => UserManagementNotifier(),
);

class UserManagementNotifier extends StateNotifier<UserManagementState> {
  UserManagementNotifier() : super(UserManagementState());

  // Fetch current user profile
  Future<void> fetchCurrentUser() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userMobile');
      
      if (userId == null) {
        throw Exception('User not logged in');
      }
      
      final user = await ApiServices.fetchUserProfile(userId);
      
      state = state.copyWith(
        isLoading: false,
        currentUser: user,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load profile: ${e.toString()}',
      );
    }
  }

  // Create new user (referral)
  Future<void> createReferralUser({
    required String firstName,
    required String lastName,
    required String mobile,
    required String referedByMobile,
    required String referedByName,
    String role = 'Investor',
  }) async {
    state = state.copyWith(
      isLoading: true, 
      error: null, 
      createUserResponse: null
    );

    try {
      final request = CreateUserRequest(
        firstName: firstName,
        lastName: lastName,
        mobile: mobile,
        referedByMobile: referedByMobile,
        referedByName: referedByName,
        role: role,
      );

      final response = await ApiServices.createUser(request: request);

      if (response != null) {
        state = state.copyWith(
          isLoading: false,
          createUserResponse: response,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to create user. Please try again.',
          createUserResponse: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An error occurred: ${e.toString()}',
        createUserResponse: null,
      );
    }
  }

  // Reset create user state
  void resetCreateUserState() {
    state = state.copyWith(createUserResponse: null, error: null);
  }

  // Clear all state
  void clear() {
    state = UserManagementState();
  }
}

final profileProvider = StateNotifierProvider<UserManagementNotifier, UserManagementState>(
  (ref) => UserManagementNotifier(),
);