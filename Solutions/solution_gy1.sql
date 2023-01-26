--1
create table konyvek(
    id integer primary key,
    szerzo varchar2(250 byte) not null,
    isbn char(10 byte) unique not null,
    tipus char(2 byte) default 'OF' not null check(tipus in ('ON', 'OF'))
);

--2 - get_next1 - next book id
CREATE OR REPLACE FUNCTION GET_NEXT1 RETURN NUMBER authid definer AS 
    v_nextID number;
    v_cnt number;
BEGIN
    select count(id) into v_cnt from konyvek;
    
    if v_cnt = 0 or v_cnt is null then
        v_nextid := 100000;
    else
        select min(id)-5 into v_nextid from konyvek;
    end if;
     
    RETURN v_nextid;
END GET_NEXT1;

--3 fv - check isbn
CREATE OR REPLACE FUNCTION CHECK_DATA1 
(
  P_ISBN IN VARCHAR2
) RETURN VARCHAR2 AS 
    v_sum number;
    v_ret number;
    v_isbn varchar2(10);
    v_check char;
BEGIN
    if length(p_isbn) <> 10 then
        raise_application_error(-20000, 'Wrong arg for isbn param in check_data1');
    end if;
    
    -- 10 9 8 7 6 5 4 3 2 1
    --                    x
    v_sum := 0;
    for i in reverse 2..10 loop
        v_sum := v_sum + substr(p_isbn, -i, 1) * i;
    end loop;
    
    v_ret := mod(v_sum, 11);
    if v_ret = 0 then
        v_check := '0';
    elsif v_ret = 1 then
        v_check := 'x';
    else
        v_check := to_char(11-v_ret);
    end if;
    
    v_isbn := substr(p_isbn, 1, 9) || v_check;
    RETURN v_isbn;
END CHECK_DATA1;

--4 - insert_data1 - fv
CREATE OR REPLACE PROCEDURE INSERT_DATA1 
(
  P_ID IN NUMBER 
, P_SZERZO IN VARCHAR2 
, P_ISBN IN VARCHAR2 
, P_TIPUS IN VARCHAR2 
, V_SOROK OUT NUMBER 
) AS 
    v_id number;
    v_isbn char(10);
BEGIN
    if P_ID is null then
        v_id := get_next1;
    else
        v_id := p_id;
    end if;
    
    V_ISBN := check_data1(p_isbn);
    
    if p_tipus not in ('ON', 'OF') then
        raise_application_error(-20002, 'Nem megfelelo tipus arg insert_data1 p_tipus parametereben');
    elsif P_SZERZO is null then
        raise_application_error(-20003, 'Szerzo nem lehet null');
    end if;
    
    insert into konyvek values (v_id, p_szerzo, v_isbn, p_tipus); 
    v_sorok := sql%rowcount;
END INSERT_DATA1;

--5 - update_data1 - Eljaras kurzor
CREATE OR REPLACE PROCEDURE UPDATE_DATA1 
(
  P_ID IN NUMBER 
, P_MIN_ID OUT NUMBER 
, P_MAX_ID OUT NUMBER 
, P_FRISSITES_DB OUT NUMBER 
) AS
    cursor cur_konyvek is select * from konyvek where id >= p_id order by id desc;
    r_konyv cur_konyvek%rowtype;
    v_cnt number;
    v_i number := 0;
BEGIN
    --max id-> len(where id valid in range)-1 * 5
    select ((count(id)-1)*5)+p_id into v_cnt from konyvek where id >= p_id;
    
    open cur_konyvek;
    loop
        fetch cur_konyvek into r_konyv;
        exit when cur_konyvek%notfound;
        
        if v_i = 0 then
            update konyvek set id=P_ID where konyvek.id=r_konyv.id;
            v_i := v_i + 1;
        else
            update konyvek set id=get_next1 where konyvek.id=r_konyv.id; 
            v_i := v_i + 1;
        end if;    
    end loop;
    close cur_konyvek;
    commit;
    
    select min(id) into P_min_id from konyvek;
    select max(id) into p_max_id from konyvek;
END UPDATE_DATA1;

--5 - helyesen kurzor
CREATE OR REPLACE PROCEDURE UPDATE_DATA11 
(
  P_ID IN NUMBER 
, P_FRISSITESEK OUT NUMBER 
, P_MIN OUT NUMBER 
, P_MAX OUT NUMBER 
) AS 
    cursor cur_konyv is select * from konyvek where id <> p_id order by id;
    r_konyv cur_konyv%rowtype;
    v_id number;
    v_id2 number;
BEGIN
    v_id := get_next11;
    v_id2 := v_id;
    --update konyvek set konyvek.id=v_id2 where konyvek.id=p_id;
    --dbms_output.put_line('a legkissebb id ez lesz: ' || v_id);
    
    open cur_konyv;
    loop
        fetch cur_konyv into r_konyv;
        exit when cur_konyv%notfound;
        
        v_id := v_id + 5;
        dbms_output.put_line('kov id: ' || v_id);
        update konyvek set konyvek.id=v_id where konyvek.id=r_konyv.id;
        --select id into v_id from konyvek where konyvek.id=r_konyv.id;
        --dbms_output.put_line('kov a sorban: ' || v_id);
        p_frissitesek := p_frissitesek + 1;
    end loop;
    close cur_konyv;
    
    update konyvek set konyvek.id=v_id2 where konyvek.id=p_id;
    dbms_output.put_line('a legkissebb id ez lesz: ' || v_id);
    
    commit;
    
    select min(id) into p_min from konyvek;
    select max(id) into p_min from konyvek;
    
END UPDATE_DATA11;
