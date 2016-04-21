package com.navrit.dosenet;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.FloatingActionButton;
import android.support.v4.content.ContextCompat;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.widget.Toast;

import com.afollestad.materialdialogs.DialogAction;
import com.afollestad.materialdialogs.MaterialDialog;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.VolleyLog;
import com.android.volley.toolbox.JsonObjectRequest;
import com.navrit.dosenet.app.AppController;

import net.danlew.android.joda.JodaTimeAndroid;

import org.joda.time.DateTime;
import org.joda.time.DateTimeZone;
import org.joda.time.LocalDateTime;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.TimeZone;
import java.util.UUID;

public class MainActivity extends AppCompatActivity implements View.OnClickListener {

    private RecyclerView rv;
    public FloatingActionButton fab;
    private SwipeRefreshLayout mSwipeRefreshLayout;
    private static String TAG = MainActivity.class.getSimpleName();

    private List<Dosimeter> dosimeterList;
    public String unitSelected = "µSv/hr";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            getWindow().setStatusBarColor(ContextCompat.getColor(this,R.color.colorPrimaryDark));
        }

        setContentView(R.layout.activity_main);

        Toolbar toolbar = (Toolbar) findViewById(R.id.tool_bar);
        setSupportActionBar(toolbar);                   // Setting toolbar as the ActionBar with setSupportActionBar() call

        // Display icon in the toolbar
        getSupportActionBar().setDisplayShowHomeEnabled(true);
        getSupportActionBar().setLogo(R.mipmap.dosenet_logo);
        getSupportActionBar().setDisplayUseLogoEnabled(true);

        rv = (RecyclerView)findViewById(R.id.recycler_view);
        LinearLayoutManager llm = new LinearLayoutManager(this);
        rv.setLayoutManager(llm);
        rv.setHasFixedSize(true);

        fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(this);

        JodaTimeAndroid.init(this);
        initializeData();

        mSwipeRefreshLayout = (SwipeRefreshLayout) findViewById(R.id.swipeRefreshLayout);
        mSwipeRefreshLayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                refreshItems();
            }
            void refreshItems() {
                // Load items
                initializeData();

                // Load complete
                onItemsLoadComplete();
            }

            void onItemsLoadComplete() {
                // Update the adapter and notify data set changed
                // ...

                // Stop refresh animation
                mSwipeRefreshLayout.setRefreshing(false);
            }
        });
        mSwipeRefreshLayout.setColorSchemeResources(android.R.color.holo_blue_bright,
                android.R.color.holo_green_light,
                android.R.color.holo_orange_light,
                android.R.color.holo_red_light);
    }

    private void initializeData() {
        dosimeterList = new ArrayList<>();
        Log.d(TAG,">>> Started JSON");
        makeJsonObjectRequest();
        Log.d(TAG,">>> Passed JSON");
    }

    /**
     * Method to make json object request where json response starts with {
     * */
    private void makeJsonObjectRequest() {
        String urlJsonObj = "https://radwatch.berkeley.edu/sites/default/files/output.geojson?" +
                UUID.randomUUID().toString().replaceAll("-","");
        JsonObjectRequest jsonObjReq = new JsonObjectRequest(Request.Method.GET,
                urlJsonObj, null, new Response.Listener<JSONObject>() {
            @Override
            public void onResponse(JSONObject response) {
                Date dateToday = Calendar.getInstance().getTime();
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                String today = sdf.format(dateToday);
                TimeZone tzLocal = TimeZone.getDefault();
                //Log.d(TAG,today);
                Log.d(TAG,tzLocal.getID());

                DateTimeFormatter dtf = DateTimeFormat.forPattern("yyyy-MM-dd HH:mm:ss");

                Log.d(TAG, ">>> Got JSON response");
                Log.v(TAG, response.toString());

                try {
                    JSONArray station_array = response.getJSONArray("features");
                    for (int i = 0; i < station_array.length(); i++) {
                        JSONObject station = station_array.getJSONObject(i);

                        JSONObject geometry = station.getJSONObject("geometry");
                        JSONArray coordinates = geometry.getJSONArray("coordinates");
                        double latitude = coordinates.getDouble(0);
                        double longitude = coordinates.getDouble(1);

                        JSONObject properties = station.getJSONObject("properties");
                        String name = properties.getString("Name");
                        String latest_measurement = properties.getString("Latest measurement");
                        String timezone = properties.getString("timezone");

                        //Convert latest_measurement to UTC, then local time

                        DateTimeZone dateTimeZone = DateTimeZone.forID(timezone);
                        DateTime date = dtf.withZone(dateTimeZone).parseDateTime(latest_measurement);
                        //DateTime UTCDate = date.toDateTime(DateTimeZone.UTC);
                        TimeZone tz2 = TimeZone.getDefault();
                        DateTime local_dt = new DateTime(date, DateTimeZone.forID(tz2.getID()));
                        LocalDateTime l2 = new LocalDateTime(local_dt);
                        Log.e(TAG,timezone+"\n\t\t\t\t\t"+local_dt+" "+latest_measurement);

                        DateTime latest_date_dt = dtf.withZone(dateTimeZone).parseDateTime(latest_measurement);
                        String latest_date = latest_date_dt.toLocalDate().toString();

                        if (!timezone.equals("America/Los_Angeles")){                        //Japan
                            DateTime dtLocal = date.withZone(DateTimeZone.forID
                                    (tzLocal.getID()));

                            //Log.e(TAG,">> "+dtLocal.plusHours(HOUR SHIFT));
                        }

                        //Log.w(TAG,today+" "+latest_date);
                        if (today.equals(latest_date)) {
                            latest_measurement = local_dt.toLocalTime()
                                    .toString().replace(".000", "");
                        } else {
                            latest_measurement = local_dt.toLocalDateTime()
                                    .toString().replace("T"," ").replace(".000", "");
                            //latest_measurement = dt.withZone(zone).toString().replace("T"," ").replace(".000", " GMT");
                        }


                        double dose;
                        switch(unitSelected){
                            case "µSv/hr":
                                dose = properties.getDouble("&microSv/hr");
                                break;
                            case "mRem/hr":
                                dose = properties.getDouble("mRem/hr");
                                break;
                            default:
                                dose = properties.getDouble("&microSv/hr");
                        }
                        dose = (double) Math.round(dose * 1000) / 1000;

                        dosimeterList.add(
                                new Dosimeter(name, dose, unitSelected, latest_measurement,
                                        longitude, latitude)
                        );
                        //Log.i(TAG, dosimeterList.get(i).name);
                    }
                    initializeAdapter();
                } catch (JSONException e) {
                    e.printStackTrace();
                    Toast.makeText(getApplicationContext(),
                            "Error: " + e.getMessage(),
                            Toast.LENGTH_LONG).show();
                }
            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                VolleyLog.e(TAG, "Error: " + error.getMessage());
                Toast.makeText(getApplicationContext(),
                        error.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });

        AppController.getInstance().addToRequestQueue(jsonObjReq);
    }

    private void initializeAdapter() {
        RVAdapter adapter = new RVAdapter(dosimeterList);
        rv.setAdapter(adapter);
    }

    @Override
    public void onClick(View view){
        Intent map_intent = new Intent(this, MapsActivity.class);
        //https://stackoverflow.com/questions/2405120/how-to-start-an-intent-by-passing-some-parameters-to-it
        // map_intent.putExtra("JSON", ... );

        startActivity(map_intent);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main_menu, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.information:
                Intent info_intent = new Intent(this, InformationActivity.class);
                startActivity(info_intent);
                return true;

            case R.id.action_settings:
                new MaterialDialog.Builder(this)
                        .title(R.string.title)
                        .content(R.string.content)
                        .positiveText(R.string.agree)
                        .negativeText(R.string.disagree)
                        .onPositive(new MaterialDialog.SingleButtonCallback() {
                            @Override
                            public void onClick(@NonNull MaterialDialog dialog, @NonNull DialogAction which) {
                                unitSelected = "µSv/hr";
                                Log.i("Unit: ", unitSelected);
                            }
                        })
                        .onNegative(new MaterialDialog.SingleButtonCallback() {
                            @Override
                            public void onClick(@NonNull MaterialDialog dialog, @NonNull DialogAction which) {
                                unitSelected = "mRem/hr";
                                Log.i("Unit: ", unitSelected);
                            }
                        })
                        .show();
                return true;

            default:
                return super.onOptionsItemSelected(item);
        }
    }

}
