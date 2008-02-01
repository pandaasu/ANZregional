/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_del_pod
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_del_pod

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_del_pod
   (vbeln                                        varchar2(10 char)                   not null,
    detseq                                       number                              not null,
    podseq                                       number                              not null,
    grund                                        varchar2(4 char)                    null,
    podmg                                        number                              null,
    lfimg_diff                                   number                              null,
    vrkme                                        varchar2(3 char)                    null,
    lgmng_diff                                   number                              null,
    meins                                        varchar2(3 char)                    null);

/**/
/* Comments
/**/
comment on table lads_del_pod is 'LADS Delivery Detail Proof Of Delivery';
comment on column lads_del_pod.vbeln is 'Sales and Distribution Document Number';
comment on column lads_del_pod.detseq is 'DET - generated sequence number';
comment on column lads_del_pod.podseq is 'POD - generated sequence number';
comment on column lads_del_pod.grund is 'Reason for variance in POD';
comment on column lads_del_pod.podmg is 'Actual quantity accepted in sales unit per delivery item';
comment on column lads_del_pod.lfimg_diff is 'Deviation in quantity actually delivered in sales unit';
comment on column lads_del_pod.vrkme is 'Sales unit';
comment on column lads_del_pod.lgmng_diff is 'Difference in actual delivery quantity in stockkeeping unit';
comment on column lads_del_pod.meins is 'Base Unit of Measure';

/**/
/* Primary Key Constraint
/**/
alter table lads_del_pod
   add constraint lads_del_pod_pk primary key (vbeln, detseq, podseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_del_pod to lads_app;
grant select, insert, update, delete on lads_del_pod to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_del_pod for lads.lads_del_pod;
