cas ss;
caslib _ALL_ assign;


data PUBLIC.TEST_CONCEPT_RULECONFIG_1;
length configline rule_attribute rule_string concept_name varchar(*);
set PUBLIC.TEST_CONCEPT_RULECONFIG;

do i = 1 to sum(count(config,"0A"x),1);
   rule_attribute="";
   rule_string="";
   concept_name="";
   configline=scan(config,i,"0A"x,"MO");
   If count(configline,":")>=2 then do;
      re_con_pattern=PRXPARSE('/(.+)\:(.+)\:(.+)/');
      if prxmatch(re_con_pattern, configline) then do;
         call prxposn(re_con_pattern, 1, position, length);
         rule_attribute = substr(configline, position, length);
         call prxposn(re_con_pattern, 2, position, length);
         concept_name = substr(configline, position, length);
         call prxposn(re_con_pattern, 3, position, length);
         rule_string = substr(configline, position, length);
         output;
      end;
   end;
   else if count(configline,":")=1 then do;
      re_con_pattern=PRXPARSE('/(.+)\:(.+)/');
      if prxmatch(re_con_pattern, configline) then do;
         call prxposn(re_con_pattern, 1, position, length);
         rule_attribute = substr(configline, position, length);
         call prxposn(re_con_pattern, 2, position, length);
         concept_name = substr(configline, position, length);
         output;
      end;
   end;
end;
run;

data PUBLIC.TEST_CONCEPT_RULECONFIG_2;
length configline entity_attribute rule_string concept_name varchar(*);
set PUBLIC.TEST_CONCEPT_RULECONFIG;
do i = 1 to sum(count(config,"0A"x),1);
   entity_attribute="";
   rule_string="";
   concept_name="";
   configline=scan(config,i,"0A"x,"MO");
   concept_name=scan(configline,2,":","MO");
   entity_attribute=scan(configline,1,":","MO");
   if compress(entity_attribute) in ("PRIORITY","FULLPATH","PREDEFINED") then do;
      rule_string=transtrn(configline,compress(entity_attribute||":"||concept_name||":"),"");
   end;
   else if compress(entity_attribute) in ("ENABLE","CASE_INSENSITIVE_MATCH") then do;
      rule_string=transtrn(configline,compress(entity_attribute||":"||concept_name),"");
   end;
   else do;
      entity_attribute="RULE";
      rule_string=transtrn(configline,compress(concept_name||":"),"");
   end;
   output;
end;
run;


/* cas ss terminate; */