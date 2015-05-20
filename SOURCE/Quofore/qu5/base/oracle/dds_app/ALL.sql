set serveroutput on size 100000
set linesize 512
set echo on
spool dds_app.log


@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_hier_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_general_list_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_role_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_pos_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_rep_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_rep_address_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_prod_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_prod_barcode_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_cust_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_cust_address_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_cust_note_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_cust_contact_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_cust_visitor_day_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_cust_contact_training_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_assort_dtl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_cust_assort_dtl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_prod_assort_dtl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_auth_list_prod_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_appoint_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_callcard_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_callcard_note_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_ord_hdr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_ord_dtl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_terr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_cust_terr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_pos_terr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_survey_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_survey_question_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_response_opt_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_task_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_task_assignment_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_task_cust_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_task_prod_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_task_survey_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_act_hdr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_survey_answer_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_graveyard_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_cust_wholesaler_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_act_dtl_dist_check_1_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_act_dtl_dist_check_2_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_act_dtl_relay_hours_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_act_dtl_second_site_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_act_dtl_interuption_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_act_dtl_hardware_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_act_dtl_upgrades_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_act_dtl_training_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_act_dtl_shelf_share_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_act_dtl_compliant_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_act_dtl_new_prod_dev_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_assort_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu5_act_dtl_pkg.sql;


spool off
