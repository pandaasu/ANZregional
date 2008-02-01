/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_locking
 Owner   : lics_app
 Author  : Steve Gregan - January 2005

 DESCRIPTION
 -----------
 Local Interface Control System - Locking

 The package implements the locking functionality.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lics_locking as

   /*-*/
   /* Public declarations
   /*-*/
   procedure request(par_lock in varchar2);
   procedure release(par_lock in varchar2);
   procedure cancel(par_lock in varchar2);


end lics_locking;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_locking as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the request routine */
   /***********************************************/
   procedure request(par_lock in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_lock varchar2(128);
      var_session varchar2(24);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_lock is
         select t01.loc_session,
                t01.loc_user,
                t01.loc_time
           from lics_lock t01
          where t01.loc_lock = var_lock;
      rcd_lics_lock csr_lics_lock%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Remove any expired locks (at least 2 days old)
      /*-*/
      delete from lics_lock where loc_time < (sysdate - 2);
      commit;

      /*-*/
      /* Set the parameter variables
      /*-*/
      var_lock := upper(par_lock);

      /*-*/
      /* Retrieve the session id
      /*-*/
      var_session := dbms_session.unique_session_id;

      /*-*/
      /* Check for an existing lock
      /*-*/
      open csr_lics_lock;
      fetch csr_lics_lock into rcd_lics_lock;
      if csr_lics_lock%found then
         raise_application_error(-20000, 'LICS_LOCKING - REQUEST - Lock (' || var_lock || ') is held by session/user/time (' || rcd_lics_lock.loc_session || '/' || rcd_lics_lock.loc_user || '/' || to_char(rcd_lics_lock.loc_time,'yyyymmddhh24miss') || ')');
      end if;
      close csr_lics_lock;

      /**/
      /* Create the lock
      /**/
      insert into lics_lock
         (loc_lock,
          loc_session,
          loc_user,
          loc_time)
         values(var_lock,
                var_session,
                user,
                sysdate);
      commit;  

   /*-------------*/
   /* End routine */
   /*-------------*/
   end request;

   /***********************************************/
   /* This procedure performs the release routine */
   /***********************************************/
   procedure release(par_lock in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_lock varchar2(128);
      var_session varchar2(24);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Remove any expired locks (at least 2 days old)
      /*-*/
      delete from lics_lock where loc_time < (sysdate - 2);
      commit;

      /*-*/
      /* Set the parameter variables
      /*-*/
      var_lock := upper(par_lock);

      /*-*/
      /* Retrieve the session id
      /*-*/
      var_session := dbms_session.unique_session_id;

      /*-*/
      /* Remove the requested lock
      /* **note - only same session can remove the lock
      /*-*/
      delete from lics_lock
       where loc_lock = var_lock
         and loc_session = var_session;
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end release;

   /**********************************************/
   /* This procedure performs the cancel routine */
   /**********************************************/
   procedure cancel(par_lock in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_lock varchar2(128);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Remove any expired locks (at least 2 days old)
      /*-*/
      delete from lics_lock where loc_time < (sysdate - 2);
      commit;

      /*-*/
      /* Set the parameter variables
      /*-*/
      var_lock := upper(par_lock);

      /*-*/
      /* Remove the requested lock
      /*-*/
      delete from lics_lock
       where loc_lock = var_lock;
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end cancel;

end lics_locking;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_locking for lics_app.lics_locking;
grant execute on lics_locking to public;