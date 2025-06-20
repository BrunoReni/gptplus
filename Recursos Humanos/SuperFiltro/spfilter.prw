#INCLUDE "PROTHEUS.CH"

Static aGrupos	:= {} 
Static cUserId	:= "" 
Static __cORGSPFL := SuperGetMv( "MV_ORGSPFL", .F., 'N' )

/*/
旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴�
쿑un뇙o    � SPFILTER � Autor � Igor Franzoi                    � Data �09/03/2009�
쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴�
쿏escri뇙o 쿑onte criado para armazenar as funcoes de SuperFiltro                 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿞intaxe   �                                                                      �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿢so       � Generico                                                             �
쳐컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
�           ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                     �
쳐컴컴컴컴컴컴컴컴쩡컴컴컴컫컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿛rogramador      � Data   � BOPS/FNC  �  Motivo da Alteracao                     �
쳐컴컴컴컴컴컴컴컴탠컴컴컴컵컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿎ecilia C.       �04/08/14쿟QFZO4     쿔ncluido o fonte da 11 para a 12.         �
읕컴컴컴컴컴컴컴컴좔컴컴컴컨컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�/*/


/*/
旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커
쿑un뇙o    쿞RVSPFilter	 � Autor 쿔gor Franzoi		   � Data �09/03/2009�
쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑
쿏escri뇙o 쿞uperFiltro da Tabela SRV									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿞intaxe   �<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿛arametros�<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿝etorno   쿬Exp = Expressao de filtro para a tabela SRV				 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿚bserva뇙o�                                                      	     �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
� Uso      쿒enerico													 �
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸/*/ 
Function SRVSPFilter()
  	If __cORGSPFL # 'S'
		Return ""
	Endif
Return GetGPEXSpFl("SRV", "RV")

/*/
旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커
쿑un뇙o    쿞RYSPFilter	 � Autor 쿔gor Franzoi		   � Data �09/03/2009�
쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑
쿏escri뇙o 쿞uperFiltro da Tabela SRY									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿞intaxe   �<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿛arametros�<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿝etorno   쿬Exp = Expressao de filtro para a tabela SRY				 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿚bserva뇙o�                                                      	     �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
� Uso      쿒enerico													 �
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸/*/
Function SRYSPFilter() 
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("SRY", "RY")

/*/
旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커
쿑un뇙o    쿎TTSPFilter	 � Autor 쿔gor Franzoi		   � Data �09/03/2009�
쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑
쿏escri뇙o 쿞uperFiltro da Tabela CTT									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿞intaxe   �<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿛arametros�<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿝etorno   쿬Exp = Expressao de filtro para a tabela CTT				 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿚bserva뇙o�                                                      	     �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
� Uso      쿒enerico													 �
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸/*/
Function CTTSPFilter()
	If (__cORGSPFL # 'S') .OR. (!(cModulo $ ("APD","CSA","GPE","PON","RSP","TRM","APT","RPM")))  //superfiltro CTT s� aplicado sobre modulos de RH
		Return ""
	Endif	
Return GetGPEXSpFl("CTT", "CTT")

/*/
旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커
쿑un뇙o    쿝CHSPFilter	 � Autor 쿔gor Franzoi		   � Data �09/03/2009�
쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑
쿏escri뇙o 쿞uperFiltro da Tabela RCH									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿞intaxe   �<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿛arametros�<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿝etorno   쿬Exp = Expressao de filtro para a tabela RCH				 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿚bserva뇙o�                                                      	     �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
� Uso      쿒enerico													 �
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸/*/
Function RCHSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("RCH", "RCH")

/*/
旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커
쿑un뇙o    쿝CJSPFilter	 � Autor 쿔gor Franzoi		   � Data �09/03/2009�
쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑
쿏escri뇙o 쿞uperFiltro da Tabela RCJ									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿞intaxe   �<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿛arametros�<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿝etorno   쿬Exp = Expressao de filtro para a tabela RCJ				 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿚bserva뇙o�                                                      	     �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
� Uso      쿒enerico													 �
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸/*/
Function RCJSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("RCJ", "RCJ")

/*/
旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커
쿑un뇙o    쿞RCSPFilter	 � Autor 쿔gor Franzoi		   � Data �09/03/2009�
쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑
쿏escri뇙o 쿞uperFiltro da Tabela SRC									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿞intaxe   �<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿛arametros�<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿝etorno   쿬Exp = Expressao de filtro para a tabela SRC				 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿚bserva뇙o�                                                      	     �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
� Uso      쿒enerico													 �
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸/*/
Function SRCSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("SRC", "RC")

/*/
旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커
쿑un뇙o    쿞RDSPFilter	 � Autor 쿔gor Franzoi		   � Data �09/03/2009�
쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑
쿏escri뇙o 쿞uperFiltro da Tabela SRD									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿞intaxe   �<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿛arametros�<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿝etorno   쿬Exp = Expressao de filtro para a tabela SRD				 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿚bserva뇙o�                                                      	     �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
� Uso      쿒enerico													 �
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸/*/
Function SRDSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("SRD", "RD")

/*/
旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커
쿑un뇙o    쿞I3SPFilter	 � Autor 쿔gor Franzoi		   � Data �09/03/2009�
쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑
쿏escri뇙o 쿞uperFiltro da Tabela SI3									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿞intaxe   �<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿛arametros�<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿝etorno   쿬Exp = Expressao de filtro para a tabela SI3				 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿚bserva뇙o�                                                      	     �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
� Uso      쿒enerico													 �
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸/*/
Function SI3SPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("CTT", "CTT")

/*/
旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커
쿑un뇙o    쿝GBSPFilter	 � Autor 쿔gor Franzoi		   � Data �20/03/2009�
쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑
쿏escri뇙o 쿞uperFiltro da Tabela RGB									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿞intaxe   �<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿛arametros�<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿝etorno   쿬Exp = Expressao de filtro para a tabela RGB				 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿚bserva뇙o�                                                      	     �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
� Uso      쿒enerico													 �
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸/*/
Function RGBSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("RGB", "RGB")

/*/
旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커
쿑un뇙o    쿝COSPFilter	 � Autor 쿔gor Franzoi		   � Data �20/03/2009�
쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑
쿏escri뇙o 쿞uperFiltro da Tabela RCO									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿞intaxe   �<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿛arametros�<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿝etorno   쿬Exp = Expressao de filtro para a tabela RCO				 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿚bserva뇙o�                                                      	     �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
� Uso      쿒enerico													 �
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸/*/
Function RCOSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("RCO", "RCO")

/*/
旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커
쿑un뇙o    쿝GCSPFilter	 � Autor 쿔gor Franzoi		   � Data �20/03/2009�
쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑
쿏escri뇙o 쿞uperFiltro da Tabela RGC									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿞intaxe   �<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿛arametros�<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿝etorno   쿬Exp = Expressao de filtro para a tabela RGC				 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿚bserva뇙o�                                                      	     �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
� Uso      쿒enerico													 �
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸/*/
Function RGCSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("RGC", "RGC")

/*/
旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커
쿑un뇙o    쿝CPSPFilter	 � Autor 쿣aldeci Lira		   � Data �14/05/2009�
쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑
쿏escri뇙o 쿞uperFiltro da Tabela Rcp									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿞intaxe   �<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿛arametros�<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿝etorno   쿬Exp = Expressao de filtro para a tabela Rcp				 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿚bserva뇙o�                                                      	     �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
� Uso      쿒enerico													 �
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸/*/
Function RCPSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("RCP", "RCP")
/*/
旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커
쿑un뇙o    쿝CQSPFilter	 � Autor 쿣aldeci Lira		   � Data �14/05/2009�
쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑
쿏escri뇙o 쿞uperFiltro da Tabela RCQ									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿞intaxe   �<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿛arametros�<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿝etorno   쿬Exp = Expressao de filtro para a tabela Rcp				 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿚bserva뇙o�                                                      	     �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
� Uso      쿒enerico													 �
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸/*/
Function RCQSPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("RCQ", "RCQ")
/*/
旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커
쿑un뇙o    쿞R3SPFilter	 � Autor 쿣aldeci Lira		   � Data �14/05/2009�
쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑
쿏escri뇙o 쿞uperFiltro da Tabela SR3									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿞intaxe   �<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿛arametros�<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿝etorno   쿬Exp = Expressao de filtro para a tabela SR3				 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿚bserva뇙o�                                                      	     �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
� Uso      쿒enerico													 �
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸/*/
Function SR3SPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("SR3", "R3")
/*/
旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커
쿑un뇙o    쿞R7SPFilter	 � Autor 쿣aldeci Lira		   � Data �14/05/2009�
쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑
쿏escri뇙o 쿞uperFiltro da Tabela SR7									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿞intaxe   �<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿛arametros�<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿝etorno   쿬Exp = Expressao de filtro para a tabela SR7				 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿚bserva뇙o�                                                      	     �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
� Uso      쿒enerico													 �
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸/*/
Function SR7SPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("SR7", "R7")
/*/
旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커
쿑un뇙o    쿝G7SPFilter	 � Autor 쿣aldeci Lira		   � Data �14/05/2009�
쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑
쿏escri뇙o 쿞uperFiltro da Tabela RG7									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿞intaxe   �<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿛arametros�<Vide Parametros Formais>									 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿝etorno   쿬Exp = Expressao de filtro para a tabela RG7				 �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
쿚bserva뇙o�                                                      	     �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
� Uso      쿒enerico													 �
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸/*/
Function RG7SPFilter()
	If __cORGSPFL # 'S'
		Return ""
	Endif	
Return GetGPEXSpFl("RG7", "RG7")
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿞PFILTER  튍utor  쿘icrosiga           � Data �  04/09/09   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     �                                                            볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP                                                         볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function GetGPESpFil(cAlias, cPrefixTable)
	Local aArea 	:= getArea()    
	Local cGrupo	:= ""
	Local cValFil	:= ""
   	Local cRet		:= ""
   	Local cKey		:= "" 
   	Local nGrupo	:= 1
   	Local nMaxGrupo	:= Len(aGrupos)
      
  	If __cORGSPFL # 'S'
		Return cRet
	Endif
	
	aGrupos	:= UsrRetGrp(cUserName)
	cUserId	:= RetCodUsr()
	
  	iif(nMaxGrupo == 0, {|| nMaxGrupo := 1, aAdd(aGrupos, "" )}, .T.)
  	
	If FindFunction(cAlias + "SPFILTER")
		If ( Select( "SRW" ) == 0 )
			ChkFile("SRW")
		EndIf
		
		SRW->(dbSetOrder(RetOrder("SRW","RW_FILIAL+RW_SPFIL+RW_ALIAS+RW_GRUPO+RW_IDUSER")))		
			
		cKey := xFilial("SRW")
		cKey += "1"
		cKey += cAlias     
   		cRet := ""      	
	   		
		/*旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		  쿛rocura todas as restricoes que cabem ao usuario, �
		  쿬onsidera os grupos e restricao pertencentes a ele�
		  읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸*/	
		If ( SRW->( dbSeek(cKey) ) )              
			cCondAux := SRW->RW_FILIAL + SRW->RW_SPFIL + SRW->RW_ALIAS
			While ( SRW->(!Eof()) .AND. cCondAux == cKey ) 
				//Verifica se a restricao se aplica ao usuario
			    If (Empty(SRW->RW_GRUPO) .AND. SRW->RW_IDUSER == cUserId);
			    	.OR. ;
			       ((Empty(SRW->RW_IDUSER) .OR. SRW->RW_IDUSER == cUserId) .AND. aScan(aGrupos, {|x| x == SRW->RW_GRUPO})> 0)
			    	
				   	If(!Empty(cRet))
				   		cRet += " .AND. " + AllTrim(SRW->RW_FILBROW)
				   	Else
				   		cRet:= AllTrim(SRW->RW_FILBROW)
				   	EndIf
				EndIf         
				
				SRW->(dbSkip()) 
				cCondAux := SRW->RW_FILIAL + SRW->RW_SPFIL + SRW->RW_ALIAS
			EndDo
		EndIf
		//-- Desabilita o filtro de filiais para o Brasil, pois o usuario precisa ter visao
		//-- total por exemplo da ficha financeira (SRD).
		IF cPaisLoc <> 'BRA'
			//Se o prefixo da tabela tiver sido mandado com _, retira-o
			cPrefixTable := StrTran( cPrefixTable, "_", "")
			cValFil := " (" + cPrefixTable +"_FILIAL $'" + fValidFil(cAlias) + "') "
			If !Empty(cRet)    
				cRet := cValFil+" .and. "+cRet
			Else
				cRet := cValFil
			EndIf
	    Endif
	EndIf	
	
	RestArea(aArea)
Return cRet                                                         
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿞PFILTER  튍utor  쿘icrosiga           � Data �  04/09/09   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     �                                                            볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP                                                         볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function GetGPEXSpFl(cTable, cPrefixTable)
	Local cExp		:= ""
	Local cChkRh	:= ""
	Local cFunName	:= ""

	If __cORGSPFL # 'S' 
		Return cExp
	EndIf

	cUserId	:= RetCodUsr()
	aGrupos   := UsrRetGrp(cUserName)	
	
	If (cUserId = "000000" .or. Empty(cUserId))
		Return cExp
	EndIf

	If (AScan(aGrupos, { |x| x == "000000"}) > 0)
		Return cExp
	EndIf	
	
	//Busca as restricoes para o usuario
	cExp := GetGPESpFil(cTable, cPrefixTable )
	
	/*/
	旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	� Caso a expressao de filtro seja maior que 4000 caracteres   �
	� imprime o tamanho no server								  �	
	읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�/*/	
	If ( Len(cExp) > 4000 )
		ConOut("Tamanho: " + Str(Len(cExp)))
	EndIf
		
Return cExp
