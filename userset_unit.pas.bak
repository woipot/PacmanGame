unit UserSet_unit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons;

{ TUserSet_Form }

type
  TUserSet_Form = class(TForm)
    Exit_BitBtn: TBitBtn;
    InfoLabel: TLabel;
    mapLabel: TLabel;
    map_bitbut: TBitBtn;
    map_bitbut1: TBitBtn;
    map_bitbut2: TBitBtn;
    map_bitbut3: TBitBtn;
    map_bitbut4: TBitBtn;
    map_bitbut5: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure map_bitbutClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  UserSet_Form: TUserSet_Form;

implementation
uses Menu_unit;

{$R *.lfm}

{ TUserSet_Form }

procedure TUserSet_Form.FormShow(Sender: TObject);
var
  data: text;
  tmp_str: string;
begin
  assignfile(data, GetCurrentDir() + '\data\data.txt');
  {$I-}
  reset(data);
  {$I+}
  if (IoResult <> 0) then begin
    showMessage('#Error: my data file is broken');
    exit;
  end;

  if (not eof(data)) then begin
    readln(data,tmp_str);
    closefile(data);
    tmp_str := ExtractFileName(xorTranslator(1,tmp_str,''));
    delete(tmp_str, length(tmp_str) - 3, 4);
    mapLabel.caption:= tmp_str;
  end
  else begin
    closefile(data);
    mapLabel.caption:= 'Empty';
  end;
end;

procedure TUserSet_Form.map_bitbutClick(Sender: TObject);
var
  data: text;
  tmp_str: string;
begin
  assignfile(data, GetCurrentDir() + '\data\data.txt');
  {$I-}
  rewrite(data);
  {$I+}
  if (IoResult <> 0) then begin
    showMessage('#FatalError: my data file is broken');
    close;
    exit;
  end;

  tmp_str:= GetCurrentdir()+ '\map\' + tButton(Sender).caption + '.txt';
  closefile(data);
  xorTranslator(2,tmp_str,GetCurrentDir() + '\data\data.txt');

  tmp_str := ExtractFileName(tmp_str);
  delete(tmp_str, length(tmp_str) - 3, 4);
  mapLabel.caption:= tmp_str;

end;

end.

