/*p-values for HCRU rates*/
/*need hospitalizations, ER visits, OP visits, top 20 visits
options mprint;	
%macro py;
		
/*overall py for all patients*/
DATA _11_rate_2overalloneyear;
	set derived._07_primary_2overall ;
	py=(eligend-index_date_overall+1)/ 365.25;
	if py ge 1 then py=1;
	ln_py=log(py);
	where one_year and index_date_overall is not null;
run;


%macro rate_tb;

		data _11_sub02; 
		set derived._07_primary_2overall; 
		where index_date_overall is not null and (rslt_grp65 is not null or rslt_grp150 is not null ) and one_year is not null;
			if rslt_grp65='<65 ' then rslt_grp='<65 ';
			else rslt_grp='>=150';
		run;

		proc sql;
			create table _11_hosp as select a.*, b.rslt_grp from derived._07_hospoverall2one_year a inner join _11_sub02 b on a.patid=b.patid;
			create table _11_er as select a.*, b.rslt_grp from derived._08_eroverall2one_year a inner join _11_sub02 b on a.patid=b.patid ;
			create table _11_outp as select a.*, b.rslt_grp from derived._09_outpoverall2one_year a inner join _11_sub02 b on a.patid=b.patid;
		quit;
				
	/*inpatient person-year denominator*/
	 proc sort data=_11_hosp2;
	 by rslt_grp;
	 run;
	 
	 proc sort data=_11_er;
	 by rslt_grp;
	 run;
	 
	  proc sort data=_11_outp;
	 by rslt_grp;
	 run;
		
	* Inpatient;
		%do q=1 %to 10;
			%let vars=%scan(n_hosp*hosp_ascvd*hosp_mi*hosp_stroke*hosp_pad*hosp_angina*hosp_revasc*hosp_other*icu*reh_cvd, &q., *);
			
			ods output Diffs=Diffs;
			proc genmod data=_11_hosp;
			class rslt_grp;
				model &vars.= rslt_grp / offset=ln_py dist=poisson link=log;
				lsmeans rslt_grp / exp pdiff cl;
				where &vars.>0;
			run;
			proc sql;	
				create table _11_ip&q. as
				select "&vars.              " as var,  probz, exp(-estimate) as expestimate, exp(-lower) as explower, exp(-upper) as expupper
				from Diffs ;
			quit;
		%end;

	* ER;
		%do q=1 %to 8;
			%let vars=%scan(n_er*er_ascvd*er_mi*er_stroke*er_pad*er_angina*er_revasc*er_other, &q., *);

			ods output DIFFS=DIFFS;
			proc genmod data=_11_er ;
			class rslt_grp;
				model &vars.= rslt_grp / offset=ln_py dist=poisson link=log;
				lsmeans rslt_grp / exp pdiff cl;
				where &vars.>0;
			run;
			proc sql;	
				create table _11_er&q. as
				select "&vars.             " as var,  probz, exp(-estimate) as expestimate, exp(-lower) as explower, exp(-upper) as expupper
				from DIFFS
				 ;
			quit;
		
		%end;
		
	* outpatient;
		%do q=1 %to 11;
			%let vars=%scan(n_outp*outp_ascvd*outp_mi*outp_stroke*outp_pad*outp_angina*outp_revasc*outp_other*cardio*gp*reh_cvd, &q., *);
	
			ods output DIFFS=DIFFS;
			proc genmod data=_11_outp;
			class rslt_grp;
				model &vars.= rslt_grp / offset=ln_py dist=poisson link=log;
				lsmeans rslt_grp / exp pdiff cl;
				where &vars.>0 ;
			run;
			proc sql;	
				create table _11_op&q. as
				select "&vars.           " as var,  probz, exp(-estimate) as expestimate, exp(-lower) as explower, exp(-upper) as expupper
				from DIFFS;
			quit;
		%end;
		
		* set final table;
		data _hcru_rateoverall; 
			set _11_ip1 - _11_ip10
				_11_er1 - _11_er8
				_11_op1- _11_op11;
		run;
	
	proc print data=_hcru_rateoverall;
	run;
%mend;
%rate_tb;
