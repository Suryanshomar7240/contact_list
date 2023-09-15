import 'package:contract_list/actions/database.dart';
import 'package:contract_list/actions/providers.dart';
import 'package:contract_list/models/user.dart';
import 'package:contract_list/pages/add_contact.dart';
import 'package:contract_list/pages/contact_list.dart';
import 'package:contract_list/pages/loading_screen.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:contract_list/pages/login.dart';
import 'package:contract_list/pages/signup.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? uid;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // uid = prefs.getString('uid');
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

  // Future<void> checkAuth() async {
  //   final userProvider = ref.watch(userStateProvider.notifier);
  //   if (uid != null && userProvider.state.loggedin != true) {
  //     final data = await DatabaseManager().getUser(uid!);
  //     userProvider.updateUser(User(
  //         name: data['name'], email: data['email'], loggedin: true, uid: uid));
  //   }
  // }

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    //   final userProvider = ref.watch(userStateProvider.notifier);
    //   if (uid != null && userProvider.state.loggedin != true) {
    //     final data = await DatabaseManager().getUser(uid!);
    //     userProvider.updateUser(User(
    //         name: data['name'],
    //         email: data['email'],
    //         loggedin: true,
    //         uid: uid));
    //   }
    // });
  }
  @override
  Widget build(BuildContext context) {
    final userProvider = ref.watch(userStateProvider);
    print(userProvider.email);
    return MaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: '/loading',
            routes: {
                '/login': (context) => const LoginPage(),
                '/loading': (context) => const LoadingScreen(),
                '/signup': (context) => const SignupPage(),
                '/contact_list': (context) => const ContactList(),
                '/add_contact': (context) => const AddContact(),
              });
  }
}