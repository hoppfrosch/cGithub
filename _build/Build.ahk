#Include %A_ScriptDir%\..\src\cGithub.ahk  ; Where to get version from to be used within documentation
#include %A_ScriptDir%\BuildTools.ahk

prevDir := A_WorkingDir

gpp := GetFullPathName(A_ScriptDir "\gpp.exe")

; Goto SRC-Directory and Preprocess files
srcDir := GetFullPathName(A_ScriptDir "\..\src")
SetWorkingDir( srcDir )

; These are the files to be preprocessed via gpp - the output is written to the given destination
preprocessFile := object()
;preprocessFile["GdipC_Main.ahk"]                   := GetFullPathName("..\lib\GdipC.ahk")
;preprocessFile["GdipCEx_Main.ahk"]                := GetFullPathName("..\lib\GdipCEx.ahk")

; These are the files zo be copied to the given destination
copyFile := object()
copyFile["cGithub.ahk"]                     := GetFullPathName("..\lib\cGithub.ahk")
copyFile["JSON\JSON.ahk"]                   := GetFullPathName("..\lib\JSON\JSON.ahk")
copyFile["log4ahk\log4ahk.ahk"]             := GetFullPathName("..\lib\log4ahk\log4ahk.ahk")
copyFile["log4ahk\CallStack\CallStack.ahk"] := GetFullPathName("..\lib\log4ahk\CallStack\CallStack.ahk")
copyFile["log4ahk\YUnit\log4ahk.ahk"]       := GetFullPathName("..\t\YUnit\log4ahk.ahk")

; Bearbeite Dateien mit Praeprozessor
for srcFile, destFile in preprocessFile {
	SplitPath destFile, name, dir
	if !DirExist(dir)
		DirCreate(dir)
		
	cmd  :=  gpp " -o " destFile " -H " srcFile
	RunWait(cmd,"max") 
}

; Einfaches Kopieren mit MD5-Ueberpruefung um doppeltes kopieren zu verhindern
for srcFile, destFile in copyFile {
	SplitPath destFile, name, dir
	if !DirExist(dir)
		DirCreate(dir)
	
	doCopy := 0
	if (FileExist(srcFile)) {
		if (FileExist(destFile)) {
			if (bcrypt_md5_file(srcFile) == bcrypt_md5_file(destFile)) {
				doCopy := 1  ; Files are not identical - dest should be overwritten by source
			}
		} else {
			doCopy := 1 ; Destination does not exist
		}
	}
	else {
		; Source does not exist 
		if (FileExist(destFile)) {
			FileDelete(destFile) ; remove the destination file if it exists
		}
	}
	
	if (doCopy) {
		FileCopy srcFile, destFile 
	}
}

; Go back to original directory
SetWorkingDir( prevDir )