﻿'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/TextBox.bi"
	
	Using My.Sys.Forms
	
	Type MDIChildType Extends Form
		Dim Index As Integer = -1
		Dim CodePage As Integer = GetACP()
		Dim Encode As FileEncodings = -1
		Dim NewLine As NewLineTypes = -1
		Dim mFile As WString Ptr = NULL
		Dim mChanged As Boolean = False
		
		Declare Property Changed(Val As Boolean)
		Declare Property Changed As Boolean
		Declare Property File(ByRef FileName As Const WString)
		Declare Property File ByRef As WString
		Declare Property Title(ByRef TitleName As Const WString)
		
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Sub Form_Activate(ByRef Sender As Form)
		Declare Sub Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		Declare Sub TextBox1_Change(ByRef Sender As TextBox)
		Declare Sub TextBox1_Click(ByRef Sender As Control)
		Declare Sub TextBox1_KeyPress(ByRef Sender As Control, Key As Integer)
		Declare Sub TextBox1_KeyUp(ByRef Sender As Control, Key As Integer, Shift As Integer)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Constructor
		
		Dim As TextBox TextBox1
	End Type
	
	Constructor MDIChildType
		'MDIChild
		With This
			.Name = "MDIChild"
			.Text = "Initial..."
			.Designer = @This
			.FormStyle = FormStyles.fsMDIChild
			.Caption = "Initial..."
			.OnDestroy = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Destroy)
			.OnActivate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Activate)
			.AllowDrop = True
			.OnDropFile = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Filename As WString), @Form_DropFile)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.SetBounds 0, 0, 640, 480
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = ""
			.TabIndex = 0
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.Align = DockStyle.alClient
			.HideSelection = False
			.MaxLength = -1
			.WantTab = True
			.SetBounds 0, 0, 624, 441
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @TextBox1_Change)
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @TextBox1_Click)
			.OnKeyPress = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer), @TextBox1_KeyPress)
			.OnKeyUp = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer), @TextBox1_KeyUp)
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared MDIChild As MDIChildType
	
	#if _MAIN_FILE_ = __FILE__
		MDIChild.MainForm = True
		MDIChild.Show
	
		App.Run
	#endif
'#End Region

Private Property MDIChildType.Changed(val As Boolean)
	mChanged = val
	
	Dim sHead As WString Ptr
	If mChanged Then
		sHead = @WStr("* ")
	Else
		sHead = @WStr("")
	End If
	If *mFile = "" Then
		Title = *sHead & WStr("Untitled - ") & Index
	Else
		Title = *sHead & FullName2File(*mFile)
	End If
End Property

Private Property MDIChildType.Changed As Boolean
	Return mChanged
End Property

Private Property MDIChildType.Title(ByRef TitleName As Const WString)
	If Text = TitleName Then Exit Property
	Text = "" + TitleName
	MDIMain.MDIChildActivate(@This)
End Property

Private Property MDIChildType.File(ByRef FileName As Const WString)
	WStr2Ptr(FileName, mFile)
	Changed = mChanged
	Dim FileInfo As SHFILEINFO
	Dim h As Any Ptr = Cast(Any Ptr, SHGetFileInfo(*mFile, 0, @FileInfo, SizeOf(FileInfo), SHGFI_SYSICONINDEX))
	SendMessage(Handle, WM_SETICON, 0, Cast(LPARAM, ImageList_GetIcon(h, FileInfo.iIcon, 0)))
End Property

Private Property MDIChildType.File ByRef As WString
	Return *mFile
End Property

Private Sub MDIChildType.Form_Destroy(ByRef Sender As Control)
	MDIMain.MDIChildDestroy(@This)
End Sub

Private Sub MDIChildType.Form_Activate(ByRef Sender As Form)
	If Encode < 0 Then Encode = FileEncodings.Utf8
	If NewLine < 0 Then NewLine = NewLineTypes.WindowsCRLF
	MDIMain.MDIChildActivate(@This)
End Sub

Private Sub MDIChildType.Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
	MDIMain.FileInsert(Filename, @This)
End Sub

Private Sub MDIChildType.TextBox1_Change(ByRef Sender As TextBox)
	Changed = True
End Sub

Private Sub MDIChildType.TextBox1_Click(ByRef Sender As Control)
	MDIMain.MDIChildClick(@This)
End Sub

Private Sub MDIChildType.TextBox1_KeyPress(ByRef Sender As Control, Key As Integer)
	TextBox1_Click(Sender)
End Sub

Private Sub MDIChildType.TextBox1_KeyUp(ByRef Sender As Control, Key As Integer, Shift As Integer)
	TextBox1_Click(Sender)
End Sub

Private Sub MDIChildType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	If MDIMain.MDIChildClose(@This) = MessageResult.mrCancel Then
		Action = False
	Else
		If mFile Then Deallocate mFile
	End If
End Sub
