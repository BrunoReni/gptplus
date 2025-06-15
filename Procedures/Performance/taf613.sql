Create PROCEDURE TAF613_## 
(
	@IN_FILIALLOG  char('C20_FILIAL'),
	@OUT_QTDDOCS integer OutPut
)
as 
/*---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus P12 </v>
    Programa    -  <s> tafa613 </s>
    Descricao   -  <d> Integração de documentos fiscais ( Fiscal X TAF ) </d>
    Entrada     -  <ri> @IN_FILIALLOG
    Saida       -  <ro> @OUT_QTDDOCS - Virada de Saldo dos produtos  </ro>

    Responsavel :  <r> Carlos Eduardo / Adilson </r>
    Data        :  <dt> 27/03/2023 </dt>
--------------------------------------------------------------------------------------------------------------------- */

--Variaveis query TAF
declare @cC20_NUMDOC char('C20_NUMDOC')
declare @cC20_SERIE  char('C20_SERIE' )
declare @cC20_INDOPE char('C20_INDOPE')
declare @cC20_CLIFOR char(15) --C20_CLIFOR
declare @cC20_LOJA   char(02) --C20_LOJA 
declare @cC20_CHVNF  char('C20_CHVNF')
declare @iNumIte 	 integer
declare @iContador	 integer

--Variaveis query ERP
declare @cCODMOD  	 char(06)
declare @cFT_TIPOMOV char('FT_TIPOMOV')
declare @cFT_TIPODOC char(06)
declare @cFT_FORMUL  char('FT_FORMUL')
declare @cCODSIT  	 char(06)
declare @cFT_EMISSAO char(08)
declare @nVLMERC  	 float --F1_VALMERC OU F2_VALVERC
declare @nVLDOC   	 float --F1_VALBRUT OU F2_VALBRUT
declare @cINDPAG  	 char(01)
declare @cINDFRT  	 char(06)
declare @cFT_PRODUTO char('FT_PRODUTO')
declare @cC1L_UM 	 char('C1L_UM')
declare @cFT_CLASFIS char(06)
declare @nFT_QUANT   decimal('FT_QUANT')
declare @nVLITEM  	 decimal('FT_TOTAL')
declare @nFT_TOTAL   decimal('FT_TOTAL')
declare @cIDPROD	 char('C1L_ID')
declare @cFilialLog  char('C20_FILIAL')

begin

	--Chumbando filial para primeiros testes.
	select @cFilialLog = @IN_FILIALLOG
	select @OUT_QTDDOCS = 0
	
	--Atualiza o status de tudo que esta pendete de processamento(1) para em processamento(2)
	update C20### set C20_STATUS = '2'
	where D_E_L_E_T_ = ' '
		and C20_FILIAL = @cFilialLog
		and C20_STATUS = '1'

	--Consulta doscumentos fiscais no TAF que precisa ser buscados no ERP para integração
	declare DADOS_C20 insensitive cursor for
		select 
			C20_NUMDOC,
			C20_SERIE,
			case when C20_INDOPE = '0' then 'E' ELSE 'S' end OPERACAO,
			C20_CLIFOR, 
			C20_LOJA,
			C20_CHVNF 
		from C20### 
		where D_E_L_E_T_ = ' '
			and C20_FILIAL = @cFilialLog
			and C20_STATUS = '2'
	for READ only
	open DADOS_C20
	fetch DADOS_C20 into @cC20_NUMDOC, @cC20_SERIE, @cC20_INDOPE, @cC20_CLIFOR, @cC20_LOJA, @cC20_CHVNF

	--Percorre todos os documentos que precisam ser integrados ao TAF.
	select @iContador = 0
	while ( @@fetch_status = 0 ) begin
		
		--Contador de documentos fiscais.
		select @iContador = @iContador + 1
		--if @iContador = 1 begin
		--	begin tran
		--END

		-- Inicia o controle de gravação
		begin transaction 		
		
		--Consulta os dados do ERP que serão integrados ao TAF.
		declare DADOS_SFT insensitive cursor for
			select 
				--Campos tabela C20
				'000001' CODMOD, --CODMOD,
				case when SFT.FT_TIPOMOV = 'E' then '0' ELSE '1' end FT_TIPOMOV,
				case 
					when SFT.FT_TIPO = 'D' then '000002' --'01'
					when SFT.FT_TIPO = 'I' then '000003' --'02'
					when SFT.FT_TIPO = 'P' then '000004' --'03'
					when SFT.FT_TIPO = 'C' then '000005' --'04'
					when SFT.FT_TIPO = 'B' then '000006' --'05'
					when SFT.FT_TIPO = 'S' then '000007' --'06'
					ELSE '000001' --00
				end FT_TIPODOC,
				case when SFT.FT_FORMUL = 'S' OR ( SFT.FT_FORMUL = ' ' and SFT.FT_TIPOMOV = 'S' ) then '0' else '1' end INDEMI,
				'000001' CODSIT,--CODSIT
				SFT.FT_EMISSAO,
				case when SFT.FT_TIPOMOV = 'S' then SF2.F2_VALMERC ELSE SF1.F1_VALMERC end VALMERC,
				case when SFT.FT_TIPOMOV = 'S' then SF2.F2_VALBRUT ELSE SF1.F1_VALBRUT end VALBRUT,   	  

				'9' INDPAG, --C20_INDPAG
				'1' INDFRT,--C20_INDFRT CINDFRT
				
				--Campos tabela C30
				SFT.FT_PRODUTO,
				--SB1.B1_UM,
				C1L.C1L_UM,
				case 
					when left(SFT.FT_CLASFIS,1) = '0' then '000001' 
					when left(SFT.FT_CLASFIS,1) = '1' then '000002'
					when left(SFT.FT_CLASFIS,1) = '2' then '000003'
					when left(SFT.FT_CLASFIS,1) = '3' then '000004'
					when left(SFT.FT_CLASFIS,1) = '4' then '000005'
					when left(SFT.FT_CLASFIS,1) = '5' then '000006'
					when left(SFT.FT_CLASFIS,1) = '6' then '000007'
					when left(SFT.FT_CLASFIS,1) = '7' then '000008'
					when left(SFT.FT_CLASFIS,1) = '8' then '000009'
					ELSE '000001'
				end FT_CLASFIS,
				SFT.FT_QUANT,
				case
					when SFT.FT_TIPO IN ('I','P','C') then SFT.FT_TOTAL
					when SFT.FT_PRCUNIT = ' ' then SFT.FT_TOTAL
					else SFT.FT_PRCUNIT
				end VLRITEM,
				SFT.FT_TOTAL,
				C1L.C1L_ID
			from SFT### SFT
			--inner join SB1### SB1 ON SB1.B1_FILIAL = @cFilialLog and SB1.B1_COD = SFT.FT_PRODUTO and SB1.D_E_L_E_T_ = ' '
			inner join C1L### C1L ON C1L.C1L_FILIAL = @cFilialLog and C1L.C1L_CODIGO = SFT.FT_PRODUTO and C1L.D_E_L_E_T_ = ' '
			left join SF2### SF2 ON SFT.FT_TIPOMOV = 'S' and SF2.F2_FILIAL = @cFilialLog and SF2.F2_DOC = SFT.FT_NFISCAL and SF2.F2_SERIE = SFT.FT_SERIE and SF2.F2_CLIENTE = SFT.FT_CLIEFOR and SF2.F2_LOJA = SFT.FT_LOJA and SF2.D_E_L_E_T_ = ' '
			left join SF1### SF1 ON SFT.FT_TIPOMOV = 'E' and SF1.F1_FILIAL = @cFilialLog and SF1.F1_DOC = SFT.FT_NFISCAL and SF1.F1_SERIE = SFT.FT_SERIE and SF1.F1_FORNECE = SFT.FT_CLIEFOR and SF1.F1_LOJA = SFT.FT_LOJA and SF1.D_E_L_E_T_ = ' '
			where SFT.D_E_L_E_T_ = ' '
				and SFT.FT_FILIAL = @cFilialLog
				and SFT.FT_NFISCAL = @cC20_NUMDOC
				and SFT.FT_SERIE = @cC20_SERIE
				and SFT.FT_TIPOMOV = @cC20_INDOPE
				and SFT.FT_CLIEFOR = @cC20_CLIFOR
				and SFT.FT_LOJA = @cC20_LOJA
		for read only	
		OPEN DADOS_SFT
		fetch DADOS_SFT into @cCODMOD		, @cFT_TIPOMOV	, @cFT_TIPODOC	, @cFT_FORMUL	, @cCODSIT, 
							 @cFT_EMISSAO	, @nVLMERC		, @nVLDOC		, @cINDPAG		, @cINDFRT, 
							 @cFT_PRODUTO	, @cC1L_UM		, @cFT_CLASFIS	, @nFT_QUANT	, @nVLITEM,
							 @nFT_TOTAL		, @cIDPROD
			
		select @iNumIte = 0
		WHILE (@@fetch_status = 0) begin

			--Caso seja uma alteração, apaga os registros da C30 para incluilos novamente com os novos dados.
			update C30### 
			set D_E_L_E_T_ = '*'
				##FIELDP01( 'R_E_C_D_E_L_' )
                	, R_E_C_D_E_L_ = R_E_C_N_O_
                ##ENDFIELDP01
			where D_E_L_E_T_ = ' '
				and C30_FILIAL = @cFilialLog
				and C30_CHVNF = @cC20_CHVNF

			--Contador de intens
			select @iNumIte = @iNumIte + 1
			
			--Grava dados dos intens do documento fiscal na tabela do TAF
			insert into C30### (C30_FILIAL, C30_CHVNF, C30_NUMITE, C30_CODITE, C30_UM, C30_ORIGEM, C30_QUANT, C30_VLRITE, C30_TOTAL ) 
				values(@cFilialLog, @cC20_CHVNF, @iNumIte, @cIDPROD, @cC1L_UM, @cFT_CLASFIS, @nFT_QUANT, @nVLITEM, @nFT_TOTAL ) 

			--Atualiza os dados das variavies
			fetch DADOS_SFT into @cCODMOD		, @cFT_TIPOMOV	, @cFT_TIPODOC	, @cFT_FORMUL	, @cCODSIT, 
								 @cFT_EMISSAO	, @nVLMERC		, @nVLDOC		, @cINDPAG		, @cINDFRT, 
								 @cFT_PRODUTO	, @cC1L_UM		, @cFT_CLASFIS	, @nFT_QUANT	, @nVLITEM,
								 @nFT_TOTAL		, @cIDPROD

		end --while

		--Atualiza os campos necessários na tabela de cabeçalho do documento fiscal.
		update C20### 
		set C20_CODMOD = @cCODMOD, 
			C20_TPDOC = @cFT_TIPODOC, 
			C20_INDEMI = @cFT_FORMUL, 
			C20_CODSIT = @cCODSIT, 
			C20_DTDOC = @cFT_EMISSAO,
			C20_VLMERC = @nVLMERC, 
			C20_VLDOC = @nVLDOC, 
			C20_INDPAG = @cINDPAG, 
			C20_INDFRT = @cINDFRT, 
			C20_STATUS = '3'	
		where D_E_L_E_T_ = ' '
			and C20_FILIAL = @cFilialLog
			and C20_CHVNF = @cC20_CHVNF

		-- Finaliza o controle da transação
		commit transaction

		CLOSE DADOS_SFT
		DEALLOCATE DADOS_SFT

		--Atualiza os dados das variavies
		fetch DADOS_C20 into @cC20_NUMDOC, @cC20_SERIE, @cC20_INDOPE, @cC20_CLIFOR, @cC20_LOJA, @cC20_CHVNF		
	end --while

	CLOSE DADOS_C20
	DEALLOCATE DADOS_C20

	select @OUT_QTDDOCS = @iContador
   --if @nContador > 0 begin
   --   commit tran
   --end	

end	