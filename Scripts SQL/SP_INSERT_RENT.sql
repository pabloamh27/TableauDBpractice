-- Procedimiento almacenado que registra una renta de una pelicula, la cual no va a poseer la fecha de devolución y se actualiza el inventario
-- Entradas: el id del customer (smallint), el id del staff que alquilo la pelicula (smallint) y el inventario de la pelicula (integer)
CREATE OR REPLACE FUNCTION public.FC_INSERT_RENTAL(
	id_customer smallint,
	id_staff smallint,
	id_inventory integer)
returns integer
AS $$
DECLARE 
	estado integer;
	id_inventory integer;
BEGIN

	-- Se verifica que no este rentada Y sin devolver
	SELECT COUNT(*) INTO estado from rental rt
	where rt.inventory_id= id_inventory and rt.return_date = NULL;

	IF estado=0 THEN
		-- Se inserta la renta 
		INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id, last_update) 
		VALUES (current_timestamp, id_inventory, id_customer, id_staff, current_timestamp);
		RETURN 1;
	END IF;
	
	RETURN 0;

END; $$ LANGUAGE 'plpgsql';
