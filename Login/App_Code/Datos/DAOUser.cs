using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Web;
using Npgsql;
using NpgsqlTypes;

/// <summary>
/// Descripción breve de DAOUser
/// </summary>
public class DAOUser
{
   public EUsuariocs login2(EUsuariocs user)
    {
        using (var db = new Mapeo())
        {
            return db.usuario.Where(x => x.UserName.Equals(user.UserName) 
            && x.Clave.Equals(user.Clave)).FirstOrDefault();
        }
    }

    public List<URol> obtenerRoles()
    {
        using (var db = new Mapeo())
        {
            return db.rol.ToList();
        }
    }

    public List<EUsuariocs> obtenerUsuarios()
    {
        using (var db = new Mapeo())
        {
            return (from uu in db.usuario
                    join rol in db.rol on uu.RolId equals rol.Id

                    select new
                    {
                        uu,
                        rol
                    }).ToList().Select(m => new EUsuariocs
                    {
                        Id = m.uu.Id,
                        Apellido = m.uu.Apellido,
                        Clave = m.uu.Clave,
                        Nombre = m.uu.Nombre,
                        NombreRol = m.rol.Nombre,
                        RolId = m.uu.RolId,
                        UserName = m.uu.UserName
                    }).ToList();
        }

    }

    public void actualizarUsuario(EUsuariocs user)
    {
        using (var db = new Mapeo())
        {

            EUsuariocs user2 = db.usuario.Where(x => x.Id == user.Id).First();
            user2.Nombre = user.Nombre;
            user2.Apellido = user.Apellido;
            user2.Clave = user.Clave;
            user2.UserName = user.UserName;
            
            db.usuario.Attach(user2);

            var entry = db.Entry(user2);
            entry.State = EntityState.Modified;
            db.SaveChanges();
        }
    }

    public void eliminarUsuario(EUsuariocs user)
    {
        using (var db = new Mapeo())
        {
            db.usuario.Attach(user);

            var entry = db.Entry(user);
            entry.State = EntityState.Deleted;
            db.SaveChanges();
        }
    }

    public void insertarUsuario(EUsuariocs user)
    {
        using (var db = new Mapeo())
        {
            db.usuario.Add(user);
            db.SaveChanges();
        }
    }

}