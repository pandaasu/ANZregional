/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_pch
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_pch

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_pch
   (matnr                                        varchar2(18 char)                   not null,
    pchseq                                       number                              not null,
    kvewe                                        varchar2(1 char)                    null,
    kotabnr                                      number                              null,
    kappl                                        varchar2(2 char)                    null,
    kschl                                        varchar2(4 char)                    null,
    vakey                                        varchar2(100 char)                  null,
    vkorg                                        varchar2(4 char)                    null);

/**/
/* Comments
/**/
comment on table lads_mat_pch is 'LADS Material Packaging Condition Header';
comment on column lads_mat_pch.matnr is 'Material Number';
comment on column lads_mat_pch.pchseq is 'PCH - generated sequence number';
comment on column lads_mat_pch.kvewe is 'Usage of the condition table';
comment on column lads_mat_pch.kotabnr is 'Condition table';
comment on column lads_mat_pch.kappl is 'Application';
comment on column lads_mat_pch.kschl is 'Condition type for packing object determination';
comment on column lads_mat_pch.vakey is 'Variable key 100 bytes';
comment on column lads_mat_pch.vkorg is 'Sales Organization';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_pch
   add constraint lads_mat_pch_pk primary key (matnr, pchseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_pch to lads_app;
grant select, insert, update, delete on lads_mat_pch to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_pch for lads.lads_mat_pch;
