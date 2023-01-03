libname assign '/mnt/share/sas/';
options mstored sasmstore=assign notes;
options sastrace=',,,ds' sastraceloc=saslog nostsuffix sql_ip_trace=source;
libname heor odbc dsn="rwe" schema="dingyig" USER="dingyig" PASSWORD="NewJersey123!";
libname derived "/home/dingyig/proj/NOV-27";
libname source odbc dsn="rwe" schema="src_optum_claims_panther" USER="dingyig" PASSWORD="NewJersey123!";

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
		CONNECT TO ODBC AS imp (USER="dingyig" PASSWORD="Hoboken2021" DATASRC='rwe');
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
	CONNECT TO ODBC AS rwd_p (USER="dingyig" PASSWORD="Hoboken2021" DATASRC='rwe');
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
/*************************************************************************************************************************************************/
/*                                                                                                                                               */
/* Macro: table1                                                                                                                                 */
/* Function: Create demographics-style output table.                                                                                             */
/* Inputs: cohort -> Dataset with all necessary variables and formatted appropriately                                                            */
/*         output_dset -> Name of output dataset. Library optional.                                                                              */
/*         cont_stats -> List all desired statistics for continuous variables separated by asterisk.                                             */
/*         autofill -> Set equal to 1 to enable. Automatically fills out the header names for some variables.  Current list includes:            */
/*                     sex, region, plantyp.                                                                                                     */
/*         headspace -> Set equal to 1 to enable. This option will leave a blank row between each variable.                                      */
/*         vars -> Names of all variables to output separated by an asterisk. Numeric values will be treated as continuous.                      */
/*         combine_cols -> Set equal to 1 to enable. Creates 1 column per stratification (instead of 2)                                          */
/*         pvalues -> Output p-values for each variable.                                                                                         */
/*         strat_whr1-5 -> Will stratify all outputs by this where statement. Leave blank to ignore. Up to 5 currently allowed.                  */
/*                                                                                                                                               */
/*************************************************************************************************************************************************/

%macro table1(cohort=, output_dset=, cont_stats=MEAN*MEDIAN, autofill=, headspace=, vars=, hide_headspace=, hide_missing=, combine_cols=, pvalues=,
	strat_whr0=1, strat_whr1=, strat_whr2=, strat_whr3=, strat_whr4=, strat_whr5=, strat_whr6=, strat_whr7=, strat_whr8=, strat_whr9=, strat_whr10=);
	
	PROC CONTENTS DATA=&cohort. OUT=contents (KEEP=name type) NOPRINT; RUN;

	%let vars=%sysfunc(COMPRESS(&vars.));
	%let n_vars=%eval(%sysfunc(LENGTH(%sysfunc(TRANWRD(&vars., *, **))))-%sysfunc(LENGTH(&vars.))+1);

	%if %length(&hide_headspace.) NE 0 %then %do;
		%let hide_headspace=%sysfunc(COMPRESS(&hide_headspace.));
		%let n_hide_headspace=%eval(%sysfunc(LENGTH(%sysfunc(TRANWRD(&hide_headspace., *, **))))-%sysfunc(LENGTH(&hide_headspace.))+1);	
	%end;
	%else %let n_hide_headspace=0;

	%if %length(&hide_missing.) NE 0 %then %do;
		%let hide_missing=%sysfunc(COMPRESS(&hide_missing.));
		%let n_hide_missing=%eval(%sysfunc(LENGTH(%sysfunc(TRANWRD(&hide_missing., *, **))))-%sysfunc(LENGTH(&hide_missing.))+1);	
	%end;
	%else %let n_hide_missing=0;

	%let n_stats=%eval(%sysfunc(LENGTH(%sysfunc(TRANWRD(&cont_stats., *, **))))-%sysfunc(LENGTH(&cont_stats.))+1);
	%let stats2 = %sysfunc(TRANWRD(%bquote(&cont_stats.), %str(%(), *));
	%let stats3 = %sysfunc(TRANWRD(%bquote(&stats2.), -, *));
	%let stats4 = %sysfunc(COMPRESS(%bquote(&stats3.), ') '));
	%let n_stats4=%eval(%sysfunc(LENGTH(%sysfunc(TRANWRD(&stats4., *, **))))-%sysfunc(LENGTH(&stats4.))+1);

	%do type=1 %to 2;
		%let name=%scan(num*char, &type., *);
		%let &name._vars=;
		PROC SQL NOPRINT;
			SELECT name INTO: &name._vars SEPARATED BY "*" FROM contents
			WHERE type=&type. AND (
				%do i=1 %to &n_vars.;
					%if &i. NE 1 %then %do; OR %end;
					UPCASE(name) EQ UPCASE("%scan(&vars., &i., *)")
				%end;
				);
			SELECT COUNT(name) INTO: n_&name._vars FROM contents
			WHERE type=&type. AND (
				%do i=1 %to &n_vars.;
					%if &i. NE 1 %then %do; OR %end;
					UPCASE(name) EQ UPCASE("%scan(&vars., &i., *)")
				%end;
				);
		QUIT;
	%end;

	%let n_strats=0;
	%do i=1 %to 10;
		%if %length(&&strat_whr&i.) %then %let n_strats=&i.;
	%end;

	%if &n_char_vars. GT 0 %then %do i=1 %to &n_char_vars.;
		%let var=%scan(&char_vars., &i., *);
		PROC SQL;
			CREATE TABLE &var._setup2 AS
			SELECT DISTINCT &var. as col1
			FROM &cohort.
			ORDER BY col1;
		QUIT;
	%end;

	%do strat=0 %to &n_strats.;

		DATA cohort_mod;
			SET &cohort.;
			WHERE &&strat_whr&strat.;
		RUN;

		PROC SQL NOPRINT;
			SELECT COUNT(*) INTO: denom FROM cohort_mod;
		QUIT; 

		PROC SQL;
			CREATE TABLE total AS
			%if &combine_cols. EQ 1 %then %do;
				SELECT "Total" as col1, PUT(COUNT(*), 8.) AS col2, COMPRESS(PUT(COUNT(*), 8.)) || " (" || COMPRESS(PUT(COUNT(*)/&denom.*100, 8.1)) || "%)" AS col3 FROM cohort_mod;
			%end;
			%else %do;
				SELECT "Total" as col1, PUT(COUNT(*), 8.) AS col2, PUT(COUNT(*)/&denom., 8.4) AS col3 FROM cohort_mod;
			%end;
		QUIT; 
		PROC MEANS DATA=cohort_mod NOPRINT;
			VAR %sysfunc(TRANWRD(&num_vars., *, ));
			OUTPUT OUT=stats
				%do i=1 %to &n_stats4.;
					%scan(&stats4., &i., *) = 
				%end;
				/ AUTONAME;
		RUN;

		%if &n_num_vars. GT 0 %then %do i=1 %to &n_num_vars.;
			%let var=%scan(&num_vars., &i., *);
			PROC SQL;
				CREATE TABLE &var._setup AS
				%do j=1 %to &n_stats.;
					%let stat=%scan(&cont_stats., &j., *);
					%if &combine_cols. EQ 1 %then %do;
						%let substat2 = %sysfunc(TRANWRD(%bquote(%sysfunc(COMPRESS(&stat.))), %str(%)), %str(, 8.2%)%) || ")")));
						%let substat3 = %sysfunc(TRANWRD(%superq(substat2), %str(%(), %str(, 8.2%)%) || " (" || COMPRESS%(PUT%(&var._)));
					%end;
					%else %do;
						%let substat2 = %sysfunc(TRANWRD(%bquote(%sysfunc(COMPRESS(&stat.))), %str(%)), %str(, 8.2%)%))));
						%let substat3 = %sysfunc(TRANWRD(%superq(substat2), %str(%(), %str(, 8.2%)%) as col2, COMPRESS%(PUT%(&var._)));
					%end;
					%let substat4 = %sysfunc(TRANWRD(%superq(substat3), %str(-), %str(, 8.2%)%) || " - " || COMPRESS%(PUT%(&var._)));
					%if "%substr(&stat.,%sysfunc(LENGTH(&stat.)),1)" EQ ")" %then %do;
						%let substat5 = %str(COMPRESS%(PUT%(&var._&substat4.) as col3;
					%end;
					%else %do;
						%let substat5 = %str(COMPRESS%(PUT%(&var._&substat4., 8.2%)%)) as col3;
					%end;
					
					%if &j. NE 1 %then %do; UNION ALL %end;
					SELECT "&stat." as col1, &substat5. FROM stats
				%end;
				;
			QUIT;
		%end;
				
		PROC FREQ DATA=cohort_mod NOPRINT;
			%if &n_char_vars. GT 0 %then %do i=1 %to &n_char_vars.;
				%let var=%scan(&char_vars., &i., *);
				TABLES &var. / OUT=&var._setup1 (KEEP=&var. count RENAME=(&var.=col1 count=col2));
			%end;
		RUN;

		%if &n_char_vars. GT 0 %then %do i=1 %to &n_char_vars.;
			%let var=%scan(&char_vars., &i., *);
			DATA &var._setup (DROP=col2 RENAME=col4=col2);
				MERGE &var._setup1 (IN=A) &var._setup2;
				BY col1;
				IF NOT A THEN col2=0;
				FORMAT col3 col4 $50.;
				%if &combine_cols. EQ 1 %then %do;
					col3 = COMPRESS(PUT(col2, 8.)) || " (" || COMPRESS(PUT(col2/&denom.*100, 8.1)) || "%)";
				%end;
				%else %do;
					col3 = PUT(col2/&denom., 8.4);
				%end;
				col4 = PUT(col2, 8.);
			RUN;
		%end;

		%if &headspace. EQ 1 %then %do;
			DATA blank; col1=""; RUN;
		%end;

		DATA output_&strat. 
			%if &combine_cols. EQ 1 %then %do; (KEEP=col0 col1 col3 RENAME=col3=strat&strat.) %end;
			%else %do; (KEEP=col0-col3 RENAME=(col2=strat&strat._n col3=strat&strat._pct)) %end;
			;
			FORMAT col0-col3 $50.;
			SET total
				%do i=1 %to &n_vars.;
					%let var=%scan(&vars., &i., *);
					%if &headspace. EQ 1 %then %do; blank (IN=&var.) %end;
					&var._setup (IN=&var. WHERE=(NOT MISSING(col1)))
					&var._setup (IN=&var. WHERE=(MISSING(col1)))
				%end;
				;
			%do i=1 %to &n_vars.;
				%let var=%scan(&vars., &i., *);
				%if &i. NE 1 %then %do; ELSE %end;
				IF &var. THEN col0="&var.";
			%end;
			IF MISSING(col1) AND NOT MISSING(col2) THEN col1="Missing";
			%if &autofill. EQ 1 %then %do;
				IF col0 IN ("sex","gender") THEN DO;
					IF col1 IN ('1','M') THEN col1="Male";
					ELSE IF col1 IN ('2','F') THEN col1="Female";
				END;
				ELSE IF col0="region" THEN DO;
					IF col1='1' THEN col1="Northeast";
					ELSE IF col1='2' THEN col1="North Central";
					ELSE IF col1='3' THEN col1="South";
					ELSE IF col1='4' THEN col1="West";
					ELSE IF col1='5' THEN col1="Unknown";
				END;
				ELSE IF col0="plantyp" THEN DO;
					IF col1='1' THEN col1="Basic/major medical";
					ELSE IF col1='2' THEN col1="Comprehensive";
					ELSE IF col1='3' THEN col1="EPO";
					ELSE IF col1='4' THEN col1="HMO"; 
					ELSE IF col1='5' THEN col1="POS"; 
					ELSE IF col1='6' THEN col1="PPO"; 
					ELSE IF col1='7' THEN col1="POS with capitation";
					ELSE IF col1='8' THEN col1="CDHP";
					ELSE IF col1='9' THEN col1="HDHP";
				END;
			%end;
		RUN;
	%end;

	DATA &output_dset.;
		MERGE output_0-output_&n_strats.;
		%if &n_hide_headspace. GT 0 %then %do i=1 %to &n_hide_headspace.;
			%if &i. NE 1 %then %do; ELSE %end;
			IF col0="%scan(&hide_headspace., &i., *)" AND MISSING(col1) THEN DELETE;
		%end;
		%if &n_hide_missing. GT 0 %then %do i=1 %to &n_hide_missing.;
			%if &i. NE 1 %then %do; ELSE %end;
			IF col0="%scan(&hide_missing., &i., *)" AND col1="Missing" THEN DELETE;
		%end;
	RUN;

	%if &pvalues. EQ 1 AND &n_strats. GE 2 %then %do;
		ODS GRAPHICS OFF;
		ODS SELECT NONE;

		DATA pval_setup;
			SET 
			%do i=1 %to &n_strats.;
				&cohort. (IN=in&i. WHERE=(&&strat_whr&i.))
			%end;
			;
			%do i=1 %to &n_strats.;
				%if &i. NE 1 %then %do; ELSE %end;
				IF in&i. THEN strat="&i.";
			%end;
			%if &n_char_vars. GT 0 %then %do j=1 %to &n_char_vars.;
				%let var=%scan(&char_vars., &j., *);
				IF MISSING(&var.) THEN &var.=".";
			%end;
		RUN;
		
		%if &n_num_vars. GT 0 %then %do j=1 %to &n_num_vars.;
			%let var=%scan(&num_vars., &j., *);
			%if &n_strats. EQ 2 %then %do;
				ODS OUTPUT EQUALITY=variance_test TTESTS=tests; 
				PROC TTEST DATA=pval_setup;
					VAR &var.; 
					CLASS strat;
				RUN; 

				PROC SQL NOPRINT;
					SELECT CASE WHEN ProbF < 0.05 THEN 'Unequal' ELSE 'Equal' END INTO: var_type FROM variance_test;
					SELECT probt INTO: pval1_&var. FROM tests WHERE Variances = "&var_type.";
				QUIT; 
							
				PROC NPAR1WAY DATA=pval_setup WILCOXON;
					VAR &var.; 
					CLASS strat;
					OUTPUT OUT=tests; 
				RUN; 

				PROC SQL NOPRINT;
					SELECT p2_wil INTO: pval3_&var. FROM tests;
				QUIT; 
			%end;
			%else %do;
				%let pval1_&var.=.;
				%let pval3_&var.=.;
			%end;

			PROC ANOVA DATA=pval_setup OUTSTAT=tests;
				CLASS strat;
				MODEL &var. = strat; 
			RUN; 
			QUIT; 

			PROC SQL NOPRINT;
				SELECT prob INTO: pval2_&var. FROM tests WHERE _TYPE_ = "ANOVA";
			QUIT; 
		%end;

		%if &n_char_vars. GT 0 %then %do j=1 %to &n_char_vars.;
			%let var=%scan(&char_vars., &j., *);

			PROC SQL NOPRINT;
				SELECT COUNT(distinct &var.) INTO: cols FROM pval_setup;
			QUIT; 
			 
			PROC FREQ DATA=pval_setup;
				TABLES strat*&var. / LIST CHISQ FISHER %if &n_strats. EQ 2 AND &cols. EQ 2 %then %do; AGREE %end; WARN=OUTPUT;
				EXACT TREND / MAXTIME=5; 
				OUTPUT CHISQ %if &n_strats. EQ 2 AND &cols. EQ 2 %then %do; MCNEM %end; OUT=tests; 
			RUN; 

			PROC SQL NOPRINT;
				SELECT warn_pchi INTO: fisher FROM tests;
				%if &fisher. EQ 0 %then %do;
					SELECT p_pchi INTO: pval1_&var. FROM tests;
				%end;
				%else %do;
					SELECT xp2_fish INTO: pval1_&var. FROM tests;
				%end;
			QUIT;
		%end;

		ODS SELECT ALL;

		DATA &output_dset.;
			SET &output_dset.;
			BY col0 NOTSORTED;
			IF first.col0 THEN DO;
				%if &n_char_vars. GT 0 %then %do j=1 %to &n_char_vars.;
					%let var=%scan(&char_vars., &j., *);
					%if &j. NE 1 %then %do; ELSE %end;
					IF UPCASE(col0)=UPCASE("&var.") THEN p_chisq=&&pval1_&var.;
				%end;
				%if &n_num_vars. GT 0 %then %do j=1 %to &n_num_vars.;
					%let var=%scan(&num_vars., &j., *);
					%if &j. NE 1 %then %do; ELSE %end;
					IF UPCASE(col0)=UPCASE("&var.") THEN DO;
						p_ttest=&&pval1_&var.;
						p_anova=&&pval2_&var.;
						p_wilcoxon=&&pval3_&var.;
					END;
				%end;
			END;
		RUN;
	%end;

%mend table1;
