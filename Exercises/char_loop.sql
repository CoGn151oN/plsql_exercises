/*
Iterate over each character in alphabet 
*/

set serveroutput on;

-- chr(65) : A
-- chr(90) : Z
declare
    v_n number := 5;
    v_str varchar(4000) := rpad(chr(65), v_n, chr(65)); 
begin  
    for i in 1..v_n
    loop
        for j in 65..90
        loop
            select regexp_replace(v_str,'[^,]',chr(j),i,1) into v_str from dual;
            dbms_output.put_line(v_str);
            --dbms_output.put_line(i || ' ' || j);
        end loop;
    end loop;
end;
/
