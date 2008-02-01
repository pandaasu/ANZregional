/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : forwarding_agent
 Owner  : od

 Description
 -----------
 Operational Data Store - Forwarding Agent Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.forwarding_agent
   (sap_forwarding_agent_code  varchar2(10 char)       not null,
    forwarding_agent_desc      varchar2(35 char)       not null,
    forwarding_agent_lupdp     varchar2(8 char)        not null,
    forwarding_agent_lupdt     date                    not null);

/**/
/* Comments
/**/
comment on table od.forwarding_agent is 'Forwarding Agent Table';
comment on column od.forwarding_agent.sap_forwarding_agent_code is 'SAP Forwarding Agent Code';
comment on column od.forwarding_agent.forwarding_agent_desc is 'Forwarding Agent Description';
comment on column od.forwarding_agent.forwarding_agent_lupdp is 'Last Updated Person';
comment on column od.forwarding_agent.forwarding_agent_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.forwarding_agent
   add constraint forwarding_agent_pk primary key (sap_forwarding_agent_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.forwarding_agent to dw_app;
grant select on od.forwarding_agent to od_app with grant option;
grant select on od.forwarding_agent to od_user;
grant select on od.forwarding_agent to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym forwarding_agent for od.forwarding_agent;