# CINEMA DATABASE
# Views, functions, procedures and triggers

# Table of Contents
1. [Create database](#create)
2. [Functions documentation](#functions)
    - 2.1 [Function: show_duration](#show_duration)
    - 2.2 [Function: end_of_show](#end_of_showw)
3. [Procedures documentation](#procedures)
    - 3.1 [Procedure: insert_show](#insert_show)

## 1. Create the database <a name="create"></a>
Create the database using the command
```sql
CREATE DATABASE cinema:
```
After that, get connected to the `cinema` database run the `cinema_tables.sql`file.
To insert data in the database run the `cinema_inserts.sql` file.


## 2. Functions documentation <a name="functions"></a>
The code of the views, functions, procedures and triggers is in the `cinema_usage.sql`file.

### 2.1 Function: calculate the total duration of a show <a name="show_duration"></a>
```
Function name: 
    show_duration

Parameters:
    Movie id (int)

Output:
    show duration in minutes (int)
```

Code:
```sql
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
```

Usage example:
```sql
SELECT *, show_duration(movie_id)
FROM shows;
```
Output:
|show_id|movie_id|room_id|start_time|show_duration|
|--|--|--|--|--|
|10|1|1|2023-12-15 14:00:00|150|
|11|2|2|2023-12-15 16:00:00|180|
|12|3|3|2023-12-15 18:00:00|120|
|13|4|4|2023-12-15 20:00:00|145|

### 2.2 Function: calculate the end of the show <a name="end_of_show"></a>
```
Function name:
    end_of_show

Parameters:
    movie id (int)
    start time (timestamp)

Output:
    end time of the show (timestamp)
````

Code:
```sql
CREATE FUNCTION end_of_show(param_movie_id INT, param_start_time TIMESTAMP) RETURNS TIMESTAMP AS $$
DECLARE
    show_duration_minutes INT;
    show_end_time TIMESTAMP;
BEGIN
    -- query 1: obtener cuánto dura el show
    SELECT 
        show_duration(movie_id) INTO show_duration_minutes
    FROM shows
    WHERE movie_id = param_movie_id;

    -- hora de fin de show = hora de inicio + minutos que dura el show
    show_end_time = param_start_time + (show_duration_minutes ||' minutes')::interval;
    RETURN show_end_time;
END;
$$ LANGUAGE PLPGSQL;
```

Another way to code the same function is:
```sql
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
```
Changes the query to get the show duration in minutes.

Usage example:
```sql
SELECT show_id, start_time, end_of_show(movie_id, start_time) as end_time
FROM shows;
```
Output:
|show_id|start_time|end_time|
|--|--|--|
|10|2023-12-15 14:00:00|2023-12-15 16:30:00|
|11|2023-12-15 16:00:00|2023-12-15 19:00:00|
|12|2023-12-15 18:00:00|2023-12-15 20:00:00|
|13|2023-12-15 20:00:00|2023-12-15 20:00:00|


## 3. Procedures documentation <a name="procedures"></a>
The code of the views, functions, procedures and triggers is in the `cinema_usage.sql`file.

### 3.1 Procedure: insert show <a name="insert_show"></a>
```
Procedure name: 
    insert_show

Parameters:
   movie id (INT)
   room id (INT)
   start time (timestamp)
```

To do this procedure more easily, let's create a view to see all the attributes of every show and the end time of each show.
Code to create the view:
```sql
CREATE VIEW shows_with_end_time AS
SELECT
    *,
    end_of_show(movie_id, start_time) as end_time
FROM shows;
```
Usage example of the view:
```sql
SELECT * FROM shows_with_end_time;
```
A view can be used as a table.

Procedure code, only checkin the previous movie finishes before the new movie starts:
```sql
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
        RAISE EXCEPTION('This schedule is occupied')
    END IF;

    INSERT INTO shows (movie_id, room_id, start_time)
    VALUES (param_movie_id, param_room_id, param_start_time);
                     
END;
$$ LANGUAGE PLPGSQL;
```

Procedure code completed, checkin the previous movie finishes before the new movie starts and if there is later a movie which starts before the new movie ends:
```sql
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
```

Let's create some tests for this procedure:

- Insert a show today in the morning
    ```sql
    CALL insert_show(1, 1, '2024-05-15 12:30:00');
    ```
    Everything must be OK.
-- Insert a show today at 13:30
    ```sql
    CALL insert_show(1, 1, '2024-05-15 13:30:00');
    ```
    You'll get the error `The show can not be created (1)`. This means, the show can't be inserted because there is a movie which started before and haven't finished yet.
-- Insert a show today at 17:00
    ```sql
    CALL insert_show(1, 1, '2024-05-15 17:00:00');
    ```
    Everything must be OK.
-- Insert a show today at 15:30:00
    ```sql
    CALL insert_show(1, 1, '2024-05-15 17:00:00');
    ```
    You'll gt the error `The show can not be created (2)`. This means, the show can't be inserted because will overlap with the next show.

