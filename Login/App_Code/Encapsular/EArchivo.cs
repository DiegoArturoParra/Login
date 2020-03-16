using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for EArchivo
/// </summary>
[Serializable]
[Table("archivo", Schema = "archive")]
public class EArchivo
{
    private int id;
    private string nombreArchivo;
    private string nombreExtension;

    public EArchivo(string nombreArchivo, string nombreExtension)
    {
        this.nombreArchivo = nombreArchivo;
        this.nombreExtension = nombreExtension;
    }

    [Key]
    [Column("id")]
    public int Id { get => id; set => id = value; }

    [Column("nombre_archivo")]
    public string NombreArchivo { get => nombreArchivo; set => nombreArchivo = value; }

    [Column("nombre_extension")]
    public string NombreExtension { get => nombreExtension; set => nombreExtension = value; }



}