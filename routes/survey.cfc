<cfscript>

/*
 *@component Survey
 *@extends _base_route
 *@description Survey routes object that handles various actions by the user.
 */

component Survey
	output="false"
	extends="_base_route"
	{
         
    function actionIndex() {

        /* get the session object */
        var sess = super.getSession();

        /* get the s_code from session. */
        var s_id = sess.getValue('s_id');

        /*
        query the database and get a list of all question
        entity_ids that are associated with the current survey id.
        */

        var q = super.getQuery('SELECT t1.q_id ' &
        ' FROM survey_question_table as t1' &
        ' WHERE t1.s_id= :s_id');

        q.addParam(name='s_id', value=s_id,CFSQLTYPE="CF_SQL_INT");

        result = q.execute().getResult();

        if(result.recordcount > 0) {

            /*
             *if the database has question assocciated with the supplied survey code.
             *extract the keys and store them as an array
             */
            var keys = [];
            for(var i = 1; i <= result.recordcount; i++){
                keys[i] = result['q_id'][i];
            }

            /* Create a new structure and store the keys */
            var output = StructNew();
            output['statusCode'] = '200';
            output['data'] = keys;

        }

        /*
         *Fallback action if the request was not performed by the front-end phonegap
         *application.
         *The system will load the survey page and allow the users to take the survey via a browser.
         */
        include "/public/survey.html";
    }

    /*
    @method actionLoadLast();
    @description - Loads the last answered questions for the currently logged in user.
    */
    function actionLoadLast() {

        /* call the getLast to get the ID of the last answered question */
        var q_id = invoke('survey', 'getLast');

        if(q_id > 0) {

            /* if successful, load the question data for the given last ID and
             * return a json object with the question data
             */
            var output = StructNew();
            output['statusCode'] = 200;
            output['data'] = invoke('survey', 'getQuestionData', {q_id=q_id});
            output['message'] = 'success';

        } else {

            /* return a json object with a message indicating that no questions were
             * found in the database
             */
            var output = StructNew();
            output['statusCode'] = 200;
            output['type'] = 'info';
            output['data'] = '';
            output['info'] = "no records found";
        }

        writeOutput(SerializeJSON(output));
    }


    /*
     *@method getPrevious - get the question from the list that comes before the question with the supplied id.
     *@param integer q_id - ID of the current question.
     *@return integer id - returns a question ID as integer
     */
    public function getPrevious(q_id) {

        if(isDefined('q_id') && isNumeric(q_id)) {

            /* get the session object */
            var sess = super.getSession();

            /* get the list of question IDs associated with the current account. */
            var q_list = sess.getValue('q_id_list');

            /* get the Index of the current question. */
            var i = ArrayFind(q_list, q_id);

            /*check if a previous question exists in the collection */
            if(i > 1) {

                return q_list[i-1];

            } else {

                /* if no previous ID, return 0 */
                return 0;
            }
        }
    }

    /*
     *@method actionLoadPrevious() - Handles the loadprevious event issues by the front-end applications.
     *@description - if the previous question id is not 0, loads the question data and returns a json object.
     *@return String json - returns a json string representing a response.
     */
    public function actionLoadPrevious() {

        /* get the previous answered question */
        /* get the request object */
        var req = super.getRequest();

        /*
        get the q_id from the request object.
        */
        var q_id = req.getData('q_id');

        /* output structure */
        var output = StructNew();

        /* validate that the q_id was set and is a valid number */
        if(isDefined('q_id') && isNumeric(q_id)) {

            /* get the ID of the previous question in the list */
            var previous_q_id = invoke('survey', 'getPrevious', {q_id=q_id});

            if(previous_q_id != 0) {

                output['statusCode'] = 200;
                output['type'] = 'data';
                output['data'] = invoke('survey', 'getQuestionData', {q_id=previous_q_id});

            } else {

                output['statusCode'] = 404;
                output['type'] = 'info';
                output['info'] = 'No Previous Questions Found';
            }

        } else {

            output['statusCode'] = 500;
            output['type'] = 'error';
            output['error'] = 'Invalid Question ID Supplied';
        }

        writeoutput(serializeJSON(output));

    }

    /*
     *@method getNext()
     *@description - Get the next question ID from the list.
     *@return Integer ID - returns a question id as number or 0 if nothing found.
     */
    public function getNext(q_id) {

        /* get the session object */
        var sess = super.getSession();

        if(isDefined('q_id') && isNumeric(q_id)) {

            /* get the list of question ID assocciated with the current account. */
            var q_list = sess.getValue('q_id_list');

            /* get the Index of the last answerd question in the list. */
            var i = ArrayFind(q_list, q_id);

            /*check if the there are more IDs in the list and return the questions data.
            If there are no more, return a survey complete message.
            */
            if(arraylen(q_list) > i) {

                return q_list[i+1];

            } else {

                return 0;
            }
        }
    }

    /*
     *@method actionLoadNext() - Handles the loadnext event issues by the front-end applications.
     *@description - if the next question id is not 0, loads the question data and returns a json object.
     *@return String json - returns a json string representing a response.
     */
    public function actionLoadNext() {

        /* get the next question */
        /* get the request object */
        var req = super.getRequest();

        /* get the session object */
        var sess = super.getSession();

        /*
        get the q_id from the request object.
        */
        var q_id = req.getData('q_id');

        if(isDefined('q_id') && isNumeric(q_id)) {

            var next_q_id = invoke('survey', 'getNext', {q_id=q_id});

            var output = StructNew();

            /* get the list of question ID assocciated with the current account.
             * in order to validate if the id is the last question in the list
             */
            var q_list = sess.getValue('q_id_list');

            /* get the Index of the current question in the list. */
            /*
            var i = ArrayFind(q_list, q_id);
            writeoutput(arraylen(q_list));
            writeoutput("index: " & i);
            */

            if(next_q_id != 0) {

                output['type'] = 'data';
                output['statusCode'] = 200;
                output['data'] = invoke('survey', 'getQuestionData', {q_id=next_q_id});

            } else if(ArrayFind(q_list, q_id) == arraylen(q_list)) {

                /* redirect */
                output['type'] = 'info';
                output['statusCode'] = 204;
                output['info'] = 'Survey Complete';

            } else {

                output['statusCode'] = 404;
                output['type'] = 'info';
                output['info'] = "No Records Found";
            };
        } else {

            output['statusCode'] = 400 ;
            output['type'] = 'error';
            output['error'] = "Invalid Question ID supplied";
        }

        writeoutput(serializeJSON(output));
    }

    /*
     *@method actionStart()
     *@description - initializes the survey question ID and loads the data for the last answered question
     */
    public function actionStart() {
        /* output structure */
        var output = StructNew();

        /* get the request object */
        var req = super.getRequest();

        /* get the session object */
        var sess = super.getSession();

        /* get the s_code from session. */
        //var s_code_id = sess.getValue('s_code_id');
        var s_id = sess.getValue('s_id');

        /*
        query the database and get a list of all question
        entity_ids that are associated with the current survey id.
        */
        var q = super.getQuery('SELECT t1.q_id ' &
        ' FROM survey_question_table as t1' &
        ' WHERE t1.s_id= :s_id');

        q.addParam(name = 's_id', value = s_id, CFSQLTYPE = "CF_SQL_INT");
        result = q.execute().getResult();

        if (result.recordcount > 0) {

            var keys = [];
            for (var i = 1; i <= result.recordcount; i++) {
                keys[i] = result['q_id'][i];
            }

        }

        /* set the keys array in session */
        sess.putValue('q_id_list', keys);

        /*get the last answered question from the database and store it in session. */
        var last_q_id = invoke('survey', 'getLast');

        /*store the value in session */
        sess.putValue('last_q_id', last_q_id);

        //load the question data for the next question in the list and display the answers.
        if(last_q_id > 0) {

            output['statusCode'] = 200;
            output['type'] = 'data';
            output['data'] = invoke('survey', 'getQuestionData', {q_id=last_q_id});
            output['message'] = 'success';

            /*add the list of question keys to the data */
            output['data']['keys'] = keys;


        } else {

            if(arraylen(keys) > 0) {

                /* load the first question from the list */
                output['statusCode'] = 200;
                output['type'] = 'data';
                output['data'] = invoke('survey', 'getQuestionData', {q_id=keys[1]});
                output['message'] = 'success';

            } else {

                output['statusCode'] = 200;
                output['type'] = 'info';
                output['data'] = structNew();
                output['info'] = "no records found";
            }

            /*add the list of question keys to the data */
            output['data']['keys'] = keys;

        }

        writeOutput(SerializeJSON(output));
    }

    /*
    @method actionLoadQuestion()
    @description - loads the question and answer data for the supplied question id.
    */
    public function actionLoadQuestion() {

        /* get the request object */
        var req = super.getRequest();

        /*
        get the q_id from the request object.
        */
        var q_id = req.getData('q_id');

        /*
        * check if the s_code is defined and is numeric.
        * if so, query the database for the last answered question.
        */
        if(isNumeric(q_id) && q_id != 0) {

            var output = StructNew();

            output['statusCode'] = 200;
            output['data'] = invoke('survey', 'getQuestionData', {q_id=q_id});

            writeoutput(serializeJSON(output));
        }
    }

    /*
    @method getQuestionData()
    @description - Loads all question data including, the question, options, and answer
    */
    public function getQuestionData(q_id) {

        /*
        * check if the s_code is defined and is numeric.
        * if so, query the database for the last answered question.
        */

        if(isNumeric(q_id) && q_id != 0) {

            //stucture to store the question data.
            var data = structNew();

            //store the question record.
            data['question'] = super.buildDataObj(invoke('survey', 'getQuestion', {q_id=q_id}));

            //load the answer options
            data['options'] = super.buildDataObj(invoke('survey', 'getOptions', {q_id=q_id}));

            //load the answer record.
            data['answer'] = super.buildDataObj(invoke('survey', 'getAnswer', {q_id=q_id}));

            return data;
        }
    }

    /*@method getLast
     *@description - Loads the question ID of the last answered question in the survey based on survey code.
     *@return integer ID - returns a question ID as integer.
     */
    public function getLast() {
        /* get the session object */
        var sess = super.getSession();

        /* get the s_code from session. */
        var s_code_id = sess.getValue('s_code_id');

        /*
        * check if the s_code is defined and is numeric.
        * if so, query the database for the last answered question.
        */
        if(isDefined('s_code_id') && isNumeric(s_code_id)) {

            var q = super.getQuery('SELECT [last] FROM survey_code_table WHERE entity_id = :s_code_id');

            q.addParam(name = 's_code_id', value = s_code_id, CFSQLTYPE = "CF_SQL_INT");

            result = q.execute().getResult();

            var q_id = result['last'][1];

            return q_id;
        }
    }


    /*
     *@method getQuestion()
     *@description - Get the question data from the database and return a result object.
     *@param integer q_id - question id.
     *@return Object - returns a result object on success or false on failure.
     */
    public function getQuestion(q_id) {

        if(isNumeric(q_id) && q_id != 0) {

            var q = super.getQuery('SELECT t1.*, t2.[type], t3.[type] as data_type
                                    FROM question_table as t1 inner join question_type as t2 on t1.q_type = t2.entity_id left join answer_type as t3
                                    on t1.a_type = t3.entity_id
                                    WHERE t1.entity_id = :q_id');

            q.addParam(name = 'q_id', value = q_id, CFSQLTYPE = "CF_SQL_INT");

            result = q.execute().getResult();

            if (result.recordcount > 0) {

                return result;
            } else {
                return false;
            }
        }
    }

    /*
    @method getAnswer()
    @param q_id - question id
    @param s_code_id - survey code id.
    */
    public function getAnswer(q_id) {

        /* get the session object */
        var sess = super.getSession();

        /* get the s_code from session. */
        var s_code_id = sess.getValue('s_code_id');

        var q = super.getQuery('SELECT t1.* FROM answer_table as t1
                                WHERE t1.q_id = :q_id AND t1.s_code_id = :s_code_id ');

        q.addParam(name='q_id', value=q_id,CFSQLTYPE="CF_SQL_INT");

        q.addParam(name='s_code_id', value=s_code_id,CFSQLTYPE="CF_SQL_INT");

        result = q.execute().getResult();

        return result;
    }

    /*
     *@method getOptions()
     *@description - get the answer options for a question with the supplied ID.
     *@param integer q_id - Question ID as integer.
     *@return Object - returns query result object.
     */
    public function getOptions(q_id) {

        var q = super.getQuery('SELECT t1.* FROM option_table as t1, question_options_table as t2
                                WHERE t2.q_id = :q_id AND t1.entity_id = t2.o_id ');

        q.addParam(name='q_id', value=q_id,CFSQLTYPE="CF_SQL_INT");

        result = q.execute().getResult();

        return result;
    }
	/*
	 *@method actionLoad() - Load the survey question/questions based on the
	 *survey code. 
	 */ 
	function actionLoadAll() {
	    /*
	     *check if the the following IDS are set:
	     *-survey code: to make sure the current user is viewing allowable survey.
	     *-survey_id: to make sure they did not inject an invalid ID into the query.
	     *-question_id: the ID of the question to load. If no ID is supplied, return a list of all questions.
	     *NOTE: code, survey_id and questions_id must all be valid and part of the same record
	     *otherwise a question can be loaded from a different survey based on its ID.
	     *-terms of service signed?
	     */


        var sess = super.getSession();

        //run the validation method to redirect to the login
        //page if the user is not logged in.
        super.userValid();


        /*
         *get the survey assocciated with the current
         *survey code.
         */

        var s_id = sess.getValue('s_id');


        /*
         *return a list of all the question IDs assocciatedi
         *with the current survey.
         */

        var q = super.getQuery('SELECT t1.*, t2.*, t3.[type] ' &
        ' FROM survey_question_table as t1, question_table as t2, question_type as t3 ' &
        ' WHERE t1.s_id= :s_id AND t2.entity_id = t1.q_id and t3.entity_id = t2.q_type ');

        q.addParam(name='s_id', value=s_id,CFSQLTYPE="CF_SQL_INT");
        result = q.execute().getResult();

        /* check that the result is not empty, and build a valid structure */
        if(result.recordcount > 0) {
            //create a collection structure.
            var collection = StructNew();

            //extract the columns and split them into an array.
            var cols = result.ColumnList.split(',');

            //loop through each result.
            for(var i = 1; i <= result.recordcount; i++) {
                var row = StructNew();

                for(field in cols) {
                    row[field] = result[field][i];


                }
                collection[result['entity_id'][i]] = row;

            }

            writeoutput(SerializeJSON(collection));

        }
	    
	}

    /*
     *@method actionSave()
     *@description - If the question ID is not in the database, a new record will be created with the supplied
     *data. If the question with the supplied id exists, the record will be updated.
     */
    function actionSave() {
        /*sucess flag */
        var valid = true;

        /* get the request object */
        var req = super.getRequest();

        /* get the session object */
        var sess = super.getSession();

        /*
        get the answers from the request object.
        the answer will be a string of numbers
        if multiple checkbox items were selected.
        */
        var answer = req.getData('answer');

        var output = StructNew();

        /* validate if the answers is a valid string and attempt to split on ',' */
        if(isDefined('answer') && Compare(getMetadata(answer).getName(), 'java.lang.String') == 0 &&
                len(answer) > 0) {

            /*split the answer on comma */
            var parts = answer.split(',');

            /*loop over the parts and replace the ~ inside the string with a ',' character*/
            for(i=1; i <= ArrayLen(parts); i++)
            {
                parts[i] = ReplaceNoCase(parts[i],"~",",","all");
            }

            if(len(parts) > 0) {

                /* flag the determines if a new answers record was created.
                if set to true, the survey_code status will reflect the last
                question answered in order to save status.
                */
                var insert = false;

                /*get the q_id */
                var q_id = req.getData('q_id');

                /* get the s_code from session. */
                var s_code_id = sess.getValue('s_code_id');

                /*load the question data from the database*/
                var question = invoke('survey', 'getQuestion', {q_id=q_id});

                /*try to load the answers from the database to check if one exists.
                if so, create and update query.
                */
                var answer = invoke('survey', 'getAnswer', {q_id=q_id});

                var type = question['type'][1].trim();

                /* generate a SQL string */
                var sql = "";

                /*
                check if an answer record exists for the current question.
                if so, create and update query.
                */
                if(answer.recordcount == 1) {
                    /* get the answer id from the result. */
                    var entity_id = answer['entity_id'][1];

                    sql = "UPDATE answer_table SET [value] = ";
                    switch (type) {
                        case "checkbox":
                        case "radio":
                            sql &= "'" & arrayToList(parts, '|') & "'";
                                break;
                        case "text":
                        case "date":
                        case "bigtext":

                            sql &= "'" & parts[1] & "'";
                                break;
                    }

                    sql &= " WHERE entity_id=" & entity_id;

                } else {
                    /* set the insert flag to true */
                    insert = true;

                    /* build the query */
                    sql = "INSERT INTO answer_table (q_id, s_code_id, [value]) VALUES";
                    if (isNumeric(q_id) && isNumeric(s_code_id)) {
                        sql &= "(" & q_id & "," & s_code_id & ",";
                        switch (type) {
                            case "checkbox":
                            case "radio":
                                sql &= "'" & arrayToList(parts, '|') & "'";
                                    break;
                            case "text":
                            case "date":
                            case "bigtext":
                                /* extract the value and truncate it to 254 maximum characters */
                                var value = mid(parts[1], 1, 254);

                                sql &= "'" & value & "'";
                                    break;
                        }

                        sql &= ")";
                    }
                }

                /* build the query object */
                var q = super.getQuery(sql);

                try{
                    var result = q.execute();
                    valid = true;

                    /*if a new answer was created, update the last question answerd
                    for the current survey_code_id
                    */
                    if(valid == true && insert == true) {

                        var updateQuery = super.getQuery("UPDATE survey_code_table SET [last]= :q_id
                         WHERE entity_id=:s_code_id");

                        updateQuery.addParam(name='s_code_id', value=s_code_id,CFSQLTYPE="CF_SQL_INT");
                        updateQuery.addparam(name='q_id', value=q_id, CFSQLTYPE="CF_SQL_INT");

                        updateQuery.execute();

                        /* set the question id in the session object */
                        sess.putValue('last_q_id', q_id);

                    }

                    output['statusCode'] = 200;
                    output['type'] = 'success';
                    output['success'] = 'Answer Saved Successfully';

                } catch(any exception) {

                    output['statusCode'] = 500;
                    output['type'] = 'error';
                    output['error'] = exception.message;

                    valid = false;
                }
            }
        } else {
            /* Invalid answer supplied */
            output['statusCode'] = 500;
            output['type'] = 'error';
            output['error'] = "Invalid Questions ID Supplied";
        }

        writeoutput(serializeJSON(output));
    }

    /*
     *@method actionSkip()
     *@description - event handler for the questionskip action. Skips the question with the supplied ID.
     */
    public function actionSkip() {

        /* get the request object */
        var req = super.getRequest();

        /* get the session object */
        var sess = super.getSession();

        /*
        get the answers from the request object.
        the answer will be a string of numbers
        if multiple checkbox items were selected.
        */
        var q_id = req.getData('q_id');


        /* validate if the answers is a valid string and attempt to split on ',' */
        if(isDefined('q_id') && isNumeric(q_id)) {

            /* get the s_code from session. */
            var s_code_id = sess.getValue('s_code_id');

            /* check if an answer exists for the current questions.
             If not, build an insert query.
             Otherwise return*/
            var answer = invoke('survey', 'getAnswer', {q_id=q_id});

            if(answer.recordcount == 0) {

                /* build the insert sql */
                var sql = "INSERT INTO answer_table (q_id, s_code_id, [value])
                VALUES (:q_id,:s_code_id, NULL)";

                /* execute the query */
                var q = super.getQuery(sql);

                q.addparam(name='q_id', value=q_id, CFSQLTYPE="CF_SQL_INT");
                q.addParam(name='s_code_id', value=s_code_id,CFSQLTYPE="CF_SQL_INT");

                var output = structNew();

                try{
                    var result = q.execute();

                    output['statusCode'] = 200;
                    output['success'] = "Answer Record Successfully Updated";
                    outout['type'] = 'success';

                } catch(any exception) {

                    output['statusCode'] = 500;
                    output['type'] = 'error';
                    output['error'] = exception.message;

                }
                writeoutput(serializeJSON(output));
            } else {

                var output = StructNew();
                output['statusCode'] = 200;
                outout['type'] = 'success';
                output['success'] = "Answer Record Already Exists, Skipping";

                writeoutput(serializeJSON(output));
            }

        } else {
            var output = StructNew();

            output['statusCode'] = 500;
            output['type'] = 'error';
            output['error'] = "Invalid Question ID Supplied";

            writeoutput(serializeJSON(output));
        }

    }
}

</cfscript>