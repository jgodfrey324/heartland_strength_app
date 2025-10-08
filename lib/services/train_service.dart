// Handles fetching of training data for user
import 'package:cloud_firestore/cloud_firestore.dart';

// Workout schema
class Workout {
  final String id;
  final String title;
  final DateTime date;
  final String coachId;
  final List<WorkoutMovement> movements;

  Workout({
    required this.id,
    required this.title,
    required this.date,
    required this.coachId,
    required this.movements,
  });

  // factory Workout.fromFirestore(DocumentSnapshot doc) {
  //   final data = doc.data() as Map<String, dynamic>;
  //   final rawMovements = List<Map<String, dynamic>>.from(data['movements'] ?? []);

  //   return Workout(
  //     id: doc.id,
  //     title: data['title'] ?? '',
  //     date: DateTime(
  //       data['date'].toDate().year,
  //       data['date'].toDate().month,
  //       data['date'].toDate().day,
  //     ),
  //     coachId: data['coachId'] ?? '',
  //     movements: rawMovements.map((m) => WorkoutMovement.fromMap(m)).toList(),
  //   );
  // }

  factory Workout.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    try {
      final rawMovements = List<Map<String, dynamic>>.from(data['movements'] ?? []);
      final movements = rawMovements.map((m) => WorkoutMovement.fromMap(m)).toList();

      return Workout(
        id: doc.id,
        title: data['title'] ?? '',
        date: DateTime(
          data['date'].toDate().year,
          data['date'].toDate().month,
          data['date'].toDate().day,
        ),
        coachId: data['coachId'] ?? '',
        movements: movements,
      );
    } catch (e, stack) {
      print('❌ Error deserializing workout ${doc.id}: $e');
      print(stack);
      rethrow;
    }
  }

}

class WorkoutMovement {
  final String movementId;
  final Map<String, Map<String, dynamic>> sets;

  WorkoutMovement({
    required this.movementId,
    required this.sets,
  });

  factory WorkoutMovement.fromMap(Map<String, dynamic> map) {
    final rawSets = map['sets'] as Map<String, dynamic>;

    final parsedSets = <String, Map<String, dynamic>>{};

    rawSets.forEach((key, value) {
      if (value is Map) {
        parsedSets[key] = Map<String, dynamic>.from(value);
      } else {
        // Log or skip invalid entries
        print("⚠️ Skipping invalid set at key $key: $value");
      }
    });

    return WorkoutMovement(
      movementId: map['movementId'],
      sets: parsedSets,
    );
  }
}


class SetEntry {
  final int reps;
  final num weightPercent;

  SetEntry({required this.reps, required this.weightPercent});

  factory SetEntry.fromMap(Map<String, dynamic> map) {
    return SetEntry(
      reps: map['reps'] ?? 0,
      weightPercent: map['weightPercent'] ?? 0,
    );
  }
}

// Movement schema
class Movement {
  final String id;
  final String name;
  final String description;
  final String? videoUrl;

  Movement({
    required this.id,
    required this.name,
    required this.description,
    this.videoUrl,
  });

  factory Movement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Movement(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      videoUrl: data['videoUrl'],
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

  Future<Map<String, Movement>> getMovementMapByIds(List<String> ids) async {
    if (ids.isEmpty) return {};

    final snapshot = await _firestore
        .collection('movements')
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    return {
      for (var doc in snapshot.docs)
        doc.id: Movement.fromFirestore(doc),
    };
  }
}
