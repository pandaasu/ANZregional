/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_int_sequence
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_int_sequence

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_int_sequence
   (ins_interface                varchar2(32 char)               not null,
    ins_sequence                 number(15,0)                    not null);

/**/
/* Comments
/**/
comment on table lics_int_sequence is 'LICS Interface Sequence Table';
comment on column lics_int_sequence.ins_interface is 'Interface sequence - interface identifier';
comment on column lics_int_sequence.ins_sequence is 'Interface sequence - sequence number';

/**/
/* Primary Key Constraint
/**/
alter table lics_int_sequence
   add constraint lics_int_sequence_pk primary key (ins_interface);

/**/
/* Foreign Key Constraints
/**/
--alter table lics_int_sequence
--   add constraint lics_int_sequence_fk01 foreign key (ins_interface)
--      references lics_interface (int_interface);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_int_sequence to lics_app;

/**/
/* Synonym
/**/
create public synonym lics_int_sequence for lics.lics_int_sequence;
