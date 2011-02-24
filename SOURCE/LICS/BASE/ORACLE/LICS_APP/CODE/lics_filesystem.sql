/******************/
/* Package Header */
/******************/
create or replace package lics_filesystem as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lics
    Package : lics_filesystem
    Owner   : lics_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Local Interface Control System - lics_filesystem

    The package implements the java utility functionality.

    1. Execute external procedure will execute an operating system command and raise
       an exception with any generated standard error information.

    2. Execute external function will execute an operating system command and return
       any generated standard out information or raise an exception with any generated
       standard error information.

    3. The command string is parsed as a space delimted string. Double quotes can be
       used to define a parameter with embedded spaces. Any embedded double quotes
       within a quoted parameter must appear as a pair (eg. "xxxx""xxxx").

    YYYY/MM   Author         Description
    -------   ------         -----------
    2011/02   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure retrieve_file_list(par_path in varchar2);
   procedure send_interface(par_interface in varchar2, par_file in varchar2);
   procedure rename_file(par_src_path in varchar2, par_src_file in varchar2, par_tar_path in varchar2, par_tar_file in varchar2, par_tar_replace in varchar2);
   procedure move_file(par_src_path in varchar2, par_src_file in varchar2, par_tar_path in varchar2, par_tar_file in varchar2, par_tar_replace in varchar2);
   procedure copy_file(par_src_path in varchar2, par_src_file in varchar2, par_tar_path in varchar2, par_tar_file in varchar2, par_tar_replace in varchar2);
   procedure delete_file(par_src_path in varchar2, par_src_file in varchar2);
   procedure archive_file_gzip(par_src_path in varchar2, par_src_file in varchar2, par_tar_path in varchar2, par_tar_file in varchar2, par_src_delete in varchar2, par_tar_replace in varchar2);
   procedure restore_file_gzip(par_src_path in varchar2, par_src_file in varchar2, par_tar_path in varchar2, par_tar_file in varchar2, par_src_delete in varchar2, par_tar_replace in varchar2);
   procedure write_log(par_log_file in varchar2, par_log_text in varchar2);
   procedure create_directory(par_dir_name in varchar2);
   procedure delete_directory(par_dir_name in varchar2);
   procedure execute_external_procedure(par_command in varchar2);
   function execute_external_function(par_command in varchar2) return varchar2;

end lics_filesystem;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_filesystem as

   /************************************************************/
   /* This procedure performs the retrieve file list procedure */
   /************************************************************/
   procedure retrieve_file_list(par_path in varchar2)
      as language java name 'com.isi.ics.cFileSystem.retrieveFileList(java.lang.String)';

   /********************************************************/
   /* This procedure performs the send interface procedure */
   /********************************************************/
   procedure send_interface(par_interface in varchar2, par_file in varchar2)
      as language java name 'com.isi.ics.cFileSystem.sendInterface(java.lang.String, java.lang.String)';

   /*****************************************************/
   /* This procedure performs the rename file procedure */
   /*****************************************************/
   procedure rename_file(par_src_path in varchar2, par_src_file in varchar2, par_tar_path in varchar2, par_tar_file in varchar2, par_tar_replace in varchar2)
      as language java name 'com.isi.ics.cFileSystem.renameFile(java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String)';

   /***************************************************/
   /* This procedure performs the move file procedure */
   /***************************************************/
   procedure move_file(par_src_path in varchar2, par_src_file in varchar2, par_tar_path in varchar2, par_tar_file in varchar2, par_tar_replace in varchar2)
      as language java name 'com.isi.ics.cFileSystem.moveFile(java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String)';

   /***************************************************/
   /* This procedure performs the copy file procedure */
   /***************************************************/
   procedure copy_file(par_src_path in varchar2, par_src_file in varchar2, par_tar_path in varchar2, par_tar_file in varchar2, par_tar_replace in varchar2)
      as language java name 'com.isi.ics.cFileSystem.copyFile(java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String)';

   /*****************************************************/
   /* This procedure performs the delete file procedure */
   /*****************************************************/
   procedure delete_file(par_src_path in varchar2, par_src_file in varchar2)
      as language java name 'com.isi.ics.cFileSystem.deleteFile(java.lang.String, java.lang.String)';

   /***********************************************************/
   /* This procedure performs the archive file GZIP procedure */
   /***********************************************************/
   procedure archive_file_gzip(par_src_path in varchar2, par_src_file in varchar2, par_tar_path in varchar2, par_tar_file in varchar2, par_src_delete in varchar2, par_tar_replace in varchar2)
      as language java name 'com.isi.ics.cFileSystem.archiveFileGzip(java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String)';

   /***********************************************************/
   /* This procedure performs the restore file GZIP procedure */
   /***********************************************************/
   procedure restore_file_gzip(par_src_path in varchar2, par_src_file in varchar2, par_tar_path in varchar2, par_tar_file in varchar2, par_src_delete in varchar2, par_tar_replace in varchar2)
      as language java name 'com.isi.ics.cFileSystem.restoreFileGzip(java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String)';

   /***************************************************/
   /* This procedure performs the write log execution */
   /***************************************************/
   procedure write_log(par_log_file in varchar2, par_log_text in varchar2)
      as language java name 'com.isi.ics.cFileSystem.writeLog(java.lang.String, java.lang.String)';

   /**********************************************************/
   /* This procedure performs the create directory execution */
   /**********************************************************/
   procedure create_directory(par_dir_name in varchar2)
      as language java name 'com.isi.ics.cFileSystem.createDirectory(java.lang.String)';

   /**********************************************************/
   /* This procedure performs the delete directory execution */
   /**********************************************************/
   procedure delete_directory(par_dir_name in varchar2)
      as language java name 'com.isi.ics.cFileSystem.deleteDirectory(java.lang.String)';

   /************************************************************/
   /* This procedure performs the external procedure execution */
   /************************************************************/
   procedure execute_external_procedure(par_command in varchar2)
      as language java name 'com.isi.ics.cExternalProcess.executeProcedure(java.lang.String)';

   /**********************************************************/
   /* This function performs the external function execution */
   /**********************************************************/
   function execute_external_function(par_command in varchar2) return varchar2
      as language java name 'com.isi.ics.cExternalProcess.executeFunction(java.lang.String) return java.lang.String';

end lics_filesystem;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_filesystem for lics_app.lics_filesystem;
grant execute on lics_filesystem to public;