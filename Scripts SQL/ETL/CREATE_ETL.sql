DROP TABLE Hechos;
DROP TABLE Address_dim;
DROP TABLE City_subdim;
DROP TABLE Country_subdim;
DROP TABLE film_x_actor;
DROP TABLE film_x_category;
DROP TABLE Film_dim;
DROP TABLE Category_subdim;
DROP TABLE Actor_subdim;
DROP TABLE Date_dim;
DROP TABLE Sucursal_dim;
DROP TABLE payment_register;


CREATE TABLE Film_dim(
	film_id SERIAL NOT NULL,
	film_name character varying(255) NOT NULL,
	CONSTRAINT dimfilm_pkey PRIMARY KEY (film_id)
);

CREATE TABLE Category_subdim(
	category_id SERIAL NOT NULL,
	category_name character varying(255) NOT NULL,
	CONSTRAINT subcat_pkey PRIMARY KEY (category_id)
);

CREATE  TABLE Actor_subdim(
	actor_id SERIAL NOT NULL,
	actor_name character varying(255) NOT NULL,
	CONSTRAINT subact_pkey PRIMARY KEY (actor_id)
);

CREATE TABLE film_x_actor(
	actor_id integer NOT NULL,
	film_id integer NOT NULL,
	CONSTRAINT film_x_actor_pkey PRIMARY KEY (actor_id, film_id),
    CONSTRAINT film_x_actor_pkey_actor_id_fkey FOREIGN KEY (actor_id)
        REFERENCES public.Actor_subdim (actor_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT film_x_actor_film_id_fkey FOREIGN KEY (film_id)
        REFERENCES public.Film_dim (film_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE  TABLE film_x_category(
	category_id integer NOT NULL,
	film_id integer NOT NULL,
	CONSTRAINT film_x_category_pkey PRIMARY KEY (film_id, category_id),
    CONSTRAINT film_x_category_category_id_fkey FOREIGN KEY (category_id)
        REFERENCES public.Category_subdim (category_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT film_x_category_film_id_fkey FOREIGN KEY (film_id)
        REFERENCES public.Film_dim (film_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE Country_subdim(
	country_id SERIAL NOT NULL,
	country_name character varying(255) NOT NULL,
	CONSTRAINT subcount_pkey PRIMARY KEY (country_id)
);

CREATE TABLE City_subdim(
	city_id SERIAL NOT NULL,
	city_name character varying(255) NOT NULL,
	country_id integer NOT NULL,
	CONSTRAINT subcit_pkey PRIMARY KEY (city_id),
	CONSTRAINT City_subdim_country_id_fkey FOREIGN KEY (country_id)
        REFERENCES public.Country_subdim (country_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE Address_dim(
	address_id SERIAL NOT NULL,
	address_name character varying(255) NOT NULL,
	city_id integer NOT NULL,
	CONSTRAINT dimadr_pkey PRIMARY KEY (address_id),
	CONSTRAINT Address_dim_city_id_fkey FOREIGN KEY (city_id)
        REFERENCES public.City_subdim (city_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE Date_dim(
	date_id SERIAL NOT NULL,
	date_day INTEGER NOT NULL,
	date_month INTEGER NOT NULL,
	date_year INTEGER NOT NULL,
	CONSTRAINT dimdate_pkey PRIMARY KEY (date_id)
);

CREATE TABLE Sucursal_dim(
	sucursal_id SERIAL NOT NULL,
	CONSTRAINT dimsuc_pkey PRIMARY KEY (sucursal_id)
);

CREATE TABLE Hechos(
	date_id integer NOT NULL,
	sucursal_id integer NOT NULL,
	address_id integer NOT NULL,
	film_id integer NOT NULL,
	monto numeric(8,2) NOT NULL,
	cantidad integer NOT NULL,
    CONSTRAINT Hechos_date_id_fkey FOREIGN KEY (date_id)
        REFERENCES public.Date_dim (date_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT Hechos_sucursal_id_fkey FOREIGN KEY (sucursal_id)
        REFERENCES public.Sucursal_dim (sucursal_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
	CONSTRAINT Hechos_adress_id_fkey FOREIGN KEY (address_id)
        REFERENCES public.Address_dim (address_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
	CONSTRAINT Hechos_film_id_fkey FOREIGN KEY (film_id)
        REFERENCES public.Film_dim (film_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE payment_register(
	payment_id integer NOT NULL,
	CONSTRAINT register_pkey PRIMARY KEY (payment_id)
);
