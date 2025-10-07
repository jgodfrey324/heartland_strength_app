// Handles fetching of training data for user
import 'package:cloud_firestore/cloud_firestore.dart';

// Workout schema
class Workout {
  final String id;
  final String title;
  final DateTime date;
  final String coachId;
  final List<String> movementIds;

  Workout({
    required this.id,
    required this.title,
    required this.date,
    required this.coachId,
    required this.movementIds,
  });

  factory Workout.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Workout(
      id: doc.id,
      title: data['title'] ?? '',
      date: DateTime(
        data['date'].toDate().year,
        data['date'].toDate().month,
        data['date'].toDate().day,
      ),
      coachId: data['coachId'] ?? '',
      movementIds: List<String>.from(data['movementIds'] ?? []),
    );
  }
}

// Movement schema
class Movement {
  final String id;
  final String name;
  final String description;

  Movement({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Movement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Movement(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
    );
  }
}

// Train service
class TrainService {
  final _firestore = FirebaseFirestore.instance;

  Future<List<Workout>> getUserWorkouts(String userId) async {
    final snapshot = await _firestore
        .collection('workouts')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) => Workout.fromFirestore(doc)).toList();
  }

  Future<List<Movement>> getMovementsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final snapshot = await _firestore
        .collection('movements')
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    return snapshot.docs.map((doc) => Movement.fromFirestore(doc)).toList();
  }
}
