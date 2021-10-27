-- PROCEDIMIENTO QUE ACTUALIZA LA FECHA DE DEVOLUCIÓN DE UNA RENTA Y ACTUALIZA EL INVENTARIO
-- ENTRADA: EL ID DE LA RENTA (SMALLINT)
CREATE OR REPLACE function public.FC_REGISTER_RETURN(
id_ren smallint)
returns integer as $$
declare
	-- Se declara la variable donde se almacenará el id
    id_inv integer;
begin
	
	-- Se registra la devolución
	UPDATE rental SET return_date = current_timestamp, last_update = current_timestamp
	WHERE rental_id = id_ren;
	
	-- Se selecciona el id del inventario de esa renta
	SELECT inventory_id INTO id_inv FROM rental WHERE rental_id = id_ren;
	
	-- Se hace un update de la fecha de la devolución 
	UPDATE inventory SET last_update = current_timestamp
	WHERE inventory_id = id_inv;
	
	RETURN 1;
end;
$$ language plpgsql;