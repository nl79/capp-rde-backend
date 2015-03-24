
function renderQuestion(resp) {

    if(resp.statusCode == 200) {
        //extract all of the parts.
        var question = resp.data.question[0];
        var options = resp.data.options;
        var answer = resp.data.answer;

        //create the form element.
        var html =  '<form id="form-question-data" method="post" action="/survey/submitAnswer">';
        html += '<input type="hidden" name="q_id" value="' + question.ENTITY_ID + '"/>';
        html += '<input type="hidden" name="q_type" value="' + question.TYPE.trim() + '"/>';
        html += '<input type="hidden" name="a_type" value="' + question.A_TYPE + '"/>';
        html += '<p id="p-question">' + resp.data.question[0].QUESTION + '</p>';

        var type = resp.data.question[0].TYPE.trim();

        console.log(type);

        if(type == 'radio' || type=='checkbox') {

            if (options && options.length && options.length > 0) {

                for (var i = 0; i < options.length; i++) {
                    html += "<input id='o_id-" + options[i].ENTITY_ID +
                    "' type='" + type.trim() +
                    "' name='answer'" +
                    "' value='" + options[i].ENTITY_ID + "' />" +
                    options[i].VALUE.trim() + "<br />";
                }
            }
        } else if (type=='text') {

            /*check if answer is set for the current question and
            set the data inside the id field and the value.
             */
            if(answer) {
                console.log('here');
                console.log(answer);
            }  else {
                html += "<textarea class='text' name='answer'></textarea><br />";
            }

        }


        html += "<button onclick='submitAnswer(this)' id='button-submit' type='button' name='submit' value='submit'>Submit</button>";
        html += '</form>';

        document.getElementById('div-content').innerHTML = html;
    }

}

function submitAnswer(ele){

    //serialize the form.
    var data = $('form#form-question-data').serialize();

    var settings = {
        url: '/survey/save',
        type: 'POST',
        data: data,
        dataType: 'json'
    };

    var callback = function(data) {
        console.log(data);
    }

    $.ajax(settings).done(callback);

}

$(document).ready(function() {
    $('button#button-start-survey').on('click', function(e){
        var settings = {
            url: '/survey/loadLast',
            type: 'GET',
            data: '',
            dataType: 'json'
        };

        var callback = function(data) {
            renderQuestion(data);
        }

        $.ajax(settings).done(callback);

    })
})