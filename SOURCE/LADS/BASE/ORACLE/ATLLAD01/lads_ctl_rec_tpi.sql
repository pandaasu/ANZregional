/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_ctl_rec_tpi
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_ctl_rec_tpi

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_ctl_rec_tpi
   (cntl_rec_id                                  number(18,0)                        not null,
    proc_instr_number                            number(8,0)                         not null,
    proc_instr_type                              varchar2(1 char)                    null,
    proc_instr_category                          varchar2(8 char)                    null,
    proc_instr_line_no                           varchar2(4 char)                    null,
    phase_number                                 varchar2(4 char)                    null);

/**/
/* Comments
/**/
comment on table lads_ctl_rec_tpi is 'LADS Control Recipe Process Instruction Type';
comment on column lads_ctl_rec_tpi.cntl_rec_id is 'Control recipe number';
comment on column lads_ctl_rec_tpi.proc_instr_number  is 'Sequence number of process instruction in recipe';
comment on column lads_ctl_rec_tpi.proc_instr_type is 'Type of process instruction';
comment on column lads_ctl_rec_tpi.proc_instr_category is 'Process instruction category';
comment on column lads_ctl_rec_tpi.proc_instr_line_no is 'Line Number of Process Instruction';
comment on column lads_ctl_rec_tpi.phase_number is 'Operation Number';

/**/
/* Primary Key Constraint
/**/
alter table lads_ctl_rec_tpi
   add constraint lads_ctl_rec_tpi_pk primary key (cntl_rec_id, proc_instr_number);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_ctl_rec_tpi to lads_app;
grant select, insert, update, delete on lads_ctl_rec_tpi to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_ctl_rec_tpi for lads.lads_ctl_rec_tpi;
