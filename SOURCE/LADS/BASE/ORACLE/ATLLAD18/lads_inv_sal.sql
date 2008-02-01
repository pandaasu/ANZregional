/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_sal
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_sal

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_sal
   (belnr                                        varchar2(35 char)                   not null,
    orgseq                                       number                              not null,
    salseq                                       number                              not null,
    vkgrp                                        varchar2(3 char)                    null,
    bezei                                        varchar2(20 char)                   null,
    cscfn                                        varchar2(40 char)                   null,
    cscln                                        varchar2(40 char)                   null,
    csctel                                       varchar2(16 char)                   null,
    addl1                                        varchar2(20 char)                   null,
    addl2                                        varchar2(20 char)                   null,
    addl3                                        varchar2(20 char)                   null);

/**/
/* Comments
/**/
comment on table lads_inv_sal is 'LADS Invoice Sales Group';
comment on column lads_inv_sal.belnr is 'IDOC document number';
comment on column lads_inv_sal.orgseq is 'ORG - generated sequence number';
comment on column lads_inv_sal.salseq is 'SAL - generated sequence number';
comment on column lads_inv_sal.vkgrp is 'Sales group';
comment on column lads_inv_sal.bezei is 'Description';
comment on column lads_inv_sal.cscfn is 'First name';
comment on column lads_inv_sal.cscln is 'Last name';
comment on column lads_inv_sal.csctel is 'First telephone number';
comment on column lads_inv_sal.addl1 is 'Additional text 1';
comment on column lads_inv_sal.addl2 is 'Additional Text 2';
comment on column lads_inv_sal.addl3 is 'Additional Text 3';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_sal
   add constraint lads_inv_sal_pk primary key (belnr, orgseq, salseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_sal to lads_app;
grant select, insert, update, delete on lads_inv_sal to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_sal for lads.lads_inv_sal;
