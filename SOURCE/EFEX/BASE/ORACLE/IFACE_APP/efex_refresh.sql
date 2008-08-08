CREATE OR REPLACE PACKAGE EFEX_REFRESH AS

PROCEDURE REFRESH_CUSTOMER(p_MarketID IN NUMBER);
PROCEDURE REFRESH_ITEM(p_MarketID IN NUMBER);
PROCEDURE REFRESH_ITEM_ORDER_BY(p_MarketID IN NUMBER);
PROCEDURE REFRESH_ITEM_ORDER_LIMITS(p_MarketID IN NUMBER);
PROCEDURE REFRESH_AU_SNACK_ITEM(p_MarketID IN NUMBER);

END EFEX_REFRESH;
/


CREATE OR REPLACE PACKAGE BODY EFEX_REFRESH AS

   v_error_email  varchar2(100) := 'asia.pacific.efex.error.messages@ap.effem.com';  
/******************************************************************************
*  NAME:       REFRESH_CUSTOMER
*  PURPOSE:    EFEX Customer REFESH PROCEDURE
*  REVISIONS:
*  Ver    Date        Author           Description
*  -----  ----------  ---------------  ------------------------------------
*  1.0    00-00-2005  GEOFF DODDS       Created View
*  1.1    01-08-2006  Toui Lepkhammany  Modified to refesh Hong Kong Customers
*                                        This includes customer status
*  1.2    20-02-2008  Toui Lepkhammany  Mod: check for city and state being null
*                                       in efex.customer.
*  1.3    08-08-2008  Steve Gregan      Modified to refresh China customers                                     
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
   
END EFEX_REFRESH;
/
