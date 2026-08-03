import 'package:flutter/material.dart';

enum LessonBlockType { text, analogy, command, tip, warning }

class LessonBlock {
  const LessonBlock(this.type, this.content, {this.caption});

  final LessonBlockType type;
  final String content;
  final String? caption;
}

class Exercise {
  const Exercise({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
  });

  final String id;
  final String question;
  final List<String> options;
  final int answer;
  final String explanation;
}

class Lesson {
  const Lesson({
    required this.id,
    required this.level,
    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.blocks,
    required this.exercises,
  });

  final String id;
  final int level;
  final String title;
  final String subtitle;
  final int minutes;
  final List<LessonBlock> blocks;
  final List<Exercise> exercises;
}

class LearningLevel {
  const LearningLevel({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final int number;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
}

class Mission {
  const Mission({
    required this.id,
    required this.title,
    required this.context,
    required this.objectives,
    required this.hints,
    required this.xp,
    required this.validator,
  });

  final String id;
  final String title;
  final String context;
  final List<String> objectives;
  final List<String> hints;
  final int xp;
  final bool Function(dynamic repository) validator;
}

class Achievement {
  const Achievement(this.id, this.title, this.description, this.icon);

  final String id;
  final String title;
  final String description;
  final IconData icon;
}
