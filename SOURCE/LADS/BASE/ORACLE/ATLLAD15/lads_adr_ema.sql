/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_adr_ema
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_adr_ema

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_adr_ema
   (obj_type                                     varchar2(10 char)                   not null,
    obj_id                                       varchar2(70 char)                   not null,
    context                                      number                              not null,
    emaseq                                       number                              not null,
    std_no                                       varchar2(1 char)                    null,
    e_mail                                       varchar2(241)                       null,
    email_srch                                   varchar2(20 char)                   null,
    std_recip                                    varchar2(1 char)                    null,
    r_3_user                                     varchar2(1 char)                    null,
    encode                                       varchar2(1 char)                    null,
    tnef                                         varchar2(1 char)                    null,
    home_flag                                    varchar2(1 char)                    null,
    consnumber                                   number                              null,
    errorflag                                    varchar2(1 char)                    null,
    flg_nouse                                    varchar2(1 char)                    null);

/**/
/* Comments
/**/
comment on table lads_adr_ema is 'LADS Address Email';
comment on column lads_adr_ema.obj_type is 'Address owner object type';
comment on column lads_adr_ema.obj_id is 'Address owner object ID';
comment on column lads_adr_ema.context is 'Semantic description of an object address';
comment on column lads_adr_ema.emaseq is 'EMA - generated sequence number';
comment on column lads_adr_ema.std_no is 'Standard Sender Address in this Communication Type';
comment on column lads_adr_ema.e_mail is 'E-Mail Address';
comment on column lads_adr_ema.email_srch is 'E-Mail Address Search Field';
comment on column lads_adr_ema.std_recip is 'Flag: Recipient is standard recipient for this number';
comment on column lads_adr_ema.r_3_user is 'Flag: connected to R/3';
comment on column lads_adr_ema.encode is 'Desired data coding (SMTP)';
comment on column lads_adr_ema.tnef is 'Flag: Receiver can receive TNEF coding via SMTP';
comment on column lads_adr_ema.home_flag is 'Recipient address in this communication type (mail sys.grp)';
comment on column lads_adr_ema.consnumber is 'Sequence number';
comment on column lads_adr_ema.errorflag is 'Flag: Record not processed';
comment on column lads_adr_ema.flg_nouse is 'Flag: This Communication Number is Not Used';

/**/
/* Primary Key Constraint
/**/
alter table lads_adr_ema
   add constraint lads_adr_ema_pk primary key (obj_type, obj_id, context, emaseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_adr_ema to lads_app;
grant select, insert, update, delete on lads_adr_ema to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_adr_ema for lads.lads_adr_ema;
