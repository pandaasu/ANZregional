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
    psa_act_text                    varchar2(128 char)            not null,
    psa_act_type                    varchar2(1)                   not null,
    psa_act_used                    varchar2(1)                   not null,
    psa_str_week                    varchar2(7)                   null,
    psa_end_week                    varchar2(7)                   null,
    psa_str_smos                    number                        null,
    psa_end_smos                    number                        null,
    psa_str_time                    date                          null,
    psa_end_time                    date                          null,
    psa_str_barn                    number                        null,
    psa_end_barn                    number                        null,
    psa_mat_code                    varchar2(32)                  null,
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
    psa_lin_code                    varchar2(32)                  null,
    psa_con_code                    varchar2(32)                  null,
    psa_dft_flag                    varchar2(1)                   null,
    psa_rra_code                    varchar2(32)                  null,
    psa_def_rra_unt                 number                        null,
    psa_def_rra_eff                 number                        null,
    psa_def_rra_was                 number                        null,
    psa_act_rra_unt                 number                        null,
    psa_act_rra_eff                 number                        null,
    psa_act_rra_was                 number                        null,
    psa_req_plt_qty                 number                        null,
    psa_req_cas_qty                 number                        null,
    psa_req_pch_qty                 number                        null,
    psa_req_mix_qty                 number                        null,
    psa_req_ton_qty                 number                        null,
    psa_req_dur_min                 number                        null,
    psa_cal_plt_qty                 number                        null,
    psa_cal_cas_qty                 number                        null,
    psa_cal_pch_qty                 number                        null,
    psa_cal_mix_qty                 number                        null,
    psa_cal_ton_qty                 number                        null,
    psa_cal_dur_min                 number                        null,
    psa_sch_plt_qty                 number                        null,
    psa_sch_cas_qty                 number                        null,
    psa_sch_pch_qty                 number                        null,
    psa_sch_mix_qty                 number                        null,
    psa_sch_ton_qty                 number                        null,
    psa_sch_dur_min                 number                        null,
    psa_act_plt_qty                 number                        null,
    psa_act_cas_qty                 number                        null,
    psa_act_pch_qty                 number                        null,
    psa_act_mix_qty                 number                        null,
    psa_act_ton_qty                 number                        null,
    psa_act_dur_min                 number                        null,
    psa_var_plt_qty                 number                        null,
    psa_var_cas_qty                 number                        null,
    psa_var_pch_qty                 number                        null,
    psa_var_mix_qty                 number                        null,
    psa_var_ton_qty                 number                        null,
    psa_var_dur_min                 number                        null);

/**/
/* Comments
/**/
comment on table psa.psa_psc_actv is 'Production Schedule Activity Table';
comment on column psa.psa_psc_actv.psa_act_code is 'Activity code';
comment on column psa.psa_psc_actv.psa_psc_code is 'Schedule code';
comment on column psa.psa_psc_actv.psa_psc_week is 'Schedule MARS week';
comment on column psa.psa_psc_actv.psa_prd_type is 'Production type code';


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

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_psc_actv to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_psc_actv for psa.psa_psc_actv;