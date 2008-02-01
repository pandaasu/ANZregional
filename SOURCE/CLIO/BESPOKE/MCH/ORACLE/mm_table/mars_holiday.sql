/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : mars_holiday
 Owner  : mm

 Description
 -----------
 Mars Holiday Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/02   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table mm.mars_holiday
   (calendar_date            date                        not null,
    moe_code                 varchar2(4)                 not null);

/**/
/* Comments
/**/
comment on table mm.mars_holiday is 'Mars Holiday Table';
comment on column mm.mars_holiday.calendar_date is 'Holiday calendar date';
comment on column mm.mars_holiday.moe_code is 'Mars Organisation Entity';

/**/
/* Primary Key Constraint
/**/
alter table mm.mars_holiday
   add constraint mars_holiday_pk primary key (calendar_date, moe_code);

/**/
/* Authority
/**/
grant select on mm.mars_holiday to public with grant option;

/**/
/* Synonym
/**/
create public synonym mars_holiday for mm.mars_holiday;
