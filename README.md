# Riziko Quiz Game

A production-ready, team-based mobile quiz game built with Flutter, Riverpod, and Clean Architecture.

## Features

- **Team-based Gameplay**: Play with multiple teams.
- **Custom Answer Evaluator**: Supports Levenshtein distance for fuzzy matching, keyword validation, and text normalization.
- **Turn-based Logic**: Teams take turns picking categories and difficulties.
- **Timer System**: Each question has a countdown timer.
- **Advanced UI Features**: Includes "Almost correct" feedback and a point-penalty hint system.

## Setup

1. Clone the repository.
2. Run `flutter pub get`.
3. (Optional) Setup Firebase:
   - Create a Firebase project.
   - Run `flutterfire configure` to generate `firebase_options.dart`.
   - Update `QuestionRepositoryImpl` to point to Firestore data instead of mock data.
4. Run `flutter run`.

## Architecture

This project strictly follows Clean Architecture principles:
- **Core**: Utilities, Router, Errors.
- **Domain**: Entities (`Question`, `Team`, `GameSession`) and Repositories.
- **Data**: Models and Repository Implementations.
- **Presentation**: UI Screens and Riverpod state management.
- **Services**: `AnswerEvaluatorService` and `TimerService`.

## Testing

Run unit tests for the answer evaluator:
```bash
flutter test
```
