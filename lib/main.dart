import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'core/services/supabase_service.dart';
import 'core/theme/military_theme.dart';
import 'features/splash/splash_page.dart';

// ✅ المسار الصحيح للسلة
import 'features/cart/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vpychjqluwggrhyqllbu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZweWNoanFsdXdnZ3JoeXFsbGJ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgzNjUyNDAsImV4cCI6MjA4Mzk0MTI0MH0.toOSNEw9mHtokIGW1kbQhDZwaxB59xsxkklYkVxbEVw',
  );

  WidgetsBinding.instance.addObserver(_AppLifecycleObserver());

  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: const MyApp(),
    ),
  );
}

// ✅ تحديث last seen
class _AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SupabaseService().updateLastSeen();
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tactical Military Store',

      // ✅ تطبيق الثيم العسكري السكري
      theme: MilitaryTheme.theme,

      home: const SplashPage(),
    );
  }
}
