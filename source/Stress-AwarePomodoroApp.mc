import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class Stress_AwarePomodoroApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        var view = new Stress_AwarePomodoroView();
        return [view, new Stress_AwarePomodoroDelegate(view)];
    }

    function getGlanceView() as [WatchUi.GlanceView] or [WatchUi.GlanceView, WatchUi.GlanceViewDelegate] or Null {
        return [new Stress_AwarePomodoroGlanceView()];
    }
}

function getApp() as Stress_AwarePomodoroApp {
    return Application.getApp() as Stress_AwarePomodoroApp;
}
