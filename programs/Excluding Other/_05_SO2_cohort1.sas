/*Demo - Secondary objective 2*/
* will convert all chatacter variable to numerical in order to save time when saving in SAS;

%macro index_date;
%let cohorts=a*b;
	%do z=1 %to 2;
	%let ct = %scan(&cohorts., &z., *);
	
	%let groups=overall*mi*pad*stroke*unsta_angina*sta_angina*tia*other*revasc*throm*cabg*endar*pci*angio_stent;
		%do i=1 %to 14;
		%let ad = %scan(&groups., &i., *);

%create(ldlc_05_demo_pre_&ad.&z.)
	select distinct a.*
		, case when a.gdr_cd='F' then 1
			when a.gdr_cd='M' then 2 
			when a.gdr_cd='U' then 3 end as gdr_cd0
		, year(a.index_date_&ad.) as index_yr
		, (year(a.index_date_&ad.)-a.yrdob) as age
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
		from dingyig._01_cohort_6&ct. as a
			left join dingyig.raw_00_dod_mbr as b 
			on a.patid=b.patid and a.index_date_&ad. between b.eligeff and b.eligend
%create(ldlc_05_demo_pre_&ad.&z.);
	%end;
	%end;
%mend;
%index_date;

options mprint;
* index ASCVD diagnosis;
%macro  index_ascvd;
%let cohorts=a*b;
	%do z=1 %to 2;
	%let ct = %scan(&cohorts., &z., *);
%let groups=overall*mi*pad*stroke*unsta_angina*sta_angina*tia*other*revasc*throm*cabg*endar*pci*angio_stent;
		%do i=1 %to 14;
		%let ad = %scan(&groups., &i., *);

	%create(ldlc_05_index_dx_&ad.&z.)
		select distinct a.*
			%do f=1 %to 13;
				%let dx =%scan(mi*pad*stroke*unsta_angina*sta_angina*tia*other*revasc*throm*cabg*endar*pci*angio_stent, &f., *);
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
	%do z=1 %to 2;
%let groups=overall*mi*pad*stroke*unsta_angina*sta_angina*tia*other*revasc*throm*cabg*endar*pci*angio_stent;
		%do i=1 %to 14;
		%let ad = %scan(&groups., &i., *);
		
	* Comorbidities + Obesity, Sedentarism, and Smoking status;
	%create(ldlc_05_demo_comor0_&ad.&z.)
			select a.patid, a.grp, a.index_date_&ad.
			%do t=1 %to 25;
				%let dx =%scan(af*cardiac_amy*hypertension*ckd*ckd2*ckd3*ckd45*hf
							*alzheimer*anemia*cancer*copd*cognitive*dementia*depression*diabete*mix_dyslipid*hypercholest*liver*obesity*rheumathoid*sleep*seden*smoke*valvular, &t., *);
				, (case when sum(a.&dx.)>0 then 1 else 0 end) as &dx.
			%end;
			from (select distinct a.patid, a.grp, a.index_date_&ad.
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
	

* index ASCVD diagnosis;
%macro  comor_demo;
	%do z=1 %to 2;
	%let groups=overall*mi*pad*stroke*unsta_angina*sta_angina*tia*other*revasc*throm*cabg*endar*pci*angio_stent;
		%do i=1 %to 14;
		%let ad = %scan(&groups., &i., *);
%let groups=overall*mi*pad*stroke*unsta_angina*sta_angina*tia*other*revasc*throm*cabg*endar*pci*angio_stent;
	
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
%do z=1 %to 2;
%let groups=overall*mi*pad*stroke*unsta_angina*sta_angina*tia*other*revasc*throm*cabg*endar*pci*angio_stent;
		%do i=1 %to 14;
		%let ad = %scan(&groups., &i., *);
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
			left join dingyig.ldlc_05_demo_comor0_1_&ad.&z. as u on q.patid=u.patid and q.grp=u.grp
			%do t=1 %to 16;
				%let lab = %scan(sys_bp*dia_bp*ldlc*vldlc*hdlc*tc*tg*lpa_mg*lpa_mol*apob*hba1c*alt*ast*alp*ck*cprot, &t., *);
				left join (select z.patid, z.grp, z.fst_dt, avg(z.rslt_nbr) as rslt_nbr
							from (select e.*, row_number() over (partition by e.patid, e.grp order by e.gap, e.fst_dt) as rn
								from (select a.patid, a.grp, b.fst_dt, b.rslt_nbr, abs(datediff(b.fst_dt,a.index_date_&ad.)) as gap
										from dingyig.ldlc_05_index_dx_&ad.&z. as a inner join (select * from dingyig.ldlc_04_lab1 
																			where year(to_date(fst_dt)) >= 2007 and year(to_date(fst_dt)) <= 2019 and rslt_nbr > 0 and rslt_nbr < 9999) as b 
										on a.patid=b.patid and b.grp="&lab." and datediff(b.fst_dt,a.index_date_&ad.) between -365.25 and -1 ) as e							
								) as z
							where z.rn=1
							group by z.patid, z.grp, z.fst_dt) as w&t. on q.patid=w&t..patid and q.grp=w&t..grp
			%end;
			
	%create(ldlc_05_demo_lab_&ad.&z.);
	%end;
	%end;
%mend demo_lab;
%demo_lab;


%macro demo_proc;
%do z=1 %to 2;
%let groups=overall*mi*pad*stroke*unsta_angina*sta_angina*tia*other*revasc*throm*cabg*endar*pci*angio_stent;
		%do zz=1 %to 14;
		%let ad = %scan(&groups., &zz., *);	
* procedure - use optum2_01_proc, not ldlc_01_proc_total, anytime prior to index;
%create(ldlc_05_demo_proc_&ad.&z.)
		select distinct q.*
			%do i=1 %to 7;
				%let proc_nm = %scan(angio_stent*cabg*endar*pci*throm*aphe*dial, &i., *);	
				, case when w&i..patid is not null and w&i..dt<q.index_date_&ad. then 1 end as &proc_nm.
			%end;
			, case when s.patid is not null and s.dt<q.index_date_&ad. then 1 end as angio
			, case when f.patid is not null and f.dt<q.index_date_&ad. then 1 end as stent
			, case when g.patid is not null and g.dt<q.index_date_&ad. then 1 end as pci_angio_stent_sameday
			, case when h.patid is not null and h.dt<q.index_date_&ad. then 1 end as pci_and_angio_stent
		from dingyig.ldlc_05_demo_lab_&ad.&z. as q
			%do t=1 %to 7;
				%let proc_nm = %scan(angio_stent*cabg*endar*pci*throm*aphe*dial, &t., *);	
				left join (select * from dingyig.optum2_01_proc0 where year(to_date(dt)) >= 2007 and year(to_date(dt)) <= 2019) as w&t. 
				on q.patid=w&t..patid and w&t..grp="&proc_nm." and w&t..dt<q.index_date_&ad.
			%end;
/* 			Angioplasty */
			left join (select * from dingyig.optum2_01_proc0 where year(to_date(dt)) >= 2007 and year(to_date(dt)) <= 2019 
				and code in (select distinct code from dingyig.optum2_proc where note in ('Angioplasty and Stent placement','Angioplasty'))) as s
			on q.patid=s.patid and s.dt<q.index_date_&ad.	
/* 			Stent placement */
			left join (select * from dingyig.optum2_01_proc0 where year(to_date(dt)) >= 2007 and year(to_date(dt)) <= 2019 
				and code in (select distinct code from dingyig.optum2_proc where note in ('Angioplasty and Stent placement','Stent placement'))) as f
			on q.patid=f.patid and f.grp='angio_stent' and f.dt<q.index_date_&ad.
			/*pci and stent*/
			left join (select distinct a.patid, a.dt from dingyig.optum2_01_proc0 as a inner join dingyig.optum2_01_proc0 as b
					on a.patid=b.patid and a.grp in ('pci') and b.grp in ('angio_stent') and year(to_date(a.dt)) >= 2007 and year(to_date(b.dt)) <= 2019) as h
			on q.patid=h.patid and h.dt<q.index_date_&ad.	
			
/* 			PCI AND Angioplasty/stent placement (on the same day) */
			left join (select distinct a.patid, a.dt from dingyig.optum2_01_proc0 as a inner join dingyig.optum2_01_proc0 as b
					on a.patid=b.patid and a.dt=b.dt and a.grp in ('pci') and b.grp in ('angio_stent') and year(to_date(a.dt)) >= 2007 and year(to_date(b.dt)) <= 2019) as g
			on q.patid=g.patid and g.dt<q.index_date_&ad.							
%create(ldlc_05_demo_proc_&ad.&z.);
%end;
%end;
%mend;
%demo_proc;


options mprint;
%macro demo_proc;
%do z=1 %to 2;
%let groups=overall*mi*pad*stroke*unsta_angina*sta_angina*tia*other*revasc*throm*cabg*endar*pci*angio_stent;
		%do zz=1 %to 14;
		%let ad = %scan(&groups., &zz., *);	
%create(ldlc_05_demo_proc1_&ad.&z.)
		select distinct q.*
		
		%do i=1 %to 7;
				%let proc_nm = %scan(angio_stent*cabg*endar*pci*throm*aphe*dial, &i., *);	
				, case when w&i..patid is not null and w&i..dt<=q.index_date_&ad. then 1 end as &proc_nm.1
			%end;
			, case when s.patid is not null then 1 end as angio1
			, case when f.patid is not null then 1 end as stent1
			, case when g.patid is not null then 1 end as pci_angio_stent_sameday1
			, case when h.patid is not null then 1 end as pci_and_angio_stent1
		from dingyig.ldlc_05_demo_proc_&ad.&z. as q
			%do t=1 %to 7;
				%let proc_nm = %scan(angio_stent*cabg*endar*pci*throm*aphe*dial, &t., *);	
				left join (select * from dingyig.optum2_01_proc0 where year(to_date(dt)) >= 2007 and year(to_date(dt)) <= 2019) as w&t. 
				on q.patid=w&t..patid and w&t..grp="&proc_nm." and w&t..dt<=q.index_date_&ad.
			%end;
/* 			Angioplasty */
			left join (select * from dingyig.optum2_01_proc0 where year(to_date(dt)) >= 2007 and year(to_date(dt)) <= 2019 
				and code in (select distinct code from dingyig.optum2_proc where note in ('Angioplasty and Stent placement','Angioplasty'))) as s
			on q.patid=s.patid and s.dt<=q.index_date_&ad.	
/* 			Stent placement */
			left join (select * from dingyig.optum2_01_proc0 where year(to_date(dt)) >= 2007 and year(to_date(dt)) <= 2019 
				and code in (select distinct code from dingyig.optum2_proc where note in ('Angioplasty and Stent placement','Stent placement'))) as f
			on q.patid=f.patid and f.grp='angio_stent' and f.dt<=q.index_date_&ad.
			/*pci and stent*/
			left join (select distinct a.patid, a.dt from dingyig.optum2_01_proc0 as a inner join dingyig.optum2_01_proc0 as b
					on a.patid=b.patid and a.grp in ('pci') and b.grp in ('angio_stent') and year(to_date(a.dt)) >= 2007 and year(to_date(b.dt)) <= 2019) as h
			on q.patid=h.patid and h.dt<=q.index_date_&ad.	
			
/* 			PCI AND Angioplasty/stent placement (on the same day) */
			left join (select distinct a.patid, a.dt from dingyig.optum2_01_proc0 as a inner join dingyig.optum2_01_proc0 as b
					on a.patid=b.patid and a.dt=b.dt and a.grp in ('pci') and b.grp in ('angio_stent') and year(to_date(a.dt)) >= 2007 and year(to_date(b.dt)) <= 2019) as g
			on q.patid=g.patid and g.dt<=q.index_date_&ad.							
%create(ldlc_05_demo_proc1_&ad.&z.);
	%end;
	%end;
%mend;
%demo_proc;

* Cholesterol lowering treatment;
%macro demo_tx;
%do z=1 %to 2;
%let groups=overall*mi*pad*stroke*unsta_angina*sta_angina*tia*other*revasc*throm*cabg*endar*pci*angio_stent;
		%do zz=1 %to 14;
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
			
		
	%create(ldlc_05_demo_tx1_&ad.&z.)
		select distinct q.*
			%do i=1 %to 16;
				%let tx = %scan(Statins*PCSK9i*Ezetimibe*Fibrates*Niacin*Mipomersen*Tocilizumab*Hormone*Fibrinolytic*Betablocker*ACE*Antiplatelet*Niacin_Statin*Loop_Diuretic*MRA*Anticoagulant, &i., *);	
				, case when w&i..patid is not null and datediff(w&i..dt,q.index_date_&ad.) between -365.25 and 0 then 1 end as &tx._index
			%end;
		from dingyig.ldlc_05_demo_tx_&ad.&z. as q
			%do t=1 %to 16;
				%let tx = %scan(Statins*PCSK9i*Ezetimibe*Fibrates*Niacin*Mipomersen*Tocilizumab*Hormone*Fibrinolytic*Betablocker*ACE*Antiplatelet*Niacin_Statin*Loop_Diuretic*MRA*Anticoagulant, &t., *);	
				left join dingyig.ldlc_04_drugs as w&t. 
				on q.patid=w&t..patid and w&t..generic="&tx." and datediff(w&t..dt,q.index_date_&ad.) between -365.25 and 0
			%end;			
		
	%create(ldlc_05_demo_tx1_&ad.&z.)
	%end;
	%end;
%mend demo_tx;
%demo_tx;



%macro bringsas;
%do z=1 %to 2;
%let groups=overall;
		%let groups=overall*mi*pad*stroke*unsta_angina*sta_angina*tia*other*revasc*throm*cabg*endar*pci*angio_stent;
		%do zz=1 %to 14;
		%let ad = %scan(&groups., &zz., *);			
proc sql;
	create table derived._05_demo_&ad.&z. as
	select a.patid, a.index_date_overall, a.index_yr	,a.age,a.region0,a.bus0 ,a.eligeff,	a.eligend,	a.product,	a.state,	a.yrdob,	a.gdr_cd	
				,index_date_mi,index_date_pad,index_date_stroke,index_date_tia,index_date_unsta_angina,index_date_sta_angina,index_date_revasc,index_date_pci,index_date_cabg,index_date_angio_stent,index_date_endar,index_date_throm,index_date_other
				,index_mi,index_pad,index_stroke,index_tia,index_unsta_angina,index_sta_angina,index_revasc,index_pci,index_cabg
				,index_angio_stent,index_endar,index_throm,index_other
			
				,angio_stent,cabg,	endar,	pci	,throm,	aphe,	dial,	angio,	stent,	pci_angio_stent_sameday	,pci_and_angio_stent
				,angio_stent1,cabg1,	endar1,	pci1	,throm1,	aphe1,	dial1,	angio1,	stent1,	pci_angio_stent_sameday1	,pci_and_angio_stent1
			
				,af,cardiac_amy,hypertension,ckd3,ckd45,hf, valvular
		
				,alzheimer,anemia,cancer,copd,cognitive,dementia,depression,diabete,mix_dyslipid,hypercholest,liver,obesity,rheumathoid,sleep	
						
				,Statins,PCSK9i,Ezetimibe,Fibrates,Niacin,Mipomersen,Tocilizumab,Hormone,Fibrinolytic,Betablocker,ACE,Antiplatelet,Niacin_Statin
				,Statins_index,PCSK9i_index,Ezetimibe_index,Fibrates_index,Niacin_index,Mipomersen_index,Tocilizumab_index,Hormone_index,Fibrinolytic_index,Betablocker_index,ACE_index,Antiplatelet_index,Niacin_Statin
				,Betablocker_index,ACE_index,Antiplatelet_index, Niacin_statin, Loop_Diuretic,MRA,Anticoagulant
				,ldlc,hdlc,tc,cprot,tg ,ckd ,ckd2 ,Niacin_Statin_index,sys_bp ,sys_bp_dt ,dia_bp ,dia_bp_dt ,ldlc_dt 
				,vldlc ,vldlc_dt ,hdlc_dt ,tc_dt ,tg_dt ,lpa_mg ,lpa_mg_dt ,lpa_mol ,lpa_mol_dt ,apob ,apob_dt ,hba1c ,hba1c_dt ,alt ,alt_dt ,ast ,ast_dt ,alp ,alp_dt ,ck ,ck_dt ,a.gdr_cd0 

			 from heor.ldlc_05_demo_tx1_&ad.&z. ;
			 
quit;
%end;
%end;
%mend;
%bringsas;

%macro demos;
%do z=1 %to 2;
%let groups=overall*mi*pad*stroke*unsta_angina*sta_angina*tia*other*revasc*throm*cabg*endar*pci*angio_stent;
		%do zz=1 %to 14;
		%let ad = %scan(&groups., &zz., *);	
options mprint;
* modify variables;
%macro rev_demo;
	data derived._05_demo1a_&ad.&z.;
		set derived._05_demo2_&ad.&z.;
		%let vars=ascvd*index_mi*index_pad*index_stroke*index_tia*index_unsta_angina*index_sta_angina*index_revasc*index_pci*index_cabg
				*index_angio_stent*index_endar*index_throm*index_other
						*af*cardiac_amy*hypertension*ckd*ckd2*ckd3*ckd45*hf
						*alzheimer*anemia*cancer
						*copd*cognitive*dementia*depression*diabete*mix_dyslipid*hypercholest*liver*obesity*rheumathoid*sleep*valvular					
						*angio_stent*cabg*endar*pci*throm*aphe*dial*angio*stent*pci_and_angio_stent*pci_angio_stent_sameday
						*angio_stent1*cabg1*endar1*pci1*throm1*aphe1*dial1*angio1*stent1*pci_and_angio_stent1*pci_angio_stent_sameday1
						*Statins*PCSK9i*Ezetimibe*Fibrates*Niacin*Mipomersen*Tocilizumab*Hormone*Fibrinolytic*Betablocker*ACE*Antiplatelet*Niacin_Statin*Loop_Diuretic*MRA*Anticoagulant
						*Statins_index*PCSK9i_index*Ezetimibe_index*Fibrates_index*Niacin_index*Mipomersen_index*Tocilizumab_index*Hormone_index*Fibrinolytic_index
						*Betablocker_index*ACE_index*Antiplatelet_index*Niacin_Statin_index
						;
	
			%do j=1 %to %sysfunc(countw(&vars., *));
			%let char = %scan(&vars., &j., *);
		
			format &char._pre $3.;
			&char._pre=&char.;
			drop &char.;
			rename &char._pre=&char.;
		%end;

		%do t=1 %to 3;
			%let dt = %scan(index_date*eligeff*eligend, &t., *);
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
		
		if pci='1' or angio_stent='1' then pci_or_angio_stent='1';
		if pci1='1' or angio_stent1='1' then pci_or_angio_stent1='1';
		
		if Ezetimibe_Statin='1' or Statins='1' or Niacin_Statin='1' then statin_tot='1';
		if Niacin_Statin='1' or Niacin='1' then Niacin_tot='1';
		if Ezetimibe_Statin='1' or Ezetimibe='1' then Eze='1';
		
		if Ezetimibe_Statin_index='1' or Statins_index='1' or Niacin_Statin_index='1' then statin_tot_index='1';
		if Niacin_Statin_index='1' or Niacin_index='1' then Niacin_tot_index='1';
		if Ezetimibe_Statin_index='1' or Ezetimibe_index='1' then Eze_index='1';
			
		if diabete='1' then hba1c_dia=hba1c;
		if diabete='1' and hba1c_dia ne . then hba1c_dia_pts='1';
		
		if ckd='1' or ckd2='1' or ckd3='1' or ckd45='1' then ckd1='1';
		drop region0 bus0 gdr_cd0 ckd ckd2 ckd3 ckd45;
	run;
%end;
%mend rev_demo;
%rev_demo;

* Demo table cohort 1;
/* index_throm	index_cabg	index_endar	index_pci	index_angio_stent	index_other */
PROC SQL;
	CREATE TABLE derived._05_demo1b_&ad. AS 
	SELECT a.*, b.rslt_grp30, b.rslt_grp50, b.rslt_grp, b.rslt_grp70, b.rslt_grp90, b.rslt_grp120, b.rslt_grp150, b.rslt_nbr as lpa 
	, '1' as overall
	FROM  derived._05_demo1a_&ad. a inner join derived._02_primary_1 b
		on a.patid=b.patid
	;
QUIT;

*Demo table cohort 2;
PROC SQL;
	CREATE TABLE derived._05_demo2b_&ad. AS 
	SELECT  a.*, b.RSLT_NBR as Lpa, 	b.rslt_grp65, b.rslt_grp105, b.rslt_grp, b.rslt_grp150, b.rslt_grp190, b.rslt_grp255, b.rslt_grp320
	, '1' as overall
	FROM derived._05_demo2a_&ad.2 a inner join derived._02_primary_2 b
		on a.patid=b.patid
	;
QUIT;
%end;
%mend; 
%demos;

%end;
%mend;
%demos;

