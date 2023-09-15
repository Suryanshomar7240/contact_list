import 'package:contract_list/actions/providers.dart';
import 'package:contract_list/pages/add_contact.dart';
import 'package:contract_list/pages/contact_list.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:contract_list/pages/login.dart';
import 'package:contract_list/pages/signup.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatefulHookConsumerWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final userProvider = ref.watch(userStateProvider);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute:
            userProvider.loggedin != null && userProvider.loggedin == true
                ? '/contact_list'
                : '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignupPage(),
          '/contact_list': (context) => const ContactList(),
          '/add_contact': (context) => const AddContact(),
        });
  }
}
