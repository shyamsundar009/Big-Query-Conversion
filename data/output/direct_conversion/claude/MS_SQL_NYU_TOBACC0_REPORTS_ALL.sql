
CREATE PROCEDURE "NYU_TOBACC0_REPORTS_ALL" 

( 
  @STARTDATE varchar(30),
  @ENDDATE varchar(30),
  @p_recordset CURSOR VARYING OUTPUT 
) 

AS

BEGIN
  DECLARE @start_dt varchar(30);
  DECLARE @end_dt varchar(30);

  SET @start_dt = CONVERT(date, @STARTDATE, 120);
  SET @end_dt = DATEADD(day, 1, CONVERT(date, @ENDDATE, 120));

  TRUNCATE table NYU_TOBACCO_MAIN_ALL_2;
  
  WITH HIST AS
  (
    SELECT DISTINCT 
      har.pat_id,
      har.hsp_account_id,
      har.adm_date_time,
      hx.contact_date,
      hx.IS_TOBACCO_USER,
      HX.tobacco_pak_per_dy,
      hx.tobacco_comment,
      hx.smoking_tob_use_c,
      hx.tobacco_used_years,
      hx.smoking_quit_date,
      hx.tobacco_user_c ,
      har.prim_enc_csn_id,
      peh.inp_adm_date,
      rank() over (partition BY har.hsp_account_id order by hx.contact_date DESC) rn 
    FROM hsp_account har
    LEFT JOIN social_hx hx ON har.pat_id = hx.pat_id
    LEFT JOIN pat_enc_hsp peh on peh.hsp_account_id = har.hsp_account_id 
        AND CONVERT(date, har.disch_date_time) >= CONVERT(date, hx.contact_date)
    WHERE har.adm_date_time IS NOT NULL
      AND har.acct_basecls_ha_c = 1
      AND har.disch_date_time >= @start_dt and har.disch_date_time <= @end_dt
  ),
  PHONE AS 
  (
    SELECT * 
    FROM
    (
      SELECT DISTINCT
        hh.hsp_account_id,
        hh.disch_date_time,
        vvv.enc_reason_name,
        vvv.contact_date,
        rank() over (partition BY hh.hsp_account_id order by vvv.contact_date) rn  
      FROM hsp_account hh
      JOIN hist ON hist.hsp_account_id = hh.hsp_account_id
      JOIN PAT_ENC_RSN_VISIT vvv ON vvv.pat_id = hh.pat_id
      WHERE vvv.enc_reason_name IN ('SUPPLEMENTAL') 
        AND vvv.CONTACT_DATE > CONVERT(date, hh.DISCH_DATE_TIME)
        AND hh.acct_basecls_ha_c = 1
        AND hh.adm_date_time IS NOT NULL
        AND vvv.contact_date IS NOT NULL
    ) t
    WHERE rn = 1
  ),
  COGNIT2 AS
  (
    SELECT
      hhh.hsp_account_id,
      MAX(upper(meas.meas_value)) AS cognit_value   
    FROM pat_enc hhh
    JOIN hist ON hist.hsp_account_id = hhh.hsp_account_id
    JOIN ip_flwsht_rec rec ON hhh.INPATIENT_DATA_ID = rec.INPATIENT_DATA_ID
    JOIN ip_flwsht_meas meas ON rec.fsd_id = meas.fsd_id
    JOIN IP_FLT_DATA FLT ON FLT.TEMPLATE_ID = meas.FLT_ID
    WHERE hhh.INPATIENT_DATA_ID IS NOT NULL  
      AND MEAS.FLO_MEAS_ID IN ('800169','910143')
      AND FLT.TEMPLATE_ID IN ('831380','910384')
      AND meas.meas_value IS NOT NULL
    GROUP BY hhh.hsp_account_id
  ),
  COMFORT AS
  (
    SELECT * 
    FROM
    (
      SELECT
        hh.hsp_account_id, 
        hh.prim_enc_csn_id,
        comf.code_status_c,
        comf.activated_inst AS COMFORT_DATE,
        comf.comments AS COMFORT,
        rank () over (partition BY hh.hsp_account_id order by comf.activated_inst) rn   
      FROM hsp_account hh
      JOIN hist ON hist.hsp_account_id = hh.hsp_account_id
      JOIN OCS_CODE_STATUS comf ON hh.prim_enc_csn_id = comf.patient_csn
      WHERE hh.acct_basecls_ha_c = 1   
        AND comf.CODE_STATUS_C = '308101'
    ) t
    WHERE rn = 1
  ),
  CESSATION AS  
  (
    SELECT DISTINCT
      hh.prim_enc_csn_id,
      proc.proc_code, 
      proc.description,
      ss.name AS order_status,
      proc.proc_ending_time AS Cessation_date
    FROM hsp_account hh
    JOIN hist ON hist.hsp_account_id = hh.hsp_account_id
    JOIN order_proc PROC ON hh.prim_enc_csn_id = proc.pat_enc_csn_id
    JOIN zc_order_status ss ON proc.order_status_c = ss.order_status_c
    WHERE hh.acct_basecls_ha_c = 1
      AND proc.proc_id = 41601  
      AND proc.order_status_c = 5
  ),
  EDUCATION AS
  (
    SELECT 
      os.pat_csn,
      os.instant_of_entry,
      tt.ttp_name,
      tit.name AS edu_status 
    FROM cl_pat_edu_os os
    JOIN hist ON hist.prim_enc_csn_id = os.pat_csn
    JOIN cl_pat_edu_title edu ON os.ped_id = edu.ped_id
    JOIN ip_edu_data tt ON edu.pat_title_id = tt.ttp_id
    LEFT JOIN ZC_PED_P_TIT_STATU tit ON edu.pat_title_status_c = tit.PED_P_TIT_STATU_C
    WHERE edu.pat_title_id = '661504'
  ),
  EDUCAT_POINTS AS
  (
    SELECT 
      main2.hsp_account_id,
      main2.pat_enc_csn_id,
      MAX(main2.Relev_of_quitting_response) AS Relev_of_quitting_response,
      MAX(main2.Relev_of_quitting_status) AS Relev_of_quitting_status,
      MAX(main2.Risk_of_health_response) AS Risk_of_health_response,
      MAX(main2.Risk_of_health_status) AS Risk_of_health_status,
      MAX(main2.Long_term_risk_response) AS Long_term_risk_response,
      MAX(main2.Long_term_risk_status) AS Long_term_risk_status,
      MAX(main2.Risk_for_other_response) AS Risk_for_other_response,
      MAX(main2.Risk_for_other_status) AS Risk_for_other_status,
      MAX(main2.Rewards_of_quitting_response) AS Rewards_of_quitting_response,
      MAX(main2.Rewards_of_quitting_status) AS Rewards_of_quitting_status,
      MAX(main2.Roadblocks_to_quitting_resp) AS Roadblocks_to_quitting_resp,
      MAX(main2.Roadblocks_to_quitting_status) AS Roadblocks_to_quitting_status,
      MAX(main2.Repetition_response) AS Repetition_response, 
      MAX(main2.Repetition_status) AS Repetition_status  
    FROM
    (
      SELECT 
        points.HSP_ACCOUNT_ID,
        POINTS.PAT_ENC_CSN_ID,
        CASE WHEN POINTS.POINTS_IED_ID IN ('805035', '914096', '661139') THEN POINTS.RESPONSE ELSE SPACE(3) END AS RELEV_OF_QUITTING_RESPONSE,   
        CASE WHEN POINTS.POINTS_IED_ID IN ('805035', '914096', '661139') THEN POINTS.STATUS ELSE SPACE(3) END AS RELEV_OF_QUITTING_STATUS,
        CASE WHEN points.points_ied_id='661315' THEN points.response ELSE SPACE(3) END AS Risk_of_health_response,    
        CASE WHEN points.points_ied_id='661315' THEN points.status ELSE SPACE(3) END AS Risk_of_health_status,
        CASE WHEN points.points_ied_id='660015' THEN points.response ELSE SPACE(3) END AS Long_term_risk_response,    
        CASE WHEN points.points_ied_id='660015' THEN points.status ELSE SPACE(3) END AS Long_term_risk_status,
        CASE WHEN points.points_ied_id='660089' THEN points.response ELSE SPACE(3) END AS Risk_for_other_response,     
        CASE WHEN POINTS.POINTS_IED_ID='660089' THEN POINTS.STATUS ELSE SPACE(3) END AS RISK_FOR_OTHER_STATUS,    
        CASE WHEN POINTS.POINTS_IED_ID IN ('801808', '911462', '660292') THEN POINTS.RESPONSE ELSE SPACE(3) END AS REWARDS_OF_QUITTING_RESPONSE,    
        CASE WHEN POINTS.POINTS_IED_ID IN ('801808', '911462', '660292') THEN POINTS.STATUS ELSE SPACE(3) END AS REWARDS_OF_QUITTING_STATUS,    
        CASE WHEN POINTS.POINTS_IED_ID IN ('804455', '913599', '660315') THEN POINTS.RESPONSE ELSE SPACE(3) END AS ROADBLOCKS_TO_QUITTING_RESP,     
        CASE WHEN POINTS.POINTS_IED_ID IN ('804455', '913599', '660315') THEN POINTS.STATUS ELSE SPACE(3) END AS ROADBLOCKS_TO_QUITTING_STATUS,    
        CASE WHEN POINTS.POINTS_IED_ID IN ('800521', '910448', '660709') THEN POINTS.RESPONSE ELSE SPACE(3) END AS REPETITION_RESPONSE,    
        CASE WHEN points.points_ied_id IN ('800521', '910448', '660709') THEN points.status ELSE SPACE(3) END AS Repetition_status    
      FROM
      (
        SELECT
          enc.HSP_ACCOUNT_ID,
          enc.PAT_ENC_CSN_ID,
          enc.ENC_TYPE_C,
          os.ped_id,
          ns.points_ied_id,
          ns.taught_at_ins,
          ns.response,
          st.name AS status,
          rank() over (partition BY enc.HSP_ACCOUNT_ID, enc.PAT_ENC_CSN_ID, ns.points_ied_id order by ns.taught_at_ins DESC) rn
        FROM pat_enc enc
        JOIN hist ON hist.hsp_account_id = enc.hsp_account_id 
        JOIN cl_pat_edu_os os ON enc.PAT_ENC_CSN_ID = os.pat_csn
        JOIN CL_PAT_EDU_LEARNER ns ON os.ped_id = ns.ped_id
        LEFT JOIN ZC_PED_CT_STATUS st ON ns.status_c = st.ped_ct_status_c
        WHERE ns.points_ied_id IN ('660015', '660089', '660292', '660315', '660709', '661139', '661315', 
                                   '800521', '801808', '804455', '805035', '914096', '911462', '913599', '910448')   
      ) points
      WHERE points.rn = 1
    ) main2
    GROUP BY main2.HSP_ACCOUNT_ID, main2.PAT_ENC_CSN_ID
  ),
  THERAPY AS
  (
    SELECT *
    FROM
    (
      SELECT
        proc.pat_enc_csn_id,
        proc.description AS therapy_description,
        proc.ordering_date,
        st.name AS therapy_status,
        qq.ord_quest_resp AS ord_quest_resp,
        proc.order_proc_id as order_id,
        rank() over (partition BY proc.pat_enc_csn_id order by proc.instantiated_time) rrr2  
      FROM order_proc PROC 
      JOIN hist ON hist.prim_enc_csn_id = proc.pat_enc_csn_id
      JOIN zc_order_status st ON proc.order_status_c = st.order_status_c
      LEFT JOIN ord_spec_quest qq ON proc.order_proc_id = qq.order_id AND qq.line = 1   
      WHERE proc.proc_id = 232422
        AND st.name IS NOT NULL
    ) t
    WHERE rrr2 = 1  
  ),
  THERAPY2 AS
  (
    SELECT *
    FROM
    (
      SELECT
        proc.pat_enc_csn_id,
        proc.description AS therapy_description2,
        proc.ordering_date AS ordering_date2,
        st.name AS therapy_status2,
        CASE 
          WHEN qq.ord_quest_resp IN ('Allergy to ALL NRT medications','Drug interaction with ALL NRT medications','Patient/Caregiver refusal',
                                       'Pregnant','Recent MI (1-2 weeks)', 'Temporary or permanent cognitive impairment')  
            THEN qq.ord_quest_resp
          ELSE ' ' 
        END AS ord_quest_resp2,
        rank() over (partition BY proc.pat_enc_csn_id order by proc.instantiated_time) rrr2  
      FROM order_proc PROC
      JOIN hist ON hist.prim_enc_csn_id = proc.pat_enc_csn_id
      JOIN zc_order_status st ON proc.order_status_c = st.order_status_c
      LEFT JOIN ord_spec_quest qq ON proc.order_proc_id = qq.order_id AND qq.line = 1
      WHERE proc.proc_id = 232422
        AND st.name IS NOT NULL    
    ) t
    WHERE rrr2 = 1
  ),
  THERAPY3 AS
  (
    SELECT *  
    FROM
    (
      SELECT 
        proc.pat_enc_csn_id,
        proc.description AS therapy_description3,
        proc.ordering_date AS ordering_date3,
        st.name AS therapy_status3,
        qq.ord_quest_resp AS ord_quest_resp3,
        proc.order_proc_id as order_id,
        rank() over (partition BY proc.pat_enc_csn_id order by proc.instantiated_time) rrr2
      FROM order_proc PROC 
      JOIN hist ON hist.prim_enc_csn_id = proc.pat_enc_csn_id
      JOIN zc_order_status st ON proc.order_status_c = st.order_status_c
      LEFT JOIN ord_spec_quest qq ON proc.order_proc_id = qq.order_id AND qq.line = 1
      WHERE proc.proc_id = 430872
        AND st.name IS NOT NULL
    ) t
    WHERE rrr2 = 1
  ),
  NOTHERAPY as 
  (
    SELECT
      proc.pat_enc_csn_id,
      proc.description AS therapy_description,
      proc.ordering_date,
      st.name AS therapy_status,
      qq.ord_quest_resp AS OTHER_REASON,
      PROC.ORDER_PROC_ID as order_id
    FROM order_proc PROC
    JOIN hist ON hist.prim_enc_csn_id = proc.pat_enc_csn_id
    JOIN zc_order_status st ON proc.order_status_c = st.order_status_c
    LEFT JOIN ord_spec_quest qq ON proc.order_proc_id = qq.order_id
    WHERE proc.proc_id = 232422 
      AND qq.ord_quest_resp <> 'Other'
  ),
  NOTHERAPY_DSCH as
  (  
    SELECT
      proc.pat_enc_csn_id,
      qq.ord_quest_resp AS other_on_discharge,
      proc.order_proc_id as order_id
    FROM order_proc PROC
    JOIN hist ON hist.prim_enc_csn_id = proc.pat_enc_csn_id 
    JOIN zc_order_status st ON proc.order_status_c = st.order_status_c
    LEFT JOIN ord_spec_quest qq ON proc.order_proc_id = qq.order_id
    WHERE proc.proc_id = 430872
      AND st.name IS NOT NULL
      AND qq.ord_quest_resp <> 'Other'
  ),
  avs as 
  (
    SELECT DISTINCT hsp_account_id
    FROM
    (
      SELECT DISTINCT 
        pe.pat_id, 
        pe.pat_enc_csn_id,
        pe.hsp_account_id,
        pe.avs_print_tm,
        hx.SMOKELESS_TOB_USE_C,
        hx.smoking_tob_use_c
      FROM pat_enc pe
      JOIN social_hx hx ON pe.pat_id = hx.pat_id
      JOIN hist ON hist.hsp_account_id = pe.hsp_account_id
      WHERE pe.avs_print_tm IS NOT NULL 
        AND (hx.SMOKELESS_TOB_USE_C IN (1, 2) OR 
             hx.smoking_tob_use_c IN (1, 2, 3, 4, 9, 10))
    ) t
  ),
  tob_screening as 
  (
    SELECT DISTINCT 
      pat_id,
      most_recent_screening
    FROM 
    (
      SELECT
        tr.pat_id,
        hx_aud_time,
        HX_AUD_ITEM,
        MAX(hx_aud_time) OVER (PARTITION BY tr.pat_id) most_recent_screening
      FROM HISTORY_AUDIT_TRL TR  
      JOIN hist ON hist.pat_id = tr.pat_id
      WHERE TR.HX_AUD_ITEM IN ('19291','19215','19213','19212','19211','19210','19209','19208','19207','19205')
    ) t
  )
  
INSERT INTO NYU_TOBACCO_MAIN_ALL_2
SELECT
  pp.PAT_MRN_ID AS PATIENT_MRN,
  hh.HSP_ACCOUNT_ID,
  hh.PRIM_ENC_CSN_ID,
  pp.pat_last_name AS PAT_LAST_NAME,  
  pp.pat_first_name AS PAT_FIRST_NAME,
  ss.name AS SEX,
  CONVERT(varchar(10), pp.birth_date, 101) AS BIRTH_DATE,
  DATEDIFF(YEAR, pp.BIRTH_DATE, Hh.ADM_DATE_TIME) AS PATIENT_AGE,
  COALESCE(hh.pat_zip, pp.zip) AS PAT_ZIP,
  ad.name AS ADMISSION_SOURCE,
  bk.name AS ETHNICITY,  
  race.name AS RACE,
  hist.smoking_tob_use_c AS SMOKING_TOB_USE_C,
  tob.name AS STATUS,
  hist.tobacco_used_years AS TOBACCO_USED_YEARS,
  hist.tobacco_comment AS TOBACCO_COMMENT,
  CONVERT(varchar(10), hist.smoking_quit_date, 101) AS SMOKING_QUIT_DATE,
  hist.tobacco_pak_per_dy AS TOBACCO_PAK_PER_DY,
  DATEDIFF(DAY, hist.smoking_quit_date, Hh.ADM_DATE_TIME) AS DAY_DIFFER,
  CASE WHEN enc4.tobacco_use_vrfy_YN = 'Y' THEN 'YES' ELSE 'NO' END AS TOBACCO_REVIEWED,
  cognit2.cognit_value AS COGNIT_VALUE,
  CONVERT(varchar(10), PHONE.contact_date, 101) AS PHONE_CONTACT_DATE,
  phone.enc_reason_name AS Post_Discharge_Phone_Call,  
  CONVERT(varchar(10), COMFORT.COMFORT_DATE, 101) AS COMFORT_DATE,
  COMFORT.COMFORT,
  CESSATION.PROC_CODE AS CESSATION_CODE,
  CESSATION.DESCRIPTION AS CESSATION,
  CESSATION.order_status AS ORDER_STATUS,  
  CONVERT(varchar(10), EDUCATION.instant_of_entry, 101) AS EDUCATION_DATE,
  EDUCATION.ttp_name AS EDUCATION_TITLE,
  EDUCAT_POINTS.Relev_of_quitting_response AS RELEV_OF_QUITTING_RESPONSE,
  EDUCAT_POINTS.Relev_of_quitting_status AS RELEV_OF_QUITTING_STATUS,  
  EDUCAT_POINTS.Risk_of_health_response AS RISK_OF_HEALTH_RESPONSE,
  EDUCAT_POINTS.Risk_of_health_status AS RISK_OF_HEALTH_STATUS,
  EDUCAT_POINTS.Long_term_risk_response AS LONG_TERM_RISK_RESPONSE,
  EDUCAT_POINTS.Long_term_risk_status AS LONG_TERM_RISK_STATUS,
  EDUCAT_POINTS.Risk_for_other_response AS RISK_FOR_OTHER_RESPONSE,
  EDUCAT_POINTS.Risk_for_other_status AS RISK_FOR_OTHER_STATUS,
  EDUCAT_POINTS.Rewards_of_quitting_response AS REWARDS_OF_QUITTING_RESPONSE,
  EDUCAT_POINTS.Rewards_of_quitting_status AS REWARDS_OF_QUITTING_STATUS,
  EDUCAT_POINTS.Roadblocks_to_quitting_resp AS ROADBLOCKS_TO_QUITTING_RESP,
  EDUCAT_POINTS.Roadblocks_to_quitting_status AS ROADBLOCKS_TO_QUITTING_STATUS,  
  EDUCAT_POINTS.Repetition_response AS REPETITION_RESPONSE,
  EDUCAT_POINTS.Repetition_status AS REPETITION_STATUS,
  EDUCATION.edu_status AS EDUCATION_STATUS,
  hh3.ip_admit_date_time AS IP_ADMIT_DATE,
  Hh.ADM_DATE_TIME AS Adm_date,
  CASE 
    WHEN ABS(DATEDIFF(DAY, hist.contact_date, hist.inp_adm_date)) < ABS(DATEDIFF(DAY, tob_screening.most_recent_screening, hist.inp_adm_date)) 
      THEN hist.contact_date
    ELSE tob_screening.most_recent_screening
  END AS closest_screening_admission,
  CASE 
    WHEN ABS(DATEDIFF(DAY, hist.contact_date, hist.inp_adm_date)) < ABS(DATEDIFF(DAY, tob_screening.most_recent_screening, hist.inp_adm_date))
      THEN DATEDIFF(DAY, hist.contact_date, hist.inp_adm_date)  
    ELSE DATEDIFF(DAY, tob_screening.most_recent_screening, hist.inp_adm_date)
  END AS time_between_scren_admission,
  Hh.disch_DATE_TIME AS Disch_date,  
  dd.name AS Disch_disposition,
  serv.ABBR AS Hospital_service_ABBR,
  serv.NAME AS HOSPITAL_SERVICE,
  adt.department_id AS ADMIT_DEP_ID,
  dep.department_name AS ADMIT_DEPARTMENT_NAME,
  Therapy.therapy_description AS "First NRT Order",
  therapy.ordering_date AS "First NRT Order Date",
  therapy.therapy_status AS "First Status",
  Therapy.ord_quest_resp AS "First Reason",
  CASE WHEN notherapy.OTHER_REASON <> therapy.ord_quest_resp THEN notherapy.OTHER_REASON END AS OTHER_REASON,
  CASE WHEN THERAPY_REASON2 IS NOT NULL THEN THERAPY_DESCRIPTION2 END AS "Valid NRT Order",  
  CASE WHEN THERAPY_REASON2 IS NOT NULL THEN ORDERING_DATE2 END AS "Valid NRT Order Date",
  CASE WHEN THERAPY_REASON2 IS NOT NULL THEN THERAPY_STATUS2 END AS "Valid Status",
  THERAPY_REASON2 AS "Valid Reason",
  Therapy3.therapy_description3 AS "Discharge Order", 
  therapy3.ordering_date3 AS "Order Date",
  therapy3.therapy_status3 AS "Status",
  Therapy3.ord_quest_resp3 AS "Reason",  
  CASE WHEN NOTHERAPY_DSCH.other_on_discharge <> therapy2.ord_quest_resp2 THEN NOTHERAPY_DSCH.other_on_discharge END AS other_on_discharge,  
  edg.ref_bill_code AS prim_diag,
  edg.dx_name AS prim_diag_description,
  Hh.disch_DATE_TIME AS dd_date,
  hh.disch_dept_id,
  hh.attending_prov_id,
  LOC.loc_name AS HOSPITAL_NAME,
  CASE WHEN avs.hsp_account_id IS NULL THEN 'No' ELSE 'Yes' END AS AVS,
  ROW_NUMBER() OVER (PARTITION BY pp.PAT_MRN_ID, hh.hsp_account_id ORDER BY hh.hsp_account_id, therapy.ordering_date, education.instant_of_entry DESC) AS rrr5  
FROM hsp_account hh
JOIN patient pp ON hh.pat_id = pp.pat_id
JOIN hsp_account_3 hh3 ON hh.hsp_account_id = hh3.hsp_account_id AND hh.combine_acct_id IS NULL  
JOIN hist ON hh.hsp_account_id = hist.hsp_account_id
JOIN pat_enc_4 enc4 ON hh.prim_enc_csn_id = enc4.pat_enc_csn_id  
JOIN clarity_adt adt ON hh.prim_enc_csn_id = adt.pat_enc_csn_id 
  AND adt.event_type_c = 1 
  AND adt.event_subtype_c <> 2
LEFT JOIN zc_patient_sex ss ON pp.sex_c = ss.patient_sex_c
LEFT JOIN CLARITY_DEP DEP ON hh.disch_dept_id = DEP.DEPARTMENT_ID
LEFT JOIN CLARITY_LOC LOC ON LOC.LOC_ID = DEP.REV_LOC_ID  
LEFT JOIN CLARITY_DEP DEPA ON DEPA.DEPARTMENT_ID = ADT.DEPARTMENT_ID
LEFT JOIN CLARITY_LOC LOCA ON LOCA.LOC_ID = DEPA.REV_LOC_ID
LEFT JOIN zc_smoking_tob_use tob ON hist.smoking_tob_use_c = tob.smoking_tob_use_c
LEFT JOIN cognit2 ON hh.hsp_account_id = cognit2.hsp_account_id
LEFT JOIN zc_pat_service serv ON hh.PRIM_SVC_HA_C = serv.hosp_serv_c
LEFT JOIN PHONE ON hh.hsp_account_id = PHONE.hsp_account_id
LEFT JOIN COMFORT ON hh.hsp_account_id = COMFORT.hsp_account_id
LEFT JOIN clarity_dep dep ON adt.department_id = dep.department_id  
LEFT JOIN CESSATION ON hh.prim_enc_csn_id = cessation.prim_enc_csn_id
LEFT JOIN pat_enc_hsp enc ON hh.prIm_enc_csn_id = enc.pat_enc_csn_id
LEFT JOIN zc_disch_disp dd ON enc.disch_disp_c = dd.disch_disp_c
LEFT JOIN education ON hh.prIm_enc_csn_id = education.pat_csn
LEFT JOIN zc_mc_adm_type ad ON hh.admission_type_c = ad.admission_type_c  
LEFT JOIN ethnic_background et ON pp.pat_id = et.pat_id AND et.line = 1
LEFT JOIN zc_ethnic_bkgrnd bk ON et.ETHNIC_BKGRND_C = bk.ETHNIC_BKGRND_C
LEFT JOIN patient_race pr ON pp.pat_id = pr.pat_id AND pr.line = 1
LEFT JOIN zc_patient_race race ON pr.patient_race_c = race.patient_race_c
LEFT JOIN hsp_acct_dx_list dx ON hh.hsp_account_id = dx.hsp_account_id AND dx.line = 1
LEFT JOIN clarity_edg edg ON dx.dx_id = edg.dx_id  
LEFT JOIN EDUCAT_POINTS ON hh.hsp_account_id = EDUCAT_POINTS.hsp_account_id
LEFT JOIN THERAPY ON hh.prim_enc_csn_id = THERAPY.pat_enc_csn_id
LEFT JOIN THERAPY2 ON hh.prim_enc_csn_id = THERAPY2.pat_enc_csn_id
LEFT JOIN THERAPY3 ON hh.prim_enc_csn_id = THERAPY3.pat_enc_csn_id
LEFT JOIN NOTHERAPY ON hh.prim_enc_csn_id = NOTHERAPY.pat_enc_csn_id AND therapy.order_id = notherapy.order_id
LEFT JOIN NOTHERAPY_DSCH ON hh.prim_enc_csn_id = NOTHERAPY_DSCH.pat_enc_csn_id AND therapy3.order_id = notherapy_dsch.order_id  
LEFT JOIN avs ON avs.hsp_account_id = hist.hsp_account_id
LEFT JOIN tob_screening ON tob_screening.pat_id = hist.pat_id
WHERE hh.acct_basecls_ha_c = 1
  AND hh.acct_class_ha_c <> 112 
  AND DATEDIFF(YEAR, pp.BIRTH_DATE, Hh.ADM_DATE_TIME) >= 18
  AND adt.department_id NOT IN (10530009, 10530010, 10800002, 10500315)
  AND hist.smoking_tob_use_c IN (1, 2, 3, 4, 8, 9, 10);

TRUNCATE table NYU_TOBACCO_MED_2;
INSERT INTO NYU_TOBACCO_MED_2
WITH medication1 AS 
(
  SELECT *
  FROM 
  (
    SELECT
      pp.PAT_MRN_ID AS patient_mrn,
      hh.hsp_account_id,
      hh.adm_date_time,
      hh.disch_date_time,
      ord.medication_id,
      ord.description,
      rec.grouper_id AS Grouper,
      it.grouper_name,
      ormode.title AS ordering_mode,
      orstatus.title AS Order_status,
      orroute.title AS Admin_route,
      ord.hv_discrete_dose AS Dose, 
      unit.title AS UNIT,
      freq.freq_name AS frequency,
      CONVERT(varchar(16), ii.taken_time, 120) AS taken_time,
      ii.comments,
      ii.mar_action_c,
      rslt.name AS ord_result,
      rsn.name AS reason,
      ord.order_med_id,
      DATEDIFF(DAY, CONVERT(date, ord.start_date), CONVERT(date, hh.ADM_DATE_TIME)) AS med_day_differ,
      ROW_NUMBER() OVER (PARTITION BY pp.PAT_MRN_ID, hh.hsp_account_id, ord.order_med_id ORDER BY taken_time DESC) AS rrr5
    FROM hsp_account hh
    JOIN order_med ord ON hh.prim_enc_csn_id = ord.pat_enc_csn_id
    JOIN mar_admin_info ii ON ord.order_med_id = ii.order_med_id AND ii.mar_action_c IN (1, 2, 115)
    JOIN GROUPER_RECORDS rec ON ord.medication_id = rec.grouper_rec_list
    JOIN PATIENT PP ON hh.PAT_ID = PP.PAT_ID
    LEFT JOIN zc_order_class orclass ON ord.order_class_c = orclass.order_class_c
    LEFT JOIN zc_ordering_mode ormode ON ord.ordering_mode_c = ormode.ordering_mode_c
    LEFT JOIN zc_order_status orstatus ON ord.order_status_c = orstatus.order_status_c
    LEFT JOIN zc_admin_route orroute ON ord.med_route_c = orroute.med_route_c
    LEFT JOIN zc_med_unit unit ON ord.dose_unit_c = unit.disp_qtyunit_c
    LEFT JOIN ip_frequency freq ON ord.hv_discr_freq_id = freq.freq_id
    LEFT JOIN zc_mar_rslt rslt ON ii.mar_action_c = rslt.result_c
    LEFT JOIN zc_mar_rsn rsn ON ii.reason_c = rsn.reason_c
    LEFT JOIN grouper_items it ON rec.grouper_id = it.grouper_id
    WHERE hh.acct_basecls_ha_c = 1
      AND rec.grouper_id = '5100000177'
      AND DATEDIFF(DAY, CONVERT(date, ord.start_date), CONVERT(date, hh.ADM_DATE_TIME)) < 3
      AND orstatus.title <> 'SENT'
      AND ord.order_class_c = 1
      AND (ii.comments NOT IN ('wrong order', 'Wrong order', 'WRONG ORDER') OR ii.comments IS NULL)
      AND hh.DISCH_DATE_TIME >= @start_dt AND hh.DISCH_DATE_TIME < @end_dt
  ) t
  WHERE rrr5 = 1
),  
medication2 AS
(
  SELECT *
  FROM
  (
    SELECT 
      pp.PAT_MRN_ID AS patient_mrn,
      hh.hsp_account_id,  
      hh.adm_date_time,
      hh.disch_date_time,
      ord.medication_id,
      ord.description,
      rec.grouper_id AS Grouper,
      it.grouper_name,
      ormode.title AS ordering_mode,
      orstatus.title AS Order_status,
      orroute.title AS Admin_route,
      ord.hv_discrete_dose AS Dose,
      unit.title AS UNIT,
      freq.freq_name AS frequency,
      CONVERT(varchar(16), ii.taken_time, 120) AS taken_time,
      ii.comments,
      ii.mar_action_c,
      rslt.name AS ord_result,
      rsn.name AS reason, 
      ord.order_med_id,
      DATEDIFF(DAY, CONVERT(date, ord.start_date), CONVERT(date, hh.ADM_DATE_TIME)) AS med_day_differ,
      ROW_NUMBER() OVER (PARTITION BY pp.PAT_MRN_ID, hh.hsp_account_id, ord.order_med_id ORDER BY ii.taken_time DESC) AS rrr6
    FROM hsp_account hh
    JOIN order_med ord ON hh.prim_enc_csn_id = ord.pat_enc_csn_id  
    JOIN medication1 ON medication1.order_med_id = ord.order_med_id
    JOIN GROUPER_RECORDS rec ON ord.medication_id = rec.grouper_rec_list
    JOIN mar_admin_info ii ON ord.order_med_id = ii.order_med_id AND ii.mar_action_c IN (1, 2, 115)
    JOIN PATIENT PP ON hh.PAT_ID = PP.PAT_ID
    LEFT JOIN zc_order_class orclass ON ord.order_class_c = orclass.order_class_c
    LEFT JOIN zc_ordering_mode ormode ON ord.ordering_mode_c = ormode.ordering_mode_c
    LEFT JOIN zc_order_status orstatus ON ord.order_status_c = orstatus.order_status_c
    LEFT JOIN zc_admin_route orroute ON ord.med_route_c = orroute.med_route_c
    LEFT JOIN zc_med_unit unit ON ord.dose_unit_c = unit.disp_qtyunit_c
    LEFT JOIN ip_frequency freq ON ord.hv_discr_freq_id = freq.freq_id 
    LEFT JOIN zc_mar_rslt rslt ON ii.mar_action_c = rslt.result_c
    LEFT JOIN zc_mar_rsn rsn ON ii.reason_c = rsn.reason_c
    LEFT JOIN grouper_items it ON rec.grouper_id = it.grouper_id
    WHERE hh.acct_basecls_ha_c = 1  
      AND rec.grouper_id = '5100000177'
      AND DATEDIFF(DAY, CONVERT(date, ord.start_date), CONVERT(date, hh.ADM_DATE_TIME)) < 3
      AND orstatus.title <> 'SENT'
      AND ord.order_class_c = 1
      AND rslt.name IN ('Patch Applied', 'Given')  
  ) t
  WHERE rrr6 = 1
)
SELECT
  medication1.patient_mrn AS "PATIENT_MRN",
  medication1.hsp_account_id AS "HSP_ACCOUNT_ID",
  CONVERT(varchar(16), medication1.adm_date_time, 120) AS "ADM_DATE_TIME",
  CONVERT(varchar(16), medication1.disch_date_time, 120) AS "DISCH_DATE_TIME",
  medication1.medication_id AS "MEDICATION_ID",
  medication1.description AS "DESCRIPTION",
  medication1.Grouper AS "GROUPER",
  medication1.grouper_name AS "GROUPER_NAME",
  medication1.ordering_mode AS "ORDERING_MODE",
  medication1.Order_status AS "ORDER_STATUS",
  medication1.Admin_route AS "ADMIN_ROUTE",
  medication1.Dose AS "DOSE",
  medication1.UNIT AS "UNIT",
  medication1.frequency AS "FREQUENCY",
  CASE 
    WHEN medication1.mar_action_c <> medication2.mar_action_c AND medication1.ord_RESULT <> medication2.ord_result 
      AND medication2.ord_result IN ('Given', 'Patch Applied')
      THEN medication2.taken_time
    ELSE medication1.taken_time
  END AS "MED_TAKEN_TIME",
  CASE 
    WHEN medication1.mar_action_c <> medication2.mar_action_c AND medication1.ord_RESULT <> medication2.ord_result
      AND medication2.ord_result IN ('Given', 'Patch Applied')
      THEN medication2.comments
    ELSE medication1.comments  
  END AS "MED_COMMENTS",
  CASE
    WHEN medication1.mar_action_c <> medication2.mar_action_c AND medication1.ord_RESULT <> medication2.ord_result
      AND medication2.ord_result IN ('Given', 'Patch Applied') 
      THEN medication2.ord_result
    ELSE medication1.ord_result
  END AS "MED_ORD_RESULT",
  CASE
    WHEN medication1.mar_action_c <> medication2.mar_action_c AND medication1.ord_RESULT <> medication2.ord_result
      AND medication2.ord_result IN ('Given', 'Patch Applied')
      THEN medication2.reason
    ELSE medication1.reason
  END AS "MED_REASON",
  ROW_NUMBER() OVER (PARTITION BY medication1.hsp_account_id ORDER BY medication1.order_med_id) AS "RRR10"
FROM medication1 
LEFT JOIN medication2 ON medication1.order_med_id = medication2.order_med_id;

DECLARE @p_recordset CURSOR;
SET @p_recordset = CURSOR FOR
WITH MAIN0 AS
(
  SELECT * FROM NYU_TOBACCO_MAIN_ALL_2
),
DISCH_MED AS
(
  SELECT all3.*
  FROM
  (
    SELECT all2.*,
      ROW_NUMBER() OVER (PARTITION BY all2.hsp_account_id ORDER BY all2.LAST_ADMIN_INST DESC) AS rrr
    FROM
    (
      SELECT
        hh.hsp_account_id,
        om.pat_enc_csn_id,
        om.medication_id,
        om.description,
        om.order_inst AS LAST_ADMIN_INST,
        gr.grouper_id
      FROM order_med om  
      JOIN pat_enc pe ON pe.pat_enc_csn_id = om.pat_enc_csn_id
      JOIN NYU_TOBACCO_MAIN_ALL_2 hh ON hh.hsp_account_id = pe.hsp_account_id
      JOIN GROUPER_MED_RECS gr ON gr.exp_meds_list_id = om.medication_id
      WHERE gr.grouper_id = '5100000177'
        AND om.ACT_ORDER_C = 1
        AND om.DISCON_TIME IS NULL
        AND om.order_status_c <> 4
        AND (om.order_class_c NOT IN (3, 6, 7, 45, 48) OR om.order_class_c IS NULL)
    ) all2  
  ) all3
  WHERE all3.rrr = 1
),
ref_proc AS
(
  SELECT DISTINCT
    pp.pat_enc_csn_id, 
    pp.proc_id,
    pp.description AS ref_proced,
    pp.ordering_date AS Ref_order_date,
    st.name AS ref_order_status,
    can.name AS reason_for_cancelation,
    hh.hsp_account_id
  FROM order_proc pp
  JOIN pat_enc pe ON pp.pat_enc_csn_id = pe.pat_enc_csn_id
  JOIN NYU_TOBACCO_MAIN_ALL_2 hh ON hh.hsp_account_id = pe.hsp_account_id
  LEFT JOIN zc_order_status st ON pp.order_status_c = st.order_status_c
  LEFT JOIN zc_reason_for_canc can ON pp.reason_for_canc_c = can.reason_for_canc_c
  WHERE pp.proc_id = 414701  
    AND pp.future_or_stand = 'S'
),
admit_dep AS  
(
  SELECT all1.*  
  FROM
  (
    SELECT
      adt.event_id,
      hh.hsp_account_id,
      adt.pat_enc_csn_id, 
      adt.next_out_event_id,
      adt.event_type_c,
      adt.department_id,
      dd.department_name,
      CONVERT(varchar(16), adt.effective_time, 110) AS effect_time,
      RANK() OVER (PARTITION BY hh.hsp_account_id ORDER BY adt.effective_time) AS ddd
    FROM NYU_TOBACCO_MAIN_ALL_2 hh 
    JOIN pat_enc_hsp peh ON peh.hsp_account_id = hh.hsp_account_id
    JOIN clarity_adt adt ON adt.pat_enc_csn_id = peh.pat_enc_csn_id
    JOIN clarity_dep dd ON adt.department_id = dd.department_id
    WHERE adt.event_subtype_c <> 2
      AND adt.event_time > CONVERT(date, '1/1/2016', 101)   
  ) all1
  WHERE ddd = 1  
),
next_admit_dep AS
(
  SELECT all1.* 
  FROM  
  (
    SELECT
      adt.event_id,
      peh.hsp_account_id,
      adt.pat_enc_csn_id,
      adt.next_out_event_id,
      adt.event_type_c,
      adt.department_id, 
      dd.department_name,
      CONVERT(varchar(16), adt.effective_time, 110) AS effect_time, 
      RANK() OVER (PARTITION BY hh.hsp_account_id ORDER BY adt.effective_time) AS ddd
    FROM NYU_TOBACCO_MAIN_ALL_2 hh
    JOIN pat_enc_hsp peh ON peh.hsp_account_id = hh.hsp_account_id
    JOIN clarity_adt adt ON peh.pat_enc_csn_id = adt.pat_enc_csn_id  
    JOIN clarity_dep dd ON adt.department_id = dd.department_id
    WHERE adt.event_subtype_c <> 2
      AND adt.event_time > CONVERT(date, '1/1/2016', 101)
      AND adt.department_id NOT IN (10500016, 10500364, 10800021)
  ) all1 
  WHERE ddd = 1
)  
SELECT 
  fff.*,
  CASE 
    WHEN "Discharge Medication" = 2 THEN 2
    WHEN "Valid Reason 2" = 2 THEN 2 
    WHEN "Discharge Medication" = 1 THEN 1
    WHEN "Valid Reason 2" = 1 THEN 1
    ELSE 0
  END AS "Total Discharge Numerator",
  CASE
    WHEN "Numerator for Education" = 2 THEN 2
    WHEN "Numerator for Education" = 0 THEN 0
    WHEN "Medication Numerator" = 0 THEN 0
    ELSE 1  
  END AS "Total Numerator",
  CASE 
    WHEN specific_override_reason IS NOT NULL AND "Patient Excluded" = '0' THEN 1
    WHEN specific_override_reason IS NULL AND "Patient Excluded" = '0' THEN 0
    ELSE 2
  END AS Referral_Refusal,
  CASE
    WHEN ref_order_date IS NOT NULL AND "Patient Excluded" = '0' THEN 1
    WHEN ref_order_date IS NULL AND "Patient Excluded" = '0' THEN 0
    ELSE 2
  END AS Referral_Agree  
FROM
(
  SELECT eee.*,
    CASE
      WHEN "Numerator for Medications" = 2 THEN 2
      WHEN SMOKING_TOB_USE_C IN (10, 2) THEN 2
      WHEN "Reason" IN ('Light Smoker (less than 5 cigarettes/day)', 'Drug interaction with ALL NRT medications',
                        'Patient/Caregiver refusal', 'Recent MI (1-2 weeks)', 'Temporary or permanent cognitive impairment',
                        'Allergy to ALL NRT medications', 'Pregnant', 'Other', 'Patient does not use tobacco') THEN 1
      ELSE 0
    END AS "Valid Reason 2"
  FROM  
  (
    SELECT ddd.*,
      CASE 
        WHEN "Numerator for Medications" = 2 THEN 2
        WHEN "Valid Reason 1" = 2 THEN 2
        WHEN "Numerator for Medications" = 1 THEN 1
        WHEN "Valid Reason 1" = 1 THEN 1
        ELSE 0
      END AS "Medication Numerator"
    FROM
    (
      SELECT ccc.*,
        CASE
          WHEN "Patient Excluded" = 1 THEN 2
          WHEN Relev_of_quitting_status IN ('Done', 'Active') THEN 1
          WHEN RISK_OF_HEALTH_STATUS IN ('Done', 'Active') THEN 1  
          WHEN LONG_TERM_RISK_STATUS IN ('Done', 'Active') THEN 1
          WHEN RISK_FOR_OTHER_STATUS IN ('Done', 'Active') THEN 1
          WHEN REWARDS_OF_QUITTING_STATUS IN ('Done', 'Active') THEN 1
          WHEN ROADBLOCKS_TO_QUITTING_STATUS IN ('Done', 'Active') THEN 1
          WHEN REPETITION_STATUS IN ('Done', 'Active') THEN 1
          ELSE 0
        END AS "Numerator for Education",
        CASE  
          WHEN "Patient Excluded" = 1 THEN 2
          WHEN SMOKING_TOB_USE_C IN (10, 2) THEN 2
          WHEN TOBACCO_COMMENT IS NOT NULL AND TOBACCO_PAK_PER_DY < 0.25 THEN 2
          WHEN MED_ORD_RESULT IS NULL THEN 0
          ELSE 1
        END AS "Numerator for Medications",
        CASE
          WHEN "Patient Excluded" = 1 THEN 2  
          WHEN SMOKING_TOB_USE_C IN (10, 2) THEN 2
          WHEN "First Reason" IN ('Light smoker (less than 5 cigarettes/day)', 'Patient/Caregiver refusal',
                                   'Recent MI (1-2 weeks)', 'Temporary or permanent cognitive impairment',
                                   'Drug interaction with ALL NRT medications', 'Pregnant', 'Other',
                                   'Patient does not use tobacco') THEN 1
          ELSE 0  
        END AS "Valid Reason 1"
      FROM
      (
        SELECT bbb.*,
          CASE
            WHEN "LOS <1.5" = 1 THEN 2  
            WHEN "Cognitive Impairment" = 1 THEN 2
            WHEN "Comfort Measure Exclusions" = 1 THEN 2
            WHEN SMOKING_TOB_USE_C IN (1, 4, 2, 10, 9, 5, 7, 3) THEN 1
            ELSE 0
          END AS "Screening",
          CASE  
            WHEN "LOS <1.5" = 1 THEN 1
            WHEN "Status Exclusion" = 1 THEN 1
            WHEN "Cognitive Impairment" = 1 THEN 1
            WHEN "Comfort Measure Exclusions" = 1 THEN 1
            ELSE 0
          END AS "Patient Excluded"  
        FROM
        (
          SELECT aaa.*,
            CASE WHEN aaa.TTM2c = '1' AND Rx_or_Reason_for_no = '1' THEN '1' ELSE '0' END AS TTM2,
            CASE WHEN aaa.TTM2b = '1' AND TTM2c = '1' THEN '1' ELSE '0' END AS TTM2a,
            DATEDIFF(SECOND, IP_ADMIT_DATE, DISCH_DATE) / 86400.0 AS LOS,
            CASE WHEN DATEDIFF(SECOND, IP_ADMIT_DATE, DISCH_DATE) / 86400.0 < 1.5 THEN 1 ELSE 0 END AS "LOS <1.5", 
            CASE 
              WHEN COGNIT_VALUE IS NULL THEN 0
              WHEN LOWER(COGNIT_VALUE) LIKE 'ex%' THEN 1
              ELSE 0
            END AS "Cognitive Impairment",
            CASE WHEN comfort IS NULL THEN 0 ELSE 1 END AS "Comfort Measure Exclusions",
            CASE  
              WHEN SMOKING_TOB_USE_C IS NULL THEN 1
              WHEN SMOKING_TOB_USE_C IN (4, 7, 5, 6, 8) THEN 1
              ELSE 0
            END AS "Status Exclusion",
            CASE
              WHEN DISCH_DISPOSITION IN ('Discharged to Children''s Hospital', 'Discharged to Other Facility', 
                                         'Expired', 'Federal Hospital', 'Hospice/Home', 'Hospice/Medical Facility',
                                         'Left Against Medical Advice', 'Long Term Care', 'Psychiatric Hospital',
                                         'Rehab Facility', 'Short Term Hospital', 'Skilled Nursing Facility',
                                         'Acute Rehab Facility') THEN 2
              WHEN DISCHARGE_MEDICATION IS NULL THEN 0  
              WHEN PRIM_ENC_CSN_ID IS NULL THEN 0
              ELSE 1
            END AS "Discharge Medication"
          FROM  
          (
            SELECT DISTINCT
              main0.*, 
              med.medication_id,
              med.description,
              med.grouper,
              med.grouper_name,
              med.ordering_mode,
              med.med_order_status, 
              med.admin_route,
              med.dose,
              med.unit,
              med.frequency,
              med.med_taken_time,
              med.med_comments,
              med.med_ord_result,  
              med.med_reason,
              CASE 
                WHEN Relev_of_quitting_status = 'Done' AND
                     Risk_of_health_status = 'Done' AND
                     Long_term_risk_status = 'Done' AND  
                     Risk_for_other_status = 'Done' AND
                     Rewards_of_quitting_status = 'Done' AND
                     Roadblocks_to_quitting_status = 'Done' AND
                     Repetition_status = 'Done' THEN '1' 
                ELSE '0'
              END AS TTM2c,
              CASE WHEN "Valid NRT Order" IS NOT NULL OR med.med_ord_result IS NOT NULL THEN '1' ELSE '0' END AS Rx_or_Reason_for_no, 
              CASE WHEN med.med_ord_result IS NOT NULL THEN '1' ELSE '0' END AS TTM2b,
              CASE 
                WHEN CONVERT(date, ADM_DATE) >= CONVERT(date, '04-dec-2013', 103) THEN '2'
                ELSE '1'  
              END AS "Nurse intervention",
              CASE
                WHEN CONVERT(date, ADM_DATE) >= CONVERT(date, '02-jul-2014', 103) THEN '3'
                WHEN CONVERT(date, ADM_DATE) < CONVERT(date, '29-may-2013', 103) THEN '1'
                WHEN CONVERT(date, ADM_DATE) < CONVERT(date, '02-jul-2014', 103) AND
                     CONVERT(date, ADM_DATE) >= CONVERT(date, '29-may-2013', 103) THEN '2'  
              END AS "Provider intervention",
              disch_med.description AS discharge_medication,
              disch_med.LAST_ADMIN_INST AS LAST_ADMIN_INST,
              CASE WHEN ref_proc.Ref_order_date IS NOT NULL THEN 'Y' ELSE 'N' END AS Ref_ORDER_OCCURED,
              ref_proc.ref_proced, 
              ref_proc.Ref_order_date,
              ref_proc.reason_for_cancelation,
              ref_proc.ref_order_status,
              refused.alert_action_date,
              refused.bpa_name,
              refused.specific_override_reason,
              CASE 
                WHEN admit_dep.department_id NOT IN (10500364, 10800021, 10500016)
                  THEN admit_dep.department_name
                ELSE next_admit_dep.department_name  
              END AS admit_dept,
              dep.department_name AS Disch_department,
              ser.prov_name AS Attend_PHY
            FROM main0
            LEFT JOIN NYU_TOBACCO_MED_2 med ON main0.hsp_account_id = med.hsp_account_id
            LEFT JOIN disch_med ON main0.hsp_account_id = disch_med.hsp_account_id
            LEFT JOIN ref_proc ON main0.hsp_account_id = ref_proc.hsp_account_id
            LEFT JOIN (
                        SELECT DISTINCT 
                          pe.hsp_account_id,
                          ff.*  
                        FROM v_cube_f_alert ff
                        JOIN pat_enc pe ON ff.pat_enc_csn_id = pe.pat_enc_csn_id
                        WHERE ff.bpa_name = 'NYU IPO OPT TO QUIT BASE'
                          AND ff.bpa_trigger_action = 'Open Patient Chart'
                          AND ff.specific_override_reason = 'Patient Refused'
                      ) refused ON main0.hsp_account_id = refused.hsp_account_id
            LEFT JOIN clarity_dep dep ON main0.disch_dept_id = dep.department_id
            LEFT JOIN clarity_ser ser ON main0.attending_prov_id = ser.prov_id  
            LEFT JOIN admit_dep ON main0.hsp_account_id = admit_dep.hsp_account_id
            LEFT JOIN next_admit_dep ON main0.hsp_account_id = next_admit_dep.hsp_account_id
          ) aaa  
        ) bbb
      ) ccc
    ) ddd
  ) eee
) fff;

OPEN @p_recordset;

END;
