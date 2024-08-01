create type weekday as ENUM ('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY');

create table pos
(
    id SERIAL PRIMARY KEY,
    location POINT NOT NULL,
    open_hour TIME NOT NULL,
    close_hour TIME NOT NULL,
    open_days weekday[] NOT NULL
);

create type consent AS ENUM ('SMS', 'EMAIL', 'PUSH');
create type client_type AS ENUM ('INDIVIDUAL', 'BUSINESS');

create table client
(
    id SERIAL PRIMARY KEY,
    pos_id SERIAL REFERENCES pos(id) NOT NULL,
    msisdn CHAR(11),
    email VARCHAR(100),
    consents consent[],
    client_type client_type NOT NULL,
);

create table blocked_list(
    client_id INT PRIMARY KEY references client(id),
);

create table contact_history(
    id SERIAL PRIMARY KEY,
    client_id INT NOT NULL references client(id),
    event_time TIMESTAMP NOT NULL,
);

---- POS
insert into pos(id, location, open_hour, close_hour, open_days) VALUES (1, POINT(52.237049, 21.017532), '00:00:00', '23:59:59', ARRAY['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY']::weekday[]);
insert into pos(id, location, open_hour, close_hour, open_days) VALUES (2, POINT(50.049683, 19.944544), '08:00:00', '15:00:00', ARRAY['MONDAY', 'TUESDAY', 'WEDNESDAY', 'FRIDAY', 'SATURDAY']::weekday[]);
insert into pos(id, location, open_hour, close_hour, open_days) VALUES (3, POINT(51.107883, 17.038538), '00:00:00', '23:59:59', ARRAY['WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY']::weekday[]);

---- Clients
insert into client(id, pos_id, msisdn, email, consents, client_type) VALUES (1, 1, '48500500500', 'jan.kowalski@nussknacker.io', ARRAY['SMS']::consent[], "INDIVIDUAL");
insert into client(id, pos_id, msisdn, email, consents, client_type) VALUES (2, 1, '48500500501', 'zbigniew.paleta@nussknacker.io', ARRAY['SMS', 'EMAIL']::consent[], "BUSINESS");
insert into client(id, pos_id, msisdn, email, consents, client_type) VALUES (3, 1, '48500500502', 'genia.nowak@nussknacker.io', ARRAY['PUSH']::consent[], "INDIVIDUAL");
insert into client(id, pos_id, msisdn, email, consents, client_type) VALUES (4, 2, '48500500503', 'klaudia.wisniewska@nussknacker.io', ARRAY['SMS', 'EMAIL', 'PUSH']::consent[], "INDIVIDUAL");
insert into client(id, pos_id, msisdn, email, consents, client_type) VALUES (5, 2, '48500500504', 'teofil.benc@nussknacker.io', ARRAY['EMAIL']::consent[]), "BUSINESS";
insert into client(id, pos_id, msisdn, email, consents, client_type) VALUES (6, 2, '48500500505', 'zdzislaw.lecina@nussknacker.io', ARRAY[]::consent[], "BUSINESS");
insert into client(id, pos_id, msisdn, email, consents, client_type) VALUES (7, 2, '48500500506', 'ksenia.gorka@nussknacker.io', ARRAY['EMAIL', 'PUSH']::consent[], "INDIVIDUAL");
insert into client(id, pos_id, msisdn, email, consents, client_type) VALUES (8, 3, '48500500507', 'anna.milkowska@nussknacker.io', ARRAY['PUSH', 'SMS']::consent[], "BUSINESS");
insert into client(id, pos_id, msisdn, email, consents, client_type) VALUES (9, 3, '48500500508', 'john.doe@nussknacker.io', ARRAY['EMAIL']::consent[], "INDIVIDUAL");
insert into client(id, pos_id, msisdn, email, consents, client_type) VALUES (10, 3, '48500500509', 'frodo.baggins@nussknacker.io', ARRAY[]::consent[], "INDIVIDUAL");

---- Blocked
insert into blocked_list(client_id) values (5);
insert into blocked_list(client_id) values (7);
insert into blocked_list(client_id) values (10);

-- Contact history
insert into contact_history(client_id, event_time) VALUES (9, NOW() - INTERVAL '1 minutes');