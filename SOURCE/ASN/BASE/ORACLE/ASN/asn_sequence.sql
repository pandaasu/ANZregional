/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : asn
 Table   : asn_sequence
 Owner   : asn
 Author  : Steve Gregan

 Description
 -----------
 Advanced Shipping Notice - asn_sequence

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Sequence creation
/**/
create sequence asn_dcs_msg_sequence
   increment by 1
   start with 1
   maxvalue 99999999
   minvalue 1
   cycle
   nocache
   order;

/**/
/* Authority
/**/
grant select on asn_dcs_msg_sequence to ics_app;

/**/
/* Synonym
/**/
create public synonym asn_dcs_msg_sequence for asn.asn_dcs_msg_sequence;
