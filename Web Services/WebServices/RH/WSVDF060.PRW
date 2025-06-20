#INCLUDE "WSVDF060.CH"
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
���Funcao    �WSVDF060  � Autor �Marcelo Faria          � Data �20.01.2014  ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Web Service responsavel pelas Certidoes Funcionais           ���
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
WSSTRUCT TVDFCertificate
    WSDATA DoctoID                     As String        //Codigo do Docto
    WSDATA DoctoDesc                   As String        //Descricao
ENDWSSTRUCT


//�����������������������������������������������������Ŀ
//�Definicao do Web Service de Certidoes Funcionais     �
//�������������������������������������������������������
WSSERVICE  RHVDFCertificate            DESCRIPTION STR0001    //Certidoes Funcionais
    WSDATA WsNull                        As String OPTIONAL     //NULL
    WSDATA EmployeeFil                  AS String               //Filial do funcionario
    WSDATA Registration                 AS String               //Matricula do funcionario

    WSDATA Request                       AS TRequest
    WSDATA VDFCertificateRequest       AS TVDFCertificate OPTIONAL

    WSMETHOD AddVDFCertificateRequest DESCRIPTION STR0002    //"Metodo que Inclui uma solicitacao de documento funcional"
ENDWSSERVICE                                                                                                     

/*/
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Metodo  �AddVDFCertificateRequest  � Autor �Marcelo Faria    �Data �20.01.2014 ���
���������������������������������������������������������������������������������Ĵ��
���Descri��o �Metodo para gravacao da solicitacao de documento funcional            ���
���������������������������������������������������������������������������������Ĵ��
���Uso     �Portal RH Vida Funcional                                              ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
/*/
WSMETHOD AddVDFCertificateRequest WSRECEIVE Request, VDFCertificateRequest WSSEND WsNull WSSERVICE RHVDFCertificate

    Local nReturnCode
    Local nSaveSX8 := GetSX8Len()

    Self:Request:RequestType       := WSClassNew("TRequestType")
    Self:Request:Status             := WSClassNew("TRequestStatus")
    
    Self:Request:Code               := GetSX8Num("RH3", "RH3_CODIGO") 
    Self:Request:RequestType:Code := "S"  ///Certificado Funcional
    Self:Request:ResponseDate      := CTod("")
    Self:Request:Status:Code       := "1"
    Self:Request:RequestDate       := dDataBase    
    Self:Request:StarterKey        := fBuscaChaveFuncionario(  Self:Request:StarterBranch,;
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
            SetSoapFault("PutRequest-VDFCertificate", STR0003)
            Break
        EndIf

        nReturnCode:= fAddVDFCertificateRequest(Self:Request, Self:VDFCertificateRequest, Self:Request:Code, OPERATION_INSERT)
        If nReturnCode > 0
            SetSoapFault("AddVDFCertificateRequest", STR0003)
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

