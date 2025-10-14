import 'package:cloud_firestore/cloud_firestore.dart';

/// --------------------
/// Models
/// --------------------

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

  factory Workout.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception('Workout document ${doc.id} has no data');
    }

    try {
      // movements is a List of Map<String, dynamic>
      final rawMovements = data['movements'] as List<dynamic>? ?? [];

      final movements = rawMovements.map((movementData) {
        if (movementData is Map<String, dynamic>) {
          return WorkoutMovement.fromMap(movementData);
        } else {
          throw Exception('Invalid movement data type in movements array');
        }
      }).toList();

      return Workout(
        id: doc.id,
        title: data['title'] as String? ?? '',
        date: data['date'] != null ? (data['date'] as Timestamp).toDate() : DateTime.now(),
        coachId: data['coachId'] as String? ?? '',
        movements: movements,
      );
    } catch (e, stack) {
      print('❌ Error deserializing workout ${doc.id}: $e');
      print(stack);
      rethrow;
    }
  }
}

class Movement {
  final String id;
  final String title;
  final String description;
  final String videoUrl;

  Movement({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
  });

  factory Movement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception('Movement document ${doc.id} has no data');
    }

    return Movement(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      videoUrl: data['videoUrl'] as String? ?? '',
    );
  }
}

class WorkoutMovement {
  final String movementId;
  final List<Map<String, dynamic>> sets;

  WorkoutMovement({
    required this.movementId,
    required this.sets,
  });

  factory WorkoutMovement.fromMap(Map<String, dynamic> map) {
    final rawSets = map['sets'];
    List<Map<String, dynamic>> parsedSets = [];

    if (rawSets is List) {
      // Each element should be Map<String, dynamic>
      parsedSets = rawSets.whereType<Map<String, dynamic>>().toList();
    } else if (rawSets is Map<String, dynamic>) {
      // If somehow it's a map, convert it to list of maps (optional fallback)
      parsedSets = rawSets.entries
          .map((e) => e.value)
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    return WorkoutMovement(
      movementId: map['movementId'] as String? ?? '',
      sets: parsedSets,
    );
  }
}

class MovementData {
  String? movementId;
  String? movementName;
  List<SetData> sets;

  MovementData({
    this.movementId,
    this.movementName,
    required this.sets,
  });

  Map<String, dynamic> toJson() => {
        'movementId': movementId,
        'movementName': movementName,
        'sets': sets.map((s) => s.toJson()).toList(),
      };

  factory MovementData.fromMap(Map<String, dynamic> map, {String? movementName}) {
    final setsList = (map['sets'] as List<dynamic>? ?? [])
        .map((s) => SetData.fromMap(s as Map<String, dynamic>))
        .toList();
    return MovementData(
      movementId: map['movementId'] as String?,
      movementName: movementName,
      sets: setsList,
    );
  }
}

class SetData {
  String reps;
  String weightPercent;

  SetData({required this.reps, required this.weightPercent});

  Map<String, dynamic> toJson() => {
        'reps': int.tryParse(reps) ?? 0,
        'weightPercent': double.tryParse(weightPercent) ?? 0.0,
      };

  factory SetData.fromMap(Map<String, dynamic> map) {
    return SetData(
      reps: (map['reps'] ?? '').toString(),
      weightPercent: (map['weightPercent'] ?? '').toString(),
    );
  }
}

/// --------------------
/// Service
/// --------------------

class TrainService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      for (var doc in snapshot.docs) doc.id: Movement.fromFirestore(doc),
    };
  }

  Future<Map<String, dynamic>?> loadWorkout(String workoutId) async {
    try {
      final doc = await _firestore.collection('workouts').doc(workoutId).get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      final title = data['title'] as String? ?? '';
      final details = data['details'] as String? ?? '';

      final rawMovements = (data['movements'] as List<dynamic>? ?? []);

      final movementIds = rawMovements
          .map((m) => (m as Map<String, dynamic>)['movementId'] as String?)
          .whereType<String>()
          .toList();

      final movementMap = await getMovementMapByIds(movementIds);

      final movements = rawMovements.map((m) {
        final map = m as Map<String, dynamic>;
        final id = map['movementId'] as String?;
        final name = id != null ? movementMap[id]?.title : null;

        return MovementData.fromMap(map, movementName: name);
      }).toList();

      return {
        'title': title,
        'details': details,
        'movements': movements,
      };
    } catch (e) {
      print('❌ Error loading workout $workoutId: $e');
      return null;
    }
  }

  Future<void> saveWorkoutWithSchedule({
    String? workoutId,
    required String title,
    required String details,
    required List<MovementData> movements,
    required String programId,
    required int weekIndex,
    required int dayIndex,
  }) async {
    final workoutsRef = _firestore.collection('workouts');

    final movementMaps = movements.where((m) => m.movementId != null).map((m) {
      final sets = m.sets.where((s) => s.reps.isNotEmpty && s.weightPercent.isNotEmpty).map((s) {
        final reps = int.tryParse(s.reps);
        final weightPercent = double.tryParse(s.weightPercent);
        if (reps == null || weightPercent == null) return null;
        return {'reps': reps, 'weightPercent': weightPercent};
      }).whereType<Map<String, dynamic>>().toList();

      return {
        'movementId': m.movementId,
        'sets': sets,
      };
    }).toList();

    String savedWorkoutId;

    if (workoutId != null) {
      await workoutsRef.doc(workoutId).update({
        'title': title,
        'details': details,
        'movements': movementMaps,
      });
      savedWorkoutId = workoutId;
    } else {
      final doc = await workoutsRef.add({
        'title': title,
        'details': details,
        'movements': movementMaps,
      });
      savedWorkoutId = doc.id;
    }

    final programRef = _firestore.collection('programs').doc(programId);
    final scheduleField = 'schedule.week$weekIndex.day$dayIndex';

    await programRef.update({
      scheduleField: FieldValue.arrayUnion([savedWorkoutId]),
    });
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getAllMovements() async {
    final snapshot = await _firestore.collection('movements').limit(50).get();
    return snapshot.docs.cast<QueryDocumentSnapshot<Map<String, dynamic>>>();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> searchMovements(String query) async {
    final snapshot = await _firestore
        .collection('movements')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();

    return snapshot.docs.cast<QueryDocumentSnapshot<Map<String, dynamic>>>();
  }

  Future<Map<String, Map<String, List<String>>>> fetchProgramSchedule(String programId) async {
    final doc = await _firestore.collection('programs').doc(programId).get();
    if (!doc.exists) return {};

    final data = doc.data() ?? {};
    final scheduleRaw = data['schedule'] as Map<String, dynamic>? ?? {};

    final Map<String, Map<String, List<String>>> schedule = {};

    scheduleRaw.forEach((weekKey, dayMapRaw) {
      final dayMap = dayMapRaw as Map<String, dynamic>;
      final Map<String, List<String>> dayMapParsed = {};

      dayMap.forEach((dayKey, workoutListRaw) {
        final workouts = (workoutListRaw as List<dynamic>? ?? [])
            .map((w) => w.toString())
            .toList();
        dayMapParsed[dayKey] = workouts;
      });

      schedule[weekKey] = dayMapParsed;
    });

    return schedule;
  }

  Future<Map<String, Workout>> fetchWorkoutsByIds(List<String> workoutIds) async {
    if (workoutIds.isEmpty) return {};

    const batchSize = 10;
    final batches = <List<String>>[];
    for (var i = 0; i < workoutIds.length; i += batchSize) {
      batches.add(workoutIds.sublist(
        i,
        (i + batchSize > workoutIds.length) ? workoutIds.length : i + batchSize,
      ));
    }

    final Map<String, Workout> workoutsMap = {};

    for (final batch in batches) {
      final snapshot = await _firestore
          .collection('workouts')
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      for (final doc in snapshot.docs) {
        workoutsMap[doc.id] = Workout.fromFirestore(doc);
      }
    }

    return workoutsMap;
  }
}
