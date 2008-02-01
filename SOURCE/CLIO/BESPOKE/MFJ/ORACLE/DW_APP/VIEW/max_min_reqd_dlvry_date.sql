/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : max_min_reqd_dlvry_date
 Owner  : dw_app

 DESCRIPTION
 -----------
 Data Warehouse - View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view max_min_reqd_dlvry_date
   (MONTH_NUM,
    MARS_PERIOD,
    PERIOD_DAY_NUM,
    MARS_YYYYPPDD,
    PERIOD_BUS_DAY_NUM,
    MIN_REQD_DLVRY_DATE, 
    MAX_REQD_DLVRY_DATE) AS 
SELECT
/*--- Normal Calendar Related ---*/
TRUNC(TT2.YYYYMMDD_DATE/100) AS MONTH_NUM,
/*--- Period Calendar Related ---*/
TT2.MARS_PERIOD,
TT2.PERIOD_DAY_NUM,
TT2.MARS_YYYYPPDD,
TT2.PERIOD_BUS_DAY_NUM,
TT1.MIN_REQD_DLVRY_DATE,
TT1.MAX_REQD_DLVRY_DATE
FROM
(
SELECT
DECODE(T1.PERIOD_DAY_NUM, 
/*--- W1 ---*/
 1, T1.CALENDAR_DATE-2, -- Sunday       Special
 2, T1.CALENDAR_DATE-3, -- Monday       Special
 3, T1.CALENDAR_DATE-2, -- Tuesday      Special
 4, T1.CALENDAR_DATE-1, -- Wednesday
 5, T1.CALENDAR_DATE-1, -- Thursday
 6, T1.CALENDAR_DATE-1, -- Friday
 7, T1.CALENDAR_DATE-1, -- Saturday
/*--- W2 ---*/
 8, T1.CALENDAR_DATE-2, -- Sunday       Special
 9, T1.CALENDAR_DATE-3, -- Monday
10, T1.CALENDAR_DATE-1, -- Tuesday
11, T1.CALENDAR_DATE-1, -- Wednesday
12, T1.CALENDAR_DATE-1, -- Thursday
13, T1.CALENDAR_DATE-1, -- Friday
14, T1.CALENDAR_DATE-1, -- Saturday
/*--- W3 ---*/
15, T1.CALENDAR_DATE-2, -- Sunday       Special
16, T1.CALENDAR_DATE-3, -- Monday
17, T1.CALENDAR_DATE-1, -- Tuesday
18, T1.CALENDAR_DATE-1, -- Wednesday
19, T1.CALENDAR_DATE-1, -- Thursday
20, T1.CALENDAR_DATE-1, -- Friday
21, T1.CALENDAR_DATE-1, -- Saturday
/*--- W4 ---*/
22, T1.CALENDAR_DATE-2, -- Sunday       Special
23, T1.CALENDAR_DATE-3, -- Monday
24, T1.CALENDAR_DATE-1, -- Tuesday
25, T1.CALENDAR_DATE-1, -- Wednesday
26, T1.CALENDAR_DATE-1, -- Thursday
27, T1.CALENDAR_DATE-1, -- Friday
28, T1.CALENDAR_DATE-1, -- Saturday
/*--- P13 year end ---*/
29, T1.CALENDAR_DATE-2, -- Sunday
30, T1.CALENDAR_DATE-3, -- Monday
/*--- Others ---*/
    T1.CALENDAR_DATE-1  -- Others
) AS MIN_REQD_DLVRY_DATE,
DECODE(T1.PERIOD_DAY_NUM, 
/*--- W1 ---*/
 1, T1.CALENDAR_DATE-1, -- Sunday
 2, T1.CALENDAR_DATE-2, -- Monday       Special
 3, T1.CALENDAR_DATE-1, -- Tuesday
 4, T1.CALENDAR_DATE-1, -- Wednesday
 5, T1.CALENDAR_DATE-1, -- Thursday
 6, T1.CALENDAR_DATE-1, -- Friday
 7, T1.CALENDAR_DATE-1, -- Saturday
/*--- W2 ---*/
 8, T1.CALENDAR_DATE-1, -- Sunday
 9, T1.CALENDAR_DATE-1, -- Monday
10, T1.CALENDAR_DATE-1, -- Tuesday
11, T1.CALENDAR_DATE-1, -- Wednesday
12, T1.CALENDAR_DATE-1, -- Thursday
13, T1.CALENDAR_DATE-1, -- Friday
14, T1.CALENDAR_DATE-1, -- Saturday
/*--- W3 ---*/
15, T1.CALENDAR_DATE-1, -- Sunday
16, T1.CALENDAR_DATE-1, -- Monday
17, T1.CALENDAR_DATE-1, -- Tuesday
18, T1.CALENDAR_DATE-1, -- Wednesday
19, T1.CALENDAR_DATE-1, -- Thursday
20, T1.CALENDAR_DATE-1, -- Friday
21, T1.CALENDAR_DATE-1, -- Saturday
/*--- W4 ---*/
22, T1.CALENDAR_DATE-1, -- Sunday
23, T1.CALENDAR_DATE-1, -- Monday
24, T1.CALENDAR_DATE-1, -- Tuesday
25, T1.CALENDAR_DATE-1, -- Wednesday
26, T1.CALENDAR_DATE-1, -- Thursday
27, T1.CALENDAR_DATE-1, -- Friday
28, T1.CALENDAR_DATE-1, -- Saturday
/*--- Others ---*/
    T1.CALENDAR_DATE-1  -- Others
) AS MAX_REQD_DLVRY_DATE
FROM 
(
SELECT 
  PERIOD_DAY_NUM,
  CALENDAR_DATE
FROM MM.MARS_DATE
WHERE YYYYMMDD_DATE = (
  SELECT
    TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDD'))
  FROM DUAL)
) T1
) TT1, MM.MARS_DATE TT2
WHERE
TT1.MAX_REQD_DLVRY_DATE = TT2.CALENDAR_DATE;

/*-*/
/* Authority
/*-*/
grant select on dw_app.max_min_reqd_dlvry_date to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym max_min_reqd_dlvry_date for dw_app.max_min_reqd_dlvry_date;

