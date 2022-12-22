* save raw data for cohort;


%macro save_raw(optumdata);
	%create(raw_00_&optumdata.)
				select *
				from src_optum_claims_panther.&optumdata. as a
				where patid in (select distinct patid from dingyig._04_cohort_setup)
	%create(raw_00_&optumdata.)

%mend save_raw;

%save_raw (optumdata= dod_c);
%save_raw (optumdata= dod_diag);
%save_raw (optumdata= dod_fd);
%save_raw (optumdata= dod_lr);
%save_raw (optumdata= dod_m);
%save_raw (optumdata= dod_mbr);
%save_raw (optumdata= dod_mbr_co_enroll);
%save_raw (optumdata= dod_mbr_detail);
%save_raw (optumdata= dod_mbrwdeath);
%save_raw (optumdata= dod_proc);
%save_raw (optumdata= dod_r);

/* %macro save_raw_lu (optumdata); */
/* 	%connDBPassThrough(dbname=dingyig., libname1=imp); */
/* 	execute (drop table if exists dingyig..raw_00_&optumdata. PURGE) by imp;  */
/* 	execute(create table dingyig..raw_00_&optumdata. as */
/* 			select * */
/* 			from src_optum_claims_panther.&optumdata.  */
/* 		) by imp; */
/* 	quit; */
/* %mend save_raw_lu; */
/* %save_raw_lu (lu_diagnosis); */
/* %save_raw_lu (lu_ndc); */
/* %save_raw_lu (lu_procedure); */
/* %save_raw_lu (provider); */
/* %save_raw_lu (provider_bridge); */



