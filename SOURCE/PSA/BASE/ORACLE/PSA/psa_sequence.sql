/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_sequence
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - psa_sequence

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Sequence creation
/**/
create sequence psa_act_sequence
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

/**/
/* Authority
/**/
grant select on psa_act_sequence to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_act_sequence for psa.psa_act_sequence;
