/*******************************************************************************
** TABLE DEFINITION
********************************************************************************

  Schema    : bi_app
  Package   : com_subjective_scores
  Author    : Trevor Keon         

  Description
  ------------------------------------------------------------------------------
  Commercial - Food - Subjective Scores  
  
  Date        Author                Description
  ----------  -------------------  --------------------------------------------
  2014-03-11  Trevor Keon           [Auto Generated]

*******************************************************************************/

  -- Drop Table
  drop table bi.com_subjective_scores cascade constraints;
  
  -- Create Table
  create table bi.com_subjective_scores (
    bus_segment varchar2(5 char) not null,
    mars_period number(6,0) not null,
    supplier varchar2(10 char) not null,
    team number(2,0) not null,
    rating_type varchar2(3 char) not null,
    rating number(5,2) not null,
    comment_user varchar2(20 char),
    comments varchar2(4000 char),
    last_update_date date not null,
    last_update_user varchar2(30 char) not null
  );
  
  -- Indexes
  alter table bi.com_subjective_scores add constraint com_subjective_scores_pk primary key (bus_segment,mars_period,supplier,team,rating_type)
    using index (create unique index bi.com_subjective_scores_pk on bi.com_subjective_scores (bus_segment,mars_period,supplier,team,rating_type));
    
  create index bi.com_subjective_scores_i0 on bi.com_subjective_scores (mars_period);

  -- Comments
  comment on table com_subjective_scores is 'Commercial - Food - Subjective Scores';
  comment on column com_subjective_scores.bus_segment is 'Business Segment';
  comment on column com_subjective_scores.mars_period is 'Mars Period';
  comment on column com_subjective_scores.supplier is 'Supplier';
  comment on column com_subjective_scores.team is 'Team (1 = Buyer, 2 = Inbound, 3 = RnD)';
  comment on column com_subjective_scores.rating_type is 'Rating Type (CIP or SC)';
  comment on column com_subjective_scores.rating is 'Rating';
  comment on column com_subjective_scores.comment_user is 'User 5/3';
  comment on column com_subjective_scores.comments is 'Comments';
  comment on column com_subjective_scores.last_update_date is 'Last Update Date/Time';
  comment on column com_subjective_scores.last_update_user is 'Last Update User';
   
  -- Grants
  grant select, insert, update, delete on bi.com_subjective_scores to bi_app, lics_app with grant option;
  grant select on bi.com_subjective_scores to qv_user;

/*******************************************************************************
  END
*******************************************************************************/
