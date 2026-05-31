# Exercício Prático de NoSQL com MongoDB — Versão Básica

## Objetivo

Este exercício tem como objetivo apresentar os conceitos fundamentais de bancos de dados NoSQL utilizando MongoDB, com foco em:

- CRUD;
- operadores;
- arrays;
- objetos aninhados;
- agregações;
- modelagem NoSQL.

---

# 1. Contexto do Exercício

Uma pequena plataforma de streaming deseja organizar informações sobre filmes. Para isso, será utilizado um banco MongoDB chamado `streamflix`, com uma coleção chamada `filmes`.

Cada filme será representado como um documento JSON.

---

# 2. Criando o Banco e a Coleção

No MongoDB Playground do VS Code, utilize:

```javascript
use("filmes")
```

A coleção `filmes` será criada automaticamente quando os primeiros documentos forem inseridos.

---

# 3. Inserindo a Base de Dados Inicial

Execute o comando abaixo para criar uma pequena base de dados inicial.

```javascript
use("filmes")

db.filmes.insertMany([
  {
    titulo: "Interestelar",
    ano: 2014,
    generos: ["Ficção Científica", "Drama"],
    avaliacao: 9.5,
    duracao: 169,
    disponivel: true,
    diretor: {
      nome: "Christopher Nolan",
      pais: "Reino Unido"
    }
  },
  {
    titulo: "Matrix",
    ano: 1999,
    generos: ["Ação", "Ficção Científica"],
    avaliacao: 9.2,
    duracao: 136,
    disponivel: true,
    diretor: {
      nome: "Lana Wachowski e Lilly Wachowski",
      pais: "Estados Unidos"
    }
  },
  {
    titulo: "Avatar",
    ano: 2009,
    generos: ["Aventura", "Ficção Científica"],
    avaliacao: 8.8,
    duracao: 162,
    disponivel: false,
    diretor: {
      nome: "James Cameron",
      pais: "Canadá"
    }
  },
  {
    titulo: "A Origem",
    ano: 2010,
    generos: ["Ação", "Suspense", "Ficção Científica"],
    avaliacao: 9.0,
    duracao: 148,
    disponivel: true,
    diretor: {
      nome: "Christopher Nolan",
      pais: "Reino Unido"
    }
  },
  {
    titulo: "Divertida Mente",
    ano: 2015,
    generos: ["Animação", "Família"],
    avaliacao: 8.7,
    duracao: 95,
    disponivel: true,
    diretor: {
      nome: "Pete Docter",
      pais: "Estados Unidos"
    }
  }
])
```

---

# 4. Parte 1 — Consultas Básicas

## Exercício 1
Liste todos os filmes cadastrados.

```javascript
db.filmes.find()
```

## Exercício 2
Busque apenas o filme `Matrix`.

```javascript
db.filmes.find({ titulo: "Matrix" })
```

## Exercício 3
Liste apenas os filmes disponíveis.

```javascript
db.filmes.find({ disponivel: true })
```

## Exercício 4
Busque o filme cujo título seja `Avatar`.

```javascript
db.filmes.findOne({ titulo: "Avatar" })
```

---

# 5. Parte 2 — CRUD

CRUD representa as quatro operações básicas sobre dados:

- Create: criar/inserir;
- Read: ler/consultar;
- Update: atualizar;
- Delete: remover.

## Exercício 5 — Create
Insira um novo filme.

```javascript
db.filmes.insertOne({
  titulo: "O Senhor dos Anéis",
  ano: 2001,
  generos: ["Fantasia", "Aventura"],
  avaliacao: 9.1,
  duracao: 178,
  disponivel: true,
  diretor: {
    nome: "Peter Jackson",
    pais: "Nova Zelândia"
  }
})
```

## Exercício 6 — Read
Consulte o filme inserido.

```javascript
db.filmes.find({ titulo: "O Senhor dos Anéis" })
```

## Exercício 7 — Update
Atualize a avaliação de `Avatar` para `9.0`.

```javascript
db.filmes.updateOne(
  { titulo: "Avatar" },
  { $set: { avaliacao: 9.0 } }
)
```

## Exercício 8 — Delete
Remova o filme `O Senhor dos Anéis`.

```javascript
db.filmes.deleteOne({ titulo: "O Senhor dos Anéis" })
```
