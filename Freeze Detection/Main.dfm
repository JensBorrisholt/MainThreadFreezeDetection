object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainThread Freeze Detection Demo'
  ClientHeight = 336
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    635
    336)
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 97
    Height = 25
    Caption = 'Sleep 6 seconds'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 39
    Width = 619
    Height = 272
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 317
    Width = 635
    Height = 19
    Panels = <>
    ExplicitLeft = 328
    ExplicitTop = 176
    ExplicitWidth = 0
  end
end
