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

> Ter uma base para verificar se alguma operação futura causou alguma anomalia ou se funcionaram certo.

**Pergunta 2**  
Por que é importante que a tabela esteja em um estado consistente antes do início dos experimentos?

> Se os dados começarem corrompidos, não teremos como verificar se um erro futuro foi por causa da falha de concorrência ou se já estava inconsistente

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

> A sessão 2 não foi concluída imediatamente, ela ficou em estado de espera, aguardando na fila.

**Pergunta 4**  
Por que a segunda sessão precisou aguardar?

> Porque a sessão 1 acessou o registro primeiro e não o liberou. Para evitar inconsistências, o SGBD protegeu o dado obrigando a sessão 2 a aguardar a liberação.

**Pergunta 5**  
Qual é a função do comando `FOR UPDATE` nesse experimento?

> O `FOR UPDATE` serve para forçar um bloqueio explícito logo no momento do `SELECT`.

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

> Porque elas não estão disputando o mesmo registro físico. A sessão 1 está alterando o registro de id 1 enquanto a sessão 2 está alterando o registro de id 4

**Pergunta 7**  
O que esse comportamento revela sobre bloqueios em nível de linha?

> Que o bloqueio em nível de linha bloqueia apenas a linha afetada, e não a tabela inteira.

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

> O objetivo era descobrir se a sessão 2 iria enxergar o dado temporário na sessão 1 ou o valor persistido no banco.

**Pergunta 9**  
Como esse experimento se relaciona com o conceito de isolamento?

> O isolamento obriga o SGBD a ocultar operações inacabadas. Se a sessão 2 conseguisse ler o valor temporário da sessão 1, estaria ocorrendo a temida anomalia da "Leitura Suja" (Dirty Read).

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

> O valor lido mudou.

**Pergunta 11**  
Que tipo de fenômeno esse teste procura identificar?

> É conhecido como "Leitura Não Repetível" (Non-repeatable read). Ocorre quando, dentro de uma única transação, uma sessão consulta a mesma linha duas vezes e obtém valores diferentes, porque outra transacão concorrente alterou o dado nesse intervalo.

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

> Poruqe elas geram conflito direto. Como as duas sessões querem gravar valores por cima da mesma linha, se o SGBD não criar uma "fila", as transações vão atropelar uma à outra, gerando uma inconsistência dos dados.

**Pergunta 13**  
Que inconsistência pode surgir quando duas transações tentam atualizar o mesmo dado quase ao mesmo tempo?

> Atualização perdida (lost update). Isso acontece quando as duas transações leem o mesmo valor base e gravam a alteração por cima uma da outra. Consequentemente, a alteração feita pela primeira transação é perdida, sendo sobreescrita pela segunda.

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

> A sessão 2 não conseguiu completar a sua operação instantaneamente e ficou em estado de espera.

**Pergunta 15**  
Por que a liberação do lock depende do fim da transação?

> Para garantir a propriedade do Isolamento e respeitar protocolos de segurança.

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

> Porque a sessão 1 bloqueou a linha antes da segunda transação, consequentemente a sessão 2 foi obrigada a esperar. 

**Pergunta 17**  
Em que essa situação difere de uma consulta `SELECT` comum?

> Um `SELECT` comum apenas lê a informação. O SGBD permite que vários `SELECTs` comuns aconteça, ao mesmo tempo sem espera (usando bloqueios compartilhados).

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

> Se o sistema respeitar a concorrência corretamente como uma fila, o saldo final deveria ser 700.

**Pergunta 19**  
Por que o resultado 800 caracteriza uma atualização perdida?

> Porque o trabalho da Transação A foi apagado do disco.

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

> Porque elas não estão competindo pelo mesmo espaço físico no disco.

**Pergunta 21**  
O que esse experimento mostra sobre concorrência quando não há disputa pelo mesmo registro?

> Mostra que banco de dados é otimizado para para o paralelismo.

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

> Um bloqueio prolongado paralisa o sistema. Todas as outras sessões que precisarem acessar aquele registro travarão em uma fila de espera.

**Pergunta 23**  
Por que transações longas tendem a ser indesejáveis em ambientes concorrentes?

> Porque transações longas seguram o bloqueio por muito tempo, impedindo que outras transações trabalhem. (starvation)

---

#### Etapa 12. Consultar o estado final

Depois de finalizar todos os testes, execute:

```sql
SELECT * FROM contas;
SELECT * FROM log_operacoes;
```

**Pergunta 24**  
Como verificar se o banco permaneceu consistente após todos os cenários executados?

> Para verificar a consistência, deve-se consultar os dados finais da tabela e conferir se eles respeitam as regras de negócios iniciais.

**Pergunta 25**  
Por que a análise final dos dados é importante após testes de concorrência?

> Porque é a prova real de que não houve falha nos testes.

---

## 7. Atividade dissertativa

### Questão 26
Explique o que é concorrência em banco de dados.

> A concorrência em um banco de dados é a capacidade do sistema de gerenciar o acesso simultâneo de múltiplos usuários e transações aos mesmos dados.

### Questão 27
Descreva o papel dos bloqueios no controle de concorrência.

> Os bloqueios servem para forçar uma exclusão mútua indicando o status de registro e criando uma fila organizada. Isso impede que transações diferentes tentem alterar o exato mesmo dado ao mesmo tempo.

### Questão 28
Explique a diferença entre acessar registros iguais e registros diferentes em transações simultâneas.

> Acessar registros diferentes geralmente não gera conflitos, pois o banco aplica bloqueios em nível de linha, permitindo que duas transações ocorram ao mesmo tempo.
> Acessar registros iguais para atualização gera um gargalo de concorrência, ou seja, o SGBD é forçado a dar prioridade para a primeira transação, deixando a segunda em espera.

### Questão 29
Por que `FOR UPDATE` é importante em determinadas operações críticas?

> Porque ele aplica um bloqueio explícito logo no momento da leitura.

### Questão 30
O que significa dizer que uma transação ficou esperando outra liberar um recurso?

> Significa que a transação precisa acessar um registro que está bloqueado no momento (pertence a outra transação que ainda não terminou).

### Questão 31
Explique o conceito de atualização perdida.

> Atualização perdida (lost update) ocorre quando duas transações leem o mesmo registro inicial ao mesmo tempo e depois gravam seus novos valores de volta no disco. A última a gravar acaba sobrescrevendo o valor gravado pela primeira transação.

### Questão 32
Descreva por que o isolamento é essencial em sistemas multiusuário.

> O Isolamento garante que transações concorrentes fiquem completamente isoladas e protegidas umas das outras. É essencial para impedir que uma transação consiga ler um dado temporário alterado por outra transação.

### Questão 33
Explique como uma leitura pode ser afetada por outra transação ainda não concluída.

> Se o banco não aplicar o isolamento corretamente, uma transação pode ler um dado que está sendo modificado por outra transação.

### Questão 34
Por que transações longas podem prejudicar o desempenho de sistemas concorrentes?

> Porque se outras transações dependem de registros que estejam bloqueados por uma transação longa, eles ficam muito tempo em estado de espera e gera lentidão no sistema.

### Questão 35
Qual é a relação entre concorrência e consistência dos dados?

> A concorrência significa que diferentes usuários acessam o banco ao mesmo tempo. O controle de concorrência serve justamente para garantir que as operações ocorram de forma segura e garantir a consistência.

### Questão 36
Descreva um exemplo real em que duas transações possam disputar o mesmo dado.

> Dois usuários acessando um e-commerce ao mesmo tempo e tentando comprar a última unidade de um item em estoque ao mesmo tempo.

### Questão 37
Explique por que nem toda operação simultânea gera conflito.

> O conflito só ocorre quando duas transações cruzam os caminhos.

### Questão 38
Como o banco de dados contribui para impedir que alterações simultâneas corrompam os dados?

> Ele contrinui usando mecanismos de bloqueios e protocolos, garantindo o Isolamento.

### Questão 39
Explique o que aconteceria em um sistema bancário sem mecanismos de lock.

> Sem mecanismos de bloqueio, sofreria lost update constantemente. Dois depósitos simultâneos resultaria em apenas um depósito (o último a ser executado) e o dinheiro seria perdido do sistema.

### Questão 40
Qual a importância de observar a ordem de execução das transações em testes práticos?

> Observar a ordem nos testes comprova quem chegou primeiro, quem teve o lock, quem foi forçado a esperar.

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

> A concorrência é a necessidade real de vários usuários acessarem o banco ao mesmo tempo. Para que isso não vire um caos, o banco utiliza bloqueios (locks) para criar filas de espera em registros que estão sendo disputados. E é o uso desses bloqueios que garante o Isolamento.

---

## 10. Desafio adicional

### Questão 42
Adapte os testes realizados para um sistema de estoque em que dois usuários tentam vender o mesmo produto simultaneamente. Explique quais riscos existem e como o banco pode evitá-los.

> Se ambos lerem o estoque como 1 e subtraírem 1, o banco pode gravar 0 duas vezes, vendendo o mesmo produto para duas pessoas.
> Para evitar, a primeira transação que chega deve aplicar um `FOR UPDATE`.

### Questão 43
Adapte os testes para um sistema de matrícula acadêmica, em que duas pessoas tentam ocupar a última vaga da mesma disciplina ao mesmo tempo.

> O primeiro aluno que clicar em matricular deve gerar um bloqueio na linha da disciplina. O segundo aluno ficará esperando o primeiro aluno terminar a matrícula e a vaga cair para zero, gerando que não há mais vagas para o segundo aluno. 

### Questão 44
Explique como você organizaria um experimento prático no VS Code com duas sessões para demonstrar espera por lock a outros estudantes.

> Abriria duas sessões no conectadas no mesmo banco. Na sessão 1, iniciaria uma transação e rodaria um `SELECT ... FOR UPDATE` em um registro, sem executar `COMMIT`. Na sessão 2, tentaria atualizar a mesma linha, verificando que essa transação ficaria em estado de espera. Então, rodaria o `COMMIT` na primeira transação e a sessão 2 seria destravada e concluiría sua operação.

### Questão 45
Compare um cenário com controle de concorrência e outro sem controle de concorrência, destacando os impactos sobre a confiabilidade dos dados.

> Em um cenário sem controle de concorrência, múltiplas transações podem ler e gravar sobre o mesmo dado simultaneamente. O impacto é a perda de confiabilidade dos dados. Sem regras para organizar os acessos, ocorrem anomalias tipo lost update.
> Com controle de concorrência, o SGBD utiliza as propriedades de isolamento e os bloqueios organizam o acesso. Se duas transações tentarem alterar o mesmo registro ao mesmo tempo, o banco força uma delas a entrar em estado de espera
