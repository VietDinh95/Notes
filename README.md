# Notes App 📝

A modern, feature-rich Notes application built with **SwiftUI** and **MVVM architecture**, featuring **NotesKit framework integration** via local Swift Package Manager. This app provides a seamless note-taking experience with local storage, real-time search, and comprehensive testing coverage.

## ✨ Features

### Core Functionality
- **Create Notes**: Add new notes with title and content
- **Read Notes**: View all notes in a clean, organized list
- **Update Notes**: Edit existing notes with real-time updates
- **Delete Notes**: Remove notes with confirmation dialog
- **Search Notes**: Find notes quickly with real-time search and debounced input
- **Offline Storage**: Persistent data using Core Data with in-memory store for testing

### User Experience
- **Modern UI**: Clean, intuitive interface built with SwiftUI
- **Smooth Animations**: Spring animations and transitions throughout the app
- **Pull-to-Refresh**: Refresh notes list with a simple gesture
- **Responsive Design**: Optimized for all iOS devices
- **Dark Mode Support**: Automatic adaptation to system appearance
- **Search Bar**: Tap-out to dismiss keyboard functionality

### Technical Features
- **MVVM Architecture**: Clean separation of concerns with dependency injection
- **NotesKit Framework**: Modular business logic encapsulated in local SPM package
- **Combine Framework**: Reactive programming for data flow and state management
- **Core Data**: Robust data persistence with CloudKit integration ready
- **Comprehensive Testing**: Unit tests with 90%+ coverage and optimized UI tests
- **Performance Optimized**: Debounced search, efficient memory management

## 🏗️ Architecture

### MVVM + Framework Integration
The application follows a sophisticated architecture pattern:

- **Model**: `NoteModel` struct with immutable properties
- **View**: SwiftUI views for user interface
- **ViewModel**: `NotesViewModel` with dependency injection
- **Framework**: `NotesKit` package containing business logic and data layer
- **Integration Layer**: `NotesKitIntegration` bridging main app and framework

### Project Structure
```
Notes/
├── NotesKit/                    # Local Swift Package
│   ├── Sources/
│   │   ├── Models/
│   │   ├── Services/
│   │   └── Repositories/
│   └── Tests/
├── Notes/                       # Main App
│   ├── Presentation/
│   │   ├── Views/
│   │   └── ViewModels/
│   ├── Integration/
│   └── NotesApp.swift
├── NotesTests/                  # Unit Tests
└── NotesUITests/               # UI Tests
    ├── UITestHelpers.swift
    ├── UITestConfiguration.swift
    └── NotesUITests.swift
```

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Installation
1. Clone the repository
   ```bash
   git clone <repository-url>
   cd Notes
   ```
2. Open `Notes.xcodeproj` in Xcode
3. Resolve package dependencies (if needed)
4. Select your target device or simulator
5. Build and run the project (⌘+R)

### Running Tests
- **Unit Tests**: ⌘+U or `xcodebuild test -scheme Notes -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:NotesTests`
- **UI Tests**: `xcodebuild test -scheme Notes -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:NotesUITests`

### Development Tools

#### Build and Test Script
```bash
# Make script executable
chmod +x build_and_test.sh

# Available commands
./build_and_test.sh build    # Build project only
./build_and_test.sh test     # Run unit tests only
./build_and_test.sh uitest   # Run UI tests only
./build_and_test.sh all      # Build + run all tests
./build_and_test.sh clean    # Clean build folder
./build_and_test.sh help     # Show help
```

#### Code Quality Tools
- **SwiftLint**: Code style enforcement (`.swiftlint.yml`)
- **SwiftFormat**: Automatic code formatting (`.swiftformat`)
- **Pre-commit Hooks**: Automated code quality checks

#### CI/CD Ready
The project includes:
- **Build Script**: `build_and_test.sh` for automated builds
- **Test Automation**: Comprehensive unit and UI test suites
- **Code Quality**: Automated linting and formatting
- **Performance Metrics**: UI test performance measurement

## 🧪 Testing

### Unit Tests (90%+ Coverage)
- **NotesViewModelTests**: Comprehensive business logic testing
- **NotesKitIntegrationTests**: Framework integration testing
- **Mock Services**: Dependency injection for isolated testing

### UI Tests (Optimized & Stable)
**Refactored for Performance & Reliability:**
- **Zero Hardcoded Delays**: All `sleep`, `Thread.sleep`, `DispatchQueue.asyncAfter` removed
- **Predicate-based Waits**: Using `XCTNSPredicateExpectation`, `XCTWaiter`, `NSPredicate`
- **Page Object Pattern**: `BasePage`, `NotesAppPage`, `AddNotePage`, `EditNotePage`
- **Helper Extensions**: `XCUIElement` and `XCUIElementQuery` extensions
- **Performance Metrics**: CPU, Memory, Storage, Clock metrics
- **Animation Disabled**: `-disableAnimations`, `-uiTestFastMode` launch arguments

**Test Coverage:**
- App launch and performance
- Note creation, editing, deletion
- Search functionality (with special characters)
- Error handling and accessibility
- Long content handling
- Multiple notes management

## 🔧 Technical Implementation

### Data Model (Immutable Design)
```swift
struct NoteModel: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let content: String
    let createdAt: Date
    let updatedAt: Date
    let isFavorite: Bool
}
```

### NotesKit Framework
- **Modular Architecture**: Business logic encapsulated in local SPM package
- **Protocol-based Services**: `NotesServiceProtocol` for testability
- **Repository Pattern**: `CoreDataNoteRepository` with CloudKit integration
- **Bridge Pattern**: `NotesKitIntegration` for seamless integration

### ViewModel (Reactive State Management)
```swift
@MainActor
class NotesViewModel: ObservableObject {
    @Published var notes: [NoteModel] = []
    @Published var filteredNotes: [NoteModel] = []
    @Published var searchText: String = ""
    @Published var isSearching: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let notesKitIntegration: NotesKitIntegration
    private var cancellables = Set<AnyCancellable>()
}
```

### Search Implementation
- **Debounced Input**: 300ms delay for performance optimization
- **Real-time Filtering**: Updates as user types
- **State Management**: `isSearching` remains `true` even with no results
- **Case-insensitive**: Searches both title and content

## 🎨 UI Components

### NotesListView
- Main list view with conditional search bar
- Pull-to-refresh functionality
- Empty state handling with proper accessibility
- Loading states and error handling

### SearchBar
- Custom SwiftUI component with focus management
- Tap-out to dismiss keyboard functionality
- Clear button for easy search reset
- Accessibility identifiers for UI testing

### AddNoteView & EditNoteView
- Form-based input with validation
- Smooth transitions and animations
- Auto-focus management
- Save/Cancel button states

## 💾 Data Persistence

### Core Data Implementation
- **In-Memory Store**: For UI testing performance
- **CloudKit Ready**: Entitlements configured for future sync
- **Repository Pattern**: Abstracted data access layer
- **Migration Support**: Future-proof data model

### NotesKit Integration
- **Local SPM**: Framework integration via Swift Package Manager
- **Dependency Injection**: Clean separation of concerns
- **Testable Design**: Mock services for unit testing

## 🚀 Performance Optimizations

### UI Tests Performance
- **Animation Disabled**: `UIView.setAnimationsEnabled(false)` for faster tests
- **In-Memory Store**: No disk I/O during testing
- **Predicate-based Waits**: Efficient element waiting
- **Performance Metrics**: CPU, Memory, Storage monitoring

### App Performance
- **Debounced Search**: Prevents excessive filtering
- **Lazy Loading**: Efficient list rendering
- **Memory Management**: Proper Combine subscription handling
- **State Optimization**: Minimal UI updates

## 🔒 Security & Privacy

- **Local Storage**: Core Data with optional CloudKit sync
- **No Analytics**: Privacy-focused design
- **Secure Data**: Standard iOS security practices
- **User Control**: Full control over data

## 📱 Platform Support

- **iOS 17.0+**: Modern SwiftUI features
- **iPhone & iPad**: Universal app design
- **Dark Mode**: Automatic appearance adaptation
- **Accessibility**: VoiceOver and Dynamic Type support

## 🛠️ Development Tools

- **Xcode 15**: Latest development environment
- **SwiftLint**: Code style enforcement
- **SwiftFormat**: Automated code formatting
- **Git**: Version control with proper branching
- **Swift Package Manager**: Local framework management

## 📚 Documentation

For detailed information about the project, please refer to the following documentation:

- **[SHOWCASE_GUIDE.md](SHOWCASE_GUIDE.md)** - Demo requirements and showcase guidelines
- **[CHALLENGES_AND_LEARNINGS.md](CHALLENGES_AND_LEARNINGS.md)** - Technical challenges and insights
- **[TECHNICAL_DOCUMENTATION.md](TECHNICAL_DOCUMENTATION.md)** - Comprehensive technical documentation

## 🔮 Future Enhancements

### Planned Features
- [ ] **CloudKit Sync**: iCloud synchronization
- [ ] **Rich Text**: Markdown support
- [ ] **Attachments**: Image and file support
- [ ] **Categories**: Note organization
- [ ] **Export**: PDF and text export
- [ ] **Widgets**: iOS home screen widgets

### Technical Improvements
- [ ] **SwiftUI 5**: Latest framework features
- [ ] **Performance**: Large dataset optimization
- [ ] **Testing**: Enhanced test coverage
- [ ] **CI/CD**: Automated testing pipeline

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes following Swift style guidelines
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming framework
- **Core Data**: Robust data persistence
- **XCTest**: Comprehensive testing framework
- **Apple**: iOS development tools and guidelines

## 📞 Support

For questions, issues, or contributions:
- Create an issue on GitHub
- Review the code documentation
- Check the test suite for examples
- Refer to the technical documentation

---

**Built with ❤️ using SwiftUI, Combine, and MVVM Architecture**











