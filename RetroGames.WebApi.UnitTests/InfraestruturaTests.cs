using Xunit;

namespace RetroGames.WebApi.UnitTests;

public class InfraestruturaTests
{
    [Fact]
    public void Executor_DeveExecutarTesteDeInfraestrutura()
    {
        Assert.Equal(2, 1 + 1);
    }
}
