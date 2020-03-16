using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for DaoArchivo
/// </summary>
public class DaoArchivo
{
    public void guardarArchivo(EArchivo archivos)
    {
        using (var db = new Mapeo())
        {
            db.archivo.Add(archivos);
            db.SaveChanges();
        }
    }

    public int validarWord()
    {
        int cantidadWord;
        using (var db = new Mapeo())
        {
            cantidadWord = db.archivo.Count(x => x.NombreExtension == ".docx");
        }
        return cantidadWord;
    }

    public int validarPdf()
    {
        int cantidadPdf;
        using (var db = new Mapeo())
        {
            cantidadPdf = db.archivo.Count(x => x.NombreExtension == ".pdf");
        }
        return cantidadPdf;
    }

    public int validarImg()
    {
        int cantidadWord;
        using (var db = new Mapeo())
        {
            cantidadWord = db.archivo.Count(x => x.NombreExtension == ".png" || x.NombreExtension == ".jpg" 
            || x.NombreExtension == ".jpge");
        }
        return cantidadWord;
    }

    public int validarCantidades()
    {
        int cantidad;
        using (var db = new Mapeo())
        {
            cantidad = (from ar in db.archivo select ar.Id).Count();
        }
        return cantidad;
    }
}
