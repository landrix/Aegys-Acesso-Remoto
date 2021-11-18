unit uCtrl_Conexoes;

interface

uses
  System.Classes, System.Generics.Collections, uConstants, System.Win.ScktComp,
  uCtrl_ThreadsService;

type
  TConexao = class
  private
    FID: string;
    FIDParceiro: string;
    FLatencia: string;
    FProtocolo: string;
    FSenha: string;
    FThreadAreaRemota: TThreadConexaoAreaRemota;
    FThreadArquivos: TThreadConexaoArquivos;
    FThreadPrincipal: TThreadConexaoPrincipal;
    FThreadTeclado: TThreadConexaoTeclado;
    FPingInicial: Int64;
    FPingFinal: Int64;
    procedure SetID(const Value: string);
    procedure SetIDParceiro(const Value: string);
    procedure SetLatencia(const Value: string);
    procedure SetProtocolo(const Value: string);
    procedure SetSenha(const Value: string);
    procedure SetThreadAreaRemota(const Value: TThreadConexaoAreaRemota);
    procedure SetThreadArquivos(const Value: TThreadConexaoArquivos);
    procedure SetThreadPrincipal(const Value: TThreadConexaoPrincipal);
    procedure SetThreadTeclado(const Value: TThreadConexaoTeclado);
    procedure SetPingInicial(const Value: Int64);
    procedure SetPingFinal(const Value: Int64);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Ping;
    procedure CriarThread(AThread: IDThreadType; ASocket: TCustomWinSocket);
    procedure LimparThread(AThread: IDThreadType);
    property ID: string read FID write SetID;
    property IDParceiro: string read FIDParceiro write SetIDParceiro;
    property Latencia: string read FLatencia write SetLatencia;
    property PingFinal: Int64 read FPingFinal write SetPingFinal;
    property PingInicial: Int64 read FPingInicial write SetPingInicial;
    property Protocolo: string read FProtocolo write SetProtocolo;
    property Senha: string read FSenha write SetSenha;
    property ThreadAreaRemota: TThreadConexaoAreaRemota read FThreadAreaRemota write SetThreadAreaRemota;
    property ThreadArquivos: TThreadConexaoArquivos read FThreadArquivos write SetThreadArquivos;
    property ThreadPrincipal: TThreadConexaoPrincipal read FThreadPrincipal write SetThreadPrincipal;
    property ThreadTeclado: TThreadConexaoTeclado read FThreadTeclado write SetThreadTeclado;
  end;

  TConexoes = class
  private
    FListaConexoes: TObjectList<TConexao>;
  public
    constructor Create;
    destructor Destroy; override;
    function GerarID: string;
    function GerarSenha: string;
    function RetornaIDParceiroPorID(AID: string): string;
    function RetornaItemPorConexao(AConexao: string): TConexao;
    function RetornaItemPorID(AID: string): TConexao;
    function VerificaID(AID: string): Boolean;
    function VerificaIDSenha(AID, ASenha: string): Boolean;
    procedure AdicionarConexao(AProtocolo: string);
    procedure InserirIDAcesso(AConexao, AID: string);
    procedure RemoverConexao(AProtocolo: string);
    property ListaConexoes: TObjectList<TConexao> read FListaConexoes;
  end;

implementation

uses
  System.SysUtils, Winapi.Windows;

{ TConexao }

procedure TConexao.SetPingFinal(const Value: Int64);
begin
  FPingFinal := Value;
end;

procedure TConexao.SetPingInicial(const Value: Int64);
begin
  FPingInicial := Value;
end;

procedure TConexao.SetProtocolo(const Value: string);
begin
  FProtocolo := Value;
end;

constructor TConexao.Create;
begin
  PingInicial := 0;
  PingFinal := 256;
end;

procedure TConexao.CriarThread(AThread: IDThreadType; ASocket: TCustomWinSocket);
begin
  case AThread of
    ttPrincipal:
      begin
        LimparThread(ttPrincipal);
        FThreadPrincipal := TThreadConexaoPrincipal.Create(ASocket, Protocolo);
      end;
    ttAreaRemota:
      begin
        LimparThread(ttAreaRemota);
        FThreadAreaRemota := TThreadConexaoAreaRemota.Create(ASocket, Protocolo);
      end;
    ttTeclado:
      begin
        LimparThread(ttTeclado);
        FThreadTeclado := TThreadConexaoTeclado.Create(ASocket, Protocolo);
      end;
    ttArquivos:
      begin
        LimparThread(ttArquivos);
        FThreadArquivos := TThreadConexaoArquivos.Create(ASocket, Protocolo);
      end;
  end;
end;

destructor TConexao.Destroy;
begin
  if Assigned(FThreadPrincipal) then
    LimparThread(ttPrincipal);
  if Assigned(FThreadAreaRemota) then
    LimparThread(ttAreaRemota);
  if Assigned(FThreadTeclado) then
    LimparThread(ttTeclado);
  if Assigned(FThreadArquivos) then
    LimparThread(ttArquivos);
  inherited;
end;

procedure TConexao.LimparThread(AThread: IDThreadType);
var
  FThread: TThread;
begin
  Protocolo := Protocolo;
  case AThread of
    ttPrincipal:
      begin
        if Assigned(FThreadPrincipal) then
        begin
          if not FThreadPrincipal.Finished then
            FThreadPrincipal.Terminate;
          FThreadPrincipal := nil;
        end;
      end;
    ttAreaRemota:
      begin
        if Assigned(FThreadAreaRemota) then
        begin
          if not FThreadAreaRemota.Finished then
            FThreadAreaRemota.Terminate;
          FThreadAreaRemota := nil;
        end;
      end;
    ttTeclado:
      begin
        if Assigned(FThreadTeclado) then
        begin
          if not FThreadTeclado.Finished then
            FThreadTeclado.Terminate;
          FThreadTeclado := nil;
        end;
      end;
    ttArquivos:
      begin
        if Assigned(FThreadArquivos) then
        begin
          if not FThreadArquivos.Finished then
            FThreadArquivos.Terminate;
          FThreadArquivos := nil;
        end;
      end;
  end;
end;

procedure TConexao.Ping;
var
  FSocket: TCustomWinSocket;
begin
  try
    if ThreadPrincipal = nil then
      Exit;

    FSocket := ThreadPrincipal.scClient;

    if (FSocket = nil) or not(FSocket.Connected) then
      Exit;

    FSocket.SendText('<|PING|>');
    PingInicial := GetTickCount;

    if Latencia <> 'Calculando...' then
      FSocket.SendText('<|SETPING|>' + IntToStr(PingFinal) + '<|END|>');
  except
  end;
end;

procedure TConexao.SetID(const Value: string);
begin
  FID := Value;
end;

procedure TConexao.SetIDParceiro(const Value: string);
begin
  FIDParceiro := Value;
end;

procedure TConexao.SetLatencia(const Value: string);
begin
  FLatencia := Value;
end;

procedure TConexao.SetSenha(const Value: string);
begin
  FSenha := Value;
end;

procedure TConexao.SetThreadAreaRemota(const Value: TThreadConexaoAreaRemota);
begin
  FThreadAreaRemota := Value;
end;

procedure TConexao.SetThreadArquivos(const Value: TThreadConexaoArquivos);
begin
  FThreadArquivos := Value;
end;

procedure TConexao.SetThreadPrincipal(const Value: TThreadConexaoPrincipal);
begin
  FThreadPrincipal := Value;
end;

procedure TConexao.SetThreadTeclado(const Value: TThreadConexaoTeclado);
begin
  FThreadTeclado := Value;
end;

{ TConexoes }

procedure TConexoes.AdicionarConexao(AProtocolo: string);
var
  i: Integer;
begin
  FListaConexoes.Add(TConexao.Create);
  i := FListaConexoes.Count - 1;
  FListaConexoes[i].Protocolo := AProtocolo;
  FListaConexoes[i].ID := GerarID;
  FListaConexoes[i].Senha := GerarSenha;
end;

constructor TConexoes.Create;
begin
  inherited;
  FListaConexoes := TObjectList<TConexao>.Create;
end;

destructor TConexoes.Destroy;
begin
  FreeAndNil(FListaConexoes);
end;

function TConexoes.GerarID: string;
var
  xID: string;
  bExists: Boolean;
  Conexao: TConexao;
begin
  bExists := False;
  while True do
  begin
    Randomize;
    xID := IntToStr(Random(9)) + IntToStr(Random(9)) + IntToStr(Random(9)) + '-' + IntToStr(Random(9)) + IntToStr(Random(9)) + IntToStr(Random(9)) + '-' + IntToStr(Random(9)) + IntToStr(Random(9)) + IntToStr(Random(9));
    for Conexao in FListaConexoes do
    begin
      if Conexao.ID = xID then
      begin
        bExists := True;
        Break;
      end;
    end;
    if not(bExists) then
      Break;
  end;
  Result := xID;
end;

function TConexoes.GerarSenha: string;
begin
  Randomize;
  Result := IntToStr(Random(9)) + IntToStr(Random(9)) + IntToStr(Random(9)) + IntToStr(Random(9));
end;

procedure TConexoes.InserirIDAcesso(AConexao, AID: string);
var
  Conexao, Conexao2: TConexao;
begin
  Conexao := RetornaItemPorConexao(AConexao);

  if Assigned(Conexao) then
  begin
    Conexao.IDParceiro := AID;

    Conexao2 := RetornaItemPorID(AID);
    Conexao2.IDParceiro := Conexao.ID;
  end;
end;

procedure TConexoes.RemoverConexao(AProtocolo: string);
var
  Conexao: TConexao;
begin
  if AProtocolo = '' then
    Exit;
  for Conexao in FListaConexoes do
  begin
    if Conexao.Protocolo = AProtocolo then
    begin
      FListaConexoes.Remove(Conexao);
      Break;
    end;
  end;
end;

function TConexoes.RetornaIDParceiroPorID(AID: string): string;
var
  Conexao: TConexao;
begin
  Result := '';
  Conexao := RetornaItemPorID(AID);
  if Assigned(Conexao) then
    Result := Conexao.IDParceiro;
end;

function TConexoes.RetornaItemPorConexao(AConexao: string): TConexao;
var
  Conexao: TConexao;
begin
  Result := nil;
  if AConexao = '' then
    Exit;
  for Conexao in FListaConexoes do
  begin
    if Conexao.Protocolo = AConexao then
    begin
      Result := Conexao;
      Break;
    end;
  end;
end;

function TConexoes.RetornaItemPorID(AID: string): TConexao;
var
  Conexao: TConexao;
begin
  Result := nil;
  if AID = '' then
    Exit;
  for Conexao in FListaConexoes do
  begin
    if Conexao.ID = AID then
    begin
      Result := Conexao;
      Break;
    end;
  end;
end;

function TConexoes.VerificaID(AID: string): Boolean;
var
  Conexao: TConexao;
begin
  for Conexao in FListaConexoes do
  begin
    if Conexao.ID = AID then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TConexoes.VerificaIDSenha(AID, ASenha: string): Boolean;
var
  Conexao: TConexao;
begin
  Result := False;
  for Conexao in FListaConexoes do
  begin
    if (Conexao.ID = AID) and (Conexao.Senha = ASenha) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

end.
