/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : qv
 Package : qv_purging
 Owner   : qv_app
 Author  : Trevor Keon

 DESCRIPTION
 -----------
 Qlikview Loader - Purging

 The package implements the purging functionality.

 **NOTES**
 ---------
 1. Only one instance of this package can execute at any one time to prevent
    database lock issues.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2010/09   Trevor Keon    Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package qv_purging as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_commit_count in number default null);

end qv_purging;
/

/****************/
/* Package Body */
/****************/
create or replace package body qv_purging as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure purge_csvqvs02;
   procedure purge_csvqvs03;

   /*-*/
   /* Private definitions
   /*-*/
   var_commit_count number;
   var_row_count number;
   
   /*-*/
   /* Private constants
   /*-*/   
   con_purging_group constant varchar2(32) := 'QV_PURGING';
   con_process_count constant number(5,0) := 10;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_commit_count in number default null) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the commit count parameter
      /*-*/
      var_commit_count := 1000000;
      if not(par_commit_count is null) then
         var_commit_count := par_commit_count;
      end if;

      /*-*/
      /* Purge the interfaces
      /*-*/
      purge_csvqvs02;
      
      purge_csvqvs03;
            
      /*-*/
      /* Commit the database when required
      /*-*/      
      commit;

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
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - QV Purging - ' || substr(SQLERRM, 1, 512));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /************************************************************/
   /* This procedure performs the purge for CSVQVS02 interface */
   /************************************************************/
   procedure purge_csvqvs02 is

      /*-*/
      /* Local definitions
      /*-*/
      var_date date;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_tp_budget_data is
         select min(calendar_date) as calendar_date
         from mars_date t01,
           (
             select year_num, 
                period_num
             from mars_date
             where calendar_date = add_months(trunc(sysdate), -3)
           ) t02
         where t01.year_num = t02.year_num
           and t01.period_num = t02.period_num;
      rcd_tp_budget_data csr_tp_budget_data%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      open csr_tp_budget_data;
      fetch csr_tp_budget_data into rcd_tp_budget_data;
      
      if csr_tp_budget_data%found then
        var_date := rcd_tp_budget_data.calendar_date;
      end if;
      
      close csr_tp_budget_data;
      
      delete
      from tp_budget_data
      where tbd_date < var_date;
      
      /*-*/
      /* Commit the database when required
      /*-*/
      if var_row_count >= var_commit_count then
         var_row_count := 0;
         commit;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_csvqvs02;
   
   procedure purge_csvqvs03 is
   
      /*-*/
      /* Local definitions
      /*-*/
      var_comments_history number;
      var_count number;
      var_available boolean;      
      
      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is
         select t01.qvc_id,
            t01.qvc_dashboard,
            t01.qvc_tab
         from qv_comments t01
         where qvc_remove_date < trunc(sysdate);
      rcd_header csr_header%rowtype;

      cursor csr_lock is
         select t01.qvc_id,
            t01.qvc_dashboard,
            t01.qvc_tab,
            t01.qvc_object,
            t01.qvc_date,
            t01.qvc_user,
            t01.qvc_comment
         from qv_comments t01
         where t01.qvc_id = rcd_header.qvc_id
            and t01.qvc_dashboard = rcd_header.qvc_dashboard
            and t01.qvc_tab = rcd_header.qvc_tab
         for update nowait;
      rcd_lock csr_lock%rowtype;      
   
   begin
   
      /*-*/
      /* Retrieve the history days
      /*-*/
      var_comments_history := to_number(lics_setting_configuration.retrieve_setting(con_purging_group, 'CSVQVS03_HIST'));
      
      /*-*/
      /* Retrieve the headers
      /*-*/
      var_count := 0;
      open csr_header;
      loop
         if var_count >= con_process_count then
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
            insert into qv_comments_history
            values
            (
               rcd_lock.qvc_dashboard,
               rcd_lock.qvc_tab,
               rcd_lock.qvc_object,
               rcd_lock.qvc_date,
               rcd_lock.qvc_user,
               sysdate,
               'QV_APP',
               rcd_lock.qvc_comment
            );
         
            delete 
            from qv_comments 
            where qvc_id = rcd_lock.qvc_id
               and qvc_dashboard = rcd_lock.qvc_dashboard
               and qvc_tab = rcd_lock.qvc_tab;    
         end if;

      end loop;
      close csr_header;
      
      delete
      from qv_comments_history
      where qch_date_removed < sysdate - var_comments_history;

      /*-*/
      /* Commit the database
      /*-*/
      commit;         
   
   /*-------------*/
   /* End routine */
   /*-------------*/   
   end purge_csvqvs03;

end qv_purging;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym qv_purging for qv_app.qv_purging;
grant execute on qv_purging to public;