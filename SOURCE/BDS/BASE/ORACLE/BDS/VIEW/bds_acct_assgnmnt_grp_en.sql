 /******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_ACCT_ASSGNMNT_GRP_EN
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Reference - Account Assignment Group - English

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/

create or replace view bds_acct_assgnmnt_grp_en as  
   select t01.acct_assgnmnt_grp_code as acct_assgnmnt_grp_code,
          t01.acct_assgnmnt_grp_desc as acct_assgnmnt_grp_desc
   from bds_refrnc_acct_assgnmnt_grp t01
   where desc_language = 'E';
/

/**/
/* Synonym
/**/
create or replace public synonym bds_acct_assgnmnt_grp_en for bds.bds_acct_assgnmnt_grp_en;



/**/
/* Authority
/**/