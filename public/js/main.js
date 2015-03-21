
function renderQuestion(resp) {

    if(resp.statusCode == 200) {
        //extract all of the parts.
        var question = resp.data.question[0];
        var options = resp.data.options;
        var answer = resp.data.answer;

        console.log(question.ENTITY_ID);

        //create the form element.
        var html =  '<form id="form-question-data" method="post" action="/survey/submitAnswer">';
        html += '<input type="hidden" name="q_id" value="' + question.ENTITY_ID + '"/>';
        html += '<input type="hidden" name="q_type" value="' + question.TYPE.trim() + '"/>';
        html += '<p id="p-question">' + resp.data.question[0].QUESTION + '</p>';

        var type = resp.data.question[0].TYPE.trim();

        console.log(type);

        if(type == 'radio' || type=='checkbox') {

            if (options && options.length && options.length > 0) {

                for (var i = 0; i < options.length; i++) {
                    html += "<input id='o_id-" + options[i].ENTITY_ID +
                    "' type='" + type.trim() +
                    "' name='answer'" +
                    "' value='" + options[i].VALUE.trim() + "' />" +
                    options[i].VALUE.trim() + "<br />";
                }
            }
        } else if (type=='text') {

            /*check if answer is set for the current question and
            set the data inside the id field and the value.
             */
            if(answer) {

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
    var answers = document.getElementsByName('answer');


    console.log(answers);
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