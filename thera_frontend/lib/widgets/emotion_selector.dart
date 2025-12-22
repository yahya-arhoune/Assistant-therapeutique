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
  final Map<String, String> moodEmojis = {
    'happy': '😊',
    'sad': '😢',
    'anxious': '😰',
    'angry': '😡',
    'calm': '😌',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you feeling?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white.withAlpha((0.9 * 255).round()),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: moodEmojis.entries.map((entry) {
              final isSelected = _selectedMood == entry.key;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedMood = entry.key);
                  widget.onSelected(_selectedMood, _intensity);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha((0.2 * 255).round())
                        : Colors.white.withAlpha((0.05 * 255).round()),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white.withAlpha((0.1 * 255).round()),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(entry.value, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(
                        entry.key.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withAlpha((0.5 * 255).round()),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Intensity',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white.withAlpha((0.9 * 255).round()),
              ),
            ),
            Text(
              '$_intensity / 5',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme.of(context).colorScheme.secondary,
            inactiveTrackColor: Colors.white.withAlpha((0.1 * 255).round()),
            thumbColor: Colors.white,
            overlayColor: Theme.of(
              context,
            ).colorScheme.secondary.withAlpha((0.2 * 255).round()),
            valueIndicatorColor: Theme.of(context).colorScheme.secondary,
          ),
          child: Slider(
            min: 1,
            max: 5,
            divisions: 4,
            value: _intensity.toDouble(),
            onChanged: (value) {
              setState(() => _intensity = value.toInt());
              widget.onSelected(_selectedMood, _intensity);
            },
          ),
        ),
      ],
    );
  }
}
