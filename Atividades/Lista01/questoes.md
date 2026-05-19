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
START TRANSACTION;

UPDATE contas
SET saldo = saldo + 10
WHERE id = 2;
```

# Lista 01

## Questão 1

Liste todos os alunos cadastrados.

## Questão 2

Mostre apenas o nome e o curso dos alunos.

## Questão 3

Liste os alunos do curso de Computacao.

## Questão 4

Liste os alunos que moram em Maringa.

## Questão 5

Mostre os alunos ordenados pelo nome em ordem alfabética.

## Questão 6

Mostre os alunos ordenados pelo ano de ingresso, do mais antigo para o mais recente.

## Questão 7

Liste os alunos que ingressaram a partir de 2022.

## Questão 8

Liste os alunos cujo nome começa com a letra A.

## Questão 9

Liste os alunos dos cursos Computacao ou Engenharia.

## Questão 10

Liste as disciplinas com carga horária entre 60 e 80 horas.

## Questão 11

Conte quantos alunos existem cadastrados.

## Questão 12

Calcule a média das notas da tabela matricula.

## Questão 13

Mostre a maior nota registrada.

## Questão 14

Mostre a menor nota registrada.

## Questão 15

Calcule a soma das cargas horárias de todas as disciplinas.

## Questão 16

Mostre a quantidade de alunos por curso.

## Questão 17

Mostre a quantidade de alunos por cidade.

## Questão 18

Mostre a média das notas por situação da matrícula.

## Questão 19

Mostre quantas matrículas existem por semestre.

## Questão 20

Mostre os cursos que possuem mais de 1 aluno cadastrado.

## Questão 21

Liste o nome dos alunos e a situação de suas matrículas.

## Questão 22

Liste o nome dos alunos e o nome das disciplinas em que estão matriculados.

## Questão 23

Liste o nome do aluno, o nome da disciplina e a nota.

## Questão 24

Liste apenas os alunos matriculados em disciplinas do departamento Computacao.

## Questão 25

Mostre o nome dos alunos que tiveram matrícula com situação Reprovado.

## Questão 26

Mostre o nome dos alunos de Computacao e as disciplinas que eles cursaram.

## Questão 27

Mostre a média de notas por aluno.

## Questão 28

Mostre a quantidade de disciplinas cursadas por cada aluno.

## Questão 29

Liste os alunos cuja média de notas foi maior que 8.

## Questão 30

Mostre o departamento e a quantidade de matrículas em disciplinas de cada departamento.
