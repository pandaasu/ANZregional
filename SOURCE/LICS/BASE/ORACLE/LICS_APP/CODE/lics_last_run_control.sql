/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics 
 Package : lics_last_run_control 
  Owner  : lics_app 
 Author  : Trevor Keon 

 DESCRIPTION 
 ----------- 
 Local identifier Control System - Last Run Control 

 The package manages the last run values for an item (interface, job, etc).
 
  FUNCTION: GET_LAST_RUN 

    1. PAR_IDENTIFIER - the identifier to get the last successful run date.
      Returns null if the identifier does not exist. 

  PROCEDURE: SET_LAST_RUN 

    1. PAR_IDENTIFIER - the identifier to set the successful run date for 
    2. PAR_DATE - the date the identifier last ran successfully on 
       
    Inserts the identifier and date if it does not exist already  

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
   function get_last_run(par_identifier in varchar2) return date;
   procedure set_last_run(par_identifier in varchar2, par_date in date);

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
  function get_last_run(par_identifier in varchar2) return date is
     
  /*-*/
  /* Local definitions 
  /*-*/
  var_result date := null;
  
  /*-*/
  /* Local cursors 
  /*-*/
  cursor csr_lics_last_run is 
    select lsr_date
    from lics_last_run
    where lsr_identifier = par_identifier;
  rcd_lics_last_run csr_lics_last_run%rowtype;
     
  /*-------------*/
  /* Begin block */
  /*-------------*/   
  begin

    /*-*/
    /* Retrieve the next run date 
    /*-*/
    open csr_lics_last_run;
    fetch csr_lics_last_run into rcd_lics_last_run;
      if csr_lics_last_run%notfound then
        var_result := null;
      else
        var_result := rcd_lics_last_run.lsr_date;
      end if;    
    close csr_lics_last_run;
    
    return var_result;
            
  /*-------------*/
  /* End routine */
  /*-------------*/
  end get_last_run;
   
  procedure set_last_run(par_identifier in varchar2, par_date in date) is

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
    where lsr_identifier = par_identifier;
    
    if ( sql%notfound ) then
      /*-*/
      /* Insert the identifier row 
      /*-*/    
      insert into lics_last_run
      (
        lsr_identifier,
        lsr_date
      )
      values
      (
        par_identifier,
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