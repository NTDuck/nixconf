{den, ...}: {
  den.aspects.productivity.tomato = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.tomato-c
      ];
    };

    # homeManager = {pkgs, ...}: {
    #   home.packages = [
    #     pkgs.unstable.tomato-c
    #   ];

    #   xdg.configFile."tomato/config.toml".source = (pkgs.formats.toml {}).generate "tomato-config.toml" {
    #     visual = {
    #       animations = 1;
    #       icons = "nerd-icons";
    #       bg_transparency = 1;
    #       status_bar_spacing = 1;
    #       status_bar_position = 0;
    #       unfocused_panel_color = 7;
    #       focused_panel_color = 1;
    #       clock_24h = 0;

    #       status_bar.modules = {
    #         left = ["InputMode" "RealTime"];
    #         center = [];
    #         right = ["Scene" "LineColumn"];
    #       };
    #     };

    #     notifications = {
    #       enabled = true;
    #       sound = true;
    #       sound_volume = 0.5;

    #       work = {
    #         title = "Work!";
    #         description = "You need to focus";
    #         audio_path = "$DATADIR/sounds/dfltnotify.mp3";
    #       };

    #       short_pause = {
    #         title = "Pause Break";
    #         description = "You have some time to chill";
    #         audio_path = "$DATADIR/sounds/pausenotify.mp3";
    #       };

    #       long_pause = {
    #         title = "Long Pause Break";
    #         description = "You have some time to chill";
    #         audio_path = "$DATADIR/sounds/pausenotify.mp3";
    #       };

    #       end_cycle = {
    #         title = "End of Pomodoro Cycle";
    #         description = "Feel free to start another!";
    #         audio_path = "$DATADIR/sounds/endnotify.mp3";
    #       };
    #     };

    #     pomodoro = {
    #       amount = 4;
    #       work_time = 25;
    #       short_pause = 5;
    #       long_pause = 30;
    #     };

    #     noise = {
    #       enabled = true;
    #       master_volume = 50;

    #       tracks = [
    #         {
    #           name = "Rain";
    #           icons = ["󰖖" "☔" "R"];
    #           sound_path = "$DATADIR/sounds/ambience-rain.mp3";
    #           default_volume = 50;
    #           sel_color = 14;
    #         }
    #         {
    #           name = "Fire";
    #           icons = ["󰈸" "🔥" "F"];
    #           sound_path = "$DATADIR/sounds/ambience-fire.mp3";
    #           default_volume = 50;
    #           sel_color = 13;
    #         }
    #         {
    #           name = "Wind";
    #           icons = ["󰖝" "🍃" "W"];
    #           sound_path = "$DATADIR/sounds/ambience-wind.mp3";
    #           default_volume = 50;
    #           sel_color = 15;
    #         }
    #         {
    #           name = "Thunder";
    #           icons = ["󱐋" "⚡" "T"];
    #           sound_path = "$DATADIR/sounds/ambience-thunder.mp3";
    #           default_volume = 50;
    #           sel_color = 11;
    #         }
    #       ];
    #     };

    #     logging = {
    #       timer_log = true;
    #       timerlog_icons = true;
    #       work_log = true;
    #       notepad_log = true;
    #     };

    #     autostart = {
    #       work = true;
    #       pause = true;
    #     };

    #     misc = {
    #       wsl = false;
    #       fps = 120;
    #       max_note_depth = 1;
    #       resume_from_unfinished_session = true;
    #     };

    #     keybindings = {
    #       DEFAULT = {
    #         ALL_SCENES = {
    #           ChangeSelectedItemLeft = ["KEY_UP" "k" "KEY_LEFT" "h"];
    #           ChangeSelectedItemRight = ["KEY_DOWN" "j" "KEY_RIGHT" "l"];
    #           ExecuteMenuAction = ["ENTER" "KEY_ENTER"];
    #           NextPanel = ["SPACE"];
    #           QuitApp = ["q" "ESC" "CTRLC"];
    #           OpenNoiseMenu = ["CTRLW" "w"];
    #           OpenHistoryPopup = ["CTRLH"];
    #           GoPrevSlide = ["KEY_LEFT" "h"];
    #           GoNextSlide = ["KEY_RIGHT" "l"];
    #           ClosePopup = ["ENTER" "KEY_ENTER" "q" "ESC" "CTRLC"];
    #           SelectPrevButton = ["KEY_LEFT" "h"];
    #           SelectNextButton = ["KEY_RIGHT" "l"];
    #           ExecuteButtonAction = ["ENTER" "KEY_ENTER"];
    #           OpenHelp = ["?" "KEY_F(1)"];
    #         };
    #         SCENE_NOTES = {
    #           ToggleMoveMode = ["V"];
    #           MoveNoteDownWrapper = ["j" "KEY_DOWN"];
    #           MoveNoteUpWrapper = ["k" "KEY_UP"];
    #           PromoteNoteWrapper = ["h" "KEY_LEFT"];
    #           DemoteNoteWrapper = ["l" "KEY_RIGHT"];
    #           DeleteNoteAtNotes = ["d"];
    #           AddNewTask = ["t"];
    #           AddNewNote = ["n"];
    #           AddSubtask = ["T"];
    #           AddSubnote = ["N"];
    #           EditCurrentNote = ["e"];
    #           ExitMoveMode = ["ENTER"];
    #           ToggleTaskAtNotes = ["ENTER"];
    #           UndoNotes = ["u"];
    #           RedoNotes = ["CTRLR"];
    #           QuitAppNotes = ["ESC" "CTRLC" "q"];
    #         };
    #         SCENE_MAIN_MENU = {
    #           SelectNextItem = ["KEY_DOWN" "KEY_RIGHT" "j" "l"];
    #           SelectPreviousItem = ["KEY_UP" "KEY_LEFT" "k" "h"];
    #           ExecuteMenuAction = ["ENTER"];
    #         };
    #         POMODORO_SCENES = {
    #           SkipPomodoroStep = ["s"];
    #           TogglePause = ["p"];
    #           OpenResetMenu = ["CTRLR"];
    #           ReturnToMainMenu = ["m"];
    #         };
    #         SCENE_NOISE = {
    #           NoiseClose = ["q" "ESC" "CTRLC"];
    #           NoiseSelectPrev = ["k" "KEY_UP"];
    #           NoiseSelectNext = ["j" "KEY_DOWN"];
    #           NoiseTogglePlay = ["SPACE"];
    #           NoiseVolumeUp = ["l" "KEY_RIGHT" "+" "="];
    #           NoiseVolumeDown = ["h" "KEY_LEFT" "-" "_"];
    #           NoiseResetAll = ["r" "R"];
    #         };
    #       };
    #       NORMAL = {
    #         SCENE_NOTES = {
    #           InputCursorLeft = ["h" "KEY_LEFT"];
    #           InputCursorRight = ["l" "KEY_RIGHT"];
    #           InputDeleteChar = ["x"];
    #           InputESC = ["ESC" "CTRLC"];
    #           InputCommit = ["ENTER" "KEY_ENTER"];
    #           SwitchToInsertMode = ["i"];
    #           SwitchToInsertModeAppend = ["a"];
    #           SwitchToVisualMode = ["v"];
    #           UndoNotes = ["u"];
    #           RedoNotes = ["CTRLR"];
    #         };
    #       };
    #       INSERT = {
    #         SCENE_NOTES = {
    #           InputCursorLeft = ["KEY_LEFT"];
    #           InputCursorRight = ["KEY_RIGHT"];
    #           InputBackspace = ["KEY_BACKSPACE" "BACKSPACE"];
    #           InputCommit = ["ENTER" "KEY_ENTER"];
    #           InputESC = ["ESC" "CTRLC"];
    #           SwitchToVisualMode = ["v"];
    #         };
    #       };
    #       VISUAL = {
    #         SCENE_NOTES = {
    #           InputCursorLeft = ["h" "KEY_LEFT"];
    #           InputCursorRight = ["l" "KEY_RIGHT"];
    #           InputVisualDelete = ["x"];
    #           InputCommit = ["ENTER" "KEY_ENTER"];
    #           InputESC = ["ESC" "CTRLC"];
    #           InputSwitchToInsertFromVisual = ["a"];
    #           SwitchToInsertMode = ["i"];
    #         };
    #       };
    #     };
    #   };
    # };
  };
}
