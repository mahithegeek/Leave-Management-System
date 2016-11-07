package com.kofax.lexmarkhub.Utility;


import android.annotation.TargetApi;
import android.app.Activity;

import android.app.DatePickerDialog;
import android.app.DatePickerDialog.OnDateSetListener;
import android.app.Dialog;
import android.app.DialogFragment;
import android.content.DialogInterface;
import android.os.Build;
import android.os.Bundle;
import android.widget.DatePicker;

public class DatePickerDialogFragment extends DialogFragment
{
    public static final String YEAR = "Year";
    public static final String MONTH = "Month";
    public static final String DATE = "Day";
    public static final String TAG = "tag";
    private OnDateSetListener mListener;

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        this.mListener = (OnDateSetListener) activity;
    }

    @Override
    public void onDetach() {
        this.mListener = null;
        super.onDetach();
    }

    @TargetApi(11)
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState)
    {
        Bundle b = getArguments();
        int y = b.getInt(YEAR);
        int m = b.getInt(MONTH);
        int d = b.getInt(DATE);
        final int tag = b.getInt(TAG);

        final DatePickerDialog picker = new DatePickerDialog(getActivity(), getConstructorListener(), y, m, d);

        if (hasJellyBeanAndAbove()) {
            picker.setButton(DialogInterface.BUTTON_POSITIVE,
                    getActivity().getString(android.R.string.ok),
                    new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            DatePicker dp = picker.getDatePicker();
                            dp.setTag(tag);
                            mListener.onDateSet(dp,
                                    dp.getYear(), dp.getMonth(), dp.getDayOfMonth());
                        }
                    });
            picker.setButton(DialogInterface.BUTTON_NEGATIVE,
                    getActivity().getString(android.R.string.cancel),
                    new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {}
                    });
        }
        return picker;
    }

    private static boolean hasJellyBeanAndAbove()
    {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN;
    }

    private OnDateSetListener getConstructorListener() {
        return hasJellyBeanAndAbove() ? null : mListener;
    }
}