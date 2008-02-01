/*
 * cServerPingTest.java
 * JUnit based test
 *
 * Created on 9 August 2007, 09:29
 */

package com.isi.boss.agent;

import junit.framework.*;
import com.isi.boss.iAgent;
import java.util.*;

/**
 *
 * @author Steve Gregan
 */
public class cServerPingTest extends TestCase {
   
   public cServerPingTest(String testName) {
      super(testName);
   }

   protected void setUp() throws Exception {
   }

   protected void tearDown() throws Exception {
   }

   /**
    * Test of retrieve method, of class com.isi.boss.agent.cServerPing.
    */
   public void testRetrieve() throws Exception {
      System.out.println("retrieve");
      
      HashMap objAttributes = new HashMap();
      cServerPing instance = new cServerPing();
      
  //    String expResult = "";
      objAttributes.put("SERVER","wodu999.ap.mars");
      String result = instance.retrieve(objAttributes);
 //     assertEquals(expResult, result);
      
      // TODO review the generated test code and remove the default call to fail.
   //   fail("The test case is a prototype.");
   }
   
}
