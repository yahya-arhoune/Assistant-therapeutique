import 'package:flutter/material.dart';

class EmotionSelector extends StatefulWidget {
  final Function(String mood, int intensity) onSelected;

  const EmotionSelector({super.key, required this.onSelected});

  @override
  State<EmotionSelector> createState() => _EmotionSelectorState();
}

class _EmotionSelectorState extends State<EmotionSelector> {
  String _selectedMood = 'happy';
  int _intensity = 3;

  final moods = ['happy', 'sad', 'anxious', 'angry', 'calm'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mood', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: moods.map((mood) {
            return ChoiceChip(
              label: Text(mood),
              selected: _selectedMood == mood,
              onSelected: (_) {
                setState(() => _selectedMood = mood);
                widget.onSelected(_selectedMood, _intensity);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        const Text('Intensity'),
        Slider(
          min: 1,
          max: 5,
          divisions: 4,
          value: _intensity.toDouble(),
          label: _intensity.toString(),
          onChanged: (value) {
            setState(() => _intensity = value.toInt());
            widget.onSelected(_selectedMood, _intensity);
          },
        ),
      ],
    );
  }
}
