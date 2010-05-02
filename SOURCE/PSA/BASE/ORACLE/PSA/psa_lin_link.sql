/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_lin_link
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Production line Link Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_lin_link
   (lli_lin_code                    varchar2(32)                  not null,
    lli_sap_code                    varchar2(32)                  not null);

/**/
/* Comments
/**/
comment on table psa.psa_lin_link is 'Production Line Link Table';
comment on column psa.psa_lin_link.lli_lin_code is 'Line code';
comment on column psa.psa_lin_link.lli_sap_code is 'SAP code';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_lin_link
   add constraint psa_lin_link_pk primary key (lli_lin_code, lli_sap_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_lin_link to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_lin_link for psa.psa_lin_link;