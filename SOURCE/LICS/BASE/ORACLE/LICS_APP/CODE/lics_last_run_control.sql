/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics 
 Package : lics_last_run_control 
 Owner   : lics_app 
 Author  : Trevor Keon 

 DESCRIPTION 
 ----------- 
 Local Interface Control System - Last Run Control 

 The package manages the last run values for an interface 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lics_last_run_control as

   /*-*/
   /* Public declarations
   /*-*/
   function get_last_run(par_interface in varchar2) return date;
   procedure set_last_run(par_interface in varchar2, par_date in date);

end lics_last_run_control;

/****************/
/* Package Body */
/****************/
create or replace package body lics_last_run_control as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /****************************************************/
   /* This procedure performs the get last run routine */
   /****************************************************/
  function get_last_run(par_interface in varchar2) return date is
     
  /*-*/
  /* Local definitions 
  /*-*/
  var_result date;
     
  /*-------------*/
  /* Begin block */
  /*-------------*/   
  begin
    
    /*-*/
    /* Get the date 
    /*-*/
    select lsr_date
    into var_result
    from lics_last_run
    where lsr_interface = par_interface;
    
    return var_result;

  /*-----------------*/
  /* Exception block */
  /*-----------------*/         
  exception
    /*-*/
    /* Ignore no data errors 
    /*-*/  
    when no_data_found then
      return null;
            
  /*-------------*/
  /* End routine */
  /*-------------*/
  end get_last_run;
   
  procedure set_last_run(par_interface in varchar2, par_date in date) is

    /*-*/
    /* Autonomous transaction 
    /*-*/
    pragma autonomous_transaction;  
  
  begin

    /*-*/
    /* Update the new date  
    /*-*/   
    update lics_last_run
    set lsr_date = par_date
    where lsr_interface = par_interface;
    
    if ( sql%notfound ) then
      /*-*/
      /* Insert the interface row 
      /*-*/    
      insert into lics_last_run
      (
        lsr_interface,
        lsr_date
      )
      values
      (
        par_interface,
        par_date
      );
    end if;
    
    /*-*/
    /* Commit the database 
    /* note - isolated commit (autonomous transaction) 
    /*-*/   
    commit;
  
  end set_last_run;

end lics_last_run_control;

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_last_run_control for lics_app.lics_last_run_control;
grant execute on lics_last_run_control to public;