# study_planner_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Local development setup for this project

When you reopen the project, start the backend and frontend separately.

### 1) Start the backend

Open a terminal in the `backend` folder and run:

```powershell
cd "c:\Users\omere\Desktop\Dersler\3\İkinci Dönem\Mobil Programlama\Personal Study Plan\backend"
uvicorn main:app --host 0.0.0.0 --port 8000
```

This makes the API available at `http://localhost:8000`.

### 2) Start the Flutter web app

Open a second terminal in the `study_planner_app` folder and run:

```powershell
cd "c:\Users\omere\Desktop\Dersler\3\İkinci Dönem\Mobil Programlama\Personal Study Plan\study_planner_app"
flutter run -d web-server --web-port 8080
```

Then open the browser URL shown by Flutter (typically `http://localhost:8080`).

### Why this works

- Backend listens on `0.0.0.0`, so the local browser can connect.
- Flutter web uses `localhost`, matching the API host in `lib/services/api_service.dart`.
- If the app still fails, check that the backend is running before clicking `Analiz Et`.
