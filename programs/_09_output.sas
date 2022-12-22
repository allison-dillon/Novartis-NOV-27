
%create(_09_outp0)
		select distinct a.*
			, b.diag
			, case when b.diag_position is null then '99' else b.diag_position end as diag_position
		from src_optum_claims_panther.dod_m as a left join src_optum_claims_panther.dod_diag as b
		on a.pat_planid=b.pat_planid and a.clmid=b.clmid and a.loc_cd=b.loc_cd
		where a.pos in (&outp_pos.) 
				and a.patid in (select distinct patid from dingyig._04_cohort_setup)
				and to_date(a.fst_dt) <='2020-06-30 23:59:59.99'
%create(_09_outp0);


* collected only primary diagnosis ;
%create(_09_outp_diag_prim)
		select distinct z.*
		from (select a.*, rank() over (partition by a.patid, a.fst_dt order by a.patid, a.fst_dt, a.diag_position) as rn /*choose first diag_position in diagnosis table*/
			from dingyig._09_outp0 as a
			) as z
		where z.rn=1 
%create(_09_outp_diag_prim);

* ASCVD diagnosis + cardiology; 
%let cardio = %str('393','394','395','396','397','398','401','402','403','404','405','410','411','412','413','414','415','416','417','420','421','422','423','424','425'
					,'426','427','428','429','430','431','432','433','434','435','436','437','438','440','441','442','443','444','445','446','447','448','449','451','452'
					,'453','454','455','456','457','458','459'
					,'I05','I06','I07','I08','I09','I10','I11','I12','I13','I14','I15','I16','I20','I21','I22','I23','I24','I25','I26','I27','I28','I30','I31','I32','I33'
					,'I34','I35','I36','I37','I38','I39','I40','I41','I42','I43','I44','I45','I46','I47','I48','I49','I50','I51','I52','I60','I61','I62','I63','I64','I65'
					,'I66','I67','I68','I69','I70','I71','I72','I73','I74','I75','I76','I77','I78','I79','I80','I81','I82','I83','I84','I85','I86','I87','I88','I89','I95'
					,'I96','I97','I98','I99');
%let ex_cardio = %str('NA');	
%macro outp_ascvd;
	%create(_09_outp_ascvd)
			select distinct patid, fst_dt
			%do i=1 %to 8;
				%let dx =%scan(mi*pad*stroke*tia*unsta_angina*sta_angina*other*cardio, &i., *); /*chd and cerebrovascular are optional*/
				, case when (substr(diag,1,3) in (&&&dx.) 
						or substr(diag,1,4) in (&&&dx.) 
						or substr(diag,1,5) in (&&&dx.) 
						or substr(diag,1,6) in (&&&dx.)) 
					then 1 else 0
				end as &dx.
			%end;
			, 0 as angio_stent, 0 as cabg, 0 as endar, 0 as pci, 0 as throm, 0 as revasc
			from dingyig._09_outp_diag_prim
			union
			select distinct a.patid, a.fst_dt
				, 0 as mi, 0 as pad, 0 as stroke, 0 as tia, 0 as unsta_angina, 0 as sta_angina, 0 as other, 0 as cardio
				%do i=1 %to 5;
					%let proc_nm = %scan(angio_stent*cabg*endar*pci*throm, &i., *);	
					, case when b.patid is not null and b.grp = "&proc_nm." then 1 else 0 end as &proc_nm. /*choose all procedure code because cant identify primary procedure*/
				%end;
				/*revascularization*/
				,case when b.patid is not null and b.grp in ('throm','cabg','endar','pci','angio_stent') then 1 else 0 end as revasc /*choose all procedure code because cant identify primary procedure*/	

			from dingyig._09_outp_diag_prim as a left join (select * from dingyig.optum2_01_proc where pos in (&outp_pos.) and grp in ('throm','cabg','endar','pci','angio_stent')) as b
			on a.patid=b.patid and a.fst_dt=b.dt
	%create(_09_outp_ascvd);
%mend outp_ascvd;
%outp_ascvd;


		
* General practitioner visits ;
%let general_prac = %str('0316','0329','0330','0331','0332','1113','1694','1721','1791','1832','1865','1927','1940','2189','2359','2378','2574','2628'
							,'2736','2811','2826','2835','2837','2889','2930','2996','3094','3122','3317','3777','3812','4645','5732','5781','6000');
%create(_09_outp_gp)
		select distinct patid, fst_dt, 1 as gp
		from src_optum_claims_panther.dod_m
		where pos in (&outp_pos.)
			and provcat in (&general_prac.) 
			and patid in (select distinct patid from dingyig._04_cohort_setup);
%create(_09_outp_gp);

* Rehabilitation;
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

%create(_09_reh)
		select distinct patid, fst_dt, 1 as reh
		/*Medical table*/
		from src_optum_claims_panther.dod_m
		where pos in (&outp_pos.)
			and (drg in (&rehab_drg.) or pos in (&rehab_pos.) or rvnu_cd in (&rehab_rvnu.) or provcat in (&rehab_provcat.) or proc_cd in (&rehab_proc.) or tos_cd in (&rehab_tos.))
			and patid in (select distinct patid from dingyig._04_cohort_setup)
		union
		/*Facility Detail file*/
		select distinct a.patid, a.fst_dt, 1 as reh
		from (select distinct * from src_optum_claims_panther.dod_m where pos in (&outp_pos.)) as a
			inner join (select distinct * from src_optum_claims_panther.dod_fd where rvnu_cd in (&rehab_rvnu.) or proc_cd in (&rehab_proc.)) as b
			on a.pat_planid=b.pat_planid and a.clmid=b.clmid and a.clmseq=b.clmseq and a.fst_dt=b.fst_dt
		where a.patid in (select distinct patid from dingyig._04_cohort_setup)
%create(_09_reh);	
		
* merge general practitioner and Rehabilitation - takes all after first index date;
%create(_09_outp_final)
			select distinct b.*
			from dingyig._04_cohort_setup as a
				inner join (select distinct a.*, b.gp, c.reh
						from dingyig._09_outp_ascvd as a 
							left join dingyig._09_outp_gp as b on a.patid=b.patid and a.fst_dt=b.fst_dt
							left join dingyig._09_reh as c on a.patid=c.patid and a.fst_dt=c.fst_dt) as b
			on a.patid=b.patid 
				and a.index_date_overall<=b.fst_dt
%create(_09_outp_final);



* File for only top 20 cause outpatient visit - takes all after first index date;
%create(_09_outp_cause)
			select distinct b.patid, b.fst_dt, b.diag
			from dingyig._04_cohort_setup as a inner join dingyig._09_outp_diag_prim as b
			on a.patid=b.patid 
				and a.index_date_overall<=b.fst_dt
%create(_09_outp_cause);


/*save to SAS*/
data derived._09_outp0;
	set heor._09_outp_final;
run;

data derived._09_outp_cause;
	set heor._09_outp_cause;
run;



* check;
proc sort data=derived._09_outp0 out=a nodupkey; by patid fst_dt; run;  /*329,857 obs*/
proc sort data=derived._09_outp_cause out=a nodupkey; by patid fst_dt; run; /*329,857 obs*/


%macro char_correct;
	data _09_outp_pre;
		set derived._09_outp0;
		%do t=1 %to 1;
			%let dt = %scan(fst_dt, &t., *);
			format &dt.2 date9.;
			&dt.2=datepart(&dt.);
			drop &dt.;
			rename &dt.2=&dt.;
		%end;
	run;
%mend char_correct;
%char_correct;


%macro outp(time, num, year);
%do z=2 %to 2;
%let groups=overall;
		%do zz=1 %to 1;
		%let ad = %scan(&groups., &zz., *);
	proc sql;
		create table _09_outp&ad.&z. as 
		select distinct a.*, b.*
		from derived._07_primary_&z.&ad. as a 
			left join (select distinct patid, fst_dt
						%do i=1 %to 10;
							%let grp =%scan(mi*pad*stroke*tia*unsta_angina*sta_angina*other*cardio*gp*reh, &i., *);
							, max(&grp.) as &grp.
						%end;
						from _09_outp_pre
						group by patid, fst_dt
						) as b
		on a.patid=b.patid 
			and a.index_date_&ad. lt b.fst_dt le (&time.)
			and a.eligeff le b.fst_dt le a.eligend
		where index_date_&ad. is not null;	
	quit;


data _09_outp2&ad.&z.; 
	set _09_outp&ad.&z.;
	* diagnosis;
	if mi=1 then outp_mi=1; 
	if stroke=1 then outp_stroke=1;
	if pad=1 or acute_pao=1 or aotic=1 or inter_clau=1 or limb=1 then outp_pad=1;
	if unsta_angina=1 then outp_angina=1;
	if revasc=1 then outp_revasc=1;
	if sta_angina=1 or tia=1 then outp_other=1;
	
	if outp_mi=1 or outp_stroke=1 or outp_pad=1 or outp_angina=1 or outp_revasc=1 or outp_other=1 then outp_ascvd=1;
	if reh eq 1 and (mi=1 or stroke=1 or outp_pad=1) then reh_cvd=1;
run;

	proc sql;
		create table _09_outp3&ad.&z. as
		select distinct patid
				, index_date_&ad., eligeff, eligend, max(fst_dt) as lst_dt format date9.
				, count(distinct fst_dt) as n_outp
			%do r=1 %to 17;
				%let cat =%scan(mi*unsta_angina*sta_angina*stroke*tia*pad
								*outp_ascvd*outp_mi*outp_stroke*outp_pad*outp_angina*outp_revasc*outp_other*cardio*gp*reh*reh_cvd, &r., *);
				, sum(case when &cat. > 0 then &cat. else 0 end) as &cat.
			%end;
		from _09_outp2&ad.&z.
		group by patid;
	quit;


data derived._09_outp&ad.&z.&year.;
	set _09_outp3&ad.&z.;
	* person-year;
	py=max((eligend-index_date_&ad.+1),(lst_dt-index_date_&ad.+1)) / 365.25;
	if py ge &num. then py=&num.;
	ln_py=log(py);

run;
	%end;
	%end;
%mend outp;
%outp(a.index_date_&ad.+365.25, 1, one_year);
%outp(a.index_date_&ad.+(365.25*2), 2, two_years);	
%outp(a.eligend, 11, all);	

/*  */
/* * check the number of patients; */
/* proc sql; */
/* 	select 'ascvd            ' as cat, count(distinct patid) as pts, count(distinct patid)/16664 as pct from derived._10_outp where outp_ascvd=1 */
/* 	union */
/* 	select 'mi' as cat, count(distinct patid) as pts, count(distinct patid)/16664 as pct from derived._10_outp where outp_mi=1 */
/* 	union */
/* 	select 'stroke' as cat, count(distinct patid) as pts, count(distinct patid)/16664 as pct from derived._10_outp where outp_stroke=1 */
/* 	union */
/* 	select 'pad' as cat, count(distinct patid) as pts, count(distinct patid)/16664 as pct from derived._10_outp where outp_pad=1 */
/* 	union */
/* 	select 'unsta_angina' as cat, count(distinct patid) as pts, count(distinct patid)/16664 as pct from derived._10_outp where outp_angina=1 */
/* 	union */
/* 	select 'revasc' as cat, count(distinct patid) as pts, count(distinct patid)/16664 as pct from derived._10_outp where outp_revasc=1 */
/* 	union */
/* 	select 'other' as cat, count(distinct patid) as pts, count(distinct patid)/16664 as pct from derived._10_outp where outp_other=1 */
/* 	union */
/* 	select 'tia' as cat, count(distinct patid) as pts, count(distinct patid)/16664 as pct from derived._10_outp where tia=1 */
/* 	union */
/* 	select 'sta_angina' as cat, count(distinct patid) as pts, count(distinct patid)/16664 as pct from derived._10_outp where sta_angina=1 */
/* 	union */
/* 	select 'reh_cvd' as cat, count(distinct patid) as pts, count(distinct patid)/16664 as pct from derived._10_outp where reh_cvd=1; */
/* quit; */






