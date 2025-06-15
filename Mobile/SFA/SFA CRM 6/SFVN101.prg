#INCLUDE "SFVN101.ch"
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � LoadRota            �Autor - Paulo Lima   � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Carrega Clientes na Rota						 			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aRota: Array das Rotas, aRoteiro: Array dos Roteiros		  ���
���			 � aCLientes: Array a clientes								  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Analista    � Data   �Motivo da Alteracao                              ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function LoadRota(aRota,aRoteiro,nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus,ntop,nRows)
Local cStr, cCliente, i
LOcal cTitulos := ""

if Len(aRota) == 0 
    aSize(aClientes,0)
	SetArray(oCliente,aClientes)
	Return Nil
Endif

dbSelectArea("HRT")
dbSetOrder(1)
dbSeek(aRota[1,1] + aRota[2,1])
if !(HRT->(Found()))
   	aSize(aClientes,0)
	SetArray(oCliente,aClientes)
	Return Nil
Endif	

HCF->(dbSetOrder(1))
If HCF->(dbSeek("MV_SFTPTIT"))
	//Tipos de titulos que nao devem ser considerados os venctos.
	cTitulos := AllTrim(HCF->CF_VALOR)
Endif

dbSelectArea("HD7")
dbSetOrder(1)
If !dbSeek(HRT->RT_PERCUR + HRT->RT_ROTA)
	MsgStop(STR0001 + HRT->RT_ROTA) //"N�o foram encontrados clientes para a rota "
  	aSize(aClientes,0)
	SetArray(oCliente,aClientes)
	Return Nil
Endif	

If Len(aClientes)==0
   	nTop := Recno()
Else
   aSize(aClientes,0)
   aSize(aRoteiro,0)
   dbGoTo(nTop)
Endif   

i:=1
While i <= nRows .And. !HD7->(Eof())
	If HD7->AD7_PERCUR == HRT->RT_PERCUR .And. HD7->AD7_ROTA == HRT->RT_ROTA
		cCliente := HD7->AD7_CLI + HD7->AD7_LOJA
		HA1->(dbSetOrder(1))
		
		If !HA1->(dbSeek(cCliente))
			dbSelectArea("HD7")
			dbSkip()
			Loop
		EndIf

		If AllTrim(HD7->AD7_FLGVIS) == "1"
			cStr := "POSI"
		Elseif AllTrim(HD7->AD7_FLGVIS) == "2"
			cStr := "NPOS"
		Else
			cStr := "NVIS"
		Endif

		AADD(aClientes,{cStr,HA1->A1_NOME,HA1->A1_COD,HA1->A1_LOJA})
		AADD(aRoteiro,{HD7->AD7_PERCUR, HD7->AD7_ROTA,HD7->AD7_ORDEM})
     
		If RetStatus(HA1->A1_COD, HA1->A1_LOJA,, cTitulos) > 0
			GridSetCellColor(oCliente, Len(aClientes),1,CLR_HRED, CLR_WHITE)
			GridSetCellColor(oCliente, Len(aClientes),2,CLR_HRED, CLR_WHITE)
		Else
			GridSetCellColor(oCliente, Len(aClientes),1,CLR_WHITE, CLR_BLACK)
			GridSetCellColor(oCliente, Len(aClientes),2,CLR_WHITE, CLR_BLACK)
		EndIf 	     
		i++
	Endif
	dbSelectArea("HD7")
	dbSkip()	
Enddo
SetArray(oCliente,aClientes)
ChangeClient(@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus)
Return nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � SelectCliente       �Autor - Paulo Lima   � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Monta array com clientes de acordo com a Rota selecionada  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aRoteiro: Array dos Roteiros, aCLientes: Array a clientes  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
-���Analista    � Data   �Motivo da Alteracao                              ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function SelectCliente(aClientes,aRoteiro,nTop,lDown,oCliente,nRows)
Local cStr, i
Local cTitulos := ""

dbSelectArea("HA1")
dbSetOrder(2)
if Len(aClientes) > 0 
   dbGoTo(nTop)
else
   dbGoTop()
   nTop	:=HA1->(RecNo())
endif

HCF->(dbSetOrder(1))
If HCF->(dbSeek("MV_SFTPTIT"))
	//Tipos de titulos que nao devem ser considerados os venctos.
	cTitulos := AllTrim(HCF->CF_VALOR)
Endif

Asize(aClientes,0)
Asize(aRoteiro,0)

For i := 1 to nRows

  if HA1->A1_FLGVIS == "1"
    cStr := "POSI"
  elseif HA1->A1_FLGVIS == "2"
    cStr := "NPOS"
  else
    cStr := "NVIS"
  endif
//  cStr += "|"
//  cStr += HA1->A1_NOME

//  AADD(aClientes,cstr)
  AADD(aClientes,{cStr,HA1->A1_NOME,HA1->A1_COD,HA1->A1_LOJA})
  If RetStatus(HA1->A1_COD, HA1->A1_LOJA,, cTitulos) > 0
  	GridSetCellColor(oCliente, Len(aClientes),1,CLR_HRED, CLR_WHITE)
  	GridSetCellColor(oCliente, Len(aClientes),2,CLR_HRED, CLR_WHITE)
  Else
  	GridSetCellColor(oCliente, Len(aClientes),1, CLR_WHITE, CLR_BLACK)
  	GridSetCellColor(oCliente, Len(aClientes),2, CLR_WHITE, CLR_BLACK)
  EndIf
  HA1->(dbSkip())
  if HA1->(Eof())
     break
  endif
Next

if (oCliente != nil)
  SetArray(oCliente, aClientes)
endif

Return nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � ClientDown          �Autor - Paulo Lima   � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � PageDown no ListBox de Clientes							  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aRota: Array das Rotas, aRoteiro: Array dos Roteiros		  ���
���			 � aCLientes: Array a clientes								  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Analista    � Data   �Motivo da Alteracao                              ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function ClientDown(nShow, oRota, oDia, oPesquisar, nCliente,oCliente, aClientes, aRota, aRoteiro, oCod,oEnd,oCGC,oLoja,oTel,oStatus,nTop,nRows)
Local nRec := HA1->(Recno()), i, nOldTop := nTop, bLoad := .t.
if Len(aClientes) == 0
	Return Nil
Endif

if nShow == 1
   dbSelectArea("HA1")
   dbSetOrder(2)
   dbGoTo(nTop)
   dbSkip(nRows)
   if !Eof()
      nTop := HA1->(Recno())
      SelectCliente(aClientes,aRoteiro,@nTop,.t.,oCliente,nRows)
      ChangeClient(@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus)
   else
     HA1->(dbGoTo(nRec))
   endif
else
	 
//   HRT->(dbSetOrder(2))
//   HRT->(dbSeek(aRota[nDia]))
	HRT->(dbSetOrder(1))
	HRT->(dbSeek(aRota[1,1] + aRota[2,1]))
 	dbSelectArea("HD7")
	dbSetOrder(1)
 	dbGoTo(nTop)

	for i := 1 to nRows
    	dbSelectArea("HD7")
      	dbSkip()
      	if !Eof() .AND. HD7->AD7_PERCUR == HRT->RT_PERCUR .And. HD7->AD7_ROTA == HRT->RT_ROTA
        	nTop := HD7->(Recno())
      	else
        	nTop := nOldTop
         	bLoad := .f.
        	break
      	endif
	next
   	if (bLoad)
//      aSize(aClientes,0)
//      aSize(aRoteiro,0)
		LoadRota(aRota,aRoteiro,@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus,@ntop,nRows)
	endif
endif

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � ClientUp            �Autor - Paulo Lima   � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � PageUp no ListBox de Clientes							  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aRota: Array das Rotas, aRoteiro: Array dos Roteiros		  ���
���			 � aCLientes: Array a clientes								  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Analista    � Data   �Motivo da Alteracao                              ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function ClientUp(nShow, oRota, oDia, oPesquisar, nCliente,oCliente, aClientes, aRota, aRoteiro, oCod,oEnd,oCGC,oLoja,oTel,oStatus,nTop,nRows)
Local nRec := HA1->(Recno()),i, nOldTop := nTop, bLoad := .t.

if Len(aClientes) == 0
	Return Nil
Endif

if nShow == 1
   HA1->(dbSetOrder(2))
   HA1->(dbGoTop())
   //if HA1->(Recno()) == nTop
   if HA1->(Bof())
      return
   endif
   HA1->(dbGoTo(nTop))
   HA1->(dbSkip(nRows*-1))
   nTop := HA1->(Recno())
   SelectCliente(aClientes,aRoteiro,@nTop,.f.,oCliente,nRows)
   ChangeClient(@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus)
else

//   HRT->(dbSetOrder(2))
//   HRT->(dbSeek(aRota[nDia]))
	HRT->(dbSetOrder(1))
	HRT->(dbSeek(aRota[1,1] + aRota[2,1]))

  HD7->(dbGoTo(nTop))
   for i := 1 to nRows
      HD7->(dbSkip(-1))
      if !HD7->(Bof()) .AND. HD7->AD7_PERCUR == HRT->RT_PERCUR .And. HD7->AD7_ROTA == HRT->RT_ROTA
         nTop := HD7->(Recno())
      else
         nTop := nOldTop
         bLoad := .f.
         break
      endif
   next
   if (bLoad)
//      aSize(aClientes,0)
//      aSize(aRoteiro,0)
	  LoadRota(aRota,aRoteiro,@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus,@ntop,nRows)
   endif
endif

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � FindCustomer        �Autor - Paulo Lima   � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Busca por um determinado Cliente							  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aRota: Array das Rotas, aRoteiro: Array dos Roteiros		  ���
���			 � aCLientes: Array a clientes, cPesqName:conteudo da pesquisa���
���			 � nPesqOrd: Ordem da pesquisa 								  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Analista    � Data   �Motivo da Alteracao                              ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function FindCustomer(oPesqName,cPesqName,nPesqOrd,oRota, oDia, oPesquisar, nCliente,oCliente, aClientes,aRoteiro, aRota, oCod,oEnd,oCGC,oLoja,oTel,oStatus,nTop,nRows)

cPesqName	:= Upper(cPesqName)
SetText(oPesqName,cPesqName)

HA1->(dbSetOrder(nPesqOrd))
HA1->(dbSeek(AllTrim(cPesqName)))
if HA1->(Found())
   nTop := HA1->(Recno())
   SelectCliente(aClientes,aRoteiro,@nTop,.f.,oCliente,nRows)
   ChangeClient(@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus)
else
   Alert(STR0002) //"Cliente n�o localizado!"
endif

Return nil


/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � ZerarVisCli         �Autor - Paulo Lima   � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Zera visitas de cliente 									  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Analista    � Data   �Motivo da Alteracao                              ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function ZerarVisCli()
Local cResp	:=""
cResp:=if(MsgYesOrNo(STR0003,STR0004),STR0005,STR0006) //"Voc� realmente deseja Zerar as Visitas dos Clientes?"###"Cancelar"###"Sim"###"N�o"
if cResp=STR0006 //"N�o"
	Return Nil
endif      
MsgStatus(STR0007) //"Zerando Visitas do Cliente..."
dbSelectArea("HA1")
dbSetOrder(1)
dbGoTop()
While !Eof()
	HA1->A1_FLGVIS	:= ""
	HA1->A1_OCO		:= ""
	dbCommit()
	dbSkip()
Enddo 
ClearStatus()
Return Nil
