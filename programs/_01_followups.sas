/*cohort 1*/
PROC SQL;
	CREATE TABLE cohort1 as 
	SELECT a.*
	FROM derived._05_demo1b_overall a
	;
quit;

/*cohort 2*/
PROC SQL;
	CREATE TABLE cohort2 as 
	SELECT a.*
	FROM derived._05_demo2b_overall a
	;
quit;

/*patients> 50*/

%macro main(cohort, lpa, lpa1, lpa2);
PROC SQL;
	SELECT 1, "N         ", COUNT(DISTINCT patid) as upats, count(patid) as pats FROM &cohort. where lpa>&lpa. and index_date_overall is not null
	UNION SELECT 2, "ASCVD", COUNT(DISTINCT patid) as upats, count(patid) as pats FROM &cohort. where lpa>&lpa. AND LPA>=&lpa1. AND LPA<=&lpa2. and index_date_overall is not null
	UNION SELECT  3, "MI/PAD/STROKE", COUNT(DISTINCT patid) as upats, count(patid) as pats FROM &cohort. where lpa>&lpa. AND LPA>=&lpa1. AND LPA<=&lpa2. and index_DATE_cvd is not null
	UNION SELECT 4, "MI", COUNT(DISTINCT patid) as upats, count(patid) as pats FROM &cohort. where lpa>&lpa. AND LPA>=&lpa1. AND LPA<=&lpa2. and index_date_MI is not null
	UNION SELECT 5, "PAD", COUNT(DISTINCT patid) as upats, count(patid) as pats FROM &cohort. where lpa>&lpa. AND LPA>=&lpa1. AND LPA<=&lpa2. and index_date_pad is not null
	UNION SELECT 6, "STROKE", COUNT(DISTINCT patid) as upats, count(patid) as pats FROM &cohort. where lpa>&lpa. AND LPA>=&lpa1. AND LPA<=&lpa2. and index_date_stroke is not null
	UNION SELECT 7, "post-revasc", COUNT(DISTINCT patid) as upats, count(patid) as pats FROM &cohort. where lpa>&lpa. AND LPA>=&lpa1. AND LPA<=&lpa2. and index_date_revasc is not null
	UNION SELECT 8, "Stable Angina", COUNT(DISTINCT patid) as upats, count(patid) as pats FROM &cohort. where lpa>&lpa. AND LPA>=&lpa1. AND LPA<=&lpa2. and index_date_sta_angina is not null
	UNION SELECT 9, "Unstable", COUNT(DISTINCT patid) as upats, count(patid) as pats FROM &cohort. where lpa>&lpa. AND LPA>=&lpa1. AND LPA<=&lpa2. and index_date_unsta_angina is not null
	UNION SELECT 10, "TIA", COUNT(DISTINCT patid) as upats, count(patid) as pats FROM &cohort. where lpa>&lpa. AND LPA>=&lpa1. AND LPA<=&lpa2. and index_date_tia is not null
	
	
	;
QUIT;
%mend;
%main(cohort1, 50, 50, 70);
%main(cohort1, 70, 70, 90);



%main(cohort2, 105, 105, 150);
%main(cohort2, 150, 150, 190);

/*Table 2*/
%macro main;
%do z=1 %to 2;
proc sql;
		create table cohort&z. as 
		select a.patid, a.index_date_overall, a.lpa, a.statins 
			,case when c.recent_ldlc <70 then '1' end as rslt_lt_70
			,case when c.recent_ldlc >=70 and recent_ldlc<=100 then '1' end as rslt_70_100
			,case when c.recent_ldlc>=100 and recent_ldlc<=130 then '1' end as rslt_100_130
			,case when c.recent_ldlc >130 then '1' end as rslt_gt_130
			,case when compress(index_unsta_angina)='1' or compress(index_sta_angina)='1' or compress(index_revasc)='1' or compress(index_tia)='1' then '1' end as index_noncvd
			,'1' as all 
		from derived._05_demo&z.b_overall a inner join derived.ldlc_06 c on a.patid=c.patid
		where a.index_date_overall is not null ;
		quit;
%end;
%mend;
%main;

/*puts two tables together*/
PROC SQL;
	CREATE TABLE cohorts AS
	SELECT a.*, "mg  " as lpa_type
	from cohort1 A
	UNION 
	SELECT a.*, "nmol" as lpa_type
	from cohort2 a
	;
QUIT;

%macro count( mg1, mg2, nmol1, nmol2);
PROC SQL; 
	SELECT 1, "rslt_lt_70", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE rslt_lt_70='1'
	UNION SELECT 2, "Lpa", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE ((lpa_type="mg" and lpa>=&mg1. and lpa<=&mg1.) or (lpa_type="nmol" and lpa>=&nmol1. and lpa<=&nmol2.))
	UNION SELECT 3, "N", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE rslt_lt_70='1' and  ((lpa_type="mg" and lpa>=&mg1. and lpa<=&mg1.) or (lpa_type="nmol" and lpa>=&nmol1. and lpa<=&nmol2.))
	UNION SELECT 4, "Statin", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE rslt_lt_70='1' and  ((lpa_type="mg" and lpa>=&mg1. and lpa<=&mg1.) or (lpa_type="nmol" and lpa>=&nmol1. and lpa<=&nmol2.)) and COMPRESS(statins)='1'
	UNION SELECT 5, "rslt_70_100", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE rslt_70_100='1'
	UNION SELECT 6, "N", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE rslt_70_100='1' and  ((lpa_type="mg" and lpa>=&mg1. and lpa<=&mg1.) or (lpa_type="nmol" and lpa>=&nmol1. and lpa<=&nmol2.))
	UNION SELECT 7, "Statin", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE rslt_70_100='1' and  ((lpa_type="mg" and lpa>=&mg1. and lpa<=&mg1.) or (lpa_type="nmol" and lpa>=&nmol1. and lpa<=&nmol2.)) and COMPRESS(statins)='1'
	UNION SELECT 8, "rslt_100_130", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE rslt_100_130='1'
	UNION SELECT 9, "N", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE rslt_100_130='1' and  ((lpa_type="mg" and lpa>=&mg1. and lpa<=&mg1.) or (lpa_type="nmol" and lpa>=&nmol1. and lpa<=&nmol2.))
	UNION SELECT 10, "Statin", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE rslt_100_130='1' and  ((lpa_type="mg" and lpa>=&mg1. and lpa<=&mg1.) or (lpa_type="nmol" and lpa>=&nmol1. and lpa<=&nmol2.)) and COMPRESS(statins)='1'
	UNION SELECT 11, "rslt_gt_130", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE rslt_gt_130='1'
	UNION SELECT 12, "N", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE rslt_gt_130='1' and  ((lpa_type="mg" and lpa>=&mg1. and lpa<=&mg1.) or (lpa_type="nmol" and lpa>=&nmol1. and lpa<=&nmol2.))
	UNION SELECT 13, "Statin", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE rslt_gt_130='1' and  ((lpa_type="mg" and lpa>=&mg1. and lpa<=&mg1.) or (lpa_type="nmol" and lpa>=&nmol1. and lpa<=&nmol2.)) and COMPRESS(statins)='1'

;
QUIT;	
%mend;

%count( 50, 70, 100, 150);
%count( 70, 90, 150, 190);


%macro count( mg1, nmol1);
PROC SQL; 
	SELECT 1, "rslt_lt_70", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE rslt_lt_70='1'
	UNION SELECT 2, "Lpa", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE ((lpa_type="mg" and lpa>&mg1. ) or (lpa_type="nmol" and lpa>&nmol1. ))
	UNION SELECT 3, "N", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE rslt_lt_70='1' and  ((lpa_type="mg" and lpa>&mg1. ) or (lpa_type="nmol" and lpa>&nmol1. ))
	UNION SELECT 4, "Statin", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE rslt_lt_70='1' and  ((lpa_type="mg" and lpa>&mg1. ) or (lpa_type="nmol" and lpa>&nmol1. )) and COMPRESS(statins)='1'
	UNION SELECT 5, "rslt_70_100", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE rslt_70_100='1'
	UNION SELECT 6, "N", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE rslt_70_100='1' and  ((lpa_type="mg" and lpa>&mg1. ) or (lpa_type="nmol" and lpa>&nmol1. ))
	UNION SELECT 7, "Statin", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE rslt_70_100='1' and  ((lpa_type="mg" and lpa>&mg1. ) or (lpa_type="nmol" and lpa>&nmol1. )) and COMPRESS(statins)='1'
	UNION SELECT 8, "rslt_100_130", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE rslt_100_130='1'
	UNION SELECT 9, "N", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE rslt_100_130='1' and  ((lpa_type="mg" and lpa>&mg1. ) or (lpa_type="nmol" and lpa>&nmol1. ))
	UNION SELECT 10, "Statin", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE rslt_100_130='1' and  ((lpa_type="mg" and lpa>&mg1. ) or (lpa_type="nmol" and lpa>&nmol1. )) and COMPRESS(statins)='1'
	UNION SELECT 11, "rslt_gt_130", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE rslt_gt_130='1'
	UNION SELECT 12, "N", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE rslt_gt_130='1' and  ((lpa_type="mg" and lpa>&mg1. ) or (lpa_type="nmol" and lpa>&nmol1. ))
	UNION SELECT 13, "Statin", count(distinct patid) as upats, count(patid) as pats FROM cohorts WHERE rslt_gt_130='1' and  ((lpa_type="mg" and lpa>&mg1. ) or (lpa_type="nmol" and lpa>&nmol1. )) and COMPRESS(statins)='1'

;
QUIT;	
%mend;


%count( 90, 190);
%count( 70, 150);