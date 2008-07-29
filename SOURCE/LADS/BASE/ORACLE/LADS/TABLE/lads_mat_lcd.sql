/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_lcd
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_lcd

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_lcd
   (matnr                                        varchar2(18 char)                   not null,
    lcdseq                                       number                              not null,
    z_matnr                                      varchar2(18 char)                   null,
    z_lcdid                                      varchar2(5 char)                    null,
    z_lcdnr                                      varchar2(18 char)                   null);

/**/
/* Comments
/**/
comment on table lads_mat_lcd is 'LADS Material Local/Legacy';
comment on column lads_mat_lcd.matnr is 'Material Number';
comment on column lads_mat_lcd.lcdseq is 'LCD - generated sequence number';
comment on column lads_mat_lcd.z_matnr is 'Regional Material Number';
comment on column lads_mat_lcd.z_lcdid is 'Regional code Id';
comment on column lads_mat_lcd.z_lcdnr is 'Regional code number';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_lcd
   add constraint lads_mat_lcd_pk primary key (matnr, lcdseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_lcd to lads_app;
grant select, insert, update, delete on lads_mat_lcd to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_lcd for lads.lads_mat_lcd;
