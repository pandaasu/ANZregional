/*******************************************************************************
/* Table Data
/*******************************************************************************
 System : pxi
 Table  : pxi_demand_group_to_account
*******************************************************************************/

-- Clear Table
delete from pxi_demand_group_to_account;

-- Populate Table
insert into pxi_demand_group_to_account (DEMAND_GROUP,ACCOUNT_CODE,PRIMARY_ACCOUNT,MOE_CODE) values ('APAG_AP','0040011053','Y','0196');
insert into pxi_demand_group_to_account (DEMAND_GROUP,ACCOUNT_CODE,PRIMARY_ACCOUNT,MOE_CODE) values ('APBW_AP','0040006340','Y','0196');
insert into pxi_demand_group_to_account (DEMAND_GROUP,ACCOUNT_CODE,PRIMARY_ACCOUNT,MOE_CODE) values ('APCM_AP','0040006177','Y','0196');
insert into pxi_demand_group_to_account (DEMAND_GROUP,ACCOUNT_CODE,PRIMARY_ACCOUNT,MOE_CODE) values ('APCO_AP','0040015020','Y','0196');
insert into pxi_demand_group_to_account (DEMAND_GROUP,ACCOUNT_CODE,PRIMARY_ACCOUNT,MOE_CODE) values ('APEC_AP','0040006300','Y','0196');
insert into pxi_demand_group_to_account (DEMAND_GROUP,ACCOUNT_CODE,PRIMARY_ACCOUNT,MOE_CODE) values ('APME_AP','0040006180','Y','0196');
insert into pxi_demand_group_to_account (DEMAND_GROUP,ACCOUNT_CODE,PRIMARY_ACCOUNT,MOE_CODE) values ('APME_AP','0040006693','N','0196');
insert into pxi_demand_group_to_account (DEMAND_GROUP,ACCOUNT_CODE,PRIMARY_ACCOUNT,MOE_CODE) values ('APMS_AP','0040010855','Y','0196');
insert into pxi_demand_group_to_account (DEMAND_GROUP,ACCOUNT_CODE,PRIMARY_ACCOUNT,MOE_CODE) values ('APPT_AP','0040011054','Y','0196');
insert into pxi_demand_group_to_account (DEMAND_GROUP,ACCOUNT_CODE,PRIMARY_ACCOUNT,MOE_CODE) values ('APVT_AP','0040011056','Y','0196');
insert into pxi_demand_group_to_account (DEMAND_GROUP,ACCOUNT_CODE,PRIMARY_ACCOUNT,MOE_CODE) values ('APWW_AP','0040006187','Y','0196');
insert into pxi_demand_group_to_account (DEMAND_GROUP,ACCOUNT_CODE,PRIMARY_ACCOUNT,MOE_CODE) values ('APWW_AP','0040006324','N','0196');

-- Commit Data
commit;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/

