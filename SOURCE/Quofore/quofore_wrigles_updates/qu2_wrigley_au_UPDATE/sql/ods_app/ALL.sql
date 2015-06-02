set serveroutput on size 100000
set linesize 512
set echo on
spool ods_app.log


@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_constants_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_util_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_interface_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw00_digest_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw01_hier_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw02_general_list_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw03_role_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw04_pos_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw05_rep_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw06_rep_addrs_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw07_prod_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw08_prod_barcode_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw09_cust_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw10_cust_addrs_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw11_cust_note_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw12_cust_contact_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw13_cust_visit_day_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw14_assort_dtl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw15_cust_assort_dtl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw16_prod_assort_dtl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw17_auth_list_prod_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw18_appoint_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw19_callcard_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw20_callcard_note_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw21_ord_hdr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw22_ord_dtl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw23_terr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw24_cust_terr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw25_pos_terr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw26_survey_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw27_survey_question_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw28_response_opt_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw29_task_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw30_task_assign_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw31_task_cust_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw32_task_prod_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw33_task_survey_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw34_act_hdr_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw35_act_dtl_a_loc_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw38_act_dtl_sell_in_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw39_act_dtl_off_loc_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw40_act_dtl_facing_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw41_act_dtl_checkout_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw42_act_dtl_express_q_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw43_act_dtl_express_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw44_act_dtl_selfscan_q_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw45_act_dtl_selfscan_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw46_act_dtl_loc_oos_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw47_act_dtl_perm_disp_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw48_survey_answer_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw49_graveyard_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw50_act_dtl_face_aisle_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw51_act_dtl_face_expre_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw52_act_dtl_face_selfs_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw53_act_dtl_face_stand_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw54_act_dtl_comp_act_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw55_act_dtl_comp_face_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_qu2cdw56_act_dtl_exec_compl_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_quocdw99_router_pkg.sql;
@C:/Users/chambma1/Project/quofore/loader_app/sql/ods_app/qu2_batch_pkg.sql;


spool off
