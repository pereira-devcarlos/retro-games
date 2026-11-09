-- Aula 1, Etapa 3: estrutura do módulo de Catálogo e Administração.
-- Execute somente em um banco retrogames existente e sem estas tabelas.
-- Este script não cria o banco, não insere dados e não altera tabelas existentes.
-- Após executado, preserve este arquivo; alterações devem usar novos scripts.
USE retrogames;

-- Tabelas de domínio possuem identificadores fixos, sem AUTO_INCREMENT.
CREATE TABLE tb_condicao_jogo (
    co_condicao_jogo INT NOT NULL,
    ds_condicao_jogo VARCHAR(50) NOT NULL,
    PRIMARY KEY (co_condicao_jogo),
    CONSTRAINT uq_condicao_jogo_descricao UNIQUE (ds_condicao_jogo)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE tb_perfil (
    co_perfil INT NOT NULL,
    ds_perfil VARCHAR(50) NOT NULL,
    PRIMARY KEY (co_perfil),
    CONSTRAINT uq_perfil_descricao UNIQUE (ds_perfil)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- Cadastros independentes são criados antes das tabelas que os referenciam.
CREATE TABLE tb_plataforma (
    co_seq_plataforma INT NOT NULL AUTO_INCREMENT,
    no_plataforma VARCHAR(80) NOT NULL,
    no_fabricante VARCHAR(80) NOT NULL,
    nu_ano_lancamento INT NOT NULL,
    PRIMARY KEY (co_seq_plataforma),
    CONSTRAINT uq_plataforma_nome UNIQUE (no_plataforma)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE tb_genero (
    co_seq_genero INT NOT NULL AUTO_INCREMENT,
    no_genero VARCHAR(50) NOT NULL,
    PRIMARY KEY (co_seq_genero),
    CONSTRAINT uq_genero_nome UNIQUE (no_genero)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- Somente ds_jogo aceita NULL. Datas devem ser fornecidas em UTC pela aplicação.
-- Preço, estoque, ano e desativação são regras da aplicação, não do banco.
-- As FKs mantêm o comportamento padrão, sem ações referenciais explícitas.
CREATE TABLE tb_jogo (
    co_seq_jogo INT NOT NULL AUTO_INCREMENT,
    no_jogo VARCHAR(150) NOT NULL,
    ds_jogo VARCHAR(1000) NULL,
    nu_ano_lancamento INT NOT NULL,
    vl_preco DECIMAL(10,2) NOT NULL,
    qt_estoque INT NOT NULL,
    st_ativo BOOLEAN NOT NULL DEFAULT TRUE,
    dt_cadastro DATETIME NOT NULL,
    co_plataforma INT NOT NULL,
    co_condicao_jogo INT NOT NULL,
    PRIMARY KEY (co_seq_jogo),
    INDEX ix_jogo_nome (no_jogo),
    INDEX ix_jogo_plataforma (co_plataforma),
    INDEX ix_jogo_condicao_jogo (co_condicao_jogo),
    CONSTRAINT fk_jogo_plataforma FOREIGN KEY (co_plataforma)
        REFERENCES tb_plataforma (co_seq_plataforma),
    CONSTRAINT fk_jogo_condicao_jogo FOREIGN KEY (co_condicao_jogo)
        REFERENCES tb_condicao_jogo (co_condicao_jogo)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- Associação N:N: a PK composta impede repetir o mesmo par jogo/gênero.
-- A PK já atende à FK co_jogo; apenas co_genero precisa de índice adicional.
CREATE TABLE tb_jogo_genero (
    co_jogo INT NOT NULL,
    co_genero INT NOT NULL,
    PRIMARY KEY (co_jogo, co_genero),
    INDEX ix_jogo_genero_genero (co_genero),
    CONSTRAINT fk_jogo_genero_jogo FOREIGN KEY (co_jogo)
        REFERENCES tb_jogo (co_seq_jogo),
    CONSTRAINT fk_jogo_genero_genero FOREIGN KEY (co_genero)
        REFERENCES tb_genero (co_seq_genero)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- Armazena apenas o hash da senha. O administrador será criado em etapa futura.
CREATE TABLE tb_usuario (
    co_seq_usuario INT NOT NULL AUTO_INCREMENT,
    no_usuario VARCHAR(100) NOT NULL,
    ds_email VARCHAR(256) NOT NULL,
    ds_senha_hash VARCHAR(500) NOT NULL,
    st_ativo BOOLEAN NOT NULL DEFAULT TRUE,
    dt_cadastro DATETIME NOT NULL,
    co_perfil INT NOT NULL,
    PRIMARY KEY (co_seq_usuario),
    CONSTRAINT uq_usuario_email UNIQUE (ds_email),
    INDEX ix_usuario_perfil (co_perfil),
    CONSTRAINT fk_usuario_perfil FOREIGN KEY (co_perfil)
        REFERENCES tb_perfil (co_perfil)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
