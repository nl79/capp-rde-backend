<cfscript>
    This.sessionManagement="Yes";

//this.loginStorage = "session";

   //writedump(getPageContext());
   //writedump(GetHttpRequestData());

    response = getPageContext().getResponse();
    response.setHeader("Access-Control-Expose-Headers","Set-Cookie");
    response.setHeader("Access-Control-Allow-Headers","Content-Type,Cookie");

    response.setHeader("Access-Control-Allow-Credentials","true");
    response.setHeader("Access-Control-Allow-Origin","null");
    response.setHeader("Access-Control-Allow-Methods","GET,PUT,POST,DELETE");
    //response.setHeader("Access-Control-Allow-Headers","Content-Type");


    //get the value of the valid flag to check if the user is logged in.
    valid = GetPageContext().GetSession().getValue('valid');

    objRequest = GetPageContext().GetRequest(); 
    strUrl = objRequest.GetRequestUrl();

    /*
     *extract the path_info and remove the first '/' from the string
     */
    path = RemoveChars(cgi.PATH_INFO, 1, 1);
    
    /*
     *split the string on '/' into nodes. 
     */
    nodes = path.split('/');
    
    //If the path_info and script name are the same, the user requested the root file.
    if(compare(cgi.PATH_INFO, cgi.SCRIPT_NAME) == 0 ||
        !isDefined('valid') || compare(valid, 'true') != 0) {

        /*
        check the current nodes
        If they are 'account/login' do not modify.
        */
        if(ArrayLen(nodes) >= 2) {
            if(compareNoCase(nodes[1], 'account') != 0 ||
                compareNoCase(nodes[2], 'login') != 0) {
                    nodes = [];
                    ArrayAppend(nodes, 'account');
                    ArrayAppend(nodes, 'login');
                }
        } else {
            nodes = [];

            /*
             *append a default route: survey
             *Action: login
             */
            ArrayAppend(nodes, 'account');
            ArrayAppend(nodes, 'index');
        }
        
    }
    
    /*
     *Parse the request URI and load the appropriate
     *Route.
     */
    
    router = new components.Router(nodes);
    
    router.loadRoute();  
    exit;

	queryService = new Query(); 
	
	queryService.setDatasource("rde_survey");
	queryService.setSQL('select * from question_table');
	result = queryService.execute();

</cfscript>                          