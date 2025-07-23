import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String address,
    String? dateOfBirth,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'address': address,
        'dateOfBirth': dateOfBirth,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      throw e;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw e;
    }
  }

  // Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null; // user cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final user = userCredential.user;

      // Check if user exists in Firestore
      final userDoc =
          await _firestore.collection('users').doc(user!.uid).get();

      if (!userDoc.exists) {
        // Create user profile
        await _firestore.collection('users').doc(user.uid).set({
          'fullName': user.displayName ?? '',
          'email': user.email,
          'phoneNumber': user.phoneNumber ?? '',
          'address': '',
          'dateOfBirth': '',
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } catch (e) {
      throw e;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw e;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut(); // Sign out from Google as well
    } catch (e) {
      throw e;
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    required String fullName,
    required String email,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'fullName': fullName,
        'email': email,
      });
    } catch (e) {
      throw e;
    }
  }
}
