import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

String getUserID(context) {
  return context.watch<AuthProvider>().userID;
}

Future<String?> getUserToken(context) async {
  return context.watch<AuthProvider>().userToken;
}

Future<String?> tryAppleLogin() async {
  final appleProvider = AppleAuthProvider();
  appleProvider.addScope('email');
  await FirebaseAuth.instance.signInWithProvider(appleProvider);

  return await FirebaseAuth.instance.currentUser!.getIdToken();
}

Future<String?> tryGoogleLogin() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );
  await FirebaseAuth.instance.signInWithCredential(credential);

  return await FirebaseAuth.instance.currentUser!.getIdToken();
}

Future<void> tryLogin(context, var type) async {
  (type == 0 ? tryGoogleLogin() : tryAppleLogin()).then((userToken) => {
    http.post(Uri.parse("https://socdoc.dev-lr.com/api/user/login"),
      headers: {
        "authToken": userToken!
      }).then((value){
      context.watch<AuthProvider>().updateUser(FirebaseAuth.instance.currentUser!.uid, userToken);
    })});
}

Future<bool> tryLogout() async {
  await FirebaseAuth.instance.signOut();
  return (FirebaseAuth.instance.currentUser == null);
}

Future<bool> tryDeleteUser() async {
  if(FirebaseAuth.instance.currentUser != null){
    return http.delete(
      Uri.parse("https://socdoc.dev-lr.com/api/user?userId=${FirebaseAuth.instance.currentUser!.uid}")
    ).then((value) => tryLogout());
  }

  return false;
}