-- Procedure creation 
CREATE PROCEDURE CTB303_## (
@IN_FILIAL Char( 'CQ5_FILIAL' ) , 
@IN_DATA Char( 08 ) , 
@IN_MOEDA Char( 'CQ5_MOEDA' ) , 
@IN_TPSALD Char( 'CQ5_TPSALD' ) , 
@IN_VALOR Float , 
@IN_CONTA Char( 'CQ5_CONTA' ) , 
@IN_CUSTO Char( 'CQ5_CCUSTO' ) , 
@IN_ITEM Char( 'CQ5_ITEM' ) , 
@IN_DC Char( 01 ) ) AS
-- Declaration of variables
DECLARE @cAux Char( 03 )
DECLARE @cFil_CQ5 Char( 'CQ5_FILIAL' )
DECLARE @cLp Char( 001 )
DECLARE @iRecno Integer
DECLARE @nDebito Float
DECLARE @nCredit Float
DECLARE @nCont Integer
DECLARE @cLastDay Char( 08 )
DECLARE @cFil_CQ4 Char( 'CQ4_FILIAL' )
DECLARE @cStatus Char( 01 )
DECLARE @cSldBase Char( 01 )
BEGIN
   SELECT @cAux  = 'CQ5' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFil_CQ5 output 
   SELECT @iRecno  = null 
   SELECT @cLp  = 'N' 
   SELECT @nDebito  = 0 
   SELECT @nCredit  = 0 
   SELECT @cStatus  = '1' 
   SELECT @cSldBase  = 'S' 
   SELECT @iRecno  = MIN ( R_E_C_N_O_ )
      FROM CQ5### 
      WHERE CQ5_FILIAL  = @cFil_CQ5  and CQ5_CONTA  = @IN_CONTA  and CQ5_CCUSTO  = @IN_CUSTO  and CQ5_ITEM  = @IN_ITEM  and CQ5_DATA  = @IN_DATA 
      and CQ5_MOEDA  = @IN_MOEDA  and CQ5_TPSALD  = @IN_TPSALD  and CQ5_LP  = 'N'  and D_E_L_E_T_  = ' ' 
   IF @iRecno is null 
   BEGIN 
      IF @IN_DC  = 'D' 
      BEGIN 
         SELECT @nDebito  = ROUND ( @IN_VALOR , 2 )
         SELECT @nCredit  = 0 
      END 
      ELSE 
      BEGIN 
         SELECT @nCredit  = ROUND ( @IN_VALOR , 2 )
         SELECT @nDebito  = 0 
      END 
      SELECT @iRecno  = COALESCE ( MAX ( R_E_C_N_O_ ), 0 )
        FROM CQ5### 
      SELECT @iRecno  = @iRecno  + 1 
      INSERT INTO CQ5### (CQ5_FILIAL , CQ5_CONTA , CQ5_CCUSTO , CQ5_ITEM , CQ5_DATA , CQ5_MOEDA , CQ5_TPSALD , CQ5_LP , CQ5_DEBITO , 
      CQ5_CREDIT , CQ5_STATUS , CQ5_SLBASE , R_E_C_N_O_ ) 
      VALUES (@cFil_CQ5 , @IN_CONTA , @IN_CUSTO , @IN_ITEM , @IN_DATA , @IN_MOEDA , @IN_TPSALD , @cLp , @nDebito , @nCredit , 
      @cStatus , @cSldBase , @iRecno )
   END 
   ELSE 
   BEGIN 
      IF @IN_DC  = 'D' 
      BEGIN 
         UPDATE CQ5### 
            SET CQ5_DEBITO  = CQ5_DEBITO  + ROUND ( @IN_VALOR , 2 )
         WHERE R_E_C_N_O_  = @iRecno 
      END 
      ELSE 
      BEGIN 
         UPDATE CQ5### 
            SET CQ5_CREDIT  = CQ5_CREDIT  + ROUND ( @IN_VALOR , 2 )
         WHERE R_E_C_N_O_  = @iRecno 
      END 
   END 
   EXEC LASTDAY_## @IN_DATA , @cLastDay output 
   SELECT @cAux  = 'CQ4' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFil_CQ4 output 
   SELECT @iRecno  = null 
   SELECT @cLp  = 'N' 
   SELECT @nDebito  = 0 
   SELECT @nCredit  = 0 
   SELECT @cStatus  = '1' 
   SELECT @cSldBase  = 'S' 
   SELECT @iRecno  = MIN ( R_E_C_N_O_ )
     FROM CQ4### 
     WHERE CQ4_FILIAL  = @cFil_CQ5  and CQ4_CONTA  = @IN_CONTA  and CQ4_CCUSTO  = @IN_CUSTO  and CQ4_ITEM  = @IN_ITEM  and CQ4_DATA  = @cLastDay 
    and CQ4_MOEDA  = @IN_MOEDA  and CQ4_TPSALD  = @IN_TPSALD  and CQ4_LP  = 'N'  and D_E_L_E_T_  = ' ' 
   IF @iRecno is null 
   BEGIN 
      IF @IN_DC  = 'D' 
      BEGIN 
         SELECT @nDebito  = ROUND ( @IN_VALOR , 2 )
         SELECT @nCredit  = 0 
      END 
      ELSE 
      BEGIN 
         SELECT @nCredit  = ROUND ( @IN_VALOR , 2 )
         SELECT @nDebito  = 0 
      END 
      SELECT @iRecno  = COALESCE ( MAX ( R_E_C_N_O_ ), 0 )
         FROM CQ4### 
      SELECT @iRecno  = @iRecno  + 1 
      INSERT INTO CQ4### (CQ4_FILIAL , CQ4_CONTA , CQ4_CCUSTO , CQ4_ITEM , CQ4_DATA , CQ4_MOEDA , CQ4_TPSALD , CQ4_LP , CQ4_DEBITO , 
      CQ4_CREDIT , CQ4_STATUS , CQ4_SLBASE , R_E_C_N_O_ ) 
      VALUES (@cFil_CQ4 , @IN_CONTA , @IN_CUSTO , @IN_ITEM , @cLastDay , @IN_MOEDA , @IN_TPSALD , @cLp , @nDebito , @nCredit , 
      @cStatus , @cSldBase , @iRecno )
   END 
   ELSE 
   BEGIN 
      IF @IN_DC  = 'D' 
      BEGIN 
         UPDATE CQ4### 
            SET CQ4_DEBITO  = CQ4_DEBITO  + ROUND ( @IN_VALOR , 2 )
         WHERE R_E_C_N_O_  = @iRecno 
      END 
      ELSE 
      BEGIN 
         UPDATE CQ4### 
            SET CQ4_CREDIT  = CQ4_CREDIT  + ROUND ( @IN_VALOR , 2 )
         WHERE R_E_C_N_O_  = @iRecno 
      END 
   END 
END 
