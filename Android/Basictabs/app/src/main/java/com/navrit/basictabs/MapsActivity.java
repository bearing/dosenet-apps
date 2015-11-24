package com.navrit.basictabs;

import com.navrit.basictabs.app.AppController;

import android.app.ProgressDialog;
import android.support.v4.app.FragmentActivity;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.CameraPosition;
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

import im.delight.android.location.SimpleLocation;
import im.delight.android.location.SimpleLocation.Point;

public class MapsActivity extends FragmentActivity {

    private static String TAG = MapsActivity.class.getSimpleName();
    private GoogleMap mMap; // Might be null if Google Play services APK is not available.
    private ProgressDialog pDialog;
    private String jsonResponse; // temporary string to show the parsed response
    private Point userLocation;
    private double minimumDistance = 20037500; // [m] Half the circumference of the Earth
    public Point closestDosimeter = new Point(51.5072,0.1275); // Initialise on London
    public LatLng closestLatLong = new LatLng(51.5072,0.1275);
    private String closestDosimeterName = "X";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_maps);
        setUpMapIfNeeded();

        pDialog = new ProgressDialog(this);
        pDialog.setMessage("Wait, fool...!");
        pDialog.setCancelable(true);
        // making json object request
        makeJsonObjectRequest();
    }

    @Override
    protected void onResume() {
        super.onResume();
        setUpMapIfNeeded();
    }

    /**
     * Sets up the map if it is possible to do so (i.e., the Google Play services APK is correctly
     * installed) and the map has not already been instantiated.. This will ensure that we only ever
     * call { #setUpMap()} once when {@link #mMap} is not null.
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
                LatLng berkeley = new LatLng(37.87, -122.27);
                setUpMap(berkeley, 8);
            }
        }
    }

    /**
     * This is where we can add markers or lines, add listeners or move the camera.
     * <p/>
     * This should only be called once and when we are sure that {@link #mMap} is not null.
     */
    private void setUpMap(LatLng map_center, int zoom) {
        mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(map_center, zoom));
    }

    /**
     * Method to make json object request where json response starts with '{'
     * */
    private void makeJsonObjectRequest() {
        showpDialog();
        userLocation = getLocation();

        String urlJsonObj = "https://radwatch.berkeley.edu/sites/default/files/output.geojson";
        JsonObjectRequest jsonObjReq = new JsonObjectRequest(Method.GET,
                urlJsonObj, null, new Response.Listener<JSONObject>() {
            @Override
            public void onResponse(JSONObject response) {
                //Log.v(TAG, response.toString());

                try {
                    // Parsing json object response - type json object
                    JSONArray station_array = response.getJSONArray("features");
                    Log.i("Number of dosimeters ", String.valueOf(station_array.length()));
                    for (int i = 0; i < station_array.length(); i++) {
                        JSONObject station = station_array.getJSONObject(i);

                        JSONObject geometry = station
                                .getJSONObject("geometry");
                        JSONArray coordinates = geometry.getJSONArray("coordinates");
                        double longitude = coordinates.getDouble(0);
                        double latitude = coordinates.getDouble(1);

                        JSONObject properties = station
                                .getJSONObject("properties");
                        String name = properties.getString("Name");
                        String latest_measurement = properties.getString("Latest measurement");
                        double dose = properties.getDouble("Latest dose (&microSv/hr)");

                        getClosestDosimeter(latitude, longitude, name);

                        jsonResponse = "";
                        jsonResponse += "Name: " + name + "\n\n";
                        jsonResponse += "Latitude, Longitude: " + latitude + ", " + longitude + "\n\n";
                        jsonResponse += "Latest Measurement: " + latest_measurement + "\n\n";
                        jsonResponse += "Latest dose (&microSv/hr): " + dose + "\n\n";

                        String radiation_info = String.format("%.4f", dose)
                                + " µSv/hr @ " +
                                latest_measurement  + " PDT";
                        mMap.addMarker(new MarkerOptions()
                                        .title(name)
                                        .snippet(radiation_info)
                                        .position(new LatLng(latitude, longitude))
                        );

                        //Log.i("JSON", jsonResponse);
                    }
                    // Set user location pin
                    mMap.addMarker(new MarkerOptions()
                                    .title("You!")
                                    .snippet("Your current rough location")
                                    .position(new LatLng(userLocation.latitude,
                                            userLocation.longitude))
                    );
                    Log.i("DOSIMETR nearest", closestDosimeterName);
                    Toast.makeText(getApplicationContext(),
                            ("Nearest dosimeter: "+closestDosimeterName),
                            Toast.LENGTH_LONG).show();
                    // Centres on nearest dosimeter, non animated transition
                    setUpMap(new LatLng(closestLatLong.latitude, closestLatLong.longitude), 9);
                } catch (JSONException e) {
                    e.printStackTrace();
                    Toast.makeText(getApplicationContext(),
                            "Error: " + e.getMessage(),
                            Toast.LENGTH_LONG).show();
                }
                hidepDialog();
            }
        }, new Response.ErrorListener() {

            @Override
            public void onErrorResponse(VolleyError error) {
                VolleyLog.e(TAG, "Error: " + error.getMessage());
                Toast.makeText(getApplicationContext(),
                        error.getMessage(), Toast.LENGTH_SHORT).show();
                // hide the progress dialog
                hidepDialog();
            }
        });

        // Adding request to request queue
        AppController.getInstance().addToRequestQueue(jsonObjReq);
    }

    public void getClosestDosimeter(double lat, double lon, String dosimeter) {
        Point pnt = new Point(lat, lon);
        double d = SimpleLocation.calculateDistance(userLocation, pnt);
        if (d <= minimumDistance){
            minimumDistance = d;
            closestLatLong = new LatLng(lat,lon);
            closestDosimeterName = dosimeter;
            Log.i("DOSIMETR calc closest", closestDosimeterName);
            Log.i("DOSIMETR LatLng", String.valueOf(closestLatLong));
        }
    }

    private Point getLocation(){
        SimpleLocation location = new SimpleLocation(this);
        // if we can't access the location yet
        if (!location.hasLocationEnabled()) {
            // ask the user to enable location access
            SimpleLocation.openSettings(this);
        }
        final double latitude = location.getLatitude();
        final double longitude = location.getLongitude();
        // stop location updates (saves battery)
        location.endUpdates();
        //Log.i("Latitude, Longitude ", (String.valueOf(latitude))+", "+String.valueOf(longitude));
        Point userPoint = new Point(latitude, longitude);
        return userPoint;
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
