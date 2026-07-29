# SaiKirthan

A multilingual devotional Flutter app for Sai Baba content, supporting English, Hindi, and Telugu.

## Features

- **Multi-language support**: English, हिन्दी (Hindi), and తెలుగు (Telugu)
- **Time-based content**: Morning, Afternoon, Evening, and Night prayers/content
- **Stories and Quotes**: Dedicated sections for inspirational stories and random quotes
- **Cross-platform**: Runs on iOS, Android, and Web
- **Beautiful UI**: Random background images with transparency for each view

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- For iOS: Xcode
- For Android: Android Studio

### Installation

1. Clone or download this repository
2. Navigate to the SaiKirthan directory:
   ```bash
   cd SaiKirthan
   ```
3. Get Flutter dependencies:
   ```bash
   flutter pub get
   ```

### Running the App

#### iOS
```bash
flutter run -d ios
```

#### Android
```bash
flutter run -d android
```

#### Web
```bash
flutter run -d chrome
```

## Project Structure

```
SaiKirthan/
├── lib/
│   ├── main.dart                 # App entry point
│   └── screens/
│       ├── content_view.dart     # Landing page with language selection
│       ├── language_view.dart    # Tab view for each language
│       ├── text_file_view.dart   # Displays text content with background
│       └── random_line_view.dart # Displays random quotes
├── assets/
│   ├── images/                   # Background and landing images
│   └── texts/                    # Text content organized by language
│       ├── English/
│       ├── Hindi/
│       └── Telugu/
└── pubspec.yaml                  # Project configuration
```

## Adding Content

To add or modify content, edit the text files in the `assets/texts/` directory:
- `English/`, `Hindi/`, `Telugu/` folders contain language-specific content
- Each folder should have: Morning, Afternoon, Evening, Night, Story, and Quotes txt files

## License

This is a devotional app created for the community.

---

**Om Sai Ram** 🙏
