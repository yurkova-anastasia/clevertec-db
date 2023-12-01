/*
Вывести к каждому самолету класс обслуживания и количество мест этого класса
*/

SELECT ad.aircraft_code,
       sea.fare_cONditiONs,
       count(sea.seat_no) AS count_of_seats
FROM aircrafts_data ad
         LEFT JOIN seats sea ON
    sea.aircraft_code = ad.aircraft_code
GROUP BY sea.fare_cONditiONs,
         ad.aircraft_code
ORDER BY ad.aircraft_code

/*
Найти 3 самых вместительных самолета (модель + кол-во мест)
*/

SELECT ad.model,
       count(sea.seat_no) AS count_of_seats
FROM aircrafts_data ad
    LEFT JOIN seats sea ON
        sea.aircraft_code = ad.aircraft_code
GROUP BY sea.fare_cONditiONs,
         ad.aircraft_code
ORDER BY count_of_seats DESC
LIMIT 3

/*
Найти все рейсы, которые задерживались более 2 часов
*/

SELECT flight_no,
       actual_departure - scheduled_departure AS delay_date
FROM flights f
WHERE actual_departure - scheduled_departure > '00:02:00'
ORDER BY delay_date ASC

/*
Найти последние 10 билетов, купленные в бизнес-классе (fare_cONditiONs = 'Business'), с указанием имени пассажира и контактных данных
*/

SELECT t.ticket_no,
       t.pASsenger_name,
       t.cONtact_data
FROM tickets t
    LEFT JOIN ticket_flights tf ON
        t.ticket_no = tf.ticket_no
WHERE tf.fare_cONditiONs = 'Business'
ORDER BY t.ticket_no DESC
LIMIT 10

/*
Найти все рейсы, у которых нет забронированных мест в бизнес-классе (fare_cONditiONs = 'Business')
*/

SELECT f.flight_id,
       f.flight_no,
       f.scheduled_departure
FROM flights f
WHERE f.flight_id NOT IN (SELECT tf.flight_id
                          FROM ticket_flights tf
                          WHERE tf.fare_cONditiONs = 'Business')
ORDER BY f.flight_no ASC

/*
Получить список аэропортов (airport_name) и городов (city), в которых есть рейсы с задержкой
*/

SELECT ad.airport_name,
       ad.city
FROM airports_data ad
    LEFT JOIN flights f ON
        f.departure_airport = ad.airport_code
WHERE f.actual_departure NOTNULL
   or f.actual_arrival NOTNULL
GROUP BY ad.airport_name,
         ad.city

/*
Получить список аэропортов (airport_name) и количество рейсов, вылетающих из каждого аэропорта, отсортированный по убыванию количества рейсов
*/

SELECT ad.airport_name,
       count(f.departure_airport) AS count_of_flights
FROM airports_data ad
    LEFT JOIN flights f ON
        f.departure_airport = ad.airport_code
GROUP BY ad.airport_name
ORDER BY count_of_flights DESC

/*
Найти все рейсы, у которых запланированное время прибытия (scheduled_arrival) было изменено и новое время прибытия (actual_arrival) не совпадает с запланированным
*/

SELECT f.flight_id,
       f.flight_no,
       f.scheduled_departure
FROM flights f
WHERE f.scheduled_arrival != f.actual_arrival;

/*
Вывести код, модель самолета и места не эконом класса для самолета "Аэробус A321-200" с сортировкой по местам
*/

SELECT ad.aircraft_code,
       ad.model,
       s.seat_no
FROM aircrafts_data ad
    LEFT JOIN seats s ON
        ad.aircraft_code = s.aircraft_code
WHERE ad.model:: json ->> 'ru' = 'Аэробус A321-200'
  AND s.fare_cONditiONs != 'Economy'
ORDER BY s.seat_no;

/*
Вывести города, в которых больше 1 аэропорта (код аэропорта, аэропорт, город)
*/

SELECT ad.city,
       count(ad.airport_code) AS count_of_airport
FROM airports_data ad
GROUP BY ad.city
HAVING count(ad.airport_code) > 1;

/*
Найти пассажиров, у которых суммарная стоимость бронирований превышает среднюю сумму всех бронирований
*/

SELECT t.passenger_name,
       sum(tf.amount)
FROM tickets t
    LEFT JOIN ticket_flights tf ON
        t.ticket_no = tf.ticket_no
GROUP BY t.passenger_name
HAVING sum(tf.amount) > (SELECT avg(tf.amount)
                         FROM ticket_flights tf)
ORDER BY sum


/*
Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация
*/

SELECT fv.flight_id,
       fv.flight_no,
       fv.scheduled_departure
FROM flights_v fv
WHERE departure_city = 'Екатеринбург'
  AND arrival_city = 'Москва'
  AND fv.status in ('Scheduled', 'ON Time', 'Delayed')
ORDER BY fv.flight_id

/*
Вывести самый дешевый и дорогой билет и стоимость (в одном результирующем ответе)
*/

(SELECT
    tf.ticket_no,
    tf.flight_id,
    tf.amount AS min_cost
FROM
    ticket_flights tf
ORDER BY
    amount
LIMIT 1)
UNION ALL
(SELECT
    tf.ticket_no,
    tf.flight_id,
    tf.amount AS max_cost
FROM
    ticket_flights tf
ORDER BY
    amount DESC
LIMIT 1)

/*
Написать DDL таблицы Customers, должны быть поля id, firstName, LAStName, email, phONe. Добавить ограничения на поля (cONstraints)
*/

CREATE TABLE customers
(
    id        bigserial PRIMARY KEY,
    firstName varchar(255) NOT null,
    lAStName  varchar(255) NOT NULL,
    email     varchar(255) NOT NULL UNIQUE CHECK (email ~* '^([a-zA-Z]+[^@]*)@([a-zA-Z]+\.)+[a-zA-Z]{2,4}$'),
    phONe     varchar(255) NOT NULL UNIQUE CHECK (phONe ~ '^[0-9]+$')
)

/*
Написать DDL таблицы Orders, должен быть id, customerId, quantity. Должен быть внешний ключ на таблицу customers + cONstraints
*/

CREATE TABLE orders
(
    id          bigserial PRIMARY KEY,
    quantity    int    NOT NULL,
    customer_id BIGINT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers (id)
)

/*
Написать 5 insert в эти таблицы
*/

INSERT INTO customers (firstname, lAStName, email, phONe)
VALUES ('firstname1', 'lAStName1', 'mail1@mail.ru', '375295275831'),
       ('firstname2', 'lAStName2', 'mail2@mail.ru', '37529527582'),
       ('firstname3', 'lAStName3', 'mail3@mail.ru', '375295275835'),
       ('firstname4', 'lAStName4', 'mail4@mail.ru', '375295275845'),
       ('firstname5', 'lAStName5', 'mail5@mail.ru', '375295275855')


INSERT INTO orders (quantity, customer_id)
VALUES (20, 2),
       (4, 1),
       (7, 3),
       (5, 5),
       (1, 4)

/*
Удалить таблицы
*/

DROP TABLE customers CASCADE

DROP TABLE orders