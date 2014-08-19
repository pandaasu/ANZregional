set serveroutput on size 100000
set linesize 512
set echo on
spool ods_app.log


@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_constants_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_util_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_interface_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw00_digest_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw01_hier_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw02_general_list_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw03_role_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw04_pos_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw05_rep_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw06_rep_address_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw07_prod_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw08_prod_barcode_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw09_cust_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw10_cust_address_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw11_cust_note_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw12_cust_contact_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw13_cust_visitor_day_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw14_assort_dtl_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw15_cust_assort_dtl_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw16_prod_assort_dtl_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw17_auth_list_prod_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw18_appoint_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw19_call_card_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw20_call_card_note_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw21_ord_hdr_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw22_ord_dtl_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw23_terr_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw24_cust_terr_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw25_pos_terr_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw26_survey_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw27_survey_question_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw28_response_opt_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw29_task_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw30_task_assignment_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw31_task_cust_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw32_task_prod_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw33_task_survey_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw34_act_hdr_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw35_act_dtl_dist_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw36_act_dtl_permancy_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw37_act_dtl_disply_std_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw38_survey_answer_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw39_graveyard_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_qu4cdw40_act_dtl_planogram_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_quocdw99_router_pkg.sql;
@C:/Users/chambma1/Project/q4_chocolate/loader_app/sql/ods_app/qu4_batch_pkg.sql;


spool off
