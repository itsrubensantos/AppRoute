unit md_principal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Generics.Collections, System.JSON, System.Permissions, System.Sensors,
  System.Sensors.Components,
  FMX.StdCtrls, FMX.ScrollBox, FMX.Memo, FMX.Maps, FMX.Objects, FMX.Edit, FMX.Controls.Presentation,
  FMX.Layouts, FMX.Controls, FMX.TabControl, FMX.Types, FMX.Forms, FMX.Graphics,
  FMX.Dialogs, FMX.Ani, FMX.Colors, FMX.WebBrowser,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Data.Bind.Components,
  Data.Bind.ObjectScope,
  REST.Types, REST.Client, REST.Response.Adapter, Web.HTTPApp;

type
  TF_principal = class(TForm)
    header: TLayout;
    LayoutT1A: TLayout;
    Label1A: TLabel;
    ed_origem: TEdit;
    Label2: TLabel;
    bg_header1A: TRectangle;
    Label3: TLabel;
    ed_destino: TEdit;
    lb_distancia: TLabel;
    bt_calcular: TRectangle;
    lb_tempo: TLabel;
    LayoutT1B: TLayout;
    bt_1: TSpeedButton;
    RadioButton_1: TRadioButton;
    RadioButton_2: TRadioButton;
    LayoutT2C: TLayout;
    Label4: TLabel;
    TabControl: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    nav_menu: TRectangle;
    Tab_1: TImage;
    Tab_2: TImage;
    r_client: TRESTClient;
    r_request: TRESTRequest;
    bt_exibir: TRectangle;
    bt_2: TSpeedButton;
    LayoutT2A: TLayout;
    Switch: TSwitch;
    Label1: TLabel;
    LocationSensor: TLocationSensor;
    LayoutT2B: TLayout;
    bt_detalhes: TRectangle;
    bt_3: TSpeedButton;
    WebBrowser_1: TWebBrowser;
    bt_sair: TImage;
    WebBrowser_2: TWebBrowser;

    procedure bt_calcularClick(Sender: TObject);
    procedure bt_sairClick(Sender: TObject);
    procedure bt_exibirmapaClick(Sender: TObject);
    procedure MudaAba(img: TImage);
    procedure AbaClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure bt_detalhesClick(Sender: TObject);
    procedure SwitchClick(Sender: TObject);
    procedure LocationSensorLocationChanged(Sender: TObject;
      const OldLocation, NewLocation: TLocationCoord2D);
    procedure bt_infoClick(Sender: TObject);

  private
    { Private declarations }
    Location: TLocationCoord2D;
    FGeocoder: TGeocoder;

    {$IFDEF ANDROID}
     Access_Fine_Location, Access_Coarse_Location : string;
     procedure DisplayRationale(
     Sender: TObject; const APermissions: TArray<string>; const APostRationaleProc: TProc);
     procedure LocationPermissionRequestResult(
     Sender: TObject; const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>);
    {$ENDIF}

    procedure OnGeocodeReverseEvent(const Address: TCivicAddress);

  public
    { Public declarations }
  end;

var
  F_principal: TF_principal;

implementation

{$R *.fmx}

uses FMX.DialogService

{$IFDEF ANDROID}
,Androidapi.Helpers, Androidapi.JNI.JavaTypes, Androidapi.JNI.Os
{$ENDIF}
;

{$IFDEF ANDROID}

procedure TF_principal.DisplayRationale(Sender: TObject; const APermissions: TArray<string>; const APostRationaleProc: TProc);
var
  I: Integer;
  RationaleMsg: string;
begin
  for I := 0 to High(APermissions) do
  begin
    if (APermissions[I] = Access_Coarse_Location) or (APermissions[I] = Access_Fine_Location) then
    RationaleMsg := 'O app precisa ter acesso ao GPS para obter sua localização'
  end;
  TDialogService.ShowMessage(RationaleMsg, procedure(const AResult: TModalResult)
  begin
    APostRationaleProc;
  end);
end;

procedure TF_principal.LocationPermissionRequestResult
  (Sender: TObject; const APermissions: TArray<string>;
  const AGrantResults: TArray<TPermissionStatus>);
var
  x: integer;
begin
  if (Length(AGrantResults) = 2) and
  (AGrantResults[0] = TPermissionStatus.Granted) and
  (AGrantResults[1] = TPermissionStatus.Granted) then
  F_principal.LocationSensor.Active := true else
  begin
    Switch.IsChecked := false;
    TDialogService.ShowMessage('Não foi possível obter a localização porque o app está sem permissão de acesso ao GPS')
  end;
end;

{$ENDIF}

procedure TF_principal.OnGeocodeReverseEvent(const Address: TCivicAddress);
var
  msg : string;
begin
  msg :=
  Address.Thoroughfare + ', ' + { Rua }
  Address.FeatureName + ', ' + { Número }
  Address.SubLocality + ', ' + { Bairro }
  Address.PostalCode; { CEP }
//Address.SubThoroughfare + ', ' + { Numero }
//Address.AdminArea + ', ' +  { UF }
//Address.SubAdminArea + ', ' + { UF }
//Address.CountryCode + ', ' + { BR }
//Address.CountryName + ', ' + { Brasil }
//Address.Locality + ', ' + { ? }
  ed_origem.Text := msg;
  TDialogService.ShowMessage(msg);
//MudaAba(Tab_1);
end;

procedure TF_principal.LocationSensorLocationChanged(Sender: TObject;
  const OldLocation, NewLocation: TLocationCoord2D);
var
  lt, lg, url: string;
begin
  Location := NewLocation;
  lt := StringReplace(Format('%2.6f', [NewLocation.Latitude]), ',', '.', [rfReplaceAll]);
  lg := StringReplace(Format('%2.6f', [NewLocation.Longitude]), ',', '.', [rfReplaceAll]);
  LocationSensor.Active := false;
//Switch.IsChecked := false;
  url := 'https://maps.google.com/maps?q=';
  //https://maps.google.com/maps?q=  + lt + ',' + lg
  WebBrowser_1.Navigate(url);
end;

procedure TF_principal.FormCreate(Sender: TObject);
begin
  {$IFDEF ANDROID}
  Access_Coarse_Location := JStringToString(TJManifest_permission.JavaClass.ACCESS_COARSE_LOCATION);
  Access_Fine_Location := JStringToString(TJManifest_permission.JavaClass.ACCESS_FINE_LOCATION);
  {$ENDIF}
end;

procedure TF_principal.bt_detalhesClick(Sender: TObject);
begin
  try

    if not Assigned(FGeocoder) then
    begin
      if Assigned(TGeocoder.Current) then
      FGeocoder := TGeocoder.Current.Create;
      if Assigned(FGeocoder) then
      FGeocoder.OnGeocodeReverse := OnGeocodeReverseEvent;
    end;
    // Tratar a traducao do endereco...
    if Assigned(FGeocoder) and not FGeocoder.Geocoding then
    FGeocoder.GeocodeReverse(Location);
  except
    ShowMessage('Erro no serviço de GeoLocalização');
  end;
end;

procedure TF_principal.SwitchClick(Sender: TObject);
begin
  if Switch.IsChecked then
  begin
    {$IFDEF ANDROID}
    PermissionsService.RequestPermissions([
    Access_Coarse_Location,
    Access_Fine_Location],
    LocationPermissionRequestResult,
    DisplayRationale);
    {$ENDIF}

    {$IFDEF IOS}
    LocationSensor.Active := true;
    {$ENDIF}
  end;
end;

procedure TF_principal.AbaClick(Sender: TObject);
begin
  MudaAba(TImage(Sender));
end;

procedure TF_principal.MudaAba(img: TImage);
begin
  Tab_1.Opacity := 0.4;
  Tab_2.Opacity := 0.4;
  //b_3.Opacity := 0.4;
  TabControl.GotoVisibleTab(img.Tag, TTabTransition.Slide);
  TabControl.TabIndex := img.Tag;
  img.Opacity := 1;
end;

procedure TF_principal.bt_exibirmapaClick(Sender: TObject);
begin
  MudaAba(Tab_2);
end;

procedure TF_principal.bt_infoClick(Sender: TObject);
begin
  ShowMessage('App distancia')
end;

procedure TF_principal.bt_sairClick(Sender: TObject);
begin
F_principal.Close;
end;

procedure TF_principal.bt_calcularClick(Sender: TObject);
var
  retorno: TJSONObject;
  p_rows: TJSONPair;
  array_rows: TJSONArray;
  array_elements: TJSONArray;
  obj_rows, obj_elements, obj_distancia,
  obj_duracao: TJSONObject;
  s_distancia,
  s_duracao: string;
  v_distancia,
  v_duracao: integer;
  media_v: double;
  s1, s2, url: string;
begin


  r_client.BaseURL := 'https://maps.googleapis.com/maps/api/distancematrix';
  r_request.Resource := 'json?origins={origem}&destinations={destino}&mode=driving&language=pt-BR&key=AIzaSyAwjnJzF57fQddVy_dL8yTC01Zw7ufVuY8';
  r_request.Params.AddUrlSegment('origem', ed_origem.Text);
  r_request.Params.AddUrlSegment('destino', ed_destino.Text);
  r_request.Params.AddUrlSegment('api_key', 'enter_here_YOUR_API_KEY');

  if RadioButton_1.IsChecked = True then
  r_request.Params.AddUrlSegment('opcao', 'driving') else
  if RadioButton_2.IsChecked = True then
  r_request.Params.AddUrlSegment('opcao', 'bicycling') else
  r_request.Params.AddUrlSegment('opcao', 'transit');
  r_request.Execute;

  retorno := r_request.Response.JSONValue as TJSONObject;

  if retorno.GetValue('status').Value <> 'OK' then
  begin
    showmessage('Ocorreu um erro ao calcular sua rota');
    Exit;
  end;

  p_rows := retorno.Get('rows');

  array_rows := p_rows.JsonValue as TJSONArray;
  obj_rows := array_rows.Items[0] as TJSONObject;

  array_elements := obj_rows.GetValue('elements') as TJSONArray;
  obj_elements := array_elements.Items[0] as TJSONObject;
  obj_distancia := obj_elements.GetValue('distance') as TJSONObject;
  obj_duracao := obj_elements.GetValue('duration') as TJSONObject;

  s_distancia := obj_distancia.GetValue('text').Value;
  v_distancia := StrToInt(obj_distancia.GetValue('value').Value);
  s_duracao   := obj_duracao.GetValue('text').Value;
  v_duracao   := StrToInt(obj_duracao.GetValue('value').Value);

  lb_distancia.Text := 'Distância a percorrer: '+s_distancia;
  lb_tempo.Text := 'Tempo estimado: '+s_duracao;



  //Switch.IsChecked := false;
  s1 := StringReplace(ed_origem.Text, ' ', '+', [rfReplaceAll]);
  s2 := StringReplace(ed_destino.Text, ' ', '+', [rfReplaceAll]);
  url := 'https://www.google.com/maps/dir/'+s1+'/'+s2+'/@,,14z';

  WebBrowser_2.Navigate(url);
end;

procedure TF_principal.FormShow(Sender: TObject);
begin
  MudaAba(Tab_1);
end;

end.
