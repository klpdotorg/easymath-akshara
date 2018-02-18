/**
 * Akshara Backend System (ABS): Android Datastore Java API Library (for Unity based Android game/app)
 * Java APIs to store telemetry data locally on the Android device and to Sync it to the ABS Server using ABS REST APIs.
 * Configuration/Settings required:
 *      Add android.permission.INTERNET in the AndroidManifest.xml file of the app
 *      <uses-permission android:name="android.permission.INTERNET" />
 * Class: absdsandroidapi
 * File: absdsandroidapi.java
 * Package: com.abs.absdsapi
 *
 * @Author: sureshkodoor@gmail.com
 */
package com.abs.absdsapi;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.os.AsyncTask;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.UUID;

public class absdsandroidapi {

    private String absdbname = "absdsunity.db";
    private Context appcontext;
    private SQLiteDatabase absdb = null;
    private String providerCode = "GWL"; // ID for the provider of the app/game. Default is 'GWL' for Good Works Labs
    private  boolean debugalerts = false;
    private  boolean erroralerts = true;

    public void initializeDS(android.content.Context context) {

        appcontext = context;

        try {

            String path = appcontext.getFilesDir().getPath();
            String absdbfilepath = path + "/"+absdbname;

            if(debugalerts)
                Log.d("ABSDSANDRAPI","absdbfilepath: "+absdbfilepath); // Log.d for DEBUG, Log.e for ERROR, Log.i for INFO, Log.w for WARNING

            absdb = SQLiteDatabase.openOrCreateDatabase(absdbfilepath, null, null);

            if(absdb != null) {
                if(debugalerts)
                    Log.d("ABSDSANDRAPI", "ABSDSANDRAPI.initializeDS: openOrCreateDatabase success. ");

                createTables();
            }
            else {
                if(erroralerts)
                    Log.e("ABSDSANDRAPI","ABSDSANDRAPI.initializeDS: openOrCreateDatabase failed. Returned NULL SQLiteDatabase handler");
            }
        }
        catch(Exception e) {
            Log.e("ABSDSANDRAPI","ABSDSANDRAPI.initializeDS: Error: "+e.toString());
        }
    }

    public boolean createTables() {

        // create / open (if already exists) the Tables
        String query_creategameplaytbl = "CREATE TABLE IF NOT EXISTS gameplaytbl ( \n" +
                "id integer primary key autoincrement, \n" +
                "id_game_play text, id_game text, access_token text, \n"+
                "start_time text, synced integer not null default 0)";

        String query_createassessmenttbl = "CREATE TABLE IF NOT EXISTS assessmenttbl ( \n" +
                "id integer primary key autoincrement, \n" +
                "id_game_play text, id_question text, pass text, \n" +
                "time2answer integer, attempts integer, date_time_submission text, \n" +
                "access_token text, synced integer not null default 0)";

        String query_createinteracteventtbl = "CREATE TABLE IF NOT EXISTS interacteventtbl ( \n" +
                "id integer primary key autoincrement,  id_game_play text, \n"+
                "id_question text, date_time_event text, event_type text, \n" +
                "res_id text,  access_token text, synced integer not null default 0)";

        String query_createchildinfotbl = "CREATE TABLE IF NOT EXISTS childinfotbl ( \n" +
                "id integer primary key autoincrement,  name text, \n"+
                "age text, gender text, phone text, grade text, language text, picfilename text, access_token text, isloggedin integer not null default 0)" ;

        if(debugalerts)
            Log.d("ABSDSANDRAPI","Enter ABSDSANDRAPI.createTables");

        try {
            absdb.execSQL(query_creategameplaytbl);
            absdb.execSQL(query_createassessmenttbl);
            absdb.execSQL(query_createinteracteventtbl);
            absdb.execSQL(query_createchildinfotbl);

            if(debugalerts)
                Log.d("ABSDSANDRAPI","createTables: success");
        }
        catch(Exception e) {
            Log.e("ABSDSANDRAPI","createTables: failed. Error: "+e.toString());
        }

        return true;
    }

    public boolean dropTables() {

        // create / open (if already exists) the Tables
        String query_dropgameplaytbl = "DROP TABLE gameplaytbl";
        String query_dropassessmenttbl = "DROP TABLE assessmenttbl";
        String query_dropinteracteventtbl = "DROP TABLE interacteventtbl";
        String query_dropchildinfotbl = "DROP TABLE childinfotbl" ;

        try {
            absdb.execSQL(query_dropgameplaytbl);
            absdb.execSQL(query_dropassessmenttbl);
            absdb.execSQL(query_dropinteracteventtbl);
            absdb.execSQL(query_dropchildinfotbl);

            if(debugalerts)
                Log.d("ABSDSANDRAPI","dropTables: success");
        }
        catch(Exception e) {
            Log.e("ABSDSANDRAPI","dropTables: failed. Error: "+e.toString());
        }

        return true;
    }

    // Save gameplay record. The id_game_play corresponding to the saved gameplay is returned.
    // The returned id_game_play should be passed to 'saveAssessment' and 'saveInteractEvent' functions to save the Assessment and InteractEvent data corresponding to this gameplay.
    //
    // Input parameters:
    // @param id_game - String. Unique Id of the game
    // @param access_token - String. access_token for the logged-in Child
    // @param start_time - String. start_time of the game 'YY:MM:DD:HH:MM:SS' format.
    //
    // Return values:
    // @return id_game_play - String. Unique Id for this gameplay session
    public String saveGameplay(String[] arrData) {

        // Create a unique identifier for id_game_play (A 15 char unique string is generated as the Id).
        // providerCode is added as the prefix

        String randomstr = UUID.randomUUID().toString(); // format 8-4-4-4-12 total 36 chars
        String gameplayid = providerCode+randomstr.substring(14,18)+ randomstr.substring(24,32); // provideCode + substring of 12 chars

        if(debugalerts)
            Log.d("ABSDSANDRAPI","Enter ABSDSANDRAPI.saveGameplay.  gameplayid: "+gameplayid);

        String query = "INSERT INTO gameplaytbl (id_game_play, id_game, access_token, start_time) \n"+
                     " VALUES (?,?,?,?)";

        try {
            absdb.execSQL(query, new String[] {gameplayid,arrData[0],arrData[1],arrData[2]});
            if(debugalerts)
                Log.d("ABSDSANDRAPI","ABSDSANDRAPI.saveGameplay: success  ");
            return gameplayid;
        }
        catch(Exception e) {
                Log.e("ABSDSANDRAPI","ABSDSANDRAPI.saveGame: failed. Error: "+e.toString());
                return null;
        }
    }

    // Save Assessment telemetry (gameplaydetail) records.
    //
    // Input parameters:
    // @param id_game_play - String. Id of the gameplay session this assement telemetry record belongs to (id_game_play returned by the saveGameplay())
    // @param id_question - String. Unique ID of the question/screen
    // @param pass - String. 'Yes' / 'No'. If the Child has answered the question correctly
    // @param time2answer - String. Time taken to answer the question (in number of seconds)
    // @param attempts - String. Number of attempts at the question before submitting the final answer
    // @param date_time_submission - String. Answer submission time in 'YY:MM:DD:HH:MM:SS' format.
    // @param access_token - String. access_token for the logged-in Child
    //
    // Return values:
    // @return status - Boolean. true/false (true for success and false for failure)
    public boolean saveAssessment(String[] arrData) {

        if(debugalerts)
            Log.d("ABSDSANDRAPI","Enter ABSDSANDRAPI.saveAssement");

        String query = "INSERT INTO assessmenttbl ( \n"+
                       "id_game_play, id_question, pass, \n "+
                       "time2answer, attempts, date_time_submission, access_token) \n"+
                       " VALUES (?,?,?,?,?,?,?)";

        try {
            absdb.execSQL(query, new String[] {arrData[0],arrData[1],arrData[2], arrData[3], arrData[4], arrData[5], arrData[6]});
            if(debugalerts)
                Log.d("ABSDSANDRAPI","ABSDSANDRAPI.saveAssessment: success  ");
            return true;
        }
        catch(Exception e) {
            Log.e("ABSDSANDRAPI","ABSDSANDRAPI.saveAssessment: failed. Error: "+e.toString());
            return false;
        }
    }

    // Save Interact Event telemetry records.
    //
    // Input parameters:
    // @param id_game_play - String. Id of the gameplay session this assement telemetry record belongs to
    // @param id_question - String. Unique ID of the question/screen
    // @param date_time_event - String. Time of occurance of the Event in 'YY:MM:DD:HH:MM:SS' format.
    // @param event_type - String. Event Id (e.g TOUCH, DRAG etc)
    // @param res_id - String. Resource Id (e.g DEVICE_BAK_BUTTON)
    // @param access_token - String. access_token for the logged-in Child
    //
    // Return values:
    // @return status - Boolean. true/false (true for success and false for failure)
    public boolean saveInteractEvent(String[] arrData) {

        if(debugalerts)
            Log.d("ABSDSANDRAPI","Enter ABSDSANDRAPI.saveInteractEvent");

        String query = "INSERT INTO interacteventtbl ( \n"+
                "id_game_play, id_question, date_time_event, \n "+
                "event_type, res_id, access_token) \n"+
                " VALUES (?,?,?,?,?,?)";

        try {
            absdb.execSQL(query, new String[] {arrData[0],arrData[1],arrData[2], arrData[3], arrData[4], arrData[5]});
            if(debugalerts)
                Log.d("ABSDSANDRAPI","ABSDSANDRAPI.saveInteractEvent: success  ");
            return true;
        }
        catch(Exception e) {
            Log.e("ABSDSANDRAPI","ABSDSANDRAPI.saveInteractEvent: failed. Error: "+e.toString());
            return false;
        }
    }

    // Fetch unsynced Gameplay telemetry records
    // Input parameters:
    // Return values: JSONArray (array of JSONObject containing unsynced 'gameplay' records)
    // @return JSONArray   [{"objdid":"", "access_token":"","id_game_play":"","id_game":"","start_time":""}, {...},{...}]
    public JSONArray fetchUnsyncedGameplayRecords() {

        String query = "SELECT id AS objid, access_token, id_game_play, id_game, start_time FROM gameplaytbl WHERE synced = 0";
        JSONArray  arrRecords = new JSONArray();

        try {
            Cursor curs = absdb.rawQuery(query, null);

            if(curs.moveToFirst()){
                do {
                    JSONObject record = new JSONObject();

                    int objid = curs.getInt(curs.getColumnIndex("objid"));
                    record.put("objid", objid);
                    String access_token = curs.getString(curs.getColumnIndex("access_token"));
                    record.put("access_token", access_token);
                    String id_game_play = curs.getString(curs.getColumnIndex("id_game_play"));
                    record.put("id_game_play", id_game_play);
                    String id_game = curs.getString(curs.getColumnIndex("id_game"));
                    record.put("id_game",id_game);
                    String start_time = curs.getString(curs.getColumnIndex("start_time"));
                    record.put("start_time", start_time);

                    arrRecords.put(record);
                } while(curs.moveToNext());
            }
            if(debugalerts)
                Log.d("ABSDSANDRAPI","ABSDSANDRAPI.fetchUnsyncedGameplayRecords: success. arrRecords "+arrRecords.toString());
        }
        catch(Exception e) {
            Log.e("ABSDSANDRAPI","ABSDSANDRAPI.fetchUnsyncedGameplayRecords: failed. Error: "+e.toString());
        }

        return arrRecords;
    }

    // Fetch unsynced Assessment telemetry records
    // Input parameters:
    // Return values: JSONArray (array of JSONObject containing unsynced 'assessment' records)
    // @return JSONArray   [{"objdid":"", "id_game_play":"","id_question":"","answer_given":"","time2answer":"","attempts":"","date_time_submission":"","access_token":""}, {...},{...}]
    public JSONArray fetchUnsyncedAssessmentRecords() {

        String query = "SELECT id AS objid, id_game_play, id_question, pass, \n"+
                       "time2answer, attempts, date_time_submission,access_token FROM assessmenttbl WHERE synced = 0";

        JSONArray  arrRecords = new JSONArray();

        try {
            Cursor curs = absdb.rawQuery(query, null);

            if(curs.moveToFirst()){
                do {
                    JSONObject record = new JSONObject();

                    int objid = curs.getInt(curs.getColumnIndex("objid"));
                    record.put("objid", objid);
                    String id_game_play = curs.getString(curs.getColumnIndex("id_game_play"));
                    record.put("id_game_play", id_game_play);
                    String id_question = curs.getString(curs.getColumnIndex("id_question"));
                    record.put("id_question", id_question);
                    String pass = curs.getString(curs.getColumnIndex("pass"));
                    record.put("pass",pass);
                    String time2answer = curs.getString(curs.getColumnIndex("time2answer"));
                    record.put("time2answer", time2answer);
                    String attempts = curs.getString(curs.getColumnIndex("attempts"));
                    record.put("attempts", attempts);
                    String date_time_submission = curs.getString(curs.getColumnIndex("date_time_submission"));
                    record.put("date_time_submission", date_time_submission);
                    String access_token = curs.getString(curs.getColumnIndex("access_token"));
                    record.put("access_token", access_token);

                    arrRecords.put(record);
                } while(curs.moveToNext());
            }
            if(debugalerts)
                Log.d("ABSDSANDRAPI","ABSDSANDRAPI.fetchUnsyncedAssessmentRecords: success. arrRecords "+arrRecords.toString());
        }
        catch(Exception e) {
            Log.e("ABSDSANDRAPI","ABSDSANDRAPI.fetchUnsyncedAssessmentRecords: failed. Error: "+e.toString());
        }

         return arrRecords;
    }

    // Fetch unsynced Interact Event telemetry records
    // Input parameters:
    // Return values: JSONArray (array of JSONObject containing unsynced 'gameplay' records)
    // @return JSONArray   [{"objdid":"", "id_game_play":"","id_question":"","date_time_event":"","edata":{"eks":{"type":"","id":""}},"access_token":""}, {...},{...}]
    public JSONArray fetchUnsyncedInteractEventRecords() {


        String query = "SELECT id AS objid, id_game_play, id_question, date_time_event, \n"+
                       "event_type,res_id,access_token FROM interacteventtbl WHERE synced = 0";

        JSONArray  arrRecords = new JSONArray();

        try {
            Cursor curs = absdb.rawQuery(query, null);

            if(curs.moveToFirst()){
                do {
                    JSONObject record = new JSONObject();

                    record.put("ekstep_eventid","OE_INTERACT");
                    int objid = curs.getInt(curs.getColumnIndex("objid"));
                    record.put("objid", objid);
                    String id_game_play = curs.getString(curs.getColumnIndex("id_game_play"));
                    record.put("id_game_play", id_game_play);
                    String id_question = curs.getString(curs.getColumnIndex("id_question"));
                    record.put("id_question",id_question);
                    String date_time_event = curs.getString(curs.getColumnIndex("date_time_event"));
                    record.put("date_time_event", date_time_event);

                    JSONObject eks = new JSONObject();
                    String event_type = curs.getString(curs.getColumnIndex("event_type"));
                    eks.put("type", event_type);
                    String res_id = curs.getString(curs.getColumnIndex("res_id"));
                    eks.put("id", res_id);

                    JSONObject edata = new JSONObject();
                    edata.put("eks",eks);

                    record.put("edata", edata);

                    String access_token = curs.getString(curs.getColumnIndex("access_token"));
                    record.put("access_token", access_token);

                    arrRecords.put(record);

                } while(curs.moveToNext());
            }
            if(debugalerts)
                Log.d("ABSDSANDRAPI","ABSDSANDRAPI.fetchUnsyncedInteractEventRecords: success. arrRecords "+arrRecords.toString());
        }
        catch(Exception e) {
            Log.e("ABSDSANDRAPI","ABSDSANDRAPI.fetchUnsyncedInteractEventRecords: failed. Error: "+e.toString());
        }

        return arrRecords;
    }

    // Sync the telemetry data to the ABS Server invoking ABS REST APIs
    // Input parameters:
    // Return values:
    public void syncTelemetry(String apibaseurl) {

        // Fetch the saved Unsynced Gameplay records
        JSONArray jsondata_gameplay = fetchUnsyncedGameplayRecords();
        // Invoke the txabsgameplay ABS REST API to sync the telemetry data
        if(jsondata_gameplay.length() > 0)
            invokeRESTAPI(apibaseurl, "txabsgameplay", jsondata_gameplay);

        // Fetch the saved Unsynced Assessment records
        JSONArray jsondata_assessment = fetchUnsyncedAssessmentRecords();
        // Invoke the txgameplaydetail ABS REST API to sync the telemetry data
        if(jsondata_assessment.length() > 0)
            invokeRESTAPI(apibaseurl, "txabsgameplaydetail", jsondata_assessment);

        // Fetch the saved Unsynced Interact Event records
        JSONArray jsondata_interactevent = fetchUnsyncedInteractEventRecords();
        // Invoke the txgameplaydetail ABS REST API to sync the telemetry data
        if(jsondata_interactevent.length() > 0)
            invokeRESTAPI(apibaseurl, "txekstepevents", jsondata_interactevent);
    }

    // Delete all the Gameplay records that are synced successfuly ('Id's of those records are in the list of 'Id's given)
    // Input parameters:
    // @param ids - String[] Array containing 'Ids'
    // Return values:
    public void deleteGameplayRecordsByIds(String ids) {

        String query = "DELETE FROM gameplaytbl WHERE id IN ("+ids+")";

        if(debugalerts)
            Log.d("ABSDSANDRAPI","In ABSDSANDRAPI.deleteSyncedGameplayRecords: query:  "+query);

        try {
            absdb.execSQL(query);
            if(debugalerts)
                Log.d("ABSDSANDRAPI","ABSDSANDRAPI.deleteSyncedGameplayRecords: success  ");
        }
        catch(Exception e) {
            Log.e("ABSDSANDRAPI","ABSDSANDRAPI.deleteSyncedGameplayRecords: failed. Error: "+e.toString());
        }
    }

    // Delete all the Assessment telemetry records that are synced successfuly ('Id's of those records are in the list of 'Id's given)
    // Input parameters:
    // @param ids - String[] Array containing 'Ids'
    // Return values:
    public void deleteAssessmentRecordsByIds(String ids) {

        String query = "DELETE FROM assessmenttbl WHERE id IN ("+ids+")";

        if(debugalerts)
            Log.d("ABSDSANDRAPI","In ABSDSANDRAPI.deleteAssessmentRecordsByIds: query:  "+query);

        try {
            absdb.execSQL(query);
            if(debugalerts)
                Log.d("ABSDSANDRAPI","ABSDSANDRAPI.deleteAssessmentRecordsByIds: success  ");
        }
        catch(Exception e) {
            Log.e("ABSDSANDRAPI","ABSDSANDRAPI.deleteAssessmentRecordsByIds: failed. Error: "+e.toString());
        }
    }

    // Delete all the Interact Event telemetry records that are synced successfuly ('Id's of those records are in the list of 'Id's given)
    // Input parameters:
    // @param ids - String[] Array containing 'Ids'
    // Return values:
    public void deleteInteractEventRecordsByIds(String ids) {

        String query = "DELETE FROM interacteventtbl WHERE id IN ("+ids+")";

        if(debugalerts)
            Log.d("ABSDSANDRAPI","In ABSDSANDRAPI.deleteInteractEventRecordsByIds: query:  "+query);

        try {
            absdb.execSQL(query);
            if(debugalerts)
                Log.d("ABSDSANDRAPI","ABSDSANDRAPI.deleteInteractEventRecordsByIds: success  ");
        }
        catch(Exception e) {
            Log.e("ABSDSANDRAPI","ABSDSANDRAPI.deleteInteractEventRecordsByIds: failed. Error: "+e.toString());
        }
    }


    // Save details of a Child
    //
    // Input parameters:
    // @param name - String. Name of the Child
    // @param age - String. Age of the Child
    // @param gender - String. Gender of the Child ('B' - Boy, 'G' - Girl)
    // @param phone - String. Phone number
    // @param grade - String. Child's grade
    // @param language - String. Language chosen
    // @param picfilename - String. Name of the local file for the Child's picture
    // @param access_token - String. access_token for the logged-in Child
    //
    // Return values:
    public void saveChildinfo(String[] arrData) {

        if(debugalerts)
            Log.d("ABSDSANDRAPI","Enter ABSDSANDRAPI.saveChildinfo");

        String query = "INSERT INTO childinfotbl (name, age, gender, phone, grade, language, picfilename, access_token) \n"+
                " VALUES (?,?,?,?,?,?,?,?)";

        try {
            absdb.execSQL(query, new String[] {arrData[0],arrData[1],arrData[2],arrData[3],arrData[4],arrData[5],arrData[6],arrData[7]});
            if(debugalerts)
                Log.d("ABSDSANDRAPI","ABSDSANDRAPI.saveChildinfo: success  ");
        }
        catch(Exception e) {
            Log.e("ABSDSANDRAPI","ABSDSANDRAPI.saveChildinfo: failed. Error: "+e.toString());
        }
    }

    // Update the details of a Child
    //
    // Input parameters:
    // @param name - String. Name of the Child
    // @param age - String. Age of the Child
    // @param gender - String. Gender of the Child ('B' - Boy, 'G' - Girl)
    // @param phone - String. Phone number
    // @param grade - String. Child's grade
    // @param language - String. Language chosen
    // @param picfilename - String. Name of the local file for the Child's picture
    // @param access_token - String. access_token for the logged-in Child
    //
    // Return values:
    public void updateChildinfo(String[] arrData) {

        if(debugalerts)
            Log.d("ABSDSANDRAPI","Enter ABSDSANDRAPI.updateChildinfo");

        String query = "UPDATE childinfotbl SET name = ?, age = ?, gender = ?, phone = ?, \n"+
                       " grade = ?, language = ?, picfilename = ?, access_token = ? WHERE access_token = ?)";

        try {
            absdb.execSQL(query, new String[] {arrData[0],arrData[1],arrData[2],arrData[3],arrData[4],arrData[5],arrData[6],arrData[7],arrData[7]}); // last arrData[7] is for WHERE condition
            if(debugalerts)
                Log.d("ABSDSANDRAPI","ABSDSANDRAPI.updateChildinfo: success  ");
        }
        catch(Exception e) {
            Log.e("ABSDSANDRAPI","ABSDSANDRAPI.updateChildinfo: failed. Error: "+e.toString());
        }
    }

    // Fetch the details of a Child
    // Input parameters:
    // @param - access_token. String
    // Return values:
    // @param String[]. String array (id, name, age, gender, phone, grade, language, picfilename, access_token)
    public String[] getChildinfo(String access_token) {

        String query = "SELECT * FROM childinfotbl WHERE access_token = '"+access_token+"'";

        String[] childinfo = new String[9];

        try {
            Cursor curs = absdb.rawQuery(query, null);

            if(curs.moveToFirst()){
                do {
                    int id = curs.getInt(curs.getColumnIndex("id"));
                    childinfo[0] = Integer.toString(id);
                    childinfo[1] = curs.getString(curs.getColumnIndex("name"));
                    childinfo[2] = curs.getString(curs.getColumnIndex("age"));
                    childinfo[3] = curs.getString(curs.getColumnIndex("gender"));
                    childinfo[4] = curs.getString(curs.getColumnIndex("phone"));
                    childinfo[5] = curs.getString(curs.getColumnIndex("grade"));
                    childinfo[6] = curs.getString(curs.getColumnIndex("language"));
                    childinfo[7] = curs.getString(curs.getColumnIndex("picfilename"));
                    childinfo[8] = curs.getString(curs.getColumnIndex("access_token"));
                } while(curs.moveToNext());
            }
            if(debugalerts)
                Log.d("ABSDSANDRAPI","ABSDSANDRAPI.getChildinfo: success. childinfo: Id:"+childinfo[0]+" Name: "+childinfo[1]);

            return childinfo;
        }
        catch(Exception e) {
            Log.e("ABSDSANDRAPI","ABSDSANDRAPI.getChildinfo: failed. Error: "+e.toString());
            return null;
        }

    }

    // Fetch the details of all the Children (fetch all the Child records saved locally on the device)
    // Input parameters:
    //
    // Return values: (avoiding using usual java collections like List as this library will be used by UNITY based android games and not sure about UNITY support for complex Java datatypes and constructs
    // @param String[][]. Two dimensional String array with arrays of Childinfo (id, name, age, gender, phone, grade, language, picfilename, access_token)
    public String[][] getAllChildinfo() {

        String query = "SELECT * FROM childinfotbl";

        try {
            Cursor curs = absdb.rawQuery(query, null);
            int totalrecordscount = curs.getCount();

            if(totalrecordscount == 0) {
                if(debugalerts)
                    Log.d("ABSDSANDRAPI","ABSDSANDRAPI.getAllChildinfo: Retrieved 0 records.");
                return null;
            }
            String[][] arrChildinfo = new String[totalrecordscount][9];
            int n = 0;

            if(debugalerts)
                Log.d("ABSDSANDRAPI","getAllChildinfo. totalrecordscount: "+totalrecordscount);

            if(curs.moveToFirst()){
                do {
                    String[] childinfo = new String[9];
                    int id = curs.getInt(curs.getColumnIndex("id"));
                    childinfo[0] = Integer.toString(id);
                    childinfo[1] = curs.getString(curs.getColumnIndex("name"));
                    childinfo[2] = curs.getString(curs.getColumnIndex("age"));
                    childinfo[3] = curs.getString(curs.getColumnIndex("gender"));
                    childinfo[4] = curs.getString(curs.getColumnIndex("phone"));
                    childinfo[5] = curs.getString(curs.getColumnIndex("grade"));
                    childinfo[6] = curs.getString(curs.getColumnIndex("language"));
                    childinfo[7] = curs.getString(curs.getColumnIndex("picfilename"));
                    childinfo[8] = curs.getString(curs.getColumnIndex("access_token"));

                    arrChildinfo[n] = childinfo;
                    n++;
                } while(curs.moveToNext());
            }
            if(debugalerts)
                Log.d("ABSDSANDRAPI","ABSDSANDRAPI.getAllChildinfo: success");
            return arrChildinfo;
        }
        catch(Exception e) {
            Log.e("ABSDSANDRAPI","ABSDSANDRAPI.getAllChildinfo: failed. Error: "+e.toString());
            return null;
        }
    }

    // Delete Child (from the local device database only)
    // Input parameters:
    // @param ids - String - access_token
    // Return values:
    public void deleteChildinfo(String access_token) {

        String query = "DELETE FROM childinfotbl WHERE access_token = '"+access_token+"'";

        if(debugalerts)
            Log.d("ABSDSANDRAPI","In ABSDSANDRAPI.deleteChildinfo: query:  "+query);

        try {
            absdb.execSQL(query);
            if(debugalerts)
                Log.d("ABSDSANDRAPI","ABSDSANDRAPI.deleteChildinfo: success  ");
        }
        catch(Exception e) {
            Log.e("ABSDSANDRAPI","ABSDSANDRAPI.deleteChildinfo: failed. Error: "+e.toString());
        }
    }

    // Set a child as logged-in (set 'isloggedin' = 1 for the Child corresponding to the access_token and set isloggedin = 0 for all other Children)
    // Input parameters:
    // @param access_token - String - access_token corresponding to the logged-in Child
    // Return values:
    //
    public void setActiveChild(String access_token) {

        if(debugalerts)
            Log.d("ABSDSANDRAPI","Enter ABSDSANDRAPI.setActiveChild");

        String query = "UPDATE childinfotbl SET isloggedin = (CASE WHEN access_token = '"+access_token+"' THEN 1 ELSE 0 END)";

        try {
            absdb.execSQL(query);
            if(debugalerts)
                Log.d("ABSDSANDRAPI","ABSDSANDRAPI.setActiveChild: success  ");
        }
        catch(Exception e) {
            Log.e("ABSDSANDRAPI","ABSDSANDRAPI.setActiveChild: failed. Error: "+e.toString());
        }
    }

    // Fetch the details of the currently logged-in child Child (Child record with 'isloggedin' 1)
    // Input parameters:
    // Return values:
    // @param String[]. String array (id, name, age, gender, phone, grade, language, picfilename, access_token)
    public String[] getActiveChild() {

        String query = "SELECT * FROM childinfotbl WHERE isloggedin = 1";

        String[] childinfo = new String[9];

        try {
            Cursor curs = absdb.rawQuery(query, null);

            if(curs.moveToFirst()){
                do {

                    int id = curs.getInt(curs.getColumnIndex("id"));
                    childinfo[0] = Integer.toString(id);
                    childinfo[1] = curs.getString(curs.getColumnIndex("name"));
                    childinfo[2] = curs.getString(curs.getColumnIndex("age"));
                    childinfo[3] = curs.getString(curs.getColumnIndex("gender"));
                    childinfo[4] = curs.getString(curs.getColumnIndex("phone"));
                    childinfo[5] = curs.getString(curs.getColumnIndex("grade"));
                    childinfo[6] = curs.getString(curs.getColumnIndex("language"));
                    childinfo[7] = curs.getString(curs.getColumnIndex("picfilename"));
                    childinfo[8] = curs.getString(curs.getColumnIndex("access_token"));
                } while(curs.moveToNext());

            }
            if(debugalerts)
                Log.d("ABSDSANDRAPI","ABSDSANDRAPI.getActiveChild: success. name: "+childinfo[1]);

            return childinfo;
        }
        catch(Exception e) {
            Log.e("ABSDSANDRAPI","ABSDSANDRAPI.getChildinfo: failed. Error: "+e.toString());
            return null;
        }

    }

    // Set the provider code (this 3-char code is used as the prefix for the unique id_game_play)
    // Input parameters:
    // @param providercode - String (3-char code identifying the provider of the app/game (e.g. 'GWL', 'CLS')
    // Return values:
    public void setProviderCode(String providercode) {

        providerCode = providercode;
        if(providerCode.length() > 3)
            providerCode = providerCode.substring(0,2);

    }

    // Invoke the ABS REST API
    // Input parameters:
    // @param apibaseurl  - String - Base URL for the REST API (e.g http://www.kodvin.com/abs/)
    // @param apiname - String (name of the api. e.g txabsgameplay
    // @param jsondata - JSONArray - array of JSONObjects
    // Return values:
    public void invokeRESTAPI(String apibaseurl, String apiname, JSONArray jsondata) {

        AsyncTask.execute(new absrestapimgr(apibaseurl,apiname,jsondata,this));
    }
}

