// 浜様様様曜様様様様�
// � Versao � 005    �
// 藩様様様擁様様様様�

#INCLUDE "Protheus.ch"
#INCLUDE "VEIVA320.CH"
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � VEIVA320 � Autor �  Rafael Goncalves     � Data � 16/09/09 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Cadastro de Tarefas                                        咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VEIVA320()
Private cCadastro := STR0001  // Cadastro de Tarefas
//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Endereca a funcao axCadastro                                 �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
DbSelectArea("VAX")
axCadastro("VAX", cCadastro, "VEIVA320EX()")
Return .T.

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    �VEIVA320EX� Autor � Rafael Goncalves      � Data � 16/09/09 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Valida se pode ser feito a exclusao                        咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VEIVA320EX()
Local aArquivos := {}
aadd(aArquivos,{"VAY","VAY_CODTAR",VAX->VAX_CODTAR,})
Return FG_DELETA(aArquivos)

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳賃陳陳陳賃陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    �VEIVA320VLD� Autor � Andre Luis Almeida   � Data � 27/05/10 咳�
臼団陳陳陳陳津陳陳陳陳陳珍陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Valida o campo VAX_CHAMAD para preencher automaticamente:  咳�
臼�          � - VAX_TARBLQ e VAX_BLQAPR qdo for na "Finalizacao"         咳�
臼�          � - VAX_BLQAPR qdo for na "Aprovacao"                        咳�
臼�          � Valida o campo VAX_ORIGEM para preencher automaticamente:  咳�
臼�          � - VAX_LIBERA qdo for na Fat.Direto                         咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VEIVA320VLD()
If M->VAX_CHAMAD == "2" // Momento da Chamada: Finalizacao
	M->VAX_TARBLQ := "0" // 0=Tarefa NAO Bloqueia a Finalizacao
	M->VAX_BLQAPR := "0" // 0=Tarefa NAO Bloqueia a Aprovacao
ElseIf M->VAX_CHAMAD == "6" // Momento da Chamada: Aprovacao
	M->VAX_BLQAPR := "0" // 0=Tarefa NAO Bloqueia a Aprovacao
EndIf
If M->VAX_ORIGEM == "2" // Faturamento Direto
	M->VAX_LIBERA := "0" // 0=Nao Liberar
EndIf
Return(.t.)