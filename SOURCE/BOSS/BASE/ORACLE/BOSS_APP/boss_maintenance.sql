/******************/
/* Package Header */
/******************/
create or replace package boss_maintenance as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : boss
    Package : boss_maintenance
    Owner   : boss_app
    Author  : Steve Gregan

    Description
    -----------
    Business Operation Scorecard System - Database Maintenance Functions

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/08   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function update_object(par_object in varchar2) return number;

end boss_maintenance;
/

/****************/
/* Package Body */
/****************/
create or replace package body boss_maintenance as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*****************************************************/
   /* This procedure performs the update object routine */
   /*****************************************************/
   function update_object(par_object in varchar2) return number is

      /*-*/
      /* Declare Variables
      /*-*/
      var_return number;
      var_object boss_object.obj_object%type;
      var_timestamp boss_object.obj_timestamp%type;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      if par_object is null then
         raise_application_error(-20000, 'Object code must be supplied');
      end if;
      var_object := upper(par_object);
      var_timestamp := sysdate;

      /*-*/
      /* Insert/Update the object
      /*-*/
      var_return := 1;
      begin
         insert into boss_object
            (obj_object,
             obj_description,
             obj_timestamp,
             obj_sequence)
         values
            (var_object,
             '*UNDEFINED',
             var_timestamp,
             1);
      exception
         when dup_val_on_index then
            update boss_object
               set obj_timestamp = var_timestamp,
                   obj_sequence = obj_sequence + 1
             where obj_object = var_object
         returning obj_sequence into var_return;
      end;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return var_return;

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
         raise_application_error(-20000, 'BOSS_MAINTENANCE - UPDATE_OBJECT (' || nvl(par_object,'NULL') || ') - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_object;

end boss_maintenance;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym boss_maintenance for boss_app.boss_maintenance;
grant execute on boss_maintenance to public;
