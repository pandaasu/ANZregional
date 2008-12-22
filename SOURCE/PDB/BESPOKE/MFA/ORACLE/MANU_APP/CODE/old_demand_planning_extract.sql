DROP PROCEDURE MANU_APP.OLD_DEMAND_PLANNING_EXTRACT;

CREATE OR REPLACE PROCEDURE MANU_APP.old_Demand_Planning_Extract
IS

       ssql VARCHAR2(2000);
       path VARCHAR2(100);
       filename VARCHAR2(100);
       success NUMBER;
       period NUMBER;
       
       
       /****************************************************
       
       This function will query the database and dump the result set 
       into the Oracle default data directory on the Server
       A Kron Job will transfer this to the Novell Directory required by the users.
       
       J.Phillipson 23 Aug 2004 
       
       *******************************************************/
       
       
        /*********************************************
        RAISE email notification OF error
        **********************************************/
        PROCEDURE raiseNotification(message IN VARCHAR2)
        IS
     
            vmessage VARCHAR2(4000);
         
        BEGIN
           vmessage := message;
           Mailout(vmessage);
        EXCEPTION
            WHEN OTHERS THEN
            vmessage := message;
        END;
     
     
BEGIN

     /* check if last day of period */
     SELECT DECODE(MAX(period_num),'',0,MAX(period_num)) period
     INTO period
     FROM MARS_DATE
     WHERE calendar_date = TRUNC(SYSDATE);
    -- AND period_day_num = 27;

     --IF period > 0 THEN


         path := '/mfadw/LADS/prod/work';
         --path := '/tmp'; 
         
         filename := 'prdct5.txt';
    
         ssql := 'SELECT c.plant_code plant, c.line_code, '; 
         ssql := ssql ||  ' c.line_status LINE_STTS, ' ;
         ssql := ssql ||  ' c.SORT_SEQUENCE LINE_SORT_SQNC, '; 
         ssql := ssql ||  ' b.cluster_code CLSTR_CODE, '; 
         ssql := ssql ||  ' b.cluster_status CLSTR_STTS,'; 
         ssql := ssql ||  ' b.SORT_SEQUENCE CLSTR_SORT_SQNC, ';
         ssql := ssql ||  ' a.material_code MATL_CODE, '; 
         ssql := ssql ||  ' to_char(a.TRGT_WGHT) TRGT_WGHT'; 
         ssql := ssql ||  ' FROM SITE_MATL_CLUSTER_XREF a, '; 
         ssql := ssql ||  ' SITE_CLUSTER_MSTR b, '; 
         ssql := ssql ||  ' SITE_LINE c '; 
         ssql := ssql ||  ' WHERE a.cluster_code = b.cluster_code ';
         ssql := ssql ||  ' AND b.line_code = c.line_code '; 
     
         success := Dump_Csv(ssql, '', path, filename);
     
    
         DBMS_OUTPUT.PUT_LINE('Demand_Planning_Extract completed Sucsesfully on ' || SYSDATE || ' Records Transferred ' || success);
         
     
     
EXCEPTION
    WHEN OTHERS THEN
         raiseNotification('Unable to extract file because of: '|| SUBSTR(SQLERRM, 1, 512));
END;
/


