# Smart Farming AI Assistant 🌱🚜

A modern, high-fidelity agricultural companion application built using **Flutter**, following **Clean Architecture** guidelines and the **MVVM (Model-View-ViewModel)** design pattern. It delivers real-time weather analytics, AI crop suitability recommendations, customized fertilizer dosages, live Mandi rates, and crop disease diagnosis chat features.

---

## ✨ Features

- **🤖 AI Farming Chatbot**: Direct messaging interface that simulates voice recordings parsing, camera/gallery image attachments, and sequential typing notifications.
- **🌦️ Weather Forecast Dashboard**: Interactive gradient panel indicating humidity, wind, and rain risk with 7-Day forecasts and crop-specific advisories (Rice, Wheat, Cotton, Maize).
- **🧪 Crop Recommendation**: Soil type and season matching matrices providing yield projections and profitability rates.
- **💧 Smart Irrigation Scheduler**: Dynamic soil moisture slider recommending water volumes (Liters/sqm) and daily watering intervals.
- **🌱 Fertilizer Dosage Calculator**: Nutrient N-P-K deficiency analysis offering Urea, DAP, MOP, or NPK blend quantities.
- **💰 Mandi Market Prices**: Live mandi rates filtering containing Yesterday's/Today's quotes and curved weekly line charts.
- **🏛️ Government Schemes**: Information and application support for PM-KISAN, crop insurance (PMFBY), soil health cards, and tractor rebates.
- **👤 Farmer Profile & Dark Theme**: Supports customizable names, village entries, preferred language configs, and real-time Dark/Light mode theme switching.

---

## 📂 Project Architecture

The directory follows **Clean Architecture** patterns:

```
lib/
├── core/
│   ├── constants/       # Global constants and app keys
│   ├── network/         # Dio ApiClient with automatic offline fallbacks
│   └── theme/           # Material 3 typography and ThemeProvider switches
└── features/            # Feature-specific MVVM layers
    ├── ai_assistant/    # Crop health chat & voice inputs
    ├── auth/            # Firebase authentication & local mock database
    ├── crop_health/     # Disease diagnosis image attachments
    ├── fertilizer/      # Fertilizer NPK calculators
    ├── home/            # Main overview dashboard grid
    ├── irrigation/      # Soil moisture watering controllers
    ├── market/          # Live Mandi rates & weekly price trend charts
    ├── onboarding/      # Splash and 3-step onboarding pages
    ├── profile/         # Farmer details & settings toggles
    ├── schemes/         # Government subsidies application panels
    └── weather/         # Detailed weather timelines
```

---

## 🛠️ Getting Started

### Prerequisites
- [Flutter SDK (v3.12.0+)](https://docs.flutter.dev/get-started/install)
- Dart SDK
- Google Chrome (for Web testing) or connected Android/iOS Emulator

### Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/prajaktalotake03-cloud/-Smart-Farming-AI-Assistant-.git
   cd -Smart-Farming-AI-Assistant-
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run Static Analysis:**
   Confirm code hygiene is warning-free:
   ```bash
   flutter analyze
   ```

4. **Run Unit & Smoke Tests:**
   Ensure widgets and provider models execute perfectly:
   ```bash
   flutter test
   ```

5. **Run the Application:**
   Run locally on your default browser:
   ```bash
   flutter run -d chrome
   ```

---

## 📦 Production Deployment

To compile the production release build of the Flutter Web bundle:
```bash
flutter build web --release
```
The static assets will be output to the `build/web/` directory, ready to be deployed to **Firebase Hosting**, **Netlify**, or **Vercel**.
