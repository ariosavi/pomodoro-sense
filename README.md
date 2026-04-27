# Stress-Aware Pomodoro

A productivity app for Garmin smartwatches that combines the Pomodoro technique with stress-level awareness. The app monitors your stress during focus sessions and automatically recommends optimal break lengths based on your physiological state.

It tracks your focus sessions and uses the watch's built-in stress sensor to recommend personalized break durations. After each focus period, the app analyzes your recent stress history and suggests either a short, long, or extra-long break depending on your stress level.

## Features

- Stress-aware break recommendations
- Pause/resume during sessions
- Session counter
- Customizable vibration and sound alerts
- Glance view support
- Progress bar during countdowns

## How It Works

1. **Ready** — Press Start to begin a focus session
2. **Focusing** — Live countdown tracks your focus time
3. **Analyzing** — App reads your stress level after focus ends
4. **Break Prompt** — Recommends break length based on stress
5. **Break** — Countdown for your recovery time

## Settings

Configure in Garmin Connect app and also in the app:

- **Focus Duration** — 15m, 20m, 25m, 30m, 45m, 60m (default: 25m)
- **Short Break** — 3m, 5m, 7m, 10m (default: 5m) — for normal stress
- **Long Break** — 8m, 10m, 15m, 20m (default: 10m) — for high stress
- **Extra Long Break** — 15m, 20m, 30m, 45m (default: 20m) — after N sessions
- **Sessions Before Long Break** — 2, 3, 4, 5, 6 (default: 4)
- **Stress Threshold** — 40, 45, 50, 55, 60, 65, 70 (default: 50)
- **Vibration** — None, Normal, or Long
- **Sound Alerts** — On/Off

## Permissions

- `SensorHistory` — Reads historical stress data from the watch

## Build & Run for development

**Prerequisites:**
- Garmin Connect IQ SDK (lin-9.1.0+)
- Java with `-Dfile.encoding=UTF-8`
- Garmin developer key

**Compile for simulator:**
```bash
java -Xms1g \
  -Dfile.encoding=UTF-8 \
  -Dapple.awt.UIElement=true \
  -jar ~/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/monkeybrains.jar \
  -o bin/StressAwarePomodoro.prg \
  -f ./monkey.jungle \
  -y ./Garmin/key/developer_key \
  -d venu3_sim \
  -w
```

The compiled `.prg` file is written to `bin/StressAwarePomodoro.prg`.
