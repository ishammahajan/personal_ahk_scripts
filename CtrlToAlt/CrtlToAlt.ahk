#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, RegEx
SetKeyDelay, 500
DetectHiddenWindows, On
CoordMode, ToolTip
#InstallKeybdHook
#UseHook

#IfWinNotActive Dota

!+z::ListHotkeys
LAlt & c:: Send, ^c

LAlt & v:: Send, ^v

LAlt & z:: Send, ^z

LAlt & a:: Send, ^a

LAlt & s:: Send, ^s

LAlt & w:: Send, ^w

LAlt & t:: SendInput, ^t

LAlt & l:: Send, ^l

LAlt & f:: Send, ^f

LWin & Backspace:: Send, ^{Backspace}

; Sidekick Shortcuts
LWin & w:: Send, !+w
LWin & f:: Send, !+f

LAlt & q::
if WinExist("A")
    WinClose
return

!r:: Reload
!e:: Edit

!m::
SetTimer, MineCraftClick, 500
return

!+m::
SetTimer, MineCraftClick, -1
return

MineCraftClick:
Click
return