# Concorrência, bloqueios e problemas clássicos em transações

## 6. Atividade prática

### Atividade: simular concorrência, bloqueios, espera e inconsistências em transações

#### Etapa 1. Criar o banco de teste

```sql
DROP TABLE IF EXISTS contas;

CREATE TABLE contas (
    id INT PRIMARY KEY,
    titular VARCHAR(100),
    saldo DECIMAL(10,2)
);

INSERT INTO contas (id, titular, saldo) VALUES
(1, 'Ana', 1000.00),
(2, 'Bruno', 500.00),
(3, 'Carlos', 300.00),
(4, 'Daniela', 800.00);

SELECT * FROM contas;
```

**Pergunta 1**  
Qual é a finalidade de manter dados iniciais conhecidos antes dos testes de concorrência?

**Pergunta 2**  
Por que é importante que a tabela esteja em um estado consistente antes do início dos experimentos?

---

#### Etapa 2. Testar bloqueio com `FOR UPDATE`

Abra duas sessões.

### Sessão 1

```sql
START TRANSACTION;

SELECT * FROM contas
WHERE id = 1
FOR UPDATE;

UPDATE contas
SET saldo = saldo - 100
WHERE id = 1;
```

Não execute `COMMIT` ainda.

### Sessão 2

```sql
START TRANSACTION;

UPDATE contas
SET saldo = saldo + 50
WHERE id = 1;
```

Agora volte para a Sessão 1 e execute:

```sql
COMMIT;
```

Depois finalize a Sessão 2 com:

```sql
COMMIT;
```

**Pergunta 3**  
O que aconteceu com a operação realizada na Sessão 2?

**Pergunta 4**  
Por que a segunda sessão precisou aguardar?

**Pergunta 5**  
Qual é a função do comando `FOR UPDATE` nesse experimento?

---

#### Etapa 3. Testar acesso concorrente a registros diferentes

Abra duas sessões.

### Sessão 1

```sql
START TRANSACTION;

UPDATE contas
SET saldo = saldo - 50
WHERE id = 1;
```

### Sessão 2

```sql
START TRANSACTION;

UPDATE contas
SET saldo = saldo + 70
WHERE id = 4;
```

Finalize ambas com:

```sql
COMMIT;
```

Depois consulte:

```sql
SELECT * FROM contas;
```

**Pergunta 6**  
Por que, nesse caso, as duas transações tendem a coexistir sem espera significativa?

**Pergunta 7**  
O que esse comportamento revela sobre bloqueios em nível de linha?

---

#### Etapa 4. Testar leitura durante transação não finalizada

### Sessão 1

```sql
START TRANSACTION;

UPDATE contas
SET saldo = saldo - 200
WHERE id = 2;
```

Sem confirmar ainda.

### Sessão 2

```sql
SELECT * FROM contas WHERE id = 2;
```

Depois volte para a Sessão 1 e execute:

```sql
ROLLBACK;
```

**Pergunta 8**  
Qual era o objetivo de consultar o mesmo registro em outra sessão antes do `COMMIT`?

**Pergunta 9**  
Como esse experimento se relaciona com o conceito de isolamento?

---

#### Etapa 5. Testar repetição de leitura

### Sessão 1

```sql
START TRANSACTION;

SELECT * FROM contas WHERE id = 3;
```

### Sessão 2

```sql
START TRANSACTION;

UPDATE contas
SET saldo = saldo + 100
WHERE id = 3;

COMMIT;
```

Agora volte para a Sessão 1 e repita:

```sql
SELECT * FROM contas WHERE id = 3;
```

Finalize a Sessão 1:

```sql
COMMIT;
```

**Pergunta 10**  
O valor lido na Sessão 1 permaneceu o mesmo ou mudou?

**Pergunta 11**  
Que tipo de fenômeno esse teste procura identificar?

---

#### Etapa 6. Simular atualização concorrente sobre o mesmo dado

Abra duas sessões.

### Sessão 1

```sql
START TRANSACTION;

SELECT * FROM contas WHERE id = 4;

UPDATE contas
SET saldo = saldo - 100
WHERE id = 4;
```

### Sessão 2

```sql
START TRANSACTION;

SELECT * FROM contas WHERE id = 4;

UPDATE contas
SET saldo = saldo - 200
WHERE id = 4;
```

Finalize ambas com `COMMIT`, observando a ordem de execução e depois consulte:

```sql
SELECT * FROM contas WHERE id = 4;
```

**Pergunta 12**  
Por que operações concorrentes sobre o mesmo registro exigem maior controle?

**Pergunta 13**  
Que inconsistência pode surgir quando duas transações tentam atualizar o mesmo dado quase ao mesmo tempo?

---

#### Etapa 7. Testar espera por lock

### Sessão 1

```sql
START TRANSACTION;

SELECT * FROM contas WHERE id = 2 FOR UPDATE;
```

Mantenha a transação aberta.

### Sessão 2

```sql
START TRANSACTION;

UPDATE contas
SET saldo = saldo + 10
WHERE id = 2;
```

Agora, depois de observar a espera, volte para a Sessão 1 e execute:

```sql
COMMIT;
```

**Pergunta 14**  
Qual evidência mostra que havia um bloqueio ativo sobre o registro?

**Pergunta 15**  
Por que a liberação do lock depende do fim da transação?

---

#### Etapa 8. Testar bloqueio com duas leituras de atualização

### Sessão 1

```sql
START TRANSACTION;

SELECT * FROM contas WHERE id = 1 FOR UPDATE;
```

### Sessão 2

```sql
START TRANSACTION;

SELECT * FROM contas WHERE id = 1 FOR UPDATE;
```

Depois finalize a Sessão 1 com:

```sql
COMMIT;
```

**Pergunta 16**  
Por que a segunda leitura com `FOR UPDATE` não pôde prosseguir imediatamente?

**Pergunta 17**  
Em que essa situação difere de uma consulta `SELECT` comum?

---

#### Etapa 9. Simular risco de atualização perdida

Considere o seguinte cenário conceitual:

- saldo atual da conta 1 = 1000
- Transação A lê saldo 1000 e decide subtrair 100
- Transação B lê saldo 1000 e decide subtrair 200
- A grava 900
- B grava 800

**Pergunta 18**  
Qual seria o saldo correto ao final, caso ambas as operações fossem consideradas corretamente?

**Pergunta 19**  
Por que o resultado 800 caracteriza uma atualização perdida?

---

#### Etapa 10. Testar inserções concorrentes em outra tabela

Crie a tabela:

```sql
DROP TABLE IF EXISTS log_operacoes;

CREATE TABLE log_operacoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(200)
);
```

Abra duas sessões.

### Sessão 1

```sql
START TRANSACTION;

INSERT INTO log_operacoes (descricao)
VALUES ('Operacao realizada pela sessao 1');
```

### Sessão 2

```sql
START TRANSACTION;

INSERT INTO log_operacoes (descricao)
VALUES ('Operacao realizada pela sessao 2');
```

Finalize ambas com `COMMIT` e consulte:

```sql
SELECT * FROM log_operacoes;
```

**Pergunta 20**  
Por que inserções em linhas diferentes nem sempre geram conflito direto?

**Pergunta 21**  
O que esse experimento mostra sobre concorrência quando não há disputa pelo mesmo registro?

---

#### Etapa 11. Simular bloqueio prolongado

### Sessão 1

```sql
START TRANSACTION;

SELECT * FROM contas WHERE id = 3 FOR UPDATE;
```

Não finalize imediatamente.

### Sessão 2

```sql
START TRANSACTION;

UPDATE contas
SET saldo = saldo + 20
WHERE id = 3;
```

**Pergunta 22**  
Quais impactos um bloqueio mantido por muito tempo pode causar em um sistema real?

**Pergunta 23**  
Por que transações longas tendem a ser indesejáveis em ambientes concorrentes?

---

#### Etapa 12. Consultar o estado final

Depois de finalizar todos os testes, execute:

```sql
SELECT * FROM contas;
SELECT * FROM log_operacoes;
```

**Pergunta 24**  
Como verificar se o banco permaneceu consistente após todos os cenários executados?

**Pergunta 25**  
Por que a análise final dos dados é importante após testes de concorrência?

---

## 7. Atividade dissertativa

### Questão 26
Explique o que é concorrência em banco de dados.

### Questão 27
Descreva o papel dos bloqueios no controle de concorrência.

### Questão 28
Explique a diferença entre acessar registros iguais e registros diferentes em transações simultâneas.

### Questão 29
Por que `FOR UPDATE` é importante em determinadas operações críticas?

### Questão 30
O que significa dizer que uma transação ficou esperando outra liberar um recurso?

### Questão 31
Explique o conceito de atualização perdida.

### Questão 32
Descreva por que o isolamento é essencial em sistemas multiusuário.

### Questão 33
Explique como uma leitura pode ser afetada por outra transação ainda não concluída.

### Questão 34
Por que transações longas podem prejudicar o desempenho de sistemas concorrentes?

### Questão 35
Qual é a relação entre concorrência e consistência dos dados?

### Questão 36
Descreva um exemplo real em que duas transações possam disputar o mesmo dado.

### Questão 37
Explique por que nem toda operação simultânea gera conflito.

### Questão 38
Como o banco de dados contribui para impedir que alterações simultâneas corrompam os dados?

### Questão 39
Explique o que aconteceria em um sistema bancário sem mecanismos de lock.

### Questão 40
Qual a importância de observar a ordem de execução das transações em testes práticos?

---

## 8. Atividade prática com enunciado formal

### Enunciado
Um sistema bancário multiusuário precisa permitir operações simultâneas sem comprometer a integridade dos dados. Para isso, implemente testes em SQL que demonstrem:

- bloqueio explícito de registros com `FOR UPDATE`
- espera de uma transação por outra
- diferença entre concorrência em registros iguais e em registros diferentes
- risco de atualização perdida
- análise da consistência final dos dados após execuções concorrentes

### Objetivos
Ao final da atividade, o estudante deve ser capaz de:

- compreender o conceito de concorrência
- identificar situações de bloqueio
- analisar o efeito de locks em duas sessões simultâneas
- perceber quando há disputa por recursos
- discutir riscos de inconsistência em operações concorrentes
- relacionar concorrência com integridade e desempenho

### Tarefa final
Com base nos testes realizados, produza um texto explicando:

- o que é concorrência em banco de dados
- como funcionam os locks
- por que algumas transações precisam esperar
- o que é atualização perdida
- por que o isolamento é importante
- como o banco preserva a consistência em acessos simultâneos

---

## 9. Questão integradora

### Questão 41
Considerando todos os experimentos realizados, explique de forma integrada como concorrência, bloqueios e isolamento atuam juntos para evitar inconsistências no banco de dados.

---

## 10. Desafio adicional

### Questão 42
Adapte os testes realizados para um sistema de estoque em que dois usuários tentam vender o mesmo produto simultaneamente. Explique quais riscos existem e como o banco pode evitá-los.

### Questão 43
Adapte os testes para um sistema de matrícula acadêmica, em que duas pessoas tentam ocupar a última vaga da mesma disciplina ao mesmo tempo.

### Questão 44
Explique como você organizaria um experimento prático no VS Code com duas sessões para demonstrar espera por lock a outros estudantes.

### Questão 45
Compare um cenário com controle de concorrência e outro sem controle de concorrência, destacando os impactos sobre a confiabilidade dos dados.
