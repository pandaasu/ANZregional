/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : qv 
 Package : qv_audit_control
  Owner  : qv_app
 Author  : Trevor Keon 

 DESCRIPTION 
 ----------- 
 Qlikview Loader - Audit Control 

 This package is used to add audit lines to the audit table for tracking of
 who uploaded a file and when.  

  PROCEDURE: ADD_AUDIT_LINE 

    1. PAR_INTERFACE - the interface that was used
    2. PAR_VERSION - the version that was loaded
    3. PAR_USER - the user who loaded the file for the interface
    
    The date is specified in this package.   

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2010/09   Trevor Keon    Created 

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package qv_audit_control as

   /*-*/
   /* Public declarations
   /*-*/
   procedure add_audit_line(par_interface varchar2, par_version number, par_user varchar2);

end qv_audit_control;
/

/****************/
/* Package Body */
/****************/
create or replace package body qv_audit_control as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);
   
  procedure add_audit_line(par_interface varchar2, par_version number, par_user varchar2) is

    /*-*/
    /* Autonomous transaction 
    /*-*/
    pragma autonomous_transaction;  
  
    /*-*/
    /* Local definitions 
    /*-*/
    var_date date := sysdate;
    var_audit_check number := 0;
  
  begin
  
    if par_interface is null then
      raise_application_error(-20000, 'Set User Session - Interface cannot be null.');
    elsif par_version is null then
      raise_application_error(-20000, 'Set User Session - Version cannot be null.');
    elsif par_user is null then
      raise_application_error(-20000, 'Set User Session - User cannot be null.');
    end if;     

    select count(*) into var_audit_check
    from qv_load_audit
    where qla_interface = par_interface
      and qla_version = par_version;
      
    if var_audit_check > 0 then
      raise_application_error(-20000, 'Set User Session - Audit line already exists.  Version = ' || par_version);
    end if;   
    
    insert into qv_load_audit
    (
      qla_interface,
      qla_version,
      qla_user,
      qla_date
    )
    values
    (
      par_interface,
      par_version,
      par_user,
      var_date
    );
    
    /*-*/
    /* Commit the database 
    /* note - isolated commit (autonomous transaction) 
    /*-*/   
    commit;
  
  end add_audit_line;

end qv_audit_control;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym qv_audit_control for qv_app.qv_audit_control;