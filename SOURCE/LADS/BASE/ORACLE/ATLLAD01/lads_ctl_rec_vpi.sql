/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_ctl_rec_vpi
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_ctl_rec_vpi

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_ctl_rec_vpi
   (cntl_rec_id                                  number(18,0)                        not null,
    proc_instr_number                            number(8,0)                         not null,
    char_line_number                             number(4,0)                         not null,
    name_char                                    varchar2(30 char)                   null,
    char_value                                   varchar2(30 char)                   null,
    data_type                                    varchar2(4 char)                    null,
    instr_char_line_number                       varchar2(4 char)                    null);

/**/
/* Comments
/**/
comment on table lads_ctl_rec_vpi is 'LADS Control Recipe Process Instruction Variable';
comment on column lads_ctl_rec_vpi.cntl_rec_id is 'Control recipe number';
comment on column lads_ctl_rec_vpi.proc_instr_number is 'Sequence number of process instruction in recipe';
comment on column lads_ctl_rec_vpi.char_line_number is 'Sequence number of proc.instruction characteristic in recipe';
comment on column lads_ctl_rec_vpi.name_char is 'Characteristic name';
comment on column lads_ctl_rec_vpi.char_value is 'Characteristic value';
comment on column lads_ctl_rec_vpi.data_type is 'Data type of characteristic';
comment on column lads_ctl_rec_vpi.instr_char_line_number is 'Line Number of Process Instruction Characteristic';

/**/
/* Primary Key Constraint
/**/
alter table lads_ctl_rec_vpi
   add constraint lads_ctl_rec_vpi_pk primary key (cntl_rec_id, proc_instr_number, char_line_number);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_ctl_rec_vpi to lads_app;
grant select, insert, update, delete on lads_ctl_rec_vpi to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_ctl_rec_vpi for lads.lads_ctl_rec_vpi;
