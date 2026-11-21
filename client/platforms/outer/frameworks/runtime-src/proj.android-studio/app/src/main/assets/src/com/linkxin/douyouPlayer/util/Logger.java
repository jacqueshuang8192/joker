package com.linkxin.douyouPlayer.util;

import java.io.File;
import java.io.RandomAccessFile;







import com.linkxin.douyouPlayer.constant.DouyouConstants;

import android.os.Environment;
import android.util.Log;

public class Logger {
	static String TAG = Logger.class.getName();
	public static boolean IS_DEBUG= DouyouConstants.IS_DEBUG;

	public static boolean isWriteToFile = true;
	private static String openLogfilepath = "/sdcard/douyou/douyou.txt";
	private static boolean isFirst = true;
	private final static String LOG_FILEPATH = "/sdcard/douyou/";
	private final static String LOG_FILENAME = "ott";
	private final static String LOG_FILEEXT = ".txt";
	private static File mLogFile;
	private final static long LOGFILE_LIMIT = 1000000L;

	private static void checkLog() {
		if (isFirst == true) {
			File file = new File(openLogfilepath);
			isFirst = false;
		}
		createLogFile();
	}

	private static void createLogFile() {
		if (isWriteToFile) {
			synchronized (LOG_FILENAME) {
				if (mLogFile == null) {
					try {
						if (!Environment.getExternalStorageState().equals(
								Environment.MEDIA_MOUNTED)) {
							return;
						}
						File logpath = new File(LOG_FILEPATH);
						if (!logpath.exists()) {
							logpath.mkdir();
						}
						mLogFile = new File(LOG_FILEPATH + LOG_FILENAME
								+ LOG_FILEEXT);
						if (!mLogFile.exists()) {
							Logger.d(TAG, "Create the file:" + LOG_FILENAME);
							mLogFile.createNewFile();
						}
					} catch (Exception e) {
						e.printStackTrace();
					}
				} else {
					if (mLogFile.isFile()) {
						if (mLogFile.length() > LOGFILE_LIMIT) {
							StringBuffer sb = new StringBuffer("");
							sb.append(LOG_FILEPATH);
							sb.append(LOG_FILENAME);
							sb.append(DateUtil.getNow());
							sb.append(LOG_FILEEXT);
							
							mLogFile.renameTo(new File(DateUtil.getNow()));
							sb = null;
							sb = new StringBuffer("");
							sb.append(LOG_FILEPATH);
							sb.append(LOG_FILENAME);
							sb.append(LOG_FILEEXT);
							mLogFile = new File(sb.toString());
							sb = null;
							if (!mLogFile.exists()) {
								Log.d(TAG, "Create the file:" + LOG_FILENAME
										+ LOG_FILEEXT);
								try {
									mLogFile.createNewFile();
								} catch (Exception e) {
									e.printStackTrace();
								}
							}
						}
					}
				}
			}
		}
	}

	private static void writeLogFile(String level, String tag, String msg) {
		if (isWriteToFile) {
			synchronized (LOG_FILENAME) {
				if (mLogFile != null) {
					StringBuffer sb = new StringBuffer();
					sb.append(DateUtil.getNow());
					sb.append(": ");
					sb.append(level);
					sb.append(": ");
					sb.append(tag);
					sb.append(": ");
					sb.append(msg);
					sb.append("\n");
					RandomAccessFile raf = null;
					try {
						raf = new RandomAccessFile(mLogFile, "rw");
						raf.seek(mLogFile.length());
						raf.write(sb.toString().getBytes("UTF-8"));
					} catch (Exception e) {
						e.printStackTrace();
					} finally {
						sb = null;
						if (raf != null) {
							try {
								raf.close();
							} catch (Exception e) {
								e.printStackTrace();
							}
						}
					}
				}
			}
		}
	}
	
	public static void d(String TAG, String msg) {
		if (IS_DEBUG) {
			android.util.Log.d(TAG, msg == null ? "" : msg);
		}
	}

	public static void i(String TAG, String msg) {
		if (IS_DEBUG) {
			Log.i(TAG, msg);
		}

	}

	public static void e(String TAG, String msg) {
		if (IS_DEBUG) {
			android.util.Log.e(TAG, msg == null ? "" : msg);
		}
	}

	public static void i(Object obj, String msg) {
		if (obj == null)
			return;
		i(obj.getClass().getSimpleName(), msg);
	}

	public static void d(Object obj, String msg) {
		if (obj == null)
			return;
		d(obj.getClass().getSimpleName(), msg);
	}

	public static void e(Object obj, String msg) {
		if (obj == null)
			return;
		e(obj.getClass().getSimpleName(), msg);
	}

	public static void w(Object obj, String msg) {
		if (obj == null)
			return;
		w(obj.getClass().getSimpleName(), msg);
	}
}
