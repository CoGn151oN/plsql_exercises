--1
create table szobak2(
    szam number(3, 0) primary key check(szam > 100),
    emelet number(1, 0) not null check (emelet between 1 and 9),
    agyak_szama number(*, 0) default 1 not null, 
    ar number(25, 5) not null
);

--2 - getnext emelet
CREATE OR REPLACE FUNCTION SF_GET_EXT_ID2 
(
  P_EMELET_SZAM IN NUMBER 
) RETURN VARCHAR2 AS 
    v_key varchar2(10);
    v_szam number;
    v_t number;
BEGIN
    if P_EMELET_SZAM not between 1 and 9 then
        raise_application_error(-20001, 'Wrong arg for P_EMELET_SZAM param. Must be between 1-9.');
    end if;
    
    v_key := to_char(P_EMELET_SZAM) || '%';
    select max(szam)+1 into v_szam from szobak2 where szam like v_key;
    if v_szam is null then
        v_szam := p_emelet_szam * 100 + 1;
    end if;
    
    if v_szam > (p_emelet_szam*100 + 99) then
        raise_application_error(-20002, 'Incorrect number generated. Result would be greater than floor max.');
    end if;
    RETURN v_szam;
END SF_GET_EXT_ID2;

--3 - cursor -  avg, db
CREATE OR REPLACE PROCEDURE SP_SZOBA_FELDOLGOZ2 
(
  P_EMELET_SZAM IN NUMBER 
, P_DB OUT NUMBER 
, P_AVG OUT NUMBER 
) AS 
    cursor cur_szoba(param_emelet number) is select * from szobak2 where szobak2.emelet=param_emelet;
    r_szoba cur_szoba%rowtype;
    emelet_error exception;
    pragma exception_init(emelet_error, -20005);
    v_sum number;
BEGIN
    if p_emelet_szam not between 1 and 9 then
        raise emelet_error;
    end if;
    
    p_db := 0;
    p_avg := 0;
    
    open cur_szoba(p_emelet_szam);
    loop
        fetch cur_szoba into r_szoba;
        exit when cur_szoba%notfound;
        
        p_db := p_db + 1;
        p_avg := p_avg + r_szoba.ar;
        --dbms_output.put_line(p_avg);
    end loop;
    close cur_szoba;
    
    if p_db = 0 then
        raise emelet_error;
    end if;
    p_avg := p_avg / p_db;
exception
    when emelet_error then
        p_db := 0;
        p_avg := -1;
END SP_SZOBA_FELDOLGOZ2;

--4 - szobak trigger
CREATE OR REPLACE TRIGGER TR_SZOBA 
BEFORE INSERT OR UPDATE ON SZOBAK2 for each row
declare
    sajat_error exception;
    pragma exception_init(sajat_error, -20003);
BEGIN
    if updating then
        :new.szam := :old.szam;
        if :new.ar < 1 or :new.agyak_szama < 1 then
            raise sajat_error;
        end if;
    elsif inserting then
        :new.szam := SF_GET_EXT_ID2(:new.emelet);
                if :new.ar < 1 or :new.agyak_szama < 1 then
            raise sajat_error;
        end if;
    end if;
END;
