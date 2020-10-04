SELECT version();
"PostgreSQL 13.0, compiled by Visual C++ build 1914, 64-bit"

----------------------------------------------------------------------------------------------------------------------------------
--Below are the queries from point 1 to 5. PostgreSQL 13.0 and pgadmin4 (Version 4.26)
----------------------------------------------------------------------------------------------------------------------------------

1) 
create table PERSON (
		     id    serial,    
  		     first_name VARCHAR ( 50 ),
   	            last_name   VARCHAR ( 50 ),
		    birth_date DATE,
        	    gender   VARCHAR ( 5 ),
		    salary    NUMERIC(10,2) check (salary > 0)    
	            );

----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

2)
insert into PERSON (first_name,last_name,birth_date,gender,salary) values ('John','Doe','01-JAN-2020','MALE',10000.50);
insert into PERSON (first_name,last_name,birth_date,gender,salary) values ('Mary','Jane','29-FEB-2020','FEMALE',5000.12);

commit;

----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

3) 

select * from person;

insert into person (first_name, last_name,birth_date, gender,salary)
select name_first , name_last, cast(bdate as DATE) , gender, sal
from
(
SELECT(
    SELECT SUBSTR(name_first,1, 50) as name_first --concat_ws(' ',name_first, name_last) as generated,
    FROM (
        SELECT string_agg(x,'')
        FROM (
            select start_arr[ 1 + ( (random() * 25)::int)  ]
            FROM
            (
                select '{Aiden,Cameron,Dion,Aiden,Anika,Ariya,Ashanti,Avery,Cameron,Ceri,
						Che,Danica,Darcy,Dion,Eman,Eren,Esme,Frankie,
						Gurdeep,Haiden,Indi,Isa,Jaskaran,Jaya,Jo,Jodie  
						Kacey,Kameron,Kayden,Keeley,Kenzie,Lucca,Macauley,
						Manraj,Nur,Oluwatobiloba,Reiss,Riley,Rima,Ronnie,Ryley,
						Sam,Sana,Shola,Sierra,Tamika,Taran,Teagan,Tia,Tiegan,Virginia,Zhane,Zion}'::text[] as start_arr
            ) syllarr,
            -- need 3 syllabes, and force generator interpretation with the '0' (else 3 same syllabes)
            generate_series(1, 3 + (generator*0))
        ) AS comp3syl(x)
    ) AS comp_name_1st(name_first)
    )
FROM generate_series(1,1000000) as generator
) as fname,
(
SELECT(
    SELECT SUBSTR(name_last,1, 50) as name_last--concat_ws(' ',name_first, name_last) as generated,
    FROM (
        SELECT string_agg(x,'')
        FROM (
            select start_arr[ 1 + ( (random() * 50)::int)  ]
            FROM
            (
                select '{Ahmad,Andersen,Arias,Barlow,Beck,Bloggs,Bowes,Buck,Burris,Cano,Chaney,Coombes,Correa,Coulson,Craig,Frye,Hackett,Hale,Huber,Hyde,Irving,Joyce,Kelley,Kim,Larson,Lynn,
			Markham,Mejia,Miranda,Neal,Newton,Novak,Ochoa,Pate,Paterson,Pennington,Rubio,Santana,Schaefer,Schofield,Shaffer,
Sweeney,Talley,Trevino,Tucker,Velazquez,Vu,Wagner,Walton,Woodward}'::text[] as start_arr
            ) syllarr,
            -- need 3 syllabes, and force generator interpretation with the '0' (else 3 same syllabes)
            generate_series(1, 3 + (generator*0))
        ) AS comp3syl(x)
    ) AS comp_name_1st(name_last)
    )
FROM generate_series(1,1000000) as generator
) as lname,
(
SELECT '01-JAN-1970'::date + s.a AS bdate FROM generate_series(0,1000000,1) AS s(a)
) as bdate,
(
SELECT CASE WHEN RANDOM() < 0.5 THEN 'male' ELSE 'female' END  as gender FROM generate_series(1, 1000000)
) as gender,
(
SELECT s.a AS sal FROM generate_series(1,1000000,1) AS s(a)
) as sal;

commit;

----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
4) 

Qry1:
-----
select * from person  where first_name = 'John' and last_name = 'Doe';
explain plan:
--------------
Seq Scan on person as person1 (rows=1 loops=1)
Filter: (((first_name)::text = 'John'::text) AND ((last_name)::text = 'Doe'::text))
Rows Removed by Filter: 1

Qry2:
-----
select * from person  where gender = 'FEMALE' and salary > 5000.50 
and birth_date > to_date(to_char(DATE(TO_TIMESTAMP(946684800)), 'YYYY-MM-DD'),'YYYY-MM-DD') and  birth_date < to_date(to_char(DATE(TO_TIMESTAMP(1609372800)), 'YYYY-MM-DD'),'YYYY-MM-DD')

explain plan:
------------
Seq Scan on person1 as person1 (rows=0 loops=1)
Filter: ((salary > 5000.50) AND ((gender)::text = 'FEMALE'::text) AND (birth_date > to_date(to_char((date('2000-01-01 08:00:00+08'::timestamp with time zone))::timestamp with time zone, 'YYYY-MM-DD'::text), 'YYYY-MM-DD'::text)) AND (birth_date < to_date(to_char((date('2020-12-31 08:00:00+08'::timestamp with time zone))::timestamp with time zone, 'YYYY-MM-DD'::text), 'YYYY-MM-DD'::text)))
Rows Removed by Filter: 2
----------------------------------------------------------------------------------------------------------------------------------
CREATE INDEX idx_name1 ON person (first_name, last_name);
CREATE INDEX idx_gsb1 ON person (gender, salary, birth_date);
----------------------------------------------------------------------------------------------------------------------------------
Qry1 (post index creation):
---------------------------
Explanation: Explain Plan: It is using the index to scan the records from the table, rather than full table scan
a) 
Bitmap Heap Scan on person as person (rows=865 loops=1)
Recheck Cond: (((first_name)::text = 'John'::text) AND ((last_name)::text = 'Doe'::text))
Heap Blocks: exact=15
865	1		2.	Bitmap Index Scan using idx_name1 (rows=865 loops=1)
Index Cond: (((first_name)::text = 'John'::text) AND ((last_name)::text = 'Doe'::text))

b) Bitmap Heap Scan	1	
   Bitmap Index Scan    1


Qry2 (post index creation):
---------------------------
explanation: Explain Plan: It is using the index to scan the records from the table, rather than full table scan

a) 
1.	Bitmap Heap Scan on person as person (rows=0 loops=1)
Recheck Cond: (((gender)::text = 'FEMALE'::text) AND (salary > 5000.50) AND (birth_date > to_date(to_char((date('2000-01-01 08:00:00+08'::timestamp with time zone))::timestamp with time zone, 'YYYY-MM-DD'::text), 'YYYY-MM-DD'::text)) AND (birth_date < to_date(to_char((date('2020-12-31 08:00:00+08'::timestamp with time zone))::timestamp with time zone, 'YYYY-MM-DD'::text), 'YYYY-MM-DD'::text)))
Heap Blocks: exact=0
0	1		2.	Bitmap Index Scan using idx_gsb1 (rows=0 loops=1)
Index Cond: (((gender)::text = 'FEMALE'::text) AND (salary > 5000.50) AND (birth_date > to_date(to_char((date('2000-01-01 08:00:00+08'::timestamp with time zone))::timestamp with time zone, 'YYYY-MM-DD'::text), 'YYYY-MM-DD'::text)) AND (birth_date < to_date(to_char((date('2020-12-31 08:00:00+08'::timestamp with time zone))::timestamp with time zone, 'YYYY-MM-DD'::text), 'YYYY-MM-DD'::text)))

b) Bitmap Heap Scan	1	
   Bitmap Index Scan	1

--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------

5) As we can see from 4th Point, both qry1 and qry2 uses full table scan to check each reacords sequentially, thus taking lot of time scanning through all the records and then
   retreiving the result set.
   Post index creation on the predicate(filter columns) both the queries qry1 and qry2 utilises these index to scan through the revelant records and show the required output. Internally the    each leaf block (from oracle) is scanned which has the address potining to the next node or value for the table. Thus making the table scan more efficient and giving faster result data.

--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------

