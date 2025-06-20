CREATE FUNCTION MSDATEDIFF (DATEPART VARCHAR(10),
                              DATA1 VARCHAR(10),
                              DATA2 VARCHAR(10))
RETURNS INTEGER

BEGIN ATOMIC
    DECLARE VDATA1 DATE;
    DECLARE VDATA2 DATE;
    DECLARE VIMESES1 INTEGER;
    DECLARE VIMESES2 INTEGER;
    DECLARE VIDIFF INTEGER;

    IF DATA1 = ' ' OR DATA1 IS NULL OR DATA2 = ' ' OR DATA2 IS NULL THEN
        SET VIDIFF = 0;
    ELSE
       SET VIDIFF = 0;
       IF UPPER(DATEPART) = 'DAY'  THEN
          SET VDATA1 = DATE( SUBSTR( DATA1, 1, 4 )||'-'||SUBSTR( DATA1, 5, 2 )||'-'||SUBSTR( DATA1, 7, 2 ) );
          SET VDATA2 = DATE( SUBSTR( DATA2, 1, 4 )||'-'||SUBSTR( DATA2, 5, 2 )||'-'||SUBSTR( DATA2, 7, 2 ) );
          SET VIDIFF = DAYS(VDATA2) - DAYS(VDATA1);
       END IF;
       IF UPPER(DATEPART) = 'MONTH'  THEN
          SET VIMESES1 = INTEGER ( SUBSTR( DATA1, 1, 4 ) ) * 12 + INTEGER ( SUBSTR( DATA1, 5, 2 ) ) ;
          SET VIMESES2 = INTEGER ( SUBSTR( DATA2, 1, 4 ) ) * 12 + INTEGER ( SUBSTR( DATA2, 5, 2 ) ) ;
          SET VIDIFF = VIMESES2 - VIMESES1;
       END IF;
       IF UPPER(DATEPART) = 'YEAR'  THEN
          SET VIDIFF = INTEGER ( SUBSTR( DATA2, 1, 4 ) ) - INTEGER ( SUBSTR( DATA1, 1, 4 ) );
       END IF;
    END IF;
    RETURN(VIDIFF);
END 