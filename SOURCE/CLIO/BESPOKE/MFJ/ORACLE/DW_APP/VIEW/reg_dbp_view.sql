/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : reg_dbp_view
 Owner  : dw_app

 DESCRIPTION
 -----------
 Data Warehouse - View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view reg_dbp_view
   (domestic_export,
    order_nbr,
    business_seg,
    brand_flag,
    ptd, 
    br_p01,
    br_p02,
    br_p03,
    br_p04,
    br_p05, 
    br_p06,
    br_p07,
    br_p08,
    br_p09,
    br_p10, 
    br_p11,
    br_p12,
    br_p13,
    op_p01,
    op_p02, 
    op_p03,
    op_p04,
    op_p05,
    op_p06,
    op_p07, 
    op_p08,
    op_p09,
    op_p10,
    op_p11,
    op_p12, 
    op_p13) as 
   select 'DOMESTIC' as domestic_export,
          decode(upper(t1.bus_sgmnt), 'PETCARE', 1, 'SNACKFOOD', 2, 'FOOD', 3) as order_nbr,
          upper(t1.bus_sgmnt) as business_seg,
          upper(t1.brand_flag) as brand_flag,
          round(t1.ptd  / 1000, 2) as ptd,
          round(t1.br_p01 / 1000, 2) as br_p01,
          round(t1.br_p02 / 1000, 2) as br_p02,
          round(t1.br_p03 / 1000, 2) as br_p03,
          round(t1.br_p04 / 1000, 2) as br_p04,
          round(t1.br_p05 / 1000, 2) as br_p05,
          round(t1.br_p06 / 1000, 2) as br_p06,
          round(t1.br_p07 / 1000, 2) as br_p07,
          round(t1.br_p08 / 1000, 2) as br_p08,
          round(t1.br_p09 / 1000, 2) as br_p09,
          round(t1.br_p10 / 1000, 2) as br_p10,
          round(t1.br_p11 / 1000, 2) as br_p11,
          round(t1.br_p12 / 1000, 2) as br_p12,
          round(t1.br_p13 / 1000, 2) as br_p13,
          round(t1.op_p01 / 1000, 2) as op_p01,
          round(t1.op_p02 / 1000, 2) as op_p02,
          round(t1.op_p03 / 1000, 2) as op_p03,
          round(t1.op_p04 / 1000, 2) as op_p04,
          round(t1.op_p05 / 1000, 2) as op_p05,
          round(t1.op_p06 / 1000, 2) as op_p06,
          round(t1.op_p07 / 1000, 2) as op_p07,
          round(t1.op_p08 / 1000, 2) as op_p08,
          round(t1.op_p09 / 1000, 2) as op_p09,
          round(t1.op_p10 / 1000, 2) as op_p10,
          round(t1.op_p11 / 1000, 2) as op_p11,
          round(t1.op_p12 / 1000, 2) as op_p12,
          round(t1.op_p13 / 1000, 2) as op_p13
     from reg_dbp t1
    order by domestic_export,
             order_nbr,
             business_seg,
             brand_flag;

/*-*/
/* Authority
/*-*/
grant select on dw_app.reg_dbp_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym reg_dbp_view for dw_app.reg_dbp_view;

