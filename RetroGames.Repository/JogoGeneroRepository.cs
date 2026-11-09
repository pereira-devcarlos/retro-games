using MySqlConnector;
using RetroGames.Model.Model;

namespace RetroGames.Repository;

public class JogoGeneroRepository : RepositoryBase, IJogoGeneroRepository
{
    public JogoGeneroRepository(RepositoryConfig configuracao)
        : base(configuracao)
    {
    }

    public async Task<List<JogoGenero>> ListarAsync()
    {
        const string sql = """
            SELECT co_jogo, co_genero FROM tb_jogo_genero ORDER BY co_jogo, co_genero;
            """;

        await using var conexao = await CriarConexaoAsync();
        await using var comando = CriarComando(conexao, sql);
        await using var leitor = await comando.ExecuteReaderAsync();
        var vinculos = new List<JogoGenero>();

        while (await leitor.ReadAsync())
        {
            vinculos.Add(MapearVinculo(leitor));
        }

        return vinculos;
    }

    public async Task<List<JogoGenero>> ListarPorJogosAsync(IReadOnlyCollection<int> idsJogos)
    {
        var ids = idsJogos.ToArray();
        if (ids.Length == 0)
        {
            return new List<JogoGenero>();
        }

        var parametros = Enumerable.Range(0, ids.Length).Select(indice => $"@idJogo{indice}");
        string sql = "SELECT co_jogo, co_genero FROM tb_jogo_genero "
            + $"WHERE co_jogo IN ({string.Join(", ", parametros)}) ORDER BY co_jogo, co_genero;";

        await using var conexao = await CriarConexaoAsync();
        await using var comando = CriarComando(conexao, sql);
        for (int indice = 0; indice < ids.Length; indice++)
        {
            AdicionarParametro(comando, $"@idJogo{indice}", ids[indice]);
        }

        await using var leitor = await comando.ExecuteReaderAsync();
        var vinculos = new List<JogoGenero>();
        while (await leitor.ReadAsync())
        {
            vinculos.Add(MapearVinculo(leitor));
        }

        return vinculos;
    }

    public async Task InserirAsync(int idJogo, IReadOnlyCollection<int> idsGeneros)
    {
        var ids = idsGeneros.ToArray();
        if (ids.Length == 0)
        {
            return;
        }

        var valores = Enumerable.Range(0, ids.Length)
            .Select(indice => $"(@idJogo, @idGenero{indice})");
        string sql = "INSERT INTO tb_jogo_genero (co_jogo, co_genero) VALUES "
            + string.Join(", ", valores) + ";";

        await using var conexao = await CriarConexaoAsync();
        await using var comando = CriarComando(conexao, sql);
        AdicionarParametro(comando, "@idJogo", idJogo);
        for (int indice = 0; indice < ids.Length; indice++)
        {
            AdicionarParametro(comando, $"@idGenero{indice}", ids[indice]);
        }

        await ExecutarGravacaoAsync(comando);
    }

    public async Task RemoverPorJogoAsync(int idJogo)
    {
        const string sql = "DELETE FROM tb_jogo_genero WHERE co_jogo = @idJogo;";
        await using var conexao = await CriarConexaoAsync();
        await using var comando = CriarComando(conexao, sql);
        AdicionarParametro(comando, "@idJogo", idJogo);
        await comando.ExecuteNonQueryAsync();
    }

    private static JogoGenero MapearVinculo(MySqlDataReader leitor)
    {
        return new JogoGenero
        {
            IdJogo = leitor.GetInt32("co_jogo"),
            IdGenero = leitor.GetInt32("co_genero"),
        };
    }
}
