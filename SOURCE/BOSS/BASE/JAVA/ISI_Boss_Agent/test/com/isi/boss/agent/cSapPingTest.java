/*
 * cSapPingTest.java
 * JUnit based test
 *
 * Created on 9 August 2007, 10:48
 */

package com.isi.boss.agent;

import junit.framework.*;
import com.isi.boss.iAgent;
import java.util.*;
import com.sap.mw.jco.*;

/**
 *
 * @author Steve Gregan
 */
public class cSapPingTest extends TestCase {
   
   public cSapPingTest(String testName) {
      super(testName);
   }

   protected void setUp() throws Exception {
   }

   protected void tearDown() throws Exception {
   }

   /**
    * Test of retrieve method, of class com.isi.boss.agent.cSapPing.
    */
   public void testRetrieve() throws Exception {
      System.out.println("retrieve");
      
      HashMap objAttributes = new HashMap();
      cSapPing instance = new cSapPing();
         
      objAttributes.put("CLIENT","002");
      objAttributes.put("USER","mfanzics");
      objAttributes.put("PASSWORD","mfanzics");
      objAttributes.put("LANGUAGE","EN");
      objAttributes.put("SERVER","sapapb.na.mars");
      objAttributes.put("SYSTEM","02");
      String result = instance.retrieve(objAttributes);
     
      // TODO review the generated test code and remove the default call to fail.
  //    fail("The test case is a prototype.");
   }
   
}
