<%@ Page Language="C#" AutoEventWireup="true" CodeFile="~/Controller/Archivos.aspx.cs" Inherits="View_Archivos" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Archivos</title>
    <style type="text/css">
        .auto-style1 {
            width: 100%;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <table class="auto-style1">
                <tr>
                    <td>
                        <asp:Label ID="Label_Nombre_usuario" runat="server" Visible="False"></asp:Label>
                        <br />
                        <br />
                        <asp:FileUpload ID="FU_Archivos" runat="server" />
                    </td>
                    <td>&nbsp;</td>
                </tr>
                <tr>
                    <td>
                        <asp:Button ID="B_Subir" runat="server" OnClick="B_Subir_Click" Text="Subir" />
                    </td>
                    <td>&nbsp;</td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>
