{
  ic_record_type = substr($0,0+1,6)
  px_company_code = substr($0,428+1,3)
  px_division_code = substr($0,418+1,3)
  type = substr($0,6+1,1)
  document_date_yyyy = substr($0,11+1,4)
  document_date_mm = substr($0,9+1,2)
  document_date_dd = substr($0,7+1,2)
  posting_date_yyyy = substr($0,19+1,4)
  posting_date_mm = substr($0,17+1,2)
  posting_date_dd = substr($0,15+1,2)
  claim_date_yyyy = substr($0,27+1,4)
  claim_date_mm = substr($0,25+1,2)
  claim_date_dd = substr($0,23+1,2)
  reference = substr($0,31+1,10)
  document_header_text = substr($0,41+1,25)
  expenditure_type = substr($0,66+1,5)
  posting_key = substr($0,71+1,7)
  account_code = substr($0,78+1,10)
  amount = substr($0,88+1,14)
  spend_amount = substr($0,102+1,14)
  tax_amount = substr($0,116+1,14)
  payment_method = substr($0,130+1,1)
  allocation = substr($0,131+1,12)
  pc_reference = substr($0,143+1,18)
  px_reference = substr($0,161+1,60)
  ext_reference = substr($0,221+1,65)
  product_number = substr($0,286+1,18)
  transaction_code = substr($0,304+1,40)
  deduction_ac_code = substr($0,344+1,20)
  payee_code = substr($0,364+1,10)
  debit_code = substr($0,374+1,20)
  credit_code = substr($0,394+1,20)
  customer_is_a_vendor = substr($0,414+1,1)
  currency = substr($0,415+1,3)
  promo_claim_detail_row_id = substr($0,438+1,10)
  promo_claim_group_row_id = substr($0,448+1,10)
  promo_claim_group_pub_id = substr($0,458+1,30)
  reason_code = substr($0,488+1,5)
  pc_message = substr($0,493+1,65)
  pc_comment = substr($0,558+1,200)
  text_1 = substr($0,758+1,40)
  text_2 = substr($0,798+1,40)
  buy_start_date_yyyy = substr($0,822+1,4)
  buy_start_date_mm = substr($0,820+1,2)
  buy_start_date_dd = substr($0,818+1,2)
  buy_stop_date_yyyy = substr($0,830+1,4)
  buy_stop_date_mm = substr($0,828+1,2)
  buy_stop_date_dd = substr($0,826+1,2)
  bom_header_sku_stock_code = substr($0,834+1,40)
  
  print \
    ic_record_type \
    px_company_code \
    px_division_code \
    type \
    document_date_yyyy \
    document_date_mm \
    document_date_dd \
    posting_date_yyyy \
    posting_date_mm \
    posting_date_dd \
    claim_date_yyyy \
    claim_date_mm \
    claim_date_dd \
    reference \
    document_header_text \
    expenditure_type \
    posting_key \
    account_code \
    amount \
    spend_amount \
    tax_amount \
    payment_method \
    allocation \
    pc_reference \
    px_reference \
    ext_reference \
    product_number \
    transaction_code \
    deduction_ac_code \
    payee_code \
    debit_code \
    credit_code \
    customer_is_a_vendor \
    currency \
    promo_claim_detail_row_id \
    promo_claim_group_row_id \
    promo_claim_group_pub_id \
    reason_code \
    pc_message \
    pc_comment \
    text_1 \
    text_2 \
    buy_start_date_yyyy \
    buy_start_date_mm \
    buy_start_date_dd \
    buy_stop_date_yyyy \
    buy_stop_date_mm \
    buy_stop_date_dd \
    bom_header_sku_stock_code \

}  