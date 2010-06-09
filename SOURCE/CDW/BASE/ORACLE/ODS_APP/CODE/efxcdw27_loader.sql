/******************/
/* Package Header */
/******************/
create or replace package ods_app.efxcdw27_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw27_loader
    Owner   : ods_app

    Description
    -----------
    Operational Data Store - Efex MRQ Task Data - EFEX to CDW

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/05   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end efxcdw27_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_app.efxcdw27_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure process_record_hdr(par_record in varchar2);
   procedure process_record_res(par_record in varchar2);
   procedure process_record_prc(par_record in varchar2);
   procedure process_record_nte(par_record in varchar2);
   procedure process_record_end(par_record in varchar2);
   procedure process_record_itm(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   rcd_efex_mrq_task efex_mrq_task%rowtype;
   rcd_efex_mrq_task_matl efex_mrq_task_matl%rowtype;

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the transaction variables
      /*-*/
      var_trn_error := false;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('HDR','RCD_ID',3);
      lics_inbound_utility.set_definition('HDR','TSK_ID',10);
      lics_inbound_utility.set_definition('HDR','MRQ_ID',10);
      lics_inbound_utility.set_definition('HDR','TSK_NAME',50);
      lics_inbound_utility.set_definition('HDR','JOB_TYPE',50);
      lics_inbound_utility.set_definition('HDR','DSP_TYPE',50);
      lics_inbound_utility.set_definition('HDR','SET_MINS',15);
      lics_inbound_utility.set_definition('HDR','ACT_MINS',15);
      lics_inbound_utility.set_definition('HDR','HR_RATE',15);
      lics_inbound_utility.set_definition('HDR','ACT_CASES',15);
      lics_inbound_utility.set_definition('HDR','STATUS',1);
      /*-*/
      lics_inbound_utility.set_definition('RES','RCD_ID',3);
      lics_inbound_utility.set_definition('RES','RES_TEXT',2000);
      /*-*/
      lics_inbound_utility.set_definition('PRC','RCD_ID',3);
      lics_inbound_utility.set_definition('PRC','PRC_TEXT',2000);
      /*-*/
      lics_inbound_utility.set_definition('NTE','RCD_ID',3);
      lics_inbound_utility.set_definition('NTE','NTE_TEXT',2000);
      /*-*/
      lics_inbound_utility.set_definition('END','RCD_ID',3);
      /*-*/
      lics_inbound_utility.set_definition('ITM','RCD_ID',3);
      lics_inbound_utility.set_definition('ITM','TSK_ID',10);
      lics_inbound_utility.set_definition('ITM','ITM_ID',10);
      lics_inbound_utility.set_definition('ITM','ITM_QTY',15);
      lics_inbound_utility.set_definition('ITM','SUPPLIER',50);
      lics_inbound_utility.set_definition('ITM','STATUS',1);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_start;

   /***********************************************/
   /* This procedure performs the on data routine */
   /***********************************************/
   procedure on_data(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_record_identifier varchar2(3);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the data based on record identifier
      /*-*/
      var_record_identifier := substr(par_record,1,3);
      case var_record_identifier
         when 'HDR' then process_record_hdr(par_record);
         when 'RES' then process_record_res(par_record);
         when 'PRC' then process_record_prc(par_record);
         when 'NTE' then process_record_nte(par_record);
         when 'END' then process_record_end(par_record);
         when 'ITM' then process_record_itm(par_record);
         else raise_application_error(-20000, 'Record identifier (' || var_record_identifier || ') not recognised');
      end case;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_data;

   /**********************************************/
   /* This procedure performs the on end routine */
   /**********************************************/
   procedure on_end is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Commit/rollback as required
      /*-*/
      if var_trn_error = true then
         rollback;
      else
         commit;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

   /**************************************************/
   /* This procedure performs the record HDR routine */
   /**************************************************/
   procedure process_record_hdr(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('HDR', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      rcd_efex_mrq_task.mrq_task_id := lics_inbound_utility.get_number('TSK_ID',null);
      rcd_efex_mrq_task.mrq_id := lics_inbound_utility.get_number('MRQ_ID',null);
      rcd_efex_mrq_task.mrq_task_name := lics_inbound_utility.get_variable('TSK_NAME');
      rcd_efex_mrq_task.job_type := lics_inbound_utility.get_variable('JOB_TYPE');
      rcd_efex_mrq_task.display_type := lics_inbound_utility.get_variable('DSP_TYPE');
      rcd_efex_mrq_task.setup_mins := lics_inbound_utility.get_number('SET_MINS',null);
      rcd_efex_mrq_task.actual_mins := lics_inbound_utility.get_number('ACT_MINS',null);
      rcd_efex_mrq_task.hr_rate := lics_inbound_utility.get_number('HR_RATE',null);
      rcd_efex_mrq_task.actual_cases := lics_inbound_utility.get_number('ACT_CASES',null);
      rcd_efex_mrq_task.compliance_rslt := null;
      rcd_efex_mrq_task.mrq_pricing := null;
      rcd_efex_mrq_task.mrq_task_notes := null;
      rcd_efex_mrq_task.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_mrq_task.valdtn_status := ods_constants.valdtn_unchecked;

      /*--------------------------------*/
      /* DELETE - Delete any child rows */
      /*--------------------------------*/

      delete from efex_mrq_task_matl where mrq_task_id = rcd_efex_mrq_task.mrq_task_id;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 1024));
         var_trn_error := true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

   /**************************************************/
   /* This procedure performs the record RES routine */
   /**************************************************/
   procedure process_record_res(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('RES', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      rcd_efex_mrq_task.compliance_rslt := rcd_efex_mrq_task.compliance_rslt || lics_inbound_utility.get_variable('RES_TEXT');

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 1024));
         var_trn_error := true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_res;

   /**************************************************/
   /* This procedure performs the record PRC routine */
   /**************************************************/
   procedure process_record_prc(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('PRC', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      rcd_efex_mrq_task.mrq_pricing := rcd_efex_mrq_task.mrq_pricing || lics_inbound_utility.get_variable('PRC_TEXT');

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 1024));
         var_trn_error := true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_prc;

   /**************************************************/
   /* This procedure performs the record NTE routine */
   /**************************************************/
   procedure process_record_nte(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('NTE', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      rcd_efex_mrq_task.mrq_task_notes := rcd_efex_mrq_task.mrq_task_notes || lics_inbound_utility.get_variable('NTE_TEXT');

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 1024));
         var_trn_error := true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_nte;

   /**************************************************/
   /* This procedure performs the record END routine */
   /**************************************************/
   procedure process_record_end(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('END', par_record);

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      begin
         insert into efex_mrq_task values rcd_efex_mrq_task;
      exception
         when dup_val_on_index then
            update efex_mrq_task
               set mrq_id = rcd_efex_mrq_task.mrq_id,
                   mrq_task_name = rcd_efex_mrq_task.mrq_task_name,
                   job_type = rcd_efex_mrq_task.job_type,
                   display_type = rcd_efex_mrq_task.display_type,
                   setup_mins = rcd_efex_mrq_task.setup_mins,
                   actual_mins = rcd_efex_mrq_task.actual_mins,
                   hr_rate = rcd_efex_mrq_task.hr_rate,
                   actual_cases = rcd_efex_mrq_task.actual_cases,
                   compliance_rslt = rcd_efex_mrq_task.compliance_rslt,
                   mrq_pricing = rcd_efex_mrq_task.mrq_pricing,
                   mrq_task_notes = rcd_efex_mrq_task.mrq_task_notes,
                   status = rcd_efex_mrq_task.status,
                   valdtn_status = rcd_efex_mrq_task.valdtn_status
             where mrq_task_id = rcd_efex_mrq_task.mrq_task_id;
      end;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 1024));
         var_trn_error := true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_end;

   /**************************************************/
   /* This procedure performs the record ITM routine */
   /**************************************************/
   procedure process_record_itm(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('ITM', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      rcd_efex_mrq_task_matl.mrq_task_id := lics_inbound_utility.get_number('TSK_ID',null);
      rcd_efex_mrq_task_matl.efex_matl_id := lics_inbound_utility.get_number('ITM_ID',null);
      rcd_efex_mrq_task_matl.matl_qty := lics_inbound_utility.get_number('ITM_QTY',null);
      rcd_efex_mrq_task_matl.supplier := lics_inbound_utility.get_variable('SUPPLIER');
      rcd_efex_mrq_task_matl.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_mrq_task_matl.valdtn_status := ods_constants.valdtn_unchecked;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      begin
         insert into efex_mrq_task_matl values rcd_efex_mrq_task_matl;
      exception
         when dup_val_on_index then
            update efex_mrq_task_matl
               set matl_qty = rcd_efex_mrq_task_matl.matl_qty,
                   supplier = rcd_efex_mrq_task_matl.supplier,
                   status = rcd_efex_mrq_task_matl.status,
                   valdtn_status = rcd_efex_mrq_task_matl.valdtn_status
             where mrq_task_id = rcd_efex_mrq_task_matl.mrq_task_id
               and efex_matl_id = rcd_efex_mrq_task_matl.efex_matl_id;
      end;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 1024));
         var_trn_error := true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_itm;

end efxcdw27_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw27_loader for ods_app.efxcdw27_loader;
grant execute on ods_app.efxcdw27_loader to lics_app;