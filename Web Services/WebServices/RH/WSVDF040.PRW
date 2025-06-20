#INCLUDE "WSVDF040.CH"
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
���Funcao    �WSVDF040  � Autor �Marcelo Faria          � Data �14.08.2013  ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Web Service responsavel pelas Diarias                        ���
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
WSSTRUCT TVDFDaily
    WSDATA InitialDate                As String                 //Data Inicial
    WSDATA FinalDate                  As String                 //Data Final
ENDWSSTRUCT


//�����������������������������������������������������Ŀ
//�Definicao do Web Service de Diarias                  �
//�������������������������������������������������������
WSSERVICE  RHVDFDaily                  DESCRIPTION STR0001       //Vida Funcional  - Diarias
    WSDATA WsNull                     As String  OPTIONAL       //NULL
    WSDATA EmployeeFil                 AS String OPTIONAL       //Filial do funcionario
    WSDATA Registration                AS String OPTIONAL       //Matricula do funcionario

    WSDATA Request                     AS TRequest
    WSDATA VDFDailyRequest              AS TVDFDaily OPTIONAL

    WSMETHOD AddVDFDailyRequest          DESCRIPTION STR0002       //"Metodo que Inclui uma solicitacao de diaria"
ENDWSSERVICE                                                                                                     

/*/
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Metodo    �AddVDFDailyRequest   � Autor �Marcelo Faria       �Data �02.10.2013 ���
���������������������������������������������������������������������������������Ĵ��
���Descri��o �Metodo para gravacao da solicitacao de diarias                      ���
���������������������������������������������������������������������������������Ĵ��
���Uso       �Portal RH Vida Funcional                                            ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
/*/
WSMETHOD AddVDFDailyRequest WSRECEIVE Request, VDFDailyRequest WSSEND WsNull WSSERVICE RHVDFDaily

    Local nReturnCode
    Local nSaveSX8 := GetSX8Len()

    Self:Request:RequestType      := WSClassNew("TRequestType")
    Self:Request:Status            := WSClassNew("TRequestStatus")
    
    Self:Request:Code               := GetSX8Num("RH3", "RH3_CODIGO") 
    Self:Request:RequestType:Code := "Q"  ///Diarias
    Self:Request:ResponseDate      := CTod("")
    Self:Request:Status:Code       := "1"
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
            SetSoapFault("AddVDFDialyRequest", STR0003)
            Break
        EndIf

        nReturnCode:= fAddVDFDailyRequest(Self:Request, Self:VDFDailyRequest, Self:Request:Code, OPERATION_INSERT)
        If nReturnCode > 0
            SetSoapFault("AddVDFDailyRequest", STR0003)
            Break
        EndIf
        
        nReturnCode:= fPutHistory(Self:Request, OPERATION_INSERT)
        If nReturnCode > 0
            SetSoapFault("AddPostRequest", STR0003)
            Break
        EndIf

        If Self:Request:Status:Code == "1"    
            WFSolicPortal(OPERATION_INSERT, Self:Request:Code, Nil, Self:Request:Branch)
        EndIf    
    End Transaction

    If nReturnCode == 0
        While (GetSx8Len() > nSaveSx8)
            ConfirmSX8()
        EndDo
    Else
        Return .F.
    EndIf 
          
Return .T.

