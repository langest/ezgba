#include <Constants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

#include <File.au3>
#include <GuiTreeView.au3>

Global $ROM_DIR = "D:\Downloads\GBA1501-2810"
Global $EZ4_EXE = "D:\Downloads\EZ4_20140306\EZ4_Client.exe"
Global $OUTPUT_DIR = "D:\EZ4_Out\GBA1501-2810"
Global $TMP_DIR = "D:\EZ4_Dumper.tmp"


Global $FORCE_NAME_OVERRIDE = True
Global $MAX_CLUMP = 1
Global $MAIN_WINDOW_CLASS = "[CLASS:#32770]"




Func ReplaceFileExtension($file_name, $new_extension)
	Local $new_name
	Local $split
	Local $slice
	Local $slice_num
	Local $size
	Local $ext_array

	If $new_extension <> "" Then
		; Check if new extension already includes leading "."
		$ext_array = StringSplit($new_extension, "", $STR_NOCOUNT)

		If $ext_array[0] <> "." Then
			$new_extension = "." & $new_extension
		EndIf
	EndIf

	; Delete the extension.
	If StringInStr($file_name, ".") <> 0 Then
		$split = StringSplit($file_name, ".")
		$size = $split[0]
		$new_name = ""

		For $slice_num = 1 To $size-1
			$slice = $split[$slice_num]
			$new_name = $new_name & "." & $slice
		Next

		$new_name = StringTrimLeft($new_name, 1)
	Else
		$new_name = $file_name
	EndIf

	If $new_extension <> "" Then
		$new_name = $new_name & $new_extension
	EndIf

	Return $new_name
EndFunc

Func Min($num1, $num2)
	; Get the smaller of two numbers.

	If $num1 < $num2 Then
		Return $num1
	Else
		; If they're equal, it doens't mattery anyways.
		Return $num2
	EndIf

	; Should never reach here.
	Return $num2
EndFunc

Func CreateDir($dir)
	; If the path doesn't exist, create it.
	If FileExists($dir) == 0 Then
		ConsoleWrite("Directory " & $dir & " does not exist; Creating now." & @CRLF)
		DirCreate($dir)
	EndIf
EndFunc

Func DeleteDir($dir)
	; If the path exists, delete it
	If $dir <> "" and $dir <> "/" and $dir <> "\" and FileExists($dir) == 1 Then
		ConsoleWrite("Directory " & $dir & " exists, deleting." & @CRLF)
		DirRemove($dir, 1)
	EndIf
EndFunc

Func CloseClient()
	While WinExists($MAIN_WINDOW_CLASS, "")
		WinClose($MAIN_WINDOW_CLASS, "")
		Sleep(500)
	WEnd
EndFunc

Func StartClient()
	Local $exe_dir
	Local $split_size
	Local $split
	Local $i

	; Change current working directory.
	$split = StringSplit($EZ4_EXE, "/\")
	$exe_dir = ""
	$split_size = $split[0]

	For $i=1 to $split_size-1
		$exe_dir = $exe_dir & $split[$i] & "/"
	Next

	$exe_dir = StringTrimRight($exe_dir, 1)
	FileChangeDir($exe_dir)

	; Run new instance
	ConsoleWrite("Starting new instance of EZ4 client." & @CRLF)
	CloseClient()
	Run($EZ4_EXE)
	WinWait($MAIN_WINDOW_CLASS, "")

	; Wait for EZ4 client to become active.
	ConsoleWrite("Waiting for EZ4 client to become active." & @CRLF)
	WinWait($MAIN_WINDOW_CLASS)
	WinActivate($MAIN_WINDOW_CLASS)
	WinWaitActive($MAIN_WINDOW_CLASS)

	; Configure it.
	InitialConfig()
EndFunc

Func PromptForSetup()
	Local $response

	$response = MsgBox(BitOR($MB_YESNO, $MB_SYSTEMMODAL), "Question", "Do you want to apply the EZ4 client's header patch to your ROM files?")
	If $response = $IDNO Then
		Exit
	EndIf

	$response = MsgBox(BitOR($MB_OKCANCEL, $MB_SYSTEMMODAL), "Setup EZ4 Client", "Open your EZ4 Client now. Use the open file dialog to set the directory to the one containing all your ROM files. Set the output directory." & @CRLF & "Set the registry key HKEY_CURRENT_USER\Software\Microsoft\Windows\Windows Error Reporting\DontShowUI to 1." & @CRLF & "Click OK once you've completed these tasks, or click cancel.")

	If $response = $IDCANCEL Then
		Exit 1
	EndIf

	; Was the registry key set?
	If RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\Windows Error Reporting", "DontShowUI") <> 1 Then
		MsgBox($MB_ICONERROR, "Incorrect Configuration", "You must set the HKEY_CURRENT_USER\Software\Microsoft\Windows\Windows Error Reporting registry key to 1, or client crashes cannot be handled." & @CRLF & @CRLF & "Exiting script.")
		Exit 1
	EndIf

	; Prepare the temporary directory.
	DeleteDir($TMP_DIR)
	CreateDir($TMP_DIR)

	; Prepare output dir. Not deleting first, because other files (such as desktop files) might be there.
	CreateDir($OUTPUT_DIR)
EndFunc

Func InitialConfig()
	; Uncheck both save and reset patches.
	ControlCommand($MAIN_WINDOW_CLASS, "", "[CLASS:Button; INSTANCE:4]", "UnCheck")
	ControlCommand($MAIN_WINDOW_CLASS, "", "[CLASS:Button; INSTANCE:2]", "UnCheck")

	; Click config.
	ControlClick($MAIN_WINDOW_CLASS, "", "[CLASS:Button; INSTANCE:7]")

	; Wait for language select to appear.
	While ControlCommand($MAIN_WINDOW_CLASS, "", "[CLASS:ComboBox; INSTANCE:1]", "IsVisible") == 0
		Sleep(100)
	WEnd

	; Select english language.
	ControlCommand($MAIN_WINDOW_CLASS, "", "[CLASS:ComboBox; INSTANCE:1]", "SelectString", "English")
	Sleep(500)

	; Confirm
	ControlClick($MAIN_WINDOW_CLASS, "", "[CLASS:Button; INSTANCE:1]")
EndFunc

Func SetEZ4Files($start, $end)
	Local $files[$end-$start+1]
	Local $file_index
	Local $file_name

	; Open file selector.
	ControlClick($MAIN_WINDOW_CLASS, "", 1014)
	Sleep(1000)

	; Wait for focus.
	While (ControlGetFocus($MAIN_WINDOW_CLASS) <> "SysListView321")
		ControlFocus($MAIN_WINDOW_CLASS, "", "[CLASS:SysListView32; INSTANCE:1]")
		Sleep(500)
	WEnd

	; Wait for ListView.
	While (ControlListView($MAIN_WINDOW_CLASS, "", "[CLASS:SysListView32; INSTANCE:1]", "GetItemCount") <= 0)
		Sleep(500)
	WEnd

	; What files are we selecting? Return these in an array.
	For $file_index = $start to $end
		$file_name = ControlListView($MAIN_WINDOW_CLASS, "", "[CLASS:SysListView32; INSTANCE:1]", "GetText", $file_index)
		$files[$file_index - $start] = $file_name
	Next

	; Select our files.
	ControlListView($MAIN_WINDOW_CLASS, "", "[CLASS:SysListView32; INSTANCE:1]", "SelectClear")
	ControlListView($MAIN_WINDOW_CLASS, "", "[CLASS:SysListView32; INSTANCE:1]", "Select", $start, $end)

	; Wait for ListView.
	While (ControlListView($MAIN_WINDOW_CLASS, "", "[CLASS:SysListView32; INSTANCE:1]", "GetSelectedCount") <= 0)
		Sleep(100)
	WEnd

	; Click the open button.
	ControlClick($MAIN_WINDOW_CLASS, "", "[CLASS:Button; INSTANCE:2]")

	If $start < $end Then
		; Wait for confirm popup.
		While (ControlCommand($MAIN_WINDOW_CLASS, "", "[CLASS:Button; INSTANCE:3]", "IsVisible") == 0) Or (ControlCommand($MAIN_WINDOW_CLASS, "", "[CLASS:Button; INSTANCE:4]", "IsVisible") == 0)
			Sleep(100)
		WEnd

		; Uncheck reset and save patches.
		ControlCommand($MAIN_WINDOW_CLASS, "", "[CLASS:Button; INSTANCE:3]", "UnCheck")
		ControlCommand($MAIN_WINDOW_CLASS, "", "[CLASS:Button; INSTANCE:4]", "UnCheck")
		Sleep(500)
	Else
		; Only one file was selected. Wait for the ListView to dissapear.
		; Wait for ListView.
		While (ControlListView($MAIN_WINDOW_CLASS, "", "[CLASS:SysListView32; INSTANCE:1]", "GetSelectedCount") > 0)
			Sleep(100)
		WEnd
		Sleep(500)

		; Uncheck both save and reset patches.
		ControlCommand($MAIN_WINDOW_CLASS, "", "[CLASS:Button; INSTANCE:4]", "UnCheck")
		ControlCommand($MAIN_WINDOW_CLASS, "", "[CLASS:Button; INSTANCE:2]", "UnCheck")
		Sleep(500)
	EndIf

	Return $files
EndFunc

Func SendRoms($is_single=False, $single_name="", $force_name_override=False)
	Local $file_name
	Local $old_path
	Local $new_path
	Local $new_name
	Local $i

	If $is_single == True Then
		; Single rom

		; DISABLED: the EZ4 client doesn't support longer filenames. The renaming method is still the better option.
		; If the rom name isn't detected by the database, enter one ourselves.
		; Sleep(80)
		; If $single_name <> "" and (ControlCommand($MAIN_WINDOW_CLASS, "", "[CLASS:Edit; INSTANCE:4]", "GetLine", 0) == "" or $force_name_override == True) Then
		; 	If $force_name_override == True Then
		; 		$new_name = ReplaceFileExtension($single_name, "")
		; 		ConsoleWrite("Forcing file name override to " & $new_name & @CRLF)
		; EndIf
		;
		; 	For $i = 1 to 3
		; 		ControlClick($MAIN_WINDOW_CLASS, "", "[CLASS:Edit; INSTANCE:4]", "right")
		; 		Sleep(50)
		; 		Send("a")
		; 		Sleep(50)
		; 		Send("{BACKSPACE}")
		; 		Sleep(50)
		; 	Next
		; 	Sleep(100)
		;
		; 	ControlCommand($MAIN_WINDOW_CLASS, "", "[CLASS:Edit; INSTANCE:4]", "EditPaste", $new_name)
		; 	Sleep(100)
		; EndIf

		; Single rom, click the send button in the main window.
		Sleep(400)
		ControlClick($MAIN_WINDOW_CLASS, "", "[CLASS:Button; INSTANCE:6]")
		Sleep(300)
		ControlClick($MAIN_WINDOW_CLASS, "", "[CLASS:Button; INSTANCE:6]")
	Else
		; Multiple roms, click the send button in the dialog box.
		ControlClick($MAIN_WINDOW_CLASS, "", "[CLASS:Button; INSTANCE:1]")
	EndIf

	; Wait for the transfer to finish.
	While (WinExists($MAIN_WINDOW_CLASS, "Send OK") == 0) and (WinExists($MAIN_WINDOW_CLASS, "was not found.") == 0) and (WinExists($MAIN_WINDOW_CLASS, "low on memory.") == 0) and (WinExists($MAIN_WINDOW_CLASS, "") == 1)
		Sleep(500)
	WEnd
	Sleep(500)

	If WinExists($MAIN_WINDOW_CLASS, "Send OK") == 1 Then
		; Click OK.
		ControlClick($MAIN_WINDOW_CLASS, "", "[CLASS:Button; INSTANCE:1; TEXT:OK; ID:2]")
		WinWaitClose($MAIN_WINDOW_CLASS, "Send OK")
		Sleep(300)

		; If it was a single rom and a filename was provided, use it to solve the no-name ".gba" issue.
		If $is_single == True and $single_name <> "" Then
			; TODO Unsafe array indices.
			$file_name = _FileListToArray($TMP_DIR, "*", 1, False)[1]

			; Transferred to temporary directory, check for no-name ".gba" files.
			If $file_name == ".gba"  or ($single_name <> "" and $force_name_override == True) Then
				; If afflicted by the no-name ".gba" issue, or name override is enabled, rename it.

				If $file_name == ".gba" and $single_name == "" Then
					$new_name = "ARBITRARY." & Random(0, 9999999999999999, 1) & ".gba"
					ConsoleWrite("No-name '.gba' afflicted file, override name not specified. Generated file name is " & $new_name & @CRLF)
				Else
					$new_name = ReplaceFileExtension($single_name, ".gba")
				EndIf

				$old_path = $TMP_DIR & "/" & $file_name
				$new_path = $OUTPUT_DIR & "/" & $new_name

				ConsoleWrite("Force rename file to " & $new_name & @CRLF)
				FileMove($old_path, $new_path,  $FC_OVERWRITE + $FC_CREATEPATH)
			Else
				; Otherwise, proceed using generated file name.
				$old_path = $TMP_DIR & "/" & $file_name
				$new_path = $OUTPUT_DIR & "/" & $file_name

				FileMove($old_path, $new_path,  $FC_OVERWRITE + $FC_CREATEPATH)
			EndIf
		Else
			; Transferred to temporary directory, check for no-name ".gba" files.
			If FileExists($TMP_DIR & "/" & ".gba") Then
				DeleteDir($TMP_DIR)
				CreateDir($TMP_DIR)
				Return -2
			EndIf

			; Transfer from temporary directory to output directory, if not affected by the no-name ".gba" problem.
			$files_array = _FileListToArray($TMP_DIR, "*", 1, False)
			For $file_name In $files_array
				; Skip the first element (contains number of files listed)
				If Not IsString($file_name) Then
					ContinueLoop
				Endif

				$old_path = $TMP_DIR & "/" & $file_name
				$new_path = $OUTPUT_DIR & "/" & $file_name

				FileMove($old_path, $new_path,  $FC_OVERWRITE + $FC_CREATEPATH)
			Next
		EndIf

		Sleep(500)
		Return 0
	ElseIf WinExists($MAIN_WINDOW_CLASS, "was not found.") == 1 Then
		; Transfer failed.
		CloseClient()
		ControlClick($MAIN_WINDOW_CLASS, "", "[CLASS:Button; INSTANCE:1]")
		Return -3
	ElseIf WinExists($MAIN_WINDOW_CLASS, "low on memory.") == 1 Then
		; The EZ4 client reads everything into memory and never frees it.
		; It's a piece of shit.
		ControlClick($MAIN_WINDOW_CLASS, "", "[CLASS:Button; INSTANCE:1]")
		CloseClient()
		Return -4
	ElseIf WinExists($MAIN_WINDOW_CLASS, "") == 0 Then
		; Client crashed.
		CloseClient()
		ControlClick($MAIN_WINDOW_CLASS, "", "[CLASS:Button; INSTANCE:2]")
		Return -1
	EndIf

	; Should never reach here.
	Return -5
EndFunc

Func SetOutputDirectory($output_path)
	; AutoIt has issues with different path separaters.
	$output_path = StringReplace($output_path, "/", "\")

	Local $current_path = ""
	Local $output_drive="", $output_dir="", $output_filename="", $output_extension=""
	Local $output_split = _PathSplit($output_path, $output_drive, $output_dir, $output_filename, $output_extension)

	; If the output path doesn't exist, create it.
	If FileExists($output_path) == 0 Then
		ConsoleWrite("Output directory " & $output_path & " does not exist; Creating now." & @CRLF)
		DirCreate($output_path)
	EndIf

	; Open the config menu
	ControlClick($MAIN_WINDOW_CLASS, "", "[CLASS:Button; INSTANCE:7]")

	; Wait for button to appear.
	While ControlCommand($MAIN_WINDOW_CLASS, "", "[CLASS:Button; INSTANCE:2]", "IsVisible") == 0
		Sleep(100)
	WEnd
	Sleep(500)

	; Click the set directory button.
	ControlClick($MAIN_WINDOW_CLASS, "", "[CLASS:Button; INSTANCE:2]")

	; Wait for treeview.
	While ControlCommand($MAIN_WINDOW_CLASS, "", "[CLASS:SysTreeView32; INSTANCE:1]", "IsVisible") == 0
		Sleep(100)
	WEnd
	Sleep(500)

	$treeview_handle = ControlGetHandle($MAIN_WINDOW_CLASS, "", "SysTreeView321")

	; Expand the drive.
	$this_pc_handle = _GUICtrlTreeView_FindItem($treeview_handle, "This PC")
	_GUICtrlTreeView_SelectItem($treeview_handle, $this_pc_handle, $TVGN_FIRSTVISIBLE)
	_GUICtrlTreeView_Expand($treeview_handle, $this_pc_handle)

	$drive_handle = _GUICtrlTreeView_FindItem($treeview_handle, $output_drive, True)
	_GUICtrlTreeView_SelectItem($treeview_handle, $drive_handle, $TVGN_FIRSTVISIBLE)
	_GUICtrlTreeView_Expand($treeview_handle, $drive_handle)

	; Expand all the directories inside.
	If $output_dir <> "" and $output_dir <> "/" and $output_dir <> "/" Then
		For $dir in StringSplit($output_dir&$output_filename&$output_extension, "/\", $STR_NOCOUNT)
			$dir_handle = _GUICtrlTreeView_FindItem($treeview_handle, $dir)
			_GUICtrlTreeView_SelectItem($treeview_handle, $dir_handle, $TVGN_FIRSTVISIBLE)
			_GUICtrlTreeView_ClickItem ($treeview_handle, $dir_handle, "left")
			_GUICtrlTreeView_Expand($treeview_handle, $dir_handle)
			Sleep(100)
		Next
	EndIf

	; Click OK to close TreeView.
	ControlClick($MAIN_WINDOW_CLASS, "", "[CLASS:Button; INSTANCE:1]")
	Sleep(200)

	; OK to back out of configuration dialog.
	ControlClick($MAIN_WINDOW_CLASS, "", "[CLASS:Button; INSTANCE:1]")
	Sleep(800)

	; Test, is output directory set correctly?
	$current_path = ControlGetText($MAIN_WINDOW_CLASS, "", "[CLASS:Static; INSTANCE:6]")

	If $current_path <> $output_path Then
		ConsoleWrite("Could not set output path. Current path is " & $current_path & @CRLF)
		Return -1
	Else
		ConsoleWrite("Output directory set to " & $current_path & @CRLF)
	EndIf

	Sleep(300)
	Return 0
EndFunc

Func ListRoms($rom_dir)
	Local $files_array[0]
	Local $clumped_array[0][$MAX_CLUMP]

	Local $file_num
	Local $clump_num

	$files_array = _FileListToArray($rom_dir, "*", 1, False)
	$num_clumps = Ceiling($files_array[0]/$MAX_CLUMP)
	$num_files = $files_array[0]

	ReDim $clumped_array[$num_clumps][$MAX_CLUMP]

	$file_num = 0
	$clump_num = 0

	ConsoleWrite("Has " & $num_clumps & " clumps for " & $num_files & " files." & @CRLF)

	For $file_name In $files_array
		; Skip the first element (contains number of files listed)
		If Not IsString($file_name) Then
			ContinueLoop
		Endif

		$clumped_array[$clump_num][$file_num] = $file_name

		If $file_num >= $MAX_CLUMP-1 Then
			$file_num = 0
			$clump_num = $clump_num  + 1
		Else
			$file_num = $file_num + 1
		EndIf
	Next

	return $clumped_array
EndFunc

Func GetNumRoms($rom_dir)
	$files_array = _FileListToArray($rom_dir, "*", 1, False)
	Return $files_array[0]
EndFunc

Func main()
	PromptForSetup()
	StartClient()
	SetOutputDirectory($TMP_DIR)

	ConsoleWrite("Temporary directory is in " & $TMP_DIR & @CRLF)

	Local $clump_num
	Local $start
	Local $end
	Local $ret
	Local $single

	Local $file_num
	Local $file_name
	Local $file_array
	Local $file_name_override

	Local $num_files = GetNumRoms($ROM_DIR)
	Local $num_clumps = Ceiling($num_files / $MAX_CLUMP)

	For $clump_num = 0 to $num_clumps-1
		$start = $clump_num * $MAX_CLUMP
		$end = $start + Min($num_files - $start - 1, $MAX_CLUMP-1)
		$ret = -3

		If $start == $end Then
			$single = True
		Else
			$single = False
		EndIf

		While $ret <> 0
			If $start <> $end then
				ConsoleWrite("Selecting files " & $start & " to " & $end & @CRLF)
				$file_array = SetEZ4Files($start, $end)

				For $file_name in $file_array
					ConsoleWrite("Selected file: " & $file_name & @CRLF)
				Next
			Else
				ConsoleWrite("Selecting file number " & $file_num & @CRLF)
				$file_array = SetEZ4Files($start, $end)

				For $file_name in $file_array
					ConsoleWrite("Selected file: " & $file_name & @CRLF)
				Next
			EndIf

			ConsoleWrite("Sending ROMs" & @CRLF)
			If $start == $end Then
				$file_name = $file_array[0]
				$ret = SendRoms($single, $file_name, $FORCE_NAME_OVERRIDE)
			Else
				$ret = SendRoms($single)
			EndIf

			If $ret == -1 Then
				ConsoleWrite("Client crashed. Retrying." & @CRLF)
				CloseClient()
				StartClient()
			ElseIf $ret == -2 Then
				ConsoleWrite("No-name '.gba' file(s) created. Retrying one-by-one." & @CRLF)
				CloseClient()
				StartClient()

				For $file_num = $start to $end
					While $ret <> 0
						ConsoleWrite("Selecting file " & $file_num & " out of " & $start & " - " & $end & @CRLF)
						$file_array = SetEZ4Files($file_num, $file_num)
						$file_name = $file_array[0]

						ConsoleWrite("Send file name: " & $file_name & @CRLF)
						$ret = SendRoms(True, $file_name, $FORCE_NAME_OVERRIDE)

						If $ret == -1 Then
							ConsoleWrite("Client crashed. Retrying." & @CRLF)
							CloseClient()
							StartClient()
						ElseIf $ret == -2 Then
							ConsoleWrite("No-name '.gba' file created. Logic failure. Retrying(?)" & @CRLF)
							CloseClient()
							StartClient()
						ElseIf $ret == -3 Then
							ConsoleWrite("Transfer failed. Retrying." & @CRLF)
							CreateDir($TMP_DIR)
							CreateDir($OUTPUT_DIR)
							Sleep(200)

							CloseClient()
							StartClient()
						ElseIf $ret == -4 Then
							ConsoleWrite("Memory low. The EZ4 client was written by idiots." & @CRLF)
							CreateDir($TMP_DIR)
							CreateDir($OUTPUT_DIR)
							Sleep(200)

							CloseClient()
							StartClient()
						ElseIf $ret <> 0 Then
							ConsoleWrite("Unrecognized return value " & $ret & "!? Retrying." & @CRLF)
							CloseClient()
							StartClient()
						EndIf
					WEnd
				Next
			ElseIf $ret == -3 Then
				ConsoleWrite("Transfer failed. Retrying." & @CRLF)
				CreateDir($TMP_DIR)
				CreateDir($OUTPUT_DIR)
				Sleep(200)

				CloseClient()
				StartClient()
			ElseIf $ret == -4 Then
				ConsoleWrite("Memory low. The EZ4 client was written by idiots." & @CRLF)
				CreateDir($TMP_DIR)
				CreateDir($OUTPUT_DIR)
				Sleep(200)

				CloseClient()
				StartClient()
			EndIf
		WEnd

		ConsoleWrite("Transfer complete." & @CRLF)
	Next

	CloseClient()
	DeleteDir($TMP_DIR)
EndFunc

main()

; Mortal Combat unknown save type
; Megaman Battle Network 6 Cybeast Falzar is no-name ".gba"
;
