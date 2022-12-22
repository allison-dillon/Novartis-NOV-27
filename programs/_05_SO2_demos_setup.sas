/*Demo - Secondary objective 2*/
* will convert all chatacter variable to numerical in order to save time when saving in SAS;

/* PROC SQL; DROP TABLE heor._07_primary_2OVERALL; QUIT; */
/* PROC SQL; */
/* 	CREATE TABLE  heor._07_primary_2OVERALL AS */
/* 	SELECT put(patid,20.) as patid,grp,	cat,	tst_desc,	rslt_nbr	,rslt_unit_nm	,product	,state	,gdr_cd	,rslt_grp65	,rslt_grp105,	rslt_grp,	rslt_grp150,	rslt_grp190,	rslt_grp255,	rslt_grp320,	lpa_date,	eligend,	eligeff,	index_date_overall,	index_date_mi,	index_date_stroke,	index_date_pad,	index_date_unsta_angina	,index_date_sta_angina,	index_date_tia,	index_date_other,	index_date_revasc,	index_date_cvd	,index_date_anginatia	,one_year */
/* 	FROM derived._07_primary_2overall; */
/* quit; */
/*  */
/*  */
/* %macro main; */
/*  */
/* %let groups=overall; */
/* 		%do i=1 %to 1; */
/* 		%let ad = %scan(&groups., &i., *); */
/* %create(_07_primary_&ad.) */
/* 	select CAST(patid as BIGINT) as patid,grp,	cat,	tst_desc,	rslt_nbr	,rslt_unit_nm	,product	,state	,gdr_cd	,rslt_grp65	,rslt_grp105,	rslt_grp,	rslt_grp150,	rslt_grp190,	rslt_grp255,	rslt_grp320,	lpa_date,	eligend,	eligeff,	index_date_overall,	index_date_mi,	index_date_stroke,	index_date_pad,	index_date_unsta_angina	,index_date_sta_angina,	index_date_tia,	index_date_other,	index_date_revasc,	index_date_cvd	,index_date_anginatia	,one_year */
/* 	FROM dingyig._07_primary_2&ad. */
/* %create(_07_primary_&ad.); */
/* 	%end; */
/* %mend; */
/* %main;	 */

%macro index_date;
%let cohorts=a*b;
	%do z=2 %to 2;
	%let ct = %scan(&cohorts., &z., *);

%let groups=overall*mi*pad*stroke;
		%do i=1 %to 4;
		%let ad = %scan(&groups., &i., *);
%create(ldlc_05_demo_pre_&ad.&z.)
	SELECT *
	FROM (
		select a.*
			,b.yrdob
			, case when B.gdr_cd='F' then 1
				when B.gdr_cd='M' then 2 
				when B.gdr_cd='U' then 3 end as gdr_cd0
			, year(a.index_date_&ad.) as index_yr
			, (year(a.index_date_&ad.)-B.yrdob) as age
			, case when b.state in ('CT','ME','MA','NH','RI','VT') then 1
				when b.state in ('NJ','NY','PA') then 2
				when b.state in ('IL','IN','MI','OH','WI') then 3
				when b.state in ('IA','KS','MN','MO','NE','ND','SD') then 4
				when b.state in ('DE','DC','FL','GA','MD','NC','SC','VA','WV') then 5
				when b.state in ('AL','KY','MS','TN') then 6
				when b.state in ('AR','LA','OK','TX') then 7
				when b.state in ('AZ','CO','ID','MT','NV','NM','UT','WY') then 8
				when b.state in ('AK','CA','HI','OR','WA') then 9
				else 10 end as region0
			, case when b.bus='COM' then 1
				when b.bus='MCR' then 2 end as bus0
			,b.race
			,b.eligeff as eligeff1
			,b.eligend as eligend1
			,row_number() over (partition by a.patid order by a.index_date_overall) as rn
			from dingyig._07_primary_&ad. as a
				left join src_optum_claims_panther.dod_mbr_detail as b 
				on a.patid=b.patid and a.index_date_&ad. between b.eligeff and b.eligend 
		) a
		WHERE RN=1

%create(ldlc_05_demo_pre_&ad.&z.);
	%end;
	%end;
%mend;
%index_date;


options mprint;
* index ASCVD diagnosis;
%macro  index_ascvd;
%let cohorts=a*b;
	%do z=2 %to 2;
	%let ct = %scan(&cohorts., &z., *);

%let groups=overall*mi*pad*stroke;
		%do zz=1 %to 4;
		%let ad = %scan(&groups., &zz., *);
	%create(ldlc_05_index_dx_&ad.&z.)
		select distinct a.*
			%do f=1 %to 11;
				%let dx =%scan(overall*mi*pad*stroke*unsta_angina*sta_angina*tia*revasc*cvd*other*anginatia, &f., *);
				, case when a.index_date_&dx. >='2008-01-01 00:00:00.00' then 1 end as index_&dx. 
			%end;
			
		from dingyig.ldlc_05_demo_pre_&ad.&z. as a 
	%create(ldlc_05_index_dx_&ad.&z.)
	%end;
	%end;
%mend index_ascvd;
%index_ascvd;

* Comorbidities + Obesity-any time prior;
%macro comor_demo;
	%do z=2 %to 2;
	
%let groups=overall*mi*pad*stroke;
		%do zz=1 %to 4;
		%let ad = %scan(&groups., &zz., *);
		
	* Comorbidities + Obesity, Sedentarism, and Smoking status;
	%create(ldlc_05_demo_comor0_&ad.&z.)
			select a.patid, a.grp, a.index_date_&ad.
			%do t=1 %to 25;
				%let dx =%scan(af*cardiac_amy*hypertension*ckd*ckd2*ckd3*ckd45*hf
							*alzheimer*anemia*cancer*copd*cognitive*dementia*depression*diabete*mix_dyslipid*hypercholest*liver*obesity*rheumathoid*sleep*seden*smoke*valvular, &t., *);
				, (case when sum(a.&dx.)>0 then 1 else 0 end) as &dx.
			%end;
			from (select distinct a.patid, 'overall' as grp, a.index_date_&ad.
				%do t=1 %to 25;
					%let dx =%scan(af*cardiac_amy*hypertension*ckd*ckd2*ckd3*ckd45*hf
							*alzheimer*anemia*cancer*copd*cognitive*dementia*depression*diabete*mix_dyslipid*hypercholest*liver*obesity*rheumathoid*sleep*seden*smoke*valvular
								, &t., *);
					, case when b.patid is not null and b.grp = "&dx." and b.dt < a.index_date_&ad. then 1 end as &dx. 
				%end;
				from dingyig.ldlc_05_index_dx_&ad.&z. as a 
					left join dingyig.ldlc_04_comor as b on a.patid=b.patid and b.dt < a.index_date_&ad.
				) as a
			group by a.patid, a.grp, a.index_date_&ad.
	%create(ldlc_05_demo_comor0_&ad.&z.);
	%end;
	%end;
%mend comor_demo;
%comor_demo;	
	

%macro  comor_demo;
	%do z=2 %to 2;
%let groups=overall*mi*pad*stroke;
		%do zz=1 %to 4;
		%let ad = %scan(&groups., &zz., *);
	%create(ldlc_05_demo_comor0_1_&ad.&z.)
		select distinct u.patid, u.grp, u.af, u.cardiac_amy, u.hypertension, u.ckd, u.ckd2, u.ckd3, u.ckd45, u.hf
				, u.alzheimer, u.anemia, u.cancer, u.copd, u.cognitive, u.dementia, u.depression, u.diabete, u.mix_dyslipid, u.hypercholest, u.liver
				, u.obesity, u.rheumathoid, u.sleep, u.seden, u.smoke
				,coalesce(u.valvular, b.valvular_proc) as valvular
		from dingyig.ldlc_05_demo_comor0_&ad.&z. u left join dingyig.ldlc_04_proc b
			on u.patid=b.patid  and b.dt < u.index_date_&ad.
	%create(ldlc_05_demo_comor0_1_&ad.&z.);
	%end;
	%end;
%mend;
%comor_demo;

* lab data one year prior to index;
%macro demo_lab;
%do z=2 %to 2;
	
%let groups=overall*mi*pad*stroke;
		%do zz=1 %to 4;
		%let ad = %scan(&groups., &zz., *);
	%create(ldlc_05_demo_lab_&ad.&z.)
			select distinct q.*
			/* merge comorbidities*/
			, u.af, u.cardiac_amy, u.hypertension, u.ckd, u.ckd2, u.ckd3, u.ckd45, u.hf
						, u.alzheimer, u.anemia, u.cancer, u.copd, u.cognitive, u.dementia, u.depression, u.diabete, u.mix_dyslipid, u.hypercholest, u.liver, u.obesity, u.rheumathoid, u.sleep, u.seden, u.smoke
						, u.valvular
			%do r=1 %to 16;
				%let lab = %scan(sys_bp*dia_bp*ldlc*vldlc*hdlc*tc*tg*lpa_mg*lpa_mol*apob*hba1c*alt*ast*alp*ck*cprot, &r., *);
				, case when w&r..patid is not null then w&r..fst_dt end as &lab._dt
				, case when w&r..patid is not null then w&r..rslt_nbr end as &lab.

			%end;
		from dingyig.ldlc_05_index_dx_&ad.&z. as q
			left join dingyig.ldlc_05_demo_comor0_1_&ad.&z. as u on q.patid=u.patid 
			%do t=1 %to 16;
				%let lab = %scan(sys_bp*dia_bp*ldlc*vldlc*hdlc*tc*tg*lpa_mg*lpa_mol*apob*hba1c*alt*ast*alp*ck*cprot, &t., *);
				left join (select z.patid, z.grp, z.fst_dt, avg(z.rslt_nbr) as rslt_nbr
							from (select e.*, row_number() over (partition by e.patid, e.grp order by e.gap, e.fst_dt) as rn
								from (select a.patid, 'overall' as grp, b.fst_dt, b.rslt_nbr, abs(datediff(b.fst_dt,a.index_date_&ad.)) as gap
										from dingyig.ldlc_05_index_dx_&ad.&z. as a inner join (select * from dingyig.ldlc_04_lab1 
																			where year(to_date(fst_dt)) >= 2007 and year(to_date(fst_dt)) <= 2020 and rslt_nbr > 0 and rslt_nbr < 9999) as b 
										on a.patid=b.patid and b.grp="&lab." and datediff(b.fst_dt,a.index_date_&ad.) between -365.25 and -1 ) as e							
								) as z
							where z.rn=1
							group by z.patid, z.grp, z.fst_dt) as w&t. on q.patid=w&t..patid
			%end;
			
	%create(ldlc_05_demo_lab_&ad.&z.);
	%end;
	%end;
%mend demo_lab;
%demo_lab;

* procedure - use optum2_01_proc, not ldlc_01_proc_total, anytime prior to index;
%macro demo_proc;
%do z=2 %to 2;
%let groups=overall*mi*pad*stroke;
		%do zz=1 %to 4;
		%let ad = %scan(&groups., &zz., *);
%create(ldlc_05_demo_proc_&ad.&z.)
		select distinct q.*
			%do i=1 %to 2;
				%let proc_nm = %scan(aphe*dial, &i., *);	
				, case when w&i..patid is not null and w&i..dt<q.index_date_&ad. then 1 end as &proc_nm.
			%end;
			
			, case when f.patid is not null and f.dt<q.index_date_&ad. then 1 end as revasc
			
		from dingyig.ldlc_05_demo_lab_&ad.&z. as q
			%do t=1 %to 2;
				%let proc_nm = %scan(aphe*dial, &t., *);	
				left join (select * from dingyig.optum2_01_other_proc where year(to_date(dt)) >= 2007 and year(to_date(dt)) <= 2020) as w&t. 
				on q.patid=w&t..patid and w&t..grp="&proc_nm." and w&t..dt<q.index_date_&ad.
			%end;
	
/* 			revasculartization */
			left join (select * from dingyig.optum2_01_proc0 where year(to_date(dt)) >= 2007 and year(to_date(dt)) <= 2020 
				and code in (select distinct code from dingyig.optum2_proc)) as f
			on q.patid=f.patid and f.grp='revasc' and f.dt<q.index_date_&ad.
						
%create(ldlc_05_demo_proc_&ad.&z.);
%end;
%end;
%mend;
%demo_proc;

options mprint;
%macro demo_proc;
%do z=2 %to 2;
%let groups=overall*mi*pad*stroke;
		%do zz=1 %to 4;
		%let ad = %scan(&groups., &zz., *);
%create(ldlc_05_demo_proc1_&ad.&z.)
		select distinct q.*
		
		%do i=1 %to 2;
				%let proc_nm = %scan(aphe*dial, &i., *);	
				, case when w&i..patid is not null and w&i..dt<=q.index_date_&ad. then 1 end as &proc_nm.1
			%end;
			
			, case when f.patid is not null and f.dt<=q.index_date_&ad. then 1 end as revasc1
			
		from dingyig.ldlc_05_demo_proc_&ad.&z. as q
		%do t=1 %to 2;
				%let proc_nm = %scan(aphe*dial, &t., *);	
				left join (select * from dingyig.optum2_01_other_proc where year(to_date(dt)) >= 2007 and year(to_date(dt)) <= 2020) as w&t. 
				on q.patid=w&t..patid and w&t..grp="&proc_nm." and w&t..dt<=q.index_date_&ad.
			%end;
	
/* 			revasculartization */
			left join (select * from dingyig.optum2_01_proc0 where year(to_date(dt)) >= 2007 and year(to_date(dt)) <= 2020 
				and code in (select distinct code from dingyig.optum2_proc)) as f
			on q.patid=f.patid and f.grp='revasc' and f.dt<=q.index_date_&ad.
						
%create(ldlc_05_demo_proc1_&ad.&z.);
	%end;
	%end;
%mend;
%demo_proc;


* Cholesterol lowering treatment;
%macro demo_tx;
%do z=2 %to 2;
%let groups=overall*mi*pad*stroke;
		%do zz=1 %to 4;
		%let ad = %scan(&groups., &zz., *);
%create(ldlc_05_demo_tx_&ad.&z.)
		select distinct q.*
			%do i=1 %to 16;
				%let tx = %scan(Statins*PCSK9i*Ezetimibe*Fibrates*Niacin*Mipomersen*Tocilizumab*Hormone*Fibrinolytic*Betablocker*ACE*Antiplatelet*Niacin_Statin*Loop_Diuretic*MRA*Anticoagulant, &i., *);	
				, case when w&i..patid is not null and datediff(w&i..dt,q.index_date_&ad.) between -365.25 and -1 then 1 end as &tx.
			%end;
		from dingyig.ldlc_05_demo_proc1_&ad.&z. as q
			%do t=1 %to 16;
				%let tx = %scan(Statins*PCSK9i*Ezetimibe*Fibrates*Niacin*Mipomersen*Tocilizumab*Hormone*Fibrinolytic*Betablocker*ACE*Antiplatelet*Niacin_Statin*Loop_Diuretic*MRA*Anticoagulant, &t., *);	
				left join dingyig.ldlc_04_drugs as w&t. 
				on q.patid=w&t..patid and w&t..generic="&tx." and datediff(w&t..dt,q.index_date_&ad.) between -365.25 and -1
			%end;						
	%create(ldlc_05_demo_tx_&ad.&z.)
			
			%end;
	%end;
%mend demo_tx;
%demo_tx;


%macro bringsas;
%do z=2 %to 2;
%let groups=overall*mi*pad*stroke;
		%do zz=1 %to 4;
		%let ad = %scan(&groups., &zz., *);
proc sql;
	create table derived._05_demo_&ad.&z. as
	select a.patid, a.index_date_overall, a.index_yr	,a.age,a.region0,a.bus0 ,a.eligeff,	a.eligend,	a.state,	a.gdr_cd	
				,index_date_overall, index_date_mi, index_date_pad, index_date_stroke,
				index_cvd, index_mi, index_pad, index_stroke, index_unsta_angina, index_sta_angina, index_tia, index_revasc, index_other, index_anginatia,
				aphe,	dial,	revasc, aphe1,	dial1,	revasc1, one_year
			
				,af,cardiac_amy,hypertension,ckd3,ckd45,hf, valvular
		
				,alzheimer,anemia,cancer,copd,cognitive,dementia,depression,diabete,mix_dyslipid,hypercholest,liver,obesity,rheumathoid,sleep	
						
				,Statins,PCSK9i,Ezetimibe,Fibrates,Niacin,Mipomersen,Tocilizumab,Hormone,Fibrinolytic,Betablocker,ACE,Antiplatelet,Niacin_Statin
				, Niacin_statin, Loop_Diuretic,MRA,Anticoagulant
				,ldlc,hdlc,tc,cprot,tg ,ckd ,ckd2 ,sys_bp ,sys_bp_dt ,dia_bp ,dia_bp_dt ,ldlc_dt 
				,vldlc ,vldlc_dt ,hdlc_dt ,tc_dt ,tg_dt ,lpa_mg ,lpa_mg_dt ,lpa_mol ,lpa_mol_dt ,apob ,apob_dt ,hba1c ,hba1c_dt ,alt ,alt_dt ,ast ,ast_dt ,alp ,alp_dt ,ck ,ck_dt ,a.gdr_cd0 
				,rslt_grp65	,rslt_grp105,	rslt_grp,	rslt_grp150,	rslt_grp190,	rslt_grp255,	rslt_grp320	
			 from heor.ldlc_05_demo_tx_&ad.&z. a ;
			 
quit;
%end;
%end;
%mend;
%bringsas;

/* PROC SQL; */
/* 	CREATE TABLE derived._05_demo_overall2 AS  */
/* 	SELECT A.*, b.* */
/* 	FROM derived._05_demo_overall2 a INNER JOIN derived._07_primary_2overall B */
/* 		 ON A.PATID=B.PATID  */
/* 		WHERE a.index_date_overall is not null; */
/* QUIT; */

%macro demos;
%do z=2 %to 2;

%let groups=overall*mi*pad*stroke;
		%do zz=1 %to 4;
		%let ad = %scan(&groups., &zz., *);

* modify variables;
	data derived._05_demo1a_&ad.&z.;
		set derived._05_demo_&ad.&z.; 
		%let vars=index_mi*index_pad*index_stroke*index_tia*index_unsta_angina*index_sta_angina*index_revasc*index_anginatia*index_cvd
						*index_other*af*cardiac_amy*hypertension*ckd*ckd2*ckd3*ckd45*hf
						*alzheimer*anemia*cancer
						*copd*cognitive*dementia*depression*diabete*mix_dyslipid*hypercholest*liver*obesity*rheumathoid*sleep*valvular					
						*aphe*dial*revasc
						*aphe1*dial1*revasc1
						*Statins*PCSK9i*Ezetimibe*Fibrates*Niacin*Mipomersen*Tocilizumab*Hormone*Fibrinolytic*Betablocker*ACE*Antiplatelet*Niacin_Statin*Loop_Diuretic*MRA*Anticoagulant
						
						;
	
		%do j=1 %to %sysfunc(countw(&vars., *));
			%let char = %scan(&vars., &j., *);
		
			format &char._pre $3.;
			&char._pre=&char.;
			drop &char.;
			rename &char._pre=&char.;
		%end;

		%do t=1 %to 2;
			%let dt = %scan(eligeff*eligend, &t., *);
			format &dt.2 date9.;
			&dt.2=datepart(&dt.);
			drop &dt.;
			rename &dt.2=&dt.;
		%end;
		
		%do t=1 %to 15;
			%let lab = %scan(sys_bp*dia_bp*ldlc*vldlc*hdlc*tc*tg*lpa_mg*lpa_mol*apob*hba1c*alt*ast*alp*ck, &t., *);
			if &lab. ne . then &lab._pts='1';
			format &lab.2 8. &lab._dt2 date9.;
			&lab.2=&lab.;
			&lab._dt2=datepart(&lab._dt);
			drop &lab. &lab._dt;
			rename &lab.2=&lab. &lab._dt2=&lab._dt;
		%end;
		
		format index_yr_pre $10.;
		index_yr_pre=index_yr;
		drop index_yr;
		rename index_yr_pre=index_yr;

		if age lt 0 then age=0;
		
		format age_grp region bus gdr_cd $20.;		
		if age <= 17 then age_grp='1. <=17';
		else if 18 <= age <= 24 then age_grp='2. 18-24';
		else if 25 <= age <= 34 then age_grp='3. 25-34';
		else if 35 <= age <= 44 then age_grp='4. 35-44';
		else if 45 <= age <= 54 then age_grp='5. 45-54';
		else if 55 <= age <= 64 then age_grp='6. 55-64';
		else if 65 <= age <= 74 then age_grp='7. 65-74';
		else if 75 <= age then age_grp='8. >=75';
		
		if region0=1 then region='1. NEW ENGLAND';
		else if region0=2 then region='2. MIDDLE ATLANTIC';
		else if region0=3 then region='3. EAST NORTH CENTRAL';
		else if region0=4 then region='4. WEST NORTH CENTRAL';
		else if region0=5 then region='5. SOUTH ATLANTIC';
		else if region0=6 then region='6. EAST SOUTH CENTRAL';
		else if region0=7 then region='7. WEST SOUTH CENTRAL';
		else if region0=8 then region='8. MOUNTAIN';
		else if region0=9 then region='9. PACIFIC';
		else if region0=10 then region='z. UNKNOWN';
		
		if bus0=1 then bus='COM';
		else if bus0=2 then bus='MCR';
		
		if gdr_cd0=1 then gdr_cd='F';
		else if gdr_cd0=2 then gdr_cd='M';	
		else if gdr_cd0=3 then gdr_cd='U';				
			
		if sys_bp ge 140 then sys_bp_grp='uc'; else if 0 le sys_bp lt 140 then sys_bp_grp='c';
		if dia_bp ge 90 then dia_bp_grp='uc'; else if 0 le dia_bp lt 90 then dia_bp_grp='c';
			
		if Ezetimibe_Statin='1' or Statins='1' or Niacin_Statin='1' then statin_tot='1';
		if Niacin_Statin='1' or Niacin='1' then Niacin_tot='1';
		if Ezetimibe_Statin='1' or Ezetimibe='1' then Eze='1';
					
		if diabete='1' then hba1c_dia=hba1c;
		if diabete='1' and hba1c_dia ne . then hba1c_dia_pts='1';
		if cmiss(Statins,Eze,PCSK9i,Fibrates,Niacin_tot,Mipomersen,Tocilizumab,Hormone,Fibrinolytic,Betablocker,ACE,Antiplatelet,Loop_Diuretic,MRA,Anticoagulant)=15 then No_RX='1';
		
		if ckd='1' or ckd2='1' or ckd3='1' or ckd45='1' then ckd1='1';
		drop region0 bus0 gdr_cd0 ckd ckd2 ckd3 ckd45;
	run;

%end;

%end;
%mend; 
%demos;



%macro demos;


%let groups=overall*mi*pad*stroke;
		%do zz=1 %to 4;
		%let ad = %scan(&groups., &zz., *);	
* Demo table cohort 1;
/* index_throm	index_cabg	index_endar	index_pci	index_angio_stent	index_other */
/* PROC SQL; */
/* 	CREATE TABLE derived._05_demo1b_&ad. AS  */
/* 	SELECT a.*, b.rslt_grp30, b.rslt_grp50, b.rslt_grp, b.rslt_grp70, b.rslt_grp90, b.rslt_grp120, b.rslt_grp150, b.rslt_nbr as lpa , b.lpa_date */
/* 	, '1' as overall */
/* 	FROM  derived._05_demo1a_&ad.1 a inner join derived._02_primary_1 b */
/* 		on a.patid=b.patid */
/* 	; */
/* QUIT; */


*Demo table cohort 2;
PROC SQL;
	CREATE TABLE derived._05_demo2b_&ad. AS 
	SELECT  a.*, b.RSLT_NBR as Lpa, rslt_nbr, b.lpa_date
	, '1' as overall
	FROM derived._05_demo1a_&ad.2 a inner join derived._02_primary_2 b
		on a.patid=b.patid
	;
QUIT;

%end;
%mend; 
%demos;

proc print data=derived._05_demo2b_mi ()


proc sql;
	select LPA,count( patid) from derived._05_demo2b_overall GROUP BY LPA;
quit;
PROC SQL;
select RSLT_NBR,count( patid) from derived._02_primary_2 GROUP BY RSLT_NBR;
quit;
