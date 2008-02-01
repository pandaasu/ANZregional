CREATE OR REPLACE FUNCTION LADS_APP.join_text_lines( matl_code in varchar2, text_hdr_seq in number )
return varchar2
is
    local_str  varchar2(2000) default null;
    local_sep  varchar2(1) := ' ';
 begin
    for x in ( select tdline from lads_mat_txl where matnr = matl_code and txhseq = text_hdr_seq) loop
        exit when (length(local_str) + length(x.tdline)) > 2000;
        local_str := local_str||local_sep||x.tdline;
     end loop;
     return local_str;
 end;
/


CREATE or replace PUBLIC SYNONYM JOIN_TEXT_LINES FOR LADS_APP.JOIN_TEXT_LINES;


GRANT EXECUTE ON LADS_APP.JOIN_TEXT_LINES TO PUBLIC;

grant execute on lads_app.join_text_lines to lads with grant option;

