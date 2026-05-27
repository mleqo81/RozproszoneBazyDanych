SET SERVEROUTPUT ON;

-- Zadanie 1
DECLARE
liczba_kursantow NUMBER;
liczba_kursow NUMBER;
liczba_wykladowcow NUMBER;
BEGIN
SELECT COUNT(*) INTO liczba_kursantow FROM kursanci;
SELECT COUNT(*) INTO liczba_kursow FROM kursy;
SELECT COUNT(*) INTO liczba_wykladowcow FROM wykladowcy;

DBMS_OUTPUT.PUT_LINE('Liczba kursantow: ' || liczba_kursantow);
DBMS_OUTPUT.PUT_LINE('Liczba kursow: ' || liczba_kursow);
DBMS_OUTPUT.PUT_LINE('Liczba wykladowcow: ' || liczba_wykladowcow);
END;
/

-- Zadanie 2
DECLARE
suma NUMBER;
BEGIN
SELECT SUM(r.cena)
INTO suma
FROM umowy u,
kursy  k,
rodzaje r
WHERE u.kurs_id = k.kurs_id
AND k.rodzaj_id = r.rodzaj_id;

DBMS_OUTPUT.PUT_LINE('Laczna wartosc umow dla BYDGOSZCZY: ' || suma || ' zl');
END;
/

-- Zadanie 3
DECLARE
miasto VARCHAR2(30);
liczba NUMBER;
BEGIN
miasto := 'BYDGOSZCZ';

SELECT COUNT(*)
INTO liczba
FROM umowy;

IF liczba = 0 THEN
DBMS_OUTPUT.PUT_LINE('Brak umow dla miasta');
ELSIF liczba < 50 THEN
DBMS_OUTPUT.PUT_LINE('Mala liczba umow');
ELSIF liczba <= 100 THEN
DBMS_OUTPUT.PUT_LINE('Srednia liczba umow');
ELSE
DBMS_OUTPUT.PUT_LINE('Duza liczba umow');
END IF;
END;
/

-- Zadanie 4
BEGIN
FOR r IN (
SELECT k.kurs_id,
ro.nazwa,
ro.godz,
ro.cena,
w.imie,
w.nazwisko
FROM kursy      k,
rodzaje    ro,
wykladowcy w
WHERE k.rodzaj_id = ro.rodzaj_id
AND k.wykladowca_id = w.wykladowca_id
) LOOP
DBMS_OUTPUT.PUT_LINE(
'Kurs ' || r.kurs_id || ': ' || r.nazwa || ', '
|| r.godz || 'h, ' || r.cena || ' zl, prowadzacy: '
|| r.imie || ' ' || r.nazwisko
);
END LOOP;
END;
/

-- Zadanie 5
CREATE OR REPLACE PROCEDURE raport_umow_miasto (
p_miasto IN VARCHAR2
) IS
liczba NUMBER;
suma NUMBER;
srednia NUMBER;
BEGIN
SELECT COUNT(*),
SUM(r.cena),
AVG(r.cena)
INTO liczba,
suma,
srednia
FROM umowy   u,
kursy   k,
rodzaje r
WHERE u.kurs_id = k.kurs_id
AND k.rodzaj_id = r.rodzaj_id;

DBMS_OUTPUT.PUT_LINE('Raport dla miasta: ' || p_miasto);
DBMS_OUTPUT.PUT_LINE('Liczba umow: ' || liczba);
DBMS_OUTPUT.PUT_LINE('Laczna wartosc umow: ' || suma || ' zl');
DBMS_OUTPUT.PUT_LINE('Srednia wartosc umowy: ' || ROUND(srednia, 2) || ' zl');
END;
/

BEGIN
raport_umow_miasto('BYDGOSZCZ');
END;
/

-- Zadanie 6
CREATE OR REPLACE FUNCTION wartosc_kursu (
p_kurs_id IN NUMBER
) RETURN NUMBER IS
cena NUMBER;
BEGIN
SELECT r.cena
INTO cena
FROM kursy   k,
rodzaje r
WHERE k.rodzaj_id = r.rodzaj_id
AND k.kurs_id = p_kurs_id;

RETURN cena;
END;
/

DECLARE
cena NUMBER;
BEGIN
cena := wartosc_kursu(1);
DBMS_OUTPUT.PUT_LINE('Cena kursu: ' || cena);
END;
/

-- Zadanie 7
CREATE OR REPLACE PROCEDURE pokaz_kursanta (
p_kursant_id IN NUMBER
) IS
imie_kursanta     VARCHAR2(20);
nazwisko_kursanta VARCHAR2(30);
BEGIN
SELECT imie,
nazwisko
INTO imie_kursanta,
nazwisko_kursanta
FROM kursanci
WHERE kursant_id = p_kursant_id;

DBMS_OUTPUT.PUT_LINE('Kursant: ' || imie_kursanta || ' ' || nazwisko_kursanta);
EXCEPTION
WHEN NO_DATA_FOUND THEN
DBMS_OUTPUT.PUT_LINE('Nie znaleziono kursanta o ID: ' || p_kursant_id);
END;
/

BEGIN
pokaz_kursanta(1000);
END;
/

-- Zadanie 8
DECLARE
CURSOR c_umowy IS
SELECT u.umowa_id,
k2.imie,
k2.nazwisko,
r.nazwa,
r.cena
FROM umowy    u,
kursanci k2,
kursy    k,
rodzaje  r
WHERE u.kursant_id = k2.kursant_id
AND u.kurs_id = k.kurs_id
AND k.rodzaj_id = r.rodzaj_id;

umowa_id umowy.umowa_id%TYPE;
imie kursanci.imie%TYPE;
nazwisko kursanci.nazwisko%TYPE;
nazwa rodzaje.nazwa%TYPE;
cena rodzaje.cena%TYPE;
BEGIN
OPEN c_umowy;
LOOP
FETCH c_umowy INTO umowa_id, imie, nazwisko, nazwa, cena;
EXIT WHEN c_umowy%NOTFOUND;

DBMS_OUTPUT.PUT_LINE(
'Umowa ' || umowa_id || ' | ' || imie || ' ' || nazwisko
|| ' | ' || nazwa || ' | ' || cena || ' zl'
);
END LOOP;
CLOSE c_umowy;
END;
/

-- Zadanie 9
CREATE OR REPLACE PROCEDURE raport_umow_szczecin IS
CURSOR c_szczecin IS
SELECT u.umowa_id,
mk.imie,
mk.nazwisko,
mr.nazwa,
mr.cena
FROM umowy           u,
mv_kursanci_filia mk,
mv_kursy_filia    k,
mv_rodzaje_filia  mr
WHERE u.kursant_id = mk.kursant_id
AND u.kurs_id = k.kurs_id
AND k.rodzaj_id = mr.rodzaj_id;

umowa_id umowy.umowa_id%TYPE;
imie VARCHAR2(20);
nazwisko VARCHAR2(30);
nazwa VARCHAR2(30);
cena NUMBER;
BEGIN
OPEN c_szczecin;
LOOP
FETCH c_szczecin INTO umowa_id, imie, nazwisko, nazwa, cena;
EXIT WHEN c_szczecin%NOTFOUND;

DBMS_OUTPUT.PUT_LINE(
'Umowa ' || umowa_id || ' | ' || imie || ' ' || nazwisko
|| ' | ' || nazwa || ' | ' || cena || ' zl | SZCZECIN'
);
END LOOP;
CLOSE c_szczecin;
END;
/

BEGIN
raport_umow_szczecin;
END;
/

-- Zadanie 10
CREATE OR REPLACE PROCEDURE raport_uczelni IS
bydgoszcz_liczba NUMBER;
bydgoszcz_suma NUMBER;
bydgoszcz_najdrozszy VARCHAR2(30);
bydgoszcz_najpop VARCHAR2(30);

szczecin_liczba NUMBER;
szczecin_suma NUMBER;
szczecin_najdrozszy VARCHAR2(30);
szczecin_najpop VARCHAR2(30);
BEGIN
SELECT COUNT(*),
SUM(r.cena)
INTO bydgoszcz_liczba,
bydgoszcz_suma
FROM umowy   u,
kursy   k,
rodzaje r
WHERE u.kurs_id = k.kurs_id
AND k.rodzaj_id = r.rodzaj_id;

SELECT r.nazwa
INTO bydgoszcz_najdrozszy
FROM rodzaje r
WHERE r.cena = (
SELECT MAX(cena) FROM rodzaje
)
AND ROWNUM = 1;

SELECT r.nazwa
INTO bydgoszcz_najpop
FROM rodzaje r,
kursy   k
WHERE k.rodzaj_id = r.rodzaj_id
AND k.kurs_id = (
SELECT kurs_id
FROM (
SELECT kurs_id,
COUNT(*) ile
FROM umowy
GROUP BY kurs_id
ORDER BY ile DESC
)
WHERE ROWNUM = 1
);

SELECT COUNT(*),
SUM(mr.cena)
INTO szczecin_liczba,
szczecin_suma
FROM umowy           u,
mv_kursy_filia    k,
mv_rodzaje_filia  mr
WHERE u.kurs_id = k.kurs_id
AND k.rodzaj_id = mr.rodzaj_id;

SELECT nazwa
INTO szczecin_najdrozszy
FROM mv_rodzaje_filia
WHERE cena = (
SELECT MAX(cena) FROM mv_rodzaje_filia
)
AND ROWNUM = 1;

SELECT mr.nazwa
INTO szczecin_najpop
FROM mv_rodzaje_filia mr,
mv_kursy_filia   k
WHERE k.rodzaj_id = mr.rodzaj_id
AND k.kurs_id = (
SELECT kurs_id
FROM (
SELECT kurs_id,
COUNT(*) ile
FROM umowy
GROUP BY kurs_id
ORDER BY ile DESC
)
WHERE ROWNUM = 1
);

DBMS_OUTPUT.PUT_LINE('RAPORT UCZELNI');
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('Miasto: BYDGOSZCZ');
DBMS_OUTPUT.PUT_LINE('Liczba umow: ' || bydgoszcz_liczba);
DBMS_OUTPUT.PUT_LINE('Laczna wartosc umow: ' || bydgoszcz_suma || ' zl');
DBMS_OUTPUT.PUT_LINE('Najdrozszy kurs: ' || bydgoszcz_najdrozszy);
DBMS_OUTPUT.PUT_LINE('Najpopularniejszy kurs: ' || bydgoszcz_najpop);
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('Miasto: SZCZECIN');
DBMS_OUTPUT.PUT_LINE('Liczba umow: ' || szczecin_liczba);
DBMS_OUTPUT.PUT_LINE('Laczna wartosc umow: ' || szczecin_suma || ' zl');
DBMS_OUTPUT.PUT_LINE('Najdrozszy kurs: ' || szczecin_najdrozszy);
DBMS_OUTPUT.PUT_LINE('Najpopularniejszy kurs: ' || szczecin_najpop);
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('PODSUMOWANIE');
DBMS_OUTPUT.PUT_LINE('Liczba wszystkich umow: ' || ( bydgoszcz_liczba + szczecin_liczba ));
DBMS_OUTPUT.PUT_LINE('Laczna wartosc wszystkich umow: ' || ( bydgoszcz_suma + szczecin_suma ) || ' zl');
END;
/

BEGIN
raport_uczelni;
END;
/
