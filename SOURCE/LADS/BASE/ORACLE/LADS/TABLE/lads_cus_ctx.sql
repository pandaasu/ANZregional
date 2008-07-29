/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cus_ctx
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cus_ctx

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cus_ctx
   (kunnr                                        varchar2(10 char)                   not null,
    cudseq                                       number                              not null,
    ctxseq                                       number                              not null,
    witht                                        varchar2(2 char)                    null,
    wt_withcd                                    varchar2(2 char)                    null,
    wt_agent                                     varchar2(1 char)                    null,
    wt_agtdf                                     varchar2(8 char)                    null,
    wt_agtdt                                     varchar2(8 char)                    null,
    wt_wtstcd                                    varchar2(16 char)                   null,
    bukrs                                        varchar2(4 char)                    null);

/**/
/* Comments
/**/
comment on table lads_cus_ctx is 'LADS Customer Withholding Tax';
comment on column lads_cus_ctx.kunnr is 'Customer Number';
comment on column lads_cus_ctx.cudseq is 'CUD - generated sequence number';
comment on column lads_cus_ctx.ctxseq is 'CTX - generated sequence number';
comment on column lads_cus_ctx.witht is 'Indicator for withholding tax type';
comment on column lads_cus_ctx.wt_withcd is 'Withholding tax code';
comment on column lads_cus_ctx.wt_agent is 'Indicator: Withholding tax agent?';
comment on column lads_cus_ctx.wt_agtdf is 'Obligated to withhold tax from';
comment on column lads_cus_ctx.wt_agtdt is 'Obligated to withhold tax until';
comment on column lads_cus_ctx.wt_wtstcd is 'Withholding tax identification number';
comment on column lads_cus_ctx.bukrs is 'Company Code';

/**/
/* Primary Key Constraint
/**/
alter table lads_cus_ctx
   add constraint lads_cus_ctx_pk primary key (kunnr, cudseq, ctxseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cus_ctx to lads_app;
grant select, insert, update, delete on lads_cus_ctx to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cus_ctx for lads.lads_cus_ctx;
