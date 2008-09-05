DROP PACKAGE MANU_APP.HIERARCHY;

CREATE OR REPLACE PACKAGE MANU_APP.HIERARCHY
  IS
        TYPE BranchTableType IS TABLE OF VARCHAR2(4000)
          INDEX BY BINARY_INTEGER;
        BranchTable BranchTableType;
        
        
        FUNCTION Branch(vLevel          IN NUMBER,
                        vValue          IN VARCHAR2,
                        vDelimiter      IN VARCHAR2 DEFAULT CHR(0))
                        RETURN VARCHAR2;
                        
       -- PRAGMA RESTRICT_REFERENCES(Branch,WNDS);
END HIERARCHY;
/


DROP PACKAGE BODY MANU_APP.HIERARCHY;

CREATE OR REPLACE PACKAGE BODY MANU_APP.HIERARCHY
  IS
        ReturnValue VARCHAR2(4000);
        
        
  FUNCTION Branch(vLevel        IN NUMBER,
                  vValue        IN VARCHAR2,
                  vDelimiter    IN VARCHAR2 DEFAULT CHR(0))
                  RETURN VARCHAR2
   IS
   
   
          v_mrp VARCHAR2(6);
          
   BEGIN
        SELECT MAX(MRP_CNTRLLR) mrp INTO v_mrp
          FROM material_mrp
          WHERE plant = 'AU10'
          AND material = vvalue ;
         
        BranchTable(vLevel) := v_mrp; --vValue;
        
        ReturnValue := '';--vValue;
        DBMS_OUTPUT.PUT_LINE('X' ||  '-' || vLevel || '-' || vValue);
        
        FOR I IN REVERSE 1..vLevel - 1 LOOP
            IF BranchTable(I) = '116' OR v_mrp = '116' THEN
               IF BranchTable(I) = '116' THEN
                  ReturnValue := 'X';
                  --ReturnValue := BranchTable(I) || vDelimiter || ReturnValue;
                  EXIT;
               END IF;
            END IF;
        END LOOP;
         
        RETURN ReturnValue;
        COMMIT;
  END Branch;
END HIERARCHY;
/


DROP PUBLIC SYNONYM HIERARCHY;

CREATE PUBLIC SYNONYM HIERARCHY FOR MANU_APP.HIERARCHY;


