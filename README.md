# 📓 Notely — A Simple Digital Notebook

A beginner-friendly Flutter mobile application for creating, managing, and searching personal notes. Built with **Hive** for local storage and **Provider** for state management.

> **University Project** — Designed as a clean, well-commented codes for presentation purposes.

---

## 📱 Screenshots

| Home Screen (Light) | Home Screen (Dark) | Note Editor |
|---|---|---|
| Note list with search bar | Dark mode toggle support | Add / edit with validation |

---

## ✨ Features

- **Create** new notes with a title and content
- **Edit** existing notes (fields pre-filled automatically)
- **Delete** notes with a confirmation dialog
- **Search** notes by title or content in real time
- **Dark mode / Light mode** toggle — preference saved across sessions
- **Persistent storage** — notes survive app restarts using Hive
- **Empty state** — friendly message when no notes exist
- **Unsaved changes warning** — prompts before discarding edits
- **Swipe to delete** — swipe a note card left to reveal the delete action
- **Most recent first** — notes sorted by last edited date

---

## 🏗️ Project Structure

```
notely/
├── pubspec.yaml                  # Dependencies & project config
└── lib/
    ├── main.dart                 # App entry point, theme setup, providers
    ├── models/
    │   ├── note.dart             # Note data model with Hive annotations
    │   └── note.g.dart           # Auto-generated Hive type adapter
    ├── screens/
    │   ├── home_screen.dart      # Main screen: list, search, delete
    │   └── note_editor_screen.dart  # Add / edit note form
    ├── services/
    │   ├── note_storage.dart     # Raw Hive DB operations (CRUD + search)
    │   ├── note_provider.dart    # State management with ChangeNotifier
    │   └── theme_provider.dart   # Dark/light mode state
    └── widgets/
        └── note_card.dart        # Reusable note card widget
```

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| [Flutter](https://flutter.dev) | Cross-platform UI framework |
| [Hive](https://pub.dev/packages/hive_flutter) | Fast local NoSQL database |
| [Provider](https://pub.dev/packages/provider) | State management |
| [UUID](https://pub.dev/packages/uuid) | Unique ID generation |
| [Intl](https://pub.dev/packages/intl) | Date formatting |

---

## 🚀 Getting Started

### Prerequisites

Make sure you have the following installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.0.0 or higher)
- Android Studio or VS Code with Flutter extension
- An Android emulator or physical device

### Installation

**1. Clone or download the project**

```bash
git clone https://github.com/Denis-7242/notely.git
cd notely
```

**2. Install dependencies**

```bash
flutter pub get
```

**3. Run the app**

```bash
flutter run
```

> **Note:** The `note.g.dart` Hive adapter file is already included in this project, so you do **not** need to run `build_runner`. In a production project you would add `*.g.dart` to `.gitignore` and regenerate it with:
> ```bash
> flutter pub run build_runner build
> ```

---

## 📦 Dependencies

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  provider: ^6.1.1
  uuid: ^4.3.3
  intl: ^0.19.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.8
```

---

## 🧠 Architecture Overview

Notely follows a clean 3-layer architecture:

```
UI Layer        → home_screen.dart, note_editor_screen.dart, note_card.dart
State Layer     → NoteProvider, ThemeProvider  (ChangeNotifier + Provider)
Data Layer      → NoteStorage (Hive) → note.dart model
```

**Data flow:**

```
User Action → Screen → Provider → NoteStorage → Hive DB
                ↑___________notifyListeners()___________|
```

---

## 📋 Note Model

Each note stores the following fields:

| Field | Type | Description |
|---|---|---|
| `id` | `String` | Unique UUID identifier |
| `title` | `String` | Note title |
| `content` | `String` | Note body text |
| `createdDate` | `DateTime` | When the note was first created |
| `updatedDate` | `DateTime` | When the note was last edited |

---

## 🎓 Key Flutter Concepts Demonstrated

This project is designed to teach the following Flutter concepts:

| Concept | File |
|---|---|
| `ChangeNotifier` + `Provider` | `note_provider.dart` |
| `Consumer` / `context.read` | `home_screen.dart` |
| `TextEditingController` | `note_editor_screen.dart` |
| Form validation with `GlobalKey<FormState>` | `note_editor_screen.dart` |
| Hive local storage with type adapters | `note_storage.dart`, `note.dart` |
| `Dismissible` (swipe gesture) | `note_card.dart` |
| Dark/Light `ThemeMode` | `main.dart` |
| `WillPopScope` (back navigation guard) | `note_editor_screen.dart` |
| `showDialog` confirmation dialogs | `home_screen.dart` |
| Empty state UI pattern | `home_screen.dart` |

---

## 🗺️ Roadmap / Possible Improvements

- [ ] Note categories / tags
- [ ] Pin important notes to the top
- [ ] Rich text formatting (bold, italic, bullet lists)
- [ ] Export notes as PDF or plain text
- [ ] Cloud sync (Firebase)
- [ ] Note sharing
- [ ] Widget home screen shortcut

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

## 👨‍💻 Author

Built as a class Flutter project. Feel free to fork, modify, and learn from the code!