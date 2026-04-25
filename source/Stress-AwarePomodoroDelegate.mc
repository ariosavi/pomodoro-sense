import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class Stress_AwarePomodoroDelegate extends WatchUi.BehaviorDelegate {

    function initialize(view as Stress_AwarePomodoroView) {
        BehaviorDelegate.initialize();
    }

    function onSelect() as Boolean {
        // ✅ Official Garmin standard pattern: Open Menu on SELECT button press
        var menu = new WatchUi.Menu();
        var app = getApp();

        // Dynamically build menu based on current state (GARMIN OFFICIAL PATTERN)
        if (app.state == app.STATE_READY) {
            menu.addItem("Start Pomodoro", :start);
        }

        if ((app.state == app.STATE_FOCUSING || app.state == app.STATE_BREAK) && !app.isPaused) {
            menu.addItem("Pause", :pause);
        }

        if ((app.state == app.STATE_FOCUSING || app.state == app.STATE_BREAK) && app.isPaused) {
            menu.addItem("Resume", :resume);
        }

        if (app.state != app.STATE_READY) {
            menu.addItem("Reset", :reset);
        }

        if (app.state == app.STATE_BREAK_PROMPT || app.state == app.STATE_BREAK) {
            menu.addItem("Skip Break", :skip_break);
        }

        menu.addItem("Exit", :exit);

        WatchUi.pushView(menu, new PomodoroMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    function onBack() as Boolean {
        // ✅ Official Garmin documented behavior
        // Return true = app stays running, all state preserved in background
        return true;
    }
}

class PomodoroMenuDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenuItem(menuItem as Symbol) as Boolean {
        var app = getApp();

        switch(menuItem) {
            case :start:
                if (app.state == app.STATE_READY) {
                    app.state = app.STATE_FOCUSING;
                    app.timeRemaining = app.FOCUS_DURATION;
                    app.isPaused = false;
                    app.startTimer();
                    app.vibrateStart();
                }
                break;

            case :pause:
                if ((app.state == app.STATE_FOCUSING || app.state == app.STATE_BREAK) && !app.isPaused) {
                    app.isPaused = true;
                    app.stopTimer();
                    app.vibratePause();
                }
                break;

            case :resume:
                if ((app.state == app.STATE_FOCUSING || app.state == app.STATE_BREAK) && app.isPaused) {
                    app.isPaused = false;
                    app.startTimer();
                    app.vibratePause();
                }
                break;

            case :reset:
                app.resetToReady();
                break;

            case :skip_break:
                if (app.state == app.STATE_BREAK_PROMPT || app.state == app.STATE_BREAK) {
                    app.resetToReady();
                }
                break;

            case :exit:
                WatchUi.popView(WatchUi.SLIDE_DOWN);
                WatchUi.popView(WatchUi.SLIDE_DOWN);
                return true;
        }

        WatchUi.requestUpdate();

        return true;
    }
}