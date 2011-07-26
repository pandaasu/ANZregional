/******************/
/* Package Header */
/******************/
create or replace package lics_measure as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
    System  : lics
    Package : lics_measure
    Owner   : lics_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Local Interface Control System - Measure

    The package implements the measure functionality.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/08   Steve Gregan   Created
    2011/06   Ben Halicki    Removed BOSS monitoring functionality (no longer used)

*******************************************************************************/

   /*-*/
   /* Public parent declarations
   /*-*/
   procedure retrieve_backlog;

end lics_measure;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_measure as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure defines the retrieve backlog */
   /***********************************************/
   procedure retrieve_backlog is

      /*-*/
      /* Local definitions
      /*-*/
      var_sav_type varchar2(128);
      var_sav_count number;
      var_tot_count number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_backlog is
         select *
           from (select t01.hea_interface as backlog_code,
                        max(t02.int_description) as backlog_desc,
                        max(t02.int_type) as backlog_type,
                        max(t02.int_group) as backlog_group,
                        count(*) as backlog_count
                   from lics_header t01, lics_interface t02
                  where t01.hea_interface = t02.int_interface(+)
                    and t01.hea_status = '3'
                  group by t01.hea_interface
                  union all
                 select '*TRIGGER_'||t01.tri_group as backlog_code,
                        t01.tri_group||' - Triggered procedures' as backlog_desc,
                        '*TRIGGERED' as backlog_type,
                        t01.tri_group as backlog_group,
                        count(*) as backlog_count
                   from lics_triggered t01
                  group by t01.tri_group)
          order by backlog_type asc,
                   backlog_code asc;
      rcd_backlog csr_backlog%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the ICS backlog
      /*-*/
      var_sav_type := null;
      var_sav_count := 0;
      var_tot_count := 0;
      open csr_backlog;
      loop
         fetch csr_backlog into rcd_backlog;
         if csr_backlog%notfound then
            exit;
         end if;

         /*-*/
         /* Output the type backlog when required
         /*-*/
         if var_sav_type is null or var_sav_type != rcd_backlog.backlog_type then
            var_sav_type := rcd_backlog.backlog_type;
            var_sav_count := 0;
         end if;

         /*-*/
         /* Output the interface backlog
         /*-*/
         var_sav_count := var_sav_count + 1;
         var_tot_count := var_tot_count + 1;

      end loop;
      close csr_backlog;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_backlog;

end lics_measure;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_measure for lics_app.lics_measure;
grant execute on lics_measure to public;