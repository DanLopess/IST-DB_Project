----------------------------------------
-- Populate
----------------------------------------

START TRANSACTION;
insert into corredor values (1, 10);
insert into corredor values (2, 10);
insert into corredor values (3, 10);
COMMIT;

START TRANSACTION;
insert into prateleira values (1, 'ESQ', 'SUPERIOR');
insert into prateleira values (1, 'DTO', 'CHAO');
insert into prateleira values (2, 'ESQ', 'SUPERIOR');
insert into prateleira values (2, 'DTO', 'CHAO');
insert into prateleira values (3, 'DTO', 'MEDIO');
insert into prateleira values (3, 'DTO', 'CHAO');
COMMIT;

START TRANSACTION;
insert into fornecedor values (100000000, 'Aquario da Rinchoa');
insert into fornecedor values (100000001, 'Ervanario do Barreiro');
insert into fornecedor values (100000002, 'Matadouro de Rio de Mouro');
insert into fornecedor values (100000003, 'Padaria Nacional');
COMMIT;

START TRANSACTION;
insert into categoria values ('Bebidas');
insert into super_categoria values ('Bebidas');
insert into categoria values ('Refrigerantes');
insert into categoria_simples values ('Refrigerantes');
insert into constituida values ('Bebidas', 'Refrigerantes');
insert into categoria values ('Aguas');
insert into categoria_simples values ('Aguas');
insert into constituida values ('Bebidas', 'Aguas');
COMMIT;

START TRANSACTION;
insert into produto values (1234567891011, 'Pepsi', 'Refrigerantes', 100000003, '2018-01-01');
insert into produto values (1234567891012, 'Coca Cola', 'Refrigerantes', 100000003, '2018-02-02');
insert into produto values (1234567891014, 'Agua Mineral', 'Aguas', 100000003, '2018-03-04');
insert into produto values (1234567891016, 'Compal', 'Refrigerantes', 100000003, '2018-10-06');
insert into produto values (1234567891019, 'Vinho do Porto', 'Aguas', 100000003, '2018-01-09');
insert into fornece_sec values (100000000, 1234567891011);
insert into fornece_sec values (100000000, 1234567891012);
insert into fornece_sec values (100000001, 1234567891014);
insert into fornece_sec values (100000001, 1234567891016);
insert into fornece_sec values (100000002, 1234567891019);
COMMIT;

START TRANSACTION;
insert into planograma values (1234567891011, 1, 'ESQ', 'SUPERIOR', 3, 5, 'Garrafeira');
insert into planograma values (1234567891012, 1, 'DTO', 'CHAO', 3, 5, 'Garrafeira');
insert into planograma values (1234567891014, 2, 'ESQ', 'SUPERIOR', 3, 5, 'Garrafeira');
insert into planograma values (1234567891016, 2, 'DTO', 'CHAO', 3, 5, 'Garrafeira');
insert into planograma values (1234567891019, 3, 'DTO', 'MEDIO', 3, 5, 'Garrafeira');
COMMIT;

START TRANSACTION;
    insert into evento_reposicao values ('Maria', '2018-05-09 09:47:53');
    insert into reposicao values (1234567891011, 1, 'ESQ', 'SUPERIOR', 'Maria', '2018-05-09 09:47:53', 4);
    insert into evento_reposicao values ('Joao', '2018-05-09 10:17:47');
    insert into reposicao values (1234567891012, 1, 'DTO', 'CHAO', 'Joao', '2018-05-09 10:17:47', 3);
    insert into evento_reposicao values ('Daniel', '2018-05-09 16:26:11');
COMMIT;
