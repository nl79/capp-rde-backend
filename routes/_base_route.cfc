<cfscript>

component _base_route
	output="false"
	{
    variables.this;
        /*
	 *base route constructor
	 */
        _base_route function init() {
            variables.this = this;
	    return( this ); 
        }
	
	/*
	 *@method: getSession() - return a reference to the current session object
	 */
	function getSession() {
	    return GetPageContext().GetSession(); 
	}
	
	/*
	 *@method: getRequest() - Build a request componenet and return a reference
	 */
	function getRequest() {
	    return new components.Request(); 
	}

    function getQuery(sql) {
        var q = new Query();

        q.setDatasource("rde_survey").setSQL(sql);

        return q;
    }
	
	/*
	 *@method: userValid() - checks if the user data is valid and the user is logged in.
	 */
	function userValid() {
	        
	    var sess = GetPageContext().GetSession();;
	    
	    
	    flag = sess.getValue('valid');
	    
	    if(isDefined("flag") && compare('true', flag) == 0) {
		
		return true; 
	    } else {
		
		//redirect to the login page.
		location('/account/login');
		exit;
		
	    }
	    
	}

    function buildDataObj(obj) {

        if(obj.recordcount > 0) {
        //create a collection structure.
            var collection = StructNew();

            //extract the columns and split them into an array.
            var cols = obj.ColumnList.split(',');

            //loop through each result.
            for(var i = 1; i <= obj.recordcount; i++) {
                var row = StructNew();

                for(field in cols) {
                    row[field] = obj[field][i];

                }
                collection[obj['entity_id'][i]] = row;
                //collection[i] = row;
            }

            return collection;

        }
    }
}

</cfscript>