package com.navrit.dosenet;

public class Dosimeter {
    String name;
    double lastDose_uSv;
    double lastDose_mRem;
    String unitSelected;
    String lastTime;
    //double distance;
    double lat;
    double lon;

    // Image (seal/crest) for card view

    //List<double> doses_uSv; // For dose over time plots
    //List<String> times;

    public Dosimeter(String name, double lastDose_uSv, String unitSelected, String lastTime){
        this.name = name;
        this.lastDose_uSv = lastDose_uSv;
        this.lastDose_mRem = lastDose_uSv/10;
        this.unitSelected = unitSelected;
        this.lastTime = lastTime;
    }

    public Dosimeter(String name, double lastDose_uSv, String unitSelected, String lastTime,
                     double lon, double lat){
        this.name = name;
        this.lastDose_uSv = lastDose_uSv;
        this.lastDose_mRem = lastDose_uSv/10;
        this.unitSelected = unitSelected;
        this.lastTime = lastTime;
        this.lon = lon;
        this.lat = lat;
    }

}
