{
  ic_record_type = substr($0,0+1,6)
  px_company_code = substr($0,25+1,3)
  px_division_code = substr($0,305+1,3)
  rec_type = substr($0,6+1,1)
  document_date_yyyy = substr($0,11+1,4)
  document_date_mm = substr($0,9+1,2)
  document_date_dd = substr($0,7+1,2)
  posting_date_yyyy = substr($0,19+1,4)
  posting_date_mm = substr($0,17+1,2)
  posting_date_dd = substr($0,15+1,2)
  document_type = substr($0,23+1,2)
  currency = substr($0,35+1,3)
  reference = substr($0,40+1,16)
  document_header_text = substr($0,56+1,25)
  posting_key = substr($0,81+1,4)
  account = substr($0,85+1,17)
  pa_assignment_flag = substr($0,102+1,1)
  amount = substr($0,103+1,13)
  payment_method = substr($0,116+1,1)
  allocation = substr($0,117+1,18)
  text = substr($0,135+1,30)
  profit_centre = substr($0,165+1,10)
  cost_centre = substr($0,175+1,10)
  sales_organisation = substr($0,185+1,4)
  sales_office = substr($0,189+1,5)
  product_number = substr($0,194+1,18)
  pa_code = substr($0,212+1,5)
  glt_row_id = substr($0,217+1,10)
  user_1 = substr($0,227+1,10)
  user_2 = substr($0,237+1,10)
  buy_start_date_yyyy = substr($0,251+1,4)
  buy_start_date_mm = substr($0,249+1,2)
  buy_start_date_dd = substr($0,247+1,2)
  buy_stop_date_yyyy = substr($0,259+1,4)
  buy_stop_date_mm = substr($0,257+1,2)
  buy_stop_date_dd = substr($0,255+1,2)
  start_date_yyyy = substr($0,267+1,4)
  start_date_mm = substr($0,265+1,2)
  start_date_dd = substr($0,263+1,2)
  stop_date_yyyy = substr($0,275+1,4)
  stop_date_mm = substr($0,273+1,2)
  stop_date_dd = substr($0,271+1,2)
  quantity = substr($0,279+1,15)
  additional_info = substr($0,294+1,10)
  promotio_is_closed = substr($0,304+1,1)
  
  print \
    ic_record_type \
    px_company_code \
    px_division_code \
    rec_type \
    document_date_yyyy \
    document_date_mm \
    document_date_dd \
    posting_date_yyyy \
    posting_date_mm \
    posting_date_dd \
    document_type \
    currency \
    reference \
    document_header_text \
    posting_key \
    account \
    pa_assignment_flag \
    amount \
    payment_method \
    allocation \
    text \
    profit_centre \
    cost_centre \
    sales_organisation \
    sales_office \
    product_number \
    pa_code \
    glt_row_id \
    user_1 \
    user_2 \
    buy_start_date_yyyy \
    buy_start_date_mm \
    buy_start_date_dd \
    buy_stop_date_yyyy \
    buy_stop_date_mm \
    buy_stop_date_dd \
    start_date_yyyy \
    start_date_mm \
    start_date_dd \
    stop_date_yyyy \
    stop_date_mm \
    stop_date_dd \
    quantity \
    additional_info \
    promotio_is_closed \

}  