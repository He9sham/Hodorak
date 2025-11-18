import 'package:hodorak/core/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  // Authentication methods
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? userMetadata,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: userMetadata,
    );
  }

  static Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static User? get currentUser => client.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;

  // Database methods
  static PostgrestQueryBuilder from(String table) {
    return client.from(table);
  }

  // Real-time subscriptions
  static RealtimeChannel channel(String name) {
    return client.channel(name);
  }

  // Storage methods (for file uploads)
  static SupabaseStorageClient get storage => client.storage;
}
