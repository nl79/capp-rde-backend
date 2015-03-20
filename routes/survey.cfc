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
/*
        if(result.recordcount > 0) {

            var keys = [];
            for(var i = 1; i <= result.recordcount; i++){
                keys[i] = result['q_id'][i];
            }

            var output = StructNew();
            output['statusCode'] = '200';
            output['data'] = keys;

            writedump(SerializeJSON(output));

        }
        */
        writeDump(super.buildDataObj(result));


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

            q.addParam(name='s_code_id', value=s_code_id,CFSQLTYPE="CF_SQL_INT");

            result = q.execute().getResult();

            if(result.recordcount > 0) {

                writeoutput(result['last'][1]);

            }

        } else {

            //create a collection structure.
            var output = StructNew();
            output['statusCode'] = '300';
            output['location'] = '/account/login';

            writeOutput(SerializeJSON(output));
        }
    }

    /*
    @method actionLoadQuestion()
    @description - loads the question and answer data for the supplied question id.
    */
    function actionLoadQuestion() {

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

            var q = super.getQuery('SELECT * FROM question_table WHERE entity_id = :q_id');

            q.addParam(name = 'q_id', value = q_id, CFSQLTYPE = "CF_SQL_INT");

            result = q.execute().getResult();

            if (result.recordcount > 0) {


                writedump(serializeJSON(result));

            }
        }
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
}

</cfscript>