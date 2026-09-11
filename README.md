<img width="1280" height="640" alt="git (1)" src="https://github.com/user-attachments/assets/8920b256-2ba8-4988-b824-5351134eb4bd" />



# HAACHII


## Basic Details
### Team Name: Gold Diggers


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
<img width="448" height="999" alt="image" src="https://github.com/user-attachments/assets/40ab3ef5-bb33-4240-9df0-00ad2c0100fd" />

<img width="448" height="959" alt="image" src="https://github.com/user-attachments/assets/6fb24be6-9c0f-442a-bd7a-aa7cdd5f0d4c" />

<img width="448" height="959" alt="image" src="https://github.com/user-attachments/assets/21b57797-7456-4d6d-beae-b4288a50be3b" />



# Diagrams
## Workflow
<img width="2752" height="1536" alt="workflow_diagram" src="https://github.com/user-attachments/assets/1f44480c-33c0-4d09-8ce4-85d64e76a524" />

*Real-time camera frames and microphone audio are continuously analyzed to confirm a sneeze. Upon detection, the algorithm triggers a sequence of cinematic UI effects—freezing the live preview, spattering dynamic droplets, playing a wiper video transition, and displaying a full-screen biometric threat report before resetting the loop."*

### Project Demo
# Video

https://github.com/user-attachments/assets/721f08fb-850b-428f-92e4-3a5e3dbf2c1d



# Additional Demos
**Released as an APK in this repository**

## Team Contributions
- Allen Jude: Project Initialization & Repository Management, UI/UX & Animations, Core Detection Logic, Visual Effects, Code Optimization
- Elna Susan: Core Services, UI Development, Documentation

---
Made with ❤️ at TinkerHub Useless Projects 

![Static Badge](https://img.shields.io/badge/TinkerHub-24?color=%23000000&link=https%3A%2F%2Fwww.tinkerhub.org%2F)
![Static Badge](https://img.shields.io/badge/UselessProjects--26-26?link=https%3A%2F%2Ftinkerhub.org%2Fevents%2F1M8ORET9A1%2Fuseless-projects-3.0)


