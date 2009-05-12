/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : vds
 Package : vds_val_configuration
 Owner   : vds_app
 Author  : Steve Gregan

 DESCRIPTION
 -----------
  Validation Data Store - VDS Validation Configuration

 The package implements the validation configuration functionality.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package vds_val_configuration as

   /**/
   /* Public declarations
   /**/
   function retrieve_group return varchar2;
   function insert_group return varchar2;
   function update_group return varchar2;
   function delete_group return varchar2;
   function retrieve_rule return varchar2;
   function insert_rule return varchar2;
   function update_rule return varchar2;
   function delete_rule return varchar2;
   function retrieve_class return varchar2;
   function insert_class return varchar2;
   function update_class return varchar2;
   function delete_class return varchar2;
   function retrieve_type return varchar2;
   function insert_type return varchar2;
   function update_type return varchar2;
   function delete_type return varchar2;
   function retrieve_filter return varchar2;
   function insert_filter return varchar2;
   function update_filter return varchar2;
   function delete_filter return varchar2;
   function load_filter return varchar2;
   function retrieve_email return varchar2;
   function insert_email return varchar2;
   function update_email return varchar2;
   function delete_email return varchar2;

end vds_val_configuration;
/

/****************/
/* Package Body */
/****************/
create or replace package body vds_val_configuration as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   con_admin_code constant varchar2(30 char) := '*ADMINISTRATOR';

   /*-*/
   /* Private definitions
   /*-*/
   rcd_vds_val_grp vds_val_grp%rowtype;
   rcd_vds_val_rul vds_val_rul%rowtype;
   rcd_vds_val_cla vds_val_cla%rowtype;
   rcd_vds_val_cla_rul vds_val_cla_rul%rowtype;
   rcd_vds_val_typ vds_val_typ%rowtype;
   rcd_vds_val_typ_rul vds_val_typ_rul%rowtype;
   rcd_vds_val_fil vds_val_fil%rowtype;
   rcd_vds_val_fil_det vds_val_fil_det%rowtype;
   rcd_vds_val_ema vds_val_ema%rowtype;
   rcd_vds_val_ema_det vds_val_ema_det%rowtype;

   /*****************************************************/
   /* This function performs the retrieve group routine */
   /*****************************************************/
   function retrieve_group return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_val_grp_01 is 
         select *
           from vds_val_grp t01
          where t01.vag_group = rcd_vds_val_grp.vag_group;
      rcd_vds_val_grp_01 csr_vds_val_grp_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Validation Configuration - Retrieve Group';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_val_grp.vag_group := upper(lics_form.get_variable('VAG_GROUP'));

      /*-*/
      /* Group must exist
      /*-*/
      open csr_vds_val_grp_01;
      fetch csr_vds_val_grp_01 into rcd_vds_val_grp_01;
      if csr_vds_val_grp_01%notfound then
         var_message := var_message || chr(13) || 'Group (' || rcd_vds_val_grp.vag_group || ') does not exist';
      end if;
      close csr_vds_val_grp_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the form data
      /*-*/
      lics_form.clear_form;
      lics_form.set_value('VAG_GROUP',rcd_vds_val_grp_01.vag_group);
      lics_form.set_value('VAG_DESCRIPTION',rcd_vds_val_grp_01.vag_description);
      lics_form.set_value('VAG_COD_LENGTH',to_char(rcd_vds_val_grp_01.vag_cod_length));
      lics_form.set_clob('VAG_COD_QUERY',rcd_vds_val_grp_01.vag_cod_query);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_group;

   /***************************************************/
   /* This function performs the insert group routine */
   /***************************************************/
   function insert_group return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_val_grp_01 is 
         select *
           from vds_val_grp t01
          where t01.vag_group = rcd_vds_val_grp.vag_group;
      rcd_vds_val_grp_01 csr_vds_val_grp_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Validation Configuration - Insert Group';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_val_grp.vag_group := upper(lics_form.get_variable('VAG_GROUP'));
      rcd_vds_val_grp.vag_description := lics_form.get_variable('VAG_DESCRIPTION');
      rcd_vds_val_grp.vag_cod_length := lics_form.get_number('VAG_COD_LENGTH');
      rcd_vds_val_grp.vag_cod_query := lics_form.get_clob('VAG_COD_QUERY');

      /*-*/
      /* Validate the data values
      /*-*/
      if rcd_vds_val_grp.vag_group is null then
         var_message := var_message || chr(13) || 'Group must be specified';
      end if;
      if rcd_vds_val_grp.vag_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;
      if rcd_vds_val_grp.vag_cod_length < 0 or rcd_vds_val_grp.vag_cod_length > 30 then
         var_message := var_message || chr(13) || 'Code must be positive and not greater than 30';
      end if;
      if rcd_vds_val_grp.vag_cod_query is null then
         var_message := var_message || chr(13) || 'Code query be specified';
      end if;

      /*-*/
      /* Group must not already exist
      /*-*/
      open csr_vds_val_grp_01;
      fetch csr_vds_val_grp_01 into rcd_vds_val_grp_01;
      if csr_vds_val_grp_01%found then
         var_message := var_message || chr(13) || 'Group (' || rcd_vds_val_grp.vag_group || ') already exists';
      end if;
      close csr_vds_val_grp_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new group
      /*-*/
      insert into vds_val_grp
         (vag_group,
          vag_description,
          vag_cod_length,
          vag_cod_query)
         values(rcd_vds_val_grp.vag_group,
                rcd_vds_val_grp.vag_description,
                rcd_vds_val_grp.vag_cod_length,
                rcd_vds_val_grp.vag_cod_query);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end insert_group;

   /***************************************************/
   /* This function performs the update group routine */
   /***************************************************/
   function update_group return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_val_grp_01 is 
         select *
           from vds_val_grp t01
          where t01.vag_group = rcd_vds_val_grp.vag_group;
      rcd_vds_val_grp_01 csr_vds_val_grp_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Validation Configuration - Update Group';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_val_grp.vag_group := upper(lics_form.get_variable('VAG_GROUP'));
      rcd_vds_val_grp.vag_description := lics_form.get_variable('VAG_DESCRIPTION');
      rcd_vds_val_grp.vag_cod_length := lics_form.get_number('VAG_COD_LENGTH');
      rcd_vds_val_grp.vag_cod_query := lics_form.get_clob('VAG_COD_QUERY');

      /*-*/
      /* Validate the data values
      /*-*/
      if rcd_vds_val_grp.vag_group is null then
         var_message := var_message || chr(13) || 'Group must be specified';
      end if;
      if rcd_vds_val_grp.vag_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;
      if rcd_vds_val_grp.vag_cod_length < 0 or rcd_vds_val_grp.vag_cod_length > 30 then
         var_message := var_message || chr(13) || 'Code must be positive and not greater than 30';
      end if;
      if rcd_vds_val_grp.vag_cod_query is null then
         var_message := var_message || chr(13) || 'Code query be specified';
      end if;

      /*-*/
      /* Group must already exist
      /*-*/
      open csr_vds_val_grp_01;
      fetch csr_vds_val_grp_01 into rcd_vds_val_grp_01;
      if csr_vds_val_grp_01%notfound then
         var_message := var_message || chr(13) || 'Group (' || rcd_vds_val_grp.vag_group || ') does not exist';
      end if;
      close csr_vds_val_grp_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing group
      /*-*/
      update vds_val_grp
         set vag_description = rcd_vds_val_grp.vag_description,
             vag_cod_length = rcd_vds_val_grp.vag_cod_length,
             vag_cod_query = rcd_vds_val_grp.vag_cod_query
         where vag_group = rcd_vds_val_grp.vag_group;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_group;

   /***************************************************/
   /* This function performs the delete group routine */
   /***************************************************/
   function delete_group return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_val_grp_01 is 
         select *
           from vds_val_grp t01
          where t01.vag_group = rcd_vds_val_grp.vag_group;
      rcd_vds_val_grp_01 csr_vds_val_grp_01%rowtype;

      cursor csr_vds_val_rul_01 is 
         select *
           from vds_val_rul t01
          where t01.var_group = rcd_vds_val_grp.vag_group;
      rcd_vds_val_rul_01 csr_vds_val_rul_01%rowtype;

      cursor csr_vds_val_cla_01 is 
         select *
           from vds_val_cla t01
          where t01.vac_group = rcd_vds_val_grp.vag_group;
      rcd_vds_val_cla_01 csr_vds_val_cla_01%rowtype;

      cursor csr_vds_val_typ_01 is 
         select *
           from vds_val_typ t01
          where t01.vat_group = rcd_vds_val_grp.vag_group;
      rcd_vds_val_typ_01 csr_vds_val_typ_01%rowtype;

      cursor csr_vds_val_fil_01 is 
         select *
           from vds_val_fil t01
          where t01.vaf_group = rcd_vds_val_grp.vag_group;
      rcd_vds_val_fil_01 csr_vds_val_fil_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Validation Configuration - Delete Group';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_val_grp.vag_group := upper(lics_form.get_variable('VAG_GROUP'));

      /*-*/
      /* Group must already exist
      /*-*/
      open csr_vds_val_grp_01;
      fetch csr_vds_val_grp_01 into rcd_vds_val_grp_01;
      if csr_vds_val_grp_01%notfound then
         var_message := var_message || chr(13) || 'Group (' || rcd_vds_val_grp.vag_group || ') does not exist';
      end if;
      close csr_vds_val_grp_01;

      /*-*/
      /* Rules must not exist for group
      /*-*/
      open csr_vds_val_rul_01;
      fetch csr_vds_val_rul_01 into rcd_vds_val_rul_01;
      if csr_vds_val_rul_01%found then
         var_message := var_message || chr(13) || 'Group (' || rcd_vds_val_grp.vag_group || ') has rules attached - unable to delete';
      end if;
      close csr_vds_val_rul_01;

      /*-*/
      /* Classifications must not exist for group
      /*-*/
      open csr_vds_val_cla_01;
      fetch csr_vds_val_cla_01 into rcd_vds_val_cla_01;
      if csr_vds_val_cla_01%found then
         var_message := var_message || chr(13) || 'Group (' || rcd_vds_val_grp.vag_group || ') has classifications attached - unable to delete';
      end if;
      close csr_vds_val_cla_01;

      /*-*/
      /* Types must not exist for group
      /*-*/
      open csr_vds_val_typ_01;
      fetch csr_vds_val_typ_01 into rcd_vds_val_typ_01;
      if csr_vds_val_typ_01%found then
         var_message := var_message || chr(13) || 'Group (' || rcd_vds_val_grp.vag_group || ') has types attached - unable to delete';
      end if;
      close csr_vds_val_typ_01;

      /*-*/
      /* Filters must not exist for group
      /*-*/
      open csr_vds_val_fil_01;
      fetch csr_vds_val_fil_01 into rcd_vds_val_fil_01;
      if csr_vds_val_fil_01%found then
         var_message := var_message || chr(13) || 'Group (' || rcd_vds_val_grp.vag_group || ') has filters attached - unable to delete';
      end if;
      close csr_vds_val_fil_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing group data
      /*-*/
      delete from vds_val_ema_det where ved_group = rcd_vds_val_grp.vag_group;
      delete from vds_val_mes_ema where (vme_execution, vme_code, vme_class, vme_sequence) in (select vam_execution, vam_code, vam_class, vam_sequence from vds_val_mes where vam_group = rcd_vds_val_grp.vag_group);
      delete from vds_val_mes where vam_group = rcd_vds_val_grp.vag_group;
      delete from vds_val_grp where vag_group = rcd_vds_val_grp.vag_group;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_group;

   /****************************************************/
   /* This function performs the retrieve rule routine */
   /****************************************************/
   function retrieve_rule return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_val_rul_01 is 
         select *
           from vds_val_rul t01
          where t01.var_rule = rcd_vds_val_rul.var_rule;
      rcd_vds_val_rul_01 csr_vds_val_rul_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Validation Configuration - Retrieve Rule';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_val_rul.var_rule := upper(lics_form.get_variable('VAR_RULE'));

      /*-*/
      /* Rule must exist
      /*-*/
      open csr_vds_val_rul_01;
      fetch csr_vds_val_rul_01 into rcd_vds_val_rul_01;
      if csr_vds_val_rul_01%notfound then
         var_message := var_message || chr(13) || 'Rule (' || rcd_vds_val_rul.var_rule || ') does not exist';
      end if;
      close csr_vds_val_rul_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the form data
      /*-*/
      lics_form.clear_form;
      lics_form.set_value('VAR_RULE',rcd_vds_val_rul_01.var_rule);
      lics_form.set_value('VAR_DESCRIPTION',rcd_vds_val_rul_01.var_description);
      lics_form.set_value('VAR_GROUP',rcd_vds_val_rul_01.var_group);
      lics_form.set_clob('VAR_QUERY',rcd_vds_val_rul_01.var_query);
      lics_form.set_value('VAR_TEST',rcd_vds_val_rul_01.var_test);
      lics_form.set_value('VAR_MESSAGE',rcd_vds_val_rul_01.var_message);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_rule;

   /**************************************************/
   /* This function performs the insert rule routine */
   /**************************************************/
   function insert_rule return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_val_rul_01 is 
         select *
           from vds_val_rul t01
          where t01.var_rule = rcd_vds_val_rul.var_rule;
      rcd_vds_val_rul_01 csr_vds_val_rul_01%rowtype;

      cursor csr_vds_val_grp_01 is 
         select *
           from vds_val_grp t01
          where t01.vag_group = rcd_vds_val_rul.var_group;
      rcd_vds_val_grp_01 csr_vds_val_grp_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Validation Configuration - Insert Rule';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_val_rul.var_rule := upper(lics_form.get_variable('VAR_RULE'));
      rcd_vds_val_rul.var_description := lics_form.get_variable('VAR_DESCRIPTION');
      rcd_vds_val_rul.var_group := upper(lics_form.get_variable('VAR_GROUP'));
      rcd_vds_val_rul.var_query := lics_form.get_clob('VAR_QUERY');
      rcd_vds_val_rul.var_test := lics_form.get_variable('VAR_TEST');
      rcd_vds_val_rul.var_message := lics_form.get_variable('VAR_MESSAGE');

      /*-*/
      /* Validate the data values
      /*-*/
      if rcd_vds_val_rul.var_rule is null then
         var_message := var_message || chr(13) || 'Rule must be specified';
      end if;
      if rcd_vds_val_rul.var_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;
      if rcd_vds_val_rul.var_group is null then
         var_message := var_message || chr(13) || 'Group must be specified';
      end if;
      if rcd_vds_val_rul.var_query is null then
         var_message := var_message || chr(13) || 'Query be specified';
      end if;
      if rcd_vds_val_rul.var_test != '*FIRST_ROW' and
         rcd_vds_val_rul.var_test != '*EACH_ROW' and
         rcd_vds_val_rul.var_test != '*LAST_ROW' and
         rcd_vds_val_rul.var_test != '*ANY_ROWS' and
         rcd_vds_val_rul.var_test != '*NO_ROWS' then
         var_message := var_message || chr(13) || 'Test must be *FIRST_ROW, *EACH_ROW, *LAST_ROW, *ANY_ROWS or *NO_ROWS';
      end if;
      if rcd_vds_val_rul.var_test = '*ANY_ROWS' or
         rcd_vds_val_rul.var_test = '*NO_ROWS' then
         if rcd_vds_val_rul.var_message is null or rcd_vds_val_rul.var_message = '*NONE' then
            var_message := var_message || chr(13) || 'Static message must be specified for tests *ANY_ROWS and *NO_ROWS';
         end if;
      else
         if rcd_vds_val_rul.var_message != '*NONE' then
            var_message := var_message || chr(13) || 'Static message must be *NONE for tests *FIRST_ROW, *EACH_ROW and *LAST_ROW';
         end if;
      end if;

      /*-*/
      /* Rule must not already exist
      /*-*/
      open csr_vds_val_rul_01;
      fetch csr_vds_val_rul_01 into rcd_vds_val_rul_01;
      if csr_vds_val_rul_01%found then
         var_message := var_message || chr(13) || 'Rule (' || rcd_vds_val_rul.var_rule || ') already exists';
      end if;
      close csr_vds_val_rul_01;

      /*-*/
      /* Group must exist
      /*-*/
      open csr_vds_val_grp_01;
      fetch csr_vds_val_grp_01 into rcd_vds_val_grp_01;
      if csr_vds_val_grp_01%notfound then
         var_message := var_message || chr(13) || 'Group (' || rcd_vds_val_rul.var_group || ') does not exist';
      end if;
      close csr_vds_val_grp_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new rule
      /*-*/
      insert into vds_val_rul
         (var_rule,
          var_description,
          var_group,
          var_query,
          var_test,
          var_message)
         values(rcd_vds_val_rul.var_rule,
                rcd_vds_val_rul.var_description,
                rcd_vds_val_rul.var_group,
                rcd_vds_val_rul.var_query,
                rcd_vds_val_rul.var_test,
                rcd_vds_val_rul.var_message);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end insert_rule;

   /**************************************************/
   /* This function performs the update rule routine */
   /**************************************************/
   function update_rule return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_val_rul_01 is 
         select *
           from vds_val_rul t01
          where t01.var_rule = rcd_vds_val_rul.var_rule;
      rcd_vds_val_rul_01 csr_vds_val_rul_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Validation Configuration - Update Rule';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_val_rul.var_rule := upper(lics_form.get_variable('VAR_RULE'));
      rcd_vds_val_rul.var_description := lics_form.get_variable('VAR_DESCRIPTION');
      rcd_vds_val_rul.var_query := lics_form.get_clob('VAR_QUERY');
      rcd_vds_val_rul.var_test := lics_form.get_variable('VAR_TEST');
      rcd_vds_val_rul.var_message := lics_form.get_variable('VAR_MESSAGE');

      /*-*/
      /* Validate the data values
      /*-*/
      if rcd_vds_val_rul.var_rule is null then
         var_message := var_message || chr(13) || 'Rule must be specified';
      end if;
      if rcd_vds_val_rul.var_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;
      if rcd_vds_val_rul.var_query is null then
         var_message := var_message || chr(13) || 'Query be specified';
      end if;
      if rcd_vds_val_rul.var_test != '*FIRST_ROW' and
         rcd_vds_val_rul.var_test != '*EACH_ROW' and
         rcd_vds_val_rul.var_test != '*LAST_ROW' and
         rcd_vds_val_rul.var_test != '*ANY_ROWS' and
         rcd_vds_val_rul.var_test != '*NO_ROWS' then
         var_message := var_message || chr(13) || 'Test must be *FIRST_ROW, *EACH_ROW, *LAST_ROW, *ANY_ROWS or *NO_ROWS';
      end if;
      if rcd_vds_val_rul.var_test = '*ANY_ROWS' or
         rcd_vds_val_rul.var_test = '*NO_ROWS' then
         if rcd_vds_val_rul.var_message is null or rcd_vds_val_rul.var_message = '*NONE' then
            var_message := var_message || chr(13) || 'Static message must be specified for tests *ANY_ROWS and *NO_ROWS';
         end if;
      else
         if rcd_vds_val_rul.var_message != '*NONE' then
            var_message := var_message || chr(13) || 'Static message must be *NONE for tests *FIRST_ROW, *EACH_ROW and *LAST_ROW';
         end if;
      end if;

      /*-*/
      /* Rule must already exist
      /*-*/
      open csr_vds_val_rul_01;
      fetch csr_vds_val_rul_01 into rcd_vds_val_rul_01;
      if csr_vds_val_rul_01%notfound then
         var_message := var_message || chr(13) || 'Rule (' || rcd_vds_val_rul.var_rule || ') does not exist';
      end if;
      close csr_vds_val_rul_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing rule
      /*-*/
      update vds_val_rul
         set var_description = rcd_vds_val_rul.var_description,
             var_query = rcd_vds_val_rul.var_query,
             var_test = rcd_vds_val_rul.var_test,
             var_message = rcd_vds_val_rul.var_message
         where var_rule = rcd_vds_val_rul.var_rule;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_rule;

   /**************************************************/
   /* This function performs the delete rule routine */
   /**************************************************/
   function delete_rule return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_val_rul_01 is 
         select *
           from vds_val_rul t01
          where t01.var_rule = rcd_vds_val_rul.var_rule;
      rcd_vds_val_rul_01 csr_vds_val_rul_01%rowtype;

      cursor csr_vds_val_cla_rul_01 is 
         select *
           from vds_val_cla_rul t01
          where t01.vcr_rule = rcd_vds_val_rul.var_rule;
      rcd_vds_val_cla_rul_01 csr_vds_val_cla_rul_01%rowtype;

      cursor csr_vds_val_typ_rul_01 is 
         select *
           from vds_val_typ_rul t01
          where t01.vtr_rule = rcd_vds_val_rul.var_rule;
      rcd_vds_val_typ_rul_01 csr_vds_val_typ_rul_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Validation Configuration - Delete Rule';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_val_rul.var_rule := upper(lics_form.get_variable('VAR_RULE'));

      /*-*/
      /* Rule must already exist
      /*-*/
      open csr_vds_val_rul_01;
      fetch csr_vds_val_rul_01 into rcd_vds_val_rul_01;
      if csr_vds_val_rul_01%notfound then
         var_message := var_message || chr(13) || 'Rule (' || rcd_vds_val_rul.var_rule || ') does not exist';
      end if;
      close csr_vds_val_rul_01;

      /*-*/
      /* Classification rule must not exist for rule
      /*-*/
      open csr_vds_val_cla_rul_01;
      fetch csr_vds_val_cla_rul_01 into rcd_vds_val_cla_rul_01;
      if csr_vds_val_cla_rul_01%found then
         var_message := var_message || chr(13) || 'Rule (' || rcd_vds_val_rul.var_rule || ') has classifications attached - unable to delete';
      end if;
      close csr_vds_val_cla_rul_01;

      /*-*/
      /* Type rule must not exist for rule
      /*-*/
      open csr_vds_val_typ_rul_01;
      fetch csr_vds_val_typ_rul_01 into rcd_vds_val_typ_rul_01;
      if csr_vds_val_typ_rul_01%found then
         var_message := var_message || chr(13) || 'Rule (' || rcd_vds_val_rul.var_rule || ') has types attached - unable to delete';
      end if;
      close csr_vds_val_typ_rul_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing rule data
      /*-*/
      delete from vds_val_ema_det where ved_rule = rcd_vds_val_rul.var_rule;
      delete from vds_val_mes_ema where (vme_execution, vme_code, vme_class, vme_sequence) in (select vam_execution, vam_code, vam_class, vam_sequence from vds_val_mes where vam_rule = rcd_vds_val_rul.var_rule);
      delete from vds_val_mes where vam_rule = rcd_vds_val_rul.var_rule;
      delete from vds_val_rul where var_rule = rcd_vds_val_rul.var_rule;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_rule;

   /**************************************************************/
   /* This function performs the retrieve classification routine */
   /**************************************************************/
   function retrieve_class return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_val_cla_01 is 
         select *
           from vds_val_cla t01
          where t01.vac_class = rcd_vds_val_cla.vac_class;
      rcd_vds_val_cla_01 csr_vds_val_cla_01%rowtype;

      cursor csr_vds_val_cla_rul_01 is 
         select *
           from vds_val_cla_rul t01,
                vds_val_rul t02
          where t01.vcr_rule = t02.var_rule(+)
            and t01.vcr_class = rcd_vds_val_cla.vac_class
          order by t01.vcr_sequence asc;
      rcd_vds_val_cla_rul_01 csr_vds_val_cla_rul_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Validation Configuration - Retrieve Classification';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_val_cla.vac_class := upper(lics_form.get_variable('VAC_CLASS'));

      /*-*/
      /* Classification must exist
      /*-*/
      open csr_vds_val_cla_01;
      fetch csr_vds_val_cla_01 into rcd_vds_val_cla_01;
      if csr_vds_val_cla_01%notfound then
         var_message := var_message || chr(13) || 'Classification (' || rcd_vds_val_cla.vac_class || ') does not exist';
      end if;
      close csr_vds_val_cla_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the form data
      /*-*/
      lics_form.clear_form;
      lics_form.set_value('VAC_CLASS',rcd_vds_val_cla_01.vac_class);
      lics_form.set_value('VAC_DESCRIPTION',rcd_vds_val_cla_01.vac_description);
      lics_form.set_value('VAC_GROUP',rcd_vds_val_cla_01.vac_group);
      lics_form.set_clob('VAC_LST_QUERY',rcd_vds_val_cla_01.vac_lst_query);
      lics_form.set_clob('VAC_ONE_QUERY',rcd_vds_val_cla_01.vac_one_query);
      lics_form.set_value('VAC_EXE_BATCH',rcd_vds_val_cla_01.vac_exe_batch);
      open csr_vds_val_cla_rul_01;
      loop
         fetch csr_vds_val_cla_rul_01 into rcd_vds_val_cla_rul_01;
         if csr_vds_val_cla_rul_01%notfound then
            exit;
         end if;
         lics_form.set_value('VCR_RULE',rcd_vds_val_cla_rul_01.vcr_rule);
      end loop;
      close csr_vds_val_cla_rul_01;
      open csr_vds_val_cla_rul_01;
      loop
         fetch csr_vds_val_cla_rul_01 into rcd_vds_val_cla_rul_01;
         if csr_vds_val_cla_rul_01%notfound then
            exit;
         end if;
         lics_form.set_value('VCR_DESCRIPTION','(' || rcd_vds_val_cla_rul_01.vcr_rule || ') ' || rcd_vds_val_cla_rul_01.var_description);
      end loop;
      close csr_vds_val_cla_rul_01;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_class;

   /************************************************************/
   /* This function performs the insert classification routine */
   /************************************************************/
   function insert_class return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_val_cla_01 is 
         select *
           from vds_val_cla t01
          where t01.vac_class = rcd_vds_val_cla.vac_class;
      rcd_vds_val_cla_01 csr_vds_val_cla_01%rowtype;

      cursor csr_vds_val_grp_01 is 
         select *
           from vds_val_grp t01
          where t01.vag_group = rcd_vds_val_cla.vac_group;
      rcd_vds_val_grp_01 csr_vds_val_grp_01%rowtype;

      cursor csr_vds_val_rul_01 is 
         select *
           from vds_val_rul t01
          where t01.var_rule = rcd_vds_val_cla_rul.vcr_rule;
      rcd_vds_val_rul_01 csr_vds_val_rul_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Validation Configuration - Insert Classification';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_val_cla.vac_class := upper(lics_form.get_variable('VAC_CLASS'));
      rcd_vds_val_cla.vac_description := lics_form.get_variable('VAC_DESCRIPTION');
      rcd_vds_val_cla.vac_group := upper(lics_form.get_variable('VAC_GROUP'));
      rcd_vds_val_cla.vac_lst_query := lics_form.get_clob('VAC_LST_QUERY');
      rcd_vds_val_cla.vac_one_query := lics_form.get_clob('VAC_ONE_QUERY');
      rcd_vds_val_cla.vac_exe_batch := upper(lics_form.get_variable('VAC_EXE_BATCH'));

      /*-*/
      /* Validate the data values
      /*-*/
      if rcd_vds_val_cla.vac_class is null then
         var_message := var_message || chr(13) || 'Classification must be specified';
      end if;
      if rcd_vds_val_cla.vac_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;
      if rcd_vds_val_cla.vac_group is null then
         var_message := var_message || chr(13) || 'Group must be specified';
      end if;
      if rcd_vds_val_cla.vac_lst_query is null then
         var_message := var_message || chr(13) || 'List query be specified';
      end if;
      if rcd_vds_val_cla.vac_one_query is null then
         var_message := var_message || chr(13) || 'Single query be specified';
      end if;
      if rcd_vds_val_cla.vac_exe_batch != 'Y' and rcd_vds_val_cla.vac_exe_batch != 'N' then
         var_message := var_message || chr(13) || 'Batch validation must be Y or N';
      end if;

      /*-*/
      /* Classification must not already exist
      /*-*/
      open csr_vds_val_cla_01;
      fetch csr_vds_val_cla_01 into rcd_vds_val_cla_01;
      if csr_vds_val_cla_01%found then
         var_message := var_message || chr(13) || 'Classification (' || rcd_vds_val_cla.vac_class || ') already exists';
      end if;
      close csr_vds_val_cla_01;

      /*-*/
      /* Group must exist
      /*-*/
      open csr_vds_val_grp_01;
      fetch csr_vds_val_grp_01 into rcd_vds_val_grp_01;
      if csr_vds_val_grp_01%notfound then
         var_message := var_message || chr(13) || 'Group (' || rcd_vds_val_cla.vac_group || ') does not exist';
      end if;
      close csr_vds_val_grp_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new classification
      /*-*/
      insert into vds_val_cla
         (vac_class,
          vac_description,
          vac_group,
          vac_lst_query,
          vac_one_query,
          vac_exe_batch)
         values(rcd_vds_val_cla.vac_class,
                rcd_vds_val_cla.vac_description,
                rcd_vds_val_cla.vac_group,
                rcd_vds_val_cla.vac_lst_query,
                rcd_vds_val_cla.vac_one_query,
                rcd_vds_val_cla.vac_exe_batch);

      /*-*/
      /* Process the classification rules
      /*-*/
      rcd_vds_val_cla_rul.vcr_class := rcd_vds_val_cla.vac_class;
      rcd_vds_val_cla_rul.vcr_sequence := 0;
      for idx in 1..to_number(lics_form.get_array_count('VCR_RULE')) loop

         /*-*/
         /* Set the data variables
         /**/
         rcd_vds_val_cla_rul.vcr_rule := upper(lics_form.get_array('VCR_RULE',idx));
         rcd_vds_val_cla_rul.vcr_sequence := rcd_vds_val_cla_rul.vcr_sequence + 1;

         /*-*/
         /* Validate the data values
         /*-*/
         if rcd_vds_val_cla_rul.vcr_rule is null then
            var_message := var_message || chr(13) || 'Rule must be specified';
         end if;

         /*-*/
         /* Rule must exist
         /*-*/
         open csr_vds_val_rul_01;
         fetch csr_vds_val_rul_01 into rcd_vds_val_rul_01;
         if csr_vds_val_rul_01%notfound then
            var_message := var_message || chr(13) || 'Rule (' || rcd_vds_val_cla_rul.vcr_rule || ') does not exist';
         else
            if rcd_vds_val_cla.vac_group != rcd_vds_val_rul_01.var_group then
               var_message := var_message || chr(13) || 'Rule (' || rcd_vds_val_cla_rul.vcr_rule || ') - classification and rule groups must be the same';
            end if;
         end if;
         close csr_vds_val_rul_01;

         /*-*/
         /* Create the new classification rule
         /*-*/
         insert into vds_val_cla_rul
            (vcr_class,
             vcr_rule,
             vcr_sequence)
            values(rcd_vds_val_cla_rul.vcr_class,
                   rcd_vds_val_cla_rul.vcr_rule,
                   rcd_vds_val_cla_rul.vcr_sequence);

      end loop;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end insert_class;

   /************************************************************/
   /* This function performs the update classification routine */
   /************************************************************/
   function update_class return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_val_cla_01 is 
         select *
           from vds_val_cla t01
          where t01.vac_class = rcd_vds_val_cla.vac_class;
      rcd_vds_val_cla_01 csr_vds_val_cla_01%rowtype;

      cursor csr_vds_val_rul_01 is 
         select *
           from vds_val_rul t01
          where t01.var_rule = rcd_vds_val_cla_rul.vcr_rule;
      rcd_vds_val_rul_01 csr_vds_val_rul_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Validation Configuration - Update Classification';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_val_cla.vac_class := upper(lics_form.get_variable('VAC_CLASS'));
      rcd_vds_val_cla.vac_description := lics_form.get_variable('VAC_DESCRIPTION');
      rcd_vds_val_cla.vac_lst_query := lics_form.get_clob('VAC_LST_QUERY');
      rcd_vds_val_cla.vac_one_query := lics_form.get_clob('VAC_ONE_QUERY');
      rcd_vds_val_cla.vac_exe_batch := upper(lics_form.get_variable('VAC_EXE_BATCH'));

      /*-*/
      /* Validate the data values
      /*-*/
      if rcd_vds_val_cla.vac_class is null then
         var_message := var_message || chr(13) || 'Classification must be specified';
      end if;
      if rcd_vds_val_cla.vac_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;
      if rcd_vds_val_cla.vac_lst_query is null then
         var_message := var_message || chr(13) || 'List query be specified';
      end if;
      if rcd_vds_val_cla.vac_one_query is null then
         var_message := var_message || chr(13) || 'Single query be specified';
      end if;
      if rcd_vds_val_cla.vac_exe_batch != 'Y' and rcd_vds_val_cla.vac_exe_batch != 'N' then
         var_message := var_message || chr(13) || 'Batch validation must be Y or N';
      end if;

      /*-*/
      /* Classification must already exist
      /*-*/
      open csr_vds_val_cla_01;
      fetch csr_vds_val_cla_01 into rcd_vds_val_cla_01;
      if csr_vds_val_cla_01%notfound then
         var_message := var_message || chr(13) || 'Classification (' || rcd_vds_val_cla.vac_class || ') does not exist';
      end if;
      close csr_vds_val_cla_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing classification
      /*-*/
      update vds_val_cla
         set vac_description = rcd_vds_val_cla.vac_description,
             vac_lst_query = rcd_vds_val_cla.vac_lst_query,
             vac_one_query = rcd_vds_val_cla.vac_one_query,
             vac_exe_batch = rcd_vds_val_cla.vac_exe_batch
         where vac_class = rcd_vds_val_cla.vac_class;

      /*-*/
      /* Process the classification rules
      /*-*/
      delete from vds_val_cla_rul where vcr_class = rcd_vds_val_cla.vac_class;
      rcd_vds_val_cla_rul.vcr_class := rcd_vds_val_cla.vac_class;
      rcd_vds_val_cla_rul.vcr_sequence := 0;
      for idx in 1..to_number(lics_form.get_array_count('VCR_RULE')) loop

         /*-*/
         /* Set the data variables
         /**/
         rcd_vds_val_cla_rul.vcr_rule := upper(lics_form.get_array('VCR_RULE',idx));
         rcd_vds_val_cla_rul.vcr_sequence := rcd_vds_val_cla_rul.vcr_sequence + 1;

         /*-*/
         /* Validate the data values
         /*-*/
         if rcd_vds_val_cla_rul.vcr_rule is null then
            var_message := var_message || chr(13) || 'Rule must be specified';
         end if;

         /*-*/
         /* Rule must exist
         /*-*/
         open csr_vds_val_rul_01;
         fetch csr_vds_val_rul_01 into rcd_vds_val_rul_01;
         if csr_vds_val_rul_01%notfound then
            var_message := var_message || chr(13) || 'Rule (' || rcd_vds_val_cla_rul.vcr_rule || ') does not exist';
         else
            if rcd_vds_val_cla_01.vac_group != rcd_vds_val_rul_01.var_group then
               var_message := var_message || chr(13) || 'Rule (' || rcd_vds_val_cla_rul.vcr_rule || ') - classification and rule groups must be the same';
            end if;
         end if;
         close csr_vds_val_rul_01;

         /*-*/
         /* Create the new classification rule
         /*-*/
         insert into vds_val_cla_rul
            (vcr_class,
             vcr_rule,
             vcr_sequence)
            values(rcd_vds_val_cla_rul.vcr_class,
                   rcd_vds_val_cla_rul.vcr_rule,
                   rcd_vds_val_cla_rul.vcr_sequence);

      end loop;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_class;

   /************************************************************/
   /* This function performs the delete classification routine */
   /************************************************************/
   function delete_class return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_val_cla_01 is 
         select *
           from vds_val_cla t01
          where t01.vac_class = rcd_vds_val_cla.vac_class;
      rcd_vds_val_cla_01 csr_vds_val_cla_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Validation Configuration - Delete Classification';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_val_cla.vac_class := upper(lics_form.get_variable('VAC_CLASS'));

      /*-*/
      /* Classification must already exist
      /*-*/
      open csr_vds_val_cla_01;
      fetch csr_vds_val_cla_01 into rcd_vds_val_cla_01;
      if csr_vds_val_cla_01%notfound then
         var_message := var_message || chr(13) || 'Classification (' || rcd_vds_val_cla.vac_class || ') does not exist';
      end if;
      close csr_vds_val_cla_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing classification data
      /*-*/
      delete from vds_val_ema_det where ved_class = rcd_vds_val_cla.vac_class;
      delete from vds_val_mes_ema where (vme_execution, vme_code, vme_class, vme_sequence) in (select vam_execution, vam_code, vam_class, vam_sequence from vds_val_mes where vam_class = rcd_vds_val_cla.vac_class);
      delete from vds_val_mes where vam_class = rcd_vds_val_cla.vac_class;
      delete from vds_val_cla_rul where vcr_class = rcd_vds_val_cla.vac_class;
      delete from vds_val_cla where vac_class = rcd_vds_val_cla.vac_class;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_class;

   /****************************************************/
   /* This function performs the retrieve type routine */
   /****************************************************/
   function retrieve_type return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_val_typ_01 is 
         select *
           from vds_val_typ t01
          where t01.vat_type = rcd_vds_val_typ.vat_type;
      rcd_vds_val_typ_01 csr_vds_val_typ_01%rowtype;

      cursor csr_vds_val_typ_rul_01 is 
         select *
           from vds_val_typ_rul t01,
                vds_val_rul t02
          where t01.vtr_rule = t02.var_rule(+)
            and t01.vtr_type = rcd_vds_val_typ.vat_type
          order by t01.vtr_sequence asc;
      rcd_vds_val_typ_rul_01 csr_vds_val_typ_rul_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Validation Configuration - Retrieve Type';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_val_typ.vat_type := upper(lics_form.get_variable('VAT_TYPE'));

      /*-*/
      /* Type must exist
      /*-*/
      open csr_vds_val_typ_01;
      fetch csr_vds_val_typ_01 into rcd_vds_val_typ_01;
      if csr_vds_val_typ_01%notfound then
         var_message := var_message || chr(13) || 'Type (' || rcd_vds_val_typ.vat_type || ') does not exist';
      end if;
      close csr_vds_val_typ_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the form data
      /*-*/
      lics_form.clear_form;
      lics_form.set_value('VAT_TYPE',rcd_vds_val_typ_01.vat_type);
      lics_form.set_value('VAT_DESCRIPTION',rcd_vds_val_typ_01.vat_description);
      lics_form.set_value('VAT_GROUP',rcd_vds_val_typ_01.vat_group);
      open csr_vds_val_typ_rul_01;
      loop
         fetch csr_vds_val_typ_rul_01 into rcd_vds_val_typ_rul_01;
         if csr_vds_val_typ_rul_01%notfound then
            exit;
         end if;
         lics_form.set_value('VTR_RULE',rcd_vds_val_typ_rul_01.vtr_rule);
      end loop;
      close csr_vds_val_typ_rul_01;
      open csr_vds_val_typ_rul_01;
      loop
         fetch csr_vds_val_typ_rul_01 into rcd_vds_val_typ_rul_01;
         if csr_vds_val_typ_rul_01%notfound then
            exit;
         end if;
         lics_form.set_value('VTR_DESCRIPTION','(' || rcd_vds_val_typ_rul_01.vtr_rule || ') ' || rcd_vds_val_typ_rul_01.var_description);
      end loop;
      close csr_vds_val_typ_rul_01;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_type;

   /**************************************************/
   /* This function performs the insert type routine */
   /**************************************************/
   function insert_type return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_val_typ_01 is 
         select *
           from vds_val_typ t01
          where t01.vat_type = rcd_vds_val_typ.vat_type;
      rcd_vds_val_typ_01 csr_vds_val_typ_01%rowtype;

      cursor csr_vds_val_grp_01 is 
         select *
           from vds_val_grp t01
          where t01.vag_group = rcd_vds_val_typ.vat_group;
      rcd_vds_val_grp_01 csr_vds_val_grp_01%rowtype;

      cursor csr_vds_val_rul_01 is 
         select *
           from vds_val_rul t01
          where t01.var_rule = rcd_vds_val_typ_rul.vtr_rule;
      rcd_vds_val_rul_01 csr_vds_val_rul_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Validation Configuration - Insert Type';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_val_typ.vat_type := upper(lics_form.get_variable('VAT_TYPE'));
      rcd_vds_val_typ.vat_description := lics_form.get_variable('VAT_DESCRIPTION');
      rcd_vds_val_typ.vat_group := upper(lics_form.get_variable('VAT_GROUP'));

      /*-*/
      /* Validate the data values
      /*-*/
      if rcd_vds_val_typ.vat_type is null then
         var_message := var_message || chr(13) || 'Type must be specified';
      end if;
      if rcd_vds_val_typ.vat_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;
      if rcd_vds_val_typ.vat_group is null then
         var_message := var_message || chr(13) || 'Group must be specified';
      end if;

      /*-*/
      /* Type must not already exist
      /*-*/
      open csr_vds_val_typ_01;
      fetch csr_vds_val_typ_01 into rcd_vds_val_typ_01;
      if csr_vds_val_typ_01%found then
         var_message := var_message || chr(13) || 'Type (' || rcd_vds_val_typ.vat_type || ') already exists';
      end if;
      close csr_vds_val_typ_01;

      /*-*/
      /* Group must exist
      /*-*/
      open csr_vds_val_grp_01;
      fetch csr_vds_val_grp_01 into rcd_vds_val_grp_01;
      if csr_vds_val_grp_01%notfound then
         var_message := var_message || chr(13) || 'Group (' || rcd_vds_val_typ.vat_group || ') does not exist';
      end if;
      close csr_vds_val_grp_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new type
      /*-*/
      insert into vds_val_typ
         (vat_type,
          vat_description,
          vat_group)
         values(rcd_vds_val_typ.vat_type,
                rcd_vds_val_typ.vat_description,
                rcd_vds_val_typ.vat_group);

      /*-*/
      /* Process the type rules
      /*-*/
      rcd_vds_val_typ_rul.vtr_type := rcd_vds_val_typ.vat_type;
      rcd_vds_val_typ_rul.vtr_sequence := 0;
      for idx in 1..to_number(lics_form.get_array_count('VTR_RULE')) loop

         /*-*/
         /* Set the data variables
         /**/
         rcd_vds_val_typ_rul.vtr_rule := upper(lics_form.get_array('VTR_RULE',idx));
         rcd_vds_val_typ_rul.vtr_sequence := rcd_vds_val_typ_rul.vtr_sequence + 1;

         /*-*/
         /* Validate the data values
         /*-*/
         if rcd_vds_val_typ_rul.vtr_rule is null then
            var_message := var_message || chr(13) || 'Rule must be specified';
         end if;

         /*-*/
         /* Rule must exist
         /*-*/
         open csr_vds_val_rul_01;
         fetch csr_vds_val_rul_01 into rcd_vds_val_rul_01;
         if csr_vds_val_rul_01%notfound then
            var_message := var_message || chr(13) || 'Rule (' || rcd_vds_val_typ_rul.vtr_rule || ') does not exist';
         else
            if rcd_vds_val_typ.vat_group != rcd_vds_val_rul_01.var_group then
               var_message := var_message || chr(13) || 'Rule (' || rcd_vds_val_typ_rul.vtr_rule || ') - type and rule groups must be the same';
            end if;
         end if;
         close csr_vds_val_rul_01;

         /*-*/
         /* Create the new type rule
         /*-*/
         insert into vds_val_typ_rul
            (vtr_type,
             vtr_rule,
             vtr_sequence)
            values(rcd_vds_val_typ_rul.vtr_type,
                   rcd_vds_val_typ_rul.vtr_rule,
                   rcd_vds_val_typ_rul.vtr_sequence);

      end loop;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end insert_type;

   /**************************************************/
   /* This function performs the update type routine */
   /**************************************************/
   function update_type return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_val_typ_01 is 
         select *
           from vds_val_typ t01
          where t01.vat_type = rcd_vds_val_typ.vat_type;
      rcd_vds_val_typ_01 csr_vds_val_typ_01%rowtype;

      cursor csr_vds_val_rul_01 is 
         select *
           from vds_val_rul t01
          where t01.var_rule = rcd_vds_val_typ_rul.vtr_rule;
      rcd_vds_val_rul_01 csr_vds_val_rul_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Validation Configuration - Update Type';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_val_typ.vat_type := upper(lics_form.get_variable('VAT_TYPE'));
      rcd_vds_val_typ.vat_description := lics_form.get_variable('VAT_DESCRIPTION');

      /*-*/
      /* Validate the data values
      /*-*/
      if rcd_vds_val_typ.vat_type is null then
         var_message := var_message || chr(13) || 'Type must be specified';
      end if;
      if rcd_vds_val_typ.vat_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;

      /*-*/
      /* Type must already exist
      /*-*/
      open csr_vds_val_typ_01;
      fetch csr_vds_val_typ_01 into rcd_vds_val_typ_01;
      if csr_vds_val_typ_01%notfound then
         var_message := var_message || chr(13) || 'Type (' || rcd_vds_val_typ.vat_type || ') does not exist';
      end if;
      close csr_vds_val_typ_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing type
      /*-*/
      update vds_val_typ
         set vat_description = rcd_vds_val_typ.vat_description
         where vat_type = rcd_vds_val_typ.vat_type;

      /*-*/
      /* Process the type rules
      /*-*/
      delete from vds_val_typ_rul where vtr_type = rcd_vds_val_typ.vat_type;
      rcd_vds_val_typ_rul.vtr_type := rcd_vds_val_typ.vat_type;
      rcd_vds_val_typ_rul.vtr_sequence := 0;
      for idx in 1..to_number(lics_form.get_array_count('VTR_RULE')) loop

         /*-*/
         /* Set the data variables
         /**/
         rcd_vds_val_typ_rul.vtr_rule := upper(lics_form.get_array('VTR_RULE',idx));
         rcd_vds_val_typ_rul.vtr_sequence := rcd_vds_val_typ_rul.vtr_sequence + 1;

         /*-*/
         /* Validate the data values
         /*-*/
         if rcd_vds_val_typ_rul.vtr_rule is null then
            var_message := var_message || chr(13) || 'Rule must be specified';
         end if;

         /*-*/
         /* Rule must exist
         /*-*/
         open csr_vds_val_rul_01;
         fetch csr_vds_val_rul_01 into rcd_vds_val_rul_01;
         if csr_vds_val_rul_01%notfound then
            var_message := var_message || chr(13) || 'Rule (' || rcd_vds_val_typ_rul.vtr_rule || ') does not exist';
         else
            if rcd_vds_val_typ_01.vat_group != rcd_vds_val_rul_01.var_group then
               var_message := var_message || chr(13) || 'Rule (' || rcd_vds_val_typ_rul.vtr_rule || ') - type and rule groups must be the same';
            end if;
         end if;
         close csr_vds_val_rul_01;

         /*-*/
         /* Create the new type rule
         /*-*/
         insert into vds_val_typ_rul
            (vtr_type,
             vtr_rule,
             vtr_sequence)
            values(rcd_vds_val_typ_rul.vtr_type,
                   rcd_vds_val_typ_rul.vtr_rule,
                   rcd_vds_val_typ_rul.vtr_sequence);

      end loop;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_type;

   /**************************************************/
   /* This function performs the delete type routine */
   /**************************************************/
   function delete_type return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_val_typ_01 is 
         select *
           from vds_val_typ t01
          where t01.vat_type = rcd_vds_val_typ.vat_type;
      rcd_vds_val_typ_01 csr_vds_val_typ_01%rowtype;

      cursor csr_vds_val_fil_01 is 
         select *
           from vds_val_fil t01
          where t01.vaf_type = rcd_vds_val_typ.vat_type;
      rcd_vds_val_fil_01 csr_vds_val_fil_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Validation Configuration - Delete Type';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_val_typ.vat_type := upper(lics_form.get_variable('VAT_TYPE'));

      /*-*/
      /* Type must already exist
      /*-*/
      open csr_vds_val_typ_01;
      fetch csr_vds_val_typ_01 into rcd_vds_val_typ_01;
      if csr_vds_val_typ_01%notfound then
         var_message := var_message || chr(13) || 'Type (' || rcd_vds_val_typ.vat_type || ') does not exist';
      end if;
      close csr_vds_val_typ_01;

      /*-*/
      /* Filter must not exist for type
      /*-*/
      open csr_vds_val_fil_01;
      fetch csr_vds_val_fil_01 into rcd_vds_val_fil_01;
      if csr_vds_val_fil_01%found then
         var_message := var_message || chr(13) || 'Type (' || rcd_vds_val_typ.vat_type || ') has filters attached - unable to delete';
      end if;
      close csr_vds_val_fil_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing type data
      /*-*/
      delete from vds_val_ema_det where ved_type = rcd_vds_val_typ.vat_type;
      delete from vds_val_mes_ema where (vme_execution, vme_code, vme_class, vme_sequence) in (select vam_execution, vam_code, vam_class, vam_sequence from vds_val_mes where vam_type = rcd_vds_val_typ.vat_type);
      delete from vds_val_mes where vam_type = rcd_vds_val_typ.vat_type;
      delete from vds_val_typ_rul where vtr_type = rcd_vds_val_typ.vat_type;
      delete from vds_val_typ where vat_type = rcd_vds_val_typ.vat_type;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_type;

   /******************************************************/
   /* This function performs the retrieve filter routine */
   /******************************************************/
   function retrieve_filter return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_val_fil_01 is 
         select *
           from vds_val_fil t01
          where t01.vaf_filter = rcd_vds_val_fil.vaf_filter;
      rcd_vds_val_fil_01 csr_vds_val_fil_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Validation Configuration - Retrieve Filter';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_val_fil.vaf_filter := upper(lics_form.get_variable('VAF_FILTER'));

      /*-*/
      /* Filter must exist
      /*-*/
      open csr_vds_val_fil_01;
      fetch csr_vds_val_fil_01 into rcd_vds_val_fil_01;
      if csr_vds_val_fil_01%notfound then
         var_message := var_message || chr(13) || 'Filter (' || rcd_vds_val_fil.vaf_filter || ') does not exist';
      end if;
      close csr_vds_val_fil_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the form data
      /*-*/
      lics_form.clear_form;
      lics_form.set_value('VAF_FILTER',rcd_vds_val_fil_01.vaf_filter);
      lics_form.set_value('VAF_DESCRIPTION',rcd_vds_val_fil_01.vaf_description);
      lics_form.set_value('VAF_GROUP',rcd_vds_val_fil_01.vaf_group);
      lics_form.set_clob('VAF_TYPE',rcd_vds_val_fil_01.vaf_type);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_filter;

   /****************************************************/
   /* This function performs the insert filter routine */
   /****************************************************/
   function insert_filter return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_val_fil_01 is 
         select *
           from vds_val_fil t01
          where t01.vaf_filter = rcd_vds_val_fil.vaf_filter;
      rcd_vds_val_fil_01 csr_vds_val_fil_01%rowtype;

      cursor csr_vds_val_grp_01 is 
         select *
           from vds_val_grp t01
          where t01.vag_group = rcd_vds_val_fil.vaf_group;
      rcd_vds_val_grp_01 csr_vds_val_grp_01%rowtype;

      cursor csr_vds_val_typ_01 is 
         select *
           from vds_val_typ t01
          where t01.vat_type = rcd_vds_val_fil.vaf_type;
      rcd_vds_val_typ_01 csr_vds_val_typ_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Validation Configuration - Insert Filter';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_val_fil.vaf_filter := upper(lics_form.get_variable('VAF_FILTER'));
      rcd_vds_val_fil.vaf_description := lics_form.get_variable('VAF_DESCRIPTION');
      rcd_vds_val_fil.vaf_group := upper(lics_form.get_variable('VAF_GROUP'));
      rcd_vds_val_fil.vaf_type := upper(lics_form.get_variable('VAF_TYPE'));

      /*-*/
      /* Validate the data values
      /*-*/
      if rcd_vds_val_fil.vaf_filter is null then
         var_message := var_message || chr(13) || 'Filter must be specified';
      end if;
      if rcd_vds_val_fil.vaf_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;
      if rcd_vds_val_fil.vaf_group is null then
         var_message := var_message || chr(13) || 'Group must be specified';
      end if;
      if rcd_vds_val_fil.vaf_type is null then
         var_message := var_message || chr(13) || 'Type must be specified';
      end if;

      /*-*/
      /* Filter must not already exist
      /*-*/
      open csr_vds_val_fil_01;
      fetch csr_vds_val_fil_01 into rcd_vds_val_fil_01;
      if csr_vds_val_fil_01%found then
         var_message := var_message || chr(13) || 'Filter (' || rcd_vds_val_fil.vaf_filter || ') already exists';
      end if;
      close csr_vds_val_fil_01;

      /*-*/
      /* Group must exist
      /*-*/
      open csr_vds_val_grp_01;
      fetch csr_vds_val_grp_01 into rcd_vds_val_grp_01;
      if csr_vds_val_grp_01%notfound then
         var_message := var_message || chr(13) || 'Group (' || rcd_vds_val_fil.vaf_group || ') does not exist';
      end if;
      close csr_vds_val_grp_01;

      /*-*/
      /* Type must exist
      /*-*/
      open csr_vds_val_typ_01;
      fetch csr_vds_val_typ_01 into rcd_vds_val_typ_01;
      if csr_vds_val_typ_01%notfound then
         var_message := var_message || chr(13) || 'Type (' || rcd_vds_val_fil.vaf_type || ') does not exist';
      else
         if rcd_vds_val_fil.vaf_group != rcd_vds_val_typ_01.vat_group then
            var_message := var_message || chr(13) || 'Filter and type groups must be the same';
         end if;
      end if;
      close csr_vds_val_typ_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new filter
      /*-*/
      insert into vds_val_fil
         (vaf_filter,
          vaf_description,
          vaf_group,
          vaf_type)
         values(rcd_vds_val_fil.vaf_filter,
                rcd_vds_val_fil.vaf_description,
                rcd_vds_val_fil.vaf_group,
                rcd_vds_val_fil.vaf_type);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end insert_filter;

   /****************************************************/
   /* This function performs the update filter routine */
   /****************************************************/
   function update_filter return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_val_fil_01 is 
         select *
           from vds_val_fil t01
          where t01.vaf_filter = rcd_vds_val_fil.vaf_filter;
      rcd_vds_val_fil_01 csr_vds_val_fil_01%rowtype;

      cursor csr_vds_val_typ_01 is 
         select *
           from vds_val_typ t01
          where t01.vat_type = rcd_vds_val_fil.vaf_type;
      rcd_vds_val_typ_01 csr_vds_val_typ_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Validation Configuration - Update Filter';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_val_fil.vaf_filter := upper(lics_form.get_variable('VAF_FILTER'));
      rcd_vds_val_fil.vaf_description := lics_form.get_variable('VAF_DESCRIPTION');
      rcd_vds_val_fil.vaf_type := upper(lics_form.get_variable('VAF_TYPE'));

      /*-*/
      /* Validate the data values
      /*-*/
      if rcd_vds_val_fil.vaf_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;
      if rcd_vds_val_fil.vaf_type is null then
         var_message := var_message || chr(13) || 'Type must be specified';
      end if;

      /*-*/
      /* Filter must already exist
      /*-*/
      open csr_vds_val_fil_01;
      fetch csr_vds_val_fil_01 into rcd_vds_val_fil_01;
      if csr_vds_val_fil_01%notfound then
         var_message := var_message || chr(13) || 'Filter (' || rcd_vds_val_fil.vaf_filter || ') does not exist';
      end if;
      close csr_vds_val_fil_01;

      /*-*/
      /* Type must exist
      /*-*/
      open csr_vds_val_typ_01;
      fetch csr_vds_val_typ_01 into rcd_vds_val_typ_01;
      if csr_vds_val_typ_01%notfound then
         var_message := var_message || chr(13) || 'Type (' || rcd_vds_val_fil.vaf_type || ') does not exist';
      else
         if rcd_vds_val_fil_01.vaf_group != rcd_vds_val_typ_01.vat_group then
            var_message := var_message || chr(13) || 'Filter and type groups must be the same';
         end if;
      end if;
      close csr_vds_val_typ_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing filter
      /*-*/
      update vds_val_fil
         set vaf_description = rcd_vds_val_fil.vaf_description,
             vaf_type = rcd_vds_val_fil.vaf_type
         where vaf_filter = rcd_vds_val_fil.vaf_filter;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_filter;

   /****************************************************/
   /* This function performs the delete filter routine */
   /****************************************************/
   function delete_filter return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_val_fil_01 is 
         select *
           from vds_val_fil t01
          where t01.vaf_filter = rcd_vds_val_fil.vaf_filter;
      rcd_vds_val_fil_01 csr_vds_val_fil_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Validation Configuration - Delete Filter';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_val_fil.vaf_filter := upper(lics_form.get_variable('VAF_FILTER'));

      /*-*/
      /* Filter must already exist
      /*-*/
      open csr_vds_val_fil_01;
      fetch csr_vds_val_fil_01 into rcd_vds_val_fil_01;
      if csr_vds_val_fil_01%notfound then
         var_message := var_message || chr(13) || 'Filter (' || rcd_vds_val_fil.vaf_filter || ') does not exist';
      end if;
      close csr_vds_val_fil_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing filter data
      /*-*/
      delete from vds_val_ema_det where ved_filter = rcd_vds_val_fil.vaf_filter;
      delete from vds_val_mes_ema where (vme_execution, vme_code, vme_class, vme_sequence) in (select vam_execution, vam_code, vam_class, vam_sequence from vds_val_mes where vam_filter = rcd_vds_val_fil.vaf_filter);
      delete from vds_val_mes where vam_filter = rcd_vds_val_fil.vaf_filter;
      delete from vds_val_fil_det where vfd_filter = rcd_vds_val_fil.vaf_filter;
      delete from vds_val_fil where vaf_filter = rcd_vds_val_fil.vaf_filter;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_filter;

   /**************************************************/
   /* This function performs the load filter routine */
   /**************************************************/
   function load_filter return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_val_fil_01 is 
         select *
           from vds_val_fil t01
          where t01.vaf_filter = rcd_vds_val_fil.vaf_filter;
      rcd_vds_val_fil_01 csr_vds_val_fil_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Validation Configuration - Load Filter';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_val_fil.vaf_filter := upper(lics_form.get_variable('VAF_FILTER'));

      /*-*/
      /* Filter must already exist
      /*-*/
      open csr_vds_val_fil_01;
      fetch csr_vds_val_fil_01 into rcd_vds_val_fil_01;
      if csr_vds_val_fil_01%notfound then
         var_message := var_message || chr(13) || 'Filter (' || rcd_vds_val_fil.vaf_filter || ') does not exist';
      end if;
      close csr_vds_val_fil_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing filter data
      /*-*/
      delete from vds_val_fil_det where vfd_filter = rcd_vds_val_fil.vaf_filter;

      /*-*/
      /* Load the new filter detail
      /*-*/
      rcd_vds_val_fil_det.vfd_filter := rcd_vds_val_fil.vaf_filter;
      for idx in 1..to_number(lics_form.get_array_count('VFD_CODE')) loop

         /*-*/
         /* Set the data variables
         /**/
         rcd_vds_val_fil_det.vfd_code := upper(lics_form.get_array('VFD_CODE',idx));

         /*-*/
         /* Create the new filter detail
         /*-*/
         begin
         insert into vds_val_fil_det
            (vfd_filter,
             vfd_code)
            values(rcd_vds_val_fil_det.vfd_filter,
                   rcd_vds_val_fil_det.vfd_code);
         exception
            when others then
               var_message := var_message || chr(13) || 'Detail code (' || rcd_vds_val_fil_det.vfd_code || ') already exists';
               exit;
         end;

      end loop;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load_filter;

   /*****************************************************/
   /* This function performs the retrieve email routine */
   /*****************************************************/
   function retrieve_email return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_val_ema_01 is 
         select *
           from vds_val_ema t01
          where t01.vae_email = rcd_vds_val_ema.vae_email;
      rcd_vds_val_ema_01 csr_vds_val_ema_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Validation Configuration - Retrieve Email';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_val_ema.vae_email := upper(lics_form.get_variable('VAE_EMAIL'));

      /*-*/
      /* Email must exist
      /*-*/
      open csr_vds_val_ema_01;
      fetch csr_vds_val_ema_01 into rcd_vds_val_ema_01;
      if csr_vds_val_ema_01%notfound then
         var_message := var_message || chr(13) || 'Email (' || rcd_vds_val_ema.vae_email || ') does not exist';
      end if;
      close csr_vds_val_ema_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the form data
      /*-*/
      lics_form.clear_form;
      lics_form.set_value('VAE_EMAIL',rcd_vds_val_ema_01.vae_email);
      lics_form.set_value('VAE_DESCRIPTION',rcd_vds_val_ema_01.vae_description);
      lics_form.set_value('VAE_ADDRESS',rcd_vds_val_ema_01.vae_address);
      lics_form.set_value('VAE_STATUS',rcd_vds_val_ema_01.vae_status);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_email;

   /***************************************************/
   /* This function performs the insert email routine */
   /***************************************************/
   function insert_email return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_val_ema_01 is 
         select *
           from vds_val_ema t01
          where t01.vae_email = rcd_vds_val_ema.vae_email;
      rcd_vds_val_ema_01 csr_vds_val_ema_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Validation Configuration - Insert Email';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_val_ema.vae_email := upper(lics_form.get_variable('VAE_EMAIL'));
      rcd_vds_val_ema.vae_description := lics_form.get_variable('VAE_DESCRIPTION');
      rcd_vds_val_ema.vae_address := lics_form.get_variable('VAE_ADDRESS');
      rcd_vds_val_ema.vae_status := lics_form.get_variable('VAE_STATUS');

      /*-*/
      /* Validate the data values
      /*-*/
      if rcd_vds_val_ema.vae_email is null then
         var_message := var_message || chr(13) || 'Email must be specified';
      end if;
      if rcd_vds_val_ema.vae_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;
      if rcd_vds_val_ema.vae_address is null then
         var_message := var_message || chr(13) || 'Address must be specified';
      end if;
      if rcd_vds_val_ema.vae_status != '0' and rcd_vds_val_ema.vae_status != '1' then
         var_message := var_message || chr(13) || 'Status must be 0(inactive) or 1(active)';
      end if;

      /*-*/
      /* Email must not already exist
      /*-*/
      open csr_vds_val_ema_01;
      fetch csr_vds_val_ema_01 into rcd_vds_val_ema_01;
      if csr_vds_val_ema_01%found then
         var_message := var_message || chr(13) || 'Email (' || rcd_vds_val_ema.vae_email || ') already exists';
      end if;
      close csr_vds_val_ema_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new email
      /*-*/
      insert into vds_val_ema
         (vae_email,
          vae_description,
          vae_address,
          vae_status)
         values(rcd_vds_val_ema.vae_email,
                rcd_vds_val_ema.vae_description,
                rcd_vds_val_ema.vae_address,
                rcd_vds_val_ema.vae_status);

      /*-*/
      /* Process the email details
      /*-*/
      rcd_vds_val_ema_det.ved_email := rcd_vds_val_ema.vae_email;
      for idx in 1..to_number(lics_form.get_array_count('VED_GROUP')) loop

         /*-*/
         /* Set the data variables
         /**/
         rcd_vds_val_ema_det.ved_group := lics_form.get_array('VED_GROUP',idx);
         rcd_vds_val_ema_det.ved_class := lics_form.get_array('VED_CLASS',idx);
         rcd_vds_val_ema_det.ved_type := lics_form.get_array('VED_TYPE',idx);
         rcd_vds_val_ema_det.ved_filter := lics_form.get_array('VED_FILTER',idx);
         rcd_vds_val_ema_det.ved_rule := lics_form.get_array('VED_RULE',idx);
         rcd_vds_val_ema_det.ved_search01 := lics_form.get_array('VED_SEARCH01',idx);
         rcd_vds_val_ema_det.ved_search02 := lics_form.get_array('VED_SEARCH02',idx);
         rcd_vds_val_ema_det.ved_search03 := lics_form.get_array('VED_SEARCH03',idx);
         rcd_vds_val_ema_det.ved_search04 := lics_form.get_array('VED_SEARCH04',idx);
         rcd_vds_val_ema_det.ved_search05 := lics_form.get_array('VED_SEARCH05',idx);
         rcd_vds_val_ema_det.ved_search06 := lics_form.get_array('VED_SEARCH06',idx);
         rcd_vds_val_ema_det.ved_search07 := lics_form.get_array('VED_SEARCH07',idx);
         rcd_vds_val_ema_det.ved_search08 := lics_form.get_array('VED_SEARCH08',idx);
         rcd_vds_val_ema_det.ved_search09 := lics_form.get_array('VED_SEARCH09',idx);

         /*-*/
         /* Validate the data values
         /*-*/
         if rcd_vds_val_ema_det.ved_group is null then
            var_message := var_message || chr(13) || 'Group must be specified';
         end if;
         if rcd_vds_val_ema_det.ved_class is null then
            var_message := var_message || chr(13) || 'Classification must be specified';
         end if;
         if rcd_vds_val_ema_det.ved_type is null then
            var_message := var_message || chr(13) || 'Type must be specified';
         end if;
         if rcd_vds_val_ema_det.ved_filter is null then
            var_message := var_message || chr(13) || 'Filter must be specified';
         end if;
         if rcd_vds_val_ema_det.ved_rule is null then
            var_message := var_message || chr(13) || 'Rule must be specified';
         end if;

         /*-*/
         /* Create the new email detail
         /*-*/
         insert into vds_val_ema_det
            (ved_email,
             ved_group,
             ved_class,
             ved_type,
             ved_filter,
             ved_rule,
             ved_search01,
             ved_search02,
             ved_search03,
             ved_search04,
             ved_search05,
             ved_search06,
             ved_search07,
             ved_search08,
             ved_search09)
            values(rcd_vds_val_ema_det.ved_email,
                   rcd_vds_val_ema_det.ved_group,
                   rcd_vds_val_ema_det.ved_class,
                   rcd_vds_val_ema_det.ved_type,
                   rcd_vds_val_ema_det.ved_filter,
                   rcd_vds_val_ema_det.ved_rule,
                   rcd_vds_val_ema_det.ved_search01,
                   rcd_vds_val_ema_det.ved_search02,
                   rcd_vds_val_ema_det.ved_search03,
                   rcd_vds_val_ema_det.ved_search04,
                   rcd_vds_val_ema_det.ved_search05,
                   rcd_vds_val_ema_det.ved_search06,
                   rcd_vds_val_ema_det.ved_search07,
                   rcd_vds_val_ema_det.ved_search08,
                   rcd_vds_val_ema_det.ved_search09);

      end loop;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end insert_email;

   /***************************************************/
   /* This function performs the update email routine */
   /***************************************************/
   function update_email return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_val_ema_01 is 
         select *
           from vds_val_ema t01
          where t01.vae_email = rcd_vds_val_ema.vae_email;
      rcd_vds_val_ema_01 csr_vds_val_ema_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Validation Configuration - Update Email';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_val_ema.vae_email := upper(lics_form.get_variable('VAE_EMAIL'));
      rcd_vds_val_ema.vae_description := lics_form.get_variable('VAE_DESCRIPTION');
      rcd_vds_val_ema.vae_address := lics_form.get_variable('VAE_ADDRESS');
      rcd_vds_val_ema.vae_status := lics_form.get_variable('VAE_STATUS');

      /*-*/
      /* Validate the data values
      /*-*/
      if rcd_vds_val_ema.vae_email is null then
         var_message := var_message || chr(13) || 'Email must be specified';
      end if;
      if rcd_vds_val_ema.vae_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;
      if rcd_vds_val_ema.vae_address is null then
         var_message := var_message || chr(13) || 'Address must be specified';
      end if;
      if rcd_vds_val_ema.vae_status != '0' and rcd_vds_val_ema.vae_status != '1' then
         var_message := var_message || chr(13) || 'Status must be 0(inactive) or 1(active)';
      end if;

      /*-*/
      /* Email must already exist
      /*-*/
      open csr_vds_val_ema_01;
      fetch csr_vds_val_ema_01 into rcd_vds_val_ema_01;
      if csr_vds_val_ema_01%notfound then
         var_message := var_message || chr(13) || 'Email (' || rcd_vds_val_ema.vae_email || ') does not exist';
      end if;
      close csr_vds_val_ema_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing email
      /*-*/
      update vds_val_ema
         set vae_description = rcd_vds_val_ema.vae_description,
             vae_address = rcd_vds_val_ema.vae_address,
             vae_status = rcd_vds_val_ema.vae_status
         where vae_email = rcd_vds_val_ema.vae_email;

      /*-*/
      /* Process the email details
      /*-*/
      delete from vds_val_ema_det where ved_email = rcd_vds_val_ema.vae_email;
      rcd_vds_val_ema_det.ved_email := rcd_vds_val_ema.vae_email;
      for idx in 1..to_number(lics_form.get_array_count('VED_GROUP')) loop

         /*-*/
         /* Set the data variables
         /**/
         rcd_vds_val_ema_det.ved_group := lics_form.get_array('VED_GROUP',idx);
         rcd_vds_val_ema_det.ved_class := lics_form.get_array('VED_CLASS',idx);
         rcd_vds_val_ema_det.ved_type := lics_form.get_array('VED_TYPE',idx);
         rcd_vds_val_ema_det.ved_filter := lics_form.get_array('VED_FILTER',idx);
         rcd_vds_val_ema_det.ved_rule := lics_form.get_array('VED_RULE',idx);
         rcd_vds_val_ema_det.ved_search01 := lics_form.get_array('VED_SEARCH01',idx);
         rcd_vds_val_ema_det.ved_search02 := lics_form.get_array('VED_SEARCH02',idx);
         rcd_vds_val_ema_det.ved_search03 := lics_form.get_array('VED_SEARCH03',idx);
         rcd_vds_val_ema_det.ved_search04 := lics_form.get_array('VED_SEARCH04',idx);
         rcd_vds_val_ema_det.ved_search05 := lics_form.get_array('VED_SEARCH05',idx);
         rcd_vds_val_ema_det.ved_search06 := lics_form.get_array('VED_SEARCH06',idx);
         rcd_vds_val_ema_det.ved_search07 := lics_form.get_array('VED_SEARCH07',idx);
         rcd_vds_val_ema_det.ved_search08 := lics_form.get_array('VED_SEARCH08',idx);
         rcd_vds_val_ema_det.ved_search09 := lics_form.get_array('VED_SEARCH09',idx);

         /*-*/
         /* Validate the data values
         /*-*/
         if rcd_vds_val_ema_det.ved_group is null then
            var_message := var_message || chr(13) || 'Group must be specified';
         end if;
         if rcd_vds_val_ema_det.ved_class is null then
            var_message := var_message || chr(13) || 'Classification must be specified';
         end if;
         if rcd_vds_val_ema_det.ved_type is null then
            var_message := var_message || chr(13) || 'Type must be specified';
         end if;
         if rcd_vds_val_ema_det.ved_filter is null then
            var_message := var_message || chr(13) || 'Filter must be specified';
         end if;
         if rcd_vds_val_ema_det.ved_rule is null then
            var_message := var_message || chr(13) || 'Rule must be specified';
         end if;

         /*-*/
         /* Create the new email detail
         /*-*/
         insert into vds_val_ema_det
            (ved_email,
             ved_group,
             ved_class,
             ved_type,
             ved_filter,
             ved_rule,
             ved_search01,
             ved_search02,
             ved_search03,
             ved_search04,
             ved_search05,
             ved_search06,
             ved_search07,
             ved_search08,
             ved_search09)
            values(rcd_vds_val_ema_det.ved_email,
                   rcd_vds_val_ema_det.ved_group,
                   rcd_vds_val_ema_det.ved_class,
                   rcd_vds_val_ema_det.ved_type,
                   rcd_vds_val_ema_det.ved_filter,
                   rcd_vds_val_ema_det.ved_rule,
                   rcd_vds_val_ema_det.ved_search01,
                   rcd_vds_val_ema_det.ved_search02,
                   rcd_vds_val_ema_det.ved_search03,
                   rcd_vds_val_ema_det.ved_search04,
                   rcd_vds_val_ema_det.ved_search05,
                   rcd_vds_val_ema_det.ved_search06,
                   rcd_vds_val_ema_det.ved_search07,
                   rcd_vds_val_ema_det.ved_search08,
                   rcd_vds_val_ema_det.ved_search09);

      end loop;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_email;

   /***************************************************/
   /* This function performs the delete email routine */
   /***************************************************/
   function delete_email return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_val_ema_01 is 
         select *
           from vds_val_ema t01
          where t01.vae_email = rcd_vds_val_ema.vae_email;
      rcd_vds_val_ema_01 csr_vds_val_ema_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Validation Configuration - Delete Email';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_val_ema.vae_email := upper(lics_form.get_variable('VAE_EMAIL'));

      /*-*/
      /* Email administrator must not be deleted
      /*-*/
      if rcd_vds_val_ema.vae_email = con_admin_code then
         var_message := var_message || chr(13) || 'Email (' || con_admin_code || ') must not be deleted';
      end if;

      /*-*/
      /* Email must already exist
      /*-*/
      open csr_vds_val_ema_01;
      fetch csr_vds_val_ema_01 into rcd_vds_val_ema_01;
      if csr_vds_val_ema_01%notfound then
         var_message := var_message || chr(13) || 'Email (' || rcd_vds_val_ema.vae_email || ') does not exist';
      end if;
      close csr_vds_val_ema_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing email data
      /*-*/
      delete from vds_val_mes_ema where vme_email = rcd_vds_val_ema.vae_email;
      delete from vds_val_ema_det where ved_email = rcd_vds_val_ema.vae_email;
      delete from vds_val_ema where vae_email = rcd_vds_val_ema.vae_email;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_email;

end vds_val_configuration;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym vds_val_configuration for vds_app.vds_val_configuration;
grant execute on vds_val_configuration to public;