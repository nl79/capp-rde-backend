<cfscript>

component Survey
	output="false"
	extends="_base_route"
	{
         
        function actionIndex() {
        
        }
        
        function actionDefault() {
            
        }
	
	/*
	 *@method: actionLogin() - queries the database and validates users
	 *survey code.
	 */ 
        
        function actionLogin() {
	     
	    /* get the session object */
	    var sess = super.getSession();
	    
	    /* get the request object */
	    var req = super.getRequest();
	    
	    
	    //get the survey code. 
	    var s_code = req.getData('s_code'); 
	    
            /*
	     *validate the users survey code
	     */
	    if(len(s_code) > 0) {
		
		//query the database
		var q = new Query(); 
	
		q.setDatasource("rde_survey");
		q.setSQL('SELECT * FROM survey_code_table WHERE s_code= :s_code');
		q.addParam(name='s_code', value=s_code,CFSQLTYPE="CF_SQL_CHAR"); 
		result = q.execute().getResult();
		
		/*
		 *check if results were returned.
		 *extract the servey ID and store it in session.
		 */ 
		if(result.recordcount > 0) {
		    
		    /*
		     *store the logged in status in the session.
		     */
		    /*
		    var s_code_id = result['entity_id'][1];	//survey code id
		    var s_code = result['s_code'][1];		//survey code
		    var s_id = result['s_id'][1]; 		//survey id.
		    */
		    sess.putValue('s_code_id', result['entity_id'][1]);
		    sess.putValue('s_code', result['s_code'][1]);
		    sess.putValue('s_id', result['s_id'][1]);
		    
		}
		    
	    }
	    
	    
	    
	    /*
	     *if valid return a redirect json to the survey page.
	     */ 
        }
	
	/*
	 *@method actionLoad() - Load the survey question/questions based on the
	 *survey code. 
	 */ 
	function actionLoad() {
	    var sess = super.getSession();
	    
	    /*
	     *check if the the following IDS are set:
	     *-survey code: to make sure the current user is viewing allowable survey.
	     *-survey_id: to make sure they did not inject an invalid ID into the query.
	     *-question_id: the ID of the question to load. If no ID is supplied, return a list of all questions.
	     *NOTE: code, survey_id and questions_id must all be valid and part of the same record
	     *otherwise a question can be loaded from a different survey based on its ID. 
	     */
	}
	       
}

</cfscript>