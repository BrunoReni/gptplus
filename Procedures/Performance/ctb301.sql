
-- Procedure creation 
CREATE PROCEDURE CTB301_## (

@IN_FILIAL Char( 'CT2_FILIAL' ) , 
@IN_DATAINI Char( 08 ) , 
@IN_DATAFIM Char( 08 ) , 
@IN_LTDSMOEDA Char( 01 ) , 
@IN_MOEDA Char( 'CT2_MOEDLC' ) , 
@IN_TPSDEST VarChar( 20 ) , 
@IN_LCOPIA Integer , 
@IN_TPSORIG Char( 001 ) , 
@IN_LLOTE Integer , 
@IN_LHIST Integer , 
@IN_CODHIST Char( 003 ) , 
@IN_LOTE Char( 'CT2_LOTE' ) , 
@IN_SBLOTE Char( 'CT2_SBLOTE' ) , 
@IN_MAXLINHA Integer , 
@IN_LTPSALD Char( 01 ) , 
@IN_MV_SOMA CHAR(01),
@OUT_RESULT Char( 01 )  output ) AS

/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBM300.PRW </s>
    Descricao       - <d>  Copia de Saldos </d>
    Funcao do Siga  -      CTBM300()
    Entrada         - <ri> @IN_FILIAL     - Filial do processamento</ri>
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Douglas Rodrigues da Silva	</r>
    Data        :     21/03/2023
    Parametro   : MV_CTBCUBE = 2 Não | Utiliza cubo de entidades contábeis
    Parametro   : MV_CTBJOB  = 2 Não | Define se usa Job para processamento.

    CTBM300 - Copia de Saldos

    2.[CTBM300PAI]==> CTB301 - Copia simples e Multiplos saldos de lancamentos. - aProc[11]
            NAO FAZ copia pelos saldos das contas                      
      2.1 [CTB300CTC ] ==> CTB309   - Atualiza Cabecalho do Lote               - aProc[10]		   
      2.1 [CTBM300DOC] ==> CTB308   - Proxima linha, documento e lote          - aProc[9]  
      2.1.[CTM300SOMA] ==> MSSOMA1  - Cria a procedure SOMA1                   - aproc[8]  
      2.1.[CTBM300STR] ==> MSSTRZERO                                           - aProc[7]
      2.1 [CTBM300CT7] ==> CTB305   - Atualizacao de saldos no CQ0/CQ1         - aProc[6]
      2.2 [CTBM300CT3] ==> CTB304   - Atualizacao de saldos no CQ2/CQ3         - aProc[5]
      2.3 [CTBM300CT4] ==> CTB303   - Atualizacao de saldos no CQ4/CQ5         - aProc[4]
      2.4 [CTBM300CTI] ==> CTB302   - Atualizacao de saldos no CQ6/CQ7         - aProc[3]
      1.  CTBM300LDAY - Lastday - Retorna o Ultimo dia do Mes                  - aProc[2]
      0.  CallXFILIAL - Cria a procedure xfilial                               - aProc[1]

  //-------------------------------------------------------------------------------------- */
-- Declaration of variables
declare @cAux Char( 03 )
declare @cFil_CT8 Char( 'CT8_FILIAL' )
declare @cFil_CT2 Char( 'CT2_FILIAL' )
declare @cCT2_FILIAL Char( 'CT2_FILIAL' )
declare @cCT2_DATA Char( 08 )
declare @cCT2_LOTE Char( 006 )
declare @cCT2_SBLOTE Char( 'CT2_SBLOTE' )
declare @cCT2_DOC Char( 006 )
declare @cCT2_LINHA Char( 003 )
declare @cCT2_MOEDLC Char( 'CT2_MOEDLC' )
declare @cCT2_DC Char( 001 )
declare @cCT2_DEBITO Char( 'CT2_DEBITO' )
declare @cCT2_CREDIT Char( 'CT2_CREDIT' )
declare @cCT2_DCD Char( 001 )
declare @cCT2_DCC Char( 001 )
declare @nCT2_VALOR Float
declare @cCT2_MOEDAS Char( 007 )
declare @cCT2_HP Char( 003 )
declare @cCT2_HIST Char( 'CT2_HIST' )
declare @cCT2_CCD Char( 'CT2_CCD' )
declare @cCT2_CCC Char( 'CT2_CCC' )
declare @cCT2_ITEMD Char( 'CT2_ITEMD' )
declare @cCT2_ITEMC Char( 'CT2_ITEMC' )
declare @cCT2_CLVLDB Char( 'CT2_CLVLDB' )
declare @cCT2_CLVLCR Char( 'CT2_CLVLCR' )
declare @cCT2_ATIVDE Char( 040 )
declare @cCT2_ATIVCR Char( 040 )
declare @cCT2_EMPORI Char( 002 )
declare @cCT2_FILORI Char( 'CT2_FILIAL' )
declare @cCT2_INTERC Char( 001 )
declare @cCT2_IDENTC Char( 050 )
declare @cCT2_TPSALD Char( 'CT2_TPSALD' )
declare @cCT2_SEQUEN Char( 010 )
declare @cCT2_MANUAL Char( 001 )
declare @cCT2_ORIGEM Char( 100 )
declare @cCT2_ROTINA Char( 010 )
declare @cCT2_AGLUT Char( 001 )
declare @cCT2_LP Char( 003 )
declare @cCT2_SEQHIS Char( 003 )
declare @cCT2_SEQLAN Char( 003 )
declare @cCT2_DTVENC Char( 008 )
declare @cCT2_SLBASE Char( 001 )
declare @cCT2_DTLP Char( 008 )
declare @cCT2_DATATX Char( 008 )
declare @nCT2_TAXA Float
declare @nCT2_VLR01 Float
declare @nCT2_VLR02 Float
declare @nCT2_VLR03 Float
declare @nCT2_VLR04 Float
declare @nCT2_VLR05 Float
declare @cCT2_CRCONV Char( 001 )
declare @cCT2_CRITER Char( 004 )
declare @cCT2_KEY Char( 200 )
declare @cCT2_SEGOFI Char( 010 )
declare @cCT2_DTCV3 Char( 08 )
declare @cCT2_SEQIDX Char( 005 )
declare @cCT2_CONFST Char( 001 )
declare @cCT2_OBSCNF Char( 040 )
declare @cCT2_USRCNF Char( 015 )
declare @cCT2_DTCONF Char( 008 )
declare @cCT2_HRCONF Char( 010 )
declare @cCT2_MLTSLD Char( 020 )
declare @cCT2_CTLSLD Char( 001 )
declare @cCT2_CODPAR Char( 006 )
declare @cCT2_NODIA Char( 010 )
declare @cCT2_DIACTB Char( 002 )
declare @cCT2_CODCLI Char( 006 )
declare @cCT2_CODFOR Char( 006 )
declare @cCT2_AT01DB Char( 020 )
declare @cCT2_AT01CR Char( 020 )
declare @cCT2_AT02DB Char( 020 )
declare @cCT2_AT02CR Char( 020 )
declare @cCT2_AT03DB Char( 020 )
declare @cCT2_AT03CR Char( 020 )
declare @cCT2_AT04DB Char( 020 )
declare @cCT2_AT04CR Char( 020 )
declare @cCT2_MOEFDB Char( 002 )
declare @cCT2_MOEFCR Char( 002 )
declare @cCT2_USERGI Char( 017 )
declare @cCT2_USERGA Char( 017 )
declare @cCT2_LANCSU Char( 003 )
declare @cCT2_GRPDIA Char( 003 )
declare @cCT2_LANC Char( 015 )
declare @cCT2_CTRLSD Char( 001 )
##FIELDP01( 'CT2.CT2_EC05DB' )
declare @cCT2_EC05DB Char( 006 )
declare @cCT2_EC05CR Char( 006 )
##ENDFIELDP01
##FIELDP02( 'CT2.CT2_EC06DB' )
declare @cCT2_EC06DB Char( 006 )
declare @cCT2_EC06CR Char( 006 )
##ENDFIELDP02
##FIELDP03( 'CT2.CT2_EC07DB' )
declare @cCT2_EC07DB Char( 006 )
declare @cCT2_EC07CR Char( 006 )
##ENDFIELDP03
##FIELDP04( 'CT2.CT2_EC08DB' )
declare @cCT2_EC08DB Char( 006 )
declare @cCT2_EC08CR Char( 006 )
##ENDFIELDP04
##FIELDP05( 'CT2.CT2_EC09DB' )
declare @cCT2_EC09DB Char( 006 )
declare @cCT2_EC09CR Char( 006 )
##ENDFIELDP05
##FIELDP06( 'CT2.CT2_VLR06' )
declare @nCT2_VLR06 Float
##ENDFIELDP06
##FIELDP07( 'CT2.CT2_VLR07' )
declare @nCT2_VLR07 Float
##ENDFIELDP07
declare @cLoteIn Char( 006 )
declare @cSbLoteIn Char( 003 )
declare @cDocIn Char( 006 )
declare @cLinhaIn Char( 003 )
declare @cSeqLan Char( 003 )
declare @cCT2_SEQLANOUT Char( 003 )
declare @cMltSldAux VarChar( 20 )
declare @cChar VarChar( 01 )
declare @iX Integer
declare @iRecnoCT2 Integer
declare @iRecnoAux Integer
declare @iRecno Integer
declare @iRecnoDel Integer
declare @cDc Char( 01 )
declare @cMoedaAnt Char( 002 )
declare @nValorAnt Float
declare @lPrim Char( 01 )
declare @lProx Char( 01 )
declare @nCont Integer
declare @cTpSald Char( 001 )
declare @nTamHist Integer

BEGIN
   SELECT @OUT_RESULT  = '0' 
   SELECT @nTamHist  = 40 
   SELECT @cAux  = 'CT2' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFil_CT2 output 
   SELECT @cAux  = 'CT8' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFil_CT8 output 
   SELECT @iRecnoCT2  = 0 
   SELECT @cLoteIn  = @IN_LOTE 
   SELECT @cSbLoteIn  = @IN_SBLOTE 
   SELECT @cDocIn  = '' 
   SELECT @cLinhaIn  = '' 
   SELECT @cMoedaAnt  = '' 
   SELECT @lPrim  = '1' 
   SELECT @nValorAnt  = 0 
   SELECT @cTpSald  = '' 
   SELECT @cCT2_SEQLANOUT  = '' 
   SELECT @iRecnoDel  = 0 
   -- Cursor declaration CUR_MOVTO
   DECLARE CUR_MOVTO insensitive  CURSOR FOR 
   SELECT CT2_FILIAL , CT2_DATA , CT2_LOTE , CT2_SBLOTE , CT2_DOC , CT2_LINHA , CT2_MOEDLC , CT2_DC , CT2_DEBITO , CT2_CREDIT , 
   CT2_DCD , CT2_DCC , CT2_VALOR , CT2_MOEDAS , CT2_HP , CT2_HIST , CT2_CCD , CT2_CCC , CT2_ITEMD , CT2_ITEMC , CT2_CLVLDB , 
   CT2_CLVLCR , CT2_ATIVDE , CT2_ATIVCR , CT2_EMPORI , CT2_FILORI , CT2_INTERC , CT2_IDENTC , CT2_TPSALD , CT2_SEQUEN , CT2_MANUAL , 
   CT2_ORIGEM , CT2_ROTINA , CT2_AGLUT , CT2_LP , CT2_SEQHIS , CT2_SEQLAN , CT2_DTVENC , CT2_SLBASE , CT2_DTLP , CT2_DATATX , 
   CT2_TAXA , CT2_VLR01 , CT2_VLR02 , CT2_VLR03 , CT2_VLR04 , CT2_VLR05 , CT2_CRCONV , CT2_CRITER , CT2_KEY , CT2_SEGOFI , 
   CT2_DTCV3 , CT2_SEQIDX , CT2_CONFST , CT2_OBSCNF , CT2_USRCNF , CT2_DTCONF , CT2_HRCONF , CT2_MLTSLD , CT2_CTLSLD , CT2_CODPAR , 
   CT2_NODIA , CT2_DIACTB , CT2_CODCLI , CT2_CODFOR , CT2_AT01DB , CT2_AT01CR , CT2_AT02DB , CT2_AT02CR , CT2_AT03DB , CT2_AT03CR , 
   CT2_AT04DB , CT2_AT04CR , CT2_MOEFDB , CT2_MOEFCR , CT2_USERGI , CT2_USERGA , CT2_LANCSU , CT2_GRPDIA , CT2_LANC , CT2_CTRLSD 
   ##FIELDP08( 'CT2.CT2_EC05DB' )
   ,CT2_EC05DB , CT2_EC05CR 
   ##ENDFIELDP08
   ##FIELDP09( 'CT2.CT2_EC06DB' )
   ,CT2_EC06DB , CT2_EC06CR
   ##ENDFIELDP09
   ##FIELDP10( 'CT2.CT2_EC07DB' )
   ,CT2_EC07DB , CT2_EC07CR 
   ##ENDFIELDP10
   ##FIELDP11( 'CT2.CT2_EC08DB' )
   ,CT2_EC08DB , CT2_EC08CR  
   ##ENDFIELDP11
   ##FIELDP12( 'CT2.CT2_EC09DB' )
   ,CT2_EC09DB , CT2_EC09CR 
   ##ENDFIELDP12
   ##FIELDP13( 'CT2.CT2_VLR06' )
   ,CT2_VLR06 
   ##ENDFIELDP13
   ##FIELDP14( 'CT2.CT2_VLR07' )
   ,CT2_VLR07
   ##ENDFIELDP14
   , R_E_C_N_O_
   FROM CT2### 
   WHERE CT2_FILIAL  = @cFil_CT2  and CT2_DATA  between @IN_DATAINI and @IN_DATAFIM  and  ( (CT2_TPSALD  = @IN_TPSORIG 
   and @IN_LTPSALD  = '1'  and CT2_MLTSLD  = ' ' )  or  (@IN_LTPSALD  = '0'  and CT2_MLTSLD  != ' ' ) )  and  ( (@IN_LTDSMOEDA  = '0' 
   and CT2_MOEDLC  = @IN_MOEDA )  or @IN_LTDSMOEDA  = '1' )  and  (CT2_CTLSLD  != '2' )  and D_E_L_E_T_  = ' ' 
   FOR READ ONLY 
    
   OPEN CUR_MOVTO
   FETCH CUR_MOVTO 
    INTO @cCT2_FILIAL , @cCT2_DATA , @cCT2_LOTE , @cCT2_SBLOTE , @cCT2_DOC , @cCT2_LINHA , @cCT2_MOEDLC , @cCT2_DC , @cCT2_DEBITO , 
   @cCT2_CREDIT , @cCT2_DCD , @cCT2_DCC , @nCT2_VALOR , @cCT2_MOEDAS , @cCT2_HP , @cCT2_HIST , @cCT2_CCD , @cCT2_CCC , @cCT2_ITEMD , 
   @cCT2_ITEMC , @cCT2_CLVLDB , @cCT2_CLVLCR , @cCT2_ATIVDE , @cCT2_ATIVCR , @cCT2_EMPORI , @cCT2_FILORI , @cCT2_INTERC , 
   @cCT2_IDENTC , @cCT2_TPSALD , @cCT2_SEQUEN , @cCT2_MANUAL , @cCT2_ORIGEM , @cCT2_ROTINA , @cCT2_AGLUT , @cCT2_LP , @cCT2_SEQHIS , 
   @cCT2_SEQLAN , @cCT2_DTVENC , @cCT2_SLBASE , @cCT2_DTLP , @cCT2_DATATX , @nCT2_TAXA , @nCT2_VLR01 , @nCT2_VLR02 , @nCT2_VLR03 , 
   @nCT2_VLR04 , @nCT2_VLR05 , @cCT2_CRCONV , @cCT2_CRITER , @cCT2_KEY , @cCT2_SEGOFI , @cCT2_DTCV3 , @cCT2_SEQIDX , @cCT2_CONFST , 
   @cCT2_OBSCNF , @cCT2_USRCNF , @cCT2_DTCONF , @cCT2_HRCONF , @cCT2_MLTSLD , @cCT2_CTLSLD , @cCT2_CODPAR , @cCT2_NODIA , 
   @cCT2_DIACTB , @cCT2_CODCLI , @cCT2_CODFOR , @cCT2_AT01DB , @cCT2_AT01CR , @cCT2_AT02DB , @cCT2_AT02CR , @cCT2_AT03DB , 
   @cCT2_AT03CR , @cCT2_AT04DB , @cCT2_AT04CR , @cCT2_MOEFDB , @cCT2_MOEFCR , @cCT2_USERGI , @cCT2_USERGA , @cCT2_LANCSU , 
   @cCT2_GRPDIA , @cCT2_LANC , @cCT2_CTRLSD 
   ##FIELDP15( 'CT2.CT2_EC05DB' )
   ,@cCT2_EC05DB , @cCT2_EC05CR
   ##ENDFIELDP15
   ##FIELDP16( 'CT2.CT2_EC06DB' )
   ,@cCT2_EC06DB , @cCT2_EC06CR
   ##ENDFIELDP16
   ##FIELDP17( 'CT2.CT2_EC07DB' )
   ,@cCT2_EC07DB , @cCT2_EC07CR
   ##ENDFIELDP17
   ##FIELDP18( 'CT2.CT2_EC08DB' )
   ,@cCT2_EC08DB , @cCT2_EC08CR
   ##ENDFIELDP18
   ##FIELDP19( 'CT2.CT2_EC09DB' )
   ,@cCT2_EC09DB , @cCT2_EC09CR
   ##ENDFIELDP19
   ##FIELDP20( 'CT2.CT2_VLR06' )
   ,@nCT2_VLR06
   ##ENDFIELDP20
   ##FIELDP21( 'CT2.CT2_VLR07' )
   ,@nCT2_VLR07
   ##ENDFIELDP21
   ,@iRecno 
   WHILE (@@fetch_status  = 0 )
   BEGIN
      IF @IN_LHIST  = 2 
      BEGIN 
         SELECT @cCT2_HIST  = SUBSTRING ( CT8_DESC , 1 , @nTamHist )
           FROM CT8### 
           WHERE CT8_FILIAL  = @cFil_CT8  and CT8_HIST  = @IN_CODHIST  and D_E_L_E_T_  = ' ' 
      END 
      SELECT @cMltSldAux  = '' 
      IF @IN_LCOPIA  = 2 
      BEGIN 
         SELECT @iX  = 1 
         WHILE (@iX  <= LEN ( @cCT2_MLTSLD ))
         BEGIN
            SELECT @cChar  = '' 
            SELECT @cChar  = SUBSTRING ( @cCT2_MLTSLD , @iX , 1 )
            IF @cChar  = @cCT2_TPSALD 
            BEGIN 
               SELECT @cChar  = '' 
            END 
            SELECT @cMltSldAux  = @cMltSldAux  + @cChar 
            SELECT @iX  = @iX  + 1 
         END 
      END 
      ELSE 
      BEGIN 
         IF  (@cCT2_CTLSLD  = ' '  or @cCT2_CTLSLD  = '0' )  and @cCT2_MLTSLD  = ' ' 
         BEGIN 
            SELECT @cMltSldAux  = @IN_TPSDEST 
         END 
      END 
      IF @IN_LLOTE  = 2 
      BEGIN 
         IF @lPrim  = '1' 
         BEGIN 
            SELECT @cCT2_LOTE  = @IN_LOTE 
            SELECT @cCT2_SBLOTE  = @IN_SBLOTE 
            SELECT @lPrim  = '0' 
         END 
         ELSE 
         BEGIN 
            SELECT @cCT2_LOTE  = @cLoteIn 
            SELECT @cCT2_SBLOTE  = @cSbLoteIn 
         END 
      END 
      SELECT @cSeqLan  = MAX ( CT2_SEQLAN )
        FROM CT2### 
        WHERE CT2_FILIAL  = @cCT2_FILIAL  and CT2_DATA  = @cCT2_DATA  and CT2_LOTE  = @cCT2_LOTE  and CT2_SBLOTE  = @cCT2_SBLOTE 
       and CT2_DOC  = @cCT2_DOC  and D_E_L_E_T_  = ' ' 
      SELECT @iX  = 1 
      SELECT @iRecnoCT2  = null 
      SELECT @cChar  = SUBSTRING ( @cMltSldAux , @iX , 1 )
      WHILE (@iX  <= LEN ( @cMltSldAux ) and @cChar  != '#' )
      BEGIN
         IF @cChar  != @cCT2_TPSALD 
         BEGIN 
            SELECT @cLoteIn  = @cCT2_LOTE 
            SELECT @cSbLoteIn  = @cCT2_SBLOTE 
            SELECT @cDocIn  = @cCT2_DOC 
            SELECT @cLinhaIn  = @cCT2_LINHA 
            IF @cCT2_DC  <> '4' 
            BEGIN 
               SELECT @cCT2_SEQLANOUT  = @cSeqLan 
               EXEC MSSOMA1 @cSeqLan , '1' , @cCT2_SEQLANOUT output 
            END 
            EXEC CTB308_## @IN_MAXLINHA , @cLoteIn , @cSbLoteIn , @cDocIn , @cLinhaIn , @cCT2_LOTE output , @cCT2_SBLOTE output , 
            @cCT2_DOC output , @cCT2_LINHA output 
            SELECT @lProx  = '1' 
            WHILE (@lProx  = '1' )
            BEGIN
               SELECT @iRecnoAux  = MIN ( R_E_C_N_O_ )
                 FROM CT2### 
                 WHERE CT2_FILIAL  = @cCT2_FILIAL  and CT2_DATA  = @cCT2_DATA  and CT2_LOTE  = @cCT2_LOTE  and CT2_SBLOTE  = @cCT2_SBLOTE 
                and CT2_DOC  = @cCT2_DOC  and CT2_LINHA  = @cCT2_LINHA  and CT2_EMPORI  = @cCT2_EMPORI  and CT2_FILORI  = @cCT2_FILORI 
                and CT2_MOEDLC  = @cCT2_MOEDLC  and CT2_SEQIDX  = @cCT2_SEQIDX  and D_E_L_E_T_  = ' ' 
               IF @iRecnoAux is null 
               BEGIN 
                  SELECT @lProx  = '0' 
               END 
               ELSE 
               BEGIN 
                  SELECT @cLoteIn  = @cCT2_LOTE 
                  SELECT @cSbLoteIn  = @cCT2_SBLOTE 
                  SELECT @cDocIn  = @cCT2_DOC 
                  SELECT @cLinhaIn  = @cCT2_LINHA 
                  IF @cCT2_DC  <> '4' 
                  BEGIN 
                     SELECT @cCT2_SEQLANOUT  = @cSeqLan 
                     EXEC MSSOMA1 @cSeqLan , '1' , @cCT2_SEQLANOUT output 
                  END 
                  EXEC CTB308_## @IN_MAXLINHA , @cLoteIn , @cSbLoteIn , @cDocIn , @cLinhaIn , @cCT2_LOTE output , @cCT2_SBLOTE output , 
                  @cCT2_DOC output , @cCT2_LINHA output 
               END 
            END 
            SELECT @cCT2_CTLSLD  = '2' 
            SELECT @cTpSald  = @cChar 
            
            --uniquekey
            ##UNIQUEKEY_START
				SELECT @iRecnoCT2 = Isnull(Min(R_E_C_N_O_), 0)
				FROM CT2###
				WHERE CT2_FILIAL = @cCT2_FILIAL
				AND CT2_DATA = @cCT2_DATA
				AND CT2_LOTE = @cCT2_LOTE
				AND CT2_SBLOTE = @cCT2_SBLOTE
				AND CT2_DOC = @cCT2_DOC
				AND CT2_LINHA = @cCT2_LINHA
				AND CT2_EMPORI = @cCT2_EMPORI
				AND CT2_FILORI = @cCT2_FILORI
				AND CT2_MOEDLC = @cCT2_MOEDLC
				AND CT2_SEQIDX = @cCT2_SEQIDX
				AND D_E_L_E_T_ = ' ' 
            ##UNIQUEKEY_END
            
            IF @iRecnoCT2 = 0
            BEGIN
                  SELECT @iRecnoCT2  = COALESCE ( MAX ( R_E_C_N_O_ ), 0 )
                  FROM CT2### 
                  SELECT @iRecnoCT2  = @iRecnoCT2  + 1 
                  --tratarecno
                  ##TRATARECNO @iRecnoCT2\
                  INSERT INTO CT2### (CT2_FILIAL , CT2_DATA , CT2_LOTE , CT2_SBLOTE , CT2_DOC , CT2_LINHA , CT2_MOEDLC , CT2_DC , 
                  CT2_DEBITO , CT2_CREDIT , CT2_DCD , CT2_DCC , CT2_VALOR , CT2_MOEDAS , CT2_HP , CT2_HIST , CT2_CCD , CT2_CCC , 
                  CT2_ITEMD , CT2_ITEMC , CT2_CLVLDB , CT2_CLVLCR , CT2_ATIVDE , CT2_ATIVCR , CT2_EMPORI , CT2_FILORI , CT2_INTERC , 
                  CT2_IDENTC , CT2_TPSALD , CT2_SEQUEN , CT2_MANUAL , CT2_ORIGEM , CT2_ROTINA , CT2_AGLUT , CT2_LP , CT2_SEQHIS , 
                  CT2_SEQLAN , CT2_DTVENC , CT2_SLBASE , CT2_DTLP , CT2_DATATX , CT2_TAXA , CT2_VLR01 , CT2_VLR02 , CT2_VLR03 , 
                  CT2_VLR04 , CT2_VLR05 , CT2_CRCONV , CT2_CRITER , CT2_KEY , CT2_SEGOFI , CT2_DTCV3 , CT2_SEQIDX , CT2_CONFST , 
                  CT2_OBSCNF , CT2_USRCNF , CT2_DTCONF , CT2_HRCONF , CT2_MLTSLD , CT2_CTLSLD , CT2_CODPAR , CT2_NODIA , CT2_DIACTB , 
                  CT2_CODCLI , CT2_CODFOR , CT2_AT01DB , CT2_AT01CR , CT2_AT02DB , CT2_AT02CR , CT2_AT03DB , CT2_AT03CR , CT2_AT04DB , 
                  CT2_AT04CR , CT2_MOEFDB , CT2_MOEFCR , CT2_USERGI , CT2_USERGA , CT2_LANCSU , CT2_GRPDIA , CT2_LANC , CT2_CTRLSD
                  ##FIELDP22( 'CT2.CT2_EC05DB' )
                  ,CT2_EC05DB , CT2_EC05CR 
                  ##ENDFIELDP22
                  ##FIELDP23( 'CT2.CT2_EC06DB' )
                  ,CT2_EC06DB , CT2_EC06CR
                  ##ENDFIELDP23
                  ##FIELDP24( 'CT2.CT2_EC07DB' )
                  ,CT2_EC07DB , CT2_EC07CR 
                  ##ENDFIELDP24
                  ##FIELDP25( 'CT2.CT2_EC08DB' )
                  ,CT2_EC08DB , CT2_EC08CR  
                  ##ENDFIELDP25
                  ##FIELDP26( 'CT2.CT2_EC09DB' )
                  ,CT2_EC09DB , CT2_EC09CR 
                  ##ENDFIELDP26
                  ##FIELDP27( 'CT2.CT2_VLR06' )
                  ,CT2_VLR06 
                  ##ENDFIELDP27
                  ##FIELDP28( 'CT2.CT2_VLR07' )
                  ,CT2_VLR07
                  ##ENDFIELDP28
                  ,R_E_C_N_O_ ) 
                  VALUES (@cCT2_FILIAL , @cCT2_DATA , @cCT2_LOTE , @cCT2_SBLOTE , @cCT2_DOC , @cCT2_LINHA , @cCT2_MOEDLC , @cCT2_DC , 
                  @cCT2_DEBITO , @cCT2_CREDIT , @cCT2_DCD , @cCT2_DCC , 0 , @cCT2_MOEDAS , @cCT2_HP , @cCT2_HIST , @cCT2_CCD , 
                  @cCT2_CCC , @cCT2_ITEMD , @cCT2_ITEMC , @cCT2_CLVLDB , @cCT2_CLVLCR , @cCT2_ATIVDE , @cCT2_ATIVCR , @cCT2_EMPORI , 
                  @cCT2_FILORI , @cCT2_INTERC , @cCT2_IDENTC , @cTpSald , @cCT2_SEQUEN , @cCT2_MANUAL , @cCT2_ORIGEM , @cCT2_ROTINA , 
                  @cCT2_AGLUT , @cCT2_LP , @cCT2_SEQHIS , @cCT2_SEQLANOUT , @cCT2_DTVENC , @cCT2_SLBASE , @cCT2_DTLP , @cCT2_DATATX , 
                  0 , 0 , 0 , 0 , 0 , 0 , @cCT2_CRCONV , @cCT2_CRITER , 
                  @cCT2_KEY , @cCT2_SEGOFI , @cCT2_DTCV3 , @cCT2_SEQIDX , @cCT2_CONFST , @cCT2_OBSCNF , @cCT2_USRCNF , @cCT2_DTCONF , 
                  @cCT2_HRCONF , @cCT2_MLTSLD , @cCT2_CTLSLD , @cCT2_CODPAR , @cCT2_NODIA , @cCT2_DIACTB , @cCT2_CODCLI , @cCT2_CODFOR , 
                  @cCT2_AT01DB , @cCT2_AT01CR , @cCT2_AT02DB , @cCT2_AT02CR , @cCT2_AT03DB , @cCT2_AT03CR , @cCT2_AT04DB , @cCT2_AT04CR , 
                  @cCT2_MOEFDB , @cCT2_MOEFCR , @cCT2_USERGI , @cCT2_USERGA , @cCT2_LANCSU , @cCT2_GRPDIA , @cCT2_LANC , @cCT2_CTRLSD
                  ##FIELDP29( 'CT2.CT2_EC05DB' )
                  ,@cCT2_EC05DB , @cCT2_EC05CR
                  ##ENDFIELDP29
                  ##FIELDP30( 'CT2.CT2_EC06DB' )
                  ,@cCT2_EC06DB , @cCT2_EC06CR
                  ##ENDFIELDP30
                  ##FIELDP31( 'CT2.CT2_EC07DB' )
                  ,@cCT2_EC07DB , @cCT2_EC07CR
                  ##ENDFIELDP31
                  ##FIELDP32( 'CT2.CT2_EC08DB' )
                  ,@cCT2_EC08DB , @cCT2_EC08CR
                  ##ENDFIELDP32
                  ##FIELDP33( 'CT2.CT2_EC09DB' )
                  ,@cCT2_EC09DB , @cCT2_EC09CR
                  ##ENDFIELDP33
                  ##FIELDP34( 'CT2.CT2_VLR06' )
                  ,0
                  ##ENDFIELDP34
                  ##FIELDP35( 'CT2.CT2_VLR07' )
                  ,0
                  ##ENDFIELDP35  
                  ,@iRecnoCT2 )
                  ##FIMTRATARECNO
            END
            --update
            UPDATE CT2###
				SET CT2_VALOR = CT2_VALOR + @nCT2_VALOR
					,CT2_TAXA = CT2_TAXA + @nCT2_TAXA
					,CT2_VLR01 = CT2_VLR01 + @nCT2_VLR01
					,CT2_VLR02 = CT2_VLR02 + @nCT2_VLR02
					,CT2_VLR03 = CT2_VLR03 + @nCT2_VLR03
					,CT2_VLR04 = CT2_VLR04 + @nCT2_VLR04
					,CT2_VLR05 = CT2_VLR05 + @nCT2_VLR05 
               ##FIELDP36( 'CT2.CT2_VLR06' )
					,CT2_VLR06 = CT2_VLR06 + @nCT2_VLR06 
               ##ENDFIELDP36 
               ##FIELDP37( 'CT2.CT2_VLR07' )
					,CT2_VLR07 = CT2_VLR07 + @nCT2_VLR07 
               ##ENDFIELDP37
				WHERE R_E_C_N_O_ = @iRecnoCT2

            IF @IN_LTDSMOEDA  = '0'  and @cCT2_MOEDLC  != '01' 
            BEGIN 
               SELECT @cMoedaAnt  = @cCT2_MOEDLC 
               SELECT @nValorAnt  = @nCT2_VALOR 
               SELECT @cCT2_MOEDLC  = '01' 
               SELECT @nCT2_VALOR  = 0 
               SELECT @cCT2_CTLSLD  = '2'
               --uniquekey
               ##UNIQUEKEY_START
				   SELECT @iRecnoCT2 = Isnull(Min(R_E_C_N_O_), 0)
				   FROM CT2###
				   WHERE CT2_FILIAL = @cCT2_FILIAL
					AND CT2_DATA = @cCT2_DATA
					AND CT2_LOTE = @cCT2_LOTE
					AND CT2_SBLOTE = @cCT2_SBLOTE
					AND CT2_DOC = @cCT2_DOC
					AND CT2_LINHA = @cCT2_LINHA
					AND CT2_EMPORI = @cCT2_EMPORI
					AND CT2_FILORI = @cCT2_FILORI
					AND CT2_MOEDLC = @cCT2_MOEDLC
					AND CT2_SEQIDX = @cCT2_SEQIDX
					AND D_E_L_E_T_ = ' ' 
               ##UNIQUEKEY_END

               IF @iRecnoCT2 = 0
               BEGIN
                  SELECT @iRecnoCT2  = COALESCE ( MAX ( R_E_C_N_O_ ), 0 )
                  FROM CT2### 
                  SELECT @iRecnoCT2  = @iRecnoCT2  + 1 
                  --tratarecno
                  ##TRATARECNO @iRecnoCT2\
                  INSERT INTO CT2### (CT2_FILIAL , CT2_DATA , CT2_LOTE , CT2_SBLOTE , CT2_DOC , CT2_LINHA , CT2_MOEDLC , CT2_DC , 
                  CT2_DEBITO , CT2_CREDIT , CT2_DCD , CT2_DCC , CT2_VALOR , CT2_MOEDAS , CT2_HP , CT2_HIST , CT2_CCD , CT2_CCC , 
                  CT2_ITEMD , CT2_ITEMC , CT2_CLVLDB , CT2_CLVLCR , CT2_ATIVDE , CT2_ATIVCR , CT2_EMPORI , CT2_FILORI , CT2_INTERC , 
                  CT2_IDENTC , CT2_TPSALD , CT2_SEQUEN , CT2_MANUAL , CT2_ORIGEM , CT2_ROTINA , CT2_AGLUT , CT2_LP , CT2_SEQHIS , 
                  CT2_SEQLAN , CT2_DTVENC , CT2_SLBASE , CT2_DTLP , CT2_DATATX , CT2_TAXA , CT2_VLR01 , CT2_VLR02 , CT2_VLR03 , 
                  CT2_VLR04 , CT2_VLR05 , CT2_CRCONV , CT2_CRITER , CT2_KEY , CT2_SEGOFI , CT2_DTCV3 , CT2_SEQIDX , CT2_CONFST , 
                  CT2_OBSCNF , CT2_USRCNF , CT2_DTCONF , CT2_HRCONF , CT2_MLTSLD , CT2_CTLSLD , CT2_CODPAR , CT2_NODIA , CT2_DIACTB , 
                  CT2_CODCLI , CT2_CODFOR , CT2_AT01DB , CT2_AT01CR , CT2_AT02DB , CT2_AT02CR , CT2_AT03DB , CT2_AT03CR , CT2_AT04DB , 
                  CT2_AT04CR , CT2_MOEFDB , CT2_MOEFCR , CT2_USERGI , CT2_USERGA , CT2_LANCSU , CT2_GRPDIA , CT2_LANC , CT2_CTRLSD 
                  ##FIELDP38( 'CT2.CT2_EC05DB' )
                  ,CT2_EC05DB , CT2_EC05CR 
                  ##ENDFIELDP38
                  ##FIELDP39( 'CT2.CT2_EC06DB' )
                  ,CT2_EC06DB , CT2_EC06CR
                  ##ENDFIELDP39
                  ##FIELDP40( 'CT2.CT2_EC07DB' )
                  ,CT2_EC07DB , CT2_EC07CR 
                  ##ENDFIELDP40
                  ##FIELDP41( 'CT2.CT2_EC08DB' )
                  ,CT2_EC08DB , CT2_EC08CR  
                  ##ENDFIELDP41
                  ##FIELDP42( 'CT2.CT2_EC09DB' )
                  ,CT2_EC09DB , CT2_EC09CR 
                  ##ENDFIELDP42
                  ##FIELDP43( 'CT2.CT2_VLR06' )
                  ,CT2_VLR06 
                  ##ENDFIELDP43
                  ##FIELDP44( 'CT2.CT2_VLR07' )
                  ,CT2_VLR07
                  ##ENDFIELDP44
                  ,R_E_C_N_O_) 
                  VALUES (@cCT2_FILIAL , @cCT2_DATA , @cCT2_LOTE , @cCT2_SBLOTE , @cCT2_DOC , @cCT2_LINHA , @cCT2_MOEDLC , @cCT2_DC , 
                  @cCT2_DEBITO , @cCT2_CREDIT , @cCT2_DCD , @cCT2_DCC , 0 , @cCT2_MOEDAS , @cCT2_HP , @cCT2_HIST , 
                  @cCT2_CCD , @cCT2_CCC , @cCT2_ITEMD , @cCT2_ITEMC , @cCT2_CLVLDB , @cCT2_CLVLCR , @cCT2_ATIVDE , @cCT2_ATIVCR , 
                  @cCT2_EMPORI , @cCT2_FILORI , @cCT2_INTERC , @cCT2_IDENTC , @cTpSald , @cCT2_SEQUEN , @cCT2_MANUAL , @cCT2_ORIGEM , 
                  @cCT2_ROTINA , @cCT2_AGLUT , @cCT2_LP , @cCT2_SEQHIS , @cCT2_SEQLANOUT , @cCT2_DTVENC , @cCT2_SLBASE , @cCT2_DTLP , 
                  @cCT2_DATATX , 0, 0 , 0 , 0 , 0 , 0 , @cCT2_CRCONV , 
                  @cCT2_CRITER , @cCT2_KEY , @cCT2_SEGOFI , @cCT2_DTCV3 , @cCT2_SEQIDX , @cCT2_CONFST , @cCT2_OBSCNF , @cCT2_USRCNF , 
                  @cCT2_DTCONF , @cCT2_HRCONF , @cCT2_MLTSLD , @cCT2_CTLSLD , @cCT2_CODPAR , @cCT2_NODIA , @cCT2_DIACTB , @cCT2_CODCLI , 
                  @cCT2_CODFOR , @cCT2_AT01DB , @cCT2_AT01CR , @cCT2_AT02DB , @cCT2_AT02CR , @cCT2_AT03DB , @cCT2_AT03CR , @cCT2_AT04DB , 
                  @cCT2_AT04CR , @cCT2_MOEFDB , @cCT2_MOEFCR , @cCT2_USERGI , @cCT2_USERGA , @cCT2_LANCSU , @cCT2_GRPDIA , @cCT2_LANC , 
                  @cCT2_CTRLSD 
                  ##FIELDP45( 'CT2.CT2_EC05DB' )
                  ,@cCT2_EC05DB , @cCT2_EC05CR
                  ##ENDFIELDP45
                  ##FIELDP46( 'CT2.CT2_EC06DB' )
                  ,@cCT2_EC06DB , @cCT2_EC06CR
                  ##ENDFIELDP46
                  ##FIELDP47( 'CT2.CT2_EC07DB' )
                  ,@cCT2_EC07DB , @cCT2_EC07CR
                  ##ENDFIELDP47
                  ##FIELDP48( 'CT2.CT2_EC08DB' )
                  ,@cCT2_EC08DB , @cCT2_EC08CR
                  ##ENDFIELDP48
                  ##FIELDP49( 'CT2.CT2_EC09DB' )
                  ,@cCT2_EC09DB , @cCT2_EC09CR
                  ##ENDFIELDP49
                  ##FIELDP50( 'CT2.CT2_VLR06' )
                  ,0
                  ##ENDFIELDP50
                  ##FIELDP51( 'CT2.CT2_VLR07' )
                  ,0
                  ##ENDFIELDP51
                  ,@iRecnoCT2 )
                  ##FIMTRATARECNO
               END      
               --update
               UPDATE CT2###
				   SET CT2_VALOR = CT2_VALOR + @nCT2_VALOR
					,CT2_TAXA = CT2_TAXA + @nCT2_TAXA
					,CT2_VLR01 = CT2_VLR01 + @nCT2_VLR01
					,CT2_VLR02 = CT2_VLR02 + @nCT2_VLR02
					,CT2_VLR03 = CT2_VLR03 + @nCT2_VLR03
					,CT2_VLR04 = CT2_VLR04 + @nCT2_VLR04
					,CT2_VLR05 = CT2_VLR05 + @nCT2_VLR05 
               ##FIELDP52( 'CT2.CT2_VLR06' )
					,CT2_VLR06 = CT2_VLR06 + @nCT2_VLR06 
               ##ENDFIELDP52 
               ##FIELDP53( 'CT2.CT2_VLR07' )
					,CT2_VLR07 = CT2_VLR07 + @nCT2_VLR07 
               ##ENDFIELDP53
				   WHERE R_E_C_N_O_ = @iRecnoCT2

               SELECT @cCT2_MOEDLC  = @cMoedaAnt 
               SELECT @nCT2_VALOR  = ROUND ( @nValorAnt , 2 )
            END 
            IF @cDc  != '4' 
            BEGIN 
               IF @cCT2_DEBITO  != ' ' 
               BEGIN 
                  SELECT @cDc  = 'D' 
                  EXEC CTB305_## @IN_FILIAL , @cCT2_DATA , @cCT2_MOEDLC , @cChar , @nCT2_VALOR , @cCT2_DEBITO , @cDc 
               END 
               IF @cCT2_CCD  != ' ' 
               BEGIN 
                  SELECT @cDc  = 'D' 
                  EXEC CTB304_## @IN_FILIAL , @cCT2_DATA , @cCT2_MOEDLC , @cChar , @nCT2_VALOR , @cCT2_DEBITO , @cCT2_CCD , 
                  @cDc 
               END 
               IF @cCT2_ITEMD  != ' ' 
               BEGIN 
                  SELECT @cDc  = 'D' 
                  EXEC CTB303_## @IN_FILIAL , @cCT2_DATA , @cCT2_MOEDLC , @cChar , @nCT2_VALOR , @cCT2_DEBITO , @cCT2_CCD , 
                  @cCT2_ITEMD , @cDc 
               END 
               IF @cCT2_CLVLDB  != ' ' 
               BEGIN 
                  SELECT @cDc  = 'D' 
                  EXEC CTB302_## @IN_FILIAL , @cCT2_DATA , @cCT2_MOEDLC , @cChar , @nCT2_VALOR , @cCT2_DEBITO , @cCT2_CCD , 
                  @cCT2_ITEMD , @cCT2_CLVLDB , @cDc 
               END 
               IF @cCT2_CREDIT  != ' ' 
               BEGIN 
                  SELECT @cDc  = 'C' 
                  EXEC CTB305_## @IN_FILIAL , @cCT2_DATA , @cCT2_MOEDLC , @cChar , @nCT2_VALOR , @cCT2_CREDIT , @cDc 
               END 
               IF @cCT2_CCC  != ' ' 
               BEGIN 
                  SELECT @cDc  = 'C' 
                  EXEC CTB304_## @IN_FILIAL , @cCT2_DATA , @cCT2_MOEDLC , @cChar , @nCT2_VALOR , @cCT2_CREDIT , @cCT2_CCC , 
                  @cDc 
               END 
               IF @cCT2_ITEMC  != ' ' 
               BEGIN 
                  SELECT @cDc  = 'C' 
                  EXEC CTB303_## @IN_FILIAL , @cCT2_DATA , @cCT2_MOEDLC , @cChar , @nCT2_VALOR , @cCT2_CREDIT , @cCT2_CCC , 
                  @cCT2_ITEMC , @cDc 
               END 
               IF @cCT2_CLVLCR  != ' ' 
               BEGIN 
                  SELECT @cDc  = 'C' 
                  EXEC CTB302_## @IN_FILIAL , @cCT2_DATA , @cCT2_MOEDLC , @cChar , @nCT2_VALOR , @cCT2_CREDIT , @cCT2_CCC , 
                  @cCT2_ITEMC , @cCT2_CLVLCR , @cDc 
               END 
            END 
         END 
         --grava CTC
         EXEC CTB309_## @cCT2_FILIAL , @cCT2_DATA , @cCT2_LOTE , @cCT2_SBLOTE , @cCT2_DOC , @cCT2_MOEDLC , @cChar , @nCT2_VALOR , 
         @cCT2_DC, @IN_MV_SOMA 
         SELECT @iX  = @iX  + 1 
         SELECT @cChar  = SUBSTRING ( @cMltSldAux , @iX , 1 )
      END 
      UPDATE CT2### 
         SET CT2_CTLSLD  = '2' 
      WHERE R_E_C_N_O_  = @iRecno 
      SELECT @cLoteIn  = @cCT2_LOTE 
      SELECT @cSbLoteIn  = @cCT2_SBLOTE 
      SELECT @cDocIn  = @cCT2_DOC 
      SELECT @cLinhaIn  = @cCT2_LINHA 
      FETCH CUR_MOVTO 
       INTO @cCT2_FILIAL , @cCT2_DATA , @cCT2_LOTE , @cCT2_SBLOTE , @cCT2_DOC , @cCT2_LINHA , @cCT2_MOEDLC , @cCT2_DC , @cCT2_DEBITO , 
      @cCT2_CREDIT , @cCT2_DCD , @cCT2_DCC , @nCT2_VALOR , @cCT2_MOEDAS , @cCT2_HP , @cCT2_HIST , @cCT2_CCD , @cCT2_CCC , 
      @cCT2_ITEMD , @cCT2_ITEMC , @cCT2_CLVLDB , @cCT2_CLVLCR , @cCT2_ATIVDE , @cCT2_ATIVCR , @cCT2_EMPORI , @cCT2_FILORI , 
      @cCT2_INTERC , @cCT2_IDENTC , @cTpSald , @cCT2_SEQUEN , @cCT2_MANUAL , @cCT2_ORIGEM , @cCT2_ROTINA , @cCT2_AGLUT , 
      @cCT2_LP , @cCT2_SEQHIS , @cCT2_SEQLAN , @cCT2_DTVENC , @cCT2_SLBASE , @cCT2_DTLP , @cCT2_DATATX , @nCT2_TAXA , @nCT2_VLR01 , 
      @nCT2_VLR02 , @nCT2_VLR03 , @nCT2_VLR04 , @nCT2_VLR05 , @cCT2_CRCONV , @cCT2_CRITER , @cCT2_KEY , @cCT2_SEGOFI , @cCT2_DTCV3 , 
      @cCT2_SEQIDX , @cCT2_CONFST , @cCT2_OBSCNF , @cCT2_USRCNF , @cCT2_DTCONF , @cCT2_HRCONF , @cCT2_MLTSLD , @cCT2_CTLSLD , 
      @cCT2_CODPAR , @cCT2_NODIA , @cCT2_DIACTB , @cCT2_CODCLI , @cCT2_CODFOR , @cCT2_AT01DB , @cCT2_AT01CR , @cCT2_AT02DB , 
      @cCT2_AT02CR , @cCT2_AT03DB , @cCT2_AT03CR , @cCT2_AT04DB , @cCT2_AT04CR , @cCT2_MOEFDB , @cCT2_MOEFCR , @cCT2_USERGI , 
      @cCT2_USERGA , @cCT2_LANCSU , @cCT2_GRPDIA , @cCT2_LANC , @cCT2_CTRLSD 
      ##FIELDP54( 'CT2.CT2_EC05DB' )
      ,@cCT2_EC05DB , @cCT2_EC05CR
      ##ENDFIELDP54
      ##FIELDP55( 'CT2.CT2_EC06DB' )
      ,@cCT2_EC06DB , @cCT2_EC06CR
      ##ENDFIELDP55
      ##FIELDP56( 'CT2.CT2_EC07DB' )
      ,@cCT2_EC07DB , @cCT2_EC07CR
      ##ENDFIELDP56
      ##FIELDP57( 'CT2.CT2_EC08DB' )
      ,@cCT2_EC08DB , @cCT2_EC08CR
      ##ENDFIELDP57
      ##FIELDP58( 'CT2.CT2_EC09DB' )
      ,@cCT2_EC09DB , @cCT2_EC09CR
      ##ENDFIELDP58
      ##FIELDP59( 'CT2.CT2_VLR06' )
      ,@nCT2_VLR06
      ##ENDFIELDP59
      ##FIELDP60( 'CT2.CT2_VLR07' )
      ,@nCT2_VLR07
      ##ENDFIELDP60
      ,@iRecno 
   END 
   CLOSE CUR_MOVTO
   DEALLOCATE CUR_MOVTO
   SELECT @OUT_RESULT  = '1' 
END 

