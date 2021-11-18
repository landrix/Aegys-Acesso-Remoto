program AegysSuporteCliente;

uses
  System.StartUpCopy,
  FMX.Forms,
  uFormConexao in 'View\uFormConexao.pas' {FormConexao},
  uFormTelaRemota in 'View\uFormTelaRemota.pas' {FormTelaRemota},
  uFormChat in 'View\uFormChat.pas' {FormChat},
  uFrameMensagemChat in 'Frame\uFrameMensagemChat.pas' {FrameMensagemChat: TFrame},
  uDM_Styles in 'Styles\uDM_Styles.pas' {DM_Styles: TDataModule},
  uFormArquivos in 'View\uFormArquivos.pas' {FormArquivos},
  uFrameArquivo in 'Frame\uFrameArquivo.pas' {FrameArquivo: TFrame},
  uCtrl_Threads in 'Control\uCtrl_Threads.pas',
  uLibClass in 'Lib\uLibClass.pas',
  uSendKeyClass in 'Lib\uSendKeyClass.pas',
  StreamManager in 'Lib\StreamManager.pas',
  uConstants in 'Structure\uConstants.pas',
  uFormSenha in 'View\uFormSenha.pas' {FormSenha},
  uCtrl_Conexao in 'Control\uCtrl_Conexao.pas',
  uHttpClass in 'Lib\uHttpClass.pas',
  Bcrypt in 'Lib\Bcrypt.pas';

{$R *.res}


begin
  Application.Initialize;
  Application.Title := 'Suporte Remoto';
  Application.CreateForm(TFormConexao, FormConexao);
  Application.CreateForm(TDM_Styles, DM_Styles);
  Application.CreateForm(TFormChat, FormChat);
  Application.CreateForm(TFormTelaRemota, FormTelaRemota);
  Application.CreateForm(TFormArquivos, FormArquivos);
  Application.CreateForm(TFormSenha, FormSenha);
  Application.Run;

end.
