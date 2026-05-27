-- Zadanie 1
-- baza11a
CREATE MATERIALIZED VIEW LOG ON kursanci
WITH PRIMARY KEY, ROWID
INCLUDING NEW VALUES;

-- baza11b
CREATE DATABASE LINK dblinkSiedziba
CONNECT TO RBD2_ST5
IDENTIFIED BY start123
USING 'baza11a';

CREATE MATERIALIZED VIEW REP_kursanci_siedziba
BUILD IMMEDIATE
REFRESH FAST ON DEMAND
AS
SELECT * FROM kursanci@dblinkSiedziba;


-- Zadanie 2
-- baza11a
CREATE MATERIALIZED VIEW REP_kursanci_local
BUILD IMMEDIATE
REFRESH FAST ON COMMIT
AS
SELECT * FROM kursanci;


-- Zadanie 3
-- baza11a
CREATE MATERIALIZED VIEW REP_przychod_kursow
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT
r.nazwa AS nazwa_kursu,
COUNT(u.umowa_id) AS liczba_uczestnikow,
COUNT(u.umowa_id) * r.cena AS przychod_brutto,
ROUND(COUNT(u.umowa_id) * r.cena * 0.19, 2) AS podatek_19
FROM kursy k
JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
JOIN umowy u ON k.kurs_id = u.kurs_id
GROUP BY r.nazwa, r.cena
UNION ALL
SELECT
r.nazwa,
COUNT(u.umowa_id),
COUNT(u.umowa_id) * r.cena,
ROUND(COUNT(u.umowa_id) * r.cena * 0.19, 2)
FROM kursy@dblinkFilia   k
JOIN rodzaje@dblinkFilia r ON k.rodzaj_id = r.rodzaj_id
JOIN umowy u ON k.kurs_id   = u.kurs_id
GROUP BY r.nazwa, r.cena;

-- Complete 1 - 
-- baza11a
CREATE MATERIALIZED VIEW REP_wykladowcy
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT * FROM wykladowcy@dblinkFilia;


-- Complete 2 
-- baza11b
INSERT INTO wykladowcy (wykladowca_id, imie, nazwisko, stawka)
VALUES (115, 'NOWA', 'WYKLADOWCA', 110);
COMMIT;


-- Complete 3 
-- baza11a 
SELECT * FROM REP_wykladowcy;


-- Complete 4 
-- baza11a
EXEC DBMS_MVIEW.REFRESH('REP_wykladowcy', 'C');


-- Complete 5 
-- baza11a
SELECT * FROM REP_wykladowcy;


-- Complete 6 
-- baza11a
CREATE MATERIALIZED VIEW REP_godz_wykladowcy_godziny
BUILD DEFERRED
REFRESH COMPLETE ON DEMAND
START WITH LAST_DAY(SYSDATE)
NEXT  LAST_DAY(SYSDATE) + 1/24
AS
SELECT
w.imie,
w.nazwisko,
SUM(r.godz) AS lacznie_godzin
FROM wykladowcy@dblinkFilia w
JOIN kursy@dblinkFilia k ON w.wykladowca_id = k.wykladowca_id
JOIN rodzaje@dblinkFilia r ON k.rodzaj_id = r.rodzaj_id
GROUP BY w.imie, w.nazwisko;


-- Complete 7 
-- baza11a
CREATE MATERIALIZED VIEW REP_kursy
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
START WITH SYSDATE
NEXT SYSDATE + 7
AS
SELECT
r.nazwa AS nazwa_kursu,
w.imie || ' ' || w.nazwisko AS prowadzacy,
r.godz AS liczba_godzin,
r.cena AS oplata
FROM kursy@dblinkFilia k
JOIN rodzaje@dblinkFilia r ON k.rodzaj_id = r.rodzaj_id
JOIN wykladowcy@dblinkFilia w ON k.wykladowca_id = w.wykladowca_id;


-- Complete 8 
-- baza11a
CREATE VIEW ALL_kursy AS
SELECT nazwa_kursu, prowadzacy, liczba_godzin, oplata
FROM REP_kursy
UNION ALL
SELECT
r.nazwa,
w.imie || ' ' || w.nazwisko,
r.godz,
r.cena
FROM kursy k
JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
JOIN wykladowcy w ON k.wykladowca_id = w.wykladowca_id;


-- Complete 9 
-- baza11a
SELECT mview_name, refresh_mode, refresh_method, last_refresh_date
FROM USER_MVIEWS;
