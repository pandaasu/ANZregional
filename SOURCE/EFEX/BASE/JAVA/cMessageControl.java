/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cMessageControl
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.efex;
import java.util.*;
import javax.microedition.lcdui.*;

/**
 * This class implements the Efex application message control.
 */
public class cMessageControl implements CommandListener {
   
   //
   // Private class declarations
   //
   private cApplication cobjApplication;
   private Display cobjDisplay;
   private List cobjMenu;
   private List cobjListDisplay;
   private Form cobjDataDisplay;
   private Command cobjCommandBack;
   private Image cobjSelectOn;
   private Image cobjSelectOff;
   private Font cobjFontSmall;
   private cResourceBundle cobjResourceBundle;
   private cControlStore cobjControlStore;
   private cMessageStore cobjMessageStore;
   private java.util.Vector cobjMessageList;
   
   /**
    * Constructs a new instance
    */
   public cMessageControl(cApplication objApplication) {
      cobjApplication = objApplication;
      cobjDisplay = cobjApplication.getDisplay();
      cobjMenu = cobjApplication.getMenu();
      cobjSelectOn = cobjApplication.getImageSelectOn();
      cobjSelectOff = cobjApplication.getImageSelectOff();
      cobjFontSmall = cobjApplication.getFontSmall();
      cobjResourceBundle = cobjApplication.getResourceBundle();
      cobjControlStore = cobjApplication.getControlStore();
      cobjMessageStore = cobjApplication.getMessageStore();
      cobjCommandBack = new Command(cobjResourceBundle.getResource("CMDBACK"), Command.BACK, 0);
   }
   
   /**
    * Override the CommandListener abstract methods
    */
   public void commandAction(Command objCommand, Displayable objDisplayable) {                                               
      if (objDisplayable == cobjListDisplay) {
         if (objCommand == cobjCommandBack) {
            cobjDisplay.setCurrent(cobjMenu);  
         } else if (objCommand == List.SELECT_COMMAND) {                                         
            actionListDisplay();
         }                                                  
      } else if (objDisplayable == cobjDataDisplay) {
         if (objCommand == cobjCommandBack) {
            actionDataDisplay();
         }
      }
      
   }
   
   /**
    * Sets the resource bundle
    */
   public void setResourceBundle() {
      cobjResourceBundle = cobjApplication.getResourceBundle();
   }
   
   /**
    * Loads the list display
    */
   public void loadListDisplay() {
      
      //
      // Message store must be loaded
      //
      if (cobjControlStore.getMobileStatus() == null) {
         Alert objAlert = new Alert(null, cobjResourceBundle.getResource("MSGLSTM01"), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjMenu);
         return;
      }
      
      //
      // Create and clear the list display
      //
      if (cobjListDisplay == null) {
         cobjListDisplay = new List(cobjResourceBundle.getResource("MSGLSTHDR"), List.IMPLICIT);
         cobjListDisplay.addCommand(cobjCommandBack);
         cobjListDisplay.setCommandListener(this);
         cobjListDisplay.setFitPolicy(Choice.TEXT_WRAP_OFF);
      }
      cobjListDisplay.deleteAll();
      
      //
      // Load the list display
      //
      try {
         cobjMessageList = cobjMessageStore.getMessageList();
         int intIndex = 0;
         for (int i=0; i<cobjMessageList.size(); i++) {
            if (((cMessageList)cobjMessageList.elementAt(i)).getStatus().equals("1")) {
               intIndex = cobjListDisplay.append(((cMessageList)cobjMessageList.elementAt(i)).getOwner() + " - " + ((cMessageList)cobjMessageList.elementAt(i)).getTitle(), cobjSelectOn);
            } else {
               intIndex = cobjListDisplay.append(((cMessageList)cobjMessageList.elementAt(i)).getOwner() + " - " + ((cMessageList)cobjMessageList.elementAt(i)).getTitle(), cobjSelectOff);
            }
            cobjListDisplay.setSelectedIndex(intIndex, false);
         }
         for (int i=0; i<cobjMessageList.size(); i++) {
            cobjListDisplay.setFont(i, cobjFontSmall);
         }
      } catch(Exception objException) {
         Alert objAlert = new Alert(null, objException.getMessage(), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjMenu);
         return;
      }
      
      //
      // Show the list display
      //
      cobjDisplay.setCurrent(cobjListDisplay);
   
   }
   
   /**
    * Actions the list display
    */
   public void actionListDisplay() {
      
      //
      // Message must be selected
      //
      if (cobjListDisplay.getSelectedIndex() < 0) {
         Alert objAlert = new Alert(null, cobjResourceBundle.getResource("MSGLSTM02"), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjListDisplay);
         return;
      }
      
      //
      // Perform the open on a seperate thread
      //
      cobjDisplay.setCurrent(new cOpenAction());
      
   }
   
   /**
    * Loads the data display
    */
   public void loadDataDisplay() {

      //
      // Create and clear the data display
      //
      if (cobjDataDisplay == null) {
         cobjDataDisplay = new Form(cobjResourceBundle.getResource("MSGDETHDR"));
         cobjDataDisplay.addCommand(cobjCommandBack);
         cobjDataDisplay.setCommandListener(this);
      }
      cobjDataDisplay.deleteAll();
      cobjDataDisplay.append(new StringItem(cobjResourceBundle.getResource("MSGDET001"), cobjMessageStore.getMessageOwner()));
      cobjDataDisplay.append(new StringItem(cobjResourceBundle.getResource("MSGDET002"), cobjMessageStore.getMessageText()));
      for (int i=0; i<cobjDataDisplay.size(); i++) {
         ((StringItem)cobjDataDisplay.get(i)).setLayout(Item.LAYOUT_NEWLINE_AFTER);
      }
      
      //
      // Show the data display
      //
      cobjDisplay.setCurrent(cobjDataDisplay);
   
   }
   
   /**
    * Actions the data display
    */
   public void actionDataDisplay() {
      
      //
      // Perform the message close on a seperate thread
      //
      cobjDisplay.setCurrent(new cCloseAction());
      
   }
   
   /**
    * This class implements the message open functionality.
    */
   class cOpenAction extends Form implements Runnable {

      //
      // Instance private declarations
      //
      private Thread cobjThread;
      private Gauge cobjGauge;

      /**
       * Constructs a new instance
       */
      public cOpenAction() {
         super(null);
         cobjGauge = new Gauge(cobjResourceBundle.getResource("MSGLSTM03"),false,Gauge.INDEFINITE,Gauge.CONTINUOUS_RUNNING);
         super.append(cobjGauge);
         cobjThread = new Thread(this);
         cobjThread.start();
      }

      /**
       * Runnable interface implementation
       */
      public void run() {
         
         //
         // Process while current thread
         //
         Displayable objDisplayable = cobjListDisplay;
         Alert objAlert = null;
         Thread objThread = Thread.currentThread();
         try {
            
            while (cobjThread == objThread) {

               //
               // Load the message data model from the data store using the
               // record identifier from the index store and clear 
               //
               cobjMessageStore.loadMessageModel(((cMessageList)cobjMessageList.elementAt(cobjListDisplay.getSelectedIndex())).getRecordId());
               
               //
               // Clear the data display
               //
               cobjDataDisplay = null;

               //
               // Stop the thread process
               //
               cobjThread = null;
            
            }
            
         } catch (Throwable objThrowable) {
            objAlert = new Alert(null, objThrowable.getMessage(), null, AlertType.ERROR);
            objAlert.setTimeout(Alert.FOREVER);
         } finally {
            if (objAlert != null) {
               cobjDisplay.setCurrent(objAlert, objDisplayable);
            } else {
               loadDataDisplay();
            } 
         }
         
      }
      
   }
   
   /**
    * This class implements the message close functionality.
    */
   class cCloseAction extends Form implements Runnable {

      //
      // Instance private declarations
      //
      private Thread cobjThread;
      private Gauge cobjGauge;

      /**
       * Constructs a new instance
       */
      public cCloseAction() {
         super(null);
         cobjGauge = new Gauge(cobjResourceBundle.getResource("MSGDETM01"),false,Gauge.INDEFINITE,Gauge.CONTINUOUS_RUNNING);
         super.append(cobjGauge);
         cobjThread = new Thread(this);
         cobjThread.start();
      }

      /**
       * Runnable interface implementation
       */
      public void run() {
         
         //
         // Process while current thread
         //
         Displayable objDisplayable = cobjMenu;
         Alert objAlert = null;
         Thread objThread = Thread.currentThread();
         try {
            
            while (cobjThread == objThread) {
               
               //
               // Save the message data model from the data store using the
               // record identifier from the index store
               //
               cobjMessageStore.setMessageRead();
               cobjMessageStore.saveMessageModel();
               
               //
               // Stop the thread process
               //
               cobjThread = null;
            
            }
            
         } catch (Throwable objThrowable) {
            objAlert = new Alert(null, objThrowable.getMessage(), null, AlertType.ERROR);
            objAlert.setTimeout(Alert.FOREVER);
         } finally {
            if (objAlert != null) {
               cobjDisplay.setCurrent(objAlert, objDisplayable);
            } else {
               loadListDisplay();
            }
         }
         
      }
      
   }
   
}
