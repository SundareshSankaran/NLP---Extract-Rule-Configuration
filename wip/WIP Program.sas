%let projectName="cas-shared-default/Analytics_Project_6d5f6a11-799a-4743-9760-3bd61ad69714";
%let targetCaslib=PUBLIC;

%let casServer=%scan("&projectName.",1,"/");
%put &casServer.;

%let projectCaslib=%scan("&projectName.",2,"/");
%put &projectCaslib.;



/*-----------------------------------------------------------------------------------------*
   This block of code calls the SAS Viya platform API to obtain a list of running CAS
   servers and creates an output table listing all CAS servers.  Thanks to Bruno Mueller
   for providing the code based on SAS Viya API documentation.
*------------------------------------------------------------------------------------------*/

%let casHost=sas-cas-server-default-client;

%let BASE_URI = %sysfunc(getoption(servicesbaseurl));
%put NOTE: &=base_uri;
 
filename resp temp;
proc http
   method=get
   url="&base_uri/casManagement/servers"
   out=resp
   oauth_bearer=sas_services 
   verbose
;
run;
 
%put NOTE: &=SYS_PROCHTTP_STATUS_CODE;
%put NOTE: &=SYS_PROCHTTP_STATUS_PHRASE;  
  
libname resp json NOALLDATA;
data __casservers;
set resp.items;
   if name="&casServer." then do;
      call symput("casHost",host);
      call symput("casPort",port);
   end;
run;

cas ss host="&casHost" port=&casPort.;
caslib _ALL_ assign;

proc cas;
   
   source CategoryCode;
      data &targetCaslib..tempRuleConfig ;
      set &targetCaslib..tempRuleConfig;
         re=PRXPARSE('/(\(.*\))/');
         length category_name varchar(*) rule_string varchar(*);
         category_name=scan(config,2,":");
         if prxmatch(re, config) then do;
            rule_string=prxposn(re,1, config);
         end;
         config=compbl(config);
      run;
   endsource;


   source ConceptCode;
      data &targetCaslib..tempRuleConfig ;
      set &targetCaslib..tempRuleConfig;
         re=PRXPARSE('/(\(.*\))/');
         length category_name varchar(*) rule_string varchar(*);
         category_name=scan(config,2,":");
         if prxmatch(re, config) then do;
            rule_string=prxposn(re,1, config);
         end;
         config=compbl(config);
      run;
   endsource;


   projectCaslib=symget("projectCaslib");
   targetCaslib=symget("targetCaslib");
   table.tableInfo /
      caslib=projectCaslib
;
   table.tableInfo result=tableList /
      caslib=projectCaslib
;
   ruleConfigList = tableList.TableInfo.where(Name contains "_RULESCONFIG");
   ruleConfigList=ruleConfigList.compute("Type",scan(Name,-2,"_"));
   print ruleConfigList;

   saveresult ruleConfigList dataout=work.results;

   n = dim(ruleConfigList);
   do i = 1 to n;
      nameTable=ruleConfigList[i,"Name"];
      typeOfRuleconfig=ruleConfigList[i,"Type"];

      table.copyTable /
		 table={name=nameTable, caslib=projectCaslib}
         casout={name="tempRuleConfig", caslib=targetCaslib, replace=True}
      ;
      
      if typeOfRuleConfig=="CATEGORY" then do;
      dataStep.runCode / 
         code=CategoryCode;
      
      end;
      else do;

      end;


      table.save /
         table={name=nameTable, caslib=projectCaslib}
         name=nameTable
         caslib=targetCaslib
         replace=True
      ;
   end;


quit;

data PUBLIC.tempRuleConfig;
set PUBLIC.tempRuleConfig;


run;


/* cas ss terminate; */