CREATE OR REPLACE FORCE VIEW qv_app.qv_po_resource_hier (process_order,
                                                         resource_code,
                                                         hier_level
                                                        )
AS
   SELECT DISTINCT t01.process_order, t01.resource_code, '1' AS hier_level
              FROM infor.ash_actuals t01
   UNION ALL
   SELECT DISTINCT t01.process_order, t06.resource_code, '2' AS hier_level
              FROM infor.ash_actuals t01,
                   infor.ash_actual_relationships t02,
                   infor.ash_actuals t06
             WHERE t01.batch_code = t02.process_batch_code
               AND t02.tank_batch_code = t06.batch_code
   UNION ALL
   SELECT DISTINCT t01.process_order, t06.resource_code, '3' AS hier_level
              FROM infor.ash_actuals t01,
                   infor.ash_actual_relationships t02,
                   infor.ash_actual_relationships t03,
                   infor.ash_actuals t06
             WHERE t01.batch_code = t02.process_batch_code
               AND t02.tank_batch_code = t03.tank_batch_code
               AND t03.process_batch_code = t06.batch_code
               AND t03.flow_direction = 'PROCESS_TO_TANK'
   UNION ALL
   SELECT DISTINCT t01.process_order, t06.resource_code, '4' AS hier_level
              FROM infor.ash_actuals t01,
                   infor.ash_actual_relationships t02,
                   infor.ash_actual_relationships t03,
                   infor.ash_actual_relationships t04,
                   infor.ash_actuals t06
             WHERE t01.batch_code = t02.process_batch_code
               AND t02.tank_batch_code = t03.tank_batch_code
               AND t03.process_batch_code = t04.process_batch_code
               AND t04.tank_batch_code = t06.batch_code
               AND t03.flow_direction = 'PROCESS_TO_TANK'
               AND t04.flow_direction = 'TANK_TO_PROCESS'
   UNION ALL
   SELECT DISTINCT t01.process_order, t06.resource_code, '5' AS hier_level
              FROM infor.ash_actuals t01,
                   infor.ash_actual_relationships t02,
                   infor.ash_actual_relationships t03,
                   infor.ash_actual_relationships t04,
                   infor.ash_actual_relationships t05,
                   infor.ash_actuals t06
             WHERE t01.batch_code = t02.process_batch_code
               AND t02.tank_batch_code = t03.tank_batch_code
               AND t03.process_batch_code = t04.process_batch_code
               AND t04.tank_batch_code = t05.tank_batch_code
               AND t05.process_batch_code = t06.batch_code
               AND t03.flow_direction = 'PROCESS_TO_TANK'
               AND t04.flow_direction = 'TANK_TO_PROCESS'
               AND t05.flow_direction = 'PROCESS_TO_TANK';

