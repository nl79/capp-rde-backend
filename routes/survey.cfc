<cfscript>

component Survey
	output="false"
	extends="_base_route"
	{
         
        function actionIndex() {
	    
	    writedump('survey-index');
	    
	    /*load the initial questions.
	     *if questions are saved, load the last question with out an answer.
	     */
	    
	    //run the validation method to redirect to the login
	    //page if the user is not logged in. 
	    super.userValid();
	    
	    
	    
	    
	    
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
	     *-terms of service signed?
	     */
	}
	       
}

</cfscript>