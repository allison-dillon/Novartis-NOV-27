/*Attrition*/

%let first_yr= 2008;
%let last_yr= 2014;
%let pre_index= 3;
%let post_index= 5;
%let seq= 35;

%let first_yr= 2010;
%let last_yr= 2016;
%let pre_index= 5;
%let post_index= 3;
%let seq= 53;


* 1. Patients with at least one of the following during the identification period:
 - Coronary artery disease (CAD)
 - Atherosclerotic cerebrovascular disease (CVD)
 - Peripheral arterial disease (PAD)
 - Artery revascularization procedure
(the first diagnosis of CAD/CVD/PAD, or revascularization procedure is the index date)
 - Diabetes: For those who are diabetic but do not have CAD/CVD/PAD/artery revascularization
(the first diabetes diagnosis date is the index date);

%connDBPassThrough(dbname=heoji3, libname1=imp);
execute (drop table if exists heoji3.mace_04_dm_pre PURGE) by imp; 
execute	(create table heoji3.mace_04_dm_pre as
		SELECT distinct a.*
		FROM (SELECT distinct *, 'dm' as diag FROM mace_02_dm where year(to_date(svcdate)) between &first_yr. and &last_yr.) as a 
			left join (select distinct enrolid from mace_02_ascvd where year(to_date(svcdate)) between &first_yr. and &last_yr.) as b
		on a.enrolid=b.enrolid
		where b.enrolid is null
	) by imp;
quit;

%connDBPassThrough(dbname=heoji3, libname1=imp);
execute (drop table if exists heoji3.mace_04_att1 PURGE) by imp; 
execute	(create table heoji3.mace_04_att1 as
		SELECT enrolid, min(svcdate) as index_dt, 'ascvd' as diag
		FROM mace_02_ascvd
		where year(to_date(svcdate)) between &first_yr. and &last_yr.
		group by enrolid
		union
		SELECT enrolid, min(svcdate) as index_dt, diag
		FROM mace_04_dm_pre
		group by enrolid, diag
	) by imp;
quit;

* 2. Patients aged 50+ (men) or 55+ (women) at the index date (1: Male 2: Female);
%connDBPassThrough(dbname=heoji3, libname1=imp);
execute (drop table if exists heoji3.mace_04_att2 PURGE) by imp; 
execute	(create table heoji3.mace_04_att2 as
		select a.*, year(to_date(a.index_dt))-b.dobyr as age, b.sex, b.enroll_start, b.enroll_end
		from mace_04_att1 as a inner join mace_02_ascvd_enrol_fn as b
		on a.enrolid=b.enrolid and a.index_dt between b.enroll_start 
			and b.enroll_end and ((year(to_date(a.index_dt))-b.dobyr >= 50 and b.sex='1') or (year(to_date(a.index_dt))-b.dobyr >= 55 and b.sex='2'))
	) by imp;
quit;

* 3. Patients with continuous enrollment (records) in the database for at least 4-5 years after the index date;	
%connDBPassThrough(dbname=heoji3, libname1=imp);
execute (drop table if exists heoji3.mace_04_att3 PURGE) by imp; 
execute	(create table heoji3.mace_04_att3 as
		select distinct *
		from mace_04_att2
		where datediff(enroll_end,index_dt) >= (365*&post_index.)
	) by imp;
quit;

* 4. Patients with continuous enrollment (records) in the database for at least 2-3 years prior to the index date;
%connDBPassThrough(dbname=heoji3, libname1=imp);
execute (drop table if exists heoji3.mace_04_att4 PURGE) by imp; 
execute	(create table heoji3.mace_04_att4 as
		select distinct *
		from mace_04_att3
		where datediff(index_dt,enroll_start) >= (365*&pre_index.)
	) by imp;
quit;

* 5. Patients without MI or stroke any time prior to or at the index date;	
%connDBPassThrough(dbname=heoji3, libname1=imp);
execute (drop table if exists heoji3.mace_04_att5 PURGE) by imp; 
execute	(create table heoji3.mace_04_att5 as
		select distinct a.*
		from mace_04_att4 as a left join (select * from mace_02_mi_stroke where year(to_date(svcdate)) between 2005 and 2019) as b
		on a.enrolid=b.enrolid and datediff(b.svcdate,a.index_dt) <= 0
		where b.enrolid is null
	) by imp;
quit;

* For subgroup I, patients with at least one of the following any time during the study period
     a. Hypertension 
     b. Inflammatory disease diagnosis
  For subgroup II, patients with at least two of the following any time during the study period
     a. Hypertension
     b. Inflammatory disease diagnosis ;
%connDBPassThrough(dbname=heoji3, libname1=imp);
execute (drop table if exists heoji3.mace_04_cohort&seq. PURGE) by imp; 
execute	(create table heoji3.mace_04_cohort&seq. as
		select distinct a.*
			, case when b.enrolid is not null then 1 end as htn
			, case when c.enrolid is not null then 1 end as infl
		from mace_04_att5 as a 
			left join (select * from mace_02_htn where year(to_date(svcdate)) between 2005 and 2019) as b on a.enrolid=b.enrolid
			left join (select * from mace_02_infl where year(to_date(svcdate)) between 2005 and 2019) as c on a.enrolid=c.enrolid
	) by imp;
quit;

* attrition table;
%connDBPassThrough(dbname=heoji3,libname1=imp);
	select * from connection to imp
	(select 1 as cat, count(distinct enrolid) as pts from mace_04_att1 union
	select 2 as cat, count(distinct enrolid) as pts from mace_04_att2 union
	select 3 as cat, count(distinct enrolid) as pts from mace_04_att3 union
	select 4 as cat, count(distinct enrolid) as pts from mace_04_att4 union
	select 5 as cat, count(distinct enrolid) as pts from mace_04_att5 union
	select 6 as cat, count(distinct enrolid) as pts from mace_04_cohort&seq. union
	select 7 as cat, count(distinct enrolid) as pts from mace_04_cohort&seq. where htn=1 or infl=1 union
	select 8 as cat, count(distinct enrolid) as pts from mace_04_cohort&seq. where htn=1 and infl=1
	);
quit; 


* final cohort (two cohorts);
%countid2(mace_04_cohort35);
%countid2(mace_04_cohort53);















