CREATE OR REPLACE procedure NYU_V_ED_SCPM_TST ( numDays in integer
                                            ) is
-- Few changes:
--    Add logging for timing debugging
--    remove end_dt as it is not effective (useless)
--    add UPDATE_DATE >= start_dt for ED_TMP
--    use "UPDATE_DATE >= start_dt" replacing "trunc(eei.update_date) between start_dt and end_dt"
--    replace "eei.*" by specific fields
--    use global temp tables:
-- CREATE GLOBAL TEMPORARY TABLE REPORTADMIN.NYUGT_ED_TMP ON COMMIT PRESERVE ROWS AS SELECT * FROM REPORTADMIN.ED_TMP WHERE ROWNUM < 0;
-- CREATE GLOBAL TEMPORARY TABLE REPORTADMIN.NYUGT_ED_ORD_TMP ON COMMIT PRESERVE ROWS AS SELECT * FROM REPORTADMIN.ED_ORD_TMP WHERE ROWNUM < 0;
-- CREATE GLOBAL TEMPORARY TABLE REPORTADMIN.NYUGT_ED_ADT_TMP ON COMMIT PRESERVE ROWS AS SELECT * FROM REPORTADMIN.ED_ADT_TMP WHERE ROWNUM < 0;
-- create index REPORTADMIN.X1_NYUGT_ED_ADT on REPORTADMIN.NYUGT_ED_ADT_TMP(EVENT_ID);
-- create index REPORTADMIN.X2_NYUGT_ED_ADT on REPORTADMIN.NYUGT_ED_ADT_TMP(PAT_ENC_CSN_ID);

--
    start_dt    date;
    -- end_dt      date;
    s_date date;
    e_date date;
    cnt integer;
    Qcnt integer;
BEGIN


    If (numDays=99999 or numDays is null) then
      start_dt := to_date('06/05/2011','mm/dd/yyyy');
      -- end_dt   := trunc(SYSDATE );
    Else
      start_dt := trunc(sysdate-numDays);
      -- end_dt   := trunc(SYSDATE );
    End If;
clarity.NYU_CLARITY_LOG_PKG.logMsg( 'REPORTADMIN.NYU_V_ED_SCPM', 'REPORTADMIN.NYU_V_ED_SCPM_TST', 'INFO', 'START', 'SP STARTED-from'||to_char(start_dt,'mm/dd/yy'));

-- These delete should be fast as no data in tmp table: JHO
delete NYUGT_ED_TMP;
delete NYUGT_ED_ORD_TMP;
delete NYUGT_ED_ADT_TMP;
COMMIT;

 ---  Qcnt:= round((end_dt - start_dt)/90); -- number of quarters

/*BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE OPTIME_TMP';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
*/

-- execute immediate 'Truncate table ED_TMP';
--execute immediate 'DROP TABLE ED_TMP PURGE';

--execute immediate 'CREATE GLOBAL TEMPORARY TABLE NYUGTT_ED_TMP ON COMMIT PRESERVE ROWS as select * from ED_TMP where 1=0';
--commit;
--5/10/21 YC split into 2 inserts to handle full refresh with the old logic:

if (numDays=99999 or numDays is null) then ---full refresh
  insert /*+ APPEND PARALLEL(8) ENABLE_PARALLEL_DML */   into NYUGT_ED_TMP
    select pat_enc_csn_id,update_date,hsp_account_id,
            max(TRIAGE_STARTED) as TRIAGE_STARTED ,
            max(IP_BED_REQUESTED)  AS IP_BED_REQUESTED,
            max(PATIENT_DEPARTED_FROM_ED)  AS PATIENT_DEPARTED_FROM_ED,
            max(PATIENT_ARRIVED_IN_ED)  AS PATIENT_ARRIVED_IN_ED,
            max(PATIENT_ADMITTED)  AS PATIENT_ADMITTED,
            max(PATIENT_ADMITTED_BY)  AS PATIENT_ADMITTED_BY,
            max(PATIENT_ADMITTED_TITLE)  AS PATIENT_ADMITTED_TITLE,
            max(PATIENT_ADMITTED_TO)  AS PATIENT_ADMITTED_TO,
            max(TRIAGE_COMPLETED)  AS TRIAGE_COMPLETED,
            max(TRIAGE_COMPLETED_BY)  AS TRIAGE_COMPLETED_BY,
            max(ASSIGN_PHYSICIAN)  AS ASSIGN_PHYSICIAN,
            max(ED_NOTE_FILED)  AS ED_NOTE_FILED,
            max(FIRST_PROVIDER_CONTACT)  AS FIRST_PROVIDER_CONTACT,
            max(DECISION_TO_ED_OBSER)  AS DECISION_TO_ED_OBSER,
            max (SHORT_TERM_STAY) as SHORT_TERM_STAY,
            max(SHORT_TERM_STAY_TIMESTAMP) as SHORT_TERM_STAY_TIMESTAMP,
            max(TRANS_TO_OBSER_TIMESTAMP) as TRANS_TO_OBSER_TIMESTAMP,
            sysdate as RUN_DATE --- YC 6/1/2018 added for control
            ,max(ED_IP_BED_ASSIGNED) as ED_IP_BED_ASSIGNED ---YC 6/13/2018 SR#2494939
            ,max(ARRIVAL_department_id) as ARRIVAL_department_id  -- 10/10/2019 YC define arrival dept by event
      from (
         select eei.pat_enc_csn_id,peh.hsp_account_id,
            max(eei.update_date) over (partition by eei.pat_enc_csn_id ) AS update_date,
            CASE WHEN EEI.EVENT_TYPE = '205' THEN eei.event_time    END AS TRIAGE_STARTED,
            CASE WHEN EEI.EVENT_TYPE = '16022281' THEN eei.event_time    END AS IP_BED_REQUESTED,
            CASE WHEN EEI.EVENT_TYPE = '95' THEN eei.event_time    END AS PATIENT_DEPARTED_FROM_ED,
            CASE WHEN EEI.EVENT_TYPE = '50' THEN eei.event_time    END AS PATIENT_ARRIVED_IN_ED,
            CASE WHEN EEI.EVENT_TYPE = '65' AND eei.adt_event_id is not null then eei.event_time END AS PATIENT_ADMITTED,
            CASE WHEN EEI.EVENT_TYPE = '65' AND eei.adt_event_id IS NOT NULL THEN emp.name  END AS PATIENT_ADMITTED_BY,
            CASE WHEN EEI.EVENT_TYPE = '65' AND eei.adt_event_id IS NOT NULL THEN ser.clinician_title END AS PATIENT_ADMITTED_TITLE,
            CASE WHEN EEI.EVENT_TYPE = '65' AND eei.adt_event_id IS NOT NULL THEN dep.mpi_id  END AS PATIENT_ADMITTED_TO,
            CASE WHEN EEI.EVENT_TYPE = '210' THEN eei.event_time    END AS TRIAGE_COMPLETED,
            CASE WHEN EEI.EVENT_TYPE = '210' THEN EMP.NAME    END AS TRIAGE_COMPLETED_BY,
            CASE WHEN eei.event_type = '16011103' THEN eei.event_time    END AS ASSIGN_PHYSICIAN,
            CASE WHEN eei.event_type = '500' THEN eei.event_time    END AS ED_NOTE_FILED,
            CASE WHEN eei.event_type = '16011103' THEN eei.event_time    END AS FIRST_PROVIDER_CONTACT,
           min( CASE  WHEN eei.event_type in('160224', '1600000062')  THEN eei.event_time END)
                over (partition by eei.pat_enc_csn_id ) AS DECISION_TO_ED_OBSER,
          CASE WHEN eei.event_type = '160225' THEN 'Y'    END AS SHORT_TERM_STAY ,
            ---12/27/2017 YC by Antony's request -- SR# 2421291
          CASE WHEN EEI.EVENT_TYPE = '160225' THEN eei.event_time  END AS SHORT_TERM_STAY_TIMESTAMP,
          CASE WHEN EEI.EVENT_TYPE = '1600000060' THEN eei.event_time  END AS TRANS_TO_OBSER_TIMESTAMP,
          min( CASE  WHEN eei.event_type in('236', '16023101')  THEN eei.event_time END)
                over (partition by eei.pat_enc_csn_id ) AS ED_IP_BED_ASSIGNED
          ,CASE WHEN EEI.EVENT_TYPE = '50' THEN EVENT_DEPT_ID    END AS ARRIVAL_department_id
          from (
            select epi.pat_enc_csn_id
              ,epi.update_date
              ---,ed_updates.CSA_UPDATE_DATE update_date -- 5/4/2020 YC per Jackey's recomendation
              ,epi.items_edited_time,epi.pat_id
              ,row_number() over (partition by epi.pat_enc_csn_id,event_type order by eei.event_time,eei.adt_event_id) rn -- YC 6/4/2018 added ,eei.adt_event_id - otherwise may be sorted by the empty adt_event first
              -- ,EEI.*
              ,EEI.ADT_EVENT_ID ,EEI.EVENT_TIME ,EEI.EVENT_TYPE ,EEI.EVENT_USER_ID ,EEI.EVENT_DEPT_ID -- Apr 30, jho

                from ed_iev_PAT_info epi
                join ed_iev_event_info eei  ON eei.event_id=epi.event_id
              -- for   left join ed_updates on ed_updates.pat_enc_csn_id=epi.pat_enc_csn_id -- YC 5/4/21 limited by updated csn
              where eei.event_type      IN ('50','65','95','205','210','16022281','500','16011103','160224','1600000062'
              ,'160225'    ---    S6/8/2017 R #2299042 Short Term Stay Patient
              ,'1600000060'--- 12/27/2017 per Antory's request - Patient transferred to ED Obs -- SR# 2421291
              ,'236'    -- ED BED ASSIGNED 6/13/2018 SR#2494939
              ,'16023101'    --ED IP BED ASSIGNED
              )
              AND eei.event_status_c  IS NULL
              AND EPI.UPDATE_DATE >= START_DT -- FILTER DATA; NO NEED FOR BETWEEN AS END_DT = TRUNC(SYSDATE) -- APR 30, JHO
              ----and trunc(eei.update_date) between start_dt and end_dt ----- YC 6/1/2018 for some reason it makes a big difference to filter dates - but not at the end of query
              ----and epi.pat_enc_csn_id in (704093404,703886494)
              ) eei
            join pat_enc_hsp peh on peh.pat_enc_csn_id = eei.pat_enc_csn_id
            left outer JOIN clarity_adt adt  ON eei.adt_event_id = adt.event_id
            LEFT OUTER JOIN clarity_emp emp  ON eei.event_user_id = emp.user_id
            LEFT OUTER JOIN clarity_ser ser  ON emp.prov_id = ser.prov_id
            LEFT OUTER JOIN cl_dep_id dep  ON adt.department_id   = dep.department_id  AND dep.mpi_id_type_id = 36
          where rn=1)
    where UPDATE_DATE >= START_DT -- Filter data; no need for between as end_dt = trunc(sysdate) -- Apr 30, jho
    group by pat_enc_csn_id,update_date,hsp_account_id ;
  
else

      insert /*+ APPEND PARALLEL(8) ENABLE_PARALLEL_DML */   into NYUGT_ED_TMP
      with ed_updates as 
      (
      SELECT distinct
           PAT_ENC.PAT_ID, PAT_ENC.PAT_ENC_CSN_ID,
           PAT_ENC_HSP.ED_EPISODE_ID, PAT_ENC_HSP.ADMIT_CONF_STAT_C,
           PAT_ENC.CONTACT_DATE, PAT_ENC.Effective_Date_Dt--,PAT_ENC.UPDATE_DATE
           ,CSA."_UPDATE_DT" CSA_UPDATE_DATE
      FROM EPIC_UTIL.CSA_PAT_ENC CSA
      INNER JOIN PAT_ENC ON CSA.PAT_ENC_CSN_ID = PAT_ENC.PAT_ENC_CSN_ID
      INNER JOIN PAT_ENC_HSP ON PAT_ENC_HSP.PAT_ENC_CSN_ID = PAT_ENC.PAT_ENC_CSN_ID 
                            AND PAT_ENC_HSP.ED_EPISODE_ID IS NOT NULL 
                            AND (PAT_ENC_HSP.ADMIT_CONF_STAT_C IS NULL OR PAT_ENC_HSP.ADMIT_CONF_STAT_C NOT IN (2,3))
      WHERE CSA."_UPDATE_DT" >= start_dt AND                   
            CSA."_SOURCE" = 0
      )
      select pat_enc_csn_id,update_date,hsp_account_id,
              max(TRIAGE_STARTED) as TRIAGE_STARTED ,
              max(IP_BED_REQUESTED)  AS IP_BED_REQUESTED,
              max(PATIENT_DEPARTED_FROM_ED)  AS PATIENT_DEPARTED_FROM_ED,
              max(PATIENT_ARRIVED_IN_ED)  AS PATIENT_ARRIVED_IN_ED,
              max(PATIENT_ADMITTED)  AS PATIENT_ADMITTED,
              max(PATIENT_ADMITTED_BY)  AS PATIENT_ADMITTED_BY,
              max(PATIENT_ADMITTED_TITLE)  AS PATIENT_ADMITTED_TITLE,
              max(PATIENT_ADMITTED_TO)  AS PATIENT_ADMITTED_TO,
              max(TRIAGE_COMPLETED)  AS TRIAGE_COMPLETED,
              max(TRIAGE_COMPLETED_BY)  AS TRIAGE_COMPLETED_BY,
              max(ASSIGN_PHYSICIAN)  AS ASSIGN_PHYSICIAN,
              max(ED_NOTE_FILED)  AS ED_NOTE_FILED,
              max(FIRST_PROVIDER_CONTACT)  AS FIRST_PROVIDER_CONTACT,
              max(DECISION_TO_ED_OBSER)  AS DECISION_TO_ED_OBSER,
              max (SHORT_TERM_STAY) as SHORT_TERM_STAY,
              max(SHORT_TERM_STAY_TIMESTAMP) as SHORT_TERM_STAY_TIMESTAMP,
              max(TRANS_TO_OBSER_TIMESTAMP) as TRANS_TO_OBSER_TIMESTAMP,
              sysdate as RUN_DATE --- YC 6/1/2018 added for control
              ,max(ED_IP_BED_ASSIGNED) as ED_IP_BED_ASSIGNED ---YC 6/13/2018 SR#2494939
              ,max(ARRIVAL_department_id) as ARRIVAL_department_id  -- 10/10/2019 YC define arrival dept by event
        from (
           select eei.pat_enc_csn_id,peh.hsp_account_id,
              max(eei.update_date) over (partition by eei.pat_enc_csn_id ) AS update_date,
              CASE WHEN EEI.EVENT_TYPE = '205' THEN eei.event_time    END AS TRIAGE_STARTED,
              CASE WHEN EEI.EVENT_TYPE = '16022281' THEN eei.event_time    END AS IP_BED_REQUESTED,
              CASE WHEN EEI.EVENT_TYPE = '95' THEN eei.event_time    END AS PATIENT_DEPARTED_FROM_ED,
              CASE WHEN EEI.EVENT_TYPE = '50' THEN eei.event_time    END AS PATIENT_ARRIVED_IN_ED,
              CASE WHEN EEI.EVENT_TYPE = '65' AND eei.adt_event_id is not null then eei.event_time END AS PATIENT_ADMITTED,
              CASE WHEN EEI.EVENT_TYPE = '65' AND eei.adt_event_id IS NOT NULL THEN emp.name  END AS PATIENT_ADMITTED_BY,
              CASE WHEN EEI.EVENT_TYPE = '65' AND eei.adt_event_id IS NOT NULL THEN ser.clinician_title END AS PATIENT_ADMITTED_TITLE,
              CASE WHEN EEI.EVENT_TYPE = '65' AND eei.adt_event_id IS NOT NULL THEN dep.mpi_id  END AS PATIENT_ADMITTED_TO,
              CASE WHEN EEI.EVENT_TYPE = '210' THEN eei.event_time    END AS TRIAGE_COMPLETED,
              CASE WHEN EEI.EVENT_TYPE = '210' THEN EMP.NAME    END AS TRIAGE_COMPLETED_BY,
              CASE WHEN eei.event_type = '16011103' THEN eei.event_time    END AS ASSIGN_PHYSICIAN,
              CASE WHEN eei.event_type = '500' THEN eei.event_time    END AS ED_NOTE_FILED,
              CASE WHEN eei.event_type = '16011103' THEN eei.event_time    END AS FIRST_PROVIDER_CONTACT,
             min( CASE  WHEN eei.event_type in('160224', '1600000062')  THEN eei.event_time END)
                  over (partition by eei.pat_enc_csn_id ) AS DECISION_TO_ED_OBSER,
            CASE WHEN eei.event_type = '160225' THEN 'Y'    END AS SHORT_TERM_STAY ,
              ---12/27/2017 YC by Antony's request -- SR# 2421291
            CASE WHEN EEI.EVENT_TYPE = '160225' THEN eei.event_time  END AS SHORT_TERM_STAY_TIMESTAMP,
            CASE WHEN EEI.EVENT_TYPE = '1600000060' THEN eei.event_time  END AS TRANS_TO_OBSER_TIMESTAMP,
            min( CASE  WHEN eei.event_type in('236', '16023101')  THEN eei.event_time END)
                  over (partition by eei.pat_enc_csn_id ) AS ED_IP_BED_ASSIGNED
            ,CASE WHEN EEI.EVENT_TYPE = '50' THEN EVENT_DEPT_ID    END AS ARRIVAL_department_id
            from (
              select epi.pat_enc_csn_id
                --,epi.update_date
                ,ed_updates.CSA_UPDATE_DATE update_date -- 5/4/2020 YC per Jackey's recomendation
                ,epi.items_edited_time,epi.pat_id
                ,row_number() over (partition by epi.pat_enc_csn_id,event_type order by eei.event_time,eei.adt_event_id) rn -- YC 6/4/2018 added ,eei.adt_event_id - otherwise may be sorted by the empty adt_event first
                -- ,EEI.*
                ,EEI.ADT_EVENT_ID ,EEI.EVENT_TIME ,EEI.EVENT_TYPE ,EEI.EVENT_USER_ID ,EEI.EVENT_DEPT_ID -- Apr 30, jho

                  from ed_iev_PAT_info epi
                  join ed_iev_event_info eei  ON eei.event_id=epi.event_id
                  join ed_updates on ed_updates.pat_enc_csn_id=epi.pat_enc_csn_id -- YC 5/4/21 limited by updated csn
                where eei.event_type      IN ('50','65','95','205','210','16022281','500','16011103','160224','1600000062'
                ,'160225'    ---    S6/8/2017 R #2299042 Short Term Stay Patient
                ,'1600000060'--- 12/27/2017 per Antory's request - Patient transferred to ED Obs -- SR# 2421291
                ,'236'    -- ED BED ASSIGNED 6/13/2018 SR#2494939
                ,'16023101'    --ED IP BED ASSIGNED
                )
                AND eei.event_status_c  IS NULL
             -- YC 5/4/21 limited by updated csn   AND EPI.UPDATE_DATE >= START_DT -- FILTER DATA; NO NEED FOR BETWEEN AS END_DT = TRUNC(SYSDATE) -- APR 30, JHO
                ----and trunc(eei.update_date) between start_dt and end_dt ----- YC 6/1/2018 for some reason it makes a big difference to filter dates - but not at the end of query
                ----and epi.pat_enc_csn_id in (704093404,703886494)
                ) eei
              join pat_enc_hsp peh on peh.pat_enc_csn_id = eei.pat_enc_csn_id
              left outer JOIN clarity_adt adt  ON eei.adt_event_id = adt.event_id
              LEFT OUTER JOIN clarity_emp emp  ON eei.event_user_id = emp.user_id
              LEFT OUTER JOIN clarity_ser ser  ON emp.prov_id = ser.prov_id
              LEFT OUTER JOIN cl_dep_id dep  ON adt.department_id   = dep.department_id  AND dep.mpi_id_type_id = 36
            where rn=1)
      --where 5/4/21 YC limited by -- trunc(update_date) between start_dt and end_dt
      --      UPDATE_DATE >= START_DT -- Filter data; no need for between as end_dt = trunc(sysdate) -- Apr 30, jho
      group by pat_enc_csn_id,update_date,hsp_account_id ;
      commit;
end if;
clarity.NYU_CLARITY_LOG_PKG.logMsg( 'REPORTADMIN.NYU_V_ED_SCPM', 'REPORTADMIN.ED_TMP', 'INFO', 'DONE', 'INSERT INTO ... SELECT FROM ... ');

-- execute immediate 'Truncate table ED_ORD_TMP';

--execute immediate 'CREATE GLOBAL TEMPORARY TABLE NYUGTT_ED_ORD_TMP ON COMMIT PRESERVE ROWS as
insert /*+ APPEND PARALLEL(8) ENABLE_PARALLEL_DML */ into NYUGT_ED_ORD_TMP
select    pp.pat_enc_csn_id
          ,pp.order_proc_id
          ,pp.proc_id
          ,pp.description --- YC 10/30/2015 make it max - there could be both orders at the same time
          ,pp.order_time
          ,pp.order_type_c
       --   ,min(pp.order_time) over (partition by pp.PAT_ENC_CSN_ID) min_order_time
       --   ,max(pp.order_time) over (partition by pp.PAT_ENC_CSN_ID) max_order_time
        FROM ORDER_METRICS m
        JOIN  order_proc pp ON pp.order_proc_id  =m.order_id
        join NYUGT_ED_TMP t ON pp.pat_enc_csn_id=t.pat_enc_csn_id
          where (pp.order_status_c is null or pp.order_status_c<>4) and (pp.proc_id in (233062,252588 ---- order for PLACE_IN_ED_OBSERVATION
                                      ,60311 ---- order for ERS_ADMIT_ORDER
                                      ,377206 --ERS PATIENT MOVEMENT -- YC 3/14/2017 Request #2278662
                                      )
                                     --- AND pp.order_status_c IS NULL)
                 or  pp.order_type_c   =49 )-- for Discharge orders
;
COMMIT;
clarity.NYU_CLARITY_LOG_PKG.logMsg( 'REPORTADMIN.NYU_V_ED_SCPM', 'REPORTADMIN.ED_ORD_TMP', 'INFO', 'DONE', 'INSERT INTO ... SELECT FROM ... ');

-- execute immediate 'Truncate table ED_ADT_TMP';
select count(*) into cnt from all_objects oo where oo.OBJECT_NAME='IDX_ED_ADT';
       if cnt=1 then execute immediate 'drop index IDX_ED_ADT'; end if;
select count(*) into cnt from all_objects oo where oo.OBJECT_NAME='IDX_ED_ADT_U';
       if cnt=1 then execute immediate 'drop index IDX_ED_ADT_U'; end if;

insert /*+ APPEND PARALLEL(8) ENABLE_PARALLEL_DML */ into NYUGT_ED_ADT_TMP
SELECT adt.EVENT_ID,adt.pat_enc_csn_id,adt.pat_id,adt.effective_time
    ,adt.event_type_c,adt.event_subtype_c
    ,adt.FROM_BASE_CLASS_C,adt.TO_BASE_CLASS_C
    ,adt.DEPARTMENT_ID
    ,adt.room_id
    ,adt.bed_csn_id
    ,adt.room_csn_id
    ,adt.pat_class_c
    ,adt.PAT_SERVICE_C
    ,adt.BASE_PAT_CLASS_C
    ,adt.FIRST_IP_IN_IP_YN
    ,adt.SEQ_NUM_IN_ENC
    FROM clarity_adt adt
    join NYUGT_ED_TMP t on t.pat_enc_csn_id=ADT.PAT_ENC_CSN_ID -- YC 1/28/2019 filter by tmp - to speed up
    where adt.EVENT_SUBTYPE_C   <> 2;
commit;
clarity.NYU_CLARITY_LOG_PKG.logMsg( 'REPORTADMIN.NYU_V_ED_SCPM', 'REPORTADMIN.ED_ADT_TMP', 'INFO', 'DONE', 'INSERT INTO ... SELECT FROM ... ');

-- execute immediate 'create unique index IDX_ED_ADT_U on ED_ADT_TMP (EVENT_ID)';
-- execute immediate 'create index IDX_ED_ADT on ED_ADT_TMP (PAT_ENC_CSN_ID)';

execute immediate 'Truncate table SCPM_ED_YC';

/*s_date := start_dt;
e_date := start_dt-1 ;--- cycle is 1 quarter

for i in 1..Qcnt LOOP

  s_date :=e_date+1;
  if i=Qcnt then
    e_date:= end_dt;
   else
    e_date := s_date+90 ;---
  end if;
*/
insert /*+ APPEND PARALLEL(8) ENABLE_PARALLEL_DML */  into SCPM_ED_YC
with FLO as (
  select * from
  (select m.meas_value,m.recorded_time,t.pat_enc_csn_id
  ,row_number() over (partition by rec.pat_id,rec.inpatient_data_id order by m.recorded_time asc) rn
 --- ,t.*
  from NYUGT_ED_TMP t
  join pat_enc pe on pe.pat_enc_csn_id =t.pat_enc_csn_id
  join IP_FLWSHT_REC rec on pe.pat_id=rec.pat_id and pe.inpatient_data_id=rec.inpatient_data_id
  join IP_FLWSHT_MEAS m on m.fsd_id=rec.fsd_id and m.flo_meas_id='1600005401' --NYU R ED INITIAL ESI
  ) where rn=1
)
SELECT DISTINCT
    P.PAT_MRN_ID                                                                                                  AS "MRN",
    P.BIRTH_DATE                                                                                                           AS "PATIENT_DOB", --Added 01/30/12 as per Jill Pinnella PMO
--    TRUNC ((TO_NUMBER (TO_CHAR (HAR.ADM_DATE_TIME, 'YYYYMMDD')) - TO_NUMBER (TO_CHAR (P.BIRTH_DATE, 'YYYYMMDD'))) / 10000) AS "PATIENT_AGE", --Added 01/30/12 as per Jill Pinnella PMO
 --YC 7/20/2017 SR#2360378
         case when months_between(trunc(HAR.ADM_DATE_TIME),trunc(p.BIRTH_DATE))<0  then 0 -- YC 8/3/2017 to avoid situation when NB admission is prior to BD
          when floor(months_between(HAR.ADM_DATE_TIME,p.BIRTH_DATE)/12)=0 then
            round(months_between(HAR.ADM_DATE_TIME,p.BIRTH_DATE)/12,2)
            else floor(months_between(HAR.ADM_DATE_TIME,p.BIRTH_DATE)/12) end AS "PATIENT_AGE",
    DEP3.MPI_ID                                                                                                            AS "DEPARTMENT",
    DEP4.MPI_ID                                                                                                            AS "DEPARTMENT_ADM",
    nvl(HAR.ADM_DATE_TIME ,peh.hosp_admsn_time)   AS "VISIT_DATE_TIME", -- YC 7/31/2018 -- to avoid missing dates
    HAR3.IP_ADMIT_DATE_TIME                                                                                                AS "ADMIT_DATE_TIME",
    HAR.HSP_ACCOUNT_NAME                                                                                                   AS "PATIENT_NAME",
    CASE
      WHEN HAR.PRIMARY_PAYOR_ID IS NULL
      THEN ZCFC2.NAME
      WHEN HAR.PRIMARY_PAYOR_ID IS NOT NULL
      THEN
        CASE
          WHEN EPM.FINANCIAL_CLASS IS NULL
          THEN ZCFC2.NAME
          ELSE ZCFC.NAME
        END
    END                   AS "FIN_CLASS",
    EPM.PAYOR_NAME        AS "PAYOR_NAME",
    EPP.BENEFIT_PLAN_NAME AS "PLAN_NAME",
--    EPP.PRODUCT_TYPE      AS "INSURANCE_PRODUCT",
    zpt.name AS "INSURANCE_PRODUCT", ---YC 3/21/2016
    EPP.RPT_GRP_ONE       AS "PLAN_RPT_GRP_ONE",
    HLB2.XR_HX_XPCTD_AMT  AS "EXPECTED_REIMBUSEMENT",
    HAR.HSP_ACCOUNT_ID    AS "ACCOUNT_NUMBER",
    ZCHAR.NAME            AS "ENCOUNTER_STATUS",
    ZCEPT.NAME            AS "DISCH_DISPOSITION",
    ZCEPT.ABBR            AS "DISC_DISP_ABBR",
    /*3 Send to OR 4 Admit
    4 Admit         9 AMA
    8 Transfer to Procedure Area 12 Expired
    9 AMA 11 Send to L
    11 Send to L 8 Transfer to Procedure Area
    */
    ---temporary conversion:
    ---ZCED.ED_DISPOSITION_C,
    CASE
      WHEN HAR.ADM_DATE_TIME>=to_date('11/09/2012','mm/dd/yyyy')
      THEN ZCED.NAME
      ELSE DECODE(ZCED.ED_DISPOSITION_C,3,'Admit',4,'AMA',8,'Expired',9,'Send to L',11,'Transfer to Procedure Area',ZCED.NAME)
    END AS "ED_DISCH_DISPOSITION",
    CASE
      WHEN HAR.ADM_DATE_TIME>=to_date('11/09/2012','mm/dd/yyyy')
      THEN ZCED.ABBR
      ELSE DECODE(ZCED.ED_DISPOSITION_C,'3','Admit','4','AMA','8','Expired','9','Send to L','11','Transfer to Procedure Area',ZCED.ABBR)
    END AS "ED_DISC_DISP_ABBR",
    CE.REF_BILL_CODE   AS "ICD9",            --Added 08/03/11--But switched to .REF_BILL_CODE from HISTORICAL_REF_CODE 03/08/12
    CE.DX_NAME         AS "ICD9_DESCRIPTION",--Added 08/03/11--
    ZCHAR1.NAME        AS "ACCOUNT_STATUS",
    HAR.TOT_CHGS       AS "TOTAL_CHARGES",
    PEH.PAT_ENC_CSN_ID AS "CSN",
    ZCHAR2.NAME        AS "PATIENT_CLASS",
    ZCPATCLS.NAME      AS "ENC_FINAL_PAT_CLASS",--Added 01/30/12 as per PMO
    --zpc5.name FIRST_PAT_CLASS, --- YC added 5/2/2013 per Glenn
   -- HAR.EXTRACT_DATETIME AS "UPDATE_DATE",
   haru.inst_of_update_dttm  AS "UPDATE_DATE",
   CASE
      WHEN ADT2.TO_BASE_CLASS_C IS NULL      THEN 'N/A'
      WHEN (ADT2.TO_BASE_CLASS_C = 0      AND ADT2.EVENT_TYPE_C      = 2)      THEN 'Discharged'
      ELSE ZCRBC.NAME
    END                   AS "PATIENT_AFTER_ED",
    PEH.ADMISSION_PROV_ID AS "ADMITTING_PROV_ID",
    HAR.TOT_PMTS          AS "TOTAL_PAYMENTS",
    HAR.TOT_ACCT_BAL      AS "TOTAL_ACCT_BAL",
/*******************************/
    TRIAGE_STARTED,
    IP_BED_REQUESTED,
    PATIENT_DEPARTED_FROM_ED,
    adt6.event_time CONVERT_TO_OBSERV,
    PATIENT_ARRIVED_IN_ED,
    PATIENT_ADMITTED,
    PATIENT_ADMITTED_BY,
    PATIENT_ADMITTED_TITLE,
    PATIENT_ADMITTED_TO,
    TRIAGE_COMPLETED,
    TRIAGE_COMPLETED_BY,
    ASSIGN_PHYSICIAN,
    ED_NOTE_FILED,
 /*******************************/
   --MIN(case when eei.event_type in (16011103, 500) then TO_CHAR(eei.event_time,'mm/dd/yyyy HH24:MI') END) AS ASSIGN_ED_NOTE_COMB,
 -- 12/4/2019   za.name AS ACUITY,
    flo.meas_value AS ACUITY,
    zam.name method_of_arrv ,
    cea.ref_bill_code ADMIT_DX_CODE ,
    cea.dx_name ADMIT_DX_NAME ,
-- YC 3/17/2017    CE_alt.REF_BILL_CODE AS "ICD10" ,
    icd10.code AS "ICD10" ,
    CE.DX_NAME       AS "ICD10_DESCRIPTION" --Added 11/08/13--
    ,    P.ZIP --- YC 5/22/2014 added by Josefina's Request# 2008194
    ,    zps.ABBR ADM_SERVICE --- YC 8/15/2014 added per Josefina's request
    ,    CEe.ref_bill_code IMPRESSION_DX_CODE --- YC 8/15/2014 added per Data Core request
    ,    CEe.dx_name IMPRESSION_DX_NAME ,
    ARVDEP.DEPARTMENT_NAME ARRIVAL_DEPT ,
    serl.prov_id first_ed_prov_id --- YC 2/5/2015 #2053889
    ,    serl.prov_name first_ed_prov_name ,
    EPP.BENEFIT_PLAN_ID PLAN_ID,
-- 1/30/2018 YC   pp.order_time         AS order_date,
--  1/30/2018 YC    pp.description        AS Place_in_ed_observation,
    min(case when proc_id in (233062,252588)  then ord.order_time end ) over (partition by peh.pat_enc_csn_id) AS order_date,
    max(case when proc_id in (233062,252588) then ord.description end ) over (partition by peh.pat_enc_csn_id) AS Place_in_ed_observation,
/*******************************/
     FIRST_PROVIDER_CONTACT,
/*******************************/
    race.name             AS patient_race,
    gr.name               AS ethnicity,
  --  pppp.order_time       AS ERS_ADM_order_date,
  --  pppp.description      AS ERS_ADMIT_ORDER,
    min(case when proc_id in (60311, 377206 ) then ord.order_time end ) over (partition by peh.pat_enc_csn_id) AS ERS_ADM_order_date,
    max(case when proc_id in (60311, 377206 ) then ord.description end ) over (partition by peh.pat_enc_csn_id) AS ERS_ADMIT_ORDER,
    adt0.effective_time   AS TRANSFER_TO_THGOF,
 --   ord5.order_time       AS DISCH_order_date
    max(case when ord.order_type_c   =49 then ord.order_time end ) over (partition by peh.pat_enc_csn_id) AS DISCH_order_date
    ,ztr.name HOSPITAL_TRANSFERRED_FROM ---YC incident #2293538 10/19/2015
    ,xtr.LOC_ID
    ,CASE
                 WHEN xtr.LOC_ID = 10530
                 THEN
                    'HJD-P'
                 WHEN (xtr.LOC_ID NOT IN (10530, 10500, 10510,10800,1084001) ---YC 5/8/2019 ) -- YC 3/21/2016 added Lutheran
                       OR xtr.LOC_ID IS NULL)
                 THEN
                    EAF.LOCATION_ABBR
                 ELSE
                    UPPER (xtr.LOC_ABBR)
              END
                 AS "FACILITY"
/*******************************/
    ,DECISION_TO_ED_OBSER
/*******************************/
,room.room_name first_ip_room
,bed.bed_label first_ip_bed
,adt3.effective_time first_ip_time
,ecc.er_complaint chief_complaint -- YC 10/7/2016 Request #2257330 - "please add Discharged Chief Complaint to ED data in EDW"
,ZCAS.NAME admit_source
,HAR3.Related_Har_Id
,SHORT_TERM_STAY
,ARVDEP.DEPARTMENT_ID ARRIVAL_DEPT_ID --- YC 9/22/2017 SR#2382644
  ,PEH.DISCH_DISP_C DISCH_DISP_ID --SR#2411219 YC 11/29/2017:
  ,HAR.PRIM_SVC_HA_C HSP_SVC_ID
  ,zps.HOSP_SERV_C SVC_ID
,zPATs.Hosp_Serv_c PAT_SERV_ID
,zPATs.Name PATIENT_SERVICE
,har.DISCH_DESTIN_HA_C
--- SR# 2421291 YC 12/27/2017
,short_term_stay_timestamp
,trans_to_obser_timestamp
,xtr.parent_loc_id
,xtr.parent_loc_name
,xtr.parent_loc_abbr
,ED_IP_BED_ASSIGNED
,g35.name  AS REPORT_GROUP_35 -- YC 6/19/2018 SR#2498763
,ARVDEP.rpt_grp_trtyfive_c
,trg.meas_value TRIAGE_DEST --YC 7/18/2019 SR# 2658011
--select count(*)
 FROM NYUGT_ED_TMP ED_TMP
---  INNER JOIN CLARITY_ADT ADT  ON PEH.PAT_ENC_CSN_ID = ADT.PAT_ENC_CSN_ID
  join PAT_ENC_HSP PEH on ED_TMP.PAT_ENC_CSN_ID=peh.pat_enc_csn_id
  INNER JOIN PATIENT P  ON PEH.PAT_ID = P.PAT_ID and p.pat_name not like 'ZZZ%' -- YC 6/20/2018
  JOIN HSP_ACCOUNT HAR        ON PEH.HSP_ACCOUNT_ID = HAR.HSP_ACCOUNT_ID
  JOIN HSP_ACCOUNT_3 HAR3       ON HAR.HSP_ACCOUNT_ID = HAR3.HSP_ACCOUNT_ID
--- 12/6/2017 YC add PEH pat service per Alice request
  LEFT OUTER JOIN ZC_PAT_SERVICE zPATs on ZPATs.Hosp_Serv_c=peh.Hosp_Serv_c
 --- YC 12/4/2019
  left join FLO on flo.pat_enc_csn_id=peh.pat_enc_csn_id
    --------------YC 2/5/2015 FIRST  ED Attending:
  LEFT OUTER JOIN
      (SELECT hap.prov_id,
        hap.pat_enc_csn_id,
        hap.attend_from_date,
        row_number() over (partition BY hap.pat_enc_csn_id order by hap.attend_from_date ASC) rn
      FROM HSP_ATND_PROV hap
      join NYUGT_ED_TMP t on t.pat_enc_csn_id=hap.pat_enc_csn_id
      WHERE hap.ed_attend_yn='Y'
          ---  and exists (select 1 from ED_TMP t where t.pat_enc_csn_id=hap.pat_enc_csn_id)
    --  )
   -- WHERE  rn=1
     )hap  ON peh.pat_enc_csn_id=hap.pat_enc_csn_id and  hap.rn=1
  LEFT OUTER JOIN CLARITY_SER serl  ON serl.prov_id=hap.prov_id

  LEFT OUTER JOIN NYUGT_ED_ADT_TMP ADTADMIT  ON peh.pat_enc_csn_id=ADTADMIT.PAT_ENC_CSN_ID and PEH.ADM_EVENT_ID = ADTADMIT.EVENT_ID
       AND ADTADMIT.EVENT_SUBTYPE_C <> 2 --Cancelled
       AND ADTADMIT.EVENT_TYPE_C     = 1 --Admission

  LEFT OUTER JOIN CLARITY_DEP ADMDEP  ON ADTADMIT.DEPARTMENT_ID = ADMDEP.DEPARTMENT_ID
  LEFT OUTER JOIN CLARITY_DEP ARVDEP  ON ARVDEP.DEPARTMENT_ID = coalesce(ED_TMP.ARRIVAL_DEPT_ID,ADTADMIT.DEPARTMENT_ID,PEH.DEPARTMENT_ID)  -- YC 10/10/2019
  left outer join ZC_DEP_RPT_GRP_35 g35 on coalesce(ED_TMP.ARRIVAL_DEPT_ID,ADTADMIT.DEPARTMENT_ID,PEH.DEPARTMENT_ID)=g35.dep_rpt_grp_35_c -- YC 6/19/2018 SR#2498763

        --YC 6/13/2017 upgrade
  LEFT OUTER JOIN ZC_DISCH_DESTIN_HA zdd on zdd.disch_destin_ha_c=har.DISCH_DESTIN_HA_C
  left outer join HSP_ACCT_LAST_UPDATE haru on haru.hsp_account_id= har.HSP_ACCOUNT_ID
  LEFT OUTER JOIN ZC_TRANSFER_SRC_HA ztr on ztr.TRANSFER_SRC_HA_C =HAR.TRANSFER_SRC_HA_C ---YC incident #2293538 10/19/2015
  LEFT OUTER JOIN NYU_V_FAC_STRUCT_X xtr ON coalesce(ED_TMP.ARRIVAL_DEPT_ID,ADTADMIT.DEPARTMENT_ID,PEH.DEPARTMENT_ID) = xtr.DEP_ID -- YC 10/10/2019 first look for arrival dept
  LEFT OUTER JOIN CLARITY_LOC EAF    ON HAR.LOC_ID = EAF.LOC_ID
-------------------------YC 05/2/2017 by SR#2300102
  LEFT OUTER JOIN ZC_ADM_SOURCE ZCAS  ON PEH.ADMIT_SOURCE_C = ZCAS.ADMIT_SOURCE_C
-------
--YC 7/18/2019 SR# 2658011 add R ED TRIAGE DESTINATION
  left join (select FR.INPATIENT_DATA_ID,fm.meas_value
       ,row_number() over (partition by FR.INPATIENT_DATA_ID order by fm.recorded_time desc) rn
       FROM IP_FLWSHT_MEAS FM
          INNER JOIN IP_FLWSHT_REC FR ON FM.FSD_ID = FR.FSD_ID
          INNER JOIN IP_FLO_GP_DATA GP ON FM.FLO_MEAS_ID = GP.FLO_MEAS_ID
             where fm.flo_meas_id = 16029
             AND ENTRY_TIME >= (start_dt - 30) -- -- !!!!! JHO:  should this subquery be more carefull????, or give it few more days
             )trg ON trg.INPATIENT_DATA_ID = peh.INPATIENT_DATA_ID and trg.rn=1
  LEFT OUTER JOIN CLARITY_DEP DEP  ON PEH.DEPARTMENT_ID = DEP.DEPARTMENT_ID
  LEFT OUTER JOIN CLARITY_EPM EPM  ON HAR.PRIMARY_PAYOR_ID = EPM.PAYOR_ID
  LEFT OUTER JOIN CLARITY_EPP EPP  ON HAR.PRIMARY_PLAN_ID = EPP.BENEFIT_PLAN_ID
  left outer join CLARITY_EPP_2 EPP2 on epp2.benefit_plan_id= EPP.BENEFIT_PLAN_ID -----YC 3/21/2016 for new Epic version
  left outer join zc_prod_type zpt on zpt.prod_type_c=epp2.prod_type_c ---YC 3/21/2016 for new Epic version
  LEFT OUTER JOIN ZC_ARRIV_MEANS zam  ON peh.MEANS_OF_ARRV_C =zam.means_of_arrv_c
  LEFT OUTER JOIN (
          -- !!! JHO: Confusing Logic ?????
          -- !!! JHO: Missing HSP_ACCOUNT_ID on where!!!
        select *
        from
          -- (SELECT INSURANCE_BUCKET_ID,HAR1.HSP_ACCOUNT_ID
          -- FROM HSP_ACCT_INS_BKTS HAR1
           -- where HAR1.LINE =
            -- (SELECT MIN (HAR1X.LINE)
            -- FROM HSP_ACCT_INS_BKTS HAR1X
            -- join REPORTADMIN.NYUGT_ED_TMP t on t.hsp_account_id=HAR1X.hsp_account_id -- YC 1/28/2019 filter by tmp - to speed up
            -- WHERE HAR1.HSP_ACCOUNT_ID = HAR1X.HSP_ACCOUNT_ID
            -- )
          -- ) HAR1
          (SELECT INSURANCE_BUCKET_ID, HSP_ACCOUNT_ID
          FROM (
             SELECT INSURANCE_BUCKET_ID, HAR1.HSP_ACCOUNT_ID,
                ROW_NUMBER() OVER(PARTITION BY HAR1.HSP_ACCOUNT_ID ORDER BY LINE) AS RN
             FROM HSP_ACCT_INS_BKTS HAR1
             JOIN NYUGT_ED_TMP ED_TMP ON ED_TMP.HSP_ACCOUNT_ID=HAR1.HSP_ACCOUNT_ID
             ) WHERE RN = 1
          ) HAR1
        JOIN
          -- (SELECT BUCKET_ID,XR_HX_XPCTD_AMT
                  -- FROM HSP_BKT_XPTRBMT_HX HLB2
                  -- WHERE HLB2.LINE =
            -- (SELECT MIN (HLB2X.LINE)
            -- FROM HSP_BKT_XPTRBMT_HX HLB2X
            -- WHERE HLB2.BUCKET_ID = HLB2X.BUCKET_ID
            -- )
          -- ) HLB2  ON HAR1.INSURANCE_BUCKET_ID = HLB2.BUCKET_ID
          (SELECT BUCKET_ID,XR_HX_XPCTD_AMT FROM
             (SELECT
                BUCKET_ID, XR_HX_XPCTD_AMT, ROW_NUMBER() OVER(PARTITION BY HLB2.BUCKET_ID ORDER BY LINE) AS RN
             FROM
                HSP_BKT_XPTRBMT_HX HLB2
                JOIN NYUGT_ED_TMP ED_TMP ON ED_TMP.HSP_ACCOUNT_ID = HLB2.HSP_ACCOUNT_ID
             ) WHERE RN = 1
          ) HLB2 ON HAR1.INSURANCE_BUCKET_ID = HLB2.BUCKET_ID
          ) HLB2 ON HAR.HSP_ACCOUNT_ID = HLB2.HSP_ACCOUNT_ID
  LEFT OUTER JOIN
    (SELECT ADT2.PAT_ENC_CSN_ID,adt2.TO_BASE_CLASS_C,adt2.EVENT_TYPE_C
    FROM NYUGT_ED_ADT_TMP ADT2
   -- join REPORTADMIN.NYUGT_ED_TMP t on t.pat_enc_csn_id=ADT2.PAT_ENC_CSN_ID -- YC 1/28/2019 filter by tmp - to speed up
    where (ADT2.FROM_BASE_CLASS_C = 3
    AND ADT2.TO_BASE_CLASS_C     <> 3)
    AND ADT2.EVENT_SUBTYPE_C     <> 2
    AND ADT2.SEQ_NUM_IN_ENC       =
      (SELECT MIN(ADT2X.SEQ_NUM_IN_ENC)
      FROM NYUGT_ED_ADT_TMP ADT2X
      WHERE ADT2.PAT_ENC_CSN_ID    = ADT2X.PAT_ENC_CSN_ID
      AND (ADT2X.FROM_BASE_CLASS_C = 3
      AND ADT2X.TO_BASE_CLASS_C   <> 3)
      AND ADT2X.EVENT_SUBTYPE_C   <> 2
      )
    ) ADT2  ON PEH.PAT_ENC_CSN_ID = ADT2.PAT_ENC_CSN_ID
  LEFT OUTER JOIN NYUGT_ED_ADT_TMP ADT3  ON peh.PAT_ENC_CSN_ID     = ADT3.PAT_ENC_CSN_ID
             AND ADT3.FIRST_IP_IN_IP_YN = 'Y'
             AND ADT3.BASE_PAT_CLASS_C  = 1 --Inpatient
  LEFT OUTER JOIN ZC_PAT_SERVICE zps  ON zps.hosp_serv_c = ADT3.PAT_SERVICE_C
  left outer join clarity_bed bed on adt3.bed_csn_id=bed.bed_csn_id
  left outer join clarity_rom room on adt3.room_csn_id=room.room_csn_id
    ----timing when patient becomes 'observation'
  LEFT OUTER JOIN
    (SELECT MIN(EFFECTIVE_TIME) event_time ,
      adt6.pat_enc_csn_id
    FROM NYUGT_ED_ADT_TMP adt6
   -- join REPORTADMIN.NYUGT_ED_TMP t on t.pat_enc_csn_id=ADT6.PAT_ENC_CSN_ID -- YC 1/28/2019 filter by tmp - to speed up
    where adt6.EVENT_SUBTYPE_C <> 2
          AND adt6.pat_class_c        ='104'
    GROUP BY adt6.pat_enc_csn_id
    ) adt6  ON PEH.PAT_ENC_CSN_ID = ADT6.PAT_ENC_CSN_ID
    --Final Coded DX------------start
  LEFT OUTER JOIN HSP_ACCT_DX_LIST HARDX  ON HAR.HSP_ACCOUNT_ID = HARDX.HSP_ACCOUNT_ID  AND HARDX.LINE        = 1
  LEFT OUTER JOIN CLARITY_EDG CE  ON HARDX.DX_ID = CE.DX_ID
    ---YC ICD10 11/8/2013
--  LEFT OUTER JOIN HSP_ACCT_FINDX_ALT altdx  ON HARDX.HSP_ACCOUNT_ID=altdx.acct_id  AND altdx.line         =1
--  LEFT OUTER JOIN CLARITY_EDG CE_ALT  ON altdx.fin_dx_alt_id = CE_ALT.DX_ID
  left outer join EDG_CURRENT_ICD10 ICD10 on hardx.dx_id=icd10.dx_id and hardx.line=1 and icd10.line=1 -- YC 3/17/2017
    --Final Coded DX------------end
    ----Admitting---
  LEFT OUTER JOIN HSP_ADMIT_DIAG HAD  ON PEH.PAT_ENC_CSN_ID = HAD.PAT_ENC_CSN_ID  AND HAD.LINE          = 1
  LEFT OUTER JOIN CLARITY_EDG CEa  ON HAD.DX_ID = CEa.DX_ID --- and cea.ref_bill_code_set_c =1
    --------------Admitting---------end
  left outer join PAT_ENC_ER_COMPLNT ecc on ecc.pat_enc_csn_id = peh.pat_enc_csn_id and ecc.line = 1
    ----ED Impression
  LEFT OUTER JOIN
    (SELECT pedx.DX_ID,
      pedx.PAT_ENC_CSN_ID
    FROM PAT_ENC_DX pedx
    join NYUGT_ED_TMP t on t.pat_enc_csn_id=pedx.PAT_ENC_CSN_ID -- YC 1/28/2019 filter by tmp - to speed up
    where pedx.dx_ed_yn='Y'
    AND pedx.LINE  =
      (SELECT MIN(line)
      FROM PAT_ENC_DX pedx2
      WHERE pedx2.dx_ed_yn     ='Y'
      AND pedx2.PAT_ENC_CSN_ID = pedx.PAT_ENC_CSN_ID
      GROUP BY PAT_ENC_CSN_ID
      )
    ) pedx  ON peh.PAT_ENC_CSN_ID = pedx.PAT_ENC_CSN_ID
  LEFT OUTER JOIN CLARITY_EDG CEe  ON pedx.DX_ID = CEe.DX_ID --- and CEe.ref_bill_code_set_c =1
    -----
  LEFT OUTER JOIN ZC_MC_PAT_STATUS ZCHAR  ON HAR.PATIENT_STATUS_C = ZCHAR.PAT_STATUS_C
  LEFT OUTER JOIN ZC_ACCT_BILLSTS_HA ZCHAR1  ON HAR.ACCT_BILLSTS_HA_C = ZCHAR1.ACCT_BILLSTS_HA_C
  LEFT OUTER JOIN ZC_ACCT_BASECLS_HA ZCHAR2  ON HAR.ACCT_BASECLS_HA_C = ZCHAR2.ACCT_BASECLS_HA_C
  LEFT OUTER JOIN ZC_DISCH_DISP ZCEPT  ON PEH.DISCH_DISP_C = ZCEPT.DISCH_DISP_C
  LEFT OUTER JOIN ZC_REP_BASE_CLASS ZCRBC  ON ADT2.TO_BASE_CLASS_C = ZCRBC.INT_REP_BASE_CLS_C
  LEFT OUTER JOIN ZC_ED_DISPOSITION ZCED  ON PEH.ED_DISPOSITION_C = ZCED.ED_DISPOSITION_C
  LEFT OUTER JOIN ZC_FINANCIAL_CLASS ZCFC  ON EPM.FINANCIAL_CLASS = ZCFC.FINANCIAL_CLASS
  LEFT OUTER JOIN ZC_FIN_CLASS ZCFC2  ON HAR.ACCT_FIN_CLASS_C = ZCFC2.FIN_CLASS_C
  LEFT OUTER JOIN CL_DEP_ID DEP3  ON DEP.DEPARTMENT_ID = DEP3.DEPARTMENT_ID AND DEP3.MPI_ID_TYPE_ID = 36 --YC 9//1/2015
  LEFT OUTER JOIN CL_DEP_ID DEP4  ON ADT3.DEPARTMENT_ID = DEP4.DEPARTMENT_ID AND DEP4.MPI_ID_TYPE_ID = 36 --YC 9//1/2015
  LEFT OUTER JOIN ZC_PAT_CLASS ZCPATCLS  ON PEH.ADT_PAT_CLASS_C = ZCPATCLS.ADT_PAT_CLASS_C
 --1/28/2019 LEFT OUTER JOIN ZC_PAT_CLASS ZCPATCLS2  ON ADT.PAT_CLASS_C = ZCPATCLS2.ADT_PAT_CLASS_C
  LEFT OUTER JOIN ZC_ACUITY_LEVEL za  ON peH.ACUITY_LEVEL_C=za.acuity_level_c
    --added when added ED event info from Epic
  /*
  LEFT OUTER JOIN ed_iev_PAT_info epi  ON peh.pat_enc_csn_id=epi.pat_csn
  LEFT OUTER JOIN ed_iev_event_info eei  ON eei.event_id=epi.event_id --and eei.event_status_c is null
  LEFT OUTER JOIN clarity_adt adt4  ON eei.adt_event_id = adt4.event_id
  LEFT OUTER JOIN clarity_emp emp  ON eei.event_user_id = emp.user_id
  LEFT OUTER JOIN clarity_ser ser  ON emp.prov_id = ser.prov_id
  LEFT OUTER JOIN cl_dep_id dep5  ON adt4.department_id   = dep5.department_id  AND DEP5.MPI_ID_TYPE_ID = 36
*/
  LEFT OUTER JOIN patient_race aa  ON p.pat_id=aa.pat_id  AND aa.line=1
  LEFT OUTER JOIN zc_patient_race race  ON aa.patient_race_c=race.patient_race_c
  LEFT OUTER JOIN zc_ethnic_group gr  ON p.ethnic_group_c=gr.ethnic_group_c
  left join NYUGT_ED_ORD_TMP ord on peh.pat_enc_csn_id = ord.pat_enc_csn_id
/*  LEFT OUTER JOIN
    (SELECT max(pp.description) description, --- YC 10/30/2015 make it max - there could be both orders at the same time
          pp.order_time,
          pp.pat_enc_csn_id
        FROM order_proc pp
        JOIN ORDER_METRICS m   ON pp.order_proc_id  =m.order_id
        join REPORTADMIN.NYUGT_ED_TMP t on t.pat_enc_csn_id=pp.PAT_ENC_CSN_ID -- YC 1/28/2019 filter by tmp - to speed up
           where pp.order_time IN
          (SELECT MIN (proc0.order_time)
          FROM order_proc proc0
          WHERE pp.pat_enc_csn_id   =proc0.pat_enc_csn_id
          AND proc0.proc_id         in (233062,252588) ---- order for PLACE_IN_ED_OBSERVATION
          AND proc0.order_status_c IS NULL
          GROUP BY proc0.pat_enc_csn_id
          )
          AND pp.proc_id            in (233062,252588)
    group by pp.order_time,pp.pat_enc_csn_id
    )pp ON peh.pat_enc_csn_id = pp.pat_enc_csn_id

  LEFT OUTER JOIN
    (SELECT DISTINCT pppp.description,
      pppp.order_time,
      pppp.pat_enc_csn_id
    FROM order_proc pppp
    JOIN ORDER_METRICS m1    ON pppp.order_proc_id  =m1.order_id
    join REPORTADMIN.NYUGT_ED_TMP t on t.pat_enc_csn_id=pppp.PAT_ENC_CSN_ID -- YC 1/28/2019 filter by tmp - to speed up
    where pppp.order_time IN
      (SELECT MIN (proc1.order_time)
      FROM order_proc proc1
      WHERE pppp.pat_enc_csn_id =proc1.pat_enc_csn_id
      AND proc1.proc_id in (60311, ---- order for ERS_ADMIT_ORDER
                                377206 --ERS PATIENT MOVEMENT -- YC 3/14/2017 Request #2278662
                                )
      AND proc1.order_status_c IS NULL
      GROUP BY proc1.pat_enc_csn_id
      )
    AND pppp.proc_id  in (60311,377206)
    )pppp ON har.prim_enc_csn_id = pppp.pat_enc_csn_id
  LEFT OUTER JOIN ( ---YC 10/30 2015 take the max , since there still could be several
       select ord5.pat_enc_csn_id, max(order_time) order_time
              from order_proc ord5
              join REPORTADMIN.NYUGT_ED_TMP t on t.pat_enc_csn_id=ord5.PAT_ENC_CSN_ID -- YC 1/28/2019 filter by tmp - to speed up
              where ord5.order_type_c   =49 -- for Discharge orders
               AND ord5.order_status_c<>4
           group by ord5.pat_enc_csn_id
        ) ord5 ON peh.pat_enc_csn_id  =ord5.pat_enc_csn_id
 */
  LEFT OUTER JOIN
    (SELECT *
    FROM NYUGT_ED_ADT_TMP adt0
    WHERE adt0.effective_time IN
      (SELECT MIN (adt5.effective_time)
      FROM NYUGT_ED_ADT_TMP adt5
      --join REPORTADMIN.NYUGT_ED_TMP t on t.pat_enc_csn_id=adt5.PAT_ENC_CSN_ID -- YC 1/28/2019 filter by tmp - to speed up
      where adt0.pat_enc_csn_id =adt5.pat_enc_csn_id
      AND adt5.room_id          =10500016241 --- for "TRANSFER_TO_THGOF"
      AND adt5.event_type_c     =3
      AND adt5.event_subtype_c  =1
      GROUP BY adt5.pat_enc_csn_id
      )
    )adt0  ON peh.pat_enc_csn_id   = adt0.pat_enc_csn_id

  WHERE ----ed_tmp.update_date between s_date and e_date and
  PEH.ED_EPISODE_ID IS NOT NULL

  and HAR3.Related_Har_Id is null --- YC 5/18/2017 filter out 'Related' encounters
  and not exists (select 1  from PATIENT_TYPE ptt where ptt.patient_type_c in ('100','101','102','104') -- test patients
                 and peh.pat_id=ptt.pat_id)

  ;
  commit;
clarity.NYU_CLARITY_LOG_PKG.logMsg( 'REPORTADMIN.NYU_V_ED_SCPM', 'REPORTADMIN.SCPM_ED', 'INFO', 'DONE', 'INSERT INTO ... SELECT FROM ... ');

---   end LOOP;
--execute immediate 'DROP TABLE ED_TMP PURGE';
--execute immediate 'DROP TABLE ED_ORD_TMP PURGE';

clarity.NYU_CLARITY_LOG_PKG.logMsg( 'REPORTADMIN.NYU_V_ED_SCPM', 'REPORTADMIN.NYU_V_ED_SCPM_TST', 'INFO', 'COMPLETED', 'STORED PROCEDURE COMPLETED');

--select * from clarity.nyu_clarity_log where log_name = 'REPORTADMIN.NYU_V_ED_SCPM' order by 1 desc
end;
/