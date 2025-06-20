#INCLUDE "WSGPE110.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � WSGPE110  � Autor � Emerson Campos		� Data � 23/04/2014 ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Web Service responsavel pela Solic Subs�dio acad�mico        ���
���������������������������������������������������������������������������Ĵ��
���Uso       � RH/Portais                                                   ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Responsavel  � Data   �Tarefa�  Motivo da Alteracao                     ��� 
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

//�����������������������������������������������������Ŀ
//�Definicao da Estrutura dos campos                    �
//�������������������������������������������������������
WSSTRUCT AcademicGrantFields
	WSDATA benefitCode						AS String				      			//C�digo do beneficio (RIS_CODE - Char - 2)
	WSDATA benefitName						AS String	      						//Nome do Benf�cio (RIS_DESC - Char - 20)
	WSDATA salaryTo							AS Float								//Sal�rio at�	
ENDWSSTRUCT                            

WSSTRUCT AcademicGrantList
	WSDATA itens								AS Array Of AcademicGrantFields		//Lista dos subs�dios acad�micos
	WSDATA curseName							AS String								//Nome do Curso
	WSDATA instituteName						AS String								//Nome da institui��o
	WSDATA contact							AS String								//Contato na intitui��o
	WSDATA phone								AS String								//Telefone do contato
	WSDATA startDate							AS String								//Data de inicio do curso
	WSDATA endDate							AS String								//Data do fim do curso
	WSDATA monthlyPayment					AS String								//Valor da mensalidade
	WSDATA installmentAmount					AS String								//Qtde. total de parcelas
	WSDATA observation						AS String								//Obesrva��o
ENDWSSTRUCT                            

//�����������������������������������������������������Ŀ
//�Definicao do Web Service de Subsidio Academico       �
//�������������������������������������������������������
WSSERVICE  RHAcademicGrant	DESCRIPTION STR0001				 					//Subsidio Academico
	WSDATA EmployeeFil 		 				AS String			        			//Filial do funcionario
	WSDATA Registration		 				AS String			        			//Matricula do funcionario

	WSDATA AcademicGrant	 					AS AcademicGrantList					//Lista de subs�dios acad�micos
	
	WSMETHOD GetListAcademicGrant			DESCRIPTION STR0002 					//Metodo que retorna a lista de subs�dios acad�micos dispon�veis para serem solicitados	
ENDWSSERVICE                                                                                                     

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Metodo    �GetRegEmployee � Autor �Marcelo Faria	      �Data �28.03.2012 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Metodo que retorna os campos do SRA, baseado na tabela RHW  	���
���������������������������������������������������������������������������Ĵ��
���Uso       � SIGATCF/Portal RH                                            ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
WSMETHOD GetListAcademicGrant WSRECEIVE EmployeeFil WSSEND AcademicGrant WSSERVICE RHAcademicGrant
Local cFilFun		:= ::EmployeeFil
Local lRet 		:= .T.
Local oItem
Local cQuery			:= GetNextAlias()

BeginSql alias cQuery
        SELECT R.RIS_COD
                  , R.RIS_DESC 
                  , R.RIS_SALATE
          FROM %table:RIS% R 
     WHERE (R.RIS_FILIAL = %exp:''% OR R.RIS_FILIAL = %exp:cFilFun%) 
       AND R.RIS_TPBENE = %exp:'83'%
       AND R.%notDel%    


EndSql 
                                          
If (cQuery)->(Eof())
	SetSoapFault(STR0001, STR0003)//"Subsidio Academico"   #   "N�o h� subs�dios acad�micos cadastrado ou dispon�veis."
	lRet :=  .F.
Else
	Self:AcademicGrant						:= WSClassNew("AcademicGrantList")
	Self:AcademicGrant:itens 				:= {}
	Self:AcademicGrant:curseName 			:= ''
	Self:AcademicGrant:instituteName 		:= ''
	Self:AcademicGrant:contact 				:= ''
	Self:AcademicGrant:phone 				:= ''
	Self:AcademicGrant:startDate 			:= ''
	Self:AcademicGrant:endDate 				:= ''
	Self:AcademicGrant:monthlyPayment 		:= ''
	Self:AcademicGrant:installmentAmount 	:= ''
	Self:AcademicGrant:observation 			:= ''
	
	While (cQuery)->(!Eof())	
		oItem:= WSClassNew("AcademicGrantFields")
		oItem:benefitCode			:= (cQuery)->RIS_COD
		oItem:benefitName			:= (cQuery)->RIS_DESC		
		oItem:salaryTo			:= (cQuery)->RIS_SALATE
		AAdd(Self:AcademicGrant:itens, oItem)
		(cQuery)->( dbSkip() )
	EndDo
EndIf	
Return lRet