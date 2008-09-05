CREATE OR REPLACE PACKAGE CHN_DATA_LOAD AS

FUNCTION CUST_ITEM_REF(p_CustomerID IN NUMBER, p_ItemID IN NUMBER) RETURN NUMBER;
PROCEDURE EXTRACT_TURNIN_ORDERS;

END CHN_DATA_LOAD;
/

CREATE OR REPLACE PACKAGE BODY CHN_DATA_LOAD AS
   v_market_id  number := 4;
   v_deliver_within_days int := 3;
   v_error_email    varchar2(100) := 'asia.pacific.efex.error.messages@ap.effem.com';
   v_fe_email       varchar(200)  := 'efex@ap.effem.com';

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
   NAME:       Extract Turnin Orders With Faxing
   PURPOSE:    Extract TurnIN orders (Order Distributor_ID <> 0) for transmission
               to distributors.

   REVISIONS:
   Ver     Date        Author           Description
   ------  ----------  ---------------  ------------------------------------
   1.0     19/08/2008  Steve Gregan     Initial version based on UBA_DATA_LOAD

******************************************************************************/
PROCEDURE EXTRACT_TURNIN_ORDERS IS

  v_conn utl_smtp.connection;
  v_order_dat_items_count VARCHAR2(5);
  v_line_num              NUMBER(3);
  v_email                 VARCHAR2(100);
  v_distributor_email     VARCHAR2(255);
  v_distributor_fax_num   VARCHAR2(50);
  v_distrib_fax_num_check VARCHAR2(10);
  v_distributor_zetafax_email VARCHAR(200);
  v_uom                   VARCHAR2(50);
  v_cust_email            VARCHAR2(255);
  v_cust_fax_num          VARCHAR2(50);
  v_cust_fax_num_check    VARCHAR2(50);
  v_cust_zetafax_email    VARCHAR2(200);
  v_print_statement_flg   VARCHAR2(1);
  v_phoned_flg            VARCHAR2(1);
  v_total_items           VARCHAR2(100);
  v_recipient             VARCHAR2(4000);

  type typ_output is table of varchar2(2000 char) index by binary_integer;
  tbl_orddat typ_output;
  tbl_ordfax typ_output;

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
           b.email_address AS cust_email,
           e.customer_code AS distrib_code,
           e.customer_name AS distrib_name,
           e.email_address AS distrib_email,
           e.fax_number AS distrib_fax,
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
    AND    a.distributor_id IS NOT NULL
    AND    a.order_status in ('SUBMITTED','PROCESSING')
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
			 NVL(DECODE(a.uom, 'TDU', ITEM_TDU_NAME, 'MCU', ITEM_MCU_NAME, 'RSU', ITEM_RSU_NAME, NULL), ITEM_NAME) AS item_name,
             NVL(a.uom, 'Case') AS unit_measure,--Ver: 1.1
			 CUST_ITEM_REF(o.customer_id, a.item_id) AS cust_item_ref
    FROM     orders o, order_item a, item b
    WHERE    o.order_id = a.order_id
	AND      a.item_id = b.item_id
    AND      NVL(order_qty,0) > 0
    AND      o.order_id = v_orderid
    ORDER BY item_code;

BEGIN

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

      --
      -- Clear the work data
      --
      tbl_orddat.delete;
      tbl_ordfax.delete;

      v_total_items := TO_CHAR(header_row.total_items);

      -- Get email address of user that created the order
      SELECT email_address
      INTO   v_email
      FROM   users
      WHERE  user_id = header_row.user_id;

      -- Get email address of the distributor to email this order to.
      v_distributor_email := header_row.distrib_email;

      -- if '+81' replace with '0' to fax number for sending from ap ZETAFAX.
      v_distrib_fax_num_check := SUBSTR(header_row.distrib_fax,1,3);
      IF v_distrib_fax_num_check = '+81' THEN
         v_distributor_fax_num := '0'||RTRIM(SUBSTR(header_row.distrib_fax,4,50));
      ELSE
         v_distributor_fax_num := header_row.distrib_fax;
      END IF;

      -- build ZETAFAX email address of the distributor to fAX this order to.
      v_distributor_zetafax_email := '"'||header_row.distrib_name||'@'||v_distributor_fax_num||'@faxanz"';

      -- Get customer email address
      v_cust_email := header_row.cust_email;

      -- Get orders print_statement_flg
      v_print_statement_flg := header_row.print_statement_flg;

      -- Get Customer fax number
      v_cust_fax_num := header_row.fax_number;

      -- Get orders phoned_flg
      v_phoned_flg := header_row.phoned_flg;

      IF v_cust_fax_num IS NOT NULL THEN
          v_cust_fax_num_check := SUBSTR(v_cust_fax_num_check,1,3);
          IF v_cust_fax_num_check = '+81' THEN
             v_cust_fax_num := '0'||RTRIM(SUBSTR(v_cust_fax_num,4,50));
          END IF;
      END IF;

      -- Build ZETAFAX email address of the customer to fax this order copy to.
      v_cust_zetafax_email := '"'||header_row.customer_name||'@'||v_cust_fax_num||'@faxanz"';

      -- Create Order Header Data for e-mail (as HTML)
      tbl_orddat(tbl_orddat.count + 1) := '<HTML>'||chr(13);
      tbl_orddat(tbl_orddat.count + 1) := '<HEAD>'||chr(13);
      tbl_orddat(tbl_orddat.count + 1) := '<TITLE>MARS Turn In Order</TITLE>'||chr(13);
      tbl_orddat(tbl_orddat.count + 1) := '</HEAD>'||chr(13);
      tbl_orddat(tbl_orddat.count + 1) := '<BODY>'||chr(13);
      tbl_orddat(tbl_orddat.count + 1) := '<P>'||chr(13);
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<B>eFEX Reference #: </B>'||header_row.order_id;
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TR><TD><FONT style="FONT-WEIGHT: bold; FONT-SIZE: large"><CENTER>MARS TURN IN ORDER</CENTER></FONT></TD></TR>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'</TABLE>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<P>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TR><TD>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TR><TD colSpan=4><HR width="100%"></TD></TR>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TR><TD><B>Wholesaler Name: '  ||'</TD></B><TD>'||header_row.distrib_name||'</TD><TD><B>Wholesaler Number: '||'</TD></B><TD>'||header_row.distrib_code||'</TD></TR>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TR><TD><B>Delivery Date: '    ||'</TD></B><TD>'||to_char(header_row.deliver_date,'DD/MM/YYYY')||'</TD></TR>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TR><TD colSpan=4><HR width="100%"></TD></TR>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TR><TD><B>Customer Name: '    ||'</TD></B><TD>'||header_row.customer_name||'</TD><TD><B>Order Taken From: ' ||'</TD></B><TD>'||header_row.contact_first_name||' '||header_row.contact_last_name||'</TD></TR>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TR><TD><B>Customer Number: '  ||'</TD></B><TD>'||header_row.customer_code||'</TD></TR>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TR><TD><B>Delivery Address: ' ||'</TD></B><TD>'||header_row.address_1||'</TD></TR>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TR><TD></TD><TD>' ||header_row.city ||', '||header_row.state||', '||header_row.postcode||'</TD></TR>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TR><TD><B>Customer Phone: '||'</TD></B><TD>'||header_row.phone_number||'</TD></TR>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TR><TD><B>Customer Fax: '||'</TD></B><TD>'||header_row.fax_number||'</TD></TR>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TR><TD colSpan=4><HR width="100%"></TD></TR>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TR><TD><B>Order Date: '||'</TD></B><TD>'||to_char(header_row.order_date,'DD/MM/YYYY')||'</TD></TR>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TR><TD colSpan=4><HR width="100%"></TD></TR>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TR><TD><B>Order Taken By: '   ||'</TD></B><TD>'||header_row.firstname||' '||header_row.lastname||'</TD><TD><B>E-Mail Address: '||'</TD></B><TD>'||nvl(v_email,'No email')||'</TD></TR>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TR><TD><B>PO: '||'</TD></B><TD>'||header_row.purchase_order||'</TD></TR>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TR><TD><B>Comments: '||'</TD></B><TD>'||header_row.order_notes||'</TD></TR>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TR><TD></TD><TD>Unit = Single consumer product</TD></TR>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'</TABLE><BR>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'</TD></TR>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TR><TD>';

      --Create Order Header Data for Fax (as Text)
      tbl_ordfax(tbl_ordfax.count + 1) := chr(10)||'TURN IN ORDER'||chr(13)||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := 'Please see the following Turn In Order.'||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := 'PO: '||header_row.purchase_order||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := 'If there are any queries, please contact me.'||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := 'Thank you'||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := 'Regards,'||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := header_row.firstname||' '||header_row.lastname||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := nvl(v_email,'No email')||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := Chr(13)||Chr(13)||Chr(13)||Chr(13)||Chr(13)||Chr(13)||Chr(13)||Chr(13)||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := 'eFEX Reference #: '||header_row.order_id||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := 'MARS TURN IN ORDER'||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := '--------------------------------------------------------------'||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := 'Wholesaler Name:  '||header_row.distrib_name||'. Wholesaler Number: '||header_row.distrib_code||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := 'Delivery Date:    '||to_char(header_row.deliver_date,'DD/MM/YYYY')||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := '--------------------------------------------------------------'||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := 'Customer Name:    '||header_row.customer_name||'. Order Taken From: '||header_row.contact_first_name||' '||header_row.contact_last_name||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := 'Delivery Address: '||header_row.address_1||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := '                  '||header_row.city ||', '||header_row.state||', '||header_row.postcode||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := 'Customer Number:  '||header_row.customer_code||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := 'Customer Phone:   '||header_row.phone_number||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := 'Customer Fax:     '||header_row.fax_number||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := '--------------------------------------------------------------'||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := 'Order Date:       '||to_char(header_row.order_date,'DD/MM/YYYY')||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := '--------------------------------------------------------------'||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := 'Order Taken By:   '||header_row.firstname||' '||header_row.lastname||'.'||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := 'E-Mail Address:   '||nvl(v_email,'No email')||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := 'PO:               '||header_row.purchase_order||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := 'Comments:         '||header_row.order_notes||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := '                  '||'Unit = Single consumer product'||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := '--------------------------------------------------------------'||Chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := chr(13);
      tbl_ordfax(tbl_ordfax.count + 1) := chr(13);

      v_line_num := 1;
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0><TR bgColor=gray><TD><B>Line#</B></TD><TD><B>Product#</B></TD><TD><B>WHS ID</B></TD><TD><B>Qty</B></TD><TD><B>UoM</B></TD><TD><B>Product</B></TD></TR>';
      tbl_ordfax(tbl_ordfax.count + 1) := chr(13)||RPAD('|Line#',6)||RPAD('|Product#',10)||RPAD('|WHS ID',10)||RPAD('|Qty',6)||RPAD('|UoM',7)||'|Product';
      tbl_ordfax(tbl_ordfax.count + 1) := '|------------------------------------------------------------------------------|'||chr(13);
      FOR detail_row IN DETAIL_CRSR(header_row.order_id) LOOP

        -- work out UOM text to send to wholesalers
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
           tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TR bgColor=#eaeaea>';
        ELSE
           tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TR>';
        END IF;
        tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TD>'||RPAD(TO_CHAR(v_line_num), 8)     ||'</TD>';
        tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TD>'||RPAD(detail_row.item_code, 10)   ||'</TD>';
        tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TD>'||RPAD(detail_row.cust_item_ref,10)||'</TD>';
        tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TD>'||RPAD(detail_row.order_qty, 6)    ||'</TD>';
        tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TD>'||RPAD(v_uom, 10)                  ||'</TD>';
        tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<TD>'||detail_row.item_name             ||'</TD>';
        tbl_orddat(tbl_orddat.count + 1) := chr(13)||'</TR>';
        --Build Order Item Data for Fax
        tbl_ordfax(tbl_ordfax.count + 1) := '|'||RPAD(TO_CHAR(v_line_num), 5)||
                                            '|'||RPAD(detail_row.item_code, 9)||
                                            '|'||RPAD(detail_row.cust_item_ref, 9)||
                                            '|'||RPAD(detail_row.order_qty, 5)||
                                            '|'||RPAD(v_uom, 6)||
                                            '|'||detail_row.item_name;
        tbl_ordfax(tbl_ordfax.count + 1) := chr(13)||'|------------------------------------------------------------------------------|'||chr(13);

        v_line_num := v_line_num + 1;
      END LOOP;

      --Build Order End for e-Mail
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'</TABLE>'||'<P>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'<B>Total Items Count: </B>'||v_total_items;
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'</TD></TR>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'</TABLE>';
      tbl_orddat(tbl_orddat.count + 1) := chr(13)||'</BODY></HTML>';

      --Build Order End for Fax
      tbl_ordfax(tbl_ordfax.count + 1) := 'Total Items Count: '||v_total_items;

      -- Check to see if this is an order confirmation only. if it is, don't send it to the wholesaler. Just send it to the ASM and eFEX inbox.
      IF v_phoned_flg = 'Y' THEN
           v_recipient := v_fe_email;
           if not(v_email is null) then
              v_recipient := v_recipient||','||v_email;
           end if;
           v_conn := smtp_mailer.begin_mail('efex@ap.effem.com',
                                            v_recipient,
                                            'eFEX TIO CONFIRMATION ONLY for '||header_row.customer_name,
                                            'text/html; charset=utf-8');
           for idx in 1..tbl_orddat.count loop
              smtp_mailer.write_mb_text(v_conn, tbl_orddat(idx));
           end loop;
  	   smtp_mailer.end_mail(v_conn);
      ELSE
          --If the distributor has an e-mail address then send the order as an email.
           IF v_distributor_email IS NOT NULL THEN
               v_recipient := v_fe_email;
               if not(v_email is null) then
                  v_recipient := v_recipient||','||v_email;
               end if;
               v_recipient := v_recipient||','||v_distributor_email;
               v_conn := smtp_mailer.begin_mail('efex@ap.effem.com',
                                                v_recipient,
                                                'eFEX E-MAIL Order For '||header_row.customer_name,
                                                'text/html; charset=utf-8');
               for idx in 1..tbl_orddat.count loop
                  smtp_mailer.write_mb_text(v_conn, tbl_orddat(idx));
               end loop;
               smtp_mailer.end_mail(v_conn);
           ELSE
               v_recipient := v_fe_email;
               if not(v_email is null) then
                  v_recipient := v_recipient||','||v_email;
               end if;
               v_conn := smtp_mailer.begin_mail('efex@ap.effem.com',
                                                v_recipient,
                                                'eFEX FAX Order has been sent for '||header_row.customer_name,
                                                'text/html; charset=utf-8');
               for idx in 1..tbl_orddat.count loop
                  smtp_mailer.write_mb_text(v_conn, tbl_orddat(idx));
               end loop;
               smtp_mailer.end_mail(v_conn);
               v_recipient := v_distributor_zetafax_email;
               v_conn := smtp_mailer.begin_mail('efex@ap.effem.com',
                                                v_recipient,
                                                'eFEX FAX Order For '||header_row.customer_name||'. Order Taken By '||header_row.firstname||' '||header_row.lastname||' '||header_row.order_date||'.',
                                                'text/plain; charset=utf-8');
               for idx in 1..tbl_ordfax.count loop
                  smtp_mailer.write_mb_text(v_conn, tbl_ordfax(idx));
               end loop;
               smtp_mailer.end_mail(v_conn);
           END IF;
       END IF;

      -- Check to see if Customer needs a copy of the order sent to them
      IF v_print_statement_flg = 'Y' THEN
          --Check to see if the Customer has an e-mail address and send
          IF v_cust_email IS NOT NULL THEN
               v_recipient := v_cust_email||',efex@ap.effem.com';
               v_conn := smtp_mailer.begin_mail('efex@ap.effem.com',
                                                v_recipient,
                                                'E-MAIL Copy of TIO eFEX Order For '||header_row.customer_name,
                                                'text/html; charset=utf-8');
               for idx in 1..tbl_orddat.count loop
                  smtp_mailer.write_mb_text(v_conn, tbl_orddat(idx));
               end loop;
               smtp_mailer.end_mail(v_conn);
          ELSE
              IF v_cust_fax_num IS NOT NULL THEN
                  v_recipient := v_cust_zetafax_email||',efex@ap.effem.com';
                  v_conn := smtp_mailer.begin_mail('efex@ap.effem.com',
                                                   v_recipient,
                                                   'FAX Copy of TIO eFEX Order For '||header_row.customer_name,
                                                   'text/plain; charset=utf-8');
                  for idx in 1..tbl_ordfax.count loop
                     smtp_mailer.write_mb_text(v_conn, tbl_ordfax(idx));
                  end loop;
                  smtp_mailer.end_mail(v_conn);
              ELSE
                  v_recipient := 'efex@ap.effem.com';
                  v_conn := smtp_mailer.begin_mail('efex@ap.effem.com',
                                                   v_recipient,
                                                   'POST Copy of eFEX TIO Order For '||header_row.customer_name,
                                                   'text/html; charset=utf-8');
                  for idx in 1..tbl_orddat.count loop
                     smtp_mailer.write_mb_text(v_conn, tbl_orddat(idx));
                  end loop;
                  smtp_mailer.end_mail(v_conn);
              END IF;
          END IF;
      END IF;

      -- Mark Order as Transferred
      UPDATE orders
      SET    order_status = 'CLOSED'
      WHERE  order_id = header_row.order_id;

    END IF;

    CLOSE TOTCHK_CRSR;
    COMMIT;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN

    SEND_MAIL(v_error_email, 'eFEX Order Interface Error', 'Error in CHN_DATA_LOAD.EXTRACT_TURNIN_ORDERS'||chr(13)||SQLERRM,NULL);

END EXTRACT_TURNIN_ORDERS;

END CHN_DATA_LOAD;
/
