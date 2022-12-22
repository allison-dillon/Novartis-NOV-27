/*Age distribution of the MarketScan population: 
	number for subjects with at least one day enrolled in 2019 of MarketScan (Commercial and Medicare supplemental) 
	by the following categories: 0-17, 18-34, 35-44, 45-54, 55-64, 65+.*/

%connDBPassThrough(dbname=heoji3, libname1=imp);
execute (drop table if exists heoji3.mace_08_age PURGE) by imp; 
execute(create table heoji3.mace_08_age as
		 select distinct enrolid, dtstart, dtend, dobyr, (2019-dobyr) as age 
	    , case when 0 <= (2019-dobyr) and (2019-dobyr) <= 17 then '0-17'
	      when 18 <= (2019-dobyr) and (2019-dobyr) <= 34 then '18-34'
	      when 35 <= (2019-dobyr) and (2019-dobyr) <= 44 then '35-44'
	      when 45 <= (2019-dobyr) and (2019-dobyr) <= 54 then '45-54'
	      when 55 <= (2019-dobyr) and (2019-dobyr) <= 64 then '55-64'
	      when 65 <= (2019-dobyr) then '65+'
	      end as agegrp
		FROM src_marketscan.ccae_mdcr_t 
		where year(dtstart) <= 2019 and year(dtend) >= 2019
/* 		where year=2019 */
	) by imp;
quit;
%output2(mace_08_age);

%connDBPassThrough(dbname=heoji3, libname1=imp); 
select * from connection to imp
	(select 'overall' as agegrp, count(distinct enrolid) as pts from mace_08_age
	union
	select agegrp, count(distinct enrolid) as pts from mace_08_age group by agegrp
	);
quit; 

%connDBPassThrough(dbname=heoji3, libname1=imp); 
select * from connection to imp
	(select min(dtstart) as min_dt, max(dtend) as max_dt from mace_08_age
	);
quit; 

%connDBPassThrough(dbname=heoji3, libname1=imp); 
select * from connection to imp
	(select avg(age) as mean_age, stddev(age) as sd_age from mace_08_age
	);
quit; 
