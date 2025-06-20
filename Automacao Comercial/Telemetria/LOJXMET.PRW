#INCLUDE "TOTVS.CH"
#INCLUDE 'FWLIBVERSION.CH' 

Static __lMetric := FWLibVersion() >= "20210517" .And. GetSrvVersion() >= "19.3.0.6" //Verifica se est� atualizado para utiliza��o do componente de Metrica

//----------------------------------------------------------------------------
/*/{Protheus.doc} LojxMetric
Fun��o para registro de M�tricas.

@type    function
@author  Alberto Deviciente
@since   04/10/2022
@version P12

@param cType        , Caractere , Tipo de M�trica.              [Obrigat�rio]
@param cSubRoutine  , Caractere , Nome da Sub-Rotina.           [Obrigat�rio]
@param cIdMetric    , Caractere , ID da M�trica                 [Obrigat�rio]
@param uValue       , Indefinido, Valor coletado na m�trica.    [Obrigat�rio]
@param dDateSend    , Data      , Data em que a Telemetria deve ser sincronizada.
@param nLapTime     , Num�rico  , Tempo de uso (em segundos).
@param cRotina      , Caractere , Nome da Rotina.

@return Nil, Nulo
/*/
//----------------------------------------------------------------------------
Function LojxMetric(cType, cSubRoutine, cIdMetric, uValue, dDateSend, nLapTime, cRotina)

Default dDateSend   := Nil
Default nLapTime    := Nil
Default cRotina     := Nil

If __lMetric

    Do Case
        Case cType == "SUM"

            //M�todo respons�vel por registrar a m�trica de SOMA. 
            FWCustomMetrics():setSumMetric(     cSubRoutine     ,;  //SubRotina Utilizada
                                                cIdMetric       ,;  //ID da M�trica
                                                uValue          ,;  //Valor da m�trica (Num�rico)
                                                dDateSend       ,;  //Data que a telemetria deve ser sincronizada
                                                nLapTime        ,;  //Tempo de uso, em segundos
                                                cRotina         )   //Sobrescreve a rotina que est� definindo a m�trica

        Case cType == "UNQ"

            //M�todo respons�vel por registrar a m�trica uma �NICA vez, somente se esta n�o existir (independente do valor).
            FWCustomMetrics():setUniqueMetric(  cSubRoutine     ,;  //SubRotina Utilizada
                                                cIdMetric       ,;  //ID da M�trica
                                                uValue          ,;  //Valor da m�trica (Caractere)
                                                dDateSend       ,;  //Data que a telemetria deve ser sincronizada
                                                nLapTime        ,;  //Tempo de uso, em segundos
                                                cRotina         )   //Sobrescreve a rotina que est� definindo a m�trica
        /*
        Case cType == "AVG"
        
            //M�todo respons�vel por registrar a m�trica de M�DIA.
            FWCustomMetrics():setAverageMetric( cSubRoutine     ,;  //SubRotina Utilizada
                                                cIdMetric       ,;  //ID da M�trica
                                                uValue          ,;  //Valor da m�trica (Num�rico)
                                                dDateSend       ,;  //Data que a telemetria deve ser sincronizada
                                                nLapTime        ,;  //Tempo de uso, em segundos
                                                cRotina         )   //Sobrescreve a rotina que est� definindo a m�trica
        */
    EndCase

EndIf

Return
