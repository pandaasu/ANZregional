/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_psc_actv
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Production Schedule Activity Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_psc_actv
   (psa_act_code                    number                        not null,
    psa_psc_code                    varchar2(32)                  not null,
    psa_psc_week                    varchar2(7)                   not null,
    psa_prd_type                    varchar2(32)                  not null,
    psa_act_type                    varchar2(1)                   not null,
    psa_upd_user                    varchar2(30)                  not null,
    psa_upd_date                    date                          not null,
    psa_chg_flag                    varchar2(1)                   null,
    psa_sch_lin_code                varchar2(32)                  null,
    psa_sch_con_code                varchar2(32)                  null,
    psa_sch_dft_flag                varchar2(1)                   null,
    psa_sch_rra_code                varchar2(32)                  null,
    psa_sch_rra_unit                number                        null,
    psa_sch_rra_effp                number                        null,
    psa_sch_rra_wasp                number                        null,
    psa_sch_win_code                varchar2(32)                  null,
    psa_sch_win_seqn                number                        null,
    psa_sch_win_flow                varchar2(1)                   null,
    psa_sch_str_time                date                          null,
    psa_sch_chg_time                date                          null,
    psa_sch_end_time                date                          null,
    psa_sch_dur_mins                number                        null,
    psa_sch_chg_mins                number                        null,
    psa_act_ent_flag                varchar2(1)                   null,
    psa_act_lin_code                varchar2(32)                  null,
    psa_act_con_code                varchar2(32)                  null,
    psa_act_dft_flag                varchar2(1)                   null,
    psa_act_rra_code                varchar2(32)                  null,
    psa_act_rra_unit                number                        null,
    psa_act_rra_effp                number                        null,
    psa_act_rra_wasp                number                        null,
    psa_act_win_code                varchar2(32)                  null,
    psa_act_win_seqn                number                        null,
    psa_act_win_flow                varchar2(1)                   null,
    psa_act_str_time                date                          null,
    psa_act_chg_time                date                          null,
    psa_act_end_time                date                          null,
    psa_act_dur_mins                number                        null,
    psa_act_chg_mins                number                        null,
    psa_var_dur_mins                number                        null,
    psa_var_chg_mins                number                        null,
    psa_var_dur_text                varchar2(2000 char)           null,
    psa_var_chg_text                varchar2(2000 char)           null,
    psa_sac_code                    varchar2(32)                  null,
    psa_sac_name                    varchar2(120 char)            null,
    psa_mat_code                    varchar2(32)                  null,
    psa_mat_name                    varchar2(120 char)            null,
    psa_mat_type                    varchar2(10)                  null,
    psa_mat_usage                   varchar2(10)                  null,
    psa_mat_uom                     varchar2(10)                  null,
    psa_mat_gro_weight              number                        null,
    psa_mat_net_weight              number                        null,
    psa_mat_unt_case                number                        null,
    psa_mat_sch_priority            number                        null,
    psa_mat_cas_pallet              number                        null,
    psa_mat_bch_quantity            number                        null,
    psa_mat_yld_percent             number                        null,
    psa_mat_yld_value               number                        null,
    psa_mat_pck_percent             number                        null,
    psa_mat_pck_weight              number                        null,
    psa_mat_bch_weight              number                        null,
    psa_mat_req_qty                 number                        null,
    psa_mat_req_plt_qty             number                        null,
    psa_mat_req_cas_qty             number                        null,
    psa_mat_req_pch_qty             number                        null,
    psa_mat_req_mix_qty             number                        null,
    psa_mat_req_ton_qty             number                        null,
    psa_mat_req_dur_min             number                        null,
    psa_mat_cal_plt_qty             number                        null,
    psa_mat_cal_cas_qty             number                        null,
    psa_mat_cal_pch_qty             number                        null,
    psa_mat_cal_mix_qty             number                        null,
    psa_mat_cal_ton_qty             number                        null,
    psa_mat_cal_dur_min             number                        null,
    psa_mat_sch_plt_qty             number                        null,
    psa_mat_sch_cas_qty             number                        null,
    psa_mat_sch_pch_qty             number                        null,
    psa_mat_sch_mix_qty             number                        null,
    psa_mat_sch_ton_qty             number                        null,
    psa_mat_sch_dur_min             number                        null,
    psa_mat_act_plt_qty             number                        null,
    psa_mat_act_cas_qty             number                        null,
    psa_mat_act_pch_qty             number                        null,
    psa_mat_act_mix_qty             number                        null,
    psa_mat_act_ton_qty             number                        null,
    psa_mat_act_dur_min             number                        null,
    psa_mat_var_plt_qty             number                        null,
    psa_mat_var_cas_qty             number                        null,
    psa_mat_var_pch_qty             number                        null,
    psa_mat_var_mix_qty             number                        null,
    psa_mat_var_ton_qty             number                        null,
    psa_mat_var_dur_min             number                        null);

/**/
/* Comments
/**/
comment on table psa.psa_psc_actv is 'Production Schedule Activity Table';
comment on column psa.psa_psc_actv.psa_act_code is 'Activity code';
comment on column psa.psa_psc_actv.psa_psc_code is 'Schedule code';
comment on column psa.psa_psc_actv.psa_psc_week is 'Schedule MARS week';
comment on column psa.psa_psc_actv.psa_prd_type is 'Production type code';
comment on column psa.psa_psc_actv.psa_act_type is 'Activity type code (P=production or T=time)';v
comment on column psa.psa_psc_actv.psa_upd_user is 'Last updated user';
comment on column psa.psa_psc_actv.psa_upd_date is 'Last updated date';
comment on column psa.psa_psc_actv.psa_chg_flag is 'Activity production change event flag (0=no or 1=yes)';
comment on column psa.psa_psc_actv.psa_sch_lin_code is 'Scheduled line code';
comment on column psa.psa_psc_actv.psa_sch_con_code is 'Scheduled line configuration code';
comment on column psa.psa_psc_actv.psa_sch_dft_flag is 'Scheduled default line flag';
comment on column psa.psa_psc_actv.psa_sch_rra_code is 'Scheduled run rate code';
comment on column psa.psa_psc_actv.psa_sch_rra_unit is 'Scheduled run rate units';
comment on column psa.psa_psc_actv.psa_sch_rra_effp is 'Scheduled run rate efficiency percentage';
comment on column psa.psa_psc_actv.psa_sch_rra_wasp is 'Scheduled run rate wastage percentage';
comment on column psa.psa_psc_actv.psa_sch_win_code is 'Scheduled shift window code';
comment on column psa.psa_psc_actv.psa_sch_win_seqn is 'Scheduled shift window sequence';
comment on column psa.psa_psc_actv.psa_sch_win_flow is 'Scheduled shift window overflow (0=no or 1=yes)';
comment on column psa.psa_psc_actv.psa_sch_str_time is 'Scheduled start time';
comment on column psa.psa_psc_actv.psa_sch_chg_time is 'Scheduled change time';
comment on column psa.psa_psc_actv.psa_sch_end_time is 'Scheduled end time';
comment on column psa.psa_psc_actv.psa_sch_dur_mins is 'Scheduled duration in minutes';
comment on column psa.psa_psc_actv.psa_sch_chg_mins is 'Scheduled change in minutes';
comment on column psa.psa_psc_actv.psa_act_ent_flag is 'Actual entered flag (0=no or 1=yes)';
comment on column psa.psa_psc_actv.psa_act_lin_code is 'Actual line code';
comment on column psa.psa_psc_actv.psa_act_con_code is 'Actual line configuration code';
comment on column psa.psa_psc_actv.psa_act_dft_flag is 'Actual default line flag';
comment on column psa.psa_psc_actv.psa_act_rra_code is 'Actual run rate code';
comment on column psa.psa_psc_actv.psa_act_rra_unit is 'Actual run rate units';
comment on column psa.psa_psc_actv.psa_act_rra_effp is 'Actual run rate efficiency percentage';
comment on column psa.psa_psc_actv.psa_act_rra_wasp is 'Actual run rate wastage percentage';
comment on column psa.psa_psc_actv.psa_act_win_code is 'Actual shift window code';
comment on column psa.psa_psc_actv.psa_act_win_seqn is 'Actual shift window sequence';
comment on column psa.psa_psc_actv.psa_act_win_flow is 'Actual shift window overflow (0=no or 1=yes)';
comment on column psa.psa_psc_actv.psa_act_str_time is 'Actual start time';
comment on column psa.psa_psc_actv.psa_act_chg_time is 'Actual change time';
comment on column psa.psa_psc_actv.psa_act_end_time is 'Actual end time';
comment on column psa.psa_psc_actv.psa_act_dur_mins is 'Actual duration in minutes';
comment on column psa.psa_psc_actv.psa_act_chg_mins is 'Actual change in minutes';
comment on column psa.psa_psc_actv.psa_var_dur_mins is 'Variance duration in minutes';
comment on column psa.psa_psc_actv.psa_var_chg_mins is 'Variance change in minutes';
comment on column psa.psa_psc_actv.psa_var_dur_text is 'Variance duration text';
comment on column psa.psa_psc_actv.psa_var_chg_text is 'Variance change text';
comment on column psa.psa_psc_actv.psa_sac_code is 'Schedule activity code';
comment on column psa.psa_psc_actv.psa_sac_name is 'Schedule activity name';
comment on column psa.psa_psc_actv.psa_mat_code is 'Material code';
comment on column psa.psa_psc_actv.psa_mat_name is 'Material name';
comment on column psa.psa_psc_actv.psa_mat_type is 'Material type';
comment on column psa.psa_psc_actv.psa_mat_usage is 'Material usage';
comment on column psa.psa_psc_actv.psa_mat_uom is 'Material UOM';
comment on column psa.psa_psc_actv.psa_mat_gro_weight is 'Material gross weight';
comment on column psa.psa_psc_actv.psa_mat_net_weight is 'Material net weight';
comment on column psa.psa_psc_actv.psa_mat_unt_case is 'Material units per case';
comment on column psa.psa_psc_actv.psa_mat_sch_priority is 'Material scheduling priority';
comment on column psa.psa_psc_actv.psa_mat_cas_pallet is 'Material cases per pallet';
comment on column psa.psa_psc_actv.psa_mat_bch_quantity is 'Material batch/lot quantity';
comment on column psa.psa_psc_actv.psa_mat_yld_percent is 'Material yield percentage';
comment on column psa.psa_psc_actv.psa_mat_yld_value is 'Material yield value';
comment on column psa.psa_psc_actv.psa_mat_pck_percent is 'Material pack weight percentage';
comment on column psa.psa_psc_actv.psa_mat_pck_weight is 'Material pack weight';
comment on column psa.psa_psc_actv.psa_mat_bch_weight is 'Material batch weight';
comment on column psa.psa_psc_actv.psa_mat_req_qty is 'Material production requirement quantity';
comment on column psa.psa_psc_actv.psa_mat_req_plt_qty is 'Material production requirement pallet quantity';
comment on column psa.psa_psc_actv.psa_mat_req_cas_qty is 'Material production requirement case quantity';
comment on column psa.psa_psc_actv.psa_mat_req_pch_qty is 'Material production requirement pouch quantity';
comment on column psa.psa_psc_actv.psa_mat_req_mix_qty is 'Material production requirement mix quantity';
comment on column psa.psa_psc_actv.psa_mat_req_ton_qty is 'Material production requirement tonne quantity';
comment on column psa.psa_psc_actv.psa_mat_req_dur_min is 'Material production requirement duration in minutes';
comment on column psa.psa_psc_actv.psa_mat_cal_plt_qty is 'Material calculated pallet quantity';
comment on column psa.psa_psc_actv.psa_mat_cal_cas_qty is 'Material calculated case quantity';
comment on column psa.psa_psc_actv.psa_mat_cal_pch_qty is 'Material calculated pouch quantity';
comment on column psa.psa_psc_actv.psa_mat_cal_mix_qty is 'Material calculated mix quantity';
comment on column psa.psa_psc_actv.psa_mat_cal_ton_qty is 'Material calculated tonne quantity';
comment on column psa.psa_psc_actv.psa_mat_cal_dur_min is 'Material calculated duration in minutes';
comment on column psa.psa_psc_actv.psa_mat_sch_plt_qty is 'Material scheduled pallet quantity';
comment on column psa.psa_psc_actv.psa_mat_sch_cas_qty is 'Material scheduled case quantity';
comment on column psa.psa_psc_actv.psa_mat_sch_pch_qty is 'Material scheduled pouch quantity';
comment on column psa.psa_psc_actv.psa_mat_sch_mix_qty is 'Material scheduled mix quantity';
comment on column psa.psa_psc_actv.psa_mat_sch_ton_qty is 'Material scheduled tonne quantity';
comment on column psa.psa_psc_actv.psa_mat_sch_dur_min is 'Material scheduled duration in minutes';
comment on column psa.psa_psc_actv.psa_mat_act_plt_qty is 'Material actual pallet quantity';
comment on column psa.psa_psc_actv.psa_mat_act_cas_qty is 'Material actual case quantity';
comment on column psa.psa_psc_actv.psa_mat_act_pch_qty is 'Material actual pouch quantity';
comment on column psa.psa_psc_actv.psa_mat_act_mix_qty is 'Material actual mix quantity';
comment on column psa.psa_psc_actv.psa_mat_act_ton_qty is 'Material actual tonne quantity';
comment on column psa.psa_psc_actv.psa_mat_act_dur_min is 'Material actual duration in minutes';
comment on column psa.psa_psc_actv.psa_mat_var_plt_qty is 'Material variance pallet quantity';
comment on column psa.psa_psc_actv.psa_mat_var_cas_qty is 'Material variance case quantity';
comment on column psa.psa_psc_actv.psa_mat_var_pch_qty is 'Material variance pouch quantity';
comment on column psa.psa_psc_actv.psa_mat_var_mix_qty is 'Material variance mix quantity';
comment on column psa.psa_psc_actv.psa_mat_var_ton_qty is 'Material variance tonne quantity';
comment on column psa.psa_psc_actv.psa_mat_var_dur_min is 'Material variance duration in minutes';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_psc_actv
   add constraint psa_psc_actv_pk primary key (psa_act_code);

/**/
/* Indexes
/**/
create index psa_psc_actv_ix01 on psa.psa_psc_actv
   (psa_psc_code, psa_psc_week, psa_prd_type, psa_act_code);
create index psa_psc_actv_ix02 on psa.psa_psc_actv
   (psa_psc_code, psa_psc_week, psa_prd_type, psa_sch_lin_code, psa_sch_con_code, psa_sch_win_code, psa_sch_win_seqn);
create index psa_psc_actv_ix03 on psa.psa_psc_actv
   (psa_psc_code, psa_psc_week, psa_prd_type, psa_act_lin_code, psa_act_con_code, psa_act_win_code, psa_act_win_seqn);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_psc_actv to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_psc_actv for psa.psa_psc_actv;