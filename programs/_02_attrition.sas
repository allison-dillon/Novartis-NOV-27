/*attriton*/
/*
ASCVD diagnosis included:
• Coronary Artery disease (MI, unstable angina, stable angina)
• Cerebrovascular disease (ischemic stroke, transient ischemic attack)
• Peripheral arterial disease
• Post-revascularization (PCI, CABG, angioplasty and/or stent placement, endarterectomy, thrombectomy)
• Other ASCVD
*/											

* 1. Patients with ASCVD diagnosis within the identification period (the earliest diagnosis is the index date);
%create(_01_ASCVD)
		select x.patid, x.cat, x.grp, x.dt as index_date
		from (select patid, dt, cat, grp from dingyig.optum2_01_ascvd
				union select patid, dt, 'revasc' as cat, grp from dingyig.optum2_01_proc where grp in ('revasc')) as x 
		inner join (select b.*
				from (select a.patid, a.dt, row_number() over (partition by a.patid order by a.patid, a.dt) as rn 
					from (select patid, dt, cat, grp from dingyig.optum2_01_ascvd
						union select patid, dt, 'revasc' as cat, grp from dingyig.optum2_01_proc where grp in ('revasc')) as a
						where a.dt between '2008-01-01 00:00:00.00' and '2019-06-30 23:59:59.99') as b
					where b.rn=1) as y
		on x.patid=y.patid and x.dt=y.dt
%create(_01_ASCVD);

%create(_01_ASCVD_1)
	select *
	,row_number() over (partition by patid order by index_date) as rn 
	from dingyig._01_ASCVD
	where index_date between '2008-01-01 00:00:00.00' and '2019-06-30 23:59:59.99'
%create(_01_ASCVD_1);


/* cvd*mi*stroke*pad*noncvd*unsta_angina*sta_angina*tia*revasc*other */
* 1-1. create separate categories for index date;
%create(_01_cohort_1)
		select a.patid, index_date, a.grp, a.cat
		from dingyig._01_ASCVD_1 a 
		WHERE RN=1
%create(_01_cohort_1);

/*adds in columns for index diagnosis date for subgroups*/
%create(_01_cohort_1a)
	select a.*
			, case when x.patid is not null then x.index_date_cvd end as index_date_cvd
			, case when b.patid is not null then b.index_date_mi end as index_date_mi
			, case when c.patid is not null then c.index_date_stroke end as index_date_stroke
			, case when d.patid is not null then d.index_date_pad end as index_date_pad	
			
			, case when f.patid is not null then f.index_date_revasc end as index_date_revasc
			, case when e.patid is not null then e.index_date_angina end as index_date_unsta_angina
			, case when g.patid is not null then g.index_date_other end as index_date_sta_angina	
			, case when h.patid is not null then h.index_date_other end as index_date_tia	
			, case when i.patid is not null then i.index_date_other end as index_date_other
			, case when j.patid is not null then j.index_date_anginatia end as index_date_anginatia
			, case when x.patid is not null and y.patid is not null then y.index_date_noncvd end as index_date_noncvd

		from dingyig._01_cohort_1 as a 
			/*CVD*/
			left join (select a.patid, min(dt) as index_date_cvd
						from dingyig._01_ASCVD as a inner join (select * from dingyig.optum2_01_ascvd where grp in ('mi','stroke','pad') 
							and dt between '2008-01-01 00:00:00.00' and '2019-06-30 23:59:59.99') as b
						on a.patid=b.patid
						group by a.patid) as x on a.patid=x.patid
			/*Non CVD*/

			left join (select a.patid, min(dt) as index_date_mi
						from dingyig._01_ASCVD as a inner join (select * from dingyig.optum2_01_ascvd where grp in ('mi') and dt between '2008-01-01 00:00:00.00' and '2019-06-30 23:59:59.99') as b
						on a.patid=b.patid
						group by a.patid) as b on a.patid=b.patid
			left join (select a.patid, min(dt) as index_date_stroke
						from dingyig._01_ASCVD as a inner join (select * from dingyig.optum2_01_ascvd where grp in ('stroke') and dt between '2008-01-01 00:00:00.00' and '2019-06-30 23:59:59.99') as b
						on a.patid=b.patid
						group by a.patid) as c on a.patid=c.patid
			left join (select a.patid, min(dt) as index_date_pad
						from dingyig._01_ASCVD as a inner join (select * from dingyig.optum2_01_ascvd where grp in ('pad') and dt between '2008-01-01 00:00:00.00' and '2019-06-30 23:59:59.99') as b
						on a.patid=b.patid
						group by a.patid) as d on a.patid=d.patid		
						
			left join (select a.patid, min(dt) as index_date_angina
						from dingyig._01_ASCVD as a inner join (select * from dingyig.optum2_01_ascvd where grp in ('unsta_angina') and dt between '2008-01-01 00:00:00.00' and '2019-06-30 23:59:59.99') as b
						on a.patid=b.patid
						group by a.patid) as e on a.patid=e.patid								
			left join (select a.patid, min(dt) as index_date_revasc
						from dingyig._01_ASCVD as a inner join (select * from dingyig.optum2_01_proc where grp in ('revasc') and dt between '2008-01-01 00:00:00.00' and '2019-06-30 23:59:59.99') as b
						on a.patid=b.patid
						group by a.patid) as f on a.patid=f.patid								
			left join (select a.patid, min(dt) as index_date_other
						from dingyig._01_ASCVD as a inner join (select * from dingyig.optum2_01_ascvd where grp in ('sta_angina') and dt between '2008-01-01 00:00:00.00' and '2019-06-30 23:59:59.99') as b
						on a.patid=b.patid
						group by a.patid) as g on a.patid=g.patid								
			left join (select a.patid, min(dt) as index_date_other
						from dingyig._01_ASCVD as a inner join (select * from dingyig.optum2_01_ascvd where grp in ('tia') and dt between '2008-01-01 00:00:00.00' and '2019-06-30 23:59:59.99') as b
						on a.patid=b.patid
						group by a.patid) as h on a.patid=h.patid	
			
			left join (select a.patid, min(dt) as index_date_other
						from dingyig._01_ASCVD as a inner join (select * from dingyig.optum2_01_ascvd where grp in ('other') and dt between '2008-01-01 00:00:00.00' and '2019-06-30 23:59:59.99') as b
						on a.patid=b.patid
						group by a.patid) as i on a.patid=i.patid	
			left join (select a.patid, min(dt) as index_date_anginatia
						from dingyig._01_ASCVD as a inner join (select * from dingyig.optum2_01_ascvd where grp in ('tia','sta_angina','unsta_angina') and dt between '2008-01-01 00:00:00.00' and '2019-06-30 23:59:59.99') as b
						on a.patid=b.patid
						group by a.patid) as j on a.patid=j.patid	
				/*Non CVD*/
			left join (select a.patid, min(dt) as index_date_noncvd
						from dingyig._01_ASCVD as a inner join (select patid, dt from dingyig.optum2_01_ascvd where grp in ('unsta_angina','sta_angina','tia') 
							and dt between '2008-01-01 00:00:00.00' and '2019-06-30 23:59:59.99' union
							select patid, dt from dingyig.optum2_01_proc where grp in ('revasc') 
							and dt between '2008-01-01 00:00:00.00' and '2019-06-30 23:59:59.99') as b
						on a.patid=b.patid and a.index_date = b.dt
						group by a.patid) as y on a.patid=y.patid	
					
%create(_01_cohort_1a);


/*gets rid of revasc index dates if mi, pad, or is occur before*/
%macro index_date;
%create(_01_cohort_1b)
	select a.patid, a.index_date as index_date_overall, a.grp, a.cat
		, index_date_mi, index_date_stroke, index_date_pad, index_date_cvd, index_date_other
		%let groups=unsta_angina*sta_angina*tia*revasc*anginatia*noncvd;
		%do i=1 %to 6;
		%let ad = %scan(&groups., &i., *);
		,case when index_date_mi<=index_date_&ad. or index_date_stroke<=index_date_&ad. or index_date_pad<=index_date_&ad. then ' ' else index_date_&ad. end as index_date_&ad.
		%end;
	FROM dingyig._01_cohort_1a a
%create(_01_cohort_1b);	
%mend;
%index_date;

/*Patients with  Lp(a) measurement in mg/dLand nmol/L -earliest measurement will be used*/ 
%macro test(results,table);
%create(_01_cohort_2&table.)
	select a.*, b.tst_desc, b.rslt_nbr, b.rslt_unit_nm, b.fst_dt as lpa_date
	, ROW_NUMBER() OVER(partition by a.patid ORDER BY fst_dt) AS RN
	FROM dingyig._01_cohort_1b a inner join dingyig.&results. b
		on a.patid=b.patid 
%create(_01_cohort_2&table.);
%mend;
%test(optum2_01_lpa_mg,a);		
%test(optum2_01_lpa_mol,b);	

/*patients excluded with more than one results on same day*/
%create(_01_cohort_2b_test)
	select a.*, b.tst_desc, b.rslt_nbr, b.rslt_unit_nm, b.fst_dt as lpa_date
	FROM dingyig._01_cohort_1b a inner join dingyig.optum2_01_mol_test b
		on a.patid=b.patid 
%create(_01_cohort_2b_test);	

/*patients excluded due to missingness*/
%create(_01_cohort_2b_test1)
	select a.*, b.tst_desc, b.rslt_nbr, b.rslt_unit_nm, b.fst_dt as lpa_date
	FROM dingyig._01_cohort_1b a inner join dingyig.optum2_01_mol_test1 b
		on a.patid=b.patid 
%create(_01_cohort_2b_test1);	


%select
	select count(distinct patid), count(patid)
	from dingyig._01_cohort_2b_test1
%select;

%select
	select count(distinct patid), count(patid)
	from dingyig._01_cohort_2b_test
%select;



%macro test(results,table);

/*Patients with continuous enrollment 12 months prior to index date*/
%create(_01_cohort_3&table.)
	select a.patid, a.index_date_overall, a.grp, a.cat, a.tst_desc, a.rslt_nbr, a.rslt_unit_nm, a.lpa_date, b.eligeff, b.eligend
/* 	, b.product, b.state, b.yrdob, gdr_cd */
		%let groups=cvd*mi*pad*stroke*unsta_angina*sta_angina*tia*revasc*anginatia*other*noncvd;
		%do i=1 %to 11;
		%let ad = %scan(&groups., &i., *);
		,case when datediff(a.index_date_&ad.,b.eligeff) >= 365.25 and (a.index_date_&ad. between b.eligeff and b.eligend) then a.index_date_&ad. else ' ' end as index_date_&ad.
		%end;
	FROM dingyig._01_cohort_2&table. a inner join src_optum_claims_panther.dod_mbr_co_enroll b
		on a.patid=b.patid and datediff(a.index_date_overall,b.eligeff) >= 365.25 and (a.index_date_overall between b.eligeff and b.eligend)
	WHERE RN=1
%create(_01_cohort_3&table.);

%mend;
%test(optum2_01_lpa_mg,a);		
%test(optum2_01_lpa_mol,b);		


%macro test(results,table);
/*Excludes patients with missing patid and resets indexes*/	
%create(_01_cohort_4&table.)
	select a.patid, a.index_date_overall, a.grp, a.cat, a.tst_desc, a.rslt_nbr, a.rslt_unit_nm, a.lpa_date, a.eligeff, a.eligend 
/* 	, a.product, a.state, a.yrdob, gdr_cd */
		,index_date_mi ,index_date_pad, index_date_stroke,index_date_unsta_angina ,index_date_sta_angina,index_date_tia, index_date_revasc, index_date_cvd, index_date_anginatia, index_date_noncvd
		,case when 
		%let groups=cvd*mi*pad*stroke*unsta_angina*sta_angina*tia*revasc*noncvd;
		%do i=1 %to 9;
		%let ad = %scan(&groups., &i., *);
		index_date_&ad. is not null
		%if &i. <9 %then or; %end;	then ' ' else index_date_other end as index_date_other

	FROM dingyig._01_cohort_3&table. a 
	WHERE patid is not null
%create(_01_cohort_4&table.);
%mend;
%test(optum2_01_lpa_mg,a);		
%test(optum2_01_lpa_mol,b);		

/*gets last plan info from mbr detail table*/

%macro test(results,table);
%create(_01_mbr_plan&table.)
	select  b.patid, b.product, b.state, b.yrdob, b.gdr_cd
	,row_number() over (partition by a.patid order by a.eligend desc, a.eligeff desc) as rn
	FROM dingyig._01_cohort_4&table. a INNER JOIN src_optum_claims_panther.dod_mbr_detail b
		on a.patid=b.patid 
%create(_01_mbr_plan&table.)
%mend;
%test(optum2_01_lpa_mg,a);		
%test(optum2_01_lpa_mol,b);	

%macro test(results,table);
/*Excludes patients with missing year of birth*/	
%create(_01_cohort_5&table.)
	select distinct a.* , b.product, b.state, b.yrdob, gdr_cd 
	FROM dingyig._01_cohort_4&table. a left join dingyig._01_mbr_plan&table. b on a.patid=b.patid and b.rn=1
	WHERE yrdob is not null
%create(_01_cohort_5&table.);
%mend;
%test(optum2_01_lpa_mg,a);		
%test(optum2_01_lpa_mol,b);	


%macro test(results,table);
/*Excludes patients with missing gender*/	
%create(_01_cohort_6&table.)
	select a.patid, 
		case when index_date_other is not null then ' ' else index_date_overall end as index_date_overall
		, a.grp, a.cat, a.tst_desc, a.rslt_nbr, a.rslt_unit_nm, a.lpa_date, a.eligeff, a.eligend, a.product, a.state, a.yrdob, gdr_cd
		,index_date_mi ,index_date_pad, index_date_stroke,index_date_unsta_angina ,index_date_sta_angina,index_date_tia, index_date_revasc, index_date_anginatia
		,index_date_other, index_date_cvd, index_date_noncvd
	FROM dingyig._01_cohort_5&table. a
	WHERE gdr_cd is not null and gdr_cd<>'U' 
%create(_01_cohort_6&table.);
%mend;
%test(optum2_01_lpa_mg,a);		
%test(optum2_01_lpa_mol,b);		


%macro test(results,table);
%select
	select 1, 'Patients with ASCVD          ', count(distinct patid) as upats from dingyig._01_cohort_1
	union select 2, '&results.', count(distinct patid) as upats from dingyig._01_cohort_2&table.
	union select 3, 'Patients with enrollment', count(distinct patid) as upats from dingyig._01_cohort_3&table.
	union select 4, 'Excluding missing patid', count(distinct patid) as upats from dingyig._01_cohort_4&table.
	union select 5, 'Excluded missing yob' , count(distinct patid) as upats from dingyig._01_cohort_5&table.
	union select 6, 'Excluding missing gender', count(distinct patid) as upats from dingyig._01_cohort_6&table.
%select;
	
%mend;
%test(optum2_01_lpa_mg,a);		
%test(optum2_01_lpa_mol,b);		


