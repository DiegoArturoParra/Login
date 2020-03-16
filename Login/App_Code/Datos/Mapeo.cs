using System.Data.Entity;
/// <summary>
/// Descripción breve de Mapeo
/// </summary>
public class Mapeo : DbContext
{
    static Mapeo()
    {
        Database.SetInitializer<Mapeo>(null);
    }
    private readonly string schema;

    public Mapeo()
           : base("name=Conexion")
    {

    }

    public DbSet<EUsuariocs> usuario { get; set; }
    public DbSet<URol> rol { get; set; }
    public DbSet<EArchivo> archivo { get; set; }

    protected override void OnModelCreating(DbModelBuilder builder)
    {
        builder.HasDefaultSchema(this.schema);

        base.OnModelCreating(builder);
    }
}