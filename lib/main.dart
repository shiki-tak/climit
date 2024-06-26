import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:climit/providers/wallet_provider.dart';
import 'package:climit/screens/create_account.dart';
import 'package:climit/screens/home/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final globalScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final String bundlerUrlKey = dotenv.get('BUNDLER_RPC_URL_KEY');
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => WalletProvider(bundlerUrlKey)),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      child: MaterialApp(
        title: 'Variance Dart',
        routes: {
          '/': (context) => const CreateAccountScreen(),
          '/home': (context) => const WalletHome(),
        },
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffE1FF01)),
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
