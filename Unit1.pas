unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Edit;

type
  TForm1 = class(TForm)
    Layout1: TLayout;
    Image1: TImage;
    Layout2: TLayout;
    Edit1: TEdit;
    Edit2: TEdit;
    Layout3: TLayout;
    Button1: TButton;
    Layout4: TLayout;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses Unit2;

procedure TForm1.Button1Click(Sender: TObject);
begin
Form2.show;
end;

end.
