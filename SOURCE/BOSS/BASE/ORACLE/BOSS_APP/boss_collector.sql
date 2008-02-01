/*****************/
/* Package Types */
/*****************/
create or replace type boss_collector_table as table of varchar2(2000 char);
/

/******************/
/* Package Header */
/******************/
create or replace package boss_collector as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : boss
    Package : boss_collector
    Owner   : boss_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Business Operation Scorecard System - Measure Collector

    The package implements the oracle execution functionality for publishing
    scorecard measures. The measures are published as an XML stream:

      <boss_data>
        <measure parent="parent_code" code="measure_code" text="measure_text" type="measure_type" alert="measure_alert">
          <value><![CDATA[measure_value]]></value>
          <text><![CDATA[measure_text]]></text>
        </measure>
      </boss_data>

      Measure Types
        *SWITCH    = *ON or *OFF
        *DATE      = YYYYMMDD
        *TIMESTAMP = YYYYMMDDHH24MISS
        *NUMBER    = Any valid number and decimal places
        *PERCENT   = Any valid number and decimal places
        *STRING    = Any string upto 2000 characters

      Measure Alert
        *NO
        *YES

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/08   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public parent declarations
   /*-*/
   function get_output(par_procedure in varchar2) return boss_collector_table;

   /*-*/
   /* Public child put declarations
   /*-*/
   procedure put_switch(par_parent in varchar2,
                        par_code in varchar2,
                        par_text in varchar2,
                        par_value in boolean,
                        par_alert in boolean);
   procedure put_date(par_parent in varchar2,
                      par_code in varchar2,
                      par_text in varchar2,
                      par_value in date,
                      par_alert in boolean);
   procedure put_timestamp(par_parent in varchar2,
                           par_code in varchar2,
                           par_text in varchar2,
                           par_value in date,
                           par_alert in boolean);
   procedure put_number(par_parent in varchar2,
                        par_code in varchar2,
                        par_text in varchar2,
                        par_value in number,
                        par_alert in boolean);
   procedure put_percent(par_parent in varchar2,
                         par_code in varchar2,
                         par_text in varchar2,
                         par_value in number,
                         par_alert in boolean);
   procedure put_string(par_parent in varchar2,
                        par_code in varchar2,
                        par_text in varchar2,
                        par_value in varchar2,
                        par_alert in boolean);

end boss_collector;
/

/****************/
/* Package Body */
/****************/
create or replace package body boss_collector as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private child definitions
   /*-*/
   var_clob clob;
   var_position integer;

   /*-*/
   /* Private child declarations
   /*-*/
   procedure begin_output;
   procedure end_output;

   /**************************************************/
   /* This procedure performs the get output routine */
   /**************************************************/
   function get_output(par_procedure in varchar2) return boss_collector_table is

      /*-*/
      /* Local definitions
      /*-*/
      var_vir_table boss_collector_table := boss_collector_table();
      var_buffer varchar2(2000 char);
      var_size binary_integer := 2000;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameters
      /*-*/
      if par_procedure is null then
         raise_application_error(-20000, 'Get Output - Procedure must be supplied');
      end if;

      /*-*/
      /* Begin the output
      /*-*/
      begin_output;

      /*-*/
      /* Execute the output procedure
      /*-*/
      begin
         execute immediate 'begin ' || par_procedure || '; end;';
      exception
         when others then
            raise_application_error(-20000, 'Get Output - Procedure (' || par_procedure || ') failed - ' || substr(SQLERRM, 1, 3000));
      end;

      /*-*/
      /* End the output
      /*-*/
      end_output;

      /*-*/
      /* Retrieve the clob in 2000 character chunks
      /*-*/
      loop

         /*-*/
         /* Retrieve the next chunk
         /*-*/
         begin
            dbms_lob.read(var_clob, var_size, var_position, var_buffer);
            var_position := var_position + var_size;
         exception
            when no_data_found then
               var_position := -1;
         end;
         if var_position < 0 then
            exit;
         end if;

         /*-*/
         /* Append to the virtual table
         /*-*/
         var_vir_table.extend;
         var_vir_table(var_vir_table.last) := var_buffer;

      end loop;

      /*-*/
      /* Return the virtual table
      /*-*/
      return var_vir_table;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_output;

   /************************************/
   /* This procedure begins the output */
   /************************************/
   procedure begin_output is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the xml data
      /*-*/
      if var_clob is null then
         dbms_lob.createtemporary(var_clob,true);
      end if;
      dbms_lob.trim(var_clob,0);

      /*-*/
      /* Output the XML wrapper start
      /*-*/
      dbms_lob.writeappend(var_clob, length('<?xml version="1.0"?>'), '<?xml version="1.0"?>');
      dbms_lob.writeappend(var_clob, length('<boss_data>'), '<boss_data>');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end begin_output;

   /**********************************/
   /* This procedure ends the output */
   /**********************************/
   procedure end_output is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Output the XML wrapper end
      /*-*/
      dbms_lob.writeappend(var_clob, length('</boss_data>'), '</boss_data>');
      var_position := 1;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end end_output;

   /*****************************************/
   /* This procedure defines the put switch */
   /*****************************************/
   procedure put_switch(par_parent in varchar2,
                        par_code in varchar2,
                        par_text in varchar2,
                        par_value in boolean,
                        par_alert in boolean) is

      /*-*/
      /* Variable definitions
      /*-*/
      var_xml varchar2(4000 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Construct the value XML
      /*-*/
      var_xml := '<measure';
      var_xml := var_xml || ' code="' || par_code || '"';
      if par_parent is null then
         var_xml := var_xml || ' parent="*TOP"';
      else
         var_xml := var_xml || ' parent="' || par_parent || '"';
      end if;
      var_xml := var_xml || ' type="*SWITCH"';
      if par_alert = false then
         var_xml := var_xml || ' alert="*NO"';
      else
         var_xml := var_xml || ' alert="*YES"';
      end if;
      var_xml := var_xml || '>';
      var_xml := var_xml || '<value><![CDATA[';
      if par_value = false then
         var_xml := var_xml || '*OFF';
      else
         var_xml := var_xml || '*ON';
      end if;
      var_xml := var_xml || ']]></value>';
      var_xml := var_xml || '<text><![CDATA[' || par_text || ']]></text>';
      var_xml := var_xml || '</measure>';

      /*-*/
      /* Output the instruction XML
      /*-*/
      dbms_lob.writeappend(var_clob, length(var_xml), var_xml);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end put_switch;

   /***************************************/
   /* This procedure defines the put date */
   /***************************************/
   procedure put_date(par_parent in varchar2,
                      par_code in varchar2,
                      par_text in varchar2,
                      par_value in date,
                      par_alert in boolean) is

      /*-*/
      /* Variable definitions
      /*-*/
      var_xml varchar2(4000 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Construct the value XML
      /*-*/
      var_xml := '<measure';
      var_xml := var_xml || ' code="' || par_code || '"';
      if par_parent is null then
         var_xml := var_xml || ' parent="*TOP"';
      else
         var_xml := var_xml || ' parent="' || par_parent || '"';
      end if;
      var_xml := var_xml || ' type="*DATE"';
      if par_alert = false then
         var_xml := var_xml || ' alert="*NO"';
      else
         var_xml := var_xml || ' alert="*YES"';
      end if;
      var_xml := var_xml || '>';
      var_xml := var_xml || '<value><![CDATA[';
      var_xml := var_xml || to_char(par_value,'yyyymmdd');
      var_xml := var_xml || ']]></value>';
      var_xml := var_xml || '<text><![CDATA[' || par_text || ']]></text>';
      var_xml := var_xml || '</measure>';

      /*-*/
      /* Output the instruction XML
      /*-*/
      dbms_lob.writeappend(var_clob, length(var_xml), var_xml);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end put_date;

   /********************************************/
   /* This procedure defines the put timestamp */
   /********************************************/
   procedure put_timestamp(par_parent in varchar2,
                           par_code in varchar2,
                           par_text in varchar2,
                           par_value in date,
                           par_alert in boolean) is

      /*-*/
      /* Variable definitions
      /*-*/
      var_xml varchar2(4000 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Construct the value XML
      /*-*/
      var_xml := '<measure';
      var_xml := var_xml || ' code="' || par_code || '"';
      if par_parent is null then
         var_xml := var_xml || ' parent="*TOP"';
      else
         var_xml := var_xml || ' parent="' || par_parent || '"';
      end if;
      var_xml := var_xml || ' type="*TIMESTAMP"';
      if par_alert = false then
         var_xml := var_xml || ' alert="*NO"';
      else
         var_xml := var_xml || ' alert="*YES"';
      end if;
      var_xml := var_xml || '>';
      var_xml := var_xml || '<value><![CDATA[';
      var_xml := var_xml || to_char(par_value,'yyyymmddhh24miss');
      var_xml := var_xml || ']]></value>';
      var_xml := var_xml || '<text><![CDATA[' || par_text || ']]></text>';
      var_xml := var_xml || '</measure>';

      /*-*/
      /* Output the instruction XML
      /*-*/
      dbms_lob.writeappend(var_clob, length(var_xml), var_xml);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end put_timestamp;

   /*****************************************/
   /* This procedure defines the put number */
   /*****************************************/
   procedure put_number(par_parent in varchar2,
                        par_code in varchar2,
                        par_text in varchar2,
                        par_value in number,
                        par_alert in boolean) is

      /*-*/
      /* Variable definitions
      /*-*/
      var_xml varchar2(4000 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Construct the value XML
      /*-*/
      var_xml := '<measure';
      var_xml := var_xml || ' code="' || par_code || '"';
      if par_parent is null then
         var_xml := var_xml || ' parent="*TOP"';
      else
         var_xml := var_xml || ' parent="' || par_parent || '"';
      end if;
      var_xml := var_xml || ' type="*NUMBER"';
      if par_alert = false then
         var_xml := var_xml || ' alert="*NO"';
      else
         var_xml := var_xml || ' alert="*YES"';
      end if;
      var_xml := var_xml || '>';
      var_xml := var_xml || '<value><![CDATA[';
      var_xml := var_xml || to_char(par_value);
      var_xml := var_xml || ']]></value>';
      var_xml := var_xml || '<text><![CDATA[' || par_text || ']]></text>';
      var_xml := var_xml || '</measure>';

      /*-*/
      /* Output the instruction XML
      /*-*/
      dbms_lob.writeappend(var_clob, length(var_xml), var_xml);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end put_number;

   /******************************************/
   /* This procedure defines the put percent */
   /******************************************/
   procedure put_percent(par_parent in varchar2,
                         par_code in varchar2,
                         par_text in varchar2,
                         par_value in number,
                         par_alert in boolean) is

      /*-*/
      /* Variable definitions
      /*-*/
      var_xml varchar2(4000 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Construct the value XML
      /*-*/
      var_xml := '<measure';
      var_xml := var_xml || ' code="' || par_code || '"';
      if par_parent is null then
         var_xml := var_xml || ' parent="*TOP"';
      else
         var_xml := var_xml || ' parent="' || par_parent || '"';
      end if;
      var_xml := var_xml || ' type="*PERCENT"';
      if par_alert = false then
         var_xml := var_xml || ' alert="*NO"';
      else
         var_xml := var_xml || ' alert="*YES"';
      end if;
      var_xml := var_xml || '>';
      var_xml := var_xml || '<value><![CDATA[';
      var_xml := var_xml || to_char(par_value);
      var_xml := var_xml || ']]></value>';
      var_xml := var_xml || '<text><![CDATA[' || par_text || ']]></text>';
      var_xml := var_xml || '</measure>';

      /*-*/
      /* Output the instruction XML
      /*-*/
      dbms_lob.writeappend(var_clob, length(var_xml), var_xml);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end put_percent;

   /*****************************************/
   /* This procedure defines the put string */
   /*****************************************/
   procedure put_string(par_parent in varchar2,
                        par_code in varchar2,
                        par_text in varchar2,
                        par_value in varchar2,
                        par_alert in boolean) is

      /*-*/
      /* Variable definitions
      /*-*/
      var_xml varchar2(4000 char);
      var_string varchar2(4000 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Fix the value for XML
      /*-*/
      if length(par_value) > 2000 then
         var_string := substr(par_value,1,2000);
      else
         var_string := par_value;
      end if;

      /*-*/
      /* Construct the value XML
      /*-*/
      var_xml := '<measure';
      var_xml := var_xml || ' code="' || par_code || '"';
      if par_parent is null then
         var_xml := var_xml || ' parent="*TOP"';
      else
         var_xml := var_xml || ' parent="' || par_parent || '"';
      end if;
      var_xml := var_xml || ' type="*STRING"';
      if par_alert = false then
         var_xml := var_xml || ' alert="*NO"';
      else
         var_xml := var_xml || ' alert="*YES"';
      end if;
      var_xml := var_xml || '>';
      var_xml := var_xml || '<value><![CDATA[';
      var_xml := var_xml || to_char(var_string);
      var_xml := var_xml || ']]></value>';
      var_xml := var_xml || '<text><![CDATA[' || par_text || ']]></text>';
      var_xml := var_xml || '</measure>';

      /*-*/
      /* Output the instruction XML
      /*-*/
      dbms_lob.writeappend(var_clob, length(var_xml), var_xml);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end put_string;

end boss_collector;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
grant execute on boss_collector to public;