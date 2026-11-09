using RetroGames.Model.Model;

namespace RetroGames.Repository;

public interface IJogoRepository
{
    Task<(List<Jogo> Itens, int Total)> ListarAsync(
        int pagina,
        int tamanhoPagina,
        string? nome = null,
        int? idPlataforma = null,
        IReadOnlyCollection<int>? ids = null,
        bool incluirInativos = false);

    Task<Jogo?> BuscarPorIdAsync(int id);

    Task<int> InserirAsync(Jogo jogo);

    Task AlterarAsync(Jogo jogo);

    Task DesativarAsync(int id);
}
