set serveroutput on size 100000
set linesize 512
set echo on
spool ods_app.log


@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_constants_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_util_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_interface_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw00_digest_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw01_hier_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw02_general_list_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw03_role_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw04_pos_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw05_rep_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw06_rep_address_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw07_prod_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw08_prod_barcode_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw09_cust_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw10_cust_address_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw11_cust_note_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw12_cust_contact_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw13_cust_visitor_day_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw14_cust_contact_training_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw15_assort_dtl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw16_cust_assort_dtl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw17_prod_assort_dtl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw18_auth_list_prod_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw19_appoint_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw20_callcard_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw21_callcard_note_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw22_ord_hdr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw23_ord_dtl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw24_terr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw25_cust_terr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw26_pos_terr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw27_survey_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw28_survey_question_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw29_response_opt_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw30_task_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw31_task_assignment_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw32_task_cust_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw33_task_prod_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw34_task_survey_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw35_act_hdr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw36_survey_answer_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw37_graveyard_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw38_cust_wholesaler_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw39_act_dtl_dist_check_1_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw40_act_dtl_dist_check_2_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw41_act_dtl_relay_hours_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw42_act_dtl_second_site_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw43_act_dtl_interuption_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw44_act_dtl_hardware_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw45_act_dtl_upgrades_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw46_act_dtl_training_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw47_act_dtl_shelf_share_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw48_act_dtl_compliant_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_qu5cdw49_act_dtl_new_prod_dev_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_quocdw99_router_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu5_batch_pkg.sql;


spool off
