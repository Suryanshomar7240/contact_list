class User {
  String? name;
  String? email;
  bool? loggedin;
  String? uid;
  User({this.name, this.email, this.loggedin, this.uid});
  User copyWith({String? name, String? email, bool? loggedin, String? uid}) {
    return User(
        name: name ?? this.name,
        email: email ?? this.email,
        loggedin: loggedin ?? this.loggedin,
        uid: uid ?? this.uid);
  }
}
