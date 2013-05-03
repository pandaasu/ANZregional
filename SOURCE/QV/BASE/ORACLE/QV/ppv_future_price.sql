/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : qv 
 Table   : ppv_future_price 
 Owner   : qv 
 Author  : Trevor Keon 

 Description
 -----------
 Qlikview Loader - ppv_future_price  

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2012/10   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table ppv_future_price
(
  pfp_plant           varchar2(8 char) not null,
  pfp_material        varchar2(32 char) not null,
  pfp_currency        varchar2(10 char) not null,
  pfp_yyyypp          number not null,
  pfp_price           number not null
);

/**/
/* Comments 
/**/
comment on table ppv_future_price is 'PPV Future Price';
comment on column ppv_future_price.pfp_plant is 'PPV Future Price - plant';
comment on column ppv_future_price.pfp_material is 'PPV Future Price - material';
comment on column ppv_future_price.pfp_currency is 'PPV Future Price - currency';
comment on column ppv_future_price.pfp_yyyypp is 'PPV Future Price - mars period (YYYYPP)';
comment on column ppv_future_price.pfp_price is 'PPV Future Price - future price';

/**/
/* Primary Key Constraint 
/**/
alter table ppv_future_price
   add constraint ppv_future_price_pk primary key (pfp_plant, pfp_material, pfp_yyyypp);

/**/
/* Index 
/**/
create index ppv_future_price_ix01 on ppv_future_price(pfp_yyyypp);
create index ppv_future_price_ix02 on ppv_future_price(pfp_plant, pfp_yyyypp);

/**/
/* Authority 
/**/
grant select, insert, update, delete on ppv_future_price to qv_app;

/**/
/* Synonym 
/**/
create or replace public synonym ppv_future_price for qv.ppv_future_price;