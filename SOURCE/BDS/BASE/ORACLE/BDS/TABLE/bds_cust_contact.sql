/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_cust_contact
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Customer Contact Person

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_cust_contact
   (customer_code                      varchar2(10 char)        not null,
    contact_number                     number                   not null,
    first_name                         varchar2(35 char)        null,
    last_name                          varchar2(35 char)        null,
    cust_department                    varchar2(12 char)        null,
    department                         varchar2(4 char)         null,
    higher_partner                     number                   null,
    phone_number                       varchar2(16 char)        null,
    salutation                         varchar2(30 char)        null,
    person_function                    varchar2(2 char)         null,
    sort_field                         varchar2(10 char)        null,
    phone_extension                    varchar2(10 char)        null,
    fax_number                         varchar2(30 char)        null,
    faz_extension                      varchar2(10 char)        null);

/*-*/
/* Comments
/*-*/
comment on table bds_cust_contact is 'Business Data Store - Customer Contact Person';
comment on column bds_cust_contact.customer_code is 'Customer Number - lads_cus_cnt.kunnr';
comment on column bds_cust_contact.contact_number is 'Number of contact person - lads_cus_cnt.parnr';
comment on column bds_cust_contact.first_name is 'First name - lads_cus_cnt.namev';
comment on column bds_cust_contact.last_name is 'Name 1 - lads_cus_cnt.name1';
comment on column bds_cust_contact.cust_department is 'Contact persons department at customer - lads_cus_cnt.abtpa';
comment on column bds_cust_contact.department is 'Contact person department - lads_cus_cnt.abtnr';
comment on column bds_cust_contact.higher_partner is 'Higher-level partner - lads_cus_cnt.uepar';
comment on column bds_cust_contact.phone_number is 'First telephone number - lads_cus_cnt.telf1';
comment on column bds_cust_contact.salutation is '''Form of address for contact person (Mr, Mrs...etc)'' - lads_cus_cnt.anred';
comment on column bds_cust_contact.person_function is 'Contact person function - lads_cus_cnt.pafkt';
comment on column bds_cust_contact.sort_field is 'Sort field - lads_cus_cnt.sortl';
comment on column bds_cust_contact.phone_extension is 'First Telephone No.: Extension - lads_cus_cnt.zz_tel_extens';
comment on column bds_cust_contact.fax_number is 'First fax no.: dialling code+number - lads_cus_cnt.zz_fax_number';
comment on column bds_cust_contact.faz_extension is 'First fax no.: extension - lads_cus_cnt.zz_fax_extens';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_cust_contact
   add constraint bds_cust_contact_pk primary key (customer_code, contact_number);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_cust_contact to lics_app;
grant select, insert, update, delete on bds_cust_contact to lads_app;
grant select, insert, update, delete on bds_cust_contact to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_cust_contact for bds.bds_cust_contact;