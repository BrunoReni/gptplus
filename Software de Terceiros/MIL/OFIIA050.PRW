// 浜様様様曜様様様様�
// � Versao � 8      �
// 藩様様様擁様様様様�
#Include "OFIIA050.ch"
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � OFIIA050 � Autor �  Renata               � Data � 08/05/00 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Exportacao pedido p/o arquivo de integracao VI5\VIB        咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe   �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Integracao montadora                                       咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/


FUNCTION OFIIA050(cPreMar,cCodPed,nOpcx)

LOCAL cChave, cCond
PRIVATE aCampos := {}
PRIVATE aRotina := MenuDef()
//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Define o cabecalho da tela de atualizacoes                   �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
PRIVATE cCadastro := OemToAnsi(STR0001)   //"Exportacao dos Dados do Pedido
Private lAuto := .f.

nOpcx := If( nOpcx # NIL, nOpcx, 3 )

If cPreMar # NIL .Or. cCodPed # NIL
	lAuto := .t.
EndIf

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Endereca a funcao de BROWSE                                  �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰

dbSelectArea("SC7")
dbSetOrder(1)

private cCodMar := ""
private cPedFab := ""
        
If lAuto

	Pergunte("VIA050",.f.) 
	
	cCodMar := MV_PAR01 := cPreMar
	cPedFab := MV_PAR02 := cCodPed

Else

	If !Pergunte("VIA050",.t.) 
	   Return
	EndIf
	
	cCodMar := MV_PAR01
	cPedFab := MV_PAR02

EndIf

FG_SEEK("VEI","MV_PAR01+cPedFab",2,.F.)
private cPedInt := VEI->VEI_NUM

dbSelectArea("SC7")
cIndex  := CriaTrab(nil,.f.)
cChave  := IndexKey()
cCond   := "SC7->C7_NUM == '"+cPedInt+"'"

If GetMv("MV_RESTPED") == "S"
	cCond += ".And. SC7->C7_CONAPRO == 'L'"
EndIf

IndRegua("SC7",cIndex,cChave,,cCond,STR0005)                       

DbSelectArea("SC7")
nIndex := RetIndex("SC7")
#IFNDEF TOP
   dbSetIndex(cIndex+ordBagExt())
#ENDIF
dbSetOrder(nIndex+1)

If lAuto

	If nOpcx == 2
		IA050V(Alias(),SC7->(Recno()),nOpcx)
	ElseIf nOpcx == 3
		IA050E(Alias(),SC7->(Recno()),nOpcx)
	EndIf	
   
Else

	mBrowse( 6, 1,22,75,"SC7")

EndIf

dbSelectArea("SC7")
dbclearfilter()
RetIndex()
DbsetOrder(1)  
#IFNDEF TOP
   If File(cIndex+OrdBagExt())
      fErase(cIndex+OrdBagExt())
   Endif
#ENDIF

Return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �IA050E    � Autor �Renata                 � Data � 20/07/00 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Chama a funcao de gravacao de integracao de pedido da mon  咳�
臼�          � tadora                                                     咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e �IA050E(CLIAS,NREG,NOPC)                                     咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � PECAS                                                      咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/

Function IA050E(cAlias,nReg,nOpc)

Processa({|| FS_INTVI5B()}) 

return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �FS_INTVI5B� Autor �Renata                 � Data � 20/07/00 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Gravacao dos dados do arquivo SC7  nos arquivos de integra 咳�
臼�          � cao VI5/VIB                                                咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � IA050E(cAlias,nREg,nOpc)                                   咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � Integracao montadora                                       咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
FUNCTION FS_INTVI5B
***************
local nRegC7 := 0
Private cRecInt := ""

Begin Transaction

FG_SEEK("VEI","cCodMar+cPedInt",1,.F.)
             
If !EMPTY(VEI->VEI_DATAVI)

	DbSelectArea("VI5")
	DbSetOrder(1)
	DbSeek( xFilial("VI5") + cCodMar + cPedFab )
	
	Do While !Eof() .And. VI5->VI5_FILIAL + VI5->VI5_CODMAR + VI5->VI5_CODPED == xFilial("VI5") + cCodMar + cPedFab

      RecLock("VI5",.F.,.T.)
      dbdelete()
      MsUnlock()
      WriteSx2("VI5")
	
		DbSelectArea("VI5")
		DbSkip()

	EndDo 
	
	DbSelectArea("VIB")
	DbSetOrder(1)
	DbSeek( xFilial("VIB") + cCodMar + cPedFab )
	
	Do While !Eof() .And. VIB->VIB_FILIAL + VIB->VIB_CODMAR + VIB->VIB_CODPED == xFilial("VIB") + cCodMar + cPedFab

      RecLock("VIB",.F.,.T.)
      dbdelete()
      MsUnlock()
      WriteSx2("VIB")
	
		DbSelectArea("VIB")
		DbSkip()

	EndDo 
	
	DbSelectArea("VEI")	
	RecLock("VEI",.f.)                     
	VEI->VEI_DATAVI := ctod("  /  /  ")
	VEI->VEI_HORAVI := 0
	MsUnLock()

EndIf

FG_SEEK("VE4","cCodmar",1,.F.)              
cCodCon := VE4->VE4_CODCON

FG_SEEK("VV1","VEI->VEI_CHAINT",1,.F.)              
cChassi := VV1->VV1_CHASSI

dbselectArea("VI5")
dbsetorder(1)
lProcura:=dbseek(xFilial("VI5")+cCodMar+cPedFab)
                    
dbselectArea("VI5")               
RecLock("VI5",If(lProcura,.F.,.T.))

VI5->VI5_FILIAL := xFilial("VI5")
VI5->VI5_CODMAR := cCodMar
VI5->VI5_TIPREG := "PED"
VI5->VI5_CODPED := cPedFab
VI5->VI5_CODCON := cCodCon
VI5->VI5_TIPPED := VEI->VEI_TIPPED
VI5->VI5_VIATRA := VEI->VEI_VIATRA
VI5->VI5_TRANSP := VEI->VEI_TRANSP
VI5->VI5_NUMOSV := VEI->VEI_NUMOSV
VI5->VI5_CHASSI := cCHASSI
VI5->VI5_PGT48H := VEI->VEI_PGT48H

MsUnlock()

cRecInt += StrZero(VI5->(Recno()),10)+"/"

ntotite := 0

dbselectArea("SC7")
nRegC7 := recno()
dbgotop()

private nCont := reccount()

ProcRegua(nCont) 

SC7->(DbGoTo(nRegC7))

do while !eof() .and. SC7->C7_FILIAL+SC7->C7_NUM == xFilial()+cPedInt
                  
   FG_SEEK("SB1","SC7->C7_PRODUTO",1,.F.)

   cCodIte := SB1->B1_CODITE

   dbselectArea("VIB")
   dbgotop()
   dbsetorder(1)
   lProcura:=dbseek(xFilial("VIB")+cCODMAR+cPedFab+cCodIte)

   dbselectArea("VIB")
   RecLock("VIB",If(lProcura,.F.,.T.))
   VIB->VIB_FILIAL := SC7->C7_FILIAL
   VIB->VIB_CODMAR := cCodMar
   VIB->VIB_CODPED := cPedFab
   VIB->VIB_CODITE := cCodite
   VIB->VIB_QTDADE := SC7->C7_QUANT
   VIB->VIB_TIPPED := VEI->VEI_TIPPED   
   VIB->VIB_PENDEN := SC7->C7_PENDEN
   MsUnlock()
   
   ntotite++

   IncProc(OemtoAnsi(STR0007))   
   
   dbselectArea("SC7")
   dbskip()        
  
enddo

dbselectArea("VI5")
RecLock("VI5",.F.)
VI5->VI5_TOTITE := ntotite
MsUnlock() 

FS_VEI()  //GRAVA VEI_DATAVI/VEI_HORAVI

End Transaction

If !Empty(cRecInt)
//   OFIIA200(2,cCodMar,GetNewPar("MV_IIA050","003"),"StrZero(VI5->(Recno()),10) $ cRecInt",,,,.t.)
Else	
   MSGSTOP(STR0011) //"Processo de exportacao concluido")
EndIf	

Return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �IA050V    � Autor �Renata                 � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � visualiza os dados dos arquivos SC7                        咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � AxVisual(cAlias,nReg,nOpc,aCampos)                         咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � Generico                                                   咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function IA050V(cAlias,nReg,nOpc)

CPOIA050()
AxVisual(cAlias,nReg,nOpc,aCampos)

return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �CPOIA050  � Autor �Renata                 � Data � 01/06/00 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o �Pega os campos no SX3 para serem mostrados na visualizacao  咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � CPOIA050()                                                 咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � integracao                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function CPOIA050()

DbSelectArea("SX3")
dbgotop()
dbseek("SC7")
aCampos := {}

do While !eof() .and. x3_arquivo == "SC7"
   if X3USO(x3_usado) .And. cNivel>=x3_nivel       
      aadd(aCampos,x3_campo)
   endif
   dbskip()
Enddo

DbSelectArea("SC7")

Return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �FS_CODPED � Autor �Renata                 � Data � 19/07/00 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o �Faz a validacao do codigo do pedido digiatado na pergunte   咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � FS_CODPED                                                  咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � integracao                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
FUNCTION FS_CODPED()
****************

local lNroPed := .f.      
private cPed := ""

FG_SEEK("VE4","MV_PAR01",1,.f.)

if VE4->VE4_PEDINI > 0    
   lNroPed = .t.
endif

if lNroPed=.t.
    cPed := strzero(val(MV_PAR02),13)
else
    cPed := space(13-len(alltrim(MV_PAR02)))+alltrim(MV_PAR02)
endif
cPed  := Mv_Par02
cPedFab := cPed

if FG_SEEK("VEI","MV_PAR01+cPed",2,.F.) = .f.
   AVISO(OemtoAnsi(STR0008),OemtoAnsi(STR0009),{OemtoAnsi(STR0010)})
   return(.f.)
Endif       

Return(.t.)   

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �FS_VEI    � Autor �Renata                 � Data � 19/07/00 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o �Grava os campos de vei_datavi e vei_horavi                  咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � FS_VEI                                                     咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � integracao                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
FUNCTION FS_VEI()

FG_SEEK("VEI","cCodMar+cPedFab",2,.f.)
RECLOCK("VEI",.f.)                     
VEI->VEI_DATAVI := ddatabase
VEI->VEI_HORAVI := Val(Substr(Time(),1,2)+Substr(Time(),4,2))
MSUNLOCK()

return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �MenuDef   � Autor �Renata                 � Data � 19/07/00 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o �Criacao do menu.							                  咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function MenuDef()
Local aRotina := { { STR0002 ,"axPesqui", 0 , 1},;
                     { STR0003 ,"IA050V", 0 , 2},;     //VIZUALIZAR
                     { STR0004 ,"IA050E", 0 , 3}}      //EXPORTAR
Return aRotina
