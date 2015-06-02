select *
from all_objects
where object_name like 'QU%'
and status <> 'VALID'
and (object_name like 'QU2%' or object_name like 'QU3%')
;
