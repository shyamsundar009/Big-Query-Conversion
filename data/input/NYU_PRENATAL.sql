CREATE OR REPLACE PROCEDURE NYU_PRENATAL (
  START_DATE IN VARCHAR
  ,END_DATE IN VARCHAR
  ,P_CURSOR OUT SYS_REFCURSOR
) AS
/* 
  Execution Plan:
  Legend: D - Done, A - Analyze, O - Optimize, T - To do,
  1. [D] Define Population (Pregnancy episodes)
  2. [D] Pull Pregnancy episode visits looking for diganosis
  3. [O] Pull Pregnancy episode visits looking for first provider, LMP, Trimester Entry of Care
  4. [O] Pull immunizations Flu/Tdap (most recent season)
    A. Get all Flu/Tdap Immunizations
    B. Filter for most recent season of Flu/Tdap
    C. Get any Declination Data (should be most recent season)
    D. Get procedure orders for Flu/Tdap
    D. Get medication orders for Flu/Tdap
  5. [O] Pull Orders Procedures for GBS, HIV, Immunizations
  6. [T] Pull Smartphrase usage Episode encounters educations on <39w GA, Breastfeeding, Domestic Violence, Fetal Movement, L&D Processes
  7. [T] Pull Smartlist usage for FHC OB Risk Assessment Initial (ELT .1 29654 - NYU OB Risk Assessment)
  7. [T] Pull Birthweight of baby if delivered at NYU low birth weight <2499g (Ask about # of babies delivered)
  8. [T] Pull Post Partum Visit and look for Depression Screening
  Notes: First prenatal date may be incorrect due to it including canceled appointments

  FOR TEMP TABLE SCHEMA CHANGES:
  drop table tmpActivePregnancyEpisodes;
  drop table tmpActivePregnancyVisits;
  drop table tmpPrenatalFluImmunizations;
  drop table tmpRecPrenatalFluImmunizations;
  drop table tmpPrenatalFluOrders;
  drop table tmpPatNextAppt;
  drop table tmpPatLabTestResults;

*/

BEGIN
  DECLARE
     RUNDATE        DATE := SYSDATE;
     --I_START_DATE DATE := EPIC_UTIL.EFN_DIN(START_DATE);
     --I_END_DATE DATE := EPIC_UTIL.EFN_DIN(END_DATE);
     I_START_DATE DATE := EPIC_UTIL.EFN_DIN('mb-1');
     I_END_DATE DATE := EPIC_UTIL.EFN_DIN('me-1');
     FLU_ORD_DATE DATE := EPIC_UTIL.EFN_DIN('08/01/2017'); -- NOT USED
     FLU_ADM_DATE DATE := EPIC_UTIL.EFN_DIN('09/01/2017'); -- NOT USED
  BEGIN
    DBMS_OUTPUT.ENABLE;
    dbms_output.put_line('Start Time: ' || RUNDATE);
    BEGIN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE tmpActivePregnancyEpisodes';
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE != -942
          THEN RAISE;
          ELSE
            EXECUTE IMMEDIATE 
              'create global temporary table tmpActivePregnancyEpisodes -- drop table tmpActivePregnancyEpisodes -- select * from tmpActivePregnancyEpisodes
              (
                Episode_ID          numeric (18,0)  NULL,
                Patient_ID          varchar (20)  NULL,
                Patient_MRN         varchar (20)  NULL,
                Patient_Name        varchar (200) NULL,
                Patient_DOB         date          NULL,
                Start_Date          date          NULL,
                First_Preg_Enc      date          NULL,
                First_Prenatal_Loc  varchar (200) NULL,
                First_Prenatal_Prov varchar (200) NULL,
                First_Prenatal_Date date          NULL,
                First_Prenatal_Trimester varchar (20)  NULL,
                LMP                 date          NULL,
                WORKING_ESD         date          NULL,
                Working_EDD         date          NULL,
                Diabetic            varchar (1)   NULL,
                Hypertensive        varchar (1)   NULL
              )';
        END IF;
    END;
    BEGIN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE tmpActivePregnancyVisits';
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE != -942
          THEN RAISE;
          ELSE
            EXECUTE IMMEDIATE 
              'create table tmpActivePregnancyVisits -- drop table tmpActivePregnancyVisits -- select * from tmpActivePregnancyVisits
              (
                Episode_ID            numeric (18,0)  NULL,
                Patient_ID            varchar (20)  NULL,
                Encounter_ID          varchar (20)  NULL,
                Encounter_Date        date          NULL,
                LMP                   date          NULL,
                Encounter_Visit_Type  varchar (100) NULL,
                Encounter_Department  varchar (200) NULL,
                Encounter_Location    varchar (200) NULL,
                Encounter_Provider    varchar (200) NULL,
                Encounter_Prov_Type   varchar (200) NULL,
                Supervising_Provider  varchar (200) NULL                     
              )';
        END IF;
    END;
    -- drop table tmpPrenatalFluImmunizations -- select * from tmpPrenatalFluImmunizations
    BEGIN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE tmpPrenatalFluImmunizations';
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE != -942
          THEN RAISE;
          ELSE
            EXECUTE IMMEDIATE
              'create table tmpPrenatalFluImmunizations  
              (
                Immune_ID           varchar (20)  NULL,
                Patient_ID          varchar (20)  NULL,
                Immunization_ID     varchar (20)  NULL,
                Order_ID            varchar (20)  NULL,
                Order_description   varchar (200) NULL,
                Adminitration_Date  date          NULL,
                Immunization_Enc_ID varchar (20)  NULL,
                Immunization_Entry  date          NULL,
                Status              varchar (20)  NULL,
                Defer_Reason        varchar (200) NULL
              )';
        END IF;
    END;
    -- Most recent flu vaccine. This is one record per patient per vaccine type. 
    BEGIN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE tmpRecPrenatalFluImmunizations';
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE != -942
          THEN RAISE;
          ELSE
            EXECUTE IMMEDIATE
              'create table tmpRecPrenatalFluImmunizations -- drop table tmpRecPrenatalFluImmunizations
              (
                Immune_ID           varchar (20)  NULL,
                Immune_Type         varchar (20)  NULL,
                Patient_ID          varchar (20)  NULL,
                Immunization_ID     varchar (20)  NULL,
                Order_ID            varchar (20)  NULL,
                Order_description   varchar (200) NULL,
                Adminitration_Date  date          NULL,
                Immunization_Enc_ID varchar (20)  NULL,
                Immunization_Entry  date          NULL,
                Status              varchar (20)  NULL,
                Defer_Reason        varchar (200) NULL,
                Scanned_Doc_Date    date          NULL,
                Scanned_Reason      varchar (100) NULL
              )';
        END IF;
    END;
    -- Lets get the Orders
    BEGIN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE tmpPrenatalFluOrders';
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE != -942
          THEN RAISE;
          ELSE
            EXECUTE IMMEDIATE
              'create table tmpPrenatalFluOrders -- drop table tmpPrenatalFluOrders
              (
                Order_ID            varchar (20)  NULL,
                Medication_ID       varchar (20)  NULL,
                Order_Code          varchar (20)  NULL,
                Proc_Code           varchar (20)  NULL,
                Patient_ID          varchar (20)  NULL,
                Order_Date          date          NULL,
                Order_Status        varchar (20)  NULL,
                Order_Provider      varchar (200) NULL,
                Order_Description   varchar (200) NULL
              )';
        END IF;
    END;
    -- The next appointment
    BEGIN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE tmpPatNextAppt';
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE != -942
          THEN RAISE;
          ELSE
            EXECUTE IMMEDIATE
              'create table tmpPatNextAppt -- drop table tmpPatNextAppt
              (
                Patient_ID          varchar (20)  NULL,
                Encounter_ID        varchar (20)  NULL,
                Encounter_Date      date          NULL,
                Encounter_Location  varchar (200) NULL,
                Encounter_Provider  varchar (200) NULL
              )';
        END IF;
    END;
    -- The next appointment
    BEGIN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE tmpPatLabTestResults';
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE != -942
          THEN RAISE;
          ELSE
            EXECUTE IMMEDIATE
              'create table tmpPatLabTestResults -- drop table tmpPatLabTestResults
              (
                Patient_ID          varchar (20)  NULL,
                Order_ID            varchar (20)  NULL,
                Proc_Code           varchar (20)  NULL,
                Proc_Desription     varchar (200) NULL,
                Order_Status        varchar (20)  NULL,
                Order_Date          date          NULL,
                Result_Date         date          NULL,
                Result_Value        varchar (200)  NULL,
                Result_Value_Desc   varchar (300)  NULL,
                Result_Status       varchar (50)  NULL
              )';
        END IF;
    END;
    dbms_output.put_line('CREATE TABLES: ' || (SYSDATE - RUNDATE) * 24 * 60 * 60 || ' SECONDS'); RUNDATE := SYSDATE;
    -- Populate tmpActivePregnancyEpisodes
    insert into tmpActivePregnancyEpisodes
    SELECT EPISODE_FILTER.EPISODE_ID
    ,PATIENT.PAT_ID
    ,PATIENT.PAT_MRN_ID
    ,PATIENT.PAT_NAME
    ,PATIENT.BIRTH_DATE
    ,EPISODE.START_DATE
    ,EPISODE.FIRST_PNC_DT
    ,ZC_FIRST_PNT_LOC.Name -- First_Prenatal_Loc
    ,'' -- First_Prenatal_Provider
    ,FIRST_PNC_DT
    ,CASE 
      WHEN FIRST_PNC_DT >= OB_WRK_EDD_DT - INTERVAL '280' DAY(3) AND FIRST_PNC_DT < OB_WRK_EDD_DT - INTERVAL '183' DAY(3)
      THEN 'FIRST'
      ELSE
        CASE
          WHEN FIRST_PNC_DT >= OB_WRK_EDD_DT - INTERVAL '182' DAY(3) AND FIRST_PNC_DT < OB_WRK_EDD_DT - INTERVAL '99' DAY(3)
          THEN 'SECOND'
          ELSE
            CASE
              WHEN FIRST_PNC_DT >= OB_WRK_EDD_DT - INTERVAL '98' DAY(3) AND FIRST_PNC_DT <= OB_WRK_EDD_DT
              THEN 'THIRD'
              ELSE NULL 
        END
      END
    END FIRST_PNC_TRIMESTER
    ,NULL
    ,OB_WRK_EDD_DT - INTERVAL '280' day(3) OB_WRK_ST_DT /* 40 WEEKS (TYPICAL PREGNANCY) */
    ,OB_WRK_EDD_DT
    ,''
    ,''
    FROM (
      SELECT EPISODE.EPISODE_ID
      FROM EPISODE
      LEFT JOIN EPISODE_LINK ON EPISODE.EPISODE_ID = EPISODE_LINK.EPISODE_ID
      LEFT JOIN PAT_ENC ON EPISODE_LINK.PAT_ENC_CSN_ID = PAT_ENC.PAT_ENC_CSN_ID
      LEFT JOIN CLARITY_DEP ON PAT_ENC.DEPARTMENT_ID = CLARITY_DEP.DEPARTMENT_ID
      LEFT JOIN CLARITY_LOC ON CLARITY_DEP.REV_LOC_ID = CLARITY_LOC.LOC_ID
      WHERE EPISODE.SUM_BLK_TYPE_ID = '2' /* PREGNANCY */
      AND EPISODE.STATUS_C <> 3
      AND PAT_ENC.CONTACT_DATE >= I_START_DATE
      --AND PAT_ENC.CONTACT_DATE < EPIC_UTIL.EFN_DIN('12/31/2017') + INTERVAL '1' DAY
      AND PAT_ENC.CONTACT_DATE < I_END_DATE + INTERVAL '1' DAY
      AND CLARITY_LOC.RPT_GRP_ELEVEN_C = '10787'
      GROUP BY EPISODE.EPISODE_ID
    ) EPISODE_FILTER
    LEFT JOIN EPISODE ON EPISODE_FILTER.EPISODE_ID = EPISODE.EPISODE_ID
    LEFT JOIN PATIENT ON EPISODE.PAT_LINK_ID = PATIENT.PAT_ID
    LEFT JOIN ZC_FIRST_PNT_LOC ON EPISODE.FIRST_PNT_LOC_C = ZC_FIRST_PNT_LOC.FIRST_PNT_LOC_C;
    -- Append tmpActivePregnancyEpisodes with partial matches
    insert into tmpActivePregnancyEpisodes
    SELECT DISTINCT EPISODE.EPISODE_ID
    ,PATIENT.PAT_ID
    ,PATIENT.PAT_MRN_ID
    ,PATIENT.PAT_NAME
    ,PATIENT.BIRTH_DATE
    ,EPISODE.START_DATE
    ,EPISODE.FIRST_PNC_DT FIRST_PREG_ENC
    ,ZC_FIRST_PNT_LOC.NAME FIRST_PRENATAL_LOC
    ,NULL FIRST_PRENATAL_PROV
    ,EPISODE.FIRST_PNC_DT FIRST_PRENATAL_DATE
    ,CASE 
      WHEN FIRST_PNC_DT >= OB_WRK_EDD_DT - INTERVAL '280' DAY(3) AND FIRST_PNC_DT < OB_WRK_EDD_DT - INTERVAL '183' DAY(3)
      THEN 'FIRST'
      ELSE
        CASE
          WHEN FIRST_PNC_DT >= OB_WRK_EDD_DT - INTERVAL '182' DAY(3) AND FIRST_PNC_DT < OB_WRK_EDD_DT - INTERVAL '99' DAY(3)
          THEN 'SECOND'
          ELSE
            CASE
              WHEN FIRST_PNC_DT >= OB_WRK_EDD_DT - INTERVAL '98' DAY(3) AND FIRST_PNC_DT <= OB_WRK_EDD_DT
              THEN 'THIRD'
              ELSE NULL 
        END
      END
    END FIRST_PNC_TRIMESTER
    ,NULL LMP
    ,EPISODE.OB_WRK_EDD_DT - INTERVAL '280' DAY(4) WORKING_ESD
    ,EPISODE.OB_WRK_EDD_DT Working_EDD
    ,NULL Diabetic
    ,NULL Hypertensive
    FROM EPISODE
    LEFT JOIN (
      SELECT DISTINCT 
      EPISODE_LINK.EPISODE_ID
      ,PAT_ENC.PAT_ID
      FROM EPISODE_LINK
      LEFT JOIN PAT_ENC ON EPISODE_LINK.PAT_ENC_CSN_ID = PAT_ENC.PAT_ENC_CSN_ID
    ) EPISODE_PAT ON EPISODE.EPISODE_ID = EPISODE_PAT.EPISODE_ID
    -- INITAL/ROUTINE PRENATAL ENCOUNTERS
    LEFT JOIN PAT_ENC ON EPISODE_PAT.PAT_ID = PAT_ENC.PAT_ID
      AND EPISODE.OB_WRK_EDD_DT - INTERVAL '280' DAY(4) < PAT_ENC.CONTACT_DATE AND PAT_ENC.CONTACT_DATE < EPISODE.OB_WRK_EDD_DT
      AND PAT_ENC.ENC_TYPE_C IN (1200,1201)
      AND PAT_ENC.CHECKIN_TIME IS NOT NULL
    LEFT JOIN CLARITY_DEP ON PAT_ENC.DEPARTMENT_ID = CLARITY_DEP.DEPARTMENT_ID
    LEFT JOIN CLARITY_LOC ON CLARITY_DEP.REV_LOC_ID = CLARITY_LOC.LOC_ID
    LEFT JOIN PATIENT ON EPISODE_PAT.PAT_ID = PATIENT.PAT_ID
    LEFT JOIN ZC_FIRST_PNT_LOC ON EPISODE.FIRST_PNT_LOC_C = ZC_FIRST_PNT_LOC.FIRST_PNT_LOC_C
    WHERE EPISODE.OB_WRK_EDD_DT IS NOT NULL
    AND EPISODE.SUM_BLK_TYPE_ID = '2'
    AND EPISODE.STATUS_C <> 3
    AND EPISODE.EPISODE_ID NOT IN (SELECT EPISODE_ID FROM tmpActivePregnancyEpisodes) 
    -- FILTER NOT LINKED ENCOUNTERS
    AND PAT_ENC.CONTACT_DATE >= I_START_DATE /* Lutheran FHC Start Date */
    --AND PAT_ENC.CONTACT_DATE < EPIC_UTIL.EFN_DIN('12/31/2017') + INTERVAL '1' DAY
    AND PAT_ENC.CONTACT_DATE < I_END_DATE + INTERVAL '1' DAY
    AND CLARITY_LOC.RPT_GRP_ELEVEN_C = '10787' ;
    dbms_output.put_line('EPISODES: ' || (SYSDATE - RUNDATE) * 24 * 60 * 60 || ' SECONDS'); RUNDATE := SYSDATE;
    -- Populate tmpActivePregnancyVisits
    insert into tmpActivePregnancyVisits
    select 
    tmpActivePregnancyEpisodes.Episode_ID,
    tmpActivePregnancyEpisodes.Patient_ID,
    PAT_ENC.Pat_Enc_CSN_ID,
    Pat_Enc.Contact_Date,
    Pat_Enc.LMP_Date,
    ZC_DISP_ENC_TYPE.NAME,
    CLARITY_DEP.DEPARTMENT_NAME,
    CLARITY_LOC.Loc_Name,
    SER_VISIT.Prov_Name, -- Visit_Provider,
    SER_VISIT.PROV_TYPE,
    SER_SUPERVISING.Prov_Name -- Attending_Provider
    from tmpActivePregnancyEpisodes
    LEFT JOIN EPISODE_LINK ON tmpActivePregnancyEpisodes.EPISODE_ID = EPISODE_LINK.EPISODE_ID
    LEFT JOIN PAT_ENC ON tmpActivePregnancyEpisodes.PATIENT_ID = PAT_ENC.PAT_ID
      AND (
        EPISODE_LINK.PAT_ENC_CSN_ID = PAT_ENC.PAT_ENC_CSN_ID
        OR (EPISODE_LINK.PAT_ENC_CSN_ID IS NULL
        AND (tmpActivePregnancyEpisodes.WORKING_ESD < PAT_ENC.CONTACT_DATE AND PAT_ENC.CONTACT_DATE < tmpActivePregnancyEpisodes.Working_EDD))
      )
      AND PAT_ENC.ENC_TYPE_C IN (101,1200,1201,1214)
      AND PAT_ENC.CHECKIN_TIME IS NOT NULL
    LEFT JOIN PAT_ENC_2 ON PAT_ENC.PAT_ENC_CSN_ID = PAT_ENC_2.PAT_ENC_CSN_ID
    LEFT JOIN CLARITY_SER SER_VISIT ON PAT_ENC.VISIT_PROV_ID = SER_VISIT.PROV_ID
    LEFT JOIN CLARITY_SER SER_SUPERVISING ON PAT_ENC_2.SUP_PROV_ID = SER_SUPERVISING.PROV_ID
    LEFT JOIN CLARITY_DEP ON PAT_ENC.DEPARTMENT_ID = CLARITY_DEP.DEPARTMENT_ID
    LEFT JOIN CLARITY_LOC ON CLARITY_DEP.REV_LOC_ID = CLARITY_LOC.LOC_ID
    LEFT JOIN ZC_DISP_ENC_TYPE ON Pat_Enc.ENC_TYPE_C = ZC_DISP_ENC_TYPE.DISP_ENC_TYPE_C ;
    dbms_output.put_line('EPISODES VISITS: ' || (SYSDATE - RUNDATE) * 24 * 60 * 60 || ' SECONDS'); RUNDATE := SYSDATE;
    -- Update tmpActivePregnancyVisits with diagnosis
    update tmpActivePregnancyEpisodes
    set (
      Diabetic
      ,Hypertensive
    ) = (
      select
      max(case when PAT_ENC_DX.DX_ID IN (SELECT EDG_CURRENT_ICD10.DX_ID FROM EDG_CURRENT_ICD10 WHERE EDG_CURRENT_ICD10.CODE IN ('O13', 'O13.9')) then 'Y' else null end) Diabetic
      ,max(case when PAT_ENC_DX.DX_ID IN (SELECT EDG_CURRENT_ICD10.DX_ID FROM EDG_CURRENT_ICD10 WHERE EDG_CURRENT_ICD10.CODE IN (SELECT VCG_ICD_CODES.ICD_CODES_LIST FROM VCG_ICD_CODES WHERE VCG_ICD_CODES.GROUPER_ID = 5100000145 AND VCG_ICD_CODES.CODE_SET_C = 2)) then 'Y' else null end) Hypertensive
      FROM tmpActivePregnancyVisits
      INNER JOIN PAT_ENC_DX ON tmpActivePregnancyVisits.Encounter_ID = PAT_ENC_DX.PAT_ENC_CSN_ID
      WHERE tmpActivePregnancyVisits.episode_id = tmpActivePregnancyEpisodes.episode_id
    );
    dbms_output.put_line('EPISODES DIAGNOSIS: ' || (SYSDATE - RUNDATE) * 24 * 60 * 60 || ' SECONDS'); RUNDATE := SYSDATE;
    -- Update tmpActivePregnancyEpisodeswith first prenatal provider
    Update tmpActivePregnancyEpisodes
    set 
    (
      First_Prenatal_Prov
    ) 
    = 
    (
        select 
          v_Patient_Encs_1.Encounter_Provider
        from 
            (
              select 
              Episode_ID,
              Patient_ID, 
              Encounter_ID, 
              Encounter_Provider,
              row_number() 
              over (PARTITION BY Patient_ID, Episode_ID order by Encounter_Date) rank
              from tmpActivePregnancyVisits   
              where 
                  tmpActivePregnancyVisits.Patient_ID         = tmpActivePregnancyEpisodes.Patient_ID
              and tmpActivePregnancyVisits.Episode_ID         = tmpActivePregnancyEpisodes.Episode_ID
            ) v_Patient_Encs_1
        where 
            rank = 1       
        --and V_Appts.Pat_ID = tmpPatNextAppt.Patient_ID
    );
    dbms_output.put_line('EPISODES FIRST PROVIDER: ' || (SYSDATE - RUNDATE) * 24 * 60 * 60 || ' SECONDS'); RUNDATE := SYSDATE;
    -- Update tmpActivePregnancyEpisodes with LMP (last menstral period) from first pregnancy encounter
    update tmpActivePregnancyEpisodes
    set 
    (
    LMP
    )
    = 
    (
        select 
          v_Patient_Encs.LMP
        from 
            (
              select 
              Episode_ID,
              Patient_ID, 
              Encounter_ID, 
              Encounter_Date,
              LMP, 
              Encounter_Visit_Type,
              row_number() 
              over (PARTITION BY Patient_ID order by Encounter_Date) rank
              from tmpActivePregnancyVisits            
              where 
                  tmpActivePregnancyVisits.Patient_ID         = tmpActivePregnancyEpisodes.Patient_ID
              and tmpActivePregnancyVisits.Episode_ID         = tmpActivePregnancyEpisodes.Episode_ID
              and tmpActivePregnancyVisits.LMP is not NULL
            ) v_Patient_Encs
        where 
            rank = 1       
        --and V_Appts.Pat_ID = tmpPatNextAppt.Patient_ID
      )
    ;
    dbms_output.put_line('EPISODES LMP: ' || (SYSDATE - RUNDATE) * 24 * 60 * 60 || ' SECONDS'); RUNDATE := SYSDATE;
    -- Lets get the next appointment details. 
    insert into tmpPatNextAppt
    select distinct
    Patient_ID,         
    '',   -- Encounter_ID     
    NULL, --  Encounter_Date 
    '',   -- Encounter_Location 
    ''    -- Encounter_Provider 
    from tmpActivePregnancyEpisodes ;
    -- Now lets get the next appointment for this patient
    update tmpPatNextAppt
    set 
    (
    tmpPatNextAppt.Encounter_ID,
    tmpPatNextAppt.Encounter_Date, 
    tmpPatNextAppt.Encounter_Location, 
    tmpPatNextAppt.Encounter_Provider 
    )
    = 
      (
          select 
            V_Appts.Pat_ENC_CSN_ID,
            V_Appts.Appt_Dttm,
            V_Appts.LOC_NAME,
            V_Appts.PROV_NAME_WID
          from 
              (
                select 
                 Pat_ID, 
                 Pat_ENC_CSN_ID, 
                 appt_dttm, 
                 Appt_Status_Name, 
                 LOC_NAME, 
                 PROV_NAME_WID,
                row_number()
                over (PARTITION BY Pat_ID
                order by appt_dttm)
                rank
                from v_sched_appt
                where 
                    v_sched_appt.Pat_ID             = tmpPatNextAppt.Patient_ID
                and v_sched_appt.appt_dttm          >= sysdate -1
                and v_sched_appt.Appt_Status_Name   = 'Scheduled'
                and v_sched_appt.Dept_Specialty_Name = 'Obstetrics and Gynecology'       
                and v_sched_appt.loc_Name like 'NYU LUTHERAN - %'
              )
          V_Appts
          where 
              rank = 1       
          --and V_Appts.Pat_ID = tmpPatNextAppt.Patient_ID
      )
    ;
    dbms_output.put_line('EPISODES NEXT APPT: ' || (SYSDATE - RUNDATE) * 24 * 60 * 60 || ' SECONDS'); RUNDATE := SYSDATE;
    -- OK, now that we have our Episodes, lets get to see what the status is of all flu shots for the patients. 
    insert into tmpPrenatalFluImmunizations -- select * from tmpPrenatalFluImmunizations where immunization_ID = 61 and status = 'Deferred' patient_ID = 'Z938854' delete from tmpPrenatalFluImmunizations
    select
    Immune_1.Immune_ID,
    tmpActivePregnancyEpisodes.Patient_ID,
    Immune_1.Immunzatn_ID,
    Immune_1.Order_ID,
    CLARITY_IMMUNZATN.Name,
    Immune_1.Immune_Date,
    Immune_1.Imm_CSN, 
    Immune_1.Entry_DTTM,
    ZC_IMMNZTN_STATUS.Name, 
    ZC_DEFER_REASON.Name
    from tmpActivePregnancyEpisodes

        inner join immune Immune_1
          on  
            Immune_1.Pat_Id = tmpActivePregnancyEpisodes.Patient_ID

        inner join CLARITY_IMMUNZATN
        on CLARITY_IMMUNZATN.IMMUNZATN_ID = Immune_1.IMMUNZATN_ID

        left outer join ZC_DEFER_REASON
          on 
            ZC_DEFER_REASON.DEFER_REASON_C = Immune_1.DEFER_REASON_C

        inner join ZC_IMMNZTN_STATUS 
          on  
            ZC_IMMNZTN_STATUS.IMMNZTN_STATUS_C = Immune_1.IMMNZTN_STATUS_C

    where 
      (
        CLARITY_IMMUNZATN.Name like '%FLU%' or 
        CLARITY_IMMUNZATN.Name like '%INFLUENZA%' or 
        CLARITY_IMMUNZATN.Immunzatn_ID = '61'
      )
    and ZC_IMMNZTN_STATUS.Name != 'Deleted'
    -- and tmpActivePregnancyEpisodes.Patient_ID = 'Z4466614'
    ;
    -- Most recent flu vaccine. 
    insert into tmpRecPrenatalFluImmunizations -- select * from tmpRecPrenatalFluImmunizations select * from tmpActivePregnancyEpisodes
    select distinct
    '',-- Immune_ID
    case when tmpPrenatalFluImmunizations.Immunization_ID != 61 then 'Influenza'
         when tmpPrenatalFluImmunizations.Immunization_ID = 61 then 'Tdap'
    end,
    tmpActivePregnancyEpisodes.Patient_ID, 
    '', -- Immunization_ID    
    '', -- Order_ID
    '', -- Order_description
    NULL, -- Adminitration_Date
    '', -- Immunization_Enc_ID 
    '', -- Immunization_Entry 
    '', --   Status          
    '',  --   Defer_Reason   
    NULL, -- Scanned doc date
    ''    -- Scanned doc reason
    from tmpActivePregnancyEpisodes -- tmpPrenatalFluImmunizations we use the active episodes because there are patients that do not have an influenza order but have a decline scanned document

      left join tmpPrenatalFluImmunizations
        on 
          tmpPrenatalFluImmunizations.Patient_ID = tmpActivePregnancyEpisodes.Patient_ID
    ;
    -- Now we get the most recent vaccine admin given and any other status that may have occured after the given. 
    update tmpRecPrenatalFluImmunizations
    set tmpRecPrenatalFluImmunizations.Immune_ID = 
      (
        select min (tmpPrenatalFluImmunizations.Immune_ID) from tmpPrenatalFluImmunizations

        inner join tmpActivePregnancyEpisodes
          on 
            tmpActivePregnancyEpisodes.Patient_ID = tmpPrenatalFluImmunizations.Patient_ID

      where 
          tmpPrenatalFluImmunizations.Patient_ID = tmpRecPrenatalFluImmunizations.PATIENT_ID
      and tmpPrenatalFluImmunizations.Status = 'Given'
      and tmpPrenatalFluImmunizations.Immunization_ID != 61
      and 
          (
            -- tmpPrenatalFluImmunizations.Adminitration_Date >= tmpActivePregnancyEpisodes.Start_Date or 
            tmpPrenatalFluImmunizations.Adminitration_Date >= EPIC_UTIL.EFN_DIN('09/01/2017') -- '09/01/2017 00:00:00'
          )
      )
    where 
      tmpRecPrenatalFluImmunizations.Immune_Type = 'Influenza'
     ; 
    update tmpRecPrenatalFluImmunizations
    set tmpRecPrenatalFluImmunizations.Immune_ID = 
      (
        select min (tmpPrenatalFluImmunizations.Immune_ID) from tmpPrenatalFluImmunizations

        inner join tmpActivePregnancyEpisodes
          on 
            tmpActivePregnancyEpisodes.Patient_ID = tmpPrenatalFluImmunizations.Patient_ID

      where 
          tmpPrenatalFluImmunizations.Patient_ID = tmpRecPrenatalFluImmunizations.PATIENT_ID
      and tmpPrenatalFluImmunizations.Status = 'Given'
      and tmpPrenatalFluImmunizations.Immunization_ID = 61
      and 
          (
            -- tmpPrenatalFluImmunizations.Adminitration_Date >= tmpActivePregnancyEpisodes.Start_Date or 
            tmpPrenatalFluImmunizations.Adminitration_Date >= EPIC_UTIL.EFN_DIN('09/01/2017') -- '09/01/2017 00:00:00'
          )
      )
    where 
      tmpRecPrenatalFluImmunizations.Immune_Type = 'Tdap'
     ; 
    -- For the vaccine admins not given , lets get the IDs.  
    update tmpRecPrenatalFluImmunizations
    set tmpRecPrenatalFluImmunizations.Immune_ID = 
      (
        select min (tmpPrenatalFluImmunizations.Immune_ID) from tmpPrenatalFluImmunizations

        inner join tmpActivePregnancyEpisodes
          on 
            tmpActivePregnancyEpisodes.Patient_ID = tmpPrenatalFluImmunizations.Patient_ID

      where 
          tmpPrenatalFluImmunizations.Patient_ID = tmpRecPrenatalFluImmunizations.PATIENT_ID
      and tmpPrenatalFluImmunizations.Status != 'Given'
      and tmpPrenatalFluImmunizations.Immunization_ID != 61
      and 
          (
            -- tmpPrenatalFluImmunizations.Adminitration_Date >= tmpActivePregnancyEpisodes.Start_Date or 
            tmpPrenatalFluImmunizations.Adminitration_Date >= EPIC_UTIL.EFN_DIN('09/01/2017') --'09/01/2017 00:00:00'
          )
      )
    where 
        tmpRecPrenatalFluImmunizations.Immune_ID is NULL
    and tmpRecPrenatalFluImmunizations.Immune_Type = 'Influenza'
    ;
    -- TDAPFor the vaccine admins not given , lets get the IDs.  
    update tmpRecPrenatalFluImmunizations
    set tmpRecPrenatalFluImmunizations.Immune_ID = 
      (
        select min (tmpPrenatalFluImmunizations.Immune_ID) from tmpPrenatalFluImmunizations

        inner join tmpActivePregnancyEpisodes
          on 
            tmpActivePregnancyEpisodes.Patient_ID = tmpPrenatalFluImmunizations.Patient_ID

      where 
          tmpPrenatalFluImmunizations.Patient_ID = tmpRecPrenatalFluImmunizations.PATIENT_ID
      and tmpPrenatalFluImmunizations.Status != 'Given'
      and tmpPrenatalFluImmunizations.Immunization_ID = 61
      and 
          (
            -- tmpPrenatalFluImmunizations.Adminitration_Date >= tmpActivePregnancyEpisodes.Start_Date or 
            tmpPrenatalFluImmunizations.Adminitration_Date >= EPIC_UTIL.EFN_DIN('09/01/2017') -- '09/01/2017 00:00:00'
          )
      )
    where 
        tmpRecPrenatalFluImmunizations.Immune_ID is NULL
    and tmpRecPrenatalFluImmunizations.Immune_Type = 'Tdap'
    ;
    -- Now that we have the Immune ID, lets get the rest of the data. select * from tmpPrenatalFluImmunizations -- 08/01/2017 Stopped here run below. 
    update tmpRecPrenatalFluImmunizations
    set
    (
    tmpRecPrenatalFluImmunizations.Immunization_ID,
    tmpRecPrenatalFluImmunizations.Order_ID,        
    tmpRecPrenatalFluImmunizations.Order_description, 
    tmpRecPrenatalFluImmunizations.Adminitration_Date,  
    tmpRecPrenatalFluImmunizations.Immunization_Enc_ID,  
    tmpRecPrenatalFluImmunizations.Immunization_Entry,  
    tmpRecPrenatalFluImmunizations.Status,              
    tmpRecPrenatalFluImmunizations.Defer_Reason
    )
    = 
    (
    --  select 
    --    tmpPrenatalFluImmunizations.Immunization_ID,
    --    tmpPrenatalFluImmunizations.Order_ID,
    --    tmpPrenatalFluImmunizations.Order_description,
    --    tmpPrenatalFluImmunizations.Adminitration_Date,
    --    tmpPrenatalFluImmunizations.Immunization_Enc_ID,
    --    tmpPrenatalFluImmunizations.Immunization_Entry,
    --    tmpPrenatalFluImmunizations.Status,
    --    tmpPrenatalFluImmunizations.Defer_Reason,
    --    rowNum()
    -- from tmpPrenatalFluImmunizations 
    -- 
    --   where 
    --      Prenatal_Flu_Immunizations.Patient_ID  = tmpRecPrenatalFluImmunizations.PATIENT_ID
    --  and Prenatal_Flu_Immunizations.Immune_ID   = tmpRecPrenatalFluImmunizations.Immune_ID
        select 
          Immunization_ID,
          Order_ID,
          Order_description,
          Adminitration_Date,
          Immunization_Enc_ID,
          Immunization_Entry,
          Status,
          Defer_Reason
        from 
          (
            select 
              Immunization_ID,
              Order_ID,
              Order_description,
              Adminitration_Date,
              Immunization_Enc_ID,
              Immunization_Entry,
              Status,
              Defer_Reason,
              row_number() over (partition by Patient_ID, Immune_ID order by Adminitration_Date desc) RANK
            from tmpPrenatalFluImmunizations    
            where 
                  tmpPrenatalFluImmunizations.Patient_ID = tmpRecPrenatalFluImmunizations.PATIENT_ID
              and tmpPrenatalFluImmunizations.Immune_ID  = tmpRecPrenatalFluImmunizations.Immune_ID
            ) Prenatal_Flu_Imm
        where 
          rank = 1
    )
    ;
    -- We need to check if the patient has signed a delcination of the immunizations. select * from tmpRecPrenatalFluImmunizations
    -- We have situations where the document of refusal has been scanned but there is no indication that influenza vaccine was refused.
    update tmpRecPrenatalFluImmunizations
    set 
    (
      Scanned_Reason,
      Scanned_Doc_Date
    )
    =
    (
       select 
          doc_info.doc_descr,
          doc_info.doc_Recv_Time
        from 
            (
              select 
               doc_pt_ID,
               doc_descr, 
               doc_Recv_Time,
              row_number()
              over (PARTITION BY doc_pt_ID
              order by doc_Recv_Time desc)
              rank
              from tmpActivePregnancyEpisodes 

              inner join doc_information 
                on 
                  doc_information.doc_pt_ID = tmpActivePregnancyEpisodes.Patient_ID
              and doc_information.doc_descr like 'REFUSAL OF IMMUNIZATION%'

               where 
                    tmpActivePregnancyEpisodes.PATIENT_ID = tmpRecPrenatalFluImmunizations.Patient_ID
                and 
                    (
                      (
                            tmpRecPrenatalFluImmunizations.Adminitration_Date is not NULL
                        and trunc (doc_information.Doc_recv_Time) = trunc (tmpRecPrenatalFluImmunizations.Adminitration_Date)    
                      ) 
                      or 
                      (
                            tmpRecPrenatalFluImmunizations.Adminitration_Date is NULL
                        and trunc (doc_information.Doc_recv_Time) >= trunc (tmpActivePregnancyEpisodes.Start_Date)
                      )
                    )
            ) Doc_Info
        where 
            rank = 1           
    )
    where 
      (
        tmpRecPrenatalFluImmunizations.Status != 'Given' or 
        tmpRecPrenatalFluImmunizations.Status is NULL
      )
    and 
      (
        tmpRecPrenatalFluImmunizations.Defer_Reason is NULL or 
        tmpRecPrenatalFluImmunizations.Defer_Reason = ''
      )
    ;
    -- Lets get the orders Proc Table -- select * from tmpPrenatalFluOrders
    insert into tmpPrenatalFluOrders -- drop table tmpPrenatalFluOrders delete from tmpPrenatalFluOrders
    select 
    Order_Proc.Order_Proc_ID,
    '', -- Medication_ID
    Order_Proc.Proc_ID,
    EAP_S.Proc_Code,
    tmpActivePregnancyEpisodes.Patient_ID,
    Order_Proc.Ordering_Date,
    ZC_ORDER_STATUS.Name,
    Clarity_Ser.Prov_Name,
    Order_Proc.Description
    from tmpActivePregnancyEpisodes

        inner join Order_Proc
          on 
            Order_Proc.Pat_ID = tmpActivePregnancyEpisodes.Patient_ID
            inner join clarity_eap eap_s on ORDER_PROC.PROC_ID = EAP_S.PROC_ID 

        left join ZC_ORDER_STATUS 
          on 
            ZC_ORDER_STATUS.ORDER_STATUS_C = Order_Proc.ORDER_STATUS_C

        left join Clarity_SER
          on 
            Clarity_SER.Prov_ID = Order_Proc.Authrzing_Prov_ID

    where 
      (
          Order_Proc.Ordering_Date >= EPIC_UTIL.EFN_DIN('08/01/2017') -- '08/01/2017 00:00:00' 
      and 
          (
            Order_Proc.Description like '%INFLUENZA VACCINE%' or 
            Order_Proc.Description like '%FLU VACCINE%'
          )
      )
      or 
      (
        Order_Proc.Description like '%TDAP%' or 
        Order_Proc.Description like '%Tdap%'
      )
     ;   
    -- And now to the order med table -- and now we get teh orders for the meds issued
    insert into tmpPrenatalFluOrders -- select * from tmpRecPrenatalFluImmunizations
    select 
    Order_Med.ORDER_MED_ID,
    Order_Med.Medication_ID,  -- We need this to determine the TDAP doses
    '',
    '',
    tmpRecPrenatalFluImmunizations.Patient_ID,
    Order_Med.ORDER_INST,
    ZC_ORDER_STATUS.Name,
    Clarity_Ser.Prov_Name,
    Order_Med.Description
    from tmpRecPrenatalFluImmunizations

       inner join Order_Med
          on 
            Order_Med.PAT_ID        = tmpRecPrenatalFluImmunizations.Patient_ID
        and Order_Med.Order_Med_ID  = tmpRecPrenatalFluImmunizations.ORDER_ID

        left join ZC_ORDER_STATUS 
          on 
            ZC_ORDER_STATUS.ORDER_STATUS_C = Order_Med.ORDER_STATUS_C

        left join Clarity_SER
          on 
            Clarity_SER.Prov_ID = Order_Med.Authrzing_Prov_ID
    where 
      Order_Med.ORDER_INST >= EPIC_UTIL.EFN_DIN('08/01/2017') -- '08/01/2017 00:00:00'
    ;   
    -- To do - Get the order ID
    insert into tmpPrenatalFluOrders -- drop table tmpPrenatalFluOrders select * from tmpPrenatalFluOrders
    select 
    Order_Proc.Order_Proc_ID,
    '', -- Medication ID
    Order_Proc.Proc_ID,
    eap_t.Proc_Code,
    tmpRecPrenatalFluImmunizations.Patient_ID,
    Order_Proc.Ordering_Date,
    ZC_ORDER_STATUS.Name,
    Clarity_Ser.Prov_Name,
    Order_Proc.Description
    from tmpRecPrenatalFluImmunizations

         inner join Order_Proc
          on 
            Order_Proc.Pat_ID         = tmpRecPrenatalFluImmunizations.Patient_ID
        and Order_Proc.ORDER_PROC_ID = tmpRecPrenatalFluImmunizations.ORDER_ID
        
        inner join clarity_eap eap_t on order_proc.proc_id = eap_t.proc_id

        left join ZC_ORDER_STATUS 
          on 
            ZC_ORDER_STATUS.ORDER_STATUS_C = Order_Proc.ORDER_STATUS_C

        left join Clarity_SER
          on 
            Clarity_SER.Prov_ID = Order_Proc.Authrzing_Prov_ID
     ;
     -- Now lets get the GBC lab values. delete from tmpPatLabTestResults
    insert into tmpPatLabTestResults
    select
    tmpActivePregnancyEpisodes.Patient_ID, 
    order_results.order_proc_ID, 
    eap_y.Proc_Code,        
    order_proc.description,
    ZC_ORDER_STATUS.Name,
    order_proc.Ordering_Date,
    order_results.Result_Date, 
    order_results.Ord_Value,
    order_results.Ord_Num_Value,
    ZC_LAB_STATUS.Name
    from tmpActivePregnancyEpisodes

        inner join order_proc
          on 
              order_proc.Pat_ID    = tmpActivePregnancyEpisodes.Patient_ID
           /* GROUP B STREPTOCOCCUS SCREEN */
          
          inner join clarity_eap eap_y on order_proc.proc_id = EAP_Y.PROC_ID and EAP_Y.proc_code = 'LAB1377'

        left outer join order_results
          on 
            order_results.order_proc_ID = order_proc.Order_Proc_ID

        left join ZC_ORDER_STATUS
          on  
              ZC_ORDER_STATUS.ORDER_STATUS_C = order_proc.ORDER_STATUS_C

        left join ZC_LAB_STATUS
          on  
            ZC_LAB_STATUS.LAB_STATUS_C = order_proc.LAB_STATUS_C
    where 
        Order_proc.ordering_Date >= EPIC_UTIL.EFN_DIN('08/01/2017');
    dbms_output.put_line('EPISODES IMMUNIZATIONS: ' || (SYSDATE - RUNDATE) * 24 * 60 * 60 || ' SECONDS'); RUNDATE := SYSDATE;
    END;
/*============================================================================================================================*/
/*============================================================================================================================*/
/*============================================================================================================================*/
    OPEN P_CURSOR FOR
      select distinct
        tmpActivePregnancyEpisodes.Episode_ID,
        tmpActivePregnancyEpisodes.Patient_ID,
        tmpActivePregnancyEpisodes.Patient_MRN,
        tmpActivePregnancyEpisodes.Patient_Name,
        tmpActivePregnancyEpisodes.Patient_DOB,
        tmpActivePregnancyEpisodes.Diabetic, 
        tmpActivePregnancyEpisodes.Hypertensive,
        tmpActivePregnancyEpisodes.Start_Date as Episode_Start_Date,
        tmpActivePregnancyEpisodes.First_Prenatal_Loc,
        tmpActivePregnancyEpisodes.First_Prenatal_Date,
        tmpActivePregnancyEpisodes.First_Prenatal_Trimester,
        First_Visit.Encounter_Department First_Prenatal_Department,
        tmpActivePregnancyEpisodes.First_Prenatal_Prov,
        First_Visit.Encounter_Date as First_Preg_Enc,
        Working_EDD,
        trunc((280 - (working_EDD - First_Visit.Encounter_Date))/7)||'w '||trunc(((280 - (working_EDD - First_Visit.Encounter_Date))/7-trunc((280 - (working_EDD - First_Visit.Encounter_Date))/7))*10)||'d' as First_Visit_GA,
        case 
            when (sysdate - working_EDD) >= 15 then NULL
            when (sysdate - working_EDD) < 14 then 
            trunc((280 - (working_EDD - sysdate))/7)||'w '||trunc(((280 - (working_EDD - sysdate))/7-trunc((280 - (working_EDD - sysdate))/7))*10)||'d' 
            end as Current_GA,
        ENCTOEPI_SDE.FHCOBRISKINITIAL,
        ENCTOEPI_SDE.FHCOBRISKINITIAL_VAL,
        ENCTOEPI_SDE.FHCOBRISKFOLLOWUP,
        ENCTOEPI_SDE.FHCOBRISKFOLLOWUP_VAL,
        EPISODE_SMARTPHRASE.FHCVBAC,
        EPISODE_SDE.EDU_BREASTFEEDING,
        EPISODE_SDE.EDU_MOVEMENT,
        EPISODE_SDE.EDU_EARLYDELIVERY,
        --LABS BLOCK
        EPISODE_ORD.LAB_HIV_FIRST_TRI,
        EPISODE_ORD.LAB_HIV_THIRD_TRI,
        EPISODE_ORD.LAB_CYSTIC_FIBROSIS,
        EPISODE_ORD.LAB_SMA,
        --FLOWSHEET BLOCK
        EPISODE_FLW_LAST.OB_FUNDAL_HEIGHT_DTTM,
        EPISODE_FLW_LAST.OB_FUNDAL_HEIGHT_VAL,
        EPISODE_FLW_LAST.OB_FHR_BASELINE_DTTM,
        EPISODE_FLW_LAST.OB_FHR_BASELINE_VAL,
        EPISODE_FLW_LAST.FETAL_MOVEMENT_DTTM,
        EPISODE_FLW_LAST.FETAL_MOVEMENT_VAL,
        EPISODE_FLW_LAST.OB_PRESENTATION_DTTM,
        EPISODE_FLW_LAST.OB_PRESENTATION_VAL,
        EPISODE_FLW_LAST.DOM_ABUSE_SCRN_DTTM,
        --FLU BLOCK
        FluOrders.Order_ID                as Flu_Order_ID,
        FluOrders.Order_Date              as Flu_Order_Date,
        FluOrders.Order_Description       as Flu_Order_Description, 
        FluOrders.Order_Status            as Flu_Order_Status,
        tmpFlu.Immune_ID                  as Flu_Immune_ID,
        --tmpFlu.Immunization_ID, 
        tmpFlu.Order_Description          as Flu_Admin_Description, 
        tmpFlu.Adminitration_Date         as Flu_Admin_Date, 
        tmpFlu.Status                     as Flu_Admin_Staus, 
        -- tmpFlu.Defer_Reason               as Flu_Defer_Reason,
        tmpFlu.Scanned_Doc_Date           as Flu_Defer_Scan_Date,
        tmpFlu.Scanned_Reason             as Flu_Scan_Date,
        TdapOrders.Order_ID               as Tdap_Order_ID,
        TdapOrders.Medication_ID          as Tdap_Medication_ID,
        TdapOrders.Order_Description      as Tdap_Order_Description,
        TdapOrders.Order_Date             as Tdap_Order_Date,
        TdapOrders.Order_Status           as Tdap_Order_Status,
        tmpTdap.Immune_ID                 as Tdap_Immune_ID,
        --tmpTdap.Immunization_ID, 
        tmpTdap.Order_Description         as Tdap_Admin_Description, 
        tmpTdap.Adminitration_Date        as Tdap_Admin_Date, 
        tmpTdap.Status                    as Tdap_Admin_Status, 
        -- tmpTdap.Defer_Reason              as Tdap_Defer_Reason,
        tmpTdap.Scanned_Doc_Date          as Tdap_Defer_Scan_Date,
        tmpTdap.Scanned_Reason            as Tdap_Defer_Reason,
        Lab_Results.Order_ID              as GBS_Order_ID,
        -- Lab_Results.Proc_Code,
        Lab_Results.Proc_Desription       as GBS_Description,
        Lab_Results.Order_Status          as GBS_Status,
        Lab_Results.Order_Date            as GBS_Ordered,
        Lab_Results.Result_Date           as GBS_Resulted,
        Lab_Results.Result_Value          as GBS_Result,
        -- Lab_Results.Result_Value_Desc,
        Lab_Results.Result_Status         as GBS_Result_Status,
        Last_Visit.Encounter_Date         as Last_Enc_Date,
        Last_Visit.Encounter_Location     as Last_Enc_Location,
        Last_Visit.Encounter_Provider     as Last_Enc_Provider,
        Last_Visit.Encounter_Prov_Type,
        Last_Visit.Supervising_Provider,
        Last_Visit.Encounter_ID,
        Last_Visit.Encounter_Visit_Type   as Last_Visit_Type,
        tmpPatNextAppt.Encounter_ID       as Next_Appt_CSN,
        tmpPatNextAppt.Encounter_Date     as Next_Appt_Date, 
        tmpPatNextAppt.Encounter_Location as Next_Appt_Location, 
        tmpPatNextAppt.Encounter_Provider as Next_Appt_Provider
        from tmpActivePregnancyEpisodes

          -- Lets get the most recent pregnancy data

          left join 
            (
              select 
                Patient_ID,
                Episode_ID, 
                Encounter_Date,
                Encounter_Location,
                Encounter_Provider, 
                  Encounter_Visit_Type,
                Encounter_Prov_Type,
                Supervising_Provider,
                Encounter_ID,
                row_number() over (partition by Patient_ID, Episode_ID order by Encounter_Date desc) RANK
              from tmpActivePregnancyVisits    
            ) Last_Visit ON LAST_VISIT.RANK = '1' 
            AND Last_visit.EPISODE_ID = tmpActivePregnancyEpisodes.Episode_ID  
            AND Last_visit.Patient_ID = tmpActivePregnancyEpisodes.Patient_ID
            -- and Last_visit.Encounter_Visit_Type in ('Initial Prenatal' , 'Office Visit', 'Routine Prenatal', 'Postpartum Visit')

            -- Lets get the most recent pregnancy data

          left join 
            (
              select 
                Patient_ID,
                Episode_ID, 
                Encounter_Date,
                Encounter_Department,
                Encounter_Location,
                Encounter_Provider, 
                Encounter_Visit_Type,
                row_number() over (partition by Patient_ID, EPISODE_ID order by Encounter_Date) RANK
              from tmpActivePregnancyVisits    
            ) First_Visit ON First_Visit.RANK = '1' 
            AND First_Visit.Episode_ID = tmpActivePregnancyEpisodes.Episode_ID  
            AND First_Visit.Patient_ID = tmpActivePregnancyEpisodes.Patient_ID
            -- and First_Visit.Encounter_Visit_Type in ('Initial Prenatal', 'Office Visit', 'Routine Prenatal', 'Postpartum Visit')

            -- Lets get the most recent order placed. 

            left join 
            (
              select 
                Order_ID,
                Medication_ID,
                Order_Date,
                Order_Description,
                Patient_ID,
                Order_Status,
                Proc_Code,
                row_number () over (partition by Patient_ID order by Order_Date) Rank
              from tmpPrenatalFluOrders 
              where 
                  (
                    tmpPrenatalFluOrders.Proc_Code != 'IMM61' or
                    tmpPrenatalFluOrders.Medication_ID = '239351' or -- FLU VAC QS 2016(4 YR UP)CD(PF) 60 MCG (15 MCG X 4)/0.5 ML IM SYRG
                    tmpPrenatalFluOrders.Medication_ID = '238711' or -- FLU VAC QS 2016-17(6-35MO)(PF) 30 MCG (7.5 MCG X 4)/0.25 ML IM SYRG
                    tmpPrenatalFluOrders.Medication_ID = '238714' or -- FLU VAC QS2016-17 36MOS UP(PF) 60 MCG (15 MCG X 4)/0.5 ML IM SYRG
                    tmpPrenatalFluOrders.Medication_ID = '238717' or -- FLU VAC TV 2016(18YR UP)RC(PF) 135 MCG (45 MCG X 3)/0.5 ML IM SOLN
                    tmpPrenatalFluOrders.Medication_ID = '238719' -- FLU VACCINE QS2016-17 36MOS UP 60 MCG (15 MCG X 4)/0.5 ML IM SUSP
                  )
            ) FluOrders on FluOrders.Rank = '1'
              and FluOrders.Patient_ID = tmpActivePregnancyEpisodes.Patient_ID

            -- Lets get the most recent order placed for TDAP

            left join 
            (
              select 
                Order_ID,
                Medication_ID,
                Order_Date,
                Order_Description,
                Patient_ID,
                Order_Status,
                Proc_Code,
                row_number () over (partition by Patient_ID order by Order_Date) Rank
              from tmpPrenatalFluOrders 
              where 
                    tmpPrenatalFluOrders.Proc_Code = 'IMM61' or
                    tmpPrenatalFluOrders.Medication_ID = '5000089' or --    DIPHTH,PERTUS(ACELL),TETANUS (BOOSTRIX) INJ ORDERABLE
                    tmpPrenatalFluOrders.Medication_ID = '201574'    or -- DIPHTH,PERTUS(ACELL),TETANUS 2.5-8-5 LF-MCG-LF/0.5ML IM SYRG
                    tmpPrenatalFluOrders.Medication_ID = '201575'    or --  DIPHTH,PERTUS(ACELL),TETANUS 2.5-8-5 LF-MCG-LF/0.5ML IM SUSP
                    tmpPrenatalFluOrders.Medication_ID = '135818'    or --  DIPHTHER,PERTUSS,TETANUS VAC
                    tmpPrenatalFluOrders.Medication_ID = '147414'    or -- DIPH,PERTUS(ACEL),TETANUS PEDI IM
                    tmpPrenatalFluOrders.Medication_ID = '147465'    or -- DIPHTH, PERTUS(ACELL), TETANUS IM
                    tmpPrenatalFluOrders.Medication_ID = '147467'    or -- DIPHTHERIA,PERTUSSIS,TETANUS IM
                    tmpPrenatalFluOrders.Medication_ID = '227724'    -- DIPHTH,PERTUS(ACELL),TETANUS IM
            ) 
              TdapOrders on TdapOrders.Rank = '1'
              and TdapOrders.Patient_ID = tmpActivePregnancyEpisodes.Patient_ID       

            -- This is where we need to get the most recent status of the admins, and given takes priority over all else. So if a patient has a given in due range followed by a deferred, 
            -- The given takes precedence. We do not need to do a top 1 - since this table only has one record of each immune type. 

            LEFT JOIN tmpRecPrenatalFluImmunizations tmpFlu
            on 
                tmpFlu.PATIENT_ID = tmpActivePregnancyEpisodes.Patient_ID 
            and tmpFlu.Immunization_ID != 61 -- Not TDAP          

          -- Now this is for TDAP We do not need to do a top 1 - since this table only has one record of each immune type. 

           LEFT JOIN tmpRecPrenatalFluImmunizations tmpTdap -- select * from tmpRecPrenatalFluImmunizations where immunization_ID = 61
            on 
                tmpTdap.PATIENT_ID = tmpActivePregnancyEpisodes.Patient_ID 
            and tmpTdap.Immunization_ID = 61 -- TDAP          

      --     left join tmpPrenatalFluOrders
      --      on 
      --        tmpPrenatalFluOrders.Patient_ID = tmpActivePregnancyEpisodes.Patient_ID

           left join 
            (
              select 
                Patient_ID,
                Order_ID,
                Proc_Code,
                Proc_Desription,
                Order_Status,
                Order_Date,
                Result_Date,
                Result_Value,
                Result_Value_Desc,
                Result_Status,
                row_number() over (partition by Patient_ID order by Order_Date desc) RANK
              from tmpPatLabTestResults    
           ) Lab_Results ON Lab_Results.RANK = '1' 
           AND Lab_Results.Patient_ID = tmpActivePregnancyEpisodes.Patient_ID
           -- and First_Visit.Encounter_Visit_Type in ('Initial Prenatal', 'Office Visit', 'Routine Prenatal', 'Postpartum Visit')   

          left join tmpPatNextAppt
            on 
              tmpPatNextAppt.Patient_ID = tmpActivePregnancyEpisodes.Patient_ID
          LEFT JOIN (
            SELECT EPISODE_ORP.EPISODE_ID
            ,MAX(CASE WHEN EPISODE_ORP.ORD_TRIMESTER = 'FIRST' AND EPISODE_ORP.CASE_HIV IS NOT NULL THEN EPISODE_ORP.ORDER_INST ELSE NULL END) LAB_HIV_FIRST_TRI
            ,MAX(CASE WHEN EPISODE_ORP.ORD_TRIMESTER = 'THIRD' AND EPISODE_ORP.CASE_HIV IS NOT NULL THEN EPISODE_ORP.ORDER_INST ELSE NULL END) LAB_HIV_THIRD_TRI
            ,MAX(CASE WHEN EPISODE_ORP.PROC_CODE IN ('LAB737','LAB21363') THEN EPISODE_ORP.ORDER_INST ELSE NULL END) LAB_CYSTIC_FIBROSIS
            ,MAX(CASE WHEN EPISODE_ORP.PROC_CODE IN ('LAB21058') THEN EPISODE_ORP.ORDER_INST ELSE NULL END) LAB_SMA
            FROM (
              SELECT 
              tmpActivePregnancyEpisodes.Episode_ID
              ,ORDER_PROC.ORDER_PROC_ID
              ,ORDER_PROC.PAT_ENC_CSN_ID
              ,ORDER_PROC.PAT_ID
              ,ORDER_PROC.ORDER_INST
              ,ORDER_PROC.RESULT_TIME
              ,CLARITY_EAP.PROC_ID
              ,CLARITY_EAP.PROC_CODE
              ,CLARITY_EAP.PROC_NAME
              ,CASE 
                WHEN ORDER_PROC.ORDER_INST >= tmpActivePregnancyEpisodes.WORKING_EDD - INTERVAL '280' DAY(3) AND ORDER_PROC.ORDER_INST < tmpActivePregnancyEpisodes.WORKING_EDD - INTERVAL '183' DAY(3)
                THEN 'FIRST'
                ELSE
                  CASE
                    WHEN ORDER_PROC.ORDER_INST >= tmpActivePregnancyEpisodes.WORKING_EDD - INTERVAL '182' DAY(3) AND ORDER_PROC.ORDER_INST < tmpActivePregnancyEpisodes.WORKING_EDD - INTERVAL '99' DAY(3)
                    THEN 'SECOND'
                    ELSE
                      CASE
                        WHEN ORDER_PROC.ORDER_INST >= tmpActivePregnancyEpisodes.WORKING_EDD - INTERVAL '98' DAY(3) AND ORDER_PROC.ORDER_INST <= tmpActivePregnancyEpisodes.WORKING_EDD
                        THEN 'THIRD'
                        ELSE NULL 
                      END
                  END
              END ORD_TRIMESTER
              ,CASE WHEN CLARITY_EAP.PROC_NAME LIKE '%HIV%' THEN 'HIV' ELSE NULL END CASE_HIV
              FROM ORDER_PROC
              INNER JOIN tmpActivePregnancyEpisodes ON ORDER_PROC.PAT_ID = tmpActivePregnancyEpisodes.Patient_ID
              AND ORDER_PROC.ORDER_INST >= tmpActivePregnancyEpisodes.WORKING_ESD AND ORDER_PROC.ORDER_INST < tmpActivePregnancyEpisodes.WORKING_EDD
              LEFT JOIN CLARITY_EAP ON ORDER_PROC.PROC_ID = CLARITY_EAP.PROC_ID
              WHERE ORDER_PROC.ORDER_STATUS_C = 5 /* NOT CANCELED */
              AND ORDER_PROC.RESULT_TIME IS NOT NULL
              AND ( 
                /* HIV Labs */
                CLARITY_EAP.PROC_CODE IN ('LAB3277','LAB3532','LAB10790','LAB2209','LAB2360','LAB103341','LAB10327','LAB1808','LAB2306')
                /* Cystic Fibrosis Labs */
                OR CLARITY_EAP.PROC_CODE IN ('LAB737','LAB21363')
                /* Spinal Suscular Atrophy Labs */
                OR CLARITY_EAP.PROC_CODE IN ('LAB21058')
              )
            ) EPISODE_ORP
            GROUP BY EPISODE_ORP.EPISODE_ID
          ) EPISODE_ORD ON tmpActivePregnancyEpisodes.EPISODE_ID = EPISODE_ORD.EPISODE_ID
      /* Encounter SDE translated to Episode SDE w/ workaround for the lack of unique SDE for FHCOBRISKINITIAL */
      LEFT JOIN (
        SELECT
        EPISODE_LINK.EPISODE_ID
        ,MIN(CASE WHEN SDE_PIVOT.NYU434 IS NOT NULL AND SDE_PIVOT.NYU970 IS NULL THEN PAT_ENC.CONTACT_DATE ELSE NULL END) FHCOBRISKINITIAL
        ,MIN(CASE WHEN SDE_PIVOT.NYU434 IS NOT NULL AND SDE_PIVOT.NYU970 IS NULL THEN SDE_PIVOT.NYU434_VAL ELSE NULL END) FHCOBRISKINITIAL_VAL
        ,MIN(CASE WHEN SDE_PIVOT.NYU434 IS NOT NULL AND SDE_PIVOT.NYU970 IS NOT NULL THEN PAT_ENC.CONTACT_DATE ELSE NULL END) FHCOBRISKFOLLOWUP
        ,MIN(CASE WHEN SDE_PIVOT.NYU434 IS NOT NULL AND SDE_PIVOT.NYU970 IS NOT NULL THEN SDE_PIVOT.NYU434_VAL ELSE NULL END) FHCOBRISKFOLLOWUP_VAL
        FROM PAT_ENC
        LEFT JOIN EPISODE_LINK ON PAT_ENC.PAT_ENC_CSN_ID = EPISODE_LINK.PAT_ENC_CSN_ID
        LEFT JOIN (
          SELECT SMRTDTA_ELEM_DATA.RECORD_ID_VARCHAR PAT_ID
          ,SMRTDTA_ELEM_DATA.CONTACT_SERIAL_NUM PAT_ENC_CSN_ID
          ,MAX(CASE WHEN SMRTDTA_ELEM_DATA.ELEMENT_ID = 'NYU#434' THEN 1 ELSE NULL END) NYU434
          ,MAX(CASE WHEN SMRTDTA_ELEM_DATA.ELEMENT_ID = 'NYU#434' THEN SMRTDTA_ELEM_VALUE ELSE NULL END) NYU434_VAL
          ,MAX(CASE WHEN SMRTDTA_ELEM_DATA.ELEMENT_ID = 'NYU#970' THEN 1 ELSE NULL END) NYU970
          FROM SMRTDTA_ELEM_DATA
          LEFT JOIN SMRTDTA_ELEM_VALUE ON SMRTDTA_ELEM_DATA.HLV_ID = SMRTDTA_ELEM_VALUE.HLV_ID
          WHERE SMRTDTA_ELEM_DATA.ELEMENT_ID IN ('NYU#434','NYU#970')
          GROUP BY SMRTDTA_ELEM_DATA.RECORD_ID_VARCHAR, SMRTDTA_ELEM_DATA.CONTACT_SERIAL_NUM
        ) SDE_PIVOT ON PAT_ENC.PAT_ID = SDE_PIVOT.PAT_ID
          AND PAT_ENC.PAT_ENC_CSN_ID = SDE_PIVOT.PAT_ENC_CSN_ID
        GROUP BY EPISODE_LINK.EPISODE_ID
      ) ENCTOEPI_SDE ON tmpActivePregnancyEpisodes.EPISODE_ID = ENCTOEPI_SDE.EPISODE_ID
      /* Episode Specific Smart Data Elements */
      LEFT JOIN (
        SELECT SMRTDTA_ELEM_DATA.RECORD_ID_NUMERIC EPISODE_ID
        ,MIN(CASE WHEN SMRTDTA_ELEM_DATA.ELEMENT_ID IN ('EPIC#OBC230', 'EPIC#OBC831', 'EPIC#OBC832') THEN TRUNC(SMRTDTA_ELEM_DATA.CUR_VALUE_DATETIME) ELSE NULL END) EDU_BREASTFEEDING
        ,MIN(CASE WHEN SMRTDTA_ELEM_DATA.ELEMENT_ID IN ('NYU#558', 'NYU#586', 'NYU#587') THEN TRUNC(SMRTDTA_ELEM_DATA.CUR_VALUE_DATETIME) ELSE NULL END) EDU_MOVEMENT
        ,MIN(CASE WHEN SMRTDTA_ELEM_DATA.ELEMENT_ID IN ('NYU#552', 'NYU#631', 'NYU#632') THEN TRUNC(SMRTDTA_ELEM_DATA.CUR_VALUE_DATETIME) ELSE NULL END) EDU_EARLYDELIVERY
        FROM SMRTDTA_ELEM_DATA
        WHERE (
          CONTEXT_NAME = 'EPISODE'
          AND SMRTDTA_ELEM_DATA.CUR_SOURCE_LQF_ID IN (92,93,94)
          AND SMRTDTA_ELEM_DATA.ELEMENT_ID IN ('EPIC#OBC230', 'EPIC#OBC831', 'EPIC#OBC832', 'NYU#558', 'NYU#586', 'NYU#587', 'NYU#552', 'NYU#631', 'NYU#632')
        )
        GROUP BY SMRTDTA_ELEM_DATA.RECORD_ID_NUMERIC
      ) EPISODE_SDE ON tmpActivePregnancyEpisodes.EPISODE_ID = EPISODE_SDE.EPISODE_ID
      LEFT JOIN (
        SELECT EPI_FLW_LAST.EPISODE_ID
        ,MAX(CASE WHEN EPI_FLW_LAST.FLO_MEAS_ID = '12401' THEN EPI_FLW_LAST.RECORDED_TIME ELSE NULL END) OB_FUNDAL_HEIGHT_DTTM
        ,MAX(CASE WHEN EPI_FLW_LAST.FLO_MEAS_ID = '12401' THEN EPI_FLW_LAST.MEAS_VALUE ELSE NULL END) OB_FUNDAL_HEIGHT_VAL
        ,MAX(CASE WHEN EPI_FLW_LAST.FLO_MEAS_ID = '12086' THEN EPI_FLW_LAST.RECORDED_TIME ELSE NULL END) OB_FHR_BASELINE_DTTM
        ,MAX(CASE WHEN EPI_FLW_LAST.FLO_MEAS_ID = '12086' THEN EPI_FLW_LAST.MEAS_VALUE ELSE NULL END) OB_FHR_BASELINE_VAL
        ,MAX(CASE WHEN EPI_FLW_LAST.FLO_MEAS_ID = '12403' THEN EPI_FLW_LAST.RECORDED_TIME ELSE NULL END) FETAL_MOVEMENT_DTTM
        ,MAX(CASE WHEN EPI_FLW_LAST.FLO_MEAS_ID = '12403' THEN EPI_FLW_LAST.MEAS_VALUE ELSE NULL END) FETAL_MOVEMENT_VAL
        ,MAX(CASE WHEN EPI_FLW_LAST.FLO_MEAS_ID = '12404' THEN EPI_FLW_LAST.RECORDED_TIME ELSE NULL END) OB_PRESENTATION_DTTM
        ,MAX(CASE WHEN EPI_FLW_LAST.FLO_MEAS_ID = '12404' THEN EPI_FLW_LAST.MEAS_VALUE ELSE NULL END) OB_PRESENTATION_VAL
        ,MAX(CASE WHEN EPI_FLW_LAST.FLO_MEAS_GRP_ID = '669658' THEN EPI_FLW_LAST.RECORDED_TIME ELSE NULL END) DOM_ABUSE_SCRN_DTTM
        FROM (
          SELECT EPISODE_LINK.EPISODE_ID
          ,IP_FLWSHT_REC.INPATIENT_DATA_ID
          ,IP_FLWSHT_MEAS.FSD_ID
          ,IP_FLO_GP_DATA.FLO_MEAS_ID
          ,IP_FLO_GP_DATA.FLO_MEAS_NAME
          ,IP_FLO_MEASUREMNTS.ID FLO_MEAS_GRP_ID
          ,IP_FLWSHT_MEAS.RECORDED_TIME
          ,IP_FLWSHT_MEAS.ENTRY_TIME
          ,IP_FLWSHT_MEAS.MEAS_VALUE
          --,TO_NUMBER(TRIM(REPLACE(UPPER(IP_FLWSHT_MEAS.MEAS_VALUE),'SECONDS',''))) MEAS_VALUE_NUM
          ,row_number() OVER (PARTITION BY EPISODE_LINK.EPISODE_ID, IP_FLWSHT_MEAS.FLO_MEAS_ID ORDER BY IP_FLWSHT_MEAS.RECORDED_TIME DESC) AS FLO_CNT
          FROM PAT_ENC
          LEFT JOIN EPISODE_LINK ON PAT_ENC.PAT_ENC_CSN_ID = EPISODE_LINK.PAT_ENC_CSN_ID
          LEFT JOIN IP_FLWSHT_REC ON PAT_ENC.INPATIENT_DATA_ID = IP_FLWSHT_REC.INPATIENT_DATA_ID
          LEFT JOIN IP_FLWSHT_MEAS ON IP_FLWSHT_REC.FSD_ID = IP_FLWSHT_MEAS.FSD_ID
          LEFT JOIN IP_FLO_GP_DATA ON IP_FLWSHT_MEAS.FLO_MEAS_ID = IP_FLO_GP_DATA.FLO_MEAS_ID
          LEFT JOIN IP_FLO_MEASUREMNTS ON IP_FLWSHT_MEAS.FLO_MEAS_ID = IP_FLO_MEASUREMNTS.MEASUREMENT_ID
            AND IP_FLO_MEASUREMNTS.ID = '669658'
          WHERE IP_FLWSHT_MEAS.FLO_MEAS_ID IN ('12401','12086','12403','12404')
          OR IP_FLO_MEASUREMNTS.ID IS NOT NULL 
        ) EPI_FLW_LAST
        WHERE EPI_FLW_LAST.FLO_CNT = 1
        GROUP BY EPI_FLW_LAST.EPISODE_ID
      ) EPISODE_FLW_LAST ON tmpActivePregnancyEpisodes.EPISODE_ID = EPISODE_FLW_LAST.EPISODE_ID
      LEFT JOIN (
        SELECT
        tmpActivePregnancyVisits.EPISODE_ID
        ,MAX(CASE WHEN CL_SPHR.SMARTPHRASE_NAME = 'FHCVBAC' THEN PAT_ENC.CONTACT_DATE ELSE NULL END) FHCVBAC
        from PAT_ENC
        INNER JOIN tmpActivePregnancyVisits ON PAT_ENC.PAT_ENC_CSN_ID = tmpActivePregnancyVisits.ENCOUNTER_ID
        LEFT JOIN HNO_INFO ON PAT_ENC.PAT_ENC_CSN_ID = HNO_INFO.PAT_ENC_CSN_ID
        LEFT JOIN NOTE_ENC_INFO ON HNO_INFO.NOTE_ID = NOTE_ENC_INFO.NOTE_ID
        LEFT JOIN NOTE_SMARTPHRASE_IDS ON NOTE_ENC_INFO.CONTACT_SERIAL_NUM = NOTE_SMARTPHRASE_IDS.NOTE_CSN_ID
        LEFT JOIN CL_SPHR ON NOTE_SMARTPHRASE_IDS.SMARTPHRASES_ID = CL_SPHR.SMARTPHRASE_ID
        WHERE CL_SPHR.SMARTPHRASE_NAME = 'FHCVBAC'
        GROUP BY tmpActivePregnancyVisits.EPISODE_ID
      ) EPISODE_SMARTPHRASE ON tmpActivePregnancyEpisodes.EPISODE_ID = EPISODE_SMARTPHRASE.EPISODE_ID ;
  --END;
END;
/