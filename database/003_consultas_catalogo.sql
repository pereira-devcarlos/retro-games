-- Aula 1, Etapa 5: consultas acadêmicas com JOINs, fora da camada Repository.
-- Pré-requisito: scripts 001 e 002 executados e confirmados.
-- Resultados esperados consideram a carga original, sem outros registros.
-- Execute o cenário auxiliar ao final separadamente e sempre finalize com ROLLBACK.
USE retrogames;

-- 1. Catálogo: 19 jogos ativos, incluindo Super Metroid e excluindo Crash Bandicoot.
-- INNER JOIN encontra a plataforma e a condição referenciadas por cada jogo.
SELECT j.co_seq_jogo, j.no_jogo, p.no_plataforma, c.ds_condicao_jogo,
       j.nu_ano_lancamento, j.vl_preco, j.qt_estoque
FROM tb_jogo AS j
INNER JOIN tb_plataforma AS p ON p.co_seq_plataforma = j.co_plataforma
INNER JOIN tb_condicao_jogo AS c ON c.co_condicao_jogo = j.co_condicao_jogo
WHERE j.st_ativo = TRUE
ORDER BY j.no_jogo, j.co_seq_jogo;
-- Resultado observado: 19 jogos no catálogo ativo.

-- 2. Gêneros de um jogo informado por ID, sem presumir valores de AUTO_INCREMENT.
-- Primeiro consulte os IDs; copie o ID desejado para @id_jogo_informado.
-- O nome não é UNIQUE: não o utilizamos para obter um único jogo automaticamente.
SELECT j.co_seq_jogo, j.no_jogo, p.no_plataforma
FROM tb_jogo AS j
INNER JOIN tb_plataforma AS p ON p.co_seq_plataforma = j.co_plataforma
ORDER BY j.no_jogo, j.co_seq_jogo;

SET @id_jogo_informado = NULL; -- Substitua NULL pelo ID consultado de Super Metroid.
-- Não prossiga enquanto o ID não estiver preenchido e conferido.
SELECT g.co_seq_genero, g.no_genero
FROM tb_jogo_genero AS jg
INNER JOIN tb_genero AS g ON g.co_seq_genero = jg.co_genero
WHERE jg.co_jogo = @id_jogo_informado
ORDER BY g.no_genero, g.co_seq_genero;
-- Esperado para Super Metroid: Ação, Aventura e Plataforma.
-- Resultado observado: Super Metroid retornou 3 gêneros.

-- 3. Jogos de um gênero: o nome UNIQUE identifica o gênero informado.
SET @nome_genero_informado = 'Corrida';
SET @id_genero_informado = (
    SELECT co_seq_genero FROM tb_genero WHERE no_genero = @nome_genero_informado
);
-- Confira que o ID não é NULL antes de executar a consulta.
SELECT @id_genero_informado AS id_genero_informado;
SELECT j.co_seq_jogo, j.no_jogo, j.st_ativo
FROM tb_jogo_genero AS jg
INNER JOIN tb_jogo AS j ON j.co_seq_jogo = jg.co_jogo
WHERE jg.co_genero = @id_genero_informado
ORDER BY j.no_jogo, j.co_seq_jogo;
-- Sem filtro de situação: lista todos os jogos associados ao gênero.
-- Esperado para Corrida: Mario Kart 64 e Super Mario Kart.
-- Resultado observado: o gênero Corrida retornou 2 jogos.

-- 4. Contagem por plataforma, incluindo jogos inativos e plataformas sem jogos.
-- LEFT JOIN preserva a plataforma sem correspondência; COUNT da PK ignora NULL.
SELECT p.co_seq_plataforma, p.no_plataforma,
       COUNT(j.co_seq_jogo) AS quantidade_jogos
FROM tb_plataforma AS p
LEFT JOIN tb_jogo AS j ON j.co_plataforma = p.co_seq_plataforma
GROUP BY p.co_seq_plataforma, p.no_plataforma
ORDER BY p.no_plataforma, p.co_seq_plataforma;
-- Esperado: NES/Famicom 3; SNES/Super Famicom 4; Mega Drive 3;
-- Game Boy 3; Nintendo 64 4; PlayStation 3. Total: 20 jogos em 6 plataformas.
-- Resultado observado: 6 plataformas e 20 jogos no total.

-- 5. Busca paginada: sete jogos ativos contêm Mario, não seis.
-- A ordenação usa a PK para desempatar nomes iguais e manter páginas estáveis.
SET @parte_nome = 'Mario';
SELECT COUNT(*) AS total_resultados
FROM tb_jogo
WHERE st_ativo = TRUE AND no_jogo LIKE CONCAT('%', @parte_nome, '%');
-- Esperado: 7.

-- Página 1: OFFSET = (1 - 1) * 5 = 0.
SELECT co_seq_jogo, no_jogo, nu_ano_lancamento, vl_preco
FROM tb_jogo
WHERE st_ativo = TRUE AND no_jogo LIKE CONCAT('%', @parte_nome, '%')
ORDER BY no_jogo, co_seq_jogo
LIMIT 5 OFFSET 0;
-- Esperado: Mario Kart 64, Mario Tennis, Super Mario 64,
-- Super Mario Bros. e Super Mario Kart.
-- Resultado observado: busca por Mario com total de 7 jogos; página 1 com 5 jogos.

-- Página 2: OFFSET = (2 - 1) * 5 = 5.
SELECT co_seq_jogo, no_jogo, nu_ano_lancamento, vl_preco
FROM tb_jogo
WHERE st_ativo = TRUE AND no_jogo LIKE CONCAT('%', @parte_nome, '%')
ORDER BY no_jogo, co_seq_jogo
LIMIT 5 OFFSET 5;
-- Esperado: Super Mario Land e Super Mario World; sem IDs repetidos entre páginas.
-- Resultado observado: página 2 da busca por Mario com 2 jogos.

-- CENÁRIO AUXILIAR DA CONSULTA 4: execute isoladamente na mesma conexão.
-- Não é um sexto teste de integridade. Não execute em uma transação já aberta.
-- Confira primeiro que o nome abaixo está ausente; esperado: 0.
SELECT COUNT(*) AS plataformas_com_nome_de_teste
FROM tb_plataforma WHERE no_plataforma = 'Teste Aula 1 Etapa 5 - Sem Jogos';
-- Se existir, interrompa e investigue; não remova registros existentes.

START TRANSACTION;
INSERT INTO tb_plataforma (no_plataforma, no_fabricante, nu_ano_lancamento)
VALUES ('Teste Aula 1 Etapa 5 - Sem Jogos', 'Fabricante de teste', 1990);
SET @id_plataforma_auxiliar = LAST_INSERT_ID();

SELECT p.co_seq_plataforma, p.no_plataforma,
       COUNT(j.co_seq_jogo) AS quantidade_jogos
FROM tb_plataforma AS p
LEFT JOIN tb_jogo AS j ON j.co_plataforma = p.co_seq_plataforma
GROUP BY p.co_seq_plataforma, p.no_plataforma
ORDER BY p.no_plataforma, p.co_seq_plataforma;
-- Esperado: 7 plataformas; a plataforma de teste aparece com quantidade 0.
-- Resultado observado: o cenário temporário mostrou uma plataforma com zero jogos.

-- Execute manualmente mesmo se algum comando anterior falhar; nunca use COMMIT.
ROLLBACK;
SELECT COUNT(*) AS plataforma_auxiliar_restante
FROM tb_plataforma WHERE co_seq_plataforma = @id_plataforma_auxiliar;
-- Esperado: 0; a consulta 4 volta a retornar as 6 plataformas originais.
-- Resultado observado após ROLLBACK: voltaram a existir 6 plataformas.
