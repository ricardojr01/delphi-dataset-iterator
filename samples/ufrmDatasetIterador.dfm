object FDatasetIteratorSample: TFDatasetIteratorSample
  Left = 0
  Top = 0
  Caption = 'FDatasetIteratorSample'
  ClientHeight = 496
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  DesignSize = (
    635
    496)
  TextHeight = 13
  object btnTeste: TButton
    Left = 8
    Top = 8
    Width = 81
    Height = 25
    Caption = '&Testar'
    TabOrder = 0
    OnClick = btnTesteClick
  end
  object mmDebug: TMemo
    Left = 8
    Top = 39
    Width = 619
    Height = 449
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssBoth
    TabOrder = 1
  end
end
