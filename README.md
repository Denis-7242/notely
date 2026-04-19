# 📓 Notely — Premium Digital Notebook

A professional, modern Flutter mobile application for creating, managing, and searching personal notes. Designed with a high-end "Midnight" aesthetic, featuring a sophisticated dark mode and fluid user experience. Built with **Hive** for local storage and **Provider** for state management.

> **University Project** — Optimized for presentation with a focus on modern UI/UX design, clean architecture, and professional polish.

---

## 📱 Visual Experience

| Home Screen (Light) | Home Screen (Premium Dark) | Note Editor |
|---|---|---|
| Clean, minimal, slate-based | Deep navy gradients & soft glows | Focus-driven writing space |

---

## ✨ Premium Features

- **Modern UI/UX**: A clean, minimal design with rounded corners (20px), soft shadows, and a professional color palette.
- **High-End Dark Mode**: A "Midnight" theme using deep navy tones (`#0F172A`), surface elevations (`#1E293B`), and vibrant indigo accents.
- **Fluid Animations**: 
  - `Hero` transitions between the note list and the editor.
  - Smooth theme switching with `AnimatedSwitcher`.
  - Interactive FAB with adaptive glow effects.
- **Intelligent Search**: Real-time filtering of notes with a modern, floating search bar.
- **Efficient Note Management**:
  - **Create/Edit**: Focus-driven editor with a borderless design.
  - **Delete**: Intuitive swipe-to-delete with a confirmation guard.
  - **Persistence**: Notes are stored locally using the high-performance Hive NoSQL database.
- **UX Polish**: Unsaved changes warnings, a friendly empty state, and a refined typography hierarchy.

---

## 🏗️ Project Structure

```
notely/
├── pubspec.yaml                  # Dependencies & project config
└── lib/
    ├── main.dart                 # App entry point, Premium Theme setup, providers
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
        └── note_card.dart        # Reusable professional note card widget
```

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| [Flutter](https://flutter.dev) | Cross-platform UI framework (Material 3) |
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

## 🎓 Key Flutter Concepts Demonstrated

This project showcases advanced Flutter UI and state management techniques:

| Concept | Implementation |
|---|---|
| **State Management** | `ChangeNotifier` + `Provider` for global state |
| **Local Persistence** | Hive NoSQL with custom type adapters |
| **Advanced UI** | `Hero` animations, `LinearGradient` backgrounds, and `AnimatedSwitcher` |
| **User Interaction** | `Dismissible` (swipe gestures) and `WillPopScope` (navigation guards) |
| **Form Handling** | `TextEditingController` and `GlobalKey<FormState>` validation |
| **Adaptive Theming** | Custom `ThemeData` for a premium Dark/Light mode experience |

---

## 🗺️ Roadmap / Possible Improvements

- [ ] Note categories / tags with color coding
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

Made by **Denis** with ❤️ using Flutter. 

Built as a professional Flutter showcase project. Feel free to fork, modify, and learn from the code!
