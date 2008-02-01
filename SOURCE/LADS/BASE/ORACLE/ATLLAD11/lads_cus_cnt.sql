/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cus_cnt
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cus_cnt

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cus_cnt
   (kunnr                                        varchar2(10 char)                   not null,
    cntseq                                       number                              not null,
    parnr                                        number                              null,
    namev                                        varchar2(35 char)                   null,
    name1                                        varchar2(35 char)                   null,
    abtpa                                        varchar2(12 char)                   null,
    abtnr                                        varchar2(4 char)                    null,
    uepar                                        number                              null,
    telf1                                        varchar2(16 char)                   null,
    anred                                        varchar2(30 char)                   null,
    pafkt                                        varchar2(2 char)                    null,
    sortl                                        varchar2(10 char)                   null,
    zz_tel_extens                                varchar2(10 char)                   null,
    zz_fax_number                                varchar2(30 char)                   null,
    zz_fax_extens                                varchar2(10 char)                   null);

/**/
/* Comments
/**/
comment on table lads_cus_cnt is 'LADS Customer Contact Person';
comment on column lads_cus_cnt.kunnr is 'Customer Number';
comment on column lads_cus_cnt.cntseq is 'CNT - generated sequence number';
comment on column lads_cus_cnt.parnr is 'Number of contact person';
comment on column lads_cus_cnt.namev is 'First name';
comment on column lads_cus_cnt.name1 is 'Name 1';
comment on column lads_cus_cnt.abtpa is 'Contact persons department at customer';
comment on column lads_cus_cnt.abtnr is 'Contact person department';
comment on column lads_cus_cnt.uepar is 'Higher-level partner';
comment on column lads_cus_cnt.telf1 is 'First telephone number';
comment on column lads_cus_cnt.anred is '"Form of address for contact person (Mr, Mrs...etc)"';
comment on column lads_cus_cnt.pafkt is 'Contact person function';
comment on column lads_cus_cnt.sortl is 'Sort field';
comment on column lads_cus_cnt.zz_tel_extens is 'First Telephone No.: Extension';
comment on column lads_cus_cnt.zz_fax_number is 'First fax no.: dialling code+number';
comment on column lads_cus_cnt.zz_fax_extens is 'First fax no.: extension';

/**/
/* Primary Key Constraint
/**/
alter table lads_cus_cnt
   add constraint lads_cus_cnt_pk primary key (kunnr, cntseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cus_cnt to lads_app;
grant select, insert, update, delete on lads_cus_cnt to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cus_cnt for lads.lads_cus_cnt;
