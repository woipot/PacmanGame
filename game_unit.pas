unit game_unit;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Grids, StdCtrls;

{ TGame_Form }

type
  TGame_Form = class(TForm)
    HPEdit: TLabel;
    Image24: TImage;
    Image25: TImage;
    Image27: TImage;
    timeLabel: TLabel;
    scoreEdit: TLabel;
    map_grid: TStringGrid;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

type
 SETTINGS = record
   file_name: string;
   game_mode: word;
 end;

type
  POINT = record
    x: integer;
    y: integer;
  end;

STGhost = class(Tthread)
  public
    dif: integer;
    arImage: array [1..4] of TImage;
    TIGhost: TImage;
    direction: word;
    counter_time: word;
    ghost_position: POINT;
    start_ghost_position: POINT;
    ghost_index: integer;
    procedure ghost_to_start_position;
    procedure ghost_pac_lose;
  private
    move_position: POINT;
    new_top: integer;
    new_left: integer;
    procedure change_tex;
    procedure Move;
  protected
    Procedure Execute; override;
end;

STPACMAN = class(Tthread)
  public
    pac_direction, next_pac_direction: word;
    ARImage: array [0..8] of Timage;
    TIpacman: TImage;
    pac_position: POINT;
    start_pac_position: POINT;
    pac_life: word;
    image_index: word;
    procedure pac_win;
    procedure pac_to_start_position;
  private
    procedure change_tex;
    procedure test;
    procedure Move_pac;
    Procedure Delete_point;
  protected
    Procedure Execute; override;
end;

var
  Game_Form: TGame_Form;
  g_set: SETTINGS;

  finSet: text;
  finmap: text;

  TIwall: array of TImage;
  TIpoint: array of TImage;
  ARghost: array of STGHOST;
  pac: STPACMAN;

  TIlife: TImage;

  action_flag: integer;

  action_flag_exit: integer;
  score: integer;
  point_count: word;

const
  comp_size = 14;  //speed = 1sek / (comp_size /pac_speed * pac_time) блоков в секунду

  h_exsize = 35;
  w_exsize = 0;

  small_point_score = 25;

  pac_speed = 2;
  pac_time = 32;

  dificult_lvl = 4;

  ghost_time = 40;
  ghost_speed = 2;

  max_size_x = 60;
  max_size_y = 30;

  min_size_x = 15;
  min_size_y = 10;

  pinky_range = 4;//4 normal
  blubi_range = 2;//2 normal
  shadow_range = 8;//8 normal



implementation
uses menu_unit;
{$R *.lfm}

{ TGame_Form }

procedure TGame_Form.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  counter: word;                                                                          =
  nik_name: string;
begin
  if (length(ArGhost) <> 0) then
    for counter := 0 to length(ArGhost) - 1 do begin
      ArGhost[counter].terminate;
    end;
  if pac <> nil then begin
    pac.terminate;

  repeat

      if (not InputQuery('Запись в таблицу результатов', 'Введите ваше имя (не более 10 симовлов (5 русских))', nik_name)) then
        break
      else

      if (length(nik_name) <> 0) and (length(nik_name) <= 10) then begin
        for counter:= 0 to 20 - length(nik_name) - length(IntToStr(score)) do
          nik_name := nik_name + ' ';

        nik_name:= nik_name + intToStr(score);
        xorTranslator(2,nik_name, GetCurrentDir()+ '\data\records.txt');
        break;
      end;
  until false;

  end;

  if (length(TIPoint)<>0) then
  for counter := 0 to length(TIPoint) - 1 do
    TIpoint[counter].free;

  if (length(ArGhost) <> 0) then
    for counter := 0 to length(ArGhost) - 1 do begin
      {for imCounter := 1 to 4 do
        ArGhost[counter].ArImage[ImCounter].picture := nil;}

     ArGhost[counter].TIGhost.picture := nil;
     freeandnil(ArGhost[counter]);
    end;

  if (length(TIwall)<> 0) then
  for counter := 0 to length(TIwall) - 1 do
    freeandnil(TiWall[counter]);

  if (pac <> nil) then begin
    {for imCounter := 0 to  8 do
      pac.ARImage[iMcounter].picture := nil;}

    pac.TIpacman.picture := nil;
    freeandnil(pac);

  end;

  map_grid.RowCount := 1;
end;


{procedure TGame_Form.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  counter: word;
  buttonSelected: integer;
begin
  if (length(ArGhost) <> 0) then
    for counter := 0 to length(ArGhost) - 1 do
      //ArGhost[counter].suspend;

  // Отображение диалога с подтверждением
  buttonSelected := MessageDlg('Вы действительно хотите выйти',mtConfirmation, [mbYes, mbNo], 0);

  // Показ типа выбранной кнопки
  if buttonSelected = mrYes then begin
    CanClose := true;
    exit;
  end else
  if buttonSelected = mrNo then begin
    CanClose := false;
    exit;
  end;

end;}

/////////////////////////////////////синхронизация привидения
procedure STghost.move;
begin
  TIGhost.top := new_top;
  TIGhost.left := new_left;
end;
///////////////////////////////////// конец синхронизация привидения

procedure StGhost.change_tex;
begin
  if (direction <> 0) then
    TiGhost.picture := ArImage[direction].picture;
end;

/////////////////////////////////////поток привиденяи
Procedure STghost.Execute;
var
  //again: label;
  distance, new_distance: double;
  counter,tmp_counter: word;
  switcher: word;
  tmp_position: POINT;
begin
  new_top := Tighost.Top;
  new_left := TiGhost.left;
  while not terminated do begin
    sleep(ghost_time);

    case direction of
    1: if (pac.TIpacman.top + 7 >= tIGhost.Top) and (tIGhost.Top >= pac.TIpacman.top ) and (tIGhost.left = pac.TiPacman.left) then synchronize(@ghost_pac_lose);
    2: if (pac.TIpacman.left + 7 <= tIGhost.left + comp_size) and (tIGhost.left + comp_size <= pac.TIpacman.left + 14 ) and (tIGhost.top = pac.TiPacman.top) then synchronize(@ghost_pac_lose);
    3: if (pac.TIpacman.top + 7 <= tIGhost.Top + comp_size) and (tIGhost.Top + comp_size <= pac.TIpacman.top + 14 ) and (tIGhost.left = pac.TiPacman.left) then synchronize(@ghost_pac_lose);
    4: if (pac.TIpacman.left + 7 >= tIGhost.left) and (tIGhost.left >= pac.TIpacman.left )and (tIGhost.top = pac.TiPacman.top)  then synchronize(@ghost_pac_lose);
    end;

    if (Tighost.Top mod comp_size = 0) and (Tighost.left mod comp_size = 0) then begin

      switcher := 0;

      case direction of
      1: begin
           ghost_position.y := ghost_position.y - 1;
           if (Game_form.map_grid.cells[ghost_position.x, ghost_position.y - 1] = '1') then
             switcher := 1
         end;
      2: begin
           ghost_position.x := ghost_position.x + 1;
           if (Game_form.map_grid.cells[ghost_position.x + 1, ghost_position.y] = '1') then
             switcher := 1
         end;
      3: begin
           ghost_position.y := ghost_position.y + 1;
           if (Game_form.map_grid.cells[ghost_position.x, ghost_position.y + 1] = '1') then
             switcher := 1
         end;
      4: begin
          ghost_position.x := ghost_position.x - 1;
          if (Game_form.map_grid.cells[ghost_position.x - 1, ghost_position.y] = '1') then
            switcher := 1
         end;
      end;

      for tmp_counter := 1 to 4 do begin
        if (tmp_counter <> direction) and (tmp_counter <> direction + 2) and (tmp_counter <> direction - 2) then
          case tmp_counter of
          1: if (Game_form.map_grid.cells[ghost_position.x, ghost_position.y - 1] <> '1') then
               switcher := 1;
          2: if (Game_form.map_grid.cells[ghost_position.x + 1, ghost_position.y] <> '1') then
               switcher := 1;
          3: if (Game_form.map_grid.cells[ghost_position.x, ghost_position.y + 1] <> '1') then
               switcher := 1;
          4: if (Game_form.map_grid.cells[ghost_position.x - 1, ghost_position.y] <> '1') then
               switcher := 1;
          end;
      end;

      if (switcher = 1) then begin
        case dif of
        //0:
        ///////////////////////////////////////////reaper
        1: begin
             move_position.x := pac.pac_position.x;
             move_position.y := pac.pac_position.y;
           end;
        //////////////////////////////////////////////blubi
        2: begin
             if (length(ARghost) <= dificult_lvl) then
               tmp_counter := 0
             else
               tmp_counter := trunc((length(ARghost) -1)/dificult_lvl) * 4;

             case pac.pac_direction of
             0,1: begin
                    tmp_position.x := pac.pac_position.x;
                    tmp_position.y := pac.pac_position.y - blubi_range;
                  end;
             2: begin
                    tmp_position.x := pac.pac_position.x + blubi_range;
                    tmp_position.y := pac.pac_position.y;
                  end;
             3: begin
                    tmp_position.x := pac.pac_position.x;
                    tmp_position.y := pac.pac_position.y + blubi_range;
                  end;
             4: begin
                    tmp_position.x := pac.pac_position.x - blubi_range;
                    tmp_position.y := pac.pac_position.y;
                  end;
             end;
             move_position.x := tmp_position.x + (tmp_position.x - ARghost[tmp_counter].Ghost_position.x);
             move_position.y := tmp_position.y + (tmp_position.y - ARghost[tmp_counter].Ghost_position.y);
           end;
        ///////////////////////////////////////////////////pinky
        3: begin
             case pac.pac_direction of
             0: begin
                  move_position.x := pac.pac_position.x;
                  move_position.y := pac.pac_position.y;
                end;
             1: begin
                    move_position.x := pac.pac_position.x;
                    move_position.y := pac.pac_position.y - pinky_range;
                  end;
             2: begin
                    move_position.x := pac.pac_position.x + pinky_range;
                    move_position.y := pac.pac_position.y;
                  end;
             3: begin
                    move_position.x := pac.pac_position.x;
                    move_position.y := pac.pac_position.y + pinky_range;
                  end;
             4: begin
                    move_position.x := pac.pac_position.x - pinky_range;
                    move_position.y := pac.pac_position.y;
                  end;
             end;
           end;
        //////////////////////////////////////////////////////////shadow
        4: begin
             if (sqrt(sqr(move_position.x - trunc(Game_form.map_grid.colcount / 5 )) + sqr(move_position.y - Game_form.map_grid.RowCount - 1)) < shadow_range) then begin
               move_position.x := pac.pac_position.x;
               move_position.y := pac.pac_position.y;
             end else begin
               move_position.x := trunc(Game_form.map_grid.colcount / 5 );
               move_position.y := Game_form.map_grid.RowCount + 1;
             end;
           end;
        end;
        /////////////////////////////////////////////////////////////
        tmp_counter := 1;
             counter := 1;
             //определение дистанции код
             if (Game_form.map_grid.cells[ghost_position.x, ghost_position.y - 1] <> '1') then begin
               new_distance := sqrt(sqr(move_position.x - ghost_position.x) + sqr(move_position.y - ghost_position.y + 1));

               if (counter = 1) then begin
                 distance := new_distance;
                 direction := tmp_counter;
               end else
               if (new_distance < distance) then begin
                 direction := tmp_counter;
                 //TIGhost.picture := ArImage[direction].picture;
                 distance := new_distance;
               end;
               counter := 2;
             end;
             tmp_counter:= tmp_counter + 1;

             if (Game_form.map_grid.cells[ghost_position.x + 1, ghost_position.y] <> '1') then begin
                new_distance := sqrt(sqr(move_position.x - ghost_position.x - 1) + sqr(move_position.y - ghost_position.y));
                if (counter = 1) then begin
                 distance := new_distance;
                 direction := tmp_counter;
                 //TIGhost.picture := ArImage[direction].picture;
               end else
               if (new_distance < distance) then begin
                 direction := tmp_counter;
                 distance := new_distance;
                 //TIGhost.picture := ArImage[direction].picture;
               end;
               counter := 2;
             end;
             tmp_counter:= tmp_counter + 1;

             if (Game_form.map_grid.cells[ghost_position.x, ghost_position.y + 1] <> '1') then begin
                new_distance := sqrt(sqr(move_position.x - ghost_position.x) + sqr(move_position.y - ghost_position.y - 1));
                if (counter = 1) then begin
                 distance := new_distance;
                 direction := tmp_counter;
                 //TIGhost.picture := ArImage[direction].picture;
               end else
               if (new_distance < distance) then begin
                 direction := tmp_counter;
                 distance := new_distance;
                 //TIGhost.picture := ArImage[direction].picture;
               end;
               counter := 2;
             end;
             tmp_counter:= tmp_counter + 1;

             if (Game_form.map_grid.cells[ghost_position.x - 1, ghost_position.y] <> '1') then begin
                new_distance := sqrt(sqr(move_position.x - ghost_position.x + 1) + sqr(move_position.y - ghost_position.y));
                if (counter = 1) then begin
                 distance := new_distance;
                 direction := tmp_counter;
                 //TIGhost.picture := ArImage[direction].picture;
               end else
               if (new_distance < distance) then begin
                 direction := tmp_counter;
                 distance := new_distance;
                 //TIGhost.picture := ArImage[direction].picture;
               end;
               counter := 2;
             end;
             synchronize(@change_tex);

           end;

    end;

    case direction of
      1: begin
           new_top := TIghost.Top - ghost_speed;
           new_left := TIghost.Left;
         end;

      2: begin
           new_top := TIghost.Top;
           new_left := TIghost.Left + ghost_speed;
         end;

      3: begin
           new_top := TIghost.Top + ghost_speed;
           new_left := TIghost.Left;
         end;

      4: begin
           new_top := TIghost.Top;
           new_left := TIghost.Left - ghost_speed;
         end;
    end;
    Synchronize(@move);
  end;
end;

/////////////////////////////////////конец потока привидений


//////////////////////////////////////////на стартовую позицию
procedure STGHOST.ghost_to_start_position;
begin
  direction := 0;
  ghost_position.x := start_ghost_position.x;
  ghost_position.y := start_ghost_position.y;
  TIghost.left := ghost_position.x * comp_size;
  TIghost.top := ghost_position.y * comp_size;
  new_top := ghost_position.y * comp_size;
  new_left := ghost_position.x * comp_size;
  //game_form.update;
end;
////////////////////////////////////////конец процедуры "на стартовую позицию"

///////////////////////////обработка клавитатуры
procedure TGame_Form.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case key of
  87,119,1064,1094, 38: pac.next_pac_direction := 1;   //up
  65, 97, 1060, 1092,37 : pac.next_pac_direction := 4;   //left
  68, 100, 1042, 1074, 39: pac.next_pac_direction := 2;   //right
  83, 115, 1067, 1099,40 : pac.next_pac_direction := 3;   //down
  end;
end;
//////////////////////////конец обработки клавиатцуры

procedure STPACMAN.test;
begin
  game_form.caption := inttostr(next_pac_direction);
end;

procedure STPACMAN.change_tex;
begin
  case pac_direction of
  1: begin
       if (image_index = 1) then begin
         image_index:= 2;
         TIpacman.picture := ArImage[5].picture;
       end else if (image_index = 2) then begin
         image_index:= 0;
         TIpacman.picture := ArImage[0].picture;
       end else if (image_index = 0) then begin
         image_index:= 1;
         TIpacman.picture := ArImage[1].picture;
       end
     end;

  2: begin
       if (image_index = 1) then begin
         image_index:= 2;
         TIpacman.picture := ArImage[6].picture;
       end else if (image_index = 2) then begin
         image_index:= 0;
         TIpacman.picture := ArImage[0].picture;
       end else if (image_index = 0) then begin
         image_index:= 1;
         TIpacman.picture := ArImage[2].picture;
       end
     end;

  3: begin
       if (image_index = 1) then begin
         image_index:= 2;
         TIpacman.picture := ArImage[7].picture;
       end else if (image_index = 2) then begin
         image_index:= 0;
         TIpacman.picture := ArImage[0].picture;
       end else if (image_index = 0) then begin
         image_index:= 1;
         TIpacman.picture := ArImage[3].picture;
       end
     end;

  4: begin
       if (image_index = 1) then begin
         image_index:= 2;
         TIpacman.picture := ArImage[8].picture;
       end else if (image_index = 2) then begin
         image_index:= 0;
         TIpacman.picture := ArImage[0].picture;
       end else if (image_index = 0) then begin
         image_index:= 1;
         TIpacman.picture := ArImage[4].picture;
       end
     end;
  end;
end;

//////обработка потока пакмана
procedure STPACMAN.Execute;
begin
 while not terminated do begin
   sleep(pac_time);
   //Synchronize(@test);
 if (TIpacman.left mod comp_size = 0) and (TIpacman.top mod comp_size = 0) then begin //блок контроля движения

   if (next_pac_direction = 1) and (Game_Form.map_grid.cells[pac_position.x, pac_position.y - 1] <> '1') then begin
     pac_direction := next_pac_direction;
     TIpacman.picture := ArImage[pac_direction].picture;
     image_index := 1;
   end
   else if (next_pac_direction = 2) and (Game_Form.map_grid.cells[pac_position.x + 1, pac_position.y] <> '1') then begin
     pac_direction := next_pac_direction;
     TIpacman.picture := ArImage[pac_direction].picture;
     image_index := 1;
   end
   else if (next_pac_direction = 3) and (Game_Form.map_grid.cells[pac_position.x, pac_position.y + 1] <> '1') then begin
     pac_direction := next_pac_direction;
     TIpacman.picture := ArImage[pac_direction].picture;
     image_index := 1;
   end
   else if (next_pac_direction = 4) and (Game_Form.map_grid.cells[pac_position.x - 1, pac_position.y] <> '1') then begin
     pac_direction := next_pac_direction;
     TIpacman.picture := ArImage[pac_direction].picture;
     image_index := 1;
   end
   else if (pac_direction = 0) then begin
     pac_direction := next_pac_direction;
     TIpacman.picture := ArImage[pac_direction].picture;
     image_index := 1;
   end;

    if (Game_Form.map_grid.cells[pac_position.x, pac_position.y] = '4') and (pac_direction <> 0) then begin
       synchronize(@Delete_point);
    end;
 end;

  ///////////////////////////////////////////////////////////////блок обработки движдения
  if (pac_direction = 1) then begin  //для движения вверх

   if (Game_Form.map_grid.cells[pac_position.x, pac_position.y - 1] = '1') then begin
     pac_direction := 0;
   end;

  end else
  //для движения вправо
  if (pac_direction = 2) then begin

    if (Game_Form.map_grid.cells[pac_position.x + 1, pac_position.y] = '1') then begin
      pac_direction := 0;
    end;

  end else
  //для движения вниз
  if (pac_direction = 3) then begin

    if (Game_Form.map_grid.cells[pac_position.x, pac_position.y + 1] = '1') then begin
      pac_direction := 0;
    end;

  end else
  //для движения влево
  if (pac_direction = 4) then begin

    if (Game_Form.map_grid.cells[pac_position.x - 1, pac_position.y] = '1') then begin
      pac_direction := 0;
    end;

  end;

  synchronize(@change_tex);
/////////////////////////////////////////////////////////////// конец блока обработки движения
 synchronize(@move_pac);
 end;

end;
////////////////////////////////////конец потока пакмана

////////////////////////////////синхронизация передвижения картинки пакмна
procedure STPACMAN.Move_pac;
begin
   case pac_direction of
  1: begin
       TIpacman.top := TIpacman.top - pac_speed;
       if (TIpacman.top mod comp_size = 0) then
         pac_position.y := pac_position.y - 1;
     end;

  2: begin
       TIpacman.left := TIpacman.left + pac_speed;
       if (TIpacman.left mod comp_size = 0) then
         pac_position.x := pac_position.x + 1;
     end;

  3: begin
       TIpacman.top := TIpacman.top + pac_speed;
       if (TIpacman.top mod comp_size = 0) then
         pac_position.y := pac_position.y + 1;
     end;

  4: begin
       TIpacman.left := TIpacman.left - pac_speed;
       if (TIpacman.left mod comp_size = 0) then
         pac_position.x := pac_position.x - 1;
     end;
  end;

end;
////////////////////////конец синхронизации передвижения картинки

/////////////////////////////////нахождение и очистка картинки поинта
Procedure STPACMAN.Delete_point;
var
  searcher: word;
begin
  searcher := 0;
  while (TIpoint[searcher].name <> 'Point' + IntToStr(pac_position.x)+ 'str' + IntToStr(pac_position.y)) and (searcher < high(TIpoint)) do
        searcher := searcher + 1;
  TIpoint[searcher].picture := nil;
  score := score + small_point_score;
  game_form.scoreEdit.caption := inttostr(score);
  Game_Form.map_grid.cells[pac_position.x, pac_position.y] := '0';
  if (point_count - 1) <> 0 then
    point_count := point_count - 1
  else
    pac_win;
end;
/////////////////////////////конец нахождения и очистки поинта

procedure STPACMAN.pac_win;
var
  counter: word;
  nik_name: string;
begin
  if (length(ARGhost) <> 0) then
    for counter := 0 to length(ARGhost) - 1 do
      ARghost[counter].terminate;

  repeat
      if (not InputQuery('Вы смогли победить', 'Введите ваше имя (не более 10 симовлов (5 русских))', nik_name)) then
        break
      else

      if (length(nik_name) <> 0) and (length(nik_name) <= 10) then begin
        for counter:= 0 to 20 - length(nik_name) - length(IntToStr(score)) do
          nik_name := nik_name + ' ';

        nik_name:= nik_name + intToStr(score);
        xorTranslator(2,nik_name, GetCurrentDir()+ '\data\records.txt');
        break;
      end;
  until false;

  game_form.close;
end;
////////////////////////////////////////////////////////////////проиграши
procedure STGHOST.ghost_pac_lose;
var
  counter: word;
  nik_name: string;
begin

  if (pac.pac_life - 1 <> 0) then begin

    pac.pac_life := pac.pac_life - 1;
    game_form.HPEdit.caption := 'hp:' + intToSTr(pac.pac_life - 1);

    pac.pac_to_start_position;

    if (length(ARGhost) <> 0) then begin
      for counter := 0 to length(ARGhost) - 1 do
        ARghost[counter].ghost_to_start_position;
    end;

  end else begin

    if length(ArGhost) <> 0 then
      for counter := 0 to length(ArGhost) - 1 do
        if counter <> ghost_index then
          arGhost[counter].terminate;
    pac.terminate;

    {repeat
      if (not InputQuery('Вы проиграли', 'Введите ваше имя (не более 10 симовлов (5 русских))', nik_name)) then
        break
      else

      if (length(nik_name) <> 0) and (length(nik_name) <= 10) then begin
        for counter:= 0 to 20 - length(nik_name) - length(IntToStr(score)) do
          nik_name := nik_name + ' ';

        nik_name:= nik_name + intToStr(score);
        xorTranslator(2,nik_name, GetCurrentDir()+ '\data\records.txt');
        break;
      end;
    until false;}

    terminate;
    game_form.close;
  end;

end;

procedure STPACMAN.pac_to_start_position;
begin
  pac_direction := 0;
  next_pac_direction:= 0;
  pac_position.x := start_pac_position.x;
  pac_position.y := start_pac_position.y;
  TIpacman.left := pac_position.x * comp_size;
  TIpacman.top := pac_Position.y * comp_size;
end;

procedure TGame_Form.FormShow(Sender: TObject);  //считывание и заполнение карты и всех надстроек
var
  stmp: string;
  str_map: word;
  col_map: word;
  length_const: word;
  top_position, left_position: word;
  pac_counter, ghost_count, wall_count: word;
  way: string;
  point_index: word;
  dif_count: word;
  ghost_index: word;
  array_counter: word;
  counter, imCounter: word;

  texWAll: TImage;
  texPoint:TImage;
begin

 //way:= ExtractFileDir(Application.ExeName);
 way := GetCurrentDir(); // копируем путь

 assignfile(finSet, way + '\data\data.txt'); // открываем папку настроек
 {$I-}
 reset(finSet);
 {$I+}
 if (IOResult <> 0) then
     begin
       showmessage('#Error: Data file not found.');
       close;
       exit;
     end;

 readln(finSet, stmp);//открываем фаил карты
 g_set.file_name := xorTranslator(1,stmp,'');

 if length(g_set.file_name) = 0 then
 begin
   showmessage('#Error: map file not found.');
   closefile(finSet);
   destroy;
   exit;
 end;

 assignfile(finmap, g_set.file_name);
 {$I-}
 reset(finmap);
 {$I+}
 if (IOResult <> 0) then
     begin
       showmessage('#Error: map file not found.');
       closefile(finSet);
       close;
       exit;
     end;

 str_map:=0; length_const := 0; point_count := 0; //для опроверки прямоугольности карты
 ghost_count := 0; wall_count := 0;
 while (not eof(finmap)) do begin
   readln(finmap, stmp);

   stmp := xorTranslator(1,stmp,'');

   if (str_map <> 0) then begin  //проверка разности
    if (length(stmp) <> length_const) then begin
      showmessage('#ERROR: Broken map file'+#13#10+'in line:'+ intToStr(str_map+1));
      closefile(finSet);
      closefile(finmap);
      close;
      exit;
    end;

   end else if (str_map = 0) then begin //только при первом чтении
     length_const := length(stmp);
     map_grid.ColCount:= length_const;
   end;

   for col_map := 0 to length(stmp) - 1 do begin
     if (stmp[col_map + 1] = '4') then
       point_count := point_count + 1
     else if (stmp[col_map + 1] = '3') then
       ghost_count := ghost_count + 1
     else if (stmp[col_map + 1] = '1') then
       wall_count := wall_count + 1;

     map_grid.Cells[col_map, str_map]:= stmp[col_map + 1];
   end;

   inc(str_map);

   if (not eof(finmap)) then
       map_grid.RowCount := map_grid.RowCount + 1;
 end;
closefile(finMap);

 if (map_grid.ColCount < min_size_x) or (map_grid.RowCount < min_size_y) then begin
   ShowMessage('#ERROR: Veri small map');
   closefile(finSet);
   close;
   exit;
 end; {else
 if (map_grid.ColCount > max_size_x) or (map_grid.RowCount > max_size_y) then begin
   ShowMessage('#ERROR: Veri big map');
   Game_form.Destroy;
   exit;
 end; }

 Game_Form.Height := map_grid.RowCount * comp_size + H_exsize;
 Game_Form.Width := map_grid.ColCount * comp_size + W_exsize;

 if (point_count = 0) then begin
   showmessage('Fatal Error# There are no points on the map');
   closefile(finSet);
   close;
   exit;
 end else
   SetLength(TIpoint, point_count); //устанавливаем размер масива

 if (ghost_count = 0) then begin
   showmessage('Fatal Error# There are no ghost on the map');
 end else
   SetLength(ARghost, ghost_count); //устанавливаем размер масива

 setLength(TIwall, wall_count);


 texWall := TImage.create(game_form);
 texWall.parent:=Game_form;
 texWall.picture.loadFromFile(way+ '\game texture\wall 50x50.png');

 texPoint := TImage.create(game_form);
 texPoint.parent:=Game_form;
 texPOint.picture.loadFromFile(way+ '\game texture\point 50x50.png');

 pac_counter := 0; // чтобы был один пакман
 point_index := 0;
 ghost_index := 0;
 wall_count := 0;
 dif_count := 1;
 for col_map := 0 to map_grid.ColCount - 1 do begin
   top_position := 0;
   left_position := comp_size * col_map;
   for str_map := 0 to map_grid.RowCount - 1 do begin
     //////////////////////////////////////////////////////pacman
     if (pac_counter = 0) and (map_grid.Cells[col_map, str_map] = '2') then begin

       Pac := STPACMAN.Create(true);
       Pac.Priority := tpNormal;
       pac.freeOnTerminate:= false;

       pac.TIpacman := TImage.Create(game_form);
       pac.TIpacman.Parent:= Game_Form;

       for counter:= 0 to 8 do begin
           Pac.ArImage[counter] := TImage.Create(game_form);
           Pac.ArImage[counter].Parent:=Game_Form;
           Pac.ArImage[counter].visible := false;
       end;

       pac.TIpacman.Left:= left_position;

       top_position := comp_size * str_map;
       pac.TIpacman.Top := top_position ;

       pac.TIpacman.width := comp_size;
       pac.TIpacman.height := comp_size;

       pac.TIpacman.stretch:= true;

       Pac.ArImage[0].picture.LoadFromFile(way + '\game texture\pacman3 50x50.png');
       Pac.ArImage[1].picture.LoadFromFile(way + '\game texture\pacman1_top 50x50.png');
       Pac.ArImage[2].picture.LoadFromFile(way + '\game texture\pacman1_right 50x50.png');
       Pac.ArImage[3].picture.LoadFromFile(way + '\game texture\pacman1_down 50x50.png');
       Pac.ArImage[4].picture.LoadFromFile(way + '\game texture\pacman1_left 50x50.png');
       Pac.ArImage[5].picture.LoadFromFile(way + '\game texture\pacman2_top 50x50.png');
       Pac.ArImage[6].picture.LoadFromFile(way + '\game texture\pacman2_right 50x50.png');
       Pac.ArImage[7].picture.LoadFromFile(way + '\game texture\pacman2_down 50x50.png');
       Pac.ArImage[8].picture.LoadFromFile(way + '\game texture\pacman2_left 50x50.png');

       pac.TIpacman.picture:= pac.ArImage[2].picture;

       pac.pac_position.x := col_map;
       pac.pac_position.y := str_map;

       pac.start_pac_position.x := col_map; // стартовая позиция
       pac.start_pac_position.y := str_map;

       pac_counter := 1;
       ///////////////////////////////////////////////////////////////wall
      end else if (map_grid.Cells[col_map, str_map] = '1') then begin

         TIwall[wall_count]:= TImage.Create(game_form);
         TIwall[wall_count].Parent:=Game_Form;

         TIwall[wall_count].Left:= left_position;

         top_position := comp_size * str_map;
         TIwall[wall_count].Top := top_position ;

         TIwall[wall_count].Width:= comp_size;
         TIwall[wall_count].Height:= comp_size;


         TIwall[wall_count].stretch:= true;

         TIwall[wall_count].picture := texWall.picture;
         wall_count := wall_count + 1;
       ///////////////////////////////////////////////////////////////point
       end else if (map_grid.Cells[col_map, str_map] = '4') then begin

         TIpoint[point_index] := TImage.Create(game_form);
         TIpoint[point_index].Parent:=Game_Form;

         TIpoint[point_index].Left:= left_position;

         top_position := comp_size * str_map;
         TIpoint[point_index].Top := top_position ;

         TIpoint[point_index].Width:= comp_size;
         TIpoint[point_index].Height:= comp_size;


         TIpoint[point_index].stretch:= true;

         TIpoint[point_index].picture := texPoint.picture;
         TIpoint[point_index].Name := 'Point' + IntToStr(col_map)+ 'str' + IntToStr(str_map);
         point_index := point_index + 1;
       ///////////////////////////////////////////////////////////////ghost
       end else if (map_grid.Cells[col_map, str_map] = '3') then begin
         ARghost[ghost_index] := STGhost.Create(true);
         ARghost[ghost_index].Priority := tpNormal;
         ArGhost[ghost_index].freeOnTerminate:= false;

         ARghost[ghost_index].ghost_index := ghost_index;

         ARghost[ghost_index].Ghost_position.x := col_map;
         ARghost[Ghost_index].Ghost_position.y := str_map;

         ARghost[ghost_index].Start_Ghost_position.x := col_map;
         ARghost[Ghost_index].start_Ghost_position.y := str_map;

         ARghost[ghost_index].dif := dif_count;

         ARghost[ghost_index].TIGhost := TImage.Create(game_form);
         ARghost[ghost_index].TIghost.Parent:=Game_Form;

         for counter:= 1 to 4 do begin
           ARghost[ghost_index].ArImage[counter] := TImage.Create(game_form);
           ARghost[ghost_index].ArImage[counter].Parent:=Game_Form;
           ARghost[ghost_index].ArImage[counter].visible := false;
           stmp := way + '\game texture\ghost' + IntToStr(dif_count) + '_' + IntToStr(Counter)+' 50x50.png';
           ArGhost[ghost_index].Arimage[Counter].Picture.LoadFromfile(stmp);
         end;

         ARghost[ghost_index].TIghost.picture := ARghost[ghost_index].ArImage[2].picture;

         ARghost[ghost_index].TIghost.Left:= left_position;

         top_position := comp_size * str_map;
         ARghost[ghost_index].TIghost.Top := top_position ;

         ARghost[ghost_index].TIghost.Width:= comp_size;
         ARghost[ghost_index].TIghost.Height:= comp_size;


         ARghost[ghost_index].TIghost.stretch:= true;

         //ARghost[ghost_index].TIghost.Name := 'Ghost' + IntToStr(ghost_index);

         ghost_index := ghost_index + 1;

         if (dif_count < dificult_lvl) then
           dif_count := dif_count + 1
         else
           dif_count := 1;

       end else if (pac_counter = 1) and (map_grid.Cells[col_map, str_map] = '2' ) then // выводим не фатальную ошибку
         ShowMessage('Non fatal Error# Repeated pacman texture');

    end;

  end;

  freeAndNil(texwall);
  freeAndnil(texpoint);

  readln(finSet,stmp);
  stmp:= xorTranslator(1,stmp,'');

  if (stmp <> '') and (pac <> nil) then
    pac.pac_life := strtoint(stmp)
  else
    pac.pac_life := 3;

  HPEDit.caption := 'hp:' + intToSTr(pac.pac_life - 1);

  scoreEdit.left := 0;
  scoreEdit.Top := Game_Form.height - 30;

  HpEdit.left := scoreEdit.width;
  HpEdit.Top := Game_Form.height - 30;



  pac.pac_direction := 0;
  pac.next_pac_direction := 0;
  score := 0;


  Menu_Form.visible := false;
  action_flag_exit := 0;

  pac.Resume;
  if (length(ARghost) <> 0) then
    for array_counter := 0 to length(ARghost) - 1 do //запуск потоков
      ARghost[array_counter].Resume;

  closefile(FinSet);
end;
// конец процедуры



end.

