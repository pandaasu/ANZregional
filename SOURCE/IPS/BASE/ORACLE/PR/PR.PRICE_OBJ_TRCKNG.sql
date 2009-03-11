
CREATE TABLE PR.PRICE_OBJ_TRCKNG
(
  OBJ_ID         NUMBER(20)                     NOT NULL,
  TABLE_NAME     VARCHAR2(32 BYTE)              NOT NULL,
  COLUMN_NAME    VARCHAR2(32 BYTE)              NOT NULL,
  CREATED_DATE   DATE,
  CREATED_BY_ID  NUMBER(20)
);

COMMENT ON TABLE PR.PRICE_OBJ_TRCKNG IS 'This table contains the common object ids that are allocated from this schemas sequence.';

COMMENT ON COLUMN PR.PRICE_OBJ_TRCKNG.OBJ_ID IS 'This is the object id that is allocated to the any objects that are created using the common sequence within this schema.';

COMMENT ON COLUMN PR.PRICE_OBJ_TRCKNG.TABLE_NAME IS 'This is the table name where this particular object ID will be used.';

COMMENT ON COLUMN PR.PRICE_OBJ_TRCKNG.COLUMN_NAME IS 'This is the column name of where the object id will be stored within the schema.';

COMMENT ON COLUMN PR.PRICE_OBJ_TRCKNG.CREATED_DATE IS 'his is the date the object was allocated.';

COMMENT ON COLUMN PR.PRICE_OBJ_TRCKNG.CREATED_BY_ID IS 'This table contains a link to every object within the schema that has been allocated from the plan sequence.';

CREATE OR REPLACE PUBLIC SYNONYM PRICE_OBJ_TRCKNG FOR PR.PRICE_OBJ_TRCKNG;

ALTER TABLE PR.PRICE_OBJ_TRCKNG ADD (
  CONSTRAINT PRICE_OBJ_TRCKNG_PK01
 PRIMARY KEY
 (OBJ_ID));

GRANT DELETE, INSERT, SELECT, UPDATE ON PR.PRICE_OBJ_TRCKNG TO PR_APP;

