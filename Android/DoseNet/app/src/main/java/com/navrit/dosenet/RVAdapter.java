package com.navrit.dosenet;

import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import java.util.List;

public class RVAdapter extends RecyclerView.Adapter<RVAdapter.DosimeterViewHolder> {
    public static class DosimeterViewHolder extends RecyclerView.ViewHolder {
        CardView cv;
        TextView dosimeterName;
        TextView dosimeterLastDose;
        TextView dosimeterDoseUnit;
        TextView dosimeterLastTime;

        DosimeterViewHolder(View itemView){
            super(itemView);
            cv = (CardView)itemView.findViewById(R.id.cardview);
            dosimeterName = (TextView)itemView.findViewById(R.id.dosimeter_name);
            dosimeterLastDose = (TextView)itemView.findViewById(R.id.dosimeter_lastDose);
            dosimeterDoseUnit = (TextView)itemView.findViewById(R.id.dosimeter_doseUnit);
            dosimeterLastTime = (TextView)itemView.findViewById(R.id.dosimeter_lastTime);
        }
    }

    List<Dosimeter> dosimeters;

    RVAdapter(List<Dosimeter> dosimeters){
        this.dosimeters = dosimeters;
    }

    @Override
    public void onAttachedToRecyclerView(RecyclerView recyclerView) {
        super.onAttachedToRecyclerView(recyclerView);
    }

    @Override
    public DosimeterViewHolder onCreateViewHolder(ViewGroup viewGroup, int i) {
        View v = LayoutInflater.from(viewGroup.getContext()).inflate(
                R.layout.dosimeter_item, viewGroup, false);
        DosimeterViewHolder pvh = new DosimeterViewHolder(v);
        return pvh;
    }

    @Override
    public void onBindViewHolder(DosimeterViewHolder viewHolder, int i) {
        String lastDose = String.valueOf(dosimeters.get(i).lastDose_uSv);
        viewHolder.dosimeterName.setText(dosimeters.get(i).name);
        viewHolder.dosimeterLastDose.setText(lastDose);
        viewHolder.dosimeterDoseUnit.setText(dosimeters.get(i).unitSelected);
        viewHolder.dosimeterLastTime.setText(dosimeters.get(i).lastTime);
    }

    @Override
    public int getItemCount() {
        return dosimeters.size();
    }
}
