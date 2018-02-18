/*
 * File: absdsjsapilib.js
 * Version: 1.4
 * Release date: 18-Feb-2018
 * Akshara Backend System (ABS): Android Datastore API Library for Cordova based Android apps.
 * Javascript APIs to store telemetry data locally on the Android device and to Sync it to the ABS Server using ABS REST APIs.
 * Pre-requisite:
 *    Plug-ins/Libraries: corodova-sqlite-strage plugin, jquery library (jquery-1.8.0.min.js, jquery.mobile-1.4.5.min.js)
 *    Settings: Add absrestapi_baseurl to the 'Content-Security-Policy' in the invoking HTML file
 *              Allow access to the absrestapi_baseurl in the cordova project config.xml
 * Author: sureshkodoor@gmail.com
 */
var absdsjsapi = {

    databasename: "absjsdb.db",
    providercode: "CAL",  // 3-char ID for the provider of the app/game. (e.g 'CAL' for Callystro)
    absdbhandler: null,
    debugalerts: false,
    erroralerts: true,

    // Create/Open the database
    initializeDS: function () {

        if (this.debugalerts)
            alert("ABSJSAPI: Enter initialiseDS");

        this.absdbhandler = window.sqlitePlugin.openDatabase(
            {
                name: this.databasename, location: 'default'
            },
            function () {
                if (this.debugalerts)
                    alert("ABSJSAPI: initialiseDS: openDatabase success");
            },
            function (msg) {
                if (this.erroralerts)
                    alert("ABSJSAPI: initialiseDS: openDatabase failed: " + msg);
                return false;
            }
        );

        // Creates/Opens the Tables
        this.createTables();

        if (this.debugalerts)
            alert("ABSJSAPI: Exit initialiseDS");

        return true;
    },

    deleteDS: function () {

        if (this.debugalerts)
            alert("ABSJSAPI: Enter deleteDS");

        this.absdbhandler = window.sqlitePlugin.deleteDatabase(
            {
                name: this.databasename, location: 'default'
            },
            function () {
                if (this.debugalerts)
                    alert("ABSJSAPI: deleteDS: success");
            },
            function (msg) {
                if (this.erroralerts)
                    alert("ABSJSAPI: deleteDS: failed: " + msg);
                return false;
            }
        );

        if (this.debugalerts)
            alert("ABSJSAPI: Exit deleteDS");
    },

    // Create the tables
    createTables: function () {

        if (this.debugalerts)
            alert("ABSJSAPI: Enter createTables");

        this.absdbhandler.sqlBatch([
            'CREATE TABLE IF NOT EXISTS gameplaytbl (id integer primary key autoincrement, id_game_play text, id_game text, access_token text, start_time text, synced integer not null default 0)',
            'CREATE TABLE IF NOT EXISTS assessmenttbl (id integer primary key autoincrement, id_game_play text, id_question text, pass text, time2answer integer, attempts integer, date_time_submission text, access_token text, synced integer not null default 0)',
            'CREATE TABLE IF NOT EXISTS interacteventtbl (id integer primary key autoincrement,  id_game_play text,  id_question text, date_time_event text, event_type text, res_id text,  access_token text, synced integer not null default 0)'
            ],
            function () {
                if (this.debugalerts)
                    alert("ABSJSAPI: createTables: success");
            },
            function (error) {
                if (this.erroralerts)
                    alert("ABSJSAPI: createTables: failed" + error.message);
                return false;
            }
        );

        if (this.debugalerts)
            alert("ABSJSAPI: Exit createTables");

        return true;
    },

    dropTables: function () {

        if (this.debugalerts)
            alert("ABSJSAPI: Enter dropTables");

        this.absdbhandler.sqlBatch([
            'DROP TABLE IF EXISTS gameplaytbl',
            'DROP TABLE IF EXISTS assessmenttbl',
            'DROP TABLE IF EXISTS interacteventtbl'
            ],
            function () {
                if (this.debugalerts)
                    alert("ABSJSAPI: dropTables: success");
            },
            function (error) {
                if (this.erroralerts)
                    alert("ABSJSAPI: dropTables: failed" + error.message);
                return false;
            }
        );

        if (this.debugalerts)
            alert("ABSJSAPI: Exit dropTables");

        return true;
    },

    // Save gameplay record. The id_game_play corresponding to the saved gameplay is returned.
    // The returned id_game_play should be passed to 'saveAssessment' and 'saveInteractEvent' functions to save the Assessment and InteractEvent data corresponding to this gameplay. 
    saveGameplay: function (objData) {


        if((objData.id_game == "") || (objData.access_token == "") || (objData.start_time == "")) {

        	if (this.erroralerts) {
                alert("ABSJSAPI: ERROR: saveGameplay: values for one or more input parameters are missing.");
                if(objData.id_game == "")  alert("ABSJSAPI: saveGameplay: id_game is null");
                else if(objData.access_token == "")  alert("ABSJSAPI: saveGameplay: access_token is null");
                else if(objData.start_time == "")  alert("ABSJSAPI: saveGameplay: start_time is null");
                else;
            } 

            return false;
        }

        if (this.debugalerts)
            alert("ABSJSAPI: Enter saveGameplay. objData: " + objData.id_game+", "+objData.access_token+", "+objData.start_time);


        var gameplayid = this.createGameplayId();

        var query = "INSERT INTO gameplaytbl (id_game_play, id_game, access_token, start_time) VALUES (?,?,?,?)";
        
        this.absdbhandler.executeSql(query, [gameplayid, objData.id_game, objData.access_token, objData.start_time],
            function (rs) {
                if (this.debugalerts) {
                    alert("ABSJSAPI: saveGameplay: success. id_game_play: " + gameplayid);
                    alert("ABSJSAPI: resultSet.insertId: " + rs.insertId);
                    alert("ABSJSAPI: resultSet.rowsAffected: " + rs.rowsAffected);
                }
                // return gameplayid; // IMPORTANT NOTE: This 'return' statement here WILL NOT WORK. SQLlite functions are executed asynchronously. 
                                      // i.e This JS function will spawn executeSql function in a seperate thread and will continue executing the 
                                      // remaining part of the function. So, saveGamePlayRecord function will return before the executeSql is 
                                      // complete (the SQLite function will run in background). Hence returning gameplayid at this point will not work. 
                                      // The calling function will get null value. So, the 'return gameplayid' is placed outside the SQLite function call.
            },
            function (error) {
                if (this.erroralerts)
                    alert("ABSJSAPI: saveGameplay: failed" + error.message);
                return false;
            }
        );

        if (this.debugalerts)
            alert("ABSJSAPI: Exit saveGameplay");
        return gameplayid;
    },

    // Create a unique identifier for id_game_play (A 15 char unique string is generated as the Id). 'providercode' prefix is to identify the provider of the app
    createGameplayId: function () {

        return this.providercode+Math.random().toString(36).substr(5, 12); // substring of 12 chars (12 chars of the original string, starting from the 5th char)
    },

    // Fetch the gameplay data for syncing (read all the unsynced gameplay records).
    //
    // IMPORTANT NOTE: The SQLite function is executed asynchronously and hence the JS function will exit before the SQLite function is completed.
    // Hence, the recrods fetched cannot be returned from the JS function as a return value. Instead, a callback function should be provided to the
    // JS function, which will be invoked when the SQLite function is completed. 
    //
    // fetchUnsyncedGameplayRecords_cbf is the callback function, which will be invoked once the SQLite function completes its execution

    fetchUnsyncedGameplayRecords: function (callbackfn) {

        if (this.debugalerts)
            alert("ABSJSAPI: Enter fetchUnsyncedGameplayRecords");

        var query = "SELECT id AS objid, access_token, id_game_play, id_game, start_time FROM gameplaytbl WHERE synced = 0";

        var arrObjs = new Array();

        this.absdbhandler.executeSql(query, [],
            function (rs) {
                var nrecords = rs.rows.length;
                if (this.debugalerts)
                   alert("ABSJSAPI: fetchUnsyncedGameplayRecords: success. Number of records:"+nrecords);
                
                for (var i = 0; i < nrecords; i++) {
                    arrObjs.push(rs.rows.item(i));
                }
                if (this.debugalerts)
                    alert("ABSJSAPI: fetchUnsyncedGameplayRecords: arrObjs: " + JSON.stringify(arrObjs));

                callbackfn(arrObjs); // Invoke the callback function to send the array of Objects with the fetched records
            },
            function (error) {
                if (this.erroralerts)
                    alert("ABSJSAPI: fetchUnsyncedGameplayRecords: failed" + error.message);
                return false;
            }
        );

        if (this.debugalerts)
            alert("ABSJSAPI: Exit fetchUnsyncedGameplayRecords");

    },

    // callback function for fetchUnsyncedGameplayRecords
    fetchUnsyncedGameplayRecords_cbf: function (arrRecords) {

        if(this.debugalerts)
            alert("ABSJSAPI: Enter fetchUnsyncedGameplayRecords_cbf");
        // alert("fetchUnsyncedGameplayRecords_cbf: arrRecords: " + JSON.stringify(arrRecords));

        // Do all the Processing, REST API calls etc here
        if(arrRecords.length > 0)
            RESTAPImgr.invokeRESTAPI('txabsgameplay', arrRecords);
    },

    // mark all the records that have 'id' values specified in the 'ids' array as synced (set 'synced' field to 1.)
    markSyncedGameplayRecords: function (ids) {

        var query = "UPDATE gameplaytbl SET synced = 1 WHERE id IN (" + ids +")";

        if (this.debugalerts)
            alert("ABSJSAPI: Enter markSyncedGameplayRecords. ids:" + ids + "  query: "+query);

        if ((ids.length == 0) || (ids == '')) {
            if (this.debugalerts)
                alert("ABSJSAPI: Empty list of 'id's. No action performed.");
            return true;
        }
        this.absdbhandler.executeSql(query, [],
            function (rs) {
                if (this.debugalerts) 
                    alert("ABSJSAPI: markSyncedGameplayRecords: success. resultSet.rowsAffected:" + rs.rowsAffected);
            },
            function (error) {
                if (this.erroralerts) 
                    alert("ABSJSAPI: markSyncedGameplayRecords: failed" + error.message);
                return false;
            }
        );

        if (this.debugalerts) 
            alert("ABSJSAPI: Exit markSyncedGameplayRecords");
    },

    // delete all the records that have 'synced' field as 1
    deleteSyncedGameplayRecords: function () {

        if (this.debugalerts) 
            alert("ABSJSAPI: Enter deleteSyncedGameplayRecords");

        var query = "DELETE FROM gameplaytbl WHERE synced = 1";

        this.absdbhandler.executeSql(query, [],
            function (rs) {
                if (this.debugalerts) 
                    alert("ABSJSAPI: deleteSyncedGameplayRecords: success. resultSet.rowsAffected: " + rs.rowsAffected);
            },
            function (error) {
                if (this.erroralerts)
                    alert("ABSJSAPI: deleteSyncedGameplayRecords: failed" + error.message);
                return false;
            }
        );

        if (this.debugalerts) 
            alert("ABSJSAPI: Exit deleteSyncedGameplayRecords");
    },

    // delete all the records that have 'id' values specified in the 'ids' array as synced. 
    // This function can be used to delete records directly instead of a two-step process of marking as synced and then deleting separately 
    deleteGameplayRecordsByIds: function (ids) {

        if (this.debugalerts)
            alert("ABSJSAPI: Enter deleteGameplayRecordsByIds");

        var query = "DELETE FROM gameplaytbl WHERE id IN (" + ids + ")";

        this.absdbhandler.executeSql(query, [],
            function (rs) {
                if (this.debugalerts)
                    alert("ABSJSAPI: deleteGameplayRecordsByIds: success. resultSet.rowsAffected: " + rs.rowsAffected);
            },
            function (error) {
                if (this.erroralerts)
                    alert("ABSJSAPI: deleteGameplayRecordsByIds: failed" + error.message);
                return false;
            }
        );

        if (this.debugalerts)
            alert("ABSJSAPI: Exit deleteGameplayRecordsByIds");
    },

    // delete all the Gameplay records 
    deleteAllGameplayRecords: function () {

        if (this.debugalerts)
            alert("ABSJSAPI: Enter deleteAllGameplayRecords");

        var query = "DELETE * FROM gameplaytbl";

        this.absdbhandler.executeSql(query, [],
            function (rs) {
                if (this.debugalerts)
                    alert("ABSJSAPI: deleteAllGameplayRecords: success. resultSet.rowsAffected: " + rs.rowsAffected);
            },
            function (error) {
                if (this.erroralerts)
                    alert("ABSJSAPI: deleteAllGameplayRecords: failed" + error.message);
                return false;
            }
        );

        if (this.debugalerts)
            alert("ABSJSAPI: Exit deleteAllGameplayRecords");
    },


    // Save assessment record. 
    saveAssessment: function (objData) {


        if((objData.id_game_play == "") || (objData.id_question == "") || (objData.pass == "") || (objData.time2answer == "") || (objData.attempts == "") || (objData.date_time_submission == "") || (objData.access_token == "")) {

        	if (this.erroralerts) {
                alert("ABSJSAPI: ERROR: saveAssessment: values for one or more input parameters are missing.");
                if(objData.id_game_play == "")  alert("ABSJSAPI: saveAssessment: id_game_play is null");
                else if(objData.id_question == "")  alert("ABSJSAPI: saveAssessment: id_question is null");
                else if(objData.pass == "")  alert("ABSJSAPI: saveAssessment: pass is null");
                else if(objData.time2answer == "")  alert("ABSJSAPI: saveAssessment: time2answer is null");
                else if(objData.attempts == "")  alert("ABSJSAPI: saveAssessment: attempts is null");
                else if(objData.date_time_submission == "")  alert("ABSJSAPI: saveAssessment: date_time_submission is null");
                else if(objData.access_token == "")  alert("ABSJSAPI: saveAssessment: access_token is null");
                else;
            } 

            return false;
        }

        if (this.debugalerts)
            alert("ABSJSAPI: Enter saveAssessment. objData: " + objData.id_game_play + ", " + objData.id_question + ", " + objData.pass + ", " + objData.time2answer + ", " + objData.attempts + ", " + objData.date_time_submission + ", " + objData.access_token);


        var query = "INSERT INTO assessmenttbl (id_game_play, id_question, pass, time2answer, attempts, date_time_submission, access_token) VALUES (?,?,?,?,?,?,?)";

        this.absdbhandler.executeSql(query, [objData.id_game_play, objData.id_question, objData.pass, objData.time2answer, objData.attempts, objData.date_time_submission, objData.access_token],
            function (rs) {
                if (this.debugalerts) {
                    alert("ABSJSAPI: saveAssessment: success");
                    alert("ABSJSAPI: resultSet.insertId: " + rs.insertId);
                    alert("ABSJSAPI: resultSet.rowsAffected: " + rs.rowsAffected);
                }
            },
            function (error) {
                if (this.erroralerts)
                    alert("ABSJSAPI: saveAssessment: failed" + error.message);
                return false;
            }
        );

        if (this.debugalerts)
            alert("ABSJSAPI: Exit saveAssessment");
    },

    // Fetch the assessment data for syncing (read all the unsynced assessment records).
    //
    // IMPORTANT NOTE: The SQLite function is executed asynchronously and hence the JS function will exit before the SQLite function is completed.
    // Hence, the recrods fetched cannot be returned from the JS function as a return value. Instead, a callback function should be provided to the
    // JS function, which will be invoked when the SQLite function is completed. 
    //
    // fetchUnsyncedAssessmentRecords_cbf is the callback function, which will be invoked once the SQLite function completes its execution
    //

    fetchUnsyncedAssessmentRecords: function (callbackfn) {

        if (this.debugalerts)
            alert("ABSJSAPI: Enter fetchUnsyncedAssessmentRecords");

        var query = "SELECT id AS objid, access_token, id_game_play, id_question, pass, time2answer, attempts, date_time_submission FROM assessmenttbl WHERE synced = 0";

        var arrObjs = new Array();

        this.absdbhandler.executeSql(query, [],
            function (rs) {
                var nrecords = rs.rows.length;
                if (this.debugalerts)
                    alert("ABSJSAPI: fetchUnsyncedAssessmentRecords: success. Number of records:" + nrecords);

                for (var i = 0; i < nrecords; i++) {
                    arrObjs.push(rs.rows.item(i));
                }
                if (this.debugalerts)
                    alert("ABSJSAPI: arrObjs: " + JSON.stringify(arrObjs));

                callbackfn(arrObjs); // Invoke the callback function to send the array of Objects with the fetched records
            },
            function (error) {
                if (this.erroralerts)
                    alert("ABSJSAPI: fetchUnsyncedAssessmentRecords: failed" + error.message);
                return false;
            }
        );

        if (this.debugalerts)
            alert("ABSJSAPI: Exit fetchUnsyncedAssessmentRecords");

    },

    // callback function for fetchUnsyncedAssessmentRecords
    fetchUnsyncedAssessmentRecords_cbf: function (arrRecords) {

        if (this.debugalerts)
            alert("ABSJSAPI: Enter fetchUnsyncedAssessmentRecords_cbf");
        // alert("fetchUnsyncedAssessmentRecords_cbf: arrRecords: " + JSON.stringify(arrRecords));

        // Do all the Processing, REST API calls etc here
        if (arrRecords.length > 0)
            RESTAPImgr.invokeRESTAPI('txabsgameplaydetail', arrRecords);
    },

    // mark all the records that have 'id' values specified in the 'ids' array as synced (set 'synced' field to 1.)
    markSyncedAssessmentRecords: function (ids) {

        var query = "UPDATE assessmenttbl SET synced = 1 WHERE id IN (" + ids + ")";

        if (this.debugalerts)
            alert("ABSJSAPI: Enter markSyncedAssessmentRecords. ids:" + ids + "  query: " + query);

        if ((ids.length == 0) || (ids == '')) {
            if (this.debugalerts)
                alert("ABSJSAPI: Empty list of 'id's. No action performed.");
            return true;
        }
        this.absdbhandler.executeSql(query, [],
            function (rs) {
                if (this.debugalerts)
                    alert("ABSJSAPI: markSyncedAssessmentRecords: success. resultSet.rowsAffected:" + rs.rowsAffected);
            },
            function (error) {
                if (this.erroralerts)
                    alert("ABSJSAPI: markSyncedAssessmentRecords: failed" + error.message);
                return false;
            }
        );

        if (this.debugalerts)
            alert("ABSJSAPI: Exit markSyncedAssessmentRecords");
    },

    // delete all the records that have 'synced' field as 1
    deleteSyncedAssessmentRecords: function () {

        if (this.debugalerts)
            alert("ABSJSAPI: Enter deleteSyncedAssessmentRecords");

        var query = "DELETE FROM assessmenttbl WHERE synced = 1";

        this.absdbhandler.executeSql(query, [],
            function (rs) {
                if (this.debugalerts)
                    alert("ABSJSAPI: deleteSyncedAssessmentRecords: success. resultSet.rowsAffected: " + rs.rowsAffected);
            },
            function (error) {
                if (this.erroralerts)
                    alert("ABSJSAPI: deleteSyncedAssessmentRecords: failed" + error.message);
                return false;
            }
        );

        if (this.debugalerts)
            alert("ABSJSAPI: Exit deleteSyncedAssessmentRecords");
    },

    // delete all the records that have 'id' values specified in the 'ids' array as synced. 
    // This function can be used to delete records directly instead of a two-step process of marking as synced and then deleting separately 
    deleteAssessmentRecordsByIds: function (ids) {

        if (this.debugalerts)
            alert("ABSJSAPI: Enter deleteAssessmentRecordsByIds");

        var query = "DELETE FROM assessmenttbl WHERE id IN (" + ids + ")";

        this.absdbhandler.executeSql(query, [],
            function (rs) {
                if (this.debugalerts)
                    alert("ABSJSAPI: deleteAssessmentRecordsByIds: success. resultSet.rowsAffected: " + rs.rowsAffected);
            },
            function (error) {
                if (this.erroralerts)
                    alert("ABSJSAPI: deleteAssessmentRecordsByIds: failed" + error.message);
                return false;
            }
        );

        if (this.debugalerts)
            alert("ABSJSAPI: Exit deleteAssessmentRecordsByIds");
    },

    // delete all the Assessment records
    deleteAllAssessmentRecords: function () {

        if (this.debugalerts)
            alert("ABSJSAPI: Enter deleteAllAssessmentRecords");

        var query = "DELETE * FROM assessmenttbl";

        this.absdbhandler.executeSql(query, [],
            function (rs) {
                if (this.debugalerts)
                    alert("ABSJSAPI: deleteAllAssessmentRecords: success. resultSet.rowsAffected: " + rs.rowsAffected);
            },
            function (error) {
                if (this.erroralerts)
                    alert("ABSJSAPI: deleteAllAssessmentRecords: failed" + error.message);
                return false;
            }
        );

        if (this.debugalerts)
            alert("ABSJSAPI: Exit deleteAllAssessmentRecords");
    },

    // Save Interact Event record. 
    saveInteractEvent: function (objData) {

        if((objData.id_game_play == "") || (objData.id_question == "") || (objData.date_time_event == "") || (objData.event_type == "") || (objData.res_id == "") || (objData.access_token == "")) {
        	if (this.erroralerts) {
                alert("ABSJSAPI: ERROR: saveInteractEvent: values for one or more input parameters are missing.");
                if(objData.id_game_play == "")  alert("ABSJSAPI: saveInteractEvent: id_game_play is null");
                else if(objData.id_question == "")  alert("ABSJSAPI: saveInteractEvent: id_question is null");
                else if(objData.date_time_event == "")  alert("ABSJSAPI: saveInteractEvent: date_time_event is null");
                else if(objData.event_type == "")  alert("ABSJSAPI: saveInteractEvent: event_type is null");
                else if(objData.res_id == "")  alert("ABSJSAPI: saveInteractEvent: res_id is null");
                else if(objData.access_token == "")  alert("ABSJSAPI: saveInteractEvent: access_token is null");
                else;
            } 
            return false;
        }

        if (this.debugalerts)
            alert("ABSJSAPI: Enter saveInteractEvent. objData: " + objData.id_game_play + ", " + objData.id_question + ", " + objData.date_time_event + ", " + objData.event_type + ", " + objData.res_id + ", "+ objData.access_token);


        var query = "INSERT INTO interacteventtbl (id_game_play, id_question, date_time_event, event_type, res_id, access_token) VALUES (?,?,?,?,?,?)";

        this.absdbhandler.executeSql(query, [objData.id_game_play, objData.id_question, objData.date_time_event, objData.event_type, objData.res_id, objData.access_token],
            function (rs) {
                if (this.debugalerts) 
                    alert("ABSJSAPI: saveInteractEvent: success");
            },
            function (error) {
                if (this.erroralerts)
                    alert("ABSJSAPI: saveInteractEvent: failed" + error.message);
            }
        );

        if (this.debugalerts)
            alert("ABSJSAPI: Exit saveInteractEvent");
    },

    // Fetch the Interact Event data for syncing (read all the unsynced Interact Event records).
    //
    // IMPORTANT NOTE: The SQLite function is executed asynchronously and hence the JS function will exit before the SQLite function is completed.
    // Hence, the recrods fetched cannot be returned from the JS function as a return value. Instead, a callback function should be provided to the
    // JS function, which will be invoked when the SQLite function is completed. 
    //
    // fetchUnsyncedInteractEventRecords_cbf is the callback function, which will be invoked once the SQLite function completes its execution
    //

    fetchUnsyncedInteractEventRecords: function (callbackfn) {

        if (this.debugalerts)
            alert("ABSJSAPI: Enter fetchUnsyncedInteractEventRecords");

        var query = "SELECT id AS objid, access_token, id_game_play,  id_question, date_time_event, event_type, res_id FROM interacteventtbl WHERE synced = 0";

        var arrObjs = new Array();

        this.absdbhandler.executeSql(query, [],
            function (rs) {
                var nrecords = rs.rows.length;
                if (this.debugalerts)
                    alert("ABSJSAPI: fetchUnsyncedInteractEventRecords: success. Number of records:" + nrecords);

                for (var i = 0; i < nrecords; i++) {
                    arrObjs.push(rs.rows.item(i));
                }
                if (this.debugalerts)
                    alert("ABSJSAPI: arrObjs: " + JSON.stringify(arrObjs));

                callbackfn(arrObjs); // Invoke the callback function to send the array of Objects with the fetched records
            },
            function (error) {
                if (this.erroralerts)
                    alert("ABSJSAPI: fetchUnsyncedInteractEventRecords: failed" + error.message);
                return false;
            }
        );

        if (this.debugalerts)
            alert("ABSJSAPI: Exit fetchUnsyncedInteractEventRecords");

    },

    // callback function for fetchUnsyncedInteractEventRecords
    fetchUnsyncedInteractEventRecords_cbf: function (arrRecords) {

        if (this.debugalerts)
            alert("ABSJSAPI: Enter fetchUnsyncedInteractEventRecords_cbf");

        // alert("fetchUnsyncedInteractEventRecords_cbf: arrRecords: " + JSON.stringify(arrRecords));

        var arrEventData = new Array();
        for (var i = 0; i < arrRecords.length; i++) {

            var arr_eks = { "type": arrRecords[i].event_type, "id": arrRecords[i].res_id };
            var arr_edata = { "eks": arr_eks };
            var arrEvent = { "ekstep_eventid":"OE_INTERACT", "objid": arrRecords[i].objid, "id_game_play": arrRecords[i].id_game_play, "id_question": arrRecords[i].id_question, "date_time_event": arrRecords[i].date_time_event, "edata": arr_edata, "access_token": arrRecords[i].access_token };

            arrEventData.push(arrEvent);
        }
        // alert("arrEventData: " + JSON.stringify(arrEventData));

        // Do all the Processing, REST API calls etc here
        if (arrRecords.length > 0)
            RESTAPImgr.invokeRESTAPI('txekstepevents', arrEventData);
    },

    // mark all the records that have 'id' values specified in the 'ids' array as synced (set 'synced' field to 1.)
    markSyncedInteractEventRecords: function (ids) {

        var query = "UPDATE interacteventtbl SET synced = 1 WHERE id IN (" + ids + ")";

        if (this.debugalerts)
            alert("ABSJSAPI: Enter markSyncedInteractEventRecords. ids:" + ids + "  query: " + query);

        if ((ids.length == 0) || (ids == '')) {
            if (this.debugalerts)
                alert("ABSJSAPI: Empty list of 'id's. No action performed.");
            return true;
        }
        this.absdbhandler.executeSql(query, [],
            function (rs) {
                if (this.debugalerts)
                    alert("ABSJSAPI: markSyncedInteractEventRecords: success. resultSet.rowsAffected:" + rs.rowsAffected);
            },
            function (error) {
                if (this.erroralerts)
                    alert("ABSJSAPI: markSyncedInteractEventRecords: failed" + error.message);
                return false;
            }
        );

        if (this.debugalerts)
            alert("ABSJSAPI: Exit markSyncedInteractEventRecords");
    },

    // delete all the records that have 'synced' field as 1
    deleteSyncedInteractEventRecords: function () {

        if (this.debugalerts)
            alert("ABSJSAPI: Enter deleteSyncedInteractEventRecords");

        var query = "DELETE FROM interacteventtbl WHERE synced = 1";

        this.absdbhandler.executeSql(query, [],
            function (rs) {
                if (this.debugalerts)
                    alert("ABSJSAPI: deleteSyncedInteractEventRecords: success. resultSet.rowsAffected: " + rs.rowsAffected);
            },
            function (error) {
                if (this.erroralerts)
                    alert("ABSJSAPI: deleteSyncedInteractEventRecords: failed" + error.message);
                return false;
            }
        );

        if (this.debugalerts)
            alert("ABSJSAPI: Exit deleteSyncedInteractEventRecords");
    },

    // delete all the records that have 'id' values specified in the 'ids' array as synced. 
    // This function can be used to delete records directly instead of a two-step process of marking as synced and then deleting separately 
    deleteInteractEventRecordsByIds: function (ids) {

        if (this.debugalerts)
            alert("ABSJSAPI: Enter deleteInteractEventRecordsByIds");

        var query = "DELETE FROM interacteventtbl WHERE id IN (" + ids + ")";
    
        this.absdbhandler.executeSql(query, [],
            function (rs) {
                if (this.debugalerts)
                    alert("ABSJSAPI: deleteInteractEventRecordsByIds: success. resultSet.rowsAffected: " + rs.rowsAffected);
            },
            function (error) {
                if (this.erroralerts)
                    alert("ABSJSAPI: deleteInteractEventRecordsByIds: failed" + error.message);
                return false;
            }
        );

        if (this.debugalerts)
            alert("ABSJSAPI: Exit deleteInteractEventRecordsByIds");
    },

    // delete all the InteractEvent records
    deleteAllInteractEventRecords: function () {

        if (this.debugalerts)
            alert("ABSJSAPI: Enter deleteAllInteractEventRecords");

        var query = "DELETE * FROM interacteventtbl";

        this.absdbhandler.executeSql(query, [],
            function (rs) {
                if (this.debugalerts)
                    alert("ABSJSAPI: deleteAllInteractEventRecords: success. resultSet.rowsAffected: " + rs.rowsAffected);
            },
            function (error) {
                if (this.erroralerts)
                    alert("ABSJSAPI: deleteAllInteractEventRecords: failed" + error.message);
                return false;
            }
        );

        if (this.debugalerts)
            alert("ABSJSAPI: Exit deleteAllInteractEventRecords");
    },

    // Sync all the Telemetry data 
    // All 'fetch' functions run asynchronously and pass records to respective callback functions. 
    // Hence the 'syncTelemetryData' will return before the execution of all 'fetch' functions are complete. 
    // Hence, no point in returning any status value from this function
    syncTelemetryData: function () {

        // Sync Gameplay records
        this.fetchUnsyncedGameplayRecords(this.fetchUnsyncedGameplayRecords_cbf);

        // Sync Gameplaydetail records
        this.fetchUnsyncedAssessmentRecords(this.fetchUnsyncedAssessmentRecords_cbf);

        // Sync Interact Event records
        this.fetchUnsyncedInteractEventRecords(this.fetchUnsyncedInteractEventRecords_cbf);
    },

    reload: function () {

        alert("ABSJSAPI: in reload");
        location.reload(); // to be used when transitioning the page
    },

    echoTest: function () {
        window.sqlitePlugin.echoTest(function () {
            alert('ABSJSAPI: ECHO Test OK');
            //console.log('ECHO test OK');
        });
    },

    selfTest: function () {
        window.sqlitePlugin.selfTest(function () {
            alert('ABSJSAPI: SELF Test OK');
            // console.log('SELF Test OK');
        });
    }

};


var RESTAPImgr = {

    absrestapi_baseurl: "https://dev.abs.klp.org.in/abs/",

    // function to invoke ABS REST API
    invokeRESTAPI: function (apiname, jsondata) {

        var apiurl = this.absrestapi_baseurl + apiname;
        var rtn = true;

        // alert("RESTAPImgr.invokeRESTAPI: apiname:" + apiurl + "jsondata" + JSON.stringify(jsondata));

        $.ajax({
            url: apiurl,
            type: "POST",
            dataType: "json",
            // async:false, // set to false to perform a synchronous request
            data: JSON.stringify(jsondata),
            contentType: 'application/json; charset=UTF-8',
            accepts: 'application/json',
            success: function (jsonresp) {
                // alert("REST API success");
                RESTAPImgr.deleteSyncedRecords(apiname, jsonresp); // delete the Synced records
            },
            error: function (error) {
                rtn = false;
                alert("ABSJSAPI: invokeRESTAPI failed: api: "+apiurl+" error: "+error.toString());
            }
        });

        return rtn;
    },

    deleteSyncedRecords: function (apiname, jsonresp) {

        // alert("RESTAPImgr.deleteSyncedRecords");

        switch (apiname) {

            case 'txabsgameplay':

                // alert("deleteSyncedRecords: case: txabsgameplay");

   
                var arrObjs1 = new Array();
                var arrIds1 = new Array();

                var nrecs1 = jsonresp.length;
                // alert("nrecords:" + nrecs1);
                for (var i = 0; i < nrecs1; i++) {
                    arrObjs1.push(jsonresp[i]);  
                }

                var nfields1 = arrObjs1.length;
                for (var j = 0; j < nfields1; j++) {
                    if(arrObjs1[j].status == 'success')
                        arrIds1.push(arrObjs1[j].objid);   // Only those records which were successfully synced are to be deleted
                }
               
                //alert("arrIds toString: " + arrIds1.toString());

                // Mark fetched records as 'Synced'
                // absdsjsapi.markSyncedGameplayRecords(arrIds1.toString());
                // Delete 'Synced' records
                // absdsjsapi.deleteSyncedGameplayRecords();
                absdsjsapi.deleteGameplayRecordsByIds(arrIds1.toString());

                break;

            case 'txabsgameplaydetail':

                // alert("deleteSyncedRecords: case: txabsgameplaydetail");

                var arrObjs2 = new Array();
                var arrIds2 = new Array();

                var nrecs2 = jsonresp.length;
                // alert("nrecords:" + nrecs2);
                for (var i = 0; i < nrecs2; i++) {
                    arrObjs2.push(jsonresp[i]);
                }

                var nfields2 = arrObjs2.length;
                for (var j = 0; j < nfields2; j++) {
                    if (arrObjs2[j].status == 'success')
                        arrIds2.push(arrObjs2[j].objid);   // Only those records which were successfully synced are to be deleted
                }

                //alert("arrIds toString: " + arrIds2.toString());

                // Mark fetched records as 'Synced'
                // absdsjsapi.markSyncedAssessmentRecords(arrIds2.toString());
                // Delete 'Synced' records
                // absdsjsapi.deleteSyncedAssessmentRecords();
                absdsjsapi.deleteAssessmentRecordsByIds(arrIds2.toString());

                break;

            case 'txekstepevents':

                // alert("deleteSyncedRecords: case: txekstepevents");

                var arrObjs3 = new Array();
                var arrIds3 = new Array();

                var nrecs3 = jsonresp.length;
                // alert("nrecords:" + nrecs3);
                for (var i = 0; i < nrecs3; i++) {
                    arrObjs3.push(jsonresp[i]);
                }

                var nfields3 = arrObjs3.length;
                for (var j = 0; j < nfields3; j++) {
                    if (arrObjs3[j].status == 'success')
                        arrIds3.push(arrObjs3[j].objid);   // Only those records which were successfully synced are to be deleted
                }

                // alert("arrIds toString: " + arrIds3.toString());

                // Mark fetched records as 'Synced'
                // absdsjsapi.markSyncedInteractEventRecords(arrIds3.toString());
                // Delete 'Synced' records
                // absdsjsapi.deleteSyncedInteractEventRecords();
                absdsjsapi.deleteInteractEventRecordsByIds(arrIds3.toString());
                break;
        }
    }
};

var TestMgr_absdsjsapi = {


    forTest: function () {

        // alert("Enter forTest");

        // document.addEventListener('deviceready', this.doTest.bind(this), false);
        document.getElementById('absdsjsapi-test-btn1').addEventListener('click', this.doTest.bind(this, '1'), false);
        document.getElementById('absdsjsapi-test-btn2').addEventListener('click', this.doTest.bind(this, '2'), false);
        document.getElementById('absdsjsapi-test-btn3').addEventListener('click', this.doTest.bind(this, '3'), false);
        document.getElementById('absdsjsapi-test-btn4').addEventListener('click', this.doTest.bind(this, '4'), false);
        document.getElementById('absdsjsapi-test-btn5').addEventListener('click', this.doTest.bind(this, '5'), false);
        document.getElementById('absdsjsapi-test-btn6').addEventListener('click', this.doTest.bind(this, '6'), false);
        document.getElementById('absdsjsapi-test-btn7').addEventListener('click', this.doTest.bind(this, '7'), false);
        document.getElementById('absdsjsapi-test-btn8').addEventListener('click', this.doTest.bind(this, '8'), false);
        document.getElementById('absdsjsapi-test-btn9').addEventListener('click', this.doTest.bind(this, '9'), false);
        document.getElementById('absdsjsapi-test-btn10').addEventListener('click', this.doTest.bind(this, '10'), false);
        document.getElementById('absdsjsapi-test-btn11').addEventListener('click', this.doTest.bind(this, '11'), false);
        document.getElementById('absdsjsapi-test-btn12').addEventListener('click', this.doTest.bind(this, '12'), false);
        document.getElementById('absdsjsapi-test-btn13').addEventListener('click', this.doTest.bind(this, '13'), false);

        document.getElementById('absdsjsapi-test-nextpage').addEventListener('click', this.doTest.bind(this, '14'), false);

        document.getElementById('absdsjsapi-test-reloadds').addEventListener('click', this.doTest.bind(this, '15'), false);
        document.getElementById('absdsjsapi-test-backtoindexpage').addEventListener('click', this.doTest.bind(this, '16'), false);
        

        // alert("Exit forTest");
    },

    doTest: function (arg) {

        // alert("Enter doTest: arg:" + arg);

        var accesstoken = "5a891ee77f10e" ;

        switch (arg) {

            case '1':
                absdsjsapi.echoTest();
                absdsjsapi.selfTest();
                break;

            case '2':
                absdsjsapi.initializeDS();
                break;

            case '3':
                absdsjsapi.dropTables();
                break;

            case '4':
                var gameplaydata = { id_game: "SK101", access_token: accesstoken, start_time: "12:10:05:10:15:10" };
                var id_gameplay = absdsjsapi.saveGameplay(gameplaydata);
                break;

            case '5':
                absdsjsapi.fetchUnsyncedGameplayRecords(absdsjsapi.fetchUnsyncedGameplayRecords_cbf);
                break;

            case '6':
                absdsjsapi.deleteSyncedGameplayRecords();
                break;

            case '7':
                var gameplaydata = { id_game: "SK101", access_token: accesstoken, start_time: "12:10:05:10:15:10" };
                var id_gameplay = absdsjsapi.saveGameplay(gameplaydata);

                var assessmentdata = { id_game_play: id_gameplay, id_question: "10", pass: "Yes", time2answer: "5", attempts: "2", date_time_submission: "05:06:07:08:09:10", access_token: accesstoken };
                absdsjsapi.saveAssessment(assessmentdata);
                break;

            case '8':
                absdsjsapi.fetchUnsyncedAssessmentRecords(absdsjsapi.fetchUnsyncedAssessmentRecords_cbf);
                break;

            case '9':
                absdsjsapi.deleteSyncedAssessmentRecords();
                break;

            case '10':
                var gameplaydata = { id_game: "SK101", access_token: accesstoken, start_time: "12:10:05:10:15:10" };
                var id_gameplay = absdsjsapi.saveGameplay(gameplaydata);

                var interactdata = { id_game_play: id_gameplay, id_question: "10", date_time_event: "03:04:07:08:07:10", event_type: "TOUCH", res_id: "DEVICE_BAK_BUTTON", access_token: accesstoken };
                absdsjsapi.saveInteractEvent(interactdata);
                break;

            case '11':
                absdsjsapi.fetchUnsyncedInteractEventRecords(absdsjsapi.fetchUnsyncedInteractEventRecords_cbf);
                break;

            case '12':
                absdsjsapi.deleteSyncedInteractEventRecords();
                break;

            case '13':
                absdsjsapi.syncTelemetryData();
                break;

            case '14':
                window.location = "page2.html";
                break;

            case '15':
                alert("case15: to call reload()");
                absdsjsapi.reload();
                break;

            case '16':
                alert("going back to index page");
                window.location = "index.html";
                break;
        }

    }
};

TestMgr_absdsjsapi.forTest();



