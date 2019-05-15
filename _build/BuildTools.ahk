;-------------------------------------------------------------------------------------------------------------
DocuUpdateVersion(ver) {
	; Updates Version (within NaturalDocs project file) within documentation 

	NDProjectFile := GetFullPathName(A_ScriptDir "\NDProj\project.txt")
	NDProjectFileTmp := NDProjectFile ".tmp"
	fileOut := FileOpen(NDProjectFileTmp, "w")

	fileIn := FileOpen(NDProjectFile,"r")
	while (!fileIn.AtEOF) {
		line := fileIn.ReadLine()
		if (foundPos := RegExMatch(line, "Subtitle\:")) {
			line := "Subtitle: Version " ver
		}
		fileOut.Write(line "`n")
	}

	fileIn.close()
	fileOut.close()
	FileMove NDProjectFileTmp, NDProjectFile, 1
}

;-------------------------------------------------------------------------------------------------------------
DocuGenerate() {
	; Generates Documentation using NaturalDocs
	EnvSet "NDPATH", GetFullPathName(A_ScriptDir "\NaturalDocs") 
	RunWait(GetFullPathName(A_ScriptDir "\NaturalDocs\NaturalDocs") " -r -p .\NDProj" )
}

;-------------------------------------------------------------------------------------------------------------
GetFullPathName(Filename) {
	; Determines the fullpath (absolute path) from relative path
	Size := DllCall("Kernel32.dll\GetFullPathNameW", "Str", Filename, "UInt", 0, "Ptr", 0, "PtrP", 0) 
	VarSetCapacity(OutputVar, Size * 2, 0) 
	r := DllCall("Kernel32.dll\GetFullPathNameW", "Str", Filename, "UInt", Size, "Str", OutputVar, "PtrP", 0)
	ret := ""
	if (r > 0)
		ret := RTrim(OutputVar, "\")
	Else
		ret := Filename
	return ret
}

; -------------------------------------------------------------------------------------------------------------
bcrypt_md5_file(filename)
{
	; calculates mf5 for a given file
	; https://github.com/jNizM/AHK_CNG/blob/master/src/hash/win10/bcrypt_md5_file.ahk
    static BCRYPT_MD5_ALGORITHM := "MD5"
    static BCRYPT_HASH_LENGTH   := "HashDigestLength"

    if !(hBCRYPT := DllCall("LoadLibrary", "str", "bcrypt.dll", "ptr"))
        throw Exception("Failed to load bcrypt.dll", -1)

    if (NT_STATUS := DllCall("bcrypt\BCryptOpenAlgorithmProvider", "ptr*", hAlgo, "ptr", &BCRYPT_MD5_ALGORITHM, "ptr", 0, "uint", 0) != 0)
        throw Exception("BCryptOpenAlgorithmProvider: " NT_STATUS, -1)

    if (NT_STATUS := DllCall("bcrypt\BCryptGetProperty", "ptr", hAlgo, "ptr", &BCRYPT_HASH_LENGTH, "uint*", cbHash, "uint", 4, "uint*", cbResult, "uint", 0) != 0)
        throw Exception("BCryptGetProperty: " NT_STATUS, -1)

    VarSetCapacity(pbHash, cbHash, 0)
    if !(f := FileOpen(filename, "r", "UTF-8"))
        throw Exception("Failed to open file: " filename, -1)
    f.Seek(0)
    while (dataread := f.RawRead(data, 262144))
        if (NT_STATUS := DllCall("bcrypt\BCryptHash", "ptr", hAlgo, "ptr", 0, "uint", 0, "ptr", &data, "uint", dataread, "ptr", &pbHash, "uint", cbHash) != 0)
            throw Exception("BCryptHash: " NT_STATUS, -1)
    f.Close()

    loop cbHash
        hash .= Format("{:02x}", NumGet(pbHash, A_Index - 1, "uchar"))

    DllCall("bcrypt\BCryptCloseAlgorithmProvider", "ptr", hAlgo, "uint", 0)
    DllCall("FreeLibrary", "ptr", hBCRYPT)

    return hash
}