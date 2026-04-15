import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// GOOGLE LOGIN
  Future<UserCredential> signInWithGoogle() async {

    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
    throw Exception("Login annullato");
    }

    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
    );

    final userCredential =
    await _auth.signInWithCredential(credential);

    await _createUserIfNotExists(userCredential.user!);

    return userCredential;


  }

  Future<void> _createUserIfNotExists(User user) async {

    final ref = _db.collection("users").doc(user.uid);

    final doc = await ref.get();

    if (!doc.exists) {

      await ref.set({

        "email": user.email,
        "name": user.displayName ?? "",
        "shopName": "",
        "role": "retailer",
        "city": "",
        "phone": "",
        "fcmToken": "",
        "createdAt": FieldValue.serverTimestamp(),

      });

    }

  }

  /// REGISTER EMAIL

  Future<UserCredential> signUpEmail({
    required String email,
    required String password,
    required String shopName,
  }) async {

    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await cred.user!.sendEmailVerification();

    await cred.user!.updateDisplayName(shopName);

    await _db.collection("users").doc(cred.user!.uid).set({
      "email": email,
      "name": shopName,
      "shopName": shopName,
      "role": "retailer",
      "city": "",
      "phone": "",
      "createdAt": FieldValue.serverTimestamp(),
    });

    return cred;
  }

  /// LOGIN EMAIL

  Future<UserCredential> loginEmail({
    required String email,
    required String password,
  }) async {

    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

//RECUOPERA PASSWORD
  Future<void> resetPassword({required String email}) async {

    await _auth.sendPasswordResetEmail(email: email);

  }


  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }
}
