#INCLUDE "PROTHEUS.CH"
/* Este fonte ter� as fun��es de x3_cbox do PLS */
//-------------------------------------------------------------------
/*/{Protheus.doc} PLCRWEBPRE
Retorna os novos status de protocolo da TISS 
@author Karine Riquena Limp
@since 12/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSSTATISS()
Local cRet := "1=Recebido;2=Em an�lise;3=Liberado para pagamento;4=Encerrado sem pagamento;5=Analisado e aguardando libera��o para o pagamento;6=Pagamento efetuado;7=N�o localizado;8=Aguardando informa��o complementar;9=Cancelado"
Return cRet

Function PLSGUTISS()
Local cRet := "1=Autorizado;2=Em an�lise;3=Negado;4=Aguardando justificativa t�cnica do solicitante;5=Aguardando documenta��o do prestador;6=Solicita��o cancelada;7=Autorizado parcialmente"
Return cRet
