package com.koushikdutta.urlimageviewhelper.sample;

import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.database.DataSetObserver;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MenuItem.OnMenuItemClickListener;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.animation.OvershootInterpolator;
import android.view.animation.ScaleAnimation;
import android.widget.Adapter;
import android.widget.ArrayAdapter;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.koushikdutta.urlimageviewhelper.UrlImageViewCallback;
import com.koushikdutta.urlimageviewhelper.UrlImageViewHelper;

public class UrlImageViewHelperSample extends Activity {
	// turn a stream into a string
	private static String readToEnd(InputStream input) throws IOException {
		DataInputStream dis = new DataInputStream(input);
		byte[] stuff = new byte[1024];
		ByteArrayOutputStream buff = new ByteArrayOutputStream();
		int read = 0;
		while ((read = dis.read(stuff)) != -1) {
			buff.write(stuff, 0, read);
		}

		return new String(buff.toByteArray());
	}

	public void uploadString(final String URLString, final String word,
			final String jsonString) {
		new Thread(new Runnable() {

			@Override
			public void run() {
				// TODO Auto-generated method stub
				HttpURLConnection httpURLConnection = null;
				try {
					URL url = new URL(URLString);
					String body = URLEncoder.encode(jsonString, "UTF-8");
					String q = URLEncoder.encode(word, "UTF-8");
					StringBuilder dataBuilder = new StringBuilder();
					dataBuilder.append("q=" + q);
					dataBuilder.append("&body=" + body);

					// md5
					Log.d("debugout","q+body:"+word+jsonString);
					
					dataBuilder.append("&random="
							+ EncoderHandler.encodeByMD5(word+jsonString));

					byte[] data = dataBuilder.toString().getBytes();

					httpURLConnection = (HttpURLConnection) url
							.openConnection();
					httpURLConnection.setConnectTimeout(3000);// 设置连接超时时间
					httpURLConnection.setDoInput(true); // 打开输入流，以便从服务器获取数据
					httpURLConnection.setDoOutput(true); // 打开输出流，以便向服务器提交数据
					httpURLConnection.setRequestMethod("POST");// 设置以Post方式提交数据
					httpURLConnection.setUseCaches(false); // 使用Post方式不能使用缓存
					// 设置请求体的类型是文本类型
					httpURLConnection.setRequestProperty("Content-Type",
							"application/x-www-form-urlencoded");
					// 设置请求体的长度
					httpURLConnection.setRequestProperty("Content-Length",
							String.valueOf(data.length));
					// 获得输出流，向服务器写入数据
					OutputStream outputStream = httpURLConnection
							.getOutputStream();
					outputStream.write(data);

					int response = httpURLConnection.getResponseCode(); // 获得服务器的响应码
					if (response == HttpURLConnection.HTTP_OK) {
						InputStream inptStream = httpURLConnection
								.getInputStream();
						String responseString = dealResponseResult(inptStream); // 处理服务器的响应结果
						Log.d("debugout", responseString);

						new Handler(getMainLooper()).post(new Runnable() {
							@Override
							public void run() {
								Toast.makeText(UrlImageViewHelperSample.this,
										"uploaded", Toast.LENGTH_SHORT).show();
							}
						});
					}
				} catch (IOException e) {
					e.printStackTrace();
				}
				if (httpURLConnection != null) {
					httpURLConnection.disconnect();
				}
			}
		}).start();

	}

	/*
	 * Function : 处理服务器的响应结果（将输入流转化成字符串） Param : inputStream服务器的响应输入流 Author :
	 * 博客园-依旧淡然
	 */
	public static String dealResponseResult(InputStream inputStream) {
		String resultData = null; // 存储处理结果
		ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
		byte[] data = new byte[1024];
		int len = 0;
		try {
			while ((len = inputStream.read(data)) != -1) {
				byteArrayOutputStream.write(data, 0, len);
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
		resultData = new String(byteArrayOutputStream.toByteArray());
		return resultData;
	}

	private ListView mListView;
	private MyAdapter mAdapter;
	private HashMap<String, JSONObject> url2JsonObject = new HashMap<String, JSONObject>();// tbl和json的映射关系
	private Set<String> selectedUrls = new HashSet<String>();// 选中图片的url

	// 每次开始搜索的时候，清楚之前的历史数据
	private void reset() {
		url2JsonObject.clear();
		selectedUrls.clear();
	}

	private void addUrl(String url) {
		selectedUrls.add(url);
	}

	private void removeUrl(String url) {
		selectedUrls.remove(url);
	}

	private boolean isUrlSelected(String url) {
		return selectedUrls.contains(url);
	}

	// TODO::根据选中url，获取相应的json string 数组，用于上传用
	// 组织形式参见google image search response
	private String getSelectedJsonString() {
		return "";
	}

	private class Row extends ArrayList {

	}

	private class MyGridAdapter extends BaseAdapter {
		public MyGridAdapter(Adapter adapter) {
			mAdapter = adapter;
			mAdapter.registerDataSetObserver(new DataSetObserver() {
				@Override
				public void onChanged() {
					super.onChanged();
					notifyDataSetChanged();
				}

				@Override
				public void onInvalidated() {
					super.onInvalidated();
					notifyDataSetInvalidated();
				}
			});
		}

		Adapter mAdapter;

		@Override
		public int getCount() {
			return (int) Math.ceil((double) mAdapter.getCount() / 4d);
		}

		@Override
		public Row getItem(int position) {
			Row row = new Row();
			for (int i = position * 4; i < 4; i++) {
				if (mAdapter.getCount() < i)
					row.add(mAdapter.getItem(i));
				else
					row.add(null);
			}
			return row;
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			convertView = getLayoutInflater().inflate(R.layout.row, null);
			LinearLayout row = (LinearLayout) convertView;
			LinearLayout l = (LinearLayout) row.getChildAt(0);
			for (int child = 0; child < 4; child++) {
				int i = position * 4 + child;
				LinearLayout c = (LinearLayout) l.getChildAt(child);
				c.removeAllViews();
				if (i < mAdapter.getCount()) {
					c.addView(mAdapter.getView(i, null, null));
				}
			}

			return convertView;
		}

	}

	private class MyAdapter extends ArrayAdapter<String> {

		public MyAdapter(Context context) {
			super(context, 0);
		}

		@Override
		public View getView(final int position, View convertView,
				ViewGroup parent) {
			if (convertView == null)
				convertView = getLayoutInflater().inflate(R.layout.image, null);

			final String url = getItem(position);
			final ImageView iv = (ImageView) convertView
					.findViewById(R.id.image);
			final TextView tv = (TextView) convertView.findViewById(R.id.text);
			iv.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					tv.setTextColor(Color.RED);
					if (isUrlSelected(url)) {
						tv.setText("");
						removeUrl(url);
					} else {
						tv.setText("Selected");
						addUrl(url);
					}
				}
			});
			iv.setAnimation(null);
			// yep, that's it. it handles the downloading and showing an
			// interstitial image automagically.
			UrlImageViewHelper.setUrlDrawable(iv, getItem(position),
					R.drawable.loading, new UrlImageViewCallback() {
						@Override
						public void onLoaded(ImageView imageView,
								Bitmap loadedBitmap, String url,
								boolean loadedFromCache) {
							if (!loadedFromCache) {
								ScaleAnimation scale = new ScaleAnimation(0, 1,
										0, 1, ScaleAnimation.RELATIVE_TO_SELF,
										.5f, ScaleAnimation.RELATIVE_TO_SELF,
										.5f);
								scale.setDuration(300);
								scale.setInterpolator(new OvershootInterpolator());
								imageView.startAnimation(scale);
							}
						}
					});

			return convertView;
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		MenuItem clear = menu.add("Clear Cache");
		clear.setOnMenuItemClickListener(new OnMenuItemClickListener() {
			@Override
			public boolean onMenuItemClick(MenuItem item) {
				UrlImageViewHelper.cleanup(UrlImageViewHelperSample.this, 0);
				return true;
			}
		});
		return super.onCreateOptionsMenu(menu);
	}

	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.main);

		final Button search = (Button) findViewById(R.id.search);
		final Button uploadButton = (Button) findViewById(R.id.upload);

		final EditText searchText = (EditText) findViewById(R.id.search_text);

		mListView = (ListView) findViewById(R.id.results);
		mAdapter = new MyAdapter(this);
		MyGridAdapter a = new MyGridAdapter(mAdapter);
		mListView.setAdapter(a);

		uploadButton.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO 上传数据
				JSONObject results = new JSONObject();
				JSONArray dataArray = new JSONArray();
				for (String str : selectedUrls) {
					JSONObject value = url2JsonObject.get(str);
					if (value != null) {
						dataArray.put(value);
					}
				}
				try {
					results.put("results", dataArray);
					JSONObject responseData = new JSONObject();
					responseData.put("responseData", results);
					Log.d("out", responseData.toString());
					uploadString(
							"http://checknewversion.duapp.com/image/wordUploader.php",
							searchText.getText().toString(),
							responseData.toString());
				} catch (Exception e) {
					e.printStackTrace();
				}

			}
		});

		search.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// background the search call!
				Thread thread = new Thread() {
					@Override
					public void run() {
						try {
							// clear existing results
							runOnUiThread(new Runnable() {
								@Override
								public void run() {
									mAdapter.clear();
								}
							});

							reset();
							// do a google image search, get the ~10 paginated
							// results
							int start = 0;
							final ArrayList<String> urls = new ArrayList<String>();
							while (start < 10) {
								DefaultHttpClient client = new DefaultHttpClient();
								HttpGet get = new HttpGet(
										String.format(
												"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%s&start=%d",
												Uri.encode(searchText.getText()
														.toString()), start));
								HttpResponse resp = client.execute(get);
								HttpEntity entity = resp.getEntity();
								InputStream is = entity.getContent();
								final JSONObject json = new JSONObject(
										readToEnd(is));
								is.close();
								final JSONArray results = json.getJSONObject(
										"responseData").getJSONArray("results");
								for (int i = 0; i < results.length(); i++) {
									JSONObject result = results
											.getJSONObject(i);
									String tbUrl = result.getString("tbUrl");
									urls.add(tbUrl);

									url2JsonObject.put(tbUrl, result);
								}

								start += results.length();
							}
							// add the results to the adapter
							runOnUiThread(new Runnable() {
								@Override
								public void run() {
									for (String url : urls) {
										mAdapter.add(url);
									}
								}
							});
						} catch (final Exception ex) {
							// explodey error, lets toast it
							runOnUiThread(new Runnable() {
								@Override
								public void run() {
									Toast.makeText(
											UrlImageViewHelperSample.this,
											ex.toString(), Toast.LENGTH_LONG)
											.show();
								}
							});
						}
					}
				};
				thread.start();
			}
		});

	}
}