# My Little Canva

A Flutter application built with clean architecture principles.

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- Android Studio / VS Code with Flutter extensions
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/my_little_canva.git
cd my_little_canva
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── core/
│   ├── config/         # App configuration
│   ├── di/            # Dependency injection
│   ├── error/         # Error handling
│   ├── network/       # Network related code
│   ├── theme/         # App theme
│   ├── utils/         # Utility functions
│   └── widgets/       # Shared widgets
├── features/          # Feature modules
│   └── [feature_name]/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── controllers/
│           ├── pages/
│           └── widgets/
└── shared/           # Shared resources
```

## Architecture

This project follows clean architecture principles:

- **Presentation Layer**: UI components and state management
- **Domain Layer**: Business logic and use cases
- **Data Layer**: Data sources and repositories

### Key Technologies

- **State Management**: Riverpod
- **Dependency Injection**: GetIt
- **Routing**: AutoRoute
- **Code Generation**: Freezed, JSON Serializable
- **Network**: Dio, Retrofit
- **Local Storage**: SharedPreferences, Hive
- **Testing**: Mockito, Mocktail

## Development Guidelines

### Code Style

- Follow the official [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Write comments for complex logic
- Keep functions small and focused

### Testing

- Write unit tests for all business logic
- Write widget tests for UI components
- Write integration tests for critical user flows

### Git Workflow

1. Create a feature branch from `develop`
2. Make your changes
3. Run tests and ensure they pass
4. Submit a pull request to `develop`

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.