--2 - Prime + authid definer as
--Prime
create or replace FUNCTION PRIME(n NUMBER) RETURN BOOLEAN AS 			
    i number;		
    temp number;
    res boolean;
BEGIN				
    i := 2;
    temp := 1;
    
    for i in 2..n/2 loop
        if mod(n, i) = 0 then
            temp := 0;
            exit;
        end if;
    end loop;  
    if temp = 1
    then
        res := true;
        dbms_output.put_line('true');
    else
        res := false;
        dbms_output.put_line('false');
    end if;		

    RETURN res;
END PRIME;

--2
GET_DOLGOZOK_NEXT_ID
CREATE OR REPLACE FUNCTION GET_DOLGOZOK_NEXT_ID RETURN NUMBER authid definer AS 
    var_tmp number;
    v_i number;
    is_null_error exception;
    pragma exception_init(is_null_error, -20001);
BEGIN
    select max(id) into var_tmp from dolgozok;
    
    if var_tmp is null then     
        raise is_null_error;   
    end if;
    
    loop
        var_tmp := var_tmp + 1;
        exit when prime(var_tmp);
    end loop;
  
    dbms_output.put_line('Returning: ' || var_tmp);
    return var_tmp;
exception
    when is_null_error then
        var_tmp := 2;
        dbms_output.put_line('Returning: ' || var_tmp);
        return var_tmp;
END GET_DOLGOZOK_NEXT_ID;

--3 - Procedure SP_FIZU_EMEL - curzor
CREATE OR REPLACE PROCEDURE SP_FIZU_EMEL 
(
  P_EV IN INTEGER 
, P_OSSZES_EMELES OUT NUMBER 
, P_EMELES_DB OUT NUMBER 
) AS 
    cursor cur_dolgozo(belepesi_ev integer) is 
        select * from dolgozok 
            where extract(year from belepes_ideje)=belepesi_ev 
            order by belepes_ideje;
    r_dolgozo cur_dolgozo%rowtype;    
BEGIN
    P_OSSZES_EMELES := 0;
    P_EMELES_DB := 0;
    open cur_dolgozo(P_EV);
  
    loop
    fetch cur_dolgozo into r_dolgozo;
    exit when cur_dolgozo%notfound;
    
    if P_EMELES_DB = 0 then
        update dolgozok set fizetes=r_dolgozo.fizetes * 1.1 where id=r_dolgozo.id;
        P_EMELES_DB := P_EMELES_DB + 1;
        P_OSSZES_EMELES := P_OSSZES_EMELES + r_dolgozo.fizetes * 0.1;
    else
        update dolgozok set fizetes=fizetes+P_OSSZES_EMELES*0.1 where id=r_dolgozo.id;
        P_EMELES_DB := P_EMELES_DB + 1;
        P_OSSZES_EMELES := P_OSSZES_EMELES + P_OSSZES_EMELES*0.1;
    end if;  
    end loop;
  
    close cur_dolgozo;
    commit;
END SP_FIZU_EMEL;

--4 - Udate/Insert Before Trigger
CREATE OR REPLACE TRIGGER TR_DOLGOZOK 
BEFORE UPDATE OR INSERT ON DOLGOZOK FOR EACH ROW
DECLARE
    v_email dolgozok.email%type;
    v_count number;
    enumerate varchar2(250);
    email_error exception;
    pragma exception_init(email_error, -20002);
BEGIN
    if inserting then
        :new.letrehozva := sysdate;
        :new.id := get_dolgozok_next_id;
           
        v_email := convert(substr(:new.nev, 1, 4), 'US7ASCII') || '@ceg.hu';     
        enumerate := substr(v_email, 1, 4)||'_@ceg.hu';
        select count(id) into v_count from dolgozok where email like enumerate;          
        if v_count = 0 THEN
            :new.email := v_email;
        else
            v_count := v_count + 1;
            :new.email := convert(substr(:new.nev, 1, 4), 'US7ASCII') || v_count || '@ceg.hu';
        end if;
        
    elsif updating then
        if :new.email <> :old.email then
            raise email_error;
        end if;
        
        :new.letrehozva := :old.letrehozva;
        :new.id := :old.id;    
    end if;
END;
