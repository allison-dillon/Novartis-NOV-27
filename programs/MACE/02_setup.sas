/*attrition*/

* set up all code and procedure;
%all_codes; 

%ms_firstcut(implib= heoji3, 
		   	 output= mace_02_ascvd, 
		     databases= %str(ccae_mdcr), 
			 date_start=, 
			 date_end=, 
			 dx_codes= %str('410','4100','41000','41001','41002','4101','41010','41011','41012','4102','41020','41021','41022','4103'
							,'41030','41031','41032','4104','41040','41041','41042','4105','41050','41051','41052','4106','41060','41061'
							,'41062','4107','41070','41071','41072','4108','41080','41081','41082','4109','41090','41091','41092','412'
							,'I21','I210','I2101','I2102','I2109','I211','I2111','I2119','I212','I2121','I2129','I213','I214','I219','I21A'
							,'I21A1','I21A9','I22','I220','I221','I222','I228','I229','I252'
							
							,'4111','413','4130','4133','4139','I20','I200','I201','I208','I209','I2511','I25110','I25111','I25118','I25119','I257','I2570'
							,'I25700','I25701','I25708','I25709','I2571','I25710','I25711','I25718','I25719','I2572','I25720','I25721','I25728','I25729'
							,'I2573','I25730','I25731','I25738','I25739','I2575','I25750','I25751','I25758','I25759','I2576','I25760','I25761','I25768'
							,'I25769','I2579','I25790','I25791','I25798','I25799'
							
							,'4140','I251'
							
							,'43301','43311','43321','43331','43381','43391','43401','43411','43491','I63','I630','I6300','I6301','I63011'
							,'I63012','I63013','I63019','I6302','I6303','I63031','I63032','I63033','I63039','I6309','I631','I6310','I6311','I63111'
							,'I63112','I63113','I63119','I6312','I6313','I63131','I63132','I63133','I63139','I6319','I632','I6320','I6321','I63211'
							,'I63212','I63213','I63219','I6322','I6323','I63231','I63232','I63233','I63239','I6329','I633','I6330','I6331','I63311'
							,'I63312','I63313','I63319','I6332','I63321','I63322','I63323','I63329','I6333','I63331','I63332','I63333','I63339','I6334'
							,'I63341','I63342','I63343','I63349','I6339','I634','I6340','I6341','I63411','I63412','I63413','I63419','I6342','I63421'
							,'I63422','I63423','I63429','I6343','I63431','I63432','I63433','I63439','I6344','I63441','I63442','I63443','I63449','I6349'
							,'I635','I6350','I6351','I63511','I63512','I63513','I63519','I6352','I63521','I63522','I63523','I63529','I6353','I63531'
							,'I63532','I63533','I63539','I6354','I63541','I63542','I63543','I63549','I6359','I636','I638','I6381','I6389','I639'
							
							,'435','4350','4351','4352','4353','4358','4359','G450','G451','G452','G453','G458','G459','H340'
							
							,'4400','4402','44020','44021','44022','44023','44024','44029','4403','44030','44031','44032','4404','4408','4409'
							,'4450','I700','I701','I70201','I70202','I70203','I70208','I70209','I70211','I70212','I70213','I70218','I70219','I70221'
							,'I70222','I70223','I70228','I70229','I70231','I70232','I70233','I70234','I70235','I70238','I70239','I70241','I70242'
							,'I70243','I70244','I70245','I70248','I70249','I7025','I70261','I70262','I70263','I70268','I70269','I70291','I70292'
							,'I70293','I70298','I70299','I70301','I70302','I70303','I70308','I70309','I70311','I70312','I70313','I70318','I70319'
							,'I70321','I70322','I70323','I70328','I70329','I70331','I70332','I70333','I70334','I70335','I70338','I70339','I70341'
							,'I70342','I70343','I70344','I70345','I70348','I70349','I7035','I70361','I70362','I70363','I70368','I70369','I70391'
							,'I70392','I70393','I70398','I70399','I70401','I70402','I70403','I70408','I70409','I70411','I70412','I70413','I70418'
							,'I70419','I70421','I70422','I70423','I70428','I70429','I70431','I70432','I70433','I70434','I70435','I70438','I70439'
							,'I70441','I70442','I70443','I70444','I70445','I70448','I70449','I7045','I70461','I70462','I70463','I70468','I70469'
							,'I70491','I70492','I70493','I70498','I70499','I70501','I70502','I70503','I70508','I70509','I70511','I70512','I70513'
							,'I70518','I70519','I70521','I70522','I70523','I70528','I70529','I70531','I70532','I70533','I70534','I70535','I70538'
							,'I70539','I70541','I70542','I70543','I70544','I70545','I70548','I70549','I7055','I70561','I70562','I70563','I70568'
							,'I70569','I70591','I70592','I70593','I70598','I70599','I70601','I70602','I70603','I70608','I70609','I70611','I70612'
							,'I70613','I70618','I70619','I70621','I70622','I70623','I70628','I70629','I70631','I70632','I70633','I70634','I70635'
							,'I70638','I70639','I70641','I70642','I70643','I70644','I70645','I70648','I70649','I7065','I70661','I70662','I70663'
							,'I70668','I70669','I70691','I70692','I70693','I70698','I70699','I70701','I70702','I70703','I70708','I70709','I70711'
							,'I70712','I70713','I70718','I70719','I70721','I70722','I70723','I70728','I70729','I70731','I70732','I70733','I70734'
							,'I70735','I70738','I70739','I70741','I70742','I70743','I70744','I70745','I70748','I70749','I7075','I70761','I70762'
							,'I70763','I70768','I70769','I70791','I70792','I70793','I70798','I70799','I708','I7090','I7091','I7092'
							
							,'44021','4439','I7021','I70211','I70212','I70213','I70218','I70219','I7031','I70311','I70312','I70313','I70318','I70319','I7041'
							,'I70411','I70412','I70413','I70418','I70419','I70499','I7051','I70511','I70512','I70513','I70518','I70519','I70599','I7061','I70611'
							,'I70612','I70613','I70618','I70619','I7071','I70711','I70712','I70713','I70718','I70719','I1739'

							,'4331','I652'		
							
							,'45989','4599','I879','I999','I998'		
							
							,'4439','I739'
							
							,'4400','I700'
							),  
			 pc_codes= %str('0210083','0210088','0210089','021008C','021008F','021008W','0210093','0210098','0210099','021009C','021009F','021009W','02100A3','02100A8','02100A9','02100AC','02100AF','02100AW','02100J3','02100J8'
						,'02100J9','02100JC','02100JF','02100JW','02100K3','02100K8','02100K9','02100KC','02100KF','02100KW','02100Z3','02100Z8','02100Z9','02100ZC','02100ZF','0210483','0210488','0210489','021048C','021048F'
						,'021048W','0210493','0210498','0210499','021049C','021049F','021049W','02104A3','02104A8','02104A9','02104AC','02104AF','02104AW','02104J3','02104J8','02104J9','02104JC','02104JF','02104JW','02104K3'
						,'02104K8','02104K9','02104KC','02104KF','02104KW','02104Z3','02104Z8','02104Z9','02104ZC','02104ZF','0211083','0211088','0211089','021108C','021108F','021108W','0211093','0211098','0211099','021109C'
						,'021109F','021109W','02110A3','02110A8','02110A9','02110AC','02110AF','02110AW','02110J3','02110J8','02110J9','02110JC','02110JF','02110JW','02110K3','02110K8','02110K9','02110KC','02110KF','02110KW'
						,'02110Z3','02110Z8','02110Z9','02110ZC','02110ZF','0211483','0211488','0211489','021148C','021148F','021148W','0211493','0211498','0211499','021149C','021149F','021149W','02114A3','02114A8','02114A9'
						,'02114AC','02114AF','02114AW','02114J3','02114J8','02114J9','02114JC','02114JF','02114JW','02114K3','02114K8','02114K9','02114KC','02114KF','02114KW','02114Z3','02114Z8','02114Z9','02114ZC','02114ZF'
						,'0212083','0212088','0212089','021208C','021208F','021208W','0212093','0212098','0212099','021209C','021209F','021209W','02120A3','02120A8','02120A9','02120AC','02120AF','02120AW','02120J3','02120J8'
						,'02120J9','02120JC','02120JF','02120JW','02120K3','02120K8','02120K9','02120KC','02120KF','02120KW','02120Z3','02120Z8','02120Z9','02120ZC','02120ZF','0212483','0212488','0212489','021248C','021248F'
						,'021248W','0212493','0212498','0212499','021249C','021249F','021249W','02124A3','02124A8','02124A9','02124AC','02124AF','02124AW','02124J3','02124J8','02124J9','02124JC','02124JF','02124JW','02124K3'
						,'02124K8','02124K9','02124KC','02124KF','02124KW','02124Z3','02124Z8','02124Z9','02124ZC','02124ZF','0213083','0213088','0213089','021308C','021308F','021308W','0213093','0213098','0213099','021309C'
						,'021309F','021309W','02130A3','02130A8','02130A9','02130AC','02130AF','02130AW','02130J3','02130J8','02130J9','02130JC','02130JF','02130JW','02130K3','02130K8','02130K9','02130KC','02130KF','02130KW'
						,'02130Z3','02130Z8','02130Z9','02130ZC','02130ZF','0213483','0213488','0213489','021348C','021348F','021348W','0213493','0213498','0213499','021349C','021349F','021349W','02134A3','02134A8','02134A9'
						,'02134AC','02134AF','02134AW','02134J3','02134J8','02134J9','02134JC','02134JF','02134JW','02134K3','02134K8','02134K9','02134KC','02134KF','02134KW','02134Z3','02134Z8','02134Z9','02134ZC','02134ZF'
						,'33510','33511','33512','33513','33514','33516','33517','33518','33519','33521','33522','33523','33533','33534','33535','33536','3610','3611','3612','3613','3614','3615','3616','3617','3619','41402'
						,'41403','41404','41405','99603','B212','B213','V4581'				
						/*other coronary procedure was removed*/
/* 						,'4A033BC','92975','92977','92978','92979','93451','93452','93453','93454','93455','93456','93457','93458','93459','93460','93461','93462','93463' */
/* 						,'93464','93503','93505','93530','93531','93532','93533','93561','93562','93563','93564','93565','93566','93567','93568','93571','93572','93751','93752','B221Z2Z' */				
						,'93457','93459','93461','92975','92977'
						,'027034Z','027035Z','027036Z','027037Z'
						,'02703D6','02703DZ','02703EZ','02703F6','02703FZ','02703G6','02703GZ','02703T6','02703TZ','02703Z6','02703ZZ','027044Z','027045Z','027046Z','027047Z','02704D6','02704DZ','02704EZ','02704F6','02704FZ'
						,'02704G6','02704GZ','02704T6','02704TZ','02704Z6','02704ZZ','027134Z','027135Z','027136Z','027137Z','02713D6','02713DZ','02713EZ','02713F6','02713FZ','02713G6','02713GZ','02713T6','02713TZ','02713Z6'
						,'02713ZZ','027144Z','027145Z','027146Z','027147Z','02714D6','02714DZ','02714EZ','02714F6','02714FZ','02714G6','02714GZ','02714T6','02714TZ','02714Z6','02714ZZ','027234Z','027235Z','027236Z','027237Z'
						,'02723D6','02723DZ','02723EZ','02723F6','02723FZ','02723G6','02723GZ','02723T6','02723TZ','02723Z6','02723ZZ','027244Z','027245Z','027246Z','027247Z','02724D6','02724DZ','02724EZ','02724F6','02724FZ'
						,'02724G6','02724GZ','02724T6','02724TZ','02724Z6','02724ZZ','027334Z','027335Z','027336Z','027337Z','02733D6','02733DZ','02733EZ','02733F6','02733FZ','02733G6','02733GZ','02733T6','02733TZ','02733Z6'
						,'02733ZZ','027344Z','027345Z','027346Z','027347Z','02734D6','02734DZ','02734EZ','02734F6','02734FZ','02734G6','02734GZ','02734T6','02734TZ','02734Z6','02734ZZ','02C03Z6','02C03ZZ','02C04Z6','02C04ZZ'
						,'02C13Z6','02C13ZZ','02C14Z6','02C14ZZ','02C23Z6','02C23ZZ','02C24Z6','02C24ZZ','02C33Z6','02C33ZZ','02C34Z6','02C34ZZ','02N43ZZ','02Q43ZZ','2703000000','270346','270356','270366','270376','2704000000'
						,'270446','270456','270466','270476','2713000000','271346','271356','271366','271376','2714000000','271446','271456','271466','271476','2723000000','272346','272366','272376','2724000000','272446','272456'
						,'272466','272476','2733000000','273346','273356','273366','273376','2734000000','273446','273456','273466','273476','3601','3602','3605','92920','92921','92924','92925','92928','92929','92933','92934','92937'
						,'92938','92941','92943','92944','92973','92980','92981','92982','92984','92995','92996','C9600','C9601','C9602','C9603','C9604','C9605','C9606','C9607','C9608','G0290','G0291','S2220','C1375','C5030','C5031'
						,'C5032','C5048','33572','4561F','4562F','75963','02CQ0ZZ','02CQ4ZZ','02CR0ZZ','02CR4ZZ','03C00ZZ','03C04ZZ','03C10ZZ','03C14ZZ','03C20ZZ','03C24ZZ','03C30ZZ','03C34ZZ','03C40ZZ','03C44ZZ','03C50ZZ','03C53ZZ'
						,'03C54ZZ','03C60ZZ','03C63ZZ','03C64ZZ','03C70ZZ','03C73ZZ','03C74ZZ','03C80ZZ','03C83ZZ','03C84ZZ','03C90ZZ','03C93ZZ','03C94ZZ','03CA0ZZ','03CA3ZZ','03CA4ZZ','03CB0ZZ','03CB3ZZ','03CB4ZZ','03CC0ZZ','03CC3ZZ'
						,'03CC4ZZ','03CD0ZZ','03CD3ZZ','03CD4ZZ','03CF0ZZ','03CF3ZZ','03CF4ZZ','03CG0ZZ','03CG4ZZ','03CH0ZZ','03CH4ZZ','03CJ0ZZ','03CJ4ZZ','03CK0ZZ','03CK4ZZ','03CL0ZZ','03CL4ZZ','03CM0ZZ','03CM4ZZ','03CN0ZZ','03CN4ZZ'
						,'03CP0ZZ','03CP4ZZ','03CQ0ZZ','03CQ4ZZ','03CR0ZZ','03CR3ZZ','03CR4ZZ','03CS0ZZ','03CS3ZZ','03CS4ZZ','03CT0ZZ','03CT3ZZ','03CT4ZZ','03CU0ZZ','03CU3ZZ','03CU4ZZ','03CV0ZZ','03CV3ZZ','03CV4ZZ','03CY0ZZ','03CY3ZZ'
						,'03CY4ZZ','04C10ZZ','04C14ZZ','04C20ZZ','04C24ZZ','04C30ZZ','04C34ZZ','04C40ZZ','04C44ZZ','04C50ZZ','04C54ZZ','04C60ZZ','04C64ZZ','04C70ZZ','04C74ZZ','04C80ZZ','04C84ZZ','04C90ZZ','04C94ZZ','04CA0ZZ','04CA4ZZ'
						,'04CB0ZZ','04CB4ZZ','04CC0ZZ','04CC4ZZ','04CD0ZZ','04CD4ZZ','04CE0ZZ','04CE4ZZ','04CF0ZZ','04CF4ZZ','04CH0ZZ','04CH4ZZ','04CJ0ZZ','04CJ4ZZ','04CK0ZZ','04CK3ZZ','04CK4ZZ','04CL0ZZ','04CL3ZZ','04CL4ZZ','04CM0ZZ'
						,'04CM3ZZ','04CM4ZZ','04CN0ZZ','04CN3ZZ','04CN4ZZ','04CP0ZZ','04CP3ZZ','04CP4ZZ','04CQ0ZZ','04CQ3ZZ','04CQ4ZZ','04CR0ZZ','04CR3ZZ','04CR4ZZ','04CS0ZZ','04CS3ZZ','04CS4ZZ','04CT0ZZ','04CT3ZZ','04CT4ZZ','04CU0ZZ'
						,'04CU3ZZ','04CU4ZZ','04CV0ZZ','04CV3ZZ','04CV4ZZ','04CW0ZZ','04CW3ZZ','04CW4ZZ','04CY0ZZ','04CY3ZZ','04CY4ZZ','33572','381','3811','3812','3813','3814','3815','3816','3818','03CG3ZZ','03CG4ZZ','03CH3ZZ','03CH4ZZ'
						,'03CJ3ZZ','03CJ4ZZ','03CK3ZZ','03CK4ZZ','03CL3ZZ','03CL4ZZ','03CM3ZZ','03CM4ZZ','03CN3ZZ','03CN4ZZ','03CP3ZZ','03CP4ZZ','03CQ3ZZ','03CQ4ZZ','03CR3ZZ','03CR4ZZ','03CS3ZZ','03CS4ZZ','03CT3ZZ','03CT4ZZ','03CU3ZZ'
						,'03CU4ZZ','03CV3ZZ','03CV4ZZ','35880'), 
			 ndc_codes=, 
			 dx_dset=, 
			 pc_dset=, 
			 ndc_dset=, 
			 ndc_drugs=,
			 total_drugn=,
			 i_o=);

%ms_firstcut(implib= heoji3, 
		   	 output= mace_02_mi_stroke, 
		     databases= %str(ccae_mdcr), 
			 date_start=, 
			 date_end=, 
			 dx_codes= %str('410','4100','41000','41001','41002','4101','41010','41011','41012','4102','41020','41021','41022','4103'
							,'41030','41031','41032','4104','41040','41041','41042','4105','41050','41051','41052','4106','41060','41061'
							,'41062','4107','41070','41071','41072','4108','41080','41081','41082','4109','41090','41091','41092','412'
							,'I21','I210','I2101','I2102','I2109','I211','I2111','I2119','I212','I2121','I2129','I213','I214','I219','I21A'
							,'I21A1','I21A9','I22','I220','I221','I222','I228','I229','I252'

							,'43301','43311','43321','43331','43381','43391','43401','43411','43491','I63','I630','I6300','I6301','I63011'
							,'I63012','I63013','I63019','I6302','I6303','I63031','I63032','I63033','I63039','I6309','I631','I6310','I6311','I63111'
							,'I63112','I63113','I63119','I6312','I6313','I63131','I63132','I63133','I63139','I6319','I632','I6320','I6321','I63211'
							,'I63212','I63213','I63219','I6322','I6323','I63231','I63232','I63233','I63239','I6329','I633','I6330','I6331','I63311'
							,'I63312','I63313','I63319','I6332','I63321','I63322','I63323','I63329','I6333','I63331','I63332','I63333','I63339','I6334'
							,'I63341','I63342','I63343','I63349','I6339','I634','I6340','I6341','I63411','I63412','I63413','I63419','I6342','I63421'
							,'I63422','I63423','I63429','I6343','I63431','I63432','I63433','I63439','I6344','I63441','I63442','I63443','I63449','I6349'
							,'I635','I6350','I6351','I63511','I63512','I63513','I63519','I6352','I63521','I63522','I63523','I63529','I6353','I63531'
							,'I63532','I63533','I63539','I6354','I63541','I63542','I63543','I63549','I6359','I636','I638','I6381','I6389','I639'
							),  
			 pc_codes=, 
			 ndc_codes=, 
			 dx_dset=, 
			 pc_dset=, 
			 ndc_dset=, 
			 ndc_drugs=,
			 total_drugn=,
			 i_o=);

%ms_firstcut(implib= heoji3, 
		   	 output= mace_02_mi, 
		     databases= %str(ccae_mdcr), 
			 date_start=, 
			 date_end=, 
			 dx_codes= %str('410','4100','41000','41001','41002','4101','41010','41011','41012','4102','41020','41021','41022','4103'
							,'41030','41031','41032','4104','41040','41041','41042','4105','41050','41051','41052','4106','41060','41061'
							,'41062','4107','41070','41071','41072','4108','41080','41081','41082','4109','41090','41091','41092','412'
							,'I21','I210','I2101','I2102','I2109','I211','I2111','I2119','I212','I2121','I2129','I213','I214','I219','I21A'
							,'I21A1','I21A9','I22','I220','I221','I222','I228','I229','I252'
							),  
			 pc_codes=, 
			 ndc_codes=, 
			 dx_dset=, 
			 pc_dset=, 
			 ndc_dset=, 
			 ndc_drugs=,
			 total_drugn=,
			 i_o=);

%ms_firstcut(implib= heoji3, 
		   	 output= mace_02_stroke, 
		     databases= %str(ccae_mdcr), 
			 date_start=, 
			 date_end=, 
			 dx_codes= %str('43301','43311','43321','43331','43381','43391','43401','43411','43491','I63','I630','I6300','I6301','I63011'
							,'I63012','I63013','I63019','I6302','I6303','I63031','I63032','I63033','I63039','I6309','I631','I6310','I6311','I63111'
							,'I63112','I63113','I63119','I6312','I6313','I63131','I63132','I63133','I63139','I6319','I632','I6320','I6321','I63211'
							,'I63212','I63213','I63219','I6322','I6323','I63231','I63232','I63233','I63239','I6329','I633','I6330','I6331','I63311'
							,'I63312','I63313','I63319','I6332','I63321','I63322','I63323','I63329','I6333','I63331','I63332','I63333','I63339','I6334'
							,'I63341','I63342','I63343','I63349','I6339','I634','I6340','I6341','I63411','I63412','I63413','I63419','I6342','I63421'
							,'I63422','I63423','I63429','I6343','I63431','I63432','I63433','I63439','I6344','I63441','I63442','I63443','I63449','I6349'
							,'I635','I6350','I6351','I63511','I63512','I63513','I63519','I6352','I63521','I63522','I63523','I63529','I6353','I63531'
							,'I63532','I63533','I63539','I6354','I63541','I63542','I63543','I63549','I6359','I636','I638','I6381','I6389','I639'
							),  
			 pc_codes=, 
			 ndc_codes=, 
			 dx_dset=, 
			 pc_dset=, 
			 ndc_dset=, 
			 ndc_drugs=,
			 total_drugn=,
			 i_o=);

%ms_firstcut(implib= heoji3, 
		   	 output= mace_02_revasc, 
		     databases= %str(ccae_mdcr), 
			 date_start=, 
			 date_end=, 
			 dx_codes=,  
			 pc_codes= %str('0210083','0210088','0210089','021008C','021008F','021008W','0210093','0210098','0210099','021009C','021009F','021009W','02100A3','02100A8','02100A9','02100AC','02100AF','02100AW','02100J3','02100J8'
						,'02100J9','02100JC','02100JF','02100JW','02100K3','02100K8','02100K9','02100KC','02100KF','02100KW','02100Z3','02100Z8','02100Z9','02100ZC','02100ZF','0210483','0210488','0210489','021048C','021048F'
						,'021048W','0210493','0210498','0210499','021049C','021049F','021049W','02104A3','02104A8','02104A9','02104AC','02104AF','02104AW','02104J3','02104J8','02104J9','02104JC','02104JF','02104JW','02104K3'
						,'02104K8','02104K9','02104KC','02104KF','02104KW','02104Z3','02104Z8','02104Z9','02104ZC','02104ZF','0211083','0211088','0211089','021108C','021108F','021108W','0211093','0211098','0211099','021109C'
						,'021109F','021109W','02110A3','02110A8','02110A9','02110AC','02110AF','02110AW','02110J3','02110J8','02110J9','02110JC','02110JF','02110JW','02110K3','02110K8','02110K9','02110KC','02110KF','02110KW'
						,'02110Z3','02110Z8','02110Z9','02110ZC','02110ZF','0211483','0211488','0211489','021148C','021148F','021148W','0211493','0211498','0211499','021149C','021149F','021149W','02114A3','02114A8','02114A9'
						,'02114AC','02114AF','02114AW','02114J3','02114J8','02114J9','02114JC','02114JF','02114JW','02114K3','02114K8','02114K9','02114KC','02114KF','02114KW','02114Z3','02114Z8','02114Z9','02114ZC','02114ZF'
						,'0212083','0212088','0212089','021208C','021208F','021208W','0212093','0212098','0212099','021209C','021209F','021209W','02120A3','02120A8','02120A9','02120AC','02120AF','02120AW','02120J3','02120J8'
						,'02120J9','02120JC','02120JF','02120JW','02120K3','02120K8','02120K9','02120KC','02120KF','02120KW','02120Z3','02120Z8','02120Z9','02120ZC','02120ZF','0212483','0212488','0212489','021248C','021248F'
						,'021248W','0212493','0212498','0212499','021249C','021249F','021249W','02124A3','02124A8','02124A9','02124AC','02124AF','02124AW','02124J3','02124J8','02124J9','02124JC','02124JF','02124JW','02124K3'
						,'02124K8','02124K9','02124KC','02124KF','02124KW','02124Z3','02124Z8','02124Z9','02124ZC','02124ZF','0213083','0213088','0213089','021308C','021308F','021308W','0213093','0213098','0213099','021309C'
						,'021309F','021309W','02130A3','02130A8','02130A9','02130AC','02130AF','02130AW','02130J3','02130J8','02130J9','02130JC','02130JF','02130JW','02130K3','02130K8','02130K9','02130KC','02130KF','02130KW'
						,'02130Z3','02130Z8','02130Z9','02130ZC','02130ZF','0213483','0213488','0213489','021348C','021348F','021348W','0213493','0213498','0213499','021349C','021349F','021349W','02134A3','02134A8','02134A9'
						,'02134AC','02134AF','02134AW','02134J3','02134J8','02134J9','02134JC','02134JF','02134JW','02134K3','02134K8','02134K9','02134KC','02134KF','02134KW','02134Z3','02134Z8','02134Z9','02134ZC','02134ZF'
						,'33510','33511','33512','33513','33514','33516','33517','33518','33519','33521','33522','33523','33533','33534','33535','33536','3610','3611','3612','3613','3614','3615','3616','3617','3619','41402'
						,'41403','41404','41405','99603','B212','B213','V4581'				
						/*other coronary procedure was removed*/
/* 						,'4A033BC','92975','92977','92978','92979','93451','93452','93453','93454','93455','93456','93457','93458','93459','93460','93461','93462','93463' */
/* 						,'93464','93503','93505','93530','93531','93532','93533','93561','93562','93563','93564','93565','93566','93567','93568','93571','93572','93751','93752','B221Z2Z' */				
						,'93457','93459','93461','92975','92977'
						,'027034Z','027035Z','027036Z','027037Z'
						,'02703D6','02703DZ','02703EZ','02703F6','02703FZ','02703G6','02703GZ','02703T6','02703TZ','02703Z6','02703ZZ','027044Z','027045Z','027046Z','027047Z','02704D6','02704DZ','02704EZ','02704F6','02704FZ'
						,'02704G6','02704GZ','02704T6','02704TZ','02704Z6','02704ZZ','027134Z','027135Z','027136Z','027137Z','02713D6','02713DZ','02713EZ','02713F6','02713FZ','02713G6','02713GZ','02713T6','02713TZ','02713Z6'
						,'02713ZZ','027144Z','027145Z','027146Z','027147Z','02714D6','02714DZ','02714EZ','02714F6','02714FZ','02714G6','02714GZ','02714T6','02714TZ','02714Z6','02714ZZ','027234Z','027235Z','027236Z','027237Z'
						,'02723D6','02723DZ','02723EZ','02723F6','02723FZ','02723G6','02723GZ','02723T6','02723TZ','02723Z6','02723ZZ','027244Z','027245Z','027246Z','027247Z','02724D6','02724DZ','02724EZ','02724F6','02724FZ'
						,'02724G6','02724GZ','02724T6','02724TZ','02724Z6','02724ZZ','027334Z','027335Z','027336Z','027337Z','02733D6','02733DZ','02733EZ','02733F6','02733FZ','02733G6','02733GZ','02733T6','02733TZ','02733Z6'
						,'02733ZZ','027344Z','027345Z','027346Z','027347Z','02734D6','02734DZ','02734EZ','02734F6','02734FZ','02734G6','02734GZ','02734T6','02734TZ','02734Z6','02734ZZ','02C03Z6','02C03ZZ','02C04Z6','02C04ZZ'
						,'02C13Z6','02C13ZZ','02C14Z6','02C14ZZ','02C23Z6','02C23ZZ','02C24Z6','02C24ZZ','02C33Z6','02C33ZZ','02C34Z6','02C34ZZ','02N43ZZ','02Q43ZZ','2703000000','270346','270356','270366','270376','2704000000'
						,'270446','270456','270466','270476','2713000000','271346','271356','271366','271376','2714000000','271446','271456','271466','271476','2723000000','272346','272366','272376','2724000000','272446','272456'
						,'272466','272476','2733000000','273346','273356','273366','273376','2734000000','273446','273456','273466','273476','3601','3602','3605','92920','92921','92924','92925','92928','92929','92933','92934','92937'
						,'92938','92941','92943','92944','92973','92980','92981','92982','92984','92995','92996','C9600','C9601','C9602','C9603','C9604','C9605','C9606','C9607','C9608','G0290','G0291','S2220','C1375','C5030','C5031'
						,'C5032','C5048','33572','4561F','4562F','75963','02CQ0ZZ','02CQ4ZZ','02CR0ZZ','02CR4ZZ','03C00ZZ','03C04ZZ','03C10ZZ','03C14ZZ','03C20ZZ','03C24ZZ','03C30ZZ','03C34ZZ','03C40ZZ','03C44ZZ','03C50ZZ','03C53ZZ'
						,'03C54ZZ','03C60ZZ','03C63ZZ','03C64ZZ','03C70ZZ','03C73ZZ','03C74ZZ','03C80ZZ','03C83ZZ','03C84ZZ','03C90ZZ','03C93ZZ','03C94ZZ','03CA0ZZ','03CA3ZZ','03CA4ZZ','03CB0ZZ','03CB3ZZ','03CB4ZZ','03CC0ZZ','03CC3ZZ'
						,'03CC4ZZ','03CD0ZZ','03CD3ZZ','03CD4ZZ','03CF0ZZ','03CF3ZZ','03CF4ZZ','03CG0ZZ','03CG4ZZ','03CH0ZZ','03CH4ZZ','03CJ0ZZ','03CJ4ZZ','03CK0ZZ','03CK4ZZ','03CL0ZZ','03CL4ZZ','03CM0ZZ','03CM4ZZ','03CN0ZZ','03CN4ZZ'
						,'03CP0ZZ','03CP4ZZ','03CQ0ZZ','03CQ4ZZ','03CR0ZZ','03CR3ZZ','03CR4ZZ','03CS0ZZ','03CS3ZZ','03CS4ZZ','03CT0ZZ','03CT3ZZ','03CT4ZZ','03CU0ZZ','03CU3ZZ','03CU4ZZ','03CV0ZZ','03CV3ZZ','03CV4ZZ','03CY0ZZ','03CY3ZZ'
						,'03CY4ZZ','04C10ZZ','04C14ZZ','04C20ZZ','04C24ZZ','04C30ZZ','04C34ZZ','04C40ZZ','04C44ZZ','04C50ZZ','04C54ZZ','04C60ZZ','04C64ZZ','04C70ZZ','04C74ZZ','04C80ZZ','04C84ZZ','04C90ZZ','04C94ZZ','04CA0ZZ','04CA4ZZ'
						,'04CB0ZZ','04CB4ZZ','04CC0ZZ','04CC4ZZ','04CD0ZZ','04CD4ZZ','04CE0ZZ','04CE4ZZ','04CF0ZZ','04CF4ZZ','04CH0ZZ','04CH4ZZ','04CJ0ZZ','04CJ4ZZ','04CK0ZZ','04CK3ZZ','04CK4ZZ','04CL0ZZ','04CL3ZZ','04CL4ZZ','04CM0ZZ'
						,'04CM3ZZ','04CM4ZZ','04CN0ZZ','04CN3ZZ','04CN4ZZ','04CP0ZZ','04CP3ZZ','04CP4ZZ','04CQ0ZZ','04CQ3ZZ','04CQ4ZZ','04CR0ZZ','04CR3ZZ','04CR4ZZ','04CS0ZZ','04CS3ZZ','04CS4ZZ','04CT0ZZ','04CT3ZZ','04CT4ZZ','04CU0ZZ'
						,'04CU3ZZ','04CU4ZZ','04CV0ZZ','04CV3ZZ','04CV4ZZ','04CW0ZZ','04CW3ZZ','04CW4ZZ','04CY0ZZ','04CY3ZZ','04CY4ZZ','33572','381','3811','3812','3813','3814','3815','3816','3818','03CG3ZZ','03CG4ZZ','03CH3ZZ','03CH4ZZ'
						,'03CJ3ZZ','03CJ4ZZ','03CK3ZZ','03CK4ZZ','03CL3ZZ','03CL4ZZ','03CM3ZZ','03CM4ZZ','03CN3ZZ','03CN4ZZ','03CP3ZZ','03CP4ZZ','03CQ3ZZ','03CQ4ZZ','03CR3ZZ','03CR4ZZ','03CS3ZZ','03CS4ZZ','03CT3ZZ','03CT4ZZ','03CU3ZZ'
						,'03CU4ZZ','03CV3ZZ','03CV4ZZ','35880'), 
			 ndc_codes=, 
			 dx_dset=, 
			 pc_dset=, 
			 ndc_dset=, 
			 ndc_drugs=,
			 total_drugn=,
			 i_o=);
			 
			 
%ms_firstcut(implib= heoji3, 
		   	 output= mace_02_dm, 
		     databases= %str(ccae_mdcr), 
			 date_start=, 
			 date_end=, 
			 dx_codes= %str('250','E10','E11','E13','E14'),  
			 pc_codes=,
			 dx_dset=, 
			 pc_dset=, 
			 ndc_dset=, 
			 ndc_drugs=,
			 total_drugn=,
			 i_o=);

%ms_firstcut(implib= heoji3, 
		   	 output= mace_02_htn, 
		     databases= %str(ccae_mdcr), 
			 date_start=, 
			 date_end=, 
			 dx_codes= %str('401','402','403','404','405','I10','I11','I12','I13','I15','I16'),  
			 pc_codes=,
			 dx_dset=, 
			 pc_dset=, 
			 ndc_dset=, 
			 ndc_drugs=,
			 total_drugn=,
			 i_o=);
			 
%ms_firstcut(implib= heoji3, 
		   	 output= mace_02_infl, 
		     databases= %str(ccae_mdcr), 
			 date_start=, 
			 date_end=, 
			 dx_codes= %str('274','711','712','713','714','715','716','M05','M06','M07','M08','M10','M11','M12','M13','M14','M1A','M15','M16','M17','M18','M19','696','L40','7100','M32','340 ','G35','555','556','K50','K51','2554','2555'
							,'E271','E274','242','E05','7102','M350 ','5790','K900 ','4462','4465','4476 ','I776 ','M310','M316','7280','72881 ','72882 ','7291','M60','7200','M45','28981','D6861','7101','M34'),  
			 pc_codes=,
			 dx_dset=, 
			 pc_dset=, 
			 ndc_dset=, 
			 ndc_drugs=,
			 total_drugn=,
			 i_o=);			 

%ms_firstcut(implib= heoji3, 
		   	 output= mace_02_gang, 
		     databases= %str(ccae_mdcr), 
			 date_start=, 
			 date_end=, 
			 dx_codes= %str('I7026'),  
			 pc_codes=,
			 dx_dset=, 
			 pc_dset=, 
			 ndc_dset=, 
			 ndc_drugs=,
			 total_drugn=,
			 i_o=);	
			 
%countid2(mace_02_ascvd);
%countid2(mace_02_mi_stroke);
%countid2(mace_02_mi);
%countid2(mace_02_revasc);
%countid2(mace_02_dm);
%countid2(mace_02_stroke);
%countid2(mace_02_htn);
%countid2(mace_02_infl);

%countid2(mace_02_gang);

%output2(mace_02_mi);


* enrollment;
/*this code takes too long time, so alternative way the below was used*/
%ms_enrollment(implib= heoji3 /*impala schema name for which input cohort and output cohort are stored*/, 
				 cohort= mace_02_ascvd /*impala table name for input cohort for which enrollment is needed*/, 
				 output= mace_02_ascvd_enrol /*impala table name for output cohort*/, 
				 databases= %str(ccae_mdcr) /*impala table name:ccae_mdcr or medicaid*/, 
				 rx=  /*drug coverage, 1-yes; 0-no*/, 
				 ffs= /*fee for service coverage*/, 
				 gap= 0 /*allowed gap in days for defining continuous enrollment*/);
				 

%connDBPassThrough(dbname=heoji3, libname1=imp);
execute (drop table if exists heoji3.mace_02_ascvd_dm PURGE) by imp; 
execute	(create table heoji3.mace_02_ascvd_dm as
		SELECT distinct enrolid
		FROM mace_02_ascvd
		union
		SELECT distinct enrolid
		FROM mace_02_dm	
	) by imp;
quit;
				 
%connDBPassThrough(dbname=heoji3, libname1=imp);
execute (drop table if exists heoji3.mace_02_ascvd_enrol_pre PURGE) by imp; 
execute	(create table heoji3.mace_02_ascvd_enrol_pre as
		SELECT * 
		FROM src_marketscan.ccae_mdcr_t /*6,954,814,968  206,027,265*/
		WHERE enrolid in (select distinct enrolid from heoji3.mace_02_ascvd_dm)
		    and year between 2005 and 2019
	) by imp;
quit;


/*enrollment period - final*/
%connDBPassThrough(dbname=heoji3, libname1=imp);
execute (DROP TABLE IF EXISTS heoji3.mace_02_ascvd_enrol_fn PURGE) by imp;
execute	(CREATE table heoji3.mace_02_ascvd_enrol_fn as 
		SELECT DISTINCT starts.enrolid, starts.dtstart AS enroll_start, ends.dtend AS enroll_end, starts.sex, starts.dobyr, starts.region, starts.plantyp
			FROM ( 
					SELECT enrolid, dtstart, ROW_NUMBER() OVER (ORDER BY enrolid, dtstart) AS rn, sex, dobyr, region, plantyp
		 			FROM ( 
							SELECT enrolid, dtstart, dtend, sex, dobyr, region, plantyp,
				 			CASE WHEN DATEDIFF(dtstart, prev_end) <= (0+1) THEN "cont" ELSE "new" END AS start_status,
				 			CASE WHEN DATEDIFF(next_start, dtend) <= (0+1) THEN "cont" ELSE "new" END AS end_status
					FROM ( 
							SELECT enrolid, dtstart, dtend, sex, dobyr, region, plantyp,
							COALESCE(LAG(dtend,1) OVER (PARTITION BY enrolid ORDER BY dtstart,dtend), null) as prev_end,
							COALESCE(LEAD(dtstart,1) OVER (PARTITION BY enrolid ORDER BY dtstart,dtend), null) as next_start
		 					FROM heoji3.mace_02_ascvd_enrol_pre
		 					) AS t1
						) AS t2
			 		WHERE start_status= "new"
				) AS starts,
				( 
					SELECT enrolid, dtend, ROW_NUMBER() OVER (ORDER BY enrolid, dtstart) AS rn
		 			FROM ( 
							SELECT enrolid, dtstart, dtend,
				 			CASE WHEN DATEDIFF(dtstart, prev_end) <= (0+1) THEN "cont" ELSE "new" END AS start_status,
				 			CASE WHEN DATEDIFF(next_start, dtend) <= (0+1) THEN "cont" ELSE "new" END AS end_status
		 			FROM ( 
							SELECT enrolid, dtstart, dtend,
							COALESCE(LAG(dtend,1) OVER (PARTITION BY enrolid ORDER BY dtstart,dtend), null) as prev_end,
							COALESCE(LEAD(dtstart,1) OVER (PARTITION BY enrolid ORDER BY dtstart,dtend), null) as next_start
		 					FROM heoji3.mace_02_ascvd_enrol_pre
		 				  ) AS t3
					) AS t4
					WHERE end_status= "new"
					) AS ends
					WHERE starts.rn = ends.rn		 
	) by imp;	
quit;
%output2(mace_02_ascvd_enrol_fn);
