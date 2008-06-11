CREATE OR REPLACE package ladims01_material as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : ladims01_material
 Owner   : site_app

 Description
 -----------
 Material Master Data

 1. PAR_EMA_RECIPIENT (MANDATORY)

    Email address attachment is to be sent to.

 2. PAR_PLANT_CODE (MANDATORY)

    GRD Plant Code extract is for


 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/02   Linden Glen    Created
 2008/05   Linden Glen    Changed to send as email

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_ema_recipient in varchar2, par_plant_code in varchar2);

end ladims01_material; 
/


CREATE OR REPLACE package body ladims01_material as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_ema_recipient in varchar2, par_plant_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);
      var_start boolean;
      var_subject varchar2(128 char);
      var_sender varchar2(128 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_matl_master is
         select '<td align=center>'||ltrim(a.sap_material_code,'0')||'</td>'||
                '<td align=center>'||a.bds_material_desc_zh||'</td>'||
                '<td align=center>'||decode(a.material_type,'ROH','RAW/SFG',
                                                            'FERT','FG',
                                                            'VERP','PACK',a.material_type)||'</td>'||
                '<td align=center>'||decode(b.special_procurement_type,'50','YES','NO')||'</td>'||
                '<td align=center>'||a.base_uom||'</td>'||
                '<td align=center>'||decode(b.plant_specific_status,'99','Retired','New')||'</td>' as extract_line
         from bds_material_hdr a,
              bds_material_plant_hdr b
         where a.sap_material_code = b.sap_material_code
           and a.bds_lads_status = '1'
           and b.plant_code = par_plant_code
           and ((a.bds_lads_date >= sysdate-1 and to_char(a.creatn_date,'yyyymmdd') in (to_char(a.bds_lads_date,'yyyymmdd'),to_char(a.bds_lads_date-1,'yyyymmdd'))) or
                (a.bds_lads_date >= sysdate-1 and b.plant_specific_status = '99'));
      rec_matl_master  csr_matl_master%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_start := true;
      var_sender := 'BDS@AP0115P';
      var_subject := 'GRD Material Change Extract - IMS - Plant Code: ' || par_plant_code;

      /*-*/
      /* Validate the parameters
      /*-*/
      if trim(par_ema_recipient) is null then
         raise_application_error(-20000, 'Email Recipient parameter is required');
      end if;
      /*-*/
      if trim(par_plant_code) is null then
         raise_application_error(-20000, 'Plant Code parameter is required');
      end if;

      /*-*/
      /* Create the new email and create the email text header part
      /*-*/
      lics_mailer.create_email(var_sender,
                               par_ema_recipient,
                               var_subject,
                               null,
                               null);
      lics_mailer.create_part(null);
      lics_mailer.append_data('GRD Material Changes for Plant ' || par_plant_code);
      lics_mailer.append_data(null);
      lics_mailer.append_data(null);

      /*-*/
      /* Open Cursor for output
      /*-*/
      open csr_matl_master;
      loop
         fetch csr_matl_master into rec_matl_master;
         if (csr_matl_master%notfound) then
            exit;
         end if;

         /*-*/
         /* Create Outbound Interface if record(s) exist
         /*-*/
         if (var_start) then

            /*-*/
            /* Create the email file and output the header data (character set UTF-8)
            /*-*/
            lics_mailer.create_part('grd_extract_' || to_char(sysdate,'yyyymmddhh24miss') || '.xls');
            lics_mailer.append_data('<head><meta http-equiv=Content-Type content="text/html; charset=utf-8"></head>');
            lics_mailer.append_data('<table border=1 cellpadding="0" cellspacing="0">');
            lics_mailer.append_data('<tr>');
            lics_mailer.append_data('<td align=right style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">MATERIAL_CODE</td>');
            lics_mailer.append_data('<td align=right style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">DESCRIPTION</td>');
            lics_mailer.append_data('<td align=right style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">MATERIAL_TYPE</td>');
            lics_mailer.append_data('<td align=right style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">PHANTOM</td>');
            lics_mailer.append_data('<td align=right style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">UOM</td>');
            lics_mailer.append_data('<td align=right style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">STATUS</td>');
            lics_mailer.append_data('</tr>');

            var_start := false;

         end if;

         /*-*/
         /* Append attachment records
         /*-*/
         lics_mailer.append_data('<tr>'||rec_matl_master.extract_line||'</tr>');

      end loop;
      close csr_matl_master;

      /*-*/
      /* Notify in email if no attachment generated
      /*-*/
      if (var_start) then
         lics_mailer.append_data('<tr><td colspan=6 align=center>NO GRD CHANGES AVAILABLE</td></tr>');
      end if;

      /*-*/
      /* Output the email file part trailer data
      /*-*/
      lics_mailer.append_data('</table>');

      /*-*/
      /* Create the email end part
      /*-*/
      lics_mailer.create_part(null);
      lics_mailer.append_data(null);
      lics_mailer.append_data(null);
      lics_mailer.append_data('** Email End **');

      /*-*/
      /* Finalise and send email (character set UTF-8)
      /*-*/
      lics_mailer.finalise_email('utf-8');

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
         /* Finalise the email
         /*-*/
         if (lics_mailer.is_created) then
             lics_mailer.create_part(null);
             lics_mailer.append_data('** FATAL ERROR DURING EXTRACT ** - Please notify support');
             lics_mailer.finalise_email('utf-8');
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - LADIMS01 MATERIAL - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ladims01_material; 
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ladims01_material for ics_app.ladims01_material;
grant execute on ladims01_material to public;
