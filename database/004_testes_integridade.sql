-- Aula 1, Etapa 5: cinco testes independentes, para execução MANUAL no Workbench.
-- NÃO execute este arquivo inteiro: quatro comandos devem falhar propositalmente.
-- Use uma conexão dedicada ao retrogames, sem transações ou alterações pendentes.
-- Ative Query > Stop Script Execution On Errors. Selecione cada fase separadamente:
-- preparação/START TRANSACTION; comando sob teste; inspeção; ROLLBACK; verificação.
-- Após cada teste, execute ROLLBACK MANUALMENTE NA MESMA CONEXÃO, mesmo após erro.
-- Se o cliente parar no erro esperado, isso NÃO significa rollback automático.
-- Nunca use COMMIT. Não inicie o próximo teste antes de encerrar o anterior.
-- Os dados serão desfeitos; números de AUTO_INCREMENT consumidos podem deixar lacunas.
-- Registre o código real do Action Output nos comentários, sem presumir aprovação.
USE retrogames;

-- PRÉ-VERIFICAÇÃO: execute separadamente antes de qualquer teste.
SELECT VERSION() AS versao, DATABASE() AS banco,
       @@SESSION.sql_mode AS modo_sql, @@SESSION.foreign_key_checks AS verificacoes_fk;
-- Exigido: MySQL 8, banco retrogames, FK = 1 e modo estrito
-- (STRICT_TRANS_TABLES ou STRICT_ALL_TABLES). Se diferente, pare e investigue.
-- Não altere configurações nem use INSERT IGNORE para contornar os resultados.

-- TESTE 1: plataforma inexistente. Esperado: erro 1452 (FK).
-- 1A. Preparação: confirme id_condicao = 2 e plataformas_com_id_invalido = 0.
SET @id_plataforma_inexistente = -1;
SELECT co_condicao_jogo AS id_condicao FROM tb_condicao_jogo WHERE co_condicao_jogo = 2;
SELECT COUNT(*) AS plataformas_com_id_invalido
FROM tb_plataforma WHERE co_seq_plataforma = @id_plataforma_inexistente;
SET @total_jogos_antes_1452 = (SELECT COUNT(*) FROM tb_jogo);
START TRANSACTION;

-- 1B. Execute SOMENTE este INSERT e confira o erro no Action Output.
INSERT INTO tb_jogo
    (no_jogo, ds_jogo, nu_ano_lancamento, vl_preco, qt_estoque,
     st_ativo, dt_cadastro, co_plataforma, co_condicao_jogo)
VALUES ('Teste integridade 1452', NULL, 1990, 10.00, 1,
        TRUE, UTC_TIMESTAMP(), @id_plataforma_inexistente, 2);
-- Código esperado: 1452. Código observado: 1452.
-- Resultado observado: erro 1452 no MySQL Workbench.

-- 1C. Execute ROLLBACK separadamente, mesmo depois da falha esperada.
ROLLBACK;
SELECT @total_jogos_antes_1452 AS quantidade_antes, COUNT(*) AS quantidade_depois
FROM tb_jogo;
-- Esperado: quantidades iguais (20 na carga original).
-- Verificação após ROLLBACK: teste encerrado na mesma conexão; dados originais preservados (6 plataformas e 20 jogos).

-- TESTE 2: nome de plataforma duplicado. Esperado: erro 1062 (UNIQUE).
-- 2A. Preparação: a plataforma deve existir exatamente uma vez.
SET @nome_plataforma_duplicada = 'Mega Drive';
SELECT co_seq_plataforma, no_plataforma FROM tb_plataforma
WHERE no_plataforma = @nome_plataforma_duplicada;
SET @total_plataformas_antes_1062 = (SELECT COUNT(*) FROM tb_plataforma);
START TRANSACTION;

-- 2B. Execute SOMENTE este INSERT.
INSERT INTO tb_plataforma (no_plataforma, no_fabricante, nu_ano_lancamento)
VALUES (@nome_plataforma_duplicada, 'Sega', 1988);
-- Código esperado: 1062. Código observado: 1062.
-- Resultado observado: erro 1062 no MySQL Workbench.

-- 2C. Execute manualmente na mesma conexão.
ROLLBACK;
SELECT @total_plataformas_antes_1062 AS quantidade_antes, COUNT(*) AS quantidade_depois
FROM tb_plataforma;
-- Esperado: quantidades iguais (6 na carga original).
-- Verificação após ROLLBACK: teste encerrado na mesma conexão; dados originais preservados (6 plataformas e 20 jogos).

-- TESTE 3: excluir plataforma com jogos. Esperado: erro 1451 (FK).
-- 3A. Preparação: nome UNIQUE localiza o ID, sem presumir sua numeração.
SET @id_plataforma_1451 = (
    SELECT co_seq_plataforma FROM tb_plataforma WHERE no_plataforma = 'Mega Drive'
);
SELECT @id_plataforma_1451 AS id_plataforma, COUNT(*) AS jogos_vinculados
FROM tb_jogo WHERE co_plataforma = @id_plataforma_1451;
-- Prossiga somente se ID não for NULL e houver jogos (esperado: 3).
START TRANSACTION;

-- 3B. Execute SOMENTE este DELETE, restrito à PK da plataforma conferida.
DELETE FROM tb_plataforma WHERE co_seq_plataforma = @id_plataforma_1451;
-- Código esperado: 1451. Código observado: 1451.
-- Resultado observado: erro 1451 no MySQL Workbench.

-- 3C. Execute manualmente na mesma conexão.
ROLLBACK;
SELECT co_seq_plataforma, no_plataforma FROM tb_plataforma
WHERE co_seq_plataforma = @id_plataforma_1451;
SELECT COUNT(*) AS jogos_vinculados FROM tb_jogo
WHERE co_plataforma = @id_plataforma_1451;
-- Esperado: Mega Drive preservado e seus 3 jogos mantidos.
-- Verificação após ROLLBACK: teste encerrado na mesma conexão; dados originais preservados (6 plataformas e 20 jogos).

-- TESTE 4: nome de jogo nulo. Esperado: erro 1048 (NOT NULL).
-- 4A. Preparação: confira a plataforma existente e a condição 2.
SET @id_plataforma_1048 = (
    SELECT co_seq_plataforma FROM tb_plataforma WHERE no_plataforma = 'Mega Drive'
);
SELECT @id_plataforma_1048 AS id_plataforma;
SELECT co_condicao_jogo FROM tb_condicao_jogo WHERE co_condicao_jogo = 2;
-- Não prossiga com ID NULL ou condição ausente.
SET @total_jogos_antes_1048 = (SELECT COUNT(*) FROM tb_jogo);
START TRANSACTION;

-- 4B. Execute SOMENTE este INSERT de uma linha; todos os demais campos são válidos.
INSERT INTO tb_jogo
    (no_jogo, ds_jogo, nu_ano_lancamento, vl_preco, qt_estoque,
     st_ativo, dt_cadastro, co_plataforma, co_condicao_jogo)
VALUES (NULL, 'Teste de obrigatoriedade do nome.', 1990, 10.00, 1,
        TRUE, UTC_TIMESTAMP(), @id_plataforma_1048, 2);
-- Código esperado: 1048. Código observado: 1048.
-- Resultado observado: erro 1048 no MySQL Workbench.

-- 4C. Execute manualmente na mesma conexão.
ROLLBACK;
SELECT @total_jogos_antes_1048 AS quantidade_antes, COUNT(*) AS quantidade_depois
FROM tb_jogo;
-- Esperado: quantidades iguais (20 na carga original).
-- Verificação após ROLLBACK: teste encerrado na mesma conexão; dados originais preservados (6 plataformas e 20 jogos).

-- TESTE 5: preço zero. Esperado: INSERT aceito, sem erro.
-- A regra de preço positivo pertence ao futuro Service; não há CHECK no banco.
-- 5A. Preparação: confira plataforma existente e condição 2.
SET @id_plataforma_preco_zero = (
    SELECT co_seq_plataforma FROM tb_plataforma WHERE no_plataforma = 'Mega Drive'
);
SELECT @id_plataforma_preco_zero AS id_plataforma;
SELECT co_condicao_jogo FROM tb_condicao_jogo WHERE co_condicao_jogo = 2;
-- Não prossiga com ID NULL ou condição ausente.
SET @total_jogos_antes_preco_zero = (SELECT COUNT(*) FROM tb_jogo);
SET @id_jogo_preco_zero = NULL;
START TRANSACTION;

-- 5B. Execute o INSERT; somente se tiver sucesso, capture a PK gerada.
INSERT INTO tb_jogo
    (no_jogo, ds_jogo, nu_ano_lancamento, vl_preco, qt_estoque,
     st_ativo, dt_cadastro, co_plataforma, co_condicao_jogo)
VALUES ('Teste integridade preco zero', 'Registro temporário para testar preço zero.',
        1990, 0.00, 1, TRUE, UTC_TIMESTAMP(), @id_plataforma_preco_zero, 2);
SET @id_jogo_preco_zero = LAST_INSERT_ID();

-- 5C. Inspecione antes do rollback, na mesma conexão.
SELECT co_seq_jogo, no_jogo, vl_preco FROM tb_jogo
WHERE co_seq_jogo = @id_jogo_preco_zero;
-- Esperado: uma linha com vl_preco = 0.00, sem inserir associações ou usuários.
-- Resultado observado: INSERT com preço zero aceito pelo banco.

-- 5D. Execute manualmente; não confirme o registro de teste.
ROLLBACK;
SELECT COUNT(*) AS registro_de_teste_restante FROM tb_jogo
WHERE co_seq_jogo = @id_jogo_preco_zero;
SELECT @total_jogos_antes_preco_zero AS quantidade_antes, COUNT(*) AS quantidade_depois
FROM tb_jogo;
-- Esperado: registro_de_teste_restante = 0 e quantidades iguais (20 originalmente).
-- Verificação após ROLLBACK: teste encerrado na mesma conexão; dados originais preservados (6 plataformas e 20 jogos).
