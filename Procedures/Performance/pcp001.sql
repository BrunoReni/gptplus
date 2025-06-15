Create procedure PCP001_## 
  (
    @IN_FILIALSB1  Char('B1_FILIAL'),
	@IN_FILIALSG1  Char('G1_FILIAL'),
    @OUT_RESULTADO Char(01)  OUTPUT
  )
As
/* ------------------------------------------------------------------------------
    Vers�o      -  <v> Protheus P12 </v>
    Programa    -  <s> PCPA200NIV.PRW </s>
    Assinatura  -  <a> 003 </a>
    Descricao   -  <d> Atualiza a coluna B1_NIVEL de acordo com a SG1 </d>
    Entrada     -  <ri> 
	               @IN_FILIALSB1  - Filial Tabela SB1
				   @IN_FILIALSG1  - Filial Tabela SG1
	               </ri>
    Saida       -  <ro> @OUT_RESULTADO - Retorna o status do Resultado </ro>
    Responsavel :  <r> Vivian Beatriz de Almeida </r>
    Data        :  <dt> 28/04/2023 </dt> 
----------------------------------------------------------------------------- */
Declare @cNivel       VarChar('B1_NIVEL')
Declare @cNivelAnt    VarChar('B1_NIVEL')
Declare @iCount       Integer
Declare @iNivel       Integer

Select @OUT_RESULTADO = '0'

Begin Tran
/* -----------------------------------------
  Atualiza todos os produtos para nivel 02
----------------------------------------- */
Update SB1###
   Set B1_NIVEL  = '02'
 Where B1_FILIAL = @IN_FILIALSB1
   And D_E_L_E_T_ = ' ' 

/* -----------------------------------------
  Atualiza os PAs com o nivel 01
----------------------------------------- */
Update SB1###
   Set B1_NIVEL  = '01'
 Where B1_FILIAL = @IN_FILIALHWA 
   And D_E_L_E_T_ = ' ' 
   And Not Exists (Select 1
                     From SG1### SG1 (nolock)
                    Where SG1.G1_FILIAL = @IN_FILIALSG1 
                      And SG1.G1_COMP   = B1_PROD
                      And SG1.D_E_L_E_T_ = ' ')
Commit Tran

/* -----------------------------------------
  Inicializa o nivel da Atualizacao
----------------------------------------- */
Select @iNivel = 2
Select @cNivel = '02'

/* --------------------------------------------------
  Loop ate o ultimo nivel possivel das estruturas
-------------------------------------------------- */
While 1=1 Begin
	/* --------------------------------------------------------
	  Verifica se existem produtos no nivel corrente
	-------------------------------------------------------- */
	Select @iCount = Count(*)
	  From SB1### (nolock)
	 Where B1_FILIAL = @IN_FILIALSB1
	   And B1_NIVEL  = @cNivel
	   And D_E_L_E_T_ = ' '

	If (@iCount = 0)  Break

	/* --------------------------------------------------------
	  Salva o ultimo nivel atualizado
	-------------------------------------------------------- */
	Select @cNivelAnt = @cNivel

	/* --------------------------------------------------------
	  Ajusta o tipo do Nivel para Caracter
	-------------------------------------------------------- */
	Select @iNivel = @iNivel + 1
	Select @cNivel = Convert(VarChar(2),@iNivel)

	If @iNivel <= 9  Select @cNivel = '0' || @cNivel

	/* -------------------------------------------------------------------
	  Adiciona nivel no componente em que seu pai esta no nivel anterior
	------------------------------------------------------------------- */
	Begin Tran
	Update SB1###
	   Set B1_NIVEL  = @cNivel
	 Where B1_FILIAL = @IN_FILIALSB1
	   And D_E_L_E_T_ = ' ' 
	   And Exists (Select 1
	                 From SG1### SG1 (nolock)
	                Where SG1.G1_FILIAL = @IN_FILIALSG1
	                  And SG1.G1_COMP   = B1_PROD
	                  And SG1.D_E_L_E_T_ = ' '
	                  And Exists (Select 1
	                                From SB1### PAI (nolock)
	                               Where PAI.B1_FILIAL = @IN_FILIALSB1
	                                 And PAI.B1_PROD   = SG1.G1_PROD
	                                 And PAI.B1_NIVEL  = @cNivelAnt))
	Commit Tran
End

/* -----------------------------------------
  Atualiza os MPs com o nivel 99
----------------------------------------- */
Begin Tran
Update SB1###
   Set B1_NIVEL  = '99'
 Where B1_FILIAL = @IN_FILIALSB1
   And D_E_L_E_T_ = ' '
   And Not Exists (Select 1
                     From SG1### SG1 (nolock)
                    Where SG1.G1_FILIAL = @IN_FILIALSG1
                      And SG1.G1_PROD   = B1_PROD
                      And SG1.D_E_L_E_T_ = ' ')
Commit Tran

Select @OUT_RESULTADO = '1'
