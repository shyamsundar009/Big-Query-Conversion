CREATE OR REPLACE PROCEDURE LUTH_SCHOOL_HEALTH_VISITS_SP

(
  BEG_DATE IN VARCHAR2
, END_DATE IN VARCHAR2
, R_TYPE  IN VARCHAR2
, P_RECORDSET OUT SYS_REFCURSOR

)

AS

BEGIN

DECLARE

BEG_DT DATE;
END_DT DATE;

BEGIN

OPEN  P_RECORDSET FOR

 With Enrollment_Status as
(Select Distinct
di.doc_pt_id,
di.doc_info_id,
di.doc_info_type_c,
zdit.name as Doc_Info_Type,
di.doc_stat_c,
zds.name as Doc_Stat,
di.doc_recv_time as Doc_dt
from doc_information di
left outer join zc_doc_info_type zdit
on zdit.doc_info_type_c = di.doc_info_type_c
left outer join zc_doc_stat zds
on zds.doc_stat_c = di.doc_stat_c
where di.doc_info_type_c = '200164'
  and di.doc_stat_c = '100121'
)
,
Anticipatory_Guidance as
(Select Distinct
--sev.hlv_id,
--sev.line,
sed.pat_link_id,
--sed.element_id,
sed.cur_value_datetime,
--sev.smrtdta_elem_value,
Case
When sev.smrtdta_elem_value = '0'
then 'F'
When sev.smrtdta_elem_value = '1'
then 'T'
else 'U'
End as TF
from smrtdta_elem_value sev
left outer join smrtdta_elem_data sed
on sed.hlv_id = sev.hlv_id
where sed.element_id in ('EPIC#43526','EPIC#38910','EPIC#38914')
)
Select DISTINCT
to_char(ADD_MONTHS(SYSDATE, -1),'Month yyyy') as Report_Month,
--TO_CHAR(sysdate - 5,'YYYY') as Report_Year,
--TO_CHAR(TRUNC(sysdate,'Q')- 1,'Q') as Report_Qtr,
Case
When pe.department_id in (10802010,10795005)
then 'PS 1'
When pe.department_id in (10802012,10795006)
then 'PS 10'
When pe.department_id in (10802014,10795007)
then 'PS 15'
When pe.department_id in (10802023,10802043)
then 'PS 24'
When pe.department_id in (10802033)
then 'PS 94'
When pe.department_id in (10802018)
then 'PS 169'
When pe.department_id in (10802019,10795008)
then 'PS 172'
When pe.department_id in (10802026,10795009)
then 'PS.MS 282'
When pe.department_id in (10802028,10795010)
then 'PS 307/MS 313'
When pe.department_id in (10795016)
then 'PS 329'
When pe.department_id in (10802030,10795011)
then 'PS 503/PS 506'
When pe.department_id in (10802006,10795003)
then 'IS 88'
When pe.department_id in (10802039,10795013,10802045)
then 'PS 188'
When pe.department_id in (10802003,10795004)
then 'Dewey JHS 136/MS 821'
When pe.department_id in (10802008)
then 'Pershing JHS 220'
When pe.department_id in (10802005,10795002)
then 'Erasmus Campus'
When pe.department_id in (10802038,10795014)
then 'George Wingate HS'
When pe.department_id in (10802036,10795015)
then 'Sunset Park High School'
When pe.department_id in (10802001,10795001)
then 'Boys & Girls Campus'
when pe.department_id in (10795017,10802054)
then 'Juan Morel'
when pe.department_id in (10802011,10795018)
then 'LSH Abraham Peds'
when pe.department_id in(10802053,10795019)
then 'South Shore Campus'
when pe.department_id in(10802050,10795020)
then 'Sheepshead Bay Peds'
else 'Not Defined'
End as Facility,
pat.pat_mrn_id,
/*Case
When dep.rev_loc_id = 10795 or upper(dep.specialty)='SOCIAL SERVICES'
then 'Behavioral'
When dep.rev_loc_id= 10802 and dep.specialty='Behavioral Health'*/
Case when dep.specialty='Behavioral Health'  or upper(dep.specialty)='SOCIAL SERVICES'  --zz 1/28/19
then 'Behavioral'
/*When dep.rev_loc_id = 10802 and upper(dep.specialty)<>'SOCIAL SERVICES'
then*/ else  'Medical'
End as Group_Name,
pe.pat_enc_csn_id,
pe.hsp_account_id,
pe.contact_date,
pe.enc_type_c,
zdet.name as Enc_Type,
1 as Visit,
pat.pat_last_name,
pat.pat_first_name,
pat.birth_date,
zs.name as Sex
,pe.appt_prc_id
,prc.PRC_NAME Visit_type
--,case when prc_name like 'NEW%' then prc_name else null end as new_pat
,pat.REC_CREATE_DATE as mrn_create_dt
,Case
When es.doc_stat is null
then 'Not Enrolled'
else es.doc_stat
End as Enroll_Status
,es.doc_dt
/*select * from
clarity_prc p where record_type='Visit Type'
and prc_id in (1215,1595,1210,102,1139,1675)
*/
FROM pat_enc pe
join patient pat on pat.pat_id = pe.pat_id
left outer join patient_3 pat3 on pat3.pat_id = pe.pat_id
left outer join Enrollment_Status es on es.doc_pt_id = pe.pat_id
left outer join zc_disp_enc_type zdet on zdet.disp_enc_type_c = pe.enc_type_c
left outer join zc_sex zs on zs.rcpt_mem_sex_c = pat.sex_c
left outer join clarity_dep dep on dep.department_id = pe.department_id
left outer join clarity_prc prc on prc.prc_id=pe.APPT_PRC_ID
--left outer join clarity_loc loc on loc.loc_id = dep.rev_loc_id
--left outer join ZC_APPT_STATUS zas on zas.appt_status_c = pe.appt_status_c
where pe.hsp_account_id is not null and pat.pat_name not like 'ZZ%' --No ZZ Patients
  and (pat3.is_test_pat_yn is null or pat3.is_test_pat_yn = 'N') -- No Test Patients
  and pe.enc_type_c in ('2','101','108','210','1000','1003','1200','1201','1214','2100',
'2500','2501','2527','156003','156004','2101','156015') --Face-to-Face Visits
  and (pe.APPT_STATUS_C is null --Appointment status is null
   or pe.APPT_STATUS_C in ('1','2','6')) -- or Scheduled,completed or arrived
 and pe.contact_date >= BEG_DT  and pe.contact_date < END_DT+1
 --- and  es.doc_stat is not null --Enrolled patients only

 --and pe.department_id in (10802023,10802043)
  and dep.rev_loc_id in
  (---10793, --Dentistry
  10795,--Behavioral Health
  10802
  ) --Pediatric Medicine and Social Services
  ;
END;
END;
/