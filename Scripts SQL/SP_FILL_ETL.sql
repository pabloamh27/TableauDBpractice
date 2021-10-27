
-- confirm payment
CREATE OR REPLACE FUNCTION Verifycate_payment(id_pay integer) RETURNS integer AS
$BODY$
DECLARE
	resp integer;
BEGIN
	SELECT count(*) into resp from payment_register pr where pr.payment_id=id_pay;
	return resp;
END
$BODY$
LANGUAGE 'plpgsql';

-- confrim Sucursal dimension
CREATE OR REPLACE FUNCTION Verifycate_store(id_store integer) RETURNS integer AS
$BODY$
DECLARE
	resp integer;
BEGIN
	SELECT count(*) into resp from Sucursal_dim sd where sd.sucursal_id=id_store;
	IF resp=0 THEN
		INSERT INTO Sucursal_dim VALUES(id_store);
	END IF;
	return id_store;
END
$BODY$
LANGUAGE 'plpgsql';


-- confrim Address dimension
CREATE OR REPLACE FUNCTION  Verifycate_address
(add_n character varying(255), city_n character varying(255), count_n character varying(255)) 
RETURNS integer AS
$BODY$
DECLARE
	add_id integer;
	resp1 integer;
	cit_id integer;
	resp2 integer;
	count_id integer;
	resp3 integer;
BEGIN
	
	-- Country
	SELECT count(*) into resp3 from Country_subdim where country_name=count_n;
	IF resp3=0 then
		insert into Country_subdim (country_name) VALUES (count_n);
	END IF;
	SELECT ct.country_id into count_id from Country_subdim ct where country_name=count_n;
	
	-- City
	SELECT count(*) into resp2 from City_subdim cs where cs.city_name=city_n and cs.country_id=count_id;
	IF resp2=0 then
		insert into City_subdim (city_name, country_id) VALUES (city_n, count_id);
	END IF;
	SELECT cs.city_id into cit_id from City_subdim cs where cs.city_name=city_n and cs.country_id=count_id;
	
	-- Address
	SELECT count(*) into resp1 from Address_dim ad where ad.address_name=add_n and ad.city_id=cit_id;
	IF resp1=0 then
		insert into Address_dim (address_name, city_id) VALUES (add_n, cit_id);
	END IF;
	SELECT ad.address_id into add_id from Address_dim ad where ad.address_name=add_n and ad.city_id=cit_id;
	
	return add_id;
END
$BODY$
LANGUAGE 'plpgsql';

-- confirm Date dimension
CREATE OR REPLACE FUNCTION Verifycate_date(date_in timestamp without time zone) RETURNS integer AS
$BODY$
DECLARE
	date_id integer;
	resp integer;
BEGIN
	SELECT count(*) into resp from Date_dim 
	where date_day=EXTRACT(DAY FROM date_in) 
	and date_year=EXTRACT(YEAR FROM date_in) 
	and date_month=EXTRACT(MONTH FROM date_in);
	IF resp=0 then
		insert into Date_dim (date_day, date_year, date_month) 
		VALUES (EXTRACT(DAY FROM date_in), EXTRACT(YEAR FROM date_in), EXTRACT(MONTH FROM date_in));
	END IF;
	SELECT dd.date_id into date_id from Date_dim dd 
	where date_day=EXTRACT(DAY FROM date_in) 
	and date_year=EXTRACT(YEAR FROM date_in) 
	and date_month=EXTRACT(MONTH FROM date_in);
	return date_id;
END
$BODY$
LANGUAGE 'plpgsql';


-- confirm Film dimension
CREATE OR REPLACE FUNCTION Verifycate_film(f_id integer, f_name character varying(255)) RETURNS integer AS
$BODY$
DECLARE
	movie_id integer;
	cat_id integer;
	act_id integer;
	resp integer;
	reg1          RECORD;
	reg2          RECORD;
	cur_act  cursor (film_i integer) for
		select CONCAT(ac.first_name, ac.last_name) actor_name from film_actor fa
		inner join actor ac on ac.actor_id=fa.actor_id
		where fa.film_id=film_i;
	cur_cat  cursor (film_i integer) for
		select ca.name category_name from film_category fc
		inner join category ca on ca.category_id=fc.category_id
		where fc.film_id=film_i;
		
BEGIN
	
	-- Se encuentra y verifica la pelicula
	SELECT count(*) into resp from Film_dim fl where fl.film_name=f_name;
	IF resp=0 then
		insert into Film_dim (film_name) 
		VALUES (f_name);
	END IF;
	SELECT fl.film_id into movie_id from Film_dim fl where fl.film_name=f_name;
	
	-- Se verifican los actores
	open cur_act(f_id);
	FETCH cur_act INTO reg1;
	WHILE( FOUND ) LOOP
	
		SELECT count(*) into resp from Actor_subdim ac where ac.actor_name=reg1.actor_name;
		IF resp=0 then
			insert into Actor_subdim (actor_name) 
			VALUES (reg1.actor_name);
		END IF;
		SELECT ac.actor_id into act_id from Actor_subdim ac where ac.actor_name=reg1.actor_name;
		
		SELECT count(*) into resp from film_x_actor fa where fa.film_id=movie_id and fa.actor_id=act_id;
		IF resp=0 then
			insert into film_x_actor (film_id, actor_id) 
			VALUES (movie_id, act_id);
		END IF;
    	FETCH cur_act INTO reg1;
		
   	END LOOP ;
	close cur_act;
	
	-- Se verifican las categorias
	open cur_cat(f_id);
	FETCH cur_cat INTO reg2;
	WHILE( FOUND ) LOOP
	
		SELECT count(*) into resp from Category_subdim ca where ca.category_name=reg2.category_name;
		IF resp=0 then
			insert into Category_subdim (category_name) 
			VALUES (reg2.category_name);
		END IF;
		SELECT ca.category_id into cat_id from Category_subdim ca where ca.category_name=reg2.category_name;
		
		SELECT count(*) into resp from film_x_category fc where fc.film_id=movie_id and fc.category_id=cat_id;
		IF resp=0 then
			insert into film_x_category (film_id, category_id) 
			VALUES (movie_id, cat_id);
		END IF;
    	FETCH cur_cat INTO reg2;
		
   	END LOOP ;
	close cur_cat;
	
	return movie_id;
END
$BODY$
LANGUAGE 'plpgsql';

CREATE OR REPLACE PROCEDURE SP_FILL_ETL()
LANGUAGE 'plpgsql'
AS $$ 
declare
	reg          RECORD;
	cur_films  cursor for 
		select py.payment_id, py.amount,
		st.store_id,
		ad.address, ct.city, cot.country,
		rt.rental_date,
		fm.film_id, fm.title, fm.release_year
		from payment py
		inner join staff sf on sf.staff_id=py.staff_id
		inner join store st on st.store_id=sf.store_id
		inner join address ad on ad.address_id=st.address_id
		inner join city ct on ct.city_id=ad.city_id
		inner join country cot on cot.country_id=ct.country_id
		inner join rental rt on rt.rental_id=py.rental_id
		inner join inventory inv on inv.inventory_id=rt.inventory_id
		inner join film fm on fm.film_id=inv.film_id;
	idstore integer; 
	idfilm integer;
	idaddress integer;
	iddate integer;
BEGIN
	open cur_films;
	FETCH cur_films INTO reg;
	
	WHILE( FOUND ) LOOP
		IF Verifycate_payment(reg.payment_id)=0 then
			
			-- Verificar e insertar store
			select Verifycate_store(reg.store_id) into idstore;
			
			-- verificar e insertar address
			select Verifycate_address(reg.address, reg.city, reg.country) into idaddress;
			
			-- verificar e insertar date
			select Verifycate_date(reg.rental_date) into iddate;
			
			-- verificar e insertar film
			select Verifycate_film(reg.film_id, CONCAT(reg.title, to_char(reg.release_year, '9999'))) 
			into idfilm;
			
			INSERT INTO Hechos VALUES (iddate, idstore, idaddress, idfilm, reg.amount, 1);
			
			INSERT INTO payment_register VALUES(reg.payment_id);
			
		END IF;
    	FETCH cur_films INTO reg;
   	END LOOP ;
	close cur_films;
END; $$;

CALL SP_FILL_ETL();




