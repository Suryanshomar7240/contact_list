import 'package:contract_list/actions/database.dart';
import 'package:contract_list/models/user.dart' as appuser;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthResponse {
  int status;
  String message;
  appuser.User? user;
  AuthResponse({required this.status, required this.message, this.user});
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<AuthResponse> registerwithEmailandPassword(
    String email,
    String name,
    String password,
  ) async {
    try {
      final userCredentail = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await DatabaseManager()
          .createUserData(name, email, userCredentail.user!.uid);
      return AuthResponse(
          status: 200,
          message: "Registered successfully",
          user: appuser.User(
              email: email,
              name: name,
              loggedin: true,
              uid: userCredentail.user!.uid));
    } on FirebaseAuthException catch (e) {
      return AuthResponse(status: 404, message: e.message!);
    }
  }

  Future<AuthResponse> signInwithEmailandPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredentail = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      dynamic userData =
          await DatabaseManager().getUser(userCredentail.user!.uid);

      return AuthResponse(
          status: 200,
          message: "Logged in successfully",
          user: appuser.User(
              name: userData['name'],
              email: userData['email'],
              loggedin: true,
              uid: userCredentail.user!.uid));
    } on FirebaseAuthException catch (e) {
      return AuthResponse(status: 404, message: e.message!);
    }
  }

  Future<AuthResponse> registerWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount == null) throw "Google Signup failed";
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      AuthCredential googleCredintials = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken);
      await _auth.signInWithCredential(googleCredintials);

      // print();
      await DatabaseManager().createUserData(googleSignInAccount.displayName!,
          googleSignInAccount.email, _auth.currentUser!.uid);
      return AuthResponse(
          status: 200,
          message: "Registered successfully",
          user: appuser.User(
              email: googleSignInAccount.email,
              name: googleSignInAccount.displayName!,
              loggedin: true,
              uid: _auth.currentUser!.uid));
    } on Exception catch (e) {
      return AuthResponse(status: 404, message: e.toString());
    }
  }

  Future<AuthResponse> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount == null) throw "Google Sign In failed";

      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      AuthCredential googleCredintials = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken);
      await _auth.signInWithCredential(googleCredintials);

      dynamic userData =
          await DatabaseManager().getUser(_auth.currentUser!.uid);

      return AuthResponse(
          status: 200,
          message: "Logged in successfully",
          user: appuser.User(
              name: userData['name'],
              email: userData['email'],
              loggedin: true,
              uid: _auth.currentUser!.uid));
    } on FirebaseAuthException catch (e) {
      return AuthResponse(status: 404, message: e.message!);
    }
  }

  // Future<AuthUser?> registerWithFacebook() async {
  //   final facebookLogin =
  //       await FacebookAuth.instance.login(permissions: ['email']);
  //   if (facebookLogin == LoginStatus.success) {
  //     final user = await FacebookAuth.instance.getUserData();
  //     AuthCredential facebookCrendentials=FacebookAuthProvider.credential(accessToken)
  //   }
  // }

  //function to implement Sign out
  String userid() {
    return _auth.currentUser!.uid;
  }

  Future signout() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return e;
    }
  }
}
