using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class View_PrimerFormulario : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void LN_Prueba_Authenticate(object sender, AuthenticateEventArgs e)
    {
        EUsuariocs eUser = new EUsuariocs();
        eUser.UserName = LN_Prueba.UserName.ToString();
        eUser.Clave = LN_Prueba.Password.ToString();

        eUser = new DAOUser().login2(eUser);

        if(eUser == null)
        {
            ((Label)LN_Prueba.FindControl("L_Mensaje")).Text = "Usuario o Clave Incorrecta";
        }
        else if(eUser.RolId == 1)
        {
            ((Label)LN_Prueba.FindControl("L_Mensaje")).Text = "Bienvenido " + eUser.Nombre;
            Session["userValido"] = eUser;
            Response.Redirect("CrudeUsuario.aspx");
        }
        else if (eUser.RolId == 2)
        {
            ((Label)LN_Prueba.FindControl("L_Mensaje")).Text = "Bienvenido " + eUser.Nombre;
            Session["Archivos"] = eUser;
            Response.Redirect("Archivos.aspx");
        }


    }
}