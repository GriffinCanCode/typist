# Typist

A macOS voice-to-text application with modern UI design, powered by WhisperX for high-quality local speech transcription.

## Features

- **Smart Floating UI**: Mouse-cursor-following popup window with glassmorphism design
- **Privacy-First**: Local speech processing with WhisperX (no data sent to cloud)
- **Fast Transcription**: Optimized for Apple Silicon and CUDA GPUs
- **Modern Design**: SwiftUI with glassmorphism effects and smooth animations
- **Hotkey Support**: Quick access via ⌘⇧Space when app is active
- **Smart Insertion**: Automatic text insertion into any active text field
- **Multi-Engine**: Supports both Apple Speech Recognition and WhisperX

## Project Structure

```
Typist/
├── App/                        # Main application entry point
│   ├── TypistApp.swift        # SwiftUI App definition
│   ├── AppDelegate.swift      # Application lifecycle management
│   └── Info.plist            # App metadata and permissions
├── UI/                        # User interface components
│   ├── Views/                 # Main view controllers
│   │   ├── ContentView.swift  # Main app window
│   │   └── FloatingWindowView.swift # Popup transcription window
│   ├── Components/            # Reusable UI components
│   │   └── GlassmorphismComponents.swift
│   └── Styles/                # Custom view styles
│       └── ButtonStyles.swift
├── Services/                  # Core business logic
│   ├── Speech/                # Speech recognition services
│   │   ├── SpeechRecognizer.swift # Apple Speech Recognition
│   │   └── WhisperXService.swift  # WhisperX integration
│   ├── System/                # System integration
│   │   └── HotkeyManager.swift    # Global/local hotkey handling
│   └── Python/                # Python WhisperX service
│       ├── whisperx_service.py    # WhisperX transcription service
│       ├── requirements.txt       # Python dependencies
│       └── setup.py              # Environment setup script
├── Utilities/                 # Helper classes and extensions
│   ├── WindowManager.swift    # Window positioning and management
│   ├── ClipboardManager.swift # Text insertion and clipboard handling
│   ├── Constants.swift        # App-wide constants
│   └── Extensions/            # Swift extensions
│       ├── Foundation+Extensions.swift
│       └── SwiftUI+Extensions.swift
└── Resources/                 # Assets and resources
```

## Installation

### Prerequisites

- macOS 14.0 or later
- Xcode 15.0 or later
- Python 3.8 or later

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/typist.git
   cd typist
   ```

2. **Set up Python environment**
   ```bash
   cd Services/Python
   python3 setup.py
   ```

3. **Build and run in Xcode**
   - Open the project in Xcode
   - Grant microphone and speech recognition permissions when prompted
   - Build and run the project

### Initial Configuration

1. **Grant Permissions**: The app will request microphone and speech recognition access
2. **Test WhisperX**: The Python service will be tested automatically
3. **Test Hotkey**: Press ⌘⇧Space while the app is active to open the floating window

## Usage

### Basic Operation

1. Activate the app (make it the frontmost application)
2. Press ⌘⇧Space to open the floating transcription window
3. Click the microphone button and speak
4. Speech will be transcribed and inserted into the active text field

### Advanced Features

- **Mouse Following**: The popup automatically appears near your mouse cursor
- **Auto-Close**: Window closes automatically after successful transcription
- **Error Handling**: Clear feedback for permission issues or service problems
- **Model Selection**: Configure WhisperX model size in the Python service

## Configuration

### WhisperX Models

Edit `Services/Python/whisperx_service.py` to change the default model:

```python
# Available models: tiny, base, small, medium, large
model_size = "base"  # Change this line
```

### Hotkey Customization

Modify `Services/System/HotkeyManager.swift`:

```swift
// Available combinations in HotkeyConfig enum
case .cmdShiftSpace  // ⌘⇧Space (default)
case .cmdSpace       // ⌘Space
case .optionSpace    // ⌥Space
```

## Development

### Architecture

- **MVVM Pattern**: Clean separation between Views, ViewModels, and Models
- **ObservableObject**: Reactive state management with SwiftUI
- **Dependency Injection**: Services injected via EnvironmentObject
- **Error Handling**: Comprehensive error types and user feedback

### Key Components

- **SpeechRecognizer**: Handles both Apple and WhisperX speech recognition
- **WindowManager**: Manages floating window positioning and behavior  
- **HotkeyManager**: Global and local hotkey registration
- **ClipboardManager**: Smart text insertion into active applications

### Testing

Run the included test button in the main window to verify all components work correctly.

## Troubleshooting

### Common Issues

**"Microphone access denied"**
- Go to System Preferences > Security & Privacy > Privacy > Microphone
- Enable access for Typist

**"WhisperX not available"**
- Run the Python setup script: `cd Services/Python && python3 setup.py`
- Check that all dependencies installed correctly

**"Hotkey not working"**
- Ensure the Typist app is the active/frontmost application
- Check for conflicts with other apps using the same hotkey

**"Text not inserting"**
- The app uses clipboard simulation - ensure the target app accepts paste commands
- For some apps, you may need to grant Accessibility permissions

### Logs

Check the logs for debugging:
- macOS Console app: Search for "Typist"
- Python service logs: `/tmp/whisperx_service.log`

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Swift naming conventions and patterns
- Add comprehensive error handling
- Include unit tests for new features
- Update documentation for API changes
- Ensure cross-platform compatibility where applicable

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **WhisperX**: For providing excellent local speech transcription
- **Apple**: For the Speech Recognition framework and SwiftUI
- **OpenAI**: For the original Whisper model

## Roadmap

- [ ] Global hotkey support (with accessibility permissions)
- [ ] Multi-language transcription
- [ ] Custom model training support
- [ ] Integration with popular text editors
- [ ] Voice command recognition
- [ ] Real-time transcription streaming
