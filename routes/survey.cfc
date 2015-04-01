<cfscript>

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


            var keys = [];
            for(var i = 1; i <= result.recordcount; i++){
                keys[i] = result['q_id'][i];
            }

            var output = StructNew();
            output['statusCode'] = '200';
            output['data'] = keys;

            /*
            var output = structNew();
            output['statusCode'] = '200';
            output['data'] = super.buildDataObj(result);
            */
            writedump(SerializeJSON(output));

        }



        //writeDump(super.buildDataObj(result));


        include "/public/survey.html";
	    //writedump(SerializeJSON(result)); 
	    
        }
        
    function actionDefault() {
            
    }
	
	/*
	 *@method actionTos() - updates the terms of service field
	 *@param s_code - survey code required
	 */ 
	function actionTos() {
	     /* get the session object */
	    var sess = super.getSession();
	    
	    /* get the s_code from session. */
	    var s_code = sess.getValue('s_code');
	}


    /*
    @method actionLoadLast();
    @description - Loads the last answered questions for the currently logged in user.
    */
    function actionLoadLast() {

        var q_id = invoke('survey', 'getLast');

        if(q_id > 0) {

            var output = StructNew();
            output['statusCode'] = 200;
            output['data'] = invoke('survey', 'getQuestionData', {q_id=q_id});
            output['message'] = 'success';

        } else {
            var output = StructNew();
            output['statusCode'] = 200;
            output['data'] = '';
            output['message'] = "no records found";
        }

        writeOutput(SerializeJSON(output));
    }


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

                var prev_q_id = q_list[i-1];

                return prev_q_id;

            } else {

                return 0;
            }
        }
    }


    public function actionLoadPrevious() {

        /* get the previous answered question */
        /* get the request object */
        var req = super.getRequest();

        /*
        get the q_id from the request object.
        */
        var q_id = req.getData('q_id');

        if(isDefined('q_id') && isNumeric(q_id)) {

            var previous_q_id = invoke('survey', 'getPrevious', {q_id=q_id});

            var output = StructNew();

            if(previous_q_id != 0) {


                output['statusCode'] = 200;
                output['data'] = invoke('survey', 'getQuestionData', {q_id=previous_q_id});

                writeoutput(serializeJSON(output));
            } else {
                output['statusCode'] = 500;
            }

        }

    }

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

                var next_q_id = q_list[i+1];

                return next_q_id;

            } else {
                return 0;
            }
        }
    }


    public function actionLoadNext() {



        /* get the next question */
        /* get the request object */
        var req = super.getRequest();

        /*
        get the q_id from the request object.
        */
        var q_id = req.getData('q_id');

        if(isDefined('q_id') && isNumeric(q_id)) {

            var next_q_id = invoke('survey', 'getNext', {q_id=q_id});

            var output = StructNew();

            if(next_q_id != 0) {

                output['statusCode'] = 200;
                output['data'] = invoke('survey', 'getQuestionData', {q_id=next_q_id});

                writeoutput(serializeJSON(output));
            } else {
                output['statusCode'] = 500;
                writeoutput(serializeJSON(output));
            };

        }

//        /* get the last answered question
//         extract the ID from the sesion, if the ID is not
//         present in session load it from the database*/
//
//         /* get the session object */
//        var sess = super.getSession();
//
//        /* get the s_code from session. */
//        var q_id = sess.getValue('last_q_id');
//
//        if(!isDefined('q_id') || !isNumeric(q_id)) {
//            /* get the id from  database */
//            q_id = invoke('survey', 'getLast');
//        }
//
//        var next_q_id = invoke('survey', 'getNext', {q_id=q_id});
//
//        writeDump(next_q_id);

    }

    /*
    start the survey
    */
    public function actionStart()
    {
        /* get the request object */
        var req = super.getRequest();

        /* get the session object */
        var sess = super.getSession();

        /* get the s_code from session. */
        var s_code_id = sess.getValue('s_code_id');

        /*
        query the database and get a list of all question
        entity_ids that are associated with the current survey id.
        */

        var q = super.getQuery('SELECT t1.q_id ' &
        ' FROM survey_question_table as t1' &
        ' WHERE t1.s_id= :s_code_id');

        q.addParam(name = 's_code_id', value = s_code_id, CFSQLTYPE = "CF_SQL_INT");

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

        //load the question data and display the answers.
        if(last_q_id > 0) {

            var output = StructNew();
            output['statusCode'] = 200;
            output['data'] = invoke('survey', 'getQuestionData', {q_id=last_q_id});
            output['message'] = 'success';

        } else {

            var output = StructNew();
            output['statusCode'] = 200;
            output['data'] = '';
            output['message'] = "no records found";
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
            //writeoutput(serializeJSON(invoke('survey', 'getQuestionData', {q_id=q_id})));
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


    public function getQuestion(q_id) {

        if(isNumeric(q_id) && q_id != 0) {


            /*
            //var q = super.getQuery('SELECT * FROM question_table WHERE entity_id = :q_id');
            var q = super.getQuery('SELECT t1.*, t2.[type], t3.[type] as data_type FROM question_table as t1, question_type as t2, answer_type as t3
                                    WHERE t1.entity_id = :q_id AND t1.q_type = t2.entity_id and t1.a_type = t3.entity_id');
            */

            var q = super.getQuery('SELECT t1.*, t2.[type], t3.[type] as data_type
                                    FROM question_table as t1 inner join question_type as t2 on t1.q_type = t2.entity_id left join answer_type as t3
                                    on t1.a_type = t3.entity_id
                                    WHERE t1.entity_id = :q_id');

            q.addParam(name = 'q_id', value = q_id, CFSQLTYPE = "CF_SQL_INT");

            result = q.execute().getResult();

            if (result.recordcount > 0) {

                return result;
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
                                sql &= "'" & parts[1] & "'";
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
                } catch(any exception) {
                    writeoutput(exeption.message);
                    valid = false;
                }

                /*
                var result = q.execute().getPrefix();
                var id = result.generatedkey;
                */


                if(valid == true) {
                    writeoutput('success');
                } else {
                    writeoutput('failed');
                }


            }
        } else {
            /* Invalid answer supplied */
            output['statusCode'] = 500;
            output['message'] = "Invalid Questions ID Supplied";
        }
    }

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

                    output['statuCode'] = 200;
                    output['message'] = "Answer Record Successfully Updated";

                } catch(any exception) {

                    output['statusCode'] = 500;
                    output['message'] = exception.message;

                }
                writeoutput(serializeJSON(output));
            } else {

                var output = StructNew();
                output['statuCode'] = 200;
                output['message'] = "Answer Record Already Exists, Skipping";

                writeoutput(serializeJSON(output));
            }

        } else {
            var output = StructNew();

            output['statuCode'] = 500;
            output['message'] = "Invalid Question ID Supplied";

            writeoutput(serializeJSON(output));
        }

    }
}

</cfscript>