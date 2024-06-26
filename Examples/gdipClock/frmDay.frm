﻿' frmDay日历
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Form1.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/Menus.bi"
	
	#include once "gdip.bi"
	#include once "gdipAnalogClock.bi"
	#include once "gdipTextClock.bi"
	#include once "gdipMonth.bi"
	#include once "gdipDay.bi"
	
	Using My.Sys.Forms
	
	Type frmDayType Extends Form
		mDate As Double = DateSerial(Year(Now()), Month(Now()), Day(Now()))
		
		'initial gdip token
		Token As gdipToken
		'form trans
		frmTrans As gdipForm
		'form display device
		frmDC As gdipDC
		'memory display device
		memDC As gdipDC
		'form canvas
		frmGraphic As gdipGraphics
		
		'draw analog coloc
		mDay As gdipDay
		mOpacity As UINT = &HFF
		
		Declare Sub DateChange(sDate As Double)
		Declare Sub Transparent(v As Boolean)
		Declare Sub PaintDay()
		
		Declare Sub Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		Declare Sub Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Sub Form_MouseLeave(ByRef Sender As Control)
		Declare Sub Form_Click(ByRef Sender As Control)
		Declare Sub Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		Declare Constructor
		
		Dim As PopupMenu PopupMenu1
	End Type
	
	Constructor frmDayType
		' frmDay
		With This
			.Name = "frmDay"
			.Text = "frmDay"
			.Caption = "Day"
			.ContextMenu = @PopupMenu1
			.OnResize = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer), @Form_Resize)
			.OnCreate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Create)
			.OnMouseMove = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer), @Form_MouseMove)
			.OnPaint = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas), @Form_Paint)
			.OnShow = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form), @Form_Show)
			.OnMouseLeave = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_MouseLeave)
			.ShowCaption = False
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Click)
			.AllowDrop = True
			.OnDropFile = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Filename As WString), @Form_DropFile)
			.SetBounds 0, 0, 240, 200
		End With
		' PopupMenu1
		With PopupMenu1
			.Name = "PopupMenu1"
			.SetBounds 10, 10, 16, 16
			.Designer = @This
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared frmDay As frmDayType
	
	#if _MAIN_FILE_ = __FILE__
		App.DarkMode = True
		frmDay.MainForm = True
		frmDay.Show
		App.Run
	#endif
'#End Region

Private Sub frmDayType.Form_Create(ByRef Sender As Control)
	'frmClock.Day2Profile(frmClock.mKeyValue())
	'设置菜单
	PopupMenu1.Add(@frmClock.mnuDaySetting)
	'初始化位置
	If frmClock.mnuLocateSticky.Checked Then
		frmClock.Form_Move(frmClock)
	Else
		frmDay.Move(frmClock.mRectDay.Left, frmClock.mRectDay.Top, frmClock.mRectDay.Right, frmClock.mRectDay.Bottom)
	End If
End Sub

Private Sub frmDayType.Form_Show(ByRef Sender As Form)
	'设置窗口透明样式
	Transparent(frmClock.mnuTransparent.Checked)
End Sub

Private Sub frmDayType.Form_Resize(ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	mDay.mForceUpdate = True
	If frmClock.mnuTransparent.Checked Then
		mDay.Background(Width*xdpi, Height*ydpi, mDate)
	Else
		mDay.Background(ClientWidth*xdpi, ClientHeight*ydpi, mDate)
	End If
	PaintDay()
End Sub

Private Sub frmDayType.Form_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	PaintDay()
End Sub

Private Sub frmDayType.Transparent(v As Boolean)
	Form_Resize(This, Width, Height)
	frmTrans.Enabled = v
	PaintDay()
End Sub

Private Sub frmDayType.PaintDay()
	If frmClock.mnuTransparent.Checked Then
		frmTrans.Create(Handle, mDay.ImageUpdate(mDate))
		frmTrans.Transform(frmClock.mOpacity)
	Else
		frmDC.Initial(Handle)
		memDC.Initial(0, ClientWidth*xdpi, ClientHeight*ydpi)
		frmGraphic.Initial(memDC.DC, True)
		frmGraphic.DrawImage(mDay.ImageUpdate(mDate))
		BitBlt(frmDC.DC, 0, 0, ClientWidth*xdpi, ClientHeight*ydpi, memDC.DC, 0, 0, SRCCOPY)
	End If
End Sub

Private Sub frmDayType.DateChange(sDate As Double)
	mDate = sDate
	Form_Resize(This, Width, Height)
End Sub

Private Sub frmDayType.Form_MouseLeave(ByRef Sender As Control)
	Form_MouseMove(This, -1, -1, -1, 0)
End Sub

Private Sub frmDayType.Form_MouseMove(ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	Static sX As Integer
	Static sY As Integer
	If CBool(sX = x) And CBool(sY = y) Then Exit Sub
	sX = x
	sY = y
	
	mDay.mMouseX = x * xdpi
	mDay.mMouseY = y * ydpi
	
	PaintDay()
	Select Case mDay.mMouseLocate
	Case 0
		Hint = "Year"
	Case 1
		Hint = "Month"
	Case 2
		Hint = "Day"
	Case 3
		Hint = "Week/Holiday"
	Case 4
		Hint = "Lunar year"
	Case 5
		Hint = "Lunar month"
	Case 6
		Hint = "Lunar day"
	Case 7
		Hint = "Weeks/Holiday/Solar terms"
	End Select
	
	If MouseButton = 0 Then
		ReleaseCapture()
		SendMessage(Sender.Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0)
	End If
End Sub

Private Sub frmDayType.Form_Click(ByRef Sender As Control)
	If mDay.mShowStyle < 2 Then 
		mDay.mShowStyle += 1
	Else
		mDay.mShowStyle= 0
	End If
	Form_Resize(This, Width, Height)
End Sub

Private Sub frmDayType.Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
	mDay.mBackImage.ImageFile = Filename
	mDay.mBackEnabled = True 
	Form_Resize(This, Width, Height)
	frmClock.Form_Resize(frmClock, frmClock.Width, frmClock.Height)
End Sub
