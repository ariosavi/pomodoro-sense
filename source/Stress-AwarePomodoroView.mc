import Toybox.Attention;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.SensorHistory;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

class Stress_AwarePomodoroView extends WatchUi.View {
    private var mState as Number;
    private var mTimer as Timer.Timer?;
    private var mTimeRemaining as Number;
    private var mBreakDuration as Number;
    private var mStressAverage as Number?;
    private var mIsPaused as Boolean;
    private var mSessionCount as Number;

    private const STATE_READY = 0;
    private const STATE_FOCUSING = 1;
    private const STATE_ANALYZING = 2;
    private const STATE_BREAK_PROMPT = 3;
    private const STATE_BREAK = 4;

    private const FOCUS_DURATION = 25 * 60;
    private const BREAK_SHORT = 5 * 60;
    private const BREAK_LONG = 10 * 60;
    private const BREAK_EXTRA_LONG = 20 * 60;
    private const SESSIONS_BEFORE_LONG_BREAK = 4;

    function initialize() {
        View.initialize();
        mState = STATE_READY;
        mTimeRemaining = 0;
        mBreakDuration = 0;
        mStressAverage = null;
        mTimer = null;
        mIsPaused = false;
        mSessionCount = 0;
    }

    function onShow() as Void {
        WatchUi.requestUpdate();
    }

    function onHide() as Void {
        stopTimer();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var h = dc.getHeight();
        var w = dc.getWidth();
        var cx = w / 2;
        var cy = h / 2;

        var text = "";
        var subText = "";
        var bottomText = "";
        var accentColor = Graphics.COLOR_WHITE;

        if (mState == STATE_READY) {
            text = "Ready";
            subText = "Start = Focus";
            accentColor = Graphics.COLOR_GREEN;
            if (mSessionCount > 0) {
                bottomText = "Done: " + mSessionCount;
            }
        } else if (mState == STATE_FOCUSING) {
            if (mIsPaused) {
                text = "Paused";
                subText = formatTime(mTimeRemaining);
                bottomText = "Bk = Reset";
                accentColor = Graphics.COLOR_YELLOW;
            } else {
                text = formatTime(mTimeRemaining);
                subText = "Focusing";
                bottomText = "Done: " + mSessionCount;
                accentColor = Graphics.COLOR_GREEN;
            }
            drawProgressBar(dc, mTimeRemaining, FOCUS_DURATION, accentColor);
        } else if (mState == STATE_ANALYZING) {
            text = "Analyzing";
            subText = "Stress check";
            accentColor = Graphics.COLOR_ORANGE;
        } else if (mState == STATE_BREAK_PROMPT) {
            if (mBreakDuration == BREAK_SHORT) {
                text = "Good job";
                subText = "5m Break";
                accentColor = Graphics.COLOR_BLUE;
            } else if (mBreakDuration == BREAK_LONG) {
                text = "High stress";
                subText = "10m Break";
                accentColor = Graphics.COLOR_RED;
            } else {
                text = "Great work";
                subText = "20m Break";
                accentColor = Graphics.COLOR_PURPLE;
            }
            bottomText = "Start = Go";
            if (mStressAverage != null) {
                bottomText = "Stress " + mStressAverage;
            }
        } else if (mState == STATE_BREAK) {
            if (mIsPaused) {
                text = "Paused";
                subText = formatTime(mTimeRemaining);
                bottomText = "Bk = Reset";
                accentColor = Graphics.COLOR_YELLOW;
            } else {
                text = formatTime(mTimeRemaining);
                subText = "Break";
                accentColor = Graphics.COLOR_BLUE;
            }
            drawProgressBar(dc, mTimeRemaining, mBreakDuration, accentColor);
        }

        // Centered layout with safe offsets for round watches
        dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 50, Graphics.FONT_SYSTEM_LARGE, text, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 10, Graphics.FONT_SYSTEM_MEDIUM, subText, Graphics.TEXT_JUSTIFY_CENTER);

        if (bottomText.length() > 0) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, cy + 28, Graphics.FONT_SYSTEM_SMALL, bottomText, Graphics.TEXT_JUSTIFY_CENTER);
        }

        drawClock(dc, cy + 55);
    }

    private function drawClock(dc as Dc, y as Number) as Void {
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour.format("%02d"), clockTime.min.format("%02d")]);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, y, Graphics.FONT_XTINY, timeString, Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function drawProgressBar(dc as Dc, remaining as Number, total as Number, color as Number) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var barW = (w * 0.40).toNumber();
        var barH = 4;
        var barX = (w - barW) / 2;
        var barY = (h * 0.12).toNumber();

        var progress = 1.0 - (remaining.toFloat() / total.toFloat());
        if (progress < 0) { progress = 0; }
        if (progress > 1) { progress = 1; }

        var fillW = (barW * progress).toNumber();
        if (fillW < 1) { fillW = 1; }

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(barX, barY, barW, barH);

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(barX, barY, fillW, barH);
    }

    private function formatTime(seconds as Number) as String {
        var m = seconds / 60;
        var s = seconds % 60;
        return Lang.format("$1$:$2$", [m.format("%02d"), s.format("%02d")]);
    }

    function onSelect() as Void {
        if (mState == STATE_READY) {
            startFocus();
        } else if (mState == STATE_BREAK_PROMPT) {
            startBreak();
        } else if (mState == STATE_FOCUSING || mState == STATE_BREAK) {
            togglePauseResume();
        }
    }

    function onBack() as Boolean {
        if (mState == STATE_READY) {
            return false;
        }
        if (mIsPaused) {
            resetToReady();
            return true;
        }
        if (mState == STATE_BREAK_PROMPT) {
            resetToReady();
            return true;
        }
        return true;
    }

    function onSkip() as Void {
        if (mState == STATE_BREAK_PROMPT || mState == STATE_BREAK) {
            resetToReady();
        }
    }

    private function startFocus() as Void {
        mState = STATE_FOCUSING;
        mTimeRemaining = FOCUS_DURATION;
        mIsPaused = false;
        startTimer();
        WatchUi.requestUpdate();
    }

    private function startBreak() as Void {
        mState = STATE_BREAK;
        mTimeRemaining = mBreakDuration;
        mIsPaused = false;
        startTimer();
        WatchUi.requestUpdate();
    }

    private function togglePauseResume() as Void {
        if (mIsPaused) {
            mIsPaused = false;
            startTimer();
        } else {
            mIsPaused = true;
            stopTimer();
        }
        WatchUi.requestUpdate();
    }

    private function startTimer() as Void {
        if (mTimer == null) {
            mTimer = new Timer.Timer();
        }
        mTimer.start(method(:onTimerTick), 1000, true);
    }

    private function stopTimer() as Void {
        if (mTimer != null) {
            mTimer.stop();
        }
    }

    function onTimerTick() as Void {
        mTimeRemaining = mTimeRemaining - 1;
        if (mTimeRemaining <= 0) {
            stopTimer();
            if (mState == STATE_FOCUSING) {
                transitionToAnalyzing();
            } else if (mState == STATE_BREAK) {
                transitionToReady();
            }
        } else {
            WatchUi.requestUpdate();
        }
    }

    private function transitionToAnalyzing() as Void {
        mState = STATE_ANALYZING;
        WatchUi.requestUpdate();

        vibrateAndTone();

        mSessionCount = mSessionCount + 1;

        var avg = calculateAverageStress();
        mStressAverage = avg;

        if (mSessionCount % SESSIONS_BEFORE_LONG_BREAK == 0) {
            mBreakDuration = BREAK_EXTRA_LONG;
        } else if (avg != null && avg >= 50) {
            mBreakDuration = BREAK_LONG;
        } else {
            mBreakDuration = BREAK_SHORT;
        }

        mState = STATE_BREAK_PROMPT;
        WatchUi.requestUpdate();
    }

    private function transitionToReady() as Void {
        vibrateAndTone();
        mState = STATE_READY;
        mTimeRemaining = 0;
        mStressAverage = null;
        mIsPaused = false;
        WatchUi.requestUpdate();
    }

    private function resetToReady() as Void {
        stopTimer();
        mState = STATE_READY;
        mTimeRemaining = 0;
        mStressAverage = null;
        mIsPaused = false;
        WatchUi.requestUpdate();
    }

    private function vibrateAndTone() as Void {
        Attention.vibrate([new Attention.VibeProfile(50, 1000)]);
        if (Attention has :playTone) {
            Attention.playTone(Attention.TONE_ALERT_LO);
        }
    }

    private function calculateAverageStress() as Number? {
        var iter = SensorHistory.getStressHistory({:period => 25});
        if (iter == null) {
            return null;
        }

        var sum = 0;
        var count = 0;
        var sample = iter.next();
        while (sample != null) {
            if (sample.data != null) {
                sum = sum + sample.data;
                count = count + 1;
            }
            sample = iter.next();
        }

        if (count == 0) {
            return null;
        }
        return sum / count;
    }
}
