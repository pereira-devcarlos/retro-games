using MySqlConnector;
using RetroGames.Model.Model;

namespace RetroGames.Repository;

public class JogoRepository : RepositoryBase, IJogoRepository
{
    private const string Colunas = """
        co_seq_jogo, no_jogo, ds_jogo, nu_ano_lancamento,
        vl_preco, qt_estoque, st_ativo, dt_cadastro,
        co_plataforma, co_condicao_jogo
        """;

    public JogoRepository(RepositoryConfig configuracao)
        : base(configuracao)
    {
    }

    public async Task<(List<Jogo> Itens, int Total)> ListarAsync(
        int pagina,
        int tamanhoPagina,
        string? nome = null,
        int? idPlataforma = null,
        IReadOnlyCollection<int>? ids = null,
        bool incluirInativos = false)
    {
        ArgumentOutOfRangeException.ThrowIfLessThan(pagina, 1);
        ArgumentOutOfRangeException.ThrowIfLessThan(tamanhoPagina, 1);
        int offset = checked((pagina - 1) * tamanhoPagina);
        var identificadores = ids?.ToArray();

        var filtros = """
            WHERE (@incluirInativos = TRUE OR st_ativo = TRUE)
              AND (@nome IS NULL OR no_jogo LIKE CONCAT('%', @nome, '%'))
              AND (@idPlataforma IS NULL OR co_plataforma = @idPlataforma)
            """;

        if (identificadores is { Length: 0 })
        {
            filtros += " AND 1 = 0";
        }
        else if (identificadores is not null)
        {
            var parametros = Enumerable.Range(0, identificadores.Length)
                .Select(indice => $"@id{indice}");
            filtros += $" AND co_seq_jogo IN ({string.Join(", ", parametros)})";
        }

        // Somente nomes internos de parâmetros entram no SQL; os valores são vinculados.
        string sql = $"SELECT {Colunas} FROM tb_jogo {filtros} "
            + "ORDER BY no_jogo, co_seq_jogo LIMIT @limite OFFSET @offset;";
        string sqlContagem = $"SELECT COUNT(*) FROM tb_jogo {filtros};";

        await using var conexao = await CriarConexaoAsync();
        var itens = new List<Jogo>();

        await using (var comando = CriarComando(conexao, sql))
        {
            AdicionarFiltros(comando, nome, idPlataforma, identificadores, incluirInativos);
            AdicionarParametro(comando, "@limite", tamanhoPagina);
            AdicionarParametro(comando, "@offset", offset);
            await using var leitor = await comando.ExecuteReaderAsync();

            while (await leitor.ReadAsync())
            {
                itens.Add(MapearJogo(leitor));
            }
        }

        await using var comandoContagem = CriarComando(conexao, sqlContagem);
        AdicionarFiltros(comandoContagem, nome, idPlataforma, identificadores, incluirInativos);
        int total = checked((int)Convert.ToInt64(await comandoContagem.ExecuteScalarAsync()));
        return (itens, total);
    }

    public async Task<Jogo?> BuscarPorIdAsync(int id)
    {
        string sql = $"SELECT {Colunas} FROM tb_jogo WHERE co_seq_jogo = @id;";
        await using var conexao = await CriarConexaoAsync();
        await using var comando = CriarComando(conexao, sql);
        AdicionarParametro(comando, "@id", id);
        await using var leitor = await comando.ExecuteReaderAsync();

        return await leitor.ReadAsync() ? MapearJogo(leitor) : null;
    }

    public async Task<int> InserirAsync(Jogo jogo)
    {
        const string sql = """
            INSERT INTO tb_jogo
                (no_jogo, ds_jogo, nu_ano_lancamento, vl_preco,
                 qt_estoque, st_ativo, dt_cadastro, co_plataforma, co_condicao_jogo)
            VALUES
                (@nome, @descricao, @anoLancamento, @preco,
                 @estoque, @ativo, @dataCadastro, @idPlataforma, @idCondicaoJogo);
            """;

        await using var conexao = await CriarConexaoAsync();
        await using var comando = CriarComando(conexao, sql);
        AdicionarDadosJogo(comando, jogo);
        AdicionarParametro(comando, "@dataCadastro", jogo.DataCadastro);
        await ExecutarGravacaoAsync(comando);
        return checked((int)comando.LastInsertedId);
    }

    public async Task AlterarAsync(Jogo jogo)
    {
        const string sql = """
            UPDATE tb_jogo
            SET no_jogo = @nome,
                ds_jogo = @descricao,
                nu_ano_lancamento = @anoLancamento,
                vl_preco = @preco,
                qt_estoque = @estoque,
                st_ativo = @ativo,
                co_plataforma = @idPlataforma,
                co_condicao_jogo = @idCondicaoJogo
            WHERE co_seq_jogo = @id;
            """;

        await using var conexao = await CriarConexaoAsync();
        await using var comando = CriarComando(conexao, sql);
        AdicionarDadosJogo(comando, jogo);
        AdicionarParametro(comando, "@id", jogo.Id);
        await ExecutarGravacaoAsync(comando);
    }

    public async Task DesativarAsync(int id)
    {
        const string sql = """
            UPDATE tb_jogo SET st_ativo = FALSE WHERE co_seq_jogo = @id;
            """;

        await using var conexao = await CriarConexaoAsync();
        await using var comando = CriarComando(conexao, sql);
        AdicionarParametro(comando, "@id", id);
        await ExecutarGravacaoAsync(comando);
    }

    private void AdicionarFiltros(
        MySqlCommand comando,
        string? nome,
        int? idPlataforma,
        int[]? ids,
        bool incluirInativos)
    {
        AdicionarParametro(comando, "@incluirInativos", incluirInativos);
        AdicionarParametro(comando, "@nome", nome);
        AdicionarParametro(comando, "@idPlataforma", idPlataforma);

        if (ids is not null)
        {
            for (int indice = 0; indice < ids.Length; indice++)
            {
                AdicionarParametro(comando, $"@id{indice}", ids[indice]);
            }
        }
    }

    private void AdicionarDadosJogo(MySqlCommand comando, Jogo jogo)
    {
        AdicionarParametro(comando, "@nome", jogo.Nome);
        AdicionarParametro(comando, "@descricao", jogo.Descricao);
        AdicionarParametro(comando, "@anoLancamento", jogo.AnoLancamento);
        AdicionarParametro(comando, "@preco", jogo.Preco);
        AdicionarParametro(comando, "@estoque", jogo.Estoque);
        AdicionarParametro(comando, "@ativo", jogo.Ativo);
        AdicionarParametro(comando, "@idPlataforma", jogo.IdPlataforma);
        AdicionarParametro(comando, "@idCondicaoJogo", jogo.IdCondicaoJogo);
    }

    private static Jogo MapearJogo(MySqlDataReader leitor)
    {
        return new Jogo
        {
            Id = leitor.GetInt32("co_seq_jogo"),
            Nome = leitor.GetString("no_jogo"),
            Descricao = leitor.IsDBNull(leitor.GetOrdinal("ds_jogo"))
                ? null : leitor.GetString("ds_jogo"),
            AnoLancamento = leitor.GetInt32("nu_ano_lancamento"),
            Preco = leitor.GetDecimal("vl_preco"),
            Estoque = leitor.GetInt32("qt_estoque"),
            Ativo = leitor.GetBoolean("st_ativo"),
            DataCadastro = leitor.GetDateTime("dt_cadastro"),
            IdPlataforma = leitor.GetInt32("co_plataforma"),
            IdCondicaoJogo = leitor.GetInt32("co_condicao_jogo"),
        };
    }
}
