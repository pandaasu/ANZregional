/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_dta_message
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_dta_message

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_dta_message
   (dam_header                   number(15,0)                    not null,
    dam_hdr_trace                number(5,0)                     not null,
    dam_dta_seq                  number(9,0)                     not null,
    dam_msg_seq                  number(5,0)                     not null,
    dam_text                     varchar2(4000 char)             not null);

/**/
/* Comments
/**/
comment on table lics_dta_message is 'LICS Data Message Table';
comment on column lics_dta_message.dam_header is 'Data message - header sequence number';
comment on column lics_dta_message.dam_hdr_trace is 'Data message - header trace sequence number';
comment on column lics_dta_message.dam_dta_seq is 'Data message - data sequence number';
comment on column lics_dta_message.dam_msg_seq is 'Data message - message sequence number';
comment on column lics_dta_message.dam_text is 'Data message - message text';

/**/
/* Primary Key Constraint
/**/
alter table lics_dta_message
   add constraint lics_dta_message_pk primary key (dam_header, dam_hdr_trace, dam_dta_seq, dam_msg_seq);

/**/
/* Foreign Key Constraints
/**/
--alter table lics_dta_message
--   add constraint lics_dta_message_fk01 foreign key (dam_header, dam_dta_seq)
--      references lics_data (dat_header, dat_dta_seq);

--alter table lics_dta_message
--   add constraint lics_dta_message_fk02 foreign key (dam_header, dam_hdr_trace)
--      references lics_hdr_trace (het_header, het_hdr_trace);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_dta_message to lics_app;
grant select on lics_dta_message to lics_exec;

/**/
/* Synonym
/**/
create public synonym lics_dta_message for lics.lics_dta_message;
