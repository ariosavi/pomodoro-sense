import Toybox.Attention;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.SensorHistory;
import Toybox.Timer;
import Toybox.WatchUi;

class Stress_AwarePomodoroView extends WatchUi.View {
    private var mState as Number;
    private var mTimer as Timer.Timer?;
    private var mTimeRemaining as Number;
    private var mBreakDuration as Number;
    private var mStressAverage as Number?;

    private const STATE_READY = 0;
    private const STATE_FOCUSING = 1;
    private const STATE_ANALYZING = 2;
    private const STATE_BREAK_PROMPT = 3;
    private const STATE_BREAK = 4;

    private const FOCUS_DURATION = 25 * 60;
    private const BREAK_SHORT = 5 * 60;
    private const BREAK_LONG = 10 * 60;

    function initialize() {
        View.initialize();
        mState = STATE_READY;
        mTimeRemaining = 0;
        mBreakDuration = 0;
        mStressAverage = null;
        mTimer = null;
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

        var text = "";
        var subText = "";

        if (mState == STATE_READY) {
            text = "Ready";
            subText = "Press to Start 25m Focus";
        } else if (mState == STATE_FOCUSING) {
            text = formatTime(mTimeRemaining);
            subText = "Focusing...";
        } else if (mState == STATE_ANALYZING) {
            text = "Analyzing";
            subText = "Reading stress data...";
        } else if (mState == STATE_BREAK_PROMPT) {
            if (mBreakDuration == BREAK_SHORT) {
                text = "Good job!";
                subText = "5m Break. Press Start.";
            } else {
                text = "High stress!";
                subText = "10m Break. Press Start.";
            }
        } else if (mState == STATE_BREAK) {
            text = formatTime(mTimeRemaining);
            subText = "Break time...";
        }

        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 3,
            Graphics.FONT_LARGE,
            text,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() * 2 / 3,
            Graphics.FONT_MEDIUM,
            subText,
            Graphics.TEXT_JUSTIFY_CENTER
        );
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
        }
    }

    private function startFocus() as Void {
        mState = STATE_FOCUSING;
        mTimeRemaining = FOCUS_DURATION;
        startTimer();
        WatchUi.requestUpdate();
    }

    private function startBreak() as Void {
        mState = STATE_BREAK;
        mTimeRemaining = mBreakDuration;
        startTimer();
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

        Attention.vibrate([new Attention.VibeProfile(50, 1000)]);

        var avg = calculateAverageStress();
        mStressAverage = avg;

        if (avg != null && avg >= 50) {
            mBreakDuration = BREAK_LONG;
        } else {
            mBreakDuration = BREAK_SHORT;
        }

        mState = STATE_BREAK_PROMPT;
        WatchUi.requestUpdate();
    }

    private function transitionToReady() as Void {
        Attention.vibrate([new Attention.VibeProfile(50, 1000)]);
        mState = STATE_READY;
        mTimeRemaining = 0;
        mStressAverage = null;
        WatchUi.requestUpdate();
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
