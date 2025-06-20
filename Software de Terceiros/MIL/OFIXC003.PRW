// 浜様様様曜様様様様�
// � Versao � 07     �
// 藩様様様擁様様様様�
 
#Include "PROTHEUS.CH"
#Include "OFIXC003.CH"

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  � OFIXC003 � Autor � Andre Luis Almeida � Data �  26/07/12   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Descricao � Visualiza (F)Fotos / (V)Videos do Produto, por:            艮�
臼�          �                                                            艮�
臼�          � >> B1_COD                                                  艮�
臼�          �  (F) MV_DIRFTGC + "PB1COD" + B1_COD + "_*.PNG"             艮�
臼�          �  (F) MV_DIRFTGC + "PB1COD" + B1_COD + "_*.JPG"             艮�
臼�          �  (V) MV_DIRFTGC + "PB1COD" + B1_COD + "_*.MP4"             艮�
臼�          �  (V) MV_DIRFTGC + "PB1COD" + B1_COD + "_*.WMV"             艮�
臼�          �  (V) MV_DIRFTGC + "PB1COD" + B1_COD + "_*.AVI"             艮�
臼�          �                                                            艮�
臼�          � >> B1_GRUPO + B1_CODITE                                    艮�
臼�          �  (F) MV_DIRFTGC + "P" + B1_GRUPO + B1_CODITE + "_*.PNG"    艮�
臼�          �  (F) MV_DIRFTGC + "P" + B1_GRUPO + B1_CODITE + "_*.JPG"    艮�
臼�          �  (V) MV_DIRFTGC + "P" + B1_GRUPO + B1_CODITE + "_*.MP4"    艮�
臼�          �  (V) MV_DIRFTGC + "P" + B1_GRUPO + B1_CODITE + "_*.WMV"    艮�
臼�          �  (V) MV_DIRFTGC + "P" + B1_GRUPO + B1_CODITE + "_*.AVI"    艮�
臼�          �                                                            艮�
臼�          � >> B1_GRUPO                                                艮�
臼�          �  (F) MV_DIRFTGC + "P" + B1_GRUPO + "_*.PNG"                艮�
臼�          �  (F) MV_DIRFTGC + "P" + B1_GRUPO + "_*.JPG"                艮�
臼�          �  (V) MV_DIRFTGC + "P" + B1_GRUPO + "_*.MP4"                艮�
臼�          �  (V) MV_DIRFTGC + "P" + B1_GRUPO + "_*.WMV"                艮�
臼�          �  (V) MV_DIRFTGC + "P" + B1_GRUPO + "_*.AVI"                艮�
臼�          �                                                            艮�
臼麺様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�  TAMANHO PADRAO DAS FOTOS  -->  560pix (largura)  x  530pix (altura)  艮�
臼麺様様様様用様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Parametros� cB1_COD = B1_COD - Codigo Interno da Peca/Produto          艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Auto-Pecas / Oficina                                       艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFIXC003(cB1_COD)
Local   nCol        := 0
Local   nLin        := 0
Local   aFotosPNG   := {} // Todas as fotos PNG
Local   aFotosJPG   := {} // Todas as fotos JPG
Local   aVideosMP4  := {} // Todos os videos MP4
Local   aVideosWMV  := {} // Todos os videos WMV
Local   aVideosAVI  := {} // Todos os videos AVI
Local   cDirFotVid  := GetNewPar("MV_DIRFTGC","") // Diretorio das FOTOS e VIDEOS
Local   nCntFor     := 0
Local   cDesProd    := ""
Local   aTitFoto    := {}
Private aFotos      := {}
Private aVideos     := {}
Default cB1_COD     := ""

If FindFunction("IsHtml") .and. IsHtml() // Esta utilizando SmartClient HTML
    MsgStop(STR0004,STR0002) // Opcao nao disponivel para SmartClient HTML! / Atencao
	Return()
EndIf

If !Empty(cB1_COD)

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+cB1_COD))
	cDesProd := Alltrim(SB1->B1_GRUPO)+" "+Alltrim(SB1->B1_CODITE)+" - "+SB1->B1_DESC

	//////////////////////////////////////////////////////////////////
	// Levanta FOTOS do B1_COD - Peca especifica                    //
	//////////////////////////////////////////////////////////////////
	ADir(cDirFotVid+"PB1COD"+Alltrim(SB1->B1_COD)+"_*.png",aFotosPNG)
	ADir(cDirFotVid+"PB1COD"+Alltrim(SB1->B1_COD)+"_*.jpg",aFotosJPG)

	If len(aFotosPNG) <= 0 .and. len(aFotosJPG) <= 0 // Caso nao exista fotos pelo B1_COD

		//////////////////////////////////////////////////////////////
		// Levanta FOTOS do B1_GRUPO + B1_CODITE - Peca especifica  //
		//////////////////////////////////////////////////////////////
		ADir(cDirFotVid+"P"+Alltrim(SB1->B1_GRUPO)+Alltrim(SB1->B1_CODITE)+"_*.png",aFotosPNG)
		ADir(cDirFotVid+"P"+Alltrim(SB1->B1_GRUPO)+Alltrim(SB1->B1_CODITE)+"_*.jpg",aFotosJPG)

		If len(aFotosPNG) <= 0 .and. len(aFotosJPG) <= 0 // Caso nao exista fotos pelo B1_GRUPO + B1_CODITE
	
			//////////////////////////////////////////////////////////
			// Levanta FOTOS do B1_GRUPO                            //
			//////////////////////////////////////////////////////////
			ADir(cDirFotVid+"P"+Alltrim(SB1->B1_GRUPO)+"_*.png",aFotosPNG)
			ADir(cDirFotVid+"P"+Alltrim(SB1->B1_GRUPO)+"_*.jpg",aFotosJPG)
	
		EndIf
	
	EndIf
	
	//////////////////////////////////////////////////////////////////
	// Levanta VIDEOS do B1_COD - Peca especifica                   //
	//////////////////////////////////////////////////////////////////
	ADir(cDirFotVid+"PB1COD"+Alltrim(SB1->B1_COD)+"_*.mp4",aVideosMP4)
	ADir(cDirFotVid+"PB1COD"+Alltrim(SB1->B1_COD)+"_*.wmv",aVideosWMV)
	ADir(cDirFotVid+"PB1COD"+Alltrim(SB1->B1_COD)+"_*.avi",aVideosAVI)

	If len(aVideosMP4) <= 0 .and. len(aVideosWMV) <= 0 .and. len(aVideosAVI) <= 0 // Caso nao exista Videos pelo B1_COD

		//////////////////////////////////////////////////////////////
		// Levanta VIDEOS do B1_GRUPO + B1_CODITE - Peca especifica //
		//////////////////////////////////////////////////////////////
		ADir(cDirFotVid+"P"+Alltrim(SB1->B1_GRUPO)+Alltrim(SB1->B1_CODITE)+"_*.mp4",aVideosMP4)
		ADir(cDirFotVid+"P"+Alltrim(SB1->B1_GRUPO)+Alltrim(SB1->B1_CODITE)+"_*.wmv",aVideosWMV)
		ADir(cDirFotVid+"P"+Alltrim(SB1->B1_GRUPO)+Alltrim(SB1->B1_CODITE)+"_*.avi",aVideosAVI)
	
		If len(aVideosMP4) <= 0 .and. len(aVideosWMV) <= 0 .and. len(aVideosAVI) <= 0 // Caso nao exista Videos pelo B1_GRUPO + B1_CODITE
	
			//////////////////////////////////////////////////////////
			// Levanta VIDEOS do B1_GRUPO                           //
			//////////////////////////////////////////////////////////
			ADir(cDirFotVid+"P"+Alltrim(SB1->B1_GRUPO)+"_*.mp4",aVideosMP4)
			ADir(cDirFotVid+"P"+Alltrim(SB1->B1_GRUPO)+"_*.wmv",aVideosWMV)
			ADir(cDirFotVid+"P"+Alltrim(SB1->B1_GRUPO)+"_*.avi",aVideosAVI)

		EndIf

	EndIf

	If ExistBlock("OXC03LEV")
		ExecBlock("OXC03LEV ", .f., .f., { aFotos, aVideos, SB1->B1_GRUPO, SB1->B1_CODITE, SB1->B1_COD })
	EndIf

	If len(aFotosPNG) <= 0 .and. len(aFotosJPG) <= 0 .and. len(aVideosMP4) <= 0 .and. len(aVideosWMV) <= 0 .and. len(aVideosAVI) <= 0 .and. len(aVideos) <= 0 .and. len(aFotos) <= 0
		MsgStop(STR0003+CHR(13)+CHR(10)+CHR(13)+CHR(10)+IIf(!Empty(cDirFotVid),cDirFotVid,"MV_DIRFTGC"),STR0002) // Foto(s)/Video(s) do Produto nao encontrados! / Atencao
		Return
	Else

		For nCntFor := 1 to len(aFotosPNG)
			aAdd(aFotos,cDirFotVid+aFotosPNG[nCntFor]) // Foto PNG
		Next
		For nCntFor := 1 to len(aFotosJPG)
			aAdd(aFotos,cDirFotVid+aFotosJPG[nCntFor]) // Foto JPG
		Next
		// adicionando titulos das fotos
		for nCntFor := 1 to Len(aFotos)
			aAdd(aTitFoto, "< " + ALLTRIM(STR(nCntFor)) + " >")
		next
		If len(aVideosMP4) > 0 .or. len(aVideosWMV) > 0 .or. len(aVideosAVI) > 0
			aAdd(aTitFoto,"< "+STR0005+" >") // Videos
			For nCntFor := 1 to len(aVideosMP4)
				aAdd(aVideos,cDirFotVid+aVideosMP4[nCntFor]) // Video MP4
			Next
			For nCntFor := 1 to len(aVideosWMV)
				aAdd(aVideos,cDirFotVid+aVideosWMV[nCntFor]) // Video WMV
			Next
			For nCntFor := 1 to len(aVideosAVI)
				aAdd(aVideos,cDirFotVid+aVideosAVI[nCntFor]) // Video AVI
			Next
		EndIf
	EndIf

	If len(aFotos) > 0 .or. len(aVideos) > 0
		DEFINE MSDIALOG oFotoProd TITLE (STR0001+": "+Alltrim(cDesProd)) From 00,00 to 560,560 PIXEL of oMainWnd  // Foto(s)/Video(s) do Produto
			@ 000,000 BUTTON oSair PROMPT "" OF oFotoProd SIZE 1,1 PIXEL ACTION oFotoProd:End()
			//
			oFoldFoto := TFolder():New(0,8,aTitFoto,{}, oFotoProd,,,,.t.,.f.,280,280)
			oFoldFoto:Align := CONTROL_ALIGN_ALLCLIENT 
			/////////////////////////////////////////////////////////////////////////
			// TAMANHO PADRAO DA IMAGEM  -->  560pix (largura)  x  530pix (altura) //
			/////////////////////////////////////////////////////////////////////////
			For nCntFor := 1 to len(aFotos)
				&("oBitMap"+Alltrim(str(nCntFor))) := TBitmap():New(000,000,280,280,,aFotos[nCntFor],.T.,oFoldFoto:aDialogs[nCntFor],,,.T.,.F.,,,.F.,,.T.,,.F.)
	   	        &("oBitMap"+Alltrim(str(nCntFor))+":Align") := CONTROL_ALIGN_ALLCLIENT
	   		Next
			nCol := 0
			nLin := 0
			For nCntFor := 1 to len(aVideos)
				nCol++
				If nCol > 4
					nCol := 1
					nLin += 12
				EndIf
				&("oMedia"+Alltrim(str(nCntFor))) := TButton():New( nLin + 2 /* <nRow> */, ( nCol * 70 ) - 69 /* <nCol> */, (STR0006+" "+Alltrim(str(nCntFor))) /* <cCaption> */, oFoldFoto:aDialogs[len(aFotos)+1] /* <oWnd> */,;
														&('{ || ' + "WinExec( 'cmd /c "+aVideos[nCntFor]+"' )" + ' }')	/* <{uAction}> */, 68 /* <nWidth> */, 10 /* <nHeight> */, /* <nHelpId> */, /* <oFont> */, /* <.default.> */,;
														.t.	/* <.pixel.> */, /* <.design.> */, /* <cMsg> */, /* <.update.> */, /* <{WhenFunc}> */,/* <{uValid}> */, /* <.lCancel.> */	)
	   	  	Next
		ACTIVATE MSDIALOG oFotoProd CENTER
	EndIf
EndIf
Return()