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

    function onBack() as Boolean {
        var handled = mView.onBack();
        if (!handled) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
        return true;
    }

    function onNextPage() as Boolean {
        mView.onSkip();
        return true;
    }
}
