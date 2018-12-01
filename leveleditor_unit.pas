unit leveleditor_unit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, Spin, Grids, DBGrids;

{ TLevelEditor_Form }

type
  TLevelEditor_Form = class(TForm)
    Clear_button: TButton;
    map_tabl: TDrawGrid;
    EditorPanel: TPanel;
    componentsPanel: TPanel;
    fild_label: TLabel;
    config_panel: TPanel;
    Exit_Button: TButton;
    number_grid: TStringGrid;
    string_label: TLabel;
    colomn_Label: TLabel;
    SaveButton: TButton;
    LoadButton1: TButton;
    map_shape: TShape;
    String_Spin: TSpinEdit;
    Colomn_Spin: TSpinEdit;
    wall_SpeedButton: TSpeedButton;
    pacman_SpeedButton: TSpeedButton;
    ghost_SpeedButton: TSpeedButton;
    Target_SpeedButton: TSpeedButton;
    procedure Clear_buttonClick(Sender: TObject);
    procedure map_tablClick(Sender: TObject);
    procedure String_SpinChange(Sender: TObject);
    procedure wall_SpeedButtonClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  LevelEditor_Form: TLevelEditor_Form;

implementation

{$R *.lfm}

{ TLevelEditor_Form }

procedure draw_map();
const
  height = 500;
  weidth = 800;
begin
  ////////////////////////////////для чисел таблицы
  LevelEditor_form.number_grid.ColCount:= LevelEditor_form.Colomn_Spin.value;
  LevelEditor_form.number_grid.RowCount:= LevelEditor_form.string_Spin.value;

  ////////////////////////////////для видимой табоицу
  LevelEditor_form.map_tabl.ColCount:=LevelEditor_form.Colomn_Spin.value;
  LevelEditor_form.map_tabl.RowCount:=LevelEditor_form.string_Spin.value;
  LevelEditor_form.map_tabl.DefaultColWidth := round (weidth/LevelEditor_form.Colomn_Spin.value);
  LevelEditor_form.map_tabl.DefaultRowHeight := round (height/LevelEditor_form.string_Spin.value);


end;

procedure TLevelEditor_Form.String_SpinChange(Sender: TObject);
begin
  draw_map();
end;

procedure TLevelEditor_Form.wall_SpeedButtonClick(Sender: TObject);
begin

end;

procedure TLevelEditor_Form.Clear_buttonClick(Sender: TObject);
begin
  map_tabl.Clear;
end;

procedure TLevelEditor_Form.map_tablClick(Sender: TObject);
begin

end;

end.

