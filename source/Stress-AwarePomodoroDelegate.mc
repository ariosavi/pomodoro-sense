import Toybox.Lang;
import Toybox.WatchUi;

class Stress_AwarePomodoroDelegate extends WatchUi.BehaviorDelegate {
    private var mView as Stress_AwarePomodoroView;

    function initialize(view as Stress_AwarePomodoroView) {
        BehaviorDelegate.initialize();
        mView = view;
    }

    function onSelect() as Boolean {
        mView.onSelect();
        return true;
    }
}
