import 'package:flutter/material.dart';
import 'package:heartlandstrengthapp/widgets/movement_search_modal.dart';
import '../services/train_service.dart';
import '../widgets/custom_button.dart';

class MovementCard extends StatelessWidget {
  final int index;
  final MovementData movement;
  final void Function(int) onAddSet;
  final void Function(int index, String movementId, String movementName) onMovementSelected;

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
      widthFactor: 0.8,
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
                final selectedMovement = await showDialog<Map<String, String>?>(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      contentPadding: const EdgeInsets.all(16),
                      content: SizedBox(
                        width: 550,
                        height: 400,
                        child: const MovementSearchModal(),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  },
                );

                if (selectedMovement != null) {
                  final selectedId = selectedMovement['id'];
                  final selectedName = selectedMovement['name'];
                  if (selectedId != null && selectedName != null) {
                    // Pass both id and name to update the movement data
                    onMovementSelected(index, selectedId, selectedName);
                  }
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  movement.movementName ?? 'Select Movement',
                  style: TextStyle(
                    color: movement.movementId == null ? Colors.grey : Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

              const SizedBox(height: 8),

              // Sets inputs
              ...movement.sets.asMap().entries.map((entry) {
                final setIndex = entry.key;
                final set = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: set.reps,
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(labelText: 'Reps'),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => set.reps = v,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: set.weightPercent,
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(labelText: 'Weight %'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (v) => set.weightPercent = v,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 8),

              // + Set button
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
