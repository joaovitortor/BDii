# StreamFlix — Exercícios Resolvidos (MongoDB)

## Como rodar isso na prática

1. **Crie um cluster no MongoDB Atlas** (gratuito, tier M0) em cloud.mongodb.com, com usuário/senha de acesso e seu IP liberado em Network Access.
2. **Instale a extensão "MongoDB for VS Code"** no VS Code.
3. Na extensão, clique em **Connect** e cole a *connection string* do seu cluster (Atlas → Connect → Drivers, algo como `mongodb+srv://usuario:senha@cluster0.xxxxx.mongodb.net/`).
4. Crie um **Playground** (ícone da extensão → "Create MongoDB Playground", ou `Ctrl+Shift+P` → "MongoDB: Create Playground"). Isso gera um arquivo `.mongodb`.
5. Cole o bloco de criação da base (seção 2 do material) num playground e rode ele primeiro (botão ▶ "Run All" no canto superior direito, ou `Ctrl+Shift+E` / `Cmd+Shift+E`).
6. Para cada exercício, cole o comando correspondente no playground e:
   - **Run All** roda o arquivo inteiro;
   - **selecione o trecho de código** e use "Run Selected Lines" (clique direito → "Run Selected Lines from Playground") para rodar só aquele comando.
7. O resultado aparece num painel lateral ("Playground Result").

Alternativa sem VS Code: instale o `mongosh` (MongoDB Shell) e rode `mongosh "sua_connection_string"`, colando os comandos direto no terminal.

---

## Nível 1 — Primeiros contatos

**1.**
Liste todos os documentos da coleção `usuarios`.
```javascript
db.usuarios.find({})
```

**2.**
Liste todos os documentos da coleção `conteudos`.
```javascript
db.conteudos.find({})
```

**3.**
Liste todos os usuários da cidade de `Curitiba`.
```javascript
db.usuarios.find({ cidade: "Curitiba" })
```

**4.**
Liste todos os conteúdos do tipo `filme`.
```javascript
db.conteudos.find({ tipo: "filme" })
```

**5.**
Busque o conteúdo cujo título é `Matrix`.
```javascript
db.conteudos.findOne({ titulo: "Matrix" })
```

**6.**
Insira um novo usuário na coleção `usuarios` com os campos:
```javascript
db.usuarios.insertOne({
  nome: "João Bidoia",
  email: "joao.bidoia@email.com",
  idade: 21,
  cidade: "Maringá",
  estado: "PR",
  interesses: ["Tecnologia", "Ficção Científica"],
  ativo: true
})
```

**7.**
Insira um novo conteúdo do tipo `filme` com os campos:

- título;
- tipo;
- ano;
- gêneros;
- avaliação média;
- duração em minutos;
- disponível.

```javascript
db.conteudos.insertOne({
  titulo: "O Poço",
  tipo: "filme",
  ano: 2019,
  generos: ["Suspense", "Terror"],
  avaliacaoMedia: 7.6,
  duracaoMinutos: 94,
  disponivel: true
})
```

---

## Nível 2 — Operadores de comparação

**8.**
Liste os conteúdos com avaliação média maior que `9`.
```javascript
db.conteudos.find({ avaliacaoMedia: { $gt: 9 } })
```

**9.**
Liste os usuários com idade maior que `30`.
```javascript
db.usuarios.find({ idade: { $gt: 30 } })
```

**10.**
Liste os conteúdos lançados antes do ano `2010`.
```javascript
db.conteudos.find({ ano: { $lt: 2010 } })
```

**11.**
Liste os conteúdos lançados a partir de `2015`.
```javascript
db.conteudos.find({ ano: { $gte: 2015 } })
```

**12.**
Liste os conteúdos cuja avaliação média seja menor ou igual a `8.8`.
```javascript
db.conteudos.find({ avaliacaoMedia: { $lte: 8.8 } })
```

**13.**
Liste os usuários que não são do estado `PR`.
```javascript
db.usuarios.find({ estado: { $ne: "PR" } })
```

---

## Nível 3 — Consultas com arrays

**14.**
Liste os conteúdos que possuem o gênero `Drama`.
```javascript
db.conteudos.find({ generos: "Drama" })
```

**15.**
Liste os conteúdos que possuem o gênero `Ficção Científica`.
```javascript
db.conteudos.find({ generos: "Ficção Científica" })
```

**16.**
Liste os conteúdos que possuem os gêneros `Drama` e `Crime` ao mesmo tempo.
```javascript
db.conteudos.find({ generos: { $all: ["Drama", "Crime"] } })
```

**17.**
Liste os usuários que possuem interesse em `Suspense`.
```javascript
db.usuarios.find({ interesses: "Suspense" })
```

**18.**
Liste os conteúdos que possuem pelo menos um dos seguintes gêneros:

- `Terror`
- `Mistério`
  
```javascript
db.conteudos.find({ generos: { $in: ["Terror", "Mistério"] } })
```

**19.**
Liste os conteúdos que não possuem o gênero `Comédia`.
```javascript
db.conteudos.find({ generos: { $nin: ["Comédia"] } })
```

---

## Nível 4 — Objetos aninhados

**20.**
Liste os conteúdos dirigidos por `Christopher Nolan`.
```javascript
db.conteudos.find({ "diretor.nome": "Christopher Nolan" })
```

**21.**
Liste os conteúdos cujo diretor é do `Reino Unido`.
```javascript
db.conteudos.find({ "diretor.pais": "Reino Unido" })
```

**22.**
Liste os usuários cujo bairro seja `Centro`.
```javascript
db.usuarios.find({ "endereco.bairro": "Centro" })
```

**23.**
Liste os usuários que possuem o campo `endereco`.
```javascript
db.usuarios.find({ endereco: { $exists: true } })
```

**24.**
Liste os usuários que não possuem o campo `endereco`.
```javascript
db.usuarios.find({ endereco: { $exists: false } })
```

---

## Nível 5 — Atualizações básicas

**25.**
Atualize o usuário `Carlos Lima` para que o campo `ativo` passe a ser `true`.
```javascript
db.usuarios.updateOne(
  { nome: "Carlos Lima" },
  { $set: { ativo: true } }
)
```

**26.**
Atualize o conteúdo `Cidade de Deus` para que o campo `disponivel` passe a ser `true`.
```javascript
db.conteudos.updateOne(
  { titulo: "Cidade de Deus" },
  { $set: { disponivel: true } }
)
```

**27.**
Adicione o campo `idiomaOriginal` ao filme `Matrix`, com o valor `Inglês`.
```javascript
db.conteudos.updateOne(
  { titulo: "Matrix" },
  { $set: { idiomaOriginal: "Inglês" } }
)
```

**28.**
Adicione o campo `classificacao` ao filme `Interestelar`, com o valor `10+`.
```javascript
db.conteudos.updateOne(
  { titulo: "Interestelar" },
  { $set: { classificacao: "10+" } }
)
```

**29.**
Atualize a avaliação média de `Avatar` para `9.0`.
```javascript
db.conteudos.updateOne(
  { titulo: "Avatar" },
  { $set: { avaliacaoMedia: 9.0 } }
)
```

---

## Nível 6 — Atualizações com operadores

**30.**
Incremente em `1` a quantidade de visualizações do conteúdo `Matrix`.
```javascript
db.conteudos.updateOne(
  { titulo: "Matrix" },
  { $inc: { visualizacoes: 1 } }
)
```

**31.**
Incremente em `1000` a quantidade de visualizações de todos os conteúdos disponíveis.
```javascript
db.conteudos.updateMany(
  { disponivel: true },
  { $inc: { visualizacoes: 1000 } }
)
```

**32.**
Adicione o gênero `Clássico` ao filme `Matrix`.
```javascript
db.conteudos.updateOne(
  { titulo: "Matrix" },
  { $push: { generos: "Clássico" } }
)
```

**33.**
Remova o gênero `Clássico` do filme `Matrix`.
```javascript
db.conteudos.updateOne(
  { titulo: "Matrix" },
  { $pull: { generos: "Clássico" } }
)
```

**34.**
Remova o campo `telefone` da usuária `Beatriz Nunes`.
```javascript
db.usuarios.updateOne(
  { nome: "Beatriz Nunes" },
  { $unset: { telefone: "" } }
)
```

**35.**
Adicione o benefício `sem anúncios` aos usuários do plano `Premium` na coleção `assinaturas`.
```javascript
db.assinaturas.updateMany(
  { plano: "Premium" },
  { $push: { beneficios: "sem anúncios" } }
)
```

---

## Nível 7 — Operadores lógicos

**36.**
Liste os conteúdos que são filmes e possuem avaliação média maior que `9`.
```javascript
db.conteudos.find({ tipo: "filme", avaliacaoMedia: { $gt: 9 } })
```

**37.**
Liste os usuários que são de `Curitiba` ou de `Maringá`.
```javascript
db.usuarios.find({ $or: [{ cidade: "Curitiba" }, { cidade: "Maringá" }] })
```

**38.**
Liste os conteúdos que são séries ou documentários.
```javascript
db.conteudos.find({ tipo: { $in: ["serie", "documentario"] } })
```

**39.**
Liste os conteúdos que possuem avaliação maior que `9` e visualizações acima de `2000000`.
```javascript
db.conteudos.find({
  avaliacaoMedia: { $gt: 9 },
  visualizacoes: { $gt: 2000000 }
})
```

**40.**
Liste os usuários ativos com idade menor que `30`.
```javascript
db.usuarios.find({ ativo: true, idade: { $lt: 30 } })
```

---

## Nível 8 — Campos opcionais e flexibilidade NoSQL

**41.**
Liste os conteúdos que possuem o campo `premios`.
```javascript
db.conteudos.find({ premios: { $exists: true } })
```

**42.**
Liste os conteúdos que não possuem o campo `diretor`.
```javascript
db.conteudos.find({ diretor: { $exists: false } })
```

**43.**
Liste os usuários que possuem o campo `premium`.
```javascript
db.usuarios.find({ premium: { $exists: true } })
```

**44.**
Liste os conteúdos que possuem o campo `temporadas`.
```javascript
db.conteudos.find({ temporadas: { $exists: true } })
```

**45. Por que documentos da mesma coleção podem ter campos diferentes?**

O MongoDB é *schemaless* (sem esquema fixo obrigatório): ao contrário de uma tabela SQL, onde toda linha precisa ter as mesmas colunas, uma coleção no MongoDB só exige que os documentos sejam BSON válidos. Isso permite guardar, na mesma coleção `conteudos`, filmes (com `duracaoMinutos`), séries (com `temporadas` e `episodios`) e documentários (com `narrador`), sem precisar criar coleções separadas ou preencher campos vazios com `null`. Isso reflete bem o mundo real: tipos diferentes de mídia têm atributos diferentes, e forçar um esquema único geraria muitos campos inúteis ou nulos.

---

## Nível 9 — Remoção de documentos

**46.**
Remova o usuário que você criou no Exercício 6.
```javascript
db.usuarios.deleteOne({ email: "joao.bidoia@email.com" })
```

**47.**

```javascript
db.conteudos.deleteOne({ titulo: "O Poço" })
```

**48.**
Remova todas as avaliações com nota menor que `8`.
```javascript
db.avaliacoes.deleteMany({ nota: { $lt: 8 } })
```

**49.**
Remova os registros de histórico cujo progresso seja menor que `40`.
```javascript
db.historico.deleteMany({ progressoPercentual: { $lt: 40 } })
```

**50. Coleções separadas x um único documento gigante**

Manter `usuarios`, `assinaturas`, `avaliacoes` e `historico` separados evita duplicar dados que crescem sem limite (um usuário pode ter centenas de itens de histórico) e mantém cada documento pequeno e rápido de ler/escrever. Já um documento único com tudo embutido fica gigante, ultrapassa mais rápido o limite de 16MB por documento do MongoDB, e fica mais caro de atualizar (toda vez que o usuário assiste algo, seria preciso reescrever o documento inteiro do usuário). Por outro lado, dados separados exigem consultas adicionais (ou `$lookup`) para juntar informações relacionadas, o que uma coleção só embutida resolveria com uma única leitura.

**51. Vantagem e desvantagem de documentos aninhados**

- *Vantagem:* dados que são sempre lidos juntos (como `endereco` dentro de `usuarios`, ou `diretor` dentro de `conteudos`) ficam disponíveis numa única leitura, sem precisar de joins/`$lookup`, o que é mais rápido e simples.
- *Desvantagem:* se aquele sub-documento crescer muito (por exemplo, um array de milhares de avaliações aninhado dentro do conteúdo) ou precisar ser consultado/atualizado de forma independente e frequente, o documento pai fica pesado e as atualizações ficam mais custosas e mais difíceis de indexar seletivamente.

**52. Quando usar referência entre coleções**

Referências (guardar só o `_id` ou uma chave como `usuarioEmail`) fazem mais sentido quando: os dados relacionados crescem sem limite (histórico, avaliações), são atualizados com frequência e de forma independente da entidade "pai", são compartilhados/reutilizados por múltiplos documentos, ou quando o volume tornaria o documento principal grande demais.

**53. Quando usar dados incorporados (embutidos)**

Dados incorporados fazem mais sentido quando a informação é pequena, tem um relacionamento de "1 para poucos", raramente muda sozinha, e é quase sempre lida junto com o documento pai — como `endereco` dentro de `usuarios` ou `diretor` dentro de `conteudos`. Isso evita consultas extras e mantém a leitura mais rápida e simples.
