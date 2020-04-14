--a)
SELECT nome
FROM (
    SELECT count(*), nif
    FROM (
        SELECT nif, categoria
        FROM (
            SELECT ean, forn_primario AS nif
            FROM produto
            UNION
            SELECT ean, nif
            FROM fornece_sec
            ) k
                NATURAL JOIN (
                    SELECT ean, categoria
                    FROM produto
                ) l
        ) j

    GROUP BY nif
    HAVING count(*) >= all (
        SELECT count(*)
        FROM  (
            SELECT nif, categoria
            FROM (
                SELECT ean, forn_primario AS nif
                FROM produto
                UNION
                SELECT ean, nif
                FROM fornece_sec
                ) n
                NATURAL JOIN (
                    SELECT ean, categoria
                    FROM produto
                ) o
            ) m
        GROUP BY nif
        )
    ) i NATURAL JOIN fornecedor ;


-- b)

SELECT DISTINCT nome, nif
FROM fornecedor f
    NATURAL JOIN(
        SELECT forn_primario AS nif
        FROM produto p
        WHERE NOT EXISTS (
            SELECT nome
            FROM categoria_simples
            EXCEPT
            SELECT nome
            FROM (categoria_simples
                natural join produto) f
            WHERE f.forn_primario = p.forn_primario
        )
    ) g;

select f.nome, f.nif
from fornecedor f
where not exists(
	select c.nome
	from categoria_simples c
	EXCEPT
	select p.nome
	from (produto
		natural join categoria_simples) p
	where p.forn_primario = f.nif
);

-- c)
SELECT *
FROM produto
WHERE ean NOT IN (
    SELECT ean
    FROM reposicao );

--d)
SELECT ean
FROM fornece_sec
GROUP BY ean
HAVING count(*) > 10;

--e)

SELECT ean
FROM(
    SELECT ean, operador
    FROM reposicao
) as f
GROUP BY ean
HAVING count(*) = 1;
