using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class View_CrudeUsuario : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if(Session["userValido"] != null && ((EUsuariocs)Session["userValido"]).RolId == 1)
            L_Nombre.Text = ((EUsuariocs)Session["userValido"]).Nombre;
        else
        {
            Response.Redirect("PrimerFormulario.aspx");
        }

        if(((EUsuariocs)Session["userValido"]).RolId == 3)
        {
            IM_2.ImageUrl = "";
        }


    }

    protected void B_Guardar_Click(object sender, EventArgs e)
    {
        EUsuariocs user = new EUsuariocs();
        user.Apellido = TB_Apellido.Text;
        user.Clave = TB_Clave.Text;
        user.Nombre = TB_Nombre.Text;
        user.RolId = int.Parse(DDL_Rol.SelectedValue);
        user.UserName = TB_UserName.Text;
        user.Session = ((EUsuariocs)Session["userValido"]).UserName;
        user.LastModify = DateTime.Now;

        new DAOUser().insertarUsuario(user);

        GV_Usuario.DataBind();
    }
}