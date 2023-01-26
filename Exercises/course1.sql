set serveroutput on;
--jump between rows
select * from (select name from student where marks > 60 order by name offset 2 rows) fetch first 1 row only;

create or replace function std70 return student.name%type
as
    v_name student.name%type;
begin
    select name into v_name from student where marks > 90;
    dbms_output.put_line(v_name);
    return v_name;
end std70;
/

create or replace function f2 return number
as
    i number;
begin
    select count(name) into i from student where marks > 50;
    return i;
end f2;
/

create or replace function av return number
as
    i number;
begin
    select avg(marks) into i from student;
    return i;
end av;
/
    
begin
    dbms_output.put_line(av);
end;
/