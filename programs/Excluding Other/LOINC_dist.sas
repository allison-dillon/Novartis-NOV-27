%macro demo_lab;
%let groups=overall;
		%do i=1 %to 1;
		%let ad = %scan(&groups., &i., *);
	%create(test_&ad.)
			select distinct q.*
			%do r=1 %to 16;
				%let lab = %scan(sys_bp*dia_bp*ldlc*vldlc*hdlc*tc*tg*lpa_mg*lpa_mol*apob*hba1c*alt*ast*alp*ck*cprot, &r., *);
				, case when w&r..patid is not null then w&r..fst_dt end as &lab._dt
				, case when w&r..patid is not null then w&r..rslt_nbr end as &lab.
				, case when w&r..patid is not null then w&r..RSLT_UNIT_NM end as &lab._unit
				, case when w&r..patid is not null then w&r..loinc_cd end as &lab.loinc_cd
			%end;
		from dingyig._01_cohort_6a q
			%do t=1 %to 16;
				%let lab = %scan(sys_bp*dia_bp*ldlc*vldlc*hdlc*tc*tg*lpa_mg*lpa_mol*apob*hba1c*alt*ast*alp*ck*cprot, &t., *);
				left join (select z.patid, z.grp, z.fst_dt, z.loinc_cd, z.RSLT_UNIT_NM, avg(z.rslt_nbr) as rslt_nbr
							from (select e.*, row_number() over (partition by e.patid, e.grp order by e.gap, e.fst_dt) as rn
								from (select a.patid, a.grp, b.fst_dt, b.loinc_cd, b.rslt_nbr, b.RSLT_UNIT_NM, abs(datediff(b.fst_dt,a.index_date_&ad.)) as gap
										from dingyig.ldlc_05_index_dx_&ad. as a inner join (select * from dingyig.ldlc_04_lab1 
																			where year(to_date(fst_dt)) >= 2007 and year(to_date(fst_dt)) <= 2019 and rslt_nbr > 0 and rslt_nbr < 9999) as b 
										on a.patid=b.patid and b.grp="&lab." and datediff(b.fst_dt,a.index_date_&ad.) between -365.25 and -1 ) as e							
								) as z
							where z.rn=1
							group by z.patid, z.grp, z.fst_dt,z.loinc_cd, z.RSLT_UNIT_NM) as w&t. on q.patid=w&t..patid and q.grp=w&t..grp
			%end;
			
	%create(test_&ad.);
	%end;
%mend demo_lab;
%demo_lab;

%select
	select top 100 *
	from 


%select
	select top 100 *
	from dingyig.test_overall
%select;

%select
	select cprotloinc_cd, cprot, upper(cprot_unit) as cprot_unit, count(patid) as pats
	from dingyig.test_overall
	where cprotloinc_cd is not null
	group by cprotloinc_cd,cprot, upper(cprot_unit)
%select;

%create(test_overall1)
	select patid, cprotloinc_cd, cprot, upper(cprot_unit) as cprot_unit
	from dingyig.test_overall
	where cprotloinc_cd is not null 
%create(test_overall1);


%connDBPassThrough(dbname=dingyig, libname1=imp);
	create table test_overall1 as select * from connection to imp
	(select * from test_overall1);
quit;


DATA TEST;
	SET test_overall1;
	label cprot="hsCRP (in mg/L)";
run;

title "hsCRP Distribution for Cohort 1";
proc univariate data=test;
   var cprot;
   histogram;
run;

/*cohort 2*/
%macro demo_lab;
%let groups=overall;
		%do i=1 %to 1;
		%let ad = %scan(&groups., &i., *);
	%create(test_&ad.)
			select distinct q.*
			%do r=1 %to 16;
				%let lab = %scan(sys_bp*dia_bp*ldlc*vldlc*hdlc*tc*tg*lpa_mg*lpa_mol*apob*hba1c*alt*ast*alp*ck*cprot, &r., *);
				, case when w&r..patid is not null then w&r..fst_dt end as &lab._dt
				, case when w&r..patid is not null then w&r..rslt_nbr end as &lab.
				, case when w&r..patid is not null then w&r..RSLT_UNIT_NM end as &lab._unit
				, case when w&r..patid is not null then w&r..loinc_cd end as &lab.loinc_cd
			%end;
		from dingyig._01_cohort_6b q
			%do t=1 %to 16;
				%let lab = %scan(sys_bp*dia_bp*ldlc*vldlc*hdlc*tc*tg*lpa_mg*lpa_mol*apob*hba1c*alt*ast*alp*ck*cprot, &t., *);
				left join (select z.patid, z.grp, z.fst_dt, z.loinc_cd, z.RSLT_UNIT_NM, avg(z.rslt_nbr) as rslt_nbr
							from (select e.*, row_number() over (partition by e.patid, e.grp order by e.gap, e.fst_dt) as rn
								from (select a.patid, a.grp, b.fst_dt, b.loinc_cd, b.rslt_nbr, b.RSLT_UNIT_NM, abs(datediff(b.fst_dt,a.index_date_&ad.)) as gap
										from dingyig._01_cohort_6b as a inner join (select * from dingyig.ldlc_04_lab1 
																			where year(to_date(fst_dt)) >= 2007 and year(to_date(fst_dt)) <= 2019 and rslt_nbr > 0 and rslt_nbr < 9999) as b 
										on a.patid=b.patid and b.grp="&lab." and datediff(b.fst_dt,a.index_date_&ad.) between -365.25 and -1 ) as e							
								) as z
							where z.rn=1
							group by z.patid, z.grp, z.fst_dt,z.loinc_cd, z.RSLT_UNIT_NM) as w&t. on q.patid=w&t..patid and q.grp=w&t..grp
			%end;
			
	%create(test_&ad.);
	%end;
%mend demo_lab;
%demo_lab;

%select
	select cprotloinc_cd, cprot, upper(cprot_unit) as cprot_unit, count(patid) as pats
	from dingyig.test_overall
	where cprotloinc_cd is not null
	group by cprotloinc_cd,cprot, upper(cprot_unit)
%select;

%create(test_overall1)
	select patid, cprotloinc_cd, cprot, upper(cprot_unit) as cprot_unit
	from dingyig.test_overall
	where cprotloinc_cd is not null 
%create(test_overall1);


%connDBPassThrough(dbname=dingyig, libname1=imp);
	create table test_overall1 as select * from connection to imp
	(select * from test_overall1);
quit;


DATA TEST;
	SET test_overall1;
	label cprot="hsCRP (in mg/L)";
run;

title "hsCRP Distribution for Cohort 2";
proc univariate data=test;
   var cprot;
   histogram;
run;
