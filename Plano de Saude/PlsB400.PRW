
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � AbrLvr   � Autor � Thiago Machado Correa � Data � 14/07/04 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Imprime termo de abertura do Livro                         ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Pls							            				  ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

Function AbrLvr()
Local aStru
Local aFicha
Local nTmp
Local cTmp

//���������������������������������������������������������������������Ŀ
//� Criar Tabela tempor�ria
//�����������������������������������������������������������������������
aStru := {}
aAdd(aStru,{"TipReg" ,"C",003,0})
aAdd(aStru,{"ConReg" ,"C",500,0})

oTempTable := FWTemporaryTable():New( "otempTable" )
oTempTable:SetFields (aStru)
oTempTable:AddIndex("01", {"TipReg", "ConReg"})

oTempTable:Create()

//���������������������������������������������������������������������Ŀ
//� Atualizar tabela tempor�ria
//�����������������������������������������������������������������������

dbSelectArea("oTempTable")
Append From AbrLvr.ini SDF

oTempTable->(dbGoTop())

//���������������������������������������������������������������������Ŀ
//� Monta vetor                                                         �
//�����������������������������������������������������������������������
aFicha  := {}

While ! oTempTable->(eof())
	If oTempTable->TipReg <> "999"
		aadd(aFicha ,oTempTable->ConReg)
	Endif
	//���������������������������������������������������������������������Ŀ
	//� Acessa proximo registro                                             �
	//�����������������������������������������������������������������������
	oTempTable->(dbSkip())
End

//���������������������������������������������������������������������Ŀ
//� Fecha a area e exclui a tabela tempor�ria
//�����������������������������������������������������������������������
oTempTable->(dbCloseArea())
oTempTable:Delete()

//���������������������������������������������������������������������Ŀ
//� Posiciona pagina                                                    �
//�����������������������������������������������������������������������
@ 0,0 PSay AvalImp(nLimite)

For nTmp:=1 to len(aFicha)
    
	cTmp := aFicha[nTmp]
	@ Li, nColuna PSay &cTmp
	Li++
	
Next

nPagina++
Li := 99


Return
