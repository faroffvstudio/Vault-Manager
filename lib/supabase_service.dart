// ignore_for_file: empty_catches

import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../VaultConfig/environment.dart';

class SupabaseService {
  // Get the already initialized Supabase client
  static SupabaseClient get client => Supabase.instance.client;

  // AUTHENTICATION METHODS

  /// Sign up a new user with email and password
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? userMetadata,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: userMetadata,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with email and password
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Sign in with stored auth data (email/password)
  static Future<AuthResponse> signInWithStoredAuth(Map<String, dynamic> authData) async {
    try {
      final email = authData['email']?.toString();
      final password = authData['password']?.toString();
      
      if (email != null && password != null) {
        return await signInWithEmail(email: email, password: password);
      } else {
        throw Exception('Email or password not found in stored auth data');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out the current user
  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
      if (!Environment.isProduction) {}
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user
  static User? getCurrentUser() {
    return client.auth.currentUser;
  }

  /// Check if user is authenticated
  static bool isAuthenticated() {
    return client.auth.currentUser != null;
  }

  /// Get current session
  static Session? getCurrentSession() {
    return client.auth.currentSession;
  }

  /// Listen to auth state changes
  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  /// Get organizations by user ID
  static Future<List<Map<String, dynamic>>> getOrganizationsByUserId(
    String userId,
  ) async {
    try {
      // First, try to get organizations from organization table
      List<Map<String, dynamic>> profiles = [];
      try {
        final profileResponse = await client
            .from('organization_metadata')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false);

        profiles = (profileResponse as List).map((profile) {
          final Map<String, dynamic> profileMap = Map<String, dynamic>.from(
            profile,
          );
          if (profileMap['subscription_plan'] != null) {
            profileMap['subscription_plan'] = jsonDecode(
              profileMap['subscription_plan'],
            );
          }
          return profileMap;
        }).toList();
      } catch (profileError) {
        if (!Environment.isProduction) {}
      }

      // If no profiles found, try to get organizations from organizations table that belong to this user
      if (profiles.isEmpty) {
        try {
          // Get current user's email for filtering
          final currentUser = client.auth.currentUser;
          final userEmail = currentUser?.email;

          // Try to get organizations by user_id first, then by email if no user_id match
          List<dynamic> orgResponse = [];

          try {
            // First try with user_id
            orgResponse = await client
                .from('organization_metadata')
                .select()
                .eq('user_id', userId)
                .order('created_at', ascending: false);
          } catch (e) {}

          // If no results and we have email, try by email
          if (orgResponse.isEmpty && userEmail != null) {
            try {
              orgResponse = await client
                  .from('organization_metadata')
                  .select()
                  .eq('user_email', userEmail)
                  .order('created_at', ascending: false);
            } catch (e) {}
          }

          // If still no results, try to get all and filter by current user's email
          if (orgResponse.isEmpty && userEmail != null) {
            try {
              final allOrgs = await client
                  .from('organization_metadata')
                  .select()
                  .order('created_at', ascending: false);

              // For organizations with null user_id/user_email, assign them to current user
              // This handles legacy organizations that weren't properly linked
              orgResponse = allOrgs.where((org) {
                final orgEmail = org['user_email']?.toString();
                final orgUserId = org['user_id']?.toString();

                // Match by email, user_id, or if both are null (legacy organizations)
                return orgEmail == userEmail ||
                    orgUserId == userId ||
                    (orgEmail == null && orgUserId == null);
              }).toList();

              // Update existing organizations to link them to current user
              for (final org in orgResponse) {
                if (org['user_id'] == null || org['user_email'] == null) {
                  try {
                    await client
                        .from('organization_metadata')
                        .update({
                          'user_id': userId,
                          'user_email': userEmail,
                          'updated_at': DateTime.now().toIso8601String(),
                        })
                        .eq('id', org['id']);

                    // Update the org data in memory too
                    org['user_id'] = userId;
                    org['user_email'] = userEmail;
                  } catch (updateError) {}
                }
              }
            } catch (e) {}
          }

          final organizations = orgResponse.map((org) {
            final Map<String, dynamic> orgMap = Map<String, dynamic>.from(org);
            // Ensure user_id is set correctly
            orgMap['user_id'] = userId;
            orgMap['organization_id'] = orgMap['id'] ?? orgMap['fvs_id'];
            orgMap['user_email'] = userEmail; // Set current user's email
            return orgMap;
          }).toList();

          if (!Environment.isProduction) {}

          return organizations;
        } catch (orgError) {
          if (!Environment.isProduction) {}
        }
      }

      // Return only the user's organizations - no fallback to all organizations
      return profiles;
    } catch (e) {
      return [];
    }
  }

  /// Get organization data from Supabase storage by organization ID
  static Future<Map<String, dynamic>?> getOrganizationDataFromStorage(
    String organizationId,
  ) async {
    try {} catch (e) {
      return null;
    }
    return null;
  }

  /// Get all users who registered through organization creation (ADMIN ONLY)
  /// WARNING: This method returns all organizations - should only be used by administrators
  static Future<List<Map<String, dynamic>>> getAllOrganizationUsers() async {
    try {
      // Check if current user has admin privileges (implement your admin check here)
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        return [];
      }

      // Try organization table first
      try {
        final response = await client
            .from('organization_metadata')
            .select('*')
            .order('created_at', ascending: false);

        final users = (response as List).map((user) {
          final Map<String, dynamic> userMap = Map<String, dynamic>.from(user);
          if (userMap['subscription_plan'] != null) {
            try {
              userMap['subscription_plan'] = jsonDecode(
                userMap['subscription_plan'],
              );
            } catch (e) {
              // If JSON decode fails, keep as string
            }
          }
          return userMap;
        }).toList();

        if (users.isNotEmpty) {
          return users;
        }
      } catch (e) {}

      // Try organizations table as fallback
      try {
        final response = await client
            .from('organization_metadata')
            .select('*')
            .order('created_at', ascending: false);

        final users = (response as List).map((user) {
          final Map<String, dynamic> userMap = Map<String, dynamic>.from(user);
          return userMap;
        }).toList();

        return users;
      } catch (e) {}

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get count of users who registered through organization creation
  static Future<int> getOrganizationUsersCount() async {
    try {
      final users = await getAllOrganizationUsers();
      return users.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get all users for community chat from organizations_metadata table
  static Future<List<Map<String, dynamic>>> getCommunityUsers() async {
    try {
      // Get ALL organizations without any user filter
      final response = await client
          .from('organizations_metadata')
          .select('*')
          .order('created_at', ascending: false);

      print('📊 Supabase Response: ${response.length} organizations found');
      
      return (response as List).map((user) {
        final Map<String, dynamic> userMap = Map<String, dynamic>.from(user);
        return {
          'user_id': userMap['company_name']?.toString().replaceAll(' ', '_').toLowerCase() ?? '',
          'name': userMap['company_name'] ?? 'Unknown Company',
          'user_name': userMap['company_name'] ?? 'Unknown Company',
          'email': userMap['email'] ?? '',
          'phone': userMap['phone'] ?? '',
          'organization_name': userMap['company_name'] ?? '',
          'last_active': userMap['created_at'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('❌ Get Community Users Error: $e');
      return [];
    }
  }
}
