/*==============================================================*/
/* DBMS name:      PostgreSQL 9.x                               */
/* Created on:     18.05.2016 2:24:25                           */
/*==============================================================*/

/*==============================================================*/
/* Table: calculation_data                                      */
/*==============================================================*/
create table calculation_data (
   calculation_data_id  SERIAL               not null,
   protocol_id          INT4                 not null,
   expression           VARCHAR(512)         not null,
   result               VARCHAR(256)         null,
   microsecs_execution_time INT8             null,
   constraint PK_CALCULATION_DATA primary key (calculation_data_id)
);

GRANT ALL PRIVILEGES ON TABLE calculation_data TO "user";

/*==============================================================*/
/* Index: calculation_data_PK                                   */
/*==============================================================*/
create unique index calculation_data_PK on calculation_data (
calculation_data_id
);

/*==============================================================*/
/* Index: calc_protocol_FK                                      */
/*==============================================================*/
create  index calc_protocol_FK on calculation_data (
protocol_id
);

/*==============================================================*/
/* Table: event_dic                                             */
/*==============================================================*/
create table event_dic (
   event_id             SERIAL               not null,
   event_type_code      CHAR(1)              not null,
   name                 VARCHAR(256)         not null,
   constraint PK_EVENT_DIC primary key (event_id),
   constraint AK_U_EVENT_NAME_EVENT_DI unique (name)
);

GRANT ALL PRIVILEGES ON TABLE event_dic TO "user";

INSERT INTO event_dic
       (event_id, event_type_code, name)
VALUES (1, 'S', 'Successful login');
INSERT INTO event_dic
       (event_id, event_type_code, name)
VALUES (2, 'E', 'Unsuccessful login');
INSERT INTO event_dic
       (event_id, event_type_code, name)
VALUES (3, 'C', 'Critical error');
INSERT INTO event_dic
       (event_id, event_type_code, name)
VALUES (4, 'S', 'Successful expression value calculation');
INSERT INTO event_dic
       (event_id, event_type_code, name)
VALUES (5, 'E', 'Error while trying to calculate expression value');

/*==============================================================*/
/* Index: event_dic_PK                                          */
/*==============================================================*/
create unique index event_dic_PK on event_dic (
event_id
);

/*==============================================================*/
/* Index: evnt_type_FK                                          */
/*==============================================================*/
create  index evnt_type_FK on event_dic (
event_type_code
);

/*==============================================================*/
/* Table: event_type_dic                                        */
/*==============================================================*/
create table event_type_dic (
   event_type_code      CHAR(1)              not null,
   name                 VARCHAR(256)         not null,
   constraint PK_EVENT_TYPE_DIC primary key (event_type_code),
   constraint AK_U_EVENT_TYPE_NAME_EVENT_TY unique (name)
);

GRANT ALL PRIVILEGES ON TABLE event_type_dic TO "user";

INSERT INTO event_type_dic
       (event_type_code, name)
VALUES ('C', 'Critical error');
INSERT INTO event_type_dic
       (event_type_code, name)
VALUES ('E', 'Error');
INSERT INTO event_type_dic
       (event_type_code, name)
VALUES ('W', 'Warning');
INSERT INTO event_type_dic
       (event_type_code, name)
VALUES ('I', 'Information');
INSERT INTO event_type_dic
       (event_type_code, name)
VALUES ('S', 'Success');
INSERT INTO event_type_dic
       (event_type_code, name)
VALUES ('T', 'Trace');

/*==============================================================*/
/* Index: event_type_dic_PK                                     */
/*==============================================================*/
create unique index event_type_dic_PK on event_type_dic (
event_type_code
);

/*==============================================================*/
/* Table: protocol                                              */
/*==============================================================*/
create table protocol (
   protocol_id          SERIAL               not null,
   user_id              INT4                 not null,
   event_id             INT4                 not null,
   event_datetime       DATE                 not null default CURRENT_TIMESTAMP,
   description          VARCHAR(256)         null,
   constraint PK_PROTOCOL primary key (protocol_id)
);

GRANT ALL PRIVILEGES ON TABLE protocol TO "user";

/*==============================================================*/
/* Index: protocol_PK                                           */
/*==============================================================*/
create unique index protocol_PK on protocol (
protocol_id
);

/*==============================================================*/
/* Index: prtcl_usr_FK                                          */
/*==============================================================*/
create  index prtcl_usr_FK on protocol (
user_id
);

/*==============================================================*/
/* Index: prtcl_evnt_FK                                         */
/*==============================================================*/
create  index prtcl_evnt_FK on protocol (
event_id
);

/*==============================================================*/
/* Table: user_dic                                              */
/*==============================================================*/
create table user_dic (
   user_id              SERIAL               not null,
   user_name            VARCHAR(256)         not null,
   first_name           VARCHAR(256)         null,
   last_name            VARCHAR(256)         null,
   description          VARCHAR(256)         null,
   constraint PK_USER_DIC primary key (user_id),
   constraint AK_U_USER_NAME_USER_DIC unique (user_name)
);

GRANT ALL PRIVILEGES ON TABLE user_dic TO "user";

INSERT INTO user_dic
       (user_id, user_name)
VALUES (1, 'user');
       

/*==============================================================*/
/* Index: user_dic_PK                                           */
/*==============================================================*/
create unique index user_dic_PK on user_dic (
user_id
);

/*==============================================================*/
/* View: v_calculation_data                                     */
/*==============================================================*/
create or replace view v_calculation_data as
SELECT calculation_data.calculation_data_id              AS calculation_data_id,
       calculation_data.protocol_id                      AS protocol_id,
       calculation_data.expression                       AS expression, 
       calculation_data.result                           AS result,
       calculation_data.microsecs_execution_time         AS microsecs_execution_time,
       protocol.user_id                                  AS user_id,
       protocol.event_id                                 AS event_id,
       protocol.event_datetime                           AS event_datetime,
       protocol.description                              AS protocol_description,
       user_dic.user_name                                AS user_name,
       user_dic.first_name                               AS user_first_name, 
       user_dic.last_name                                AS user_last_name, 
       user_dic.description                              AS user_description,
       event_dic.event_type_code                         AS event_type_code,
       event_dic.name                                    AS event_name,
       event_type_dic.name                               AS event_type_name
  FROM calculation_data,
       protocol,
       user_dic,
       event_dic,
       event_type_dic
 WHERE (calculation_data.protocol_id = protocol.protocol_id)
   AND (user_dic.user_id = protocol.user_id)
   AND (event_dic.event_id = protocol.event_id)
   AND (event_type_dic.event_type_code = event_dic.event_type_code);

GRANT SELECT ON v_calculation_data TO "user";

GRANT SELECT ON ALL SEQUENCES IN SCHEMA "public" TO "user";

alter table calculation_data
   add constraint FK_CALCULAT_CALC_PROT_PROTOCOL foreign key (protocol_id)
      references protocol (protocol_id)
      on delete restrict on update restrict;

alter table event_dic
   add constraint FK_EVENT_DI_EVNT_TYPE_EVENT_TY foreign key (event_type_code)
      references event_type_dic (event_type_code)
      on delete restrict on update restrict;

alter table protocol
   add constraint FK_PROTOCOL_PRTCL_EVN_EVENT_DI foreign key (event_id)
      references event_dic (event_id)
      on delete restrict on update restrict;

alter table protocol
   add constraint FK_PROTOCOL_PRTCL_USR_USER_DIC foreign key (user_id)
      references user_dic (user_id)
      on delete restrict on update restrict;

