/*p values for inpatient HCRU one year follow up Number of encounters, <65 nmol/L vs >=150 nmol/L*/
/*only need inpatient leng of stay over 1 year and IP LOS per hosp*/

%macro stat_hcru ;
	/* Create HCRU table */
		data _10_sub02; 
		set derived._07_primary_2overall; 
		format rslt_grp $10.;
		where index_date_overall is not null and (rslt_grp65 is not null or rslt_grp150 is not null ) and one_year is not null;
			if rslt_grp65='<65 ' then rslt_grp='<65 ';
			else rslt_grp='>=150';
		run;
					
		proc sql;
			create table _10_hosp2 as select * from derived._07_hospoverall2one_year where patid in (select distinct patid from _10_sub02);
			create table _10_er2 as select * from derived._08_eroverall2one_year where patid in (select distinct patid from _10_sub02) ;
			create table _10_outp2 as select * from derived._09_outpoverall2one_year where patid in (select distinct patid from _10_sub02) ;
		quit;
		
		* Length of Stay in Hospitalizations;
	
				proc sql; 
					create table _10_stat_los_out as  
					select patid
					%do q=1 %to 12;
					%let vars=%scan(los*hosp_ascvd_los*hosp_mi_los*hosp_stroke_los*hosp_pad_los*hosp_angina_los*hosp_revasc_los*hosp_other_los
								*icu_los*icu_stay_los*reh_cvd_los*reh_cvd_stay_los*, &q., *);
						, sum(case when &vars. ge 1 then &vars. end) as &vars.
					%end;
					from _10_hosp2
					GROUP BY patid;
				quit;	
			
		* Length of Stay per Hospitalizations;
				proc sql; 
					create table _10_stat_losperhosp as  
					select patid
					%do q=1 %to 12;
						%let vars=%scan(los*hosp_ascvd_los*hosp_mi_los*hosp_stroke_los*hosp_pad_los*hosp_angina_los*hosp_revasc_los*hosp_other_los
										*icu_los*icu_stay_los*reh_cvd_los*reh_cvd_stay_los, &q., *);
						%let denom=%scan(n_hosp*hosp_ascvd*hosp_mi*hosp_stroke*hosp_pad*hosp_angina*hosp_revasc*hosp_other*icu*icu*reh_cvd*reh_cvd, &q., *);
							, sum(case when &vars. ge 1 then &vars./&denom. end) as &vars._ph
					%end;
					from _10_hosp2
					group by patid;
				quit;	
			
	
		PROC SQL;
			CREATE TABLE _HCRU_FINAL AS
			SELECT a.patid
				,CASE WHEN a.rslt_grp= '<65 ' THEN 'LT_65 ' ELSE 'GE_150' END AS rslt_grp
				,b.*, c.*
			FROM _10_sub02 a 
					LEFT JOIN _10_stat_los_out b on a.patid=b.patid
					LEFT JOIN _10_stat_losperhosp C on a.patid=c.patid
		;
		QUIT;
		


%let source_dset=_HCRU_FINAL;
%let output_dset=zz_HCRU_pvalues;
%let global_options=HEADER ONECOL NOMISSING PVALS FISH STTEST MEDIANS MWUTEST; /* DEFAULTS = AUTOTYPE MISSING NOHEADER NOONECOL NOPVALS INDEPENDENT PARAMETRIC NOSMD MEANS QUARTILES RANGES */ /*ALLCHARS ALLNUMS */
%let strat_var=rslt_grp;
%let weight_var=;
%let pval_comparators=('LT_65 ' 'GE_150');

%let vars=los*hosp_ascvd_los*hosp_mi_los*hosp_stroke_los*hosp_pad_los*hosp_angina_los*hosp_revasc_los*hosp_other_los
								*icu_los*icu_stay_los*reh_cvd_los*reh_cvd_stay_los*							
								los_ph*hosp_ascvd_los_ph*hosp_mi_los_ph*hosp_stroke_los_ph*hosp_pad_los_ph*hosp_angina_los_ph*hosp_revasc_los_ph*hosp_other_los_ph
								*icu_los_ph*icu_stay_los_ph*reh_cvd_los_ph*reh_cvd_stay_los;
%table1_init;
%do i=1 %to %sysfunc(countw(&vars.));
	%let var=%scan(&vars., &i., *);
	%table1_row(&var., N, &var.); 
%end;

DATA zz_HCRU_pvalues1;
	SET zz_HCRU_pvalues;
	IF p1_test='NA' THEN p1_val=' ';
RUN;

PROC PRINT DATA=zz_HCRU_pvalues1;
WHERE trim(value) NOT LIKE  'Z%';
VAR var value LT_65_1 GE_150_1	p1_test	p1_val;
RUN;


%mend stat_hcru;
%stat_hcru;



