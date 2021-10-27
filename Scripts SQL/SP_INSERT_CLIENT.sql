-- Procedure que permite insertar un cliente, recibiendo por entrada toda la información correspondiente
-- Entrada: 3 INT, 3 String, 1 boolean y 2 dates.
CREATE OR REPLACE FUNCTION public."FC_INSERTAR_CLIENTE"(
    new_store_id smallint,
    new_first_name character varying,
    new_last_name character varying,
    new_email character varying,
    new_address_id smallint,
    new_activebool boolean,
    new_create_date date,
    new_last_update timestamp without time zone,
    new_active integer)
returns integer as $$
BEGIN
	insert into customer (store_id, first_name, last_name, email, address_id, activebool, create_date, last_update, active) 
	values (new_store_id, new_first_name, new_last_name, new_email, new_address_id, new_activebool, new_create_date, new_last_update, new_active);
	RETURN 1; 
END;
$$ LANGUAGE plpgsql;