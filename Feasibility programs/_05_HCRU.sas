/*Revised HCRU for one year follow up excluding events within 90 days of index date*/
options mprint;
%macro labs(year, years);
/*counts labs during post index period*/
	%let cohorts=a*b;
	%do z=2 %to 2;
	%let ct = %scan(&cohorts., &z., *);
	%let groups=overall;
		%do i=1 %to 1;
			%let ad = %scan(&groups., &i., *);
	%create(_05_lab_&ad.&z.&year.)
			select q.patid, q.index_date_&ad.
			%do r=1 %to 7;
				%let lab = %scan(ldlc*hdlc*tc*tg*lpa_mg*lpa_mol*cprot, &r., *);
				, count(distinct case when w&r..patid is not null then w&r..rslt_nbr end) as &lab._cnt
			%end;
		from dingyig._01_cohort_6&ct. as q
			%do t=1 %to 7;
				%let lab = %scan(ldlc*hdlc*tc*tg*lpa_mg*lpa_mol*cprot, &t., *);
				left join (select patid, grp, fst_dt, rslt_nbr from dingyig.ldlc_04_lab2 
						where year(to_date(fst_dt)) >= 2007 and year(to_date(fst_dt)) <= 2020 and rslt_nbr > 0 and rslt_nbr < 9999 and grp="&lab.")
					as w&t. on q.patid=w&t..patid and q.index_date_&ad.+INTERVAL 90 DAYS < w&t..fst_dt and w&t..fst_dt<=&years.
			%end;
			group by q.patid, q.index_date_&ad.
	%create(_05_lab_&ad.&z.&year.);
			%end;
		%end;
%mend;
%labs(one_year, index_date_&ad. + INTERVAL 365 DAYS);


* lab data one year post index;
options mprint;
%macro labs(year, years);
/*labs at index*/
	%let cohorts=a*b;
	%do z=2 %to 2;
	%let ct = %scan(&cohorts., &z., *);
	%let groups=overall;
		%do i=1 %to 1;
			%let ad = %scan(&groups., &i., *);
	%create(_05_lab1_&ad.&z.&year.)
			select distinct q.*
			/* merge comorbidities*/
			%do r=1 %to 7;
				%let lab = %scan(ldlc*hdlc*tc*tg*lpa_mg*lpa_mol*cprot, &r., *);
				, case when w&r..patid is not null then w&r..fst_dt end as &lab._dt
				, case when w&r..patid is not null then w&r..rslt_nbr end as &lab.

			%end;
		from dingyig._01_cohort_6&ct. q
			%do t=1 %to 7;
				%let lab = %scan(ldlc*hdlc*tc*tg*lpa_mg*lpa_mol*cprot, &t., *);
				left join (select z.patid, z.grp, z.fst_dt, avg(z.rslt_nbr) as rslt_nbr
							from (select e.*, row_number() over (partition by e.patid, e.grp order by e.gap, e.fst_dt) as rn
								from (select a.patid, a.grp, b.fst_dt, b.rslt_nbr, abs(datediff(b.fst_dt,a.index_date_&ad.)) as gap
										from dingyig._01_cohort_6&ct. as a inner join (select * from dingyig.ldlc_04_lab2 
																			where year(to_date(fst_dt)) >= 2007 and year(to_date(fst_dt)) <= 2020 and rslt_nbr > 0 and rslt_nbr < 9999) as b 
										on a.patid=b.patid and b.grp="&lab." and a.index_date_&ad.+INTERVAL 90 DAYS < b.fst_dt and b.fst_dt<=&years. ) as e						
								) as z
						
							where z.rn=1
							group by z.patid, z.grp, z.fst_dt) as w&t. on q.patid=w&t..patid and q.grp=w&t..grp
			%end;
	%create(_05_lab1_&ad.&z.&year.);
	%end;
	%end;
%mend;
%labs(one_year, index_date_&ad. + INTERVAL 365 DAYS);


%macro procs(year, years);
	%do z=2 %to 2;
	%let groups=overall;
		%do zz=1 %to 1;
			%let ad = %scan(&groups., &zz., *);
/*procedures one year post index not including index date - added in count of procedures for frequency*/
	%create(_05_proc_&ad.&z.&year.)
		select q.patid, q.index_date_&ad.
			%do i=1 %to 2;
				%let proc_nm = %scan(aphe*dial, &i., *);	
				, max(case when w&i..patid is not null and index_date_&ad.< w&i..dt and w&i..dt<= &years. then 1 end) as &proc_nm.
				, count(distinct case when w&i..patid is not null then w&i..dt end) as &proc_nm._cnt
			%end;
			, max(case when s.patid is not null then 1 end) as revasc
			, count(distinct case when s.patid  is not null then  s.dt end) as revasc_cnt
		
		from dingyig._05_lab1_&ad.&z.&year. as q
			%do t=1 %to 2;
				%let proc_nm = %scan(aphe*dial, &t., *);	
				left join (select * from dingyig.optum2_01_other_proc  where year(to_date(dt)) >= 2007 and year(to_date(dt)) <= 2020) as w&t. 
				on q.patid=w&t..patid and w&t..grp="&proc_nm." and q.index_date_&ad. < w&t..dt and w&t..dt<=&years.
			%end;
	/* 			Revascularization */
			left join (select * from dingyig.optum2_01_proc where year(to_date(dt)) >= 2007 and year(to_date(dt)) <= 2020 
				and code in (select distinct code from dingyig.optum2_01_proc)) as s
			on q.patid=s.patid and q.index_date_&ad. +INTERVAL 90 DAYS < s.dt and s.dt<=&years.


		group by q.patid, q.index_date_&ad.
	%create(_05_proc_&ad.&z.&year.)
	%end;
	%end;
%mend;
%procs(one_year, index_date_&ad. + INTERVAL 365 DAYS);

* Medications at index - need to do for all for consistency;
%macro demo_tx(year, years);
%do z=2 %to 2;
	%let groups=overall;
		%do zz=1 %to 1;
		%let ad = %scan(&groups., &zz., *);	
%create(_05_demo_tx_&ad.&z.&year.)
		select distinct q.*
			%do i=1 %to 16;
				%let tx = %scan(Statins*PCSK9i*Ezetimibe*Fibrates*Niacin*Mipomersen*Tocilizumab*Hormone*Fibrinolytic*Betablocker*ACE*Antiplatelet*Niacin_Statin*Loop_Diuretic*MRA*Anticoagulant, &i., *);	
				, case when w&i..patid is not null then 1 end as &tx.
			%end;
		from dingyig._05_lab1_&ad.&z.&year. as q
			%do t=1 %to 16;
				%let tx = %scan(Statins*PCSK9i*Ezetimibe*Fibrates*Niacin*Mipomersen*Tocilizumab*Hormone*Fibrinolytic*Betablocker*ACE*Antiplatelet*Niacin_Statin*Loop_Diuretic*MRA*Anticoagulant, &t., *);	
				left join dingyig.ldlc_04_drugs as w&t. 
				on q.patid=w&t..patid and w&t..generic="&tx." and q.index_date_&ad.=w&t..dt	
			%end;						
	%create(_05_demo_tx_&ad.&z.&year.)
	%end;
	%end;
%mend demo_tx;

%demo_tx(one_year, index_date_&ad. + INTERVAL 365 DAYS);


* Medications post index;
%macro demo_tx(year, years);
%do z=2 %to 2;
	%let groups=overall;
		%do zz=1 %to 1;
		%let ad = %scan(&groups., &zz., *);			
	%create(_05_demo_tx1_&ad.&z.&year.)
		select distinct q.*
			%do i=1 %to 16;
				%let tx = %scan(Statins*PCSK9i*Ezetimibe*Fibrates*Niacin*Mipomersen*Tocilizumab*Hormone*Fibrinolytic*Betablocker*ACE*Antiplatelet*Niacin_Statin*Loop_Diuretic*MRA*Anticoagulant, &i., *);	
				, case when w&i..patid is not null and q.index_date_&ad. < w&i..dt and w&i..dt<=&years. then 1 end as &tx._index
			%end;
		from dingyig._05_demo_tx_&ad.&z.&year. as q
			%do t=1 %to 16;
				%let tx = %scan(Statins*PCSK9i*Ezetimibe*Fibrates*Niacin*Mipomersen*Tocilizumab*Hormone*Fibrinolytic*Betablocker*ACE*Antiplatelet*Niacin_Statin*Loop_Diuretic*MRA*Anticoagulant, &t., *);	
				left join dingyig.ldlc_04_drugs as w&t. 
				on q.patid=w&t..patid and w&t..generic="&tx." and q.index_date_&ad. < w&t..dt and  w&t..dt<=&years. 	
			%end;			
		
	%create(_05_demo_tx1_&ad.&z.&year.)
	%end;
	%end;
%mend demo_tx;

%demo_tx(one_year, index_date_&ad. + INTERVAL 365 DAYS);


%macro combine(year, years);
%do z=2 %to 2;
	%let groups=overall;
		%do zz=1 %to 1;
		%let ad = %scan(&groups., &zz., *);	
	%create(_05_all&ad.&z.&year.)
		select a.*
			,b.aphe, b.aphe_cnt
			, b.dial, b.dial_cnt, b.revasc, b.revasc_cnt
			,c.ldlc_cnt, c.hdlc_cnt, c.tc_cnt , c.tg_cnt , c.lpa_mg_cnt , c.lpa_mol_cnt , c.cprot_cnt
		from dingyig._05_demo_tx1_&ad.&z.&year. a left join dingyig._05_proc_&ad.&z.&year. b 	on a.patid=b.patid
												left join dingyig._05_lab_&ad.&z.&year. c on a.patid=c.patid
											
	
	%create(_05_all&ad.&z.&year.);
		%end;
		%end;
	
%mend;

%combine(one_year, index_date_&ad. + INTERVAL 365 DAYS);



%macro bringsas(year, years);
%do z=2 %to 2;
%let groups=overall;
		%do zz=1 %to 1;
		%let ad = %scan(&groups., &zz., *);			
proc sql;
	create table derived._05_hcru_&ad.&z.&year. as
	select *
	 from heor._05_all&ad.&z.&year. ;
			 
quit;
	%end;
	%end;

%mend;

%bringsas(one_year, index_date_&ad. + INTERVAL 365 DAYS);




