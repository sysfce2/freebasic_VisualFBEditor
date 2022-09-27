﻿'#Compile "Form1.rc"
#define UNICODE
#include once "windows.bi"
#include once "win\commctrl.bi"

Dim msg As MSG
Dim As WNDCLASSEX wc
Dim As WString * 100 NameClass = "MyClass"
Dim As HINSTANCE HInst = GetModuleHandle(0)

Function WndProc(ByVal hwnd As HWND, ByVal msg As UINT, ByVal wparam As WPARAM, ByVal lparam As LPARAM) As LRESULT
	Select Case msg
	Case WM_CREATE
		
	Case WM_COMMAND
		
	Case WM_DESTROY
		PostQuitMessage(0)
	End Select
	Return DefWindowProc(hwnd, msg, wparam, lparam)
End Function

With wc
	.cbSize = SizeOf(WNDCLASSEX)
	.style = CS_HREDRAW Or CS_VREDRAW
	.lpfnWndProc = @WndProc
	.hInstance = HInst
	.hIcon = LoadIcon(0, IDI_QUESTION)
	.hCursor = LoadCursor(0, IDC_ARROW)
	.hbrBackground = Cast(HBRUSH, COLOR_WINDOW)
	.lpszClassName = StrPtr(NameClass)
	.hIconSm = .hIcon
End With

If RegisterClassEx(@wc) = 0 Then
	Print "Register error, press any key"
	Sleep
	End
EndIf

InitCommonControls

CreateWindowEx(0, NameClass, "Main Window", WS_VISIBLE Or WS_OVERLAPPEDWINDOW, 10, 10, 300, 300, 0, 0, HInst, 0)

While GetMessage(@msg, 0, 0, 0)
	TranslateMessage(@msg)
	DispatchMessage(@msg)
Wend
