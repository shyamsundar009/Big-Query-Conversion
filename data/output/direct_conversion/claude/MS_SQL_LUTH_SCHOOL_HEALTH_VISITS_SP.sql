
CREATE PROCEDURE LUTH_SCHOOL_HEALTH_VISITS_SP
(
  @BEG_DATE VARCHAR(255),
  @END_DATE VARCHAR(255),
  @R_TYPE VARCHAR(255)
)
AS
BEGIN

DECLARE @BEG_DT DATE, @END_DT DATE;
SELECT @BEG_DT = CAST(@BEG_DATE AS DATE), @END_DT = CAST(@END_DATE AS DATE);

WITH Enrollment_Status AS (
  SELECT DISTINCT 
    di.doc_pt_id,
    di.doc_info_id,
    di.doc_info_type_c,
    zdit.name AS Doc_Info_Type,
    di.doc_stat_c,
    zds.name AS Doc_Stat,
    di.doc_recv_time AS Doc_dt
  FROM doc_information di
  LEFT JOIN zc_doc_info_type zdit ON zdit.doc_info_type_c = di.doc_info_type_c  
  LEFT JOIN zc_doc_stat zds ON zds.doc_stat_c = di.doc_stat_c
  WHERE di.doc_info_type_c = '200164' AND di.doc_stat_c = '100121'
),
Anticipatory_Guidance AS (
  SELECT DISTINCT
    sed.pat_link_id,
    sed.cur_value_datetime,
    CASE 
      WHEN sev.smrtdta_elem_value = '0' THEN 'F'
      WHEN sev.smrtdta_elem_value = '1' THEN 'T'
      ELSE 'U'
    END AS TF
  FROM smrtdta_elem_value sev
  LEFT JOIN smrtdta_elem_data sed ON sed.hlv_id = sev.hlv_id
  WHERE sed.element_id IN ('EPIC#43526','EPIC#38910','EPIC#38914')  
)
SELECT DISTINCT
  FORMAT(DATEADD(MONTH, -1, GETDATE()),'MMMM yyyy') AS Report_Month,
  CASE 
    WHEN pe.department_id IN (10802010,10795005) THEN 'PS 1'
    WHEN pe.department_id IN (10802012,10795006) THEN 'PS 10'  
    WHEN pe.department_id IN (10802014,10795007) THEN 'PS 15'
    WHEN pe.department_id IN (10802023,10802043) THEN 'PS 24'
    WHEN pe.department_id IN (10802033) THEN 'PS 94'
    WHEN pe.department_id IN (10802018) THEN 'PS 169'
    WHEN pe.department_id IN (10802019,10795008) THEN 'PS 172'  
    WHEN pe.department_id IN (10802026,10795009) THEN 'PS.MS 282'
    WHEN pe.department_id IN (10802028,10795010) THEN 'PS 307/MS 313'
    WHEN pe.department_id IN (10795016) THEN 'PS 329'
    WHEN pe.department_id IN (10802030,10795011) THEN 'PS 503/PS 506'
    WHEN pe.department_id IN (10802006,10795003) THEN 'IS 88'
    WHEN pe.department_id IN (10802039,10795013,10802045) THEN 'PS 188'
    WHEN pe.department_id IN (10802003,10795004) THEN 'Dewey JHS 136/MS 821'  
    WHEN pe.department_id IN (10802008) THEN 'Pershing JHS 220'
    WHEN pe.department_id IN (10802005,10795002) THEN 'Erasmus Campus'  
    WHEN pe.department_id IN (10802038,10795014) THEN 'George Wingate HS'
    WHEN pe.department_id IN (10802036,10795015) THEN 'Sunset Park High School'
    WHEN pe.department_id IN (10802001,10795001) THEN 'Boys & Girls Campus'
    WHEN pe.department_id IN (10795017,10802054) THEN 'Juan Morel'
    WHEN pe.department_id IN (10802011,10795018) THEN 'LSH Abraham Peds'
    WHEN pe.department_id IN (10802053,10795019) THEN 'South Shore Campus'
    WHEN pe.department_id IN (10802050,10795020) THEN 'Sheepshead Bay Peds'
    ELSE 'Not Defined' 
  END AS Facility,
  pat.pat_mrn_id,
  CASE 
    WHEN dep.specialty = 'Behavioral Health' OR UPPER(dep.specialty) = 'SOCIAL SERVICES' THEN 'Behavioral'
    ELSE 'Medical'
  END AS Group_Name,
  pe.pat_enc_csn_id,
  pe.hsp_account_id, 
  pe.contact_date,
  pe.enc_type_c,
  zdet.name AS Enc_Type,
  1 AS Visit,
  pat.pat_last_name,
  pat.pat_first_name,
  pat.birth_date,
  zs.name AS Sex,
  pe.appt_prc_id,
  prc.PRC_NAME AS Visit_type,
  pat.REC_CREATE_DATE AS mrn_create_dt,
  CASE 
    WHEN es.doc_stat IS NULL THEN 'Not Enrolled'
    ELSE es.doc_stat
  END AS Enroll_Status,
  es.doc_dt
FROM pat_enc pe
JOIN patient pat ON pat.pat_id = pe.pat_id
LEFT JOIN patient_3 pat3 ON pat3.pat_id = pe.pat_id  
LEFT JOIN Enrollment_Status es ON es.doc_pt_id = pe.pat_id
LEFT JOIN zc_disp_enc_type zdet ON zdet.disp_enc_type_c = pe.enc_type_c
LEFT JOIN zc_sex zs ON zs.rcpt_mem_sex_c = pat.sex_c  
LEFT JOIN clarity_dep dep ON dep.department_id = pe.department_id
LEFT JOIN clarity_prc prc ON prc.prc_id = pe.APPT_PRC_ID  
WHERE pe.hsp_account_id IS NOT NULL
  AND pat.pat_name NOT LIKE 'ZZ%'
  AND (pat3.is_test_pat_yn IS NULL OR pat3.is_test_pat_yn = 'N')
  AND pe.enc_type_c IN ('2','101','108','210','1000','1003','1200','1201','1214','2100','2500',
    '2501','2527','156003','156004','2101','156015')  
  AND (pe.APPT_STATUS_C IS NULL OR pe.APPT_STATUS_C IN ('1','2','6'))
  AND pe.contact_date >= @BEG_DT AND pe.contact_date < DATEADD(DAY, 1, @END_DT)
  AND dep.rev_loc_id IN (10795, 10802);

END
