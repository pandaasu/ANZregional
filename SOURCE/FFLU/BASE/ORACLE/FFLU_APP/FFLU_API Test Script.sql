-- Testing Script for API Functions. 
select * from table(fflu_api.get_user_list());  -- Should return the list of available users in the system.

select * from table(fflu_api.get_authorised_user(''));  -- Should raise an exception 

select * from table(fflu_api.get_authorised_user('TEST'));  -- Should return GUEST.

select * from table(fflu_api.get_authorised_user('HORNCHR'));  -- Should return HORNCHR

select * from table(fflu_api.get_interface_list()); -- Should return the list of available interfaces in the system.

select * from table(fflu_api.get_interface_group_list()); -- Returns the list of interface groups. 

select * from table(fflu_api.get_interface_group_join()); -- Returns the list of interface groups. 

select * from table(fflu_api.GET_USER_INTERFACE_OPTIONS('TEST')); -- Should return the permissions that GUEST has against various interfaces.

select * from table(fflu_api.GET_USER_INTERFACE_OPTIONS('HORNCHR')); -- Should return the permissions that HORNCHR has against various interfaces.
