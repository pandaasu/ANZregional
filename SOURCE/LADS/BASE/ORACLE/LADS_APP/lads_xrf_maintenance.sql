/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_xrf_maintenance
 Owner   : lads_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Local Atlas Data Store - Cross Reference Maintenance

 The package implements the cross reference functionality.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_xrf_maintenance as

   /*-*/
   /* Public declarations
   /*-*/
   function insert_detail(par_code in varchar2,
                          par_source in varchar2,
                          par_target in varchar2) return varchar2;
   function update_detail(par_code in varchar2,
                          par_source in varchar2,
                          par_target in varchar2) return varchar2;
   function delete_detail(par_code in varchar2,
                          par_source in varchar2) return varchar2;

end lads_xrf_maintenance;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_xrf_maintenance as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_lads_xrf_det lads_xrf_det%rowtype;

   /****************************************************/
   /* This function performs the insert detail routine */
   /****************************************************/
   function insert_detail(par_code in varchar2,
                          par_source in varchar2,
                          par_target in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_xrf_hdr_01 is 
         select *
           from lads_xrf_hdr t01
          where t01.xrf_code = rcd_lads_xrf_det.xrf_code;
      rcd_lads_xrf_hdr_01 csr_lads_xrf_hdr_01%rowtype;

      cursor csr_lads_xrf_det_01 is 
         select *
           from lads_xrf_det t01
          where t01.xrf_code = rcd_lads_xrf_det.xrf_code
            and t01.xrf_source = rcd_lads_xrf_det.xrf_source;
      rcd_lads_xrf_det_01 csr_lads_xrf_det_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Cross Reference Maintenance - Insert Detail';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lads_xrf_det.xrf_code := par_code;
      rcd_lads_xrf_det.xrf_source := par_source;
      rcd_lads_xrf_det.xrf_target := par_target;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lads_xrf_det.xrf_code is null then
         var_message := var_message || chr(13) || 'Cross reference code must be specified';
      end if;
      if rcd_lads_xrf_det.xrf_source is null then
         var_message := var_message || chr(13) || 'Cross reference source must be specified';
      end if;
      if rcd_lads_xrf_det.xrf_target is null then
         var_message := var_message || chr(13) || 'Cross reference target must be specified';
      end if;

      /*-*/
      /* Cross reference header must exist
      /*-*/
      open csr_lads_xrf_hdr_01;
      fetch csr_lads_xrf_hdr_01 into rcd_lads_xrf_hdr_01;
      if csr_lads_xrf_hdr_01%notfound then
         var_message := var_message || chr(13) || 'Cross reference code (' || rcd_lads_xrf_det.xrf_code || ') does not exist';
      end if;
      close csr_lads_xrf_hdr_01;

      /*-*/
      /* Cross reference detail must not already exist
      /*-*/
      open csr_lads_xrf_det_01;
      fetch csr_lads_xrf_det_01 into rcd_lads_xrf_det_01;
      if csr_lads_xrf_det_01%found then
         var_message := var_message || chr(13) || 'Cross reference source (' || rcd_lads_xrf_det.xrf_source || ') already exists';
      end if;
      close csr_lads_xrf_det_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Insert the cross reference detail
      /*-*/
      insert into lads_xrf_det
         (xrf_code,
          xrf_source,
          xrf_target)
         values(rcd_lads_xrf_det.xrf_code,
                rcd_lads_xrf_det.xrf_source,
                rcd_lads_xrf_det.xrf_target);

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
   end insert_detail;

   /****************************************************/
   /* This function performs the update detail routine */
   /****************************************************/
   function update_detail(par_code in varchar2,
                          par_source in varchar2,
                          par_target in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_xrf_hdr_01 is 
         select *
           from lads_xrf_hdr t01
          where t01.xrf_code = rcd_lads_xrf_det.xrf_code;
      rcd_lads_xrf_hdr_01 csr_lads_xrf_hdr_01%rowtype;

      cursor csr_lads_xrf_det_01 is 
         select *
           from lads_xrf_det t01
          where t01.xrf_code = rcd_lads_xrf_det.xrf_code
            and t01.xrf_source = rcd_lads_xrf_det.xrf_source;
      rcd_lads_xrf_det_01 csr_lads_xrf_det_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Cross Reference Maintenance - Update Detail';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lads_xrf_det.xrf_code := par_code;
      rcd_lads_xrf_det.xrf_source := par_source;
      rcd_lads_xrf_det.xrf_target := par_target;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lads_xrf_det.xrf_code is null then
         var_message := var_message || chr(13) || 'Cross reference code must be specified';
      end if;
      if rcd_lads_xrf_det.xrf_source is null then
         var_message := var_message || chr(13) || 'Cross reference source must be specified';
      end if;
      if rcd_lads_xrf_det.xrf_target is null then
         var_message := var_message || chr(13) || 'Cross reference target must be specified';
      end if;

      /*-*/
      /* Cross reference header must exist
      /*-*/
      open csr_lads_xrf_hdr_01;
      fetch csr_lads_xrf_hdr_01 into rcd_lads_xrf_hdr_01;
      if csr_lads_xrf_hdr_01%notfound then
         var_message := var_message || chr(13) || 'Cross reference code (' || rcd_lads_xrf_det.xrf_code || ') does not exist';
      end if;
      close csr_lads_xrf_hdr_01;

      /*-*/
      /* Cross reference detail must exist
      /*-*/
      open csr_lads_xrf_det_01;
      fetch csr_lads_xrf_det_01 into rcd_lads_xrf_det_01;
      if csr_lads_xrf_det_01%notfound then
         var_message := var_message || chr(13) || 'Cross reference source (' || rcd_lads_xrf_det.xrf_source || ') does not exist';
      end if;
      close csr_lads_xrf_det_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the cross reference detail
      /*-*/
      update lads_xrf_det
         set xrf_target= rcd_lads_xrf_det.xrf_target
         where xrf_code = rcd_lads_xrf_det.xrf_code
           and xrf_source = rcd_lads_xrf_det.xrf_source;

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
   end update_detail;

   /****************************************************/
   /* This function performs the delee detail routine */
   /*****************************************************/
   function delete_detail(par_code in varchar2,
                          par_source in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_xrf_hdr_01 is 
         select *
           from lads_xrf_hdr t01
          where t01.xrf_code = rcd_lads_xrf_det.xrf_code;
      rcd_lads_xrf_hdr_01 csr_lads_xrf_hdr_01%rowtype;

      cursor csr_lads_xrf_det_01 is 
         select *
           from lads_xrf_det t01
          where t01.xrf_code = rcd_lads_xrf_det.xrf_code
            and t01.xrf_source = rcd_lads_xrf_det.xrf_source;
      rcd_lads_xrf_det_01 csr_lads_xrf_det_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Cross Reference Maintenance - Delete Detail';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lads_xrf_det.xrf_code := par_code;
      rcd_lads_xrf_det.xrf_source := par_source;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lads_xrf_det.xrf_code is null then
         var_message := var_message || chr(13) || 'Cross reference code must be specified';
      end if;
      if rcd_lads_xrf_det.xrf_source is null then
         var_message := var_message || chr(13) || 'Cross reference source must be specified';
      end if;

      /*-*/
      /* Cross reference header must exist
      /*-*/
      open csr_lads_xrf_hdr_01;
      fetch csr_lads_xrf_hdr_01 into rcd_lads_xrf_hdr_01;
      if csr_lads_xrf_hdr_01%notfound then
         var_message := var_message || chr(13) || 'Cross reference code (' || rcd_lads_xrf_det.xrf_code || ') does not exist';
      end if;
      close csr_lads_xrf_hdr_01;

      /*-*/
      /* Cross reference detail must exist
      /*-*/
      open csr_lads_xrf_det_01;
      fetch csr_lads_xrf_det_01 into rcd_lads_xrf_det_01;
      if csr_lads_xrf_det_01%notfound then
         var_message := var_message || chr(13) || 'Cross reference source (' || rcd_lads_xrf_det.xrf_source || ') does not exist';
      end if;
      close csr_lads_xrf_det_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the cross reference detail
      /*-*/
      delete from lads_xrf_det
         where xrf_code = rcd_lads_xrf_det.xrf_code
           and xrf_source = rcd_lads_xrf_det.xrf_source;

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
   end delete_detail;

end lads_xrf_maintenance;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_xrf_maintenance for lads_app.lads_xrf_maintenance;
grant execute on lads_xrf_maintenance to public;