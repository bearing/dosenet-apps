package com.navrit.DoseNet;

import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.navrit.DoseNet.app.AppController;

import android.app.ProgressDialog;
import android.content.Context;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.support.v4.app.FragmentActivity;
import android.os.Bundle;
import android.util.Log;
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

import im.delight.android.location.SimpleLocation;
import im.delight.android.location.SimpleLocation.Point;

public class MapsActivity extends FragmentActivity implements LocationListener{

    ////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////// Global variables /////////////////////////////////////////
    private static String TAG = MapsActivity.class.getSimpleName();
    private GoogleMap mMap; // Might be null if Google Play services APK is not available.
    private ProgressDialog pDialog;
    private Point userLocation;
    private double minimumDistance = 20037500; // [m] Half the circumference of the Earth
    public LatLng closest = new LatLng(51.5072,0.1275);
    private String closestDosimeterName = "X";
    protected LocationManager locationManager;
    static double u_Lat;
    static double u_Lng;
    private boolean first = true;
    ////////////////////////////////////////////////////////////////////////////////////////////////

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_maps);

        setUpMapIfNeeded();

        makepDialog();

        locationManager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
        locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 0, 0, this);
        userLocation = getLocation();

        getParsePlotJSON(); //Main program logic
    }

    @Override
    protected void onResume() {
        super.onResume();
        setUpMapIfNeeded();
    }

    private void makepDialog(){
        pDialog = new ProgressDialog(this);
        pDialog.setMessage("Wait, fool...!");
        pDialog.setCancelable(true);
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
                mMap.setMyLocationEnabled(true);
                mMap.getUiSettings().setMyLocationButtonEnabled(true);
                mMap.getUiSettings().setCompassEnabled(false);
                mMap.getUiSettings().setRotateGesturesEnabled(false);
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
    private void getParsePlotJSON() {
        showpDialog();

        String urlJsonObj = "https://radwatch.berkeley.edu/sites/default/files/output.geojson";
        JsonObjectRequest jsonObjReq = new JsonObjectRequest(Method.GET,
                urlJsonObj, null, new Response.Listener<JSONObject>() {
            @Override
            public void onResponse(JSONObject response) {
                Log.v(TAG, response.toString());

                try {
                    // Parsing json object response - type json object
                    JSONArray station_array = response.getJSONArray("features");
                    Log.i("Number of dosimeters ", String.valueOf(station_array.length()));

                    for (int i = 0; i < station_array.length(); i++) {

                        JSONObject station = station_array.getJSONObject(i);
                        JSONObject geometry = station.getJSONObject("geometry");
                        JSONArray coordinates = geometry.getJSONArray("coordinates");
                        double longitude = coordinates.getDouble(0);
                        double latitude = coordinates.getDouble(1);
                        JSONObject properties = station.getJSONObject("properties");
                        String name = properties.getString("Name");
                        String latest_measurement = properties.getString("Latest measurement");
                        double dose = properties.getDouble("Latest dose (&microSv/hr)");

                        Log.i("NAME ", name);

                        /*jsonResponse = "";
                        jsonResponse += "Name: " + name + "\n\n";
                        jsonResponse += "Latitude, Longitude: " + latitude + ", " +
                                longitude + "\n\n";
                        jsonResponse += "Latest Measurement: " + latest_measurement + "\n\n";
                        jsonResponse += "Latest dose (&microSv/hr): " + dose + "\n\n";*/

                        String radiation_info = String.format("%.4f", dose)
                                + " µSv/hr @ " + latest_measurement  + " PDT";
                        mMap.addMarker(new MarkerOptions()
                                        .title(name)
                                        .snippet(radiation_info)
                                        .position(new LatLng(latitude, longitude))
                        );

                        getClosestDosimeter(latitude, longitude, name);
                        //mClusterManager.addItem(new Dosimeter(latitude, longitude, name, radiation_info));
                        //Log.i("JSON", jsonResponse);
                    }
                    Log.i("DOSIMETR nearest", closestDosimeterName);
                    Toast.makeText(getApplicationContext(),
                            ("Nearest dosimeter (of " + String.valueOf(station_array.length())
                                    + "): " + closestDosimeterName),
                            Toast.LENGTH_LONG).show();
                    // Centres on nearest dosimeter, non animated transition
                    setUpMap(new LatLng(closest.latitude, closest.longitude), 9);

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
                hidepDialog();
            }
        });

        // Adding request to request queue
        AppController.getInstance().addToRequestQueue(jsonObjReq);
    }

    private Point getLocation() {
        SimpleLocation s_location = new SimpleLocation(this);
        // if we can't access the location yet
        if (!s_location.hasLocationEnabled()) {
            // ask the user to enable location access
            SimpleLocation.openSettings(this);
        }
        final double latitude = s_location.getLatitude();
        final double longitude = s_location.getLongitude();
        // stop location updates (saves battery)
        s_location.endUpdates();
        //Log.i("Latitude, Longitude ", (String.valueOf(latitude))+", "+String.valueOf(longitude));
        return new Point(latitude, longitude);
    }

    public void getClosestDosimeter(double lat, double lon, String dosimeter) {
        Point pnt = new Point(lat, lon);
        double d = SimpleLocation.calculateDistance(userLocation, pnt);
        if (d <= minimumDistance){
            minimumDistance = d;
            closest = new LatLng(lat,lon);
            closestDosimeterName = dosimeter;
            String msg = closestDosimeterName + d;
            Log.i("DOSIMETR calc closest", msg);
            Log.i("DOSIMETR LatLng", String.valueOf(closest));
        }
    }

    @Override
    public void onLocationChanged(Location location) {
        if (first) {
            String msg = "Latitude:" + location.getLatitude() + ", Longitude:" + location.getLongitude();
            Log.i("Location changed", msg);

            u_Lat = location.getLatitude();
            u_Lng = location.getLongitude();

            // Set user location pin
            mMap.addMarker(new MarkerOptions()
                    .title("You!")
                    .snippet("Your current rough location")
                    .position(new LatLng(u_Lat, u_Lng))
                    .icon(BitmapDescriptorFactory.
                            defaultMarker(BitmapDescriptorFactory.HUE_AZURE)));
            first = false;
        }
    }

    @Override
    public void onStatusChanged(String provider, int status, Bundle extras) {
        Log.d("Latitude", "status");
    }

    @Override
    public void onProviderEnabled(String provider) {
        Log.d("Latitude","enable");
    }

    @Override
    public void onProviderDisabled(String provider) {
        Log.d("Latitude","disable");
    }

    private void showpDialog() {
        if (!pDialog.isShowing())
            pDialog.show();
    }

    // hide the progress dialog
    private void hidepDialog() {
        if (pDialog.isShowing())
            pDialog.dismiss();
    }
}
