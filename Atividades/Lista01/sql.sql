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
