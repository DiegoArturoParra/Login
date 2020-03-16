using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;


/// <summary>
/// Descripción breve de EUsuariocs
/// </summary>
/// 
[Serializable]
[Table("usuario", Schema = "usuario")]
public class EUsuariocs
{
    private string userName;
    private string clave;
    private string nombre;
    private int id;
    private string apellido;
    private Nullable<int> rolId;
    private string session;
    private Nullable<DateTime> lastModify;

    private string nombreRol;
    [Key]
    [Column("id")]
    public int Id { get => id; set => id = value; }
    [Column("user_name")]
    public string UserName { get => userName; set => userName = value; }
    [Column("clave")]
    public string Clave { get => clave; set => clave = value; }
    [Column("nombre")]
    public string Nombre { get => nombre; set => nombre = value; }
   
    [Column("apellido")]
    public string Apellido { get => apellido; set => apellido = value; }
    [Column("rol_id")]
    public Nullable<int> RolId { get => rolId; set => rolId = value; }
    [Column("session")]
    public string Session { get => session; set => session = value; }
    [Column("last_modify")]
    public Nullable<DateTime> LastModify { get => lastModify; set => lastModify = value; }

    [NotMapped]
    public string NombreRol { get => nombreRol; set => nombreRol = value; }
    
}