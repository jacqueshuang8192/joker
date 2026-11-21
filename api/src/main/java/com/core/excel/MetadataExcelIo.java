package com.core.excel;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Field;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import jxl.Workbook;
import jxl.write.Label;
import jxl.write.WritableSheet;
import jxl.write.WritableWorkbook;
import jxl.write.WriteException;
import jxl.write.biff.RowsExceededException;

import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

/**
 * EXCEL IO操作
 * 
 * @作者 sundm
 * @版本 V1.0
 * @更新时间 2014-4-18 下午4:28:01
 */
public class MetadataExcelIo {

	public static   <T> String[][] parseLand(List<T> objects,Class<T> clazz) {
	    int size = objects.size();
	    Field[] fields = clazz.getDeclaredFields();
	    String[][] content = new String[size + 1][fields.length];
	    for (int i = 0; i < fields.length; i++) {
	      Field f = fields[i];
//	      content[0][i] = f.getName();
	      FieldMeta meta = f.getAnnotation(FieldMeta.class);  
	      content[0][i] = meta.name();
	    }
	    for (int i = 0 ; i < size; i++) {
	      T school = objects.get(i);
	      for (int j = 0; j < fields.length; j++) {
	        Field f = fields[j];
	        f.setAccessible(true);
	        try {
	          String value = "";
	          if (f.get(school) != null) {
	            value = f.get(school).toString();
	          }
	          content[i+1][j] = value;
	        } catch (IllegalArgumentException e) {
	          e.printStackTrace();
	        } catch (IllegalAccessException e) {
	          e.printStackTrace();
	        }
	      }
	    }
	    return content;
	  }


	  public static String writeFile(String fileName, String[][] content) {
	    WritableWorkbook wwb = null;
	    String filePath = "c:\\data\\excel\\" + fileName +".xls";
	    try {
	      wwb = Workbook.createWorkbook(new File(filePath));
	    } catch (IOException e) {
	      e.printStackTrace();
	    }
	    if (wwb != null) {
	      WritableSheet ws = wwb.createSheet(fileName, 1);
	      for (int row = 0; row < content.length; row++) {
	        for (int j = 0; j < content[row].length; j++) {
	          Label labelC = new Label(j, row, content[row][j]);
	          try {
	            ws.addCell(labelC);
	          } catch (RowsExceededException e) {
	            e.printStackTrace();
	          } catch (WriteException e) {
	            e.printStackTrace();
	          }
	        }
	      }
	      try {
	        wwb.write();
	        wwb.close();
	        return filePath;
	      } catch (IOException e) {
	        e.printStackTrace();
	      } catch (WriteException e) {
	        e.printStackTrace();
	      }
	    }
	    return null;
	  }

	public static int numSheet(File file) {
		XSSFWorkbook sssfWorkbook=null;
		try {
			InputStream is  = new FileInputStream(file);
			sssfWorkbook = new XSSFWorkbook(is);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		if(null==sssfWorkbook){
			return 0;
		}
		// 获取工作表Sheet
		return sssfWorkbook.getNumberOfSheets();
	}
	
	/**
	 * 
	 * @param file 文件
	 * @param clazz 映射类
	 * @param numSheet  文件第几个sheet 
	 * @param readFrist 起始读取行
	 * @param readLast  结束读取行
	 * @return
	 */
	public static <T> List<T> excelToClass(File file, Class<T> clazz,int numSheet,int readFrist,int readLast) {
		List<T> lands = new ArrayList<T>();
		try {
			FileInputStream fileInputStream = new FileInputStream(file);
//			POIFSFileSystem poifs = new POIFSFileSystem(fileInputStream);
			XSSFWorkbook workbook = new XSSFWorkbook(fileInputStream);
			//从0开始
			XSSFSheet sheet = workbook.getSheetAt(numSheet);
			Iterator<Row> rows = sheet.rowIterator();
			int index = 0;
			List<String> keys = new ArrayList<String>();
			while (rows.hasNext()) {
				XSSFRow row = (XSSFRow) rows.next();
				if (index == 0) {
					// int num = row.getRowNum();
					int num = row.getLastCellNum();
					for (int i = 0; i < num; i++) {
						XSSFCell cell = row.getCell(i);
						if (cell != null) {
							String value = getStringCellValue(cell);
							keys.add(value);
						}
					}
				}
				if(index==readLast){
					break;
				}
				if (index >= readFrist-1) { // 决定从哪一行开始提取,这里从第一行
					Map<String, String> map = new HashMap<String, String>();
					int num = row.getLastCellNum();
					for (int i = 0; i < num; i++) {
						if(i==num){
							break;
						}
						XSSFCell cell = row.getCell(i);
						if (cell != null) {
							map.put(keys.get(i), getStringCellValue(cell));
						}
					}
					try {
						T land = newTclass(clazz);
						MetadataBeanRefUtil.setFieldValue(land, map);
						lands.add(land);
					} catch (InstantiationException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (IllegalAccessException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				}
				index++;
			}
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return lands;
	}

	private static <T> T newTclass(Class<T> clazz)
			throws InstantiationException, IllegalAccessException {
		T a = clazz.newInstance();
		return a;

	}

	private static String getStringCellValue(XSSFCell cell) {// 获取单元格数据内容为字符串类型的数据
		String strCell = "";
		switch (cell.getCellType()) {
		case STRING:
			strCell = cell.getStringCellValue();
			break;
		case NUMERIC:
			DecimalFormat df = new DecimalFormat("#");
			strCell = String.valueOf(df.format(cell.getNumericCellValue()));
			break;
		case BOOLEAN:
			strCell = String.valueOf(cell.getBooleanCellValue());
			break;
		case BLANK:
			strCell = "";
			break;
		default:
			strCell = "";
			break;
		}
		if (strCell.equals("") || strCell == null) {
			return "";
		}
		return strCell;
	}

	public static String getUUID() {
		UUID uuid = UUID.randomUUID();
		String str = uuid.toString();
		return str.substring(0, 8);
	}
}