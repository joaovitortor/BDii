# SQL

```sql
DROP TABLE IF EXISTS matricula;
DROP TABLE IF EXISTS disciplina;
DROP TABLE IF EXISTS aluno;

CREATE TABLE aluno (
    id INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    curso VARCHAR(50) NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    ano_ingresso INT NOT NULL
);

CREATE TABLE disciplina (
    id INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    departamento VARCHAR(50) NOT NULL,
    carga_horaria INT NOT NULL
);

CREATE TABLE matricula (
    id INT PRIMARY KEY,
    aluno_id INT NOT NULL,
    disciplina_id INT NOT NULL,
    semestre VARCHAR(10) NOT NULL,
    nota DECIMAL(4,2),
    frequencia DECIMAL(5,2),
    situacao VARCHAR(20) NOT NULL,
    CONSTRAINT fk_matricula_aluno FOREIGN KEY (aluno_id) REFERENCES aluno(id),
    CONSTRAINT fk_matricula_disciplina FOREIGN KEY (disciplina_id) REFERENCES disciplina(id)
);

INSERT INTO aluno (id, nome, curso, cidade, ano_ingresso) VALUES
(1, 'Ana Silva', 'Computacao', 'Maringa', 2022),
(2, 'Bruno Souza', 'Engenharia', 'Londrina', 2021),
(3, 'Carla Lima', 'Computacao', 'Maringa', 2023),
(4, 'Diego Alves', 'Direito', 'Curitiba', 2020),
(5, 'Elisa Rocha', 'Computacao', 'Apucarana', 2022);

INSERT INTO disciplina (id, nome, departamento, carga_horaria) VALUES
(1, 'Banco de Dados', 'Computacao', 60),
(2, 'Algoritmos', 'Computacao', 80),
(3, 'Calculo I', 'Matematica', 80),
(4, 'Direito Constitucional', 'Direito', 60);

INSERT INTO matricula (id, aluno_id, disciplina_id, semestre, nota, frequencia, situacao) VALUES
(1, 1, 1, '2024-1', 8.50, 90.00, 'Aprovado'),
(2, 1, 2, '2024-1', 7.80, 88.00, 'Aprovado'),
(3, 2, 3, '2024-1', 6.00, 75.00, 'Aprovado'),
(4, 3, 1, '2024-1', 9.20, 95.00, 'Aprovado'),
(5, 3, 3, '2024-1', 5.00, 60.00, 'Reprovado'),
(6, 4, 4, '2024-1', 8.00, 92.00, 'Aprovado'),
(7, 5, 2, '2024-1', 6.50, 70.00, 'Aprovado');
```

# VOLUME

```sql
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
```

# Lista 01

## Questão 1

Liste todos os alunos cadastrados.

```sql
SELECT * FROM aluno;
```

## Questão 2

Mostre apenas o nome e o curso dos alunos.

```sql
SELECT nome, curso FROM aluno;
```

## Questão 3

Liste os alunos do curso de Computacao.

```sql
SELECT * FROM aluno WHERE curso = 'Computacao';
```

## Questão 4

Liste os alunos que moram em Maringa.

```sql
SELECT * FROM aluno WHERE cidade = 'Maringa';
```

## Questão 5

Mostre os alunos ordenados pelo nome em ordem alfabética.

```sql
SELECT * FROM aluno ORDER BY nome:
```

## Questão 6

Mostre os alunos ordenados pelo ano de ingresso, do mais antigo para o mais recente.

```sql
SELECT * FROM aluno ORDER BY ano_ingresso ASC;
```

## Questão 7

Liste os alunos que ingressaram a partir de 2022.

```sql
SELECT * FROM aluno WHERE ano_ingreso > 2021
```

## Questão 8

Liste os alunos cujo nome começa com a letra A.

```sql
SELECT * FROM aluno WHERE nome LIKE 'A%';
```

## Questão 9

Liste os alunos dos cursos Computacao ou Engenharia.

```sql
SELECT * FROM aluno WHERE curso IN ('Computacao', 'Engenharia');
```

## Questão 10

Liste as disciplinas com carga horária entre 60 e 80 horas.

```sql
SELECT * FROM disciplina WHERE carga_horaria BETWEEN 60 AND 80;
```

## Questão 11

Conte quantos alunos existem cadastrados.

```sql
SELECT COUNT(*) FROM aluno;
```

## Questão 12

Calcule a média das notas da tabela matricula.

```sql
SELECT AVG(nota) FROM matricula;
```

## Questão 13

Mostre a maior nota registrada.

```sql
SELECT MAX(nota) FROM matricula;
```

## Questão 14

Mostre a menor nota registrada.

```sql
SELECT MIN(nota) FROM matricula;
```

## Questão 15

Calcule a soma das cargas horárias de todas as disciplinas.

```sql
SELECT SUM(carga_horaria) FROM disciplina;
```

## Questão 16

Mostre a quantidade de alunos por curso.

```sql
SELECT curso, COUNT(*) AS qtd_alunos FROM aluno GROUP BY curso;
```

## Questão 17

Mostre a quantidade de alunos por cidade.

```sql
SELECT cidade, COUNT(*) AS qtd_alunos FROM aluno GROUP BY cidade;
```

## Questão 18

Mostre a média das notas por situação da matrícula.

```sql
SELECT situacao, AVF(nota) AS media_notas FROM matricula GROUP BY situacao;
```

## Questão 19

Mostre quantas matrículas existem por semestre.

```sql
SELECT semestre, COUNT(*), AS qtd_matricula FROM matricula GROUP BY situacao;
```

## Questão 20

Mostre os cursos que possuem mais de 1 aluno cadastrado.

```sql
SELECT curso FROM aluno GROUP BY curso HAVING CONT(*) > 1;
```

## Questão 21

Liste o nome dos alunos e a situação de suas matrículas.

```sql
SELECT a.nome, m.situacao
FROM aluno a
JOIN matricula m ON a.id - m.aluno_id;
```

## Questão 22

Liste o nome dos alunos e o nome das disciplinas em que estão matriculados.

```sql
SELECT a.nome AS nome_aluno, d.nome AS nome_disciplina
FROM aluno a
JOIN matricula m ON a.id = m.aluno_id
JOIN disciplina d ON m.disciplinha_id = d.id;
```

## Questão 23

Liste o nome do aluno, o nome da disciplina e a nota.

```sql
SELECT a.nome AS nome_aluno, d.nome
```

## Questão 24

Liste apenas os alunos matriculados em disciplinas do departamento Computacao.

```sql

```

## Questão 25

Mostre o nome dos alunos que tiveram matrícula com situação Reprovado.

```sql

```

## Questão 26

Mostre o nome dos alunos de Computacao e as disciplinas que eles cursaram.

```sql

```

## Questão 27

Mostre a média de notas por aluno.

```sql

```

## Questão 28

Mostre a quantidade de disciplinas cursadas por cada aluno.

```sql

```

## Questão 29

Liste os alunos cuja média de notas foi maior que 8.

```sql

```

## Questão 30

Mostre o departamento e a quantidade de matrículas em disciplinas de cada departamento.

```sql

```
