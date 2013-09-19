/*******************************************************************************
** TABLE DEFINITION
********************************************************************************

  Schema    : tlco
  Package   : tlco_bill_raw_sng
  Author    : Chris Horn          

  Description
  ------------------------------------------------------------------------------
  Telecoms Bill Data - Singapore  
  
  Date        Author                Description
  ----------  -------------------  --------------------------------------------
  2013-09-10  Chris Horn            [Auto Generated]

*******************************************************************************/

  -- Drop Table
  drop table tlco.tlco_bill_raw_sng cascade constraints;
  
  -- Create Table
  create table tlco.tlco_bill_raw_sng (
    call_description2 varchar2(100 char),
    data_usage number(30,10),
    payment_amount number(30,10),
    autoroam_operator varchar2(100 char),
    call_description1 varchar2(100 char),
    duration number(30,10),
    call_details varchar2(100 char),
    terminating_number varchar2(100 char),
    destination varchar2(100 char),
    usage_type varchar2(100 char),
    time_of_call varchar2(8 char),
    date_of_call varchar2(8 char),
    charges number(30,10),
    origin_number varchar2(20 char),
    service_type varchar2(100 char),
    bill_id varchar2(10 char) not null,
    account_number number(10,0) not null,
    bill_date date not null,
    last_update_date date not null,
    last_update_user varchar2(30 char) not null
  );
  
  -- Indexes
  create index tlco.tlco_bill_raw_sng_i0 on tlco.tlco_bill_raw_sng (bill_id);

  -- Comments
  comment on table tlco_bill_raw_sng is 'Telecoms Bill Data - Singapore';
  comment on column tlco_bill_raw_sng.call_description2 is 'Call Description2';
  comment on column tlco_bill_raw_sng.data_usage is 'Data Usage (kByte)';
  comment on column tlco_bill_raw_sng.payment_amount is 'Payment Amount';
  comment on column tlco_bill_raw_sng.autoroam_operator is 'Autoroam Operator';
  comment on column tlco_bill_raw_sng.call_description1 is 'Call Description';
  comment on column tlco_bill_raw_sng.duration is 'Duration (Min)';
  comment on column tlco_bill_raw_sng.call_details is 'Call Details';
  comment on column tlco_bill_raw_sng.terminating_number is 'Terminating Number';
  comment on column tlco_bill_raw_sng.destination is 'Destination';
  comment on column tlco_bill_raw_sng.usage_type is 'Usage Type';
  comment on column tlco_bill_raw_sng.time_of_call is 'Time of Call';
  comment on column tlco_bill_raw_sng.date_of_call is 'Date of Call';
  comment on column tlco_bill_raw_sng.charges is 'Charges';
  comment on column tlco_bill_raw_sng.origin_number is 'Originating Number';
  comment on column tlco_bill_raw_sng.service_type is 'Service Type';
  comment on column tlco_bill_raw_sng.bill_id is 'Bill ID';
  comment on column tlco_bill_raw_sng.account_number is 'Account Number';
  comment on column tlco_bill_raw_sng.bill_date is 'Bill Date';
  comment on column tlco_bill_raw_sng.last_update_date is 'Last Update Date/Time';
  comment on column tlco_bill_raw_sng.last_update_user is 'Last Update User';
   
  -- Grants
  grant select, insert, update, delete on tlco.tlco_bill_raw_sng to tlco_app, lics_app with grant option;
  grant select on tlco.tlco_bill_raw_sng to tlco_app;

/*******************************************************************************
  END
*******************************************************************************/
