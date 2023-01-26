
create or replace trigger t1 before insert or update or delete on student 
for each row when (new.marks > 0)
declare
    marksdiff number;
begin
    marksdiff := :new.marks - :old.marks;
    dbms_output.put_line('old: ' || :old.marks);
    dbms_output.put_line('new: ' || :new.marks);
    dbms_output.put_line('diff: ' || :diff.marks);
end;
/
set serveroutput on;
update student set marks=96 where name='jenna';

create table hotel (
    guest_id varchar2(20) primary key,
    booking_date timestamp,
    name varchar2(50),
    room_no int
);




create or REPLACE trigger t_guest_insert after delete on hotel
--for each row when (old.name <> 'emma')
begin
    insert into hotel(guest_id, booking_date, name, room_no) values('user1', current_timestamp+1, 'jenna', 69);
end;
/

delete from hotel where name='robin';

insert into hotel(guest_id, booking_date, name, room_no) values('user1', current_timestamp+1, 'jenna', 69);






create or replace trigger t_booking_name after update on hotel
for each row when (old.booking_date <> null)
declare
    vn varchar2(25);
begin
    select name into vn from hotel where :new.booking_date > '2020-01-01';
    dbms_output.put_line(vn);
end;
/

update hotel set booking_date='2021-01-01' where name='robin';