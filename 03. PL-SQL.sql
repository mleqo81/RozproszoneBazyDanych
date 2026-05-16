SET SERVEROUTPUT ON;

-- Zadanie 1
DECLARE
    liczba_kursantow number;
    liczba_kursow number;
    liczba_wykladowcow number;
BEGIN
    select count(*) into liczba_kursantow from kursanci;
    select count(*) into liczba_kursow from kursy;
    select count(*) into liczba_wykladowcow from wykladowcy;

    dbms_output.put_line('Liczba kursantow: ' || liczba_kursantow);
    dbms_output.put_line('Liczba kursow: ' || liczba_kursow);
    dbms_output.put_line('Liczba wykladowcow: ' || liczba_wykladowcow);
END;
/

-- Zadanie 2
DECLARE
    suma number;
BEGIN
    select sum(r.cena) into suma
    from umowy u, kursy k, rodzaje r
    where u.kurs_id = k.kurs_id
    and k.rodzaj_id = r.rodzaj_id;

    dbms_output.put_line('Laczna wartosc umow dla BYDGOSZCZY: ' || suma || ' zl');
END;
/

-- Zadanie 3
DECLARE
    miasto varchar2(30);
    liczba number;
BEGIN
    miasto := 'BYDGOSZCZ';

    select count(*) into liczba
    from umowy;

    if liczba = 0 then
        dbms_output.put_line('Brak umow dla miasta');
    elsif liczba < 50 then
        dbms_output.put_line('Mala liczba umow');
    elsif liczba <= 100 then
        dbms_output.put_line('Srednia liczba umow');
    else
        dbms_output.put_line('Duza liczba umow');
    end if;
END;
/

-- Zadanie 4
BEGIN
    for r in (
        select k.kurs_id, ro.nazwa, ro.godz, ro.cena, w.imie, w.nazwisko
        from kursy k, rodzaje ro, wykladowcy w
        where k.rodzaj_id = ro.rodzaj_id
        and k.wykladowca_id = w.wykladowca_id
    )
    loop
        dbms_output.put_line('Kurs ' || r.kurs_id || ': ' || r.nazwa || ', ' || r.godz || 'h, ' || r.cena || ' zl, prowadzacy: ' || r.imie || ' ' || r.nazwisko);
    end loop;
END;
/

-- Zadanie 5
create or replace procedure raport_umow_miasto(p_miasto in varchar2)
is
    liczba number;
    suma number;
    srednia number;
begin
    select count(*), sum(r.cena), avg(r.cena)
    into liczba, suma, srednia
    from umowy u, kursy k, rodzaje r
    where u.kurs_id = k.kurs_id
    and k.rodzaj_id = r.rodzaj_id;

    dbms_output.put_line('Raport dla miasta: ' || p_miasto);
    dbms_output.put_line('Liczba umow: ' || liczba);
    dbms_output.put_line('Laczna wartosc umow: ' || suma || ' zl');
    dbms_output.put_line('Srednia wartosc umowy: ' || round(srednia, 2) || ' zl');
end;
/

begin
    raport_umow_miasto('BYDGOSZCZ');
end;
/

-- Zadanie 6
create or replace function wartosc_kursu(p_kurs_id in number)
return number
is
    cena number;
begin
    select r.cena into cena
    from kursy k, rodzaje r
    where k.rodzaj_id = r.rodzaj_id
    and k.kurs_id = p_kurs_id;

    return cena;
end;
/

declare
    cena number;
begin
    cena := wartosc_kursu(1);
    dbms_output.put_line('Cena kursu: ' || cena);
end;
/

-- Zadanie 7
create or replace procedure pokaz_kursanta(p_kursant_id in number)
is
    imie_kursanta varchar2(20);
    nazwisko_kursanta varchar2(30);
begin
    select imie, nazwisko into imie_kursanta, nazwisko_kursanta
    from kursanci
    where kursant_id = p_kursant_id;

    dbms_output.put_line('Kursant: ' || imie_kursanta || ' ' || nazwisko_kursanta);
exception
    when no_data_found then
        dbms_output.put_line('Nie znaleziono kursanta o ID: ' || p_kursant_id);
end;
/

begin
    pokaz_kursanta(1000);
end;
/

-- Zadanie 8
declare
    cursor c_umowy is
        select u.umowa_id, k2.imie, k2.nazwisko, r.nazwa, r.cena
        from umowy u, kursanci k2, kursy k, rodzaje r
        where u.kursant_id = k2.kursant_id
        and u.kurs_id = k.kurs_id
        and k.rodzaj_id = r.rodzaj_id;

    umowa_id umowy.umowa_id%type;
    imie kursanci.imie%type;
    nazwisko kursanci.nazwisko%type;
    nazwa rodzaje.nazwa%type;
    cena rodzaje.cena%type;
begin
    open c_umowy;
    loop
        fetch c_umowy into umowa_id, imie, nazwisko, nazwa, cena;
        exit when c_umowy%notfound;

        dbms_output.put_line('Umowa ' || umowa_id || ' | ' || imie || ' ' || nazwisko || ' | ' || nazwa || ' | ' || cena || ' zl');
    end loop;
    close c_umowy;
end;
/

-- Zadanie 9
create or replace procedure raport_umow_szczecin
is
    cursor c_szczecin is
        select u.umowa_id, mk.imie, mk.nazwisko, mr.nazwa, mr.cena
        from umowy u, mv_kursanci_filia mk, mv_kursy_filia k, mv_rodzaje_filia mr
        where u.kursant_id = mk.kursant_id
        and u.kurs_id = k.kurs_id
        and k.rodzaj_id = mr.rodzaj_id;

    umowa_id umowy.umowa_id%type;
    imie varchar2(20);
    nazwisko varchar2(30);
    nazwa varchar2(30);
    cena number;
begin
    open c_szczecin;
    loop
        fetch c_szczecin into umowa_id, imie, nazwisko, nazwa, cena;
        exit when c_szczecin%notfound;

        dbms_output.put_line('Umowa ' || umowa_id || ' | ' || imie || ' ' || nazwisko || ' | ' || nazwa || ' | ' || cena || ' zl | SZCZECIN');
    end loop;
    close c_szczecin;
end;
/

begin
    raport_umow_szczecin;
end;
/

-- Zadanie 10
create or replace procedure raport_uczelni
is
    bydgoszcz_liczba number;
    bydgoszcz_suma number;
    bydgoszcz_najdrozszy varchar2(30);
    bydgoszcz_najpop varchar2(30);

    szczecin_liczba number;
    szczecin_suma number;
    szczecin_najdrozszy varchar2(30);
    szczecin_najpop varchar2(30);
begin
    select count(*), sum(r.cena)
    into bydgoszcz_liczba, bydgoszcz_suma
    from umowy u, kursy k, rodzaje r
    where u.kurs_id = k.kurs_id
    and k.rodzaj_id = r.rodzaj_id;

    select r.nazwa into bydgoszcz_najdrozszy
    from rodzaje r
    where r.cena = (select max(cena) from rodzaje)
    and rownum = 1;

    select r.nazwa into bydgoszcz_najpop
    from rodzaje r, kursy k
    where k.rodzaj_id = r.rodzaj_id
    and k.kurs_id = (
        select kurs_id from (
            select kurs_id, count(*) ile
            from umowy
            group by kurs_id
            order by ile desc
        ) where rownum = 1
    );

    select count(*), sum(mr.cena)
    into szczecin_liczba, szczecin_suma
    from umowy u, mv_kursy_filia k, mv_rodzaje_filia mr
    where u.kurs_id = k.kurs_id
    and k.rodzaj_id = mr.rodzaj_id;

    select nazwa into szczecin_najdrozszy
    from mv_rodzaje_filia
    where cena = (select max(cena) from mv_rodzaje_filia)
    and rownum = 1;

    select mr.nazwa into szczecin_najpop
    from mv_rodzaje_filia mr, mv_kursy_filia k
    where k.rodzaj_id = mr.rodzaj_id
    and k.kurs_id = (
        select kurs_id from (
            select kurs_id, count(*) ile
            from umowy
            group by kurs_id
            order by ile desc
        ) where rownum = 1
    );

    dbms_output.put_line('RAPORT UCZELNI');
    dbms_output.put_line('');
    dbms_output.put_line('Miasto: BYDGOSZCZ');
    dbms_output.put_line('Liczba umow: ' || bydgoszcz_liczba);
    dbms_output.put_line('Laczna wartosc umow: ' || bydgoszcz_suma || ' zl');
    dbms_output.put_line('Najdrozszy kurs: ' || bydgoszcz_najdrozszy);
    dbms_output.put_line('Najpopularniejszy kurs: ' || bydgoszcz_najpop);
    dbms_output.put_line('');
    dbms_output.put_line('Miasto: SZCZECIN');
    dbms_output.put_line('Liczba umow: ' || szczecin_liczba);
    dbms_output.put_line('Laczna wartosc umow: ' || szczecin_suma || ' zl');
    dbms_output.put_line('Najdrozszy kurs: ' || szczecin_najdrozszy);
    dbms_output.put_line('Najpopularniejszy kurs: ' || szczecin_najpop);
    dbms_output.put_line('');
    dbms_output.put_line('PODSUMOWANIE');
    dbms_output.put_line('Liczba wszystkich umow: ' || (bydgoszcz_liczba + szczecin_liczba));
    dbms_output.put_line('Laczna wartosc wszystkich umow: ' || (bydgoszcz_suma + szczecin_suma) || ' zl');
end;
/

begin
    raport_uczelni;
end;
/
