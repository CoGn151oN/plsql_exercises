select * from jelenlet;

truncate table jelenlet;

CREATE OR REPLACE PROCEDURE eljaras (v_hallgato_kod IN VARCHAR2) AS
BEGIN
    INSERT INTO jelenlet (tanora_id, hallgato_kod) VALUES (
        (SELECT t.id from hallgato_x_kurzus h
            JOIN kurzus k ON h.kurzus_id = k.id
            JOIN tanora t ON t.kurzus_id = k.id
            WHERE 
                systimestamp BETWEEN t.start_at AND t.end_at
                AND
                h.hallgato_kod = UPPER(v_hallgato_kod)),
        v_hallgato_kod
    );
END eljaras;
/

begin
    eljaras('abcd');
end;
/

select t.id from hallgato_x_kurzus h
    join kurzus k on h.kurzus_id = k.id
    join tanora t on t.kurzus_id = k.id
    where 
        systimestamp between t.start_at and t.end_at
        and
        h.hallgato_kod = 'abcd';
    

--megadja tanora id-t
select id
    from tanora
    where systimestamp between start_at and end_at;


SELECT tanora.id FROM tanora
            INNER JOIN hallgato_x_kurzus ON tanora.kurzus_id = hallgato_x_kurzus.kurzus_id
            WHERE hallgato_x_kurzus.hallgato_kod = 'abcd';
