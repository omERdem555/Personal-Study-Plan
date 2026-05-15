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

### 3) Port çakışması olursa ne yapmalı?

Eğer `uvicorn` veya `flutter run` komutları:

- `error while attempting to bind on address ('0.0.0.0', 8000)`
- `Failed to create server socket ... address = 0.0.0.0, port = 8080`

şeklinde bir hata veriyorsa, aynı port başka bir uygulama tarafından kullanılıyor demektir.

#### A) Önce çalışan eski süreci kapatın

Windows terminalde şu komutu çalıştırın:

```powershell
netstat -ano | findstr :8000
```

veya

```powershell
netstat -ano | findstr :8080
```

Sonra çıkışta görünen PID değerini kullanarak süreci kapatın. Örneğin netstat çıktısı (Listening)`1234` ise:

```powershell
taskkill /PID 1234 /F
```

**Önemli:** `1234` sadece örnek bir değerdir. Kendi ekranda görünen PID sayısını kullanın.

Not: `taskkill /PID <PID> /F` şeklinde yazmak PowerShell’de hataya yol açar; `<>` karakterlerini yazmayın. Eğer `uvicorn` veya `flutter` komutunu daha önce çalıştırdıysanız, bu pencerede `Ctrl+C` ile durdurmak da yeterlidir.

#### B) Portu değiştirmek isterseniz

Eğer portu boşaltamıyorsanız, alternatif bir port seçin:

- Backend için: `--port 8001`
- Flutter web için: `--web-port 8081`

Backend çalıştırma örneği:

```powershell
uvicorn main:app --host 0.0.0.0 --port 8001
```

Flutter web çalıştırma örneği:

```powershell
flutter run -d web-server --web-port 8081
```

Eğer backend portunu değiştirirseniz, `study_planner_app/lib/services/api_service.dart` içindeki `baseUrl` değerini de aynı porta göre güncelleyin.

### Why this works

- Backend listens on `0.0.0.0`, so the local browser can connect.
- Flutter web uses `localhost`, matching the API host in `lib/services/api_service.dart`.
- If the app still fails, check that the backend is running before clicking `Analiz Et`.
