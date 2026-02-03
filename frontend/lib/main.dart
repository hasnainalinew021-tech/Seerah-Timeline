import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'screen/splash_screen.dart';
import 'screen/dashboard_screen.dart';
import 'package:seerah_timeline/service/favorites_service.dart'; // Added import

// 1. Define a global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    anonKey: "sb_publishable_t9ayeFDKIpuiUcj-2D-MdA_f6qDb2_O",
    url: 'https://hgcarcqmfwmbywrxmpnp.supabase.co',
  );
  await FavoritesService().init(); // Added this line
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
    _handleInitialLink();
  }

  // Handle the initial link when app is opened from email
  void _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      print('📱 Initial link received: $uri');
      if (uri != null) {
        _processDeepLink(uri);
      }
    } catch (e) {
      print('❌ Error handling initial link: $e');
    }
  }

  // Handle links when app is already opened
  void _handleIncomingLinks() {
    _appLinks.uriLinkStream.listen((Uri? uri) {
      print('📱 Incoming link received: $uri');
      if (uri != null) {
        _processDeepLink(uri);
      }
    });
  }

  // Process the deep link and extract auth token
  void _processDeepLink(Uri uri) async {
    try {
      print('🔍 Processing deep link: $uri');

      // Check for Custom Scheme (Preferred for Mobile Redirects)
      final isCustomScheme = uri.scheme == 'io.supabase.seerah_timeline';
      
      // Check for Supabase Auth Verify Link (Legacy/Web flow)
      final isSupabaseLink = uri.host == 'hgcarcqmfwmbywrxmpnp.supabase.co' &&
          uri.path.contains('/auth/v1/verify');

      if (isCustomScheme || isSupabaseLink) {
        print('🔄 Attempting to get session from URL...');
        try {
          // getSessionFromUrl handles both:
          // 1. Redirect URLs with `code` (PKCE) or `#access_token` (Implicit)
          // 2. Direct Verify Links (Magic Link)
          final response = await supabase.auth.getSessionFromUrl(uri, storeSession: true);
          
          if (response.session != null) {
            print('✅ Authentication successful!');
            print('✅ User: ${response.session?.user.email}');
            
            // 3. Navigate to Home Screen using the global key
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
              (route) => false,
            );
          } else {
             print('⚠️ No session created from link.');
          }
        } catch (e) {
          print('❌ Error getting session from URL: $e');
        }
      } else {
        print('ℹ️ Not a recognized auth link');
      }
    } catch (e) {
      print('❌ Error processing deep link: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // 2. Assign the key
      debugShowCheckedModeBanner: false,
      title: 'Digital Seerah',
      home: const SplashScreen(),
    );
  }
}
