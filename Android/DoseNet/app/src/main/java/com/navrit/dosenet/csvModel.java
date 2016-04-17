package com.navrit.dosenet;


import android.util.Log;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.VolleyLog;
import com.android.volley.toolbox.JsonObjectRequest;
import com.navrit.dosenet.app.AppController;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.UUID;

public class csvModel {
    public String url_geojson = "https://radwatch.berkeley.edu/sites/default/files/output.geojson?"
            + UUID.randomUUID().toString().replace("-", "");
    private static String TAG = csvModel.class.getSimpleName();

    public void getCSVs(){
        JsonObjectRequest jsonObjReq = new JsonObjectRequest(Request.Method.GET,
                url_geojson, null, new Response.Listener<JSONObject>() {
            @Override
            public void onResponse(JSONObject response) {
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
                        double dose = properties.getDouble("&microSv/hr");
                        String csv_location = properties.getString("csv_location");
                        String timezone = properties.getString("timezone");


                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                    Log.e(TAG,e.getMessage());
                }
            }
        }, new Response.ErrorListener() {

            @Override
            public void onErrorResponse(VolleyError e) {
                VolleyLog.e(TAG, "Error: " + e.getMessage());
                Log.e(TAG,e.getMessage());
            }
        });

        AppController.getInstance().addToRequestQueue(jsonObjReq);
    }
}
