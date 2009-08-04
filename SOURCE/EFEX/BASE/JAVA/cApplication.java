/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cApplication
 * Author  : Steve Gregan
 * Date    : April 2008
 */
package com.isi.efex;
import java.io.*;
import javax.microedition.midlet.*;
import javax.microedition.lcdui.*;
import org.netbeans.microedition.lcdui.*;
import org.netbeans.microedition.lcdui.laf.ColorSchema;

/**
 * This class implements the Efex application midlet.
 */
public class cApplication extends MIDlet implements CommandListener {
   
   //
   // Private class declarations
   //
   private String cstrVersion = "1.9.8.0";
   private boolean cbolPaused;
   private Class cobjClass;
   private Display cobjDisplay;
   private List cobjMenuDisplay;
   private Form cobjMobileConfigDisplay;
   private Form cobjRouteLoadDisplay;
   private Form cobjRouteSaveDisplay;
   private Form cobjRouteShowDisplay;
   private Image cobjConfiguration;
   private Image cobjRouteLoad;
   private Image cobjRouteSave;
   private Image cobjRouteProperty;
   private Image cobjCustomerOpen;
   private Image cobjDataUpdate;
   private Image cobjMessageCheck;
   private Image cobjSelectOn;
   private Image cobjSelectOff;
   private Image cobjError;
   private Font cobjFontHead;
   private Font cobjFontMedium;
   private Font cobjFontSmall;
   private Font cobjFontMenu;
   private cTableColorSchema cobjTableColorSchema;
   private cNumberFormatter cobjFormatter;
   private Command cobjCommandExit;
   private Command cobjCommandBack;
   private Command cobjCommandCancel;
   private Command cobjCommandAccept;
   private cResourceBundle cobjResourceBundle;
   private cRouteControl cobjRouteControl;
   private cCustomerControl cobjCustomerControl;
   private cMessageControl cobjMessageControl;
   private cMobileStore cobjMobileStore;
   private cControlStore cobjControlStore;
   private cRouteStore cobjRouteStore;
   private cCustomerStore cobjCustomerStore;
   private cMessageStore cobjMessageStore;
   private cUomStore cobjUomStore;
   private cCustomerLocationStore cobjCustomerLocationStore;
   private cCustomerTypeStore cobjCustomerTypeStore;
   private cCustomerChannelStore cobjCustomerChannelStore;
   private cDistributorStore cobjDistributorStore;
   
   /**
    * Constructs a new instance
    */
   public cApplication() {
      initialiseMIDlet();
   }
   
   /**
    * Override the MIDlet abstract methods
    */
   public void startApp() {
      cbolPaused = false;
   }
   public void pauseApp() {
      cbolPaused = true;
   }
   public void destroyApp(boolean unconditional) {}
   
   /**
    * Override the CommandListener abstract methods
    */
   public void commandAction(Command objCommand, Displayable objDisplayable) {                                               
      if (objDisplayable == cobjMenuDisplay) {                                       
         if (objCommand == cobjCommandExit) {                                          
            exitMIDlet();
         } else if (objCommand == List.SELECT_COMMAND) {                                         
            actionMainMenu(); 
         }                                                  
      } else if (objDisplayable == cobjMobileConfigDisplay) {
         if (objCommand == cobjCommandCancel) {
            cobjDisplay.setCurrent(cobjMenuDisplay);  
         } else if (objCommand == cobjCommandAccept) {
            actionMobileConfig();
         }
      } else if (objDisplayable == cobjRouteLoadDisplay) {
         if (objCommand == cobjCommandCancel) {
            cobjDisplay.setCurrent(cobjMenuDisplay); 
         } else if (objCommand == cobjCommandAccept) {
            actionRouteLoad();
         }
      } else if (objDisplayable == cobjRouteSaveDisplay) {
         if (objCommand == cobjCommandCancel) {
            cobjDisplay.setCurrent(cobjMenuDisplay);  
         } else if (objCommand == cobjCommandAccept) {
            actionRouteSave();
         }
      } else if (objDisplayable == cobjRouteShowDisplay) {
         if (objCommand == cobjCommandBack) {
            actionRouteShow();
         }                                                  
      }
      
   }  
    
   /**
    * Initialises the MIDlet
    */
   public void initialiseMIDlet() {
      
      //
      // Initialise the MIDlet display
      //
      cbolPaused = false;
      cobjClass = getClass();
      cobjDisplay = Display.getDisplay(this);
      
      //
      // Load the mobile store
      //
      cobjMobileStore = new cMobileStore();
      try {
         cobjMobileStore.loadDataModel();
      } catch (Exception objException) {}
      cobjResourceBundle = new cResourceEnglish();
      if (cobjMobileStore.getLanguage() != null && cobjMobileStore.getLanguage().equals("English")) {
         cobjResourceBundle = new cResourceEnglish();
      }
      if (cobjMobileStore.getLanguage() != null && cobjMobileStore.getLanguage().equals("Chinese")) {
         cobjResourceBundle = new cResourceChinese();
      }
      
      //
      // Perform the application load on a seperate thread
      //
      cobjDisplay.setCurrent(new cApplicationLoad(this));
      
   }
   
   /**
    * Exits MIDlet
    */
   public void exitMIDlet() {
       cobjDisplay.setCurrent(null);
       destroyApp(true);
       notifyDestroyed();
   }
   
   /**
    * Application resource methods
    */
   protected Display getDisplay() {
      return cobjDisplay;
   }
   protected Class getMidletClass() {
      return cobjClass;
   }
   protected List getMenu() {
      return cobjMenuDisplay;
   }
   protected Image getImageRouteLoad() {
      return cobjRouteLoad;
   }
   protected Image getImageRouteSave() {
      return cobjRouteSave;
   }
   protected Image getImageRouteProperty() {
      return cobjRouteProperty;
   }
   protected Image getImageCustomerOpen() {
      return cobjCustomerOpen;
   }
   protected Image getImageDataUpdate() {
      return cobjDataUpdate;
   }
   protected Image getImageMessageCheck() {
      return cobjMessageCheck;
   }
   protected Image getImageSelectOn() {
      return cobjSelectOn;
   }
   protected Image getImageSelectOff() {
      return cobjSelectOff;
   }
   protected Image getImageError() {
      return cobjError;
   }
   protected Font getFontHead() {
      return cobjFontHead;
   }
   protected Font getFontMedium() {
      return cobjFontMedium;
   }
   protected Font getFontSmall() {
      return cobjFontSmall;
   }
   protected Font getFontMenu() {
      return cobjFontMenu;
   }
   protected cResourceBundle getResourceBundle() {
      return cobjResourceBundle;
   }
   protected ColorSchema getTableColorSchema() {
      return cobjTableColorSchema;
   }
   protected cNumberFormatter getFormatter() {
      return cobjFormatter;
   }
   protected cMobileStore getMobileStore() {
      return cobjMobileStore;
   }
   protected cControlStore getControlStore() {
      return cobjControlStore;
   }
   protected cRouteStore getRouteStore() {
      return cobjRouteStore;
   }
   protected cCustomerStore getCustomerStore() {
      return cobjCustomerStore;
   }
   protected cUomStore getUomStore() {
      return cobjUomStore;
   }
   protected cCustomerLocationStore getCustomerLocationStore() {
      return cobjCustomerLocationStore;
   }
   protected cCustomerTypeStore getCustomerTypeStore() {
      return cobjCustomerTypeStore;
   }
   protected cCustomerChannelStore getCustomerChannelStore() {
      return cobjCustomerChannelStore;
   }
   protected cDistributorStore getDistributorStore() {
      return cobjDistributorStore;
   }
   protected cMessageStore getMessageStore() {
      return cobjMessageStore;
   }

   /**
    * Performs an action assigned to the selected list element in the list component.
    */
   public void actionMainMenu() {
      int intIndex = cobjMenuDisplay.getSelectedIndex();
      if (intIndex == 0) {
         loadRouteLoad();
      } else if (intIndex == 1) {
         cobjMessageControl.loadListDisplay();
      } else if (intIndex == 2) {
         cobjRouteControl.loadOpenDisplay();
      } else if (intIndex == 3) {
         cobjCustomerControl.loadOpenDisplay();
      } else if (intIndex == 4) {
         loadRouteSave();
      } else if (intIndex == 5) {
         loadRouteShow();
      } else if (intIndex == 6) {
         loadMobileConfig();
      }
   }
   
   /**
    * Loads the mobile config display
    */
   public void loadMobileConfig() {
      
      //
      // Create and clear the mobile config display
      //
      if (cobjMobileConfigDisplay == null) {
         cobjMobileConfigDisplay = new Form(cobjResourceBundle.getResource("MOBCFGHDR") + " (" + cstrVersion + ")");
         cobjMobileConfigDisplay.addCommand(cobjCommandCancel);
         cobjMobileConfigDisplay.addCommand(cobjCommandAccept);
         cobjMobileConfigDisplay.setCommandListener(this);
      }
      cobjMobileConfigDisplay.deleteAll();
      cobjMobileConfigDisplay.append(new TextField(cobjResourceBundle.getResource("MOBCFG001"), cobjMobileStore.getUserName(), 10, TextField.ANY));
      cobjMobileConfigDisplay.append(new ChoiceGroup(cobjResourceBundle.getResource("MOBCFG002"), ChoiceGroup.POPUP, new String[] {"English","Chinese"}, null));
      ((ChoiceGroup)cobjMobileConfigDisplay.get(1)).setSelectedIndex(0, true);
      if (cobjMobileStore.getLanguage() != null && cobjMobileStore.getLanguage().equals("English")) {
         ((ChoiceGroup)cobjMobileConfigDisplay.get(1)).setSelectedIndex(0, true);
      } else if (cobjMobileStore.getLanguage() != null && cobjMobileStore.getLanguage().equals("Chinese")) {
         ((ChoiceGroup)cobjMobileConfigDisplay.get(1)).setSelectedIndex(1, true);
      }
      cobjMobileConfigDisplay.append(new TextField(cobjResourceBundle.getResource("MOBCFG003"), cobjMobileStore.getServerUrl(), 128, TextField.ANY));
      cobjMobileConfigDisplay.append(new ChoiceGroup(cobjResourceBundle.getResource("MOBCFG004"), ChoiceGroup.POPUP, new String[] {"*YES","*NO"}, null));
      ((ChoiceGroup)cobjMobileConfigDisplay.get(3)).setSelectedIndex(0, true);
      if (cobjMobileStore.getSecure() != null && cobjMobileStore.getSecure().equals("*YES")) {
         ((ChoiceGroup)cobjMobileConfigDisplay.get(3)).setSelectedIndex(0, true);
      } else if (cobjMobileStore.getSecure() != null && cobjMobileStore.getSecure().equals("*NO")) {
         ((ChoiceGroup)cobjMobileConfigDisplay.get(3)).setSelectedIndex(1, true);
      }
      for (int i=0; i<cobjMobileConfigDisplay.size(); i++) {
         ((Item)cobjMobileConfigDisplay.get(i)).setLayout(Item.LAYOUT_VCENTER | Item.LAYOUT_NEWLINE_BEFORE | Item.LAYOUT_NEWLINE_AFTER);
      }
      
      //
      // Show the mobile config display
      //
      cobjDisplay.setCurrent(cobjMobileConfigDisplay);
   
   }
   
   /**
    * Actions the mobile config display
    */
   public void actionMobileConfig() {
      
      //
      // Perform the mobile configuration on a separate thread
      //
      cobjMobileStore.setUserName(((TextField)cobjMobileConfigDisplay.get(0)).getString().toUpperCase());
      cobjMobileStore.setLanguage(((ChoiceGroup)cobjMobileConfigDisplay.get(1)).getString(((ChoiceGroup)cobjMobileConfigDisplay.get(1)).getSelectedIndex()));
      cobjMobileStore.setServerUrl(((TextField)cobjMobileConfigDisplay.get(2)).getString());
      cobjMobileStore.setSecure(((ChoiceGroup)cobjMobileConfigDisplay.get(3)).getString(((ChoiceGroup)cobjMobileConfigDisplay.get(3)).getSelectedIndex()));
      if (cobjMobileStore.getUserName() == null || cobjMobileStore.getUserName().equals("")) {
         Alert objAlert = new Alert(null, cobjResourceBundle.getResource("MOBCFGM01"), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjMobileConfigDisplay);
         return;
      }
      if (cobjMobileStore.getServerUrl() == null || cobjMobileStore.getServerUrl().equals("")) {
         Alert objAlert = new Alert(null, cobjResourceBundle.getResource("MOBCFGM02"), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjMobileConfigDisplay);
         return;
      }
      cobjDisplay.setCurrent(new cMobileConfiguration());
      
   }
   
   /**
    * Loads the route load display
    */
   public void loadRouteLoad() {
      
      //
      // Mobile must be configured
      //
      if (cobjMobileStore.getUserName() == null || cobjMobileStore.getUserName().equals("")) {
         Alert objAlert = new Alert(null, cobjResourceBundle.getResource("MOBDWNM01"), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjMenuDisplay);
         return;
      }
      
      //
      // Create and clear the route load display
      //
      if (cobjRouteLoadDisplay == null) {
         cobjRouteLoadDisplay = new Form(cobjResourceBundle.getResource("MOBDWNHDR"));
         cobjRouteLoadDisplay.addCommand(cobjCommandCancel);
         cobjRouteLoadDisplay.addCommand(cobjCommandAccept);
         cobjRouteLoadDisplay.setCommandListener(this);
      }
      cobjRouteLoadDisplay.deleteAll();
      cobjRouteLoadDisplay.append(new TextField(cobjResourceBundle.getResource("MOBDWN001"), "", 10, TextField.NUMERIC));
      if (cobjControlStore.getMobileStatus() != null && !cobjControlStore.getMobileStatus().toUpperCase().equals("*SAVED")) {
         cobjRouteLoadDisplay.append(new StringItem(cobjResourceBundle.getResource("MOBDWN002"), cobjResourceBundle.getResource("MOBDWN003")));
      }
      cobjRouteLoadDisplay.append(new StringItem(cobjResourceBundle.getResource("MOBDWN004"), cobjResourceBundle.getResource("MOBDWN005")));
      for (int i=0; i<cobjRouteLoadDisplay.size(); i++) {
         ((Item)cobjRouteLoadDisplay.get(i)).setLayout(Item.LAYOUT_VCENTER | Item.LAYOUT_NEWLINE_BEFORE | Item.LAYOUT_NEWLINE_AFTER);
      }
      
      //
      // Show the route load display
      //
      cobjDisplay.setCurrent(cobjRouteLoadDisplay);
   
   }
   
   /**
    * Actions the route load display
    */
   public void actionRouteLoad() {
      
      //
      // Perform the route load on a seperate thread
      //
      cobjDisplay.setCurrent(new cRouteDownload(cobjMobileStore.getUserName(),((TextField)cobjRouteLoadDisplay.get(0)).getString()));
      
   }
   
   /**
    * Loads the route save display
    */
   public void loadRouteSave() {
      
      //
      // Mobile must be configured
      //
      if (cobjMobileStore.getUserName() == null || cobjMobileStore.getUserName().equals("")) {
         Alert objAlert = new Alert(null, cobjResourceBundle.getResource("MOBUPLM01"), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjMenuDisplay);
         return;
      }
      
      //
      // Route must be loaded
      //
      if (cobjControlStore.getMobileStatus() == null || cobjControlStore.getMobileStatus().equals("")) {
         Alert objAlert = new Alert(null, cobjResourceBundle.getResource("MOBUPLM02"), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjMenuDisplay);
         return;
      }
      
      //
      // Check for uncalled customers
      //
      boolean bolCalled = true;
      try {
         java.util.Vector objRouteList = cobjRouteStore.getRouteList();
         for (int i=0; i<objRouteList.size(); i++) {
            if (!((cRouteList)objRouteList.elementAt(i)).getStatus().equals("1")) {
               bolCalled = false;
            }
         }
      } catch(Exception objException) {
         Alert objAlert = new Alert(null, objException.getMessage(), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjMenuDisplay);
         return;
      }

      //
      // Create and clear the route save display
      //
      if (cobjRouteSaveDisplay == null) {
         cobjRouteSaveDisplay = new Form(cobjResourceBundle.getResource("MOBUPLHDR"));
         cobjRouteSaveDisplay.addCommand(cobjCommandCancel);
         cobjRouteSaveDisplay.addCommand(cobjCommandAccept);
         cobjRouteSaveDisplay.setCommandListener(this);
      }
      cobjRouteSaveDisplay.deleteAll();
      cobjRouteSaveDisplay.append(new TextField(cobjResourceBundle.getResource("MOBUPL001"), "", 10, TextField.NUMERIC));
      if (cobjControlStore.getMobileStatus().toUpperCase().equals("*SAVED")) {
         cobjRouteSaveDisplay.append(new StringItem(cobjResourceBundle.getResource("MOBUPL002"), cobjResourceBundle.getResource("MOBUPL003"))); 
      }
      if (!bolCalled) {
         cobjRouteSaveDisplay.append(new StringItem(cobjResourceBundle.getResource("MOBUPL004"), cobjResourceBundle.getResource("MOBUPL005")));
      }
      cobjRouteSaveDisplay.append(new StringItem(cobjResourceBundle.getResource("MOBUPL006"), cobjResourceBundle.getResource("MOBUPL007")));
      for (int i=0; i<cobjRouteSaveDisplay.size(); i++) {
         ((Item)cobjRouteSaveDisplay.get(i)).setLayout(Item.LAYOUT_VCENTER | Item.LAYOUT_NEWLINE_BEFORE | Item.LAYOUT_NEWLINE_AFTER);
      }
      
      //
      // Show the route save display
      //
      cobjDisplay.setCurrent(cobjRouteSaveDisplay);
   
   }
   
   /**
    * Actions the route save display
    */
   public void actionRouteSave() {
      
      //
      // Perform the route save on a seperate thread
      //
      cobjDisplay.setCurrent(new cRouteUpload(cobjMobileStore.getUserName(),((TextField)cobjRouteSaveDisplay.get(0)).getString()));
      
   }
   
   /**
    * Loads the route show display
    */
   public void loadRouteShow() {
      
      //
      // Mobile must be configured
      //
      if (cobjMobileStore.getUserName() == null || cobjMobileStore.getUserName().equals("")) {
         Alert objAlert = new Alert(null, cobjResourceBundle.getResource("MOBSETM01"), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjMenuDisplay);
         return;
      }
      
      //
      // Route must be loaded
      //
      if (cobjControlStore.getMobileStatus() == null || cobjControlStore.getMobileStatus().equals("")) {
         Alert objAlert = new Alert(null, cobjResourceBundle.getResource("MOBSETM02"), null, AlertType.ERROR);
         objAlert.setTimeout(Alert.FOREVER);
         cobjDisplay.setCurrent(objAlert, cobjMenuDisplay);
         return;
      }

      //
      // Create and clear the route show display
      //
      if (cobjRouteShowDisplay == null) {
         cobjRouteShowDisplay = new Form(cobjResourceBundle.getResource("MOBSETHDR"));
         cobjRouteShowDisplay.addCommand(cobjCommandBack);
         cobjRouteShowDisplay.setCommandListener(this);
      }
      cobjRouteShowDisplay.deleteAll();
      cobjRouteShowDisplay.append(new StringItem(cobjResourceBundle.getResource("MOBSET001"), cobjMobileStore.getUserName()));
      cobjRouteShowDisplay.append(new StringItem(cobjResourceBundle.getResource("MOBSET002"), cobjControlStore.getUserFirstName() + " " + cobjControlStore.getUserLastName()));
      cobjRouteShowDisplay.append(new StringItem(cobjResourceBundle.getResource("MOBSET003"), cobjControlStore.getMobileDate()));
      cobjRouteShowDisplay.append(new StringItem(cobjResourceBundle.getResource("MOBSET004"), cobjControlStore.getMobileStatus()));
      cobjRouteShowDisplay.append(new StringItem(cobjResourceBundle.getResource("MOBSET005"), cobjControlStore.getMobileLoadedTime()));
      cobjRouteShowDisplay.append(new StringItem(cobjResourceBundle.getResource("MOBSET006"), cobjControlStore.getMobileSavedTime()));
      for (int i=0; i<cobjRouteShowDisplay.size(); i++) {
         ((Item)cobjRouteShowDisplay.get(i)).setLayout(Item.LAYOUT_NEWLINE_AFTER);
      }
      
      //
      // Show the route show display
      //
      cobjDisplay.setCurrent(cobjRouteShowDisplay);
   
   }
   
   /**
    * Actions the route show display
    */
   public void actionRouteShow() {
      
      //
      // Show the main menu
      //
      cobjDisplay.setCurrent(cobjMenuDisplay);
      
   }
   
   /**
    * This class implements the Efex application table color schema.
    */
   class cTableColorSchema extends ColorSchema {

      /**
       * Override abstract ColorSchema methods
       */
      public Image getBackgroundImage() {
         return null;
      }
      public int getBackgroundImageAnchorPoint() {
         return 0;
      }
      public int getColor(int intColorSpecifier) {
         switch (intColorSpecifier) {
            case Display.COLOR_BACKGROUND:
               return 0xe0e0e0;
            case Display.COLOR_HIGHLIGHTED_FOREGROUND:
               return 0xffffff;
            case Display.COLOR_HIGHLIGHTED_BACKGROUND:
               return 0x0033ff;
            case Display.COLOR_BORDER:
               return 0x202020;
            case Display.COLOR_HIGHLIGHTED_BORDER:
               return 0x202020;
            case Display.COLOR_FOREGROUND:
               return 0x000000;
            default:
               return 0x000000;
         }
      }
      public boolean isBackgroundImageTiled() {
         return false;
      }
      public boolean isBackgroundTransparent() {
         return false;
      }

   }
   
   /**
    * This class implements the Efex application number formatter.
    */
   class cNumberFormatter {
      public double getNumber(String strNumber) {
         double dblValue;
         try {
            dblValue = Double.parseDouble(strNumber);
         } catch (NumberFormatException objException) {
            dblValue = 0;
         }
         return dblValue;
      }
      public String formatNumber(String strNumber, int intDecimals, boolean bolNegative) {
         double dblValue;
         try {
            dblValue = Double.parseDouble(strNumber);
         } catch (NumberFormatException objException) {
            dblValue = 0;
         }
         if (!bolNegative && dblValue < 0) {
            dblValue = dblValue * -1;
         }
         if (intDecimals != 0) {
            for (int i=0; i<intDecimals; i++) {
               dblValue = dblValue * 10;
            }
         }
         String strReturn = String.valueOf((long)dblValue);
         while (strReturn.length() < (intDecimals+1)) {
            strReturn = "0" + strReturn;
         }
         if (intDecimals != 0) {
            strReturn = strReturn.substring(0, strReturn.length()-(intDecimals)) + "." + strReturn.substring(strReturn.length()-intDecimals);
         }
         return strReturn;
      }
      public String formatNumber(double dblNumber, int intDecimals, boolean bolNegative) {
         double dblValue = dblNumber;
         if (!bolNegative && dblValue < 0) {
            dblValue = dblValue * -1;
         }
         if (intDecimals != 0) {
            for (int i=0; i<intDecimals; i++) {
               dblValue = dblValue * 10;
            }
         }
         String strReturn = String.valueOf((long)dblValue);
         while (strReturn.length() < (intDecimals+1)) {
            strReturn = "0" + strReturn;
         }
         if (intDecimals != 0) {
            strReturn = strReturn.substring(0, strReturn.length()-(intDecimals)) + "." + strReturn.substring(strReturn.length()-intDecimals);
         }
         return strReturn;
      }
   }
   
   /**
    * This class implements the Efex application load functionality.
    */
   class cApplicationLoad extends Form implements Runnable {

      //
      // Instance private declarations
      //
      private Thread cobjThread;
      private Gauge cobjGauge;
      private cApplication cobjApplication;

      /**
       * Constructs a new instance
       */
      public cApplicationLoad(cApplication objApplication) {
         super(null);
         cobjGauge = new Gauge(cobjResourceBundle.getResource("MOBMNUM01"),false,Gauge.INDEFINITE,Gauge.CONTINUOUS_RUNNING);
         super.append(cobjGauge);
         cobjApplication = objApplication;
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
         Displayable objDisplayable = cobjMenuDisplay;
         Alert objAlert = null;
         Thread objThread = Thread.currentThread();
         try {
            
            while (cobjThread == objThread) {
               
               //
               // Create the application fonts
               //
               cobjFontHead = Font.getFont(Font.FACE_PROPORTIONAL, Font.STYLE_BOLD, Font.SIZE_LARGE);
               cobjFontMedium = Font.getFont(Font.FACE_PROPORTIONAL, Font.STYLE_BOLD, Font.SIZE_MEDIUM);
               cobjFontSmall = Font.getFont(Font.FACE_PROPORTIONAL, Font.STYLE_PLAIN, Font.SIZE_SMALL);
               cobjFontMenu = Font.getFont(Font.FACE_PROPORTIONAL, Font.STYLE_BOLD, Font.SIZE_SMALL);

               //
               // Create the application references
               //
               cobjControlStore = new cControlStore();
               cobjRouteStore = new cRouteStore();
               cobjCustomerStore = new cCustomerStore();
               cobjMessageStore = new cMessageStore();
               cobjUomStore = new cUomStore();
               cobjCustomerLocationStore = new cCustomerLocationStore();
               cobjCustomerTypeStore = new cCustomerTypeStore();
               cobjCustomerChannelStore = new cCustomerChannelStore();
               cobjDistributorStore = new cDistributorStore();
               cobjControlStore.loadControlModel();
               cobjTableColorSchema = new cTableColorSchema();
               cobjFormatter = new cNumberFormatter();

               //
               // Create the application images
               //
               try {
                  cobjConfiguration = Image.createImage("/config.png");
                  cobjRouteLoad = Image.createImage("/routeLoad.png");
                  cobjRouteSave = Image.createImage("/routeSave.png");
                  cobjRouteProperty = Image.createImage("/routeProperty.png");
                  cobjCustomerOpen = Image.createImage("/customerOpen.png");
                  cobjDataUpdate = Image.createImage("/dataUpdate.png");
                  cobjMessageCheck = Image.createImage("/messageCheck.png");
                  cobjSelectOn = Image.createImage("/selectOn.png");
                  cobjSelectOff = Image.createImage("/selectOff.png");
                  cobjError = Image.createImage("/error.png");
               } catch (java.io.IOException objException) {}

               //
               // Create the application commands
               //
               cobjCommandExit = new Command(cobjResourceBundle.getResource("CMDEXIT"), Command.EXIT, 0);
               cobjCommandBack = new Command(cobjResourceBundle.getResource("CMDBACK"), Command.BACK, 0);
               cobjCommandCancel = new Command(cobjResourceBundle.getResource("CMDCANCEL"), Command.CANCEL, 0);
               cobjCommandAccept = new Command(cobjResourceBundle.getResource("CMDACCEPT"), Command.SCREEN, 0);

               //
               // Create the application main menu
               //
               cobjMenuDisplay = new List(cobjResourceBundle.getResource("MOBMNUHDR"), List.IMPLICIT);
               cobjMenuDisplay.append(cobjResourceBundle.getResource("MOBMNU002"), cobjRouteLoad);
               cobjMenuDisplay.append(cobjResourceBundle.getResource("MOBMNU007"), cobjMessageCheck);
               cobjMenuDisplay.append(cobjResourceBundle.getResource("MOBMNU005"), cobjCustomerOpen);
               cobjMenuDisplay.append(cobjResourceBundle.getResource("MOBMNU006"), cobjDataUpdate);
               cobjMenuDisplay.append(cobjResourceBundle.getResource("MOBMNU003"), cobjRouteSave);
               cobjMenuDisplay.append(cobjResourceBundle.getResource("MOBMNU004"), cobjRouteProperty);
               cobjMenuDisplay.append(cobjResourceBundle.getResource("MOBMNU001"), cobjConfiguration);
               cobjMenuDisplay.addCommand(cobjCommandExit);
               cobjMenuDisplay.setCommandListener(cobjApplication);
               cobjMenuDisplay.setFitPolicy(Choice.TEXT_WRAP_OFF);
               cobjMenuDisplay.setFont(0, cobjFontMedium);
               cobjMenuDisplay.setFont(1, cobjFontMedium);
               cobjMenuDisplay.setFont(2, cobjFontMedium);
               cobjMenuDisplay.setFont(3, cobjFontMedium);
               cobjMenuDisplay.setFont(4, cobjFontMedium);
               cobjMenuDisplay.setFont(5, cobjFontMedium);
               cobjMenuDisplay.setFont(6, cobjFontMedium);

               //
               // Create the function control instances
               //
               cobjRouteControl = new cRouteControl(cobjApplication);
               cobjCustomerControl = new cCustomerControl(cobjApplication);
               cobjMessageControl = new cMessageControl(cobjApplication);

               //
               //Set the display
               //
               objDisplayable = cobjMenuDisplay;
               
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
               cobjDisplay.setCurrent(objDisplayable); 
            } 
         }
         
      }
      
   }
   
   /**
    * This class implements the mobile configuration functionality.
    */
   class cMobileConfiguration extends Form implements Runnable {

      //
      // Instance private declarations
      //
      private Thread cobjThread;
      private Gauge cobjGauge;

      /**
       * Constructs a new instance
       */
      public cMobileConfiguration() {
         super(null);
         cobjGauge = new Gauge("Configuring mobile...",false,Gauge.INDEFINITE,Gauge.CONTINUOUS_RUNNING);
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
         Displayable objDisplayable = cobjMenuDisplay;
         Alert objAlert = null;
         Thread objThread = Thread.currentThread();
         try {
            
            while (cobjThread == objThread) {
                
               //
               // Save the mobile configuration and reset the main menu
               //
               cobjMobileStore.saveDataModel();
               if (cobjMobileStore.getLanguage() != null && cobjMobileStore.getLanguage().equals("English")) {
                  cobjResourceBundle = new cResourceEnglish();
               }
               if (cobjMobileStore.getLanguage() != null && cobjMobileStore.getLanguage().equals("Chinese")) {
                  cobjResourceBundle = new cResourceChinese();
               }
               cobjRouteControl.setResourceBundle();
               cobjCustomerControl.setResourceBundle();
               cobjMessageControl.setResourceBundle();
               cobjMenuDisplay.setTitle(cobjResourceBundle.getResource("MOBMNUHDR"));
               cobjMenuDisplay.set(0, cobjResourceBundle.getResource("MOBMNU002"), cobjRouteLoad);
               cobjMenuDisplay.set(1, cobjResourceBundle.getResource("MOBMNU007"), cobjMessageCheck);
               cobjMenuDisplay.set(2, cobjResourceBundle.getResource("MOBMNU005"), cobjCustomerOpen);
               cobjMenuDisplay.set(3, cobjResourceBundle.getResource("MOBMNU006"), cobjDataUpdate);
               cobjMenuDisplay.set(4, cobjResourceBundle.getResource("MOBMNU003"), cobjRouteSave);
               cobjMenuDisplay.set(5, cobjResourceBundle.getResource("MOBMNU004"), cobjRouteProperty);
               cobjMenuDisplay.set(6, cobjResourceBundle.getResource("MOBMNU001"), cobjConfiguration);
               
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
               cobjDisplay.setCurrent(objDisplayable);
            } 
         }
         
      }
      
   }
   
   /**
    * This class implements the Efex route download functionality.
    */
   class cRouteDownload extends Form implements Runnable, CommandListener {

      //
      // Instance private declarations
      //
      private Thread cobjThread;
      private Gauge cobjGauge;
      private String cstrUserName;
      private String cstrPassword;

      /**
       * Constructs a new instance
       */
      public cRouteDownload(String strUserName, String strPassword) {
         super(null);
         super.addCommand(cobjCommandCancel);
         super.setCommandListener(this);
         cobjGauge = new Gauge(cobjResourceBundle.getResource("MOBDWNM02"),false,Gauge.INDEFINITE,Gauge.CONTINUOUS_RUNNING);
         super.append(cobjGauge);
         cstrUserName = strUserName;
         cstrPassword = strPassword;
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
         Displayable objDisplayable = cobjMenuDisplay;
         Alert objAlert = null;
         Thread objThread = Thread.currentThread();
         cConnection objConnection = null;
         cMailbox objOutbox = null;
         cMailbox objInbox = null;
         try {
            
            while (cobjThread == objThread) {
              
               //
               // Load the request buffer
               //
               objOutbox = new cMailbox();
               objOutbox.addMessage(cMailbox.EFEX_RQS_USERNAME,cstrUserName);
               objOutbox.addMessage(cMailbox.EFEX_RQS_PASSWORD,cstrPassword);
               
               //
               // Communicate with the server
               //
               objConnection = new cConnection(cobjResourceBundle);
               String strResponse = objConnection.postDataStream(cobjMobileStore.getSecure(), cobjMobileStore.getServerUrl() + "/MobileDownload.ashx", objOutbox.getBuffer().toString());

               //
               // Load the response messages and process
               //
               objInbox = new cMailbox();
               objInbox.putBuffer(strResponse);
               cMessage objMessage = null;
               StringBuffer objStoreBuffer = null;
               for (int i=0; i<objInbox.getMessageCount(); i++) {
                  objMessage = objInbox.getMessage(i);  
                  switch (objMessage.getCode()) {
                     case cMailbox.EFEX_RQS_MESSAGE: {
                        throw new Throwable(objMessage.getData());
                     }
                     case cMailbox.EFEX_CTL_STR: {
                        objStoreBuffer = new StringBuffer();
                        break;
                     }
                     case cMailbox.EFEX_CTL_END: {
                         cobjControlStore.loadDataStore(objStoreBuffer.toString());
                         cobjControlStore.loadControlModel();
                        break;
                     }
                     case cMailbox.EFEX_RTE_STR: {
                        objStoreBuffer = new StringBuffer();
                        break;
                     }
                     case cMailbox.EFEX_RTE_END: {
                        cobjRouteStore.loadDataStore(objStoreBuffer.toString());
                        break;
                     }
                     case cMailbox.EFEX_CUS_STR: {
                        objStoreBuffer = new StringBuffer();
                        break;
                     }
                     case cMailbox.EFEX_CUS_END: {
                        cobjCustomerStore.loadDataStore(objStoreBuffer.toString());
                        break;
                     }
                     case cMailbox.EFEX_MSG_STR: {
                        objStoreBuffer = new StringBuffer();
                        break;
                     }
                     case cMailbox.EFEX_MSG_END: {
                        cobjMessageStore.loadDataStore(objStoreBuffer.toString());
                        break;
                     }
                     case cMailbox.EFEX_UOM_STR: {
                        objStoreBuffer = new StringBuffer();
                        break;
                     }
                     case cMailbox.EFEX_UOM_END: {
                        cobjUomStore.loadDataStore(objStoreBuffer.toString());
                        break;
                     }
                     case cMailbox.EFEX_CUS_LOCN_STR: {
                        objStoreBuffer = new StringBuffer();
                        break;
                     }
                     case cMailbox.EFEX_CUS_LOCN_END: {
                        cobjCustomerLocationStore.loadDataStore(objStoreBuffer.toString());
                        break;
                     }
                     case cMailbox.EFEX_CUS_TYPE_STR: {
                        objStoreBuffer = new StringBuffer();
                        break;
                     }
                     case cMailbox.EFEX_CUS_TYPE_END: {
                        cobjCustomerTypeStore.loadDataStore(objStoreBuffer.toString());
                        break;
                     }
                     case cMailbox.EFEX_CUS_TRADE_CHANNEL_STR: {
                        objStoreBuffer = new StringBuffer();
                        break;
                     }
                     case cMailbox.EFEX_CUS_TRADE_CHANNEL_END: {
                        cobjCustomerChannelStore.loadDataStore(objStoreBuffer.toString());
                        break;
                     }
                     case cMailbox.EFEX_DIS_STR: {
                        objStoreBuffer = new StringBuffer();
                        break;
                     }
                     case cMailbox.EFEX_DIS_END: {
                        cobjDistributorStore.loadDataStore(objStoreBuffer.toString());
                        break;
                     }
                     default: {
                        objStoreBuffer = objStoreBuffer.append(objMessage.getMessageData());
                     }
                  }
               }
               
               //
               // Stop the thread process
               //
               cobjThread = null;
            
            }
            
         } catch (Throwable objThrowable) {
            objAlert = new Alert(null, objThrowable.getMessage(), null, AlertType.ERROR);
            objAlert.setTimeout(Alert.FOREVER);
         } finally {
            objConnection = null;
            super.removeCommand(cobjCommandCancel);
            if (objAlert != null) {
               cobjDisplay.setCurrent(objAlert, objDisplayable);
            } else {
               objAlert = new Alert(null, cobjResourceBundle.getResource("MOBDWNM03"), null, AlertType.INFO);
               objAlert.setTimeout(Alert.FOREVER);
               cobjDisplay.setCurrent(objAlert,objDisplayable); 
            } 
         }
         
      }

      /**
       * Override the CommandListener abstract methods
       */
      public void commandAction(Command objCommand, Displayable objDisplayable) {                                               

         //
         // Show the main menu
         //
         cobjThread = null;
         super.removeCommand(cobjCommandCancel);

      }
      
   }
   
   /**
    * This class implements the Efex route upload functionality.
    */
   class cRouteUpload extends Form implements Runnable, CommandListener {

      //
      // Instance private declarations
      //
      private Thread cobjThread;
      private Gauge cobjGauge;
      private String cstrUserName;
      private String cstrPassword;

      /**
       * Constructs a new instance
       */
      public cRouteUpload(String strUserName, String strPassword) {
         super(null);
         super.addCommand(cobjCommandCancel);
         super.setCommandListener(this);
         cobjGauge = new Gauge(cobjResourceBundle.getResource("MOBUPLM03"),false,Gauge.INDEFINITE,Gauge.CONTINUOUS_RUNNING);
         super.append(cobjGauge);
         cstrUserName = strUserName;
         cstrPassword = strPassword;
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
         Displayable objDisplayable = cobjMenuDisplay;
         Alert objAlert = null;
         Thread objThread = Thread.currentThread();
         cConnection objConnection = null;
         cMailbox objOutbox = null;
         cMailbox objInbox = null;
         try {
            
            while (cobjThread == objThread) {
               
               //
               // Load the message buffer from the data store
               //
               cobjControlStore.saveControlModel("*OPEN");

               //
               // Load the request buffer
               //
               objOutbox = new cMailbox();
               objOutbox.addMessage(cMailbox.EFEX_RQS_USERNAME,cstrUserName);
               objOutbox.addMessage(cMailbox.EFEX_RQS_PASSWORD,cstrPassword);
               objOutbox.addBulkMessages(cobjRouteStore.saveDataStore());
               objOutbox.addBulkMessages(cobjCustomerStore.saveDataStore());
                  
               //
               // Communicate with the server
               //
               objConnection = new cConnection(cobjResourceBundle);
               String strResponse = objConnection.postDataStream(cobjMobileStore.getSecure(), cobjMobileStore.getServerUrl() + "/MobileUpload.ashx", objOutbox.getBuffer().toString());
               
               //
               // Load the response messages and process
               //
               objInbox = new cMailbox();
               objInbox.putBuffer(strResponse);
               cMessage objMessage = null;
               StringBuffer objStoreBuffer = null;
               for (int i=0; i<objInbox.getMessageCount(); i++) {
                  objMessage = objInbox.getMessage(i);
                  switch (objMessage.getCode()) {
                     case cMailbox.EFEX_RQS_MESSAGE: {
                        throw new Throwable(objMessage.getData());
                     }
                     default: {
                        objStoreBuffer = objStoreBuffer.append(objMessage.getCode());
                     }
                  }
               }
               
               //
               // Load the message buffer from the data store
               //
               cobjControlStore.saveControlModel("*SAVED");

               //
               // Stop the thread process
               //
               cobjThread = null;
           
            }

         } catch (Throwable objThrowable) {
            objAlert = new Alert(null, objThrowable.getMessage(), null, AlertType.ERROR);
            objAlert.setTimeout(Alert.FOREVER);
         } finally {
            objConnection = null;
            super.removeCommand(cobjCommandCancel);
            if (objAlert != null) {
               cobjDisplay.setCurrent(objAlert, objDisplayable);
            } else {
               objAlert = new Alert(null, cobjResourceBundle.getResource("MOBUPLM04"), null, AlertType.INFO);
               objAlert.setTimeout(Alert.FOREVER);
               cobjDisplay.setCurrent(objAlert,objDisplayable);
            } 
         }
         
      }

      /**
       * Override the CommandListener abstract methods
       */
      public void commandAction(Command objCommand, Displayable objDisplayable) {                                               

         //
         // Show the main menu
         //
         cobjThread = null;
         super.removeCommand(cobjCommandCancel);

      }
      
   }
 
}
