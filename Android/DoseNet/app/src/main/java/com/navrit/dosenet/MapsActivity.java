package com.navrit.dosenet;

import java.util.UUID;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Build;
import android.support.v4.app.FragmentActivity;
import android.os.Bundle;
import android.support.v4.content.ContextCompat;
import android.util.Log;
import android.view.WindowManager;
import android.widget.Toast;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.android.volley.Request.Method;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.VolleyLog;
import com.android.volley.toolbox.JsonObjectRequest;
import com.navrit.dosenet.app.AppController;

public class MapsActivity extends FragmentActivity {

    private static String TAG = MapsActivity.class.getSimpleName();
    private GoogleMap mMap; // Might be null if Google Play services APK is not available.
    private ProgressDialog pDialog;
    private String jsonResponse; // temporary string to show the parsed response
    String urlJsonObj = "https://radwatch.berkeley.edu/sites/default/files/output.geojson?" +
            UUID.randomUUID().toString().replaceAll("-","");

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            getWindow().setStatusBarColor(ContextCompat.getColor(this,R.color.colorPrimaryDarker));
        }

        setContentView(R.layout.activity_maps);

        pDialog = new ProgressDialog(this);
        pDialog.setMessage("Loading...");
        pDialog.setCancelable(true);

        setUpMapIfNeeded();
        showpDialog();
        makeJsonObjectRequest();
        //Intent map_intent = getIntent();
        //String firstKeyName = map_intent.getStringExtra("firstKeyName"); // will return "FirstKeyValue"
        hidepDialog();
    }

    @Override
    protected void onResume() {
        super.onResume();
        setUpMapIfNeeded();
    }

    /**
     * Sets up the map if it is possible to do so (i.e., the Google Play services APK is correctly
     * installed) and the map has not already been instantiated.. This will ensure that we only ever
     * call {@link #setUpMap()} once when {@link #mMap} is not null.
     * <p/>
     * If it isn't installed {@link SupportMapFragment} (and
     * {@link com.google.android.gms.maps.MapView MapView}) will show a prompt for the user to
     * install/update the Google Play services APK on their device.
     * <p/>
     * A user can return to this FragmentActivity after following the prompt and correctly
     * installing/updating/enabling the Google Play services. Since the FragmentActivity may not
     * have been completely destroyed during this process (it is likely that it would only be
     * stopped or paused), {@link #onCreate(Bundle)} may not be called again so we should call this
     * method in {@link #onResume()} to guarantee that it will be called.
     */
    private void setUpMapIfNeeded() {
        // Do a null check to confirm that we have not already instantiated the map.
        if (mMap == null) {
            // Try to obtain the map from the SupportMapFragment.
            mMap = ((SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map))
                    .getMap();
            // Check if we were successful in obtaining the map.
            if (mMap != null) {
                setUpMap();
            }
        }
    }

    /**
     * This is where we can add markers or lines, add listeners or move the camera.
     * <p/>
     * This should only be called once and when we are sure that {@link #mMap} is not null.
     */
    private void setUpMap() {
        LatLng map_center = new LatLng(37, -164);
        mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(map_center, 1));
        /*CameraPosition cameraPosition = CameraPosition.builder()
                .target(map_center)
                .zoom(11)
                .bearing(0)
                .build();
        // Animate the change in camera view over 2 seconds
        map.animateCamera(CameraUpdateFactory.newCameraPosition(cameraPosition),5000, null);*/
    }

    /**
     * Method to make json object request where json response starts with {
     * */
    private void makeJsonObjectRequest() {
        JsonObjectRequest jsonObjReq = new JsonObjectRequest(Method.GET,
                urlJsonObj, null, new Response.Listener<JSONObject>() {
            @Override
            public void onResponse(JSONObject response) {
                Log.v(TAG, response.toString());

                try {
                    // Parsing json object response
                    // response will be a json object

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
                        double dose = properties.getDouble("&microSv/hr");

                        /*jsonResponse = "";
                        jsonResponse += "Name: " + name + "\n\n";
                        jsonResponse += "Latitude, Longitude: " + longitude + ", " + latitude + "\n\n";
                        jsonResponse += "Latest Measurement: " + latest_measurement + "\n\n";
                        jsonResponse += "Latest dose (&microSv/hr): " + dose + "\n\n";*/
                        //jsonResponse += ": " +  + "\n\n";

                        String radiation_info = String.format("%.4f", dose)
                                + " µSv/hr @ " + latest_measurement;
                        mMap.addMarker(new MarkerOptions()
                                .title(name).snippet(radiation_info)
                                .position(new LatLng(longitude, latitude))
                        );

                        //txtResponse.setText(jsonResponse);
                        //Log.v("JSON", jsonResponse);
                    }
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

    private void showpDialog() {
        if (!pDialog.isShowing())
            pDialog.show();
    }

    private void hidepDialog() {
        if (pDialog.isShowing())
            pDialog.dismiss();
    }
}
