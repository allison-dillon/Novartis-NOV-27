/* Main ASCVD cohorts - Total N patients with Lp(a) measurement and ASCVD by mg/dl and nmol/L?*/
PROC SQL;
	CREATE TABLE _01_cohort1 as 
	select a.patid, index_date_overall, lpa, lpa_date, age, yrdob, recent_ldlc, r_ldlc_date, statins, Betablocker, ACE, hypertension, diabete, cohort
	FROM (	 
		SELECT a.patid, a.index_date_overall, lpa, lpa_date, age, yrdob, statins, Betablocker, ACE, hypertension, diabete, b.recent_ldlc, b.r_ldlc_date, 1 as cohort
		FROM derived._05_demo1b_overall a left join derived.ldlc_06 b on a.patid=b.patid
		UNION ALL
		SELECT a.patid, a.index_date_overall, lpa, lpa_date, age, yrdob, statins, Betablocker, ACE, hypertension, diabete, b.recent_ldlc, b.r_ldlc_date, 2 as cohort
		FROM derived._05_demo2b_overall a left join derived.ldlc_06 b
			on a.patid=b.patid
	) a 

	where a.index_date_overall is not null
	ORDER BY patid;
quit;



/*slide 1 - flags if patients had index events before/after age 55 and if elevated Lp(a) (>=70 mg/dL or >= 150 nmol/L)*/
PROC SQL;
	CREATE TABLE _01_cohort_2 AS 
	SELECT cohort, patid, index_date_overall, lpa, age
		,case when age<55 then 1 else 0 end as LT_55
		,case when age<60 then 1 else 0 end as LT_60
		,case when age<65 then 1 else 0 end as LT_65
		,case when (cohort=1 and lpa>=70) or (cohort=2 and lpa>=150) then 1 else 0 end as elevate_lpa
	FROM _01_cohort1;
QUIT;

/*counts for slide 1 - age 55*/

PROC SQL;
	SELECT 1,"AllPatients",  count(PATID), count(patid) from _01_cohort_2 
	UNION SELECT 2,"Patients 55",  COUNT(CASE WHEN LT_55=1 then PATID end), COUNT(CASE WHEN LT_55=0 then PATID end) from _01_cohort_2
	UNION SELECT 3,"Elevated Lpa",  COUNT(CASE WHEN LT_55=1 and elevate_lpa=1 then PATID end), COUNT(CASE WHEN LT_55=0  and elevate_lpa=1 then PATID end) from _01_cohort_2  
	;
QUIT;

/*counts for slide 1-60*/
PROC SQL;
	SELECT 1,"AllPatients",  count(PATID), count(patid) from _01_cohort_2 
	UNION SELECT 2,"Patients 60",  COUNT(CASE WHEN LT_60=1 then PATID end), COUNT(CASE WHEN LT_60=0 then PATID end) from _01_cohort_2
	UNION SELECT 3,"Elevated Lpa",  COUNT(CASE WHEN LT_60=1 and elevate_lpa=1 then PATID end), COUNT(CASE WHEN LT_60=0  and elevate_lpa=1 then PATID end) from _01_cohort_2  
	;
QUIT;

/*counts for slide 1-65*/
PROC SQL;
	SELECT 1,"AllPatients",  count(PATID), count(patid) from _01_cohort_2 
	UNION SELECT 2,"Patients 65",  COUNT(CASE WHEN LT_65=1 then PATID end), COUNT(CASE WHEN LT_65=0 then PATID end) from _01_cohort_2
	UNION SELECT 3,"Elevated Lpa",  COUNT(CASE WHEN LT_65=1 and elevate_lpa=1 then PATID end), COUNT(CASE WHEN LT_65=0  and elevate_lpa=1 then PATID end) from _01_cohort_2  
	;
QUIT;



%macro main;
/*slide 2 - Total ASCVD patients excluding other cohort*/
%create(_01_feas_ASCVD)
	SELECT patid, index_date
	FROM (
		SELECT patid, index_date
		,case when 
	%let groups=cvd*mi*pad*stroke*unsta_angina*sta_angina*tia*revasc*noncvd;
		%do i=1 %to 9;
		%let ad = %scan(&groups., &i., *);
		index_date_&ad. is not null
		%if &i. <9 %then or; %end;	then ' ' else index_date_other end as index_date_other
	from dingyig._01_cohort_1a ) a
	WHERE index_date_other is null
%create(_01_feas_ASCVD);
%mend;
%main;

/*Patients with continuous enrollment 12 months prior to index date*/
%create(_01_feas_ASCVD_1)
	select a.* , b.eligeff, b.eligend
	FROM dingyig._01_feas_ASCVD a inner join src_optum_claims_panther.dod_mbr_co_enroll b
		on a.patid=b.patid and datediff(a.index_date,b.eligeff) >= 365.25 and (a.index_date between b.eligeff and b.eligend)
%create(_01_feas_ASCVD_1);

/*removes missing gender and year of birth*/
%create(_01_feas_ASCVD_1a)
	select *
	from (	
		select a.*, b.product, b.state, b.yrdob, b.gdr_cd
		,row_number() over (partition by a.patid order by a.eligend desc, a.eligeff desc) as rn
		FROM dingyig._01_feas_ASCVD_1 a INNER JOIN src_optum_claims_panther.dod_mbr_detail b
			on a.patid=b.patid 
			where a.patid is not null and b.yrdob is not null and gdr_cd is not null and gdr_cd<>'U' ) a 
	WHERE RN=1
%create(_01_feas_ASCVD_1a);

%let ldlc = %str('13457-7','18262-6','2089-1','22748-8','35198-1','39469-2','49026-8','49027-6','56136-5','56137-3','56138-1','56139-9','69419-0'
				,'91105-7','91106-5','91107-3','91108-1','91109-9','91110-7','91111-5','91112-3','91113-1','91114-9','91115-6','91116-4','91117-2','91118-0');
%let lpa_mg = %str('10835-7');
%let lpa_mol = %str('43583-4');

/*lab values during the study period, earliest Lp(a) and most recent LDLC will be used*/
%macro labsetup;
	%create(_01_feas_lab)
		%do t=1 %to 3;
			%let lab = %scan(ldlc*lpa_mg*lpa_mol, &t., *);
			select distinct a.patid, "&lab." as grp, a.loinc_cd, a.fst_dt, a.RSLT_UNIT_NM, a.RSLT_NBR
			from (select * 
					from src_optum_claims_panther.dod_lr 
					where loinc_cd in (&&&lab.) 
						/*for blood pressure, all measures without units are good to go*/
						%if &t. >= 1 and &t. <= 2 %then %do; 
							and (RSLT_UNIT_NM in ('MG/DL','mg/dL','mg/dl','mg/dL','MG/DL','mg/dl','mg/DL','mg/Dl','mg/dL (calc)','MG/DL (CALC)','mg/dL F11.23','mg/dLmg/dLL','mg-dL','milligram per deci')
								or lower(RSLT_UNIT_NM)='mg/dl' or lower(RSLT_UNIT_NM) like '%mg/dl%' or RSLT_UNIT_NM like '%mg/dl%' or RSLT_UNIT_NM like '%mg/dL%')
						%end;		
						%if &t. = 3 %then %do; /*lpa_mol*/
							and RSLT_UNIT_NM in ('nmol/Lnmol/LL','nmol/L','NMOL/L')
						%end;	
					and fst_dt>='2007-01-01 00:00:00.00' and fst_dt<='2020-06-30 00:00:00.00'
		) as a inner join dingyig._01_feas_ASCVD_1a b
			on a.patid=b.patid
			%if &t. < 3 %then %do; union %end;
		%end;
	%create(_01_feas_lab);			
%mend;
%labsetup;						
						
						
/*gets most recent LDL-C in study period for total ASCVD patients in study period*/
%create(_01_feas_LDLC)
	select *
	from (
		select a.patid, index_date, b.loinc_cd, b.fst_dt, b.rslt_unit_nm, b.rslt_nbr
		,row_number() over (partition by a.patid order by b.fst_dt desc) as rn
		from dingyig._01_feas_ASCVD_1a A inner join dingyig._01_feas_lab b
			on a.patid=b.patid and b.grp='ldlc'
			and (RSLT_UNIT_NM in ('MG/DL','mg/dL','mg/dl','mg/dL','MG/DL','mg/dl','mg/DL','mg/Dl','mg/dL (calc)','MG/DL (CALC)','mg/dL F11.23','mg/dLmg/dLL','mg-dL','milligram per deci')
								or lower(RSLT_UNIT_NM)='mg/dl' or lower(RSLT_UNIT_NM) like '%mg/dl%' or RSLT_UNIT_NM like '%mg/dl%' or RSLT_UNIT_NM like '%mg/dL%' )
			and b.fst_dt>='2007-01-01 00:00:00.00' and b.fst_dt<='2020-06-30 00:00:00.00'
								) a
	where rn=1
%create(_01_feas_LDLC);	


/*gets earliest Lp(a) reading in study period*/
%create(_01_feas_Lpa)
select *
	from (
		select a.patid, index_date, b.loinc_cd, b.fst_dt, b.rslt_unit_nm, b.rslt_nbr
		,row_number() over (partition by a.patid order by b.fst_dt ) as rn
		from dingyig._01_feas_ASCVD_1a A inner join dingyig._01_feas_lab b
			on a.patid=b.patid and b.grp in ('lpa_mg','lpa_mol')
			and (b.RSLT_UNIT_NM in ('MG/DL','mg/dL','mg/dl','mg/dL','MG/DL','mg/dl','mg/DL','mg/Dl','mg/dL (calc)','MG/DL (CALC)','mg/dL F11.23','mg/dLmg/dLL','mg-dL','milligram per deci')
								or lower(b.RSLT_UNIT_NM)='mg/dl' or lower(b.RSLT_UNIT_NM) like '%mg/dl%' or b.RSLT_UNIT_NM like '%mg/dl%' or b.RSLT_UNIT_NM like '%mg/dL%' or b.RSLT_UNIT_NM in ('nmol/Lnmol/LL','nmol/L','NMOL/L'))
			and b.fst_dt>='2007-01-01 00:00:00.00' and b.fst_dt<='2020-06-30 00:00:00.00'
								) a
	where rn=1	
%create(_01_feas_Lpa);


/*medications for the analysis*/
%create(_01_feas_drugs)
			select a.patid, a.fill_dt as dt, a.ndc, b.grp
				, case when b.grp in ('Angiotensin-converting enzyme (ACE) inhibitors','Angiotensin II Receptor Blockers') then 'ACE'
					when b.grp in ('Alpha-beta-blockers','Beta-blocker') then 'Betablocker'
					when b.grp in ('Hormone replacement therapy') then 'Hormone'
					when b.grp in ('Fibrinolytic therapy') then 'Fibrinolytic'
					when b.grp in ('Loop diuretics') then 'Loop_Diuretics'
					when b.grp in ('Mineralocorticoid Receptor Antagonists (MRA)') then 'MRA'
					else b.grp end as generic
			from src_optum_claims_panther.dod_r as a inner join dingyig.optum2_drug b
				on a.ndc=b.ndc
			where b.grp in ('Angiotensin-converting enzyme (ACE) inhibitors','Angiotensin II Receptor Blockers','Statins','Alpha-beta-blockers','Beta-blocker')
			and a.fill_dt>='2007-01-01 00:00:00.00' and a.fill_dt<='2020-06-30 00:00:00.00'
%create(_01_feas_drugs);


%macro main;
/*statins or hypertensive drugs during baseline*/	
%create(_01_feas_drugs_1)
	select a.patid, a.index_date
	%let grp=Statins*Betablocker*ACE;
		%do i=1 %to 3;
		%let drug=%scan(&grp., &i., *);
		,max(case when b.generic="&drug." then '1' end) as &drug.
		%end;
	from dingyig._01_feas_ASCVD_1a a left join dingyig._01_feas_drugs b
		on a.patid=b.patid and datediff(b.dt,a.index_date) between -365.25 and -1
	GROUP BY a.patid, a.index_date
%create(_01_feas_drugs_1);
%mend;
%main;


/*hypertension and diabetes during baseline*/	
* CV comorbidities - 7;
%let hypertension = %str('401','402','403','404','405','I10','I11','I12','I13','I15','I16');
%let diabete = %str('250','E10','E11','E13','E14');

%macro comor;
	%create(_01_feas_comor)
		%do i=1 %to 2;
			%let dx =%scan(hypertension*diabete, &i., *);
			select a.patid, a.pat_planid, a.clmid, a.fst_dt as dt, a.diag as code, "&dx." as grp
			from src_optum_claims_panther.dod_diag as a
			where (substr(a.diag,1,3) in (&&&dx.) 
					or substr(a.diag,1,4) in (&&&dx.) 
					or substr(a.diag,1,5) in (&&&dx.) 
					or substr(a.diag,1,6) in (&&&dx.)) 
				and a.patid in (select distinct patid from dingyig._01_feas_ASCVD_1a)
				and a.fst_dt>='2007-01-01 00:00:00.00' and a.fst_dt<='2020-06-30 00:00:00.00'
			%if &i. < 2 %then %do; union %end;
		%end;	
	%create(_01_feas_comor);
	
%mend comor;
%comor;

/*comorbidities in baseline*/
%macro main;
%create(_01_feas_comor_1)
	select a.patid, a.index_date
	%let grps=hypertension*diabete;
		%do i=1 %to 2;
		%let grp=%scan(&grps., &i., *);
		,max(case when b.grp="&grp." then '1' end) as &grp.
		%end;
	from dingyig._01_feas_ASCVD_1a a left join dingyig._01_feas_comor b
		on a.patid=b.patid and datediff(b.dt,a.index_date) between -365.25 and -1
	GROUP BY a.patid, a.index_date
%create(_01_feas_comor_1);
%mend;
%main;


/*add all variables*/
%create(_01_feas_final)
	select a.*
		, b.rslt_nbr as LDLC
		, c.rslt_nbr as lpa
		, c.rslt_unit_nm
		, d.Statins, d.Betablocker, d.ACE
		,case when d.betablocker='1' or d.ace='1' then '1' end as anti_hyp
		, e.hypertension, e.diabete
	from dingyig._01_feas_ASCVD_1a a left join dingyig._01_feas_LDLC b on a.patid=b.patid
								 left join dingyig._01_feas_Lpa c on a.patid=c.patid
								 left join dingyig._01_feas_ASCVD_2 d on a.patid=d.patid
								  left join dingyig._01_feas_comor_1 e on a.patid=e.patid
%create(_01_feas_final);

/*left columns on second slide*/
%select	
	select 1, 'All ASCVD    ' , count(distinct patid), count(patid) from dingyig._01_feas_ASCVD
	union select 2,  'ASCVD with enrollment', count(distinct patid), count(patid) from dingyig._01_feas_ASCVD_1
	union select 3,  'No missing year or gender', count(distinct patid), count(patid) from dingyig._01_feas_ASCVD_1a
	union select 4,  'LDLC<100 or on statins', count(distinct patid), count(patid) from dingyig._01_feas_final where LDLC<100 or statins='1'
	union select 5,  ' Lp(a) measurement', count(distinct patid), count(patid) from dingyig._01_feas_final where (LDLC<100 or statins='1') and lpa is not null
	union select 6,  'elevated Lp(a)', count(distinct patid), count(patid) from dingyig._01_feas_final where (LDLC<100 or statins='1') and  ((upper(rslt_unit_nm)='MG/DL' and lpa>=70) or (upper(rslt_unit_nm) like '%NMOL%' and lpa>=150))
	order by 1
%select

/*middle column on second slide*/
%select	
	select 1, 'All ASCVD    ' , count(distinct patid), count(patid) from dingyig._01_feas_ASCVD
	union select 2,  'ASCVD with enrollment', count(distinct patid), count(patid) from dingyig._01_feas_ASCVD_1
	union select 3,  'No missing year or gender', count(distinct patid), count(patid) from dingyig._01_feas_final
	union select 4,  'w/o Hypertension or hyp & anti-hyp', count(distinct patid), count(patid) from dingyig._01_feas_final where hypertension is null or (hypertension='1' and anti_hyp='1')
	union select 5,  ' Lp(a) measurement', count(distinct patid), count(patid) from dingyig._01_feas_final where (hypertension is null or (hypertension='1' and anti_hyp='1')) and lpa is not null
	union select 6,  'elevated Lp(a)', count(distinct patid), count(patid) from dingyig._01_feas_final where (hypertension is null or (hypertension='1' and anti_hyp='1')) and  ((upper(rslt_unit_nm)='MG/DL' and lpa>=70) or (upper(rslt_unit_nm) like '%NMOL%' and lpa>=150))
%select


/*right column on second slide*/
%select	
	select 1, 'All ASCVD    ' , count(distinct patid), count(patid) from dingyig._01_feas_ASCVD
	union select 2,  'ASCVD with enrollment', count(distinct patid), count(patid) from dingyig._01_feas_ASCVD_1
	union select 3,  'No missing year or gender', count(distinct patid), count(patid) from dingyig._01_feas_final
	union select 4,  'No diabetes', count(distinct patid), count(patid) from dingyig._01_feas_final where diabete is null
	union select 5,  ' Lp(a) measurement', count(distinct patid), count(patid) from dingyig._01_feas_final where diabete is null and lpa is not null
	union select 6,  'elevated Lp(a)', count(distinct patid), count(patid) from dingyig._01_feas_final where diabete is null and  ((upper(rslt_unit_nm)='MG/DL' and lpa>=70) or (upper(rslt_unit_nm) like '%NMOL%' and lpa>=150))
%select

/*counts for new slide*/
/*left column*/
%select	
	select 1, 'All ASCVD    ' , count(distinct patid), count(patid) from dingyig._01_feas_ASCVD
	union select 2,  'ASCVD with enrollment', count(distinct patid), count(patid) from dingyig._01_feas_ASCVD_1
	union select 3,  'No missing year or gender', count(distinct patid), count(patid) from dingyig._01_feas_final
	union select 4,  'LDLC <100', count(distinct patid), count(patid) from dingyig._01_feas_final where LDLC<100 
	union select 5,  ' Lp(a) measurement', count(distinct patid), count(patid) from dingyig._01_feas_final where LDLC<100 and lpa is not null
	union select 6,  'elevated Lp(a)', count(distinct patid), count(patid) from dingyig._01_feas_final where LDLC<100 and  ((upper(rslt_unit_nm)='MG/DL' and lpa>=70) or (upper(rslt_unit_nm) like '%NMOL%' and lpa>=150))
%select

/*left middle column*/
%select	
	select 1, 'All ASCVD    ' , count(distinct patid), count(patid) from dingyig._01_feas_ASCVD
	union select 2,  'ASCVD with enrollment', count(distinct patid), count(patid) from dingyig._01_feas_ASCVD_1
	union select 3,  'No missing year or gender', count(distinct patid), count(patid) from dingyig._01_feas_final
	union select 4,  'No Hypertension', count(distinct patid), count(patid) from dingyig._01_feas_final where hypertension is null 
	union select 5,  ' Lp(a) measurement', count(distinct patid), count(patid) from dingyig._01_feas_final where hypertension is null and lpa is not null
	union select 6,  'elevated Lp(a)', count(distinct patid), count(patid) from dingyig._01_feas_final where hypertension is null and ((upper(rslt_unit_nm)='MG/DL' and lpa>=70) or (upper(rslt_unit_nm) like '%NMOL%' and lpa>=150))
%select

/*right middle column*/
%select	
	select 1, 'All ASCVD    ' , count(distinct patid), count(patid) from dingyig._01_feas_ASCVD
	union select 2,  'ASCVD with enrollment', count(distinct patid), count(patid) from dingyig._01_feas_ASCVD_1
	union select 3,  'No missing year or gender', count(distinct patid), count(patid) from dingyig._01_feas_final
	union select 4,  'LDLC >100', count(distinct patid), count(patid) from dingyig._01_feas_final where LDLC>=100 
	union select 5,  ' Lp(a) measurement', count(distinct patid), count(patid) from dingyig._01_feas_final where LDLC>=100 and lpa is not null
	union select 6,  'elevated Lp(a)', count(distinct patid), count(patid) from dingyig._01_feas_final where LDLC>=100  and  ((upper(rslt_unit_nm)='MG/DL' and lpa>=70) or (upper(rslt_unit_nm) like '%NMOL%' and lpa>=150))
%select

/*right column*/
%select	
	select 1, 'All ASCVD    ' , count(distinct patid), count(patid) from dingyig._01_feas_ASCVD
	union select 2,  'ASCVD with enrollment', count(distinct patid), count(patid) from dingyig._01_feas_ASCVD_1
	union select 3,  'No missing year or gender', count(distinct patid), count(patid) from dingyig._01_feas_final
	union select 4,  'LDLC > 100', count(distinct patid), count(patid) from dingyig._01_feas_final where LDLC>=100 and statins='1'
	union select 5,  ' Lp(a) measurement', count(distinct patid), count(patid) from dingyig._01_feas_final where LDLC>=100 and statins='1' and lpa is not null
	union select 6,  'elevated Lp(a)', count(distinct patid), count(patid) from dingyig._01_feas_final where LDLC>=100 and statins='1' and  ((upper(rslt_unit_nm)='MG/DL' and lpa>=70) or (upper(rslt_unit_nm) like '%NMOL%' and lpa>=150))
%select

/*check patients with LDLC values*/
%select
	 select 1,'LDLC<100' count(distinct patid), count(patid) from dingyig._01_feas_final where LDLC<100 
	 union select 2,'LDLC=100' count(distinct patid), count(patid) from dingyig._01_feas_final where LDLC=100 
	 union select 3,'LDLC>100' count(distinct patid), count(patid) from dingyig._01_feas_final where LDLC>100 
%select;


