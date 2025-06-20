#INCLUDE "WSVDF070.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE OPERATION_INSERT        1
#DEFINE OPERATION_UPDATE        2
#DEFINE OPERATION_APPROVE       3
#DEFINE OPERATION_REPROVE       4
#DEFINE OPERATION_DELETE        5

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �WSVDF070  � Autor �Marcelo Faria          � Data �12.11.2013  ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Web Service responsavel pelo Saldo de Dias de Folga          ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Portal RH Vida Funcional                                     ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Responsavel  � Data   �Tarefa�  Motivo da Alteracao                     ��� 
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

//�����������������������������������������������������Ŀ
//�Definicao da Estrutura dos campos                    �
//�������������������������������������������������������


//�����������������������������������������������������Ŀ
//�Definicao do Web Service de Saldo de Dias de Folga   �
//�������������������������������������������������������
WSSERVICE  RHVDFDaysOff                  DESCRIPTION STR0001       //Controle de Saldo de Dias de Folga
    WSDATA WsNull                          As String OPTIONAL       //NULL
    WSDATA EmployeeFil                    AS String                 //Filial do funcionario
    WSDATA Registration                   AS String                 //Matricula do funcionario

    WSDATA Request                        AS TRequest
    WSDATA VDFVacationRequest            AS TVDFVacation OPTIONAL

    WSMETHOD AddVDFDaysOffRequest       DESCRIPTION STR0002      //"Metodo que Inclui uma solicita��o para saldo de dias de folga"
ENDWSSERVICE

/*/
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Metodo    �AddVDFDaysOffRequest� Autor �Marcelo Faria        �Data �12.11.2013 ���
���������������������������������������������������������������������������������Ĵ��
���Descri��cao �Metodo para gravacao da solicitacao de saldo de dias de folga       ���
���������������������������������������������������������������������������������Ĵ��
���Uso       �Portal RH Vida Funcional                                            ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
/*/
WSMETHOD AddVDFDaysOffRequest WSRECEIVE Request, VDFVacationRequest WSSEND WsNull WSSERVICE RHVDFDaysOff
Local nReturnCode
Local nSaveSX8 := GetSX8Len()

    Self:Request:RequestType        := WSClassNew("TRequestType")
    Self:Request:Status              := WSClassNew("TRequestStatus")

    Self:Request:Code                := GetSX8Num("RH3", "RH3_CODIGO") 
    Self:Request:RequestType:Code  := "T"  ///Solicitacao de saldo de dias de folga
    Self:Request:ResponseDate       := CTod("")
    Self:Request:Status:Code        := "1"
    Self:Request:RequestDate        := dDataBase    
    Self:Request:StarterKey         := fBuscaChaveFuncionario(  Self:Request:StarterBranch,;
                                                                      Self:Request:StarterRegistration,;
                                                                      Self:Request:Vision)

    If Empty(Self:Request:ApproverRegistration)
        If Self:Request:ApproverLevel == 98
           Self:Request:Status:Code    := "5"
        Else
           Self:Request:Status:Code    := "4"
        EndIf   
        Self:Request:StarterLevel      := 1
    Else
        Self:Request:StarterLevel      := Self:Request:ApproverLevel+1
    EndIf                                                               

                                       
    Begin Transaction
        nReturnCode:= fPutRequest(Self:Request, OPERATION_INSERT,"SIGAGFP")
        If nReturnCode > 0
            SetSoapFault("AddVDFVPutRequest", STR0002)
            Break
        EndIf

        nReturnCode:= fAddVDFDaysOffRequest(Self:Request, Self:VDFVacationRequest, Self:Request:Code, OPERATION_INSERT)
        If nReturnCode > 0
            SetSoapFault("AddVDFDaysOffRequest", STR0002)
            Break
        EndIf
        
        nReturnCode:= fPutHistory(Self:Request, OPERATION_INSERT)
        If nReturnCode > 0
            SetSoapFault("AddVDFPostRequest", STR0002)
            Break
        EndIf
    
        If Self:Request:Status:Code == "1"        
            WFSolicPortal(OPERATION_INSERT, Self:Request:Code, Nil, Self:Request:Branch)
        EndIF    
        
    End Transaction

    If nReturnCode == 0
        While (GetSx8Len() > nSaveSx8)
            ConfirmSX8()
        EndDo
    Else
        Return .F.
    EndIf 

Return .T.

