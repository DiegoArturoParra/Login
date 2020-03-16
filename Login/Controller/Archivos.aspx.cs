using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class View_Archivos : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["userValido"] != null && ((EUsuariocs)Session["userValido"]).RolId == 1)
        {
            Label_Nombre_usuario.Text = "Hola "+((EUsuariocs)Session["userValido"]).Nombre +"eres "
                + ((EUsuariocs)Session["userValido"]).RolId;
        }
        else
        {
            Response.Redirect("PrimerFormulario.aspx");
        }
    }

    public void validarArchivo(string saveArchivo, ClientScriptManager cm, EArchivo archivos)
    {
        if (System.IO.File.Exists(saveArchivo))
        {
            cm.RegisterClientScriptBlock(this.GetType(), "", "<script type='text/javascript'>alert('Ya existe un archivo en el servidor con ese nombre');</script>");
            return;
        }
        try
        {
            FU_Archivos.PostedFile.SaveAs(saveArchivo);
            new DaoArchivo().guardarArchivo(archivos);
            cm.RegisterClientScriptBlock(this.GetType(), "", "<script type='text/javascript'>alert('El archivo ha sido cargado');</script>");
        }
        catch (Exception exc)
        {
            cm.RegisterClientScriptBlock(this.GetType(), "", "<script type='text/javascript'>alert('Error: ');</script>");
            return;
        }
    }

    protected void B_Subir_Click(object sender, EventArgs e)
    {
        DaoArchivo cantidades = new DaoArchivo();

        ClientScriptManager cm = this.ClientScript;
        string nombreArchivo = System.IO.Path.GetFileNameWithoutExtension(FU_Archivos.PostedFile.FileName);
        string extension = System.IO.Path.GetExtension(FU_Archivos.PostedFile.FileName);
        string saveLocation;

        int cantidadWord = cantidades.validarWord();
        int cantidadPdf = cantidades.validarPdf();
        int cantidadImg = cantidades.validarImg();
        int cantidad = cantidades.validarCantidades();
        if (cantidadWord >= 3 || cantidadImg >= 2 || cantidadPdf >= 1)
        {
            if (cantidad >= 6)
            {
                cm.RegisterClientScriptBlock(this.GetType(), "", "<script type='text/javascript'>alert('Ya existe más de tres archivos word.');</script>");
                return;
            }

        }
        // constructor con los parametros
        EArchivo archivos = new EArchivo(nombreArchivo, extension);

        if (extension.Equals(".jpg") || extension.Equals(".jpge") || extension.Equals(".png"))
        {
            saveLocation = Server.MapPath("~\\Archivos\\Imagenes\\")
                + nombreArchivo + extension;
            validarArchivo(saveLocation, cm, archivos);
        }
        else if (extension.Equals(".pdf"))
        {
            saveLocation = Server.MapPath("~\\Archivos\\Pdf\\")
               + nombreArchivo + extension;
            validarArchivo(saveLocation, cm, archivos);
        }
        else if (extension.Equals(".docx"))
        {
            saveLocation = Server.MapPath("~\\Archivos\\Word\\")
              + nombreArchivo.Trim(new Char[] { '.' }) + extension;
            validarArchivo(saveLocation, cm, archivos);
        }
        else
        {
            cm.RegisterClientScriptBlock(this.GetType(), "", "<script type='text/javascript'>alert('Tipo de archivo no valido');</script>");
            return;
        }
    }
}