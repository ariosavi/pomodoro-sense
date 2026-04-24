import Toybox.Lang;
import Toybox.WatchUi;

class Stress_AwarePomodoroDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new Stress_AwarePomodoroMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}