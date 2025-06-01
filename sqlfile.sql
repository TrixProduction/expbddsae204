-- "ID","Name","Sex","Age","Height","Weight","Team","NOC","Games","Year","Season","City","Sport","Event","Medal"
DROP TABLE IF EXISTS athlete_events;
CREATE TEMP TABLE athlete_events (
ID int,
nam text,
sex CHAR(1),
age int,
height int,
weight float,
team text,
noc VARCHAR(3),
game text,
yer int,
season text,
city text,
sport text,
event text,
medal text
);
\copy athlete_events FROM 'athlete_events.csv' with (format CSV, delimiter ',', NULL 'NA');
SELECT pg_total_relation_size('athlete_events') AS total_size_bytes; -- 8192
DELETE FROM athlete_events WHERE yer < 1920;
DELETE FROM athlete_events WHERE sport LIKE 'Art%';
SELECT COUNT(*) FROM athlete_events;
DROP TABLE IF EXISTS noc CASCADE;
CREATE TABLE noc (
noc VARCHAR(3) PRIMARY KEY,
region text,
notes text
);
\copy noc FROM 'noc_regions.csv' with (format CSV, delimiter ',', HEADER, NULL 'NA'); -- the instruction HEADER removes the first line of the file
SELECT COUNT(*) FROM noc;
DROP TABLE IF EXISTS performance CASCADE;
DROP TABLE IF EXISTS game CASCADE;
DROP TABLE IF EXISTS event CASCADE;
DROP TABLE IF EXISTS athlete CASCADE;
CREATE TABLE athlete (id int PRIMARY KEY, name text, sex char);
CREATE TABLE event(id serial PRIMARY KEY, event text, sport text);
CREATE TABLE game (id serial PRIMARY KEY, game text, yer int, season text, city text);
CREATE TABLE performance(
id_athlete int REFERENCES athlete(id),
id_event int REFERENCES event(id),
id_game int REFERENCES game(id),
noc text REFERENCES noc(noc),
medal text, age int ,weight float ,height int,
PRIMARY KEY(id_athlete, id_event, id_game, noc));
INSERT INTO athlete SELECT DISTINCT ID, nam, sex FROM athlete_events; -- INSERT 0 127575
INSERT INTO event(event, sport) SELECT DISTINCT event, sport FROM athlete_events; -- INSERT 0 572
INSERT INTO game(game, yer, season, city) SELECT DISTINCT game, yer, season, city FROM athlete_events; -- INSERT 0 46
INSERT INTO performance
SELECT p.id, e.id, G.id , n.noc , medal, age, weight, height
FROM athlete_events p , noc n , event e, game G
WHERE p.noc = n.noc
AND p.event = e.event AND p.sport = e.sport
AND G.game = p.game AND G.yer=p.yer AND G.season=p.season AND G.city=p.city;
-- INSERT 0 254731
-- Q2:
-- 1: 41500688
-- 2:
SELECT pg_total_relation_size('athlete_events') AS total_size_bytes; -- 8192 (same thing as typing \dt+ into the terminal)
DROP TABLE IF EXISTS tables CASCADE;
CREATE temp TABLE tables(name text);
INSERT INTO tables
VALUES('event'),('game'),('athlete'),('performance'),('noc'),('athlete_events');
SELECT pg_size_pretty(SUM(pg_total_relation_size(name))) FROM tables; -- 139264 Bytes or 136 kB
-- 3: