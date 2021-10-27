create role EMP with login password 'contraseña123';
grant execute on function FC_FIND_MOVIE(movie Character Varying) to EMP;
grant execute on function FC_INSERT_RENTAL(id_customer smallint, id_staff smallint, id_inventory integer) to EMP;
grant execute on function FC_REGISTER_RETURN(id_rental smallint) to EMP;
                                              
create role ADMIN with login password 'contraseña123' in role emp;
grant execute on function "FC_INSERTAR_CLIENTE"(
	new_store_id smallint,
	new_first_name character varying,
	new_last_name character varying,
	new_email character varying,
	new_address_id smallint,
	new_activebool boolean,
	new_create_date date,
	new_last_update timestamp without time zone,
	new_active integer) to ADMIN;
	
create user video with superuser;

create user empleado1 with role EMP;

create user administrador1 with role ADMIN;

GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA public TO video;