unit records_unit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons;

{ Trecords_Form }

type
  Trecords_Form = class(TForm)
    clear_Button: TButton;
    Exit_BitBtn: TBitBtn;
    InfoLabel: TLabel;
    records_Memo: TMemo;
    procedure clear_ButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  records_Form: Trecords_Form;

implementation
uses Menu_unit;
{$R *.lfm}

{ Trecords_Form }

procedure Trecords_Form.FormShow(Sender: TObject);
var
  Fin: text;
  stmp: string;
begin
  assignfile(fin, getcurrentdir() + '\data\records.txt');
  {$I+}
  reset(fin);
  {$I-}
  if (IoResult <> 0) then begin
    showMessage('#Error: Records file not found');
    exit;
  end;

  records_memo.Clear;
  while (not eof(fin)) do begin
    readln(fin, stmp);
    stmp := xorTranslator(1,stmp,'');

    records_Memo.lines.insert(0,stmp);

  end;
  closefile(Fin);
end;

procedure Trecords_Form.clear_ButtonClick(Sender: TObject);
var
  fin: text;
begin
  assignfile(fin, getcurrentdir() + '\data\records.txt');
  {$I+}
  rewrite(fin);
  {$I-}
  if (IoResult <> 0) then begin
    showMessage('#Error: Records file not found');
    exit;
  end;

  Records_Memo.Clear;
  closefile(fin);
end;

{ Trecords_Form }

end.

