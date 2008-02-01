/*****************/
/* Package Types */
/*****************/
create or replace type boss_measure_object as object
   (hie_hierarchy                     varchar2(30 char),
    hie_description                   varchar2(128 char),
    obj_rownum                        number,
    obj_level                         number,
    obj_object                        varchar2(30 char),
    obj_description                   varchar2(128 char),
    obj_timestamp                     date,
    mea_rownum                        number,
    mea_level                         number,
    mea_measure                       varchar2(30 char),
    mea_description                   varchar2(128 char),
    mea_type                          varchar2(10 char),
    mea_alert                         varchar2(4 char),
    mea_value                         varchar2(2000 char));
/

create or replace type boss_measure_collection as table of boss_measure_object;
/


/******************/
/* Package Header */
/******************/
create or replace package boss_retrieval as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : boss
    Package : boss_retrieval
    Owner   : boss_app
    Author  : Steve Gregan

    Description
    -----------
    Business Operation Scorecard System - Retrieval Table Functions

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/08   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function get_measures(par_hierarchy in varchar2, par_parent in varchar2) return boss_measure_collection pipelined;

end boss_retrieval;
/

/****************/
/* Package Body */
/****************/
create or replace package body boss_retrieval as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /****************************************************/
   /* This procedure performs the get measures routine */
   /****************************************************/
   function get_measures(par_hierarchy in varchar2, par_parent in varchar2) return boss_measure_collection pipelined is

      /*-*/
      /* Declare Variables
      /*-*/
      var_hierarchy boss_hie_object.hio_hierarchy%type;
      var_parent boss_hie_object.hio_parent%type;

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor csr_hierarchy is
         select t01.hie_hierarchy as hie_hierarchy,
                t01.hie_description as hie_description,
                t02.obj_rownum as obj_rownum,
                t02.obj_level as obj_level,
                t02.obj_object as obj_object,
                t02.obj_description as obj_description,
                t02.obj_timestamp as obj_timestamp,
                t03.obm_rownum as mea_rownum,
                t03.obm_level as mea_level,
                t03.obm_measure as mea_measure,
                t03.obm_description as mea_description,
                t03.obm_type as mea_type,
                t03.obm_alert as mea_alert,
                t03.obm_value as mea_value
           from (select t01.hie_hierarchy,
                        t01.hie_description
                   from boss_hierarchy t01
                  where t01.hie_hierarchy = var_hierarchy) t01,
                (select t01.hio_hierarchy,
                        rownum as obj_rownum,
                        level as obj_level,
                        t01.hio_object as obj_object,
                        t02.obj_description,
                        t02.obj_sequence,
                        t02.obj_timestamp
                   from (select * from boss_hie_object where hio_hierarchy = var_hierarchy) t01,
                        boss_object t02
                  where t01.hio_object = t02.obj_object(+)
                  start with t01.hio_parent = var_parent
                connect by prior t01.hio_object = t01.hio_parent) t02,
                (select t01.obj_object,
                        rownum as obm_rownum,
                        level as obm_level,
                        t02.obm_measure,
                        t02.obm_description,
                        t02.obm_type,
                        t02.obm_alert,
                        t02.obm_value
                   from boss_object t01,
                        boss_obj_measure t02
                  where t01.obj_object = t02.obm_object(+)
                    and t01.obj_sequence = obm_sequence(+)
                  start with t02.obm_parent = '*TOP'
                connect by prior t02.obm_measure = t02.obm_parent) t03
          where t01.hie_hierarchy = t02.hio_hierarchy(+)
            and t02.obj_object = t03.obj_object(+)
          order by t02.obj_rownum asc,
                   t03.obm_rownum asc;
      rcd_hierarchy csr_hierarchy%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_hierarchy := par_hierarchy;
      if var_hierarchy is null then
         raise_application_error(-20000, 'Hierarchy code must be supplied');
      end if;
      var_parent := par_parent;
      if var_parent is null then
         var_parent := '*TOP';
      end if;

      /*-*/
      /* Retrieve the hierarchy dataand pipe to output
      /*-*/
      open csr_hierarchy;
      loop
         fetch csr_hierarchy into rcd_hierarchy;
         if csr_hierarchy%notfound then
            exit;
         end if;

         /*-*/
         /* Pipe the output to the consumer
         /*-*/
         pipe row(boss_measure_object(rcd_hierarchy.hie_hierarchy,
                                      rcd_hierarchy.hie_description,
                                      rcd_hierarchy.obj_rownum,
                                      rcd_hierarchy.obj_level,
                                      rcd_hierarchy.obj_object,
                                      rcd_hierarchy.obj_description,
                                      rcd_hierarchy.obj_timestamp,
                                      rcd_hierarchy.mea_rownum,
                                      rcd_hierarchy.mea_level,
                                      rcd_hierarchy.mea_measure,
                                      rcd_hierarchy.mea_description,
                                      rcd_hierarchy.mea_type,
                                      rcd_hierarchy.mea_alert,
                                      rcd_hierarchy.mea_value));

      end loop;
      close csr_hierarchy;

      /*-*/
      /* Return
      /*-*/  
      return;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'BOSS_RETRIEVAL - GET_MEASURES (' || nvl(par_hierarchy,'NULL') || ',' || nvl(par_parent,'NULL') || ') - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_measures;

end boss_retrieval;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym boss_retrieval for boss_app.boss_retrieval;
grant execute on boss_retrieval to public;
