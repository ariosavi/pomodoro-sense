import Toybox.Application;
import Toybox.Attention;
import Toybox.Background;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

(:background)
class Stress_AwarePomodoroServiceDelegate extends System.ServiceDelegate {

    function initialize() {
        ServiceDelegate.initialize();
    }

    function onTemporalEvent() as Void {
        var timerExpired = false;

        try {
            var snapshot = PomoState.loadSnapshot();

            if (PomoState.isRunningState(snapshot.state)
                    && !snapshot.isPaused
                    && snapshot.timerEndEpoch > 0) {

                var now = Time.now().value();

                if (now >= snapshot.timerEndEpoch) {
                    // Timer expired — update state and mark alertPending
                    snapshot = PomoState.completeCountdown(snapshot);
                    snapshot.alertPending = true;
                    PomoState.saveSnapshot(snapshot);
                    timerExpired = true;
                } else {
                    // Not expired yet — re-schedule next poll in 5 minutes
                    var pollInterval = 5 * 60;
                    var nextWakeUp = now + pollInterval;
                    if (snapshot.timerEndEpoch < nextWakeUp) {
                        nextWakeUp = snapshot.timerEndEpoch;
                    }
                    try {
                        Background.registerForTemporalEvent(new Time.Moment(nextWakeUp));
                    } catch (ex) {}
                }
            }
        } catch (ex) {}

        // Pass timerExpired=true to foreground via onBackgroundData.
        // Garmin OS will wake/notify the foreground app which then vibrates.
        // NOTE: Attention.vibrate() does NOT work in background context on most
        // Garmin devices — vibration MUST be triggered from foreground in
        // onBackgroundData().
        Background.exit(timerExpired);
    }
}
