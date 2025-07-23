import 'package:cloud_firestore/cloud_firestore.dart';

class DonorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register as a donor
  Future<void> registerDonor({
    required String userId,
    required String name,
    required String email,
    required String bloodGroup,
    required int age,
    required String cnicNumber,
    required String phoneNumber,
    required String gender,
    required String city,
    required String area,
  }) async {
    try {
      await _firestore.collection('donors').doc(userId).set({
        'userId': userId,
        'name': name,
        'email': email,
        'bloodGroup': bloodGroup,
        'age': age,
        'cnicNumber': cnicNumber,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'city': city,
        'area': area,
        'isAvailable': true,
        'registeredAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw e;
    }
  }

  // Get all donors with filters
  Future<List<Map<String, dynamic>>> getDonors({
    String? bloodGroup,
    String? gender,
    String? city,
  }) async {
    try {
      Query query = _firestore.collection('donors').where('isAvailable', isEqualTo: true);

      if (bloodGroup != null && bloodGroup != 'All') {
        query = query.where('bloodGroup', isEqualTo: bloodGroup);
      }
      if (gender != null && gender != 'All') {
        query = query.where('gender', isEqualTo: gender);
      }
      if (city != null && city != 'All') {
        query = query.where('city', isEqualTo: city);
      }

      final QuerySnapshot snapshot = await query.get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      throw e;
    }
  }

  // Get donor details by ID
  Future<Map<String, dynamic>?> getDonorById(String donorId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('donors').doc(donorId).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      throw e;
    }
  }

  // Update donor availability
  Future<void> updateDonorAvailability(String donorId, bool isAvailable) async {
    try {
      await _firestore.collection('donors').doc(donorId).update({
        'isAvailable': isAvailable,
      });
    } catch (e) {
      throw e;
    }
  }
}