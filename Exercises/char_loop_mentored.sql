set serveroutput on;

declare 
  l_num number            := 3;
  l_str varchar2(4000);
  l_act_str varchar2(4000);
  l_end_str varchar2(4000);
  l_clear_after_ixd number := 0;
  
  -- next char
  l_nc char;
  
  l_total number := 1;
begin
  
  
  -- init
  for i in 1 .. l_num 
  loop
    l_str := l_str || 'a';
    l_end_str := l_end_str || 'z';
  end loop;
  
  dbms_output.put_line(l_str);

  -- do it while we reach the end of sequence
  while(l_str <> l_end_str)
  loop
  
    l_total := l_total + 1;
    
    for i in reverse 1 .. l_num
    loop
      
      if substr(l_str, i, 1) <> 'z' and l_num = i then        -- it is not at the max char, increase by 1
        l_nc := chr(ascii(substr(l_str, i, 1))+1);            -- get the next char
        l_str := regexp_replace(l_str, '.', l_nc, 1, i);      -- increase sequence
        dbms_output.put_line(l_str); 
        exit;                                                 -- restart for loop                                                   
      elsif substr(l_str, i, 1) <> 'z' and l_num <> i then
        l_nc := chr(ascii(substr(l_str, i, 1))+1);            -- get the next char
        l_str := regexp_replace(l_str, '.', l_nc, 1, i);      -- increase sequence 
        
        -- reset chars 
        l_str := regexp_replace(l_str,'.','a',i+1,0);
        dbms_output.put_line(l_str);
        exit;                                                 -- restart for loop
        
      end if;  
    end loop;
    
  end loop;


  dbms_output.put_line(l_str);
  
  dbms_output.put_line('Total: ' || l_total);
  --dbms_output.put_line(l_end_str);
end;
/
