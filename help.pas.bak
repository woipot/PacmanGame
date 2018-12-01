unit Help;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, ExtCtrls, Menus;

{ THelp_form }

type
  THelp_form = class(TForm)
    Exit_BitBtn: TBitBtn;
    Ghost_Image: TImage;
    Image1: TImage;
    help_Memo: TMemo;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Help_form: THelp_form;

implementation
uses Menu_unit;
{$R *.lfm}

{ THelp_form }

{procedure THelp_form.FormCreate(Sender: TObject);
var
  stmp: string;
begin
  stmp := GetCurrentDir() + '\data\help.txt';
  xorTranslator(3,'', stmp);
  help_memo.Lines.LoadFromFile(stmp);
  xorTranslator(3,'',stmp);
end;}

end.

