/******************************************************************/
/* System  : QVI                                                  */
/* Object  : _qvi_lics_app_config                                 */
/* Author  : Mal Chambeyron                                       */
/* Date    : May 2012                                             */
/******************************************************************/

/*--------------------------------*/
/* MUST BE CONNECTED AS USER LICS */
/*--------------------------------*/

insert into lics_sec_option (seo_option,seo_description,seo_script,seo_status) values ('QVI_DAS_CONFIG','Dashboard Maintenance','qvi_das_config.asp','1');
insert into lics_sec_option (seo_option,seo_description,seo_script,seo_status) values ('QVI_DAS_ENQUIRY','Dashboard Enquiry','qvi_das_enquiry.asp','1');
insert into lics_sec_option (seo_option,seo_description,seo_script,seo_status) values ('QVI_DIM_CONFIG','Dimension Maintenance','qvi_dim_config.asp','1');

insert into lics_sec_menu (sem_menu,sem_description) values ('QVI_ADMIN','QlikView Interfacing Administration');

insert into lics_sec_link (sel_menu,sel_sequence,sel_type,sel_link) values ('QVI_ADMIN',1,'*MNU','ICS_ADMIN');
insert into lics_sec_link (sel_menu,sel_sequence,sel_type,sel_link) values ('QVI_ADMIN',2,'*OPT','QVI_DIM_CONFIG');
insert into lics_sec_link (sel_menu,sel_sequence,sel_type,sel_link) values ('QVI_ADMIN',3,'*OPT','QVI_DAS_CONFIG');
insert into lics_sec_link (sel_menu,sel_sequence,sel_type,sel_link) values ('QVI_ADMIN',4,'*OPT','QVI_DAS_ENQUIRY');


