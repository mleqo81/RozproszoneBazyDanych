-- Database link
CREATE DATABASE LINK dblinkFilia
  CONNECT TO RBD2_ST5
  IDENTIFIED BY start123
  USING 'baza11b';

-- Test połączenia
SELECT * FROM kursanci@dblinkFilia;


-- 5. Synonimy
CREATE SYNONYM wykladowcySiedziba FOR wykladowcy;
CREATE SYNONYM wykladowcyFilia FOR wykladowcy@dblinkFilia;
 
CREATE SYNONYM kursanciSiedziba FOR kursanci;
CREATE SYNONYM kursanciFilia FOR kursanci@dblinkFilia;
 
CREATE SYNONYM kursySiedziba FOR kursy;
CREATE SYNONYM kursyFilia FOR kursy@dblinkFilia;
 
CREATE SYNONYM rodzajeSiedziba FOR rodzaje;
CREATE SYNONYM rodzajeFilia FOR rodzaje@dblinkFilia;


-- 6. Widoki kursanciAll i wykladowcyAll
CREATE VIEW kursanciAll AS
  SELECT imie, nazwisko FROM kursanciSiedziba
  UNION
  SELECT imie, nazwisko FROM kursanciFilia;
 
CREATE VIEW wykladowcyAll AS
  SELECT imie, nazwisko FROM wykladowcySiedziba
  UNION
  SELECT imie, nazwisko FROM wykladowcyFilia;


-- 7. Widoki kursyAll
CREATE VIEW kursyAll AS
  SELECT k.nazwa,
         w.imie || ' ' || w.nazwisko AS prowadzacy,
         (SELECT COUNT(*) FROM umowy u WHERE u.id_kursu = k.id_kursu) AS uczestnicy
  FROM kursySiedziba k
  JOIN wykladowcySiedziba w ON k.id_wykladowcy = w.id_wykladowcy
  UNION
  SELECT k.nazwa,
         w.imie || ' ' || w.nazwisko AS prowadzacy,
         (SELECT COUNT(*) FROM umowy u WHERE u.id_kursu = k.id_kursu) AS uczestnicy
  FROM kursyFilia k
  JOIN wykladowcyFilia w ON k.id_wykladowcy = w.id_wykladowcy;


-- 8. Przychody
SELECT SUM(u.oplata) AS przychod
FROM umowy u
WHERE u.id_kursu IN (SELECT id_kursu FROM kursySiedziba)
   OR u.id_kursu IN (SELECT id_kursu FROM kursyFilia);


-- 9. Koszty
SELECT SUM(k.stawka * k.liczba_godzin) AS koszty
FROM (
  SELECT w.stawka, k.liczba_godzin
  FROM kursySiedziba k JOIN wykladowcySiedziba w ON k.id_wykladowcy = w.id_wykladowcy
  UNION ALL
  SELECT w.stawka, k.liczba_godzin
  FROM kursyFilia k JOIN wykladowcyFilia w ON k.id_wykladowcy = w.id_wykladowcy
) k;


-- 10. Zysk dla każdego kursu
SELECT k.nazwa,
       NVL(przychody.suma, 0) - NVL(koszty.koszt, 0) AS zysk
FROM (
  SELECT id_kursu, nazwa FROM kursySiedziba
  UNION ALL
  SELECT id_kursu, nazwa FROM kursyFilia
) k
LEFT JOIN (
  SELECT id_kursu, SUM(oplata) AS suma
  FROM umowy
  GROUP BY id_kursu
) przychody ON k.id_kursu = przychody.id_kursu
LEFT JOIN (
  SELECT k2.id_kursu, w.stawka * k2.liczba_godzin AS koszt
  FROM kursySiedziba k2 JOIN wykladowcySiedziba w ON k2.id_wykladowcy = w.id_wykladowcy
  UNION ALL
  SELECT k2.id_kursu, w.stawka * k2.liczba_godzin AS koszt
  FROM kursyFilia k2 JOIN wykladowcyFilia w ON k2.id_wykladowcy = w.id_wykladowcy
) koszty ON k.id_kursu = koszty.id_kursu;


-- 11. Łączny zysk
SELECT SUM(NVL(przychody.suma, 0) - NVL(koszty.koszt, 0)) AS laczny_zysk
FROM (
  SELECT id_kursu FROM kursySiedziba
  UNION ALL
  SELECT id_kursu FROM kursyFilia
) k
LEFT JOIN (
  SELECT id_kursu, SUM(oplata) AS suma
  FROM umowy
  GROUP BY id_kursu
) przychody ON k.id_kursu = przychody.id_kursu
LEFT JOIN (
  SELECT k2.id_kursu, w.stawka * k2.liczba_godzin AS koszt
  FROM kursySiedziba k2 JOIN wykladowcySiedziba w ON k2.id_wykladowcy = w.id_wykladowcy
  UNION ALL
  SELECT k2.id_kursu, w.stawka * k2.liczba_godzin AS koszt
  FROM kursyFilia k2 JOIN wykladowcyFilia w ON k2.id_wykladowcy = w.id_wykladowcy
) koszty ON k.id_kursu = koszty.id_kursu;



