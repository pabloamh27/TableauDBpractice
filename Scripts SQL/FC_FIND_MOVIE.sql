-- Función que resive el nombre de una pelicula y recibe su id 
-- Entradas: El nombre de la pelicula / Character Varying
-- Salida: El id de la pelicula
create or replace function FC_FIND_MOVIE(movie character varying) returns integer as $$
declare
	-- Se declara la variable donde se almacenará el id
    movie_id integer;
begin
	-- Se busca la pelicula por el nombre
    select film_id into movie_id from film where film.title LIKE CONCAT('%',movie,'%');
    return movie_id;

end;
$$ language plpgsql;
