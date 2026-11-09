# RetroGames

Projeto acadêmico de desenvolvimento web full-stack para uma loja de jogos retrô usados. O desenvolvimento é incremental, com ASP.NET Core, MySQL e React, seguindo a especificação e as orientações do professor em [AGENTS.md](AGENTS.md).

> Estado atual: Aulas 1 e 2 implementadas, com modelos, scripts SQL e camada Repository. O catálogo e a administração ainda não estão disponíveis pela API ou pela interface web.

## 1. Objetivo e funcionalidades previstas

O projeto exercita modelagem relacional, SQL, acesso assíncrono a dados com ADO.NET e organização em camadas.

O escopo funcional planejado inclui:

- Catálogo público com busca textual, filtros por plataforma e gênero e paginação.
- Consulta de detalhes dos jogos.
- Manutenção de plataformas.
- Manutenção e desativação de jogos, com associação a gêneros.
- Consulta de gêneros e condições de conservação.
- Autenticação e autorização do administrador.

Já existem operações de persistência para plataformas, jogos e associações, além das consultas de gêneros e condições. Essas operações ainda não estão integradas a fluxos completos da aplicação.

## 2. Tecnologias utilizadas

| Componente | Tecnologia | Versão configurada |
| --- | --- | --- |
| Backend | .NET / ASP.NET Core com controllers | 10 (`net10.0`) |
| Acesso a dados | ADO.NET e MySqlConnector | 2.6.2 |
| Banco | MySQL em Docker Compose | Imagem `mysql:8.0` |
| Frontend | React e React DOM, com JavaScript | 19; lockfile: 19.3.1 |
| Build do frontend | Vite | 8; lockfile: 8.3.6 |
| Plugin React | `@vitejs/plugin-react` | 6; lockfile: 6.2.1 |
| Ambiente JavaScript | Node.js | 22, definido em `.nvmrc` |
| Testes .NET | xUnit v3 | 3.0.0 |
| Executor de testes | Microsoft.NET.Test.Sdk / xunit.runner.visualstudio | 17.14.1 / 3.0.2 |

FluentValidation, Moq, Bootstrap, Axios, React Router e documentação OpenAPI/Swagger pertencem ao planejamento do curso, mas ainda não estão instalados ou configurados. Não há Entity Framework, Dapper ou TypeScript.

## 3. Arquitetura da solução

O fluxo previsto é `React → Controller → Service → Repository → MySQL`. Atualmente, a camada Repository existe, mas ainda não está registrada ou conectada aos controllers.

| Projeto | Responsabilidade | Estado atual |
| --- | --- | --- |
| `RetroGames.Model` | Entidades correspondentes às tabelas e constantes de domínio | Sete modelos e duas classes de constantes |
| `RetroGames.Repository` | SQL parametrizado e mapeamento dos resultados | Base, cinco repositories e agregador `RepositorySet` |
| `RetroGames.Services` | Regras de negócio, composição de dados e transações | Estrutura inicial; sem serviços implementados |
| `RetroGames.WebApi.ApiModels` | Contratos de entrada/saída e envelope da API | Estrutura inicial; sem contratos implementados |
| `RetroGames.WebApi` | Controllers e configuração HTTP | Template com `WeatherForecast`; sem endpoints do RetroGames |
| `RetroGames.WebApi.UnitTests` | Testes unitários | Um teste mínimo de infraestrutura do xUnit |
| `retrogames.web` | Interface React | Template inicial do Vite, sem telas de negócio |

Referências diretas entre projetos:

- `Model` e `WebApi.ApiModels`: nenhuma.
- `Repository`: `Model`.
- `Services`: `Model`, `Repository` e `WebApi.ApiModels`.
- `WebApi`: `Model`, `Repository`, `Services` e `WebApi.ApiModels`.
- `WebApi.UnitTests`: `WebApi` e `Services`.

Por decisão didática, cada consulta dos repositories lê uma única tabela, sem JOINs. Filtros, ordenação, contagem e paginação são executados no SQL. A composição entre tabelas e as transações ficarão no Service. Os JOINs dos exercícios em `database/` não pertencem à implementação dos repositories.

## 4. Estrutura de diretórios

```text
retro-games/
├── RetroGames.sln
├── RetroGames.Model/
│   ├── Model/
│   └── Constantes/
├── RetroGames.Repository/
│   ├── RepositoryBase.cs
│   ├── RepositoryConfig.cs
│   ├── RegistroDuplicadoException.cs
│   ├── PlataformaRepository.cs
│   ├── JogoRepository.cs
│   ├── JogoGeneroRepository.cs
│   ├── GeneroRepository.cs
│   ├── CondicaoJogoRepository.cs
│   ├── RepositorySet.cs
│   └── interfaces correspondentes
├── RetroGames.Services/
├── RetroGames.WebApi.ApiModels/
├── RetroGames.WebApi/
│   ├── Controllers/
│   └── Properties/launchSettings.json
├── RetroGames.WebApi.UnitTests/
├── retrogames.web/
│   ├── src/
│   ├── public/
│   ├── package.json
│   ├── package-lock.json
│   └── vite.config.js
├── database/
├── compose.yaml
├── .env.example
├── .gitignore
├── .nvmrc
├── AGENTS.md
└── README.md
```

O `.env` local não é versionado. Os arquivos `Class1.cs` dos templates foram preservados.

## 5. Banco de dados e scripts SQL

O módulo possui sete tabelas: `tb_condicao_jogo`, `tb_perfil`, `tb_plataforma`, `tb_genero`, `tb_jogo`, `tb_jogo_genero` e `tb_usuario`. A tabela associativa representa o relacionamento N:N entre jogos e gêneros.

A estrutura usa InnoDB, `utf8mb4` e `utf8mb4_0900_ai_ci`, com PKs, FKs e restrições UNIQUE. Não há triggers, procedures, functions ou CHECKs. A descrição do jogo é a única coluna anulável.

| Script | Finalidade e execução |
| --- | --- |
| `001_criar_tabelas.sql` | Criar as sete tabelas no banco `retrogames` existente e vazio |
| `002_inserir_dados_exemplo.sql` | Carga única: 3 condições, 2 perfis, 6 plataformas, 8 gêneros, 20 jogos e 36 associações; nenhum usuário |
| `003_consultas_catalogo.sql` | Cinco exercícios de consulta, paginação e cenário auxiliar de plataforma sem jogos |
| `004_testes_integridade.sql` | Cinco testes manuais: erros 1452, 1062, 1451 e 1048, além da aceitação de preço zero |

Para uma instalação nova, abra os scripts no Workbench e execute primeiro o `001`, depois o `002`. Não os execute novamente em um banco já preparado.

Na carga `002`, habilite a interrupção em erros, execute as inserções sem incluir o `COMMIT`, confira os dados na mesma conexão e só então confirme a transação. Se houver erro, execute `ROLLBACK`. O MySQL pode desfazer apenas o comando que falhou, não toda a transação.

O script `003` exige informar o ID do jogo na consulta de gêneros. Seu cenário auxiliar inclui um INSERT temporário e deve terminar com `ROLLBACK`. O `004` não deve ser executado inteiro: rode cada teste por fases e execute `ROLLBACK` manualmente na mesma conexão, inclusive após os erros esperados.

Os comentários dos scripts `003` e `004` registram os resultados da validação manual. A carga original tem 19 jogos ativos; a busca por `Mario` retorna 7 jogos, distribuídos em páginas de 5 e 2. Super Metroid possui estoque zero e Crash Bandicoot está inativo.

Scripts já executados devem ser preservados; mudanças estruturais futuras entram em novos arquivos SQL.

## 6. Pré-requisitos

- Git.
- .NET SDK 10 e ASP.NET Core Targeting Pack correspondente, se distribuído separadamente pelo sistema.
- Node.js 22 e npm; NVM para usar o `.nvmrc`.
- Docker Engine e Docker Compose disponíveis.
- MySQL Workbench para preparação e validação manual do banco.
- VS Code com C# Dev Kit é o ambiente de desenvolvimento adotado no curso.

No ambiente Arch Linux utilizado, os comandos Docker são executados com `sudo`. Se seu usuário já tiver permissão para acessar o Docker, esse prefixo pode ser omitido.

## 7. Configuração do ambiente

Execute os comandos a partir da raiz do repositório, salvo indicação diferente.

### Node.js

Com o NVM carregado no terminal:

```bash
nvm install 22
nvm use
node --version
npm --version
```

O comando `nvm use` consulta o `.nvmrc`. A instalação só é necessária se a versão ainda não estiver disponível.

### Variáveis locais

Se ainda não existir `.env`, copie o modelo sem sobrescrever uma configuração existente:

```bash
cp --no-clobber .env.example .env
chmod 600 .env
```

Abra o arquivo local no editor e preencha os marcadores `SUA_SENHA`. As variáveis previstas no modelo são:

| Variável | Uso |
| --- | --- |
| `MYSQL_ROOT_PASSWORD` | Inicialização da senha root pela imagem MySQL |
| `ConnectionStrings__Default` | Conexão futura da API com `127.0.0.1:3307`, banco `retrogames` |

Utilize a mesma senha válida do banco nos dois campos. Se o volume já foi inicializado, alterar `.env` não redefine a senha armazenada no MySQL. Caracteres especiais precisam respeitar os formatos do `.env` e da connection string.

O `.env` deve permanecer fora do Git; `.env.example` contém somente marcadores. Não compartilhe senhas em comandos, logs ou commits. A API ainda não carrega esse arquivo nem entrega sua connection string ao Repository.

## 8. Execução local

### Banco de dados

```bash
sudo docker compose config --quiet
sudo docker compose up -d mysql
sudo docker compose ps
```

A configuração publica somente `127.0.0.1:3307`, encaminhando para a porta 3306 do contêiner. Os dados persistem no volume `retrogames_mysql_dados`. O banco `retrogames` é criado pela imagem na primeira inicialização; as tabelas são criadas manualmente pelo script `001`.

Configure no Workbench uma conexão **Standard TCP/IP**, host `127.0.0.1`, porta `3307` e usuário `root`. Informe a senha localmente. Esse uso de root é uma simplificação acadêmica prevista nas diretrizes do projeto.

Os scripts SQL não são executados automaticamente pelo Compose. Este serviço é separado de uma instalação local de MariaDB e dos bancos de outros projetos.

### Backend

```bash
dotnet restore RetroGames.sln
dotnet build RetroGames.sln
dotnet run --project RetroGames.WebApi --launch-profile http -- --urls http://localhost:5080
```

O comando fixa a porta 5080 nesta execução. Os perfis atuais de `launchSettings.json` usam porta dinâmica (`localhost:0`), portanto executar sem `--urls` não garante essa porta.

A API oferece somente o endpoint de exemplo `GET /WeatherForecast`. O endereço raiz não possui página inicial. Swagger, autenticação, contratos do RetroGames, leitura de `.env` e registro dos repositories ainda não estão configurados.

### Frontend

Em outro terminal, ative o Node 22 na raiz e entre na pasta do frontend:

```bash
nvm use
cd retrogames.web
npm ci
npm run dev -- --host 127.0.0.1 --port 5173 --strictPort
```

Acesse `http://127.0.0.1:5173`. A aplicação exibe o template React/Vite. O `vite.config.js` contém o plugin React, mas ainda não configura proxy `/api` ou integração com o backend.

Para gerar e visualizar o build, dentro de `retrogames.web`:

```bash
npm run build
npm run preview
```

O build é gerado em `dist/`; o endereço de preview é informado pelo Vite no terminal.

## 9. Verificações e testes

Na raiz:

```bash
dotnet build RetroGames.sln
dotnet test RetroGames.sln
```

O projeto de testes contém um único `[Fact]` de infraestrutura para confirmar o funcionamento do xUnit. Ainda não há testes de regras de negócio, repositories ou endpoints do RetroGames.

No frontend, `npm run build` verifica a geração da aplicação. Não há suíte automatizada de testes JavaScript configurada. Os testes SQL do Workbench são separados dos testes executados por `dotnet test`.

## 10. Estado atual do desenvolvimento

| Entrega | Situação |
| --- | --- |
| Solução com seis projetos .NET 10 e frontend JavaScript | Implementada |
| Docker Compose e modelo de variáveis locais | Implementados |
| Estrutura SQL, dados de exemplo, consultas e testes de integridade | Scripts implementados, com validação manual registrada |
| Sete modelos e constantes de condições e perfis | Implementados |
| Base Repository e tratamento de duplicidade MySQL 1062 | Implementados |
| Repositories de plataformas, jogos, associações, gêneros e condições | Implementados |
| Agregador dos cinco repositories | Implementado |
| Regras de negócio, Services e transações da aplicação | Planejados |
| Contratos, validação, tratamento HTTP e endpoints do RetroGames | Planejados |
| Autenticação, autorização e proteção CSRF | Planejadas |
| Telas de catálogo e administração e integração frontend/API | Planejadas |

A implementação concluída cobre as Aulas 1 e 2. Os próximos passos são a camada Service e, nas etapas seguintes, a integração HTTP e as telas do sistema, conforme os roteiros do professor.
