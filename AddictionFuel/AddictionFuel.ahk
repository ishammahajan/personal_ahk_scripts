#SingleInstance Force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, RegEx ; For better matching of addiction windows
SetKeyDelay, 500 ; For better window control
DetectHiddenWindows, On ; Detect windows accross virtual desktops
CoordMode, ToolTip ; Sets ToolTip coordinates as relative to main screen

isPaused := 0
pauseForced := 0

IniRead, breakCount, AddictionFuel.ini, Settings, breakCount, 0
IniRead, breakCountBeforeLongBreak, AddictionFuel.ini, Settings, breakCountBeforeLongBreak, 4
IniRead, LongBreakPeriod, AddictionFuel.ini, Settings, LongBreakPeriod, 1800000
IniRead, ShortBreakPeriod, AddictionFuel.ini, Settings, ShortBreakPeriod, 300000
IniRead, WorkPeriod, AddictionFuel.ini, Settings, WorkPeriod, 1800000
IniRead, AddictionsRegex, AddictionFuel.ini, Settings, AddictionsRegex, (YouTube|Twitch|Patreon)
IniRead, DisableWhenActiveWindow, AddictionFuel.ini, Settings, DisableWhenActiveWindow, (Dota)
IniRead, StartWithBreak, AddictionFuel.ini, Settings, StartWithBreak, 0

;; Ignores hotkeys when specified windows are active
Hotkey, IfWinNotActive, %DisableWhenActiveWindow%
Hotkey, !+r, ReloadScript
;Hotkey, #!y, ShowCurrentBreakCounterValue
;Hotkey, #y, ResetBreakCounter
;Hotkey, ^y, TogglePlayStatus
;Hotkey, #!y, ToggleSpotify


;;   _____ _    _ _____ 
;;  / ____| |  | |_   _|
;; | |  __| |  | | | |  
;; | | |_ | |  | | | |  
;; | |__| | |__| |_| |_ 
;;  \_____|\____/|_____|
;;                      

Gui, Add, Text, x242 y239 w0 h0 , Breaks before Long Break:
Gui, Add, Button, x442 y289 w60 h20 gToggleAddictionCycleOnOff vToggleCycleButton, &Start
Gui, Add, Button, x322 y289 w10 h0 , Button
Gui, Add, Button, x272 y289 w90 h20 gResetBreakCounter vResetBreaksButton, % "&Reset Breaks (" breakCount ")"
if (StartWithBreak == 1) 
	Gui, Add, CheckBox, x342 y179 w70 h20 vStartWithBreak Checked, with break
else
	Gui, Add, CheckBox, x342 y179 w70 h20 vStartWithBreak, with break
Gui, Add, Text, x12 y289 w60 h20 0x200 vCyclePartIndicator, Cycle Stop
Gui, Add, Progress, x72 y289 w190 h20 +Border vAddictionCycleProgress, 0
Gui, Add, GroupBox, x12 y9 w490 h270 , Settings
Gui, Add, StatusBar, x12 y9 w460 h270 , 
Gui, Add, Text, x22 y39 w60 h30 , Initial Break Count:
Gui, Add, Edit, x92 y39 w140 h20 +Right vbreakCount, %breakCount%
Gui, Add, Text, x242 y39 w90 h30 , Breaks Before Long Break
Gui, Add, Edit, x342 y39 w150 h20 +Right vbreakCountBeforeLongBreak, %breakCountBeforeLongBreak%
Gui, Add, Text, x242 y89 w90 h30 , Short Break Period (ms):
Gui, Add, Edit, x342 y89 w150 h20 +Right vShortBreakPeriod, %ShortBreakPeriod%
Gui, Add, Text, x22 y89 w60 h30 , Long Break Period (ms):
Gui, Add, Edit, x92 y89 w140 h20 +Right vLongBreakPeriod, %LongBreakPeriod%
Gui, Add, Text, x22 y129 w60 h30 , Work Period (ms):
Gui, Add, Edit, x92 y129 w140 h20 +Right vWorkPeriod, %WorkPeriod%
Gui, Add, Text, x242 y129 w90 h40 , Addiction Window Title Matching Regex:
Gui, Add, Edit, x342 y129 w150 h40 +Right vAddictionsRegex, %AddictionsRegex%
Gui, Add, Text, x22 y179 w60 h80 , Pause Cycle when Window Title matches Regex:
Gui, Add, Edit, x92 y179 w140 h40 +Right vDisableWhenActiveWindow, %DisableWhenActiveWindow%
Gui, Add, Button, x372 y249 w90 h20 gSettingsWrite, &Apply
Gui, Add, Text, x242 y179 w90 h30 , Script Start Settings
Gui, Add, Button, x372 y289 w60 h20 gforceTogglePauseScript vPauseButton +Disabled, Pause
; Generated using SmartGUI Creator 4.0
Gui, Show, x162 y242 h338 w518, Addiction Fuel
Return

GuiClose:
ExitApp

;;  _    _ _   _ _ _ _   _           
;; | |  | | | (_) (_) | (_)          
;; | |  | | |_ _| |_| |_ _  ___  ___ 
;; | |  | | __| | | | __| |/ _ \/ __|
;; | |__| | |_| | | | |_| |  __/\__ \
;;  \____/ \__|_|_|_|\__|_|\___||___/
;;                                   

ReloadScript:
Reload
return

;; Read/Write to ini file
SettingsWrite:
Gui, Submit, NoHide
IniWrite, %breakCount%, AddictionFuel.ini, Settings, breakCount
IniWrite, %breakCountBeforeLongBreak%, AddictionFuel.ini, Settings, breakCountBeforeLongBreak
IniWrite, %LongBreakPeriod%, AddictionFuel.ini, Settings, LongBreakPeriod
IniWrite, %ShortBreakPeriod%, AddictionFuel.ini, Settings, ShortBreakPeriod
IniWrite, %WorkPeriod%, AddictionFuel.ini, Settings, WorkPeriod
IniWrite, %AddictionsRegex%, AddictionFuel.ini, Settings, AddictionsRegex
IniWrite, %DisableWhenActiveWindow%, AddictionFuel.ini, Settings, DisableWhenActiveWindow
IniWrite %StartWithBreak%, AddictionFuel.ini, Settings, StartWithBreak
SendMessage("Saved Settings to File")
return

;; Timer to update the time remaining until break on the top right of the screen
TimeLeftToolTip:
ElapsedTime := A_TickCount - StartTime
RemainingTime := AddictionFuelPeriod - ElapsedTime
AddictionCycleProgressPercent := 100 - RemainingTime / AddictionFuelPeriod * 100
GuiControl,, AddictionCycleProgress, %AddictionCycleProgressPercent%
RemainingTime := RemainingTime / 1000 / 60
ToolTip, % RemainingTime " (" CycleStep ")", %A_ScreenWidth%, 0, 2
return

togglePauseScript() {
	global isPaused
	global timeElapsedInCyclePart
	global StartTime
	global AddictionFuelPeriod
	if %isPaused% {
		sendMessage("AddictionFuel has resumed")
		SetTimer, AddictionFuel, % AddictionFuelPeriod - timeElapsedInCyclePart
		StartTime := A_TickCount - timeElapsedInCyclePart
		SetTimer, TimeLeftToolTip, on
		isPaused := 0
	} else {
		sendMessage("AddictionFuel has paused")
		SetTimer, AddictionFuel, off
		timeElapsedInCyclePart := A_TickCount - StartTime
		SetTimer, TimeLeftToolTip, off
		Sleep 10
		ToolTip,,,,2
		isPaused := 1
	}
}

forceTogglePauseScript() {
	global pauseForced
	if pauseForced {
		pauseForced := 0
		GuiControl, Text, PauseButton, Pause
	} else {
		pauseForced := 1
		GuiControl, Text, PauseButton, Play
	}
	togglePauseScript()
}

CheckPauseScript:
if (((WinActive(DisableWhenActiveWindow) and !isPaused) or (!WinActive(DisableWhenActiveWindow) and isPaused)) and !pauseForced) {
	togglePauseScript()
}
return

;; To remove a given ToolTip
RemoveMessage:
ToolTip, , , , 1
SB_SetText("")
return

;; Introduce a tooltip to provide info to the user
sendMessage(message) {
	;ToolTip, , , , 1
	;ToolTip, %message%, 16, 16, 1
	SB_SetText("  " message)
	SetTimer, RemoveMessage, -1000
	return
}

updateBreakCounterValue() {
	global breakCount
	GuiControl, Text, ResetBreaksButton, % "Reset Breaks (" breakCount ")"
}

;; Reset the break counter
ResetBreakCounter:
breakCount := 0
sendMessage("Break Counter Reset")
updateBreakCounterValue()
return

;; Show current break counter
ShowCurrentBreakCounterValue:
sendMessage("Break Counter currently on - " breakCount " -")
return

TogglePlayStatus:
toggleAddiction()
spotifyKey("{Space}")
return

;; Test script
!+y:
addictions := ["a", "b"]
addictslmao := "("
for index, addiction in addictions {
	addictslmao := addictslmao addiction "|"
}
addictslmao := SubStr(addictslmao, 1, -1)
addictslmao := addictslmao ")"
MsgBox % addictslmao
return

;; Check if addictive window is active and play/pause if so using JS in omnibar
addictiveWindowActive() {
	global AddictionsRegex
	if not WinActive(AddictionsRegex) {
		return 0
	} else {
		return 1
	}
}
pauseAddiction() {
	if addictiveWindowActive() {
		Send, {Esc}
		Sleep, 100
		Send, ^l
		Sleep, 50
		SendInput, javascript:document.getElementsByTagName('video')[0].pause()
		Sleep, 200
		Send, {Enter}
	}
	return
}
playAddiction() {
	if addictiveWindowActive() {
		Send, {Esc}
		Sleep, 100
		Send, ^l
		Sleep, 50
		SendInput, javascript:document.getElementsByTagName('video')[0].play()
		Sleep, 200
		Send, {Enter}
	}
	return
}
toggleAddiction() {
	if addictiveWindowActive() {
		Send, {Esc}
		Sleep, 100
		Send, ^l
		Sleep, 50
		SendInput, javascript:if (document.getElementsByTagName('video')[0].paused) document.getElementsByTagName('video')[0].play(); else document.getElementsByTagName('video')[0].pause()
		Sleep, 200
		Send, {Enter}
	}
	return
}

;; Check if spotify is playing and accordingly ensure it is playing or paused
getSpotifyPlayStatus() {
	spotifyPlaying := 1
	WinGet, spotifyWindowIds, list, ahk_exe Spotify.exe
	Loop, %spotifyWindowIds%
	{
		this_ID := spotifyWindowIds%A_Index%
		WinGetTitle, title, ahk_id %this_ID%
		if (title == "")
			continue
		if (title == "Spotify" or title == "Spotify Premium")
		{
			spotifyPlaying := 0
			break
		}
	}
	return spotifyPlaying
}
playSpotify() {
	if (getSpotifyPlayStatus() == 0)
		spotifyKey("{Space}")
}
pauseSpotify() {
	if (getSpotifyPlayStatus() == 1)
		spotifyKey("{Space}")
}

;;  __  __       _          _____           _       _   
;; |  \/  |     (_)        / ____|         (_)     | |  
;; | \  / | __ _ _ _ __   | (___   ___ _ __ _ _ __ | |_ 
;; | |\/| |/ _` | | '_ \   \___ \ / __| '__| | '_ \| __|
;; | |  | | (_| | | | | |  ____) | (__| |  | | |_) | |_ 
;; |_|  |_|\__,_|_|_| |_| |_____/ \___|_|  |_| .__/ \__|
;;                                           | |        
;;                                           |_|        

;; Turn on and off the addiction cycle
ToggleAddictionCycleOnOff:
if %isAddicted% {
	sendMessage("AddictionFuel is now OFF")
	SetTimer, AddictionFuel, off
	SetTimer, TimeLeftToolTip, Off
	SetTimer, CheckPauseScript, Off
	GuiControl, Text, ToggleCycleButton, &Start
	GuiControl, Text, CyclePartIndicator, Cycle Stop
	GuiControl, Disable, PauseButton
	GuiControl, Text, PauseButton, Pause
	isPaused := 0
	pauseForced := 0
	Sleep, 10
	ToolTip,,,,2
} else {
	justPressedStart := 1
	sendMessage("AddictionFuel is now ON")
	SetTimer, AddictionFuel, 0
	GuiControl, Text, ToggleCycleButton, &Stop
	GuiControl, Enable, PauseButton
}
isAddicted := not isAddicted
return

;; Timer to cycle between addiction and work
AddictionFuel:
if (WorkOn or (StartWithBreak and justPressedStart)) { 
	WinGetTitle, prevtitle, A
	WinActivate, %AddictionsRegex%
	playAddiction()
	pauseSpotify()
	if not justPressedStart {
		breakCount := breakCount + 1
	}
	if (breakCount >= breakCountBeforeLongBreak) {
		breakCount := 0
		AddictionFuelPeriod := LongBreakPeriod
		GuiControl, Text, CyclePartIndicator, Long Break
	} else {
		AddictionFuelPeriod := ShortBreakPeriod
		GuiControl, Text, CyclePartIndicator, Short Break
	}
	updateBreakCounterValue()
	CycleStep := "Break"
	WorkOn := 0
} else {
	pauseAddiction()
	playSpotify()
	WinActivate, %prevtitle%
	AddictionFuelPeriod := WorkPeriod
	GuiControl, Text, CyclePartIndicator, Work Time
	CycleStep := "Work"
	WorkOn := 1
}
StartTime := A_TickCount
SetTimer, TimeLeftToolTip, 1000
SetTimer, CheckPauseScript, 1000
SetTimer, AddictionFuel, %AddictionFuelPeriod%
justPressedStart := 0
return

;;   _____             _   _  __         ______                _   _                 
;;  / ____|           | | (_)/ _|       |  ____|              | | (_)                
;; | (___  _ __   ___ | |_ _| |_ _   _  | |__ _   _ _ __   ___| |_ _  ___  _ __  ___ 
;;  \___ \| '_ \ / _ \| __| |  _| | | | |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
;;  ____) | |_) | (_) | |_| | | | |_| | | |  | |_| | | | | (__| |_| | (_) | | | \__ \
;; |_____/| .__/ \___/ \__|_|_|  \__, | |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
;;        | |                     __/ |                                              
;;        |_|                    |___/                                               
;; Picked up from gist: https://gist.github.com/jcsteh/7ccbc6f7b1b7eb85c1c14ac5e0d65195
getSpotifyHwnd() {
	WinGet, spotifyHwnd, ID, ahk_exe Spotify.exe
	; We need the app's third top level window, so get next twice.
	spotifyHwnd := DllCall("GetWindow", "uint", spotifyHwnd, "uint", 2)
	spotifyHwnd := DllCall("GetWindow", "uint", spotifyHwnd, "uint", 2)
	Return spotifyHwnd
}

;; Send a key to Spotify.
spotifyKey(key) {
	spotifyHwnd := getSpotifyHwnd()
	; Chromium ignores keys when it isn't focused.
	; Focus the document window without bringing the app to the foreground.
	ControlFocus, Chrome_RenderWidgetHostHWND1, ahk_id %spotifyHwnd%
	ControlSend, , %key%, ahk_id %spotifyHwnd%
	Return
}

;; Win+alt+p: Play/Pause
ToggleSpotify:
spotifyKey("{Space}")
return