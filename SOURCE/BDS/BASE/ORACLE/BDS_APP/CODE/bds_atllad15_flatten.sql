/******************/
/* Package Header */
/******************/
create or replace package bds_atllad15_flatten as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : BDS (Business Data Store)
    Package : bds_atllad15_flatten
    Owner   : bds_app
    Author  : Steve Gregan

    Description
    -----------
    Business Data Store - ATLLAD15 - Address Master (ADRMAS02)

    PARAMETERS
      1. PAR_ACTION [MANDATORY]
         *DOCUMENT            - ONLY to be called from LADS load package, assumes locking/commits in parent
         *DOCUMENT_OVERRIDE   - manual flattening execution, implements locks/commits internally
         *REFRESH             - process all unflattened LADS records
         *REBUILD             - process all LADS records - truncates BDS table(s) first
                              - RECOMMEND stopping ICS jobs prior to execution

    NOTES
      1. This package must raise an exception on failure to exclude database activity from parent commit

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/03   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_action in varchar2, par_obj_type in varchar2, par_obj_id in varchar2, par_context in number);

end bds_atllad15_flatten;
/

/****************/
/* Package Body */
/****************/
create or replace package body bds_atllad15_flatten as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   snapshot_exception exception;
   pragma exception_init(application_exception, -20000);
   pragma exception_init(snapshot_exception, -1555);

   /*-*/
   /* Private declarations
   /*-*/
   procedure lads_lock(par_obj_type in varchar2, par_obj_id in varchar2, par_context in number);
   procedure bds_flatten(par_obj_type in varchar2, par_obj_id in varchar2, par_context in number);
   procedure bds_refresh;
   procedure bds_rebuild;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_action in varchar2, par_obj_type in varchar2, par_obj_id in varchar2, par_context in number) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Execute BDS Flattening process
      /*-*/
      case upper(par_action)
        when '*DOCUMENT' then bds_flatten(par_obj_type, par_obj_id, par_context);
        when '*DOCUMENT_OVERRIDE' then lads_lock(par_obj_type, par_obj_id, par_context);
        when '*REFRESH' then bds_refresh;
        when '*REBUILD' then bds_rebuild;
        else raise_application_error(-20000, 'Action parameter must be *DOCUMENT, *DOCUMENT_OVERRIDE, *REFRESH or *REBUILD');
      end case;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'bds_atllad15_flatten - EXECUTE ' || par_action || ' - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /***************************************************/
   /* This procedure perfroms the BDS Flatten routine */
   /***************************************************/
   procedure bds_flatten(par_obj_type in varchar2, par_obj_id in varchar2, par_context in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_flattened varchar2(1);
      var_excluded boolean;

      /*-*/
      /* BDS record definitions
      /*-*/
      rcd_bds_addr_header bds_addr_header%rowtype;
      rcd_bds_addr_comment bds_addr_comment%rowtype;
      rcd_bds_addr_detail bds_addr_detail%rowtype;
      rcd_bds_addr_email bds_addr_email%rowtype;
      rcd_bds_addr_fax bds_addr_fax%rowtype;
      rcd_bds_addr_phone bds_addr_phone%rowtype;
      rcd_bds_addr_url bds_addr_url%rowtype;
      rcd_bds_addr_customer bds_addr_customer%rowtype;
      rcd_bds_addr_vendor bds_addr_vendor%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_adr_hdr is
         select t01.obj_type as obj_type,
                t01.obj_id as obj_id,
                t01.context as context,
                t01.idoc_name as idoc_name,
                t01.idoc_number as idoc_number,
                t01.idoc_timestamp as idoc_timestamp,
                t01.lads_date as lads_date,
                t01.lads_status as lads_status,
                t01.obj_id_ext as obj_id_ext
           from lads_adr_hdr t01
          where t01.obj_type = par_obj_type
            and t01.obj_id = par_obj_id
            and t01.context = par_context;
      rcd_lads_adr_hdr csr_lads_adr_hdr%rowtype;

      cursor csr_lads_adr_com is
         select * from (
            select t01.obj_type as obj_type,
                   t01.obj_id as obj_id,
                   t01.context as context,
                   t01.comseq as comseq,
                   nvl(t01.addr_vers,'*NONE') as addr_vers,
                   nvl(t01.langu,'*NONE') as langu,
                   t01.langu_iso as langu_iso,
                   t01.adr_notes as adr_notes,
                   t01.errorflag as errorflag,
                   rank() over (partition by nvl(t01.addr_vers,'*NONE'),
                                             nvl(t01.langu,'*NONE')
                                    order by t01.comseq) as rnkseq
              from lads_adr_com t01
             where t01.obj_type = rcd_lads_adr_hdr.obj_type
               and t01.obj_id = rcd_lads_adr_hdr.obj_id
               and t01.context = rcd_lads_adr_hdr.context)
         where rnkseq = 1;
      rcd_lads_adr_com csr_lads_adr_com%rowtype;

      cursor csr_lads_adr_det is
         select t01.*,
                t02.telephone,
                t02.tel_ext,
                t02.tel_no,
                t03.fax,
                t03.fax_ext,
                t03.fax_no
           from (
            select t01.obj_type as obj_type,
                   t01.obj_id as obj_id,
                   t01.context as context,
                   t01.detseq as detseq,
                   nvl(t01.addr_vers,'*NONE') as addr_vers,
                   bds_date.bds_to_date('*START_DATE',t01.from_date) as from_date,
                   bds_date.bds_to_date('*END_DATE',t01.to_date) as to_date,
                   t01.title as title,
                   t01.name as name,
                   t01.name_2 as name_2,
                   t01.name_3 as name_3,
                   t01.name_4 as name_4,
                   t01.conv_name as conv_name,
                   t01.c_o_name as c_o_name,
                   t01.city as city,
                   t01.district as district,
                   t01.city_no as city_no,
                   t01.distrct_no as distrct_no,
                   t01.chckstatus as chckstatus,
                   t01.regiogroup as regiogroup,
                   t01.postl_cod1 as postl_cod1,
                   t01.postl_cod2 as postl_cod2,
                   t01.postl_cod3 as postl_cod3,
                   t01.pcode1_ext as pcode1_ext,
                   t01.pcode2_ext as pcode2_ext,
                   t01.pcode3_ext as pcode3_ext,
                   t01.po_box as po_box,
                   t01.po_w_o_no as po_w_o_no,
                   t01.po_box_cit as po_box_cit,
                   t01.pboxcit_no as pboxcit_no,
                   t01.po_box_reg as po_box_reg,
                   t01.pobox_ctry as pobox_ctry,
                   t01.po_ctryiso as po_ctryiso,
                   t01.deliv_dis as deliv_dis,
                   t01.transpzone as transpzone,
                   t01.street as street,
                   t01.street_no as street_no,
                   t01.str_abbr as str_abbr,
                   t01.house_no as house_no,
                   t01.house_no2 as house_no2,
                   t01.house_no3 as house_no3,
                   t01.str_suppl1 as str_suppl1,
                   t01.str_suppl2 as str_suppl2,
                   t01.str_suppl3 as str_suppl3,
                   t01.location as location,
                   t01.building as building,
                   t01.floor as floor,
                   t01.room_no as room_no,
                   t01.country as country,
                   t01.countryiso as countryiso,
                   t01.langu as langu,
                   t01.langu_iso as langu_iso,
                   t01.region as region,
                   t01.sort1 as sort1,
                   t01.sort2 as sort2,
                   t01.extens_1 as extens_1,
                   t01.extens_2 as extens_2,
                   t01.time_zone as time_zone,
                   t01.taxjurcode as taxjurcode,
                   t01.address_id as address_id,
                   t01.langu_cr as langu_cr,
                   t01.langucriso as langucriso,
                   t01.comm_type as comm_type,
                   t01.addr_group as addr_group,
                   t01.home_city as home_city,
                   t01.homecityno as homecityno,
                   t01.dont_use_s as dont_use_s,
                   t01.dont_use_p as dont_use_p,
                   rank() over (partition by nvl(t01.addr_vers,'*NONE'),
                                             t01.from_date,
                                             t01.to_date
                                    order by t01.detseq) as rnkseq
              from lads_adr_det t01
             where t01.obj_type = rcd_lads_adr_hdr.obj_type
               and t01.obj_id = rcd_lads_adr_hdr.obj_id
               and t01.context = rcd_lads_adr_hdr.context) t01,
           (select t01.obj_type as obj_type02,
                   t01.obj_id as obj_id02,
                   t01.context as context02,
                   t01.telephone,
                   t01.extension as tel_ext,
                   t01.tel_no
              from lads_adr_tel t01
            where t01.obj_type = rcd_lads_adr_hdr.obj_type
              and t01.obj_id = rcd_lads_adr_hdr.obj_id
              and t01.context = rcd_lads_adr_hdr.context
              and t01.std_no = 'X') t02,
           (select t01.obj_type as obj_type03,
                   t01.obj_id as obj_id03,
                   t01.context as context03,
                   t01.fax,
                   t01.extension as fax_ext,
                   t01.fax_no
              from lads_adr_fax t01
            where t01.obj_type = rcd_lads_adr_hdr.obj_type
              and t01.obj_id = rcd_lads_adr_hdr.obj_id
              and t01.context = rcd_lads_adr_hdr.context
              and t01.std_no = 'X') t03
         where t01.rnkseq = 1
           and t01.obj_type = t02.obj_type02(+)
           and t01.obj_id = t02.obj_id02(+)
           and t01.context = t02.context02(+)
           and t01.obj_type = t03.obj_type03(+)
           and t01.obj_id = t03.obj_id03(+)
           and t01.context = t03.context03(+);
      rcd_lads_adr_det csr_lads_adr_det%rowtype;

      cursor csr_lads_adr_ema is
         select t01.obj_type as obj_type,
                t01.obj_id as obj_id,
                t01.context as context,
                t01.emaseq as emaseq,
                t01.std_no as std_no,
                t01.e_mail as e_mail,
                t01.email_srch as email_srch,
                t01.std_recip as std_recip,
                t01.r_3_user as r_3_user,
                t01.encode as encode,
                t01.tnef as tnef,
                t01.home_flag as home_flag,
                t01.consnumber as consnumber,
                t01.errorflag as errorflag,
                t01.flg_nouse as flg_nouse
           from lads_adr_ema t01
          where t01.obj_type = rcd_lads_adr_hdr.obj_type
            and t01.obj_id = rcd_lads_adr_hdr.obj_id
            and t01.context = rcd_lads_adr_hdr.context;
      rcd_lads_adr_ema csr_lads_adr_ema%rowtype;

      cursor csr_lads_adr_fax is
         select t01.obj_type as obj_type,
                t01.obj_id as obj_id,
                t01.context as context,
                t01.faxseq as faxseq,
                t01.country as country,
                t01.countryiso as countryiso,
                t01.std_no as std_no,
                t01.fax as fax,
                t01.extension as extension,
                t01.fax_no as fax_no,
                t01.sender_no as sender_no,
                t01.fax_group as fax_group,
                t01.std_recip as std_recip,
                t01.r_3_user as r_3_user,
                t01.home_flag as home_flag,
                t01.consnumber as consnumber,
                t01.errorflag as errorflag,
                t01.flg_nouse as flg_nouse
           from lads_adr_fax t01
          where t01.obj_type = rcd_lads_adr_hdr.obj_type
            and t01.obj_id = rcd_lads_adr_hdr.obj_id
            and t01.context = rcd_lads_adr_hdr.context;
      rcd_lads_adr_fax csr_lads_adr_fax%rowtype;

      cursor csr_lads_adr_tel is
         select t01.obj_type as obj_type,
                t01.obj_id as obj_id,
                t01.context as context,
                t01.telseq as telseq,
                t01.country as country,
                t01.countryiso as countryiso,
                t01.std_no as std_no,
                t01.telephone as telephone,
                t01.extension as extension,
                t01.tel_no as tel_no,
                t01.caller_no as caller_no,
                t01.std_recip as std_recip,
                t01.r_3_user as r_3_user,
                t01.home_flag as home_flag,
                t01.consnumber as consnumber,
                t01.errorflag as errorflag,
                t01.flg_nouse as flg_nouse
           from lads_adr_tel t01
          where t01.obj_type = rcd_lads_adr_hdr.obj_type
            and t01.obj_id = rcd_lads_adr_hdr.obj_id
            and t01.context = rcd_lads_adr_hdr.context;
      rcd_lads_adr_tel csr_lads_adr_tel%rowtype;

      cursor csr_lads_adr_url is
         select t01.obj_type as obj_type,
                t01.obj_id as obj_id,
                t01.context as context,
                t01.urlseq as urlseq,
                t01.std_no as std_no,
                t01.uri_type as uri_type,
                t01.uri as uri,
                t01.std_recip as std_recip,
                t01.home_flag as home_flag,
                t01.consnumber as consnumber,
                t01.uri_part1 as uri_part1,
                t01.uri_part2 as uri_part2,
                t01.uri_part3 as uri_part3,
                t01.uri_part4 as uri_part4,
                t01.uri_part5 as uri_part5,
                t01.uri_part6 as uri_part6,
                t01.uri_part7 as uri_part7,
                t01.uri_part8 as uri_part8,
                t01.uri_part9 as uri_part9,
                t01.errorflag as errorflag,
                t01.flg_nouse as flg_nouse
           from lads_adr_url t01
          where t01.obj_type = rcd_lads_adr_hdr.obj_type
            and t01.obj_id = rcd_lads_adr_hdr.obj_id
            and t01.context = rcd_lads_adr_hdr.context;
      rcd_lads_adr_url csr_lads_adr_url%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_excluded := false;
      var_flattened := '1';

      /*-*/
      /* Perform BDS Flattening Logic
      /* **note** - assumes that a lock is held in a parent procedure
      /*          - assumes commit/rollback will be issued in a parent procedure
      /*-*/

      /*-*/
      /* Delete the BDS table child data
      /*-*/
      delete from bds_addr_comment where address_type = par_obj_type and address_code = par_obj_id and address_context = par_context;
      delete from bds_addr_detail where address_type = par_obj_type and address_code = par_obj_id and address_context = par_context;
      delete from bds_addr_email where address_type = par_obj_type and address_code = par_obj_id and address_context = par_context;
      delete from bds_addr_fax where address_type = par_obj_type and address_code = par_obj_id and address_context = par_context;
      delete from bds_addr_phone where address_type = par_obj_type and address_code = par_obj_id and address_context = par_context;
      delete from bds_addr_url where address_type = par_obj_type and address_code = par_obj_id and address_context = par_context;

      /*-*/
      /* Delete the BDS customer/vendor data when required
      /*-*/
      if par_context = 1 then
         if par_obj_type = 'KNA1' then
            delete from bds_addr_customer where customer_code = par_obj_id;
         end if;
         if par_obj_type = 'LFA1' then
            delete from bds_addr_vendor where vendor_code = par_obj_id;
         end if;
      end if;

      /*-*/
      /* Retrieve the LADS header
      /*-*/
      open csr_lads_adr_hdr;
      fetch csr_lads_adr_hdr into rcd_lads_adr_hdr;
      if csr_lads_adr_hdr%notfound then
         raise_application_error(-20000, 'LADS Header row not found');
      end if;
      close csr_lads_adr_hdr;

      /*-*/
      /* Set the BDS header values
      /*-*/
      rcd_bds_addr_header.address_type := rcd_lads_adr_hdr.obj_type;
      rcd_bds_addr_header.address_code := rcd_lads_adr_hdr.obj_id;
      rcd_bds_addr_header.address_context := rcd_lads_adr_hdr.context;
      rcd_bds_addr_header.sap_idoc_name := rcd_lads_adr_hdr.idoc_name;
      rcd_bds_addr_header.sap_idoc_number := rcd_lads_adr_hdr.idoc_number;
      rcd_bds_addr_header.sap_idoc_timestamp := rcd_lads_adr_hdr.idoc_timestamp;
      rcd_bds_addr_header.bds_lads_date := rcd_lads_adr_hdr.lads_date;
      rcd_bds_addr_header.bds_lads_status := rcd_lads_adr_hdr.lads_status;
      rcd_bds_addr_header.address_key := rcd_lads_adr_hdr.obj_id_ext;

      /*-*/
      /* Update the BDS header
      /*-*/
      update bds_addr_header
         set sap_idoc_name = rcd_bds_addr_header.sap_idoc_name,
             sap_idoc_number = rcd_bds_addr_header.sap_idoc_number,
             sap_idoc_timestamp = rcd_bds_addr_header.sap_idoc_timestamp,
             bds_lads_date = rcd_bds_addr_header.bds_lads_date,
             bds_lads_status = rcd_bds_addr_header.bds_lads_status,
             address_key = rcd_bds_addr_header.address_key
         where address_type = rcd_bds_addr_header.address_type
           and address_code = rcd_bds_addr_header.address_code
           and address_context = rcd_bds_addr_header.address_context;
      if sql%notfound then
         insert into bds_addr_header
            (address_type,
             address_code,
             address_context,
             sap_idoc_name,
             sap_idoc_number,
             sap_idoc_timestamp,
             bds_lads_date,
             bds_lads_status,
             address_key)
             values(rcd_bds_addr_header.address_type,
                    rcd_bds_addr_header.address_code,
                    rcd_bds_addr_header.address_context,
                    rcd_bds_addr_header.sap_idoc_name,
                    rcd_bds_addr_header.sap_idoc_number,
                    rcd_bds_addr_header.sap_idoc_timestamp,
                    rcd_bds_addr_header.bds_lads_date,
                    rcd_bds_addr_header.bds_lads_status,
                    rcd_bds_addr_header.address_key);
      end if;

      /*-*/
      /* Process the LADS address comment
      /*-*/
      open csr_lads_adr_com;
      loop
         fetch csr_lads_adr_com into rcd_lads_adr_com;
         if csr_lads_adr_com%notfound then
            exit;
         end if;

         /*-*/
         /* Set the BDS child values
         /*-*/
         rcd_bds_addr_comment.address_type := rcd_lads_adr_com.obj_type;
         rcd_bds_addr_comment.address_code := rcd_lads_adr_com.obj_id;
         rcd_bds_addr_comment.address_context := rcd_lads_adr_com.context;
         rcd_bds_addr_comment.address_version := rcd_lads_adr_com.addr_vers;
         rcd_bds_addr_comment.address_language := rcd_lads_adr_com.langu;
         rcd_bds_addr_comment.address_language_iso := rcd_lads_adr_com.langu_iso;
         rcd_bds_addr_comment.address_notes := rcd_lads_adr_com.adr_notes;
         rcd_bds_addr_comment.error_flag := rcd_lads_adr_com.errorflag;

         /*-*/
         /* Insert the child row
         /*-*/
         insert into bds_addr_comment
            (address_type,
             address_code,
             address_context,
             address_version,
             address_language,
             address_language_iso,
             address_notes,
             error_flag)
             values(rcd_bds_addr_comment.address_type,
                    rcd_bds_addr_comment.address_code,
                    rcd_bds_addr_comment.address_context,
                    rcd_bds_addr_comment.address_version,
                    rcd_bds_addr_comment.address_language,
                    rcd_bds_addr_comment.address_language_iso,
                    rcd_bds_addr_comment.address_notes,
                    rcd_bds_addr_comment.error_flag);

      end loop;
      close csr_lads_adr_com;

      /*-*/
      /* Process the LADS address detail
      /*-*/
      open csr_lads_adr_det;
      loop
         fetch csr_lads_adr_det into rcd_lads_adr_det;
         if csr_lads_adr_det%notfound then
            exit;
         end if;

         /*-*/
         /* Set the BDS child values
         /*-*/
         rcd_bds_addr_detail.address_type := rcd_lads_adr_det.obj_type;
         rcd_bds_addr_detail.address_code := rcd_lads_adr_det.obj_id;
         rcd_bds_addr_detail.address_context := rcd_lads_adr_det.context;
         rcd_bds_addr_detail.address_version := rcd_lads_adr_det.addr_vers;
         rcd_bds_addr_detail.valid_from_date := rcd_lads_adr_det.from_date;
         rcd_bds_addr_detail.valid_to_date := rcd_lads_adr_det.to_date;
         rcd_bds_addr_detail.title := rcd_lads_adr_det.title;
         rcd_bds_addr_detail.name := rcd_lads_adr_det.name;
         rcd_bds_addr_detail.name_02 := rcd_lads_adr_det.name_2;
         rcd_bds_addr_detail.name_03 := rcd_lads_adr_det.name_3;
         rcd_bds_addr_detail.name_04 := rcd_lads_adr_det.name_4;
         rcd_bds_addr_detail.converted_name := rcd_lads_adr_det.conv_name;
         rcd_bds_addr_detail.c_o_name := rcd_lads_adr_det.c_o_name;
         rcd_bds_addr_detail.city := rcd_lads_adr_det.city;
         rcd_bds_addr_detail.district := rcd_lads_adr_det.district;
         rcd_bds_addr_detail.city_code := rcd_lads_adr_det.city_no;
         rcd_bds_addr_detail.district_code := rcd_lads_adr_det.distrct_no;
         rcd_bds_addr_detail.city_status := rcd_lads_adr_det.chckstatus;
         rcd_bds_addr_detail.regional_structure_grouping := rcd_lads_adr_det.regiogroup;
         rcd_bds_addr_detail.city_post_code := rcd_lads_adr_det.postl_cod1;
         rcd_bds_addr_detail.po_box_post_code := rcd_lads_adr_det.postl_cod2;
         rcd_bds_addr_detail.company_post_code := rcd_lads_adr_det.postl_cod3;
         rcd_bds_addr_detail.city_post_code_extension := rcd_lads_adr_det.pcode1_ext;
         rcd_bds_addr_detail.po_box_post_code_extension := rcd_lads_adr_det.pcode2_ext;
         rcd_bds_addr_detail.company_post_code_extension := rcd_lads_adr_det.pcode3_ext;
         rcd_bds_addr_detail.po_box := rcd_lads_adr_det.po_box;
         rcd_bds_addr_detail.po_box_minus_number := rcd_lads_adr_det.po_w_o_no;
         rcd_bds_addr_detail.po_box_city := rcd_lads_adr_det.po_box_cit;
         rcd_bds_addr_detail.po_box_city_code := rcd_lads_adr_det.pboxcit_no;
         rcd_bds_addr_detail.po_box_region := rcd_lads_adr_det.po_box_reg;
         rcd_bds_addr_detail.po_box_country := rcd_lads_adr_det.pobox_ctry;
         rcd_bds_addr_detail.po_box_country_iso := rcd_lads_adr_det.po_ctryiso;
         rcd_bds_addr_detail.delivery_district := rcd_lads_adr_det.deliv_dis;
         rcd_bds_addr_detail.transportation_zone := rcd_lads_adr_det.transpzone;
         rcd_bds_addr_detail.street := rcd_lads_adr_det.street;
         rcd_bds_addr_detail.street_code := rcd_lads_adr_det.street_no;
         rcd_bds_addr_detail.street_abbreviated := rcd_lads_adr_det.str_abbr;
         rcd_bds_addr_detail.house_number := rcd_lads_adr_det.house_no;
         rcd_bds_addr_detail.house_number_supplement := rcd_lads_adr_det.house_no2;
         rcd_bds_addr_detail.house_number_range := rcd_lads_adr_det.house_no3;
         rcd_bds_addr_detail.street_supplement_01 := rcd_lads_adr_det.str_suppl1;
         rcd_bds_addr_detail.street_supplement_02 := rcd_lads_adr_det.str_suppl2;
         rcd_bds_addr_detail.street_supplement_03 := rcd_lads_adr_det.str_suppl3;
         rcd_bds_addr_detail.location := rcd_lads_adr_det.location;
         rcd_bds_addr_detail.building := rcd_lads_adr_det.building;
         rcd_bds_addr_detail.floor := rcd_lads_adr_det.floor;
         rcd_bds_addr_detail.room_number := rcd_lads_adr_det.room_no;
         rcd_bds_addr_detail.country := rcd_lads_adr_det.country;
         rcd_bds_addr_detail.country_iso := rcd_lads_adr_det.countryiso;
         rcd_bds_addr_detail.language := rcd_lads_adr_det.langu;
         rcd_bds_addr_detail.language_iso := rcd_lads_adr_det.langu_iso;
         rcd_bds_addr_detail.region_code := rcd_lads_adr_det.region;
         rcd_bds_addr_detail.search_term_01 := rcd_lads_adr_det.sort1;
         rcd_bds_addr_detail.search_term_02 := rcd_lads_adr_det.sort2;
         rcd_bds_addr_detail.data_extension_01 := rcd_lads_adr_det.extens_1;
         rcd_bds_addr_detail.data_extension_02 := rcd_lads_adr_det.extens_2;
         rcd_bds_addr_detail.time_zone := rcd_lads_adr_det.time_zone;
         rcd_bds_addr_detail.tax_jurisdiction_code := rcd_lads_adr_det.taxjurcode;
         rcd_bds_addr_detail.address_identifier := rcd_lads_adr_det.address_id;
         rcd_bds_addr_detail.creation_language := rcd_lads_adr_det.langu_cr;
         rcd_bds_addr_detail.language_iso639 := rcd_lads_adr_det.langucriso;
         rcd_bds_addr_detail.communication_type := rcd_lads_adr_det.comm_type;
         rcd_bds_addr_detail.address_group := rcd_lads_adr_det.addr_group;
         rcd_bds_addr_detail.home_city := rcd_lads_adr_det.home_city;
         rcd_bds_addr_detail.home_city_code := rcd_lads_adr_det.homecityno;
         rcd_bds_addr_detail.street_undeliverable_flag := rcd_lads_adr_det.dont_use_s;
         rcd_bds_addr_detail.po_box_undeliverable_flag := rcd_lads_adr_det.dont_use_p;

         /*-*/
         /* Insert the child row
         /*-*/
         insert into bds_addr_detail
            (address_type,
             address_code,
             address_context,
             address_version,
             valid_from_date,
             valid_to_date,
             title,
             name,
             name_02,
             name_03,
             name_04,
             converted_name,
             c_o_name,
             city,
             district,
             city_code,
             district_code,
             city_status,
             regional_structure_grouping,
             city_post_code,
             po_box_post_code,
             company_post_code,
             city_post_code_extension,
             po_box_post_code_extension,
             company_post_code_extension,
             po_box,
             po_box_minus_number,
             po_box_city,
             po_box_city_code,
             po_box_region,
             po_box_country,
             po_box_country_iso,
             delivery_district,
             transportation_zone,
             street,
             street_code,
             street_abbreviated,
             house_number,
             house_number_supplement,
             house_number_range,
             street_supplement_01,
             street_supplement_02,
             street_supplement_03,
             location,
             building,
             floor,
             room_number,
             country,
             country_iso,
             language,
             language_iso,
             region_code,
             search_term_01,
             search_term_02,
             data_extension_01,
             data_extension_02,
             time_zone,
             tax_jurisdiction_code,
             address_identifier,
             creation_language,
             language_iso639,
             communication_type,
             address_group,
             home_city,
             home_city_code,
             street_undeliverable_flag,
             po_box_undeliverable_flag)
             values(rcd_bds_addr_detail.address_type,
                    rcd_bds_addr_detail.address_code,
                    rcd_bds_addr_detail.address_context,
                    rcd_bds_addr_detail.address_version,
                    rcd_bds_addr_detail.valid_from_date,
                    rcd_bds_addr_detail.valid_to_date,
                    rcd_bds_addr_detail.title,
                    rcd_bds_addr_detail.name,
                    rcd_bds_addr_detail.name_02,
                    rcd_bds_addr_detail.name_03,
                    rcd_bds_addr_detail.name_04,
                    rcd_bds_addr_detail.converted_name,
                    rcd_bds_addr_detail.c_o_name,
                    rcd_bds_addr_detail.city,
                    rcd_bds_addr_detail.district,
                    rcd_bds_addr_detail.city_code,
                    rcd_bds_addr_detail.district_code,
                    rcd_bds_addr_detail.city_status,
                    rcd_bds_addr_detail.regional_structure_grouping,
                    rcd_bds_addr_detail.city_post_code,
                    rcd_bds_addr_detail.po_box_post_code,
                    rcd_bds_addr_detail.company_post_code,
                    rcd_bds_addr_detail.city_post_code_extension,
                    rcd_bds_addr_detail.po_box_post_code_extension,
                    rcd_bds_addr_detail.company_post_code_extension,
                    rcd_bds_addr_detail.po_box,
                    rcd_bds_addr_detail.po_box_minus_number,
                    rcd_bds_addr_detail.po_box_city,
                    rcd_bds_addr_detail.po_box_city_code,
                    rcd_bds_addr_detail.po_box_region,
                    rcd_bds_addr_detail.po_box_country,
                    rcd_bds_addr_detail.po_box_country_iso,
                    rcd_bds_addr_detail.delivery_district,
                    rcd_bds_addr_detail.transportation_zone,
                    rcd_bds_addr_detail.street,
                    rcd_bds_addr_detail.street_code,
                    rcd_bds_addr_detail.street_abbreviated,
                    rcd_bds_addr_detail.house_number,
                    rcd_bds_addr_detail.house_number_supplement,
                    rcd_bds_addr_detail.house_number_range,
                    rcd_bds_addr_detail.street_supplement_01,
                    rcd_bds_addr_detail.street_supplement_02,
                    rcd_bds_addr_detail.street_supplement_03,
                    rcd_bds_addr_detail.location,
                    rcd_bds_addr_detail.building,
                    rcd_bds_addr_detail.floor,
                    rcd_bds_addr_detail.room_number,
                    rcd_bds_addr_detail.country,
                    rcd_bds_addr_detail.country_iso,
                    rcd_bds_addr_detail.language,
                    rcd_bds_addr_detail.language_iso,
                    rcd_bds_addr_detail.region_code,
                    rcd_bds_addr_detail.search_term_01,
                    rcd_bds_addr_detail.search_term_02,
                    rcd_bds_addr_detail.data_extension_01,
                    rcd_bds_addr_detail.data_extension_02,
                    rcd_bds_addr_detail.time_zone,
                    rcd_bds_addr_detail.tax_jurisdiction_code,
                    rcd_bds_addr_detail.address_identifier,
                    rcd_bds_addr_detail.creation_language,
                    rcd_bds_addr_detail.language_iso639,
                    rcd_bds_addr_detail.communication_type,
                    rcd_bds_addr_detail.address_group,
                    rcd_bds_addr_detail.home_city,
                    rcd_bds_addr_detail.home_city_code,
                    rcd_bds_addr_detail.street_undeliverable_flag,
                    rcd_bds_addr_detail.po_box_undeliverable_flag);

         /*-*/
         /* Insert the BDS customer/vendor data when required
         /*-*/
         if rcd_bds_addr_detail.address_context = 1 then
            if rcd_bds_addr_detail.address_type = 'KNA1' then
               insert into bds_addr_customer
                  (customer_code,
                   address_version,
                   valid_from_date,
                   valid_to_date,
                   title,
                   name,
                   name_02,
                   name_03,
                   name_04,
                   city,
                   district,
                   city_post_code,
                   po_box_post_code,
                   company_post_code,
                   po_box,
                   po_box_minus_number,
                   po_box_city,
                   po_box_region,
                   po_box_country,
                   po_box_country_iso,
                   transportation_zone,
                   street,
                   house_number,
                   location,
                   building,
                   floor,
                   room_number,
                   country,
                   country_iso,
                   language,
                   language_iso,
                   region_code,
                   search_term_01,
                   search_term_02,
                   phone_number,
                   phone_extension,
                   phone_full_number,
                   fax_number,
                   fax_extension,
                   fax_full_number)
                   values(rcd_bds_addr_detail.address_code,
                          rcd_bds_addr_detail.address_version,
                          rcd_bds_addr_detail.valid_from_date,
                          rcd_bds_addr_detail.valid_to_date,
                          rcd_bds_addr_detail.title,
                          rcd_bds_addr_detail.name,
                          rcd_bds_addr_detail.name_02,
                          rcd_bds_addr_detail.name_03,
                          rcd_bds_addr_detail.name_04,
                          rcd_bds_addr_detail.city,
                          rcd_bds_addr_detail.district,
                          rcd_bds_addr_detail.city_post_code,
                          rcd_bds_addr_detail.po_box_post_code,
                          rcd_bds_addr_detail.company_post_code,
                          rcd_bds_addr_detail.po_box,
                          rcd_bds_addr_detail.po_box_minus_number,
                          rcd_bds_addr_detail.po_box_city,
                          rcd_bds_addr_detail.po_box_region,
                          rcd_bds_addr_detail.po_box_country,
                          rcd_bds_addr_detail.po_box_country_iso,
                          rcd_bds_addr_detail.transportation_zone,
                          rcd_bds_addr_detail.street,
                          rcd_bds_addr_detail.house_number,
                          rcd_bds_addr_detail.location,
                          rcd_bds_addr_detail.building,
                          rcd_bds_addr_detail.floor,
                          rcd_bds_addr_detail.room_number,
                          rcd_bds_addr_detail.country,
                          rcd_bds_addr_detail.country_iso,
                          rcd_bds_addr_detail.language,
                          rcd_bds_addr_detail.language_iso,
                          rcd_bds_addr_detail.region_code,
                          rcd_bds_addr_detail.search_term_01,
                          rcd_bds_addr_detail.search_term_02,
                          rcd_lads_adr_det.telephone,
                          rcd_lads_adr_det.tel_ext,
                          rcd_lads_adr_det.tel_no,
                          rcd_lads_adr_det.fax,
                          rcd_lads_adr_det.fax_ext,
                          rcd_lads_adr_det.fax_no);
            end if;
            if rcd_bds_addr_detail.address_type = 'LFA1' then
               insert into bds_addr_vendor
                  (vendor_code,
                   address_version,
                   valid_from_date,
                   valid_to_date,
                   title,
                   name,
                   name_02,
                   name_03,
                   name_04,
                   city,
                   district,
                   city_post_code,
                   po_box_post_code,
                   company_post_code,
                   po_box,
                   po_box_minus_number,
                   po_box_city,
                   po_box_region,
                   po_box_country,
                   po_box_country_iso,
                   transportation_zone,
                   street,
                   house_number,
                   location,
                   building,
                   floor,
                   room_number,
                   country,
                   country_iso,
                   language,
                   language_iso,
                   region_code,
                   search_term_01,
                   search_term_02,
                   phone_number,
                   phone_extension,
                   phone_full_number,
                   fax_number,
                   fax_extension,
                   fax_full_number)
                   values(rcd_bds_addr_detail.address_code,
                          rcd_bds_addr_detail.address_version,
                          rcd_bds_addr_detail.valid_from_date,
                          rcd_bds_addr_detail.valid_to_date,
                          rcd_bds_addr_detail.title,
                          rcd_bds_addr_detail.name,
                          rcd_bds_addr_detail.name_02,
                          rcd_bds_addr_detail.name_03,
                          rcd_bds_addr_detail.name_04,
                          rcd_bds_addr_detail.city,
                          rcd_bds_addr_detail.district,
                          rcd_bds_addr_detail.city_post_code,
                          rcd_bds_addr_detail.po_box_post_code,
                          rcd_bds_addr_detail.company_post_code,
                          rcd_bds_addr_detail.po_box,
                          rcd_bds_addr_detail.po_box_minus_number,
                          rcd_bds_addr_detail.po_box_city,
                          rcd_bds_addr_detail.po_box_region,
                          rcd_bds_addr_detail.po_box_country,
                          rcd_bds_addr_detail.po_box_country_iso,
                          rcd_bds_addr_detail.transportation_zone,
                          rcd_bds_addr_detail.street,
                          rcd_bds_addr_detail.house_number,
                          rcd_bds_addr_detail.location,
                          rcd_bds_addr_detail.building,
                          rcd_bds_addr_detail.floor,
                          rcd_bds_addr_detail.room_number,
                          rcd_bds_addr_detail.country,
                          rcd_bds_addr_detail.country_iso,
                          rcd_bds_addr_detail.language,
                          rcd_bds_addr_detail.language_iso,
                          rcd_bds_addr_detail.region_code,
                          rcd_bds_addr_detail.search_term_01,
                          rcd_bds_addr_detail.search_term_02,
                          rcd_lads_adr_det.telephone,
                          rcd_lads_adr_det.tel_ext,
                          rcd_lads_adr_det.tel_no,
                          rcd_lads_adr_det.fax,
                          rcd_lads_adr_det.fax_ext,
                          rcd_lads_adr_det.fax_no);
            end if;
         end if;

      end loop;
      close csr_lads_adr_det;

      /*-*/
      /* Process the LADS address email
      /*-*/
      open csr_lads_adr_ema;
      loop
         fetch csr_lads_adr_ema into rcd_lads_adr_ema;
         if csr_lads_adr_ema%notfound then
            exit;
         end if;

         /*-*/
         /* Set the BDS child values
         /*-*/
         rcd_bds_addr_email.address_type := rcd_lads_adr_ema.obj_type;
         rcd_bds_addr_email.address_code := rcd_lads_adr_ema.obj_id;
         rcd_bds_addr_email.address_context := rcd_lads_adr_ema.context;
         rcd_bds_addr_email.address_sequence := rcd_lads_adr_ema.emaseq;
         rcd_bds_addr_email.standard_sender_flag := rcd_lads_adr_ema.std_no;
         rcd_bds_addr_email.email_address := rcd_lads_adr_ema.e_mail;
         rcd_bds_addr_email.email_search := rcd_lads_adr_ema.email_srch;
         rcd_bds_addr_email.standard_receiver_flag := rcd_lads_adr_ema.std_recip;
         rcd_bds_addr_email.sap_r3_user := rcd_lads_adr_ema.r_3_user;
         rcd_bds_addr_email.smtp_encoding := rcd_lads_adr_ema.encode;
         rcd_bds_addr_email.tnef_coding_flag := rcd_lads_adr_ema.tnef;
         rcd_bds_addr_email.home_flag := rcd_lads_adr_ema.home_flag;
         rcd_bds_addr_email.sequence_number := rcd_lads_adr_ema.consnumber;
         rcd_bds_addr_email.error_flag := rcd_lads_adr_ema.errorflag;
         rcd_bds_addr_email.not_used_flag := rcd_lads_adr_ema.flg_nouse;

         /*-*/
         /* Insert the child row
         /*-*/
         insert into bds_addr_email
            (address_type,
             address_code,
             address_context,
             address_sequence,
             standard_sender_flag,
             email_address,
             email_search,
             standard_receiver_flag,
             sap_r3_user,
             smtp_encoding,
             tnef_coding_flag,
             home_flag,
             sequence_number,
             error_flag,
             not_used_flag)
             values(rcd_bds_addr_email.address_type,
                    rcd_bds_addr_email.address_code,
                    rcd_bds_addr_email.address_context,
                    rcd_bds_addr_email.address_sequence,
                    rcd_bds_addr_email.standard_sender_flag,
                    rcd_bds_addr_email.email_address,
                    rcd_bds_addr_email.email_search,
                    rcd_bds_addr_email.standard_receiver_flag,
                    rcd_bds_addr_email.sap_r3_user,
                    rcd_bds_addr_email.smtp_encoding,
                    rcd_bds_addr_email.tnef_coding_flag,
                    rcd_bds_addr_email.home_flag,
                    rcd_bds_addr_email.sequence_number,
                    rcd_bds_addr_email.error_flag,
                    rcd_bds_addr_email.not_used_flag);

      end loop;
      close csr_lads_adr_ema;

      /*-*/
      /* Process the LADS address fax
      /*-*/
      open csr_lads_adr_fax;
      loop
         fetch csr_lads_adr_fax into rcd_lads_adr_fax;
         if csr_lads_adr_fax%notfound then
            exit;
         end if;

         /*-*/
         /* Set the BDS child values
         /*-*/
         rcd_bds_addr_fax.address_type := rcd_lads_adr_fax.obj_type;
         rcd_bds_addr_fax.address_code := rcd_lads_adr_fax.obj_id;
         rcd_bds_addr_fax.address_context := rcd_lads_adr_fax.context;
         rcd_bds_addr_fax.address_sequence := rcd_lads_adr_fax.faxseq;
         rcd_bds_addr_fax.country := rcd_lads_adr_fax.country;
         rcd_bds_addr_fax.country_iso := rcd_lads_adr_fax.countryiso;
         rcd_bds_addr_fax.standard_sender_flag := rcd_lads_adr_fax.std_no;
         rcd_bds_addr_fax.fax_number := rcd_lads_adr_fax.fax;
         rcd_bds_addr_fax.fax_extension := rcd_lads_adr_fax.extension;
         rcd_bds_addr_fax.fax_full_number := rcd_lads_adr_fax.fax_no;
         rcd_bds_addr_fax.sender_number := rcd_lads_adr_fax.sender_no;
         rcd_bds_addr_fax.fax_group := rcd_lads_adr_fax.fax_group;
         rcd_bds_addr_fax.standard_receiver_flag := rcd_lads_adr_fax.std_recip;
         rcd_bds_addr_fax.sap_r3_user := rcd_lads_adr_fax.r_3_user;
         rcd_bds_addr_fax.home_flag := rcd_lads_adr_fax.home_flag;
         rcd_bds_addr_fax.sequence_number := rcd_lads_adr_fax.consnumber;
         rcd_bds_addr_fax.error_flag := rcd_lads_adr_fax.errorflag;
         rcd_bds_addr_fax.not_used_flag := rcd_lads_adr_fax.flg_nouse;

         /*-*/
         /* Insert the child row
         /*-*/
         insert into bds_addr_fax
            (address_type,
             address_code,
             address_context,
             address_sequence,
             country,
             country_iso,
             standard_sender_flag,
             fax_number,
             fax_extension,
             fax_full_number,
             sender_number,
             fax_group,
             standard_receiver_flag,
             sap_r3_user,
             home_flag,
             sequence_number,
             error_flag,
             not_used_flag)
             values(rcd_bds_addr_fax.address_type,
                    rcd_bds_addr_fax.address_code,
                    rcd_bds_addr_fax.address_context,
                    rcd_bds_addr_fax.address_sequence,
                    rcd_bds_addr_fax.country,
                    rcd_bds_addr_fax.country_iso,
                    rcd_bds_addr_fax.standard_sender_flag,
                    rcd_bds_addr_fax.fax_number,
                    rcd_bds_addr_fax.fax_extension,
                    rcd_bds_addr_fax.fax_full_number,
                    rcd_bds_addr_fax.sender_number,
                    rcd_bds_addr_fax.fax_group,
                    rcd_bds_addr_fax.standard_receiver_flag,
                    rcd_bds_addr_fax.sap_r3_user,
                    rcd_bds_addr_fax.home_flag,
                    rcd_bds_addr_fax.sequence_number,
                    rcd_bds_addr_fax.error_flag,
                    rcd_bds_addr_fax.not_used_flag);

      end loop;
      close csr_lads_adr_fax;

      /*-*/
      /* Process the LADS address phone
      /*-*/
      open csr_lads_adr_tel;
      loop
         fetch csr_lads_adr_tel into rcd_lads_adr_tel;
         if csr_lads_adr_tel%notfound then
            exit;
         end if;

         /*-*/
         /* Set the BDS child values
         /*-*/
         rcd_bds_addr_phone.address_type := rcd_lads_adr_tel.obj_type;
         rcd_bds_addr_phone.address_code := rcd_lads_adr_tel.obj_id;
         rcd_bds_addr_phone.address_context := rcd_lads_adr_tel.context;
         rcd_bds_addr_phone.address_sequence := rcd_lads_adr_tel.telseq;
         rcd_bds_addr_phone.country := rcd_lads_adr_tel.country;
         rcd_bds_addr_phone.country_iso := rcd_lads_adr_tel.countryiso;
         rcd_bds_addr_phone.standard_sender_flag := rcd_lads_adr_tel.std_no;
         rcd_bds_addr_phone.phone_number := rcd_lads_adr_tel.telephone;
         rcd_bds_addr_phone.phone_extension := rcd_lads_adr_tel.extension;
         rcd_bds_addr_phone.phone_full_number := rcd_lads_adr_tel.tel_no;
         rcd_bds_addr_phone.caller_number := rcd_lads_adr_tel.caller_no;
         rcd_bds_addr_phone.standard_receiver_flag := rcd_lads_adr_tel.std_recip;
         rcd_bds_addr_phone.sap_r3_user := rcd_lads_adr_tel.r_3_user;
         rcd_bds_addr_phone.home_flag := rcd_lads_adr_tel.home_flag;
         rcd_bds_addr_phone.sequence_number := rcd_lads_adr_tel.consnumber;
         rcd_bds_addr_phone.error_flag := rcd_lads_adr_tel.errorflag;
         rcd_bds_addr_phone.not_used_flag := rcd_lads_adr_tel.flg_nouse;

         /*-*/
         /* Insert the child row
         /*-*/
         insert into bds_addr_phone
            (address_type,
             address_code,
             address_context,
             address_sequence,
             country,
             country_iso,
             standard_sender_flag,
             phone_number,
             phone_extension,
             phone_full_number,
             caller_number,
             standard_receiver_flag,
             sap_r3_user,
             home_flag,
             sequence_number,
             error_flag,
             not_used_flag)
             values(rcd_bds_addr_phone.address_type,
                    rcd_bds_addr_phone.address_code,
                    rcd_bds_addr_phone.address_context,
                    rcd_bds_addr_phone.address_sequence,
                    rcd_bds_addr_phone.country,
                    rcd_bds_addr_phone.country_iso,
                    rcd_bds_addr_phone.standard_sender_flag,
                    rcd_bds_addr_phone.phone_number,
                    rcd_bds_addr_phone.phone_extension,
                    rcd_bds_addr_phone.phone_full_number,
                    rcd_bds_addr_phone.caller_number,
                    rcd_bds_addr_phone.standard_receiver_flag,
                    rcd_bds_addr_phone.sap_r3_user,
                    rcd_bds_addr_phone.home_flag,
                    rcd_bds_addr_phone.sequence_number,
                    rcd_bds_addr_phone.error_flag,
                    rcd_bds_addr_phone.not_used_flag);

      end loop;
      close csr_lads_adr_tel;

      /*-*/
      /* Process the LADS address URL
      /*-*/
      open csr_lads_adr_url;
      loop
         fetch csr_lads_adr_url into rcd_lads_adr_url;
         if csr_lads_adr_url%notfound then
            exit;
         end if;

         /*-*/
         /* Set the BDS child values
         /*-*/
         rcd_bds_addr_url.address_type := rcd_lads_adr_url.obj_type;
         rcd_bds_addr_url.address_code := rcd_lads_adr_url.obj_id;
         rcd_bds_addr_url.address_context := rcd_lads_adr_url.context;
         rcd_bds_addr_url.address_sequence := rcd_lads_adr_url.urlseq;
         rcd_bds_addr_url.standard_sender_flag := rcd_lads_adr_url.std_no;
         rcd_bds_addr_url.uri_type := rcd_lads_adr_url.uri_type;
         rcd_bds_addr_url.uri := rcd_lads_adr_url.uri;
         rcd_bds_addr_url.standard_receiver_flag := rcd_lads_adr_url.std_recip;
         rcd_bds_addr_url.home_flag := rcd_lads_adr_url.home_flag;
         rcd_bds_addr_url.sequence_number := rcd_lads_adr_url.consnumber;
         rcd_bds_addr_url.uri_part_01 := rcd_lads_adr_url.uri_part1;
         rcd_bds_addr_url.uri_part_02 := rcd_lads_adr_url.uri_part2;
         rcd_bds_addr_url.uri_part_03 := rcd_lads_adr_url.uri_part3;
         rcd_bds_addr_url.uri_part_04 := rcd_lads_adr_url.uri_part4;
         rcd_bds_addr_url.uri_part_05 := rcd_lads_adr_url.uri_part5;
         rcd_bds_addr_url.uri_part_06 := rcd_lads_adr_url.uri_part6;
         rcd_bds_addr_url.uri_part_07 := rcd_lads_adr_url.uri_part7;
         rcd_bds_addr_url.uri_part_08 := rcd_lads_adr_url.uri_part8;
         rcd_bds_addr_url.uri_part_09 := rcd_lads_adr_url.uri_part9;
         rcd_bds_addr_url.error_flag := rcd_lads_adr_url.errorflag;
         rcd_bds_addr_url.not_used_flag := rcd_lads_adr_url.flg_nouse;

         /*-*/
         /* Insert the child row
         /*-*/
         insert into bds_addr_url
            (address_type,
             address_code,
             address_context,
             address_sequence,
             standard_sender_flag,
             uri_type,
             uri,
             standard_receiver_flag,
             home_flag,
             sequence_number,
             uri_part_01,
             uri_part_02,
             uri_part_03,
             uri_part_04,
             uri_part_05,
             uri_part_06,
             uri_part_07,
             uri_part_08,
             uri_part_09,
             error_flag,
             not_used_flag)
             values(rcd_bds_addr_url.address_type,
                    rcd_bds_addr_url.address_code,
                    rcd_bds_addr_url.address_context,
                    rcd_bds_addr_url.address_sequence,
                    rcd_bds_addr_url.standard_sender_flag,
                    rcd_bds_addr_url.uri_type,
                    rcd_bds_addr_url.uri,
                    rcd_bds_addr_url.standard_receiver_flag,
                    rcd_bds_addr_url.home_flag,
                    rcd_bds_addr_url.sequence_number,
                    rcd_bds_addr_url.uri_part_01,
                    rcd_bds_addr_url.uri_part_02,
                    rcd_bds_addr_url.uri_part_03,
                    rcd_bds_addr_url.uri_part_04,
                    rcd_bds_addr_url.uri_part_05,
                    rcd_bds_addr_url.uri_part_06,
                    rcd_bds_addr_url.uri_part_07,
                    rcd_bds_addr_url.uri_part_08,
                    rcd_bds_addr_url.uri_part_09,
                    rcd_bds_addr_url.error_flag,
                    rcd_bds_addr_url.not_used_flag);

      end loop;
      close csr_lads_adr_url;

      /*-*/
      /* Perform exclusion processing
      /*-*/
      if (var_excluded) then
         var_flattened := '2';
      end if;

      /*-*/
      /* Update LADS header record to reflect flattened status
      /*-*/
      update lads_adr_hdr
         set lads_flattened = var_flattened
         where obj_type = par_obj_type
           and obj_id = par_obj_id
           and context = par_context;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'BDS_FLATTEN - ' || 'OBJ_TYPE: ' || par_obj_type || ' OBJ_ID: ' || par_obj_id || ' CONTEXT: ' || par_context || ' - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end bds_flatten;

   /*******************************************************************************/
   /* This procedure performs the lock routine                                    */
   /*   notes - acquires a lock on the LADS header record                         */
   /*         - uses NOWAIT, assumes if locked, LADS load will re-call flattening */
   /*         - issues commit to release lock                                     */
   /*         - used when manually executing flattening                           */
   /*******************************************************************************/
   procedure lads_lock(par_obj_type in varchar2, par_obj_id in varchar2, par_context in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lock is
         select t01.*
           from lads_adr_hdr t01
          where t01.obj_type = par_obj_type
            and t01.obj_id = par_obj_id
            and t01.context = par_context
            for update nowait;
      rcd_lock csr_lock%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Attempt to lock the header row
      /* notes - must still exist
      /*         must not be locked
      /*-*/
      var_available := true;
      begin
         open csr_lock;
         fetch csr_lock into rcd_lock;
         if csr_lock%notfound then
            var_available := false;
         end if;
      exception
         when others then
            var_available := false;
      end;
      /*-*/
      if csr_lock%isopen then
         close csr_lock;
      end if;
      /*-*/
      if (var_available) then

         /*-*/
         /* Flatten
         /*-*/
         bds_flatten(rcd_lock.obj_type, rcd_lock.obj_id, rcd_lock.context);

         /*-*/
         /* Commit
         /*-*/
         commit;

      else
         rollback;
      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
  exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end lads_lock;

   /******************************************************************************************/
   /* This procedure performs the refresh routine                                            */
   /*   notes - processes all LADS records with unflattened status                           */
   /******************************************************************************************/
   procedure bds_refresh is

      /*-*/
      /* Local definitions
      /*-*/
      var_open boolean;
      var_exit boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_flatten is
         select t01.obj_type,
                t01.obj_id,
                t01.context
           from lads_adr_hdr t01
          where nvl(t01.lads_flattened,'0') = '0';
      rcd_flatten csr_flatten%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve document header with lads_flattened status = 0
      /* notes - cursor is reopened when snapshot to old
      /*-*/
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next document to process
         /*-*/
         loop
            if var_open = true then
               if csr_flatten%isopen then
                  close csr_flatten;
               end if;
               open csr_flatten;
               var_open := false;
            end if;
            begin
               fetch csr_flatten into rcd_flatten;
               if csr_flatten%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         /*-*/
         if var_exit = true then
            exit;
         end if;

         lads_lock(rcd_flatten.obj_type, rcd_flatten.obj_id, rcd_flatten.context);

      end loop;
      close csr_flatten;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end bds_refresh;

   /******************************************************************************************/
   /* This procedure performs the rebuild routine                                            */
   /*   notes - RECOMMEND stopping ICS jobs prior to execution                               */
   /*         - performs a truncate on the target BDS table                                  */
   /*         - updates all LADS records to unflattened status                               */
   /*         - calls bds_refresh procedure to drive processing                              */
   /******************************************************************************************/
   procedure bds_rebuild is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Truncate target BDS table(s)
      /*-*/
      bds_table.truncate('bds_addr_customer');
      bds_table.truncate('bds_addr_vendor');
      bds_table.truncate('bds_addr_url');
      bds_table.truncate('bds_addr_phone');
      bds_table.truncate('bds_addr_fax');
      bds_table.truncate('bds_addr_email');
      bds_table.truncate('bds_addr_detail');
      bds_table.truncate('bds_addr_comment');
      bds_table.truncate('bds_addr_header');

      /*-*/
      /* Set all source LADS documents to unflattened status
      /*-*/
      update lads_adr_hdr
         set lads_flattened = '0';

      /*-*/
      /* Commit
      /*-*/
      commit;

      /*-*/
      /* Execute BDS_REFRESH to repopulate BDS target tables
      /*-*/
      bds_refresh;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, ' - BDS_REBUILD - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end bds_rebuild;

end bds_atllad15_flatten;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym bds_atllad15_flatten for bds_app.bds_atllad15_flatten;
grant execute on bds_atllad15_flatten to lics_app;
grant execute on bds_atllad15_flatten to lads_app;