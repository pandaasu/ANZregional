/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_ctl_rec_txt
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_ctl_rec_txt

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_ctl_rec_txt
   (cntl_rec_id                                  number(18,0)                        not null,
    proc_instr_number                            number(8,0)                         not null,
    char_line_number                             number(4,0)                         not null,
    tdformat                                     varchar2(2 char)                    null,
    tdline                                       varchar2(132 char)                  null,
    arrival_sequence                             number(9,0)                         not null);

/**/
/* Comments
/**/
comment on table lads_ctl_rec_txt is 'LADS Control Recipe Text';
comment on column lads_ctl_rec_txt.cntl_rec_id is 'Control recipe number';
comment on column lads_ctl_rec_txt.proc_instr_number is 'Sequence number of process instruction in recipe';
comment on column lads_ctl_rec_txt.char_line_number is 'Sequence number of proc.instruction characteristic in recipe';
comment on column lads_ctl_rec_txt.tdformat is 'Tag column';
comment on column lads_ctl_rec_txt.tdline is 'Text line';
comment on column lads_ctl_rec_txt.arrival_sequence is 'Generated arrival sequence';

/**/
/* Primary Key Constraint
/**/
alter table lads_ctl_rec_txt
   add constraint lads_ctl_rec_txt_pk primary key (cntl_rec_id, proc_instr_number, char_line_number, arrival_sequence);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_ctl_rec_txt to lads_app;
grant select, insert, update, delete on lads_ctl_rec_txt to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_ctl_rec_txt for lads.lads_ctl_rec_txt;
