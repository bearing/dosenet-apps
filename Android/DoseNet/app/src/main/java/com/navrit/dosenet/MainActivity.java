package com.navrit.dosenet;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.FloatingActionButton;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;

import com.afollestad.materialdialogs.DialogAction;
import com.afollestad.materialdialogs.MaterialDialog;

import java.util.ArrayList;
import java.util.List;

public class MainActivity extends AppCompatActivity implements View.OnClickListener {

    private Toolbar toolbar;
    private RecyclerView rv;
    public FloatingActionButton btn_map;

    private List<Dosimeter> dosimeters;
    public String unit_selected = "usv";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            getWindow().setStatusBarColor(ContextCompat.getColor(this,R.color.colorPrimaryDark));
        }

        setContentView(R.layout.activity_main);

        toolbar = (Toolbar) findViewById(R.id.tool_bar); // Attaching the layout to the toolbar object
        setSupportActionBar(toolbar);                   // Setting toolbar as the ActionBar with setSupportActionBar() call

        // Display icon in the toolbar
        getSupportActionBar().setDisplayShowHomeEnabled(true);
        getSupportActionBar().setLogo(R.mipmap.dosenet_logo);
        getSupportActionBar().setDisplayUseLogoEnabled(true);

        btn_map = (FloatingActionButton) findViewById(R.id.fab);
        btn_map.setOnClickListener(this);

        rv = (RecyclerView)findViewById(R.id.recycler_view);
        LinearLayoutManager llm = new LinearLayoutManager(this);
        rv.setLayoutManager(llm);
        rv.setHasFixedSize(true);

        initializeData();
        initializeAdapter();
    }

    private void initializeData() {
        dosimeters = new ArrayList<>();

        dosimeters.add(new Dosimeter("A name", 0.01, "2016-09-02 04:00"));
        dosimeters.add(new Dosimeter("sdthgw3fpdshg", 0.01, "2016-09-02 04:00"));
        dosimeters.add(new Dosimeter("Koriyama", 0.01, "2016-09-02 04:00"));
        dosimeters.add(new Dosimeter("A name", 0.01, "2016-09-02 04:00"));
        dosimeters.add(new Dosimeter("sdthgw3fpdshg", 0.01, "2016-09-02 04:00"));
        dosimeters.add(new Dosimeter("Koriyama", 0.01, "2016-09-02 04:00"));
        dosimeters.add(new Dosimeter("A name", 0.01, "2016-09-02 04:00"));
        dosimeters.add(new Dosimeter("sdthgw3fpdshg", 0.01, "2016-09-02 04:00"));
        dosimeters.add(new Dosimeter("Koriyama", 0.01, "2016-09-02 04:00"));
    }

    private void initializeAdapter() {
        RVAdapter adapter = new RVAdapter(dosimeters);
        rv.setAdapter(adapter);
    }

    @Override
    public void onClick(View view){
        Intent map_intent = new Intent(this, MapsActivity.class);
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
                                unit_selected = "usv";
                                Log.i("Unit: ", unit_selected);
                            }
                        })
                        .onNegative(new MaterialDialog.SingleButtonCallback() {
                            @Override
                            public void onClick(@NonNull MaterialDialog dialog, @NonNull DialogAction which) {
                                unit_selected = "mrem";
                                Log.i("Unit: ", unit_selected);
                            }
                        })
                        .show();
                return true;

            default:
                return super.onOptionsItemSelected(item);

        }
    }

}
