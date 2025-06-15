#INCLUDE "TOTVS.CH"

/*/
{Protheus.doc} RHNPLIBJOB
- Rela�ao de funcoes do Meu RH que poder�o ser executadas via JOB quando � necess�rio obter dados de outro grupo;
/*/

/*/
{Protheus.doc} GetDataOrJob
- Executa a fun��o normal, ou via job quando a solicita��o � para outro grupo
@author:	Marcelo Silveira
@since:		03/08/2020
@param:		cRotina - C�digo que indica qual rotina ser� executada;
			aParams - Parametros que ser�o passados para a rotina que ser� executada;			
			cEmpToReq - Empresa para verificar se a execu��o ser� via Job;
@return:	uRet - Retorno conforme a fun��o que est� sendo executada

----------------------------------------------------------
Premissas para que uma fun��o possa ser executada via Job

Uma fun��o qualquer que est� sendo executada via Job:

	1. Dever� receber 3 par�metros adicionais: 
		- C�digo do Grupo onde a fun��o deve ser executada
		- Vari�vel l�gica para indicar a execu��o via JOB
		- Nome da vari�vel p�blica de controle 

	2. Na execu��o via Job dever� setar a conex�o e o ambiente do grupo (3 para n�o consumir licen�as)
		RPCSetType( 3 )
		RPCSetEnv( CEMPRESA, CFILIAL ) //Empresa e Filial para prepara��o do ambiente
	
	3. Antes do retorno da fun��o a vari�vel de controle dever� ser alimentada com valor "1" para indicar o t�rmino do Job
		PutGlbValue(cUID, "1")

Exemplo de uso: GetPeriodApont()
----------------------------------------------------------
/*/
Function GetDataForJob( cRotina, aParams, cEmpToReq)

Local uRet							//Retorno da fun��o
Local cNewPar01		:= Nil

Local cUID			:= ""			//Nome da variavel de controle na execu��o via Job
Local nCount		:= 0			//Contador para controlar o limite para finaliza��o do Job
Local nTime			:= 1000			//Indica quantos segundos o sistema ir� aguardar a cada incremento do contador (default 1 segundo) 
Local lNumPar 		:= .F.			//Valida o n�mero de parametros que a fun��o executada deve ter
Local lExecJob		:= .F.			//Indica que a execu��o ser� feita via Job
Local cEmpAtual		:= cEmpAnt	//Grupo que est� logado para comparar se � o mesmo grupo da requisi��o 
Local lRdMakeExtBH  := .F.
Local cRdMakeRot19  := ""

Default cRotina 	:= ""
Default aParams		:= {}
Default cEmpToReq	:= cEmpAnt

	lExecJob := !(cEmpToReq == cEmpAtual) //Define a execu��o via Job quando a requisi��o � para outro grupo

	DO CASE 
		Case cRotina == "1" //Retorna os periodos de apontamento

			//Valida a quantidade de parametros esperados pela rotina => GetPeriodApont
			lNumPar := Len(aParams) >= 3

			//Variavel para tratar novos parametros acionados na rotina
			cNewPar01 := If( Len(aParams) > 3, aParams[4], cNewPar01 )

			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_PERAPO_" + AllTrim( Str(ThreadID()) )
				
				//Atribui a variavel de controle				
				PutGlbValue(cUID,"0")
				
				//Define a cria��o e o retorno do Job				
				uRet := StartJob( "GetPeriodApont", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], cNewPar01, cEmpToReq, .T., cUID )
			Else
				uRet := GetPeriodApont(aParams[1], aParams[2], aParams[3], cNewPar01 )
			EndIf

		Case cRotina == "2" //Realiza a reprovacao de uma batida que foi incluida por geolocalizao

			//Valida a quantidade de parametros esperados pela rotina => fUpdGeoClock
			lNumPar := Len(aParams) == 4

			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHU_GEOUPD_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a cria��o e o retorno do Job
				uRet := StartJob( "fUpdGeoClock", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], cEmpToReq, .T., cUID )
			Else
				uRet := fUpdGeoClock( aParams[1], aParams[2], aParams[3], aParams[4] )
			EndIf

		Case cRotina == "3" //Retorna as marca��es do funcionario

			lNumPar := Len(aParams) == 5

			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_GETCLOCK_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a cria��o e o retorno do Job
				uRet := StartJob( "getClockings", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], cEmpToReq, .T., cUID )
			EndIf

		Case cRotina == "4" //Retorna os saldos de horas do per�odo do colaborador

			lNumPar := Len(aParams) == 5

			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_GETBALANCE_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a cria��o e o retorno do Job
				uRet := StartJob( "fMyBalance", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], cEmpToReq, .T., cUID )
			Else
				uRet := fMyBalance(aParams[1], aParams[2], aParams[3], aParams[4], aParams[5])
			EndIf

		Case cRotina == "5" //Retorna o arquivo do espelho de ponto

			lNumPar := Len(aParams) == 7

			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_FILECLOCK_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a cria��o e o retorno do Job
				uRet := StartJob( "FileClocking", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], aParams[6], aParams[7], .T., cUID )
			EndIf

		Case cRotina == "6" //Inclus�o de batidas do ponto eletronico (POST)

			lNumPar := Len(aParams) == 5

			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHPO_CLOCKING_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a cria��o e o retorno do Job
				uRet := StartJob( "fSetClocking", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], cEmpToReq, .T., cUID )
			EndIf

		Case cRotina == "7" //Altera��o de batidas do ponto eletronico (PUT)

			lNumPar := Len(aParams) == 6

			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHPU_CLOCKING_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a cria��o e o retorno do Job
				uRet := StartJob( "fEditClocking", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], aParams[6], cEmpToReq, .T., cUID )
			EndIf
		Case cRotina == "8" //Retorna o arquivo do informe de rendimentos

			lNumPar := Len(aParams) == 6

			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_FIRPF_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a cria��o e o retorno do Job
				uRet := StartJob( "fGetFileAnnualRec", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], aParams[6], cEmpToReq, .T., cUID )
			EndIf
		Case cRotina == "9" //Retorna o Join do campo Filial de duas tabelas para uso em queryes 

			lNumPar := Len(aParams) == 4

			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_FWJOIN_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a cria��o e o retorno do Job
				uRet := StartJob( "getJoinFilial", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], .T., cUID )
			Else
				uRet := getJoinFilial(aParams[1], aParams[2], aParams[3])
			EndIf
		Case cRotina == "10" // Retorna os processos da tabela RCJ
			lNumPar := Len(aParams) >= 3
			
			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_PROCESS_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a cria��o e o retorno do Job
				uRet := StartJob( "fProcess", GetEnvServer(), .T., aParams, .T., cUID )
			EndIf
		Case cRotina == "11" // Retorna os centros de custo
			lNumPar := Len(aParams) >= 3
			
			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_COSTCENTER_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a cria��o e o retorno do Job
				uRet := StartJob( "fCostCenter", GetEnvServer(), .T., aParams, .T., cUID )
			EndIf
		Case cRotina == "12" // Retorna os departamentos.
			lNumPar := Len(aParams) >= 5
			
			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_DEPTOS_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a cria��o e o retorno do Job
				uRet := StartJob( "fGetDepto", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], .T., cUID )
			EndIf
		Case cRotina == "13" //Retorna os motivos de inclus�o de batida de ponto. 

			lNumPar := Len(aParams) == 3

			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_TYPECLOCK_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a cria��o e o retorno do Job
				uRet := StartJob( "fGetClockType", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], .T., cUID )
			Else
				uRet := fGetClockType(aParams[1], aParams[2], aParams[3])
			EndIf
		Case cRotina == "14" //Retorna os motivos de inclus�o de batida de ponto. 

			lNumPar := Len(aParams) == 2

			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_TYPEALLOWANCES_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a cria��o e o retorno do Job
				uRet := StartJob( "GetAllowances", GetEnvServer(), .T., aParams[1], aParams[2], .T., cUID )
			Else
				uRet := GetAllowances(aParams[1], aParams[2])
			EndIf
		Case cRotina == "15" //Retorna objeto com dados do funcion�rio no formato employeesRequisitions.

			lNumPar := Len(aParams) == 3

			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_TRANSFDETAIL_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a cria��o e o retorno do Job
				uRet := StartJob( "fGetReqEmp", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], .T., cUID )
			Else
				uRet := fGetReqEmp(aParams[1], aParams[2], aParams[3])
			EndIf
		Case cRotina == "16" // Ocorr�ncias de f�rias/afastamentos/feriados no espelho de ponto do funcion�rio.
			lNumPar := Len(aParams) >= 4
			
			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_OCCASIONALDAYS_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a cria��o e o retorno do Job
				uRet := StartJob( "fMontaOcc", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], cEmpToReq, .T., cUID )
			EndIf
		Case cRotina == "17" // Fun��es
			lNumPar := Len(aParams) >= 5
			
			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_JOBFUNC_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a cria��o e o retorno do Job
				uRet := StartJob( "fJobFunc", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], .T., cUID )
			Else
				uRet := fJobFunc(aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], .F., NIL)
			EndIf
		Case cRotina == "18" // Cargos
			lNumPar := Len(aParams) >= 5
			
			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_JOBROLES_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				//Define a cria��o e o retorno do Job
				uRet := StartJob( "fJobRoles", GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], .T., cUID )
			Else
				uRet := fJobRoles(aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], .F., NIL)
			EndIf
		Case cRotina == "19" // Extrato do banco de horas
			lNumPar := Len(aParams) == 5
			lRdMakeExtBH := ExistBlock("fExtBHoras")
			If lExecJob .And. lNumPar
				//Define o nome da variavel de controle
				cUID := "MRHG_EXTRACT_BH_" + AllTrim( Str(ThreadID()) )

				//Atribui a variavel de controle
				PutGlbValue(cUID,"0")

				// Define se vai chamar o RDMAKE.
				cRdMakeRot19 :=  If(lRdMakeExtBH, "U_fExtBHoras", "fMrhExtBh")

				//Define a cria��o e o retorno do Job
				uRet := StartJob( cRdMakeRot19, GetEnvServer(), .T., aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], .T., cUID )
			Else
				uRet := If(lRdMakeExtBH, U_fExtBHoras(aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], .F., NIL), fMrhExtBh(aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], .F., NIL)) 
			EndIf	
	ENDCASE

	//Aguarda a finalizacao do JOB no m�ximo por 10 segundos antes de sair da rotina
	While lExecJob
		//Obtem o valor da variavel global
		If GetGlbValue(cUID) == "1"
			Exit
		Else 
			nCount ++
			Sleep(nTime)
		EndIf
		lExecJob := (nCount < 10)
	EndDo

	//Limpa a variavel global da memoria
	If !Empty(cUID)
		ClearGlbValue(cUID)
	EndIf

Return( uRet )

