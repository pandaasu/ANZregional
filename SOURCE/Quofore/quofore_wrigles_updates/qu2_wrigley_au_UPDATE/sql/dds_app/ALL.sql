set serveroutput on size 100000
set linesize 512
set echo on
spool dds_app.log


@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_hier_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_general_list_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_role_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_pos_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_rep_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_rep_addrs_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_prod_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_prod_barcode_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_cust_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_cust_addrs_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_cust_note_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_cust_contact_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_cust_visit_day_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_assort_dtl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_cust_assort_dtl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_prod_assort_dtl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_auth_list_prod_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_appoint_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_callcard_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_callcard_note_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_ord_hdr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_ord_dtl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_terr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_cust_terr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_pos_terr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_survey_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_survey_question_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_response_opt_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_task_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_task_assign_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_task_cust_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_task_prod_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_task_survey_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_act_hdr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_act_dtl_a_loc_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_act_dtl_sell_in_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_act_dtl_off_loc_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_act_dtl_facing_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_act_dtl_checkout_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_act_dtl_express_q_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_act_dtl_express_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_act_dtl_selfscan_q_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_act_dtl_selfscan_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_act_dtl_loc_oos_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_act_dtl_perm_disp_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_survey_answer_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_graveyard_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_act_dtl_face_aisle_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_act_dtl_face_expre_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_act_dtl_face_selfs_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_act_dtl_face_stand_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_act_dtl_comp_act_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_act_dtl_comp_face_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_act_dtl_exec_compl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_assort_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/dds_app/qu2_act_dtl_pkg.sql;


spool off
