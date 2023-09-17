import 'package:contract_list/actions/providers.dart';
import 'package:flutter/material.dart';
import 'package:contract_list/actions/auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginPage extends StatefulHookConsumerWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final AuthService _auth = AuthService();
  String email = "";
  String password = "";
  String error = "";
  bool loading = false;
  late GlobalKey<FormState>? _formKey;
  @override
  initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.read(userStateProvider.notifier);
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: SafeArea(
        child: Scaffold(
            body: Center(
          child: loading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromARGB(236, 255, 26, 26)))
              : Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Center(
                            child: Text("Login!",
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600))),
                        const SizedBox(height: 50),
                        //Username and password
                        Form(
                          key: _formKey,
                          child: Column(children: [
                            Text(error,
                                style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 5),
                            TextFormField(
                              onChanged: (val) => email = val,
                              validator: (val) =>
                                  val!.isEmpty && val.contains("@")
                                      ? "Enter a valid Email"
                                      : null,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  labelText: 'Email'),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              onChanged: (val) => password = val,
                              validator: (val) =>
                                  val!.isEmpty ? "Enter password" : null,
                              obscureText: true,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  labelText: 'Password'),
                            ),
                            const SizedBox(height: 25),
                            InkWell(
                              onTap: () async {
                                setState(() {
                                  loading = true;
                                });
                                if (_formKey!.currentState!.validate()) {
                                  AuthResponse response =
                                      await _auth.signInwithEmailandPassword(
                                          email, password);
                                  if (response.status == 404) {
                                    setState(() {
                                      error = response.message;
                                      loading = false;
                                    });
                                    return;
                                  }
                                  userState.updateUser(response.user!);
                                  Navigator.of(context)
                                      .popAndPushNamed('/contact_list');
                                }
                                setState(() {
                                  loading = false;
                                });
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.65,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(236, 255, 26, 26),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Color.fromARGB(
                                              169, 255, 160, 160),
                                          offset: Offset(
                                            10.0,
                                            12.0,
                                          ),
                                          blurRadius: 10.0,
                                          spreadRadius: 1.0)
                                    ]),
                                child: const Text('Login',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 15),
                        Center(
                          child: Text(" OR ",
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(height: 15),
                        InkWell(
                          onTap: () async {
                            setState(() {
                              loading = true;
                            });
                            AuthResponse response =
                                await _auth.registerWithGoogle();
                            if (response.status == 404) {
                              setState(() {
                                error = response.message;
                                loading = false;
                              });
                              return;
                            }
                            userState.updateUser(response.user!);
                            Navigator.of(context)
                                .popAndPushNamed('/contact_list');
                            setState(() {
                              loading = false;
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.65,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey[400] ?? Colors.black,
                                      offset: const Offset(
                                        10.0,
                                        10.0,
                                      ),
                                      blurRadius: 10.0,
                                      spreadRadius: 1.0)
                                ]),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Image.asset(
                                  'assets/google_logo.png',
                                  height: 35,
                                ),
                                Text('Login with Google',
                                    style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: () async {
                          setState(() {
                              loading = true;
                            });
                            AuthResponse response =
                                await _auth.registerWithFacebook();
                            if (response.status == 404) {
                              setState(() {
                                error = response.message;
                                loading = false;
                              });
                              return;
                            }
                            userState.updateUser(response.user!);
                            Navigator.of(context)
                                .popAndPushNamed('/contact_list');
                            setState(() {
                              loading = false;
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.65,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey[400] ?? Colors.black,
                                      offset: const Offset(
                                        10.0,
                                        10.0,
                                      ),
                                      blurRadius: 10.0,
                                      spreadRadius: 1.0)
                                ]),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Image.asset(
                                  'assets/facebook.jpeg',
                                  height: 35,
                                ),
                                Text('Login with Facebook',
                                    style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have and account? "),
                            InkWell(
                                onTap: () {
                                  Navigator.of(context)
                                      .popAndPushNamed('/signup');
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text("Register",
                                      style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontSize: 14)),
                                ))
                          ],
                        )
                      ],
                    ),
                  ),
                ),
        )),
      ),
    );
  }
}
