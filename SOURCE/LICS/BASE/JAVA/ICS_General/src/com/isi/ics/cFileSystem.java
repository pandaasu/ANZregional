/**
 * System : Interface Control System
 * Type   : Class
 * Name   : cFileSystem
 * Author : Steve Gregan
 * Date   : February 2011
 */
package com.isi.ics;
import java.io.*;
import java.util.*;
import java.util.zip.*;
import java.sql.*;

/**
 * This class implements the file system functionality.
 */
public final class cFileSystem {

   /**
    * Method to retrieve a filtered file list
    *
    * @param strFilePath the file path
    * @throws Exception the exception message
    */
   public static void retrieveFileList(String strFilePath) throws Exception {

		//
		// Retrieve the file list
		//
      File objPath = new File(strFilePath);
		if (!objPath.exists()) {
         throw new Exception("Retrieve File List Failed - Path (" + strFilePath + ") does not exist");
      }
		if (!objPath.isDirectory()) {
         throw new Exception("Retrieve File List Failed - Path (" + strFilePath + ") is not a directory");
      }
		ArrayList objFileArray = new ArrayList();
		File[] objPaths = objPath.listFiles();
		for (int i=0; i<objPaths.length; i++) {
			if (objPaths[i].isDirectory()) {
				File[] objFiles = objPaths[i].listFiles();
				for (int j=0; j<objFiles.length; j++) {
					if (objFiles[j].isFile() && !objFiles[j].getName().startsWith("~")) {
						objFileArray.add(objPaths[i].getName()+"\t"+objFiles[j].getName());
					}
				}
			}
		}
		if (objFileArray.isEmpty()) {
			return;
		}

		//
		// Load the file list
		//
		boolean bolInserted = false;
		String strWork;
		String[] strData;
		String INSERT_FILE =
			"insert into lics_file" +
			" (fil_file," +
			" fil_path," +
			" fil_name," +
			" fil_status," +
			" fil_crt_user," +
			" fil_crt_time," +
			" fil_message)" +
			" select lics_file_sequence.nextval, ?, ?, '1', user, sysdate, null from dual" +
			" where not((?, ?) in (select upper(fil_path), upper(fil_name) from lics_file))";
      Connection objConnection = DriverManager.getConnection("jdbc:default:connection:");
		objConnection.setAutoCommit(false);
      PreparedStatement objStatement = null;
		try {
			objStatement = objConnection.prepareStatement(INSERT_FILE);
			for (int i=0; i<objFileArray.size(); i++) {
				strWork = (String)objFileArray.get(i);
				strData = strWork.split("\t");
				objStatement.setString(1, strData[0].toUpperCase());
				objStatement.setString(2, strData[1]);
				objStatement.setString(3, strData[0].toUpperCase());
				objStatement.setString(4, strData[1].toUpperCase());
				objStatement.executeUpdate();
				bolInserted = true;
			}
			objConnection.commit();
		} catch(Exception objException) {
         throw objException;
      } finally {
         if (objStatement != null) {
            objStatement.close();
				objStatement = null;
         }
      }

		//
		// Wake the file job processors when required
		//
		if (bolInserted) {
			CallableStatement objCallableStatement = objConnection.prepareCall("{call lics_pipe.spray('*FILE', null, '*WAKE')}");
			try {
				objCallableStatement.execute();
			} catch(Exception objException) {
				throw objException;
			} finally {
				if (objCallableStatement != null) {
					objCallableStatement.close();
					objCallableStatement = null;
				}
			}
		}

   }

	/**
    * Method to rename a file
    *
    * @param strSrcPath the source canonical path
	 * @param strSrcFile the source file name
    * @param strTarPath the target canonical path
	 * @param strTarFile the target file name
	 * @param strReplace replace the target file when exists
    * @throws Exception the exception message
    */
   public static void renameFile(String strSrcPath, String strSrcFile, String strTarPath, String strTarFile, String strReplace) throws Exception {
      File objSrcFile = new File(strSrcPath, strSrcFile);
		if (!objSrcFile.exists()) {
			throw new Exception("Rename File Failed - Source file (" + strSrcPath + ":" + strSrcFile + ") does not exist");
		} else if (!objSrcFile.isFile()) {
			throw new Exception("Rename File Failed - Source file (" + strSrcPath + ":" + strSrcFile + ") is not a file");
		}
		File objTarFile = new File(strTarPath, strTarFile);
		if (objTarFile.exists()) {
			if (!objTarFile.isFile()) {
				throw new Exception("Rename File Failed - Target file (" + strTarPath + ":" + strTarFile + ") exists but is not a file");
			} else {
				if (!strReplace.equals("1")) {
					throw new Exception("Rename File Failed - Target file exists and replace not requested");
				} else {
					if (!objTarFile.delete()) {
						throw new Exception("Rename File Failed - Target file deletion failed");
					}
				}
			}
		}
		if (!objSrcFile.renameTo(objTarFile)) {
			throw new Exception("Rename File Failed - Source file(" + strSrcPath + ":" + strSrcFile + ") Target file (" + strTarPath + ":" + strTarFile + ")");
		}
   }

	/**
    * Method to move a file
    *
    * @param strSrcPath the source canonical path
	 * @param strSrcFile the source file name
    * @param strTarPath the target canonical path
	 * @param strTarFile the target file name
	 * @param strReplace replace the target file when exists
    * @throws Exception the exception message
    */
   public static void moveFile(String strSrcPath, String strSrcFile, String strTarPath, String strTarFile, String strReplace) throws Exception {
      File objSrcFile = new File(strSrcPath, strSrcFile);
		if (!objSrcFile.exists()) {
			throw new Exception("Move File Failed - Source file (" + strSrcPath + ":" + strSrcFile + ") does not exist");
		} else if (!objSrcFile.isFile()) {
			throw new Exception("Move File Failed - Source file (" + strSrcPath + ":" + strSrcFile + ") is not a file");
		}
		File objTarFile = new File(strTarPath, strTarFile);
		if (objTarFile.exists()) {
			if (!objTarFile.isFile()) {
				throw new Exception("Move File Failed - Target file (" + strTarPath + ":" + strTarFile + ") exists but is not a file");
			} else {
				if (!strReplace.equals("1")) {
					throw new Exception("Move File Failed - Target file exists and replace not requested");
				} else {
					if (!objTarFile.delete()) {
						throw new Exception("Move File Failed - Target file deletion failed");
					}
				}
			}
		}
		if (!objSrcFile.renameTo(objTarFile)) {
			throw new Exception("Move File Failed - Source file(" + strSrcPath + ":" + strSrcFile + ") Target file (" + strTarPath + ":" + strTarFile + ")");
		}
   }

	/**
    * Method to copy a file
    *
    * @param strSrcPath the source canonical path
	 * @param strSrcFile the source file name
    * @param strTarPath the target canonical path
	 * @param strTarFile the target file name
	 * @param strReplace replace the target file when exists
    * @throws Exception the exception message
    */
   public static void copyFile(String strSrcPath, String strSrcFile, String strTarPath, String strTarFile, String strReplace) throws Exception {
      
		//
      // Check the source and target file information
      //
		File objSrcFile = new File(strSrcPath, strSrcFile);
		if (!objSrcFile.exists()) {
			throw new Exception("Copy File Failed - Source file (" + strSrcPath + ":" + strSrcFile + ") does not exist");
		} else if (!objSrcFile.isFile()) {
			throw new Exception("Copy File Failed - Source file (" + strSrcPath + ":" + strSrcFile + ") is not a file");
		}
		File objTarFile = new File(strTarPath, strTarFile);
		if (objTarFile.exists()) {
			if (!objTarFile.isFile()) {
				throw new Exception("Copy File Failed - Target file (" + strTarPath + ":" + strTarFile + ") exists but is not a file");
			} else {
				if (!strReplace.equals("1")) {
					throw new Exception("Copy File Failed - Target file exists and replace not requested");
				} else {
					if (!objTarFile.delete()) {
						throw new Exception("Copy File Failed - Target file deletion failed");
					}
				}
			}
		}

		//
      // Copy the source file to the target file
      //
		InputStream objInputStream = null;
		OutputStream objOutputStream = null;
		try {
			objInputStream = new FileInputStream(objSrcFile);
			objOutputStream = new FileOutputStream(objTarFile);
			byte[] bytBuffer = new byte[4096];
			int intLength = 0;
			while ((intLength = objInputStream.read(bytBuffer)) > 0) {
				objOutputStream.write(bytBuffer, 0 ,intLength);
			}
			objOutputStream.close();
			objInputStream.close();
		} catch(Exception objException) {
         throw new Exception("Copy File Failed - Data copy failed - " + objException.getMessage());
      } finally {
         objOutputStream = null;
         objInputStream = null;
      }
		
   }

	/**
    * Method to delete a file
    *
    * @param strSrcPath the source canonical path
	 * @param strSrcFile the source file name
    * @throws Exception the exception message
    */
   public static void deleteFile(String strSrcPath, String strSrcFile) throws Exception {
      File objSrcFile = new File(strSrcPath, strSrcFile);
		if (objSrcFile.exists()) {
			if (!objSrcFile.isFile()) {
				throw new Exception("Delete File Failed - Source file (" + strSrcPath + ":" + strSrcFile + ") is not a file");
			}
			if (!objSrcFile.delete()) {
				throw new Exception("Delete File Failed - Source file deletion failed");
			}
		}
   }

	/**
    * Method to archive a file in GZIP format
	 * **notes** 1. Source file is always decompressed
	 *           2. Target file is always compressed
    *
    * @param strSrcPath the source canonical path
	 * @param strSrcFile the source file name
    * @param strTarPath the target canonical path
	 * @param strTarFile the target file name
	 * @param strDelete delete the source file
	 * @param strReplace replace the target file when exists
    * @throws Exception the exception message
    */
   public static void archiveFileGzip(String strSrcPath, String strSrcFile, String strTarPath, String strTarFile, String strDelete, String strReplace) throws Exception {

		//
      // Check the source and target file information
      //
		File objSrcFile = new File(strSrcPath, strSrcFile);
		if (!objSrcFile.exists()) {
			throw new Exception("Archive File GZIP Failed - Source file (" + strSrcPath + ":" + strSrcFile + ") does not exist");
		} else if (!objSrcFile.isFile()) {
			throw new Exception("Archive File GZIP Failed - Source file (" + strSrcPath + ":" + strSrcFile + ") is not a file");
		}
		File objTarFile = new File(strTarPath, strTarFile);
		if (objTarFile.exists()) {
			if (!objTarFile.isFile()) {
				throw new Exception("Archive File GZIP Failed - Target file (" + strTarPath + ":" + strTarFile + ") exists but is not a file");
			} else {
				if (!strReplace.equals("1")) {
					throw new Exception("Archive File GZIP Failed - Target file exists and replace not requested");
				} else {
					if (!objTarFile.delete()) {
						throw new Exception("Archive File GZIP Failed - Target file deletion failed");
					}
				}
			}
		}

      //
      // Compress (GZIP) the source file to the target file
      //
		FileInputStream objInputStream = null;
      GZIPOutputStream objOutputStream = null;
      byte[] bytBuffer = new byte[4096];
      int intLength = 0;
      try {
			objInputStream = new FileInputStream(objSrcFile);
			objOutputStream = new GZIPOutputStream(new FileOutputStream(objTarFile));
			while ((intLength = objInputStream.read(bytBuffer)) > 0) {
				objOutputStream.write(bytBuffer,0,intLength);
			}
			objOutputStream.finish();
			objOutputStream.close();
			objInputStream.close();
      } catch(Exception objException) {
         throw new Exception("Archive File GZIP Failed - File compression failed - " + objException.getMessage());
      } finally {
         objOutputStream = null;
         objInputStream = null;
      }

		//
      // Delete the source file when requested
      //
		if (strDelete.equals("1")) {
			if (!objSrcFile.delete()) {
				throw new Exception("Archive File GZIP Failed - Source file delete failed");
			}
		}

   }

	/**
    * Method to restore a file from GZIP format
	 * **notes** 1. Source file is always compressed
	 *           2. Target file is always decompressed
    *
    * @param strSrcPath the source canonical path
	 * @param strSrcFile the source file name
    * @param strTarPath the target canonical path
	 * @param strTarFile the target file name
	 * @param strDelete delete the source file
	 * @param strReplace replace the target file when exists
    * @throws Exception the exception message
    */
   public static void restoreFileGzip(String strSrcPath, String strSrcFile, String strTarPath, String strTarFile, String strDelete, String strReplace) throws Exception {

		//
      // Check the source and target file information
      //
		File objSrcFile = new File(strSrcPath, strSrcFile);
		if (!objSrcFile.exists()) {
			throw new Exception("Restore File GZIP Failed - Source file (" + strSrcPath + ":" + strSrcFile + ") does not exist");
		} else if (!objSrcFile.isFile()) {
			throw new Exception("Restore File GZIP Failed - Source file (" + strSrcPath + ":" + strSrcFile + ") is not a file");
		}
		File objTarFile = new File(strTarPath, strTarFile);
		if (objTarFile.exists()) {
			if (!objTarFile.isFile()) {
				throw new Exception("Restore File GZIP Failed - Target file (" + strTarPath + ":" + strTarFile + ") exists but is not a file");
			} else {
				if (!strReplace.equals("1")) {
					throw new Exception("Restore File GZIP Failed - Target file exists and replace not requested");
				} else {
					if (!objTarFile.delete()) {
						throw new Exception("Restore File GZIP Failed - Target file deletion failed");
					}
				}
			}
		}

      //
      // Decompress (GZIP) the source file to the target file
      //
		GZIPInputStream objInputStream = null;
      FileOutputStream objOutputStream = null;
      byte[] bytBuffer = new byte[4096];
      int intLength = 0;
      try {
			objInputStream = new GZIPInputStream(new FileInputStream(objSrcFile));
			objOutputStream = new FileOutputStream(objTarFile);
			while ((intLength = objInputStream.read(bytBuffer)) > 0) {
				objOutputStream.write(bytBuffer,0,intLength);
			}
			objOutputStream.close();
			objInputStream.close();
      } catch(Exception objException) {
         throw new Exception("Restore File GZIP Failed - File decompression failed - " + objException.getMessage());
      } finally {
         objOutputStream = null;
         objInputStream = null;
      }

		//
      // Delete the source file when requested
      //
		if (strDelete.equals("1")) {
			if (!objSrcFile.delete()) {
				throw new Exception("Restore File GZIP Failed - Source file delete failed");
			}
		}

   }

	/**
    * Method to archive a file in ZIP format
	 * **notes** 1. Source file is always decompressed
	 *           2. Target file is always compressed
    *
    * @param strSrcPath the source canonical path
	 * @param strSrcFile the source file name
    * @param strTarPath the target canonical path
	 * @param strTarFile the target file name
	 * @param strDelete delete the source file
	 * @param strReplace replace the target file when exists
	 * @throws Exception the exception message
    */
   public static void archiveFileZip(String strSrcPath, String strSrcFile, String strTarPath, String strTarFile, String strDelete, String strReplace) throws Exception {

		//
      // Check the source and target file information
      //
		File objSrcFile = new File(strSrcPath, strSrcFile);
		if (!objSrcFile.exists()) {
			throw new Exception("Archive File ZIP Failed - Source file (" + strSrcPath + ":" + strSrcFile + ") does not exist");
		} else if (!objSrcFile.isFile()) {
			throw new Exception("Archive File ZIP Failed - Source file (" + strSrcPath + ":" + strSrcFile + ") is not a file");
		}
		File objTarFile = new File(strTarPath, strTarFile);
		if (objTarFile.exists()) {
			if (!objTarFile.isFile()) {
				throw new Exception("Archive File ZIP Failed - Target file (" + strTarPath + ":" + strTarFile + ") exists but is not a file");
			} else {
				if (!strReplace.equals("1")) {
					throw new Exception("Archive File ZIP Failed - Target file exists and replace not requested");
				} else {
					if (!objTarFile.delete()) {
						throw new Exception("Archive File ZIP Failed - Target file deletion failed");
					}
				}
			}
		}

      //
      // Compress (ZIP) the source file to the target file
      //
      //
      // Local variables
      //
		FileInputStream objInputStream = null;
      ZipOutputStream objOutputStream = null;
      byte[] bytBuffer = new byte[4096];
      int intLength = 0;
      try {
			objInputStream = new FileInputStream(objSrcFile);
			objOutputStream = new ZipOutputStream(new FileOutputStream(objTarFile));
			objOutputStream.putNextEntry(new ZipEntry(objSrcFile.getName()));
			while ((intLength = objInputStream.read(bytBuffer)) > 0) {
				objOutputStream.write(bytBuffer,0,intLength);
			}
			objOutputStream.closeEntry();
			objOutputStream.close();
			objInputStream.close();
      } catch(Exception objException) {
         throw new Exception("Archive File ZIP Failed - File Compression Failed - " + objException.getMessage());
      } finally {
         objOutputStream = null;
         objInputStream = null;
      }

		//
      // Delete the source file when requested
      //
		if (strDelete.equals("1")) {
			if (!objSrcFile.delete()) {
				throw new Exception("Archive File ZIP Failed - Source File Delete Failed");
			}
		}

   }

	/**
    * Method to restore a file from ZIP format
	 * **notes** 1. Source file is always compressed
	 *           2. Target file is always decompressed
    *
    * @param strSrcPath the source canonical path
	 * @param strSrcFile the source file name
    * @param strTarPath the target canonical path
	 * @param strTarFile the target file name
	 * @param strDelete delete the source file
	 * @param strReplace replace the target file when exists
    * @throws Exception the exception message
    */
   public static void restoreFileZip(String strSrcPath, String strSrcFile, String strTarPath, String strTarFile, String strDelete, String strReplace) throws Exception {

		//
      // Check the source and target file information
      //
		File objSrcFile = new File(strSrcPath, strSrcFile);
		if (!objSrcFile.exists()) {
			throw new Exception("Restore File ZIP Failed - Source file (" + strSrcPath + ":" + strSrcFile + ") does not exist");
		} else if (!objSrcFile.isFile()) {
			throw new Exception("Restore File ZIP Failed - Source file (" + strSrcPath + ":" + strSrcFile + ") is not a file");
		}
		File objTarFile = new File(strTarPath, strTarFile);
		if (objTarFile.exists()) {
			if (!objTarFile.isFile()) {
				throw new Exception("Restore File ZIP Failed - Target file (" + strTarPath + ":" + strTarFile + ") exists but is not a file");
			} else {
				if (!strReplace.equals("1")) {
					throw new Exception("Restore File ZIP Failed - Target file exists and replace not requested");
				} else {
					if (!objTarFile.delete()) {
						throw new Exception("Restore File ZIP Failed - Target file deletion failed");
					}
				}
			}
		}

      //
      // Decompress (ZIP) the source file to the target file
      //
      ZipInputStream objInputStream = null;
      FileOutputStream objOutputStream = null;
		ZipEntry objZipEntry = null;
      byte[] bytBuffer = new byte[4096];
      int intLength = 0;
      try {
			objInputStream = new ZipInputStream(new FileInputStream(objSrcFile));
			if ((objZipEntry = objInputStream.getNextEntry()) != null) {
				objOutputStream = new FileOutputStream(objZipEntry.getName());
				while ((intLength = objInputStream.read(bytBuffer)) > 0) {
					objOutputStream.write(bytBuffer,0,intLength);
				}
				objOutputStream.flush();
				objOutputStream.close();
			}
			objInputStream.close();
      } catch(Exception objException) {
         throw new Exception("Restore File ZIP Failed - File Decompression Failed - " + objException.getMessage());
      } finally {
         objOutputStream = null;
         objInputStream = null;
      }
		//
      // Delete the source file when requested
      //
		if (strDelete.equals("1")) {
			if (!objSrcFile.delete()) {
				throw new Exception("Restore File ZIP Failed - Source file delete failed");
			}
		}

   }

	/**
    * Method to write a log line
    *
    * @param strLogFile the log text
	 * @param strLogText the log text
    * @throws Exception the exception message
    */
   public static void writeLog(String strLogFile, String strLogText) throws Exception {
      PrintWriter objPrintWriter = new PrintWriter(new FileWriter(strLogFile, true));
      objPrintWriter.println(strLogText);
      objPrintWriter.close();
   }

	/**
    * Method to create a directory
    *
    * @param strPath the directory name
    * @throws Exception the exception message
    */
   public static void createDirectory(String strPath) throws Exception {
		File objFile = new File(strPath);
		if (!objFile.exists()) {
			try {
				if (!objFile.mkdir()) {
					throw new Exception("Create Directory Failed - Unable to create directory (" + strPath + ")");
				}
			} catch(Exception objException) {
				throw new Exception("Create Directory Failed - " + objException.getMessage());
			}
		}
   }

	/**
    * Method to delete a directory and all children
    *
    * @param strPath the directory name
    * @throws Exception the exception message
    */
   public static void deleteDirectory(String strPath) throws Exception {
		File objFile = new File(strPath);
      if (objFile.isDirectory()) {
         String[] strChildren = objFile.list();
			if (strChildren.length != 0) {
				throw new Exception("Delete Directory Failed - Files exist in the directory - unable to delete");
         }
			try {
				if (!objFile.delete()) {
					throw new Exception("Delete Directory Failed - Unable to delete directory (" + objFile.getName() + ")");
				}
			} catch(Exception objException) {
				throw new Exception("Delete Directory Failed - " + objException.getMessage());
			}
      }
   }

	/**
    * Method to clear a directory and all children
    *
    * @param strPath the directory name
    * @throws Exception the exception message
    */
   public static void clearDirectory(String strPath) throws Exception {
		File objFile = new File(strPath);
      if (objFile.isDirectory()) {
         String[] strChildren = objFile.list();
         for (int i=0; i<strChildren.length; i++) {
            File objWork = new File(objFile, strChildren[i]);
            if (objWork.isFile()) {
               if (!objWork.delete()) {
                  throw new Exception("Clear Directory Failed - Unable to delete file (" + objWork.getName() + ")");
               }
            } else if (objWork.isDirectory()) {
               if (!objWork.delete()) {
                  throw new Exception("Clear Directory Failed - Unable to delete directory (" + objWork.getName() + ")");
               }
            }
         }
      }
   }
   
}