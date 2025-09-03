class Environment {
  // Get from environment variables or secure storage
  static String get supabaseUrl => const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://cgabgqjnggxztmkbigrt.supabase.co');
  static String get supabaseAnonKey => const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNnYWJncWpuZ2d4enRta2JpZ3J0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI5MDUyMDUsImV4cCI6MjA2ODQ4MTIwNX0.AA3xeTBcAS9hOTaTfN7aLlTUul8X-8XWue7ix2-iuCI');
  
  // Build configuration
  static const bool isProduction = bool.fromEnvironment('PRODUCTION', defaultValue: false);
  static const bool enableDebugLogs = bool.fromEnvironment('DEBUG_LOGS', defaultValue: true);
  static const bool enableDevelopmentFeatures = bool.fromEnvironment('DEV_FEATURES', defaultValue: true);
  
  // Database settings
  static const String defaultDataPath = String.fromEnvironment('DATA_PATH', defaultValue: r'C:\faroffvstudio\vault\data');
  static const bool useFixedPath = bool.fromEnvironment('USE_FIXED_PATH', defaultValue: true);
  
  // App settings
  static const String appName = 'Vault Business';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Security - Never hardcode passwords
  static String get defaultPassword => const String.fromEnvironment('DEFAULT_PASSWORD', defaultValue: 'ChangeMe123!');
}