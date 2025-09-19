CREATE FUNCTION [dbo].[SOUNDEX_GER] (@strWord NVARCHAR(1000))
RETURNS NVARCHAR(1000) AS
BEGIN

DECLARE
       @Word NVARCHAR(1000),
       @WordLen int,
       @Code NVARCHAR(1000) = '',
       @PhoneticCode NVARCHAR(1000) = '',
       @index int,
       @RegEx NVARCHAR(50),
       @previousCharval nvarchar(1) = '|',
       @Charval nvarchar(1)

   SET @Word = lower(@strWord);
   IF len(@Word) < 1
      RETURN 0;

    --Umwandlung:
    -- v->f, w->f, j->i, y->i, ph->f, ä->a, ö->o, ü->u, ß->ss, é->e, è->e, à->a, ç->c

  SET @Word = REPLACE(
                                  REPLACE(
                                        REPLACE(
                                               REPLACE(
                                                      REPLACE(
                                                            REPLACE(
                                                                   REPLACE(
                                                                          REPLACE(
                                                                                 REPLACE(
                                                                                       REPLACE(
                                                                                              REPLACE(
                                                                                                     REPLACE(
                                                                                                            REPLACE(
                                                                                                                  REPLACE(
                                                                                                                         REPLACE(@Word,'v','f'),
                                                                                                                  'w','f'),
                                                                                                            'j','i'),
                                                                                                     'y','i'),
                                                                                              'ä','a'),
                                                                                       'ö','o'),
                                                                                 'ü','u'),                                                                                                 
                                                                          'é','e'),
                                                                   'è','e'),
                                                            'ê','e'),
                                                      'à','a'),
                                               'á','a'),
                                        'ç','c'),
                                  'ph', 'f'),
                              'ß', 'ss');


     -- Zahlen und Sonderzeichen entfernen

       SET @RegEx = '%[^a-z]%';
       WHILE PatIndex(@RegEx, @Word) > 0
           SET @Word = Stuff(@Word, PatIndex(@RegEx, @Word), 1, '');


     -- Bei Strings der Länge 1 wird ein Leerzeichen angehängt, um die Anlautprüfung auf den zweiten Buchstaben zu ermöglichen.

    SET @WordLen = LEN(@Word);
    IF @WordLen = 1
        SET @Word += ' '; 

    -- Sonderfälle am Wortanfang

    IF (substring(@Word,1,1) = 'c')
   BEGIN
  -- vor a,h,k,l,o,q,r,u,x
            SET @Code =
                  CASE
                      WHEN substring(@Word,2,1) IN ('a','h','k','l','o','q','r','u','x')
                         THEN '4'
                         ELSE '8'
                   END;
           SET @index = 2
       END
   ELSE
      SET @index = 1;


   -- Codierung    

   WHILE @index <= @WordLen
   BEGIN 
        SET @Code = 
           CASE
              WHEN substring(@Word,@index,1) in ('a','e','i','o','u')
                  THEN @Code + '0'
              WHEN substring(@Word,@index,1) = 'b'
                  THEN @Code + '1'
              WHEN substring(@Word,@index,1) = 'p'
                  THEN IIF (@index < @WordLen, IIF(substring(@Word,@index+1,1) = 'h', @Code+'3', @Code+'1'), @Code+'1')
              WHEN substring(@Word,@index,1) in ('d','t')
                  THEN IIF (@index < @WordLen, IIF(substring(@Word,@index+1,1) in ('c','s','z'), @Code+'8', @Code+'2'), @Code+'2')
              WHEN substring(@Word,@index,1) = 'f'
                  THEN @Code + '3'
              WHEN substring(@Word,@index,1) in ('g','k','q')
                  THEN @Code + '4'
              WHEN substring(@Word,@index,1) = 'c'
                  THEN IIF (@index < @WordLen, IIF(substring(@Word,@index+1,1) in ('a','h','k','o','q','u','x'), IIF(substring(@Word,@index-1,1) = 's' or substring(@Word,@index-1,1) = 'z', @Code+'8', @Code+'4'), @Code+'8'), @Code+'8')
              WHEN substring(@Word,@index,1) = 'x'
                  THEN IIF (@index > 1, IIF(substring(@Word,@index-1,1) in ('c','k','x'), @Code+'8', @Code+'48'), @Code+'48')
              WHEN substring(@Word,@index,1) = 'l'
                  THEN @Code + '5'
              WHEN substring(@Word,@index,1) = 'm' or substring(@Word,@index,1) = 'n'
                  THEN @Code + '6'
              WHEN substring(@Word,@index,1) = 'r'
                  THEN @Code + '7'
              WHEN substring(@Word,@index,1) = 's' or substring(@Word,@index,1) = 'z'
                  THEN @Code + '8'
              ELSE @Code
         END;
         SET @index += 1;
     END


   -- die mehrfachen Codes entfernen und erst dann die “0″ eliminieren
   -- Am Wortanfang bleiben “0″-Codes erhalten

   SET @index = 0;
   WHILE @index < LEN(@code) 
   BEGIN 
      SET @charval = SUBSTRING(@code, @index+1, 1);
      IF @charval <> @previousCharval 
      BEGIN 
         IF @charval <> '0' OR @index = 0 
         BEGIN  
             SET @PhoneticCode += @charval;
         END   
     END 
     SET @previousCharval = @charval;
     SET @index += 1;
   END  
 RETURN @PhoneticCode;

 END;
