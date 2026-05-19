# Aplicando conceitos de transações em banco de dados sequencial

## 1. Atividade prática

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
Qual é o objetivo da tabela `contas` neste cenário prático?

> Simular Transferências, Demonstrar a Atomicidade e Validar Consistência

**Pergunta 2**  
Quais são os saldos iniciais de cada titular antes da execução das transações?

>Ana -> 1000 
Bruno -> 500
Carlos -> 300
Daniela -> 800
---

#### Etapa 2. Testar COMMIT

Execute:

```sql
START TRANSACTION;

UPDATE contas
SET saldo = saldo - 100
WHERE id = 1;

UPDATE contas
SET saldo = saldo + 100
WHERE id = 2;

COMMIT;
```

Depois:

```sql
SELECT * FROM contas;
```

**Pergunta 3**  
O que aconteceu com os saldos após o `COMMIT`?

> As alterações feitas pelas instruções `UPDATE` tornaram-se permanentes no banco de dados.

**Pergunta 4**  
Por que as duas instruções `UPDATE` devem fazer parte da mesma transação?

> Porque foi uma transferência da contaid = 1 para a contaid = 2, a transação precisa garantir que o saldo total se mantenha
---

#### Etapa 3. Testar ROLLBACK

Execute:

```sql
START TRANSACTION;

UPDATE contas
SET saldo = saldo - 50
WHERE id = 2;

UPDATE contas
SET saldo = saldo + 50
WHERE id = 3;

ROLLBACK;
```

Depois:

```sql
SELECT * FROM contas;
```

**Pergunta 5**  
Por que os valores não foram alterados ao final?

> Porque o `ROLLBACK` cancelou a transação em andamento

**Pergunta 6**  
Em quais situações reais o uso de `ROLLBACK` seria essencial?

> Ele é essencial sempre que uma transação não consegue ser concluída com sucesso.
> Por ex: Falta de saldo na conta, falha de rede ou queda de energia, cancelamento explícito.
---

#### Etapa 4. Testar erro lógico antes da confirmação

Execute:

```sql
START TRANSACTION;

UPDATE contas
SET saldo = saldo - 2000
WHERE id = 3;

SELECT * FROM contas WHERE id = 3;

ROLLBACK;
```

Depois:

```sql
SELECT * FROM contas WHERE id = 3;
```

**Pergunta 7**  
Por que a transação foi desfeita neste caso?

> A transação foi desfeita pelo `ROLLBACK` porque a operação gerou um erro nas regras de negócio. O Carlos ficaria com saldo negativo.

**Pergunta 8**  
Qual problema de integridade poderia ocorrer se essa transação fosse confirmada?

> O banco de dados perderia a propriedade de Consistência.
---

#### Etapa 5. Testar múltiplas operações na mesma transação

Execute:

```sql
START TRANSACTION;

UPDATE contas
SET saldo = saldo - 100
WHERE id = 4;

UPDATE contas
SET saldo = saldo + 60
WHERE id = 1;

UPDATE contas
SET saldo = saldo + 40
WHERE id = 2;

COMMIT;
```

Depois:

```sql
SELECT * FROM contas;
```

**Pergunta 9**  
Qual conta foi debitada e quais contas foram creditadas?

> A conta da Daniela foi debitada e a conta do Bruno e do Carlos foram creditadas.

**Pergunta 10**  
Por que esse conjunto de operações também deve ser tratado como uma única transação?

> Se o sistema falhasse após realizar apenas um dos créditos, parte do dinheiro da transferência desapareceria.

---

#### Etapa 6. Testar leitura durante transação

Execute:

```sql
START TRANSACTION;

UPDATE contas
SET saldo = saldo - 150
WHERE id = 1;
```

Sem executar `COMMIT` ainda, em outra sessão rode:

```sql
SELECT * FROM contas WHERE id = 1;
```

Depois volte para a primeira sessão e execute:

```sql
ROLLBACK;
```

**Pergunta 11**  
Qual era o objetivo de observar o valor da conta em outra sessão antes do `COMMIT`?

> Verificar se a Sessão 2 iria enxergar o saldo original da conta ou o saldo temporário que a Sessão 1 aletrou mas ainda não confirmou.

**Pergunta 12**  
Como esse teste se relaciona com o conceito de isolamento?

> O isolamento garante que transações concorrentes não interfiram umas nas outras e sejam executadas como se estivessem sozinhas no sistema. Uma transação não deve expor seus resultados intermediários para outras sessões.

---

#### Etapa 7. Testar lock com duas sessões

Abra duas conexões.

### Sessão 1

```sql
START TRANSACTION;

SELECT * FROM contas WHERE id = 1 FOR UPDATE;

UPDATE contas
SET saldo = saldo - 200
WHERE id = 1;
```

Não execute `COMMIT` ainda.

### Sessão 2

```sql
START TRANSACTION;

UPDATE contas
SET saldo = saldo + 300
WHERE id = 1;
```

**Observe**  
A segunda sessão pode ficar bloqueada esperando a primeira terminar.

Agora volte para a Sessão 1 e faça:

```sql
COMMIT;
```

Depois finalize a Sessão 2.

**Pergunta 13**  
O que aconteceu com a segunda transação?

> A segunda transação ficou bloqueada (em estado de espera), aguardando na fila para ser executada.

**Pergunta 14**  
Por que ela precisou esperar?

> Ela precisou esperar porque o SGBD aplicou um bloqueio sobre o registro acessado pela Sessão 1. Para garantir a propriedade do Isolamento em ambientes multiusuários, o banco de dados impede que a Sessão 2 modifique o mesmo dado simultaneamente.

**Pergunta 15**  
Qual a função do `FOR UPDATE`?

> É aplicar propositalmente um bloqueio explícito sobre as linhas lidas logo no momento da consulta. Ela avisa ao banco de dados que a transação pretende atualizar aqueles dados em breve, impedindo que outras transações os modifiquem no meio do processo.
---

#### Etapa 8. Testar concorrência em registros diferentes

Abra duas conexões.

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

Depois execute `COMMIT` em ambas.

**Pergunta 16**  
Por que nesse caso as transações tendem a não disputar o mesmo recurso?

> Porque as transações estão manipulando linhas diferentes da mesma tabela.

**Pergunta 17**  
O que esse teste mostra sobre concorrência em linhas diferentes da tabela?

> Quando não há disputa pelo mesmo dado específico, as transações coexistem de forma concorrente.
---

#### Etapa 9. Criar tabela de movimentações

Execute:

```sql
DROP TABLE IF EXISTS movimentacoes;

CREATE TABLE movimentacoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    conta_origem INT,
    conta_destino INT,
    valor DECIMAL(10,2),
    data_movimentacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Pergunta 18**  
Qual é a importância de registrar movimentações além de atualizar os saldos?

> Registrar as movimentações serve para criar um histórico. Se apenas atualizar os saldos, o banco de dados sabe quanto dinheiro o usuário tem agora, mas perde a informação de como o dinheiro chegou ou saiu de lá. Garante verificar possíveis fraudes ou erros no sistema
---

#### Etapa 10. Transferência com registro em histórico

Execute:

```sql
START TRANSACTION;

UPDATE contas
SET saldo = saldo - 120
WHERE id = 2;

UPDATE contas
SET saldo = saldo + 120
WHERE id = 3;

INSERT INTO movimentacoes (conta_origem, conta_destino, valor)
VALUES (2, 3, 120.00);

COMMIT;
```

Depois:

```sql
SELECT * FROM contas;
SELECT * FROM movimentacoes;
```

**Pergunta 19**  
Por que o `INSERT` na tabela `movimentacoes` deve estar na mesma transação dos `UPDATE`s?

> Para respeitar as propriedades de Atomicidade e Consistência. A transferência bancária e o registro dessa transferência são partes da mesma regra de negócio. Garante o "Tudo ou Nada".

**Pergunta 20**  
O que poderia acontecer se o histórico fosse gravado, mas os saldos não fossem atualizados, ou vice-versa?

> Se o saldo for alterado e o histórico falhar, o dinheiro muda de conta sem deixar nenhum rastro
> Se o histórico foi gravado, mas o saldo falhar, o sistema vai gerar um "comprovante fantasma", registrando uma transferência mesmo que o dinheiro nunca tenha saído da conta de origem.
---

#### Etapa 11. Simular falha antes do registro da movimentação

Execute:

```sql
START TRANSACTION;

UPDATE contas
SET saldo = saldo - 80
WHERE id = 1;

UPDATE contas
SET saldo = saldo + 80
WHERE id = 4;

ROLLBACK;
```

Depois:

```sql
SELECT * FROM contas;
SELECT * FROM movimentacoes;
```

**Pergunta 21**  
O que o `ROLLBACK` garantiu nesse cenário?

> O `ROLLBACK` garantiu a reversão de todas as atualizações temporárias que já haviam sido processadas na memória RAM. Como a movimentação não conseguiu ser executada, geraria uma falha na Atomicidade.

**Pergunta 22**  
Como esse teste demonstra a propriedade de atomicidade?

> Atomicidade significa que uma transação não pode ser processada parcialmente. Ao encontrar uma falha, o SGBD decidiu cancelar toda a transação de forma atômica, desfazendo até mesmo os comandos que tinham dado certo antes.
---

#### Etapa 12. Consultar estado final

Execute:

```sql
SELECT * FROM contas;
SELECT * FROM movimentacoes;
```

**Pergunta 23**  
Como verificar se o banco permaneceu consistente após todas as operações realizadas?

> Consultadno os saldos finais da tabela de contas e verificando se cada alteração bate exatamente com os valores registrados na tabela de movimentacoes.

**Pergunta 24**  
Por que a consistência do banco depende não apenas dos comandos SQL, mas também da forma como eles são agrupados em transações?

> Porque um comando SQL individual só garante que aquele dado específico foi alterado corretamente. No entanto, a lógica real exige um grupo de comandos. Se não agrupar esse conjunto de SQLs dentro de uma transação, o SGBD não saberá que eles dependem uns dos outros.
---

## 7. Atividade dissertativa

### Questão 25
Explique o que é uma transação em banco de dados.

> Uma transação é uma unidade lógica de trabalho que agrupa um ou mais comandos SQLs que devem ser executados pelo banco de dados como um bloco único, seguindo a regra do "tudo ou nada".

### Questão 26
Descreva a diferença entre `COMMIT` e `ROLLBACK`.

>`COMMIT`: confirma a transação, tornando todas as alterações permanentes e salvas no disco.
> `ROLLBACK`: cancela a transação em andamento e desfaz todas as alterações temporárias, retornando os dados ao estado original em caso de falha ou erro.

### Questão 27
Explique por que uma transferência bancária deve ser tratada como transação.

> Porque ela exige operações múltiplas e interdependentes. Ao agrupá-las em uma transação, o SGBD garante que o sistema cair após o débito, o crédito não fique pendente.

### Questão 28
O que pode acontecer se duas transações alterarem o mesmo dado ao mesmo tempo sem controle de concorrência?

> Pode ocorrer uma anomalia grave chamada de Atualização Perdida (lost update). Isso ocorre quando uma transação sobrescreve e apaga os dados gravados por outra transação simultânea, corrompendo a consistência do banco.

### Questão 29
Qual a relação entre transações e as propriedades ACID?

> As propriedades ACID (Atomicidade, Consistência, Isolamento e Durabilidade) são o conjunto de regras fundamentais que o SGBD aplica sobre qualquer transação. Elas servem para garantir que a transação seja executada de forma segura e confiável.

### Questão 30
Explique o significado da propriedade de atomicidade no contexto de uma operação bancária.

> A atomicidade diz que uma transação é uma unidade de processamento indivisível, operando sobre a regra do "tudo ou nada". Em um contexto bancário, garante que o débito em uma conta e o crédito na outra aconteçam obrigatoriamente juntos, e, caso ocorra um erro, o SGBD desfaz toda a operação.

### Questão 31
Explique o que significa dizer que uma transação preserva a consistência do banco de dados.

> Significa que, após a execução de uma transação, o banco de dados deve obrigatoriamente transitar de um estado válido para outro estado válido, continuando consistente e respeitando todas as regras de negócio.

### Questão 32
Descreva o papel do isolamento em ambientes com múltiplos usuários acessando o mesmo banco.

> O isolamento garante que uma transação seja executada como se estivesse completamente isolada das demais, ocultando resultados intermediários (evitando "leitura suja"). Em ambientes multiusuários, ele evita que diferentes sessões interfiram umas nas outras.

### Questão 33
Explique a importância da durabilidade após a execução de um `COMMIT`.

> A durabilidade garante a sobrevivência dos dados. Após o `COMMIT` ser executado, todas as alterações são persistidas permanentemente no banco de dados.

### Questão 34
O que é controle de concorrência e por que ele é necessário?

> É um mecanismo que gerencia e sincroniza a execução intercalada de múltiplas transações simultâneas. Ele é estritamente necessário para permitir que vários usuários acessem o banco ao mesmo tempo de forma eficiente.

### Questão 35
Explique a função do lock em transações concorrentes.

> O lock é uma variável associdad a um item específico do banco de dados que controla o status de acesso a esse item. Em ambientes com transações concorrentes, sua função é sincronizar o acesso para evitar conflitos, garantindo que apenas uma transação por vez possa alterar um dado (exclusão mútua), o que impede inconsistências.

### Questão 36
Descreva um exemplo prático em que o `FOR UPDATE` seja necessário.

> O `FOR UPDATE` é usado para aplicar um bloqueio explícito logo no momento da leitura de um registro.
> Exemplo prático: Ao consultar o saldo de um cliente para realizar um débito, impede que outra sessão também altere o saldo desse cliente.

### Questão 37
O que é uma atualização perdida (*lost update*)?

> A atualização perdida é um problema de concorrência que ocorre quando duas transações leem o mesmo registro simultaneamente e, em seguida, tentam atualizá-lo. O resultado é que a alteração feita pela primeira transação é completamente sobrescrita e "perdida" pela gravação da segunda transação, deixando o banco com um valor final incorreto.

### Questão 38
Explique por que nem toda leitura concorrente gera problema, mas algumas atualizações simultâneas sim.

> O banco de dados permite múltiplos bloqueios compartilhados (read_lock), por várias transações apenas lendo o mesmo dado não alteram o estado do banco e não geram conflito. No entando, as atualizações modificam dados e exigem um bloqueio exclusivo (write_lock). Se atualizações simultâneas ocorrerem no mesmo dado sem esse bloqueio, elas destruirão a integridade da informação, gerando anomalias como a atualização perdida ou a leitura de dados temporários.

### Questão 39
Qual é a importância de registrar operações em uma tabela de histórico dentro da mesma transação?

> A importância é de garantir a Atomicidade e a Consistência do sistema. Ao agrupar a atualização do dado principal (como o saldo) e a gravação do histórico na mesma transação, o banco garante que se houver uma falha antes do fim do processo, tudo será desfeito pelo `ROLLBACK`.

### Questão 40
Em um sistema acadêmico, cite um exemplo de operação que deveria ser tratada como transação.

> A matrícula de um aluno em uma turma. O banco precisa verificar se há limites de vagas, reduzir o número de vagas disponíveis e inserir o nome do aluno na lista da disciplina.

### Questão 41
Em um sistema de estoque, cite um exemplo de falha que poderia justificar o uso de `ROLLBACK`.

> Um cliente tentar comprar o último item da loja. O sistema reduz 1 do estoque, mas no momento de cobrar no cartão de crédito, a compra é recusada ou a internet cai. O `ROLLBACK` cancela a venda e devolve o item para o estoque.

### Questão 42
Como o processamento de transações contribui para a confiabilidade de sistemas de informação?

> Ele garante que falhas de energias, erros de software ou acessos simultâneos de vários usuários não vão corromper, apagar ou duplicar dados.

---

### Questão 43
Considerando todos os experimentos realizados, explique de forma integrada como atomicidade, consistência, isolamento e durabilidade atuam em conjunto no processamento de transações.

> O Isolamento bloqueia para esconder o que você está fazendo de outros usuários, evitando que leiam dados incompletos. A Atomicidade garante que sua operação vá até o fim ou seja totalmente desfeita caso algo dê errado. Isso garante a Consistência matemática do sistema e respeita as regras de negócio. Se tudo der certo, a Durabilidade persiste as informações no disco.

---

## Desafio

### Questão 44
Adapte o exemplo bancário para um sistema de matrícula em disciplinas, em que uma transação deva:

- verificar vaga disponível
- reduzir a quantidade de vagas
- registrar a matrícula do aluno

Explique por que essas operações devem ocorrer na mesma transação.

> Devem ocorrer na mesma transação pela regra do "tudo ou nada". Se o banco travar logo após reduzir a quantidade de vagas, mas antes de registrar o nome do aluno, aquela vaga vai virar uma vaga "fantasma". Além disso, mantê-las na mesma transação permite bloquear a linha da turma para evitar que dois alunos ocupem a mesma vaga simultaneamente.

### Questão 45
Adapte o exemplo para um sistema de estoque e vendas, explicando quais operações devem ser agrupadas para evitar inconsistências.

> - Bloquear a linha do produto
> - Deduzir a quantidade do estoque
> - Inserir o registro do pagamento
> - Registrar a nota fiscal na tabela de histórico

> Se qualquer um desses passos falhar, tudo é desfeito, evitando que um produto saia do estoque sem ser pago ou que seja pago sem que a nota seja gerada.   
