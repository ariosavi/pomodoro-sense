import Toybox.Application;
import Toybox.Background;
import Toybox.System;
import Toybox.Time;

(:background)
class PomodoroSenseServiceDelegate extends System.ServiceDelegate {

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
                    snapshot = PomoState.completeCountdown(snapshot);
                    snapshot.alertPending = true;
                    PomoState.saveSnapshot(snapshot);
                    timerExpired = true;
                } else {
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

        Background.exit(timerExpired);
    }
}
