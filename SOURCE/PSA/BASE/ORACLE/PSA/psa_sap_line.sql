/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_sap_line
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - SAP Line Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_sap_line
   (sli_sap_code                    varchar2(32)                  not null,
    sli_sap_text                    varchar2(128 char)            not null);

/**/
/* Comments
/**/
comment on table psa.psa_sap_line is 'SAP Line Table';
comment on column psa.psa_sap_line.sli_sap_code is 'SAP code';
comment on column psa.psa_sap_line.sli_sap_text is 'SAP text';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_sap_line
   add constraint psa_sap_line_pk primary key (sli_sap_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_sap_line to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_sap_line for psa.psa_sap_line;