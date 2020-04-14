DROP FUNCTION IF EXISTS checkForSuperCategory(character varying);
DROP FUNCTION IF EXISTS listCatRecursive(character varying);



CREATE OR REPLACE FUNCTION checkForSuperCategory(IN cat_name VARCHAR(80)) RETURNS BOOLEAN AS
$$
BEGIN
    PERFORM categoria FROM constituida WHERE categoria = cat_name;
    RETURN FOUND;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION listCatRecursive(IN cat_name VARCHAR(80)) RETURNS TABLE (categ VARCHAR(80)) AS
$$
BEGIN

RETURN QUERY
WITH RECURSIVE findSub(super_categoria, categoria) AS (
    SELECT c.super_categoria, c.categoria
    FROM constituida c
    WHERE c.super_categoria = cat_name
    UNION ALL
    SELECT  c.super_categoria, c.categoria
    FROM findSub fs, constituida c
    WHERE c.super_categoria = fs.categoria
)
SELECT categoria FROM findSub;

END
$$ LANGUAGE plpgsql;
