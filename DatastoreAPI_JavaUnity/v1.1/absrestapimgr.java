package com.abs.absdsapi;

import android.util.Log;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

/**
 * Class to invoke ABS REST APIs
 * This class implements 'runnable'. The 'run' methods fetch all the telemetry records ('gameplay', 'assessment', 'interactevents') and
 * sync to the ABS backend Server by invoking the ABS REST APIs. All the successfully synced records stored in the local device database
 * are deleted after syncing with the ABS Backend Server.
 * This class is invoked by the 'invokeRESTAPI' method of the absdsandroidapi class
 *
 * @Author: sureshkodoor@gmail.com
 */

public class absrestapimgr implements Runnable {

    private String absrestapiurl;
    private String absapiname;
    private JSONArray jsondata;
    private absdsandroidapi absdsapiobj;

    private boolean debugalerts = false;

    public absrestapimgr(String apibaseurl, String apiname, JSONArray data, absdsandroidapi dsapiobj) {

        absapiname = apiname;
        String baseurl = apibaseurl;
        if((baseurl.charAt(baseurl.length() - 1)) != '/')
            baseurl = baseurl+"/";
        absrestapiurl = baseurl+apiname;

        jsondata = data;
        absdsapiobj = dsapiobj;
    }

    @Override
    public void run() {

        HttpURLConnection apiConnection = null;

        try {
            URL apiurl = new URL(absrestapiurl);

            // Create connection
            apiConnection =  (HttpURLConnection) apiurl.openConnection();
            apiConnection.setRequestProperty("Accept","application/json");
            apiConnection.setRequestMethod("POST");

            // send Data
            apiConnection.setDoOutput(true);
            OutputStream outstream = apiConnection.getOutputStream();
            outstream.write(jsondata.toString().getBytes());
            if(debugalerts) {
                Log.d("ABSDSANDROIDDAPI", "absrestapimgr.run. send data: success. jsondata: " + jsondata.toString());
            }
            // read Response
            InputStream instream = apiConnection.getInputStream();
            InputStreamReader instreamreader = new InputStreamReader(instream,"UTF-8");

            BufferedReader inreader = new BufferedReader(instreamreader);
            StringBuilder sb = new StringBuilder();
            String line = "";
            while((line = inreader.readLine()) != null) {
                sb.append(line);
                break;
            }

            // Close the connection
            inreader.close();
            apiConnection.disconnect();

            // create array of 'Id's of the successfully synced records
            JSONArray arrJsonResp = new JSONArray(sb.toString());
            int resplength = arrJsonResp.length();
            StringBuilder syncedids = new StringBuilder();

            for(int i =0; i < resplength; i++) {

                JSONObject respObj = arrJsonResp.getJSONObject(i);
                if(respObj.getString("status").equals("success")) {
                    syncedids.append(respObj.getString("objid"));
                    if(i < (resplength-1))
                        syncedids.append(",");
                }
            }

            if(debugalerts) {
                Log.d("ABSDSANDROIDDAPI", "absrestapimgr.run: success. Rxd Response. Synced Ids: " + syncedids.toString());
            }

            // Delete the synced records
            deleteSyncedRecords(syncedids.toString());
        }
        catch(Exception e) {
            Log.e("ABSDSANDROIDDAPI","absrestapimgr.run: Exception: "+e.toString());
            if(apiConnection != null)
                apiConnection.disconnect();
        }
    }

    public void deleteSyncedRecords(String ids) {

        switch(absapiname) {

            case "txabsgameplay":
                absdsapiobj.deleteGameplayRecordsByIds(ids);
                break;

            case "txabsgameplaydetail":
                absdsapiobj.deleteAssessmentRecordsByIds(ids);
                break;

            case "txekstepevents":
                absdsapiobj.deleteInteractEventRecordsByIds(ids);
                break;
        }
    }
}
