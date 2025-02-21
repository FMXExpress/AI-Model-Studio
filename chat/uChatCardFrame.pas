unit uChatCardFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Controls.Presentation;

type
  TChatCardFrame = class(TFrame)
    layCard: TLayout;
  protected
    function CalcTextObjectSize(
      const AText: string;
      const ATextSettings: TTextSettings;
      const AMaxWidth: Single;
      var ASize: TSizeF): boolean;
  end;

implementation

uses
  System.Math,
  FMX.TextLayout;

{$R *.fmx}

{ TChatCardFrame }

function TChatCardFrame.CalcTextObjectSize(const AText: string;
  const ATextSettings: TTextSettings; const AMaxWidth: Single;
  var ASize: TSizeF): boolean;
const
  FakeText = 'P|y'; // Do not localize

  function RoundToScale(const Value, Scale: Single): Single;
  begin
    if Scale > 0 then
      Result := Ceil(Value * Scale) / Scale
    else
      Result := Ceil(Value);
  end;

var
  LLayout: TTextLayout;
  LScale: Single;
  LMaxWidth, LWidth: Single;
begin
  Result := False;
  if (Scene <> nil) then begin
    LMaxWidth := AMaxWidth;

    LScale := Scene.GetSceneScale;
    LLayout := TTextLayoutManager.DefaultTextLayout.Create;
    try
      LLayout.BeginUpdate;

      if AText.IsEmpty then
        LLayout.Text := FakeText
      else
        LLayout.Text := AText;

      LLayout.Font := ATextSettings.Font;
      if ATextSettings.WordWrap and (LMaxWidth > 1) then
        LLayout.MaxSize := TPointF.Create(
          LMaxWidth,
          TTextLayout.MaxLayoutSize.Y);

      LLayout.WordWrap := ATextSettings.WordWrap;
      LLayout.Trimming := TTextTrimming.None;
      LLayout.VerticalAlign := TTextAlign.Leading;
      LLayout.HorizontalAlign := TTextAlign.Leading;
      LLayout.EndUpdate;

      if ATextSettings.WordWrap then
        LLayout.MaxSize := TPointF.Create(
          LMaxWidth + LLayout.TextRect.Left * 2,
          TTextLayout.MaxLayoutSize.Y);

      if AText.IsEmpty then
        LWidth := 0
      else if ATextSettings.WordWrap and (LLayout.Width >= LLayout.MaxSize.X * 0.95) then
        LWidth := LLayout.MaxSize.X
      else
        LWidth := LLayout.Width;

      ASize.Width := RoundToScale(LWidth, LScale);
      ASize.Height := RoundToScale(LLayout.Height, LScale);
      Result := True;
    finally
      LLayout.Free;
    end;
  end;
end;

end.
