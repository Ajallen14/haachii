<img width="1280" height="640" alt="git (1)" src="https://github.com/user-attachments/assets/8920b256-2ba8-4988-b824-5351134eb4bd" />



# HAACHII 🎯


## Basic Details
### Team Name: [Name]


### Team Members
- Team Lead: Allen Jude - Albertian Institute of Science and Technology
- Member 2: Elna Susan - Albertian Institute of Science and Technology


### Project Description
Sneeze Trajectory Analyzer is a real-time computer vision system that detects sneezes via facial landmark tracking and computes their ballistic properties — blast radius, expulsion velocity, and danger zone — using actual projectile motion physics. It then tells you, with complete scientific confidence, exactly who got hit.

### The Problem (that doesn't exist)
Every day, thousands of innocent bystanders are struck by unregistered, unregulated sneeze droplets traveling at unknown velocities — and NOBODY is tracking this. There is no early-warning system. No blast radius map. No accountability. Meanwhile, world governments spend billions on missile defense systems but *zero* dollars on sneeze defense systems. We're not saying a sneeze is a weapon. We're saying nobody has proven it *isn't*. This ends today.

### The Solution (that nobody asked for)
We pointed a webcam at people's faces and taught it to recognize the universal warning signs of an incoming sneeze — the head snap, the mouth flare, the point of no return — using MediaPipe Face Mesh for real-time facial tracking. The moment a sneeze is detected, our system runs honest-to-god projectile motion physics on the head's velocity and angle to calculate a live "blast cone" overlay, complete with distance, direction, and a danger zone. Anyone else in frame gets auto-scanned for impact and publicly flagged as a casualty. It's peer-reviewed science applied to a problem no one was asking anyone to solve — but now that we've solved it, you're welcome.

## Technical Details
### Technologies/Components Used
For Software:
- Languages used: Dart
- Frameworks used: Flutter
- Libraries used:
    * camera: For high-resolution live feed interception.
    * google_mlkit_face_detection: For real-time 3D head pitch (Euler X) and bounding box tracking.
    * record: For the low-latency audio decibel tripwire.
    * video_player: For the cinematic screen-wiping transition overlay.
    * animated_text_kit & lottie: For the splash screen and biometric terminal UI effects.
- Tools used : Google ML Kit Vision API, standard Flutter toolchain (Android SDK / iOS SDK).

### Implementation
For Software:
# Installation
```
# Clone the repository
git clone https://github.com/Ajallen14/haachii.git
cd haachii

# Clean the workspace (crucial for resolving cross-platform audio/camera dependency caching)
flutter clean

# Fetch all packages
flutter pub get
```

# Run
```
flutter run
```

### Project Documentation
For Software:

# Screenshots (Add at least 3)
![Screenshot1](Add screenshot 1 here with proper name)
*Add caption explaining what this shows*

![Screenshot2](Add screenshot 2 here with proper name)
*Add caption explaining what this shows*

![Screenshot3](Add screenshot 3 here with proper name)
*Add caption explaining what this shows*

# Diagrams
![Workflow](Add your workflow/architecture diagram here)
*Add caption explaining your workflow*

### Project Demo
# Video
[Add your demo video link here]
*Explain what the video demonstrates*

# Additional Demos
[Add any extra demo materials/links]

## Team Contributions
- [Name 1]: [Specific contributions]
- [Name 2]: [Specific contributions]
- [Name 3]: [Specific contributions]

---
Made with ❤️ at TinkerHub Useless Projects 

![Static Badge](https://img.shields.io/badge/TinkerHub-24?color=%23000000&link=https%3A%2F%2Fwww.tinkerhub.org%2F)
![Static Badge](https://img.shields.io/badge/UselessProjects--26-26?link=https%3A%2F%2Ftinkerhub.org%2Fevents%2F1M8ORET9A1%2Fuseless-projects-3.0)


