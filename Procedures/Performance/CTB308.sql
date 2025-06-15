-- Procedure creation 
CREATE PROCEDURE CTB308_## (
@IN_MAXLINHA Integer , 
@IN_LOTE Char('CT2_LOTE') , 
@IN_SBLOTE Char( 'CT2_SBLOTE' ) , 
@IN_DOC Char( 'CT2_DOC' ) , 
@IN_LINHA Char( 'CT2_LINHA' ) , 
@OUT_LOTE Char( 'CT2_LOTE' )  output , 
@OUT_SBLOTE Char( 'CT2_SBLOTE' )  output , 
@OUT_DOC Char( 'CT2_DOC' )  output , 
@OUT_LINHA Char( 'CT2_LINHA' )  output ) AS
-- Declaration of variables
DECLARE @cLinha Char( 'CT2_LINHA' )
DECLARE @cLinhaIn Char( 'CT2_LINHA' )
DECLARE @cLote Char( 'CT2_LOTE' )
DECLARE @cLoteIn Char( 'CT2_LOTE' )
DECLARE @cSbLote Char( 'CT2_SBLOTE' )
DECLARE @cDoc Char( 'CT2_DOC' )
DECLARE @cDocIn Char( 'CT2_DOC' )
DECLARE @iLinha Integer
DECLARE @iMaxLinha Integer
DECLARE @iTamLinha Integer
BEGIN
   SELECT @iMaxLinha  = @IN_MAXLINHA 
   SELECT @iTamLinha  = LEN ( @IN_LINHA )
   SELECT @cLote  = @IN_LOTE 
   SELECT @cSbLote  = @IN_SBLOTE 
   SELECT @cDoc  = @IN_DOC 
   SELECT @cLinha  = @IN_LINHA 
   SELECT @cLinhaIn  = @cLinha 
   SELECT @cLoteIn  = @cLote 
   SELECT @cDocIn  = @cDoc 
   IF @cLinha  = 'zzz' 
   BEGIN 
      SELECT @iLinha  = 0 
      EXEC MSSTRZERO @iLinha , @iTamLinha , @cLinha output 
      IF @cDoc  > 'zzzzzz' 
      BEGIN 
         SELECT @cDoc  = '000000' 
         SELECT @cLoteIn  = @cLote 
         EXEC MSSOMA1 @cLoteIn , '1' , @cLote output 
      END 
      ELSE 
      BEGIN 
         SELECT @cDocIn  = @cDoc 
         EXEC MSSOMA1 @cDocIn , '1' , @cDoc output 
      END 
   END 
   ELSE 
   BEGIN 
      SELECT @cLinhaIn  = @cLinha 
      EXEC MSSOMA1 @cLinhaIn , '1' , @cLinha output 
   END 
   SELECT @OUT_LINHA  = @cLinha 
   SELECT @OUT_LOTE  = @cLote 
   SELECT @OUT_SBLOTE  = @cSbLote 
   SELECT @OUT_DOC  = @cDoc 
END 
