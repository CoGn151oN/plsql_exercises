/*
olyan eljaras ami veletlenszeruen general adatokat a hallgato tablan
nev attributumai:
veletlenszeruen vezetek es keresztnevbol
6 hosszu string
evf 1-2-3 szamokbol
szak: konstans -> nem foglalkozunk
DBMSrandom.string(milyen karakter legyen benne, milyen hosszu legyen) >> neptun kod
DBMSrandom.value(kezdo ertek, veg ertek) -> int     (balrol zart jobbrol nyilt)
*/


declare
    v_b varchar(12);
    v_n number;
    v_rand varchar(12);
begin
    loop
        v_rand := dbms_random.string('x', 6);
        
        select count(*) into v_n from hallgatok where neptun_kod = v_rand;
    exit when (v_n = 0);
    end loop;
    dbms_output.put_line(v_rand);
        
end;
/

declare
    --len vezeteknev/keresztnev
    v_len_vezeteknev NUMBER;
    v_len_keresztnev NUMBER;
    --random index vezeteknev/keresztnev
    v_rand_veznev NUMBER;
    v_rand_kereszt NUMBER;
    --str kivalasztott random vezeteknev/keresztnev
    v_vez rbann.vezeteknevek.vezeteknev%type;
    v_ker rbann.keresztnevek.keresztnev%type;
    --kepzes adatok megadasa (evfolyam szam indexe fogja kivalasztani)
    v_kepzes VARCHAR2(100 char);
    TYPE kepzesarray IS VARRAY(7) OF VARCHAR2(100);
    kepzesek kepzesarray;
    --evfolyam, neptun kod
    v_evfolyam NUMBER;
    v_b varchar(12);
    v_n number;
    v_rand varchar(12);
    v_neptun_kod varchar2(6);
    --while loop ind
    v_while NUMBER := 0;
begin
     --ertekadas: vezeteknev/keresztnev len
    select count(vezeteknev) into v_len_vezeteknev from rbann.vezeteknevek;
    select count(keresztnev) into v_len_keresztnev from rbann.keresztnevek;
    kepzesek := kepzesarray('Tanari', 'Informatika', 'Kozgaz', 'Gyogyszeresz', 'Mernoki', 'Vendeglatas', 'Boraszat');
    
    while v_while < 50
    loop
        --random index
        v_rand_veznev := floor(dbms_random.value(1, v_len_vezeteknev+1));
        v_rand_kereszt := floor(dbms_random.value(1, v_len_keresztnev+1));
        --vezeteknev ertekadas
        select vezeteknev into v_vez from (
            select rownum rn, vezeteknev from (
              select v.vezeteknev from rbann.vezeteknevek v order by v.gyakorisag, v.vezeteknev)
            )where rn=v_rand_veznev;
        --keresztnev ertekadas
        select keresztnev into v_ker from (
            select rownum rn, keresztnev from
            (select k.keresztnev from rbann.keresztnevek k order by k.gyakorisag, k.keresztnev)
            )where rn=v_rand_kereszt;
        --evfolyam ertekadas
        v_evfolyam := floor(dbms_random.value(1, 7));
        --kepzes ertekadas
        v_kepzes := kepzesek(v_evfolyam);
        --neptun kod ertekadas
        loop
            v_rand := dbms_random.string('x', 6);
            
            select count(*) into v_n from hallgatok where neptun_kod = v_rand;
        exit when (v_n = 0);
        end loop;
        v_neptun_kod := v_rand;
        --v_neptun_kod := to_char(v_while);
        
        INSERT INTO hallgatok(neptun_kod, nev, kepzes, evfolyam) VALUES (v_neptun_kod, v_vez || ' ' || v_ker, v_kepzes, v_evfolyam);
        v_while := v_while + 1;
    end loop;
end;
/
