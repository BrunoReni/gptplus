#include "rwmake.ch"
#include "protheus.ch"
#include "RHUPDGPE.CH" 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fRhUpdMsg � Autor � Marcelo Silveira	    � Data � 04/10/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna informacoes do compatibilizador                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Retornar informacao sobre a atualizacao conforme o indice  ���
���          � Ver exemplo no fonte GPEM020 - Folha Nova                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  
Function fRhUpdMsg( nUpd )

    Local cMsg := ""

    DEFAULT nUpd := 0

    If nUpd > 0

        Do Case
            Case nUpd == 197 ; cMsg := "197 - " + STR0277
            Case nUpd == 198 ; cMsg := "198 - " + STR0285
            Case nUpd == 201 ; cMsg := "201 - " + STR0291
            Case nUpd == 206 ; cMsg := "206 - " + STR0298
            Case nUpd == 207 ; cMsg := "207 - " + STR0299
            Case nUpd == 210 ; cMsg := "210 - " + STR0300
            Case nUpd == 211 ; cMsg := "211 - " + STR0303
        End Case
        
        If !Empty(cMsg)
            cMsg := STR0280 + CRLF + CRLF + cMsg  //#"Para acessar esta rotina atualize o sistema com o compatibilizador RHUPDMOD, executando a(s) opcao(es) abaixo:"
        EndIf

    EndIf

Return(cMsg)
