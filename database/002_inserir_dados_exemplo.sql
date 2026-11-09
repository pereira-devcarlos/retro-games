-- Aula 1, Etapa 4: dados fictícios de catálogo para jogos e plataformas reais.
-- Execute uma única vez, após 001_criar_tabelas.sql, nas sete tabelas vazias.
-- Use a mesma conexão para todo o script: os IDs capturados são variáveis de sessão.
-- Configure o cliente para interromper em erro. Se houver erro, não execute COMMIT;
-- execute ROLLBACK na mesma conexão e investigue antes de tentar novamente.
-- Preços, estoques, condições e descrições são exemplos, não cotações comerciais.
USE retrogames;

START TRANSACTION;
SET @data_cadastro = UTC_TIMESTAMP();

-- 1. Domínios: somente condições e perfis recebem IDs fixos.
INSERT INTO tb_condicao_jogo (co_condicao_jogo, ds_condicao_jogo) VALUES
    (1, 'Novo'), (2, 'Usado'), (3, 'Recondicionado');
INSERT INTO tb_perfil (co_perfil, ds_perfil) VALUES
    (1, 'Administrador'), (2, 'Cliente');

-- 2. Plataformas: o banco gera as chaves; as referências usam nomes UNIQUE.
INSERT INTO tb_plataforma (no_plataforma, no_fabricante, nu_ano_lancamento) VALUES
    ('Nintendo Entertainment System / Famicom', 'Nintendo', 1983),
    ('Super Nintendo / Super Famicom', 'Nintendo', 1990),
    ('Mega Drive', 'Sega', 1988),
    ('Game Boy', 'Nintendo', 1989),
    ('Nintendo 64', 'Nintendo', 1996),
    ('PlayStation', 'Sony', 1994);

SET @plataforma_nes = (SELECT co_seq_plataforma FROM tb_plataforma WHERE no_plataforma = 'Nintendo Entertainment System / Famicom');
SET @plataforma_snes = (SELECT co_seq_plataforma FROM tb_plataforma WHERE no_plataforma = 'Super Nintendo / Super Famicom');
SET @plataforma_mega_drive = (SELECT co_seq_plataforma FROM tb_plataforma WHERE no_plataforma = 'Mega Drive');
SET @plataforma_game_boy = (SELECT co_seq_plataforma FROM tb_plataforma WHERE no_plataforma = 'Game Boy');
SET @plataforma_nintendo_64 = (SELECT co_seq_plataforma FROM tb_plataforma WHERE no_plataforma = 'Nintendo 64');
SET @plataforma_playstation = (SELECT co_seq_plataforma FROM tb_plataforma WHERE no_plataforma = 'PlayStation');

-- 3. Gêneros: referências localizadas pelo nome UNIQUE.
INSERT INTO tb_genero (no_genero) VALUES
    ('Ação'), ('Aventura'), ('Plataforma'), ('RPG'), ('Corrida'), ('Luta'), ('Quebra-cabeça'), ('Esportes');

SET @genero_acao = (SELECT co_seq_genero FROM tb_genero WHERE no_genero = 'Ação');
SET @genero_aventura = (SELECT co_seq_genero FROM tb_genero WHERE no_genero = 'Aventura');
SET @genero_plataforma = (SELECT co_seq_genero FROM tb_genero WHERE no_genero = 'Plataforma');
SET @genero_rpg = (SELECT co_seq_genero FROM tb_genero WHERE no_genero = 'RPG');
SET @genero_corrida = (SELECT co_seq_genero FROM tb_genero WHERE no_genero = 'Corrida');
SET @genero_luta = (SELECT co_seq_genero FROM tb_genero WHERE no_genero = 'Luta');
SET @genero_quebra_cabeca = (SELECT co_seq_genero FROM tb_genero WHERE no_genero = 'Quebra-cabeça');
SET @genero_esportes = (SELECT co_seq_genero FROM tb_genero WHERE no_genero = 'Esportes');

-- 4. Cada jogo é inserido individualmente e associado imediatamente aos gêneros.
-- LAST_INSERT_ID() captura a chave real; não há busca por nome de jogo nem cálculo de IDs.
-- A reutilização de @id_jogo é segura porque cada conjunto de vínculos vem logo depois.

-- Super Mario Bros..
INSERT INTO tb_jogo
    (no_jogo, ds_jogo, nu_ano_lancamento, vl_preco, qt_estoque, st_ativo, dt_cadastro, co_plataforma, co_condicao_jogo)
VALUES
    ('Super Mario Bros.', 'Percorra o Reino dos Cogumelos e enfrente os desafios de Bowser.', 1985, 119.90, 5, TRUE, @data_cadastro, @plataforma_nes, 2);
SET @id_jogo = LAST_INSERT_ID();
INSERT INTO tb_jogo_genero (co_jogo, co_genero) VALUES
    (@id_jogo, @genero_plataforma), (@id_jogo, @genero_acao);

-- The Legend of Zelda.
INSERT INTO tb_jogo
    (no_jogo, ds_jogo, nu_ano_lancamento, vl_preco, qt_estoque, st_ativo, dt_cadastro, co_plataforma, co_condicao_jogo)
VALUES
    ('The Legend of Zelda', 'Explore Hyrule em busca dos fragmentos da Triforce.', 1986, 189.90, 3, TRUE, @data_cadastro, @plataforma_nes, 2);
SET @id_jogo = LAST_INSERT_ID();
INSERT INTO tb_jogo_genero (co_jogo, co_genero) VALUES
    (@id_jogo, @genero_aventura), (@id_jogo, @genero_acao);

-- Castlevania.
INSERT INTO tb_jogo
    (no_jogo, ds_jogo, nu_ano_lancamento, vl_preco, qt_estoque, st_ativo, dt_cadastro, co_plataforma, co_condicao_jogo)
VALUES
    ('Castlevania', 'Atravesse o castelo de Drácula com o chicote de Simon Belmont.', 1986, 159.90, 2, TRUE, @data_cadastro, @plataforma_nes, 3);
SET @id_jogo = LAST_INSERT_ID();
INSERT INTO tb_jogo_genero (co_jogo, co_genero) VALUES
    (@id_jogo, @genero_acao), (@id_jogo, @genero_plataforma);

-- Super Mario World.
INSERT INTO tb_jogo
    (no_jogo, ds_jogo, nu_ano_lancamento, vl_preco, qt_estoque, st_ativo, dt_cadastro, co_plataforma, co_condicao_jogo)
VALUES
    ('Super Mario World', 'Explore a Terra dos Dinossauros com Mario e Yoshi.', 1990, 149.90, 6, TRUE, @data_cadastro, @plataforma_snes, 2);
SET @id_jogo = LAST_INSERT_ID();
INSERT INTO tb_jogo_genero (co_jogo, co_genero) VALUES
    (@id_jogo, @genero_plataforma), (@id_jogo, @genero_aventura);

-- Super Mario Kart.
INSERT INTO tb_jogo
    (no_jogo, ds_jogo, nu_ano_lancamento, vl_preco, qt_estoque, st_ativo, dt_cadastro, co_plataforma, co_condicao_jogo)
VALUES
    ('Super Mario Kart', 'Dispute corridas de kart com personagens do Reino dos Cogumelos.', 1992, 139.90, 4, TRUE, @data_cadastro, @plataforma_snes, 2);
SET @id_jogo = LAST_INSERT_ID();
INSERT INTO tb_jogo_genero (co_jogo, co_genero) VALUES
    (@id_jogo, @genero_corrida);

-- Super Metroid — ativo e sem estoque.
INSERT INTO tb_jogo
    (no_jogo, ds_jogo, nu_ano_lancamento, vl_preco, qt_estoque, st_ativo, dt_cadastro, co_plataforma, co_condicao_jogo)
VALUES
    ('Super Metroid', 'Investigue os caminhos de Zebes e amplie o arsenal de Samus.', 1994, 249.90, 0, TRUE, @data_cadastro, @plataforma_snes, 2);
SET @id_jogo = LAST_INSERT_ID();
INSERT INTO tb_jogo_genero (co_jogo, co_genero) VALUES
    (@id_jogo, @genero_acao), (@id_jogo, @genero_aventura), (@id_jogo, @genero_plataforma);

-- Donkey Kong Country.
INSERT INTO tb_jogo
    (no_jogo, ds_jogo, nu_ano_lancamento, vl_preco, qt_estoque, st_ativo, dt_cadastro, co_plataforma, co_condicao_jogo)
VALUES
    ('Donkey Kong Country', 'Ajude Donkey Kong e Diddy a recuperar seu estoque de bananas.', 1994, 179.90, 3, TRUE, @data_cadastro, @plataforma_snes, 3);
SET @id_jogo = LAST_INSERT_ID();
INSERT INTO tb_jogo_genero (co_jogo, co_genero) VALUES
    (@id_jogo, @genero_plataforma), (@id_jogo, @genero_aventura);

-- Sonic the Hedgehog.
INSERT INTO tb_jogo
    (no_jogo, ds_jogo, nu_ano_lancamento, vl_preco, qt_estoque, st_ativo, dt_cadastro, co_plataforma, co_condicao_jogo)
VALUES
    ('Sonic the Hedgehog', 'Corra por zonas cheias de obstáculos para enfrentar o Dr. Robotnik.', 1991, 99.90, 7, TRUE, @data_cadastro, @plataforma_mega_drive, 2);
SET @id_jogo = LAST_INSERT_ID();
INSERT INTO tb_jogo_genero (co_jogo, co_genero) VALUES
    (@id_jogo, @genero_plataforma), (@id_jogo, @genero_acao);

-- Sonic the Hedgehog 2.
INSERT INTO tb_jogo
    (no_jogo, ds_jogo, nu_ano_lancamento, vl_preco, qt_estoque, st_ativo, dt_cadastro, co_plataforma, co_condicao_jogo)
VALUES
    ('Sonic the Hedgehog 2', 'Acompanhe Sonic e Tails em uma aventura contra o Dr. Robotnik.', 1992, 119.90, 5, TRUE, @data_cadastro, @plataforma_mega_drive, 2);
SET @id_jogo = LAST_INSERT_ID();
INSERT INTO tb_jogo_genero (co_jogo, co_genero) VALUES
    (@id_jogo, @genero_plataforma), (@id_jogo, @genero_acao);

-- Streets of Rage 2.
INSERT INTO tb_jogo
    (no_jogo, ds_jogo, nu_ano_lancamento, vl_preco, qt_estoque, st_ativo, dt_cadastro, co_plataforma, co_condicao_jogo)
VALUES
    ('Streets of Rage 2', 'Enfrente gangues pelas ruas em combates cooperativos.', 1992, 169.90, 2, TRUE, @data_cadastro, @plataforma_mega_drive, 3);
SET @id_jogo = LAST_INSERT_ID();
INSERT INTO tb_jogo_genero (co_jogo, co_genero) VALUES
    (@id_jogo, @genero_acao), (@id_jogo, @genero_luta);

-- Tetris.
INSERT INTO tb_jogo
    (no_jogo, ds_jogo, nu_ano_lancamento, vl_preco, qt_estoque, st_ativo, dt_cadastro, co_plataforma, co_condicao_jogo)
VALUES
    ('Tetris', 'Encaixe peças e complete linhas antes que a pilha alcance o topo.', 1989, 89.90, 8, TRUE, @data_cadastro, @plataforma_game_boy, 2);
SET @id_jogo = LAST_INSERT_ID();
INSERT INTO tb_jogo_genero (co_jogo, co_genero) VALUES
    (@id_jogo, @genero_quebra_cabeca);

-- Super Mario Land.
INSERT INTO tb_jogo
    (no_jogo, ds_jogo, nu_ano_lancamento, vl_preco, qt_estoque, st_ativo, dt_cadastro, co_plataforma, co_condicao_jogo)
VALUES
    ('Super Mario Land', 'Atravesse os reinos de Sarasaland para resgatar a princesa Daisy.', 1989, 109.90, 4, TRUE, @data_cadastro, @plataforma_game_boy, 2);
SET @id_jogo = LAST_INSERT_ID();
INSERT INTO tb_jogo_genero (co_jogo, co_genero) VALUES
    (@id_jogo, @genero_plataforma), (@id_jogo, @genero_acao);

-- The Legend of Zelda: Link's Awakening.
INSERT INTO tb_jogo
    (no_jogo, ds_jogo, nu_ano_lancamento, vl_preco, qt_estoque, st_ativo, dt_cadastro, co_plataforma, co_condicao_jogo)
VALUES
    ('The Legend of Zelda: Link''s Awakening', 'Explore a ilha de Koholint e descubra o mistério do Peixe do Vento.', 1993, 199.90, 2, TRUE, @data_cadastro, @plataforma_game_boy, 2);
SET @id_jogo = LAST_INSERT_ID();
INSERT INTO tb_jogo_genero (co_jogo, co_genero) VALUES
    (@id_jogo, @genero_aventura), (@id_jogo, @genero_acao);

-- Super Mario 64.
INSERT INTO tb_jogo
    (no_jogo, ds_jogo, nu_ano_lancamento, vl_preco, qt_estoque, st_ativo, dt_cadastro, co_plataforma, co_condicao_jogo)
VALUES
    ('Super Mario 64', 'Entre nos mundos dos quadros do castelo e reúna estrelas.', 1996, 179.90, 5, TRUE, @data_cadastro, @plataforma_nintendo_64, 2);
SET @id_jogo = LAST_INSERT_ID();
INSERT INTO tb_jogo_genero (co_jogo, co_genero) VALUES
    (@id_jogo, @genero_plataforma), (@id_jogo, @genero_aventura);

-- Mario Kart 64.
INSERT INTO tb_jogo
    (no_jogo, ds_jogo, nu_ano_lancamento, vl_preco, qt_estoque, st_ativo, dt_cadastro, co_plataforma, co_condicao_jogo)
VALUES
    ('Mario Kart 64', 'Dispute corridas e batalhas de kart em pistas tridimensionais.', 1996, 189.90, 3, TRUE, @data_cadastro, @plataforma_nintendo_64, 2);
SET @id_jogo = LAST_INSERT_ID();
INSERT INTO tb_jogo_genero (co_jogo, co_genero) VALUES
    (@id_jogo, @genero_corrida);

-- The Legend of Zelda: Ocarina of Time.
INSERT INTO tb_jogo
    (no_jogo, ds_jogo, nu_ano_lancamento, vl_preco, qt_estoque, st_ativo, dt_cadastro, co_plataforma, co_condicao_jogo)
VALUES
    ('The Legend of Zelda: Ocarina of Time', 'Viaje entre duas épocas de Hyrule para enfrentar Ganondorf.', 1998, 279.90, 2, TRUE, @data_cadastro, @plataforma_nintendo_64, 2);
SET @id_jogo = LAST_INSERT_ID();
INSERT INTO tb_jogo_genero (co_jogo, co_genero) VALUES
    (@id_jogo, @genero_aventura), (@id_jogo, @genero_acao);

-- Mario Tennis.
INSERT INTO tb_jogo
    (no_jogo, ds_jogo, nu_ano_lancamento, vl_preco, qt_estoque, st_ativo, dt_cadastro, co_plataforma, co_condicao_jogo)
VALUES
    ('Mario Tennis', 'Participe de partidas de tênis com personagens do universo Mario.', 2000, 159.90, 3, TRUE, @data_cadastro, @plataforma_nintendo_64, 3);
SET @id_jogo = LAST_INSERT_ID();
INSERT INTO tb_jogo_genero (co_jogo, co_genero) VALUES
    (@id_jogo, @genero_esportes);

-- Final Fantasy VII.
INSERT INTO tb_jogo
    (no_jogo, ds_jogo, nu_ano_lancamento, vl_preco, qt_estoque, st_ativo, dt_cadastro, co_plataforma, co_condicao_jogo)
VALUES
    ('Final Fantasy VII', 'Acompanhe Cloud e seus aliados em uma jornada pela defesa do planeta.', 1997, 229.90, 2, TRUE, @data_cadastro, @plataforma_playstation, 2);
SET @id_jogo = LAST_INSERT_ID();
INSERT INTO tb_jogo_genero (co_jogo, co_genero) VALUES
    (@id_jogo, @genero_rpg), (@id_jogo, @genero_aventura);

-- Tekken 3 — condição Novo.
INSERT INTO tb_jogo
    (no_jogo, ds_jogo, nu_ano_lancamento, vl_preco, qt_estoque, st_ativo, dt_cadastro, co_plataforma, co_condicao_jogo)
VALUES
    ('Tekken 3', 'Escolha seu lutador e dispute confrontos no torneio Punho de Ferro.', 1998, 299.90, 1, TRUE, @data_cadastro, @plataforma_playstation, 1);
SET @id_jogo = LAST_INSERT_ID();
INSERT INTO tb_jogo_genero (co_jogo, co_genero) VALUES
    (@id_jogo, @genero_luta);

-- Crash Bandicoot — inativo.
INSERT INTO tb_jogo
    (no_jogo, ds_jogo, nu_ano_lancamento, vl_preco, qt_estoque, st_ativo, dt_cadastro, co_plataforma, co_condicao_jogo)
VALUES
    ('Crash Bandicoot', 'Atravesse as ilhas de Crash e enfrente os planos do Dr. Neo Cortex.', 1996, 129.90, 2, FALSE, @data_cadastro, @plataforma_playstation, 2);
SET @id_jogo = LAST_INSERT_ID();
INSERT INTO tb_jogo_genero (co_jogo, co_genero) VALUES
    (@id_jogo, @genero_plataforma), (@id_jogo, @genero_acao);

-- 5. Confirme todas as inserções em conjunto. Nenhum usuário é inserido.
COMMIT;

-- Verificação manual após a execução (consultas comentadas, não fazem parte da carga):
-- SELECT COUNT(*) FROM tb_condicao_jogo; -- Esperado: 3.
-- SELECT COUNT(*) FROM tb_perfil; -- Esperado: 2.
-- SELECT COUNT(*) FROM tb_plataforma; -- Esperado: 6.
-- SELECT COUNT(*) FROM tb_genero; -- Esperado: 8.
-- SELECT COUNT(*) FROM tb_jogo; -- Esperado: 20.
-- SELECT COUNT(*) FROM tb_jogo_genero; -- Esperado: 36.
-- SELECT COUNT(*) FROM tb_usuario; -- Esperado: 0.
-- A consulta abaixo deve retornar zero linhas (todos os jogos têm de 1 a 3 gêneros):
-- SELECT j.co_seq_jogo, COUNT(jg.co_genero) AS quantidade_generos
-- FROM tb_jogo AS j LEFT JOIN tb_jogo_genero AS jg ON jg.co_jogo = j.co_seq_jogo
-- GROUP BY j.co_seq_jogo HAVING COUNT(jg.co_genero) NOT BETWEEN 1 AND 3;
-- SELECT no_jogo, qt_estoque, st_ativo, co_condicao_jogo FROM tb_jogo
-- WHERE no_jogo IN ('Super Metroid', 'Crash Bandicoot', 'Tekken 3');
-- Esperado: Super Metroid com estoque 0; Crash Bandicoot inativo; Tekken 3 com condição 1.
