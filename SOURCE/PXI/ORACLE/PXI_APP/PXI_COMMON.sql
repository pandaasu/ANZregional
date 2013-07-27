create or replace package pxi_common as

function char_format(i_value in varchar2, i_length in number, i_format_type in number, i_value_is_nullable in number) return varchar2;
function numb_format(i_value in number, i_format in varchar2, i_value_is_nullable in number) return varchar2;
function date_format(i_value in date, i_format in varchar2, i_value_is_nullable in number) return varchar2;

function is_nullable return number;
function is_not_nullable return number;

function format_type_none return number;
function format_type_trim return number;
function format_type_ltrim return number;
function format_type_rtrim return number;
function format_type_ltrim_zeros return number;

end pxi_common;
/
