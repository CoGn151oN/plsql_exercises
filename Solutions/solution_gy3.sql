--1
create table dolgozok3(
    id char(4) primary key,
    nev varchar2(250) not null,
    nem char(1) not null check(nem in('F', 'N')),
    fizetes integer not null,
    letrehozva date not null
);

--2 - Tarolt fv
CREATE OR REPLACE FUNCTION GETNEXT3 
(
  P_NEM IN CHAR 
, V_NEXT_ID OUT VARCHAR2 
) RETURN VARCHAR2 AS 
    v_cnt int;
BEGIN
    select count(id)+1 into v_cnt from dolgozok3 where nem=p_nem;
    v_next_id := upper(p_nem) || '-' || rpad(v_cnt, 2, 0); 
      
    RETURN v_next_id;
END GETNEXT3;

--3 - Eljaras -> don’t need to declare w variable, just cal
CREATE OR REPLACE PROCEDURE ATLAGBER 
(
  P_NEM IN CHAR 
, V_ATLAGBER OUT NUMBER 
) authid definer AS 
    cursor cur_avg is select fizetes from dolgozok3 where nem=upper(p_nem);
    r_fizu number;
    v_db number;
    v_sum number;
    nem_error exception;
    pragma exception_init(nem_error, -20001);
BEGIN
    if P_NEM is null OR upper(p_nem) not in ('F', 'N') then
        raise nem_error;
    end if;

    v_db := 0;
    v_sum := 0;
    
    open cur_avg;
    loop
        fetch cur_avg into r_fizu;
        exit when cur_avg%notfound;
        v_db := v_db + 1;
        v_sum := v_sum + r_fizu;
    end loop;   
    close cur_avg;
    
    v_atlagber := v_sum / v_db;
exception
    when nem_error then
        v_atlagber := -1;
END ATLAGBER;

--4 - trigger
CREATE OR REPLACE TRIGGER DOLGOZOK3 
BEFORE INSERT ON DOLGOZOK3 for each row
BEGIN
    if :old.nem not in ('F', 'N') then
        raise_application_error(-20005, 'Nem can only be F or N');
    end if;
    :new.id := getnext3(:new.nem, :new.id);
    :new.letrehozva := sysdate;
END;
