import 'dart:io';

class AppConfig {
  // Default vault data path - production ready
  // ignore: constant_identifier_names
  static const String DEFAULT_VAULT_PATH = r'C:\faroffvstudio\vault\data';
  
  // Check if custom path is set via environment variable
  static String get vaultDataPath {
    // Check environment variable first
    final envPath = Platform.environment['VAULT_DATA_PATH'];
    if (envPath != null && envPath.isNotEmpty) {
      return envPath;
    }
    
    // Default to original path
    return DEFAULT_VAULT_PATH;
  }
  
  // Check if should use fixed path (default: true for C: drive)
  static bool get useFixedPath {
    final envUseFixed = Platform.environment['VAULT_USE_FIXED_PATH'];
    if (envUseFixed != null) {
      return envUseFixed.toLowerCase() == 'true';
    }
    return true; // Use C: drive by default
  }
  
  // Get full database path (deprecated - now using individual company databases)
  static String get globalDatabasePath {
    return '$vaultDataPath\\vault_global.db';
  }
  
  // Create vault directory if it doesn't exist
  static void ensureVaultDirectoryExists() {
    final directory = Directory(vaultDataPath);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
  }
}
