
$(document).ready(function() {
    $('button#button-start-survey').on('click', function(e){
        var settings = {
            url: '/survey/loadLast',
            type: 'GET',
            data: '',
            dataType: 'json'
        };

        var callback = function(data) {
            console.log(data);
        }

        $.ajax(settings).done(callback);

    })
})