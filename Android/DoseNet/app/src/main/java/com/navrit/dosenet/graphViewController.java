package com.navrit.dosenet;


import android.util.Log;
import android.widget.Toast;

import com.android.volley.*;
import com.android.volley.toolbox.JsonObjectRequest;
import com.navrit.dosenet.app.AppController;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Date;
import java.util.List;
import java.util.UUID;

final class csvStruct{
    private static String TAG = graphViewController.class.getSimpleName();

    List<Date> times;
    List<Double> doses;

    private int getLength(){
        if (doses.size() == times.size()){
            return doses.size();
        } else {
            Log.e(TAG,": ERROR: Mismatch between Size of doses and times variables.");
            return 0;
        }
    }


}

public class graphViewController {
    private static String TAG = graphViewController.class.getSimpleName();

    public void getCSV(){
        String url_csv = "https://radwatch.berkeley.edu/sites/default/files/dosenet/"
                + getShortName(dosimeter.name) + "?"
                + UUID.randomUUID().toString().replace("-", "");
        JsonObjectRequest jsonObjReq = new JsonObjectRequest(Request.Method.GET,
                url_csv, null, new Response.Listener<JSONObject>() {
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
