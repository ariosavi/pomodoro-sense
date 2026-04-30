import Toybox.Graphics;
import Toybox.Lang;
import Toybox.SensorHistory;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Math;

class PomodoroSenseView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onShow() as Void {
        WatchUi.requestUpdate();
    }

    function onHide() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var h = dc.getHeight();
        var w = dc.getWidth();
        var cx = w / 2;

        var text = "";
        var subText = "";
        var infoText = "";
        var accentColor = Graphics.COLOR_WHITE;
        
        var app = getApp();

        // Determine state-specific display text and colors
        if (app.state == app.STATE_READY) {
            text = "Ready";
            subText = "Press Start";
            infoText = "Completed: " + app.sessionCount;
            accentColor = Graphics.COLOR_GREEN;
        } else if (app.state == app.STATE_FOCUSING) {
            if (app.isPaused) {
                text = "Paused";
                subText = formatTime(app.timeRemaining);
                infoText = "";
                accentColor = Graphics.COLOR_YELLOW;
            } else {
                text = formatTime(app.timeRemaining);
                subText = "Focusing";
                infoText = "Completed: " + app.sessionCount;
                accentColor = Graphics.COLOR_GREEN;
            }
        } else if (app.state == app.STATE_ANALYZING) {
            text = "Analyzing";
            subText = "Reading stress";
            accentColor = Graphics.COLOR_ORANGE;
        } else if (app.state == app.STATE_BREAK_PROMPT) {
            var breakMinutes = app.breakDuration / 60;
            if (breakMinutes == app.breakShortMinutes) {
                text = "Good job";
                subText = breakMinutes + "m break";
                accentColor = Graphics.COLOR_BLUE;
            } else if (breakMinutes == app.breakLongMinutes) {
                text = "High stress";
                subText = breakMinutes + "m break";
                accentColor = Graphics.COLOR_RED;
            } else {
                text = "Great work";
                subText = breakMinutes + "m break";
                accentColor = Graphics.COLOR_PURPLE;
            }
            infoText = "Completed: " + app.sessionCount;
        } else if (app.state == app.STATE_BREAK) {
            if (app.isPaused) {
                text = "Paused";
                subText = formatTime(app.timeRemaining);
                infoText = "Completed: " + app.sessionCount;
                accentColor = Graphics.COLOR_YELLOW;
            } else {
                text = formatTime(app.timeRemaining);
                subText = "Break";
                infoText = "Completed: " + app.sessionCount;
                accentColor = Graphics.COLOR_BLUE;
            }
        }

        // Draw clock at the top
        drawClock(dc, cx, (h * 0.07).toNumber());

        // Draw progress bar for Focusing and Break states
        if (app.state == app.STATE_FOCUSING || app.state == app.STATE_BREAK) {
            drawProgressBar(dc, accentColor, (h * 0.14).toNumber());
        }

        // Draw main title with accent color
        dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (h * 0.28).toNumber(), Graphics.FONT_LARGE, text, Graphics.TEXT_JUSTIFY_CENTER);

        // Draw subtitle
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (h * 0.42).toNumber(), Graphics.FONT_SMALL, subText, Graphics.TEXT_JUSTIFY_CENTER);

        var yInfoBase = (h * 0.54).toNumber();
        var yLineHeight = 32;
        var yCurrentLine = yInfoBase;
        
        if (app.state == app.STATE_READY) {
            // ===== READY STATE DISPLAY =====
            // Display focus duration
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, yCurrentLine, Graphics.FONT_XTINY, "Focus duration: " + app.focusDurationMinutes + " min", Graphics.TEXT_JUSTIFY_CENTER);
            yCurrentLine += yLineHeight;

            // Display completed sessions count
            if (infoText.length() > 0) {
                dc.drawText(cx, yCurrentLine, Graphics.FONT_XTINY, infoText, Graphics.TEXT_JUSTIFY_CENTER);
                yCurrentLine += yLineHeight;
            }

            // Draw separator line
            yCurrentLine += 10;
            drawSeparatorLine(dc, yCurrentLine, w);
            yCurrentLine += 10;

            // Display current stress level with color coding (green < 30, yellow < 60, red >= 60)
            var currentStress = getCurrentStress();
            var stressText = "Stress: " + (currentStress != null ? Math.round(currentStress).toNumber() : "-");
            var stressColor = Graphics.COLOR_LT_GRAY;
            if (currentStress != null) {
                var stressLevel = Math.round(currentStress).toNumber();
                if (stressLevel < 30) {
                    stressColor = Graphics.COLOR_GREEN;
                } else if (stressLevel < 60) {
                    stressColor = Graphics.COLOR_YELLOW;
                } else {
                    stressColor = Graphics.COLOR_RED;
                }
            }
            dc.setColor(stressColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, yCurrentLine, Graphics.FONT_XTINY, stressText, Graphics.TEXT_JUSTIFY_CENTER);
            yCurrentLine += yLineHeight;

            // Display current body battery level in yellow
            var bodyBattery = getCurrentBodyBattery();
            var bodyBatteryText = "Body Battery: " + (bodyBattery != null ? Math.round(bodyBattery).toNumber() : "-");
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, yCurrentLine, Graphics.FONT_XTINY, bodyBatteryText, Graphics.TEXT_JUSTIFY_CENTER);
            yCurrentLine += yLineHeight;

            // Display current heart rate in dark red
            var heartRate = getCurrentHeartRate();
            var heartRateText = "HR: " + (heartRate != null ? Math.round(heartRate).toNumber() : "-");
            dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, yCurrentLine, Graphics.FONT_XTINY, heartRateText, Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            // ===== FOCUSING / BREAK / BREAK_PROMPT STATES DISPLAY =====
            // Display completed sessions or other info
            if (infoText.length() > 0) {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cx, yCurrentLine, Graphics.FONT_XTINY, infoText, Graphics.TEXT_JUSTIFY_CENTER);
                yCurrentLine += yLineHeight;
            }
            
            // Draw separator line
            yCurrentLine += 10;
            drawSeparatorLine(dc, yCurrentLine, w);
            yCurrentLine += 10;

            // Display stress level (average for Break Prompt, current for Focusing/Break)
            if (app.state == app.STATE_BREAK_PROMPT && app.stressAverage != null) {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cx, yCurrentLine, Graphics.FONT_XTINY, "Avg stress: " + Math.round(app.stressAverage).toNumber(), Graphics.TEXT_JUSTIFY_CENTER);
                yCurrentLine += yLineHeight;
            } else {
                var currentStress = getCurrentStress();
                if (currentStress != null) {
                    var stressLevel = Math.round(currentStress).toNumber();
                    var stressColor = Graphics.COLOR_LT_GRAY;

                    if (stressLevel < 30) {
                        stressColor = Graphics.COLOR_GREEN;
                    } else if (stressLevel < 60) {
                        stressColor = Graphics.COLOR_YELLOW;
                    } else {
                        stressColor = Graphics.COLOR_RED;
                    }

                    dc.setColor(stressColor, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(cx, yCurrentLine, Graphics.FONT_XTINY, "Stress: " + stressLevel, Graphics.TEXT_JUSTIFY_CENTER);
                } else {
                    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(cx, yCurrentLine, Graphics.FONT_XTINY, "Stress: -", Graphics.TEXT_JUSTIFY_CENTER);
                }
                yCurrentLine += yLineHeight;
            }

            // Display body battery (show delta during Break Prompt, current otherwise)
            var bodyBattery = getCurrentBodyBattery();
            var bodyBatteryText = "";
            if (app.state == app.STATE_BREAK_PROMPT && app.bodyBatteryAtStart != null) {
                var currentBB = bodyBattery != null ? Math.round(bodyBattery).toNumber() : null;
                if (currentBB != null) {
                    var startBB = Math.round(app.bodyBatteryAtStart).toNumber();
                    var changeBB = currentBB - startBB;
                    var changeStr = "";
                    if (changeBB >= 0) {
                        changeStr = "+" + changeBB;
                    } else {
                        changeStr = changeBB.toString();
                    }
                    bodyBatteryText = "Body Battery: " + startBB + "→" + currentBB + " (" + changeStr + ")";
                } else {
                    var startBB = Math.round(app.bodyBatteryAtStart).toNumber();
                    bodyBatteryText = "Body Battery: " + startBB + "→- (-)";
                }
            } else {
                bodyBatteryText = "Body Battery: " + (bodyBattery != null ? Math.round(bodyBattery).toNumber() : "-");
            }
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, yCurrentLine, Graphics.FONT_XTINY, bodyBatteryText, Graphics.TEXT_JUSTIFY_CENTER);
            yCurrentLine += yLineHeight;

            // Display current heart rate in dark red
            var heartRate = getCurrentHeartRate();
            var heartRateText = "HR: " + (heartRate != null ? Math.round(heartRate).toNumber() : "-");
            dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, yCurrentLine, Graphics.FONT_XTINY, heartRateText, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    // Draw the time at the top of the screen
    private function drawClock(dc as Dc, cx as Number, y as Number) as Void {
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour.format("%02d"), clockTime.min.format("%02d")]);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, y, Graphics.FONT_XTINY, timeString, Graphics.TEXT_JUSTIFY_CENTER);
        
    }

    // Draw the circular progress bar
    private function drawProgressBar(dc as Dc, color as Number, barY as Number) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;
        var radius = cx - 3;
        var thickness = 12;

        var app = getApp();
        var remaining = app.timeRemaining;
        var total = (app.state == app.STATE_FOCUSING) ? (app.focusDurationMinutes * 60) : app.breakDuration;
        var progress = 1.0 - (remaining.toFloat() / total.toFloat());
        if (progress < 0) { progress = 0; }
        if (progress > 1) { progress = 1; }

        var sweepAngle = progress * 360.0;

        dc.setPenWidth(thickness);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, 90, 450);

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, 90, (90 + sweepAngle).toNumber());
    }

    // Format time display in MM:SS or MM format
    private function formatTime(seconds as Number) as String {
        var app = getApp();
        var m = seconds / 60;
        var s = seconds % 60;
        
        if (app.displaySeconds) {
            return Lang.format("$1$:$2$", [m.format("%02d"), s.format("%02d")]);
        } else {
            return m.format("%d");
        }
    }

    // Get the latest stress reading from sensor history
    private function getCurrentStress() as Number? {
        var iter = SensorHistory.getStressHistory({:period => 3});
        var latestStress = null;
        var sample = iter.next();
        while (sample != null) {
            if (sample.data != null) {
                latestStress = sample.data;
            }
            sample = iter.next();
        }
        return latestStress;
    }

    // Get the latest body battery reading from sensor history
    private function getCurrentBodyBattery() as Number? {
        try {
            var iter = SensorHistory.getBodyBatteryHistory({:period => 1});
            var sample = iter.next();
            if (sample != null && sample.data != null) {
                return sample.data;
            }
        } catch (ex) {
        }
        return null;
    }

    // Get the latest heart rate reading from sensor history
    private function getCurrentHeartRate() as Number? {
        try {
            var iter = SensorHistory.getHeartRateHistory({:period => 1});
            var sample = iter.next();
            if (sample != null && sample.data != null) {
                return sample.data;
            }
        } catch (ex) {
        }
        return null;
    }

    // Draw a consistent horizontal separator line
    private function drawSeparatorLine(dc as Dc, y as Number, w as Number) as Void {
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(50, y + 1, w - 50, y + 1);
    }
}
