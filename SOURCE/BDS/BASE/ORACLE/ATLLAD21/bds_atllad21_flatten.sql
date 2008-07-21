create or replace package bds_atllad21_flatten as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : BDS (Business Data Store)
 Package : bds_atllad21_flatten
 Owner   : BDS_APP
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - ATLLAD21 - Classification Data (CLFMAS01)


 PARAMETERS
   1. PAR_ACTION [MANDATORY]
      *DOCUMENT            - ONLY to be called from LADS load package, assumes locking/commits in parent
      *DOCUMENT_OVERRIDE   - manual flattening execution, implements locks/commits internally
      *REFRESH             - process all unflattened LADS records
      *REBUILD             - process all LADS records - truncates BDS table(s) first
                           - RECOMMEND stopping ICS jobs prior to execution

   2. PAR_ATNAM [MANDATORY on *DOCUMENT and *DOCUMENT_OVERRIDE]
      Field from LADS document in LADS_CHR_MAS_HDR.ATNAM


 NOTES 
   1. This package must raise an exception on failure to exclude database activity from parent commit


 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/11   Linden Glen    Created
 2006/11   Linden Glen    Changed sap_classfctn_code to sap_charistic_value_code
 2007/08   Steve Gregan   Changed to ignore descriptions with no language key
 2008/07   Linden Glen    Added *NONE decode to LANGUAGE on SAP_CHARISTIC_VALUE

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_action in varchar2, par_atnam in varchar2);

end bds_atllad21_flatten;
/


/****************/
/* Package Body */
/****************/
create or replace package body bds_atllad21_flatten as

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
   procedure lads_lock(par_atnam in varchar2);
   procedure bds_flatten(par_atnam in varchar2);
   procedure bds_refresh;
   procedure bds_rebuild;


   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_action in varchar2, par_atnam in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Execute BDS Flattening process
      /*-*/   
      case upper(par_action)
        when '*DOCUMENT' then bds_flatten(par_atnam);
        when '*DOCUMENT_OVERRIDE' then lads_lock(par_atnam);
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
         raise_application_error(-20000, 'BDS_ATLLAD21_FLATTEN - EXECUTE ' || par_action || ' - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;


   /***************************************************/
   /* This procedure perfroms the BDS Flatten routine */
   /***************************************************/
   procedure bds_flatten(par_atnam in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_flattened varchar2(1);
      var_excluded boolean;
      rcd_bds_charistic_hdr bds_charistic_hdr%rowtype;
      rcd_bds_charistic_desc bds_charistic_desc%rowtype;
      rcd_bds_charistic_value bds_charistic_value%rowtype;
      rcd_bds_charistic_value_en bds_charistic_value_en%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_chr_mas_hdr is
         select t01.atnam as atnam,
		(select max(atbez) 
                 from lads_chr_mas_det 
                 where atnam = t01.atnam 
                   and spras_iso = 'EN'
                 group by atnam) as bds_charistic_desc_en,
                max(t01.idoc_name) as idoc_name,
                max(t01.idoc_number) as idoc_number,
                max(t01.idoc_timestamp) as idoc_timestamp,
                max(t01.lads_date) as lads_date,
                max(t01.lads_status) as lads_status,
                max(t01.adatu) as adatu,
                max(t01.aname) as aname,
                max(t01.vdatu) as vdatu,
                max(t01.vname) as vname,
                max(t01.atkle) as atkle,
                max(t01.aterf) as aterf,
                max(t01.atein) as atein,
                max(t01.msgfn) as msgfn,
                max(t01.atkla) as atkla
         from lads_chr_mas_hdr t01
         where t01.atnam = par_atnam
         group by t01.atnam;
      rcd_lads_chr_mas_hdr  csr_lads_chr_mas_hdr%rowtype;

      cursor csr_lads_chr_mas_value_en is
         select nvl(t01.atwrt,'*NONE') as atwrt,
                max(t02.atwtb) as atwtb
         from lads_chr_mas_val t01,
              lads_chr_mas_dsc t02
         where t01.atnam = t02.atnam(+)
           and t01.atzhl = t02.atzhl(+)
           and t01.valseq = t02.valseq(+)
           and t02.spras_iso(+) = 'EN'
           and t01.atnam = rcd_lads_chr_mas_hdr.atnam
         group by nvl(t01.atwrt,'*NONE');
      rcd_lads_chr_mas_value_en  csr_lads_chr_mas_value_en%rowtype;

      cursor csr_lads_chr_mas_value is
         select nvl(t01.atwrt,'*NONE') as atwrt,
                nvl(t02.spras_iso,'*NONE') as spras_iso,
                max(t02.atwtb) as atwtb
         from lads_chr_mas_val t01,
              lads_chr_mas_dsc t02
         where t01.atnam = t02.atnam(+)
           and t01.valseq = t02.valseq(+)
           and t01.atzhl = t02.atzhl(+)
           and t01.atnam = rcd_lads_chr_mas_hdr.atnam
         group by nvl(t01.atwrt,'*NONE'), nvl(t02.spras_iso,'*NONE');
      rcd_lads_chr_mas_value  csr_lads_chr_mas_value%rowtype;

      cursor csr_lads_chr_mas_det is
         select t01.spras_iso as spras_iso,
                max(t01.atbez) as atbez 
         from lads_chr_mas_det t01
         where t01.atnam = rcd_lads_chr_mas_hdr.atnam
         group by t01.spras_iso;
      rcd_lads_chr_mas_det  csr_lads_chr_mas_det%rowtype;


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
      /* Process Characteristic Master header
      /*-*/
      open csr_lads_chr_mas_hdr;
      fetch csr_lads_chr_mas_hdr into rcd_lads_chr_mas_hdr;
      if (csr_lads_chr_mas_hdr%notfound) then
         raise_application_error(-20000, 'Characteristic Header cursor not found');
      end if;
      close csr_lads_chr_mas_hdr;

      rcd_bds_charistic_hdr.sap_charistic_code := rcd_lads_chr_mas_hdr.atnam;
      rcd_bds_charistic_hdr.bds_charistic_desc_en := rcd_lads_chr_mas_hdr.bds_charistic_desc_en;
      rcd_bds_charistic_hdr.bds_lads_date := rcd_lads_chr_mas_hdr.lads_date;
      rcd_bds_charistic_hdr.bds_lads_status := rcd_lads_chr_mas_hdr.lads_status;
      rcd_bds_charistic_hdr.sap_idoc_name := rcd_lads_chr_mas_hdr.idoc_name;
      rcd_bds_charistic_hdr.sap_idoc_number := rcd_lads_chr_mas_hdr.idoc_number;
      rcd_bds_charistic_hdr.sap_idoc_timestamp := rcd_lads_chr_mas_hdr.idoc_timestamp;
      rcd_bds_charistic_hdr.sap_creatn_date := rcd_lads_chr_mas_hdr.adatu;
      rcd_bds_charistic_hdr.sap_creatn_user := rcd_lads_chr_mas_hdr.aname;
      rcd_bds_charistic_hdr.sap_change_date := rcd_lads_chr_mas_hdr.vdatu;
      rcd_bds_charistic_hdr.sap_change_user := rcd_lads_chr_mas_hdr.vname;
      rcd_bds_charistic_hdr.sap_case_snstive := rcd_lads_chr_mas_hdr.atkle;
      rcd_bds_charistic_hdr.sap_entry_reqd := rcd_lads_chr_mas_hdr.aterf;
      rcd_bds_charistic_hdr.sap_sngl_value := rcd_lads_chr_mas_hdr.atein;
      rcd_bds_charistic_hdr.sap_function := rcd_lads_chr_mas_hdr.msgfn;
      rcd_bds_charistic_hdr.sap_charistic_grp := rcd_lads_chr_mas_hdr.atkla;

      /*--------------------------*/
      /* UPDATE BDS_CHARISTIC_HDR */
      /*--------------------------*/
      update bds_charistic_hdr
         set bds_charistic_desc_en = rcd_bds_charistic_hdr.bds_charistic_desc_en,
             bds_lads_date = rcd_bds_charistic_hdr.bds_lads_date,
             bds_lads_status = rcd_bds_charistic_hdr.bds_lads_status,
             sap_idoc_name = rcd_bds_charistic_hdr.sap_idoc_name,
             sap_idoc_number = rcd_bds_charistic_hdr.sap_idoc_number,
             sap_idoc_timestamp = rcd_bds_charistic_hdr.sap_idoc_timestamp,
             sap_creatn_date = rcd_bds_charistic_hdr.sap_creatn_date,
             sap_creatn_user = rcd_bds_charistic_hdr.sap_creatn_user,
             sap_change_date = rcd_bds_charistic_hdr.sap_change_date,
             sap_change_user = rcd_bds_charistic_hdr.sap_change_user,
             sap_case_snstive = rcd_bds_charistic_hdr.sap_case_snstive,
             sap_entry_reqd = rcd_bds_charistic_hdr.sap_entry_reqd,
             sap_sngl_value = rcd_bds_charistic_hdr.sap_sngl_value,
             sap_function = rcd_bds_charistic_hdr.sap_function,
             sap_charistic_grp = rcd_bds_charistic_hdr.sap_charistic_grp
      where sap_charistic_code = rcd_bds_charistic_hdr.sap_charistic_code;
      if (sql%notfound) then
         insert into bds_charistic_hdr
            (sap_charistic_code,
             bds_charistic_desc_en,
             bds_lads_date,
             bds_lads_status,
             sap_idoc_name,
             sap_idoc_number,
             sap_idoc_timestamp,
             sap_creatn_date,
             sap_creatn_user,
             sap_change_date,
             sap_change_user,
             sap_case_snstive,
             sap_entry_reqd,
             sap_sngl_value,
             sap_function,
             sap_charistic_grp)
          values
            (rcd_bds_charistic_hdr.sap_charistic_code,
             rcd_bds_charistic_hdr.bds_charistic_desc_en,
             rcd_bds_charistic_hdr.bds_lads_date,
             rcd_bds_charistic_hdr.bds_lads_status,
             rcd_bds_charistic_hdr.sap_idoc_name,
             rcd_bds_charistic_hdr.sap_idoc_number,
             rcd_bds_charistic_hdr.sap_idoc_timestamp,
             rcd_bds_charistic_hdr.sap_creatn_date,
             rcd_bds_charistic_hdr.sap_creatn_user,
             rcd_bds_charistic_hdr.sap_change_date,
             rcd_bds_charistic_hdr.sap_change_user,
             rcd_bds_charistic_hdr.sap_case_snstive,
             rcd_bds_charistic_hdr.sap_entry_reqd,
             rcd_bds_charistic_hdr.sap_sngl_value,
             rcd_bds_charistic_hdr.sap_function,
             rcd_bds_charistic_hdr.sap_charistic_grp);
      end if;


      /*-*/
      /* Process Characteristic English values
      /*-*/

      /*----------------------------*/
      /* DELETE BDS_CHARISTIC_VALUE */
      /*----------------------------*/
      delete bds_charistic_value_en
       where sap_charistic_code = rcd_bds_charistic_hdr.sap_charistic_code;


      open csr_lads_chr_mas_value_en;
      loop
         fetch csr_lads_chr_mas_value_en into rcd_lads_chr_mas_value_en;
         if (csr_lads_chr_mas_value_en%notfound) then
            exit;
         end if;

         rcd_bds_charistic_value_en.sap_charistic_code := rcd_bds_charistic_hdr.sap_charistic_code;
         rcd_bds_charistic_value_en.sap_charistic_value_code := rcd_lads_chr_mas_value_en.atwrt;
         rcd_bds_charistic_value_en.sap_charistic_value_desc := rcd_lads_chr_mas_value_en.atwtb;

         /*----------------------------*/
         /* UPDATE BDS_CHARISTIC_VALUE */
         /*----------------------------*/
         insert into bds_charistic_value_en
            (sap_charistic_code,
             sap_charistic_value_code,
             sap_charistic_value_desc)
          values 
            (rcd_bds_charistic_value_en.sap_charistic_code,
             rcd_bds_charistic_value_en.sap_charistic_value_code,
             rcd_bds_charistic_value_en.sap_charistic_value_desc);

      end loop;
      close csr_lads_chr_mas_value_en;


      /*-*/
      /* Process Characteristic values
      /*-*/

      /*----------------------------*/
      /* DELETE BDS_CHARISTIC_VALUE */
      /*----------------------------*/
      delete bds_charistic_value
       where sap_charistic_code = rcd_bds_charistic_hdr.sap_charistic_code;


      open csr_lads_chr_mas_value;
      loop
         fetch csr_lads_chr_mas_value into rcd_lads_chr_mas_value;
         if (csr_lads_chr_mas_value%notfound) then
            exit;
         end if;

         rcd_bds_charistic_value.sap_charistic_code := rcd_bds_charistic_hdr.sap_charistic_code;
         rcd_bds_charistic_value.sap_charistic_value_code := rcd_lads_chr_mas_value.atwrt;
         rcd_bds_charistic_value.sap_charistic_value_lang := rcd_lads_chr_mas_value.spras_iso;
         rcd_bds_charistic_value.sap_charistic_value_desc := rcd_lads_chr_mas_value.atwtb;

         /*----------------------------*/
         /* UPDATE BDS_CHARISTIC_VALUE */
         /*----------------------------*/
         insert into bds_charistic_value
            (sap_charistic_code,
             sap_charistic_value_code,
             sap_charistic_value_lang,
             sap_charistic_value_desc)
          values 
            (rcd_bds_charistic_value.sap_charistic_code,
             rcd_bds_charistic_value.sap_charistic_value_code,
             rcd_bds_charistic_value.sap_charistic_value_lang,
             rcd_bds_charistic_value.sap_charistic_value_desc);

      end loop;
      close csr_lads_chr_mas_value;


      /*-*/
      /* Process Characteristic descriptions
      /*-*/

      /*----------------------------*/
      /* DELETE BDS_CHARISTIC_DESC  */
      /*----------------------------*/
      delete bds_charistic_desc
       where sap_charistic_code = rcd_bds_charistic_hdr.sap_charistic_code;


      open csr_lads_chr_mas_det;
      loop
         fetch csr_lads_chr_mas_det into rcd_lads_chr_mas_det;
         if (csr_lads_chr_mas_det%notfound) then
            exit;
         end if;

         rcd_bds_charistic_desc.sap_charistic_code := rcd_bds_charistic_hdr.sap_charistic_code;
         rcd_bds_charistic_desc.sap_charistic_desc_lang := rcd_lads_chr_mas_det.spras_iso;
         rcd_bds_charistic_desc.sap_charistic_desc := rcd_lads_chr_mas_det.atbez;


         /*---------------------------*/
         /* UPDATE BDS_CHARISTIC_DESC */
         /*---------------------------*/
         insert into bds_charistic_desc
            (sap_charistic_code,
             sap_charistic_desc_lang,
             sap_charistic_desc)
          values 
            (rcd_bds_charistic_desc.sap_charistic_code,
             rcd_bds_charistic_desc.sap_charistic_desc_lang,
             rcd_bds_charistic_desc.sap_charistic_desc);

      end loop;
      close csr_lads_chr_mas_det;


      /*-*/
      /* Perform exclusion processing
      /*-*/   
      if (var_excluded) then
         var_flattened := '2';
      end if;


      /*-*/
      /* Update LADS header record to reflect flattened status
      /*-*/   
      update lads_chr_mas_hdr
         set lads_flattened = var_flattened
       where atnam = par_atnam;


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
         raise_application_error(-20000, 'BDS_FLATTEN -  ' || 'ATNAM: ' || nvl(par_atnam,'null') || substr(SQLERRM, 1, 1024));

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
   procedure lads_lock(par_atnam in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lock is
         select *
         from lads_chr_mas_hdr t01
         where t01.atnam = par_atnam
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
         bds_flatten(par_atnam);

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
         select t01.atnam
         from lads_chr_mas_hdr t01
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

         lads_lock(rcd_flatten.atnam);

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
      bds_table.truncate('bds_charistic_desc');
      bds_table.truncate('bds_charistic_value');
      bds_table.truncate('bds_charistic_hdr');

      /*-*/
      /* Set all source LADS documents to unflattened status
      /*-*/
      update lads_chr_mas_hdr
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

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, ' - BDS_REBUILD - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end bds_rebuild;

end bds_atllad21_flatten;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym bds_atllad21_flatten for bds_app.bds_atllad21_flatten;
grant execute on bds_atllad21_flatten to lics_app;
grant execute on bds_atllad21_flatten to lads_app;
