package com.navrit.dosenet;

public class Dosimeter {
    String name;
    String lastTime;
    double lastDose_uSv;
    //double lastDose_mRem;
    //double distance;
    //double lat;
    //double lon;

    // Image for card view

    //List<double> doses_uSv; // For dose over time plots
    //List<String> times;

    Dosimeter(String name, String lastTime, double lastDose_uSv){
        this.name = name;
        this.lastTime = lastTime;
        this.lastDose_uSv = lastDose_uSv;
    }

}
