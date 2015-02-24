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
	    
	    
	    
	    writedump(req.getData('q_code')); 
	    
	    writedump(cgi);
	    
            /*
	     *validate the users survey code
	     */
	    
	    
	    /*
	     *store the logged in status in the session.
	     */
	    
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