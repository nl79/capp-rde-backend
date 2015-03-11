
$(function() {
    
    $('#btn-login').on('click', function() {
        //make an ajax call with the textsurv data.
        var s_code = $('#input-s_code').val();
        
        if (!s_code) {
            alert('Survey code Required');
            return; 
        }
        
        var settings = {
            'url': '/account/login/',
            'data': 's_code=' + s_code,
            'complete': function(data) {
                console.log(data); 
            },
            'dataType': 'json'
        };
        
        
        $.ajax(settings); 
    }); 
}); 