/*ER visits*/
 
%create(_08_er_diag)
		select distinct a.*
			, b.diag
			, case when b.diag_position is null then '99' else b.diag_position end as diag_position
		from src_optum_claims_panther.dod_m as a left join src_optum_claims_panther.dod_diag as b
		on a.pat_planid=b.pat_planid and a.clmid=b.clmid and a.loc_cd=b.loc_cd
		where a.pos in (&er_pos.) 
				and a.patid in (select distinct patid from dingyig._04_cohort_setup)
				
%create(_08_er_diag);

* use optum2_08_er file (continuous ER visits);
%create(_08_er0)
		select distinct a.patid, b.fst_dt, a.diag, a.diag_position
		from dingyig._08_er_diag as a inner join dingyig._07_er as b
		on a.patid=b.patid and a.fst_dt between b.fst_dt and b.lst_dt
			and to_date(b.fst_dt) <='2020-06-30 23:59:59.99'
%create(_08_er0);

*  diagnosis in primary position;
%create(_08_er_diag_prim)
		select distinct z.*
		from (select a.*, rank() over (partition by a.patid, a.fst_dt order by a.patid, a.fst_dt, a.diag_position) as rn 
			from dingyig._08_er0 as a
			) as z
			where rn=1
%create(_08_er_diag_prim);


%macro er_ascvd;
	%create(_08_er_ascvd)
			select distinct patid, fst_dt
			
			%do i=1 %to 7;
				%let dx =%scan(mi*pad*stroke*tia*unsta_angina*sta_angina*other, &i., *); /*chd and cerebrovascular are optional*/
				, case when (substr(diag,1,3) in (&&&dx.) 
						or substr(diag,1,4) in (&&&dx.) 
						or substr(diag,1,5) in (&&&dx.) 
						or substr(diag,1,6) in (&&&dx.)) 
					then 1 else 0
				end as &dx.
			%end;
			, 0 as angio_stent, 0 as cabg, 0 as endar, 0 as pci, 0 as throm, 0 as revasc
			from dingyig._08_er_diag_prim
			
			union
			select distinct a.patid, a.fst_dt
				, 0 as mi, 0 as pad, 0 as stroke, 0 as tia, 0 as unsta_angina, 0 as sta_angina, 0 as other
				%do i=1 %to 5;
					%let proc_nm = %scan(angio_stent*cabg*endar*pci*throm, &i., *);	
					, case when b.patid is not null and b.grp = "&proc_nm." then 1 else 0 end as &proc_nm. /*choose all procedure code because cant identify primary procedure*/
				%end;
				/*revascularization*/
				,case when b.patid is not null and b.grp in ('throm','cabg','endar','pci','angio_stent') then 1 else 0 end as revasc /*choose all procedure code because cant identify primary procedure*/	

			from dingyig._08_er_diag_prim as a left join (select * from dingyig.optum2_01_proc where pos in (&er_pos.) and grp in ('throm','cabg','endar','pci','angio_stent')) as b
			on a.patid=b.patid and a.fst_dt=b.dt
	%create(_08_er_ascvd);
%mend er_ascvd;
%er_ascvd;

/*save to SAS*/
data _08_er_ascvd;
	set heor._08_er_ascvd;
run;


%macro char_correct;
	data _08_er_pre;
		set _08_er_ascvd;
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

/*ER visits within 2 years- need 1 and 2 years*/
%macro er (time, num, year);
%do z=1 %to 2;
%let groups=overall*mi*pad*stroke*unsta_angina*sta_angina*tia*other*revasc*cvd*anginatia*noncvd;
		%do zz=1 %to 12;
		%let ad = %scan(&groups., &zz., *);
	proc sql;
		create table _08_er&ad.&z. as 
		select distinct a.*, b.*
		from derived._07_primary_&z.&ad. as a 
			left join (select distinct patid, fst_dt
						%do i=1 %to 8;
							%let grp =%scan(mi*pad*stroke*tia*unsta_angina*sta_angina*other*revasc, &i., *);
							, max(&grp.) as &grp.
						%end;
						from _08_er_pre
						group by patid, fst_dt
						) as b
		on a.patid=b.patid 
			and a.index_date_&ad. lt b.fst_dt le (&time.)
			and a.eligeff le b.fst_dt le a.eligend;	
	quit;



data _08_er2&ad.&z.; 
	set _08_er&ad.&z.;
	* diagnosis;
	if mi=1 then er_mi=1; 
	if stroke=1 then er_stroke=1;
	if pad=1 or acute_pao=1 or aotic=1 or inter_clau=1 or limb=1 then er_pad=1;
	if unsta_angina=1 then er_angina=1;
	if  revasc=1 then er_revasc=1;
	if sta_angina=1 or tia=1 then er_other=1;
	
	if er_mi=1 or er_stroke=1 or er_pad=1 or er_angina=1 or er_revasc=1 or er_other=1 then er_ascvd=1;
run;

	proc sql;
		create table _08_er3&ad.&z. as
		select distinct patid
				, index_date_&ad., eligeff, eligend
				, count(distinct fst_dt) as n_er
				, max(fst_dt) as lst_dt format date9.
			%do r=1 %to 14;
				%let cat =%scan(mi*unsta_angina*sta_angina*stroke*tia*pad*revasc
								*er_ascvd*er_mi*er_stroke*er_pad*er_angina*er_revasc*er_other, &r., *);
				, sum(case when &cat. > 0 then &cat. else 0 end) as &cat.
			%end;
		from _08_er2&ad.&z.
		group by patid;
	quit;

data derived._08_er&ad.&z.&year.;
	set _08_er3&ad.&z.;
	* person-year;
	py=max((eligend-index_date_&ad.+1),(lst_dt-index_date_&ad.+1)) / 365.25;
	if py ge &num. then py=&num.;
	ln_py=log(py);
	
run;
	%end;
	%end;
%mend er;
%er(a.index_date_&ad.+365.25, 1, one_year);
%er(a.index_date_&ad.+(365.25*2), 2, two_years);	
%er(a.eligend, 11, all);	


* check the number of patients;
/* proc sql; */
/* 	select 'ascvd            ' as cat, count(distinct patid) as pts, count(distinct patid)/4473 as pct from derived._09_er where er_ascvd=1 */
/* 	union */
/* 	select 'mi' as cat, count(distinct patid) as pts, count(distinct patid)/4473 as pct from derived._09_er where er_mi=1 */
/* 	union */
/* 	select 'stroke' as cat, count(distinct patid) as pts, count(distinct patid)/4473 as pct from derived._09_er where er_stroke=1 */
/* 	union */
/* 	select 'pad' as cat, count(distinct patid) as pts, count(distinct patid)/4473 as pct from derived._09_er where er_pad=1 */
/* 	union */
/* 	select 'unsta_angina' as cat, count(distinct patid) as pts, count(distinct patid)/4473 as pct from derived._09_er where er_angina=1 */
/* 	union */
/* 	select 'revasc' as cat, count(distinct patid) as pts, count(distinct patid)/4473 as pct from derived._09_er where er_revasc=1 */
/* 	union */
/* 	select 'other' as cat, count(distinct patid) as pts, count(distinct patid)/4473 as pct from derived._09_er where er_other=1; */
/* quit; */
/*  */
/*  */
/*  */
/*  */
