/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_ref_fld
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_ref_fld

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_ref_fld
   (z_tabname                                    varchar2(30 char)                   not null,
    fldseq                                       number                              not null,
    z_fieldname                                  varchar2(30 char)                   null,
    z_offset                                     number                              null,
    z_leng                                       number                              null);

/**/
/* Comments
/**/
comment on table lads_ref_fld is 'LADS Reference Field';
comment on column lads_ref_fld.z_tabname is 'Table Name';
comment on column lads_ref_fld.fldseq is 'FLD - generated sequence number';
comment on column lads_ref_fld.z_fieldname is 'Field Name';
comment on column lads_ref_fld.z_offset is 'Offset of a field in work area';
comment on column lads_ref_fld.z_leng is 'Length (No. of Characters)';

/**/
/* Primary Key Constraint
/**/
alter table lads_ref_fld
   add constraint lads_ref_fld_pk primary key (z_tabname, fldseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_ref_fld to lads_app;
grant select, insert, update, delete on lads_ref_fld to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_ref_fld for lads.lads_ref_fld;
