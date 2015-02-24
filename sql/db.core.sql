/*
select * 
  from information_schema.columns 
 where table_name = 'survey_question_table'; 
*/

Drop database rde_survey; 
CREATE database rde_survey; 
USE rde_survey; 

CREATE TABLE question_type (
	entity_id	int		not null	IDENTITY(1,1)	PRIMARY KEY, 
	[type]		char(10)	not null
); 

-- type of the answer permitted. EX: int, float, string. 
CREATE TABLE answer_type (
	entity_id int	not null IDENTITY(1,1)	PRIMARY KEY, 
	[type]		char(7)	not null,
);

-- Survey table
CREATE TABLE survey_table(
	entity_id	int	        not null IDENTITY(1,1)	PRIMARY KEY, 
	name		char(50)	not null, 
	[description]	char(150)	null
); 

-- Survey code table: stores the survey code and associted survey id. 
CREATE TABLE survey_code_table(
        entity_id       int             not null	IDENTITY(1,1) PRIMARY KEY,
		s_code		char(8)		not null, 
        s_id            int             not null        FOREIGN KEY REFERENCES survey_table(entity_id)
); 

CREATE TABLE question_table(
	entity_id	int	not null	IDENTITY(1,1)	PRIMARY KEY, 
	question	text	not null, 
	q_type		int     not null    FOREIGN KEY REFERENCES question_type(entity_id),	-- controls if the questions are radio buttons or checkboxes
	options		char	(150)	    null,	-- Answers options, delimited by the '|' simbol. 
	a_type		int     null        FOREIGN KEY REFERENCES answer_type(entity_id),
);

-- q_id - question id that the answer is assocciated with.
-- s_code_id - the survey code id the answer is assoccited with. (used for assocciting answer with individual takers). 
CREATE TABLE answer_table(
	entity_id	int not null	IDENTITY(1,1)	PRIMARY KEY, 
	q_id		int	        not null	FOREIGN KEY REFERENCES question_table(entity_id),
    s_code_id       int             not null        FOREIGN KEY REFERENCES survey_code_table(entity_id),
	value		varchar(150)		not null 
); 


CREATE TABLE survey_question_table(
	s_id		int     not null FOREIGN KEY REFERENCES survey_table(entity_id), 
	q_id		int	not null FOREIGN KEY REFERENCES question_table(entity_id), 
); 

-- Test Data
-- Default question types
-- checkbox - multiple answers permitted. 
-- radio - one answer selection permitted. 
-- text - open ended answer. 
INSERT INTO question_type ([type]) 
VALUES('checkbox'), ('radio'), ('text'); 

-- Default answer types
-- int - numeric value
-- float - floating point value
-- string - string value. 
-- date - string in a date format.  
INSERT INTO answer_type ([type]) 
VALUES('int'), ('float'), ('string'), ('date');

-- Test Survey
INSERT INTO survey_table (name, [description])
VALUES ('RDE-Test Survey', 'RDE-Test Survey'); 

-- Test Questions
INSERT INTO question_table(question, q_type, options, a_type)
VALUES('Access to Care: A patient was unable to get an appointment within 48 hours for an acute/serious problem', 
2, 'daily|weekly|monthly|Several times in the past 12 months|Once or twice in the pat 12 months|Not in the past 12 months|Does not apply or dont know', 
3), 
('Patient Identification: The wrong chart/medical record was used for a patient.', 
2, 'always|never|sometimes', 3), 
('How Many cigarettes does the patient smoke per day', 3, null, 1), 
('What Fruit to you like', 1, 'apple|bannana|peach|berries|pizza|I dont like Any', null); 

-- Link the questions to the survey.
INSERT INTO survey_question_table (s_id, q_id)
VALUES(1,1),(1,2),(1,3),(1,4); 

-- Survey code table link - the survey code will be generated automatically. 
INSERT INTO survey_code_table (s_code, s_id) 
VALUES('testsurv', 1); 