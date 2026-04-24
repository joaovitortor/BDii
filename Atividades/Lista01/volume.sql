INSERT INTO aluno (nome, curso, cidade, ano_ingresso)
SELECT
    CONCAT('Aluno ', n + 1),
    CASE
        WHEN MOD(n, 10) = 0 THEN 'Computacao'
        WHEN MOD(n, 10) = 1 THEN 'Engenharia'
        WHEN MOD(n, 10) = 2 THEN 'Administracao'
        WHEN MOD(n, 10) = 3 THEN 'Direito'
        WHEN MOD(n, 10) = 4 THEN 'Medicina'
        WHEN MOD(n, 10) = 5 THEN 'Arquitetura'
        WHEN MOD(n, 10) = 6 THEN 'Psicologia'
        WHEN MOD(n, 10) = 7 THEN 'Economia'
        WHEN MOD(n, 10) = 8 THEN 'Fisica'
        ELSE 'Matematica'
    END,
    CASE
        WHEN MOD(n, 8) = 0 THEN 'Maringa'
        WHEN MOD(n, 8) = 1 THEN 'Curitiba'
        WHEN MOD(n, 8) = 2 THEN 'Londrina'
        WHEN MOD(n, 8) = 3 THEN 'Cascavel'
        WHEN MOD(n, 8) = 4 THEN 'Ponta Grossa'
        WHEN MOD(n, 8) = 5 THEN 'Foz do Iguacu'
        WHEN MOD(n, 8) = 6 THEN 'Arapongas'
        ELSE 'Apucarana'
    END,
    2018 + MOD(n, 8)
FROM numeros
WHERE n < 100000;

INSERT INTO numeros (n)
WITH RECURSIVE seq AS (
    SELECT 0 AS n
    UNION ALL
    SELECT n + 1
    FROM seq
    WHERE n < 999999
)
SELECT n
FROM seq;

DROP TABLE IF EXISTS numeros;

CREATE TABLE numeros (
    n INT NOT NULL PRIMARY KEY
);
