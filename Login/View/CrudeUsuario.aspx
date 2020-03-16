<%@ Page Language="C#" AutoEventWireup="true" CodeFile="~/Controller/CrudeUsuario.aspx.cs" Inherits="View_CrudeUsuario" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Usuarios</title>
    <style type="text/css">
        .auto-style1 {
            width: 100%;
        }
        .auto-style2 {
            width: 30%;
        }
        .auto-style3 {
            width: 40%;
        }
        .auto-style4 {
            height: 30px;
        }
        .auto-style5 {
            text-align: center;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <table class="auto-style1">
                <tr>
                    <td class="auto-style2">
                        <asp:ObjectDataSource ID="ODS_Usuario" runat="server" SelectMethod="obtenerUsuarios" TypeName="DAOUser" DataObjectTypeName="EUsuariocs" DeleteMethod="eliminarUsuario" UpdateMethod="actualizarUsuario"></asp:ObjectDataSource>
                    </td>
                    <td class="auto-style3">
                        <asp:ObjectDataSource ID="ODS_Rol" runat="server" SelectMethod="obtenerRoles" TypeName="DAOUser"></asp:ObjectDataSource>
                    </td>
                    <td class="auto-style2">
                        <asp:Image ID="IM_2" runat="server" Width="30%" ImageUrl="~/Archivos/Usuario/Img1.jpg" />
                    </td>
                </tr>
                <tr>
                    <td colspan ="3">
                        Bienvenido = <asp:Label ID="L_Nombre" runat="server"></asp:Label>
                        <br />
                        <br />
                        <div class="auto-style5">
                        <asp:GridView ID="GV_Usuario" runat="server" AutoGenerateColumns="False" CellPadding="4" DataKeyNames="Id" DataSourceID="ODS_Usuario" ForeColor="#333333" GridLines="None" HorizontalAlign="Center" Width="90%" AllowPaging="True" ShowFooter="True">
                            <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                            <Columns>
                                <asp:BoundField DataField="Nombre" HeaderText="Nombre" SortExpression="Nombre" />
                                <asp:BoundField DataField="Apellido" HeaderText="Apellido" SortExpression="Apellido" />
                                <asp:BoundField DataField="UserName" HeaderText="UserName" SortExpression="UserName" />
                                <asp:BoundField DataField="Clave" HeaderText="Clave" SortExpression="Clave" />
                                <asp:BoundField DataField="NombreRol" HeaderText="NombreRol" SortExpression="NombreRol" />
                                <asp:CommandField HeaderText="Editar" ShowEditButton="True" />
                                <asp:CommandField HeaderText="Eliminar" ShowDeleteButton="True" />
                            </Columns>
                            <EditRowStyle BackColor="#999999" />
                            <FooterStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
                            <HeaderStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
                            <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Center" />
                            <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                            <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                            <SortedAscendingCellStyle BackColor="#E9E7E2" />
                            <SortedAscendingHeaderStyle BackColor="#506C8C" />
                            <SortedDescendingCellStyle BackColor="#FFFDF8" />
                            <SortedDescendingHeaderStyle BackColor="#6F8DAE" />
                        </asp:GridView>
                        </div>
                    </td>
                </tr>
              
                <tr>
                    <td colspan ="3" class="auto-style4">
                        Nombre:
                        <asp:TextBox ID="TB_Nombre" runat="server"></asp:TextBox>
&nbsp; Apellido
                        <asp:TextBox ID="TB_Apellido" runat="server"></asp:TextBox>
&nbsp;UserName:
                        <asp:TextBox ID="TB_UserName" runat="server"></asp:TextBox>
&nbsp;Clave
                        <asp:TextBox ID="TB_Clave" runat="server" TextMode="Password"></asp:TextBox>
&nbsp;Rol:
                        <asp:DropDownList ID="DDL_Rol" runat="server" DataSourceID="ODS_Rol" DataTextField="Nombre" DataValueField="Id">
                        </asp:DropDownList>
&nbsp;&nbsp;&nbsp;&nbsp;
                        <asp:Button ID="B_Guardar" runat="server" OnClick="B_Guardar_Click" Text="Guardar" />
                    </td>
                </tr>
              
            </table>
        </div>
    </form>
</body>
</html>
