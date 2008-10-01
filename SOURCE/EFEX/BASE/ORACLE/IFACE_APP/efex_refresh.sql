CREATE OR REPLACE PACKAGE EFEX_REFRESH AS

PROCEDURE REFRESH_CUSTOMER(p_MarketID IN NUMBER);
PROCEDURE REFRESH_ITEM(p_MarketID IN NUMBER);
PROCEDURE REFRESH_ITEM_ORDER_BY(p_MarketID IN NUMBER);
PROCEDURE REFRESH_ITEM_ORDER_LIMITS(p_MarketID IN NUMBER);
PROCEDURE REFRESH_AU_SNACK_ITEM(p_MarketID IN NUMBER);
PROCEDURE REFRESH_CHINA_ITEM(p_MarketID IN NUMBER);
PROCEDURE REFRESH_CHINA_CUSTOMER(p_MarketID IN NUMBER);
PROCEDURE WRITE_LOG(par_text IN VARCHAR2);

END EFEX_REFRESH;
/

CREATE OR REPLACE PACKAGE BODY EFEX_REFRESH AS

   v_error_email  varchar2(100) := 'asia.pacific.efex.error.messages@ap.effem.com';
   var_log_type varchar2(32);
   var_log_line number; 
/******************************************************************************
*  NAME:       REFRESH_CUSTOMER
*  PURPOSE:    EFEX Customer REFESH PROCEDURE
*  REVISIONS:
*  Ver    Date        Author           Description
*  -----  ----------  ---------------  ------------------------------------
*  1.0    00-00-2005  GEOFF DODDS       Created View
*  1.1    01-08-2006  Toui Lepkhammany    Modified to refesh Hong Kong Customers
                                         This includes customer status
*  1.2    20-02-2008  Toui Lepkhammany  Mod: check for city and state being null
                                        in efex.customer.
                                        
******************************************************************************/
PROCEDURE REFRESH_CUSTOMER(p_MarketID IN NUMBER) IS

     --Cursor modified by T.L (1.1) to include status clause and other details clauses.
   CURSOR csrUpdateCust IS
   select b.customer_code, 
                     b.customer_name, 
                    b.address_1, 
                    b.city, 
                    b.state, 
                    b.cust_status
   from   customer a, iface.iface_customer b
   where  a.customer_code = b.customer_code
   and    (a.customer_name <> b.customer_name
                     --Include customers where their status are not the same  
                     or (a.status <> b.cust_status)
                    or upper(a.address_1) <> upper(b.address_1)
                    or a.city <> b.city 
                    or (a.city is null and b.city is not null)
                    or a.state <> b.state
                    or (a.state is null and b.state is not null))
   and    a.market_id = b.market_id
   and    a.market_id = p_MarketID;

BEGIN

   FOR iface_row IN csrUpdateCust LOOP
    --We are not updating Hong Kong Names until P10 2006
        if p_MarketID <> 3 then  
        update customer
        set    customer_name = iface_row.customer_name,
                       address_1 = iface_row.address_1,
                             city = iface_row.city,
                             state = iface_row.state
        where  customer_code = iface_row.customer_code
        and    market_id = p_MarketID;
        end if;
        
        --Check if the customer is a HK customer, if it is then update the extra bits
        if p_MarketID = 3 then
            update customer
          set    status = iface_row.cust_status
          where  customer_code = iface_row.customer_code
          and    market_id = p_MarketID;
        end if;
             
    update iface.iface_customer
      set    iface_status = 'UPDATED'
    where  customer_code = iface_row.customer_code
        and    market_id = p_MarketID;
  
    commit;

   END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    Send_Mail(v_error_email, 'eFEX Refresh Interface Error', 'Error in EFEX_REFRESH.REFRESH_CUSTOMER'||chr(13)||SQLERRM,NULL);
END REFRESH_CUSTOMER;

/******************************************************************************
*  NAME:       REFRESH_ITEM
*  PURPOSE:    EFEX Item REFESH PROCEDURE
*  REVISIONS:
*  Ver    Date        Author           Description
*  -----  ----------  ---------------  ------------------------------------
*  1.0    00-00-2005  GEOFF DODDS       Created View
*  1.1    07-08-2006  Toui Lepkhammany    Modified to refesh Hong Kong Item
*                                         This includes Item status and 

Item Category
*  1.2    06-06-2007  Toui Lepkhammany  Modified to include RTM changes and Snack field 
*                                        requirements.
*  1.3      18-07-2007  Toui Lepkhammany  Mod: to include Snack changes. mcu ean, tdu ean and 
*                                             pack_format
*  1.4    03/10/2007  Toui Lepkhammany  Mod: procedure excludes Australian Snackfood items.
*                                           These items are handled in the REFRESH_AU_SNACK_ITEM procedure
*  1.5    04/10/2007  Toui Lepkhammany  Mod: Changed efex.item price columns to match name changes
*  1.6    22/04/2008  Toui Lepkhammany  Mod: Changed the item select clause to check for NULL UOMs and NULL 

Order_source.
*  1.7    02/06/2008  Geoff Dodds       No refresh of ITEM_NAME and added ITEM_UNIT_NAME and ITEM_CASE_NAME
******************************************************************************/
PROCEDURE REFRESH_ITEM(p_MarketID IN NUMBER) IS

   v_zro5        NUMBER(10,2);
   v_units_case  NUMBER(4);
   v_mcu_per_tdu NUMBER(4);
   v_tdu_price1  NUMBER(10,2);
   v_mcu_price3  NUMBER(10,2);
   v_rsu_price4  NUMBER(10,2); 
   
   CURSOR csrUpdateItem IS
   SELECT b.item_code,
          b.item_name,
          b.rsu_ean_code,
          b.cases_layer,
          b.layers_pallet,
          b.units_case,
          b.mcu_per_tdu,
          b.unit_measure,
          b.price1,
          b.price2,
          b.brand,
          b.sub_brand,
          b.item_category, -- bus segment i.e. petcare, food, snackfood
          b.pack_size,
          b.pack_type,
          b.pack_format,
          b.item_status,
          b.product_category,
          b.market_category,
          b.market_subcategory,
          b.market_subcategory_group,
          b.item_source_id,
          b.mcu_ean_code,
          b.tdu_ean_code,
          b.item_tdu_name,
          b.item_mcu_name,
          b.item_rsu_name
   FROM   
          item a, 
          iface.iface_item b
   WHERE  
          a.item_code = b.item_code
     AND  (
              a.rsu_ean_code  <> b.rsu_ean_code
              OR a.cases_layer   <> b.cases_layer
              OR a.layers_pallet <> b.layers_pallet
              OR a.units_case    <> b.units_case
              OR (a.unit_measure  <> b.unit_measure OR a.unit_measure IS NULL)
              OR a.tdu_price        <> b.price1
              OR DECODE(a.rrp_price, null, 0, a.rrp_price) <> DECODE(b.price2, null, 0, b.price2)         

                                
                 OR a.brand         <> b.brand
              OR a.sub_brand     <> b.sub_brand
              OR a.item_category <> b.item_category             
              OR a.pack_size     <> b.pack_size
              OR a.pack_type     <> b.pack_type
              OR a.pack_format   <> b.pack_format
              OR a.status        <> DECODE(a.status, 'X', 'X', b.item_status) 
              OR NVL(a.product_category, ' ') <> b.product_category 
              OR a.market_category <> b.market_category
              OR a.market_subcategory <> b.market_subcategory
              OR a.market_subcategory_group <> b.market_subcategory_group
              OR (a.item_source_id <> b.item_source_id OR a.item_source_id IS NULL)
              OR a.mcu_ean_code <> b.mcu_ean_code
              OR a.tdu_ean_code <> b.tdu_ean_code
              OR NVL(a.item_tdu_name, ' ') <> b.item_tdu_name
              OR NVL(a.item_mcu_name, ' ') <> b.item_mcu_name
              OR NVL(a.item_rsu_name, ' ') <> b.item_rsu_name
          )
     AND  a.market_id = b.market_id
     AND  a.market_id = p_MarketID;

BEGIN

   FOR iface_row IN csrUpdateItem LOOP
   
      v_zro5 := iface_row.price1;
      v_units_case := iface_row.units_case;
      v_mcu_per_tdu := iface_row.mcu_per_tdu;
      
      -- Do Snack Item Price Calculations
      v_tdu_price1 := v_zro5;
      v_mcu_price3 := v_tdu_price1 / v_mcu_per_tdu;
      v_rsu_price4 := v_tdu_price1 / v_units_case; 
          
      -- Check for the Australian Market
      IF (p_MarketID = 1) THEN
          -- Don't process Australian Snackfood items here.
          IF (iface_row.item_category <> 'Snackfood') THEN
              UPDATE item
                 SET rsu_ean_code     = iface_row.rsu_ean_code,
                     cases_layer      = iface_row.cases_layer,
                     layers_pallet    = iface_row.layers_pallet,
                     units_case       = iface_row.units_case,
			         tdu_price        = v_tdu_price1,
			         rrp_price        = iface_row.price2,
			 		 mcu_price        = v_mcu_price3,
			 		 rsu_price        = v_rsu_price4,
			         brand            = iface_row.brand,
			         sub_brand        = iface_row.sub_brand,
		             item_category    = iface_row.item_category,
		             pack_size        = iface_row.pack_size,
			         pack_type        = iface_row.pack_type,
                     pack_format      = iface_row.pack_format,
			         status           = DECODE(status, 'X', 'X', iface_row.item_status),
		             product_category = iface_row.product_category,
			         market_category  = iface_row.market_category,
			         market_subcategory = iface_row.market_subcategory,
		             item_source_id   = iface_row.item_source_id,
					 mcu_ean_code     = iface_row.mcu_ean_code,
					 tdu_ean_code     = iface_row.tdu_ean_code,
					 item_tdu_name    = iface_row.item_tdu_name,			 	

		 			 				             			 
					 item_mcu_name    = iface_row.item_mcu_name,			 	

		 			 				             			 
					 item_rsu_name    = iface_row.item_rsu_name			 	

		 			 				             			 
		      WHERE  item_code = iface_row.item_code
		        AND  market_id = p_MarketID;	
					  
		      UPDATE iface.iface_item
		         SET iface_status = 'UPDATED'
		       WHERE item_code = iface_row.item_code
			     AND market_id = p_MarketID;
		  
		      COMMIT;
		  END IF;
	  ELSE
	      --Update other Market's Item details (e.g. 3 for Hong Kong)
		  UPDATE item
	         SET item_name     = iface_row.item_name,
	             rsu_ean_code  = iface_row.rsu_ean_code,
	             cases_layer   = iface_row.cases_layer,
	             layers_pallet = iface_row.layers_pallet,
	             units_case    = iface_row.units_case,
		         tdu_price        = iface_row.price1,
		         rrp_price        = iface_row.price2,
		         brand         = iface_row.brand,
		         sub_brand     = iface_row.sub_brand,
	             item_category = iface_row.item_category,
	             pack_size     = iface_row.pack_size,
		         pack_type     = iface_row.pack_type,
		         status        = iface_row.item_status,
	             product_category = iface_row.product_category,
		         market_category  = iface_row.market_category,
		         market_subcategory = iface_row.market_subcategory,
	             item_source_id   = iface_row.item_source_id,
			     mcu_ean_code  = iface_row.mcu_ean_code,
				 tdu_ean_code  = iface_row.tdu_ean_code					 	

		 			 				             			 
	      WHERE  item_code = iface_row.item_code
	        AND  market_id = p_MarketID;	
				  
	      UPDATE iface.iface_item
	         SET iface_status = 'UPDATED'
	       WHERE item_code = iface_row.item_code
		     AND market_id = p_MarketID;
	  
	      COMMIT;	  
	  END IF;

   END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    Send_Mail(v_error_email, 'eFEX Refresh Interface Error', 'Error in EFEX_REFRESH.REFRESH_ITEM'||chr(13)

||SQLERRM,NULL);
END REFRESH_ITEM;

/******************************************************************************
   NAME:       Refresh Item Order By
   PURPOSE:    Refreshes IFACE_Item's Order_By status ("L" - Layer, "P" - Pallet) 
               based on Brand Flag and product_category combination defined in table IFACE_APP.ITEM_BRAND_ORDERBY.

   REVISIONS:
   Ver     Date        Author           Description
   ------  ----------  ---------------  ------------------------------------
   1.0     08/06/2007  Toui Lepkhammany Initial Version

******************************************************************************/
PROCEDURE REFRESH_ITEM_ORDER_BY(p_MarketID IN NUMBER) IS

   CURSOR csrItemBrandOrderByStatus IS
   SELECT ii.item_code,
          ibo.brand,
          ibo.product_category,
          ibo.order_by
   FROM   
          item_brand_orderby ibo,
          iface.iface_item ii
   WHERE  
          ibo.status = 'A'
     AND  ibo.brand = ii.brand
     AND  ibo.product_category = ii.product_category
     AND  ibo.market_id = p_MarketID;
          
BEGIN

   FOR item_brand_row IN csrItemBrandOrderByStatus LOOP
       
       UPDATE
           iface.iface_item
       SET            
           order_by = item_brand_row.order_by,
           iface_status = 'UPDATED'
       WHERE
           iface.iface_item.item_code = item_brand_row.item_code;
                                     
       COMMIT;
                                
   END LOOP;
    
EXCEPTION
  WHEN OTHERS THEN
    Send_Mail(v_error_email, 'eFEX Refresh Interface Error', 'Error in EFEX_REFRESH.REFRESH_ITEM_ORDER_BY'||chr(13)||SQLERRM,NULL);
END REFRESH_ITEM_ORDER_BY;

/******************************************************************************
*  NAME:       REFRESH_ITEM_ORDER LIMITS
*  PURPOSE:    EFEX Item REFESH ORDER LIMITS PROCEDURE. 
*              This procedure updates an items min_order_qty and order multiples
*              figure based on whether the item can only be ordered by Layer "L" or
*              pallet "P".  
*  REVISIONS:
*  Ver    Date        Author           Description
*  -----  ----------  ---------------  ------------------------------------
*  1.0    08-06-2007  Toui Lepkhammany  Created View
******************************************************************************/
PROCEDURE REFRESH_ITEM_ORDER_LIMITS(p_MarketID IN NUMBER) IS

   CURSOR csrUpdateItemOrderLimits IS
   SELECT b.item_code,
          b.item_name,
          b.cases_layer,
          b.layers_pallet,
          b.units_case,
          b.unit_measure,
          b.order_by
   FROM   
          item a, 
          iface.iface_item b
   WHERE  
          a.item_code = b.item_code
     AND  (b.order_by = 'L' OR b.order_by = 'P')
     AND  a.market_id = b.market_id
     AND  a.market_id = p_MarketID;

BEGIN

   FOR iface_row IN csrUpdateItemOrderLimits LOOP
      
      --Update min_order_gty and order_multiples based on order_by flag = 'L'
       IF iface_row.order_by = 'L' THEN
           UPDATE 
               item
           SET  
               min_order_qty = iface_row.cases_layer,
               order_multiples = iface_row.cases_layer
           WHERE
               item_code = iface_row.item_code
           AND    
               market_id = p_MarketID;
       END IF;

       --Update min_order_gty and order_multiples based on order_by flag = 'P'
       IF iface_row.order_by = 'P' THEN
           UPDATE 
               item
           SET  
               min_order_qty = iface_row.cases_layer * iface_row.layers_pallet,
               order_multiples = iface_row.cases_layer * iface_row.layers_pallet
           WHERE
               item_code = iface_row.item_code
           AND    
               market_id = p_MarketID;
       END IF;
              
       UPDATE iface.iface_item
       SET 
           iface_status = 'UPDATED'
       WHERE 
           item_code = iface_row.item_code
       AND 
           market_id = p_MarketID;
  
      COMMIT;

   END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    Send_Mail(v_error_email, 'eFEX Refresh Interface Error', 'Error in EFEX_REFRESH.REFRESH_ITEM_ORDER_LIMITS'||chr(13)||SQLERRM,NULL);
END REFRESH_ITEM_ORDER_LIMITS;

/******************************************************************************
*  NAME:       REFRESH_AU_SNACK_ITEM
*  PURPOSE:    EFEX Item Refreshes Australian Snackfood items and calculates 
*              TDU price (item.price1), MCU price (item.price3) and RSU price (item.price4)
*  REVISIONS:
*  Ver    Date        Author           Description
*  -----  ----------  ---------------  ------------------------------------
*  1.0    03/10/2007  Toui Lepkhammany Created Procedure.
*  1.1    04/10/2007  Toui Lepkhammany Mod: Changed efex.item price columns to match name changes
*  1.2    02/06/2008  Geoff Dodds       No refresh of ITEM_NAME and added ITEM_UNIT_NAME and ITEM_CASE_NAME
******************************************************************************/
PROCEDURE REFRESH_AU_SNACK_ITEM(p_MarketID IN NUMBER) IS

   v_zro5        NUMBER(10,2);
   v_units_case  NUMBER(4);
   v_mcu_per_tdu NUMBER(4);
   v_tdu_price1  NUMBER(10,2);
   v_mcu_price3  NUMBER(10,2);
   v_rsu_price4  NUMBER(10,2); 


   CURSOR csrUpdateItem IS
   SELECT b.item_code,
          b.item_name,
		  b.rsu_ean_code,
		  b.cases_layer,
		  b.layers_pallet,
		  b.units_case,
		  b.mcu_per_tdu,
		  b.unit_measure,
		  b.price1,
		  b.price2,
          b.brand,
          b.sub_brand,
          b.item_category,
          b.pack_size,
		  b.pack_type,
          b.pack_format,
          b.item_status,
		  b.product_category,
		  b.market_category,
		  b.market_subcategory,
		  b.market_subcategory_group,
		  b.item_source_id,
          b.mcu_ean_code,
          b.tdu_ean_code,
		  b.item_tdu_name,
		  b.item_mcu_name,
		  b.item_rsu_name
   FROM   
          item a, 
          iface.iface_item b
   WHERE  
          a.item_code = b.item_code
     AND  (
              a.rsu_ean_code  <> b.rsu_ean_code
              OR a.cases_layer   <> b.cases_layer
              OR a.layers_pallet <> b.layers_pallet
              OR a.units_case    <> b.units_case
              OR a.unit_measure  <> b.unit_measure
              OR a.tdu_price        <> TO_NUMBER(TO_CHAR((b.price1/(1-(13/100))),'9999999.99'), '999999.99') 

--convert snack's GSV price to TDU price.
              OR DECODE(a.rrp_price, null, 0, a.rrp_price) <> DECODE(b.price2, null, 0, b.price2)	 	

		  			  		
   	          OR a.brand         <> b.brand
              OR a.sub_brand     <> b.sub_brand
              OR a.item_category <> b.item_category			 
              OR a.pack_size     <> b.pack_size
              OR a.pack_type     <> b.pack_type
              OR a.pack_format   <> b.pack_format
		      OR a.status        <> DECODE(a.status, 'X', 'X', b.item_status) 
			  OR NVL(a.product_category, ' ') <> b.product_category 
			  OR a.market_category <> b.market_category
              OR a.market_subcategory <> b.market_subcategory
              OR a.market_subcategory_group <> b.market_subcategory_group
			  OR a.item_source_id <> b.item_source_id
              OR a.mcu_ean_code <> b.mcu_ean_code
			  OR a.tdu_ean_code <> b.tdu_ean_code
			  OR NVL(a.item_tdu_name, ' ') <> b.item_tdu_name
			  OR NVL(a.item_mcu_name, ' ') <> b.item_mcu_name
			  OR NVL(a.item_rsu_name, ' ') <> b.item_rsu_name
          )
     AND  a.market_id = b.market_id
	 AND  a.item_category = 'Snackfood'
     AND  a.market_id = p_MarketID;

BEGIN

   FOR iface_row IN csrUpdateItem LOOP
   
      v_zro5 := iface_row.price1;
	  v_units_case := iface_row.units_case;
	  v_mcu_per_tdu := iface_row.mcu_per_tdu;
	  
	  -- Do Snack Item Price Calculations
	  v_tdu_price1 := v_zro5 / (1-(13/100));
	  v_mcu_price3 := v_tdu_price1 / v_mcu_per_tdu;
	  v_rsu_price4 := v_tdu_price1 / v_units_case;
	     
	  UPDATE item
         SET rsu_ean_code     = iface_row.rsu_ean_code,
             cases_layer      = iface_row.cases_layer,
             layers_pallet    = iface_row.layers_pallet,
             units_case       = iface_row.units_case,
			 unit_measure     = iface_row.unit_measure,
	         tdu_price        = v_tdu_price1,
	         rrp_price        = iface_row.price2,
			 mcu_price        = v_mcu_price3,
			 rsu_price        = v_rsu_price4,
	         brand            = iface_row.brand,
	         sub_brand        = iface_row.sub_brand,
             item_category    = iface_row.item_category,
             pack_size        = iface_row.pack_size,
	         pack_type        = iface_row.pack_type,
             pack_format      = iface_row.pack_format,
	         status           = DECODE(status, 'X', 'X', iface_row.item_status),
             product_category = iface_row.product_category,
	         market_category  = iface_row.market_category,
	         market_subcategory = iface_row.market_subcategory,
			 item_source_id   = iface_row.item_source_id,
			 mcu_ean_code     = iface_row.mcu_ean_code,
			 tdu_ean_code     = iface_row.tdu_ean_code,
			 item_tdu_name    = iface_row.item_tdu_name,			 			

 			 				             			 
			 item_mcu_name    = iface_row.item_mcu_name,			 			

 			 				             			 
			 item_rsu_name    = iface_row.item_rsu_name			 			

 			 				             			 	 		

	 			 				             			 
      WHERE  item_code = iface_row.item_code
        AND  market_id = p_MarketID;	
					  
      UPDATE iface.iface_item
         SET iface_status = 'UPDATED'
       WHERE item_code = iface_row.item_code
	     AND market_id = p_MarketID;
		  
      COMMIT;

   END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    Send_Mail(v_error_email, 'eFEX Refresh Interface Error', 'Error in EFEX_REFRESH.REFRESH_ITEM'||chr(13)

||SQLERRM,NULL);
END REFRESH_AU_SNACK_ITEM;

/******************************************************************************
*  NAME:       REFRESH_CHINA_ITEM
*  PURPOSE:    EFEX China Item REFESH PROCEDURE
*  REVISIONS:
*  Ver    Date        Author           Description
*  -----  ----------  ---------------  ------------------------------------
*  1.0    17-08-2008  Steve Gregan     Created from REFRESH_ITEM 
******************************************************************************/
PROCEDURE REFRESH_CHINA_ITEM(p_MarketID IN NUMBER) IS

   CURSOR csrUpdateItem IS
   SELECT b.item_code,
          b.item_name,
          b.rsu_ean_code,
          b.cases_layer,
          b.layers_pallet,
          decode(b.units_case,null,1,0,1,b.units_case) as units_case,
          decode(b.mcu_per_tdu,null,1,0,1,b.mcu_per_tdu) as mcu_per_tdu,
          b.unit_measure,
          b.price1,
          b.price2,
          b.brand,
          b.sub_brand,
          b.item_category,
          b.pack_size,
          b.pack_type,
          b.pack_format,
          b.item_status
   FROM   
          item a, 
          iface.iface_item b
   WHERE  
          a.item_code = b.item_code
     AND  (
              a.rsu_ean_code     <> b.rsu_ean_code
              OR a.cases_layer   <> b.cases_layer
              OR a.layers_pallet <> b.layers_pallet
              OR nvl(a.units_case,0) <> decode(b.units_case,null,1,0,1,b.units_case)
              OR nvl(a.mcu_per_tdu,0) <> decode(b.mcu_per_tdu,null,1,0,1,b.mcu_per_tdu)
              OR (a.unit_measure <> b.unit_measure OR a.unit_measure IS NULL)
              OR a.tdu_price     <> b.price1
              OR DECODE(a.rrp_price, null, 0, a.rrp_price) <> DECODE(b.price2, null, 0, b.price2)         
              OR a.brand         <> b.brand
              OR a.sub_brand     <> b.sub_brand
              OR a.item_category <> b.item_category             
           --   OR a.pack_size   <> b.pack_size
              OR a.pack_type     <> b.pack_type
              OR a.pack_format   <> b.pack_format
              OR a.status        <> DECODE(a.status, 'X', 'X', b.item_status) 
          )
     AND  a.market_id = b.market_id
     AND  a.market_id = p_MarketID;

BEGIN

   FOR iface_row IN csrUpdateItem LOOP

      UPDATE item
         SET item_name = iface_row.item_name,
             rsu_ean_code = iface_row.rsu_ean_code,
             cases_layer = iface_row.cases_layer,
             layers_pallet = iface_row.layers_pallet,
             units_case = iface_row.units_case,
             mcu_per_tdu = iface_row.mcu_per_tdu,
             tdu_price = iface_row.price1,
             rrp_price = iface_row.price2,
             mcu_price = round(iface_row.price1/iface_row.mcu_per_tdu,2),
             rsu_price = round(iface_row.price1/iface_row.units_case,2),
             brand = iface_row.brand,
             sub_brand = iface_row.sub_brand,
             item_category = iface_row.item_category,
        --   pack_size = iface_row.pack_size,
             pack_type = iface_row.pack_type,
            status = iface_row.item_status				 				 				             			 
      WHERE item_code = iface_row.item_code
        AND market_id = p_MarketID;	
				  
     UPDATE iface.iface_item
        SET iface_status = 'UPDATED'
      WHERE item_code = iface_row.item_code
        AND market_id = p_MarketID;
	  
      COMMIT;	  

   END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    Send_Mail(v_error_email, 'eFEX Refresh Interface Error', 'Error in EFEX_REFRESH.REFRESH_CHINA_ITEM'||chr(13)

||SQLERRM,NULL);
END REFRESH_CHINA_ITEM;

/******************************************************************************
*  NAME:       REFRESH_CHINA_CUSTOMER
*  PURPOSE:    EFEX China Customer REFESH PROCEDURE
*  REVISIONS:
*  Ver    Date        Author           Description
*  -----  ----------  ---------------  ------------------------------------
*  1.0    17-08-2008  Steve Gregan     Created from REFRESH_CUSTOMER                               
******************************************************************************/
PROCEDURE REFRESH_CHINA_CUSTOMER(p_MarketID IN NUMBER) IS

   bol_update boolean;
   var_affiliation_id number;
   var_cust_type_id number;
   var_cust_contact_id number;

   cursor csr_iface_customer is
      select a.geo_level1_code,
             a.geo_level2_code,
             a.geo_level3_code,
             a.geo_level4_code,
             a.geo_level5_code,
             a.geo_level1_name,
             a.geo_level2_name,
             a.geo_level3_name,
             a.geo_level4_name,
             a.geo_level5_name,
             a.std_level1_code,
             a.std_level2_code,
             a.std_level3_code,
             a.std_level4_code,
             a.std_level1_name,
             a.std_level2_name,
             a.std_level3_name,
             a.std_level4_name
        from iface.iface_customer a
       where a.market_id = p_MarketID;
   rcd_iface_customer csr_iface_customer%rowtype;

   cursor csr_customer is
      select a.customer_id,
             a.business_unit_id,
             a.affiliation_id,
             a.cust_type_id,
             a.customer_name as old_customer_name, 
             a.address_1 as old_address_1, 
             a.city as old_city, 
             a.state as old_state, 
             a.status as old_status,
             a.outlet_location as old_outlet_location,
             a.geo_level1_code as old_geo_level1_code,
             a.geo_level2_code as old_geo_level2_code,
             a.geo_level3_code as old_geo_level3_code,
             a.geo_level4_code as old_geo_level4_code,
             a.geo_level5_code as old_geo_level5_code,
             a.std_level1_code as old_std_level1_code,
             a.std_level2_code as old_std_level2_code,
             a.std_level3_code as old_std_level3_code,
             a.std_level4_code as old_std_level4_code,
             a.distributor_flg as old_distributor_flg,
             b.customer_code, 
             b.customer_name, 
             b.address_1, 
             b.city, 
             b.state, 
             b.cust_status,
             b.contact_name,
             b.sales_person_code,
             b.sales_person_name,
             b.outlet_location,
             b.cust_type,
             b.affiliation,
             b.geo_level1_code,
             b.geo_level2_code,
             b.geo_level3_code,
             b.geo_level4_code,
             b.geo_level5_code,
             b.geo_level1_name,
             b.geo_level2_name,
             b.geo_level3_name,
             b.geo_level4_name,
             b.geo_level5_name,
             b.std_level1_code,
             b.std_level2_code,
             b.std_level3_code,
             b.std_level4_code,
             b.std_level1_name,
             b.std_level2_name,
             b.std_level3_name,
             b.std_level4_name,
             b.distributor_flg
        from customer a,
             iface.iface_customer b
       where a.customer_code = b.customer_code
         and a.market_id = b.market_id
         and a.market_id = p_MarketID;
   rcd_customer csr_customer%rowtype;

   cursor csr_affiliation is
      select t01.*
        from affiliation t01,
             affiliation_group t02
       where t01.affiliation_group_id = t02.affiliation_group_id
         and t02.business_unit_id = rcd_customer.business_unit_id
         and t01.affiliation_name_en = rcd_customer.affiliation;
   rcd_affiliation csr_affiliation%rowtype;

   cursor csr_cust_type is
      select t01.*
        from cust_type t01,
             cust_trade_channel t02,
             cust_channel t03
       where t01.cust_trade_channel_id = t02.cust_trade_channel_id
         and t02.cust_channel_id = t03.cust_channel_id
         and t03.business_unit_id = rcd_customer.business_unit_id
         and t01.cust_type_name_en = rcd_customer.cust_type;
   rcd_cust_type csr_cust_type%rowtype;

   cursor csr_cust_contact is 
      select t01.*
        from cust_contact t01
       where t01.customer_id = rcd_customer.customer_id
         and t01.status = 'A'
       order by t01.cust_contact_id asc;
   rcd_cust_contact csr_cust_contact%rowtype;

   cursor csr_users is 
      select t03.*
        from (select t01.sales_territory_id
                from (select t01.sales_territory_id,
                             rank() over (partition by t01.customer_id
                                              order by t01.sales_territory_id) as rnkseq
                        from cust_sales_territory t01
                       where t01.customer_id = rcd_customer.customer_id
                         and t01.status = 'A'
                         and t01.primary_flg = 'Y') t01
               where t01.rnkseq = 1) t01,
             sales_territory t02,
             users t03
       where t01.sales_territory_id = t02.sales_territory_id
         and t02.user_id = t02.user_id;
   rcd_users csr_users%rowtype;

   cursor csr_geo_hierarchy is
      select t01.*
        from geo_hierarchy t01
       where t01.geo_level1_code = rcd_iface_customer.geo_level1_code
         and t01.geo_level2_code = rcd_iface_customer.geo_level2_code
         and t01.geo_level3_code = rcd_iface_customer.geo_level3_code
         and t01.geo_level4_code = rcd_iface_customer.geo_level4_code
         and t01.geo_level5_code = rcd_iface_customer.geo_level5_code;
   rcd_geo_hierarchy csr_geo_hierarchy%rowtype;

   cursor csr_standard_hierarchy is
      select t01.*
        from standard_hierarchy t01
       where t01.std_level1_code = rcd_iface_customer.std_level1_code
         and t01.std_level2_code = rcd_iface_customer.std_level2_code
         and t01.std_level3_code = rcd_iface_customer.std_level3_code
         and t01.std_level4_code = rcd_iface_customer.std_level4_code;
   rcd_standard_hierarchy csr_standard_hierarchy%rowtype;

BEGIN

   --
   -- clear the log
   --
   var_log_type := 'CHINA_CUSTOMER';
   var_log_line := 0;
   delete from iface_log where log_type = var_log_type;
   commit;

   --
   -- retrieve the IFACE customer data
   --
   open csr_iface_customer;
   loop
      fetch csr_iface_customer into rcd_iface_customer;
      if csr_iface_customer%notfound then
         exit;
      end if;

      --
      -- if geo hierarchy does not exist then insert
      -- if any geo hierarchy names are different then update
      --
      if (not(rcd_iface_customer.geo_level1_code is null) and
          not(rcd_iface_customer.geo_level2_code is null) and
          not(rcd_iface_customer.geo_level3_code is null) and
          not(rcd_iface_customer.geo_level4_code is null) and
          not(rcd_iface_customer.geo_level5_code is null)) then
         open csr_geo_hierarchy;
         fetch csr_geo_hierarchy into rcd_geo_hierarchy;
         if csr_geo_hierarchy%notfound then
            insert into geo_hierarchy
               values(rcd_iface_customer.geo_level1_code,
                      rcd_iface_customer.geo_level2_code,
                      rcd_iface_customer.geo_level3_code,
                      rcd_iface_customer.geo_level4_code,
                      rcd_iface_customer.geo_level5_code,
                      rcd_iface_customer.geo_level1_name,
                      rcd_iface_customer.geo_level2_name,
                      rcd_iface_customer.geo_level3_name,
                      rcd_iface_customer.geo_level4_name,
                      rcd_iface_customer.geo_level5_name);
            commit;
         else
            if (rcd_geo_hierarchy.geo_level1_name != rcd_iface_customer.geo_level1_name or
                rcd_geo_hierarchy.geo_level2_name != rcd_iface_customer.geo_level2_name or
                rcd_geo_hierarchy.geo_level3_name != rcd_iface_customer.geo_level3_name or
                rcd_geo_hierarchy.geo_level4_name != rcd_iface_customer.geo_level4_name or
                rcd_geo_hierarchy.geo_level5_name != rcd_iface_customer.geo_level5_name) then
               update geo_hierarchy
                  set geo_level1_name = rcd_iface_customer.geo_level1_name,
                      geo_level2_name = rcd_iface_customer.geo_level2_name,
                      geo_level3_name = rcd_iface_customer.geo_level3_name,
                      geo_level4_name = rcd_iface_customer.geo_level4_name,
                      geo_level5_name = rcd_iface_customer.geo_level5_name
                where geo_level1_code = rcd_iface_customer.geo_level1_code
                  and geo_level2_code = rcd_iface_customer.geo_level2_code
                  and geo_level3_code = rcd_iface_customer.geo_level3_code
                  and geo_level4_code = rcd_iface_customer.geo_level4_code
                  and geo_level5_code = rcd_iface_customer.geo_level5_code;
               commit;
            end if;
         end if;
         close csr_geo_hierarchy;
      end if;

      --
      -- if standard hierarchy does not exist then insert
      -- if any standard hierarchy names are different then update
      --
      if (not(rcd_iface_customer.std_level1_code is null) and
          not(rcd_iface_customer.std_level2_code is null) and
          not(rcd_iface_customer.std_level3_code is null) and
          not(rcd_iface_customer.std_level4_code is null)) then
         open csr_standard_hierarchy;
         fetch csr_standard_hierarchy into rcd_standard_hierarchy;
         if csr_standard_hierarchy%notfound then
            insert into standard_hierarchy
               values(rcd_iface_customer.std_level1_code,
                      rcd_iface_customer.std_level2_code,
                      rcd_iface_customer.std_level3_code,
                      rcd_iface_customer.std_level4_code,
                      rcd_iface_customer.std_level1_name,
                      rcd_iface_customer.std_level2_name,
                      rcd_iface_customer.std_level3_name,
                      rcd_iface_customer.std_level4_name);
            commit;
         else
            if (rcd_standard_hierarchy.std_level1_name != rcd_iface_customer.std_level1_name or
                rcd_standard_hierarchy.std_level2_name != rcd_iface_customer.std_level2_name or
                rcd_standard_hierarchy.std_level3_name != rcd_iface_customer.std_level3_name or
                rcd_standard_hierarchy.std_level4_name != rcd_iface_customer.std_level4_name) then
               update standard_hierarchy
                  set std_level1_name = rcd_iface_customer.std_level1_name,
                      std_level2_name = rcd_iface_customer.std_level2_name,
                      std_level3_name = rcd_iface_customer.std_level3_name,
                      std_level4_name = rcd_iface_customer.std_level4_name
                where std_level1_code = rcd_iface_customer.std_level1_code
                  and std_level2_code = rcd_iface_customer.std_level2_code
                  and std_level3_code = rcd_iface_customer.std_level3_code
                  and std_level4_code = rcd_iface_customer.std_level4_code;
               commit;
            end if;
         end if;
         close csr_standard_hierarchy;
      end if;

   end loop;
   close csr_iface_customer;

   --
   -- retrieve the customer data
   --
   open csr_customer;
   loop
      fetch csr_customer into rcd_customer;
      if csr_customer%notfound then
         exit;
      end if;

      --
      -- set the update indicator
      --
      bol_update := false;

      --
      -- customer changed
      --
      if (rcd_customer.old_customer_name != rcd_customer.customer_name or
          rcd_customer.old_status != rcd_customer.cust_status or
          nvl(rcd_customer.old_address_1,'*NULL') != nvl(rcd_customer.address_1,'*NULL') or
          nvl(rcd_customer.old_city,'*NULL') != nvl(rcd_customer.city,'*NULL') or
          nvl(rcd_customer.old_state,'*NULL') != nvl(rcd_customer.state,'*NULL') or
          nvl(rcd_customer.old_outlet_location,'*NULL') != nvl(rcd_customer.outlet_location,'*NULL') or
          nvl(rcd_customer.old_distributor_flg,'N') != nvl(rcd_customer.distributor_flg,'N')) then
         bol_update := true;
      end if;

      --
      -- geo hierarchy changed
      --
      if (nvl(rcd_customer.old_geo_level1_code,'*NULL') != nvl(rcd_customer.geo_level1_code,'*NULL') or
          nvl(rcd_customer.old_geo_level2_code,'*NULL') != nvl(rcd_customer.geo_level2_code,'*NULL') or
          nvl(rcd_customer.old_geo_level3_code,'*NULL') != nvl(rcd_customer.geo_level3_code,'*NULL') or
          nvl(rcd_customer.old_geo_level4_code,'*NULL') != nvl(rcd_customer.geo_level4_code,'*NULL') or
          nvl(rcd_customer.old_geo_level5_code,'*NULL') != nvl(rcd_customer.geo_level5_code,'*NULL')) then
         bol_update := true;
      end if;

      --
      -- standard hierarchy changed
      --
      if (nvl(rcd_customer.old_std_level1_code,'*NULL') != nvl(rcd_customer.std_level1_code,'*NULL') or
          nvl(rcd_customer.old_std_level2_code,'*NULL') != nvl(rcd_customer.std_level2_code,'*NULL') or
          nvl(rcd_customer.old_std_level3_code,'*NULL') != nvl(rcd_customer.std_level3_code,'*NULL') or
          nvl(rcd_customer.old_std_level4_code,'*NULL') != nvl(rcd_customer.std_level4_code,'*NULL')) then
         bol_update := true;
      end if;

      --
      -- if affiliation name not exist then log error
      -- if affiliation name is different then update to new id
      --
      if not(rcd_customer.affiliation is null) then
         var_affiliation_id := rcd_customer.affiliation_id;
         open csr_affiliation;
         fetch csr_affiliation into rcd_affiliation;
         if csr_affiliation%notfound then
            write_log('Customer id ('||to_char(rcd_customer.customer_id)||') business unit id ('||to_char(rcd_customer.business_unit_id)||') - affiliation name ('||rcd_customer.affiliation||') not found on AFFILIATION table using AFFILIATION_NAME_EN');
         else
            if rcd_affiliation.affiliation_id != rcd_customer.affiliation_id then
               var_affiliation_id := rcd_affiliation.affiliation_id;
               bol_update := true;
            end if;
         end if;
         close csr_affiliation;
      end if;

      --
      -- if customer type name not exist then log error
      -- if customer type name is different then update to new id
      --
      if not(rcd_customer.cust_type is null) then
         var_cust_type_id := rcd_customer.cust_type_id;
         open csr_cust_type;
         fetch csr_cust_type into rcd_cust_type;
         if csr_cust_type%notfound then
            write_log('Customer id ('||to_char(rcd_customer.customer_id)||') business unit id ('||to_char(rcd_customer.business_unit_id)||') - customer type name ('||rcd_customer.cust_type||') not found on CUST_TYPE table using CUST_TYPE_NAME_EN');
         else
            if rcd_cust_type.cust_type_id != rcd_customer.cust_type_id then
               var_cust_type_id := rcd_cust_type.cust_type_id;
               bol_update := true;
            end if;
         end if;
        close csr_cust_type;
      end if;

      --
      -- if customer status is active
      -- if customer contact name is different then update the name
      -- if customer contact does not exist then create the contact
      --
      /*-*/
      /* Retrieve the existing customer contact
      /* **notes** 1. The first active customer contact is retrieved
      /*-*/
      if rcd_customer.old_status = 'A' and rcd_customer.cust_status = 'A' then
         if not(rcd_customer.contact_name is null) then
            open csr_cust_contact;
            fetch csr_cust_contact into rcd_cust_contact;
            if csr_cust_contact%found then
               if rcd_cust_contact.first_name != rcd_customer.contact_name then
                  update cust_contact
                     set first_name = rcd_customer.contact_name,
                         modified_user = user,
                         modified_date = sysdate
                   where cust_contact_id = rcd_cust_contact.cust_contact_id;
                  bol_update := true;
               end if;
            else
               select cust_contact_seq.nextval into var_cust_contact_id from dual;
               insert into cust_contact
                  (cust_contact_id, first_name, customer_id, status, modified_user, modified_date)
                  values(var_cust_contact_id, rcd_customer.contact_name, rcd_customer.customer_id, 'A', user, sysdate);
               bol_update := true;
            end if;
            close csr_cust_contact;
         end if;
      end if;

      --
      -- if customer salesperson code does not exist then log error
      --
      /*-*/
      /* Retrieve the existing customer users relationship
      /* **notes** 1. The first active primary customer sales territory user is retrieved
      /*-*/
      if not(rcd_customer.sales_person_code is null) then
         open csr_users;
         fetch csr_users into rcd_users;
         if csr_users%notfound then
            write_log('Customer id ('||to_char(rcd_customer.customer_id)||') business unit id ('||to_char(rcd_customer.business_unit_id)||') - sales person code ('||rcd_customer.sales_person_code||') not found on USERS table using USERNAME');
         end if;
         close csr_users;
      end if;

      --
      -- update the customer when required
      --
      if bol_Update = true then

         --
         -- update the customer
         --
         update customer
            set customer_name = rcd_customer.customer_name,
                address_1 = rcd_customer.address_1,
                city = rcd_customer.city,
                state = rcd_customer.state,
                status = rcd_customer.cust_status,
                outlet_location = rcd_customer.outlet_location,
                distributor_flg = rcd_customer.distributor_flg,
                affiliation_id = var_affiliation_id,
                cust_type_id = var_cust_type_id,
                geo_level1_code = rcd_customer.geo_level1_code,
                geo_level2_code = rcd_customer.geo_level2_code,
                geo_level3_code = rcd_customer.geo_level3_code,
                geo_level4_code = rcd_customer.geo_level4_code,
                geo_level5_code = rcd_customer.geo_level5_code,
                std_level1_code = rcd_customer.std_level1_code,
                std_level2_code = rcd_customer.std_level2_code,
                std_level3_code = rcd_customer.std_level3_code,
                std_level4_code = rcd_customer.std_level4_code
          where customer_id = rcd_customer.customer_id;

         --
         -- update the IFACE customer
         --
         update iface.iface_customer
            set iface_status = 'UPDATED'
          where customer_code = rcd_customer.customer_code
            and market_id = p_MarketID;

         --
         -- commit the database
         --
         commit;

      end if;

   end loop;
   close csr_customer;

EXCEPTION
  WHEN OTHERS THEN
    Send_Mail(v_error_email, 'eFEX Refresh Interface Error', 'Error in EFEX_REFRESH.REFRESH_CHINA_CUSTOMER'||chr(13)||SQLERRM,NULL);
END REFRESH_CHINA_CUSTOMER;

PROCEDURE WRITE_LOG(par_text IN VARCHAR2) IS

   /*-*/
   /* Autonomous transaction
   /*-*/
   pragma autonomous_transaction;

BEGIN

   /*-*/
   /* Insert the log row
   /*-*/
   var_log_line := var_log_line + 1;
   insert into iface_log values(var_log_type, var_log_line, sysdate, par_text);

   /*-*/
   /* Commit the database
   /* note - isolated commit (autonomous transaction)
   /*-*/
   commit;

END WRITE_LOG;
   
END EFEX_REFRESH;
/
