create or replace package esched_app.esched_purging as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/** 
  System  : Electronic Schedule
  Package : esched_purging
  Owner   : esched_app
  Author  : Trevor Keon

  Description 
  ----------- 
  Electronic Schedule - Purging

  dd-mmm-yyyy  Author           Description 
  -----------  ------           ----------- 
  03-Dec-2008  Trevor Keon      Created 
*******************************************************************************/

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute;
   
end esched_purging; 
/

create or replace package body esched_app.esched_purging as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure purge_tolpdb02;

   /*-*/
   /* Private constants
   /*-*/
   con_purging_group constant varchar2(32) := 'ESCHED_PURGING';
   cnt_process_count constant number(5,0) := 10;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Purge the TOLPDB02 (inbound DCO factory transfers) 
      /*-*/
      purge_tolpdb02;

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
         raise_application_error(-20000, 'FATAL ERROR - Electronic Schedule - Purging - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;
   
  /******************************************************/
  /* This procedure performs the purge TOLPDB02 routine */
  /******************************************************/
  procedure purge_tolpdb02 is

    /*-*/
    /* Local definitions
    /*-*/
    var_history number;
    var_count number;
    var_available boolean;

    /*-*/
    /* Local cursors
    /*-*/
    cursor csr_header is
      select distinct t01.transmit_date, 
        t01.transmit_time, 
        t01.warehouse_ref
      from tolas_factryxfer t01
      where to_date(t01.transmit_date || t01.transmit_time, 'yyyymmddhh24miss') < sysdate - var_history;
    rcd_header csr_header%rowtype;  
    
    cursor csr_lock is
      select t01.transmit_date, 
        t01.transmit_time, 
        t01.warehouse_ref
      from tolas_factryxfer t01
      where t01.transmit_date = rcd_header.transmit_date
        and t01.transmit_time = rcd_header.transmit_time
        and t01.warehouse_ref = rcd_header.warehouse_ref
      for update nowait;
    rcd_lock csr_lock%rowtype;

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*-*/
    /* Retrieve the history days
    /*-*/
    var_history := to_number(lics_setting_configuration.retrieve_setting(con_purging_group, 'TOLPDB02'));

    /*-*/
    /* Retrieve the headers
    /*-*/
    var_count := 0;
    open csr_header;
    loop
      if var_count >= cnt_process_count then
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
      /* Delete the related data when available
      /*-*/
      if var_available = true then    
        delete
        from tolas_factryxfer
        where transmit_date = rcd_lock.transmit_date
          and transmit_time = rcd_lock.transmit_time
          and warehouse_ref = rcd_lock.warehouse_ref;   
      end if;

    end loop;
    close csr_header;

    /*-*/
    /* Commit the database
    /*-*/
    commit;

  /*-------------*/
  /* End routine */
  /*-------------*/
  end purge_tolpdb02;  
  
end esched_purging; 
/

/*-*/
/* Authority 
/*-*/
grant execute on esched_app.esched_purging to appsupport;
grant execute on esched_app.esched_purging to lics_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym esched_purging for esched_app.esched_purging;