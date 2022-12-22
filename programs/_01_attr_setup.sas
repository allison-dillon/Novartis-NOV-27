/*code for Attrition*/
*Medication NDC - cholesterol-lowering treatment;
FILENAME REFFILE '/home/dingyig/proj/NOV-27/import/ndc_list_rev.xlsx';
PROC IMPORT DATAFILE=REFFILE replace
	DBMS=XLSX
	OUT=ndc;
	GETNAMES=YES;
RUN; 

data derived.ndc;
	set ndc (rename=(ndc=old));
	format ndc $11.;
	where not missing(old);
	test=put(old, 11.);
	if length(compress(test))=7 then ndc=cat('0000',compress(test));
	else if length(compress(test))=8 then ndc=cat('000',compress(test));
	else if length(compress(test))=9 then ndc=cat('00',compress(test));
	else if length(compress(test))=10 then ndc=cat('0',compress(test));
	else ndc=test;
	drop old test;
run;

* statin procedure;
%let statin_proc = %str('4002F','4013F','0006F','G9507','G9441','G9664','G8816','G9796');


FILENAME REFFILE '/home/dingyig/proj/NOV-27/import/other_proc.xlsx';
PROC IMPORT DATAFILE=REFFILE replace
	DBMS=XLSX
	OUT=other_proc;
	GETNAMES=YES;
RUN;

data derived.other_proc (rename=(procedure=proc 'code type'n=codetype));
	set other_proc;
	drop description;
run;

PROC SQL; CREATE TABLE heor.optum2_other_proc AS SELECT * FROM derived.other_proc; QUIT;


FILENAME REFFILE '/home/dingyig/proj/NOV-27/import/proc_list_rev.xlsx';
PROC IMPORT DATAFILE=REFFILE replace
	DBMS=XLSX
	OUT=proc_updated;
	GETNAMES=YES;
RUN;

data derived.proc_updated1 ;
	set proc_updated;

run;


* Medication;
%connDBPassThrough(dbname=dingyig, libname1=imp);
execute (drop table if exists imp.optum2_drug PURGE) by imp; 
%connDBRef(dbname=dingyig, libname=imp);  
data imp.optum2_drug; set derived.ndc; run;


* procedures;
%connDBPassThrough(dbname=dingyig, libname1=imp);
execute (drop table if exists optum2_proc PURGE) by imp; 
%connDBRef(dbname=dingyig, libname=imp);  
data imp.optum2_proc; set derived.proc_updated1; run;

data heor.optum2_proc;
	set derived.proc_updated1;
run;

PROC SQL;	DROP TABLE heor.optum2_drug; QUIT;
PROC SQL;
	CREATE TABLE heor.optum2_drug AS 
	SELECT *
	FROM derived.ndc;
QUIT;


/* * procedures; */
/* %connDBPassThrough(dbname=dingyig, libname1=imp); */
/* execute (drop table if exists optum2_proc PURGE) by imp;  */
/* %connDBRef(dbname=dingyig, libname=imp);   */
/* data imp.optum2_proc; set derived.proc_updated1; run; */

* Lp(a) measurements;
%create(optum2_01_lpa_mg )
		select a.*
		from src_optum_claims_panther.dod_lr as a 
			inner join (select z.patid, z.fst_dt, count(z.patid) as cnt
						from (select distinct a.* from src_optum_claims_panther.dod_lr as a
							where a.LOINC_CD = '10835-7'
							and a.RSLT_NBR is not null
							and (a.RSLT_UNIT_NM='MG/DL' or a.RSLT_UNIT_NM='mg/dL' or a.RSLT_UNIT_NM='mg/dl' or lower(a.RSLT_UNIT_NM)='mg/dl')
							and a.RSLT_NBR > 0 /*exclude zero value*/
							) as z
						group by z.patid, z.fst_dt) as b
		on a.patid=b.patid and a.fst_dt=b.fst_dt and b.cnt=1 /*exclude multiple Lp(a) on same day*/
		where year(to_date(a.fst_dt)) >= 2007 
			and year(to_date(a.fst_dt)) <= 2020 
			and a.LOINC_CD = '10835-7'
			and a.RSLT_NBR is not null
			and (a.RSLT_UNIT_NM='MG/DL' or a.RSLT_UNIT_NM='mg/dL' or a.RSLT_UNIT_NM='mg/dl' or lower(a.RSLT_UNIT_NM)='mg/dl')
			and a.RSLT_NBR > 0 /*exclude zero value*/
%create(optum2_01_lpa_mg );

%create(optum2_01_lpa_mol)
		select a.*
		from src_optum_claims_panther.dod_lr as a 
			inner join (select z.patid, z.fst_dt, count(z.patid) as cnt
						from (select distinct a.* from src_optum_claims_panther.dod_lr as a
							where a.LOINC_CD = '43583-4'
							and a.RSLT_NBR is not null
							and a.RSLT_UNIT_NM in ('nmol/Lnmol/LL','nmol/L','NMOL/L')
							and a.RSLT_NBR > 0 /*exclude zero value*/
							) as z
						group by z.patid, z.fst_dt) as b
		on a.patid=b.patid and a.fst_dt=b.fst_dt and b.cnt=1 /*exclude multiple Lp(a) on same day*/
		where year(to_date(a.fst_dt)) >= 2007 
			and year(to_date(a.fst_dt)) <= 2020
			and a.LOINC_CD = '43583-4'
			and a.RSLT_NBR is not null
			and a.RSLT_UNIT_NM in ('nmol/Lnmol/LL','nmol/L','NMOL/L')
			and a.RSLT_NBR > 0 /*exclude zero value*/
%create(optum2_01_lpa_mol);

/*gets patients with multiple measurements on same day*/
%create(optum2_01_mol_test)
		select a.*
		from src_optum_claims_panther.dod_lr as a 
			inner join (select z.patid, z.fst_dt, count(z.patid) as cnt
						from (select distinct a.* from src_optum_claims_panther.dod_lr as a
							where a.LOINC_CD = '43583-4'
							and a.RSLT_NBR is not null
							and a.RSLT_UNIT_NM in ('nmol/Lnmol/LL','nmol/L','NMOL/L')
							and a.RSLT_NBR > 0 /*exclude zero value*/
							) as z
						group by z.patid, z.fst_dt) as b
		on a.patid=b.patid and a.fst_dt=b.fst_dt and b.cnt>1 /*multiple Lp(a) on same day*/
		where year(to_date(a.fst_dt)) >= 2007 
			and year(to_date(a.fst_dt)) <= 2020
			and a.LOINC_CD = '43583-4'
			and a.RSLT_NBR is not null
			and a.RSLT_UNIT_NM in ('nmol/Lnmol/LL','nmol/L','NMOL/L')
			and a.RSLT_NBR > 0 /*exclude zero value*/
%create(optum2_01_mol_test);

/*patients with 0 or missing values.*/
%create(optum2_01_mol_test1)
		select a.*
		from src_optum_claims_panther.dod_lr as a 
			inner join (select z.patid, z.fst_dt, count(z.patid) as cnt
						from (select distinct a.* from src_optum_claims_panther.dod_lr as a
							where a.LOINC_CD = '43583-4'
							and a.RSLT_NBR is not null
							and a.RSLT_UNIT_NM in ('nmol/Lnmol/LL','nmol/L','NMOL/L')
							and a.RSLT_NBR > 0 /*exclude zero value*/
							) as z
						group by z.patid, z.fst_dt) as b
		on a.patid=b.patid and a.fst_dt=b.fst_dt /*multiple Lp(a) on same day*/
		where year(to_date(a.fst_dt)) >= 2007 
			and year(to_date(a.fst_dt)) <= 2020
			and a.LOINC_CD = '43583-4'
			and a.RSLT_UNIT_NM in ('nmol/Lnmol/LL','nmol/L','NMOL/L')
			and (a.RSLT_NBR is null or a.RSLT_NBR = 0) /*exclude zero value*/
%create(optum2_01_mol_test1);


* patients with ASCVD;
%macro ascvd;
	%create(optum2_01_ascvd)
		%do i=1 %to 7;
			%let dxgrp =%scan(cad*cad*cad*cerebro*cerebro*pad*other, &i., *);
			%let dx =%scan(mi*unsta_angina*sta_angina*stroke*tia*pad*other, &i., *);
			select a.patid, a.pat_planid, a.clmid, a.fst_dt as dt, a.diag as code, "&dxgrp." as cat, "&dx." as grp
			from src_optum_claims_panther.dod_diag as a
			where year(to_date(a.fst_dt)) >= 2008
				and year(to_date(a.fst_dt)) <= 2020 
				and a.diag in (&&&dx.) 	
			%if &i. < 7 %then %do; union %end;
		%end;
%create(optum2_01_ascvd);
%mend ascvd;
%ascvd;

* patients with CABG, PCI or stent, endarterectomy and thrombectomy;
/*for HCRU setup, procedure datafile to make it consistent procedure date using Medical table, including POS*/
*Post-revascularization (PCI, CABG, angioplasty and/or stent placement, endarterectomy, thrombectomy);
%macro proc;	
%create(optum2_01_proc0)
		
			/*Medical table*/
			select distinct a.patid, a.fst_dt as dt, a.pos, 'NA' as conf_id, a.proc_cd as code, b.codetype, "revasc" as grp
			from  src_optum_claims_panther.dod_m as a inner join dingyig.optum2_proc as b
			on a.proc_cd=b.code 
			where b.codetype in ('CPT/HCPCS') /*CPT/HCPCS   in Medical table*/
			UNION
			select distinct a.patid, a.fst_dt as dt, a.pos, 'NA' as conf_id, a.proc_cd as code, b.codetype, "revasc" as grp
			from  src_optum_claims_panther.dod_m as a inner join dingyig.optum2_proc as b
			on a.proc_cd=b.code 
			where b.codetype in ('DRG') /*DRG in Medical table*/
			UNION
			/*Procedure table*/
			select distinct a.patid, a.fst_dt as dt, a.pos, 'NA' as conf_id, b.proc as code, b.codetype, "revasc" as grp
			from  src_optum_claims_panther.dod_m as a
				inner join (select distinct a.*, b.codetype 
							from  src_optum_claims_panther.dod_proc as a inner join dingyig.optum2_proc as b
							on a.proc=b.code 
							where a.icd_flag='10' and (b.codetype= 'ICD-10-PCS') /*ICD-Procedure in Procedure table*/
						) as b
			on a.pat_planid=b.pat_planid and a.clmid=b.clmid and a.loc_cd='1'
			union	
			select distinct a.patid, a.fst_dt as dt, a.pos, 'NA' as conf_id, b.proc as code, b.codetype, "revasc" as grp
			from  src_optum_claims_panther.dod_m as a
				inner join (select distinct a.*, b.codetype 
							from  src_optum_claims_panther.dod_proc as a inner join dingyig.optum2_proc as b
							on a.proc=b.code 
							where a.icd_flag='9' and (b.codetype= 'ICD-9-PCS') /*ICD-Procedure in Procedure table*/
						) as b
			on a.pat_planid=b.pat_planid and a.clmid=b.clmid and a.loc_cd='1'
			union		
			/*Facility Detail table*/
			select distinct a.patid, a.fst_dt as dt, a.pos, 'NA' as conf_id, b.proc_cd as code, b.codetype, "revasc" as grp
			from  src_optum_claims_panther.dod_m as a
				inner join (select distinct a.*, b.codetype
							from  src_optum_claims_panther.dod_fd as a inner join dingyig.optum2_proc as b
							on a.proc_cd=b.code 
							where (b.codetype= 'CPT/HCPCS') /*CPT/HCPCS in Facility table*/
							) as b		
			on a.pat_planid=b.pat_planid and a.clmid=b.clmid and a.clmseq=b.clmseq and a.fst_dt=b.fst_dt	
						
			/*Confinement table*/
			%do r=1 %to 5;
				union
				select distinct a.patid, a.admit_date as dt, '98' as pos, a.conf_id, a.proc&r. as code, b.codetype, "revasc" as grp /*confinement table will be POS 98*/
				from  src_optum_claims_panther.dod_c as a inner join dingyig.optum2_proc as b
								on a.proc&r.=b.code
								where a.icd_flag='10' and (b.codetype= 'ICD-10-PCS') /*ICD-Procedure in Confinement table*/
				union
				select distinct a.patid, a.admit_date as dt, '98' as pos, a.conf_id, a.proc&r. as code, b.codetype, "revasc" as grp /*confinement table will be POS 98*/
				from  src_optum_claims_panther.dod_c as a inner join dingyig.optum2_proc as b
								on a.proc&r.=b.code 
								where a.icd_flag='9' and (b.codetype= 'ICD-9-PCS') /*ICD-Procedure in Confinement table*/
			%end;
%create(optum2_01_proc0);


	%create(optum2_01_proc)
		select * 
		from dingyig.optum2_01_proc0 
		where year(to_date(dt)) >= 2007 and to_date(dt) <='2020-06-30 23:59:59.99'
	%create(optum2_01_proc)
		
%mend proc;
%proc;



%macro other_proc;	
	%create(optum2_01_other_proc)
		
			/*Medical table*/
			select distinct a.patid, a.fst_dt as dt, a.pos, 'NA' as conf_id, a.proc_cd as code, b.codetype, b.grp
			from  src_optum_claims_panther.dod_m a inner join dingyig.optum2_other_proc as b
			on a.proc_cd=b.code
			where (b.codetype= 'CPT/HCPCS') /*CPT/HCPCS in Medical table*/
			and to_date(a.fst_dt) <='2020-06-30 23:59:59.99'
			union
			
			select distinct a.patid, a.fst_dt as dt, a.pos, 'NA' as conf_id, a.rvnu_cd as code, b.codetype, b.grp
			from  src_optum_claims_panther.dod_m as a inner join dingyig.optum2_other_proc as b
			on a.rvnu_cd=b.code 
			where (b.codetype= 'Revenue Code') /*Reven code in Medical table*/
			and to_date(a.fst_dt) <='2020-06-30 23:59:59.99'
			union
			/*Procedure table*/
			select distinct a.patid, a.fst_dt as dt, a.pos, 'NA' as conf_id, b.proc as code, b.codetype, b.grp
			from  src_optum_claims_panther.dod_m as a
				inner join (select distinct a.*, b.codetype, b.grp
							from  src_optum_claims_panther.dod_proc as a inner join dingyig.optum2_other_proc as b
							on a.proc=b.code
							where a.icd_flag='10' and (b.codetype= 'ICD10') /*ICD-Procedure in Procedure table*/
						) as b
			on a.pat_planid=b.pat_planid and a.clmid=b.clmid and a.loc_cd='1'
			and to_date(a.fst_dt) <='2020-06-30 23:59:59.99'
			union	
			select distinct a.patid, a.fst_dt as dt, a.pos, 'NA' as conf_id, b.proc as code, b.codetype, b.grp
			from  src_optum_claims_panther.dod_m as a
				inner join (select distinct a.*, b.codetype , b.grp
							from  src_optum_claims_panther.dod_proc as a inner join dingyig.optum2_other_proc as b
							on a.proc=b.code
							where a.icd_flag='9' and ( b.codetype= 'ICD9') /*ICD-Procedure in Procedure table*/
							) as b
			on a.pat_planid=b.pat_planid and a.clmid=b.clmid and a.loc_cd='1'
			and to_date(a.fst_dt) <='2020-06-30 23:59:59.99'
			union		
			/*Facility Detail table*/
			select distinct a.patid, a.fst_dt as dt, a.pos, 'NA' as conf_id, b.proc_cd as code, b.codetype, b.grp
			from  src_optum_claims_panther.dod_m as a
				inner join (select distinct a.*, b.codetype, b.grp
							from  src_optum_claims_panther.dod_fd as a inner join dingyig.optum2_other_proc as b
							on a.proc_cd=b.code
							where (b.codetype= 'CPT/HCPCS') /*CPT/HCPCS in Facility table*/
							) as b		
			on a.pat_planid=b.pat_planid and a.clmid=b.clmid and a.clmseq=b.clmseq and a.fst_dt=b.fst_dt	
			and to_date(a.fst_dt) <='2020-06-30 23:59:59.99'
			union
			select distinct a.patid, a.fst_dt as dt, a.pos, 'NA' as conf_id, b.rvnu_cd as code, b.codetype, b.grp
			from  src_optum_claims_panther.dod_m as a
				inner join (select distinct a.*, b.codetype, b.grp
							from  src_optum_claims_panther.dod_fd as a inner join dingyig.optum2_other_proc as b
							on a.rvnu_cd=b.code 
							where (b.codetype= 'Revenue Code') /*Reven code in Facility table*/
							) as b		
			on a.pat_planid=b.pat_planid and a.clmid=b.clmid and a.clmseq=b.clmseq and a.fst_dt=b.fst_dt	
			and to_date(a.fst_dt) <='2020-06-30 23:59:59.99'
			/*Confinement table*/
			%do r=1 %to 5;
				union
				select distinct a.patid, a.admit_date as dt, '98' as pos, a.conf_id, a.proc&r. as code, b.codetype, b.grp /*confinement table will be POS 98*/
				from  src_optum_claims_panther.dod_c as a inner join dingyig.optum2_other_proc as b
								on a.proc&r.=b.code
								where a.icd_flag='10' and ( b.codetype= 'ICD10') /*ICD-Procedure in Confinement table*/
								and to_date(a.admit_date) <='2020-06-30 23:59:59.99'
				union
				select distinct a.patid, a.admit_date as dt, '98' as pos, a.conf_id, a.proc&r. as code, b.codetype, b. grp /*confinement table will be POS 98*/
				from  src_optum_claims_panther.dod_c as a inner join dingyig.optum2_other_proc as b
								on a.proc&r.=b.code 
								where a.icd_flag='9' and (b.codetype= 'ICD9') /*ICD-Procedure in Confinement table*/
								and to_date(a.admit_date) <='2020-06-30 23:59:59.99'
			%end;
		
%create(optum2_01_other_proc);
%mend;
%other_proc; 


%macro gang_dx;	
	%create(optum2_01_gang)
		select a.patid, a.pat_planid, a.clmid, a.fst_dt as dt, '98' as pos, a.diag as code, a.diag, "gang" as cat, "gang" as grp
			from src_optum_claims_panther.dod_diag a
			where year(to_date(a.fst_dt)) >= 2008
				and year(to_date(a.fst_dt)) <= 2020 
				and a.diag like 'I7026%' 		
%create(optum2_01_gang);
%mend;
%gang_dx; 
