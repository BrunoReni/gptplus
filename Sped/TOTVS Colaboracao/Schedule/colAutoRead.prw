#Include "Protheus.ch"

//-----------------------------------------------------------------
/*/{Protheus.doc} colAutoRead
Execucao do processo de leitura dos arquivos recebidos via TOTVS Colaboração 2.0.

@author  Rafael Iaquinto
@since   24/07/2014
@version 11.8
/*/
//-----------------------------------------------------------------
Function colAutoRead(aParam) 

Local oComTransmite := Nil
Local lImpXML       := SuperGetMv("MV_IMPXML",.F.,.F.) .And. CKO->(FieldPos("CKO_ARQXML")) > 0 .And. !Empty(CKO->(IndexKey(5)))
Local cTraCID       := SuperGetMv("MV_XMLCID",.F.,"")
Local cTraCSEC      := SuperGetMv("MV_XMLCSEC",.F.,"")

colReadDocs()

If lImpXML .And. !Empty(cTraCID) .And. !Empty(cTraCSEC)
    oComTransmite := ComTransmite():New()

    //Busca XML nas pastas IN/Lidos e grava na CKO
    oComTransmite:XMLINLIDOS()

    If oComTransmite:TokenTotvsTransmite() 
        //Busca XML no Transmite e grava na CKO
        oComTransmite:XMLTRANSMITE()
        
        //Informa Transmite dos documentos importados
        oComTransmite:XMLEXPORTED(1)

        //Atualiza Status
        oComTransmite:XMLSTATUSTRA()
    Endif
Endif
		
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Retorna as perguntas definidas no schedule.

@return aReturn			Array com os parametros

@author  Rafael Iaquinto
@since   24/07/2014
@version 12
/*/
//-------------------------------------------------------------------

Static Function SchedDef()

Local aParam  := {}

aParam := { "P",;			//Tipo R para relatorio P para processo
            "",;	//Pergunte do relatorio, caso nao use passar ParamDef
            ,;			//Alias
            ,;			//Array de ordens
            }				//Titulo

Return aParam
