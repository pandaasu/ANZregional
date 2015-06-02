set serveroutput on size 100000
set linesize 512
set echo on
spool ods_app.log


@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_constants_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_util_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_interface_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw00_digest_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw01_hier_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw02_general_list_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw03_role_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw04_pos_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw05_rep_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw06_rep_addrs_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw07_prod_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw08_prod_barcode_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw09_cust_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw10_cust_addrs_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw11_cust_note_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw12_cust_contact_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw13_cust_visit_day_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw14_assort_dtl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw15_cust_assort_dtl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw16_prod_assort_dtl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw17_auth_list_prod_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw18_appoint_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw19_callcard_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw20_callcard_note_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw21_ord_hdr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw22_ord_dtl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw23_terr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw24_cust_terr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw25_pos_terr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw26_survey_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw27_survey_question_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw28_response_opt_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw29_task_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw30_task_assign_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw31_task_cust_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw32_task_prod_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw33_task_survey_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw34_act_hdr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw35_act_dtl_hotspot_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw36_act_dtl_gpa_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw37_act_dtl_ranging_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw38_act_dtl_pos_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw39_act_dtl_off_loc_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw40_survey_answer_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw41_graveyard_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw42_act_dtl_hwaudit_gr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw43_act_dtl_hwaudit_ro_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw44_act_dtl_storeop_gr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw45_act_dtl_storeop_ro_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw46_act_dtl_top_sku_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_qu3cdw47_act_dtl_pcking_chg_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_quocdw99_router_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu3_batch_pkg.sql;


spool off
