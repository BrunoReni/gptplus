#INCLUDE "PPJSLANGUAGE.CH"     
#include "protheus.ch"
#Include "FILEIO.ch"  
#INCLUDE "APWEBEX.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  PPJSLANGUAGE  Autor� Cesar Augusto Bianchi � Data � 25/09/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Traducao das sentencas utilizadas nos arquivos .JS do Portal���
���          �Protheus WEB.                                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void                                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Portal Protheus                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MakeJsLang�Autor  �Cesar A. Bianchi    � Data �  25/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica a existencia do arquivo .JS que contem as sentencas���
���          �do portal Protheus. Se ja existe entao apaga e recria.      ���
�������������������������������������������������������������������������͹��
���Uso       � Portal Protheus WEB                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function CriaJsLang() 
Local lRet := .F.
Local cNameJs		:= "PPLanguage.js"
Local cTexto		:= ""
Local nHdl			:= 1
Local cPulaLin		:= chr(13) + chr(10)
Local aStr			:= GetStrPP()
Local nX			:= 0
Local cEnv     		:= GetEnvServer()
Local cPathWebPP	:= ""
Local cRootPath		:= ""
Private cMyWebJOB	:= GetWebJob()
Private cIniFile 	:= GetAdv97()

//�����������������������������������������������Ŀ
//�Busca o RootPath do Protheus e dos arquivos WEB�
//�������������������������������������������������
cPathWebPP	:= GetPathPP()
cRootPath   := alltrim(GetPvProfString( cEnv , "RootPath", '', cIniFile ))

if !Empty(cPathWebPP)
	
	//�����������������������������������������������������Ŀ
	//�Remove o caminho inicial "RootPath" da string PathWeb�
	//�������������������������������������������������������
	cPathWebPP := StrTran(Upper(cPathWebPP), Upper(cRootPath),"")
	
	//��������������������������������������������������
	//�Verifica se possui a barra no final do cPahWebPP�
	//��������������������������������������������������
	if substr(cPathWebPP,len(cPathWebPP),1) != "\"
		cPathWebPP += "\"	
	endif
	
	//���������������������������Ŀ
	//�Apaga o atual PPLanguage.js�
	//�����������������������������
	if File(cPathWebPP+cNameJs)
		if FErase(cPathWebPP+cNameJs) < 0
			//FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0021 , 0, 0, {}) //'Erro durante substitui��o do arquivo PPLanguage.js. Processo abortado.'
			Return
		endif
	endif

	//����������������������������Ŀ
	//�Cria o arquivo PPLanguage.js�
	//������������������������������
	nHdl := FCreate(cPathWebPP+cNameJs)
	if nHdl < 0
		//FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0021 , 0, 0, {}) //'Erro durante substitui��o do arquivo PPLanguage.js. Processo abortado.'
		Return	
	Else
		//������������������������Ŀ
		//�Grava as novas sentencas�
		//��������������������������
		cTexto := ""
		For nX := 1 to len(aStr)
			cTexto += 'var ' + aStr[nX,1] + ' = "' + aStr[nX,2] + '";' + cPulaLin
		Next nX
	   	FSeek(nHdl,0,1)
		FWrite(nHdl, cTexto, Len(cTexto))
		FClose(nHdl) 
		
		if File(cPathWebPP+cNameJs)
			//FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0022 , 0, 0, {}) //'Criando arquivo de idiomas do Portal... OK'
			lRet := .T.
		endif

	endif	
else
	//FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0023 , 0, 0, {}) //'Erro durante cria��o do arquivo PPLanguage.js. Processo abortado.'
endif

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetPathPP �Autor  �Cesar A. Bianchi    � Data �  25/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o raiz dos arquivos do portal protheus              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Portal Protheus WEB                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function GetPathPP()
Local aIniSessions	:= GetIniSessions(GetADV97())
Local nT			:= 0
Local nX			:= 0
Local nPosSeSession	:= 0
Local cPesqWeb 		:= ""
Local cPathWeb   	:= ""

nPosSeSession:=0
For nT:=1 To Len(aIniSessions)
	cPesqWeb:= GetPvProfString( aIniSessions[nT] , "SIGAWEB", '', cIniFile )
	IF alltrim(Upper(cPesqWeb)) == "PP"
		For nX:=1 To Len(aIniSessions)
			cPesqWeb:= GetPvProfString( aIniSessions[nX] , "RESPONSEJOB", '', cIniFile )
			IF Upper(cPesqWeb)==Upper(cMyWebJOB)
				nPosSeSession:=nX
				Exit
			Endif
		Next nX
	Endif
	IF nPosSeSession<>0
		Exit
	Endif
Next nT

If nPosSeSession > 0
	cPathWeb:= alltrim(GetPvProfString( aIniSessions[nPosSeSession] , "PATH", '(empty)', cIniFile ))
EndIf

Return cPathWeb

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetStrPP  �Autor  �Cesar A. Bianchi    � Data �  25/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna um array com todas as sentencas utilizadas nos arqui���
���          �vos .JS utilizados pelo Portal Protheus WEB                 ���
�������������������������������������������������������������������������͹��
���Uso       � Portal Protheus WEB                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function GetStrPP()
Local aRet := {}

aAdd(aRet,{"STR0001",STR0001})
aAdd(aRet,{"STR0002",STR0002})
aAdd(aRet,{"STR0003",STR0003})
aAdd(aRet,{"STR0004",STR0004})
aAdd(aRet,{"STR0005",STR0005})
aAdd(aRet,{"STR0006",STR0006})
aAdd(aRet,{"STR0007",STR0007})
aAdd(aRet,{"STR0008",STR0008})
aAdd(aRet,{"STR0009",STR0009})
aAdd(aRet,{"STR0010",STR0010})
aAdd(aRet,{"STR0011",STR0011})
aAdd(aRet,{"STR0012",STR0012})
aAdd(aRet,{"STR0013",STR0013})
aAdd(aRet,{"STR0014",STR0014})
aAdd(aRet,{"STR0015",STR0015})
aAdd(aRet,{"STR0016",STR0016})
aAdd(aRet,{"STR0017",STR0017})
aAdd(aRet,{"STR0018",STR0018})
aAdd(aRet,{"STR0019",STR0019})
aAdd(aRet,{"STR0020",STR0020})

Return aRet