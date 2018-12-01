unit Settings_unit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin;

{ Tsettings_Form }

type
  Tsettings_Form = class(TForm)
    translate_Button: TButton;
    way_Label: TLabel;
    mode_spin: TSpinEdit;
    way_Edit: TEdit;
    information_Edit: TEdit;
    info_Label: TLabel;
    procedure translate_ButtonClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  settings_Form: Tsettings_Form;

implementation
uses menu_unit;
{$R *.lfm}



{ Tsettings_Form }

procedure Tsettings_Form.translate_ButtonClick(Sender: TObject);
begin
  xorTranslator(mode_spin.Value, information_edit.text, way_edit.text);
end;

end.

