// Modal pops up when adding a workout to a program or schedule
import 'package:flutter/material.dart';
import '../services/train_service.dart';
import 'custom_button.dart';
import 'workout_header.dart';
import 'workout_form_fields.dart';
import 'movement_card.dart';


class AddWorkoutModal extends StatefulWidget {
  final String programId;
  final int weekIndex;
  final int dayIndex;
  final String? existingWorkoutId;

  const AddWorkoutModal({
    Key? key,
    required this.programId,
    required this.weekIndex,
    required this.dayIndex,
    this.existingWorkoutId,
  }) : super(key: key);

  @override
  State<AddWorkoutModal> createState() => _AddWorkoutModalState();
}

class _AddWorkoutModalState extends State<AddWorkoutModal> {
  final _formKey = GlobalKey<FormState>();

  final TrainService _trainService = TrainService();

  String _title = '';
  String _details = '';
  List<MovementData> _movements = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingWorkoutId != null) {
      _loadWorkout();
    }
  }

  Future<void> _loadWorkout() async {
    setState(() => _isLoading = true);

    final data = await _trainService.loadWorkout(widget.existingWorkoutId!);

    if (data != null) {
      _title = data['title'] as String? ?? '';
      _details = data['details'] as String? ?? '';
      _movements = (data['movements'] as List<dynamic>?)
              ?.cast<MovementData>()
              .toList() ??
          [];
    }

    setState(() => _isLoading = false);
  }

  void _addMovement() {
    setState(() {
      _movements.add(MovementData(movementId: null, sets: []));
    });
  }

  void _addSet(int movementIndex) {
    setState(() {
      _movements[movementIndex].sets.add(SetData(reps: '', weightPercent: ''));
    });
  }

  void _onMovementSelected(int index, String movementId, String movementName) {
    setState(() {
      _movements[index].movementId = movementId;
      _movements[index].movementName = movementName;
    });
  }


  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    await _trainService.saveWorkoutWithSchedule(
      workoutId: widget.existingWorkoutId,
      title: _title,
      details: _details,
      movements: _movements,
      programId: widget.programId,
      weekIndex: widget.weekIndex,
      dayIndex: widget.dayIndex,
    );

    setState(() => _isLoading = false);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Padding(
        padding: EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      WorkoutHeader(
                        isEditing: widget.existingWorkoutId != null,
                        weekIndex: widget.weekIndex,
                        dayIndex: widget.dayIndex,
                      ),
                      WorkoutFormFields(
                        initialTitle: _title,
                        initialDetails: _details,
                        onSaveTitle: (v) => _title = v,
                        onSaveDetails: (v) => _details = v,
                      ),
                      ..._movements.asMap().entries.map((entry) {
                        final index = entry.key;
                        final movement = entry.value;
                        return MovementCard(
                          index: index,
                          movement: movement,
                          onAddSet: _addSet,
                          onMovementSelected: _onMovementSelected,
                        );
                      }),
                      const SizedBox(height: 12),
                      CustomButton(text: '+ Movement', onPressed: _addMovement),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomButton(
                            text: 'Cancel',
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          CustomButton(
                            text: 'Save',
                            onPressed: _onSave,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
