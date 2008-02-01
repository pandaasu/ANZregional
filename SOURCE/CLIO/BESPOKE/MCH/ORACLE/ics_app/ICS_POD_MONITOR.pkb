CREATE OR REPLACE package body         ics_pod_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);


   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

      /*-*/
      /* Local Variables
      /*-*/
      var_ema_group varchar2(512 char);
      var_count number;
      var_data boolean;

      /*-*/
      /* Local Cursors
      /*-*/
      cursor csr_pod_monitor is
         select distinct del_doc_num
         from order_fact
         where ord_lin_status = '*INV'
           and pod_date is null;
      rec_pod_monitor csr_pod_monitor%rowtype;


   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Define variables
      /*-*/
      var_ema_group := 'jed.luo@smtp.ap.mars';
      var_data := false;
      var_count := 0;

      /*-*/
      /* Create Email
      /*-*/
      isi_mailer.create_email(var_ema_group,
                              'ICS POD Monitor for '
                                 || upper(sys_context ('USERENV', 'DB_NAME'))
                                 || ' on ' || to_char(sysdate,'DD/MM/YYYY')
                              ,null,null);

      open csr_pod_monitor;
      loop
         fetch csr_pod_monitor into rec_pod_monitor;
         if (csr_pod_monitor%notfound) then
            exit;
         end if;

         if (var_count = 0) then

            var_data := true;

            /*-*/
            /* Write Email header
            /*-*/
            isi_mailer.append_data('*------------------------------------------------------------------------------------*');
            isi_mailer.append_data('|The following Delivery Documents have been Invoiced in CLIO, but no POD data exists |');
            isi_mailer.append_data('|  * Please manually send the corresponding POD documents to HK LADS/CLIO            |');
            isi_mailer.append_data('*====================================================================================*');
            isi_mailer.append_data(null);

         end if;

         isi_mailer.append_data(rec_pod_monitor.del_doc_num);

         var_count := var_count+1;

      end loop;
      close csr_pod_monitor;

      if (var_data) then

         isi_mailer.append_data(null);
         isi_mailer.append_data('*=============================================================================================================*');
         isi_mailer.append_data(null);
         isi_mailer.append_data('TOTAL DOCUMENTS : ' || var_count);

         /*-*/
         /* Finalise Email
         /*-*/
         isi_mailer.finalise_email(lics_parameter.system_unit || '.' || lics_parameter.system_environment || '@' || upper(sys_context ('USERENV', 'DB_NAME')));

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
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Finalise Email
         /*-*/
         if (isi_mailer.is_created) then
            isi_mailer.append_data('** FATAL ERROR DURING ICS POD MONITOR ** - ' || SQLERRM);
            isi_mailer.finalise_email(lics_parameter.system_environment || '@' || upper(sys_context ('USERENV', 'DB_NAME')));
         end if;

         /*-*/
         /* Raise the exception
         /*-*/
         raise;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ics_pod_monitor;
/

