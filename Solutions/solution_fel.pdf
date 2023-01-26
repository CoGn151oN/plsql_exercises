--1
create table tranzakciok(
    tranzakcio_id char(19) primary key,
    terhelt_szamla number(4, 0) not null,
    kedvezemenyezett_szamla number(4, 0) not null,
    osszeg number(10,0) not null check(osszeg > 0), --terhelt-/kedvezmenyezett+
    letrehozva timestamp(3) default current_timestamp not null,
    konyveles_napja date,
    statusz char(1) check(statusz in ('E', 'B', null)),
    constraint fk_terh_sz foreign key (terhelt_szamla) references ugyfelszamla(id),
    constraint fk_kedv_sz foreign key (kedvezemenyezett_szamla) references ugyfelszamla(id),
    constraint ch_azonos_sz check(terhelt_szamla <> kedvezemenyezett_szamla)    
);
commit;

--2
CREATE OR REPLACE FUNCTION GETNEXTID 
(
  P_UGYFSZ_AZON IN ugyfelszamla.id%type 
, P_ERTEKNAP IN DATE 
) RETURN tranzakciok.tranzakcio_id%type authid definer AS 
    v_ugyf_id char(4);
    v_erteknap char(8);
    v_cnt number;
    v_id_cnt number;
BEGIN
    --erteknap+sorszam
    if P_ERTEKNAP is null then
        v_erteknap := to_char(sysdate,'YYYYMMDD');
        select count(tranzakcio_id)+1 into v_cnt from tranzakciok where letrehozva=sysdate;
    else
        v_erteknap := to_char(P_ERTEKNAP,'YYYYMMDD');
        select count(tranzakcio_id)+1 into v_cnt from tranzakciok where letrehozva=P_ERTEKNAP;
    end if;
    
    if v_cnt > 99999 then
        raise_application_error(-20002, 'Reached tranzaction limit!');
    end if;
    
    --ugyfelszamla azonosito
    select count(id) into v_id_cnt from ugyfelszamla where id=P_UGYFSZ_AZON;
    if length(P_UGYFSZ_AZON) > 4 then
        raise_application_error(-20001, 'Id arg too long for designated param (>4 length)');
    elsif v_id_cnt = 0 then
        raise_application_error(-20003, 'Customer doesnt exist');
    else
        v_ugyf_id := lpad(P_UGYFSZ_AZON, 4, 0);
    end if;
    
    return v_erteknap || '-' || v_ugyf_id || '-' || lpad(v_cnt, 5, 0);
END GETNEXTID;

--3
create or replace TRIGGER tr_insert_trans 
BEFORE INSERT ON TRANZAKCIOK for each row
DECLARE
    v_date DATE;
    v_new DATE;
BEGIN
    v_date := TRUNC(:new.konyveles_napja);
    
    if inserting then
        IF TO_CHAR(v_date,'DY') IN ('SAT','SUN') THEN
            v_new := next_day(v_date, 'MONDAY');
            :new.konyveles_napja := v_new;
        END IF;
        
        :new.tranzakcio_id := getnextid(:new.terhelt_szamla, :new.konyveles_napja);
        :new.statusz := null;             
    end if;
END;

--4
create or replace PROCEDURE TRANZAKCIOVEGREHAJT 
(
  P_NAP IN DATE 
, P_HIBAKOD OUT INTEGER 
) AS 
    v_nap date;
    cursor cur_tranz(d date) is select * from tranzakciok 
        where letrehozva between 
            TO_DATE (to_char(d, 'YYYY-MM-DD')|| 'T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND 
            TO_DATE(to_char(d, 'YYYY-MM-DD')|| 'T23:59:59', 'YYYY-MM-DD"T"HH24:MI:SS') AND 
            statusz is null; 
    r_tranz cur_tranz%rowtype;
    v_cnt_terh number;
    v_cnt_kedv number;
    v_utalas_utan number;
BEGIN
    P_HIBAKOD := -1;

    if p_nap is null then
        v_nap := sysdate;
    else
        v_nap := p_nap;
    end if;

    open cur_tranz(P_NAP);
    loop
        fetch cur_tranz into r_tranz;
        exit when cur_tranz%notfound;
        dbms_output.put_line(r_tranz.tranzakcio_id);
        --inaktiv countok
        select count(*) into v_cnt_terh from ugyfelszamla 
            where id=r_tranz.terhelt_szamla and aktiv='I';
        dbms_output.put_line(v_cnt_terh);
        select count(*) into v_cnt_kedv from ugyfelszamla 
            where id=r_tranz.kedvezemenyezett_szamla and aktiv='I';
        dbms_output.put_line(v_cnt_kedv);
        --mi marad a terhelt szamlan utana
        select 
            (select egyenleg from ugyfelszamla where id=r_tranz.terhelt_szamla) 
            - osszeg into v_utalas_utan
            from tranzakciok where tranzakcio_id=r_tranz.tranzakcio_id;
        dbms_output.put_line(v_utalas_utan);
          
        --ha barmelyik szamla inaktiv vagy nincs eleg penz
        if v_cnt_terh > 0 or v_cnt_kedv > 0 or v_utalas_utan < 0 then
            update tranzakciok set statusz='E' 
                where tranzakciok.tranzakcio_id=r_tranz.tranzakcio_id;
            dbms_output.put_line('Expect 0');
        else
            update tranzakciok set statusz='B' 
                where tranzakciok.tranzakcio_id=r_tranz.tranzakcio_id;
            dbms_output.put_line('Expect update');
                
            update ugyfelszamla set egyenleg = egyenleg - r_tranz.osszeg 
                where id=r_tranz.terhelt_szamla;              
            update ugyfelszamla set egyenleg = egyenleg + r_tranz.osszeg
                where id=r_tranz.kedvezemenyezett_szamla;
        end if;     
    end loop;
    close cur_tranz;
    
    p_hibakod := sql%rowcount;
    
    commit;

END TRANZAKCIOVEGREHAJT;
