/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_del_htp
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_del_htp

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_del_htp
   (vbeln                                        varchar2(10 char)                   not null,
    htxseq                                       number                              not null,
    htpseq                                       number                              not null,
    tdformat                                     varchar2(2 char)                    null,
    tdline                                       varchar2(132 char)                  null);

/**/
/* Comments
/**/
comment on table lads_del_htp is 'LADS Delivery Text Detail';
comment on column lads_del_htp.vbeln is 'Sales and Distribution Document Number';
comment on column lads_del_htp.htxseq is 'HTX - generated sequence number';
comment on column lads_del_htp.htpseq is 'HTP - generated sequence number';
comment on column lads_del_htp.tdformat is 'Tag column';
comment on column lads_del_htp.tdline is 'Text line';


/**/
/* Primary Key Constraint
/**/
alter table lads_del_htp
   add constraint lads_del_htp_pk primary key (vbeln, htxseq, htpseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_del_htp to lads_app;
grant select, insert, update, delete on lads_del_htp to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_del_htp for lads.lads_del_htp;
