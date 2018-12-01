unit about_unit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, ExtCtrls;

{ TAbout_Form }

type
  TAbout_Form = class(TForm)
    Exit_BitBtn: TBitBtn;
    Ghost_Image: TImage;
    Ghost_Image1: TImage;
    Ghost_Image2: TImage;
    Ghost_Image3: TImage;
    Ghost_Image4: TImage;
    help_Memo: TMemo;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  About_Form: TAbout_Form;

implementation

{$R *.lfm}

{ TAbout_Form }


end.

