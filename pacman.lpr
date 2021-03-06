program Project1;

{$mode delphi}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, menu_unit, levelEditor_unit, game_unit, Settings_unit, records_unit,
  Help, about_unit, UserSet_unit;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(Tmenu_Form, Menu_Form);
  Application.CreateForm(TLEvelEditor_Form, LevelEditor_Form);
  Application.CreateForm(TGame_Form, Game_Form);
  Application.CreateForm(Tsettings_Form, settings_Form);
  Application.CreateForm(Trecords_Form, records_Form);
  Application.CreateForm(THelp_form, Help_form);
  Application.CreateForm(TAbout_Form, About_Form);
  Application.CreateForm(TUserSet_Form, UserSet_Form);
  Application.Run;
end.

