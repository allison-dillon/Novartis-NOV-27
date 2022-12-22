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
				union select patid, dt, 'revasc' as cat, grp from dingyig.optum2_01_proc where grp in ('throm','cabg','endar','pci','angio_stent')) as x 
		inner join (select b.*
				from (select a.patid, a.dt, row_number() over (partition by a.patid order by a.patid, a.dt) as rn 
					from (select patid, dt, cat, grp from dingyig.optum2_01_ascvd
						union select patid, dt, 'revasc' as cat, grp from dingyig.optum2_01_proc where grp in ('throm','cabg','endar','pci','angio_stent')) as a
						where a.dt between '2008-01-01 00:00:00.00' and '2018-12-31 23:59:59.99') as b
					where b.rn=1) as y
		on x.patid=y.patid and x.dt=y.dt
%create(_01_ASCVD);

%create(_01_ASCVD_1)
	select *
	,row_number() over (partition by patid order by index_date) as rn 
	from dingyig._01_ASCVD
	where index_date between '2008-01-01 00:00:00.00' and '2018-12-31 23:59:59.99'
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
			
			, case when x.patid is not null and y.patid is not null then y.index_date_noncvd end as index_date_noncvd
			, case when e.patid is not null then e.index_date_angina end as index_date_unsta_angina
			, case when f.patid is not null then f.index_date_revasc end as index_date_revasc
			, case when g.patid is not null then g.index_date_other end as index_date_sta_angina	
			, case when h.patid is not null then h.index_date_other end as index_date_tia	
/* 			, case when i.patid is not null then i.index_date_other end as index_date_other */
			
			, case when s.patid is not null then s.index_date_pci end as index_date_pci
			, case when t.patid is not null then t.index_date_cabg end as index_date_cabg	
			, case when u.patid is not null then u.index_date_angio_stent end as index_date_angio_stent	
			, case when v.patid is not null then v.index_date_endar end as index_date_endar
			, case when w.patid is not null then w.index_date_throm end as index_date_throm
		from dingyig._01_cohort_1 as a 
			/*CVD*/
			left join (select a.patid, min(dt) as index_date_cvd
						from dingyig._01_ASCVD as a inner join (select * from dingyig.optum2_01_ascvd where grp in ('mi','stroke','pad') 
							and dt between '2008-01-01 00:00:00.00' and '2018-12-31 23:59:59.99') as b
						on a.patid=b.patid
						group by a.patid) as x on a.patid=x.patid
			/*Non CVD*/
			left join (select a.patid, min(dt) as index_date_noncvd
						from dingyig._01_ASCVD as a inner join (select patid, dt from dingyig.optum2_01_ascvd where grp in ('unsta_angina','sta_angina','tia') 
							and dt between '2008-01-01 00:00:00.00' and '2018-12-31 23:59:59.99' union
							select patid, dt from dingyig.optum2_01_proc where grp in ('throm','cabg','endar','pci','angio_stent') 
							and dt between '2008-01-01 00:00:00.00' and '2018-12-31 23:59:59.99') as b
						on a.patid=b.patid and a.index_date = b.dt
						group by a.patid) as y on a.patid=y.patid		

			left join (select a.patid, min(dt) as index_date_mi
						from dingyig._01_ASCVD as a inner join (select * from dingyig.optum2_01_ascvd where grp in ('mi') and dt between '2008-01-01 00:00:00.00' and '2018-12-31 23:59:59.99') as b
						on a.patid=b.patid
						group by a.patid) as b on a.patid=b.patid
			left join (select a.patid, min(dt) as index_date_stroke
						from dingyig._01_ASCVD as a inner join (select * from dingyig.optum2_01_ascvd where grp in ('stroke') and dt between '2008-01-01 00:00:00.00' and '2018-12-31 23:59:59.99') as b
						on a.patid=b.patid
						group by a.patid) as c on a.patid=c.patid
			left join (select a.patid, min(dt) as index_date_pad
						from dingyig._01_ASCVD as a inner join (select * from dingyig.optum2_01_ascvd where grp in ('pad') and dt between '2008-01-01 00:00:00.00' and '2018-12-31 23:59:59.99') as b
						on a.patid=b.patid
						group by a.patid) as d on a.patid=d.patid		
						
			left join (select a.patid, min(dt) as index_date_angina
						from dingyig._01_ASCVD as a inner join (select * from dingyig.optum2_01_ascvd where grp in ('unsta_angina') and dt between '2008-01-01 00:00:00.00' and '2018-12-31 23:59:59.99') as b
						on a.patid=b.patid
						group by a.patid) as e on a.patid=e.patid								
			left join (select a.patid, min(dt) as index_date_revasc
						from dingyig._01_ASCVD as a inner join (select * from dingyig.optum2_01_proc where grp in ('throm','cabg','endar','pci','angio_stent') and dt between '2008-01-01 00:00:00.00' and '2018-12-31 23:59:59.99') as b
						on a.patid=b.patid
						group by a.patid) as f on a.patid=f.patid								
			left join (select a.patid, min(dt) as index_date_other
						from dingyig._01_ASCVD as a inner join (select * from dingyig.optum2_01_ascvd where grp in ('sta_angina') and dt between '2008-01-01 00:00:00.00' and '2018-12-31 23:59:59.99') as b
						on a.patid=b.patid
						group by a.patid) as g on a.patid=g.patid								
			left join (select a.patid, min(dt) as index_date_other
						from dingyig._01_ASCVD as a inner join (select * from dingyig.optum2_01_ascvd where grp in ('tia') and dt between '2008-01-01 00:00:00.00' and '2018-12-31 23:59:59.99') as b
						on a.patid=b.patid
						group by a.patid) as h on a.patid=h.patid							
/* 			left join (select a.patid, min(dt) as index_date_other */
/* 						from dingyig._01_ASCVD as a inner join (select * from dingyig.optum2_01_ascvd where grp in ('other') and dt between '2008-01-01 00:00:00.00' and '2018-12-31 23:59:59.99') as b */
/* 						on a.patid=b.patid */
/* 						group by a.patid) as i on a.patid=i.patid	 */
						
			left join (select a.patid, min(dt) as index_date_pci
						from dingyig._01_ASCVD as a inner join (select * from dingyig.optum2_01_proc where grp in ('pci') and dt between '2008-01-01 00:00:00.00' and '2018-12-31 23:59:59.99') as b
						on a.patid=b.patid
						group by a.patid) as s on a.patid=s.patid	
							
			left join (select a.patid, min(dt) as index_date_cabg
						from dingyig._01_ASCVD as a inner join (select * from dingyig.optum2_01_proc where grp in ('cabg') and dt between '2008-01-01 00:00:00.00' and '2018-12-31 23:59:59.99') as b
						on a.patid=b.patid
						group by a.patid) as t on a.patid=t.patid	
						
			left join (select a.patid, min(dt) as index_date_angio_stent
						from dingyig._01_ASCVD as a inner join (select * from dingyig.optum2_01_proc where grp in ('angio_stent') and dt between '2008-01-01 00:00:00.00' and '2018-12-31 23:59:59.99') as b
						on a.patid=b.patid
						group by a.patid) as u on a.patid=u.patid	
						
			left join (select a.patid, min(dt) as index_date_endar
						from dingyig._01_ASCVD as a inner join (select * from dingyig.optum2_01_proc where grp in ('endar') and dt between '2008-01-01 00:00:00.00' and '2018-12-31 23:59:59.99') as b
						on a.patid=b.patid
						group by a.patid) as v on a.patid=v.patid		
						
			left join (select a.patid, min(dt) as index_date_throm
						from dingyig._01_ASCVD as a inner join (select * from dingyig.optum2_01_proc where grp in ('throm') and dt between '2008-01-01 00:00:00.00' and '2018-12-31 23:59:59.99') as b
						on a.patid=b.patid
						group by a.patid) as w on a.patid=w.patid				
%create(_01_cohort_1a);

%macro index_date;
%create(_01_cohort_1b)
	select a.patid, a.index_date as index_date_overall, a.grp, a.cat
		, index_date_mi, index_date_stroke, index_date_pad, index_date_cvd
		%let groups=unsta_angina*sta_angina*tia*revasc*throm*cabg*endar*pci*angio_stent*noncvd;
		%do i=1 %to 10;
		%let ad = %scan(&groups., &i., *);
		,case when index_date_mi<=index_date_&ad. or index_date_stroke<=index_date_&ad. or index_date_pad<=index_date_&ad. then ' ' else index_date_&ad. end as index_date_&ad.
		%end;
	FROM dingyig._01_cohort_1a a
%create(_01_cohort_1b);	
%mend;
%index_date;

options mprint;

%macro test(results,table);
/*Patients with  Lp(a) measurement in mg/dL -earliest measurement will be used*/ 
%create(_01_cohort_2&table.)
	select a.*, b.tst_desc, b.rslt_nbr, b.rslt_unit_nm, b.fst_dt as lpa_date
	, ROW_NUMBER() OVER(partition by a.patid ORDER BY fst_dt) AS RN
	FROM dingyig._01_cohort_1b a inner join dingyig.&results. b
		on a.patid=b.patid 
%create(_01_cohort_2&table.);

%mend;
%test(optum2_01_lpa_mg,a);		
%test(optum2_01_lpa_mol,b);		

%macro test(results,table);
/*Patients with continuous enrollment 12 months prior to index date*/
%create(_01_cohort_3&table.)
	select a.patid, a.index_date_overall, a.grp, a.cat, a.tst_desc, a.rslt_nbr, a.rslt_unit_nm
		, a.lpa_date, b.eligeff, b.eligend, b.product, b.state, b.yrdob, gdr_cd
		%let groups=mi*pad*stroke*unsta_angina*sta_angina*tia*revasc*throm*cabg*endar*pci*angio_stent;
		%do i=1 %to 12;
		%let ad = %scan(&groups., &i., *);
		,case when datediff(a.index_date_&ad.,b.eligeff) >= 365.25 and (a.index_date_&ad. between b.eligeff and b.eligend) then a.index_date_&ad. else ' ' end as index_date_&ad.
		%end;
	FROM dingyig._01_cohort_2&table. a inner join src_optum_claims_panther.dod_mbr b
		on a.patid=b.patid and datediff(a.index_date_overall,b.eligeff) >= 365.25 and (a.index_date_overall between b.eligeff and b.eligend)
	WHERE RN=1
%create(_01_cohort_3&table.);

%mend;
%test(optum2_01_lpa_mg,a);		
%test(optum2_01_lpa_mol,b);		

%macro test(results,table);
/*Excludes patients with missing patid*/	
%create(_01_cohort_4&table.)
	select *
	FROM dingyig._01_cohort_3&table.
	WHERE patid is not null
%create(_01_cohort_4&table.);

%mend;
%test(optum2_01_lpa_mg,a);		
%test(optum2_01_lpa_mol,b);		

%macro test(results,table);
/*Excludes patients with missing year of birth*/	
%create(_01_cohort_5&table.)
	select *
	FROM dingyig._01_cohort_4&table. 
	WHERE yrdob is not null
%create(_01_cohort_5&table.);

%mend;
%test(optum2_01_lpa_mg,a);		
%test(optum2_01_lpa_mol,b);		

%macro test(results,table);
/*Excludes patients with missing gender*/	
%create(_01_cohort_6&table.)
	select *
	FROM dingyig._01_cohort_5&table.
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


%macro test(table);
%create(_01_cohort_6&table.)
	select a.patid,a.grp,a.cat,a.tst_desc,a.rslt_nbr,a.rslt_unit_nm,a.lpa_date,a.eligeff,a.eligend,a.product,a.state,a.yrdob,a.gdr_cd,
	a.index_date_mi,a.index_date_pad,a.index_date_stroke,a.index_date_unsta_angina,a.index_date_sta_angina,a.index_date_tia
	,a.index_date_revasc,a.index_date_throm,a.index_date_cabg,a.index_date_endar,a.index_date_pci,a.index_date_angio_stent
	,b.index_date_cvd, case when b.index_date_cvd is not null then b.index_date_noncvd end as index_date_noncvd
	,least(coalesce(b.index_date_cvd, b.index_date_noncvd),coalesce(b.index_date_noncvd, b.index_date_cvd)) as index_date_overall
	from dingyig._01_cohort_5&table. a inner join dingyig._01_cohort_1b b
		on a.patid=b.patid
	WHERE gdr_cd is not null and gdr_cd<>'U' 
%create(_01_cohort_6&table.)
%mend;
%test(a);
%test(b);


