/******************/
/* Package Header */
/******************/
create or replace package lads_purging as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lads
    Package : lads_purging
    Owner   : lads_app
    Author  : Steve Gregan - January 2004

    DESCRIPTION
    -----------
    Local Atlas Data Store - Purging

    YYYY/MM   Author         Description
    -------   ------         -----------
    2004/01   Steve Gregan   Created
    2006/06   Linden Glen    MOD : ATLLAD03 Purging
                             ADD : ATLLAD25 Purging
    2006/08   Linden Glen    ADD : ATLLAD28 and ATLLAD29 Purging

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end lads_purging;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_purging as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure purge_atllad01;
   procedure purge_atllad02;
   procedure purge_atllad03;
   procedure purge_atllad09;
   procedure purge_atllad12;
   procedure purge_atllad13;
   procedure purge_atllad14;
   procedure purge_atllad16;
   procedure purge_atllad18;
   procedure purge_atllad20;
   procedure purge_atllad25;
   procedure purge_atllad28;
   procedure purge_atllad29;


   /*-*/
   /* Private constants
   /*-*/
   con_purging_group constant varchar2(32) := 'LADS_PURGING';
   cnt_process_count constant number(5,0) := 10;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Purge the atllad01 (control recipe)
      /*-*/
      purge_atllad01;

      /*-*/
      /* Purge the atllad02 (stock balance)
      /*-*/
      purge_atllad02;

      /*-*/
      /* Purge the atllad03 (ICB LLT intransit)
      /*-*/
      purge_atllad03;

      /*-*/
      /* Purge the atllad09 (stock transfer and purchase order)
      /*-*/
      purge_atllad09;

      /*-*/
      /* Purge the atllad12 (invoice summary)
      /*-*/
      purge_atllad12;

      /*-*/
      /* Purge the atllad13 (sales order)
      /*-*/
      purge_atllad13;

      /*-*/
      /* Purge the atllad14 (shipment)
      /*-*/
      purge_atllad14;

      /*-*/
      /* Purge the atllad16 (delivery)
      /*-*/
      purge_atllad16;

      /*-*/
      /* Purge the atllad18 (invoice)
      /*-*/
      purge_atllad18;

      /*-*/
      /* Purge the atllad20 (hierarchy)
      /*-*/
      purge_atllad20;

      /*-*/
      /* Purge the atllad25 (Generic ICB)
      /*-*/
      purge_atllad25;

      /*-*/
      /* Purge the atllad28 (Open Purchase Order/Requisition)
      /*-*/
      purge_atllad28;

      /*-*/
      /* Purge the atllad29 (Open Planned Process Orders)
      /*-*/
      purge_atllad29;


   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise the exception
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Local Atlas Data Store - Purging - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /******************************************************/
   /* This procedure performs the purge ATLLAD01 routine */
   /******************************************************/
   procedure purge_atllad01 is

      /*-*/
      /* Local definitions
      /*-*/
      var_history number;
      var_count number;
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is
         select t01.cntl_rec_id
           from lads_ctl_rec_hpi t01
          where t01.lads_date < sysdate - var_history;
      rcd_header csr_header%rowtype;

      cursor csr_lock is
         select t01.cntl_rec_id
           from lads_ctl_rec_hpi t01
          where t01.cntl_rec_id = rcd_header.cntl_rec_id
                for update nowait;
      rcd_lock csr_lock%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the history days
      /*-*/
      var_history := to_number(lics_setting_configuration.retrieve_setting(con_purging_group, 'ATLLAD01'));

      /*-*/
      /* Retrieve the headers
      /*-*/
      var_count := 0;
      open csr_header;
      loop
         if var_count >= cnt_process_count then
            if csr_header%isopen then
               close csr_header;
            end if;
            commit;
            open csr_header;
            var_count := 0;
         end if;
         fetch csr_header into rcd_header;
         if csr_header%notfound then
            exit;
         end if;

         /*-*/
         /* Increment the count
         /*-*/
         var_count := var_count + 1;

         /*-*/
         /* Attempt to lock the header
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
         if csr_lock%isopen then
            close csr_lock;
         end if;

         /*-*/
         /* Delete the header and related data when available
         /*-*/
         if var_available = true then
            delete from lads_ctl_rec_txt where cntl_rec_id = rcd_lock.cntl_rec_id;
            delete from lads_ctl_rec_vpi where cntl_rec_id = rcd_lock.cntl_rec_id;
            delete from lads_ctl_rec_tpi where cntl_rec_id = rcd_lock.cntl_rec_id;
            delete from lads_ctl_rec_hpi where cntl_rec_id = rcd_lock.cntl_rec_id;
         end if;

      end loop;
      close csr_header;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_atllad01;

   /******************************************************/
   /* This procedure performs the purge ATLLAD02 routine */
   /******************************************************/
   procedure purge_atllad02 is

      /*-*/
      /* Local definitions
      /*-*/
      var_history number;
      var_count number;
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is
         select t01.bukrs,
                t01.werks,
                t01.lgort,
                t01.budat,
                t01.timlo
           from lads_stk_bal_hdr t01
          where t01.lads_date < sysdate - var_history;
      rcd_header csr_header%rowtype;

      cursor csr_lock is
         select t01.bukrs,
                t01.werks,
                t01.lgort,
                t01.budat,
                t01.timlo
           from lads_stk_bal_hdr t01
          where t01.bukrs = rcd_header.bukrs
            and t01.werks = rcd_header.werks
            and t01.lgort = rcd_header.lgort
            and t01.budat = rcd_header.budat
            and t01.timlo = rcd_header.timlo
                for update nowait;
      rcd_lock csr_lock%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the history days
      /*-*/
      var_history := to_number(lics_setting_configuration.retrieve_setting(con_purging_group, 'ATLLAD02'));

      /*-*/
      /* Retrieve the headers
      /*-*/
      var_count := 0;
      open csr_header;
      loop
         if var_count >= cnt_process_count then
            if csr_header%isopen then
               close csr_header;
            end if;
            commit;
            open csr_header;
            var_count := 0;
         end if;
         fetch csr_header into rcd_header;
         if csr_header%notfound then
            exit;
         end if;

         /*-*/
         /* Increment the count
         /*-*/
         var_count := var_count + 1;

         /*-*/
         /* Attempt to lock the header
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
         if csr_lock%isopen then
            close csr_lock;
         end if;

         /*-*/
         /* Delete the header and related data when available
         /*-*/
         if var_available = true then
            delete from lads_stk_bal_det where bukrs = rcd_lock.bukrs
                                           and werks = rcd_lock.werks
                                           and lgort = rcd_lock.lgort
                                           and budat = rcd_lock.budat
                                           and timlo = rcd_lock.timlo;
            delete from lads_stk_bal_hdr where bukrs = rcd_lock.bukrs
                                           and werks = rcd_lock.werks
                                           and lgort = rcd_lock.lgort
                                           and budat = rcd_lock.budat
                                           and timlo = rcd_lock.timlo;
         end if;

      end loop;
      close csr_header;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_atllad02;

   /******************************************************/
   /* This procedure performs the purge ATLLAD03 routine */
   /******************************************************/
   procedure purge_atllad03 is

      /*-*/
      /* Local definitions
      /*-*/
      var_history number;
      var_count number;
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is
         select t01.venum
         from lads_icb_llt_hdr t01
         where t01.lads_date < sysdate - var_history;
      rcd_header csr_header%rowtype;

      cursor csr_lock is
         select t01.venum
         from lads_icb_llt_hdr t01
         where t01.venum = rcd_header.venum
         for update nowait;
      rcd_lock csr_lock%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the history days
      /*-*/
      var_history := to_number(lics_setting_configuration.retrieve_setting(con_purging_group, 'ATLLAD03'));

      /*-*/
      /* Retrieve the headers
      /*-*/
      var_count := 0;
      open csr_header;
      loop
         if var_count >= cnt_process_count then
            if csr_header%isopen then
               close csr_header;
            end if;
            commit;
            open csr_header;
            var_count := 0;
         end if;
         fetch csr_header into rcd_header;
         if csr_header%notfound then
            exit;
         end if;

         /*-*/
         /* Increment the count
         /*-*/
         var_count := var_count + 1;

         /*-*/
         /* Attempt to lock the header
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
         if csr_lock%isopen then
            close csr_lock;
         end if;

         /*-*/
         /* Delete the header and related data when available
         /*-*/
         if var_available = true then
            delete from lads_icb_llt_det where venum = rcd_lock.venum;
            delete from lads_icb_llt_hdr where venum = rcd_lock.venum;
         end if;

      end loop;
      close csr_header;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_atllad03;

   /******************************************************/
   /* This procedure performs the purge ATLLAD09 routine */
   /******************************************************/
   procedure purge_atllad09 is

      /*-*/
      /* Local definitions
      /*-*/
      var_history number;
      var_count number;
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is
         select t01.belnr
           from lads_sto_po_hdr t01
          where t01.lads_date < sysdate - var_history;
      rcd_header csr_header%rowtype;

      cursor csr_lock is
         select t01.belnr
           from lads_sto_po_hdr t01
          where t01.belnr = rcd_header.belnr
                for update nowait;
      rcd_lock csr_lock%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the history days
      /*-*/
      var_history := to_number(lics_setting_configuration.retrieve_setting(con_purging_group, 'ATLLAD09'));

      /*-*/
      /* Retrieve the headers
      /*-*/
      var_count := 0;
      open csr_header;
      loop
         if var_count >= cnt_process_count then
            if csr_header%isopen then
               close csr_header;
            end if;
            commit;
            open csr_header;
            var_count := 0;
         end if;
         fetch csr_header into rcd_header;
         if csr_header%notfound then
            exit;
         end if;

         /*-*/
         /* Increment the count
         /*-*/
         var_count := var_count + 1;

         /*-*/
         /* Attempt to lock the header
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
         if csr_lock%isopen then
            close csr_lock;
         end if;

         /*-*/
         /* Delete the header and related data when available
         /*-*/
         if var_available = true then
            delete from lads_sto_po_smy where belnr = rcd_lock.belnr;
            delete from lads_sto_po_oid where belnr = rcd_lock.belnr;
            delete from lads_sto_po_pad where belnr = rcd_lock.belnr;
            delete from lads_sto_po_itp where belnr = rcd_lock.belnr;
            delete from lads_sto_po_sch where belnr = rcd_lock.belnr;
            delete from lads_sto_po_gen where belnr = rcd_lock.belnr;
            delete from lads_sto_po_htx where belnr = rcd_lock.belnr;
            delete from lads_sto_po_hti where belnr = rcd_lock.belnr;
            delete from lads_sto_po_pay where belnr = rcd_lock.belnr;
            delete from lads_sto_po_del where belnr = rcd_lock.belnr;
            delete from lads_sto_po_ref where belnr = rcd_lock.belnr;
            delete from lads_sto_po_pnr where belnr = rcd_lock.belnr;
            delete from lads_sto_po_con where belnr = rcd_lock.belnr;
            delete from lads_sto_po_dat where belnr = rcd_lock.belnr;
            delete from lads_sto_po_org where belnr = rcd_lock.belnr;
            delete from lads_sto_po_hdr where belnr = rcd_lock.belnr;
         end if;

      end loop;
      close csr_header;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_atllad09;

   /******************************************************/
   /* This procedure performs the purge ATLLAD12 routine */
   /******************************************************/
   procedure purge_atllad12 is

      /*-*/
      /* Local definitions
      /*-*/
      var_history number;
      var_count number;
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is
         select t01.fkdat,
                t01.bukrs
           from lads_inv_sum_hdr t01
          where t01.lads_date < sysdate - var_history;
      rcd_header csr_header%rowtype;

      cursor csr_lock is
         select t01.fkdat,
                t01.bukrs
           from lads_inv_sum_hdr t01
          where t01.fkdat = rcd_header.fkdat
            and t01.bukrs = rcd_header.bukrs
                for update nowait;
      rcd_lock csr_lock%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the history days
      /*-*/
      var_history := to_number(lics_setting_configuration.retrieve_setting(con_purging_group, 'ATLLAD12'));

      /*-*/
      /* Retrieve the headers
      /*-*/
      var_count := 0;
      open csr_header;
      loop
         if var_count >= cnt_process_count then
            if csr_header%isopen then
               close csr_header;
            end if;
            commit;
            open csr_header;
            var_count := 0;
         end if;
         fetch csr_header into rcd_header;
         if csr_header%notfound then
            exit;
         end if;

         /*-*/
         /* Increment the count
         /*-*/
         var_count := var_count + 1;

         /*-*/
         /* Attempt to lock the header
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
         if csr_lock%isopen then
            close csr_lock;
         end if;

         /*-*/
         /* Delete the header and related data when available
         /*-*/
         if var_available = true then
            delete from lads_inv_sum_det where fkdat = rcd_lock.fkdat
                                           and bukrs = rcd_lock.bukrs;
            delete from lads_inv_sum_hdr where fkdat = rcd_lock.fkdat
                                           and bukrs = rcd_lock.bukrs;
         end if;

      end loop;
      close csr_header;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_atllad12;

   /******************************************************/
   /* This procedure performs the purge ATLLAD13 routine */
   /******************************************************/
   procedure purge_atllad13 is

      /*-*/
      /* Local definitions
      /*-*/
      var_history number;
      var_count number;
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is
         select t01.belnr
           from lads_sal_ord_hdr t01
          where t01.lads_date < sysdate - var_history;
      rcd_header csr_header%rowtype;

      cursor csr_lock is
         select t01.belnr
           from lads_sal_ord_hdr t01
          where t01.belnr = rcd_header.belnr
                for update nowait;
      rcd_lock csr_lock%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the history days
      /*-*/
      var_history := to_number(lics_setting_configuration.retrieve_setting(con_purging_group, 'ATLLAD13'));

      /*-*/
      /* Retrieve the headers
      /*-*/
      var_count := 0;
      open csr_header;
      loop
         if var_count >= cnt_process_count then
            if csr_header%isopen then
               close csr_header;
            end if;
            commit;
            open csr_header;
            var_count := 0;
         end if;
         fetch csr_header into rcd_header;
         if csr_header%notfound then
            exit;
         end if;

         /*-*/
         /* Increment the count
         /*-*/
         var_count := var_count + 1;

         /*-*/
         /* Attempt to lock the header
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
         if csr_lock%isopen then
            close csr_lock;
         end if;

         /*-*/
         /* Delete the header and related data when available
         /*-*/
         if var_available = true then
            delete from lads_sal_ord_smy where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_isy where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_isx where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_isj where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_isi where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_iso where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_isp where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_isn where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_ist where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_isd where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_isr where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_iss where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_itt where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_itx where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_idd where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_itp where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_itd where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_igt where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_iid where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_ipd where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_ipn where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_isc where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_ips where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_ico where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_ita where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_idt where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_iad where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_irf where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_sog where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_gen where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_txt where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_txi where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_pcd where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_add where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_top where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_tod where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_ref where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_pad where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_pnr where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_con where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_tax where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_dat where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_org where belnr = rcd_lock.belnr;
            delete from lads_sal_ord_hdr where belnr = rcd_lock.belnr;
         end if;

      end loop;
      close csr_header;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_atllad13;

   /******************************************************/
   /* This procedure performs the purge ATLLAD14 routine */
   /******************************************************/
   procedure purge_atllad14 is

      /*-*/
      /* Local definitions
      /*-*/
      var_history number;
      var_count number;
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is
         select t01.tknum
           from lads_shp_hdr t01
          where t01.lads_date < sysdate - var_history;
      rcd_header csr_header%rowtype;

      cursor csr_lock is
         select t01.tknum
           from lads_shp_hdr t01
          where t01.tknum = rcd_header.tknum
                for update nowait;
      rcd_lock csr_lock%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the history days
      /*-*/
      var_history := to_number(lics_setting_configuration.retrieve_setting(con_purging_group, 'ATLLAD14'));

      /*-*/
      /* Retrieve the headers
      /*-*/
      var_count := 0;
      open csr_header;
      loop
         if var_count >= cnt_process_count then
            if csr_header%isopen then
               close csr_header;
            end if;
            commit;
            open csr_header;
            var_count := 0;
         end if;
         fetch csr_header into rcd_header;
         if csr_header%notfound then
            exit;
         end if;

         /*-*/
         /* Increment the count
         /*-*/
         var_count := var_count + 1;

         /*-*/
         /* Attempt to lock the header
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
         if csr_lock%isopen then
            close csr_lock;
         end if;

         /*-*/
         /* Delete the header and related data when available
         /*-*/
         if var_available = true then
            delete from lads_shp_dhi where tknum = rcd_lock.tknum;
            delete from lads_shp_dhu where tknum = rcd_lock.tknum;
            delete from lads_shp_drf where tknum = rcd_lock.tknum;
            delete from lads_shp_dbt where tknum = rcd_lock.tknum;
            delete from lads_shp_dng where tknum = rcd_lock.tknum;
            delete from lads_shp_dib where tknum = rcd_lock.tknum;
            delete from lads_shp_dit where tknum = rcd_lock.tknum;
            delete from lads_shp_drs where tknum = rcd_lock.tknum;
            delete from lads_shp_ded where tknum = rcd_lock.tknum;
            delete from lads_shp_das where tknum = rcd_lock.tknum;
            delete from lads_shp_dad where tknum = rcd_lock.tknum;
            delete from lads_shp_dlv where tknum = rcd_lock.tknum;
            delete from lads_shp_hsi where tknum = rcd_lock.tknum;
            delete from lads_shp_hsd where tknum = rcd_lock.tknum;
            delete from lads_shp_hsp where tknum = rcd_lock.tknum;
            delete from lads_shp_hst where tknum = rcd_lock.tknum;
            delete from lads_shp_htg where tknum = rcd_lock.tknum;
            delete from lads_shp_htx where tknum = rcd_lock.tknum;
            delete from lads_shp_hda where tknum = rcd_lock.tknum;
            delete from lads_shp_had where tknum = rcd_lock.tknum;
            delete from lads_shp_har where tknum = rcd_lock.tknum;
            delete from lads_shp_hct where tknum = rcd_lock.tknum;
            delete from lads_shp_hdr where tknum = rcd_lock.tknum;
         end if;

      end loop;
      close csr_header;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_atllad14;

   /******************************************************/
   /* This procedure performs the purge ATLLAD16 routine */
   /******************************************************/
   procedure purge_atllad16 is

      /*-*/
      /* Local definitions
      /*-*/
      var_history number;
      var_count number;
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is
         select t01.vbeln
           from lads_del_hdr t01
          where t01.lads_date < sysdate - var_history;
      rcd_header csr_header%rowtype;

      cursor csr_lock is
         select t01.vbeln
           from lads_del_hdr t01
          where t01.vbeln = rcd_header.vbeln
                for update nowait;
      rcd_lock csr_lock%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the history days
      /*-*/
      var_history := to_number(lics_setting_configuration.retrieve_setting(con_purging_group, 'ATLLAD16'));

      /*-*/
      /* Retrieve the headers
      /*-*/
      var_count := 0;
      open csr_header;
      loop
         if var_count >= cnt_process_count then
            if csr_header%isopen then
               close csr_header;
            end if;
            commit;
            open csr_header;
            var_count := 0;
         end if;
         fetch csr_header into rcd_header;
         if csr_header%notfound then
            exit;
         end if;

         /*-*/
         /* Increment the count
         /*-*/
         var_count := var_count + 1;

         /*-*/
         /* Attempt to lock the header
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
         if csr_lock%isopen then
            close csr_lock;
         end if;

         /*-*/
         /* Delete the header and related data when available
         /*-*/
         if var_available = true then
            delete from lads_del_huc where vbeln = rcd_lock.vbeln;
            delete from lads_del_huh where vbeln = rcd_lock.vbeln;
            delete from lads_del_dtp where vbeln = rcd_lock.vbeln;
            delete from lads_del_dtx where vbeln = rcd_lock.vbeln;
            delete from lads_del_erf where vbeln = rcd_lock.vbeln;
            delete from lads_del_irf where vbeln = rcd_lock.vbeln;
            delete from lads_del_int where vbeln = rcd_lock.vbeln;
            delete from lads_del_pod where vbeln = rcd_lock.vbeln;
            delete from lads_del_det where vbeln = rcd_lock.vbeln;
            delete from lads_del_nod where vbeln = rcd_lock.vbeln;
            delete from lads_del_stg where vbeln = rcd_lock.vbeln;
            delete from lads_del_rte where vbeln = rcd_lock.vbeln;
            delete from lads_del_htp where vbeln = rcd_lock.vbeln;
            delete from lads_del_htx where vbeln = rcd_lock.vbeln;
            delete from lads_del_tim where vbeln = rcd_lock.vbeln;
            delete from lads_del_adl where vbeln = rcd_lock.vbeln;
            delete from lads_del_add where vbeln = rcd_lock.vbeln;
            delete from lads_del_hdr where vbeln = rcd_lock.vbeln;
         end if;

      end loop;
      close csr_header;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_atllad16;

   /******************************************************/
   /* This procedure performs the purge ATLLAD18 routine */
   /******************************************************/
   procedure purge_atllad18 is

      /*-*/
      /* Local definitions
      /*-*/
      var_history number;
      var_count number;
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is
         select t01.belnr
           from lads_inv_hdr t01
          where t01.lads_date < sysdate - var_history;
      rcd_header csr_header%rowtype;

      cursor csr_lock is
         select t01.belnr
           from lads_inv_hdr t01
          where t01.belnr = rcd_header.belnr
                for update nowait;
      rcd_lock csr_lock%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the history days
      /*-*/
      var_history := to_number(lics_setting_configuration.retrieve_setting(con_purging_group, 'ATLLAD18'));

      /*-*/
      /* Retrieve the headers
      /*-*/
      var_count := 0;
      open csr_header;
      loop
         if var_count >= cnt_process_count then
            if csr_header%isopen then
               close csr_header;
            end if;
            commit;
            open csr_header;
            var_count := 0;
         end if;
         fetch csr_header into rcd_header;
         if csr_header%notfound then
            exit;
         end if;

         /*-*/
         /* Increment the count
         /*-*/
         var_count := var_count + 1;

         /*-*/
         /* Attempt to lock the header
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
         if csr_lock%isopen then
            close csr_lock;
         end if;

         /*-*/
         /* Delete the header and related data when available
         /*-*/
         if var_available = true then
            delete from lads_inv_smy where belnr = rcd_lock.belnr;
            delete from lads_inv_iti where belnr = rcd_lock.belnr;
            delete from lads_inv_itx where belnr = rcd_lock.belnr;
            delete from lads_inv_icb where belnr = rcd_lock.belnr;
            delete from lads_inv_ift where belnr = rcd_lock.belnr;
            delete from lads_inv_ita where belnr = rcd_lock.belnr;
            delete from lads_inv_icp where belnr = rcd_lock.belnr;
            delete from lads_inv_icn where belnr = rcd_lock.belnr;
            delete from lads_inv_iaj where belnr = rcd_lock.belnr;
            delete from lads_inv_ipn where belnr = rcd_lock.belnr;
            delete from lads_inv_ias where belnr = rcd_lock.belnr;
            delete from lads_inv_iob where belnr = rcd_lock.belnr;
            delete from lads_inv_idt where belnr = rcd_lock.belnr;
            delete from lads_inv_irf where belnr = rcd_lock.belnr;
            delete from lads_inv_grd where belnr = rcd_lock.belnr;
            delete from lads_inv_mat where belnr = rcd_lock.belnr;
            delete from lads_inv_gen where belnr = rcd_lock.belnr;
            delete from lads_inv_sal where belnr = rcd_lock.belnr;
            delete from lads_inv_org where belnr = rcd_lock.belnr;
            delete from lads_inv_txi where belnr = rcd_lock.belnr;
            delete from lads_inv_txt where belnr = rcd_lock.belnr;
            delete from lads_inv_ftd where belnr = rcd_lock.belnr;
            delete from lads_inv_bnk where belnr = rcd_lock.belnr;
            delete from lads_inv_cur where belnr = rcd_lock.belnr;
            delete from lads_inv_top where belnr = rcd_lock.belnr;
            delete from lads_inv_tod where belnr = rcd_lock.belnr;
            delete from lads_inv_tax where belnr = rcd_lock.belnr;
            delete from lads_inv_dcn where belnr = rcd_lock.belnr;
            delete from lads_inv_dat where belnr = rcd_lock.belnr;
            delete from lads_inv_ref where belnr = rcd_lock.belnr;
            delete from lads_inv_adj where belnr = rcd_lock.belnr;
            delete from lads_inv_pnr where belnr = rcd_lock.belnr;
            delete from lads_inv_con where belnr = rcd_lock.belnr;
            delete from lads_inv_cus where belnr = rcd_lock.belnr;
            delete from lads_inv_hdr where belnr = rcd_lock.belnr;
         end if;

      end loop;
      close csr_header;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_atllad18;

   /******************************************************/
   /* This procedure performs the purge ATLLAD20 routine */
   /******************************************************/
   procedure purge_atllad20 is

      /*-*/
      /* Local definitions
      /*-*/
      var_history number;
      var_count number;
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is
         select t01.hdrdat,
                t01.hdrseq
           from lads_hie_cus_hdr t01
          where t01.lads_date < sysdate - var_history;
      rcd_header csr_header%rowtype;

      cursor csr_lock is
         select t01.hdrdat,
                t01.hdrseq
           from lads_hie_cus_hdr t01
          where t01.hdrdat = rcd_header.hdrdat
            and t01.hdrseq = rcd_header.hdrseq
                for update nowait;
      rcd_lock csr_lock%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the history days
      /*-*/
      var_history := to_number(lics_setting_configuration.retrieve_setting(con_purging_group, 'ATLLAD20'));

      /*-*/
      /* Retrieve the headers
      /*-*/
      var_count := 0;
      open csr_header;
      loop
         if var_count >= cnt_process_count then
            if csr_header%isopen then
               close csr_header;
            end if;
            commit;
            open csr_header;
            var_count := 0;
         end if;
         fetch csr_header into rcd_header;
         if csr_header%notfound then
            exit;
         end if;

         /*-*/
         /* Increment the count
         /*-*/
         var_count := var_count + 1;

         /*-*/
         /* Attempt to lock the header
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
         if csr_lock%isopen then
            close csr_lock;
         end if;

         /*-*/
         /* Delete the header and related data when available
         /*-*/
         if var_available = true then
            delete from lads_hie_cus_det where hdrdat = rcd_lock.hdrdat
                                           and hdrseq = rcd_lock.hdrseq;
            delete from lads_hie_cus_hdr where hdrdat = rcd_lock.hdrdat
                                           and hdrseq = rcd_lock.hdrseq;
         end if;

      end loop;
      close csr_header;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_atllad20;

   /******************************************************/
   /* This procedure performs the purge ATLLAD25 routine */
   /******************************************************/
   procedure purge_atllad25 is

      /*-*/
      /* Local definitions
      /*-*/
      var_history number;
      var_count number;
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is
         select t01.zzgrpnr
           from lads_exp_hdr t01
          where t01.lads_date < sysdate - var_history;
      rcd_header csr_header%rowtype;

      cursor csr_lock is
         select t01.zzgrpnr
           from lads_exp_hdr t01
          where t01.zzgrpnr = rcd_header.zzgrpnr
                for update nowait;
      rcd_lock csr_lock%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the history days
      /*-*/
      var_history := to_number(lics_setting_configuration.retrieve_setting(con_purging_group, 'ATLLAD25'));

      /*-*/
      /* Retrieve the headers
      /*-*/
      var_count := 0;
      open csr_header;
      loop
         if var_count >= cnt_process_count then
            if csr_header%isopen then
               close csr_header;
            end if;
            commit;
            open csr_header;
            var_count := 0;
         end if;
         fetch csr_header into rcd_header;
         if csr_header%notfound then
            exit;
         end if;

         /*-*/
         /* Increment the count
         /*-*/
         var_count := var_count + 1;

         /*-*/
         /* Attempt to lock the header
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
         if csr_lock%isopen then
            close csr_lock;
         end if;

         /*-*/
         /* Delete the header and related data when available
         /*-*/
         if var_available = true then
            delete from lads_exp_add where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_dat where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_del where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_det where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_erf where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_gen where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_hag where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_har where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_hda where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_hde where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_hin where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_hor where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_hsd where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_hsh where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_hsi where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_hsp where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_hst where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_huc where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_huh where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_icn where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_ico where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_idt where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_ign where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_int where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_inv where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_ire where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_irf where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_ord where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_org where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_pnr where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_shp where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_sin where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_sor where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_tim where zzgrpnr = rcd_lock.zzgrpnr;
            delete from lads_exp_hdr where zzgrpnr = rcd_lock.zzgrpnr;
         end if;

      end loop;
      close csr_header;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_atllad25;

   /******************************************************/
   /* This procedure performs the purge ATLLAD28 routine */
   /******************************************************/
   procedure purge_atllad28 is

      /*-*/
      /* Local definitions
      /*-*/
      var_history number;
      var_count number;
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is
         select t01.order_num,
                t01.order_item
           from lads_opr_hdr t01
          where t01.lads_date < sysdate - var_history;
      rcd_header csr_header%rowtype;

      cursor csr_lock is
         select t01.order_num,
                t01.order_item
           from lads_opr_hdr t01
          where t01.order_num = rcd_header.order_num
            and t01.order_item = rcd_header.order_item
                for update nowait;
      rcd_lock csr_lock%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the history days
      /*-*/
      var_history := to_number(lics_setting_configuration.retrieve_setting(con_purging_group, 'ATLLAD28'));

      /*-*/
      /* Retrieve the headers
      /*-*/
      var_count := 0;
      open csr_header;
      loop
         if var_count >= cnt_process_count then
            if csr_header%isopen then
               close csr_header;
            end if;
            commit;
            open csr_header;
            var_count := 0;
         end if;
         fetch csr_header into rcd_header;
         if csr_header%notfound then
            exit;
         end if;

         /*-*/
         /* Increment the count
         /*-*/
         var_count := var_count + 1;

         /*-*/
         /* Attempt to lock the header
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
         if csr_lock%isopen then
            close csr_lock;
         end if;

         /*-*/
         /* Delete the header and related data when available
         /*-*/
         if var_available = true then
            delete from lads_opr_hdr where order_num = rcd_lock.order_num
                                       and order_item = rcd_lock.order_item;
         end if;

      end loop;
      close csr_header;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_atllad28;

   /******************************************************/
   /* This procedure performs the purge ATLLAD29 routine */
   /******************************************************/
   procedure purge_atllad29 is

      /*-*/
      /* Local definitions
      /*-*/
      var_history number;
      var_count number;
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is
         select t01.order_id
           from lads_ppo_hdr t01
          where t01.lads_date < sysdate - var_history;
      rcd_header csr_header%rowtype;

      cursor csr_lock is
         select t01.order_id
           from lads_ppo_hdr t01
          where t01.order_id = rcd_header.order_id
                for update nowait;
      rcd_lock csr_lock%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the history days
      /*-*/
      var_history := to_number(lics_setting_configuration.retrieve_setting(con_purging_group, 'ATLLAD29'));

      /*-*/
      /* Retrieve the headers
      /*-*/
      var_count := 0;
      open csr_header;
      loop
         if var_count >= cnt_process_count then
            if csr_header%isopen then
               close csr_header;
            end if;
            commit;
            open csr_header;
            var_count := 0;
         end if;
         fetch csr_header into rcd_header;
         if csr_header%notfound then
            exit;
         end if;

         /*-*/
         /* Increment the count
         /*-*/
         var_count := var_count + 1;

         /*-*/
         /* Attempt to lock the header
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
         if csr_lock%isopen then
            close csr_lock;
         end if;

         /*-*/
         /* Delete the header and related data when available
         /*-*/
         if var_available = true then
            delete from lads_ppo_hdr where order_id = rcd_lock.order_id;
         end if;

      end loop;
      close csr_header;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_atllad29;

end lads_purging;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_purging for lads_app.lads_purging;
grant execute on lads_purging to public;