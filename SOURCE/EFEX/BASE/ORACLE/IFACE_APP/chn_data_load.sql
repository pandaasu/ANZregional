CREATE OR REPLACE PACKAGE CHN_DATA_LOAD AS

FUNCTION CUST_ITEM_REF(p_CustomerID IN NUMBER, p_ItemID IN NUMBER) RETURN NUMBER;

PROCEDURE EXTRACT_ORDERS;
PROCEDURE EXTRACT_DIRECT_ORDERS(p_filedir IN varchar2);
PROCEDURE EXTRACT_TURNIN_ORDERS(p_filedir IN varchar2);
PROCEDURE EXTRACT_SITE_ORDERS(p_filedir IN varchar2);
PROCEDURE EXTRACT_DIRECT_SITE_ORDERS(p_order_id IN NUMBER, p_item_source_id IN NUMBER); 
PROCEDURE EXTRACT_TURNIN_SITE_ORDERS(p_order_id IN NUMBER, p_item_source_id IN NUMBER, p_distributor_id IN NUMBER);

END CHN_DATA_LOAD;
/



??if wholesaler email ..
??if wholesaler fax ...


CREATE OR REPLACE PACKAGE BODY CHN_DATA_LOAD AS
   v_chn_market_id  number := 4;
   v_deliver_within_days int := 3;
   v_error_email    varchar2(100) := 'asia.pacific.efex.error.messages@ap.effem.com,';
   v_fe_email       varchar(200)  := 'sandra.dick@ap.effem.com, efex@ap.effem.com,';
   --v_custserv_email varchar2(100) := 'Petcare.customer.orders@ap.effem.com,';
   v_custserv_email varchar2(200) := 'Petcare.customer.orders@ap.effem.com, sandra.dick@ap.effem.com, efex@ap.effem.com,';

/******************************************************************************
   NAME:       Cust Item Ref
   PURPOSE:    return the customers item reference for an Item

   REVISIONS:
   Ver     Date        Author           Description
   ------  ----------  ---------------  ------------------------------------
   1.0     05/06/2008  Geoff Dodds      Initial Version

******************************************************************************/
FUNCTION CUST_ITEM_REF(p_CustomerID IN NUMBER, p_ItemID IN NUMBER) RETURN NUMBER IS

  v_REFCODE           number;

BEGIN

   	SELECT REF_CODE
	INTO   v_REFCODE
	FROM   customer c, range_item i
	WHERE  c.range_id = i.range_id
	AND    c.customer_id = p_CustomerID
	AND    i.item_id = p_ItemID;

	RETURN v_REFCODE;

END CUST_ITEM_REF;

/******************************************************************************
   NAME:       Extract_Orders
   PURPOSE:    Initiates orders extract processes

   REVISIONS:
   Ver     Date        Author           Description
   ------  ----------  ---------------  ------------------------------------
   1.0     15/08/2008  Steve Gregan     Initial Version - cloned from UBA_DATA_LOAD

******************************************************************************/
PROCEDURE EXTRACT_ORDERS IS
BEGIN

  --1) First process any site orders.
  EXTRACT_SITE_ORDERS(p_filedir);
  --2) Second extact any Direct orders.
  EXTRACT_DIRECT_ORDERS(p_filedir);
  --3) Thirdly extract any turn in orders.
  EXTRACT_TURNIN_ORDERS(p_filedir);

  --4) Process Customer Payment receipts
  PROCESS_CUSTOMER_RECEIPTS;
  
END EXTRACT_ORDERS;

/******************************************************************************
   NAME:       Extract Direct Orders
   PURPOSE:    Extract direct orders (Order Distributor_ID = 0) for transmission
               to Logistics.

   REVISIONS:
   Ver     Date        Author           Description
   ------  ----------  ---------------  ------------------------------------
   1.0     15/08/2008  Steve Gregan     Initial Version - cloned from UBA_DATA_LOAD
                                                                                    
******************************************************************************/
PROCEDURE EXTRACT_DIRECT_ORDERS(p_filedir IN varchar2) IS

  v_order_id              NUMBER;
  v_order_dat             VARCHAR2(32767);
  v_line_num              NUMBER(3);
  v_iface_id              NUMBER(15,0);
  v_cust_email            VARCHAR2(255);   --Ver 1.4
  v_cust_fax_num          VARCHAR2(50);    --Ver 1.4
  v_cust_fax_num_check    VARCHAR2(50);    --Ver 1.4
  v_cust_zetafax_email    VARCHAR2(200);   --Ver 1.4
  v_print_statement_flg   VARCHAR2(1);     --Ver 1.4
  v_site_order_check      NUMBER(3);       --Ver 1.5
  v_phoned_flg            VARCHAR2(1);     --Ver 1.8  

  -- New Orders Cursor gives a list of unprocessed orders
  CURSOR HEADER_CRSR IS
    SELECT order_id,
           a.customer_id,
           b.customer_code,
           a.cust_contact_id,
           a.distributor_id,
           a.user_id,
           a.print_statement_flg,         --Ver 1.4
           'Sales Order' order_type,
           order_date,
           deliver_date,
           purchase_order,
           order_notes,
           total_items,
           confirm_flg,
           phoned_flg,
           delasap_flg,
           sendfax_flg,
           delnext_flg,
           order_status,
           c.username,
           c.firstname,
           c.lastname,
           c.email_address,
           d.first_name contact_first_name,
           d.last_name contact_last_name,
           b.customer_name,
           b.address_1,
           b.city,
           b.state,
           b.postcode,
           b.phone_number,
           b.fax_number,
           b.email_address AS cust_email, --Ver 1.4
           e.customer_code distrib_code,
           e.customer_name distrib_name,
           b.outlet_flg
    FROM   orders a,
           customer b,
           users c,
           cust_contact d,
           customer e
    WHERE  a.customer_id = b.customer_id
    AND    a.user_id = c.user_id
    AND       a.cust_contact_id = d.cust_contact_id(+)
    AND       a.distributor_id = e.customer_id(+)
    AND    a.distributor_id IS NULL --Ver: 1.3 A DIRECT ORDER
    AND       a.order_status in ('SUBMITTED','PROCESSING')
    AND    a.phoned_flg = 'N' --Ver: 1.8    
    AND    b.customer_code IS NOT NULL
    AND    b.market_id = v_market_id;

  -- Total Check Cursor gives a total count of the order quantity
  CURSOR TOTCHK_CRSR(v_orderid NUMBER) IS
    SELECT   NVL(SUM(order_qty), 0) totalcheck,
             COUNT(*)               totallines
    FROM     order_item
    WHERE    order_id = v_orderid
    AND      NVL(order_qty,0) > 0;
  totchk_row TOTCHK_CRSR%rowtype;

  -- Order Detail Cursor return details for each line item in the order
  CURSOR DETAIL_CRSR IS
    SELECT   order_qty,
             a.item_id,
             item_code,
             item_name,
             unit_measure
    FROM     order_item a,
             item b
    WHERE     a.item_id = b.item_id
    AND      NVL(order_qty,0) > 0
    AND      order_id = v_order_id
    ORDER BY item_code;

BEGIN

  -- Read Order Header
  FOR header_row in HEADER_CRSR LOOP
    v_order_id := header_row.order_id;
    
    --Ver 1.5: check to see if the order has corresponding order_source entry
    SELECT COUNT(*) INTO v_site_order_check
    FROM ORDER_SOURCE
    WHERE ORDER_ID = v_order_id;
    
    --Ver 1.5: if it's not a site order, then process it as a direct order
    IF (v_site_order_check = 0) THEN
        -- Check Order Total
        OPEN TOTCHK_CRSR(header_row.order_id);
        FETCH TOTCHK_CRSR INTO totchk_row;
        IF (header_row.total_items <> totchk_row.totalcheck) THEN
          IF upper(header_row.order_status) = 'SUBMITTED' THEN
            UPDATE orders
            SET    order_status = 'PROCESSING'
            WHERE  order_id = header_row.order_id;
    
          ELSIF upper(header_row.order_status) = 'PROCESSING' THEN
            UPDATE orders
            SET    order_status = 'LINE COUNT ERROR'
            WHERE  order_id = header_row.order_id;
    
            SEND_MAIL(v_error_email, 'eFEX Order error for Order ID: '||header_row.order_id, 'Line Count Error for Order ID: '||header_row.order_id,NULL);
    
          END IF;
    
        -- Order is Valid - Process it
        ELSE
    
          --Ver 1.4: Get customer email address
          v_cust_email := header_row.cust_email;      
          --Ver 1.4: Get orders print_statement_flg
          v_print_statement_flg := header_row.print_statement_flg;      
          --Ver 1.4: Get Customer fax number
          v_cust_fax_num := header_row.fax_number;
          
          IF v_cust_fax_num IS NOT NULL THEN
              v_cust_fax_num_check := SUBSTR(v_cust_fax_num_check,1,3);
              IF v_cust_fax_num_check = '+61' THEN
                 v_cust_fax_num := '0'||RTRIM(SUBSTR(v_cust_fax_num,4,50));
              END IF;
          END IF;
          
          --Ver 1.4: Build ZETAFAX email address of the customer to fax this order copy to.
          v_cust_zetafax_email := '"'||header_row.customer_name||'@'||v_cust_fax_num||'@faxanz"';

          --Ver 1.9: Get orders phoned_flg
          v_phoned_flg := header_row.phoned_flg; 

          IF v_phoned_flg = 'N' THEN --Ver 1.9                    
              -- Open Orders Interface
              v_iface_id := outbound_loader.create_interface('CISATL10');
        
              --  Build Order Header
              v_order_dat := 'HDR';
              v_order_dat := v_order_dat||'EFX';
              v_order_dat := v_order_dat||'Z001';
              v_order_dat := v_order_dat||RPAD(TO_CHAR(header_row.username), 10);
              v_order_dat := v_order_dat||RPAD(TO_CHAR(800000000 + header_row.order_id), 10);
              v_order_dat := v_order_dat||TO_CHAR(header_row.order_date, 'yyyymmdd');
              v_order_dat := v_order_dat||TO_CHAR(header_row.deliver_date, 'yyyymmdd');
              v_order_dat := v_order_dat||RPAD(' ', 6);
              v_order_dat := v_order_dat||LPAD(TO_CHAR(header_row.customer_code), 8,0);
              v_order_dat := v_order_dat||LPAD(TO_CHAR(header_row.customer_code), 8,0);
              v_order_dat := v_order_dat||LPAD(TO_CHAR(header_row.customer_code), 8,0);
              v_order_dat := v_order_dat||RPAD(header_row.purchase_order||' ', 35);
              v_order_dat := v_order_dat||LPAD(TO_CHAR(totchk_row.totallines), 4,0);
              v_order_dat := v_order_dat||'147 ';
              v_order_dat := v_order_dat||'12'; --Ver 1.7 Food Service Distribution Channel
              v_order_dat := v_order_dat||'57'; --Ver 1.7 Food Division
              v_order_dat := v_order_dat||'ZOR ';
              outbound_loader.append_data(v_order_dat);
        
                    -- Build Order Note
                    v_order_dat := 'HTX';
                    v_order_dat := v_order_dat||'0001'; --SAP Comment code
                    v_order_dat := v_order_dat||'EN';
                    --Check to see if the order note is more than 70 Characters long.
                    IF (LENGTH(TO_CHAR(header_row.order_notes)) > 70) THEN
                             --Put in replacement note asking CS to check the eFEX order email for the order comment details.
                             v_order_dat := v_order_dat||RPAD('Order note too long. Please check eFEX email for PO:'||header_row.purchase_order, 70);
                    ELSE
                                v_order_dat := v_order_dat||RPAD(TO_CHAR(header_row.order_notes), 70);
                    END IF;
                    outbound_loader.append_data(v_order_dat);
        
              -- Build Order Detail
              v_line_num := 1;
              FOR detail_row IN DETAIL_CRSR LOOP
        
                v_order_dat := 'DET';
                v_order_dat := v_order_dat||LPAD(TO_CHAR(v_line_num), 6,0);
                v_order_dat := v_order_dat||LPAD(detail_row.item_code,8,0);
                v_order_dat := v_order_dat||TO_CHAR(detail_row.order_qty, 'FM09999999999.000');
                v_order_dat := v_order_dat||'   '; -- UOM
                v_line_num  := v_line_num + 1;
                outbound_loader.append_data(v_order_dat);
              END LOOP;
        
              -- Close PASSTHROUGH INTERFACE
              outbound_loader.finalise_interface();

          END IF; --Ver 1.9    
    
          -- Create Email for Customer Service
          v_order_dat := RPAD('Date: ',20)||to_char(header_row.order_date,'DD/MM/YYYY')||chr(13);
          v_order_dat := v_order_dat||RPAD('Order Taken By: ',20)||header_row.firstname||' '||header_row.lastname||chr(13);
          v_order_dat := v_order_dat||RPAD('Order Taken From: ',20)||header_row.contact_first_name||' '||header_row.contact_last_name||chr(13);
          v_order_dat := v_order_dat||RPAD('Order Type: ',20)||header_row.order_type||chr(13);
          v_order_dat := v_order_dat||RPAD('eFEX Reference #: ',20)||header_row.order_id||chr(13);
          v_order_dat := v_order_dat||chr(13);
          v_order_dat := v_order_dat||RPAD('Delivery Date: ',20)||to_char(header_row.deliver_date,'DD/MM/YYYY')||chr(13);
          v_order_dat := v_order_dat||chr(13);
          v_order_dat := v_order_dat||RPAD('Customer Name: ',20)||header_row.customer_name||chr(13);
          v_order_dat := v_order_dat||RPAD('Customer Number: ',20)||header_row.customer_code||chr(13);
          v_order_dat := v_order_dat||RPAD('Customer Phone: ',20)||header_row.phone_number||chr(13);
          v_order_dat := v_order_dat||RPAD('Customer Fax: ',20)||header_row.fax_number||chr(13);
          v_order_dat := v_order_dat||RPAD('Delivery Address: ',20)||header_row.address_1||chr(13);
          v_order_dat := v_order_dat||RPAD(' ',20)||header_row.city||', '||header_row.state||', '||header_row.postcode||chr(13);
          v_order_dat := v_order_dat||chr(13);
          v_order_dat := v_order_dat||RPAD('PO: ',20)||header_row.purchase_order||chr(13);
          v_order_dat := v_order_dat||chr(13);
          v_order_dat := v_order_dat||RPAD('Bill To Name: ',20)||header_row.distrib_name||chr(13);
          v_order_dat := v_order_dat||RPAD('Bill To Number: ',20)||header_row.distrib_code||chr(13);
          v_order_dat := v_order_dat||chr(13);
          v_order_dat := v_order_dat||RPAD('Comments: ',20)||header_row.order_notes||chr(13);
          v_order_dat := v_order_dat||chr(13);
          v_line_num  := 1;
          v_order_dat := v_order_dat||RPAD('Line#',8)||RPAD('Product#',10)||RPAD('Qty',6)||RPAD('UoM',10)||'Product'||CHR(13);
          FOR detail_row IN DETAIL_CRSR LOOP
                v_order_dat := v_order_dat||RPAD(TO_CHAR(v_line_num), 8);
                v_order_dat := v_order_dat||RPAD(detail_row.item_code, 10);
              v_order_dat := v_order_dat||RPAD(detail_row.order_qty, 6);
                v_order_dat := v_order_dat||RPAD(detail_row.unit_measure, 10);
                v_order_dat := v_order_dat||detail_row.item_name||CHR(13);
              v_line_num  := v_line_num + 1;
          END LOOP;
          v_order_dat := v_order_dat||chr(13);
          v_order_dat := v_order_dat||RPAD('Total Case Count: ', 25)||header_row.total_items;

          -- Mark Order as Transferred
          UPDATE orders
          SET    order_status = 'CLOSED'
          WHERE  order_id = header_row.order_id;
          COMMIT;
              
          --Ver 1.9: Only send Confirmation e-mails to ASMs and eFEX inbox.
          IF v_phoned_flg = 'Y' THEN
                SEND_MAIL(header_row.email_address||',efex@ap.effem.com', 'eFEX DIRECT ORDER CONFIRMATION ONLY  for '||header_row.customer_name||' PO #: '||header_row.purchase_order, v_order_dat,NULL);
          ELSE    
                  SEND_MAIL(header_row.email_address||',efex@ap.effem.com', 'eFEX Order for '||header_row.customer_name||' PO #: '||header_row.purchase_order, v_order_dat,NULL);
          END IF;
    
          --Ver 1.4: Check to see if Customer needs a copy of the order sent to them
          IF v_print_statement_flg = 'Y' THEN
              --Check to see if the Customer has an e-mail address and send
              IF v_cust_email IS NOT NULL THEN
                  --Send customer order copy as e-mail
                  SEND_MAIL(v_cust_email||',efex@ap.effem.com', 'E-MAIL Copy of eFEX Direct Order For '||header_row.customer_name, v_order_dat,NULL);          
              ELSE
                  IF v_cust_fax_num IS NOT NULL THEN
                      --Else send as fax
                      SEND_MAIL(v_cust_zetafax_email||',efex@ap.effem.com', 'FAX Copy of eFEX Direct Order For '||header_row.customer_name, v_order_dat,NULL);
                  ELSE
                      --Else send to efex inbox for posting.
                      SEND_MAIL('efex@ap.effem.com', 'POST Copy of eFEX Direct Order For '||header_row.customer_name, v_order_dat,NULL);
                  END IF;
              END IF;             
          END IF;
                
        END IF;
        CLOSE TOTCHK_CRSR;
        COMMIT;
    END IF; --Ver 1.5 end if
    
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN

    IF outbound_loader.is_created = TRUE THEN
      outbound_loader.add_exception(SUBSTR(SQLERRM, 1, 512));
      outbound_loader.finalise_interface;
    END IF;

    SEND_MAIL(v_error_email, 'eFEX Order Interface Error', 'Error in CHN_DATA_LOAD.EXTRACT_DIRECT_ORDERS'||chr(13)||SQLERRM,NULL);

END EXTRACT_DIRECT_ORDERS;

/******************************************************************************
   NAME:       Extract Turnin Orders With Faxing
   PURPOSE:    Extract TurnIN orders (Order Distributor_ID <> 0) for transmission
               to distributors.

   REVISIONS:
   Ver     Date        Author           Description
   ------  ----------  ---------------  ------------------------------------
   1.0     10/11/2005  Geoff Dodds      Initial Version
   1.1     14/06/2007  Toui Lepkhammany Updated to handle direct faxing to Distributors
                                        through ZETAFAX.
   1.2     19/06/2007  Toui Lepkhammany  Updated to send fax to distributor through zetafax
   1.3     28/06/2007  Toui Lepkhammany Mod: remove order_type check and replace
                                             the logic definition of TURN IN order to be
                                             if efex.orders.Distributor_id NOT IS NULL then
                                             process it as a TURN IN ORDER.
  1.4     19/07/2007   Toui Lepkhammany MOD: fixed faxing format.
  1.5     27/08/2007   Dennis Chang     Mod: add comment Unit = Single consumer product
  1.6     17/10/2007   Toui Lepkhammany Mod: add change to UOM call TDU = Case, MCU = Inner, RSU = Unit
  1.7     23/10/2007   Toui Lepkhammany Mod: add ability to process 'print_statement_flg' to
                                             send order copy to customers'
  1.8     01/11/2007   Dennis Chang     Mod: only process orders with a delivery date within 3 days of the current date for Snack.
  1.9      31/01/2008   Toui Lepkhammany MOD: If phoned_flg = Y then don't send to the wholesaler. It is a confirmation Order only.
                                             Only send to User and efex mailbox.
  2.0     03/06/2008   Geoff Dodds       Use TDU/MCU/RSU NAME instead of ITEM_NAME based on UOM type
  2.1     05/06/2008   Geoff Dodds       Added CUST_ITEM_REF to extract/email/fax
******************************************************************************/
PROCEDURE EXTRACT_TURNIN_ORDERS(p_filedir IN varchar2) IS

  v_order_dat             VARCHAR2(32767);
  v_order_dat_items       VARCHAR2(32767); --Ver 1.1
  v_order_dat_items_count VARCHAR2(5);     --Ver 1.1
  v_order_dat_end         VARCHAR2(500);   --Ver 1.1
  v_order_dat_fax         VARCHAR2(32767); --Ver 1.3
  v_line_num              NUMBER(3);
  v_email                  VARCHAR2(100);
  v_distributor_email     VARCHAR2(255);   --Ver 1.1
  v_distributor_fax_num   VARCHAR2(50);    --Ver 1.1
  v_distrib_fax_num_check VARCHAR2(10);    --Ver 1.1
  v_distributor_zetafax_email VARCHAR(200);--Ver 1.1
  v_uom                   VARCHAR2(50);    --Ver 1.5
  v_cust_email            VARCHAR2(255);   --Ver 1.7
  v_cust_fax_num          VARCHAR2(50);    --Ver 1.7
  v_cust_fax_num_check    VARCHAR2(50);    --Ver 1.7
  v_cust_zetafax_email    VARCHAR2(200);   --Ver 1.7
  v_print_statement_flg   VARCHAR2(1);     --Ver 1.7
  v_phoned_flg            VARCHAR2(1);     --Ver 1.9
  v_debug_string          VARCHAR2(5000);  --Debug Code
  v_total_items           VARCHAR2(100);

  -- New Orders Cursor gives a list of unprocessed orders
  CURSOR HEADER_CRSR IS
    SELECT order_id,
           a.customer_id,
           b.customer_code,
           a.cust_contact_id,
           a.distributor_id,
           a.user_id,
           a.print_statement_flg, --Ver 1.7
           'Turn In Order' AS order_type,
           order_date,
           deliver_date,
           purchase_order,
           order_notes,
           total_items,
           confirm_flg,
           phoned_flg,
           delasap_flg,
           sendfax_flg,
           delnext_flg,
           order_status,
           c.firstname,
           c.lastname,
           c.email_address,
           d.first_name AS contact_first_name,
           d.last_name AS contact_last_name,
           b.customer_name,
           b.address_1,
           b.city,
           b.state,
           b.postcode,
           b.phone_number,
           b.fax_number,
           b.email_address AS cust_email,    --Ver: 1.7
           e.customer_code AS distrib_code,
           e.customer_name AS distrib_name,
           e.email_address AS distrib_email, --Ver: 1.1
           e.fax_number AS distrib_fax,      --Ver: 1.1
           b.outlet_flg
    FROM   orders a,
           customer b,
           users c,
           cust_contact d,
           customer e
    WHERE  a.customer_id = b.customer_id
    AND    a.user_id = c.user_id
    AND    a.cust_contact_id = d.cust_contact_id(+)
    AND    a.distributor_id = e.customer_id(+)
    AND    a.distributor_id IS NOT NULL --Ver: 1.3 A TURN IN ORDER
    AND    ( a.order_status in ('SUBMITTED','PROCESSING') OR
             (a.order_status = 'ONHOLD' AND a.deliver_date < (select sysdate+v_deliver_within_days from dual) ) )
    AND    b.market_id = v_market_id;

  -- Total Check Cursor gives a total count of the order quantity
  CURSOR TOTCHK_CRSR(v_orderid NUMBER) IS
    SELECT   NVL(SUM(order_qty), 0) totalcheck,
             COUNT(*)               totallines
    FROM     order_item
    WHERE    order_id = v_orderid
    AND      NVL(order_qty,0) > 0;
  totchk_row TOTCHK_CRSR%rowtype;

  -- Order Detail Cursor return details for each line item in the order
  CURSOR DETAIL_CRSR(v_orderid NUMBER) IS
    SELECT   order_qty,
             a.item_id,
             item_code,
			 NVL(DECODE(a.uom, 'TDU', ITEM_TDU_NAME, 'MCU', ITEM_MCU_NAME, 'RSU', ITEM_RSU_NAME, NULL), ITEM_NAME) AS item_name, -- Ver: 2.0
             NVL(a.uom, 'Case') AS unit_measure,--Ver: 1.1
			 CUST_ITEM_REF(o.customer_id, a.item_id) AS cust_item_ref -- Ver: 2.1
    FROM     orders o, order_item a, item b
    WHERE    o.order_id = a.order_id
	AND      a.item_id = b.item_id
    AND      NVL(order_qty,0) > 0
    AND      o.order_id = v_orderid
    ORDER BY item_code;

BEGIN

  -- put indirect orders on hold if the deliver date is not within 3 days of the current date for Australia Snackfood users
  -- ie., business unit 2 for Australia Snackfood
  update orders set order_status = 'ONHOLD'
  where deliver_date >= (select sysdate+v_deliver_within_days from dual)
    and user_id in (select distinct user_id from user_segment us, segment s where us.segment_id = s.segment_id and business_unit_id = v_Aus_Snackfood)
    and order_status in ('SUBMITTED','PROCESSING')
    and distributor_id is not null; -- a Turn in order
  commit;

  -- Read Order Header
  FOR header_row in HEADER_CRSR LOOP

    -- Check Order Total
    OPEN TOTCHK_CRSR(header_row.order_id);
    FETCH TOTCHK_CRSR INTO totchk_row;
    IF (header_row.total_items <> totchk_row.totalcheck) THEN
      IF upper(header_row.order_status) = 'SUBMITTED' THEN
        UPDATE orders
        SET    order_status = 'PROCESSING'
        WHERE  order_id = header_row.order_id;

      ELSIF upper(header_row.order_status) = 'PROCESSING' THEN
        UPDATE orders
        SET    order_status = 'LINE COUNT ERROR'
        WHERE  order_id = header_row.order_id;

        SEND_MAIL(v_error_email, 'eFEX Order error for Order ID: '||header_row.order_id, 'Line Count Error for Order ID: '||header_row.order_id,NULL);

      END IF;

    -- Order is Valid - Process it
    ELSE
      --Debug Code Order id
      v_debug_string := 'Order ID: '||header_row.order_id;
      v_total_items := TO_CHAR(header_row.total_items);

      -- Get email address of user that created the order
      SELECT email_address
      INTO   v_email
      FROM   users
      WHERE  user_id = header_row.user_id;

      --Ver 1.1: Get email address of the distributor to email this order to.
      v_distributor_email := header_row.distrib_email;

      --Ver 1.1: if '+61' replace with '0' to fax number for sending from ap ZETAFAX.
      v_distrib_fax_num_check := SUBSTR(header_row.distrib_fax,1,3);
      IF v_distrib_fax_num_check = '+61' THEN
         v_distributor_fax_num := '0'||RTRIM(SUBSTR(header_row.distrib_fax,4,50));
      ELSE
         v_distributor_fax_num := header_row.distrib_fax;
      END IF;

      --Ver 1.1: build ZETAFAX email address of the distributor to fAX this order to.
      v_distributor_zetafax_email := '"'||header_row.distrib_name||'@'||v_distributor_fax_num||'@faxanz"';

      --Ver 1.7: Get customer email address
      v_cust_email := header_row.cust_email;

      --Ver 1.7: Get orders print_statement_flg
      v_print_statement_flg := header_row.print_statement_flg;

      --Ver 1.7: Get Customer fax number
      v_cust_fax_num := header_row.fax_number;

      --Ver 1.9: Get orders phoned_flg
      v_phoned_flg := header_row.phoned_flg;

      IF v_cust_fax_num IS NOT NULL THEN
          v_cust_fax_num_check := SUBSTR(v_cust_fax_num_check,1,3);
          IF v_cust_fax_num_check = '+61' THEN
             v_cust_fax_num := '0'||RTRIM(SUBSTR(v_cust_fax_num,4,50));
          END IF;
      END IF;

      --Ver 1.7: Build ZETAFAX email address of the customer to fax this order copy to.
      v_cust_zetafax_email := '"'||header_row.customer_name||'@'||v_cust_fax_num||'@faxanz"';

      --Debug Code
      v_debug_string := v_debug_string ||chr(13)||'1) Before create html order header';

      -- Create Order Header Data for e-mail (as HTML)
      v_order_dat := '<HTML>'||chr(13);
      v_order_dat := v_order_dat||'<HEAD>'||chr(13);
      v_order_dat := v_order_dat||'<TITLE>MARS Turn In Order</TITLE>'||chr(13);
      v_order_dat := v_order_dat||'</HEAD>'||chr(13);
      v_order_dat := v_order_dat||'<BODY>'||chr(13);
      v_order_dat := v_order_dat||'<P>'||chr(13);
      v_order_dat := v_order_dat||chr(13)||'<B>eFEX Reference #: </B>'||header_row.order_id;
      v_order_dat := v_order_dat||chr(13)||'<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>';
      v_order_dat := v_order_dat||chr(13)||'<TR><TD><FONT style="FONT-WEIGHT: bold; FONT-SIZE: large"><CENTER>MARS TURN IN ORDER</CENTER></FONT></TD></TR>';
      v_order_dat := v_order_dat||chr(13)||'</TABLE>';
      v_order_dat := v_order_dat||chr(13)||'<P>';
      v_order_dat := v_order_dat||chr(13)||'<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>';
      v_order_dat := v_order_dat||chr(13)||'<TR><TD>';
      v_order_dat := v_order_dat||chr(13)||'<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>';
      v_order_dat := v_order_dat||chr(13)||'<TR><TD colSpan=4><HR width="100%"></TD></TR>';
      v_order_dat := v_order_dat||chr(13)||'<TR><TD><B>Wholesaler Name: '  ||'</TD></B><TD>'||header_row.distrib_name||'</TD><TD><B>Wholesaler Number: '||'</TD></B><TD>'||header_row.distrib_code||'</TD></TR>';
      v_order_dat := v_order_dat||chr(13)||'<TR><TD><B>Delivery Date: '    ||'</TD></B><TD>'||to_char(header_row.deliver_date,'DD/MM/YYYY')||'</TD></TR>';
      v_order_dat := v_order_dat||chr(13)||'<TR><TD colSpan=4><HR width="100%"></TD></TR>';
      v_order_dat := v_order_dat||chr(13)||'<TR><TD><B>Customer Name: '    ||'</TD></B><TD>'||header_row.customer_name||'</TD><TD><B>Order Taken From: ' ||'</TD></B><TD>'||header_row.contact_first_name||' '||header_row.contact_last_name||'</TD></TR>';
      v_order_dat := v_order_dat||chr(13)||'<TR><TD><B>Customer Number: '  ||'</TD></B><TD>'||header_row.customer_code||'</TD></TR>';
      v_order_dat := v_order_dat||chr(13)||'<TR><TD><B>Delivery Address: ' ||'</TD></B><TD>'||header_row.address_1||'</TD></TR>';
      v_order_dat := v_order_dat||chr(13)||'<TR><TD></TD><TD>' ||header_row.city ||', '||header_row.state||', '||header_row.postcode||'</TD></TR>';
      v_order_dat := v_order_dat||chr(13)||'<TR><TD><B>Customer Phone: '||'</TD></B><TD>'||header_row.phone_number||'</TD></TR>';
      v_order_dat := v_order_dat||chr(13)||'<TR><TD><B>Customer Fax: '||'</TD></B><TD>'||header_row.fax_number||'</TD></TR>';
      v_order_dat := v_order_dat||chr(13)||'<TR><TD colSpan=4><HR width="100%"></TD></TR>';
      v_order_dat := v_order_dat||chr(13)||'<TR><TD><B>Order Date: '||'</TD></B><TD>'||to_char(header_row.order_date,'DD/MM/YYYY')||'</TD></TR>';
      v_order_dat := v_order_dat||chr(13)||'<TR><TD colSpan=4><HR width="100%"></TD></TR>';
      v_order_dat := v_order_dat||chr(13)||'<TR><TD><B>Order Taken By: '   ||'</TD></B><TD>'||header_row.firstname||' '||header_row.lastname||'</TD><TD><B>E-Mail Address: '||'</TD></B><TD>'||v_email||'</TD></TR>';
      v_order_dat := v_order_dat||chr(13)||'<TR><TD><B>PO: '||'</TD></B><TD>'||header_row.purchase_order||'</TD></TR>';
      v_order_dat := v_order_dat||chr(13)||'<TR><TD><B>Comments: '||'</TD></B><TD>'||header_row.order_notes||'</TD></TR>';
      v_order_dat := v_order_dat||chr(13)||'<TR><TD></TD><TD>Unit = Single consumer product</TD></TR>';
      v_order_dat := v_order_dat||chr(13)||'</TABLE><BR>';
      v_order_dat := v_order_dat||chr(13)||'</TD></TR>';
      v_order_dat := v_order_dat||chr(13)||'<TR><TD>';

      --Debug Code
      v_debug_string := v_debug_string||chr(13)|| '2) Before create text order header';

      --Create Order Header Data for Fax (as Text)
      v_order_dat_fax := chr(10)||'TURN IN ORDER'||chr(13)||Chr(13);
      v_order_dat_fax := v_order_dat_fax||'Please see the following Turn In Order.'||Chr(13);
      v_order_dat_fax := v_order_dat_fax||'PO: '||header_row.purchase_order||Chr(13);
      v_order_dat_fax := v_order_dat_fax||'If there are any queries, please contact me.'||Chr(13);
      v_order_dat_fax := v_order_dat_fax||'Thank you'||Chr(13);
      v_order_dat_fax := v_order_dat_fax||'Regards,'||Chr(13);
      v_order_dat_fax := v_order_dat_fax||header_row.firstname||' '||header_row.lastname||Chr(13);
      v_order_dat_fax := v_order_dat_fax||v_email||Chr(13);
      v_order_dat_fax := v_order_dat_fax||Chr(13)||Chr(13)||Chr(13)||Chr(13)||Chr(13)||Chr(13)||Chr(13)||Chr(13)||Chr(13);
      v_order_dat_fax := v_order_dat_fax||'eFEX Reference #: '||header_row.order_id||chr(13);
      v_order_dat_fax := v_order_dat_fax||'MARS TURN IN ORDER'||chr(13);
      v_order_dat_fax := v_order_dat_fax||'--------------------------------------------------------------'||chr(13);
      v_order_dat_fax := v_order_dat_fax||'Wholesaler Name:  '||header_row.distrib_name||'. Wholesaler Number: '||header_row.distrib_code||chr(13);
      v_order_dat_fax := v_order_dat_fax||'Delivery Date:    '||to_char(header_row.deliver_date,'DD/MM/YYYY')||chr(13);
      v_order_dat_fax := v_order_dat_fax||'--------------------------------------------------------------'||chr(13);
      v_order_dat_fax := v_order_dat_fax||'Customer Name:    '||header_row.customer_name||'. Order Taken From: '||header_row.contact_first_name||' '||header_row.contact_last_name||chr(13);
      v_order_dat_fax := v_order_dat_fax||'Delivery Address: '||header_row.address_1||chr(13);
      v_order_dat_fax := v_order_dat_fax||'                  '||header_row.city ||', '||header_row.state||', '||header_row.postcode||chr(13);
      v_order_dat_fax := v_order_dat_fax||'Customer Number:  '||header_row.customer_code||chr(13);
      v_order_dat_fax := v_order_dat_fax||'Customer Phone:   '||header_row.phone_number||chr(13);
      v_order_dat_fax := v_order_dat_fax||'Customer Fax:     '||header_row.fax_number||chr(13);
      v_order_dat_fax := v_order_dat_fax||'--------------------------------------------------------------'||chr(13);
      v_order_dat_fax := v_order_dat_fax||'Order Date:       '||to_char(header_row.order_date,'DD/MM/YYYY')||chr(13);
      v_order_dat_fax := v_order_dat_fax||'--------------------------------------------------------------'||chr(13);
      v_order_dat_fax := v_order_dat_fax||'Order Taken By:   '||header_row.firstname||' '||header_row.lastname||'.'||chr(13);
      v_order_dat_fax := v_order_dat_fax||'E-Mail Address:   '||v_email||chr(13);
      v_order_dat_fax := v_order_dat_fax||'PO:               '||header_row.purchase_order||chr(13);
      v_order_dat_fax := v_order_dat_fax||'Comments:         '||header_row.order_notes||chr(13);
      v_order_dat_fax := v_order_dat_fax||'                  '||'Unit = Single consumer product'||chr(13);
      v_order_dat_fax := v_order_dat_fax||'--------------------------------------------------------------'||chr(13);
      v_order_dat_fax := v_order_dat_fax||chr(13);
      v_order_dat_fax := v_order_dat_fax||chr(13);

      --Debug Code
      v_debug_string := v_debug_string ||chr(13)|| '3) Before create line item header';

      v_line_num := 1;
      --v_order_dat_items := chr(13)||'<TABLE TABLE cellSpacing=0 cellPadding=0 width="80%" border=1>'||chr(13)||'<TR bgColor=gray><TD><B>'||RPAD('Line#',8)||'</B></TD><TD><B>'||RPAD('Product#',10)||'</B></TD><TD><B>'||RPAD('Qty',6)||'</B></TD><TD><B>'||RPAD('UoM',10)||'</B></TD><TD><B>'||'Product'||'</B></TD></TR>';
      v_order_dat_items := chr(13)||'<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0><TR bgColor=gray><TD><B>Line#</B></TD><TD><B>Product#</B></TD><TD><B>WHS ID</B></TD><TD><B>Qty</B></TD><TD><B>UoM</B></TD><TD><B>Product</B></TD></TR>';
      --v_order_dat_fax := v_order_dat_fax||'|------------------------------------------------------------------------|'||chr(13);
      v_order_dat_fax := v_order_dat_fax||RPAD('|Line#',6)||RPAD('|Product#',10)||RPAD('|WHS ID',10)||RPAD('|Qty',6)||RPAD('|UoM',7)||'|Product'||CHR(13);
      v_order_dat_fax := v_order_dat_fax||'|------------------------------------------------------------------------------|'||chr(13);
      FOR detail_row IN DETAIL_CRSR(header_row.order_id) LOOP

      --Debug Code
      v_debug_string := v_debug_string ||chr(13)||'4) Inside line item. Item ID: '||detail_row.item_id;

        -- 1.6 Mod: work out UOM text to send to wholesalers
        v_uom := detail_row.unit_measure;
        IF v_uom = 'TDU' THEN
           v_uom := 'Case';
        ELSE
           IF v_uom = 'MCU' THEN
               v_uom := 'Inner';
           ELSE
               IF v_uom = 'RSU' THEN
                   v_uom := 'Unit';
               END IF;
           END IF;
        END IF;
        --Build Order Items Data for e-Mail
        IF MOD(v_line_num,2) = 1 THEN
           v_order_dat_items := v_order_dat_items||chr(13)||'<TR bgColor=#eaeaea>';
        ELSE
           v_order_dat_items := v_order_dat_items||chr(13)||'<TR>';
        END IF;
        v_order_dat_items := v_order_dat_items||chr(13)||'<TD>'||RPAD(TO_CHAR(v_line_num), 8)     ||'</TD>';
        v_order_dat_items := v_order_dat_items||chr(13)||'<TD>'||RPAD(detail_row.item_code, 10)   ||'</TD>';
        v_order_dat_items := v_order_dat_items||chr(13)||'<TD>'||RPAD(detail_row.cust_item_ref,10)||'</TD>';
        v_order_dat_items := v_order_dat_items||chr(13)||'<TD>'||RPAD(detail_row.order_qty, 6)    ||'</TD>';
        v_order_dat_items := v_order_dat_items||chr(13)||'<TD>'||RPAD(v_uom, 10)                  ||'</TD>';
        v_order_dat_items := v_order_dat_items||chr(13)||'<TD>'||detail_row.item_name             ||'</TD>';
        v_order_dat_items := v_order_dat_items||chr(13)||'</TR>';
        --Build Order Item Data for Fax
        v_order_dat_fax := v_order_dat_fax||'|'||RPAD(TO_CHAR(v_line_num), 5);
        v_order_dat_fax := v_order_dat_fax||'|'||RPAD(detail_row.item_code, 9);
        v_order_dat_fax := v_order_dat_fax||'|'||RPAD(detail_row.cust_item_ref, 9);
        v_order_dat_fax := v_order_dat_fax||'|'||RPAD(detail_row.order_qty, 5);
        v_order_dat_fax := v_order_dat_fax||'|'||RPAD(v_uom, 6);
        v_order_dat_fax := v_order_dat_fax||'|'||detail_row.item_name;
        v_order_dat_fax := v_order_dat_fax||chr(13)||'|------------------------------------------------------------------------------|'||chr(13);

        v_line_num := v_line_num + 1;
      END LOOP;

      --Debug Code
      v_debug_string := v_debug_string ||chr(13)||'5) After Line Item Loop';

      --Build Order End for e-Mail
      v_order_dat_items := v_order_dat_items||chr(13)||'</TABLE>'||chr(13)||'<P>';
      --Debug Code
      v_debug_string := v_debug_string ||chr(13)||    '5.1';
      v_order_dat_items := v_order_dat_items||chr(13)||'<B>Total Items Count: </B>'||v_total_items;

            --Debug Code
      v_debug_string := v_debug_string ||chr(13)||    '5.2';
      v_order_dat_end := chr(13)||'</TD></TR>';
            --Debug Code
      v_debug_string := v_debug_string ||chr(13)||    '5.3';
      v_order_dat_end := v_order_dat_end||chr(13)||'</TABLE>';
            --Debug Code
      v_debug_string := v_debug_string ||chr(13)||    '5.4';
      v_order_dat_end := v_order_dat_end||chr(13)||'</BODY></HTML>';

      --Debug Code
      v_debug_string := v_debug_string ||chr(13)||    '5.5';
      --Build Order End for Fax
      v_order_dat_fax:= v_order_dat_fax||'Total Items Count: '||v_total_items;

      --Debug Code
      v_debug_string := v_debug_string ||chr(13)||'6) After build of Order End text/html';

      --Ver 1.9: Check to see if this is an order confirmation only. if it is, don't send it to the wholesaler. Just send it to the ASM and eFEX inbox.
      IF v_phoned_flg = 'Y' THEN
           SEND_MAIL(v_fe_email||v_email, 'eFEX TIO CONFIRMATION ONLY for '||header_row.customer_name, v_order_dat||v_order_dat_items||v_order_dat_end,'text/html');
      ELSE
          --If the distributor has an e-mail address then send the order as an email.
           IF v_distributor_email IS NOT NULL THEN
               --Send the order email to ASM and to Functional Expert
               SEND_MAIL(v_fe_email||v_email||','||v_distributor_email, 'eFEX E-MAIL Order For '||header_row.customer_name, v_order_dat||v_order_dat_items||v_order_dat_end,'text/html');
           ELSE

               SEND_MAIL(v_fe_email||v_email, 'eFEX FAX Order has been sent for '||header_row.customer_name, v_order_dat||v_order_dat_items||v_order_dat_end,'text/html');
               --Send the order to ZETAFAX.
               SEND_MAIL(v_distributor_zetafax_email, 'eFEX FAX Order For '||header_row.customer_name||'. Order Taken By '||header_row.firstname||' '||header_row.lastname||' '||header_row.order_date||'.', v_order_dat_fax,NULL);
           END IF; --Ver 1.0
       END IF;

      --Debug Code
      v_debug_string := v_debug_string ||chr(13)||'7) After Send order to distributor';

      --Ver 1.7: Check to see if Customer needs a copy of the order sent to them
      IF v_print_statement_flg = 'Y' THEN
          --Check to see if the Customer has an e-mail address and send
          IF v_cust_email IS NOT NULL THEN
              --Send customer order copy as e-mail
              SEND_MAIL(v_cust_email||',efex@ap.effem.com', 'E-MAIL Copy of TIO eFEX Order For '||header_row.customer_name, v_order_dat||v_order_dat_items||v_order_dat_end,'text/html');
          ELSE
              IF v_cust_fax_num IS NOT NULL THEN
                  --Else send as fax
                  SEND_MAIL(v_cust_zetafax_email||',efex@ap.effem.com', 'FAX Copy of TIO eFEX Order For '||header_row.customer_name, v_order_dat_fax,NULL);
              ELSE
                  --Else send to efex inbox for posting.
                  SEND_MAIL('efex@ap.effem.com', 'POST Copy of eFEX TIO Order For '||header_row.customer_name, v_order_dat||v_order_dat_items||v_order_dat_end,'text/html');
              END IF;
          END IF;
      END IF;

      --Debug Code
      v_debug_string := v_debug_string ||chr(13)||'8) Before order status change';

      -- Mark Order as Transferred
      UPDATE orders
      SET    order_status = 'CLOSED'
      WHERE  order_id = header_row.order_id;

      --Debug Code
      v_debug_string := v_debug_string ||chr(13)||'9) After order status change';

    END IF;

    CLOSE TOTCHK_CRSR;
    COMMIT;

    --Debug Code
    v_debug_string := v_debug_string ||chr(13)||'10) After commit';

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN

    SEND_MAIL(v_error_email, 'eFEX Order Interface Error', 'Error in CHN_DATA_LOAD.EXTRACT_TURNIN_ORDERS'||chr(13)||SQLERRM||chr(13)||' Debug String: '||v_debug_string,NULL);

END EXTRACT_TURNIN_ORDERS;


/******************************************************************************
   NAME:       Extract Site Orders
   PURPOSE:    Extract Site orders (Order ordery_type is NULL) for transmission
               to either SAP or The selected distributor.

   REVISIONS:
   Ver     Date        Author           Description
   ------  ----------  ---------------  ------------------------------------
   1.0     18/06/2007  Toui Lepkhammany Initial Version
   1.1     19/10/2007  Toui Lepkhammany MOD: Fix bug where order status change
                                        does not commit.
                                        Moved order status update to close to 
                                        correct position.
                                        Changed 'PROCESSING' status to 'PROCESSINGSO'
                                        (Processing Site Orders)                                        
   1.2     12/05/2008  Geoff Dodds      Added total price check by site to ensure
                                        order meets minimum order size requirements 
   1.3     15/05/2008  Geoff Dodds      Modified flow to ensure an error in any part 
                                        of a split order puts the order into error
******************************************************************************/
PROCEDURE EXTRACT_SITE_ORDERS(p_filedir IN varchar2) IS

  v_order_valid          BOOLEAN; 
  
   --Cursor to get all unprocessed Site orders
  CURSOR HEADER_CRSR IS
       SELECT o.order_id,
              o.total_items,
              o.order_status
       FROM   orders o,
              order_source os,
              customer c
       WHERE  o.order_id = os.order_id
       AND    o.customer_id = c.customer_id
       AND    o.order_status in ('SUBMITTED','PROCESSINGSO')
       AND    os.status = 'A' 
       AND    c.market_id = v_market_id
       GROUP BY o.order_id, total_items, order_status;
       
   -- Total Check Cursor gives a total count of the order quantity
   CURSOR TOTCHK_CRSR(v_orderid NUMBER) IS
       SELECT   NVL(SUM(order_qty), 0) totalcheck,
                COUNT(*)               totallines
       FROM     order_item
       WHERE    order_id = v_orderid
       AND      NVL(order_qty,0) > 0;
   totchk_row TOTCHK_CRSR%rowtype;        

   -- Source Check Cursor checks total price for the the order source
   CURSOR SRCCHK_CRSR(v_orderid NUMBER) IS
       SELECT OS.ITEM_SOURCE_ID,
              OS.DISTRIBUTOR_ID,
              SUM(ORDER_QTY * DECODE(UOM, 'RSU', RSU_PRICE, 'MCU', MCU_PRICE, 'TDU', TDU_PRICE, 0)) AS TOTAL_SOURCE_VALUE,
              MAX(MIN_ORDER_VALUE) AS MIN_SOURCE_VALUE
       FROM   ORDER_ITEM OI, ITEM I, ITEM_SOURCE S, ORDER_SOURCE OS
       WHERE  OI.ITEM_ID = I.ITEM_ID
       AND    I.ITEM_SOURCE_ID = S.ITEM_SOURCE_ID
       AND    S.ITEM_SOURCE_ID = OS.ITEM_SOURCE_ID
       AND    OI.ORDER_ID = OS.ORDER_ID
       AND    OI.STATUS = 'A'
       AND    OI.ORDER_ID = v_orderid
       GROUP BY OS.ITEM_SOURCE_ID, OS.DISTRIBUTOR_ID;

BEGIN

  -- Read Order Header
  FOR order_row in HEADER_CRSR LOOP

    v_order_valid := true;
       
    -- Check Order Total Items 
    OPEN TOTCHK_CRSR(order_row.order_id);
    FETCH TOTCHK_CRSR INTO totchk_row;
    CLOSE TOTCHK_CRSR;
    IF (order_row.total_items <> totchk_row.totalcheck) THEN
      IF upper(order_row.order_status) = 'SUBMITTED' THEN
        UPDATE orders
        SET    order_status = 'PROCESSINGSO'
        WHERE  order_id = order_row.order_id;
      ELSIF upper(order_row.order_status) = 'PROCESSINGSO' THEN
        UPDATE orders
        SET    order_status = 'LINE COUNT ERROR'
        WHERE  order_id = order_row.order_id;
        SEND_MAIL(v_error_email, 'eFEX Site Order error for Order ID: '||order_row.order_id, 'Line Count Error for Order ID: '||order_row.order_id,NULL);
      END IF;
      
      v_order_valid := false;
      COMMIT;
    END IF;

    -- Check Order Source Totals 
    IF v_order_valid THEN 
      FOR source_row in SRCCHK_CRSR(order_row.order_id) LOOP
        -- Only Validate Direct Orders
        IF (source_row.distributor_id IS NULL) THEN
          -- Validate Order Total is Greater Than Required Minimum 
          IF (source_row.total_source_value < source_row.total_source_value) THEN
            UPDATE orders
            SET    order_status = 'ORDER SOURCE ERROR'
            WHERE  order_id = order_row.order_id;
            SEND_MAIL(v_error_email, 'eFEX Site Order error for Order ID: '||order_row.order_id, 'Site Min order value not met for Order ID: '||order_row.order_id,NULL);
            v_order_valid := false;
            COMMIT;
          END IF;
        END IF;
      END LOOP;  
    END IF;

    --Order is Valid so Process each Source/Site  
    IF v_order_valid THEN 
       
      FOR source_row in SRCCHK_CRSR(order_row.order_id) LOOP

        --If the distributor ID is not populated then it's a direct order
        IF source_row.distributor_id IS NULL THEN
          EXTRACT_DIRECT_SITE_ORDERS(order_row.order_id, source_row.item_source_id);               
        ELSE --the order is a turn in order
          EXTRACT_TURNIN_SITE_ORDERS(order_row.order_id, source_row.item_source_id, source_row.distributor_id);    
        END IF;

      END LOOP;
           
      -- Mark Order as Transferred
      UPDATE orders
      SET    order_status = 'CLOSED'
      WHERE  order_id = order_row.order_id;
      COMMIT;
     END IF;
                                    
   END LOOP;   

EXCEPTION
  WHEN OTHERS THEN

    SEND_MAIL(v_error_email, 'eFEX Order Interface Error', 'Error in CHN_DATA_LOAD.EXTRACT_SITE_ORDERS'||chr(13)||SQLERRM,NULL);
       
END EXTRACT_SITE_ORDERS;

/******************************************************************************
   NAME:       Extract Direct Site Orders
   PURPOSE:    Extract direct orders with site based items for transmission to SAP.

   REVISIONS:
   Ver     Date        Author           Description
   ------  ----------  ---------------  ------------------------------------
   1.0     18/06/2007  Toui Lepkhammany Initial Version
   1.1     23/10/2007   Toui Lepkhammany Mod: add ability to process 'print_statement_flg' to 
                                             send order copy to customers'
   1.2     21/01/2008  Toui Lepkhammany MOD: Added Total Mars List Price information to the 
                                        e-mail that gets sent to customer service and ASMs.                                              
******************************************************************************/
PROCEDURE EXTRACT_DIRECT_SITE_ORDERS(p_order_id IN NUMBER, p_item_source_id IN NUMBER) IS

   v_order_id               NUMBER(10);
   v_order_dat             VARCHAR2(32767);
   v_line_num              NUMBER(3);
   v_iface_id              NUMBER(15,0);
   v_item_source_id        NUMBER(10);
   v_order_suffix          VARCHAR2(10);
   v_item_linecount        NUMBER;
   v_item_qtycount         NUMBER;
   v_cust_email            VARCHAR2(255);   --Ver 1.1
   v_cust_fax_num          VARCHAR2(50);    --Ver 1.1
   v_cust_fax_num_check    VARCHAR2(50);    --Ver 1.1
   v_cust_zetafax_email    VARCHAR2(200);   --Ver 1.1
   v_print_statement_flg   VARCHAR2(1);     --Ver 1.1
   v_tot_list_price        NUMBER(10,2);    --Ver 1.2

   -- New Orders Cursor retruns the single unprocessed order based on the order ID (p_order_id) passed in
   CURSOR ORDER_HEADER_CRSR IS
       SELECT  order_id,
               a.customer_id,
               b.customer_code,
               a.cust_contact_id,
               a.distributor_id,
               a.user_id,
               a.print_statement_flg,   --Ver 1.1
               'Sales Order' order_type,
               order_date,
               deliver_date,
               purchase_order,
               order_notes,
               --total_items,
               confirm_flg,
               phoned_flg,
               delasap_flg,
               sendfax_flg,
               delnext_flg,
               order_status,
               c.username,
               c.firstname,
               c.lastname,
               c.email_address,
               d.first_name contact_first_name,
               d.last_name contact_last_name,
               b.customer_name,
               b.address_1,
               b.city,
               b.state,
               b.postcode,
               b.phone_number,
               b.fax_number,
               b.email_address AS cust_email, --Ver 1.1
               e.customer_code distrib_code,
               e.customer_name distrib_name,
               b.outlet_flg
       FROM    orders a,
               customer b,
               users c,
               cust_contact d,
               customer e
       WHERE   a.customer_id = b.customer_id
       AND     a.user_id = c.user_id
       AND       a.cust_contact_id = d.cust_contact_id(+)
       AND       a.distributor_id = e.customer_id(+)
       AND     a.order_id = v_order_id
       AND     b.market_id = v_market_id;
   order_header_rv ORDER_HEADER_CRSR%ROWTYPE;
      
   -- Order Detail Cursor return details for each line item in the order by given item source id
   CURSOR DETAIL_BY_SITE_CRSR IS
       SELECT  a.order_qty,
               a.item_id,
               b.item_code,
               b.item_name,
               b.tdu_price,   --Ver 1.2
               b.unit_measure,
               c.order_suffix
       FROM    order_item a,
               item b,
               item_source c
       WHERE   a.item_id = b.item_id
       AND     b.item_source_id = c.item_source_id
       AND     NVL(a.order_qty,0) > 0
       AND     a.order_id = v_order_id
       AND     c.item_source_id = v_item_source_id
       AND     c.status = 'A' 
   ORDER BY b.item_code;

   --Cursor to return the order_suffix given an item source ID
   CURSOR SITE_SUFFIX_CRSR(v_item_sourceID NUMBER) IS
       SELECT order_suffix
       FROM   item_source
       WHERE  item_source_id = v_item_sourceID;      
   site_suffix_rv SITE_SUFFIX_CRSR%ROWTYPE;    
   
  -- Total Check Cursor gives a total count of the order quantity given order ID and item source id
  CURSOR TOTALS_CRSR(v_orderID NUMBER, v_item_sourceID NUMBER) IS
    SELECT   NVL(SUM(oi.order_qty), 0) qtycount,
             COUNT(*)               totallines
    FROM     order_item oi,
             item i    
    WHERE    order_id = v_orderid
    AND      NVL(order_qty,0) > 0
    AND      oi.item_id = i.item_id
    AND      i.item_source_id = v_item_sourceID;
  totals_rv TOTALS_CRSR%rowtype; 
   
BEGIN

   --Get the item source order suffix
   OPEN SITE_SUFFIX_CRSR(p_item_source_id);
   FETCH SITE_SUFFIX_CRSR INTO site_suffix_rv;
   CLOSE SITE_SUFFIX_CRSR;
   
   --Get the order items line count and qty count by site.
   OPEN TOTALS_CRSR(p_order_id, p_item_source_id);
   FETCH TOTALS_CRSR INTO totals_rv;
   CLOSE TOTALS_CRSR;  
   
   -- Assign the variables
   v_order_id := p_order_id;
   v_item_source_id := p_item_source_id; 
   v_order_suffix := site_suffix_rv.order_suffix;
   v_item_linecount := totals_rv.totallines;
   v_item_qtycount := totals_rv.qtycount;
   
   --Check to see if the Site order has any ITEMS to send if it does then process it.
   IF v_item_linecount > 0 THEN
       -- Read Order Header
       OPEN ORDER_HEADER_CRSR;
       FETCH ORDER_HEADER_CRSR INTO order_header_rv;
       CLOSE ORDER_HEADER_CRSR;
 
       --Ver 1.1: Get customer email address
      v_cust_email := order_header_rv.cust_email;      
      --Ver 1.1: Get orders print_statement_flg
      v_print_statement_flg := order_header_rv.print_statement_flg;      
      --Ver 1.1: Get Customer fax number
      v_cust_fax_num := order_header_rv.fax_number;
      
      IF v_cust_fax_num IS NOT NULL THEN
          v_cust_fax_num_check := SUBSTR(v_cust_fax_num_check,1,3);
          IF v_cust_fax_num_check = '+61' THEN
             v_cust_fax_num := '0'||RTRIM(SUBSTR(v_cust_fax_num,4,50));
          END IF;
      END IF;
      
      --Ver 1.1: Build ZETAFAX email address of the customer to fax this order copy to.
      v_cust_zetafax_email := '"'||order_header_rv.customer_name||'@'||v_cust_fax_num||'@faxanz"';  
      
       -- Open Orders Interface
       v_iface_id := outbound_loader.create_interface('CISATL10');
        
       --  Build Order Header
       v_order_dat := 'HDR';
       v_order_dat := v_order_dat||'EFX';
       v_order_dat := v_order_dat||'Z001';
       v_order_dat := v_order_dat||RPAD(TO_CHAR(order_header_rv.username), 10);
       v_order_dat := v_order_dat||RPAD(TO_CHAR(800000000 + order_header_rv.order_id), 10);
       v_order_dat := v_order_dat||TO_CHAR(order_header_rv.order_date, 'yyyymmdd');
       v_order_dat := v_order_dat||TO_CHAR(order_header_rv.deliver_date, 'yyyymmdd');
       v_order_dat := v_order_dat||RPAD(' ', 6);
       v_order_dat := v_order_dat||LPAD(TO_CHAR(order_header_rv.customer_code), 8,0);
       v_order_dat := v_order_dat||LPAD(TO_CHAR(order_header_rv.customer_code), 8,0);
       v_order_dat := v_order_dat||LPAD(TO_CHAR(order_header_rv.customer_code), 8,0);
       v_order_dat := v_order_dat||RPAD(order_header_rv.purchase_order||' '||v_order_suffix||' ', 35); --Add order suffix to customer PO number.
       v_order_dat := v_order_dat||LPAD(TO_CHAR(v_item_linecount), 4,0);
       v_order_dat := v_order_dat||'147 ';
       v_order_dat := v_order_dat||'20';
       v_order_dat := v_order_dat||'51';
       v_order_dat := v_order_dat||'ZOR ';
       outbound_loader.append_data(v_order_dat);
        
       -- Build Order Note
       v_order_dat := 'HTX';
       v_order_dat := v_order_dat||'0001'; --SAP Comment code
       v_order_dat := v_order_dat||'EN';
       --Check to see if the order note is more than 70 Characters long.
       IF (LENGTH(TO_CHAR(order_header_rv.order_notes)) > 70) THEN
           --Put in replacement note asking CS to check the eFEX order email for the order comment details.
           v_order_dat := v_order_dat||RPAD('Order note too long. Please check eFEX email for PO:'||order_header_rv.purchase_order, 70);
       ELSE
           v_order_dat := v_order_dat||RPAD(TO_CHAR(order_header_rv.order_notes), 70);
       END IF;
       outbound_loader.append_data(v_order_dat);
        
       -- Build Order Detail
       v_line_num := 1;
       FOR detail_row IN DETAIL_BY_SITE_CRSR LOOP
           v_order_dat := 'DET';
           v_order_dat := v_order_dat||LPAD(TO_CHAR(v_line_num), 6,0);
           v_order_dat := v_order_dat||LPAD(detail_row.item_code,8,0);
           v_order_dat := v_order_dat||TO_CHAR(detail_row.order_qty, 'FM09999999999.000');
           v_order_dat := v_order_dat||'   '; -- UOM
           v_line_num  := v_line_num + 1;
           outbound_loader.append_data(v_order_dat);
       END LOOP;
       -- Close PASSTHROUGH INTERFACE
       outbound_loader.finalise_interface();                       

       COMMIT;

       -- Create Email for Customer Service
       -- Include ORDER SUFFIX to item details
       v_order_dat := RPAD('Date: ',20)||to_char(order_header_rv.order_date,'DD/MM/YYYY')||chr(13);
       v_order_dat := v_order_dat||RPAD('Order Taken By: ',20)||order_header_rv.firstname||' '||order_header_rv.lastname||chr(13);
       v_order_dat := v_order_dat||RPAD('Order Taken From: ',20)||order_header_rv.contact_first_name||' '||order_header_rv.contact_last_name||chr(13);
       v_order_dat := v_order_dat||RPAD('Order Type: ',20)||order_header_rv.order_type||chr(13);
       v_order_dat := v_order_dat||RPAD('eFEX Reference #: ',20)||order_header_rv.order_id||chr(13);
       v_order_dat := v_order_dat||chr(13);
       v_order_dat := v_order_dat||RPAD('Delivery Date: ',20)||to_char(order_header_rv.deliver_date,'DD/MM/YYYY')||chr(13);
       v_order_dat := v_order_dat||chr(13);
       v_order_dat := v_order_dat||RPAD('Customer Name: ',20)||order_header_rv.customer_name||chr(13);
       v_order_dat := v_order_dat||RPAD('Customer Number: ',20)||order_header_rv.customer_code||chr(13);
       v_order_dat := v_order_dat||RPAD('Customer Phone: ',20)||order_header_rv.phone_number||chr(13);
       v_order_dat := v_order_dat||RPAD('Customer Fax: ',20)||order_header_rv.fax_number||chr(13);
       v_order_dat := v_order_dat||RPAD('Delivery Address: ',20)||order_header_rv.address_1||chr(13);
       v_order_dat := v_order_dat||RPAD(' ',20)||order_header_rv.city||', '||order_header_rv.state||', '||order_header_rv.postcode||chr(13);
       v_order_dat := v_order_dat||chr(13);
       v_order_dat := v_order_dat||RPAD('PO: ',20)||order_header_rv.purchase_order||chr(13);
       v_order_dat := v_order_dat||chr(13);
       v_order_dat := v_order_dat||RPAD('Bill To Name: ',20)||order_header_rv.distrib_name||chr(13);
       v_order_dat := v_order_dat||RPAD('Bill To Number: ',20)||order_header_rv.distrib_code||chr(13);
       v_order_dat := v_order_dat||chr(13);
       v_order_dat := v_order_dat||RPAD('Comments: ',20)||order_header_rv.order_notes||chr(13);
       v_order_dat := v_order_dat||chr(13);
       v_tot_list_price := 0.00; --Ver 1.2
       v_line_num  := 1;       
       v_order_dat := v_order_dat||RPAD('Line#',8)||RPAD('Product#',10)||RPAD('Qty',6)||RPAD('UoM',6)||RPAD('Site',10)||'Product'||CHR(13);
       FOR detail_row IN DETAIL_BY_SITE_CRSR LOOP
             v_order_dat := v_order_dat||RPAD(TO_CHAR(v_line_num), 8);
             v_order_dat := v_order_dat||RPAD(detail_row.item_code, 10);
           v_order_dat := v_order_dat||RPAD(detail_row.order_qty, 6);
             v_order_dat := v_order_dat||RPAD(detail_row.unit_measure, 6);
             v_order_dat := v_order_dat||RPAD(detail_row.order_suffix, 10);
             v_order_dat := v_order_dat||detail_row.item_name||CHR(13);
           v_tot_list_price := v_tot_list_price + (detail_row.order_qty * detail_row.tdu_price); --Ver 1.2
           v_line_num  := v_line_num + 1;
       END LOOP;
       v_order_dat := v_order_dat||chr(13);
       v_order_dat := v_order_dat||RPAD('Total Case Count: ', 25)||v_item_qtycount;
       v_order_dat := v_order_dat||chr(13)||'Total Mars List Price: '||to_char(v_tot_list_price,'$999999.99'); --Ver 1.2

       SEND_MAIL(v_custserv_email||order_header_rv.email_address, 'eFEX Order for '||order_header_rv.customer_name||' PO #: '||order_header_rv.purchase_order||' '||v_order_suffix, v_order_dat,NULL);
       
       --Ver 1.1: Check to see if Customer needs a copy of the order sent to them
       IF v_print_statement_flg = 'Y' THEN
           --Check to see if the Customer has an e-mail address and send
           IF v_cust_email IS NOT NULL THEN
               --Send customer order copy as e-mail
               SEND_MAIL(v_cust_email||',efex@ap.effem.com', 'E-MAIL Copy of eFEX Direct Site Order For '||order_header_rv.customer_name||' PO #: '||order_header_rv.purchase_order||' '||v_order_suffix, v_order_dat,NULL);          
            ELSE
               IF v_cust_fax_num IS NOT NULL THEN
                   --Else send as fax
                   SEND_MAIL(v_cust_zetafax_email||',efex@ap.effem.com', 'FAX Copy of eFEX Direct Site Order For '||order_header_rv.customer_name||' PO #: '||order_header_rv.purchase_order||' '||v_order_suffix, v_order_dat,NULL);
               ELSE
                   --Else send to efex inbox for posting.
                   SEND_MAIL('efex@ap.effem.com', 'POST Copy of eFEX Direct Site Order For '||order_header_rv.customer_name||' PO #: '||order_header_rv.purchase_order||' '||v_order_suffix, v_order_dat,NULL);
               END IF;
           END IF;             
        END IF;
      
       COMMIT;
   
   END IF;
   
EXCEPTION
  WHEN OTHERS THEN

    IF outbound_loader.is_created = TRUE THEN
      outbound_loader.add_exception(SUBSTR(SQLERRM, 1, 512));
      outbound_loader.finalise_interface;
    END IF;

    SEND_MAIL(v_error_email, 'eFEX Order Interface Error', 'Error in CHN_DATA_LOAD.EXTRACT_DIRECT_SITE_ORDERS'||chr(13)||SQLERRM,NULL);

END EXTRACT_DIRECT_SITE_ORDERS;

/******************************************************************************
   NAME:       Extract Turn In Site Orders
   PURPOSE:    Extract Turn In Site orders  for transmission to distributors.

   REVISIONS:
   Ver     Date        Author           Description
   ------  ----------  ---------------  ------------------------------------
   1.0     19/06/2007  Toui Lepkhammany Initial Version
   1.1     27/08/2007   Dennis Chang     Mod: add comment Unit = Single consumer product
   1.2     17/10/2007   Toui Lepkhammany Mod: add change to UOM call TDU = Case, MCU = Inner, RSU = Unit
   1.3     23/10/2007   Toui Lepkhammany Mod: add ability to process 'print_statement_flg' to
                                             send order copy to customers'
   1.4    03/06/2008   Geoff Dodds       Use TDU/MCU/RSU NAME instead of ITEM_NAME based on UOM type
******************************************************************************/
PROCEDURE EXTRACT_TURNIN_SITE_ORDERS(p_order_id IN NUMBER, p_item_source_id IN NUMBER, p_distributor_id IN NUMBER) IS

   v_order_id                  NUMBER(10);
   v_order_dat                 VARCHAR2(32767);
   v_order_dat_items           VARCHAR2(32767);
   v_order_dat_items_count     VARCHAR2(50);
   v_order_dat_end             VARCHAR2(500);
   v_line_num                  NUMBER(3);
   v_email                       VARCHAR2(100);
   v_distributor_email         VARCHAR2(100);
   v_distributor_fax_num       VARCHAR2(50);
   v_distrib_fax_num_check     VARCHAR2(10);
   v_distributor_zetafax_email VARCHAR(200);
   v_distributor_id            NUMBER(10);
   v_item_source_id            NUMBER(10);
   v_order_suffix              VARCHAR2(10);
   v_item_linecount            NUMBER;
   v_item_qtycount             NUMBER;
   v_uom                       VARCHAR2(50);
   v_cust_email                VARCHAR2(255);   --Ver 1.3
   v_cust_fax_num              VARCHAR2(50);    --Ver 1.3
   v_cust_fax_num_check        VARCHAR2(50);    --Ver 1.3
   v_cust_zetafax_email        VARCHAR2(200);   --Ver 1.3
   v_print_statement_flg       VARCHAR2(1);     --Ver 1.3

  -- New Orders Cursor retruns the single unprocessed order based on the order ID (p_order_id) passed in
   CURSOR ORDER_HEADER_CRSR IS
       SELECT  a.order_id,
               a.customer_id,
               b.customer_code,
               a.cust_contact_id,
               f.distributor_id,
               a.user_id,
               a.print_statement_flg,         --Ver 1.3
               'Turn In Order' AS order_type,
               order_date,
               deliver_date,
               purchase_order,
               order_notes,
               total_items,
               confirm_flg,
               phoned_flg,
               delasap_flg,
               sendfax_flg,
               delnext_flg,
               order_status,
               c.firstname,
               c.lastname,
               c.email_address,
               d.first_name AS contact_first_name,
               d.last_name AS contact_last_name,
               b.customer_name,
               b.address_1,
               b.city,
               b.state,
               b.postcode,
               b.phone_number,
               b.fax_number,
               b.email_address AS cust_email,     --Ver 1.3
               e.customer_code AS distrib_code,
               e.customer_name AS distrib_name,
               e.email_address AS distrib_email,
               e.fax_number AS distrib_fax,
               b.outlet_flg
       FROM    orders a,
               customer b,
               users c,
               cust_contact d,
               customer e,
               order_source f
       WHERE   a.customer_id = b.customer_id
       AND       a.user_id = c.user_id
       AND       a.cust_contact_id = d.cust_contact_id(+)
       AND     a.order_id = f.order_id
       AND     f.distributor_id = e.customer_id
       AND     f.item_source_id = v_item_source_id
       AND     f.distributor_id = v_distributor_id
       AND     a.order_id = v_order_id
       AND     b.market_id = v_market_id;
   order_header_rv ORDER_HEADER_CRSR%ROWTYPE;

   -- Order Detail Cursor return details for each line item in the order by given item source id
   CURSOR DETAIL_BY_SITE_CRSR IS
       SELECT  a.order_qty,
               a.item_id,
               b.item_code,
               NVL(DECODE(a.uom, 'TDU', ITEM_TDU_NAME, 'MCU', ITEM_MCU_NAME, 'RSU', ITEM_RSU_NAME, NULL), ITEM_NAME) AS item_name, -- Ver: 1.4
               NVL(a.uom, 'Case') AS unit_measure, --use the Order table's unit of measure
               c.order_suffix
       FROM    order_item a,
               item b,
               item_source c
       WHERE   a.item_id = b.item_id
       AND     b.item_source_id = c.item_source_id
       AND     NVL(a.order_qty,0) > 0
       AND     a.order_id = v_order_id
       AND     c.item_source_id = v_item_source_id
       AND     c.status = 'A'
   ORDER BY b.item_code;

   --Cursor to return the order_suffix given an item source ID
   CURSOR SITE_SUFFIX_CRSR(v_item_sourceID NUMBER) IS
       SELECT order_suffix
       FROM   item_source
       WHERE  item_source_id = v_item_sourceID;
   site_suffix_rv SITE_SUFFIX_CRSR%ROWTYPE;

     -- Total Check Cursor gives a total count of the order quantity given order ID and item source id
   CURSOR TOTALS_CRSR(v_orderID NUMBER, v_item_sourceID NUMBER) IS
       SELECT   NVL(SUM(oi.order_qty), 0) qtycount,
                COUNT(*)               totallines
       FROM     order_item oi,
                item i
       WHERE    order_id = v_orderid
       AND      NVL(order_qty,0) > 0
       AND      oi.item_id = i.item_id
       AND      i.item_source_id = v_item_sourceID;
   totals_rv TOTALS_CRSR%rowtype;

BEGIN

   --Get the item source order suffix
   OPEN SITE_SUFFIX_CRSR(p_item_source_id);
   FETCH SITE_SUFFIX_CRSR INTO site_suffix_rv;
   CLOSE SITE_SUFFIX_CRSR;

   --Get the order items line count and qty count by site.
   OPEN TOTALS_CRSR(p_order_id, p_item_source_id);
   FETCH TOTALS_CRSR INTO totals_rv;
   CLOSE TOTALS_CRSR;

   v_order_id := p_order_id;
   v_item_source_id := p_item_source_id;
   v_distributor_id := p_distributor_id;
   v_order_suffix := site_suffix_rv.order_suffix;
   v_item_linecount := totals_rv.totallines;
   v_item_qtycount := totals_rv.qtycount;

   --Check to see if the Site order has any products to send if it does then process it.
   IF v_item_linecount > 0 THEN

       -- Read Order Header
       OPEN ORDER_HEADER_CRSR;
       FETCH ORDER_HEADER_CRSR INTO order_header_rv;
       CLOSE ORDER_HEADER_CRSR;

       -- Get email address of user that created the order
       SELECT email_address
       INTO   v_email
       FROM   users
       WHERE  user_id = order_header_rv.user_id;

       --Ver 1.0: Get email address of the distributor to email this order to.
       v_distributor_email := order_header_rv.distrib_email;

       --Ver 1.0: if '+61' replace with '0' to fax number for sending from ap ZETAFAX.
       v_distrib_fax_num_check := SUBSTR(order_header_rv.distrib_fax,1,3);
       IF  v_distrib_fax_num_check = '+61' THEN
           v_distributor_fax_num := '0'||RTRIM(SUBSTR(order_header_rv.distrib_fax,4,50));
       ELSE
           v_distributor_fax_num := order_header_rv.distrib_fax;
       END IF;

       --build ZETAFAX email address of the distributor to fAX this order to.
       v_distributor_zetafax_email := '"'||order_header_rv.distrib_name||'@'||v_distributor_fax_num||'@faxanz"';

       --Ver 1.3: Get customer email address
      v_cust_email := order_header_rv.cust_email;
      --Ver 1.3: Get orders print_statement_flg
      v_print_statement_flg := order_header_rv.print_statement_flg;
      --Ver 1.3: Get Customer fax number
      v_cust_fax_num := order_header_rv.fax_number;

      IF v_cust_fax_num IS NOT NULL THEN
          v_cust_fax_num_check := SUBSTR(v_cust_fax_num_check,1,3);
          IF v_cust_fax_num_check = '+61' THEN
             v_cust_fax_num := '0'||RTRIM(SUBSTR(v_cust_fax_num,4,50));
          END IF;
      END IF;

      --Ver 1.3: Build ZETAFAX email address of the customer to fax this order copy to.
      v_cust_zetafax_email := '"'||order_header_rv.customer_name||'@'||v_cust_fax_num||'@faxanz"';

       -- Create Order Data
       v_order_dat := 'TURN IN ORDER'||chr(13);
       v_order_dat := v_order_dat||chr(13);
       v_order_dat := v_order_dat||'Please see the following Turn In Order.'||chr(13);
       v_order_dat := v_order_dat||'PO: '||order_header_rv.purchase_order||' '||v_order_suffix||chr(13);
       v_order_dat := v_order_dat||'If there are any queries, please contact me.'||chr(13);
       v_order_dat := v_order_dat||'Thank you'||chr(13);
       v_order_dat := v_order_dat||'Regards,'||chr(13);
       v_order_dat := v_order_dat||order_header_rv.firstname||' '||order_header_rv.lastname||chr(13);
       v_order_dat := v_order_dat||v_email||chr(13);
       v_order_dat := v_order_dat||chr(13);
       v_order_dat := v_order_dat||chr(13);
       v_order_dat := v_order_dat||chr(13);
       v_order_dat := v_order_dat||chr(13);
       v_order_dat := v_order_dat||chr(13);
       v_order_dat := v_order_dat||chr(13);
       v_order_dat := v_order_dat||chr(13);
       v_order_dat := v_order_dat||chr(13);
       v_order_dat := v_order_dat||chr(13);
       v_order_dat := v_order_dat||'Delivery Date: '||to_char(order_header_rv.deliver_date,'DD/MM/YYYY')||chr(13);
       v_order_dat := v_order_dat||chr(13);
       v_order_dat := v_order_dat||'Customer Name: '||order_header_rv.customer_name||chr(13);
       v_order_dat := v_order_dat||'Customer Number: '||order_header_rv.customer_code||chr(13);
       v_order_dat := v_order_dat||'Customer Phone: '||order_header_rv.phone_number||chr(13);
       v_order_dat := v_order_dat||'Customer Fax: '||order_header_rv.fax_number||chr(13);
       v_order_dat := v_order_dat||'Delivery Address: '||order_header_rv.address_1||chr(13);
       v_order_dat := v_order_dat||order_header_rv.city ||', '||order_header_rv.state||', '||order_header_rv.postcode||chr(13);
       v_order_dat := v_order_dat||chr(13);
       v_order_dat := v_order_dat||'Order Date: '||to_char(order_header_rv.order_date,'DD/MM/YYYY')||chr(13);
       v_order_dat := v_order_dat||'Order Taken By: '||order_header_rv.firstname||' '||order_header_rv.lastname||chr(13);
       v_order_dat := v_order_dat||'E-Mail Address: '||v_email||chr(13);
       v_order_dat := v_order_dat||'Order Taken From: '||order_header_rv.contact_first_name||' '||order_header_rv.contact_last_name||chr(13);
       v_order_dat := v_order_dat||'Order Type: '||order_header_rv.order_type||chr(13);
       v_order_dat := v_order_dat||'eFEX Reference #: '||order_header_rv.order_id||chr(13);
       v_order_dat := v_order_dat||chr(13);
       v_order_dat := v_order_dat||'PO: '||order_header_rv.purchase_order||' '||v_order_suffix||chr(13);
       v_order_dat := v_order_dat||chr(13);
       v_order_dat := v_order_dat||'Wholesaler Name: '||order_header_rv.distrib_name||chr(13);
       v_order_dat := v_order_dat||'Wholesaler Number: '||order_header_rv.distrib_code||chr(13);
       v_order_dat := v_order_dat||chr(13);
       v_order_dat := v_order_dat||'Comments: '||order_header_rv.order_notes||chr(13);
       v_order_dat := v_order_dat||'          '||'Unit = Single consumer product'||chr(13);
       v_order_dat := v_order_dat||chr(13);
       v_order_dat := v_order_dat||chr(13);

       v_line_num := 1;
       v_order_dat := v_order_dat||RPAD('Line#',8)||RPAD('Product#',10)||RPAD('Qty',6)||RPAD('UoM',10)||'Product'||CHR(13);
       FOR detail_row IN DETAIL_BY_SITE_CRSR LOOP
           -- 1.6 Mod: work out UOM text to send to wholesalers
           v_uom := detail_row.unit_measure;
           IF v_uom = 'TDU' THEN
              v_uom := 'Case';
           ELSE
              IF v_uom = 'MCU' THEN
                  v_uom := 'Inner';
              ELSE
                  IF v_uom = 'RSU' THEN
                      v_uom := 'Unit';
                  END IF;
              END IF;
           END IF;
           v_order_dat := v_order_dat||RPAD(TO_CHAR(v_line_num), 8);
           v_order_dat := v_order_dat||RPAD(detail_row.item_code, 10);
           v_order_dat := v_order_dat||RPAD(detail_row.order_qty, 6);
           v_order_dat := v_order_dat||RPAD(v_uom, 10);
           v_order_dat := v_order_dat||detail_row.item_name||CHR(13);
           v_line_num := v_line_num + 1;
       END LOOP;

       v_order_dat:= v_order_dat||'Total Items Count: '||v_item_qtycount;

      --If the distributor has an e-mail address then send the order as an email.
       IF v_distributor_email IS NOT NULL THEN
           --Send the order email to ASM and to Functional Expert
           SEND_MAIL(v_fe_email||v_email||','||v_distributor_email, 'eFEX E-mail Order For '||order_header_rv.customer_name||' '||v_order_suffix, v_order_dat,NULL);
       ELSE
           SEND_MAIL(v_fe_email||v_email, 'eFEX Fax Order has been sent for '||order_header_rv.customer_name, v_order_dat,NULL);
           --Send the order to ZETAFAX.
           SEND_MAIL(v_distributor_zetafax_email, 'eFEX Fax Order For '||order_header_rv.customer_name||' '||v_order_suffix||'. Order Taken By '||order_header_rv.firstname||' '||order_header_rv.lastname||' '||order_header_rv.order_date||'.', v_order_dat,NULL);
       END IF;

       --Ver 1.1: Check to see if Customer needs a copy of the order sent to them
       IF v_print_statement_flg = 'Y' THEN
           --Check to see if the Customer has an e-mail address and send
           IF v_cust_email IS NOT NULL THEN
               --Send customer order copy as e-mail
               SEND_MAIL(v_cust_email||',efex@ap.effem.com', 'E-MAIL Copy of eFEX TIO Site Order For '||order_header_rv.customer_name||' '||v_order_suffix, v_order_dat,NULL);
            ELSE
               IF v_cust_fax_num IS NOT NULL THEN
                   --Else send as fax
                   SEND_MAIL(v_cust_zetafax_email||',efex@ap.effem.com', 'FAX Copy of eFEX TIO Site Order For '||order_header_rv.customer_name||' '||v_order_suffix, v_order_dat,NULL);
               ELSE
                   --Else send to efex inbox for posting.
                   SEND_MAIL('efex@ap.effem.com', 'POST Copy of eFEX TIO Site Order For '||order_header_rv.customer_name||' '||v_order_suffix, v_order_dat,NULL);
               END IF;
           END IF;
        END IF;

    END IF;

EXCEPTION
  WHEN OTHERS THEN

    SEND_MAIL(v_error_email, 'eFEX Order Interface Error', 'Error in CHN_DATA_LOAD.EXTRACT_TURNIN_SITE_ORDERS'||chr(13)||SQLERRM,NULL);

END EXTRACT_TURNIN_SITE_ORDERS;

END CHN_DATA_LOAD;
/
