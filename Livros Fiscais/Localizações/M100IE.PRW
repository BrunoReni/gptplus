/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪哪勘�
北矲uncao    矼100IE    � Autor � Fernando Machima       � Data � 02.11.00  潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪哪幢�
北矰escricao 砅rograma que calcula Imposto especifico de combustivel(CHILE) 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       矼ATA101                                                       潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function M100IE()

LOCAL _cAlias 
LOCAL _nOrd     
LOCAL cCpoDecs
LOCAL nDecs := 0
LOCAL nCols := 0
LOCAL nPosIE := 0

SetPrvt("AITEMINFO,AIMPOSTO")

_cAlias := Alias()
_nOrd   := IndexOrd()

aItemINFO   := ParamIxb[1]
aImposto    := aClone(ParamIxb[2])
nCols       := ParamIxb[3]

aImposto[02] := SFB->FB_ALIQ	// Aliquota
aImposto[03] := aItemINFO[3]  //Base de Calculo
            
cCpoDecs := "F1_VALIMP"+SFB->FB_CPOLVRO
dbSelectArea("SX3")
dbSetOrder(2)
If dbSeek(cCpoDecs)
   nDecs := SX3->X3_DECIMAL
Else
   nDecs := 2
EndIf   

nPosIE:= Ascan(aHeader,{|x|Trim(x[2])=="D1_IE"})
If nPosIE > 0    
   aImposto[4]:= Round(aCols[nCols][nPosIE] * aItemInfo[1],nDecs)   //Calculo do imposto
EndIf  

DbSelectArea(_cAlias)
DbSetOrder(_nOrd)

Return( aImposto )

