// Movement card for list of movements within workout when adding / creating / viewing workout
import 'package:flutter/material.dart';
import 'package:heartlandstrengthapp/widgets/movement_search_modal.dart';
import '../services/train_service.dart';
import '../widgets/custom_button.dart';

class MovementCard extends StatelessWidget {
  final int index;
  final MovementData movement;
  final void Function(int) onAddSet;
  final void Function(int, String) onMovementSelected;

  const MovementCard({
    super.key,
    required this.index,
    required this.movement,
    required this.onAddSet,
    required this.onMovementSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.8, // 80% width of the modal parent
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movement selector
              GestureDetector(
                onTap: () async {
                  final selectedMovementId = await showModalBottomSheet<String?>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    useRootNavigator: true,
                    builder: (_) => Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: MediaQuery.of(context).size.height * 0.5,
                          color: Colors.white,
                          child: const MovementSearchModal(),
                        ),
                      ),
                    ),
                  );

                  if (selectedMovementId != null) {
                    onMovementSelected(index, selectedMovementId);
                  }
                },
                child: FractionallySizedBox(
                  widthFactor: 1, // 100% of the FractionallySizedBox above (i.e., 80% modal width)
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      movement.movementId ?? 'Select Movement',
                      style: TextStyle(
                        color: movement.movementId == null ? Colors.grey : Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Sets inputs
              ...movement.sets.map((set) {
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: set.reps,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(labelText: 'Reps'),
                        keyboardType: TextInputType.number,
                        onSaved: (v) => set.reps = v ?? '',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: set.weightPercent,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(labelText: 'Weight %'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onSaved: (v) => set.weightPercent = v ?? '',
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: CustomButton(
                  text: '+ Set',
                  onPressed: () => onAddSet(index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
