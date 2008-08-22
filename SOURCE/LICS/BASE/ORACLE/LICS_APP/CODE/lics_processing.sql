/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_processing
 Owner   : lics_app
 Author  : Steve Gregan - July 2005

 DESCRIPTION
 -----------
 Local Interface Control System - Processing

 The package implements the processing functionality.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/07   Steve Gregan   Created
 2008/08   Steve Gregan   Added check group function

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lics_processing as

   /*-*/
   /* Public declarations
   /*-*/
   procedure set_trace(par_prt_process in varchar2,
                       par_prt_date in varchar2);
   procedure check_group(par_pro_group in varchar2,
                         par_pro_date in varchar2,
                         par_tri_process in varchar2,
                         par_tri_function in varchar2,
                         par_tri_procedure in varchar2,
                         par_tri_opr_alert in varchar2,
                         par_tri_ema_group in varchar2,
                         par_tri_group in varchar2);
   function check_group(par_pro_group in varchar2,
                        par_pro_date in varchar2,
                        par_tri_process in varchar2) return boolean;

end lics_processing;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_processing as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*************************************************/
   /* This procedure performs the set trace routine */
   /*************************************************/
   procedure set_trace(par_prt_process in varchar2,
                       par_prt_date in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /**/
      /* Create the process trace
      /* **note** 1. the trace can only be insert once for a date
      /*          2. assumption is that this is only invoked on success of process
      /**/
      begin
         insert into lics_pro_trace
            (prt_process,
             prt_date)
            values(par_prt_process,
                   par_prt_date);
         commit;
      exception
         when others then
            null;
      end;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end set_trace;

   /***************************************************/
   /* This procedure performs the check group routine */
   /***************************************************/
   procedure check_group(par_pro_group in varchar2,
                         par_pro_date in varchar2,
                         par_tri_process in varchar2,
                         par_tri_function in varchar2,
                         par_tri_procedure in varchar2,
                         par_tri_opr_alert in varchar2,
                         par_tri_ema_group in varchar2,
                         par_tri_group in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;
      var_completed boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_pro_group is 
         select t01.prg_group
           from lics_pro_group t01
          where t01.prg_group = par_pro_group
                for update;
      rcd_lics_pro_group csr_lics_pro_group%rowtype;

      cursor csr_check_group is
         select t01.prc_exist,
                decode(t02.prt_process,null,'N','Y') as prt_exist
           from lics_pro_check t01,
                (select t02.prt_process
                   from lics_pro_trace t02
                  where prt_date = par_pro_date) t02
          where t01.prc_process = t02.prt_process(+)
            and t01.prc_group = par_pro_group;
      rcd_check_group csr_check_group%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Attempt to lock the process group row
      /* **notes** - waits until available
      /*-*/
      var_available := true;
      begin
         open csr_lics_pro_group;
         fetch csr_lics_pro_group into rcd_lics_pro_group;
         if csr_lics_pro_group%notfound then
            var_available := false;
         end if;
      exception
         when others then
            var_available := false;
      end;
      if csr_lics_pro_group%isopen then
         close csr_lics_pro_group;
      end if;

      /*-*/
      /* Check the process group for completion when available
      /*-*/
      if var_available = true then

         /*-*/
         /* Check for process group completion
         /*-*/
         var_completed := true;
         open csr_check_group;
         loop
            fetch csr_check_group into rcd_check_group;
            if csr_check_group%notfound then
               exit;
            end if;
            if rcd_check_group.prc_exist <> rcd_check_group.prt_exist then
               var_completed := false;
            end if;
         end loop;
         close csr_check_group;
         if var_completed = true then

            /**/
            /* Create the triggered process
            /**/
            lics_trigger_loader.execute(par_tri_function,
                                        par_tri_procedure,
                                        par_tri_opr_alert,
                                        par_tri_ema_group,
                                        par_tri_group);

            /**/
            /* Create the triggered process trace
            /**/
            insert into lics_pro_trace
               (prt_process,
                prt_date)
               values(par_tri_process,
                      par_pro_date);

         end if;

      end if;

      /*-*/
      /* Commit the database
      /*-*/
      commit;  

   /*-------------*/
   /* End routine */
   /*-------------*/
   end check_group;

   /***************************************************/
   /* This procedure performs the check group routine */
   /***************************************************/
   function check_group(par_pro_group in varchar2,
                        par_pro_date in varchar2,
                        par_tri_process in varchar2) return boolean is

      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;
      var_completed boolean;
      var_return boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_pro_group is 
         select t01.prg_group
           from lics_pro_group t01
          where t01.prg_group = par_pro_group
                for update;
      rcd_lics_pro_group csr_lics_pro_group%rowtype;

      cursor csr_check_group is
         select t01.prc_exist,
                decode(t02.prt_process,null,'N','Y') as prt_exist
           from lics_pro_check t01,
                (select t02.prt_process
                   from lics_pro_trace t02
                  where prt_date = par_pro_date) t02
          where t01.prc_process = t02.prt_process(+)
            and t01.prc_group = par_pro_group;
      rcd_check_group csr_check_group%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the return variable
      /*-*/
      var_return := false;

      /*-*/
      /* Attempt to lock the process group row
      /* **notes** - waits until available
      /*-*/
      var_available := true;
      begin
         open csr_lics_pro_group;
         fetch csr_lics_pro_group into rcd_lics_pro_group;
         if csr_lics_pro_group%notfound then
            var_available := false;
         end if;
      exception
         when others then
            var_available := false;
      end;
      if csr_lics_pro_group%isopen then
         close csr_lics_pro_group;
      end if;

      /*-*/
      /* Check the process group for completion when available
      /*-*/
      if var_available = true then

         /*-*/
         /* Check for process group completion
         /*-*/
         var_completed := true;
         open csr_check_group;
         loop
            fetch csr_check_group into rcd_check_group;
            if csr_check_group%notfound then
               exit;
            end if;
            if rcd_check_group.prc_exist <> rcd_check_group.prt_exist then
               var_completed := false;
            end if;
         end loop;
         close csr_check_group;
         if var_completed = true then

            /**/
            /* Create the triggered process trace
            /**/
            insert into lics_pro_trace
               (prt_process,
                prt_date)
               values(par_tri_process,
                      par_pro_date);

            /**/
            /* Set the triggered process trace
            /**/
            var_return := true;

         end if;

      end if;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return the result
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end check_group;

end lics_processing;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_processing for lics_app.lics_processing;
grant execute on lics_processing to public;