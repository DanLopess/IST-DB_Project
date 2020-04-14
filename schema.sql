DROP TABLE IF EXISTS categoria cascade;
DROP TABLE IF EXISTS categoria_simples cascade;
DROP TABLE IF EXISTS super_categoria cascade;
DROP TABLE IF EXISTS constituida cascade;
DROP TABLE IF EXISTS produto cascade;
DROP TABLE IF EXISTS fornecedor cascade;
DROP TABLE IF EXISTS fornece_sec cascade;
DROP TABLE IF EXISTS corredor cascade;
DROP TABLE IF EXISTS prateleira cascade;
DROP TABLE IF EXISTS planograma cascade;
DROP TABLE IF EXISTS evento_reposicao cascade;
DROP TABLE IF EXISTS reposicao cascade;

----------------------------------------
-- Table Creation
----------------------------------------

-- Named constraints are global to the database.
-- Therefore the following use the following naming rules:
--   1. pk_table for names of primary key constraints
--   2. fk_table_another for names of foreign key constraints

create table categoria
(
    nome varchar(80) not null unique,
    constraint pk_categoria primary key(nome)
);

create table categoria_simples
(
    nome varchar(80) not null unique,
    constraint pk_catsimples primary key(nome),
    constraint fk_catsimples foreign key(nome) references categoria(nome)
);

create table super_categoria
(
    nome varchar(80) not null unique,
    constraint pk_supercat primary key(nome),
    constraint fk_supercat foreign key(nome) references categoria(nome)
);

create table constituida
(
    super_categoria varchar(80) not null,
    categoria varchar(80) not null,
    constraint pk_constituida primary key(super_categoria, categoria),
    constraint fk_constituida_supercat foreign key(super_categoria) references super_categoria(nome),
    constraint fk_constituida_cat foreign key(categoria) references categoria(nome),
	check (super_categoria != categoria)
);

create table fornecedor
(
    nif numeric not null check (nif BETWEEN 100000000 and 999999999),
    nome varchar(80) not null,
    constraint pk_fornecedor primary key(nif)
);

create table produto
(
    ean numeric not null unique check (ean BETWEEN 1000000000000 and 9999999999999), -- 13 digits
    design varchar(80) not null,
    categoria varchar(80) not null,
    forn_primario numeric not null,
    data date not null check(data <= CURRENT_DATE),
    constraint pk_produto primary key (ean),
    constraint fk_produto_fornprim foreign key (forn_primario) references fornecedor(nif)
);

create table fornece_sec
(
    nif numeric not null,
    ean numeric not null,
    constraint pk_fornece_sec primary key (nif, ean),
    constraint fk_fornece_sec_forn foreign key (nif) references fornecedor(nif),
    constraint fk_fornece_sec_ean foreign key (ean) references produto(ean)
);

create table corredor
(
    nro numeric not null,
    largura numeric not null,
    constraint pk_corredor primary key (nro)
);

create table prateleira
(
    nro numeric not null,
    lado char(3) not null check (lado = 'ESQ' or lado = 'DTO'),
    altura varchar(10) not null check (altura = 'SUPERIOR' or altura = 'MEDIO' or altura = 'CHAO'),
    constraint pk_prateleira primary key (nro, lado, altura),
    constraint fk_prateleira foreign key (nro) references corredor(nro)
);

create table planograma
(
    ean numeric not null,
    nro numeric not null,
    lado varchar(80) not null,
    altura varchar(10) not null,
    face numeric not null,
    unidades numeric not null,
    loc varchar(20) not null,
    constraint pk_planograma primary key (ean, nro, lado, altura),
    constraint fk_planograma_prod foreign key (ean) references produto(ean),
    constraint fk_planograma_prat foreign key (nro,lado,altura) references prateleira(nro, lado, altura)
);

create table evento_reposicao
(
    operador varchar(80) not null,
    instante timestamp not null check (instante < CURRENT_TIMESTAMP(2)),
    constraint pk_evento_reposicao primary key (operador, instante)
);

create table reposicao
(
    ean numeric not null,
    nro numeric not null,
    lado varchar(80) not null,
    altura varchar(10) not null,
	operador varchar(80) not null,
    instante timestamp not null check (instante < CURRENT_TIMESTAMP(2)),
	unidades numeric not null,
    constraint pk_reposicao primary key (ean, nro, lado, altura, operador, instante),
    constraint fk_reposicao_plano foreign key (ean, nro, lado, altura) references planograma(ean, nro, lado, altura),
    constraint fk_reposicao_evento foreign key (operador, instante) references evento_reposicao(operador, instante)
  );

----------------------------------------
-- Triggers e Check Functions
----------------------------------------

-- Verifies when a category is added
CREATE OR REPLACE FUNCTION chk_cat_name()
RETURNS trigger AS $BODY$
BEGIN
	IF NEW.nome NOT IN (SELECT nome FROM categoria_simples) AND NEW.nome
	NOT IN (SELECT nome FROM super_categoria) THEN
		RAISE EXCEPTION 'Nome nao esta em categoria simples ou super categoria';
	ELSIF NEW.nome IN (SELECT nome FROM categoria_simples) AND NEW.nome
	IN (SELECT nome FROM super_categoria) THEN
		RAISE EXCEPTION 'Nome esta em categoria simples e em super categoria simultaneamente';
	END IF;
RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

CREATE  CONSTRAINT TRIGGER cat
AFTER INSERT OR UPDATE ON categoria
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE chk_cat_name();

--Verifies if EAN is in fornece_sec
CREATE OR REPLACE FUNCTION chk_ean_in_sec() RETURNS trigger AS
$BODY$
BEGIN
    IF NEW.ean NOT IN (SELECT ean FROM fornece_sec) THEN
        RAISE EXCEPTION 'EAN nao esta em fornece_sec';
    END IF;
RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER ean_sec
AFTER INSERT OR UPDATE ON produto
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE chk_ean_in_sec();

--Verifies if fornecedor is in fornece_sec for same product
CREATE OR REPLACE FUNCTION chk_fornprim_fornsec() RETURNS trigger AS
$BODY$
BEGIN
    IF NEW.nif IN (SELECT nif FROM produto natural join fornece_sec
		WHERE produto.forn_primario=fornece_sec.nif) THEN
        RAISE EXCEPTION 'Nif ja e fornecedor primario deste ean';
    END IF;
RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER forn_sec
AFTER INSERT OR UPDATE ON fornece_sec
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE chk_fornprim_fornsec();

--Cycle detection in constituida
CREATE OR REPLACE FUNCTION chk_for_cat_cycle() RETURNS TRIGGER AS
$BODY$
DECLARE loops INTEGER;
BEGIN

WITH RECURSIVE search_table(super_categoria, categoria, depth, path, cycle ) AS (
    SELECT c.super_categoria, c.categoria, 1, ARRAY[ROW(c.super_categoria, c.categoria)], false
    FROM constituida c
    UNION ALL
    SELECT c.super_categoria, c.categoria, st.depth + 1, path ||
	ROW(c.super_categoria, c.categoria), ROW(c.super_categoria, c.categoria) = ANY(path)
    FROM constituida c, search_table st
    WHERE c.super_categoria = st.categoria AND NOT cycle
)
SELECT COUNT(*) FROM search_table WHERE cycle = true INTO loops;

IF loops > 0 THEN
    RAISE EXCEPTION 'Loop in constituida';
END IF;
RETURN NEW;

END;
$BODY$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER cycle_chk
AFTER INSERT ON constituida
FOR EACH ROW EXECUTE PROCEDURE chk_for_cat_cycle();
