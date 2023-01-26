set serveroutput on;

declare
  c_alphabet constant varchar2(26 char) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
begin
  --AAAA ... AAAB ... ZZZZ
  for i1 in 1 .. length(c_alphabet) loop
    for i2 in 1 .. length(c_alphabet) loop
      for i3 in 1 .. length(c_alphabet) loop
        for i4 in 1 .. length(c_alphabet) loop
          insert into words(word) values(
            substr(c_alphabet, i1, 1) ||
            substr(c_alphabet, i2, 1) ||
            substr(c_alphabet, i3, 1) ||
            substr(c_alphabet, i4, 1) 
          ); 
        end loop;
      end loop;
    end loop;
  end loop;
end;
/
select count(id) from words;
select * from words;
truncate table words;