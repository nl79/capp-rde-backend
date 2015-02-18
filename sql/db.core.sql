/*
select * 
  from information_schema.columns 
 where table_name = 'survey_question_table'; 
*/

Drop database rde_survey; 
CREATE database rde_survey; 
USE rde_survey; 
 
CREATE TABLE user_table(
entity_id	int		not null	PRIMARY KEY, 

); 

CREATE TABLE question_type (
	entity_id	int		not null	PRIMARY KEY, 
	name		char(10)	not null
); 
 
CREATE TABLE question_table(
	entity_id	int	not null	PRIMARY KEY, 
	question	text	not null, 
	q_type		int not null FOREIGN KEY REFERENCES question_type(entity_id),	-- controls if the questions are radio buttons or checkboxes

); 

CREATE TABLE answer_table(
	entity_id	int not null	PRIMARY KEY, 
	q_id		int	not null	FOREIGN KEY REFERENCES question_table(entity_id), 
	value		char(50)		not null 
); 

-- Survey table
CREATE TABLE survey_table(
	entity_id	int	not null	PRIMARY KEY, 
	name		char(50)		not null, 
	[description]	char(150)	null
); 

CREATE TABLE survey_question_table(
	s_id		int not null FOREIGN KEY REFERENCES survey_table(entity_id), 
	q_id		int	not null FOREIGN KEY REFERENCES question_table(entity_id)
); 