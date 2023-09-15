import 'package:contract_list/actions/database.dart';
import 'package:contract_list/actions/providers.dart';
import 'package:contract_list/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulHookConsumerWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> {
  void checkAuth() async {
    final userProvider = ref.watch(userStateProvider.notifier);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    print(uid);
    if (uid != null && userProvider.state.loggedin != true) {
      final data = await DatabaseManager().getUser(uid);
      userProvider.updateUser(User(
          name: data['name'], email: data['email'], loggedin: true, uid: uid));
      Navigator.of(context).popAndPushNamed('/contact_list');
      return;
    } else {
      Navigator.of(context).popAndPushNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    checkAuth();
    return const Scaffold(
        body:  Center(
          child: CircularProgressIndicator(
            strokeWidth: 50,
              valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(236, 255, 26, 26))),
        ));
  }
}
