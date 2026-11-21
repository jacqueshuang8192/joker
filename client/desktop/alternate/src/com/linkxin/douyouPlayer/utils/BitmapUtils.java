package com.linkxin.douyouPlayer.utils;

import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.Bitmap.Config;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.PixelFormat;
import android.graphics.PointF;
import android.graphics.PorterDuff.Mode;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Environment;
import android.util.DisplayMetrics;

import com.linkxin.douyouPlayer.util.Logger;
import com.linkxin.douyouPlayer.vo.BitmapEntity;
import com.sina.weibo.sdk.utils.LogUtil;


public class BitmapUtils {

	public static final int RAW_SIZE = 128;

	private static int sWidth = 128;
	private static int sHeight = 128;

	public static void setSize(int width, int height) {
		int size = width > height ? width : height;
		sWidth = size;
		sHeight = size;
	}

	public static void reset() {
		sWidth = RAW_SIZE;
		sHeight = RAW_SIZE;
	}

	public static Bitmap getBitmap(byte[] coverByte) {
		try {
			if (coverByte == null)
				return null;

			BitmapFactory.Options opts = new BitmapFactory.Options();
			opts.inJustDecodeBounds = true;
			BitmapFactory.decodeByteArray(coverByte, 0, coverByte.length, opts);
			opts.inSampleSize = BitmapUtils.computeSampleSize(opts, -1, sWidth
					* sHeight);

			opts.inJustDecodeBounds = false;
			return BitmapFactory.decodeByteArray(coverByte, 0,
					coverByte.length, opts);
		} catch (Exception ex) {
			ex.printStackTrace();
            return null;
		}
	}

	public static Bitmap getBitmap(InputStream is) {
		try {
			if (is == null)
				return null;

			int size = is.available();
			byte[] bs = new byte[size];
			is.read(bs, 0, bs.length);

			return getBitmap(bs);
		} catch (Exception ex) {
			ex.printStackTrace();
		}

		return null;
	}

	public static Bitmap getBitmap(String path, PackageUtils.FilePosition pos) {
		if (StringUtils.isEmpty(path))
			return null;
		else if (pos == null)
			return null;

		byte[] buffer = FileUtils.getBuffer(path, pos.getOffset(),
				pos.getSize());

		return getBitmap(buffer);
	}

	public static Bitmap getBitmap(String path) {
		if (StringUtils.isEmpty(path))
			return null;

		byte[] buffer = FileUtils.getBuffer(path);

		return getBitmap(buffer);
	}

	public static int computeSampleSize(BitmapFactory.Options options,
			int minSideLength, int maxNumOfPixels) {
		int initialSize = computeInitialSampleSize(options, minSideLength,
				maxNumOfPixels);
		int roundedSize;
		if (initialSize <= 8) {
			roundedSize = 1;
			while (roundedSize < initialSize) {
				roundedSize <<= 1;
			}
		} else {
			roundedSize = (initialSize + 7) / 8 * 8;
		}

		return roundedSize;
	}

	private static int computeInitialSampleSize(BitmapFactory.Options options,
			int minSideLength, int maxNumOfPixels) {
		double w = options.outWidth;
		double h = options.outHeight;

		int lowerBound = (maxNumOfPixels == -1) ? 1 : (int) Math.ceil(Math
				.sqrt(w * h / maxNumOfPixels));
		int upperBound = (minSideLength == -1) ? 128 : (int) Math.min(
				Math.floor(w / minSideLength), Math.floor(h / minSideLength));

		if (upperBound < lowerBound) {
			// return the larger one when there is no overlapping zone.
			return lowerBound;
		}

		if ((maxNumOfPixels == -1) && (minSideLength == -1)) {
			return 1;
		} else if (minSideLength == -1) {
			return lowerBound;
		} else {
			return upperBound;

		}
	}

	/**
	 * 默认以jpg格式保存图片到指定路径
	 * 
	 * @param bm
	 * @param path
	 * @return
	 */
	public static boolean saveFile(Bitmap bm, String path) {
		if (bm == null || path == null)
			return false;
		File myCaptureFile = new File(path);
		if (myCaptureFile.exists()) {
			myCaptureFile.delete();
		}
		try {
			BufferedOutputStream bos = new BufferedOutputStream(
					new FileOutputStream(myCaptureFile));
			bm.compress(Bitmap.CompressFormat.JPEG, 80, bos);
			bos.flush();
			bos.close();
			return true;
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return false;
	}

	/**
	 * 以指定格式保存图片到指定路径
	 * 
	 * @param bm
	 * @param path
	 * @param format
	 * @return
	 */
	public static boolean saveFile(Bitmap bm, String path,
			Bitmap.CompressFormat format) {
		if (bm == null || path == null)
			return false;
		File myCaptureFile = new File(path);
		if (myCaptureFile.exists()) {
			myCaptureFile.delete();
		}
		try {
			BufferedOutputStream bos = new BufferedOutputStream(
					new FileOutputStream(myCaptureFile));
			bm.compress(format, 80, bos);
			bos.flush();
			bos.close();
			return true;
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return false;
	}

	// Bitmap转byte[]
	public static byte[] Bitmap2Bytes(Bitmap bm, Bitmap.CompressFormat format) {
		if (bm == null) {
			return null;
		}
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		bm.compress(format, 100, baos);
		return baos.toByteArray();
	}

	// byte[]转Bitmap
	public static Bitmap Bytes2Bimap(byte[] b) {
		if (b.length != 0) {
			return BitmapFactory.decodeByteArray(b, 0, b.length);
		} else {
			return null;
		}
	}

	public static Bitmap toRoundBitmap(Bitmap bitmap, int round) {
		if (bitmap == null)
			return null;
		int width = bitmap.getWidth();
		int height = bitmap.getHeight();
		float roundPx;
		float left, top, right, bottom, dst_left, dst_top, dst_right, dst_bottom;
		if (width <= height) {
			if (round != 0)
				roundPx = round;
			else
				roundPx = width / 2;
			top = 0;
			bottom = width;
			left = 0;
			right = width;
			height = width;
			dst_left = 0;
			dst_top = 0;
			dst_right = width;
			dst_bottom = width;
		} else {
			if (round != 0)
				roundPx = round;
			else
				roundPx = height / 2;
			float clip = (width - height) / 2;
			left = clip;
			right = width - clip;
			top = 0;
			bottom = height;
			width = height;
			dst_left = 0;
			dst_top = 0;
			dst_right = height;
			dst_bottom = height;
		}

		Bitmap output = Bitmap.createBitmap(width, height, Config.ARGB_8888);
		Canvas canvas = new Canvas(output);

		final int color = 0xff424242;
		final Paint paint = new Paint();

		final Rect src = new Rect((int) left, (int) top, (int) right,
				(int) bottom);
		final Rect dst = new Rect((int) dst_left, (int) dst_top,
				(int) dst_right, (int) dst_bottom);
		final RectF rectF = new RectF(dst);

		paint.setAntiAlias(true);
		canvas.drawARGB(0, 0, 0, 0);
		paint.setColor(color);
		canvas.drawRoundRect(rectF, roundPx, roundPx, paint);
		paint.setXfermode(new PorterDuffXfermode(Mode.SRC_IN));
		canvas.drawBitmap(bitmap, src, dst, paint);
		return output;
	}

	public static Bitmap getBitmap(Bitmap bitMap, int w, int h) {
		int width = bitMap.getWidth();
		int height = bitMap.getHeight();
		// 设置想要的大小
		int newWidth = w;
		int newHeight = h;
		// 计算缩放比例
		float scaleWidth = ((float) newWidth) / width;
		float scaleHeight = ((float) newHeight) / height;
		// 取得想要缩放的matrix参数
		Matrix matrix = new Matrix();
		matrix.postScale(scaleWidth, scaleHeight);
		// 得到新的图片
		bitMap = Bitmap.createBitmap(bitMap, 0, 0, width, height, matrix, true);

		return bitMap;
	}

    private static final String TAG = "BitmapUtils";
    public static Bitmap getCombineBitmaps(List<BitmapEntity> mEntityList,
                                           Bitmap... bitmaps) {
        Logger.d(TAG,"count=>" + mEntityList.size());
        Bitmap newBitmap = Bitmap.createBitmap(200, 200, Config.ARGB_8888);
        Logger.d(TAG,"newBitmap=>" + newBitmap.getWidth() + ","
                + newBitmap.getHeight());
        for (int i = 0; i < mEntityList.size(); i++) {
            Logger.d(TAG,"i==>" + i);
            newBitmap = mixtureBitmap(newBitmap, bitmaps[i], new PointF(
                    mEntityList.get(i).x, mEntityList.get(i).y));
        }
        return newBitmap;
    }
    public static Bitmap getCombineBitmaps(List<BitmapEntity> mEntityList,
                                           List<Bitmap> bitmaps) {
        Logger.d(TAG,"count=>" + mEntityList.size());
        Bitmap newBitmap = Bitmap.createBitmap(200, 200, Config.ARGB_8888);
        Logger.d(TAG,"newBitmap=>" + newBitmap.getWidth() + ","
                + newBitmap.getHeight());
        for (int i = 0; i < mEntityList.size(); i++) {
            Logger.d(TAG,"i==>" + i);
            newBitmap = mixtureBitmap(newBitmap, bitmaps.get(i), new PointF(
                    mEntityList.get(i).x, mEntityList.get(i).y));
        }
        return newBitmap;
    }

    /**
     * 将多个Bitmap合并成一个图片。
     *
     * @param columns 将多个图合成多少列
     * @param bitmaps
     *            ... 要合成的图片
     * @return
     */
    public static Bitmap combineBitmaps(int columns, Bitmap... bitmaps) {
        if (columns <= 0 || bitmaps == null || bitmaps.length == 0) {
            throw new IllegalArgumentException(
                    "Wrong parameters: columns must > 0 and bitmaps.length must > 0.");
        }
        int maxWidthPerImage = 20;
        int maxHeightPerImage = 20;
        for (Bitmap b : bitmaps) {
            maxWidthPerImage = maxWidthPerImage > b.getWidth() ? maxWidthPerImage
                    : b.getWidth();
            maxHeightPerImage = maxHeightPerImage > b.getHeight() ? maxHeightPerImage
                    : b.getHeight();
        }
        Logger.d(TAG,"maxWidthPerImage=>" + maxWidthPerImage
                + ";maxHeightPerImage=>" + maxHeightPerImage);
        int rows = 0;
        if (columns >= bitmaps.length) {
            rows = 1;
            columns = bitmaps.length;
        } else {
            rows = bitmaps.length % columns == 0 ? bitmaps.length / columns
                    : bitmaps.length / columns + 1;
        }
        Bitmap newBitmap = Bitmap.createBitmap(columns * maxWidthPerImage, rows
                * maxHeightPerImage, Config.ARGB_8888);
        Logger.d(TAG,"newBitmap=>" + newBitmap.getWidth() + ","
                + newBitmap.getHeight());
        for (int x = 0; x < rows; x++) {
            for (int y = 0; y < columns; y++) {
                int index = x * columns + y;
                if (index >= bitmaps.length)
                    break;
                Logger.d(TAG,"y=>" + y + " * maxWidthPerImage=>"
                        + maxWidthPerImage + " = " + (y * maxWidthPerImage));
                Logger.d(TAG,"x=>" + x + " * maxHeightPerImage=>"
                        + maxHeightPerImage + " = " + (x * maxHeightPerImage));
                newBitmap = mixtureBitmap(newBitmap, bitmaps[index],
                        new PointF(y * maxWidthPerImage, x * maxHeightPerImage));
            }
        }
        return newBitmap;
    }

    /**
     * Mix two Bitmap as one.
     *
     * @param first
     * @param second
     * @param fromPoint
     *            where the second bitmap is painted.
     * @return
     */
    public static Bitmap mixtureBitmap(Bitmap first, Bitmap second,
                                       PointF fromPoint) {
        if (first == null || second == null || fromPoint == null) {
            return null;
        }
        Bitmap newBitmap = Bitmap.createBitmap(first.getWidth(),
                first.getHeight(), Config.ARGB_8888);
        Canvas cv = new Canvas(newBitmap);
        cv.drawBitmap(first, 0, 0, null);
        cv.drawBitmap(second, fromPoint.x, fromPoint.y, null);
        cv.save(Canvas.ALL_SAVE_FLAG);
        cv.restore();
        return newBitmap;
    }

    public static void getScreenWidthAndHeight(Activity mContext) {
        DisplayMetrics metric = new DisplayMetrics();
        mContext.getWindowManager().getDefaultDisplay().getMetrics(metric);
        int width = metric.widthPixels; // 屏幕宽度（像素）
        int height = metric.heightPixels; // 屏幕高度（像素）
        Logger.d(TAG,"screen width=>" + width + ",height=>" + height);
    }

    static public Drawable getScaleDraw(String imgPath, Context mContext) {

        Bitmap bitmap = null;
        try {
            Logger.d(TAG,
                    "[getScaleDraw]imgPath is " + imgPath.toString());
            File imageFile = new File(imgPath);
            if (!imageFile.exists()) {
                Logger.d(TAG, "[getScaleDraw]file not  exists");
                return null;
            }
            BitmapFactory.Options opts = new BitmapFactory.Options();
            opts.inJustDecodeBounds = true;
            BitmapFactory.decodeFile(imgPath, opts);

            opts.inSampleSize = computeSampleSize(opts, -1, 800 * 480);
            // Log.d("BitmapUtil","inSampleSize===>"+opts.inSampleSize);
            opts.inJustDecodeBounds = false;
            bitmap = BitmapFactory.decodeFile(imgPath, opts);

        } catch (OutOfMemoryError err) {
            Logger.d(TAG, "[getScaleDraw] out of memory");

        }
        if (bitmap == null) {
            return null;
        }
        Drawable resizeDrawable = new BitmapDrawable(mContext.getResources(),
                bitmap);
        return resizeDrawable;
    }


    static public Bitmap getScaleBitmap(Resources res, int id) {

        Bitmap bitmap = null;
        try {
            BitmapFactory.Options opts = new BitmapFactory.Options();
            opts.inJustDecodeBounds = true;
            BitmapFactory.decodeResource(res, id, opts);

            opts.inSampleSize = computeSampleSize(opts, -1, 800 * 480);
            // Log.d("BitmapUtil","inSampleSize===>"+opts.inSampleSize);
            opts.inJustDecodeBounds = false;
            bitmap = BitmapFactory.decodeResource(res, id, opts);
        } catch (OutOfMemoryError err) {
            Logger.d(TAG, "[getScaleBitmap] out of memory");

        }
        return bitmap;
    }

    public static void saveMyBitmap(Context mContext, Bitmap bitmap,
                                    String desName) throws IOException {
        FileOutputStream fOut = null;

        if (Environment.getExternalStorageState() != Environment.MEDIA_MOUNTED) {
            Logger.d(TAG,"sdcard doesn't exit, save png to app dir");
            fOut = mContext.openFileOutput(desName + ".png",
                    Context.MODE_PRIVATE);
        } else {
            File f = new File(Environment.getExternalStorageDirectory()
                    .getPath() + "/Asst/cache/" + desName + ".png");
            f.createNewFile();
            fOut = new FileOutputStream(f);
        }
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, fOut);
        try {
            fOut.flush();
        } catch (IOException e) {
            e.printStackTrace();
        }
        try {
            fOut.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // drawable 转换成bitmap
    public static Bitmap drawableToBitmap(Drawable drawable) {
        int width = drawable.getIntrinsicWidth();// 取drawable的长宽
        int height = drawable.getIntrinsicHeight();
        Bitmap.Config config = drawable.getOpacity() != PixelFormat.OPAQUE ?Bitmap.Config.ARGB_8888:Bitmap.Config.RGB_565;// 取drawable的颜色格式
        Bitmap bitmap = Bitmap.createBitmap(width, height, config);// 建立对应bitmap
        Canvas canvas = new Canvas(bitmap);// 建立对应bitmap的画布
        drawable.setBounds(0, 0, width, height);
        drawable.draw(canvas);// 把drawable内容画到画布中
        return bitmap;
    }

    /**
     * 默认压缩图片
     * @param bm
     * @return
     */
    public static byte[] Bitmap2Bytes(Bitmap bm) {
        return Bitmap2Bytes(bm,65);//图片压缩 65，100表示不压缩
    }

    /**
     * @param bm
     * @param quality 在0~100之间，quality越高图片质量越好
     * @return
     */
    public static byte[] Bitmap2Bytes(Bitmap bm,int quality) {
        if (quality <0 || quality >100){
            quality = 100;
        }
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        bm.compress(Bitmap.CompressFormat.PNG, quality, baos);
        return baos.toByteArray();
    }

}
