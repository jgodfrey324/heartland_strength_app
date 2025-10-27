import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

/// Adds a new program document to Firestore.
///
/// [title], [description], and [createdByUserId] are required.
/// [schedule] is a Map of date strings ("YYYY-MM-DD") to lists of workout IDs.
/// Returns the newly created document reference.
Future<DocumentReference> addProgramToFirestore({
  required String title,
  required String description,
  required String createdByUserId,
  required Map<String, List<String>> schedule,
}) async {
  final programData = {
    'title': title.trim(),
    'description': description.trim(),
    'createdBy': createdByUserId,
    'assignedTo': {
      'users': [],
      'teams': [],
    },
    'schedule': schedule,
    'createdAt': FieldValue.serverTimestamp(),
  };

  final docRef = await _firestore.collection('programs').add(programData);
  return docRef;
}

/// Assigns a program to specific teams and users by updating the 'assignedTo' field.
Future<void> assignProgramToTeamsAndUsers({
  required String programId,
  required List<String> teamIds,
  required List<String> userIds,
}) async {
  await _firestore.collection('programs').doc(programId).update({
    'assignedTo': {
      'teams': teamIds,
      'users': userIds,
    },
  });
}
