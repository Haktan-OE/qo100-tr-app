import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qo100_tr/features/profile/domain/exceptions/profile_exceptions.dart';

abstract interface class FirestoreUserProfileDataSource {
  String? get currentUid;

  Stream<String?> watchUid();

  Future<Map<String, dynamic>?> getProfile(String uid);

  Stream<Map<String, dynamic>?> watchProfile(String uid);

  Future<void> setProfile(String uid, Map<String, dynamic> data);
}

class FirebaseFirestoreUserProfileDataSource
    implements FirestoreUserProfileDataSource {
  FirebaseFirestoreUserProfileDataSource(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  String? get currentUid => _auth.currentUser?.uid;

  @override
  Stream<String?> watchUid() => _auth
      .authStateChanges()
      .map((user) => user?.uid)
      .handleError((_) => throw ProfileInfrastructureException());

  @override
  Future<Map<String, dynamic>?> getProfile(String uid) async {
    try {
      return (await _profileDocument(uid).get()).data();
    } on FirebaseException {
      throw ProfileInfrastructureException();
    }
  }

  @override
  Stream<Map<String, dynamic>?> watchProfile(String uid) {
    return _profileDocument(uid)
        .snapshots()
        .map((snapshot) => snapshot.data())
        .handleError((_) => throw ProfileInfrastructureException());
  }

  @override
  Future<void> setProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _profileDocument(uid).set(data);
    } on FirebaseException {
      throw ProfileInfrastructureException();
    }
  }

  DocumentReference<Map<String, dynamic>> _profileDocument(String uid) {
    return _firestore.collection('users').doc(uid);
  }
}
