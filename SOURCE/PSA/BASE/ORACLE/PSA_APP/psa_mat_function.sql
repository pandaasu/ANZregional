/******************/
/* Package Header */
/******************/
create or replace package psa_app.psa_mat_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : psa_mat_function
    Owner   : psa_app

    Description
    -----------
    Production Scheduling Application - Material Function

    This package contain the material functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/12   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure update_master;
   function select_list return psa_xml_type pipelined;
   function retrieve_data return psa_xml_type pipelined;
   procedure update_data(par_user in varchar2);
   procedure inactivate_data(par_user in varchar2);

end psa_mat_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body psa_app.psa_mat_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*****************************************************/
   /* This procedure performs the update master routine */
   /*****************************************************/
   procedure update_master is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_report_email varchar2(256);
      var_upd_flag boolean;
      rcd_psa_mat_defn psa_mat_defn%rowtype;

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'PSA SAP Material Maintenance';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_bds_data is
         select ltrim(t01.sap_material_code,' 0') as material_code,
                t01.sap_material_code,
                t01.bds_material_desc_en,
                t01.material_type,
                t01.base_uom,
                t01.gross_weight,
                t01.net_weight,
                t01.bds_pce_factor_from_base_uom,
                decode(t01.material_type,'FERT',decode(t01.mars_intrmdt_prdct_compnt_flag,'X','MPO','TDU'),'VERP',substr(t01.bds_material_desc_en,1,3),'*NONE') material_usage,
                t02.sap_prodctn_line_code,
                t03.*,
                t04.lli_lin_code
           from bds.bds_material_plant_mfanz t01,
                bds.bds_material_classfctn t02,
                psa_mat_defn t03,
                (select t01.lli_sap_code,
                        min(t01.lli_lin_code) as lli_lin_code
                   from psa_lin_link t01,
                        psa_lin_defn t02
                  where t01.lli_lin_code = t02.lde_lin_code
                    and t02.lde_lin_status = '1'
                  group by t01.lli_sap_code) t04
          where t01.sap_material_code = t02.sap_material_code(+)
            and t01.sap_material_code = t03.mde_sap_code(+)
            and t02.sap_prodctn_line_code = t04.lli_sap_code(+)
            and t01.plant_code = 'NZ01'
            and ((t01.material_type = 'FERT' and t01.plant_specific_status = '20' and (t01.mars_traded_unit_flag = 'X' or t01.mars_intrmdt_prdct_compnt_flag = 'X')) or
                 (t01.material_type = 'VERP' and t01.plant_specific_status = '20' and (substr(t01.bds_material_desc_en,1,3)) in ('PCH','RLS')))
          order by t01.sap_material_code asc;
      rcd_bds_data csr_bds_data%rowtype;

      cursor csr_psa_fert is
         select t01.*
           from psa_mat_defn t01
          where t01.mde_mat_type = 'FERT'
            and t01.mde_mat_usage in ('TDU','MPO')
            and (t01.mde_mat_status != '*INACTIVE' and t01.mde_mat_status != '*DEL')
            and not(t01.mde_sap_code in (select sap_material_code
                                           from bds.bds_material_plant_mfanz
                                          where plant_code = 'NZ01'
                                            and material_type = 'FERT'
                                            and plant_specific_status = '20'
                                            and (mars_traded_unit_flag = 'X' or mars_intrmdt_prdct_compnt_flag = 'X')))
          order by t01.mde_mat_code asc;
      rcd_psa_fert csr_psa_fert%rowtype;

      cursor csr_psa_verp is
         select t01.*
           from psa_mat_defn t01
          where t01.mde_mat_type = 'VERP'
            and t01.mde_mat_usage in ('PCH','RLS')
            and (t01.mde_mat_status != '*INACTIVE' and t01.mde_mat_status != '*DEL')
            and not(t01.mde_sap_code in (select sap_material_code
                                           from bds.bds_material_plant_mfanz
                                          where plant_code = 'NZ01'
                                            and material_type = 'VERP'
                                            and plant_specific_status = '20'
                                            and (substr(bds_material_desc_en,1,3)) in ('PCH','RLS')))
          order by t01.mde_mat_code asc;
      rcd_psa_verp csr_psa_verp%rowtype;

      cursor csr_material is
         select t01.*
           from psa_mat_defn t01
          where t01.mde_mat_status in ('*ADD','*CHG','*DEL')
          order by t01.mde_mat_code asc;
      rcd_material csr_material%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log variables
      /*-*/
      var_log_prefix := 'PSA - SAP_MATERIAL_MAINTENANCE';
      var_log_search := 'SAP_MATERIAL_MAINTENANCE';
      var_report_email := psa_sys_function.retrieve_system_value('MATERIAL_AUDIT_EMAIL');

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - PSA SAP Material Maintenance');

      /*-*/
      /* Log the event
      /*-*/
      lics_logging.write_log('--> Updating PSA material from the SAP material data');

      /*-*/
      /* Process the BDS materials
      /*-*/
      open csr_bds_data;
      loop
         fetch csr_bds_data into rcd_bds_data;
         if csr_bds_data%notfound then
            exit;
         end if;

         /*-*/
         /* Insert new materials (*ADD) - material does not exist
         /*-*/
         if rcd_bds_data.mde_mat_code is null then

            rcd_psa_mat_defn.mde_mat_code := rcd_bds_data.material_code;
            rcd_psa_mat_defn.mde_sap_code := rcd_bds_data.sap_material_code;
            rcd_psa_mat_defn.mde_mat_name := rcd_bds_data.bds_material_desc_en;
            rcd_psa_mat_defn.mde_mat_type := rcd_bds_data.material_type;
            rcd_psa_mat_defn.mde_mat_usage := rcd_bds_data.material_usage;
            rcd_psa_mat_defn.mde_mat_uom := rcd_bds_data.base_uom;
            rcd_psa_mat_defn.mde_gro_weight := rcd_bds_data.gross_weight;
            rcd_psa_mat_defn.mde_net_weight := rcd_bds_data.net_weight;
            rcd_psa_mat_defn.mde_unt_case := rcd_bds_data.bds_pce_factor_from_base_uom;
            rcd_psa_mat_defn.mde_sap_line := rcd_bds_data.sap_prodctn_line_code;
            rcd_psa_mat_defn.mde_mat_status := '*ADD';
            rcd_psa_mat_defn.mde_sys_user := user;
            rcd_psa_mat_defn.mde_sys_date := sysdate;
            rcd_psa_mat_defn.mde_upd_user := null;
            rcd_psa_mat_defn.mde_upd_date := null;
            rcd_psa_mat_defn.mde_prd_type := null;
            rcd_psa_mat_defn.mde_sch_priority := 0;
            rcd_psa_mat_defn.mde_dft_line := rcd_bds_data.lli_lin_code;
            rcd_psa_mat_defn.mde_cas_pallet := 0;
            rcd_psa_mat_defn.mde_bch_quantity := 0;
            rcd_psa_mat_defn.mde_yld_percent := 0;
            rcd_psa_mat_defn.mde_yld_value := 0;
            rcd_psa_mat_defn.mde_pck_percent := 0;
            rcd_psa_mat_defn.mde_pck_weight := rcd_psa_mat_defn.mde_net_weight * rcd_psa_mat_defn.mde_unt_case;
            rcd_psa_mat_defn.mde_bch_weight := 0;
            if rcd_psa_mat_defn.mde_mat_type = 'TDU' then
               rcd_psa_mat_defn.mde_prd_type := '*FILL';
            elsif rcd_psa_mat_defn.mde_mat_type = 'MPO' then
               rcd_psa_mat_defn.mde_prd_type := '*FILL';
            elsif rcd_psa_mat_defn.mde_mat_type = 'PCH' then
               rcd_psa_mat_defn.mde_prd_type := '*FORM';
            elsif rcd_psa_mat_defn.mde_mat_type = 'RLS' then
               rcd_psa_mat_defn.mde_prd_type := '*NONE';
            end if;
            insert into psa_mat_defn values rcd_psa_mat_defn;

         /*-*/
         /* Update existing materials
         /*-*/
         else

            /*-*/
            /* Reset the update flag
            /*-*/
            var_upd_flag := false;

            /*-*/
            /* Update inactive/deleted materials (*ADD)
            /*-*/
            if rcd_bds_data.mde_mat_status = '*INACTIVE' or rcd_bds_data.mde_mat_status = '*DEL' then

               var_upd_flag := true;
               rcd_psa_mat_defn.mde_mat_status := '*ADD';

            /*-*/
            /* Update active/changed/added materials (*CHG)
            /*-*/
            elsif rcd_bds_data.mde_mat_status = '*ACTIVE' or rcd_bds_data.mde_mat_status = '*CHG' or rcd_bds_data.mde_mat_status = '*ADD' then

               if (rcd_bds_data.mde_mat_name != rcd_bds_data.bds_material_desc_en or
                   rcd_bds_data.mde_mat_type != rcd_bds_data.material_type or
                   rcd_bds_data.mde_mat_usage != rcd_bds_data.material_usage or
                   rcd_bds_data.mde_mat_uom != rcd_bds_data.base_uom or
                   rcd_bds_data.mde_gro_weight != rcd_bds_data.gross_weight or
                   rcd_bds_data.mde_net_weight != rcd_bds_data.net_weight or
                   rcd_bds_data.mde_unt_case != rcd_bds_data.bds_pce_factor_from_base_uom or
                   nvl(rcd_bds_data.mde_sap_line,'*NULL') != nvl(rcd_bds_data.sap_prodctn_line_code,'*NULL')) then

                  var_upd_flag := true;
                  if rcd_bds_data.mde_mat_status = '*ACTIVE' then
                     rcd_psa_mat_defn.mde_mat_status := '*CHG';
                  end if;

               end if;

            end if;

            /*-*/
            /* Update when required
            /*-*/
            if var_upd_flag = true then

               rcd_psa_mat_defn.mde_mat_name := rcd_bds_data.bds_material_desc_en;
               rcd_psa_mat_defn.mde_mat_type := rcd_bds_data.material_type;
               rcd_psa_mat_defn.mde_mat_usage := rcd_bds_data.material_usage;
               rcd_psa_mat_defn.mde_mat_uom := rcd_bds_data.base_uom;
               rcd_psa_mat_defn.mde_gro_weight := rcd_bds_data.gross_weight;
               rcd_psa_mat_defn.mde_net_weight := rcd_bds_data.net_weight;
               rcd_psa_mat_defn.mde_unt_case := rcd_bds_data.bds_pce_factor_from_base_uom;
               rcd_psa_mat_defn.mde_sap_line := rcd_bds_data.sap_prodctn_line_code;
               rcd_psa_mat_defn.mde_sys_user := user;
               rcd_psa_mat_defn.mde_sys_date := sysdate;
               rcd_psa_mat_defn.mde_prd_type := rcd_bds_data.mde_prd_type;
               rcd_psa_mat_defn.mde_sch_priority := rcd_bds_data.mde_sch_priority;
               rcd_psa_mat_defn.mde_dft_line := rcd_bds_data.lli_lin_code;
               rcd_psa_mat_defn.mde_cas_pallet := rcd_bds_data.mde_cas_pallet;
               rcd_psa_mat_defn.mde_bch_quantity := rcd_bds_data.mde_bch_quantity;
               rcd_psa_mat_defn.mde_yld_percent := rcd_bds_data.mde_yld_percent;
               rcd_psa_mat_defn.mde_yld_value := rcd_bds_data.mde_yld_value;
               rcd_psa_mat_defn.mde_pck_percent := rcd_bds_data.mde_pck_percent;
               rcd_psa_mat_defn.mde_pck_weight := rcd_psa_mat_defn.mde_net_weight * rcd_psa_mat_defn.mde_unt_case;
               rcd_psa_mat_defn.mde_bch_weight := rcd_bds_data.mde_bch_weight;
               if rcd_psa_mat_defn.mde_prd_type = '*PACK' then
                  rcd_psa_mat_defn.mde_yld_value := 1;
               elsif rcd_psa_mat_defn.mde_prd_type = '*FILL' then
                  rcd_psa_mat_defn.mde_yld_value := (rcd_psa_mat_defn.mde_unt_case * rcd_psa_mat_defn.mde_bch_quantity * rcd_psa_mat_defn.mde_yld_percent);
               elsif rcd_psa_mat_defn.mde_prd_type = '*FORM' then
                  rcd_psa_mat_defn.mde_yld_value := rcd_psa_mat_defn.mde_bch_quantity;
               end if;
               if rcd_psa_mat_defn.mde_prd_type = '*FILL' then
                  rcd_psa_mat_defn.mde_pck_weight := (rcd_psa_mat_defn.mde_net_weight / rcd_psa_mat_defn.mde_unt_case);
               end if;
               if rcd_psa_mat_defn.mde_prd_type = '*FILL' then
                  rcd_psa_mat_defn.mde_bch_weight := (rcd_psa_mat_defn.mde_yld_value * rcd_psa_mat_defn.mde_pck_weight * round((rcd_psa_mat_defn.mde_pck_percent / 100),2));
               end if;
               update psa_mat_defn
                  set mde_mat_name = rcd_psa_mat_defn.mde_mat_name,
                      mde_mat_type = rcd_psa_mat_defn.mde_mat_type,
                      mde_mat_usage = rcd_psa_mat_defn.mde_mat_usage,
                      mde_mat_uom = rcd_psa_mat_defn.mde_mat_uom,
                      mde_gro_weight = rcd_psa_mat_defn.mde_gro_weight,
                      mde_net_weight = rcd_psa_mat_defn.mde_net_weight,
                      mde_unt_case = rcd_psa_mat_defn.mde_unt_case,
                      mde_sap_line = rcd_psa_mat_defn.mde_sap_line,
                      mde_mat_status = rcd_psa_mat_defn.mde_mat_status,
                      mde_sys_user = rcd_psa_mat_defn.mde_sys_user,
                      mde_sys_date = rcd_psa_mat_defn.mde_sys_date,
                      mde_prd_type = rcd_psa_mat_defn.mde_prd_type,
                      mde_sch_priority = rcd_psa_mat_defn.mde_sch_priority,
                      mde_dft_line = rcd_psa_mat_defn.mde_dft_line,
                      mde_cas_pallet = rcd_psa_mat_defn.mde_cas_pallet,
                      mde_bch_quantity = rcd_psa_mat_defn.mde_bch_quantity,
                      mde_yld_percent = rcd_psa_mat_defn.mde_yld_percent,
                      mde_yld_value = rcd_psa_mat_defn.mde_yld_value,
                      mde_pck_percent = rcd_psa_mat_defn.mde_pck_percent,
                      mde_pck_weight = rcd_psa_mat_defn.mde_pck_weight,
                      mde_bch_weight = rcd_psa_mat_defn.mde_bch_weight
                where mde_mat_code = rcd_bds_data.mde_mat_code;

            end if;

         end if;

      end loop;
      close csr_bds_data;

      /*-*/
      /* Process the PSA FERT materials
      /*-*/
      open csr_psa_fert;
      loop
         fetch csr_psa_fert into rcd_psa_fert;
         if csr_psa_fert%notfound then
            exit;
         end if;

         /*-*/
         /* Remove existing FERT materials (physical delete)
         /*-*/
         if rcd_psa_fert.mde_mat_status = '*ADD' then

            delete from psa_mat_defn
             where mde_mat_code = rcd_psa_fert.mde_mat_code;

         /*-*/
         /* Remove existing FERT materials (*DEL)
         /*-*/
         else

            rcd_psa_mat_defn.mde_mat_status := '*DEL';
            rcd_psa_mat_defn.mde_sys_user := user;
            rcd_psa_mat_defn.mde_sys_date := sysdate;
            update psa_mat_defn
               set mde_mat_status = rcd_psa_mat_defn.mde_mat_status,
                   mde_sys_user = rcd_psa_mat_defn.mde_sys_user,
                   mde_sys_date = rcd_psa_mat_defn.mde_sys_date
             where mde_mat_code = rcd_psa_fert.mde_mat_code;

         end if;

      end loop;
      close csr_psa_fert;

      /*-*/
      /* Process the PSA VERP materials
      /*-*/
      open csr_psa_verp;
      loop
         fetch csr_psa_verp into rcd_psa_verp;
         if csr_psa_verp%notfound then
            exit;
         end if;

         /*-*/
         /* Remove existing VERP materials (physical delete)
         /*-*/
         if rcd_psa_verp.mde_mat_status = '*ADD' then

            delete from psa_mat_defn
             where mde_mat_code = rcd_psa_verp.mde_mat_code;

         /*-*/
         /* Remove existing VERP materials (*DEL)
         /*-*/
         else

            rcd_psa_mat_defn.mde_mat_status := '*DEL';
            rcd_psa_mat_defn.mde_sys_user := user;
            rcd_psa_mat_defn.mde_sys_date := sysdate;
            update psa_mat_defn
               set mde_mat_status = rcd_psa_mat_defn.mde_mat_status,
                   mde_sys_user = rcd_psa_mat_defn.mde_sys_user,
                   mde_sys_date = rcd_psa_mat_defn.mde_sys_date
             where mde_mat_code = rcd_psa_verp.mde_mat_code;

         end if;

      end loop;
      close csr_psa_verp;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Log the event
      /*-*/
      lics_logging.write_log('--> Sending material audit report');

      /*-*/
      /* Create the new email and create the email text header part
      /*-*/
      lics_mailer.create_email('PSA_'||psa_parameter.system_unit||'_'||psa_parameter.system_environment,
                               var_report_email,
                               'PSA SAP Material Maintenance - Material Audit',
                               null,
                               null);
      lics_mailer.create_part(null);
      lics_mailer.append_data('PSA SAP Material Maintenance - Material Audit');
      lics_mailer.append_data(null);
      lics_mailer.append_data(null);
      lics_mailer.append_data(null);

      /*-*/
      /* Create the email file and output the header data
      /*-*/
      lics_mailer.create_part('PSA_SAP_Material_Audit.xls');
      lics_mailer.append_data('<head><meta http-equiv=Content-Type content="text/html; charset=utf-8"></head>');
      lics_mailer.append_data('<table border=1 cellpadding="0" cellspacing="0">');
      lics_mailer.append_data('<tr>');
      lics_mailer.append_data('<td align=center colspan=7 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">PSA - SAP Material Audit Report - '||to_char(sysdate,'yyyy/mm/dd hh24:mi')||'</td>');
      lics_mailer.append_data('</tr>');

      /*-*/
      /* Output the report header columns
      /*-*/
      lics_mailer.append_data('<tr>');
      lics_mailer.append_data('<td align=center style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Material Code</td>');
      lics_mailer.append_data('<td align=center style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">SAP Code</td>');
      lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Material Name</td>');
      lics_mailer.append_data('<td align=center style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Material Type</td>');
      lics_mailer.append_data('<td align=center style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Material Usage</td>');
      lics_mailer.append_data('<td align=center style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Material Status</td>');
      lics_mailer.append_data('<td align=center style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Status Date/Time</td>');
      lics_mailer.append_data('</tr>');

      /*-*/
      /* Generate the material audit report
      /*-*/
      open csr_material;
      loop
         fetch csr_material into rcd_material;
         if csr_material%notfound then
            exit;
         end if;

         /*-*/
         /* Output the report data
         /*-*/
         lics_mailer.append_data('<tr>');
         lics_mailer.append_data('<td align=center style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_material.mde_mat_code||'</td>');
         lics_mailer.append_data('<td align=center style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;mso-number-format:\@;">'||rcd_material.mde_sap_code||'</td>');
         lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_material.mde_mat_name||'</td>');
         lics_mailer.append_data('<td align=center style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_material.mde_mat_type||'</td>');
         lics_mailer.append_data('<td align=center style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_material.mde_mat_usage||'</td>');
         lics_mailer.append_data('<td align=center style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_material.mde_mat_status||'</td>');
         lics_mailer.append_data('<td align=center style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(rcd_material.mde_sys_date,'yyyy/mm/dd hh24:mi:Ss')||'</td>');
         lics_mailer.append_data('</tr>');

      end loop;
      close csr_material;

      /*-*/
      /* Output the email file part trailer data
      /*-*/
      lics_mailer.append_data('</table>');
      lics_mailer.create_part(null);
      lics_mailer.append_data(null);
      lics_mailer.append_data(null);
      lics_mailer.append_data(null);
      lics_mailer.append_data('** Email End **');
      lics_mailer.finalise_email('utf-8');

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - PSA SAP Material Maintenance');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

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
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Log error
         /*-*/
         if lics_logging.is_created = true then
            lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
            lics_logging.end_log;
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - PSA_MAT_FUNCTION - UPDATE_MASTER - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_master;

   /***************************************************/
   /* This procedure performs the select list routine */
   /***************************************************/
   function select_list return psa_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_str_code varchar2(32);
      var_end_code varchar2(32);
      var_output varchar2(2000 char);
      var_pag_size number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_slct is
         select t01.*
           from (select t01.mde_mat_code,
                        t01.mde_mat_name,
                        t01.mde_mat_status
                   from psa_mat_defn t01
                  where (var_str_code is null or t01.mde_mat_code >= var_str_code)
                  order by t01.mde_mat_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_next is
         select t01.*
           from (select t01.mde_mat_code,
                        t01.mde_mat_name,
                        t01.mde_mat_status
                   from psa_mat_defn t01
                  where ((var_action = '*NXTDEF' and (var_end_code is null or t01.mde_mat_code > var_end_code)) or
                         (var_action = '*PRVDEF'))
                  order by t01.mde_mat_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_prev is
         select t01.*
           from (select t01.mde_mat_code,
                        t01.mde_mat_name,
                        t01.mde_mat_status
                   from psa_mat_defn t01
                  where ((var_action = '*PRVDEF' and (var_str_code is null or t01.mde_mat_code < var_str_code)) or
                         (var_action = '*NXTDEF'))
                  order by t01.mde_mat_code desc) t01
          where rownum <= var_pag_size;

      /*-*/
      /* Local arrays
      /*-*/
      type typ_list is table of csr_slct%rowtype index by binary_integer;
      tbl_list typ_list;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Clear the message data
      /*-*/
      psa_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PSA_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_psa_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_psa_request,'@ACTION'));
      var_str_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@STRCDE')));
      var_end_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@ENDCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*SELDEF' and var_action != '*PRVDEF' and var_action != '*NXTDEF' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(psa_xml_object('<?xml version="1.0" encoding="UTF-8"?><PSA_RESPONSE>'));

      /*-*/
      /* Retrieve the material list and pipe the results
      /*-*/
      var_pag_size := 20;
      if var_action = '*SELDEF' then
         tbl_list.delete;
         open csr_slct;
         fetch csr_slct bulk collect into tbl_list;
         close csr_slct;
         for idx in 1..tbl_list.count loop
            pipe row(psa_xml_object('<LSTROW MATCDE="'||to_char(tbl_list(idx).mde_mat_code)||'" MATNAM="'||psa_to_xml(tbl_list(idx).mde_mat_name)||'" MATSTS="'||psa_to_xml(tbl_list(idx).mde_mat_status)||'"/>'));
         end loop;
      elsif var_action = '*NXTDEF' then
         tbl_list.delete;
         open csr_next;
         fetch csr_next bulk collect into tbl_list;
         close csr_next;
         if tbl_list.count = var_pag_size then
            for idx in 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW MATCDE="'||to_char(tbl_list(idx).mde_mat_code)||'" MATNAM="'||psa_to_xml(tbl_list(idx).mde_mat_name)||'" MATSTS="'||psa_to_xml(tbl_list(idx).mde_mat_status)||'"/>'));
            end loop;
         else
            open csr_prev;
            fetch csr_prev bulk collect into tbl_list;
            close csr_prev;
            for idx in reverse 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW MATCDE="'||to_char(tbl_list(idx).mde_mat_code)||'" MATNAM="'||psa_to_xml(tbl_list(idx).mde_mat_name)||'" MATSTS="'||psa_to_xml(tbl_list(idx).mde_mat_status)||'"/>'));
            end loop;
         end if;
      elsif var_action = '*PRVDEF' then
         tbl_list.delete;
         open csr_prev;
         fetch csr_prev bulk collect into tbl_list;
         close csr_prev;
         if tbl_list.count = var_pag_size then
            for idx in reverse 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW MATCDE="'||to_char(tbl_list(idx).mde_mat_code)||'" MATNAM="'||psa_to_xml(tbl_list(idx).mde_mat_name)||'" MATSTS="'||psa_to_xml(tbl_list(idx).mde_mat_status)||'"/>'));
            end loop;
         else
            open csr_next;
            fetch csr_next bulk collect into tbl_list;
            close csr_next;
            for idx in 1..tbl_list.count loop
               pipe row(psa_xml_object('<LSTROW MATCDE="'||to_char(tbl_list(idx).mde_mat_code)||'" MATNAM="'||psa_to_xml(tbl_list(idx).mde_mat_name)||'" MATSTS="'||psa_to_xml(tbl_list(idx).mde_mat_status)||'"/>'));
            end loop;
         end if;
      end if;

      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(psa_xml_object('</PSA_RESPONSE>'));

      /*-*/
      /* Return
      /*-*/
      return;

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_MAT_FUNCTION - SELECT_LIST - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_list;

   /*****************************************************/
   /* This procedure performs the retrieve data routine */
   /*****************************************************/
   function retrieve_data return psa_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_mat_code varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_mat_defn t01
          where t01.mde_mat_code = var_mat_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_type is
         select t01.*
           from psa_prd_type t01
          where t01.pty_prd_status = '1'
            and t01.pty_prd_mat_usage = '1'
          order by t01.pty_prd_type asc;
      rcd_type csr_type%rowtype;

      cursor csr_line is
         select t01.*
           from psa_lin_defn t01
          where t01.lde_lin_status = '1'
            and t01.lde_prd_type in (select pty_prd_type
                                       from psa_prd_type
                                      where pty_prd_mat_usage = '1'
                                        and pty_prd_lin_usage = '1'
                                        and pty_prd_status = '1')
          order by t01.lde_lin_code asc;
      rcd_line csr_line%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Clear the message data
      /*-*/
      psa_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PSA_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_psa_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_psa_request,'@ACTION'));
      var_mat_code := upper(psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@MATCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDDEF' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing material
      /*-*/
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         psa_gen_function.add_mesg_data('Material ('||var_mat_code||') does not exist');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(psa_xml_object('<?xml version="1.0" encoding="UTF-8"?><PSA_RESPONSE>'));

      /*-*/
      /* Pipe the material XML
      /*-*/
      var_output := '<MATDFN MATCDE="'||psa_to_xml(rcd_retrieve.mde_mat_code||' - (Last updated by '||rcd_retrieve.mde_upd_user||' on '||to_char(rcd_retrieve.mde_upd_date,'yyyy/mm/dd')||')')||'"';
      var_output := var_output||' MATNAM="'||psa_to_xml(rcd_retrieve.mde_mat_name)||'"';
      var_output := var_output||' MATTYP="'||psa_to_xml(rcd_retrieve.mde_mat_type)||'"';
      var_output := var_output||' MATUSG="'||psa_to_xml(rcd_retrieve.mde_mat_usage)||'"';
      var_output := var_output||' MATUOM="'||psa_to_xml(rcd_retrieve.mde_mat_uom)||'"';
      var_output := var_output||' MATGRW="'||psa_to_xml(to_char(rcd_retrieve.mde_gro_weight))||'"';
      var_output := var_output||' MATNEW="'||psa_to_xml(to_char(rcd_retrieve.mde_net_weight))||'"';
      var_output := var_output||' MATUNC="'||psa_to_xml(to_char(rcd_retrieve.mde_unt_case))||'"';
      var_output := var_output||' MATSLN="'||psa_to_xml(rcd_retrieve.mde_sap_line)||'"';
      var_output := var_output||' MATSTS="'||psa_to_xml(rcd_retrieve.mde_mat_status)||'"';
      var_output := var_output||' MATSYS="'||psa_to_xml(rcd_retrieve.mde_sys_user||' on '||to_char(rcd_retrieve.mde_sys_date,'yyyy/mm/dd'))||'"';
      var_output := var_output||' MATPTY="'||psa_to_xml(rcd_retrieve.mde_prd_type)||'"';
      var_output := var_output||' MATSPR="'||psa_to_xml(to_char(rcd_retrieve.mde_sch_priority))||'"';
      var_output := var_output||' MATLIN="'||psa_to_xml(rcd_retrieve.mde_dft_line)||'"';
      var_output := var_output||' MATCPL="'||psa_to_xml(to_char(rcd_retrieve.mde_cas_pallet))||'"';
      var_output := var_output||' MATBQY="'||psa_to_xml(to_char(rcd_retrieve.mde_bch_quantity))||'"';
      var_output := var_output||' MATYPC="'||psa_to_xml(to_char(rcd_retrieve.mde_yld_percent))||'"';
      var_output := var_output||' MATYVL="'||psa_to_xml(to_char(rcd_retrieve.mde_yld_value))||'"';
      var_output := var_output||' MATPPC="'||psa_to_xml(to_char(rcd_retrieve.mde_pck_percent))||'"';
      var_output := var_output||' MATPWE="'||psa_to_xml(to_char(rcd_retrieve.mde_pck_weight))||'"';
      var_output := var_output||' MATBWE="'||psa_to_xml(to_char(rcd_retrieve.mde_bch_weight))||'"/>';
      pipe row(psa_xml_object(var_output));

      /*-*/
      /* Pipe the type data XML
      /*-*/
      open csr_type;
      loop
         fetch csr_type into rcd_type;
         if csr_type%notfound then
            exit;
         end if;
         pipe row(psa_xml_object('<TYPDFN TYPCDE="'||psa_to_xml(rcd_type.pty_prd_type)||'" TYPNAM="'||psa_to_xml('('||rcd_type.pty_prd_type||') '||rcd_type.pty_prd_name)||'"/>'));
      end loop;
      close csr_type;

      /*-*/
      /* Pipe the line data XML
      /*-*/
      open csr_line;
      loop
         fetch csr_line into rcd_line;
         if csr_line%notfound then
            exit;
         end if;
         pipe row(psa_xml_object('<LINDFN LINCDE="'||psa_to_xml(rcd_line.lde_lin_code)||'" LINNAM="'||psa_to_xml('('||rcd_line.lde_lin_code||') '||rcd_line.lde_lin_name)||'"/>'));
      end loop;
      close csr_line;

      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(psa_xml_object('</PSA_RESPONSE>'));

      /*-*/
      /* Return
      /*-*/
      return;

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_MAT_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_data;

   /***************************************************/
   /* This procedure performs the update data routine */
   /***************************************************/
   procedure update_data(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      var_found boolean;
      rcd_psa_mat_defn psa_mat_defn%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_mat_defn t01
          where t01.mde_mat_code = rcd_psa_mat_defn.mde_mat_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_type is
         select t01.*
           from psa_prd_type t01
          where t01.pty_prd_type = rcd_psa_mat_defn.mde_prd_type;
      rcd_type csr_type%rowtype;

      cursor csr_line is
         select t01.*
           from psa_lin_defn t01
          where t01.lde_lin_code = rcd_psa_mat_defn.mde_dft_line;
      rcd_line csr_line%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the message data
      /*-*/
      psa_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PSA_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_psa_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_psa_request,'@ACTION'));
      if var_action != '*UPDDEF' and var_action != '*CRTDEF' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;
      rcd_psa_mat_defn.mde_mat_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@MATCDE'));
      rcd_psa_mat_defn.mde_mat_name := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@MATNAM'));
      rcd_psa_mat_defn.mde_mat_status := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@MATSTS'));
      rcd_psa_mat_defn.mde_upd_user := upper(par_user);
      rcd_psa_mat_defn.mde_upd_date := sysdate;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_psa_mat_defn.mde_mat_name is null then
         psa_gen_function.add_mesg_data('Material name must be supplied');
      end if;
      if rcd_psa_mat_defn.mde_mat_status is null or (rcd_psa_mat_defn.mde_mat_status != '0' and rcd_psa_mat_defn.mde_mat_status != '1') then
         psa_gen_function.add_mesg_data('Material status must be (0)inactive or (1)active');
      end if;
      if rcd_psa_mat_defn.mde_upd_user is null then
         psa_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the parent relationships
      /*-*/
      open csr_type;
      fetch csr_type into rcd_type;
      if csr_type%notfound then
         psa_gen_function.add_mesg_data('Production type code ('||rcd_psa_mat_defn.mde_prd_type||') does not exist');
      else
         if rcd_type.pty_prd_status != '1' then
            psa_gen_function.add_mesg_data('Production type code ('||rcd_psa_mat_defn.mde_prd_type||') status must be active');
         end if;
         if rcd_type.pty_prd_mat_usage != '1' then
            psa_gen_function.add_mesg_data('Production type code ('||rcd_psa_mat_defn.mde_prd_type||') must be flagged for material usage');
         end if;
      end if;
      close csr_type;

      open csr_line;
      fetch csr_line into rcd_line;
      if csr_line%notfound then
         psa_gen_function.add_mesg_data('Line code ('||rcd_psa_mat_defn.mde_dft_line||') does not exist');
      else
         if rcd_line.lde_lin_status != '1' then
            psa_gen_function.add_mesg_data('Line code ('||rcd_psa_mat_defn.mde_dft_line||') status must be active');
         end if;
      end if;
      close csr_line;

      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the material
      /*-*/
      var_confirm := 'updated';
      var_found := false;
      begin
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%found then
            var_found := true;
         end if;
         close csr_retrieve;
      exception
         when others then
            var_found := true;
            psa_gen_function.add_mesg_data('Material ('||rcd_psa_mat_defn.mde_mat_code||') is currently locked');
      end;
      if var_found = false then
         psa_gen_function.add_mesg_data('Material ('||rcd_psa_mat_defn.mde_mat_code||') does not exist');
      end if;
      if psa_gen_function.get_mesg_count = 0 then
         update psa_mat_defn
            set mde_mat_name = rcd_psa_mat_defn.mde_mat_name,
                mde_mat_status = rcd_psa_mat_defn.mde_mat_status,
                mde_upd_user = rcd_psa_mat_defn.mde_upd_user,
                mde_upd_date = rcd_psa_mat_defn.mde_upd_date
          where mde_mat_code = rcd_psa_mat_defn.mde_mat_code;
      else
         rollback;
         return;
      end if;

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Send the confirm message
      /*-*/
      psa_gen_function.set_cfrm_data('Material ('||rcd_psa_mat_defn.mde_mat_code||') successfully '||var_confirm);

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
         /* Raise an exception to the calling application
         /*-*/
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_MAT_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

   /*******************************************************/
   /* This procedure performs the inactivate data routine */
   /*******************************************************/
   procedure inactivate_data(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      var_found boolean;
      rcd_psa_mat_defn psa_mat_defn%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_mat_defn t01
          where t01.mde_mat_code = rcd_psa_mat_defn.mde_mat_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;


   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the message data
      /*-*/
      psa_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PSA_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_psa_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_psa_request,'@ACTION'));
      if var_action != '*DLTDEF' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;
      rcd_psa_mat_defn.mde_mat_code := psa_from_xml(xslProcessor.valueOf(obj_psa_request,'@MATCDE'));
      rcd_psa_mat_defn.mde_mat_status := '*INACTIVE';
      rcd_psa_mat_defn.mde_upd_user := upper(par_user);
      rcd_psa_mat_defn.mde_upd_date := sysdate;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_psa_mat_defn.mde_upd_user is null then
         psa_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the material
      /*-*/
      var_confirm := 'inactivated';
      var_found := false;
      begin
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%found then
            var_found := true;
         end if;
         close csr_retrieve;
      exception
         when others then
            var_found := true;
            psa_gen_function.add_mesg_data('Material ('||rcd_psa_mat_defn.mde_mat_code||') is currently locked');
      end;
      if var_found = false then
         psa_gen_function.add_mesg_data('Material ('||rcd_psa_mat_defn.mde_mat_code||') does not exist');
      end if;
      if psa_gen_function.get_mesg_count = 0 then
         update psa_mat_defn
            set mde_mat_status = rcd_psa_mat_defn.mde_mat_status,
                mde_upd_user = rcd_psa_mat_defn.mde_mat_status,
                mde_upd_date = rcd_psa_mat_defn.mde_upd_date
          where mde_mat_code = rcd_psa_mat_defn.mde_mat_code;
      else
         rollback;
         return;
      end if;

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Send the confirm message
      /*-*/
      psa_gen_function.set_cfrm_data('Material ('||rcd_psa_mat_defn.mde_mat_code||') successfully '||var_confirm);

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
         /* Raise an exception to the calling application
         /*-*/
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_MAT_FUNCTION - INACTIVATE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end inactivate_data;

end psa_mat_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym psa_mat_function for psa_app.psa_mat_function;
grant execute on psa_app.psa_mat_function to public;
