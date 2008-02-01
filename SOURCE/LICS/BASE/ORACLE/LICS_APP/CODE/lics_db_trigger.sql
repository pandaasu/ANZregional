/******************************************************************************/
/* Trigger Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_db_trigger
 Owner   : sys
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Interface Control System - Database Triggers

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2007/07   Steve Gregan   Changed restart jobs to dbms_job submit

*******************************************************************************/

create or replace trigger ics_startup after startup on database

   /*--------------*/
   /* Declarations */
   /*--------------*/
   declare

      /*-*/
      /* Variable definitions
      /*-*/
      var_logins varchar2(128);
      var_job_number binary_integer;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /**/
      /* Retrieve the database state
      /**/
      var_logins := null;
      begin
         select logins into var_logins from v$instance;
      exception
         when others then
            null;
      end;

      /**/
      /* Execute the restart job script when required
      /**/
      if var_logins <> 'RESTRICTED' then
         dbms_job.submit(var_job_number, 
                         'lics_job_control.restart_jobs;',
                         sysdate,
                         null);
      end if;

   end;