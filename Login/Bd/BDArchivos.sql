PGDMP     4                     x            bdSubirArchivos    12.2    12.2 ;    A           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            B           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            C           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            D           1262    115347    bdSubirArchivos    DATABASE     �   CREATE DATABASE "bdSubirArchivos" WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Spanish_Spain.1252' LC_CTYPE = 'Spanish_Spain.1252';
 !   DROP DATABASE "bdSubirArchivos";
                postgres    false                        2615    123539    archive    SCHEMA        CREATE SCHEMA archive;
    DROP SCHEMA archive;
                postgres    false            	            2615    115348    security    SCHEMA        CREATE SCHEMA security;
    DROP SCHEMA security;
                postgres    false            E           0    0    SCHEMA security    COMMENT     Z   COMMENT ON SCHEMA security IS 'Schema que se encarga de almacenar el tema de seguridad.';
                   postgres    false    9            
            2615    115349    usuario    SCHEMA        CREATE SCHEMA usuario;
    DROP SCHEMA usuario;
                postgres    false            F           0    0    SCHEMA usuario    COMMENT     V   COMMENT ON SCHEMA usuario IS 'Scehma destinado para contener los objetos de usuario';
                   postgres    false    10            �            1255    115350    f_log_auditoria()    FUNCTION     �  CREATE FUNCTION security.f_log_auditoria() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	 DECLARE
		_pk TEXT :='';		-- Representa la llave primaria de la tabla que esta siedno modificada.
		_sql TEXT;		-- Variable para la creacion del procedured.
		_column_guia RECORD; 	-- Variable para el FOR guarda los nombre de las columnas.
		_column_key RECORD; 	-- Variable para el FOR guarda los PK de las columnas.
		_session TEXT;	-- Almacena el usuario que genera el cambio.
		_user_db TEXT;		-- Almacena el usuario de bd que genera la transaccion.
		_control INT;		-- Variabel de control par alas llaves primarias.
		_count_key INT = 0;	-- Cantidad de columnas pertenecientes al PK.
		_sql_insert TEXT;	-- Variable para la construcción del insert del json de forma dinamica.
		_sql_delete TEXT;	-- Variable para la construcción del delete del json de forma dinamica.
		_sql_update TEXT;	-- Variable para la construcción del update del json de forma dinamica.
		_new_data RECORD; 	-- Fila que representa los campos nuevos del registro.
		_old_data RECORD;	-- Fila que representa los campos viejos del registro.

	BEGIN

			-- Se genera la evaluacion para determianr el tipo de accion sobre la tabla
		 IF (TG_OP = 'INSERT') THEN
			_new_data := NEW;
			_old_data := NEW;
		ELSEIF (TG_OP = 'UPDATE') THEN
			_new_data := NEW;
			_old_data := OLD;
		ELSE
			_new_data := OLD;
			_old_data := OLD;
		END IF;

		-- Se genera la evaluacion para determianr el tipo de accion sobre la tabla
		IF ((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = TG_TABLE_SCHEMA AND table_name = TG_TABLE_NAME AND column_name = 'id' ) > 0) THEN
			_pk := _new_data.id;
		ELSE
			_pk := '-1';
		END IF;

		-- Se valida que exista el campo modified_by
		IF ((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = TG_TABLE_SCHEMA AND table_name = TG_TABLE_NAME AND column_name = 'session') > 0) THEN
			_session := _new_data.session;
		ELSE
			_session := '';
		END IF;

		-- Se guarda el susuario de bd que genera la transaccion
		_user_db := (SELECT CURRENT_USER);

		-- Se evalua que exista el procedimeinto adecuado
		IF (SELECT COUNT(*) FROM security.function_db_view acfdv WHERE acfdv.b_function = 'field_audit' AND acfdv.b_type_parameters = TG_TABLE_SCHEMA || '.'|| TG_TABLE_NAME || ', '|| TG_TABLE_SCHEMA || '.'|| TG_TABLE_NAME || ', character varying, character varying, character varying, text, character varying, text, text') > 0
			THEN
				-- Se realiza la invocación del procedured generado dinamivamente
				PERFORM security.field_audit(_new_data, _old_data, TG_OP, _session, _user_db , _pk, ''::text);
		ELSE
			-- Se empieza la construcción del Procedured generico
			_sql := 'CREATE OR REPLACE FUNCTION security.field_audit( _data_new '|| TG_TABLE_SCHEMA || '.'|| TG_TABLE_NAME || ', _data_old '|| TG_TABLE_SCHEMA || '.'|| TG_TABLE_NAME || ', _accion character varying, _session text, _user_db character varying, _table_pk text, _init text)'
			|| ' RETURNS TEXT AS ''
'
			|| '
'
	|| '	DECLARE
'
	|| '		_column_data TEXT;
	 	_datos jsonb;
	 	
'
	|| '	BEGIN
			_datos = ''''{}'''';
';
			-- Se evalua si hay que actualizar la pk del registro de auditoria.
			IF _pk = '-1'
				THEN
					_sql := _sql
					|| '
		_column_data := ';

					-- Se genera el update con la clave pk de la tabla
					SELECT
						COUNT(isk.column_name)
					INTO
						_control
					FROM
						information_schema.table_constraints istc JOIN information_schema.key_column_usage isk ON isk.constraint_name = istc.constraint_name
					WHERE
						istc.table_schema = TG_TABLE_SCHEMA
					 AND	istc.table_name = TG_TABLE_NAME
					 AND	istc.constraint_type ilike '%primary%';

					-- Se agregan las columnas que componen la pk de la tabla.
					FOR _column_key IN SELECT
							isk.column_name
						FROM
							information_schema.table_constraints istc JOIN information_schema.key_column_usage isk ON isk.constraint_name = istc.constraint_name
						WHERE
							istc.table_schema = TG_TABLE_SCHEMA
						 AND	istc.table_name = TG_TABLE_NAME
						 AND	istc.constraint_type ilike '%primary%'
						ORDER BY 
							isk.ordinal_position  LOOP

						_sql := _sql || ' _data_new.' || _column_key.column_name;
						
						_count_key := _count_key + 1 ;
						
						IF _count_key < _control THEN
							_sql :=	_sql || ' || ' || ''''',''''' || ' ||';
						END IF;
					END LOOP;
				_sql := _sql || ';';
			END IF;

			_sql_insert:='
		IF _accion = ''''INSERT''''
			THEN
				';
			_sql_delete:='
		ELSEIF _accion = ''''DELETE''''
			THEN
				';
			_sql_update:='
		ELSE
			';

			-- Se genera el ciclo de agregado de columnas para el nuevo procedured
			FOR _column_guia IN SELECT column_name, data_type FROM information_schema.columns WHERE table_schema = TG_TABLE_SCHEMA AND table_name = TG_TABLE_NAME
				LOOP
						
					_sql_insert:= _sql_insert || '_datos := _datos || json_build_object('''''
					|| _column_guia.column_name
					|| '_nuevo'
					|| ''''', '
					|| '_data_new.'
					|| _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea', 'USER-DEFINED') THEN 
						_sql_insert:= _sql_insert
						||'::text';
					END IF;

					_sql_insert:= _sql_insert || ')::jsonb;
				';

					_sql_delete := _sql_delete || '_datos := _datos || json_build_object('''''
					|| _column_guia.column_name
					|| '_anterior'
					|| ''''', '
					|| '_data_old.'
					|| _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea', 'USER-DEFINED') THEN 
						_sql_delete:= _sql_delete
						||'::text';
					END IF;

					_sql_delete:= _sql_delete || ')::jsonb;
				';

					_sql_update := _sql_update || 'IF _data_old.' || _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea','USER-DEFINED') THEN 
						_sql_update:= _sql_update
						||'::text';
					END IF;

					_sql_update:= _sql_update || ' <> _data_new.' || _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea','USER-DEFINED') THEN 
						_sql_update:= _sql_update
						||'::text';
					END IF;

					_sql_update:= _sql_update || '
				THEN _datos := _datos || json_build_object('''''
					|| _column_guia.column_name
					|| '_anterior'
					|| ''''', '
					|| '_data_old.'
					|| _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea','USER-DEFINED') THEN 
						_sql_update:= _sql_update
						||'::text';
					END IF;

					_sql_update:= _sql_update
					|| ', '''''
					|| _column_guia.column_name
					|| '_nuevo'
					|| ''''', _data_new.'
					|| _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea', 'USER-DEFINED') THEN 
						_sql_update:= _sql_update
						||'::text';
					END IF;

					_sql_update:= _sql_update
					|| ')::jsonb;
			END IF;
			';
			END LOOP;

			-- Se le agrega la parte final del procedured generico
			
			_sql:= _sql || _sql_insert || _sql_delete || _sql_update
			|| ' 
		END IF;

		INSERT INTO security.auditoria
		(
			fecha,
			accion,
			schema,
			tabla,
			pk,
			session,
			user_bd,
			data
		)
		VALUES
		(
			CURRENT_TIMESTAMP,
			_accion,
			''''' || TG_TABLE_SCHEMA || ''''',
			''''' || TG_TABLE_NAME || ''''',
			_table_pk,
			_session,
			_user_db,
			_datos::jsonb
			);

		RETURN NULL; 
	END;'''
|| '
LANGUAGE plpgsql;';

			-- Se genera la ejecución de _sql, es decir se crea el nuevo procedured de forma generica.
			EXECUTE _sql;

		-- Se realiza la invocación del procedured generado dinamivamente
			PERFORM security.field_audit(_new_data, _old_data, TG_OP::character varying, _session, _user_db, _pk, ''::text);

		END IF;

		RETURN NULL;

END;
$$;
 *   DROP FUNCTION security.f_log_auditoria();
       security          postgres    false    9            �            1259    115352    usuario    TABLE       CREATE TABLE usuario.usuario (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    apellido text NOT NULL,
    user_name text NOT NULL,
    clave text NOT NULL,
    rol_id integer,
    session text,
    last_modify timestamp without time zone
);
    DROP TABLE usuario.usuario;
       usuario         heap    postgres    false    10            �            1255    115358 e   field_audit(usuario.usuario, usuario.usuario, character varying, text, character varying, text, text)    FUNCTION     �  CREATE FUNCTION security.field_audit(_data_new usuario.usuario, _data_old usuario.usuario, _accion character varying, _session text, _user_db character varying, _table_pk text, _init text) RETURNS text
    LANGUAGE plpgsql
    AS $$

	DECLARE
		_column_data TEXT;
	 	_datos jsonb;
	 	
	BEGIN
			_datos = '{}';

		IF _accion = 'INSERT'
			THEN
				_datos := _datos || json_build_object('id_nuevo', _data_new.id)::jsonb;
				_datos := _datos || json_build_object('nombre_nuevo', _data_new.nombre)::jsonb;
				_datos := _datos || json_build_object('apellido_nuevo', _data_new.apellido)::jsonb;
				_datos := _datos || json_build_object('user_name_nuevo', _data_new.user_name)::jsonb;
				_datos := _datos || json_build_object('clave_nuevo', _data_new.clave)::jsonb;
				_datos := _datos || json_build_object('rol_id_nuevo', _data_new.rol_id)::jsonb;
				_datos := _datos || json_build_object('session_nuevo', _data_new.session)::jsonb;
				_datos := _datos || json_build_object('last_modify_nuevo', _data_new.last_modify)::jsonb;
				
		ELSEIF _accion = 'DELETE'
			THEN
				_datos := _datos || json_build_object('id_anterior', _data_old.id)::jsonb;
				_datos := _datos || json_build_object('nombre_anterior', _data_old.nombre)::jsonb;
				_datos := _datos || json_build_object('apellido_anterior', _data_old.apellido)::jsonb;
				_datos := _datos || json_build_object('user_name_anterior', _data_old.user_name)::jsonb;
				_datos := _datos || json_build_object('clave_anterior', _data_old.clave)::jsonb;
				_datos := _datos || json_build_object('rol_id_anterior', _data_old.rol_id)::jsonb;
				_datos := _datos || json_build_object('session_anterior', _data_old.session)::jsonb;
				_datos := _datos || json_build_object('last_modify_anterior', _data_old.last_modify)::jsonb;
				
		ELSE
			IF _data_old.id <> _data_new.id
				THEN _datos := _datos || json_build_object('id_anterior', _data_old.id, 'id_nuevo', _data_new.id)::jsonb;
			END IF;
			IF _data_old.nombre <> _data_new.nombre
				THEN _datos := _datos || json_build_object('nombre_anterior', _data_old.nombre, 'nombre_nuevo', _data_new.nombre)::jsonb;
			END IF;
			IF _data_old.apellido <> _data_new.apellido
				THEN _datos := _datos || json_build_object('apellido_anterior', _data_old.apellido, 'apellido_nuevo', _data_new.apellido)::jsonb;
			END IF;
			IF _data_old.user_name <> _data_new.user_name
				THEN _datos := _datos || json_build_object('user_name_anterior', _data_old.user_name, 'user_name_nuevo', _data_new.user_name)::jsonb;
			END IF;
			IF _data_old.clave <> _data_new.clave
				THEN _datos := _datos || json_build_object('clave_anterior', _data_old.clave, 'clave_nuevo', _data_new.clave)::jsonb;
			END IF;
			IF _data_old.rol_id <> _data_new.rol_id
				THEN _datos := _datos || json_build_object('rol_id_anterior', _data_old.rol_id, 'rol_id_nuevo', _data_new.rol_id)::jsonb;
			END IF;
			IF _data_old.session <> _data_new.session
				THEN _datos := _datos || json_build_object('session_anterior', _data_old.session, 'session_nuevo', _data_new.session)::jsonb;
			END IF;
			IF _data_old.last_modify <> _data_new.last_modify
				THEN _datos := _datos || json_build_object('last_modify_anterior', _data_old.last_modify, 'last_modify_nuevo', _data_new.last_modify)::jsonb;
			END IF;
			 
		END IF;

		INSERT INTO security.auditoria
		(
			fecha,
			accion,
			schema,
			tabla,
			pk,
			session,
			user_bd,
			data
		)
		VALUES
		(
			CURRENT_TIMESTAMP,
			_accion,
			'usuario',
			'usuario',
			_table_pk,
			_session,
			_user_db,
			_datos::jsonb
			);

		RETURN NULL; 
	END;$$;
 �   DROP FUNCTION security.field_audit(_data_new usuario.usuario, _data_old usuario.usuario, _accion character varying, _session text, _user_db character varying, _table_pk text, _init text);
       security          postgres    false    9    205    205            �            1255    115359 8   f_insertar(character varying, text, text, text, integer)    FUNCTION     }  CREATE FUNCTION usuario.f_insertar(_nombre character varying, _apellido text, _user_name text, _clave text, _rolid integer) RETURNS SETOF void
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO 
			usuario.usuario
			(
				nombre,
				apellido,
				user_name,
				clave,
				rol_id
			)
	VALUES
		(
			_nombre,
			_apellido,
			_user_name,
			_clave,
			_rolid
			
		);
	END;
$$;
 {   DROP FUNCTION usuario.f_insertar(_nombre character varying, _apellido text, _user_name text, _clave text, _rolid integer);
       usuario          postgres    false    10            �            1255    115360 9   f_insertar1(character varying, text, text, text, integer)    FUNCTION     �  CREATE FUNCTION usuario.f_insertar1(_nombre character varying, _apellido text, _user_name text, _clave text, _rolid integer) RETURNS SETOF boolean
    LANGUAGE plpgsql
    AS $$
	DECLARE
		_cantidad integer;
	BEGIN
		_cantidad := (SELECT COUNT(*) FROM usuario.usuario WHERE user_name = _user_name);
	
		IF _cantidad = 0 
			THEN 
				INSERT INTO 
					usuario.usuario
					(
						nombre,
						apellido,
						user_name,
						clave,
						rol_id
					)
				VALUES
					(
						_nombre,
						_apellido,
						_user_name,
						_clave,
						_rolid
					);
					
				RETURN QUERY SELECT TRUE;
			ELSE
				RETURN QUERY SELECT FALSE;
			END IF;
	END;
$$;
 |   DROP FUNCTION usuario.f_insertar1(_nombre character varying, _apellido text, _user_name text, _clave text, _rolid integer);
       usuario          postgres    false    10            �            1259    115361    v_login    VIEW     z   CREATE VIEW usuario.v_login AS
 SELECT 0 AS user_id,
    ''::text AS nombre,
    0 AS rol_id,
    ''::text AS rol_nombre;
    DROP VIEW usuario.v_login;
       usuario          postgres    false    10            �            1255    115365    f_login(text, text)    FUNCTION     �  CREATE FUNCTION usuario.f_login(_user_name text, _clave text) RETURNS SETOF usuario.v_login
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN QUERY
		SELECT
			uu.id AS user_id,
			uu.nombre || ' ' || uu.apellido AS nombre,
			ur.id AS rol_id,
			ur.nombre AS rol_nombre

		FROM
			usuario.usuario uu JOIN usuario.rol ur ON ur.id = uu.rol_id
		WHERE
			uu.user_name = _user_name
		 AND	uu.clave = _clave;
	END;
$$;
 =   DROP FUNCTION usuario.f_login(_user_name text, _clave text);
       usuario          postgres    false    10    206            �            1255    115366    f_obtener_usuarios()    FUNCTION     �   CREATE FUNCTION usuario.f_obtener_usuarios() RETURNS SETOF usuario.usuario
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN QUERY
		SELECT
			uu.*

		FROM
			usuario.usuario uu;
	END;
$$;
 ,   DROP FUNCTION usuario.f_obtener_usuarios();
       usuario          postgres    false    10    205            �            1259    123581    archivo    TABLE     �   CREATE TABLE archive.archivo (
    id integer NOT NULL,
    nombre_archivo character varying(30) NOT NULL,
    nombre_extension character varying(30) NOT NULL
);
    DROP TABLE archive.archivo;
       archive         heap    postgres    false    8            �            1259    123579    archivo_id_seq    SEQUENCE     �   CREATE SEQUENCE archive.archivo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE archive.archivo_id_seq;
       archive          postgres    false    215    8            G           0    0    archivo_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE archive.archivo_id_seq OWNED BY archive.archivo.id;
          archive          postgres    false    214            �            1259    115367 	   auditoria    TABLE     K  CREATE TABLE security.auditoria (
    id bigint NOT NULL,
    fecha timestamp without time zone NOT NULL,
    accion character varying(100),
    schema character varying(200) NOT NULL,
    tabla character varying(200),
    session text,
    user_bd character varying(100) NOT NULL,
    data jsonb NOT NULL,
    pk text NOT NULL
);
    DROP TABLE security.auditoria;
       security         heap    postgres    false    9            H           0    0    TABLE auditoria    COMMENT     a   COMMENT ON TABLE security.auditoria IS 'Tabla que almacena la trazabilidad de la informaicón.';
          security          postgres    false    207            I           0    0    COLUMN auditoria.id    COMMENT     D   COMMENT ON COLUMN security.auditoria.id IS 'campo pk de la tabla ';
          security          postgres    false    207            J           0    0    COLUMN auditoria.fecha    COMMENT     Z   COMMENT ON COLUMN security.auditoria.fecha IS 'ALmacen ala la fecha de la modificación';
          security          postgres    false    207            K           0    0    COLUMN auditoria.accion    COMMENT     f   COMMENT ON COLUMN security.auditoria.accion IS 'Almacena la accion que se ejecuto sobre el registro';
          security          postgres    false    207            L           0    0    COLUMN auditoria.schema    COMMENT     m   COMMENT ON COLUMN security.auditoria.schema IS 'Almanena el nomnbre del schema de la tabla que se modifico';
          security          postgres    false    207            M           0    0    COLUMN auditoria.tabla    COMMENT     `   COMMENT ON COLUMN security.auditoria.tabla IS 'Almacena el nombre de la tabla que se modifico';
          security          postgres    false    207            N           0    0    COLUMN auditoria.session    COMMENT     p   COMMENT ON COLUMN security.auditoria.session IS 'Campo que almacena el id de la session que generó el cambio';
          security          postgres    false    207            O           0    0    COLUMN auditoria.user_bd    COMMENT     �   COMMENT ON COLUMN security.auditoria.user_bd IS 'Campo que almacena el user que se autentico en el motor para generar el cmabio';
          security          postgres    false    207            P           0    0    COLUMN auditoria.data    COMMENT     d   COMMENT ON COLUMN security.auditoria.data IS 'campo que almacena la modificaicón que se realizó';
          security          postgres    false    207            Q           0    0    COLUMN auditoria.pk    COMMENT     W   COMMENT ON COLUMN security.auditoria.pk IS 'Campo que identifica el id del registro.';
          security          postgres    false    207            �            1259    115373    auditoria_id_seq    SEQUENCE     {   CREATE SEQUENCE security.auditoria_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE security.auditoria_id_seq;
       security          postgres    false    9    207            R           0    0    auditoria_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE security.auditoria_id_seq OWNED BY security.auditoria.id;
          security          postgres    false    208            �            1259    115375    function_db_view    VIEW     �  CREATE VIEW security.function_db_view AS
 SELECT pp.proname AS b_function,
    oidvectortypes(pp.proargtypes) AS b_type_parameters
   FROM (pg_proc pp
     JOIN pg_namespace pn ON ((pn.oid = pp.pronamespace)))
  WHERE ((pn.nspname)::text <> ALL (ARRAY[('pg_catalog'::character varying)::text, ('information_schema'::character varying)::text, ('admin_control'::character varying)::text, ('vial'::character varying)::text]));
 %   DROP VIEW security.function_db_view;
       security          postgres    false    9            �            1259    115380    prueba    TABLE     9   CREATE TABLE usuario.prueba (
    id integer NOT NULL
);
    DROP TABLE usuario.prueba;
       usuario         heap    postgres    false    10            �            1259    115383    prueba_id_seq    SEQUENCE     �   CREATE SEQUENCE usuario.prueba_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE usuario.prueba_id_seq;
       usuario          postgres    false    10    210            S           0    0    prueba_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE usuario.prueba_id_seq OWNED BY usuario.prueba.id;
          usuario          postgres    false    211            �            1259    115385    rol    TABLE     P   CREATE TABLE usuario.rol (
    id integer NOT NULL,
    nombre text NOT NULL
);
    DROP TABLE usuario.rol;
       usuario         heap    postgres    false    10            T           0    0 	   TABLE rol    COMMENT     S   COMMENT ON TABLE usuario.rol IS 'Almacena los diferentes roles de la aplicación';
          usuario          postgres    false    212            �            1259    115391    usuario_id_seq    SEQUENCE     �   CREATE SEQUENCE usuario.usuario_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 5
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE usuario.usuario_id_seq;
       usuario          postgres    false    205    10            U           0    0    usuario_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE usuario.usuario_id_seq OWNED BY usuario.usuario.id;
          usuario          postgres    false    213            �
           2604    123584 
   archivo id    DEFAULT     j   ALTER TABLE ONLY archive.archivo ALTER COLUMN id SET DEFAULT nextval('archive.archivo_id_seq'::regclass);
 :   ALTER TABLE archive.archivo ALTER COLUMN id DROP DEFAULT;
       archive          postgres    false    214    215    215            �
           2604    115393    auditoria id    DEFAULT     p   ALTER TABLE ONLY security.auditoria ALTER COLUMN id SET DEFAULT nextval('security.auditoria_id_seq'::regclass);
 =   ALTER TABLE security.auditoria ALTER COLUMN id DROP DEFAULT;
       security          postgres    false    208    207            �
           2604    115394 	   prueba id    DEFAULT     h   ALTER TABLE ONLY usuario.prueba ALTER COLUMN id SET DEFAULT nextval('usuario.prueba_id_seq'::regclass);
 9   ALTER TABLE usuario.prueba ALTER COLUMN id DROP DEFAULT;
       usuario          postgres    false    211    210            �
           2604    115395 
   usuario id    DEFAULT     j   ALTER TABLE ONLY usuario.usuario ALTER COLUMN id SET DEFAULT nextval('usuario.usuario_id_seq'::regclass);
 :   ALTER TABLE usuario.usuario ALTER COLUMN id DROP DEFAULT;
       usuario          postgres    false    213    205            >          0    123581    archivo 
   TABLE DATA           H   COPY archive.archivo (id, nombre_archivo, nombre_extension) FROM stdin;
    archive          postgres    false    215   �o       7          0    115367 	   auditoria 
   TABLE DATA           c   COPY security.auditoria (id, fecha, accion, schema, tabla, session, user_bd, data, pk) FROM stdin;
    security          postgres    false    207   �o       9          0    115380    prueba 
   TABLE DATA           %   COPY usuario.prueba (id) FROM stdin;
    usuario          postgres    false    210   Kr       ;          0    115385    rol 
   TABLE DATA           *   COPY usuario.rol (id, nombre) FROM stdin;
    usuario          postgres    false    212   hr       6          0    115352    usuario 
   TABLE DATA           h   COPY usuario.usuario (id, nombre, apellido, user_name, clave, rol_id, session, last_modify) FROM stdin;
    usuario          postgres    false    205   �r       V           0    0    archivo_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('archive.archivo_id_seq', 8, true);
          archive          postgres    false    214            W           0    0    auditoria_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('security.auditoria_id_seq', 14, true);
          security          postgres    false    208            X           0    0    prueba_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('usuario.prueba_id_seq', 1, false);
          usuario          postgres    false    211            Y           0    0    usuario_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('usuario.usuario_id_seq', 41, true);
          usuario          postgres    false    213            �
           2606    123586    archivo archivo_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY archive.archivo
    ADD CONSTRAINT archivo_pkey PRIMARY KEY (id);
 ?   ALTER TABLE ONLY archive.archivo DROP CONSTRAINT archivo_pkey;
       archive            postgres    false    215            �
           2606    115397    auditoria pk_security_auditoria 
   CONSTRAINT     _   ALTER TABLE ONLY security.auditoria
    ADD CONSTRAINT pk_security_auditoria PRIMARY KEY (id);
 K   ALTER TABLE ONLY security.auditoria DROP CONSTRAINT pk_security_auditoria;
       security            postgres    false    207            �
           2606    115399    usuario pk_usuario_usuario 
   CONSTRAINT     Y   ALTER TABLE ONLY usuario.usuario
    ADD CONSTRAINT pk_usuario_usuario PRIMARY KEY (id);
 E   ALTER TABLE ONLY usuario.usuario DROP CONSTRAINT pk_usuario_usuario;
       usuario            postgres    false    205            �
           2606    115401    rol rol_pkey 
   CONSTRAINT     K   ALTER TABLE ONLY usuario.rol
    ADD CONSTRAINT rol_pkey PRIMARY KEY (id);
 7   ALTER TABLE ONLY usuario.rol DROP CONSTRAINT rol_pkey;
       usuario            postgres    false    212            �
           2620    115402    usuario tg_usuario_usuario    TRIGGER     �   CREATE TRIGGER tg_usuario_usuario AFTER INSERT OR DELETE OR UPDATE ON usuario.usuario FOR EACH ROW EXECUTE FUNCTION security.f_log_auditoria();
 4   DROP TRIGGER tg_usuario_usuario ON usuario.usuario;
       usuario          postgres    false    205    216            >      x������ � �      7   �  x���ێ�0���)"����w�n.Z�VQ��E����%Xi[�C��b596��
�l�?f�Y�Cޝ��L "�"仄!�����t1����2ɛ' ���ˋr#Ea�q�|��b�U�-w��s�e��y�|��4��B������Xsp>,�m�O G\�� d��,��V��m�0{�}b#'�ۙ"PxN�[7@�p��z��[�<]u���m!�"ɳΒ}
��i��yG}Ὸ��Z�
!W��N<F��!)/��6����vPV���#"\``Ȅh�d���f�\��R��hͅ��xԚ�>��zl�W�fa`}}�1���9r�ϩ�N�]2����<;|�#���ZH��ù��i�i�/�F�VmN��i4����sÀ2�V�`�gDt�jӈ.�3߄hP>�'N�&_.3����5��sǥ�:�� �C�`��O0���f��Z0�ի�1��r��NҰ��3覚t���r�Bo!��TCj��x���Y�E<(-��F����nό��|�S���j��q^�	]�W�-YQ�7P�zr�^��,�9��ҀIcѽA82�F����@����y��(b4�i��<��X���W!��=�x6\;�.���F�)L�k���~      9      x������ � �      ;      x�3�tL����,.)JL�/����� K�>      6   q   x�-�;
�@@�S������!�"9�̈́�veМ?B�y���c5],��VWOW[-J�-�萁a~���P��E�O��c����?!����D'��ƞt̂s��_��!I     