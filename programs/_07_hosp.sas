/*Hospitalization*/
* conf_id or los were used to check the database;
* All hospitalization in Confinement table and Medical table;

%create(_07_hosp0)
		select patid, conf_id, admit_date as fst_dt, disch_date as lst_dt, los, 'c' as tb
		from src_optum_claims_panther.dod_c
		where patid in (select distinct patid from dingyig._04_cohort_setup)
		and to_date(admit_date) <='2020-06-30 23:59:59.99' 
		union
		select a.patid, a.conf_id, a.fst_dt, a.lst_dt1 as lst_dt, datediff(a.lst_dt,a.fst_dt)+1 as los, 'm' as tb
		from (select *, case when lst_dt is null then fst_dt else lst_dt end as lst_dt1 from src_optum_claims_panther.dod_m) as a
		where a.pos in (&inp_pos.) and a.patid in (select distinct patid from dingyig._04_cohort_setup)
		and to_date(a.fst_dt) <='2020-06-30 23:59:59.99'
%create(_07_hosp0);


* Add ER visit: if ER date is one day prior to the inpatient visits, they are considered a continuous hospitalization;
* generate continuous ER visits;
%create(_07_er)
	SELECT DISTINCT starts.patid
	        , starts.fst_dt AS fst_dt
	        , ends.lst_dt AS lst_dt
		FROM ( 
				SELECT patid, fst_dt, ROW_NUMBER() OVER (ORDER BY patid, fst_dt) AS rn
	 			FROM ( 
						SELECT patid, fst_dt, lst_dt,
			 				CASE WHEN DATEDIFF(fst_dt, prev_end) <= (0+1) THEN "cont" ELSE "new" END AS start_status,
			 				CASE WHEN DATEDIFF(next_start, lst_dt) <= (0+1) THEN "cont" ELSE "new" END AS end_status
						FROM ( 
								SELECT a.patid, a.fst_dt, a.lst_dt,
								COALESCE(LAG(a.lst_dt,1) OVER (PARTITION BY a.patid ORDER BY a.fst_dt,a.lst_dt), null) as prev_end,
								COALESCE(LEAD(a.fst_dt,1) OVER (PARTITION BY a.patid ORDER BY a.fst_dt,a.lst_dt), null) as next_start
			 					FROM (select patid, fst_dt, case when lst_dt is null then fst_dt else lst_dt end as lst_dt, pos from src_optum_claims_panther.dod_m) as a
			 					where a.pos in (&er_pos.) and a.patid in (select distinct patid from dingyig._04_cohort_setup)
			 					) AS t1
					) AS t2
		 		WHERE start_status= "new"
			) AS starts,
			( 
				SELECT patid, lst_dt, ROW_NUMBER() OVER (ORDER BY patid, fst_dt) AS rn
	 			FROM ( 
						SELECT patid, fst_dt, lst_dt,
				 			CASE WHEN DATEDIFF(fst_dt, prev_end) <= (0+1) THEN "cont" ELSE "new" END AS start_status,
				 			CASE WHEN DATEDIFF(next_start, lst_dt) <= (0+1) THEN "cont" ELSE "new" END AS end_status
	 					FROM ( 
							SELECT a.patid, a.fst_dt, a.lst_dt,
							COALESCE(LAG(a.lst_dt,1) OVER (PARTITION BY a.patid ORDER BY a.fst_dt,a.lst_dt), null) as prev_end,
							COALESCE(LEAD(a.fst_dt,1) OVER (PARTITION BY a.patid ORDER BY a.fst_dt,a.lst_dt), null) as next_start
		 					FROM (select patid, fst_dt, case when lst_dt is null then fst_dt else lst_dt end as lst_dt, pos from src_optum_claims_panther.dod_m) as a 
		 					where a.pos in (&er_pos.) and a.patid in (select distinct patid from dingyig._04_cohort_setup)
	 					  ) AS t3
				) AS t4
				WHERE end_status= "new"
				) AS ends
				WHERE starts.rn = ends.rn
%create(_07_er);

* select ER one day prior to the hospitalization;
%create(_07_er2)
		select a.patid, a.fst_dt, b.lst_dt, datediff(b.lst_dt,a.fst_dt)+1 as los, 'er' as tb /*ER claims one day prior to the hospitalization*/
					from dingyig._07_hosp0 as a inner join dingyig._07_er as b
					on a.patid=b.patid and datediff(a.fst_dt,b.lst_dt)=1 /*select one day prior to the admit date*/
%create(_07_er2);	


* Combine Hospitalization and ER and make hospitalization with continuous visits;		
%create(_07_hosp_er_set)
	SELECT DISTINCT starts.patid
	        , starts.fst_dt AS fst_dt
	        , ends.lst_dt AS lst_dt
		FROM ( 
				SELECT patid, fst_dt, ROW_NUMBER() OVER (ORDER BY patid, fst_dt) AS rn
	 			FROM ( 
						SELECT patid, fst_dt, lst_dt,
			 				CASE WHEN DATEDIFF(fst_dt, prev_end) <= (0+1) THEN "cont" ELSE "new" END AS start_status,
			 				CASE WHEN DATEDIFF(next_start, lst_dt) <= (0+1) THEN "cont" ELSE "new" END AS end_status
						FROM ( 
								SELECT a.patid, a.fst_dt, a.lst_dt,
								COALESCE(LAG(a.lst_dt,1) OVER (PARTITION BY a.patid ORDER BY a.fst_dt,a.lst_dt), null) as prev_end,
								COALESCE(LEAD(a.fst_dt,1) OVER (PARTITION BY a.patid ORDER BY a.fst_dt,a.lst_dt), null) as next_start
			 					FROM (select patid, fst_dt, lst_dt from dingyig._07_hosp0 union select patid, fst_dt, lst_dt from dingyig._07_er2) as a
			 					) AS t1
					) AS t2
		 		WHERE start_status= "new"
			) AS starts,
			( 
				SELECT patid, lst_dt, ROW_NUMBER() OVER (ORDER BY patid, fst_dt) AS rn
	 			FROM ( 
						SELECT patid, fst_dt, lst_dt,
				 			CASE WHEN DATEDIFF(fst_dt, prev_end) <= (0+1) THEN "cont" ELSE "new" END AS start_status,
				 			CASE WHEN DATEDIFF(next_start, lst_dt) <= (0+1) THEN "cont" ELSE "new" END AS end_status
	 					FROM ( 
							SELECT a.patid, a.fst_dt, a.lst_dt,
							COALESCE(LAG(a.lst_dt,1) OVER (PARTITION BY a.patid ORDER BY a.fst_dt,a.lst_dt), null) as prev_end,
							COALESCE(LEAD(a.fst_dt,1) OVER (PARTITION BY a.patid ORDER BY a.fst_dt,a.lst_dt), null) as next_start
		 					FROM (select patid, fst_dt, lst_dt from dingyig._07_hosp0 union select patid, fst_dt, lst_dt from dingyig._07_er2) as a
	 					  ) AS t3
				) AS t4
				WHERE end_status= "new"
				) AS ends
				WHERE starts.rn = ends.rn
%create(_07_hosp_er_set);

* Merge conf_id and diag: diag in Confinement table was preferred over diagnosis table;
%macro hosp_diag;
	%create(_07_hosp_er_diag)
			%do i=1 %to 5;
				select distinct a.*, b.conf_id, b.diag&i. as diag, case when b.patid is not null then "0&i." else '99' end as diag_position /*checked all conf_id had diag*/
				from dingyig._07_hosp_er_set as a left join src_optum_claims_panther.dod_c as b /*use Confinement table*/
				on a.patid=b.patid and b.admit_date between a.fst_dt and a.lst_dt 
				union
			%end;	
			/*Note: some multiple conf_id had continuous admit_date and disch_date, --> this is one hospitalizaiton*/
			select x.*, 'NA' as conf_id, y.diag, y.diag_position
			from dingyig._07_hosp_er_set as x
				left join (select a.patid, a.fst_dt, b.diag, case when b.diag_position is null then '99' else b.diag_position end as diag_position
							from src_optum_claims_panther.dod_m as a 
								inner join src_optum_claims_panther.dod_diag as b /*use Diagnosis table*/
							on a.pat_planid=b.pat_planid and a.clmid=b.clmid and a.loc_cd=b.loc_cd
							where a.pos in (&inp_pos.,&er_pos.) and a.patid in (select patid from dingyig._07_hosp_er_set)) as y
				on x.patid=y.patid and y.fst_dt between x.fst_dt and x.lst_dt	
		%create(_07_hosp_er_diag);
%mend hosp_diag;
%hosp_diag;


* changed to primary diagnosis;
%create(_07_hosp_er_diag_prim)
		select distinct z.*
		from (select a.*, rank() over (partition by a.patid, a.fst_dt order by a.patid, a.fst_dt, a.diag_position) as rn /*choose DIAG1 in confinement and first diag_position in diagnosis table*/
			from dingyig._07_hosp_er_diag as a
			) as z
		where z.rn=1 
%create(_07_hosp_er_diag_prim);

* ASCVD;
%macro hosp_ascvd;
	%create(_07_hosp_ascvd)
			select distinct patid, fst_dt, lst_dt
			%do i=1 %to 7;
				%let dx =%scan(mi*pad*stroke*tia*unsta_angina*sta_angina*other, &i., *); /*chd and cerebrovascular are optional*/
				, case when (substr(diag,1,3) in (&&&dx.) 
						or substr(diag,1,4) in (&&&dx.) 
						or substr(diag,1,5) in (&&&dx.) 
						or substr(diag,1,6) in (&&&dx.)) 
					then 1 else 0
				end as &dx.
			%end;
			, 0 as revasc
			from dingyig._07_hosp_er_diag_prim
			union
			select distinct a.patid, a.fst_dt, a.lst_dt
				, 0 as mi, 0 as pad, 0 as stroke, 0 as tia, 0 as unsta_angina, 0 as sta_angina, 0 as other
					, case when b.patid is not null and b.grp = "revasc" then 1 else 0 end as revasc /*choose all procedure code because cant identify primary procedure*/
				/*revascularization*/	
			from dingyig._07_hosp_er_diag_prim as a left join (select * from dingyig.optum2_01_proc where pos in (&inp_pos.,&er_pos.) and grp in ('revasc')) as b
			on a.patid=b.patid and b.dt between a.fst_dt and a.lst_dt
	%create(_07_hosp_ascvd);
%mend hosp_ascvd;
%hosp_ascvd;

/*Lpa measurements for hospitalizations*/
	%create(_07_hosp_lpa)
		select distinct a.patid, a.fst_dt, a.lst_dt
		, case when b.grp='lpa_mg' and rslt_NBR <  30 then 1 else 0 end as mg30
		, case when b.grp='lpa_mg' and RSLT_NBR <  50 then 1 else 0 end as mg50
		, case when b.grp='lpa_mg' and 30 <=  RSLT_NBR and RSLT_NBR <  50 then 1 else 0 end as mg30_50
		, case when b.grp='lpa_mg' and 50 <=  RSLT_NBR and RSLT_NBR <  70 then 1 else 0 end as mg50_70
		, case when b.grp='lpa_mg' and 70 <=  RSLT_NBR and RSLT_NBR <  90 then 1 else 0 end as mg70_90
		, case when b.grp='lpa_mg' and 90 <=  RSLT_NBR and RSLT_NBR <  120 then 1 else 0 end as mg90_120
		, case when b.grp='lpa_mg' and 70 <=  RSLT_NBR then 1 else 0 end as mg70
		, case when b.grp='lpa_mg' and 90 <=  RSLT_NBR then 1 else 0 end as mg90
		, case when b.grp='lpa_mg' and 120 <=  RSLT_NBR then 1 else 0 end as mg120
		, case when b.grp='lpa_mg' and 150 <=  RSLT_NBR then 1 else 0 end as mg150
	, case when b.grp='lpa_mol' and rslt_NBR <  65 then 1 else 0 end as mol65
		, case when b.grp='lpa_mol' and  RSLT_NBR <  105 then 1 else 0 end as mol105
		, case when b.grp='lpa_mol' and  65 <=  RSLT_NBR and RSLT_NBR <  105 then 1 else 0 end as mol65_105
		 ,case when b.grp='lpa_mol' and  105 <=  RSLT_NBR and RSLT_NBR <  150 then 1 else 0 end as mol105_150
		 ,case 	when b.grp='lpa_mol' and  150 <=  RSLT_NBR and RSLT_NBR <  190 then 1 else 0 end as mol150_190
		 ,case 	when b.grp='lpa_mol' and  190 <=  RSLT_NBR and RSLT_NBR <  255 then 1 else 0 end as mol190_255
		, case when b.grp='lpa_mol' and  150 <=  RSLT_NBR then 1 else 0 end as mol150
		, case when b.grp='lpa_mol' and  190 <=  RSLT_NBR then 1 else 0 end as mol190
		, case when b.grp='lpa_mol' and  255 <=  RSLT_NBR then 1 else 0 end as mol255
		, case when b.grp='lpa_mol' and  320 <=  RSLT_NBR then 1 else 0 end as mol320
 		from dingyig._07_hosp_er_diag_prim as a left join dingyig.ldlc_04_lab2 b
 			on a.patid=b.patid and b.grp in ('lpa_mg','lpa_mol') and b.fst_dt between a.fst_dt and a.lst_dt
	%create(_07_hosp_lpa);
	

/*ICU */
%let icu = %str('0206','0233');
%create(_07_icu0)
			select distinct patid, fst_dt as dt
			from src_optum_claims_panther.dod_m
			where rvnu_cd in (&icu.) and pos in (&inp_pos.,&er_pos.) /*Revenue code in Medical table*/
			union
			select distinct a.patid, a.fst_dt as dt
			from src_optum_claims_panther.dod_m as a
				inner join (select distinct * from src_optum_claims_panther.dod_fd where rvnu_cd in (&icu.)) as b /*Revenue code in Facility table*/			
			on a.pat_planid=b.pat_planid and a.clmid=b.clmid and a.clmseq=b.clmseq and a.fst_dt=b.fst_dt
			where a.pos in (&inp_pos.,&er_pos.)
/* 			union */
/* 			select distinct a.patid, a.admit_date as dt */
/* 			from src_optum_claims_panther.dod_c as a */
/* 			where a.icu_ind='Y' */ /*icu_ind is not validated*/
%create(_07_icu0);

%create(_07_icu)
			select a.patid, a.fst_dt, count(distinct b.dt) as icu_los /*max: 7 days*/
			from dingyig._07_hosp_ascvd as a inner join dingyig._07_icu0 as b
			on a.patid=b.patid and b.dt between a.fst_dt and a.lst_dt
			group by a.patid, a.fst_dt
%create(_07_icu);


/*Rehabilitation*/
%let rehab_drg = %str('462','945','946');
%let rehab_pos = %str('31','61','62');
%let rehab_rvnu = %str('0024','0118','0128','0138','0148','0158','0911','0931','0932','0943','0022','0550','0551','0552','0559');
%let rehab_tos = %str('FAC_IP.REHSNF','FAC_IP.SNF','PROF.PHYMED');
%let rehab_provcat = %str('0067','0068','0069','0772','0773','0774','0775','0776','0777','0778','0779','0780','0781','0782','0783','0784'
					,'0785','0786','0787','0788','0789','0790','0791','0792','0793','0794','1034','1035','1114','1120','1153','1180','1184'
					,'1189','1335','1368','1370','1372','1374','1376','1378','1379','1380','1382','1384','1388','1390','1392','1394','1396'
					,'1398','1400','1402','1404','1406','1408','1410','1412','1414','1416','1418','1420','1422','1424','1426','1428','1430'
					,'1432','1434','1465','1509','1560','1562','1591','1683','1834','1878','1879','1890','1893','1951','1971','1978','1982'
					,'2012','2116','2184','2186','2212','2235','2261','2271','2296','2327','2349','2455','2461','2550','2633','2662','2667'
					,'2687','2705','2775','2820','2875','2893','2900','2943','2960','2963','2964','2967','2993','3036','3072','3164','3173'
					,'3181','3182','3190','3223','3260','3269','3281','3309','3347','3362','3383','3398','3434','3472','3505','3571','3584'
					,'3592','3679','3700','3729','3759','3821','3863','3895','3906','3965','3977','3999','4086','4146','4156','4215','4275'
					,'4340','4635','5607','5772','5779','5782','5856','5863','5884','5887','5910','6696','6711','6789','6842','6977','7048'
					,'7053','7066','7076','7083','7119','7209','7263');
%let rehab_proc = %str('4510F','93668','93797','93798','G0422','G0423','G8699','G8700','S9472');

%create(_07_reh0)
		select distinct patid, fst_dt as dt
		/*Medical table*/
		from src_optum_claims_panther.dod_m
		where pos in (&inp_pos.,&er_pos.)
			and (drg in (&rehab_drg.) or pos in (&rehab_pos.) or rvnu_cd in (&rehab_rvnu.) or provcat in (&rehab_provcat.) or proc_cd in (&rehab_proc.) or tos_cd in (&rehab_tos.))
			and patid in (select distinct patid from dingyig._04_cohort_setup)
		union
		/*Facility Detail file*/
		select distinct a.patid, a.fst_dt as dt
		from (select distinct * from src_optum_claims_panther.dod_m where pos in (&inp_pos.,&er_pos.)) as a
			inner join (select distinct * from src_optum_claims_panther.dod_fd where rvnu_cd in (&rehab_rvnu.) or proc_cd in (&rehab_proc.)) as b
			on a.pat_planid=b.pat_planid and a.clmid=b.clmid and a.clmseq=b.clmseq and a.fst_dt=b.fst_dt
		where a.patid in (select distinct patid from dingyig._04_cohort_setup)
		union
		/*Confinement table*/
		select distinct patid, admit_date as dt
		from src_optum_claims_panther.dod_c
		where (drg in (&rehab_drg.) or pos in (&rehab_pos.) or tos_cd in (&rehab_tos.))
			and patid in (select distinct patid from dingyig._04_cohort_setup)
%create(_07_reh0);	
		
%create(_07_reh)
			select a.patid, a.fst_dt, count(distinct b.dt) as reh_los
			from dingyig._07_hosp_ascvd as a inner join dingyig._07_reh0 as b
			on a.patid=b.patid and b.dt between a.fst_dt and a.lst_dt
			group by a.patid, a.fst_dt
%create(_07_reh);
		
* merge ICU, Rehabilitation and Lpa Measurements;
%create(_07_hosp_final)
			select distinct a.*, b.icu_los, c.reh_los
			,d.mg30,d.mg50,d.mg30_50,d.mg50_70,d.mg70_90,d.mg90_120,d.mg70,d.mg90,d.mg120,d.mg150,d.mol65,d.mol105,d.mol65_105,d.mol105_150,d.mol150_190,d.mol190_255,d.mol150,d.mol190,d.mol255,d.mol320
			from dingyig._07_hosp_ascvd as a 
				left join dingyig._07_icu as b on a.patid=b.patid and a.fst_dt=b.fst_dt
				left join dingyig._07_reh as c on a.patid=c.patid and a.fst_dt=c.fst_dt
				left join dingyig._07_hosp_lpa d on a.patid=d.patid and a.fst_dt=d.fst_dt
%create(_07_hosp_final);


/*save to SAS*/
data _07_hosp;
	set heor._07_hosp_final;
run;


/*patients enrolled continuously for time period*/
%macro enroll;
	%do z=1 %to 2;
	%let groups=overall*mi*pad*stroke*unsta_angina*sta_angina*tia*other*revasc*cvd*anginatia*noncvd;
		%do zz=1 %to 12;
		
		%let ad = %scan(&groups., &zz., *);
	/*change variables for cohort2*/
	data  _07_primary_&z.&ad. ;
	set derived._02_primary_&z.;
		%do t=1 %to 14;
			%let dt = %scan(lpa_date*eligend*eligeff*index_date_overall*index_date_mi*index_date_stroke*index_date_pad*index_date_unsta_angina*index_date_sta_angina*index_date_tia*index_date_other*index_date_revasc*index_date_cvd*index_date_anginatia, &t., *);
			format &dt.2 date9.;
			&dt.2=datepart(&dt.);
			drop &dt.;
			rename &dt.2=&dt.;
		%end;
		
		run;
		
	proc sql;
		create table derived._07_primary_&z.&ad. as 
		select a.*
		,case when eligend>=index_date_&ad. +365.25 then 1 end as one_year
		,case when eligend>=index_date_&ad. +(365.25*2) then 1 end as two_years
		from _07_primary_&z.&ad.  a;
	quit;	
		
	%end;
	%end;
%mend;
%enroll;



%macro char_correct;
	data _07_hosp_pre;
		set _07_hosp;
		%do t=1 %to 2;
			%let dt = %scan(fst_dt*lst_dt, &t., *);
			format &dt.2 date9.;
			&dt.2=datepart(&dt.);
			drop &dt.;
			rename &dt.2=&dt.;
		%end;
	run;
	
%mend char_correct;
%char_correct;


/*hospitalizations need all,  1 and 2 years*/
options mprint;	
%macro hosp(time, num, year);
/*cohort 1*/
%do z=1 %to 2;
%let groups=overall*mi*pad*stroke*unsta_angina*sta_angina*tia*other*revasc*cvd*anginatia*noncvd;
		%do zz=1 %to 12;
		
		%let ad = %scan(&groups., &zz., *);
	proc sql;
		create table _07_hosp_&ad.&z. as 
		select distinct a.patid, a.eligeff, a.eligend, a.index_date_&ad., b.*
		from derived._07_primary_&z.&ad.  as a 
			left join (select distinct patid, fst_dt, lst_dt
						%do i=1 %to 30;
							%let grp =%scan(mi*pad*stroke*tia*unsta_angina*sta_angina*other*revasc
											*icu_los*reh_los*mg30*mg50*mg30_50*mg50_70*mg70_90*mg90_120*mg70*mg90*mg120*mg150*mol65*mol105*mol65_105*mol105_150
											*mol150_190*mol190_255*mol150*mol190*mol255*mol320, &i., *);
							, max(&grp.) as &grp.
						%end;
						from _07_hosp_pre
						group by patid, fst_dt
						) as b
		on a.patid=b.patid 
			and a.index_date_&ad. lt b.fst_dt le (&time.)
			and a.eligeff le b.fst_dt le a.eligend;	
	quit;
	


data _07_hosp2_&ad.&z.; 
	set _07_hosp_&ad.&z.;
	
	* length of stay;
	los=lst_dt-fst_dt+1;
	
	* diagnosis;
	if mi=1 then hosp_mi=1; 
	if stroke=1 then hosp_stroke=1;
	if pad=1 or acute_pao=1 or aotic=1 or inter_clau=1 or limb=1 then hosp_pad=1;
	if unsta_angina=1 then hosp_angina=1;
	if revasc=1 then hosp_revasc=1;
	if sta_angina=1 or tia=1 then hosp_other=1;
	
	* ICU and rehabilitation;
	if reh_los ge 1 and (mi=1 or stroke=1 or hosp_pad=1) then reh_cvd=1;
	if icu_los ge 1 then icu=1;
	
	if hosp_mi=1 or hosp_stroke=1 or hosp_pad=1 or hosp_angina=1 or hosp_revasc=1 or hosp_other=1 then hosp_ascvd=1;
	/*rates for MI, PAD or REVASC*/
	if hosp_mi=1 or hosp_stroke=1 or hosp_revasc=1 then hosp_mi_is_re=1;
run;

	proc sql;
		create table _07_hosp3&ad.&z. as
		select distinct patid
				, index_date_&ad., eligeff, eligend, max(lst_dt) as lst_dt format date9.
				, count(distinct fst_dt) as n_hosp
			/* number of hospitalizations */
			%do r=1 %to 37;
				%let cat =%scan(mi*unsta_angina*sta_angina*stroke*tia*pad
								*hosp_ascvd*hosp_mi*hosp_stroke*hosp_pad*hosp_angina*hosp_revasc*hosp_other*reh_cvd*icu
								*los*hosp_mi_is_re*mg30*mg50*mg30_50*mg50_70*mg70_90*mg90_120*mg70*mg90*mg120*mg150*mol65*mol105*mol65_105*mol105_150
											*mol150_190*mol190_255*mol150*mol190*mol255*mol320, &r., *);
				, sum(case when &cat. > 0 then &cat. else 0 end) as &cat.
			%end;
			/* length of stay */
			%do j=1 %to 36;
				%let sub = %scan(mi*unsta_angina*sta_angina*stroke*tia*pad
								*hosp_ascvd*hosp_mi*hosp_stroke*hosp_pad*hosp_angina*hosp_revasc*hosp_other*reh_cvd*icu*hosp_mi_is_re
								*mg30*mg50*mg30_50*mg50_70*mg70_90*mg90_120*mg70*mg90*mg120*mg150*mol65*mol105*mol65_105*mol105_150
											*mol150_190*mol190_255*mol150*mol190*mol255*mol320, &j., *);
				, sum(case when &sub. > 0 then los else 0 end) as &sub._los
			%end;
			, sum(case when icu_los > 0 then icu_los else 0 end) as icu_stay_los /*only number of days with ICU*/
			, sum(case when reh_cvd > 0 then reh_los else 0 end) as reh_cvd_stay_los /*only number of days with rehabilitation*/
		from _07_hosp2_&ad.&z.
		group by patid;
	quit;
	
	
	
data derived._07_hosp&ad.&z.&year;
	set _07_hosp3&ad.&z.;
	* person-year;
	py=max((eligend-index_date_&ad.+1),(lst_dt-index_date_&ad.+1)) / 365.25;
	if py ge &num. then py=&num.;
	ln_py=log(py);
	
run;

		%end;
	%end;
%mend ;
%hosp(a.index_date_&ad.+365.25, 1, one_year);
%hosp(a.index_date_&ad.+(365.25*2), 2, two_years);	
%hosp(a.eligend, 11, all);	
