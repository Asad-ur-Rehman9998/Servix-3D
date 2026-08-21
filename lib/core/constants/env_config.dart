import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  static String get apiBaseUrl =>
      dotenv.maybeGet('API_BASE_URL') ?? 'https://api.servix3d.example.com/v1';

  static String get googleMapsApiKey =>
      dotenv.maybeGet('GOOGLE_MAPS_API_KEY') ?? '';

  static String get stripePublishableKey =>
      dotenv.maybeGet('STRIPE_PUBLISHABLE_KEY') ?? '';

  static bool get enableMockApi {
    final value = dotenv.maybeGet('ENABLE_MOCK_API') ?? 'true';
    return value.toLowerCase() == 'true';
  }

  static bool get hasMapsKey => googleMapsApiKey.isNotEmpty &&
      !googleMapsApiKey.contains('your_');
}
