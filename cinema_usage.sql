
/** 
    ***** SHOW DURATION ******
*/
-- Funcion que calcula la duración total del SHOW
CREATE FUNCTION show_duration(param_movie_id int) RETURNS INT AS $$
DECLARE
    movie_duration_minutes INT; -- variable to save the duration of the movie
    total_show_duration INT;
BEGIN
    -- get the duration of the movie
    SELECT duration INTO movie_duration_minutes
    FROM movies
    WHERE movie_id = param_movie_id;

    -- total show = time of trailers + movie duration + time of cleaning
    total_show_duration = 15 + movie_duration_minutes + 15;
    RETURN total_show_duration;

END;
$$ LANGUAGE PLPGSQL;

DROP FUNCTION end_of_show;

/** 
    ***** END OF SHOW ******
*/
CREATE FUNCTION end_of_show(param_movie_id INT, param_start_time TIMESTAMP) RETURNS TIMESTAMP AS $$
DECLARE
    show_duration_minutes INT;
    show_end_time TIMESTAMP;
BEGIN
    -- query 1: obtener cuánto dura el show
    SELECT  show_duration(param_movie_id) INTO show_duration_minutes;

    -- hora de fin de show = hora de inicio + minutos que dura el show
    show_end_time = param_start_time + (show_duration_minutes ||' minutes')::interval;
    RETURN show_end_time;
END;
$$ LANGUAGE PLPGSQL;

SELECT show_id, start_time, end_of_show(movie_id, start_time) as end_time
FROM shows;


/** 
    ***** INSERT SHOW ******
*/
CREATE VIEW shows_with_end_time AS
SELECT
    *,
    end_of_show(movie_id, start_time) as end_time
FROM shows;

SELECT * FROM shows_with_end_time;

CREATE PROCEDURE insert_show (param_movie_id INT, param_room_id INT, param_start_time TIMESTAMP) AS $$
DECLARE
    end_of_previous_movie TIMESTAMP;
    start_of_next_movie TIMESTAMP;
    end_of_new_movie TIMESTAMP;
BEGIN
    -- Mirar a qué hora acaba la pelicula que empieza antes que esta que queremos programar
    SELECT end_time INTO end_of_previous_movie
    FROM shows_with_end_time
    WHERE
        room_id = param_room_id             -- especificar la sala
        AND start_time < param_start_time   -- la hora inicio de la peli anterior tiene que ser ANTES de que empiece la nueva peli
    ORDER BY start_time DESC                
    LIMIT 1;             

    IF end_of_previous_movie > param_start_time THEN
        RAISE EXCEPTION 'The show can not be created(1)';
    END IF;

    -- Mirar a qué hora empieza la película de después (para comprobar que no solapa tampoco)
    SELECT start_time INTO start_of_next_movie
    FROM shows_with_end_time
    WHERE
        room_id = param_room_id            
        AND start_time > param_start_time   -- tiene que empezar después que la nueva
    ORDER BY start_time ASC                 -- SUPER IMPORTANTE: cambiar la ordenación                
    LIMIT 1;   

    -- Mirar a qué hora acabaría teóricamente la película nueva
    SELECT end_of_show(param_movie_id, param_start_time) INTO end_of_new_movie;

    IF  end_of_new_movie > start_of_next_movie THEN
        RAISE EXCEPTION 'The show can not be created(2)';
    END IF;

    INSERT INTO shows (movie_id, room_id, start_time)
    VALUES (param_movie_id, param_room_id, param_start_time);
                    
END;
$$ LANGUAGE PLPGSQL;

CALL insert_show(1, 1, '2024-05-15 15:30:00');