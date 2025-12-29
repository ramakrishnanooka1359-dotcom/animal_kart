import 'package:animal_kart_demo2/auth/models/user_model.dart';
import 'package:animal_kart_demo2/network/api_services.dart';
import 'package:animal_kart_demo2/profile/models/%20create_user_request.dart';
import 'package:animal_kart_demo2/profile/models/create_user_response.dart';
import 'package:animal_kart_demo2/utils/save_user.dart';
import 'package:flutter/foundation.dart';
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

// Provider
final profileProvider =
    StateNotifierProvider<UserManagementNotifier, UserManagementState>(
      (ref) => UserManagementNotifier(),
    );

class UserManagementNotifier extends StateNotifier<UserManagementState> {
  UserManagementNotifier() : super(UserManagementState());

  // Load local profile from SharedPreferences
  Future<void> loadLocalProfile() async {
    try {
      final user = await loadUserFromPrefs();
      if (user != null) {
        state = state.copyWith(currentUser: user);
      }
    } catch (e) {
      debugPrint('Error loading local profile: $e');
    }
  }

  // Fetch current user profile
  Future<void> fetchCurrentUser() async {
    // Start by loading local data if available
    await loadLocalProfile();

    state = state.copyWith(isLoading: true, error: null);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userMobile');

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final user = await ApiServices.fetchUserProfile(userId);

      if (user != null) {
        // Persist newly fetched user data
        await saveUserToPrefs(user);

        state = state.copyWith(
          isLoading: false,
          currentUser: user,
          error: null,
        );
      } else {
        // If user is null but we have local data, don't show error
        state = state.copyWith(
          isLoading: false,
          error: state.currentUser == null ? 'User profile not found' : null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: state.currentUser == null
            ? 'Failed to load profile: ${e.toString()}'
            : null,
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
      createUserResponse: null,
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

        // Refresh profile after successful referral
        await fetchCurrentUser();
      } else {
        // Keep currentUser even if creation fails
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
