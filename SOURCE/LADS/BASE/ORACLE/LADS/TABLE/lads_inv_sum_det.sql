/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_sum_det
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_sum_det

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_sum_det
   (fkdat                                        varchar2(8 char)                    not null,
    bukrs                                        varchar2(4 char)                    not null,
    detseq                                       number                              not null,
    vkorg                                        varchar2(4 char)                    null,
    fkart                                        varchar2(4 char)                    null,
    znumiv                                       number                              null,
    znumps                                       number                              null,
    netwr                                        number                              null,
    waerk                                        varchar2(5 char)                    null);

/**/
/* Comments
/**/
comment on table lads_inv_sum_det is 'LADS Invoice Summary Detail';
comment on column lads_inv_sum_det.fkdat is 'Invoice Create Date';
comment on column lads_inv_sum_det.bukrs is 'Company Code';
comment on column lads_inv_sum_det.detseq is 'DET - generated sequence number';
comment on column lads_inv_sum_det.vkorg is 'Sales Organisation';
comment on column lads_inv_sum_det.fkart is 'Invoice Type';
comment on column lads_inv_sum_det.znumiv is 'Number of Invoice Documents';
comment on column lads_inv_sum_det.znumps is 'Number of Invoice Lines';
comment on column lads_inv_sum_det.netwr is 'Total Invoice Value';
comment on column lads_inv_sum_det.waerk is 'DET Currency';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_sum_det
   add constraint lads_inv_sum_det_pk primary key (fkdat, bukrs, detseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_sum_det to lads_app;
grant select, insert, update, delete on lads_inv_sum_det to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_sum_det for lads.lads_inv_sum_det;
