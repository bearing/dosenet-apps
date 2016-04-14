package com.navrit.dosenet;

public class Dosimeter {
    String name;
    double lastDose_uSv;
    String lastTime;
    //double lastDose_mRem;
    //double distance;
    //double lat;
    //double lon;

    // Image for card view

    //List<double> doses_uSv; // For dose over time plots
    //List<String> times;

    Dosimeter(String name, double lastDose_uSv, String lastTime){
        this.name = name;
        this.lastDose_uSv = lastDose_uSv;
        this.lastTime = lastTime;
    }

}
