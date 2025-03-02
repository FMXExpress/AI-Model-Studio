unit uChatTextCardFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  uChatCardFrame, FMX.Objects, FMX.Layouts, FMX.Memo.Types,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.Styles.Objects;

type
  TChatTextCardFrame = class(TChatCardFrame)
    recCard: TRectangle;
    memText: TMemo;
    procedure FrameResized(Sender: TObject);
    procedure memTextChangeTracking(Sender: TObject);
    procedure memTextApplyStyleLookup(Sender: TObject);
  private
    FFitingSize: boolean;
    function GetExtraHeight(): single;
    function GetExtraWidth(): single;
    procedure FitSize();
  public
    class function NewUser(const AText: string; const AContainer: TControl): TChatCardFrame; static;
    class function NewAssistant(const AText: string; const AContainer: TControl): TChatCardFrame; static;
  end;

implementation

uses
  System.Math,
  FMX.TextLayout;

{$R *.fmx}

procedure TChatTextCardFrame.FrameResized(Sender: TObject);
begin
  inherited;
  if not FFitingSize then
    FitSize();
end;

function TChatTextCardFrame.GetExtraHeight: single;
begin
  Result := layCard.Margins.Top + layCard.Margins.Bottom
          + recCard.Margins.Top + recCard.Margins.Bottom
          + memText.Margins.Top + memText.Margins.Bottom;
end;

function TChatTextCardFrame.GetExtraWidth: single;
begin
  Result := layCard.Margins.Left + layCard.Margins.Right
          + recCard.Margins.Left + recCard.Margins.Right
          + memText.Margins.Left + memText.Margins.Right;
end;

procedure TChatTextCardFrame.memTextApplyStyleLookup(Sender: TObject);
begin
  inherited;
  var LBackground := memText.FindStyleResource('background') as TActiveStyleObject;

  if not Assigned(LBackground) then
    Exit;

  LBackground.Opacity := 0;
  LBackground.HitTest := False;
  LBackground.Repaint();
end;

procedure TChatTextCardFrame.memTextChangeTracking(Sender: TObject);
begin
  inherited;
  FitSize();
end;

class function TChatTextCardFrame.NewAssistant(const AText: string;
  const AContainer: TControl): TChatCardFrame;
begin
  Result := TChatTextCardFrame.Create(AContainer);
  Result.Name := 'assistant_chattext_' + AContainer.ComponentCount.ToString();
  Result.Align := TAlignLayout.Bottom;
  AContainer.AddObject(Result);
  Result.Align := TAlignLayout.Top;

  TChatTextCardFrame(Result).layCard.Align := TAlignLayout.Left;
  TChatTextCardFrame(Result).memText.Lines.Add(AText);
end;

class function TChatTextCardFrame.NewUser(const AText: string;
  const AContainer: TControl): TChatCardFrame;
begin
  Result := TChatTextCardFrame.Create(AContainer);
  Result.Name := 'user_chattext_' + AContainer.ComponentCount.ToString();
  Result.Align := TAlignLayout.Bottom;
  AContainer.AddObject(Result);
  Result.Align := TAlignLayout.Top;

  TChatTextCardFrame(Result).memText.Lines.Add(AText);
end;

procedure TChatTextCardFrame.FitSize;
var
  LMemoSize: TSizeF;
begin
  var LMaxWidth := Self.Width * 0.5;

  FFitingSize := true;

  Self.CalcTextObjectSize(
    memText.Text,
    memText.TextSettings,
    LMaxWidth,
    LMemoSize);

  if (LMemoSize.Width = LMaxWidth) then
    layCard.Width := LMemoSize.Width
  else
    layCard.Width := LMemoSize.Width + 6 + GetExtraWidth();

  Self.Height := LMemoSize.Height + 6 + GetExtraHeight();

  FFitingSize := false;
end;

end.
