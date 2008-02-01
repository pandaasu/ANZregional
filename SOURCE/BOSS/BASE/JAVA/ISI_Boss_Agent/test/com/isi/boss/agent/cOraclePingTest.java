/*
 * cOraclePingTest.java
 * JUnit based test
 *
 * Created on 9 August 2007, 10:10
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
public class cOraclePingTest extends TestCase {
   
   public cOraclePingTest(String testName) {
      super(testName);
   }

   protected void setUp() throws Exception {
   }

   protected void tearDown() throws Exception {
   }

   /**
    * Test of retrieve method, of class com.isi.boss.agent.cOraclePing.
    */
   public void testRetrieve() throws Exception {
      System.out.println("retrieve");
      
      HashMap objAttributes = new HashMap();
      cOraclePing instance = new cOraclePing();
      
      objAttributes.put("CONNECTION","jdbc:oracle:thin:@wodu003.ap.mars:1521:ap0052t");
      objAttributes.put("USER","nouser");
      objAttributes.put("PASSWORD","nopassword");
      String result = instance.retrieve(objAttributes);
      
      // TODO review the generated test code and remove the default call to fail.
   //   fail("The test case is a prototype.");
   }
   
}
