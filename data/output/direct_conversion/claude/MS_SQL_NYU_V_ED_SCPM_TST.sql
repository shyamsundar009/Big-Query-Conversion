
CREATE OR ALTER procedure NYU_V_ED_SCPM_TST ( @numDays integer
                                            ) as
BEGIN
    declare @start_dt    date;
    declare @s_date date;
    declare @e_date date;
    declare @cnt integer;
    declare @Qcnt integer;

    If (@numDays=99999 or @numDays is null) 
    begin
      set @start_dt = cast('06/05/2011' as date);
    End
    Else
    begin  
      set @start_dt = cast(getdate()-@numDays as date);
    End
    print 'REPORTADMIN.NYU_V_ED_SCPM_TST SP STARTED-from '+convert(varchar(10), @start_dt, 101);

    delete from NYUGT_ED_TMP;
    delete from NYUGT_ED_ORD_TMP;
    delete from NYUGT_ED_ADT_TMP;

    if (@numDays=99999 or @numDays is null)
    begin
      insert into NYUGT_ED_TMP WITH (TABLOCK)
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
                getdate() as RUN_DATE
                ,max(ED_IP_BED_ASSIGNED) as ED_IP_BED_ASSIGNED 
                ,max(ARRIVAL_department_id) as ARRIVAL_department_id  
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
              CASE WHEN EEI.EVENT_TYPE = '160225' THEN eei.event_time  END AS SHORT_TERM_STAY_TIMESTAMP,
              CASE WHEN EEI.EVENT_TYPE = '1600000060' THEN eei.event_time  END AS TRANS_TO_OBSER_TIMESTAMP,  
              min( CASE  WHEN eei.event_type in('236', '16023101')  THEN eei.event_time END)
                    over (partition by eei.pat_enc_csn_id ) AS ED_IP_BED_ASSIGNED,
              CASE WHEN EEI.EVENT_TYPE = '50' THEN EVENT_DEPT_ID    END AS ARRIVAL_department_id       
              from (
                select epi.pat_enc_csn_id
                  ,epi.update_date                
                  ,epi.items_edited_time,epi.pat_id
                  ,row_number() over (partition by epi.pat_enc_csn_id,event_type order by eei.event_time,eei.adt_event_id) rn
                  ,EEI.ADT_EVENT_ID ,EEI.EVENT_TIME ,EEI.EVENT_TYPE ,EEI.EVENT_USER_ID ,EEI.EVENT_DEPT_ID
                    from ed_iev_PAT_info epi
                    join ed_iev_event_info eei  ON eei.event_id=epi.event_id  
                  where eei.event_type      IN ('50','65','95','205','210','16022281','500','16011103','160224','1600000062'
                  ,'160225'
                  ,'1600000060'
                  ,'236'    
                  ,'16023101'    
                  )
                  AND eei.event_status_c  IS NULL      
                  AND EPI.UPDATE_DATE >= @START_DT
                  ) eei
                join pat_enc_hsp peh on peh.pat_enc_csn_id = eei.pat_enc_csn_id
                left outer JOIN clarity_adt adt  ON eei.adt_event_id = adt.event_id
                LEFT OUTER JOIN clarity_emp emp  ON eei.event_user_id = emp.user_id
                LEFT OUTER JOIN clarity_ser ser  ON emp.prov_id = ser.prov_id 
                LEFT OUTER JOIN cl_dep_id dep  ON adt.department_id   = dep.department_id  AND dep.mpi_id_type_id = 36
              where rn=1)
        where UPDATE_DATE >= @START_DT    
        group by pat_enc_csn_id,update_date,hsp_account_id ;
      commit;
    end
    else
    begin
          insert into NYUGT_ED_TMP WITH (TABLOCK)
          with ed_updates as 
          (
          SELECT distinct
               PAT_ENC.PAT_ID, PAT_ENC.PAT_ENC_CSN_ID,  
               PAT_ENC_HSP.ED_EPISODE_ID, PAT_ENC_HSP.ADMIT_CONF_STAT_C,
               PAT_ENC.CONTACT_DATE, PAT_ENC.Effective_Date_Dt
               ,CSA."_UPDATE_DT" CSA_UPDATE_DATE
          FROM EPIC_UTIL.CSA_PAT_ENC CSA
          INNER JOIN PAT_ENC ON CSA.PAT_ENC_CSN_ID = PAT_ENC.PAT_ENC_CSN_ID
          INNER JOIN PAT_ENC_HSP ON PAT_ENC_HSP.PAT_ENC_CSN_ID = PAT_ENC.PAT_ENC_CSN_ID 
                                AND PAT_ENC_HSP.ED_EPISODE_ID IS NOT NULL 
                                AND (PAT_ENC_HSP.ADMIT_CONF_STAT_C IS NULL OR PAT_ENC_HSP.ADMIT_CONF_STAT_C NOT IN (2,3))  
          WHERE CSA."_UPDATE_DT" >= @start_dt AND                   
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
                  getdate() as RUN_DATE
                  ,max(ED_IP_BED_ASSIGNED) as ED_IP_BED_ASSIGNED
                  ,max(ARRIVAL_department_id) as ARRIVAL_department_id  
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
                CASE WHEN EEI.EVENT_TYPE = '160225' THEN eei.event_time  END AS SHORT_TERM_STAY_TIMESTAMP,
                CASE WHEN EEI.EVENT_TYPE = '1600000060' THEN eei.event_time  END AS TRANS_TO_OBSER_TIMESTAMP,
                min( CASE  WHEN eei.event_type in('236', '16023101')  THEN eei.event_time END) 
                      over (partition by eei.pat_enc_csn_id ) AS ED_IP_BED_ASSIGNED,
                CASE WHEN EEI.EVENT_TYPE = '50' THEN EVENT_DEPT_ID    END AS ARRIVAL_department_id
                from (
                  select epi.pat_enc_csn_id
                    ,ed_updates.CSA_UPDATE_DATE update_date 
                    ,epi.items_edited_time,epi.pat_id
                    ,row_number() over (partition by epi.pat_enc_csn_id,event_type order by eei.event_time,eei.adt_event_id)
 rn
                    ,EEI.ADT_EVENT_ID ,EEI.EVENT_TIME ,EEI.EVENT_TYPE ,EEI.EVENT_USER_ID ,EEI.EVENT_DEPT_ID
                      from ed_iev_PAT_info epi
                      join ed_iev_event_info eei  ON eei.event_id=epi.event_id
                      join ed_updates on ed_updates.pat_enc_csn_id=epi.pat_enc_csn_id
                    where eei.event_type      IN ('50','65','95','205','210','16022281','500','16011103','160224','1600000062'
                    ,'160225'
                    ,'1600000060' 
                    ,'236'
                    ,'16023101'
                    )
                    AND eei.event_status_c  IS NULL
                    ) eei  
                  join pat_enc_hsp peh on peh.pat_enc_csn_id = eei.pat_enc_csn_id
                  left outer JOIN clarity_adt adt  ON eei.adt_event_id = adt.event_id
                  LEFT OUTER JOIN clarity_emp emp  ON eei.event_user_id = emp.user_id
                  LEFT OUTER JOIN clarity_ser ser  ON emp.prov_id = ser.prov_id
                  LEFT OUTER JOIN cl_dep_id dep  ON adt.department_id   = dep.department_id  AND dep.mpi_id_type_id = 36
                where rn=1)
          group by pat_enc_csn_id,update_date,hsp_account_id ;
        commit;
    end  

    insert into NYUGT_ED_ORD_TMP WITH (TABLOCK)
    select    pp.pat_enc_csn_id
              ,pp.order_proc_id 
              ,pp.proc_id
              ,pp.description
              ,pp.order_time
              ,pp.order_type_c   
            FROM ORDER_METRICS m
            JOIN  order_proc pp ON pp.order_proc_id  =m.order_id  
            join NYUGT_ED_TMP t ON pp.pat_enc_csn_id=t.pat_enc_csn_id
              where (pp.order_status_c is null or pp.order_status_c<>4) and (pp.proc_id in (233062,252588
                                          ,60311
                                          ,377206 
                                          )
                     or  pp.order_type_c   =49 )
    COMMIT;

    select @cnt=count(*) from sys.indexes where name='IDX_ED_ADT';
           if @cnt=1 
           begin 
             drop index IDX_ED_ADT on NYUGT_ED_ADT_TMP;
           end
    select @cnt=count(*) from sys.indexes where name='IDX_ED_ADT_U';  
           if @cnt=1
           begin
             drop index IDX_ED_ADT_U on NYUGT_ED_ADT_TMP;
           end 

    insert into NYUGT_ED_ADT_TMP WITH (TABLOCK)
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
        join NYUGT_ED_TMP t on t.pat_enc_csn_id=ADT.PAT_ENC_CSN_ID
        where adt.EVENT_SUBTYPE_C   <> 2;
    commit;

    truncate table SCPM_ED_YC;

    insert into SCPM_ED_YC WITH (TABLOCK)
with FLO as ( 
  select * from
  (select m.meas_value,m.recorded_time,t.pat_enc_csn_id
  ,row_number() over (partition by rec.pat_id,rec.inpatient_data_id order by m.recorded_time asc) rn
  from NYUGT_ED_TMP t 
  join pat_enc pe on pe.pat_enc_csn_id =t.pat_enc_csn_id
  join IP_FLWSHT_REC rec on pe.pat_id=rec.pat_id and pe.inpatient_data_id=rec.inpatient_data_id
  join IP_FLWSHT_MEAS m on m.fsd_id=rec.fsd_id and m.flo_meas_id='1600005401'
  ) where rn=1  
) 
SELECT DISTINCT
    P.PAT_MRN_ID                                                                                                  AS "MRN", 
    P.BIRTH_DATE                                                                                                           AS "PATIENT_DOB",
         case when datediff(month, p.BIRTH_DATE, HAR.ADM_DATE_TIME)<0  then 0
          when floor(datediff(month, p.BIRTH_DATE, HAR.ADM_DATE_TIME)/12)=0 then 
            round(datediff(month, p.BIRTH_DATE, HAR.ADM_DATE_TIME)/12.0,2)
            else floor(datediff(month, p.BIRTH_DATE, HAR.ADM_DATE_TIME)/12) end AS "PATIENT_AGE",
    DEP3.MPI_ID                                                                                                            AS "DEPARTMENT", 
    DEP4.MPI_ID                                                                                                            AS "DEPARTMENT_ADM",
    coalesce(HAR.ADM_DATE_TIME ,peh.hosp_admsn_time)   AS "VISIT_DATE_TIME",
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
    zpt.name AS "INSURANCE_PRODUCT", 
    EPP.RPT_GRP_ONE       AS "PLAN_RPT_GRP_ONE",
    HLB2.XR_HX_XPCTD_AMT  AS "EXPECTED_REIMBUSEMENT", 
    HAR.HSP_ACCOUNT_ID    AS "ACCOUNT_NUMBER",
    ZCHAR.NAME            AS "ENCOUNTER_STATUS", 
    ZCEPT.NAME            AS "DISCH_DISPOSITION",
    ZCEPT.ABBR            AS "DISC_DISP_ABBR",  
    CASE
      WHEN HAR.ADM_DATE_TIME>=cast('11/09/2012' as date)  
      THEN ZCED.NAME
      ELSE CASE ZCED.ED_DISPOSITION_C WHEN 3 THEN 'Admit' WHEN 4 THEN 'AMA' WHEN 8 THEN 'Expired' WHEN 9 THEN 'Send to L' WHEN 11 THEN 'Transfer to Procedure Area' ELSE ZCED.NAME END
    END AS "ED_DISCH_DISPOSITION",
    CASE  
      WHEN HAR.ADM_DATE_TIME>=cast('11/09/2012' as date)
      THEN ZCED.ABBR
      ELSE CASE ZCED.ED_DISPOSITION_C WHEN '3' THEN 'Admit' WHEN '4' THEN 'AMA' WHEN '8' THEN 'Expired' WHEN '9' THEN 'Send to L' WHEN '11' THEN 'Transfer to Procedure Area' ELSE ZCED.ABBR END  
    END AS "ED_DISC_DISP_ABBR",
    CE.REF_BILL_CODE   AS "ICD9",
    CE.DX_NAME         AS "ICD9_DESCRIPTION", 
    ZCHAR1.NAME        AS "ACCOUNT_STATUS", 
    HAR.TOT_CHGS       AS "TOTAL_CHARGES",
    PEH.PAT_ENC_CSN_ID AS "CSN", 
    ZCHAR2.NAME        AS "PATIENT_CLASS",
    ZCPATCLS.NAME      AS "ENC_FINAL_PAT_CLASS",
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
    flo.meas_value AS ACUITY,
    zam.name method_of_arrv ,
    cea.ref_bill_code ADMIT_DX_CODE , 
    cea.dx_name ADMIT_DX_NAME ,
    icd10.code AS "ICD10" ,
    CE.DX_NAME       AS "ICD10_DESCRIPTION"
    ,    P.ZIP
    ,    zps.ABBR ADM_SERVICE
    ,    CEe.ref_bill_code IMPRESSION_DX_CODE
    ,    CEe.dx_name IMPRESSION_DX_NAME , 
    ARVDEP.DEPARTMENT_NAME ARRIVAL_DEPT ,
    serl.prov_id first_ed_prov_id
    ,    serl.prov_name first_ed_prov_name ,
    EPP.BENEFIT_PLAN_ID PLAN_ID, 
    min(case when proc_id in (233062,252588)  then ord.order_time end ) over (partition by peh.pat_enc_csn_id) AS order_date,
    max(case when proc_id in (233062,252588) then ord.description end ) over (partition by peh.pat_enc_csn_id) AS Place_in_ed_observation,
/*******************************/
     FIRST_PROVIDER_CONTACT,
/*******************************/  
    race.name             AS patient_race,
    gr.name               AS ethnicity,
    min(case when proc_id in (60311, 377206 ) then ord.order_time end ) over (partition by peh.pat_enc_csn_id) AS ERS_ADM_order_date, 
    max(case when proc_id in (60311, 377206 ) then ord.description end ) over (partition by peh.pat_enc_csn_id) AS ERS_ADMIT_ORDER,
    adt0.effective_time   AS TRANSFER_TO_THGOF,
    max(case when ord.order_type_c   =49 then ord.order_time end ) over (partition by peh.pat_enc_csn_id) AS DISCH_order_date
    ,ztr.name HOSPITAL_TRANSFERRED_FROM
    ,xtr.LOC_ID
    ,CASE
                 WHEN xtr.LOC_ID = 10530 
                 THEN
                    'HJD-P'  
                 WHEN (xtr.LOC_ID NOT IN (10530, 10500, 10510,10800,1084001)
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
,ecc.er_complaint chief_complaint
,ZCAS.NAME admit_source
,HAR3.Related_Har_Id
,SHORT_TERM_STAY
,ARVDEP.DEPARTMENT_ID ARRIVAL_DEPT_ID
  ,PEH.DISCH_DISP_C DISCH_DISP_ID
  ,HAR.PRIM_SVC_HA_C HSP_SVC_ID
  ,zps.HOSP_SERV_C SVC_ID
,zPATs.Hosp_Serv_c PAT_SERV_ID
,zPATs.Name PATIENT_SERVICE  
,har.DISCH_DESTIN_HA_C
,short_term_stay_timestamp
,trans_to_obser_timestamp
,xtr.parent_loc_id
,xtr.parent_loc_name  
,xtr.parent_loc_abbr
,ED_IP_BED_ASSIGNED
,g35.name  AS REPORT_GROUP_35
,ARVDEP.rpt_grp_trtyfive_c
,trg.meas_value TRIAGE_DEST
 FROM NYUGT_ED_TMP ED_TMP  
  join PAT_ENC_HSP PEH on ED_TMP.PAT_ENC_CSN_ID=peh.pat_enc_csn_id
  INNER JOIN PATIENT P  ON PEH.PAT_ID = P.PAT_ID and p.pat_name not like 'ZZZ%'
  JOIN HSP_ACCOUNT HAR        ON PEH.HSP_ACCOUNT_ID = HAR.HSP_ACCOUNT_ID 
  JOIN HSP_ACCOUNT_3 HAR3       ON HAR.HSP_ACCOUNT_ID = HAR3.HSP_ACCOUNT_ID
  LEFT OUTER JOIN ZC_PAT_SERVICE zPATs on ZPATs.Hosp_Serv_c=peh.Hosp_Serv_c
  left join FLO on flo.pat_enc_csn_id=peh.pat_enc_csn_id
  LEFT OUTER JOIN
      (SELECT hap.prov_id,
        hap.pat_enc_csn_id,
        hap.attend_from_date,
        row_number() over (partition BY hap.pat_enc_csn_id order by hap.attend_from_date ASC) rn
      FROM HSP_ATND_PROV hap
      join NYUGT_ED_TMP t on t.pat_enc_csn_id=hap.pat_enc_csn_id
      WHERE hap.ed_attend_yn='Y'
     )hap  ON peh.pat_enc_csn_id=hap.pat_enc_csn_id and  hap.rn=1
  LEFT OUTER JOIN CLARITY_SER serl  ON serl.prov_id=hap.prov_id

  LEFT OUTER JOIN NYUGT_ED_ADT_TMP ADTADMIT  ON peh.pat_enc_csn_id=ADTADMIT.PAT_ENC_CSN_ID and PEH.ADM_EVENT_ID = ADTADMIT.EVENT_ID
       AND ADTADMIT.EVENT_SUBTYPE_C <> 2
       AND ADTADMIT.EVENT_TYPE_C     = 1

  LEFT OUTER JOIN CLARITY_DEP ADMDEP  ON ADTADMIT.DEPARTMENT_ID = ADMDEP.DEPARTMENT_ID
  LEFT OUTER JOIN CLARITY_DEP ARVDEP  ON ARVDEP.DEPARTMENT_ID = coalesce(ED_TMP.ARRIVAL_DEPT_ID,ADTADMIT.DEPARTMENT_ID,PEH.DEPARTMENT_ID)
  left outer join ZC_DEP_RPT_GRP_35 g35 on coalesce(ED_TMP.ARRIVAL_DEPT_ID,ADTADMIT.DEPARTMENT_ID,PEH.DEPARTMENT_ID)=g35.dep_rpt_grp_35_c

  LEFT OUTER JOIN ZC_DISCH_DESTIN_HA zdd on zdd.disch_destin_ha_c=har.DISCH_DESTIN_HA_C
  left outer join HSP_ACCT_LAST_UPDATE haru on haru.hsp_account_id= har.HSP_ACCOUNT_ID
  LEFT OUTER JOIN ZC_TRANSFER_SRC_HA ztr on ztr.TRANSFER_SRC_HA_C =HAR.TRANSFER_SRC_HA_C
  LEFT OUTER JOIN NYU_V_FAC_STRUCT_X xtr ON coalesce(ED_TMP.ARRIVAL_DEPT_ID,ADTADMIT.DEPARTMENT_ID,PEH.DEPARTMENT_ID) = xtr.DEP_ID
  LEFT OUTER JOIN CLARITY_LOC EAF    ON HAR.LOC_ID = EAF.LOC_ID
  LEFT OUTER JOIN ZC_ADM_SOURCE ZCAS  ON PEH.ADMIT_SOURCE_C = ZCAS.ADMIT_SOURCE_C
  left join (select FR.INPATIENT_DATA_ID,fm.meas_value
       ,row_number() over (partition by FR.INPATIENT_DATA_ID order by fm.recorded_time desc) rn
       FROM IP_FLWSHT_MEAS FM
          INNER JOIN IP_FLWSHT_REC FR ON FM.FSD_ID = FR.FSD_ID
          INNER JOIN IP_FLO_GP_DATA GP ON FM.FLO_MEAS_ID = GP.FLO_MEAS_ID
             where fm.flo_meas_id = 16029
             AND ENTRY_TIME >= (@start_dt - 30)
             )trg ON trg.INPATIENT_DATA_ID = peh.INPATIENT_DATA_ID and trg.rn=1
  LEFT OUTER JOIN CLARITY_DEP DEP  ON PEH.DEPARTMENT_ID = DEP.DEPARTMENT_ID
  LEFT OUTER JOIN CLARITY_EPM EPM  ON HAR.PRIMARY_PAYOR_ID = EPM.PAYOR_ID
  LEFT OUTER JOIN CLARITY_EPP EPP  ON HAR.PRIMARY_PLAN_ID = EPP.BENEFIT_PLAN_ID
  left outer join CLARITY_EPP_2 EPP2 on epp2.benefit_plan_id= EPP.BENEFIT_PLAN_ID
  left outer join zc_prod_type zpt on zpt.prod_type_c=epp2.prod_type_c
  LEFT OUTER JOIN ZC_ARRIV_MEANS zam  ON peh.MEANS_OF_ARRV_C =zam.means_of_arrv_c
  LEFT OUTER JOIN (
        select *
        from 
          (SELECT INSURANCE_BUCKET_ID, HSP_ACCOUNT_ID 
          FROM (
             SELECT INSURANCE_BUCKET_ID, HAR1.HSP_ACCOUNT_ID,
                ROW_NUMBER() OVER(PARTITION BY HAR1.HSP_ACCOUNT_ID ORDER BY LINE) AS RN
             FROM HSP_ACCT_INS_BKTS HAR1
             JOIN NYUGT_ED_TMP ED_TMP ON ED_TMP.HSP_ACCOUNT_ID=HAR1.HSP_ACCOUNT_ID
             ) WHERE RN = 1
          ) HAR1
        JOIN        
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
             AND ADT3.BASE_PAT_CLASS_C  = 1
  LEFT OUTER JOIN ZC_PAT_SERVICE zps  ON zps.hosp_serv_c = ADT3.PAT_SERVICE_C
  left outer join clarity_bed bed on adt3.bed_csn_id=bed.bed_csn_id
  left outer join clarity_rom room on adt3.room_csn_id=room.room_csn_id
  LEFT OUTER JOIN
    (SELECT MIN(EFFECTIVE_TIME) event_time ,
      adt6.pat_enc_csn_id
    FROM NYUGT_ED_ADT_TMP adt6
    where adt6.EVENT_SUBTYPE_C <> 2 
          AND adt6.pat_class_c        ='104'
    GROUP BY adt6.pat_enc_csn_id
    ) adt6  ON PEH.PAT_ENC_CSN_ID = ADT6.PAT_ENC_CSN_ID
  LEFT OUTER JOIN HSP_ACCT_DX_LIST HARDX  ON HAR.HSP_ACCOUNT_ID = HARDX.HSP_ACCOUNT_ID  AND HARDX.LINE        = 1
  LEFT OUTER JOIN CLARITY_EDG CE  ON HARDX.DX_ID = CE.DX_ID
  left outer join EDG_CURRENT_ICD10 ICD10 on hardx.dx_id=icd10.dx_id and hardx.line=1 and icd10.line=1
  LEFT OUTER JOIN HSP_ADMIT_DIAG HAD  ON PEH.PAT_ENC_CSN_ID = HAD.PAT_ENC_CSN_ID  AND HAD.LINE          = 1
  LEFT OUTER JOIN CLARITY_EDG CEa  ON HAD.DX_ID = CEa.DX_ID
  left outer join PAT_ENC_ER_COMPLNT ecc on ecc.pat_enc_csn_id = peh.pat_enc_csn_id and ecc.line = 1   
  LEFT OUTER JOIN
    (SELECT pedx.DX_ID,
      pedx.PAT_ENC_CSN_ID
    FROM PAT_ENC_DX pedx
    join NYUGT_ED_TMP t on t.pat_enc_csn_id=pedx.PAT_ENC_CSN_ID
    where pedx.dx_ed_yn='Y'
    AND pedx.LINE  =
      (SELECT MIN(line) 
      FROM PAT_ENC_DX pedx2
      WHERE pedx2.dx_ed_yn     ='Y'
      AND pedx2.PAT_ENC_CSN_ID = pedx.PAT_ENC_CSN_ID
      GROUP BY PAT_ENC_CSN_ID
      )
    ) pedx  ON peh.PAT_ENC_CSN_ID = pedx.PAT_ENC_CSN_ID   
  LEFT OUTER JOIN CLARITY_EDG CEe  ON pedx.DX_ID = CEe.DX_ID
  LEFT OUTER JOIN ZC_MC_PAT_STATUS ZCHAR  ON HAR.PATIENT_STATUS_C = ZCHAR.PAT_STATUS_C
  LEFT OUTER JOIN ZC_ACCT_BILLSTS_HA ZCHAR1  ON HAR.ACCT_BILLSTS_HA_C = ZCHAR1.ACCT_BILLSTS_HA_C
  LEFT OUTER JOIN ZC_ACCT_BASECLS_HA ZCHAR2  ON HAR.ACCT_BASECLS_HA_C = ZCHAR2.ACCT_BASECLS_HA_C  
  LEFT OUTER JOIN ZC_DISCH_DISP ZCEPT  ON PEH.DISCH_DISP_C = ZCEPT.DISCH_DISP_C
  LEFT OUTER JOIN ZC_REP_BASE_CLASS ZCRBC  ON ADT2.TO_BASE_CLASS_C = ZCRBC.INT_REP_BASE_CLS_C
  LEFT OUTER JOIN ZC_ED_DISPOSITION ZCED  ON PEH.ED_DISPOSITION_C = ZCED.ED_DISPOSITION_C
  LEFT OUTER JOIN ZC_FINANCIAL_CLASS ZCFC  ON EPM.FINANCIAL_CLASS = ZCFC.FINANCIAL_CLASS
  LEFT OUTER JOIN ZC_FIN_CLASS ZCFC2  ON HAR.ACCT_FIN_CLASS_C = ZCFC2.FIN_CLASS_C
  LEFT OUTER JOIN CL_DEP_ID DEP3  ON DEP.DEPARTMENT_ID = DEP3.DEPARTMENT_ID AND DEP3.MPI_ID_TYPE_ID = 36
  LEFT OUTER JOIN CL_DEP_ID DEP4  ON ADT3.DEPARTMENT_ID = DEP4.DEPARTMENT_ID AND DEP4.MPI_ID_TYPE_ID = 36
  LEFT OUTER JOIN ZC_PAT_CLASS ZCPATCLS  ON PEH.ADT_PAT_CLASS_C = ZCPATCLS.ADT_PAT_CLASS_C
  LEFT OUTER JOIN ZC_ACUITY_LEVEL za  ON peH.ACUITY_LEVEL_C=za.acuity_level_c
  LEFT OUTER JOIN patient_race aa  ON p.pat_id=aa.pat_id  AND aa.line=1
  LEFT OUTER JOIN zc_patient_race race  ON aa.patient_race_c=race.patient_race_c  
  LEFT OUTER JOIN zc_ethnic_group gr  ON p.ethnic_group_c=gr.ethnic_group_c
  left join NYUGT_ED_ORD_TMP ord on peh.pat_enc_csn_id = ord.pat_enc_csn_id
  LEFT OUTER JOIN
    (SELECT *
    FROM NYUGT_ED_ADT_TMP adt0
    WHERE adt0.effective_time IN  
      (SELECT MIN (adt5.effective_time)
      FROM NYUGT_ED_ADT_TMP adt5
      where adt0.pat_enc_csn_id =adt5.pat_enc_csn_id
      AND adt5.room_id          =10500016241
      AND adt5.event_type_c     =3
      AND adt5.event_subtype_c  =1
      GROUP BY adt5.pat_enc_csn_id
      )
    )adt0  ON peh.pat_enc_csn_id   = adt0.pat_enc_csn_id

  WHERE
  PEH.ED_EPISODE_ID IS NOT NULL

  and HAR3.Related_Har_Id is null 
  and not exists (select 1  from PATIENT_TYPE ptt where ptt.patient_type_c in ('100','101','102','104')
                 and peh.pat_id=ptt.pat_id) 
  ;
  commit;

  print 'REPORTADMIN.NYU_V_ED_SCPM_TST STORED PROCEDURE COMPLETED';

end

