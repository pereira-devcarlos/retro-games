using MySqlConnector;

namespace RetroGames.Repository;

public abstract class RepositoryBase
{
    private readonly RepositoryConfig _configuracao;

    protected RepositoryBase(RepositoryConfig configuracao)
    {
        _configuracao = configuracao;
    }

    // Quem recebe a conexão aberta deve descartá-la com await using.
    protected async Task<MySqlConnection> CriarConexaoAsync()
    {
        var conexao = new MySqlConnection(_configuracao.ConnectionString);

        try
        {
            await conexao.OpenAsync();
            return conexao;
        }
        catch
        {
            await conexao.DisposeAsync();
            throw;
        }
    }

    protected MySqlCommand CriarComando(MySqlConnection conexao, string sql)
    {
        return new MySqlCommand(sql, conexao);
    }

    protected void AdicionarParametro(MySqlCommand comando, string nome, object? valor)
    {
        comando.Parameters.AddWithValue(nome, valor ?? DBNull.Value);
    }

    // O chamador mantém a posse do comando, inclusive para consultar LastInsertedId.
    protected async Task<int> ExecutarGravacaoAsync(MySqlCommand comando)
    {
        try
        {
            return await comando.ExecuteNonQueryAsync();
        }
        catch (MySqlException excecao) when (excecao.Number == 1062)
        {
            throw new RegistroDuplicadoException(
                "Já existe um registro com os mesmos dados únicos.",
                excecao);
        }
    }
}
