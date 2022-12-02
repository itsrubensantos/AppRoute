unit Unit2;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls;

type
  TForm2 = class(TForm)
    Image1: TImage;
    Layout1: TLayout;
    Image2: TImage;
    Label1: TLabel;
    Layout2: TLayout;
    Image3: TImage;
    Image4: TImage;
    Label2: TLabel;
    Label3: TLabel;
    procedure Image2Click(Sender: TObject);
    procedure Image4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.fmx}

uses md_principal, Unit3;

procedure TForm2.Image2Click(Sender: TObject);
begin
F_principal.Show;
end;

procedure TForm2.Image4Click(Sender: TObject);
begin
Form3.show;
end;

end.
