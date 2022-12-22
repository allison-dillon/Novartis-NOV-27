libname assign '/mnt/share/sas/';
options mstored sasmstore=assign notes;
options sastrace=',,,ds' sastraceloc=saslog nostsuffix sql_ip_trace=source;
libname heor odbc dsn="rwe" schema="dingyig" USER="dingyig" PASSWORD="MinnNew123!";
libname derived "/home/dingyig/proj/NOV-27";
libname source odbc dsn="rwe" schema="src_optum_claims_panther" USER="dingyig" PASSWORD="MinnNew123!";

options mstored sasmstore=assign notes;
OPTIONS MPRINT MINOPERATOR;
option mlogic mprint SYMBOLGEN;
libname assign '/mnt/share/sas/';
options mstored sasmstore=assign notes;
options sastrace=',,,ds' sastraceloc=saslog nostsuffix sql_ip_trace=source;
%let sysuserpwd=MinnNew123!;
%let uid=dingyig;
%let project=dingyig;
%let prefix=dingyig;
%let schema=src_optum_claims_panther;
libname derived '/home/dingyig/proj/NOV-27';


%global workspace project prefix open_close;

%let project=dingyig;
%let prefix=dingyig;
%let open_close=0;

%macro dropchkf(table);
%if %sysfunc(exist(&table.)) %then %do;
	PROC SQL;
		DROP TABLE &table.;
	QUIT;
%end;
%mend dropchkf;


%macro create(tablename);
	%if &open_close.=0 %then %do;
		%let open_close=1;
		PROC SQL;
		CONNECT TO ODBC AS imp (USER="dingyig" PASSWORD="MinnNew123!" DATASRC='rwe');
			EXECUTE( DROP TABLE IF EXISTS &prefix..&tablename. PURGE ) BY imp;
			EXECUTE(
				CREATE TABLE &prefix..&tablename. AS
	%end;
	%else %do;
		%let open_close=0;
			) BY imp;
			SELECT * FROM CONNECTION TO imp ( 
				SELECT %str(%')&prefix..&tablename.%str(%') As _table, COUNT(*) AS _rows 
				FROM &prefix..&tablename. 
			);
			
		QUIT;
	%end;
%mend create;

%macro select ;
	%if &open_close. EQ 0 %then %do;
	%let open_close=1;
	PROC SQL;
	CONNECT TO ODBC AS rwd_p (USER="dingyig" PASSWORD="MinnNew123!" DATASRC='rwe');
	SELECT * FROM CONNECTION TO rwd_p ( 
	
	
	%end;
	%else %do;
	%let open_close=0;
	);
	DISCONNECT FROM rwd_p;
	QUIT;
	%end;
%mend select;

*imports list of all cholesterol ndcs*;
/* FILENAME REFFILE '/home/dingyig/proj/ASCVD_Optum/cholesterol_ndc.xlsx'; */
/* PROC IMPORT DATAFILE=REFFILE replace */
/* 	DBMS=XLSX */
/* 	OUT=chol_ndc; */
/* 	GETNAMES=YES; */
/* RUN; */

/* %connDBPassThrough(dbname=dingyig, libname1=imp); */
/* execute (drop table if exists dingyig.chol_ndc PURGE) by imp; */
/* %connDBRef(dbname=dingyig, libname=imp); */
/* data imp.chol_ndc; set chol_ndc; run;		 */


%let mi = %str('410','4100','41000','41001','41002','4101','41010','41011','41012','4102','41020','41021','41022','4103','41030','41031','41032','4104','41040',
'41041','41042','4105','41050','41051','41052','4106','41060','41061','41062','4107','41070','41071','41072','4108','41080','41081','41082','4109','41090','41091',
'41092','412','42979','I21','I210','I2101','I2102','I2109','I211','I2111','I2119','I212','I2121','I2129','I213','I214','I219','I21A','I21A1','I21A9','I22','I220',
'I221','I222','I228','I229','I230','I231','I232','I233','I234','I235','I236','I237','I238','I252');

%let stroke = %str('43301','43311','43321','43331','43381','43391','43401','43411','43491','I63','I630','I6300','I6301','I63011','I63012','I63013','I63019','I6302','I6303','I63031','I63032','I63033','I63039','I6309','I631','I6310','I6311','I63111','I63112','I63113','I63119','I6312','I6313','I63131','I63132','I63133','I63139','I6319','I632','I6320','I6321',
'I63211','I63212','I63213','I63219','I6322','I6323','I63231','I63232','I63233','I63239','I6329','I633','I6330','I6331','I63311','I63312','I63313','I63319','I6332','I63321','I63322','I63323','I63329','I6333','I63331','I63332','I63333','I63339','I6334','I63341','I63342','I63343','I63349','I6339','I634','I6340','I6341','I63411','I63412','I63413',
'I63419','I6342','I63421','I63422','I63423','I63429','I6343','I63431','I63432','I63433','I63439','I6344','I63441','I63442','I63443','I63449','I6349','I635','I6350','I6351','I63511','I63512','I63513','I63519','I6352','I63521','I63522','I63523','I63529','I6353','I63531','I63532','I63533','I63539','I6354','I63541','I63542','I63543','I63549','I6359',
'I636','I638','I6381','I6389','I639');

%let pad = %str('440','4402','4402','44021','44022','44023','44024','44029','4403','4403','44031','44032','4404','4408','4409','445','I700','I701',
'I70201','I70202','I70203','I70208','I70209','I7021','I70211','I70212','I70213','I70218','I70219','I70221','I70222','I70223','I70228','I70229','I70231','I70232','I70233','I70234','I70235','I70238','I70239','I70241','I70242','I70243','I70244','I70245','I70248','I70249','I7025','I70261','I70262','I70263','I70268','I70269','I70291','I70292',
'I70293','I70298','I70299','I70301','I70302','I70303','I70308','I70309','I7031','I70311','I70312','I70313','I70318','I70319','I70321','I70322','I70323','I70328','I70329','I70331','I70332',
'I70333','I70334','I70335','I70338','I70339','I70341','I70342','I70343','I70344','I70345','I70348','I70349','I7035','I70361','I70362','I70363','I70368','I70369','I70391','I70392','I70393','I70398','I70399','I70401','I70402','I70403','I70408','I70409','I7041','I70411','I70412','I70413','I70418','I70419','I70421','I70422','I70423','I70428','I70429','I70431','I70432','I70433','I70434',
'I70435','I70438','I70439','I70441','I70442','I70443','I70444','I70445','I70448','I70449','I7045','I70461','I70462','I70463','I70468','I70469','I70491','I70492','I70493','I70498','I70499','I70501','I70502','I70503','I70508','I70509','I7051	','I70511','I70512','I70513','I70518','I70519','I70521','I70522','I70523','I70528','I70529','I70531','I70532','I70533','I70534','I70535','I70538',
'I70539','I70541','I70542','I70543','I70544','I70545','I70548','I70549','I7055','I70561','I70562','I70563','I70568','I70569','I70591','I70592','I70593','I70598','I70599','I70601','I70602','I70603','I70608','I70609','I7061','I70611','I70612','I70613','I70618','I70619','I70621','I70622','I70623','I70628','I70629','I70631','I70632','I70633','I70634','I70635','I70638','I70639','I70641','I70642','I70643','I70644','I70645','I70648','I70649','I7065','I70661','I70662','I70663','I70668','I70669','I70691','I70692','I70693','I70698','I70699','I70701','I70702','I70703','I70708','I70709','I7071','I70711','I70712','I70713','I70718','I70719','I70721','I70722','I70723',
'I70728','I70729','I70731','I70732','I70733','I70734','I70735','I70738','I70739','I70741','I70742','I70743','I70744','I70745','I70748','I70749','I7075','I70761',
'I70762','I70763','I70768','I70769','I70791','I70792','I70793','I70798','I70799','I708','I7090','I7091','I7092');

/*gangrene for MACE rates*/
%let gang=%str('I7026');

%let unsta_angina = %str('4111','I200','I25110','I25700','I25710','I25720','I25730','I25750','I25760','I25790');

%let sta_angina = %str('413','4130','4139','I20','I208','I209','I2511','I25111','I25118','I25119','I257','I2570','I25701','I25708'
,'I25709','I2571','I25711','I25718','I25719','I2572','I25721','I25728','I25729','I2573','I25731',
'I25738','I25739','I2575','I25751','I25758','I25759','I2576','I25761','I25768','I25769','I2579','I25791','I25798','I25799');
			
%let tia = %str('435','4350','4351','4352','4353','4358','4359','G450','G451','G452','G453','G458','G459','G460','G461','G462','I67848');

%let other = %str('414','41401','41402','41403','41404','41405','41406','41407','4142','4143','4144','4148','I2510','I25810','I25811','I25812','I2582',
'I2583','I2584','43300','43310','43320','43330','43380','43390','I65','I650','I6501','I6502','I6503','I6509','I651','I652','I6521','I6522','I6523','I6529',
'I658','I659','I66','I660','I6601','I6602','I6603','I6609','I661','I6611','I6612','I6613','I6619','I662','I6621','I6622','I6623','I6629','I663','I668','I669','I672');

*gangrene for MACE rates;
%let gang=%str('I7026');

* Aortic valve stenosis;
%let avs_icd = %str('I35','I350','I351','I352','I358','I359','4241');
%let avs_icd_proc = %str('02RF07Z','02RF08Z','02RF0JZ','02RF0KZ','02RF37H','02RF37Z','02RF38H','02RF38Z','02RF3JH','02RF3JZ','02RF3KH','02RF3KZ','3521','3522','3505','3506');


* place of service;
%let inp_pos = %str('21','34','51','55','56','61');
%let outp_pos = %str('2','3','4','11','12','13','14','15','16','17','20','22','24','41','42','49','50','53','57','60','62','65','71');
%let er_pos = %str('23');


%let inp_pos=%str('21','34','51','55','56','61');
%let er_pos=%str('23');
%let outp_pos=%str('2','3','4','11','12','13','14','15','16','17','20','22','24','41','42','49','50','53','57','60','62','65','71');


%macro table1_init;
	OPTIONS MINOPERATOR MPRINT;
	ODS GRAPHICS OFF;

	%global rn missing header pvals onecol means medians meanmed minmax smds n_strats strat_names cost mean_ptest median_ptest patid;
	%let rn=0;
	%let missing       = TRUE;
	%let header        = FALSE;
	%let pvals         = FALSE;
	%let onecol        = FALSE;
	%let means         = TRUE ;
	%let medians       = TRUE ;
	%let meanmed       = FALSE;
	%let minmax        = FALSE;
	%let smds          = FALSE;
	%let cost          = FALSE;

	%if NOMISSING     IN (&global_options.) %then %do; %let missing       = FALSE; %end;
	%if HEADER        IN (&global_options.) %then %do; %let header        = TRUE ; %end;
	%if PVALS         IN (&global_options.) %then %do; %let pvals         = TRUE ; %end;
	%if ONECOL        IN (&global_options.) %then %do; %let onecol        = TRUE ; %end;
	%if NOMEANS       IN (&global_options.) %then %do; %let means         = FALSE; %end;
	%if NOMEDIANS     IN (&global_options.) %then %do; %let medians       = FALSE; %end;
	%if MEANMED       IN (&global_options.) %then %do; %let meanmed       = TRUE;  %end;
	%if MINMAX        IN (&global_options.) %then %do; %let minmax        = TRUE;  %end;
	%if SMDS          IN (&global_options.) %then %do; %let smds          = TRUE ; %end;
	%if COST          IN (&global_options.) %then %do; %let COST          = TRUE ; %end;

	%if STTEST  IN (&global_options.) %then %do; %let mean_ptest = STTEST ; %end;
	%else %if PSTTEST IN (&global_options.) %then %do; %let mean_ptest = PSTTEST; %end;
	%else %if ANOVA   IN (&global_options.) %then %do; %let mean_ptest = ANOVA  ; %end;
	%else %if RMANOVA IN (&global_options.) %then %do; %let mean_ptest = RMANOVA; %end;
	%else %let mean_ptest = NONE;
	
	%if MWUTEST IN (&global_options.) %then %do; %let median_ptest = MWUTEST; %end;
	%else %if WSRTEST IN (&global_options.) %then %do; %let median_ptest = WSRTEST; %end;
	%else %if KWTEST  IN (&global_options.) %then %do; %let median_ptest = KWTEST ; %end;
	%else %if FMTEST  IN (&global_options.) %then %do; %let median_ptest = FMTEST ; %end;
	%else %let median_ptest = NONE;
	
/* 	%let char_tests=PCHI LRCHI MHCHI AJCHI FISH MCNEM CMHGA CMHCOR CMHRMS; */

	PROC CONTENTS DATA=&source_dset. OUT=contents (KEEP=name type) NOPRINT; RUN;
	PROC SQL NOPRINT;
		SELECT name INTO :patid FROM contents
		WHERE LOWCASE(name) IN ('enrolid','patid','ptid','pat_id','pat_key','patientid');
	QUIT;

	PROC SQL NOPRINT;
		SELECT COUNT(DISTINCT &strat_var.), COUNT(*) INTO :n_strats, :denom0 FROM &source_dset.;
		%let n_strats=%sysfunc(COMPRESS(&n_strats.));
	
		SELECT denom INTO :denom1-:denom&n_strats.
		FROM (SELECT &strat_var., COUNT(*) AS denom FROM &source_dset. GROUP BY &strat_var.)
		ORDER BY &strat_var.;

		SELECT COUNT(*) INTO: denom0 FROM &source_dset.;

		SELECT DISTINCT &strat_var. INTO :strat_names SEPARATED BY '*' FROM &source_dset. ORDER BY &strat_var.;
	QUIT;
	
	DATA header_row;
		FORMAT var value $64.;
		var="PLACEHOLDER";
		value="PLACEHOLDER";
	RUN;
	
	PROC DATASETS lib=work NOLIST;
		DELETE &output_dset.;
	RUN; QUIT;
	
	DATA &output_dset.;
		FORMAT var value $64. col0_1 %do sn=1 %to &n_strats.; %scan(&strat_names., &sn., *)_1 %end; $30.;
		var="Total";
		value="Total";
		col0_1=&denom0.;
		%do sn=1 %to &n_strats.; %if %scan(&strat_names., &sn., *)='. (.%)' %then %scan(&strat_names., &sn., *)='-'; %end;
		%do sn=1 %to &n_strats.; %scan(&strat_names., &sn., *)_1=&&denom&sn.; %end;
	RUN;
	
%mend table1_init;

%macro table1_row(var, row_options, hlabel, test);

	%let rn=%eval(&rn.+1);
	%if "&hlabel." EQ "" %then %let hlabel=&var.;
	%if "&row_options." EQ "" %then %let row_options=NONE;
	
	%let row_missing       = FALSE;
	%let row_header        = FALSE;
	%let row_means         = FALSE;
	%let row_medians       = FALSE;
	%let row_meanmed       = FALSE;
	%let row_minmax        = FALSE;
	%let row_smds          = FALSE;
	%let row_cost          = FALSE;

	%if (&missing. EQ TRUE AND NOT(NOMISSING IN (&row_options.))) OR (MISSING IN (&row_options.)) %then %let row_missing=TRUE;
	%if (&header.  EQ TRUE AND NOT(NOHEADER  IN (&row_options.))) OR (HEADER  IN (&row_options.)) %then %let row_header =TRUE;
	%if (&means.   EQ TRUE AND NOT(NOMEANS   IN (&row_options.))) OR (MEANS   IN (&row_options.)) %then %let row_means  =TRUE;
	%if (&medians. EQ TRUE AND NOT(NOMEDIANS IN (&row_options.))) OR (MEDIANS IN (&row_options.)) %then %let row_medians=TRUE;
	%if (&meanmed. EQ TRUE AND NOT(NOMEANMED IN (&row_options.))) OR (MEANMED IN (&row_options.)) %then %let row_meanmed=TRUE;
	%if (&minmax.  EQ TRUE AND NOT(NOMINMAX  IN (&row_options.))) OR (MINMAX  IN (&row_options.)) %then %let row_minmax =TRUE;
	%if (&smds.    EQ TRUE AND NOT(NOSMDS    IN (&row_options.))) OR (SMDS    IN (&row_options.)) %then %let row_smds   =TRUE;		
	%if (&cost.    EQ TRUE AND NOT(NOCOST    IN (&row_options.))) OR (COST    IN (&row_options.)) %then %let row_cost   =TRUE;		

	%if STTEST  IN (&row_options.) %then %do; %let row_mean_ptest = STTEST ; %end;
	%else %if PSTTEST IN (&row_options.) %then %do; %let row_mean_ptest = PSTTEST; %end;
	%else %if ANOVA   IN (&row_options.) %then %do; %let row_mean_ptest = ANOVA  ; %end;
	%else %if RMANOVA IN (&row_options.) %then %do; %let row_mean_ptest = RMANOVA; %end;
	%else %let row_mean_ptest = &mean_ptest.;
	
	%if MWUTEST IN (&row_options.) %then %do; %let row_median_ptest = MWUTEST; %end;
	%else %if WSRTEST IN (&row_options.) %then %do; %let row_median_ptest = WSRTEST; %end;
	%else %if KWTEST  IN (&row_options.) %then %do; %let row_median_ptest = KWTEST ; %end;
	%else %if FMTEST  IN (&row_options.) %then %do; %let row_median_ptest = FMTEST ; %end;
	%else %let row_median_ptest = &median_ptest.;

	PROC SQL NOPRINT;
		SELECT type INTO: var_type
		FROM contents
		WHERE LOWCASE(name) EQ LOWCASE("&var.");
	QUIT;
	
	%if &var_type. EQ 2 %then %let row_type=C;
	%else %if C IN (&row_options.) %then %let row_type=C;
	%else %if N IN (&row_options.) %then %let row_type=N;
	%else %if ALLCHARS IN (&global_options.) %then %let row_type=C;
	%else %if ALLNUMS IN (&global_options.) %then %let row_type=N;
	%else %if &var_type. EQ 1 %then %let row_type=N;

	/* CATEGORICAL VARIABLES */
	%if &var_type. IN (1 2) AND C IN (&row_options.) %then %do; 	
		PROC FREQ DATA=&source_dset. NOPRINT;
			%if &row_missing. EQ FALSE %then WHERE NOT MISSING(&var.);;
			%if &weight_var. NE %then WEIGHT &weight_var.;;
			TABLES &var. / %if &row_missing. EQ TRUE %then MISSING; OUT=&var._setup0 (DROP=percent);
		RUN;
		
		PROC FREQ DATA=&source_dset. NOPRINT;
			%if &row_missing. EQ FALSE %then WHERE NOT MISSING(&var.);;
			%if &weight_var. NE %then WEIGHT &weight_var.;;
			TABLES &var.*&strat_var. / %if &row_missing. EQ TRUE %then MISSING; OUT=&var._setup1 (DROP=percent);
		RUN;
		
		PROC TRANSPOSE DATA=&var._setup1 OUT=&var._setup2 (DROP=_LABEL_) NAME=&strat_var.;
			BY &var.;
			ID &strat_var.;
			VAR count;
		RUN;

		%if &pvals. EQ TRUE %then %do pn=1 %to %sysfunc(COUNTW(&pval_comparators., *));
			%let samples=%scan(&pval_comparators., &pn., *);
			%let ptest&pn.=NA;		
			%let pval&pn.=;		
			
			PROC SQL NOPRINT;
				SELECT COUNT(DISTINCT &var.) INTO :uniq_values FROM &source_dset. WHERE &strat_var. IN &samples.
				%if &row_missing. EQ FALSE %then AND NOT MISSING(&var.);;
			QUIT;
			
			/*%if &dependent. EQ TRUE AND %sysfunc(COUNTW(&samples.)) EQ 2 AND &uniq_values. EQ 2 %then %do; %let mcnem=TRUE; %end;*/
		
			PROC FREQ DATA=&source_dset. NOPRINT;
				WHERE &strat_var. IN &samples.
					%if &row_missing. EQ FALSE %then AND NOT MISSING(&var.);;
				%if &weight_var. NE %then WEIGHT &weight_var.;;
				TABLES &var.*&strat_var. / LIST CHISQ FISHER CMH AGREE WARN=OUTPUT;
				EXACT TREND / MAXTIME=1; 
				OUTPUT CHISQ CMH MCNEM OUT=stats_output (RENAME=xp2_fish=p_fish); 
			RUN; 
			
			%if %sysfunc(EXIST(stats_output)) %then %do;
				PROC SQL NOPRINT;
					SELECT p_fish, "FISH" INTO :pval&pn., :ptest&pn. FROM stats_output; 
					%if &&pval&pn. EQ . %then %do;
						SELECT p_pchi, "PCHI*" INTO :pval&pn., :ptest&pn. FROM stats_output; 
					%end;
				QUIT;
			%end;
			
			%let smd&pn.=.;
			%if &row_smds. EQ TRUE %then %do;
				%table1_smd;
			%end;
		%end;
		
		DATA &var._setup3 (DROP=&var.);
			FORMAT var $32. value $64. %if &pvals. EQ TRUE %then %do pn=1 %to %sysfunc(COUNTW(&pval_comparators., *)); p&pn._test p&pn._val $10. %end;;
			MERGE &var._setup0 (RENAME=count=COL0) &var._setup2;
			BY &var.;
			var="&var.";
			value=&var.;
			IF _N_ EQ 1 THEN DO;
				%if &pvals. EQ TRUE %then %do pn=1 %to %sysfunc(COUNTW(&pval_comparators., *));
					p&pn._test="&&ptest&pn.";
					p&pn._val="&&pval&pn."; 
					if input(p&pn._val, 10.4)<.0001 then p&pn._val='<.0001';
				%end;
				%if &smds. EQ TRUE %then %do pn=1 %to %sysfunc(COUNTW(&pval_comparators., *));
					smd&pn.=&&smd&pn.;
				%end;
			END;
		RUN;
		
		PROC CONTENTS DATA=&var._setup3 OUT=strats_present (KEEP=name type) NOPRINT; RUN;
		PROC SQL NOPRINT;
			SELECT COMPRESS(name) INTO :strats_present SEPARATED BY ' ' FROM strats_present;
		QUIT;

		PROC SQL;
			CREATE TABLE row&rn. AS
			SELECT var, value
				%if &onecol. EQ FALSE %then %do sn=1 %to %eval(&n_strats.+1);
					%let colname=%scan(col0*&strat_names., &sn., *);
					%if &colname. IN (&strats_present.) %then %do;
						, CASE WHEN &colname. is not null then PUT(&colname., BEST8.) else '-' end as &colname._1 LENGTH=20
						, CASE WHEN &colname. is not null then PUT(&colname./SUM(&colname.), BEST8.) else '-' end AS &colname._2 LENGTH=20
					%end;
					%else %do;
						, '-' AS &colname._1 LENGTH=20
						, '-' AS &colname._2 LENGTH=20
					%end;
				%end;
				%else %do sn=1 %to %eval(&n_strats.+1);
					%let colname=%scan(col0*&strat_names., &sn., *);
					%if &colname. IN (&strats_present.) %then %do;
						, CASE WHEN &colname. is not null then COMPRESS(PUT(&colname., BEST8.))||" ("||COMPRESS(PUT(&colname./SUM(&colname.)*100, 8.1))||"%)"  else '-' end AS &colname._1 LENGTH=20
					%end;
					%else %do;
						, '-' AS &colname._1 LENGTH=20
					%end;
				%end;
				%if &pvals. EQ TRUE %then %do pn=1 %to %sysfunc(COUNTW(&pval_comparators., *));
					, p&pn._test, p&pn._val
				%end;
				%if &smds. EQ TRUE %then %do pn=1 %to %sysfunc(COUNTW(&pval_comparators., *));
					, smd&pn.
				%end;
			FROM &var._setup3;
		QUIT;
		
	%end;
	
	/* CONTINUOUS VARIABLES */
	%else %if &var_type. EQ 1 AND N IN (&row_options.) %then %do; 	 
		PROC MEANS DATA=&source_dset. NOPRINT;
			FORMAT &var. BEST8.;
			%if &weight_var. NE %then WEIGHT &weight_var.;;
			CLASS &strat_var.;
			VAR &var.;
			OUTPUT OUT=&var._setup (DROP=_TYPE_ _FREQ_) MEAN= STDDEV= MEDIAN= Q1= Q3= MIN= MAX=/ AUTONAME;
		RUN;

		%if &pvals. EQ TRUE %then %do pn=1 %to %sysfunc(COUNTW(&pval_comparators., *));
			%let samples=%scan(&pval_comparators., &pn., *);
		
			%let mean_ptest&pn.=NA;
			%let mean_pval&pn.=;
			%let mean_df&pn.=;
			%if &row_means. EQ TRUE %then %do;
				%if &row_mean_ptest. = STTEST %then %do;
					ODS SELECT NONE;
					ODS OUTPUT EQUALITY=stats_output1 TTESTS=stats_output2;
					PROC TTEST DATA=&source_dset.;
						WHERE &strat_var. IN &samples.;
						%if &weight_var. NE %then WEIGHT &weight_var.;;
						VAR &var.;
						CLASS &strat_var.;
					RUN;
					ODS SELECT ALL;
					
					%if %sysfunc(EXIST(stats_output1)) AND %sysfunc(EXIST(stats_output2)) %then %do;
						PROC SQL NOPRINT;
							SELECT CASE WHEN probf < 0.05 THEN 'Unequal' ELSE 'Equal' END INTO :variance_type FROM stats_output1;
							SELECT probt, "STTEST" INTO :mean_pval&pn., :mean_ptest&pn. FROM stats_output2 WHERE variances EQ "&variance_type.";
						QUIT;
					%end;
				%end;
				%if &row_mean_ptest. = PSTTEST %then %do;
					PROC SQL NOPRINT;
						SELECT DISTINCT COMPRESS(&strat_var.) INTO :psttest_strats SEPARATED BY " " FROM &source_dset.
						WHERE &strat_var. IN &samples.;
						SELECT COUNT(DISTINCT &strat_var.) INTO :psttest_n_strats FROM &source_dset. WHERE &strat_var. IN &samples.;
					QUIT;

					%if &psttest_n_strats. EQ 2 %then %do;
						DATA stats_output_setup1 stats_output_setup2;
							SET &source_dset. (KEEP=&patid. &strat_var. &var.);
							WHERE &strat_var. IN &samples.;
							IF NOT MISSING(&var.) THEN DO;
								IF &strat_var. EQ "%scan(&psttest_strats., 1)" THEN OUTPUT stats_output_setup1;
								ELSE IF &strat_var. EQ "%scan(&psttest_strats., 2)" THEN OUTPUT stats_output_setup2;
							END;
						RUN;
						PROC SORT DATA=stats_output_setup1; BY &patid; RUN;
						PROC SORT DATA=stats_output_setup2; BY &patid; RUN;
						
						DATA stats_output_setup;
							MERGE stats_output_setup1 (IN=a RENAME=&var.=psttest_var1) stats_output_setup2 (IN=b RENAME=&var.=psttest_var2);
							BY &patid.;
							IF a AND b;
						RUN;
					
						ODS SELECT NONE;
						ODS OUTPUT TTests=stats_output;
						PROC TTEST DATA=stats_output_setup SIDES=2 ALPHA=0.05 H0=0;
							PAIRED psttest_var2 * psttest_var1;
						RUN;
						ODS SELECT ALL;
						
						%if %sysfunc(EXIST(stats_output)) %then %do;
							PROC SQL NOPRINT;
								SELECT Probt, "PSTTEST", df INTO :mean_pval&pn., :mean_ptest&pn., :mean_df&pn. FROM stats_output;
							QUIT;
						%end;
					%end;
				%end;
				%if &row_mean_ptest. = ANOVA %then %do;
					ODS SELECT NONE;
					ODS OUTPUT ModelANOVA=stats_output;
					PROC ANOVA DATA=&source_dset.;
						WHERE &strat_var. IN &samples.;
						CLASS &strat_var.;
						MODEL &var. = &strat_var.;
					RUN;
					ODS SELECT ALL;
					
					%if %sysfunc(EXIST(stats_output)) %then %do;
						PROC SQL NOPRINT;
							SELECT ProbF, "ANOVA" INTO :mean_pval&pn., :mean_ptest&pn. FROM stats_output;
						QUIT;
					%end;
				%end;
				%if &row_mean_ptest. = RMANOVA %then %do;
				%end;
			%end;

			%let median_ptest&pn.=NA;
			%let median_pval&pn.=;
			%let median_df&pn.=;
			%if &row_medians. EQ TRUE %then %do;
				%if &row_median_ptest. = MWUTEST %then %do;
					ODS SELECT NONE;
					PROC NPAR1WAY DATA=&source_dset. WILCOXON;
						WHERE &strat_var. IN &samples.;
	/* 					%if &weight_var. NE %then WEIGHT &weight_var.;; */
						VAR &var.;
						CLASS &strat_var.;
						OUTPUT OUT=wtest; 
					RUN;
					ODS SELECT ALL;
					
					%if %sysfunc(EXIST(wtest)) %then %do;
						PROC SQL NOPRINT;
							SELECT p2_wil, "MWU" INTO :median_pval&pn., :median_ptest&pn. FROM wtest;
						QUIT;
					%end;
				%end;
				%if &row_median_ptest. = WSRTEST %then %do;
					PROC SQL NOPRINT;
						SELECT DISTINCT COMPRESS(&strat_var.) INTO :wsrtest_strats SEPARATED BY " " FROM &source_dset. WHERE &strat_var. IN &samples.;
						SELECT COUNT(DISTINCT &strat_var.) INTO :wsrtest_n_strats FROM &source_dset. WHERE &strat_var. IN &samples.;
					QUIT;

					%if &wsrtest_n_strats. EQ 2 %then %do;
						DATA stats_output_setup1 stats_output_setup2;
							SET &source_dset. (KEEP=&patid. &strat_var. &var.);
							WHERE &strat_var. IN &samples.;
							IF NOT MISSING(&var.) THEN DO;
								IF &strat_var. EQ "%scan(&wsrtest_strats., 1)" THEN OUTPUT stats_output_setup1;
								ELSE IF &strat_var. EQ "%scan(&wsrtest_strats., 2)" THEN OUTPUT stats_output_setup2;
							END;
						RUN;
						PROC SORT DATA=stats_output_setup1; BY &patid; RUN;
						PROC SORT DATA=stats_output_setup2; BY &patid; RUN;
						
						DATA stats_output_setup;
							MERGE stats_output_setup1 (IN=a RENAME=&var.=wsrtest_var1) stats_output_setup2 (IN=b RENAME=&var.=wsrtest_var2);
							BY &patid.;
							IF a AND b;
							wsrtest_diff=wsrtest_var2-wsrtest_var1;
						RUN;
						
						ODS SELECT NONE;
						ODS OUTPUT TestsForLocation=stats_output1 Moments=stats_output2;
						PROC UNIVARIATE DATA=stats_output_setup;
							VAR wsrtest_diff;
						RUN;
						ODS SELECT ALL;

						%if %sysfunc(EXIST(stats_output1)) %then %do;
							PROC SQL NOPRINT;
								SELECT pValue, "WSR" INTO :median_pval&pn., :median_ptest&pn. FROM stats_output1 WHERE test = 'Signed Rank';
								SELECT cValue1 INTO :median_df&pn. FROM stats_output2 WHERE label1='N';
							QUIT;
						%end;
					%end;
				%end;
				%if &row_median_ptest. = KWTEST %then %do;
					ODS SELECT NONE;
					PROC NPAR1WAY DATA=&source_dset. WILCOXON;
						WHERE &strat_var. IN &samples.;
	/* 					%if &weight_var. NE %then WEIGHT &weight_var.;; */
						VAR &var.;
						CLASS &strat_var.;
						OUTPUT OUT=wtest; 
					RUN;
					ODS SELECT ALL;
					
					%if %sysfunc(EXIST(wtest)) %then %do;
						PROC SQL NOPRINT;
							SELECT p_kw, "KW" INTO :median_pval&pn., :median_ptest&pn. FROM wtest;
						QUIT;
					%end;
				%end;
				%if &row_median_ptest. = FMTEST %then %do;
					ODS SELECT NONE;
					ODS OUTPUT CMH=cmh;
					PROC FREQ DATA=&source_dset.;
						TABLES &strat_var.*&var. / CMH2 SCORES=RANK NOPRINT;
					RUN;
					ODS SELECT ALL;
					
					%if %sysfunc(EXIST(cmh)) %then %do;
						PROC SQL NOPRINT;
							SELECT prob, "FM" INTO :median_pval&pn., :median_ptest&pn. FROM cmh WHERE AltHypothesis = 'Row Mean Scores Differ';
						QUIT;
					%end;
				%end;
			%end;
			
			%let smd&pn.=.;
			%if &row_smds. EQ TRUE %then %do;
				%table1_smd;
			%end;
		%end;
		
		DATA row&rn. (KEEP=var value
				%do sn=1 %to %eval(&n_strats.+1); 
					%let colname=%scan(col0*&strat_names., &sn., *);
					&colname.: 
				%end;
				%if &pvals. EQ TRUE %then %do; p: %end; 
				%if &smds. EQ TRUE %then %do; smd: %end;
			);
			MERGE 
				%do sn=1 %to %eval(&n_strats.+1);
					%let colname=%scan(col0*&strat_names., &sn., *);
					&var._setup (
						RENAME=(&var._mean=mean_&colname. &var._stddev=sd_&colname. &var._median=median_&colname. &var._q1=q1_&colname. &var._q3=q3_&colname. &var._min=min_&colname. &var._max=max_&colname.)
						%if &colname. EQ col0 %then %do; WHERE=(MISSING(&strat_var.)) %end;
						%else %do; WHERE=(&strat_var. EQ "&colname.") %end;
					)
				%end;;
			FORMAT var $32. value $64. 
				%do sn=1 %to %eval(&n_strats.+1); 
					%let colname=%scan(col0*&strat_names., &sn., *);
					&colname._1 $30.
					%if &onecol. EQ FALSE %then %do; &colname._2 $30. %end;
				%end;
				%if &pvals. EQ TRUE %then %do pn=1 %to %sysfunc(COUNTW(&pval_comparators., *)); p&pn._test p&pn._val $10. %end;;
			var="&var.";
			%if &row_means. EQ TRUE %then %do;
				value="Mean (SD)";
				%do sn=1 %to %eval(&n_strats.+1); 
					%let colname=%scan(col0*&strat_names., &sn., *);
					%if &onecol. EQ FALSE AND &row_cost. EQ FALSE %then %do;
						&colname._1 = COMPRESS(PUT(mean_&colname., 10.2));
						&colname._2 = COMPRESS(PUT(SD_&colname., 10.2));
					%end;
					%else %if &onecol. EQ FALSE AND &row_cost. EQ TRUE %then %do;
						&colname._1 = "$"||COMPRESS(PUT(mean_&colname., 10.2));
						&colname._2 = "$"||COMPRESS(PUT(SD_&colname., 10.2));
					%end;
					%else %if &onecol. EQ TRUE AND &row_cost. EQ TRUE %then %do;
						&colname._1 = COMPRESS("$"||PUT(mean_&colname.,10.2))||" ($"||COMPRESS(PUT(SD_&colname., 10.2))||")";
					%end;
					%else %if &onecol. EQ TRUE AND &row_cost. EQ FALSE %then %do;
						&colname._1 = COMPRESS(PUT(mean_&colname, 10.2))||" ("||COMPRESS(PUT(SD_&colname., 10.2))||")";
					%end;
				%end;
				%if &pvals. EQ TRUE %then %do pn=1 %to %sysfunc(COUNTW(&pval_comparators., *));
					p&pn._test="&&mean_ptest&pn.";
					p&pn._val="&&mean_pval&pn.";
					%if &&mean_df&pn. NE %then %do; p&pn._df=&&mean_df&pn.; %end;
					%if &row_smds. EQ TRUE %then %do; smd&pn.=.; %end;
					IF p&pn._test NE "NA" AND INPUT(p&pn._val, 10.4)<.0001 THEN p&pn._val='<.0001';
				%end;
				OUTPUT;
			%end;
			%if &row_meanmed. EQ TRUE %then %do;
				value="Mean (Median)";
				%do sn=1 %to %eval(&n_strats.+1); 
					%let colname=%scan(col0*&strat_names., &sn., *);
					%if &onecol. EQ FALSE AND &row_cost. EQ FALSE %then %do;
						&colname._1 = COMPRESS(PUT(mean_&colname., 10.1));
						&colname._2 = COMPRESS(PUT(median_&colname., 10.1));
					%end;
					%else %if &onecol. EQ FALSE AND &row_cost. EQ TRUE %then %do;
						&colname._1 = "$"||COMPRESS(PUT(mean_&colname., 10.2));
						&colname._2 = "$"||COMPRESS(PUT(median_&colname., 10.2));
					%end;
					%else %if &onecol. EQ TRUE AND &row_cost. EQ TRUE %then %do;
						&colname._1 = COMPRESS("$"||PUT(mean_&colname.,10.2))||" ($"||COMPRESS(PUT(median_&colname., 10.2))||")";
					%end;
					%else %if &onecol. EQ TRUE AND &row_cost. EQ FALSE %then %do;
						&colname._1 = COMPRESS(PUT(mean_&colname, 10.2))||" ("||COMPRESS(PUT(median_&colname., 10.2))||")";
					%end;
				%end;
				%if &pvals. EQ TRUE %then %do pn=1 %to %sysfunc(COUNTW(&pval_comparators., *));
					p&pn._test="";
					p&pn._val="";
					%if &&mean_df&pn. NE %then %do; p&pn._df=.; %end;
				%end;
				OUTPUT;
			%end;
			%if &row_medians. EQ TRUE %then %do;
				value="Median (Q1 - Q3)";
				%do sn=1 %to %eval(&n_strats.+1); 
					%let colname=%scan(col0*&strat_names., &sn., *);		
					%if &onecol. EQ FALSE AND &row_cost. EQ FALSE %then %do;
						&colname._1 = PUT(ROUND(median_&colname.,.1), 10.2);
						&colname._2 = COMPRESS(PUT(ROUND(q1_&colname.,.1), 10.2)) || " - " || COMPRESS(PUT(ROUND(q3_&colname.,.1), 10.2));
					%end;
					%else %if &onecol. EQ FALSE AND &row_cost. EQ TRUE %then %do;
						&colname._1 = "$"||COMPRESS(PUT(ROUND(median_&colname.,.11), 10.2));
						&colname._2 = COMPRESS("$"||PUT(ROUND(q1_&colname.,.11), 10.2)) || " - " || COMPRESS("$"||PUT(q3_&colname., 10.2));
					%end;
					%else %if &onecol. EQ TRUE AND &row_cost. EQ TRUE %then %do;
						&colname._1 = COMPRESS("$"||PUT(median_&colname., 10.2))||" ($"||COMPRESS(PUT(q1_&colname., 10.2))||" - $"||COMPRESS(PUT(q3_&colname., 10.2))||")";
					%end;
					%else %if &onecol. EQ TRUE AND &row_cost. EQ FALSE %then %do;
						&colname._1 = COMPRESS(PUT(median_&colname., 10.2))||" ("||COMPRESS(PUT(ROUND(q1_&colname.,.1), 10.2))||" - "||COMPRESS(PUT(ROUND(q3_&colname.,.1), 10.2))||")";
					%end;
				%end;
				%if &pvals. EQ TRUE %then %do pn=1 %to %sysfunc(COUNTW(&pval_comparators., *));
					p&pn._test="&&median_ptest&pn.";
					p&pn._val="&&median_pval&pn.";
					%if &&median_df&pn. NE %then %do; p&pn._df=&&median_df&pn.; %end;
					%if &row_smds. EQ TRUE %then %do; smd&pn.=.; %end;
					IF p&pn._test NE "NA" AND INPUT(p&pn._val, 10.4)<.0001 THEN p&pn._val='<.0001';
				%end;
				OUTPUT;
			%end;
			%if &row_minmax. EQ TRUE %then %do;
				value="Min (Max)";
				%do sn=1 %to %eval(&n_strats.+1); 
					%let colname=%scan(col0*&strat_names., &sn., *);
					%if &onecol. EQ FALSE AND &row_cost. EQ FALSE %then %do;
						&colname._1 = COMPRESS(PUT(Min_&colname., 10.2));
						&colname._2 = COMPRESS(PUT(Max_&colname., 10.2));
					%end;
					%else %if &onecol. EQ FALSE AND &row_cost. EQ TRUE %then %do;
						&colname._1 = "$"||COMPRESS(PUT(Min_&colname., 10.2));
						&colname._2 = "$"||COMPRESS(PUT(Max_&colname., 10.2));
					%end;
					%else %if &onecol. EQ TRUE AND &row_cost. EQ TRUE %then %do;
						&colname._1 = COMPRESS("$"||PUT(Min_&colname.,10.2))||" ($"||COMPRESS(PUT(Max_&colname., 10.2))||")";
					%end;
					%else %if &onecol. EQ TRUE AND &row_cost. EQ FALSE %then %do;
						&colname._1 = COMPRESS(PUT(Min_&colname, 10.2))||" ("||COMPRESS(PUT(Max_&colname., 10.2))||")";
					%end;
				%end;
				%if &pvals. EQ TRUE %then %do pn=1 %to %sysfunc(COUNTW(&pval_comparators., *));
					p&pn._test="";
					p&pn._val="";
					%if &&mean_df&pn. NE OR &&median_df&pn. NE %then %do; p&pn._df=.; %end;
				%end;
				OUTPUT;
			%end;
		RUN;
	%end;
		
	PROC DATASETS LIB=work NOLIST;
		DELETE &var._setup: stats_output:;
	RUN; QUIT;
		
	%if &row_header. EQ TRUE %then %do;
		DATA row&rn.;
			SET header_row (IN=a) row&rn.;
			IF A THEN DO;
				var="&var.";
				value="&hlabel.";
			END;
/*			rownum=&rn.;*/
		RUN;
	%end;

	DATA &output_dset.; SET &output_dset. row&rn.;
	%do sn=1 %to &n_strats.; %if %scan(&strat_names., &sn., *)_1='. (.%)' %then %scan(&strat_names., &sn., *)_1='-'; %end;
/* 	ROWNUM=_n_; */
	RUN;

%mend table1_row;

%macro table1_smd; 

	/* Continuous */
	%if &row_type. EQ N %then %do;
		PROC MEANS DATA = &source_dset. NOPRINT;
			WHERE &strat_var. IN &samples.;
			CLASS &strat_var.;
			VAR &var.;
			%if &weight_var. NE %then WEIGHT &weight_var.;;
			OUTPUT OUT=temp_1 (WHERE=(_TYPE_ EQ 1)) MEAN=_mean_ STD=_std_;
		RUN;
	
		PROC SQL NOPRINT;
			SELECT (MAX(_mean_) - MIN(_mean_))/SQRT((MAX(_std_)**2 + MIN(_std_)**2)/2) INTO :smd&pn.
			FROM temp_1;
		QUIT;
	
		PROC DATASETS LIB=work NODETAILS NOLIST;
			DELETE temp_1;
		QUIT;
	%end;
	%else %if &row_type. EQ C AND &uniq_values. EQ 2 %then %do;
	
		DATA temp_1;
			SET &source_dset. (KEEP = &strat_var. &var. &weight_var.);
			WHERE &strat_var. IN &samples.;
		RUN;
		
		PROC SQL;
			CREATE TABLE temp_2 as
			SELECT DISTINCT &var. as &var.
			FROM temp_1
			WHERE &var. is not missing;
		QUIT;
		
		PROC SQL;
			CREATE TABLE temp_3 AS
			SELECT a.*, b.&strat_var.
			FROM temp_2 AS a, (SELECT DISTINCT &strat_var. FROM temp_1) AS b;
		QUIT;
		
		ODS SELECT NONE;
		ODS OUTPUT CrossTabFreqs = temp_4;
		PROC FREQ DATA = temp_1 ;
			TABLE &var. * &strat_var.;
			%if &weight_var. NE %then WEIGHT &weight_var.;;
		RUN;
		ODS SELECT ALL;
		
		proc sql;
			CREATE TABLE  temp_5 as
			SELECT a.*, b.ColPercent
			FROM temp_3 as a
			LEFT JOIN temp_4 as b ON a.&strat_var. = b.&strat_var. AND a.&var. = b.&var.;
		QUIT;
		
		DATA temp_6;
			SET temp_5;
			IF ColPercent = . THEN ColPercent = 0;
		RUN;
		
		PROC SORT DATA = temp_6 OUT = catfreq;
			BY &strat_var. &var.;
		RUN;
		
		DATA temp_7;
			SET catfreq;
			BY &strat_var.;
			IF first.&strat_var.;
			ColPercent = ColPercent/100;
		RUN;
		
		PROC SQL NOPRINT;
			SELECT (MAX(ColPercent) - MIN(ColPercent))/(SQRT((MAX(ColPercent)*(1-MAX(ColPercent)) + MIN(ColPercent)*(1-MIN(ColPercent)))/2)) INTO :smd&pn.
			FROM temp_7;
		QUIT;
		
		PROC DATASETS LIB = work NODETAILS NOLIST;
			DELETE  temp_1 - temp_8;
		RUN; QUIT;
	%end;
	%else %if &row_type. EQ C AND &uniq_values. GT 2 %then %do;
	
		DATA temp_1;
			SET &source_dset. (KEEP = &strat_var. &var. &weight_var.);
			WHERE &strat_var. IN &samples.;
		RUN;
		
		PROC SQL;
			CREATE TABLE temp_2 as
			SELECT DISTINCT &var. as &var.
			FROM temp_1
			WHERE &var. is not missing;
		QUIT;
		
		PROC SQL;
			CREATE TABLE temp_3 AS
			SELECT a.*, b.&strat_var.
			FROM temp_2 AS a, (SELECT DISTINCT &strat_var. FROM temp_1) AS b;
		QUIT;
		
		ODS SELECT NONE;
		ODS OUTPUT CrossTabFreqs = temp_4;
		PROC FREQ DATA = temp_1 ;
			TABLE &var. * &strat_var.;
			%if &weight_var. NE %then WEIGHT &weight_var.;;
		RUN;
		ODS SELECT ALL;
		
		proc sql;
			CREATE TABLE  temp_5 as
			SELECT a.*, b.ColPercent
			FROM temp_3 as a
			LEFT JOIN temp_4 as b ON a.&strat_var. = b.&strat_var. AND a.&var. = b.&var.;
		QUIT;
		
		DATA temp_6;
			SET temp_5;
			IF ColPercent = . THEN ColPercent = 0;
		RUN;
		
		PROC SORT DATA = temp_6 OUT = catfreq;
			BY &strat_var. &var.;
		RUN;
	
	   		%let _k_ = %eval(&uniq_values. - 1); 
   			%let _k_ = %sysfunc(strip(&_k_.)); 
  			data temp_7; 
   				set catfreq; 
  				by &strat_var.; 
   				if last.&strat_var. then delete; 
   				ColPercent = ColPercent/100; 
  			run; 
/*   			proc print data=temp_7; run; */

  			proc sql noprint; 
   				select ColPercent into :tlist separated by ' '  
				from temp_7 AS a
				INNER JOIN (SELECT &strat_var. FROM temp_7 (OBS=1)) AS b ON a.&strat_var.=b.&strat_var.
				ORDER BY &var.; 

   				select ColPercent into :clist separated by ' '  
				from temp_7 AS a
				LEFT JOIN (SELECT &strat_var. FROM temp_7 (OBS=1)) AS b ON a.&strat_var.=b.&strat_var.
				WHERE MISSING(b.&strat_var.)
				ORDER BY &var.; 
  			quit; 
  			

/* vector T, C and T-C */
  			data t_1; 
   				array t{*}  t1- t&_k_.   (&tlist.); 
   				array c{*}  c1- c&_k_.   (&clist.); 
   				array tc{*} tc1 - tc&_k_. ; 
   				do i = 1 to dim(t); 
    				tc{i} = t{i} - c{i}; 
   				end; 
   			drop i; 
  			run; 

/* each column has one element of a S covariance matrix (k x k) */

			%let _dm = ; 
			%let _dm = %eval(&_k_.*&_k_.); 
  			data covdata; 
   				array t{*}  t1- t&_k_.  (&tlist.); 
   				array c{*}  c1- c&_k_.   (&clist.); 
   				array cv{&_k_.,&_k_.} x1 -x&_dm.; 
   				do i = 1 to &_k_.; 
    				do j = 1 to &_k_.; 
     					if i = j then do; 
      						cv{i,j} = 0.5*(t{i}*(1-t{i}) + c{i}*(1-c{i})); 
      						end; 
     					else do; 
      						cv{i,j} = -0.5 * (t[i] * t[j] + c[i] * c[j]); 
      						end; 
    					if cv{&_k_.,&_k_.] ne . then output; 
    				end; 
  				end; 
  			run; 

  			proc transpose data = covdata(keep = x1 -x&_dm.) out = covdata_1; 
  			run; 

  			data covdata_2; 
   				set covdata_1; 
   				retain id gp 1; 
   				if mod(_n_ - 1,&_k_.) = 0 then gp = gp + 1; 
  			run; 

		  	proc sort data = covdata_2 ; 
		   		by gp id; 
		  	run;   

			data covdata_3; 
		   		set covdata_2; 
		   		by gp id; 
		   		retain lp; 
		   		if first.gp then lp = 0; 
		   		lp = lp+1; 
		  	run; 

/* transpose to a S variance-covariance matrix format */
           
		  	data covdata_4; 
		   		set covdata_3; 
		   		retain y1-y&_k_.; 
		   		array cy{1:&_k_.} y1-y&_k_.; 
		   		by gp id; 
		   		if first.gp then do; 
		    		do k = 1 to &_k_.; 
		     			cy{k} = .; 
				    end; 
		   		end; 
		   		cy{lp} = col1; 
		   		if last.gp then output; 
		   		keep y:; 
		  	run; 

/* get inverse of S matrix */
		  data A_1; 
		   set covdata_4; 
		   array _I{*} I1-I&_k_.; 
		   do j=1 to &_k_.; 
		    if j=_n_ then _I[j]=1;  
		    else _I[j]=0; 
		   end; 
		   drop j; 
		  run; 

/* solve the inverse of the matrix */

  %macro inv; 
    	%do j=1 %to &_k_.; 
    		proc orthoreg data=A_1 outest=A_inv_&j.(keep=y1-y&_k_.) 
     			noprint singular=1E-16; 
     			model I&j=y1-y&_k_. /noint; 
    		run; 
    		quit; 
    	%end; 

   		data A_inverse; 
    		set %do j=1 %to &_k_.; 
     		A_inv_&j 
     	%end;; 
   		run; 
  %mend; 
  %inv; 

  		proc transpose data=A_inverse out=A_inverse_t; 
  		run; 

   /* calculate the mahalanobis distance */
  		data t_2; 
   			set A_inverse_t; 
   			array t{*}  t1- t&_k_.  (&tlist.); 
   			array c{*}  c1- c&_k_.  (&clist.); 
   			i = _n_; 
   			trt = t{i}; 
   			ctl = c{i}; 
   			tc = t{i} - c{i}; 
  		run; 
 
		data t_3; 
   			set t_2; 
   			array aa{&_k_.} col1 - col&_k_.; 
   			array bb{&_k_.} bb1- bb&_k_.; 
   			do i = 1 to &_k_.; 
    			bb{i} = aa{i}*tc; 
   			end; 
  		run; 

  		proc summary data = t_3 noprint; 
   			var bb1-bb&_k_.; 
   			output out = t_4 sum =; 
  		run; 

  		data t_5; 
   			merge t_1 t_4; 
   			array d1{*} tc1- tc&_k_. ; 
   			array d2{*} bb1-bb&_k_.; 
   			array d3{*} y1-y&_k_.; 
   			do i = 1 to &_k_.; 
   				d3{i} = d1{i}*d2{i}; 
   			end; 
   			d = sqrt(sum(of y1-y&_k_.)); 
   			stddiff = d;      
   			keep stddiff; 
  		run; 

  		proc sql noprint; 
   			select stddiff into: smd&pn. from t_5; 
  		quit; 
   
  		proc datasets lib = work nodetails nolist; 
   			delete temp: covdata covdata_1 covdata_2 covdata_3 covdata_4 
      		A_1 A_inverse A_inverse_t t_1 t_2 t_3 t_4 t_5
     		A_inv_:; 
  		quit; 
	
	
	%end;

%mend table1_smd; 				


