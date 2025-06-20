#INCLUDE "ofiia180.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OFIIA180 � Autor �  Renata               � Data � 14/03/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validade da Operacao                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico  (Modelo3)                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
#Include "protheus.ch"
#Include "Fileio.ch"
Function OFIIA180

Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0006)   //) //"Datas de Validade das Operacoes"

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������

dbSelectArea("VH4")
mBrowse(06,01,22,75,"VH4")

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � IA180    � Autor �  Renata               � Data � 10/03/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inclusao, alteracao, visualizacao do VH4/VH5               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico  (Modelo3)                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ia180(cAlias,nReg,nOpc)

Local bCampo  := { |nCPO| Field(nCPO) }
Local nCntFor := 0 , _ni := 0
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk 
Local nPosRec := 0
Private aTELA[0][0],aGETS[0] 
Private aCpoEnchoice  := {} , aCols := {} , aHeader := {}

//��������������������������������������������������������������Ŀ
//� Cria variaveis M->????? da Enchoice                          �
//����������������������������������������������������������������
RegToMemory("VH4",.t.)         // .t. para carregar campos virtuais

if nOpc == 3
   nOpcE := 3
   nOpcG := 3
elseif nOpc == 4
   nOpcE := 4
   nOpcG := 4
elseif nOpc == 2
   nOpcE := 2
   nOpcG := 2
else
   nOpcE := 5
   nOpcG := 5
endif

aCpoEnchoice  :={}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VH4")

While !Eof().and.(x3_arquivo=="VH4")

   if X3USO(x3_usado).and.cNivel>=x3_nivel && .And.!(x3_campo $ [/])
      AADD(aCpoEnchoice,x3_campo)
   Endif
   
   &( "M->"+Alltrim(x3_campo) ) := CriaVar(x3_campo)
   
   dbSkip()

EndDo

If !(Inclui)
   DbSelectArea("VH4")
   For nCntFor := 1 TO FCount()
      M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
   Next
Endif

//��������������������������������������������������������������Ŀ
//� Cria aHeader e aCols da GetDados                             �
//����������������������������������������������������������������
nUsado:=0
dbSelectArea("SX3")
dbSeek("VH5")
aHeader:={}
While !Eof().And.(x3_arquivo=="VH5")
   If X3USO(x3_usado).And.cNivel>=x3_nivel.And.!(x3_campo $ [VH5_CODMAR/VH5_DESMARVH5_CODOPE/])
   
      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )

      &( "M->"+Alltrim(x3_campo) ) := CriaVar(x3_campo)
      
   Endif
   dbSkip()
End

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VH5")
ADHeadRec("VH5",aHeader)
// Posicao do registro
nPosRec:=Len(aHeader)
nUsado :=Len(aHeader)

aCols:={}
DbSelectArea("VH5")
DbSetOrder(1)
DbSeek(xFilial("VH5")+M->VH4_CODMAR+M->VH4_CODOPE)

If nOpc == 3 .Or. !Found()
   aCols:={Array(nUsado+1)}
   aCols[1,nUsado+1]:=.F.
   For _ni:=1 to nUsado
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := 0
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VH5"
		Else	
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
		EndIf	
   Next
Else

   While !eof() .and. M->VH4_CODMAR+M->VH4_CODOPE == VH5->VH5_CODMAR+VH5->VH5_CODOPE .And. VH5->VH5_FILIAL == xFilial("VH5")

       AADD(aCols,Array(nUsado+1))
       For _ni:=1 to nUsado
			If IsHeadRec(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := VH5->(RecNo())
			ElseIf IsHeadAlias(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := "VH5"
			Else
				aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
			EndIf	
       Next
       aCols[Len(aCols),nUsado+1]:=.F.
       dbSkip()

   End
Endif

If Len(aCols)>0
   //��������������������������������������������������������������Ŀ
   //� Executa a Modelo 3                                           �
   //����������������������������������������������������������������
   cTitulo       := cCadastro
   cAliasEnchoice:="VH4"
   cAliasGetD    :="VH5"
   cLinOk        :="FG_OBRIGAT()"
   cTudOk        :="AllwaysTrue()"
   cFieldOk      :="FG_MEMVAR()"

   If !(Inclui)
      DbSelectArea("VH4")
      DbSetOrder(1)
      dbSeek(xFilial("VH4")+M->VH4_CODMAR+M->VH4_CODOPE)
   Endif

   DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 28,80	of oMainWnd   
   EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{15,1,70,315},,3,,,,,,.F.)
   oGetDados := MsGetDados():New(75,1,143,315,nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,,cFieldOk)
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(oGetDados:TudoOk().And.obrigatorio(aGets,aTela).And.FS_GRVALOPE( nOpc ),oDlg:End(),.f.) },{|| oDlg:End() })

Endif

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GRVALOP�Autor  �Fabio               � Data �  08/15/00   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Integracao                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GRVALOPE( nOpc )

Local lRet := .t. , I := 1
Private lMsHelpAuto := .t.

//��������������������������������������������������������������Ŀ
//� Executar processamento                                       �
//����������������������������������������������������������������
If nOpc # 2

   Begin Transaction

      DbSelectArea("VH4")
      DbSetOrder(1)
      DbSeek(xFilial("VH4")+M->VH4_CODMAR+M->VH4_CODOPE)

      If nOpc == 3 .Or. nOpc == 4

         If !RecLock("VH4" , !Found() )
            Help("  ",1,"REGNLOCK")
            lRet := .f.
            DisarmTransaction()
            Break               
         EndIf
         
         FG_GRAVAR("VH4")

         MsUnlock()

      EndIf

      For i:=1 to Len(aCols)

         DbSelectArea("VH5")
         DbSetOrder(1)
         DbSeek(xFilial("VH5")+M->VH4_CODMAR+M->VH4_CODOPE+aCols[I,FG_POSVAR("VH5_CODPAR")]+dtos(aCols[I,FG_POSVAR("VH5_DATVAL")]))

         If ( nOpc == 3 .Or. nOpc == 4 ) .And. !aCols[i,len(aCols[i])]

            If !RecLock("VH5", !Found() )
               Help("  ",1,"REGNLOCK")
               lRet := .f.
               DisarmTransaction()
               Break               
            EndIf
            
            FG_GRAVAR("VH5",aCols,aHeader,i)
            VH5->VH5_FILIAL := xFilial("VH5")
            VH5->VH5_CODMAR := M->VH4_CODMAR
            VH5->VH5_CODOPE := M->VH4_CODOPE
            VH5->VH5_CODPAR := aCols[I,FG_POSVAR("VH5_CODPAR")]
            VH5->VH5_DATVAL := aCols[I,FG_POSVAR("VH5_DATVAL")]
            MsUnlock()

         ElseIf Found()

            If !RecLock("VH5",.F.,.T.)
               Help("  ",1,"REGNLOCK")
               lRet := .f.
               DisarmTransaction()
               Break               
            EndIf
            
            dbdelete()
            MsUnlock()
            WriteSx2("VH5")

         EndIf

      Next

      DbSelectArea("VH4")
      
      If nOpc == 5 .And. Found() 
           
         If !RecLock("VH4",.F.,.T.)
            Help("  ",1,"REGNLOCK")
            lRet := .f.
            DisarmTransaction()
            Break               
         EndIf
               
         dbdelete()
         MsUnlock()
         WriteSx2("VH4")
      
      EndIf

   End Transaction

EndIf            

If !lRet
   MostraErro()
EndIf

Return(lRet)

Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui", 0 , 1},; //PESQUISAR
                     { STR0002 ,"ia180", 0 , 2},;  //VISUALIZAR 
                     { STR0003 ,"ia180", 0 , 3},;  //INCLUIR 
                     { STR0004 ,"ia180", 0 , 4},;  //ALTERAR
                     { STR0005 ,"ia180", 0 , 5}}   //Excluir 
Return aRotina
