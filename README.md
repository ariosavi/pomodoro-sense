# Stress-Aware Pomodoro

A Garmin Connect IQ watch app that combines the classic Pomodoro Technique with real-time stress monitoring to suggest personalized break lengths.

## Features

- **Glance View**: Quickly see the app name and your latest stress score, or "Ready to focus" when stress data is unavailable.
- **Stress-Aware Breaks**: After each 25-minute focus session, the app reads your average stress level from the last 25 minutes and adjusts your break:
  - **Low stress** (`< 50` or no data): 5-minute break
  - **High stress** (`>= 50`): 10-minute break
- **Vibration Alerts**: Notifies you when a focus session ends and when a break ends.

## App Flow

1. **Ready** — Press Start to begin a 25-minute focus session.
2. **Focusing** — A live countdown (MM:SS) tracks your focus time.
3. **Analyzing** — When focus ends, the app vibrates and reads your average stress score.
4. **Break Prompt** — Displays a recommended break length based on your stress.
5. **Break** — Press Start to begin the countdown. When it ends, the app vibrates and returns to Ready.

## Permissions

- `SensorHistory` — Required to read historical stress data.

## Supported Devices

- fenix 7
- fenix 8 (47mm)
- venu 3

## Building

Open this project in Visual Studio Code with the **Garmin Connect IQ** extension and build as usual (`Monkey C: Build Current Project`).

## File Overview

| File | Description |
|------|-------------|
| `source/Stress-AwarePomodoroApp.mc` | Application entry point and Glance View registration |
| `source/Stress-AwarePomodoroView.mc` | Main view with all 5 states and timer logic |
| `source/Stress-AwarePomodoroDelegate.mc` | Button delegate (handles Start/Select) |
| `source/Stress-AwarePomodoroGlanceView.mc` | Glance view showing latest stress score |
| `manifest.xml` | App manifest with `SensorHistory` permission |
| `resources/strings/strings.xml` | App strings |
| `resources/drawables/` | Launcher icon and other drawables |
