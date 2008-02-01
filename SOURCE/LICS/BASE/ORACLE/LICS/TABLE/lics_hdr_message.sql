/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_hdr_message
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_hdr_message

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_hdr_message
   (hem_header                   number(15,0)                    not null,
    hem_hdr_trace                number(5,0)                     not null,
    hem_msg_seq                  number(5,0)                     not null,
    hem_text                     varchar2(4000 char)             not null);

/**/
/* Comments
/**/
comment on table lics_hdr_message is 'LICS Header Message Table';
comment on column lics_hdr_message.hem_header is 'Header message - header sequence number';
comment on column lics_hdr_message.hem_hdr_trace is 'Header message - trace sequence number';
comment on column lics_hdr_message.hem_msg_seq is 'Header message - message sequence number';
comment on column lics_hdr_message.hem_text is 'Header message - message text';

/**/
/* Primary Key Constraint
/**/
alter table lics_hdr_message
   add constraint lics_hdr_message_pk primary key (hem_header, hem_hdr_trace, hem_msg_seq);

/**/
/* Foreign Key Constraints
/**/
--alter table lics_hdr_message
--   add constraint lics_hdr_message_fk01 foreign key (hem_header, hem_hdr_trace)
--      references lics_hdr_trace (het_header, het_hdr_trace);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_hdr_message to lics_app;

/**/
/* Synonym
/**/
create public synonym lics_hdr_message for lics.lics_hdr_message;
