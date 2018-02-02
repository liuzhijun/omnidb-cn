UPDATE db_type SET dbt_in_enabled = 1 WHERE dbt_st_name = 'oracle';--omnidb--

ALTER TABLE users
ADD COLUMN stc_in_code integer;--omnidb--

ALTER TABLE users
ADD COLUMN use_bo_bot integer;--omnidb--

UPDATE users
SET stc_in_code = 1,
    use_bo_bot = 0;--omnidb--

DROP TABLE messages;--omnidb--

DROP TABLE messages_users;--omnidb--

CREATE TABLE channels (
    cha_in_code integer not null,
    cha_st_name text,
    cha_bo_private integer not null,
    constraint pk_channels primary key (cha_in_code)
);--omnidb--
INSERT INTO channels VALUES(1, 'General', 0);--omnidb--

CREATE TABLE groups (
    gro_in_code integer not null,
    constraint pk_groups primary key (gro_in_code)
);--omnidb--

CREATE TABLE messages_types (
    met_in_code integer not null,
    met_st_description text,
    constraint pk_messages_types primary key (met_in_code)
);--omnidb--
INSERT INTO messages_types VALUES(1, 'Plain Text');--omnidb--
INSERT INTO messages_types VALUES(2, 'Pasted Image');--omnidb--
INSERT INTO messages_types VALUES(3, 'Snippet');--omnidb--
INSERT INTO messages_types VALUES(4, 'Attachment');--omnidb--
INSERT INTO messages_types VALUES(5, 'Mention');--omnidb--

CREATE TABLE messages (
    mes_in_code integer not null,
    mes_dt_creation text not null,
    mes_dt_update text not null,
    use_in_code integer not null,
    met_in_code integer not null,
    mes_st_content text,
    mes_st_title text,
    mes_st_attachmentname text,
    mes_st_attachmentpath text,
    mes_st_snippetmode text,
    mes_st_originalcontent text,
    constraint pk_messages primary key (mes_in_code),
    constraint messages_fk_0 foreign key (use_in_code) references users (user_id)  on update CASCADE  on delete CASCADE ,
    constraint messages_fk_1 foreign key (met_in_code) references messages_types (met_in_code)  on update CASCADE  on delete CASCADE
);--omnidb--

CREATE TABLE messages_channels (
    mes_in_code integer not null,
    cha_in_code integer not null,
    use_in_code integer not null,
    mec_bo_viewed integer not null,
    constraint pk_messages_channels primary key (mes_in_code, cha_in_code, use_in_code),
    constraint messages_channels_fk_0 foreign key (use_in_code) references users (user_id)  on update CASCADE  on delete CASCADE ,
    constraint messages_channels_fk_1 foreign key (mes_in_code) references messages (mes_in_code)  on update CASCADE  on delete CASCADE ,
    constraint messages_channels_fk_2 foreign key (cha_in_code) references channels (cha_in_code)  on update CASCADE  on delete CASCADE
);--omnidb--

CREATE TABLE messages_groups (
    mes_in_code integer not null,
    gro_in_code integer not null,
    use_in_code integer not null,
    meg_bo_viewed integer not null,
    constraint pk_messages_groups primary key (mes_in_code, gro_in_code, use_in_code),
    constraint messages_groups_fk_0 foreign key (use_in_code) references users (user_id)  on update CASCADE  on delete CASCADE ,
    constraint messages_groups_fk_1 foreign key (mes_in_code) references messages (mes_in_code)  on update CASCADE  on delete CASCADE ,
    constraint messages_groups_fk_2 foreign key (gro_in_code) references groups (gro_in_code)  on update CASCADE  on delete CASCADE
);--omnidb--

CREATE TABLE status_chat (
    stc_in_code integer not null,
    stc_st_name text not null,
    constraint pk_status_chat primary key (stc_in_code)
);--omnidb--
INSERT INTO status_chat VALUES(1, 'None');--omnidb--
INSERT INTO status_chat VALUES(2, 'In a Meeting');--omnidb--
INSERT INTO status_chat VALUES(3, 'Remote Work');--omnidb--
INSERT INTO status_chat VALUES(4, 'Busy');--omnidb--

CREATE TABLE users_channels (
    use_in_code integer not null,
    cha_in_code integer not null,
    usc_bo_silenced integer not null,
    constraint pk_users_channels primary key (use_in_code, cha_in_code),
    constraint users_channels_fk_0 foreign key (use_in_code) references users (user_id)  on update CASCADE  on delete CASCADE ,
    constraint users_channels_fk_1 foreign key (cha_in_code) references channels (cha_in_code)  on update CASCADE  on delete CASCADE
);--omnidb--
INSERT INTO users_channels (use_in_code, cha_in_code, usc_bo_silenced)
SELECT user_id as use_in_code,
       1 as cha_in_code,
       0 as usc_bo_silenced
from users;--omnidb--

CREATE TABLE users_groups (
    use_in_code integer not null,
    gro_in_code integer not null,
    usg_bo_silenced integer not null,
    constraint pk_users_groups primary key (use_in_code, gro_in_code),
    constraint users_groups_fk_0 foreign key (use_in_code) references users (user_id)  on update CASCADE  on delete CASCADE ,
    constraint users_groups_fk_1 foreign key (gro_in_code) references groups (gro_in_code)  on update CASCADE  on delete CASCADE
);--omnidb--

CREATE TABLE user_group_tmp (
    group_id integer not null,
    user_id_a integer not null,
    user_id_b integer not null,
    constraint pk_messages_groups primary key (group_id)
);--omnidb--

INSERT INTO user_group_tmp (user_id_a, user_id_b)
SELECT a.user_id AS user_id_a,
       b.user_id AS user_id_b
FROM users a
INNER JOIN users b ON 1 = 1
WHERE b.user_id < a.user_id;--omnidb--

INSERT INTO groups (gro_in_code)
SELECT group_id
FROM user_group_tmp;--omnidb--

INSERT INTO users_groups (use_in_code, gro_in_code, usg_bo_silenced)
SELECT user_id_a, group_id, 0
FROM user_group_tmp
UNION ALL
SELECT user_id_b, group_id, 0
FROM user_group_tmp;--omnidb--

DROP TABLE user_group_tmp;--omnidb--

UPDATE version SET ver_id = '2.5.0';--omnidb--