/*
 * cOracleExecTest.java
 * JUnit based test
 *
 * Created on 9 August 2007, 11:05
 */

package com.isi.boss.agent;

import junit.framework.*;
import com.isi.boss.iAgent;
import java.util.*;
import java.sql.*;

/**
 *
 * @author Steve Gregan
 */
public class cOracleExecTest extends TestCase {
   
   public cOracleExecTest(String testName) {
      super(testName);
   }

   protected void setUp() throws Exception {
   }

   protected void tearDown() throws Exception {
   }

   /**
    * Test of retrieve method, of class com.isi.boss.agent.cOracleExec.
    */
   public void testRetrieve() throws Exception {
      System.out.println("retrieve");
      
      HashMap objAttributes = new HashMap();
      cOracleExec instance = new cOracleExec();
      
      objAttributes.put("CONNECTION","jdbc:oracle:thin:@wodu003.ap.mars:1521:ap0052t");
      objAttributes.put("USER","lics_app");
      objAttributes.put("PASSWORD","licice");
      objAttributes.put("PROCEDURE","lics_measure.retrieve_backlog");
      String result = instance.retrieve(objAttributes);
      
      // TODO review the generated test code and remove the default call to fail.
  //   fail("The test case is a prototype.");
   }
   
}
