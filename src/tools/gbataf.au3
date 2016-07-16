#include <Debug.au3>
#include <File.au3>
#include <AutoItConstants.au3>
#include <FileConstants.au3>
#include <WindowsConstants.au3>

; Automates gbata patching rom to SRAM on Windows.
; Usage: gbata.au3 INPUT_FILE OUTPUT_FILE [GBATA_EXECUTABLE]

Func DirName($path)
    Local $drive = "", $dir = "", $fname = "", $fext = ""
    _PathSplit($path, $drive, $dir, $fname, $fext)
    Return $drive & $dir
EndFunc

Func BaseName($path)
    Local $drive = "", $dir = "", $fname = "", $fext = ""
    _PathSplit($path, $drive, $dir, $fname, $fext)
    Return $fname & $fext
EndFunc

Func ControlCommandWait($title, $text, $controlID, $command = "IsEnabled", $option = "")
    Local $is_enabled = False

    For $i = 0 To 400 Step 1
        If ControlCommand($title, $text, $controlID, $command, $option) > 0 Then
            $is_enabled = True
            ExitLoop
        Else
            Sleep(10)
        EndIf
    Next

    Return $is_enabled
EndFunc

Func SwitchTab()
    Local $switched = False

    For $i = 0 To 5 Step 1
        WinActivate("GBA Tool Advance")
        ControlFocus("GBA Tool Advance", "", "[CLASS:TPageControl]")
        Sleep(50)

        ControlSend("GBA Tool Advance", "", "[CLASS:TPageControl]", "{END}")
        Sleep(100)
        ControlSend("GBA Tool Advance", "", "[CLASS:TPageControl]", "+^{TAB}")
        Sleep(100)
        ControlSend("GBA Tool Advance", "", "[CLASS:TPageControl]", "+^{TAB}")

        If ControlCommandWait("GBA Tool Advance", "SRAM Patcher", "[CLASS:TButton; INSTANCE:2]", "IsEnabled") == False Then
            Sleep(10)
        ElseIf ControlCommandWait("GBA Tool Advance", "Select", "[CLASS:TButton; INSTANCE:3]", "IsEnabled") == False Then
            Sleep(10)
        Else
            $switched = True
            ExitLoop
        EndIf
    Next

    Return $switched
EndFunc

Func SetRomFile($rom_path)
    ControlCommandWait("GBA Tool Advance", "", "[CLASS:TButton; INSTANCE:1]")
    ControlClick("GBA Tool Advance", "", "[CLASS:TButton; INSTANCE:1]")
    WinWait("Open")

    ControlCommandWait("Open", "", "[CLASS:Edit; INSTANCE:1]")
    ControlSetText("Open", "", "[CLASS:Edit; INSTANCE:1]", $rom_path)

    ControlCommandWait("Open", "", "[CLASS:Button; INSTANCE:2]")
    ControlClick("Open", "", "[CLASS:Button; INSTANCE:2]")

    WinWaitClose("Open")
EndFunc

Func WriteRomFile($rom_path, $write_path)
    Local $write_dir = DirName($write_path)

    If SwitchTab() == True Then
        DirCreate($write_dir)
        ControlSetText("GBA Tool Advance", "SRAM Patcher", "[CLASS:TEdit; INSTANCE:2]", $write_path)

        If ControlCommandWait("GBA Tool Advance", "Patch", "[CLASS:TButton; INSTANCE:2]") == True Then
            ControlClick("GBA Tool Advance", "", "[CLASS:TButton; INSTANCE:2]")
            WinWait("Information", "", "[CLASS:TButton]")

            ControlCommandWait("Information", "", "[CLASS:TButton]")
            ControlClick("Information", "", "[CLASS:TButton]")
        Else
            ConsoleWriteError("ERROR: Can't patch " & $rom_path & @CRLF)
        EndIf
    Else
        ConsoleWriteError("ERROR: Can't click SRAM patch button." & @CRLF)
    EndIf
EndFunc

Func StartGbata($executable_path = "gbata")
    If Not WinExists("GBA Tool Advance") Then
        Run($GBATA_EXECUTABLE)
        WinWait("GBA Tool Advance")
        Sleep(50)
    EndIf
EndFunc

Func QuitGbata()
    While WinExists("GBA Tool Advance")
        WinClose("GBA Tool Advance")
    WEnd
EndFunc

_Assert(UBound($CmdLine) >= 3)
$INPUT_FILE = _PathFull($CmdLine[1])
$OUTPUT_FILE = _PathFull($CmdLine[2])
$GBATA_EXECUTABLE = UBound($CmdLine) >= 4 ? _PathFull($CmdLine[3]) : "gbata.exe"

ConsoleWrite($INPUT_FILE & @CRLF)

StartGbata($GBATA_EXECUTABLE)
SetRomFile($INPUT_FILE)
WriteRomFile($INPUT_FILE, $OUTPUT_FILE)
;QuitGbata()
