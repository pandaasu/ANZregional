/******************************************************************************/
/*  NAME:       EFEX_CHN_CUSTOMER                                             */
/*  PURPOSE:    China EFEX Item view                                          */
/*  REVISIONS:                                                                */
/*  Ver    Date        Author           Description                           */
/*  -----  ----------  ---------------  ------------------------------------  */
/*  1.0    08-07-2008  Steve Gregan     Created View                          */
/******************************************************************************/

create or replace force view ics_app.efex_chn_customer
   (cust_code,
    name,
    address_1,
    city,
    state,
    post_code,
    phone_number,
    fax_number,
    affiliation,
    cust_type,
    status) as 
   select ltrim(cust.kunnr, '0') as cust_code,
          ltrim(addr.name ||' '|| addr.name_2) as name,
          ltrim(addr.house_no||' '||addr.street) as address_1,
          addr.city,
          addr.region as state,
          addr.postl_cod1 as post_code,
          addr.telephone as phone_number,
          addr.fax as fax_number,
          std_hier.cust_name_en_level_3 as affiliation,
          std_hier.cust_name_en_level_2 as cust_type,
          cust.loevm as status
     from lads_cus_hdr cust,
          std_hier,
          (select a1.obj_id, a1.obj_type, a2.name, a2.name_2, a2.sort1, a2.house_no,
                  a2.street, a2.city, a2.region, a2.postl_cod1, a2.countryiso,
                  a3.telephone, a3.extension, a3.tel_no, a4.fax, a4.fax_no
             from lads_adr_hdr a1,
                  lads_adr_det a2,
                  lads_adr_tel a3,
                  lads_adr_fax a4
            where a1.obj_type = 'KNA1'
              and a1.context = 1
              and a2.addr_vers(+) is null -- null for local address details (can be 'k' for kanji etc.)
              and a2.to_date(+) >= to_char(sysdate, 'yyyymmdd')
              and a3.std_no(+) = 'X'
              and a4.std_no(+) = 'X'
              and a1.obj_id = a2.obj_id(+)
              and a1.obj_type = a2.obj_type(+)
              and a1.context = a2.context(+)
              and a1.obj_id = a3.obj_id(+)
              and a1.obj_type = a3.obj_type(+)
              and a1.context = a3.context(+)
              and a1.obj_id = a4.obj_id(+)
              and a1.obj_type = a4.obj_type(+)
              and a1.context = a4.context(+)) addr,
          (select distinct g.vkorg, g.kunnr
             from lads_cus_sad g
            where g.vkorg in ('135')) org,
          (select c1.objek, c1.obtab,
                  max (case when atnam = 'CLFFERT103' then atwrt end) as pos_place_code,
                  max (case when atnam = 'CLFFERT101' then atwrt end) as pos_frmt_code,
                  max (case when atnam = 'CLFFERT108' then atwrt end) as op_bus_model_code,
                  max (case when atnam = 'CLFFERT107' then atwrt end) as prmry_route_code,
                  max (case when atnam = 'CLFFERT104' then atwrt end) as banner_code,
                  max (case when atnam = 'CLFFERT105' then atwrt end) as prnt_accnt_code,
                  max (case when atnam = 'CLFFERT106' then atwrt end) as dstrbtn_route_code,
                  max (case when atnam = 'CLFFERT36' then atwrt end) as cust_buying_group_code,
                  max (case when atnam = 'CLFFERT37' then atwrt end) as multi_mrkt_accnt_code,
                  max (case when atnam = 'CLFFERT41' then atwrt end) as pos_frmt_grpng_code
             from lads_cla_hdr c1, lads_cla_chr c2
            where c1.obtab = 'KNA1'
              and c1.klart = '011'
              and c1.obtab = c2.obtab(+)
              and c1.objek = c2.objek(+)
              and c1.klart = c2.klart(+)
            group by c1.objek, c1.obtab) classn
    where (cust.ktokd = '0001' or cust.ktokd = '0002') --Sold To and Ship To Customers
      and ltrim(cust.kunnr, '0') = std_hier.sap_hier_cust_code(+)
      and cust.kunnr = org.kunnr
      and cust.kunnr = addr.obj_id(+)
      and cust.kunnr = classn.objek(+);

/*-*/
/* Authority
/*-*/
grant select on ics_app.efex_chn_customer to ics_reader;
grant select on ics_app.efex_chn_customer to public;

/*-*/
/* Synonym
/*-*/
create or replace public synonym efex_chn_customer for ics_app.efex_chn_customer;
