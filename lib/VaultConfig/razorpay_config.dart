class RazorpayConfig {
  // Test keys - Replace with your actual Razorpay keys
  static const String testKeyId = 'rzp_test_qUGkVCBTDKgzOn';
  static const String testKeySecret = 'oiHOEr7h8lw3Mdr1pGSg6tWg';
  
  // Production keys - Replace with your actual Razorpay keys
  static const String productionKeyId = 'rzp_live_YOUR_KEY_ID';
  static const String productionKeySecret = 'YOUR_KEY_SECRET';
  
  // Environment-based key selection
  static const bool isProduction = false; // Set to true for production
  
  static String get keyId => isProduction ? productionKeyId : testKeyId;
  static String get keySecret => isProduction ? productionKeySecret : testKeySecret;
  
  // Payment configuration
  static const String defaultCurrency = 'INR';
  static const String companyName = 'Vault Business';
  static const String companyEmail = 'support@vaultbusiness.com';
  static const String companyContact = '+91XXXXXXXXXX';
  
  // Theme configuration
  static const Map<String, dynamic> themeConfig = {
    'color': '#3B82F6',
    'backdrop_color': '#F9FAFB',
    'hide_topbar': false,
  };
  
  // Payment methods configuration
  static const List<String> preferredPaymentMethods = [
    'card',
    'netbanking',
    'wallet',
    'upi',
  ];
} 