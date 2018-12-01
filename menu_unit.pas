unit Menu_Unit;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Buttons,
  Menus, StdCtrls, ComCtrls, leveleditor_unit,  settings_unit, records_unit, help,
  About_unit, userset_unit;

{ TMenu_Form }

type
  TMenu_Form = class(TForm)
    GameMenu: TMainMenu;
    InfoLabel: TLabel;
    MenuFile: TMenuItem;
    MenuExit: TMenuItem;
    MenuHelp: TMenuItem;
    MenuAbout: TMenuItem;
    MenuHelpAct: TMenuItem;
    MenuDeweloper: TMenuItem;
    MenuSettings: TMenuItem;
    MenuSettingsAct: TMenuItem;
    Play_bitbut: TBitBtn;
    LevelEditor_bitbtn: TBitBtn;
    Seting_bitbut: TBitBtn;
    Exit_bitbut3: TBitBtn;
    Records_bitbut: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure LevelEditor_bitbtnClick(Sender: TObject);
    procedure MenuAboutClick(Sender: TObject);
    procedure MenuDeweloperClick(Sender: TObject);
    procedure MenuExitClick(Sender: TObject);
    procedure MenuHelpActClick(Sender: TObject);
    procedure MenuSettingsActClick(Sender: TObject);
    procedure Play_bitbutClick(Sender: TObject);
    procedure Records_bitbutClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

  function xorTranslator(mode: integer; information: string; way: string): string; //mode 1 - translate information, 2- xorTranslate information, 3 - xorTran

var
  Menu_Form: TMenu_Form;

implementation
uses
  game_unit;
{$R *.lfm}

{ TMenu_Form }

function xorTranslator(mode: integer; information: string; way: string): string; //mode 1 - translate information, 2- xorTranslate information, 3 - xorTranslate/translate file
var                                                                               //1: information                 2: information and way       3: way
  counter: word;
  tmp_str: string;
  file_str: string;
  code: char;
  inFile: text;
  outFIle: text;
begin

  code:= 'A';
  tmp_str := '';

  case mode of
  1: begin
       if (length(information) <> 0) then
         for counter:= 1 to length(information) do
           tmp_str := tmp_str + chr(ord(code) xor ord(information[counter]));

       xorTranslator := tmp_str;
     end;

  2: begin
       assignfile(InFile, way);
       {$I-}
       append(inFile);
       {$I+}
       if (IOResult <> 0) then
         begin
           //showmessage('#Error: file on way:' + way + ' ,not found.');
            {$I-}
            rewrite(InFile);
            {$I+}
            if (IOResult <> 0) then
            begin
              showmessage('#Error: file on way:' + way + ' ,not found.');
              exit;
            end;
         end;

       if (length(information) <> 0) then
         for counter:= 1 to length(information) do
           tmp_str := tmp_str + chr(ord(code) xor ord(information[counter]));

       writeln(inFile, tmp_str);

       close(inFile);
     end;

  3: begin
       assignfile(InFile, way);
       {$I-}
       reset(InFile);
       {$I+}
       if (IOResult <> 0) then
         begin
           showmessage('#Error: file on way:' + way + ' ,not found.');
           exit;
         end;

       assignfile(OutFile, ExtractFilePath(way) + '\tmp_file.txt');
       {$I-}
       rewrite(OutFile);
       {$I+}
       if (IOResult <> 0) then
         begin
           showmessage('#Error: fail creating tmp file');
           close(inFile);
           exit;
         end;

       while( not eof(InFile)) do begin
         readln(InFile, file_str);

         tmp_str := '';
         if (length(file_str) <> 0) then
           for counter:= 1 to length(file_str) do
             tmp_str := tmp_str + chr(ord(code) xor ord(file_str[counter]));

         writeln(OutFile, tmp_str);
       end;
       close(inFile);
       {file_str := ExtractFileName(way);
       file_str := ExtractFilePath(way);}
       Erase(InFile);


       //tmp_str:= ExtractFileName(way);
       close(outFile);
       rename(outFile, way);


       {if not renamefile(tmp_str, way) then begin
         ShowMessage('#Error: fail moving tmp file');
         close(OutFile);
         //erase(OutFile);
         exit;
       end;}


     end;

  end;
end;

procedure TMenu_Form.LevelEditor_bitbtnClick(Sender: TObject);
begin
  Menu_form.visible := false;
  levelEditor_form.Show;
  Menu_form.visible := true;
end;

procedure TMenu_Form.MenuAboutClick(Sender: TObject);
begin
  Menu_form.visible := false;
  about_form.Showmodal;
  Menu_form.visible := true;
end;

procedure TMenu_Form.FormCreate(Sender: TObject);
var
  data: text;
  tmp_str: string;
begin
  assignfile(data, GetCurrentDir() + '\data\data.txt');
  {$I-}
  reset(data);
  {$I+}
  if (IoResult <> 0) then begin

    {$I-}
    rewrite(data);
    {$I+}
    if (IoResult <> 0) then begin
      showMessage('#FAAAATAL: my data file is broken...I can not start game.');
      close;
      exit;
    end;
    closefile(data);
    xorTranslator(2,GetCurrentDir() + '\map\big 1.txt',GetCurrentDir() + '\data\data.txt');
    close;
    exit;
  end;

  if (not eof(data)) then
    readln(data,tmp_str);
    closefile(data);
    rewrite(data);
    closefile(data);
    if (pos(getCurrentDir(), tmp_str) = 0) then begin
      rewrite(data);
      closefile(data);
      xorTranslator(2,GetCurrentDir() + '\map\big 1.txt',GetCurrentDir() + '\data\data.txt');
    end
  else begin
    closefile(data);
    xorTranslator(2,GetCurrentDir() + '\map\big 1.txt',GetCurrentDir() + '\data\data.txt');
  end;


end;

procedure TMenu_Form.MenuDeweloperClick(Sender: TObject);
var
  nik_name: string;
begin
  nik_name := '';
  if (InputQuery('Доступ в режим разработки', 'Введите пароль', nik_name)) then
    if (nik_name = 't3o-103b') then begin
       Settings_form.showmodal;
    end;

end;

procedure TMenu_Form.MenuExitClick(Sender: TObject);
begin
  close;
end;

procedure TMenu_Form.MenuHelpActClick(Sender: TObject);
begin
  Menu_form.visible := false;
  Help_form.Showmodal;
  Menu_form.visible := true;
end;

procedure TMenu_Form.MenuSettingsActClick(Sender: TObject);
begin
  Menu_form.visible := false;
  UserSet_form.Showmodal;
  Menu_form.visible := true;
end;


procedure TMenu_Form.Play_bitbutClick(Sender: TObject);
begin
  //Menu_form.visible := false;
  infoLabel.caption := 'Wait...';
  Menu_form.update;
  Play_bitbut.Enabled := false;
  Game_form.Showmodal;
  infoLabel.caption := 'PACMAN';
  Menu_form.visible := true;
  Play_bitbut.Enabled := true;
end;

procedure TMenu_Form.Records_bitbutClick(Sender: TObject);
begin
  Menu_form.visible := false;
  records_form.Showmodal;
  Menu_form.visible := true;
end;

end.

