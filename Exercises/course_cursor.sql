set serveroutput on;
select * from inventory;
insert all
        into inventory(product_id, details, price, stock_status) values ('it001', 'iron rod', 121, 'out')
        into inventory(product_id, details, price, stock_status) values ('it002', 'steel bolts', 111, 'in')
        into inventory(product_id, details, price, stock_status) values ('it003', 'washer tar', 231, 'in')
        into inventory(product_id, details, price, stock_status) values ('it004', 'foam', 112, 'out')
select 1 from dual;

declare
    v_id inventory.product_id%type;
    v_details inventory.details%type;
    v_price inventory.price%type;
cursor c_inventory is select product_id, details, price from inventory where stock_status='out';
begin
open c_inventory;
    loop
        fetch c_inventory into v_id, v_details, v_price;
        exit when c_inventory%notfound;
        dbms_output.put_line(v_id || '   ' || v_details || '   ' || v_price);
    end loop;
close c_inventory;
end;
/


