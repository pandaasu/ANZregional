/*
 * cExecutionTest.java
 * JUnit based test
 *
 * Created on 9 August 2007, 08:43
 */

package com.isi.boss;

import junit.framework.*;
import java.util.*;
import java.io.*;
import javax.xml.parsers.*;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.w3c.dom.Document;
import org.w3c.dom.DOMException;

/**
 *
 * @author Steve Gregan
 */
public class cExecutionTest extends TestCase {
   
   public cExecutionTest(String testName) {
      super(testName);
   }

   protected void setUp() throws Exception {
   }

   protected void tearDown() throws Exception {
   }


   /**
    * Test of main method, of class com.isi.boss.cExecution.
    */
   public void testMain() {
      System.out.println("main");
      
      String[] args = {"-configuration", "c:\\isi_boss\\config\\config.xml", "-execution", "c:\\isi_boss\\config\\execution.xml"};
      cExecution.main(args);
      
      // TODO review the generated test code and remove the default call to fail.
    //  fail("The test case is a prototype.");
   }
   
}
