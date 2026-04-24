import Toybox.Graphics;
import Toybox.Lang;
import Toybox.SensorHistory;
import Toybox.WatchUi;

class Stress_AwarePomodoroGlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();

        dc.drawText(
            width / 2,
            2,
            Graphics.FONT_TINY,
            "Stress-Aware Pomodoro",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        var stressText = "Ready to focus";
        var iter = SensorHistory.getStressHistory({
            :period => 1,
            :order => SensorHistory.ORDER_NEWEST_FIRST
        });

        if (iter != null) {
            var sample = iter.next();
            if (sample != null && sample.data != null) {
                stressText = "Stress: " + sample.data;
            }
        }

        dc.drawText(
            width / 2,
            height / 2 + 2,
            Graphics.FONT_SMALL,
            stressText,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }
}
