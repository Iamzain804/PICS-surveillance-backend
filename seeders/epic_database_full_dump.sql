--
-- PostgreSQL database dump
--

\restrict Ims2cupM0I1wiNduvyNIDLju3JLW0Dv8mGJu0uSoBtB7qnJpKQLY3k2nVRQXxW4

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_role_id_fkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_department_id_fkey;
ALTER TABLE IF EXISTS ONLY public.staff DROP CONSTRAINT IF EXISTS staff_department_id_fkey;
ALTER TABLE IF EXISTS ONLY public.staff DROP CONSTRAINT IF EXISTS staff_branch_id_fkey;
ALTER TABLE IF EXISTS ONLY public.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_role_id_fkey;
ALTER TABLE IF EXISTS ONLY public.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_permission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.review_queue DROP CONSTRAINT IF EXISTS review_queue_event_id_fkey;
ALTER TABLE IF EXISTS ONLY public.person_track_logs DROP CONSTRAINT IF EXISTS person_track_logs_video_log_id_fkey;
ALTER TABLE IF EXISTS ONLY public.events DROP CONSTRAINT IF EXISTS events_video_id_fkey;
ALTER TABLE IF EXISTS ONLY public.department_shifts DROP CONSTRAINT IF EXISTS department_shifts_department_id_fkey;
ALTER TABLE IF EXISTS ONLY public.cameras DROP CONSTRAINT IF EXISTS cameras_branch_id_fkey;
ALTER TABLE IF EXISTS ONLY public.branch_activities DROP CONSTRAINT IF EXISTS branch_activities_branch_id_fkey;
DROP INDEX IF EXISTS public.ix_videos_id;
DROP INDEX IF EXISTS public.ix_videos_folder_type;
DROP INDEX IF EXISTS public.ix_videos_filename;
DROP INDEX IF EXISTS public.ix_video_processing_logs_video_name;
DROP INDEX IF EXISTS public.ix_video_processing_logs_id;
DROP INDEX IF EXISTS public.ix_users_username;
DROP INDEX IF EXISTS public.ix_users_id;
DROP INDEX IF EXISTS public.ix_users_email;
DROP INDEX IF EXISTS public.ix_system_logs_id;
DROP INDEX IF EXISTS public.ix_staff_staff_id;
DROP INDEX IF EXISTS public.ix_staff_id;
DROP INDEX IF EXISTS public.ix_staff_email;
DROP INDEX IF EXISTS public.ix_staff_department_id;
DROP INDEX IF EXISTS public.ix_staff_branch_id;
DROP INDEX IF EXISTS public.ix_roles_name;
DROP INDEX IF EXISTS public.ix_roles_id;
DROP INDEX IF EXISTS public.ix_review_queue_id;
DROP INDEX IF EXISTS public.ix_review_queue_event_id;
DROP INDEX IF EXISTS public.ix_person_track_logs_id;
DROP INDEX IF EXISTS public.ix_permissions_name;
DROP INDEX IF EXISTS public.ix_permissions_id;
DROP INDEX IF EXISTS public.ix_events_video_id;
DROP INDEX IF EXISTS public.ix_events_id;
DROP INDEX IF EXISTS public.ix_events_employee_id;
DROP INDEX IF EXISTS public.ix_events_camera_role;
DROP INDEX IF EXISTS public.ix_departments_name;
DROP INDEX IF EXISTS public.ix_departments_id;
DROP INDEX IF EXISTS public.ix_department_shifts_id;
DROP INDEX IF EXISTS public.ix_cameras_id;
DROP INDEX IF EXISTS public.ix_cameras_camera_id;
DROP INDEX IF EXISTS public.ix_cameras_branch_id;
DROP INDEX IF EXISTS public.ix_branches_name;
DROP INDEX IF EXISTS public.ix_branches_id;
DROP INDEX IF EXISTS public.ix_branch_activities_id;
DROP INDEX IF EXISTS public.ix_branch_activities_branch_id;
DROP INDEX IF EXISTS public.ix_branch_activities_activity_id;
DROP INDEX IF EXISTS public.ix_activities_id;
DROP INDEX IF EXISTS public.ix_activities_activity_id;
ALTER TABLE IF EXISTS ONLY public.videos DROP CONSTRAINT IF EXISTS videos_pkey;
ALTER TABLE IF EXISTS ONLY public.video_processing_logs DROP CONSTRAINT IF EXISTS video_processing_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.events DROP CONSTRAINT IF EXISTS uq_events_video_track_frame;
ALTER TABLE IF EXISTS ONLY public.system_logs DROP CONSTRAINT IF EXISTS system_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.staff DROP CONSTRAINT IF EXISTS staff_pkey;
ALTER TABLE IF EXISTS ONLY public.roles DROP CONSTRAINT IF EXISTS roles_pkey;
ALTER TABLE IF EXISTS ONLY public.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_pkey;
ALTER TABLE IF EXISTS ONLY public.review_queue DROP CONSTRAINT IF EXISTS review_queue_pkey;
ALTER TABLE IF EXISTS ONLY public.person_track_logs DROP CONSTRAINT IF EXISTS person_track_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.permissions DROP CONSTRAINT IF EXISTS permissions_pkey;
ALTER TABLE IF EXISTS ONLY public.events DROP CONSTRAINT IF EXISTS events_pkey;
ALTER TABLE IF EXISTS ONLY public.departments DROP CONSTRAINT IF EXISTS departments_pkey;
ALTER TABLE IF EXISTS ONLY public.department_shifts DROP CONSTRAINT IF EXISTS department_shifts_pkey;
ALTER TABLE IF EXISTS ONLY public.cameras DROP CONSTRAINT IF EXISTS cameras_pkey;
ALTER TABLE IF EXISTS ONLY public.branches DROP CONSTRAINT IF EXISTS branches_pkey;
ALTER TABLE IF EXISTS ONLY public.branch_activities DROP CONSTRAINT IF EXISTS branch_activities_pkey;
ALTER TABLE IF EXISTS ONLY public.alembic_version DROP CONSTRAINT IF EXISTS alembic_version_pkc;
ALTER TABLE IF EXISTS ONLY public.activities DROP CONSTRAINT IF EXISTS activities_pkey;
ALTER TABLE IF EXISTS ONLY public.activities DROP CONSTRAINT IF EXISTS activities_name_key;
ALTER TABLE IF EXISTS public.videos ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.video_processing_logs ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.users ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.system_logs ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.staff ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.roles ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.review_queue ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.person_track_logs ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.permissions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.events ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.departments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.department_shifts ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.cameras ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.branches ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.branch_activities ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.activities ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.videos_id_seq;
DROP TABLE IF EXISTS public.videos;
DROP SEQUENCE IF EXISTS public.video_processing_logs_id_seq;
DROP TABLE IF EXISTS public.video_processing_logs;
DROP SEQUENCE IF EXISTS public.users_id_seq;
DROP TABLE IF EXISTS public.users;
DROP SEQUENCE IF EXISTS public.system_logs_id_seq;
DROP TABLE IF EXISTS public.system_logs;
DROP SEQUENCE IF EXISTS public.staff_id_seq;
DROP TABLE IF EXISTS public.staff;
DROP SEQUENCE IF EXISTS public.roles_id_seq;
DROP TABLE IF EXISTS public.roles;
DROP TABLE IF EXISTS public.role_permissions;
DROP SEQUENCE IF EXISTS public.review_queue_id_seq;
DROP TABLE IF EXISTS public.review_queue;
DROP SEQUENCE IF EXISTS public.person_track_logs_id_seq;
DROP TABLE IF EXISTS public.person_track_logs;
DROP SEQUENCE IF EXISTS public.permissions_id_seq;
DROP TABLE IF EXISTS public.permissions;
DROP SEQUENCE IF EXISTS public.events_id_seq;
DROP TABLE IF EXISTS public.events;
DROP SEQUENCE IF EXISTS public.departments_id_seq;
DROP TABLE IF EXISTS public.departments;
DROP SEQUENCE IF EXISTS public.department_shifts_id_seq;
DROP TABLE IF EXISTS public.department_shifts;
DROP SEQUENCE IF EXISTS public.cameras_id_seq;
DROP TABLE IF EXISTS public.cameras;
DROP SEQUENCE IF EXISTS public.branches_id_seq;
DROP TABLE IF EXISTS public.branches;
DROP SEQUENCE IF EXISTS public.branch_activities_id_seq;
DROP TABLE IF EXISTS public.branch_activities;
DROP TABLE IF EXISTS public.alembic_version;
DROP SEQUENCE IF EXISTS public.activities_id_seq;
DROP TABLE IF EXISTS public.activities;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activities (
    id integer NOT NULL,
    activity_id character varying NOT NULL,
    name character varying NOT NULL,
    description character varying,
    types character varying,
    status character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.activities OWNER TO postgres;

--
-- Name: activities_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.activities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.activities_id_seq OWNER TO postgres;

--
-- Name: activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.activities_id_seq OWNED BY public.activities.id;


--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO postgres;

--
-- Name: branch_activities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.branch_activities (
    id integer NOT NULL,
    branch_id integer NOT NULL,
    activity_id character varying NOT NULL,
    name character varying NOT NULL,
    floor character varying,
    camera_direction character varying,
    camera_id character varying,
    camera_name character varying,
    camera_ids character varying,
    description character varying,
    status character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.branch_activities OWNER TO postgres;

--
-- Name: branch_activities_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.branch_activities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.branch_activities_id_seq OWNER TO postgres;

--
-- Name: branch_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.branch_activities_id_seq OWNED BY public.branch_activities.id;


--
-- Name: branches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.branches (
    id integer NOT NULL,
    name character varying NOT NULL,
    address character varying,
    phone character varying,
    manager_name character varying,
    status character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.branches OWNER TO postgres;

--
-- Name: branches_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.branches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.branches_id_seq OWNER TO postgres;

--
-- Name: branches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.branches_id_seq OWNED BY public.branches.id;


--
-- Name: cameras; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cameras (
    id integer NOT NULL,
    camera_id character varying NOT NULL,
    name character varying NOT NULL,
    branch_id integer NOT NULL,
    location character varying,
    camera_type character varying,
    sub_location character varying,
    rtsp_url character varying,
    is_checkin boolean,
    is_checkout boolean,
    status character varying,
    created_at timestamp without time zone,
    activity_id character varying,
    activity_name character varying,
    recording_path character varying,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.cameras OWNER TO postgres;

--
-- Name: cameras_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cameras_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cameras_id_seq OWNER TO postgres;

--
-- Name: cameras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cameras_id_seq OWNED BY public.cameras.id;


--
-- Name: department_shifts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.department_shifts (
    id integer NOT NULL,
    department_id integer NOT NULL,
    shift_name character varying,
    shift_start character varying,
    shift_end character varying,
    grace_time_mins integer,
    break_start character varying,
    break_end character varying,
    days character varying,
    early_departure_buffer_mins integer DEFAULT 10
);


ALTER TABLE public.department_shifts OWNER TO postgres;

--
-- Name: department_shifts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.department_shifts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.department_shifts_id_seq OWNER TO postgres;

--
-- Name: department_shifts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.department_shifts_id_seq OWNED BY public.department_shifts.id;


--
-- Name: departments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.departments (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    is_active boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    shift_name character varying,
    shift_start character varying,
    shift_end character varying,
    grace_time_mins integer,
    break_start character varying,
    break_end character varying,
    early_departure_buffer_mins integer DEFAULT 10
);


ALTER TABLE public.departments OWNER TO postgres;

--
-- Name: departments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.departments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.departments_id_seq OWNER TO postgres;

--
-- Name: departments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.departments_id_seq OWNED BY public.departments.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.events (
    id integer NOT NULL,
    video_id integer,
    camera_role character varying,
    track_id integer NOT NULL,
    event_type character varying,
    "timestamp" character varying,
    frame_number integer NOT NULL,
    confidence double precision,
    status character varying,
    created_at timestamp without time zone,
    employee_id character varying,
    employee_name character varying,
    recognition_confidence double precision,
    recognition_status character varying,
    recognized_at timestamp without time zone
);


ALTER TABLE public.events OWNER TO postgres;

--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.events_id_seq OWNER TO postgres;

--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.permissions (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    "group" character varying NOT NULL
);


ALTER TABLE public.permissions OWNER TO postgres;

--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.permissions_id_seq OWNER TO postgres;

--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.permissions_id_seq OWNED BY public.permissions.id;


--
-- Name: person_track_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.person_track_logs (
    id integer NOT NULL,
    video_log_id integer NOT NULL,
    video_name character varying(255) NOT NULL,
    track_id integer NOT NULL,
    master_track_id integer NOT NULL,
    status character varying(50) NOT NULL,
    person_name character varying(255) NOT NULL,
    person_id character varying(100),
    confidence double precision,
    first_seen_time character varying(100),
    last_seen_time character varying(100),
    total_hits integer,
    created_at timestamp without time zone
);


ALTER TABLE public.person_track_logs OWNER TO postgres;

--
-- Name: person_track_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.person_track_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.person_track_logs_id_seq OWNER TO postgres;

--
-- Name: person_track_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.person_track_logs_id_seq OWNED BY public.person_track_logs.id;


--
-- Name: review_queue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.review_queue (
    id integer NOT NULL,
    event_id integer NOT NULL,
    suggested_staff_id character varying,
    confidence double precision,
    status character varying,
    face_crop_path character varying,
    created_at timestamp without time zone
);


ALTER TABLE public.review_queue OWNER TO postgres;

--
-- Name: review_queue_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.review_queue_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.review_queue_id_seq OWNER TO postgres;

--
-- Name: review_queue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.review_queue_id_seq OWNED BY public.review_queue.id;


--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role_permissions (
    role_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.role_permissions OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying NOT NULL,
    is_active boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: staff; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.staff (
    id integer NOT NULL,
    staff_id character varying NOT NULL,
    name character varying NOT NULL,
    email character varying NOT NULL,
    phone character varying,
    role character varying,
    is_active boolean,
    has_face_encoding boolean,
    profile_picture character varying,
    branch_id integer,
    department_id integer,
    shift_start_time character varying,
    shift_end_time character varying,
    is_visitor boolean,
    visitor_expiry timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    registration_video character varying
);


ALTER TABLE public.staff OWNER TO postgres;

--
-- Name: staff_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.staff_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.staff_id_seq OWNER TO postgres;

--
-- Name: staff_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.staff_id_seq OWNED BY public.staff.id;


--
-- Name: system_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.system_logs (
    id integer NOT NULL,
    "timestamp" timestamp without time zone,
    level character varying,
    module character varying,
    message character varying
);


ALTER TABLE public.system_logs OWNER TO postgres;

--
-- Name: system_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.system_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.system_logs_id_seq OWNER TO postgres;

--
-- Name: system_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.system_logs_id_seq OWNED BY public.system_logs.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying NOT NULL,
    email character varying NOT NULL,
    hashed_password character varying NOT NULL,
    full_name character varying,
    role character varying,
    role_id integer,
    department_id integer,
    is_active boolean,
    is_super_admin boolean,
    is_first_login boolean,
    created_at timestamp without time zone,
    last_login timestamp without time zone,
    reset_token character varying
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: video_processing_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.video_processing_logs (
    id integer NOT NULL,
    video_name character varying(255) NOT NULL,
    video_start_timestamp character varying(100),
    total_frames_processed integer,
    total_unique_tracks integer,
    authorized_count integer,
    unauthorized_count integer,
    authorized_persons character varying,
    processed_at timestamp without time zone
);


ALTER TABLE public.video_processing_logs OWNER TO postgres;

--
-- Name: video_processing_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.video_processing_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.video_processing_logs_id_seq OWNER TO postgres;

--
-- Name: video_processing_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.video_processing_logs_id_seq OWNED BY public.video_processing_logs.id;


--
-- Name: videos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.videos (
    id integer NOT NULL,
    filename character varying,
    folder_type character varying,
    file_path character varying,
    file_size_mb double precision,
    duration_seconds double precision,
    resolution character varying,
    fps double precision,
    video_start_time character varying,
    camera_name character varying,
    status character varying,
    created_at timestamp without time zone
);


ALTER TABLE public.videos OWNER TO postgres;

--
-- Name: videos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.videos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.videos_id_seq OWNER TO postgres;

--
-- Name: videos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.videos_id_seq OWNED BY public.videos.id;


--
-- Name: activities id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities ALTER COLUMN id SET DEFAULT nextval('public.activities_id_seq'::regclass);


--
-- Name: branch_activities id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branch_activities ALTER COLUMN id SET DEFAULT nextval('public.branch_activities_id_seq'::regclass);


--
-- Name: branches id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branches ALTER COLUMN id SET DEFAULT nextval('public.branches_id_seq'::regclass);


--
-- Name: cameras id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cameras ALTER COLUMN id SET DEFAULT nextval('public.cameras_id_seq'::regclass);


--
-- Name: department_shifts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department_shifts ALTER COLUMN id SET DEFAULT nextval('public.department_shifts_id_seq'::regclass);


--
-- Name: departments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments ALTER COLUMN id SET DEFAULT nextval('public.departments_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);


--
-- Name: person_track_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person_track_logs ALTER COLUMN id SET DEFAULT nextval('public.person_track_logs_id_seq'::regclass);


--
-- Name: review_queue id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.review_queue ALTER COLUMN id SET DEFAULT nextval('public.review_queue_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: staff id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff ALTER COLUMN id SET DEFAULT nextval('public.staff_id_seq'::regclass);


--
-- Name: system_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_logs ALTER COLUMN id SET DEFAULT nextval('public.system_logs_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: video_processing_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video_processing_logs ALTER COLUMN id SET DEFAULT nextval('public.video_processing_logs_id_seq'::regclass);


--
-- Name: videos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.videos ALTER COLUMN id SET DEFAULT nextval('public.videos_id_seq'::regclass);


--
-- Data for Name: activities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activities (id, activity_id, name, description, types, status, created_at, updated_at) FROM stdin;
1	ACT-001	Attendence		["Main Gate"]	active	2026-08-28 13:30:14.297668	2026-08-28 13:30:14.297668
2	ACT-002	Break		["breakIn", "breakOut"]	active	2026-08-28 13:30:52.191657	2026-08-28 13:30:52.191657
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alembic_version (version_num) FROM stdin;
0002_events_unique
\.


--
-- Data for Name: branch_activities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.branch_activities (id, branch_id, activity_id, name, floor, camera_direction, camera_id, camera_name, camera_ids, description, status, created_at, updated_at) FROM stdin;
1	9	ACT-001	Attendence	Main Gate	Single Camera	CAM-001	Attendence_MainGate	CAM-001		active	2026-08-28 13:39:33.297378	2026-08-28 13:39:33.297378
2	7	ACT-001	Attendance	Ground Floor	In	CAM-001	\N	\N	Main Gate Attendance	active	2026-08-28 13:40:28.7161	2026-08-28 13:40:28.7161
\.


--
-- Data for Name: branches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.branches (id, name, address, phone, manager_name, status, created_at, updated_at) FROM stdin;
7	Hanif Jewellers	Main Gulberg, Lahore	\N	\N	active	2026-08-13 07:08:10.6571	2026-08-13 07:08:10.6571
8	HF Branch	HF Main Headquarters	\N	\N	active	2026-08-13 07:15:00.399271	2026-08-13 07:15:00.399271
9	Main Branch	Head Office	\N	\N	active	2026-08-27 12:21:40.809561	2026-08-27 12:21:40.809561
\.


--
-- Data for Name: cameras; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cameras (id, camera_id, name, branch_id, location, camera_type, sub_location, rtsp_url, is_checkin, is_checkout, status, created_at, activity_id, activity_name, recording_path, updated_at) FROM stdin;
2	CAM-001	Attendence_MainGate	9		Single Camera	Main Gate	D:\\EEpic\\web-admin-backend\\data\\raw\\attendance	t	t	active	2026-08-28 13:38:54.370462	ACT-001	Attendance	D:\\EEpic\\web-admin-backend\\data\\raw\\attendance	2026-08-28 13:38:54.370462
\.


--
-- Data for Name: department_shifts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.department_shifts (id, department_id, shift_name, shift_start, shift_end, grace_time_mins, break_start, break_end, days, early_departure_buffer_mins) FROM stdin;
63	95	Mon-Thu Regular	11:00 AM	08:45 PM	10	01:00 PM	02:00 PM	Mon,Tue,Wed,Thu	10
64	95	Friday Shift	02:00 PM	08:45 PM	10	04:00 PM	04:30 PM	Fri	10
65	95	Saturday Shift	11:00 AM	07:00 PM	10	01:00 PM	02:00 PM	Sat	10
66	99	Mon-Thu Regular	11:00 AM	08:45 PM	10	01:00 PM	02:00 PM	Mon,Tue,Wed,Thu	10
67	99	Friday Shift	02:00 PM	08:45 PM	10	04:00 PM	04:30 PM	Fri	10
68	99	Saturday Shift	11:00 AM	07:00 PM	10	01:00 PM	02:00 PM	Sat	10
69	100	Mon-Thu Regular	11:45 AM	09:00 PM	10	01:00 PM	02:00 PM	Mon,Tue,Wed,Thu	10
70	100	Friday Shift	02:00 PM	09:00 PM	10	04:00 PM	04:30 PM	Fri	10
71	100	Saturday Shift	11:45 AM	09:00 PM	10	01:00 PM	02:00 PM	Sat	10
72	101	Mon-Thu Regular	11:45 AM	09:00 PM	10	01:00 PM	02:00 PM	Mon,Tue,Wed,Thu	10
73	101	Friday Shift	02:00 PM	09:00 PM	10	04:00 PM	04:30 PM	Fri	10
74	101	Saturday Shift	11:45 AM	09:00 PM	10	01:00 PM	02:00 PM	Sat	10
75	102	Mon-Thu Regular	11:45 AM	09:00 PM	10	01:00 PM	02:00 PM	Mon,Tue,Wed,Thu	10
76	102	Friday Shift	02:00 PM	09:00 PM	10	04:00 PM	04:30 PM	Fri	10
77	102	Saturday Shift	11:45 AM	09:00 PM	10	01:00 PM	02:00 PM	Sat	10
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.departments (id, name, description, is_active, created_at, updated_at, shift_name, shift_start, shift_end, grace_time_mins, break_start, break_end, early_departure_buffer_mins) FROM stdin;
95	Account Division	Accounts and Financial Ledger Division	t	2026-08-13 07:11:11.55517	2026-08-27 17:14:32.674555	Morning	11:00 AM	08:45 PM	10	01:00 PM	02:00 PM	10
99	Finance Division	Corporate Finance & Budgeting Division	t	2026-08-27 12:21:40.826876	2026-08-27 17:14:32.674555	General Shift	11:00 AM	08:45 PM	10	01:00 PM	02:00 PM	10
100	Retail Watches Division	Retail Watches & Timepieces Sales Division	t	2026-08-27 12:21:40.833798	2026-08-27 17:14:32.674555	General Shift	11:45 AM	09:00 PM	10	01:00 PM	02:00 PM	10
101	Jewellery and Gold Division	Gold & Traditional Jewellery Retail Division	t	2026-08-27 12:21:40.833798	2026-08-27 17:14:32.674555	General Shift	11:45 AM	09:00 PM	10	01:00 PM	02:00 PM	10
102	Jewellery and Diamond Division	Diamond & Luxury Gemstones Division	t	2026-08-27 12:21:40.852625	2026-08-27 17:14:32.674555	General Shift	11:45 AM	09:00 PM	10	01:00 PM	02:00 PM	10
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.events (id, video_id, camera_role, track_id, event_type, "timestamp", frame_number, confidence, status, created_at, employee_id, employee_name, recognition_confidence, recognition_status, recognized_at) FROM stdin;
73924	1916	attendance	11	Person Entered	27-08-2026 10:10:04	15096	0.85	pending	2026-08-27 18:33:24.329982	\N	Person #11	0	unrecognized	\N
73931	1916	attendance	19	Person Entered	27-08-2026 10:12:20	18482	0.85	pending	2026-08-27 18:34:22.593296	\N	Person #19	0	unrecognized	\N
73945	1916	attendance	34	Person Entered	27-08-2026 10:21:00	31878	0.85	unrecognized	2026-08-27 18:37:08.787992	\N	Person #34	0	unrecognized	2026-08-27 18:37:27.724121
73987	1916	attendance	96	Person Entered	27-08-2026 10:34:05	51093	0.85	unrecognized	2026-08-27 18:47:15.930336	\N	Person #96	0	unrecognized	2026-08-27 18:47:25.101135
73927	1916	attendance	14	Person Entered	27-08-2026 10:10:57	15687	0.85	unrecognized	2026-08-27 18:33:50.3043	\N	Person #14	0	unrecognized	2026-08-27 18:34:02.826705
74022	1916	attendance	140	Person Entered	27-08-2026 10:36:38	54934	0.85	pending	2026-08-27 18:52:14.826364	\N	Person #140	\N	pending	\N
73950	1916	attendance	39	Person Entered	27-08-2026 10:23:00	34660	0.85	unrecognized	2026-08-27 18:38:37.819992	\N	Person #39	0	unrecognized	2026-08-27 18:39:00.409635
74023	1916	attendance	140	Person Entered	27-08-2026 10:36:42	55034	0.85	pending	2026-08-27 18:52:14.936782	\N	Person #140	\N	pending	\N
73977	1916	attendance	81	Person Entered	27-08-2026 10:34:15	50646	0.85	unrecognized	2026-08-27 18:46:10.576989	\N	Person #81	0	unrecognized	2026-08-27 18:46:34.117219
73938	1916	attendance	25	Person Entered	27-08-2026 10:16:05	24074	0.85	unrecognized	2026-08-27 18:35:32.779229	\N	Person #25	0	unrecognized	2026-08-27 18:35:41.546102
73984	1916	attendance	90	Person Entered	27-08-2026 10:33:57	50918	0.85	pending	2026-08-27 18:46:53.633891	\N	Person #90	\N	pending	\N
73954	1916	attendance	42	Person Entered	27-08-2026 10:25:09	37675	0.85	unrecognized	2026-08-27 18:40:36.672902	\N	Person #42	0	unrecognized	2026-08-27 18:40:41.790197
73935	1916	attendance	22	Person Entered	27-08-2026 10:14:02	20997	0.85	unrecognized	2026-08-27 18:34:49.064983	\N	Person #22	0	unrecognized	2026-08-27 18:34:57.141801
73973	1916	attendance	69	Person Entered	27-08-2026 10:33:42	50280	0.85	unrecognized	2026-08-27 18:45:30.319777	\N	Person #69	0	unrecognized	2026-08-27 18:46:06.386126
74010	1916	attendance	121	Person Entered	27-08-2026 10:35:58	53836	0.85	unrecognized	2026-08-27 18:51:20.018368	\N	Person #121	0	unrecognized	2026-08-27 18:51:33.299834
73959	1916	attendance	51	Person Entered	27-08-2026 10:31:27	47036	0.85	unrecognized	2026-08-27 18:41:53.156918	\N	Person #51	0	unrecognized	2026-08-27 18:42:13.893304
73965	1916	attendance	62	Person Entered	27-08-2026 10:32:18	48431	0.85	pending	2026-08-27 18:43:17.234719	\N	Person #62	\N	pending	\N
74012	1916	attendance	127	Person Entered	27-08-2026 10:36:00	53997	0.85	pending	2026-08-27 18:51:37.299657	\N	Person #127	0	unrecognized	\N
73969	1916	attendance	67	Person Entered	27-08-2026 10:33:45	49624	0.85	unrecognized	2026-08-27 18:44:26.551526	\N	Person #67	0	unrecognized	2026-08-27 18:45:09.925693
73985	1916	attendance	91	Person Entered	27-08-2026 10:34:45	50929	0.85	unrecognized	2026-08-27 18:46:54.038001	\N	Person #91	0	unrecognized	2026-08-27 18:49:20.424363
73992	1916	attendance	106	Person Entered	27-08-2026 10:34:37	51330	0.85	unrecognized	2026-08-27 18:48:11.800694	\N	Person #106	0	unrecognized	2026-08-27 18:50:01.31612
73996	1916	attendance	108	Person Entered	27-08-2026 10:34:41	52024	0.85	pending	2026-08-27 18:50:02.005462	\N	Person #108	\N	pending	\N
74021	1916	attendance	140	Person Entered	27-08-2026 10:36:31	54773	0.85	pending	2026-08-27 18:52:14.605358	\N	Person #140	\N	pending	\N
74003	1916	attendance	108	Person Entered	27-08-2026 10:35:24	53080	0.85	pending	2026-08-27 18:50:35.923943	\N	Person #108	\N	pending	\N
74024	1916	attendance	140	Person Entered	27-08-2026 10:37:16	55213	0.85	unrecognized	2026-08-27 18:52:15.136116	\N	Person #140	0	unrecognized	2026-08-27 18:52:23.30336
74025	1916	attendance	141	Person Entered	27-08-2026 10:37:23	55263	0.85	unrecognized	2026-08-27 18:52:18.366295	\N	Person #141	0	unrecognized	2026-08-27 18:52:42.098772
74026	1916	attendance	143	Person Entered	27-08-2026 10:37:19	55335	0.85	unrecognized	2026-08-27 18:52:28.963394	\N	Person #143	0	unrecognized	2026-08-27 18:52:30.745514
74027	1916	attendance	144	Person Entered	27-08-2026 10:37:10	55706	0.85	unrecognized	2026-08-27 18:52:42.856139	\N	Person #144	0	unrecognized	2026-08-27 18:52:43.95679
74028	1916	attendance	145	Person Entered	27-08-2026 10:37:51	56115	0.85	unrecognized	2026-08-27 18:52:45.078156	\N	Person #145	0	unrecognized	2026-08-27 18:52:52.061327
74033	1916	checkin	152	check_in	27-08-2026 10:42:00	63786	0.85	normal	2026-08-27 18:53:13.897632	STF-007	Faisal Saleem	0.4637	recognized	2026-08-27 18:53:17.56479
73933	1916	attendance	21	Person Entered	27-08-2026 10:12:54	19343	0.85	pending	2026-08-27 18:34:33.684538	\N	Person #21	0	unrecognized	\N
73939	1916	checkin	25	check_in	27-08-2026 10:18:00	26838	0.85	normal	2026-08-27 18:35:43.934495	STF-023	Syed Zubair Zulfiqar	0.4767	recognized	2026-08-27 18:35:50.822516
73925	1916	attendance	12	Person Entered	27-08-2026 10:10:36	15234	0.85	unrecognized	2026-08-27 18:33:28.714062	\N	Person #12	0	unrecognized	2026-08-27 18:33:37.472238
73997	1916	attendance	106	Person Entered	27-08-2026 10:35:11	52153	0.85	unrecognized	2026-08-27 18:50:03.962316	\N	Person #106	0	unrecognized	2026-08-27 18:50:03.977964
73942	1916	attendance	30	Person Entered	27-08-2026 10:20:36	30126	0.85	unrecognized	2026-08-27 18:36:12.168921	\N	Person #30	0	unrecognized	2026-08-27 18:36:45.588889
73966	1916	attendance	64	Person Entered	27-08-2026 10:32:36	48475	0.85	unrecognized	2026-08-27 18:43:23.495967	\N	Person #64	0	unrecognized	2026-08-27 18:43:35.223411
73970	1916	attendance	65	Person Entered	27-08-2026 10:33:31	50127	0.85	unrecognized	2026-08-27 18:45:10.234051	\N	Person #65	0	unrecognized	2026-08-27 18:45:28.736203
73974	1916	attendance	73	Person Entered	27-08-2026 10:33:34	50331	0.85	pending	2026-08-27 18:45:48.335879	\N	Person #73	0	unrecognized	\N
73978	1916	attendance	82	Person Entered	27-08-2026 10:33:48	50677	0.85	pending	2026-08-27 18:46:21.256143	\N	Person #82	0	unrecognized	\N
73929	1916	attendance	16	Person Entered	27-08-2026 10:10:43	16031	0.85	unrecognized	2026-08-27 18:34:05.142041	\N	Person #16	0	unrecognized	2026-08-27 18:34:11.366192
73926	1916	attendance	13	Person Entered	27-08-2026 10:10:47	15441	0.85	unrecognized	2026-08-27 18:33:38.371695	\N	Person #13	0	unrecognized	2026-08-27 18:33:49.738147
73928	1916	attendance	15	Person Entered	27-08-2026 10:10:41	16019	0.85	pending	2026-08-27 18:34:04.667081	\N	Person #15	\N	pending	\N
73946	1916	attendance	35	Person Entered	27-08-2026 10:21:19	31892	0.85	unrecognized	2026-08-27 18:37:12.354799	\N	Person #35	0	unrecognized	2026-08-27 18:37:34.898172
74015	1916	attendance	132	Person Entered	27-08-2026 10:36:08	54187	0.85	pending	2026-08-27 18:51:55.498998	\N	Person #132	0	unrecognized	\N
74036	1916	attendance	156	Person Entered	27-08-2026 10:45:00	68255	0.85	unrecognized	2026-08-27 18:54:09.700341	\N	Person #156	0	unrecognized	2026-08-27 18:54:18.942636
73956	1916	attendance	47	Person Entered	27-08-2026 10:31:11	46011	0.85	unrecognized	2026-08-27 18:41:07.406645	\N	Person #47	0	unrecognized	2026-08-27 18:41:34.234251
73955	1916	attendance	45	Person Entered	27-08-2026 10:30:48	45405	0.85	unrecognized	2026-08-27 18:40:50.242002	\N	Person #45	0	unrecognized	2026-08-27 18:41:06.19994
73932	1916	attendance	20	Person Entered	27-08-2026 10:13:00	19068	0.85	unrecognized	2026-08-27 18:34:25.87583	\N	Person #20	0	unrecognized	2026-08-27 18:34:33.033158
73951	1916	attendance	40	Person Entered	27-08-2026 10:24:01	35262	0.85	unrecognized	2026-08-27 18:39:01.42808	\N	Person #40	0	unrecognized	2026-08-27 18:40:25.764236
73962	1916	attendance	55	Person Entered	27-08-2026 10:31:46	47638	0.85	pending	2026-08-27 18:42:45.757645	\N	Person #55	0	unrecognized	\N
73988	1916	attendance	97	Person Entered	27-08-2026 10:34:05	51116	0.85	unrecognized	2026-08-27 18:47:24.242413	\N	Person #97	0	unrecognized	2026-08-27 18:47:28.106697
73990	1916	attendance	100	Person Entered	27-08-2026 10:34:07	51152	0.85	pending	2026-08-27 18:47:39.677147	\N	Person #100	0	unrecognized	\N
74004	1916	attendance	106	Person Entered	27-08-2026 10:35:50	53538	0.85	unrecognized	2026-08-27 18:50:39.361753	\N	Person #106	0	unrecognized	2026-08-27 18:51:07.631876
73993	1916	attendance	107	Person Entered	27-08-2026 10:34:14	51344	0.85	pending	2026-08-27 18:48:18.797522	\N	Person #107	0	unrecognized	\N
74009	1916	attendance	120	Person Entered	27-08-2026 10:35:53	53747	0.85	unrecognized	2026-08-27 18:51:07.985444	\N	Person #120	0	unrecognized	2026-08-27 18:51:18.83131
74018	1916	attendance	136	Person Entered	27-08-2026 10:36:11	54258	0.85	pending	2026-08-27 18:52:02.356339	\N	Person #136	0	unrecognized	\N
74019	1916	attendance	137	Person Entered	27-08-2026 10:36:41	54274	0.85	unrecognized	2026-08-27 18:52:02.752335	\N	Person #137	0	unrecognized	2026-08-27 18:52:12.897283
74011	1916	attendance	123	Person Entered	27-08-2026 10:36:09	53918	0.85	unrecognized	2026-08-27 18:51:32.570433	\N	Person #123	0	unrecognized	2026-08-27 18:51:58.125479
74017	1916	attendance	135	Person Entered	27-08-2026 10:36:11	54211	0.85	unrecognized	2026-08-27 18:51:58.520329	\N	Person #135	0	unrecognized	2026-08-27 18:52:02.09706
74034	1916	attendance	153	Person Entered	27-08-2026 10:45:00	67221	0.85	unrecognized	2026-08-27 18:53:28.051845	\N	Person #153	0	unrecognized	2026-08-27 18:54:05.222463
74029	1916	attendance	146	Person Entered	27-08-2026 10:38:04	57068	0.85	unrecognized	2026-08-27 18:52:53.256381	\N	Person #146	0	unrecognized	2026-08-27 18:52:54.678058
74039	1916	attendance	159	Person Entered	27-08-2026 10:46:52	70289	0.85	pending	2026-08-27 18:55:00.926712	\N	Person #159	0	unrecognized	\N
74038	1916	attendance	158	Person Entered	27-08-2026 10:47:00	69935	0.85	unrecognized	2026-08-27 18:54:31.23038	\N	Person #158	0	unrecognized	2026-08-27 18:55:00.210757
74040	1916	attendance	160	Person Entered	27-08-2026 10:47:18	70329	0.85	unrecognized	2026-08-27 18:55:02.407988	\N	Person #160	0	unrecognized	2026-08-27 18:55:02.730194
74041	1916	attendance	161	Person Entered	27-08-2026 10:47:48	70926	0.85	unrecognized	2026-08-27 18:55:03.889866	\N	Person #161	0	unrecognized	2026-08-27 18:55:31.251473
74042	1916	attendance	162	Person Entered	27-08-2026 10:48:24	72543	0.85	unrecognized	2026-08-27 18:55:33.184312	\N	Person #162	0	unrecognized	2026-08-27 18:55:38.772213
74043	1916	attendance	163	Person Entered	27-08-2026 10:48:29	72689	0.85	unrecognized	2026-08-27 18:55:39.611478	\N	Person #163	0	unrecognized	2026-08-27 18:55:47.20206
74049	1916	attendance	173	Person Entered	27-08-2026 10:49:52	74783	0.85	pending	2026-08-27 18:56:41.665514	\N	Person #173	0	unrecognized	\N
73919	1916	attendance	5	Person Entered	27-08-2026 10:06:00	8860	0.85	unrecognized	2026-08-27 18:32:35.808575	\N	Person #5	0	unrecognized	2026-08-27 18:32:39.321397
73917	1916	attendance	1	Person Entered	27-08-2026 10:02:00	3754	0.85	unrecognized	2026-08-27 18:32:18.599185	\N	Person #1	0	unrecognized	2026-08-27 18:32:28.469108
73952	1916	attendance	40	Person Entered	27-08-2026 10:24:06	36063	0.85	unrecognized	2026-08-27 18:40:26.141107	\N	Person #40	0	unrecognized	2026-08-27 18:40:28.438154
73957	1916	checkin	48	check_in	27-08-2026 10:31:03	46574	0.85	normal	2026-08-27 18:41:35.400835	STF-013	Muhammad Faizan	0.4802	recognized	2026-08-27 18:41:35.422336
73947	1916	attendance	36	Person Entered	27-08-2026 10:21:23	32016	0.85	unrecognized	2026-08-27 18:37:36.043041	\N	Person #36	0	unrecognized	2026-08-27 18:37:46.207508
79487	1951	breakout	104	Break Out	25-08-2026 19:02:17	10745	0.85	normal	2026-08-28 14:34:46.050442	STF-011	Syed Shoaib Ahmad Alvi	0.4898	recognized	2026-08-28 14:35:01.269078
73918	1916	attendance	4	Person Entered	27-08-2026 10:05:57	8854	0.85	unrecognized	2026-08-27 18:32:34.12127	\N	Person #4	0	unrecognized	2026-08-27 18:32:46.615016
73387	1890	attendance	1	Person Entered	10-08-2026 10:00:33	1	0.85	unrecognized	2026-08-27 14:55:01.61159	\N	Person #1	0	unrecognized	2026-08-27 14:55:45.49475
73967	1916	attendance	65	Person Entered	27-08-2026 10:33:45	49096	0.85	unrecognized	2026-08-27 18:43:35.707989	\N	Person #65	0	unrecognized	2026-08-27 18:45:09.723629
73971	1916	attendance	67	Person Entered	27-08-2026 10:33:26	50127	0.85	pending	2026-08-27 18:45:10.42228	\N	Person #67	0	unrecognized	\N
73948	1916	attendance	36	Person Entered	27-08-2026 10:22:32	32984	0.85	unrecognized	2026-08-27 18:37:47.468256	\N	Person #36	0	unrecognized	2026-08-27 18:38:14.809355
73922	1916	attendance	9	Person Entered	27-08-2026 10:09:00	13633	0.85	unrecognized	2026-08-27 18:32:59.850466	\N	Person #9	0	unrecognized	2026-08-27 18:33:07.196898
73930	1916	attendance	17	Person Entered	27-08-2026 10:11:36	17354	0.85	unrecognized	2026-08-27 18:34:13.170628	\N	Person #17	0	unrecognized	2026-08-27 18:34:21.134878
73936	1916	attendance	23	Person Entered	27-08-2026 10:14:43	21968	0.85	unrecognized	2026-08-27 18:34:59.527095	\N	Person #23	0	unrecognized	2026-08-27 18:35:22.435869
73975	1916	attendance	77	Person Entered	27-08-2026 10:33:44	50600	0.85	pending	2026-08-27 18:46:08.196893	\N	Person #77	0	unrecognized	\N
73979	1916	attendance	83	Person Entered	27-08-2026 10:33:50	50746	0.85	pending	2026-08-27 18:46:26.826912	\N	Person #83	0	unrecognized	\N
73940	1916	attendance	27	Person Entered	27-08-2026 10:19:32	28638	0.85	unrecognized	2026-08-27 18:35:56.61958	\N	Person #27	0	unrecognized	2026-08-27 18:36:06.422352
73923	1916	attendance	10	Person Entered	27-08-2026 10:09:00	14041	0.85	unrecognized	2026-08-27 18:33:08.550579	\N	Person #10	0	unrecognized	2026-08-27 18:33:22.592849
73934	1916	attendance	21	Person Entered	27-08-2026 10:13:38	19772	0.85	unrecognized	2026-08-27 18:34:35.437953	\N	Person #21	0	unrecognized	2026-08-27 18:34:47.397699
73983	1916	attendance	88	Person Entered	27-08-2026 10:33:56	50891	0.85	pending	2026-08-27 18:46:52.695145	\N	Person #88	0	unrecognized	\N
73986	1916	attendance	94	Person Entered	27-08-2026 10:34:01	51004	0.85	pending	2026-08-27 18:47:06.04299	\N	Person #94	0	unrecognized	\N
73388	1890	attendance	3	Person Entered	10-08-2026 10:00:59	654	0.85	unrecognized	2026-08-27 14:55:04.663504	\N	Person #3	0	unrecognized	2026-08-27 14:55:51.362228
73963	1916	attendance	55	Person Entered	27-08-2026 10:32:17	48042	0.85	unrecognized	2026-08-27 18:42:51.607058	\N	Person #55	0	unrecognized	2026-08-27 18:43:13.676372
73390	1890	attendance	5	Person Entered	10-08-2026 10:00:26	675	0.85	pending	2026-08-27 14:55:13.476379	\N	Person #5	0	unrecognized	\N
73994	1916	attendance	108	Person Entered	27-08-2026 10:34:37	51711	0.85	unrecognized	2026-08-27 18:49:33.013044	\N	Person #108	0	unrecognized	2026-08-27 18:50:01.515575
73998	1916	attendance	108	Person Entered	27-08-2026 10:34:47	52153	0.85	pending	2026-08-27 18:50:04.166212	\N	Person #108	\N	pending	\N
74005	1916	attendance	108	Person Entered	27-08-2026 10:35:42	53538	0.85	pending	2026-08-27 18:50:39.566171	\N	Person #108	0	unrecognized	\N
73389	1890	attendance	4	Person Entered	10-08-2026 10:00:28	671	0.85	unrecognized	2026-08-27 14:55:11.490762	\N	Person #4	0	unrecognized	2026-08-27 14:55:28.945312
73989	1916	attendance	99	Person Entered	27-08-2026 10:34:31	51130	0.85	unrecognized	2026-08-27 18:47:29.787521	\N	Person #99	0	unrecognized	2026-08-27 18:47:40.888397
73391	1890	attendance	7	Person Entered	10-08-2026 10:00:34	824	0.85	unrecognized	2026-08-27 14:55:36.183198	\N	Person #7	0	unrecognized	2026-08-27 14:55:49.43822
74006	1916	attendance	114	Person Entered	27-08-2026 10:35:44	53579	0.85	pending	2026-08-27 18:50:40.066119	\N	Person #114	0	unrecognized	\N
74001	1916	attendance	113	Person Entered	27-08-2026 10:35:41	52872	0.85	unrecognized	2026-08-27 18:50:23.457977	\N	Person #113	0	unrecognized	2026-08-27 18:50:32.620157
73999	1916	attendance	106	Person Entered	27-08-2026 10:35:44	52308	0.85	unrecognized	2026-08-27 18:50:04.318457	\N	Person #106	0	unrecognized	2026-08-27 18:50:35.433624
74013	1916	attendance	129	Person Entered	27-08-2026 10:36:07	54099	0.85	unrecognized	2026-08-27 18:51:39.672942	\N	Person #129	0	unrecognized	2026-08-27 18:51:50.696184
74014	1916	attendance	130	Person Entered	27-08-2026 10:36:08	54166	0.85	unrecognized	2026-08-27 18:51:47.070025	\N	Person #130	0	unrecognized	2026-08-27 18:51:55.322189
74020	1916	attendance	136	Person Entered	27-08-2026 10:36:23	54561	0.85	pending	2026-08-27 18:52:13.229178	\N	Person #136	0	unrecognized	\N
74030	1916	attendance	146	Person Entered	27-08-2026 10:38:07	57172	0.85	pending	2026-08-27 18:52:55.010777	\N	Person #146	\N	pending	\N
74031	1916	attendance	148	Person Entered	27-08-2026 10:39:33	59319	0.85	pending	2026-08-27 18:52:57.765952	\N	Person #148	0	unrecognized	\N
73920	1916	attendance	8	Person Entered	27-08-2026 10:08:54	13343	0.85	pending	2026-08-27 18:32:51.01399	\N	Person #8	\N	pending	\N
73393	1890	attendance	1	Person Entered	10-08-2026 10:01:02	1471	0.85	unrecognized	2026-08-27 14:55:51.044169	\N	Person #1	0	unrecognized	2026-08-27 14:56:20.39053
73958	1916	attendance	49	Person Entered	27-08-2026 10:31:16	46758	0.85	unrecognized	2026-08-27 18:41:40.341963	\N	Person #49	0	unrecognized	2026-08-27 18:41:52.437836
74048	1916	attendance	171	Person Entered	27-08-2026 10:50:15	74754	0.85	unrecognized	2026-08-27 18:56:33.519998	\N	Person #171	0	unrecognized	2026-08-27 18:56:35.218287
73981	1916	attendance	86	Person Entered	27-08-2026 10:33:52	50780	0.85	pending	2026-08-27 18:46:37.479605	\N	Person #86	0	unrecognized	\N
73943	1916	attendance	30	Person Entered	27-08-2026 10:20:47	30488	0.85	unrecognized	2026-08-27 18:36:46.381968	\N	Person #30	0	unrecognized	2026-08-27 18:37:03.79461
73944	1916	attendance	31	Person Entered	27-08-2026 10:20:57	31410	0.85	pending	2026-08-27 18:37:05.922101	\N	Person #31	0	unrecognized	\N
73937	1916	attendance	24	Person Entered	27-08-2026 10:15:00	23122	0.85	unrecognized	2026-08-27 18:35:24.224664	\N	Person #24	0	unrecognized	2026-08-27 18:35:31.202989
73921	1916	attendance	8	Person Entered	27-08-2026 10:09:03	13500	0.85	unrecognized	2026-08-27 18:32:51.222991	\N	Person #8	0	unrecognized	2026-08-27 18:32:58.878006
73941	1916	attendance	29	Person Entered	27-08-2026 10:19:24	29097	0.85	pending	2026-08-27 18:36:08.11298	\N	Person #29	0	unrecognized	\N
73972	1916	attendance	68	Person Entered	27-08-2026 10:33:42	50244	0.85	unrecognized	2026-08-27 18:45:17.954997	\N	Person #68	0	unrecognized	2026-08-27 18:46:07.515236
73968	1916	attendance	66	Person Entered	27-08-2026 10:32:59	49350	0.85	unrecognized	2026-08-27 18:43:48.67173	\N	Person #66	0	unrecognized	2026-08-27 18:44:21.875057
73961	1916	attendance	53	Person Entered	27-08-2026 10:31:41	47353	0.85	unrecognized	2026-08-27 18:42:17.103294	\N	Person #53	0	unrecognized	2026-08-27 18:42:42.211954
73949	1916	attendance	38	Person Entered	27-08-2026 10:22:47	34053	0.85	unrecognized	2026-08-27 18:38:17.030332	\N	Person #38	0	unrecognized	2026-08-27 18:38:36.3012
73953	1916	attendance	41	Person Entered	27-08-2026 10:24:56	37357	0.85	unrecognized	2026-08-27 18:40:31.360744	\N	Person #41	0	unrecognized	2026-08-27 18:40:35.303913
73392	1890	attendance	8	Person Entered	10-08-2026 10:00:34	863	0.85	pending	2026-08-27 14:55:50.081768	\N	Person #8	0	unrecognized	\N
73995	1916	attendance	106	Person Entered	27-08-2026 10:34:43	52024	0.85	unrecognized	2026-08-27 18:50:01.801694	\N	Person #106	0	unrecognized	2026-08-27 18:50:03.669081
73960	1916	checkin	52	check_in	27-08-2026 10:31:33	47297	0.85	normal	2026-08-27 18:42:14.705062	STF-013	Muhammad Faizan	0.4729	recognized	2026-08-27 18:42:15.11538
73976	1916	attendance	80	Person Entered	27-08-2026 10:33:47	50643	0.85	unrecognized	2026-08-27 18:46:09.727192	\N	Person #80	0	unrecognized	2026-08-27 18:46:19.500781
73964	1916	attendance	61	Person Entered	27-08-2026 10:32:19	48382	0.85	unrecognized	2026-08-27 18:43:03.191214	\N	Person #61	0	unrecognized	2026-08-27 18:43:23.061647
73395	1890	attendance	11	Person Entered	10-08-2026 10:01:04	1528	0.85	unrecognized	2026-08-27 14:55:59.319935	\N	Person #11	0	unrecognized	2026-08-27 14:56:23.760532
73394	1890	attendance	9	Person Entered	10-08-2026 10:01:02	1478	0.85	unrecognized	2026-08-27 14:55:51.632227	\N	Person #9	0	unrecognized	2026-08-27 14:56:21.761474
73980	1916	attendance	84	Person Entered	27-08-2026 10:34:16	50749	0.85	unrecognized	2026-08-27 18:46:27.522974	\N	Person #84	0	unrecognized	2026-08-27 18:46:39.383251
74000	1916	attendance	108	Person Entered	27-08-2026 10:34:53	52308	0.85	pending	2026-08-27 18:50:04.531908	\N	Person #108	0	unrecognized	\N
73991	1916	attendance	103	Person Entered	27-08-2026 10:34:09	51201	0.85	unrecognized	2026-08-27 18:47:51.504761	\N	Person #103	0	unrecognized	2026-08-27 18:47:59.114665
74002	1916	attendance	106	Person Entered	27-08-2026 10:35:33	53080	0.85	unrecognized	2026-08-27 18:50:35.723633	\N	Person #106	0	unrecognized	2026-08-27 18:50:38.951258
74008	1916	attendance	117	Person Entered	27-08-2026 10:35:49	53702	0.85	pending	2026-08-27 18:50:58.75286	\N	Person #117	0	unrecognized	\N
74016	1916	attendance	134	Person Entered	27-08-2026 10:36:08	54196	0.85	pending	2026-08-27 18:51:57.387803	\N	Person #134	0	unrecognized	\N
74032	1916	attendance	149	Person Entered	27-08-2026 10:40:20	60441	0.85	unrecognized	2026-08-27 18:53:01.047354	\N	Person #149	0	unrecognized	2026-08-27 18:53:10.372454
74035	1916	attendance	155	Person Entered	27-08-2026 10:45:19	67974	0.85	pending	2026-08-27 18:54:06.467194	\N	Person #155	0	unrecognized	\N
74037	1916	attendance	157	Person Entered	27-08-2026 10:45:55	68797	0.85	unrecognized	2026-08-27 18:54:20.288136	\N	Person #157	0	unrecognized	2026-08-27 18:54:29.723274
74059	1916	attendance	184	Person Entered	27-08-2026 10:52:00	77956	0.85	unrecognized	2026-08-27 18:58:48.810481	\N	Person #184	0	unrecognized	2026-08-27 18:59:04.935117
74050	1916	attendance	174	Person Entered	27-08-2026 10:50:47	75387	0.85	unrecognized	2026-08-27 18:57:03.334071	\N	Person #174	0	unrecognized	2026-08-27 18:57:54.02776
74062	1916	attendance	189	Person Entered	27-08-2026 10:53:00	79386	0.85	unrecognized	2026-08-27 18:59:19.034057	\N	Person #189	0	unrecognized	2026-08-27 18:59:56.275368
74068	1916	attendance	200	Person Entered	27-08-2026 10:56:03	83852	0.85	unrecognized	2026-08-27 19:01:39.970401	\N	Person #200	0	unrecognized	2026-08-27 19:02:36.807186
74078	1916	attendance	208	Person Entered	27-08-2026 10:57:00	85866	0.85	unrecognized	2026-08-27 19:03:26.86518	\N	Person #208	0	unrecognized	2026-08-27 19:04:55.292226
74060	1916	attendance	187	Person Entered	27-08-2026 10:52:14	78349	0.85	pending	2026-08-27 18:59:06.204908	\N	Person #187	0	unrecognized	\N
74077	1916	attendance	207	Person Entered	27-08-2026 10:57:36	85774	0.85	unrecognized	2026-08-27 19:03:23.645713	\N	Person #207	0	unrecognized	2026-08-27 19:03:25.658153
74111	1916	attendance	250	Person Entered	27-08-2026 11:02:07	93124	0.85	unrecognized	2026-08-27 19:11:12.948822	\N	Person #250	0	unrecognized	2026-08-27 19:11:24.650606
74096	1916	attendance	235	Person Entered	27-08-2026 10:59:54	89750	0.85	unrecognized	2026-08-27 19:08:29.810968	\N	Person #235	0	unrecognized	2026-08-27 19:08:46.394265
74100	1916	attendance	236	Person Entered	27-08-2026 11:00:44	91078	0.85	pending	2026-08-27 19:09:10.897462	\N	Person #236	0	unrecognized	\N
74105	1916	attendance	244	Person Entered	27-08-2026 11:01:00	91500	0.85	pending	2026-08-27 19:10:15.70043	\N	Person #244	0	unrecognized	\N
74065	1916	attendance	194	Person Entered	27-08-2026 10:54:00	80963	0.85	unrecognized	2026-08-27 19:01:13.651812	\N	Person #194	0	unrecognized	2026-08-27 19:01:25.522748
74093	1916	attendance	228	Person Entered	27-08-2026 10:59:40	89465	0.85	unrecognized	2026-08-27 19:07:51.775283	\N	Person #228	0	unrecognized	2026-08-27 19:07:54.083208
74044	1916	attendance	164	Person Entered	27-08-2026 10:49:00	72961	0.85	unrecognized	2026-08-27 18:55:48.170793	\N	Person #164	0	unrecognized	2026-08-27 18:55:56.164254
74081	1916	attendance	212	Person Entered	27-08-2026 10:57:54	86024	0.85	unrecognized	2026-08-27 19:04:10.102337	\N	Person #212	0	unrecognized	2026-08-27 19:05:05.69245
74123	1916	attendance	268	Person Entered	27-08-2026 11:04:20	96424	0.85	unrecognized	2026-08-27 19:14:12.029285	\N	Person #268	0	unrecognized	2026-08-27 19:14:22.897651
74070	1916	attendance	202	Person Entered	27-08-2026 10:56:00	83955	0.85	unrecognized	2026-08-27 19:02:01.646881	\N	Person #202	0	unrecognized	2026-08-27 19:02:18.868583
74072	1916	attendance	204	Person Entered	27-08-2026 10:56:06	84109	0.85	unrecognized	2026-08-27 19:02:39.558889	\N	Person #204	0	unrecognized	2026-08-27 19:02:51.763681
74135	1916	attendance	282	Person Entered	27-08-2026 11:06:37	99886	0.85	unrecognized	2026-08-27 19:17:53.234849	\N	Person #282	0	unrecognized	2026-08-27 19:17:59.582377
74119	1916	attendance	261	Person Entered	27-08-2026 11:03:24	95028	0.85	unrecognized	2026-08-27 19:12:50.807853	\N	Person #261	0	unrecognized	2026-08-27 19:13:09.00533
74095	1916	attendance	233	Person Entered	27-08-2026 10:59:46	89496	0.85	unrecognized	2026-08-27 19:07:54.88006	\N	Person #233	0	unrecognized	2026-08-27 19:08:28.949004
74087	1916	attendance	220	Person Entered	27-08-2026 10:59:19	88274	0.85	unrecognized	2026-08-27 19:06:18.822577	\N	Person #220	0	unrecognized	2026-08-27 19:06:37.750094
74116	1916	attendance	257	Person Entered	27-08-2026 11:02:43	94005	0.85	unrecognized	2026-08-27 19:12:13.362537	\N	Person #257	0	unrecognized	2026-08-27 19:12:23.454691
74130	1916	attendance	277	Person Entered	27-08-2026 11:05:33	97611	0.85	unrecognized	2026-08-27 19:16:16.394429	\N	Person #277	0	unrecognized	2026-08-27 19:16:27.84052
74109	1916	attendance	248	Person Entered	27-08-2026 11:01:51	92695	0.85	unrecognized	2026-08-27 19:10:47.451606	\N	Person #248	0	unrecognized	2026-08-27 19:11:03.234903
74160	1916	attendance	319	Person Entered	27-08-2026 11:08:32	102784	0.85	pending	2026-08-27 19:24:12.653699	\N	Person #319	0	unrecognized	\N
74139	1916	attendance	290	Person Entered	27-08-2026 11:07:32	101053	0.85	unrecognized	2026-08-27 19:18:36.560161	\N	Person #290	0	unrecognized	2026-08-27 19:19:17.47303
74132	1916	attendance	279	Person Entered	27-08-2026 11:05:38	98337	0.85	unrecognized	2026-08-27 19:17:03.946732	\N	Person #279	0	unrecognized	2026-08-27 19:17:19.250177
74127	1916	attendance	274	Person Entered	27-08-2026 11:04:58	97290	0.85	unrecognized	2026-08-27 19:15:23.082932	\N	Person #274	0	unrecognized	2026-08-27 19:15:37.243451
74156	1916	attendance	312	Person Entered	27-08-2026 11:08:26	102620	0.85	unrecognized	2026-08-27 19:22:50.963196	\N	Person #312	0	unrecognized	2026-08-27 19:22:59.169088
74144	1916	attendance	296	Person Entered	27-08-2026 11:07:55	101817	0.85	unrecognized	2026-08-27 19:19:35.324819	\N	Person #296	0	unrecognized	2026-08-27 19:19:43.961107
74148	1916	attendance	301	Person Entered	27-08-2026 11:08:08	102187	0.85	pending	2026-08-27 19:20:25.570057	\N	Person #301	0	unrecognized	\N
74153	1916	attendance	306	Person Entered	27-08-2026 11:08:40	102435	0.85	unrecognized	2026-08-27 19:21:25.601766	\N	Person #306	0	unrecognized	2026-08-27 19:24:49.929532
74159	1916	attendance	318	Person Entered	27-08-2026 11:08:31	102729	0.85	unrecognized	2026-08-27 19:23:39.897462	\N	Person #318	0	unrecognized	2026-08-27 19:24:06.516228
74171	1916	attendance	332	Person Entered	27-08-2026 11:10:00	105247	0.85	unrecognized	2026-08-27 19:26:49.250212	\N	Person #332	0	unrecognized	2026-08-27 19:26:54.767552
74173	1916	attendance	337	Person Entered	27-08-2026 11:10:12	105280	0.85	pending	2026-08-27 19:27:00.094111	\N	Person #337	0	unrecognized	\N
74149	1916	attendance	302	Person Entered	27-08-2026 11:08:17	102279	0.85	unrecognized	2026-08-27 19:20:33.07253	\N	Person #302	0	unrecognized	2026-08-27 19:21:22.993715
74069	1916	attendance	201	Person Entered	27-08-2026 10:55:58	83937	0.85	pending	2026-08-27 19:01:58.304735	\N	Person #201	\N	pending	\N
74051	1916	attendance	175	Person Entered	27-08-2026 10:50:45	75460	0.85	unrecognized	2026-08-27 18:57:19.557689	\N	Person #175	0	unrecognized	2026-08-27 18:57:40.203583
74073	1916	attendance	206	Person Entered	27-08-2026 10:56:08	84181	0.85	pending	2026-08-27 19:03:00.716173	\N	Person #206	0	unrecognized	\N
74110	1916	attendance	249	Person Entered	27-08-2026 11:02:04	93034	0.85	unrecognized	2026-08-27 19:11:04.406354	\N	Person #249	0	unrecognized	2026-08-27 19:11:12.029093
74103	1916	attendance	242	Person Entered	27-08-2026 11:00:53	91312	0.85	pending	2026-08-27 19:09:25.942021	\N	Person #242	0	unrecognized	\N
74079	1916	attendance	210	Person Entered	27-08-2026 10:57:00	85913	0.85	unrecognized	2026-08-27 19:03:35.133925	\N	Person #210	0	unrecognized	2026-08-27 19:03:52.809476
74082	1916	attendance	213	Person Entered	27-08-2026 10:57:29	86211	0.85	pending	2026-08-27 19:04:58.064533	\N	Person #213	0	unrecognized	\N
74114	1916	attendance	255	Person Entered	27-08-2026 11:02:22	93543	0.85	pending	2026-08-27 19:12:00.08638	\N	Person #255	0	unrecognized	\N
74091	1916	attendance	225	Person Entered	27-08-2026 10:59:38	89427	0.85	unrecognized	2026-08-27 19:07:44.568263	\N	Person #225	0	unrecognized	2026-08-27 19:07:49.603107
74121	1916	attendance	263	Person Entered	27-08-2026 11:03:29	95178	0.85	unrecognized	2026-08-27 19:13:23.445164	\N	Person #263	0	unrecognized	2026-08-27 19:13:36.808629
74045	1916	attendance	165	Person Entered	27-08-2026 10:49:55	74219	0.85	unrecognized	2026-08-27 18:55:58.285104	\N	Person #165	0	unrecognized	2026-08-27 18:56:07.39946
74124	1916	attendance	270	Person Entered	27-08-2026 11:04:34	96835	0.85	pending	2026-08-27 19:14:23.877659	\N	Person #270	0	unrecognized	\N
74088	1916	attendance	221	Person Entered	27-08-2026 10:59:33	88435	0.85	unrecognized	2026-08-27 19:06:38.455257	\N	Person #221	0	unrecognized	2026-08-27 19:07:23.568936
74085	1916	attendance	217	Person Entered	27-08-2026 10:58:00	86915	0.85	unrecognized	2026-08-27 19:05:25.090802	\N	Person #217	0	unrecognized	2026-08-27 19:05:50.781172
74128	1916	attendance	275	Person Entered	27-08-2026 11:05:04	97447	0.85	unrecognized	2026-08-27 19:15:39.856074	\N	Person #275	0	unrecognized	2026-08-27 19:16:15.582762
74157	1916	attendance	313	Person Entered	27-08-2026 11:08:25	102622	0.85	pending	2026-08-27 19:22:51.918874	\N	Person #313	0	unrecognized	\N
79492	1951	breakout	105	Break Out	25-08-2026 19:02:19	10793	0.85	normal	2026-08-28 14:35:01.436476	STF-014	Muhammad Asif	0.4533	recognized	2026-08-28 14:35:10.55199
74137	1916	attendance	286	Person Entered	27-08-2026 11:06:47	100109	0.85	unrecognized	2026-08-27 19:18:02.009665	\N	Person #286	0	unrecognized	2026-08-27 19:18:19.850307
74125	1916	attendance	271	Person Entered	27-08-2026 11:05:04	96854	0.85	unrecognized	2026-08-27 19:14:24.367744	\N	Person #271	0	unrecognized	2026-08-27 19:16:13.380012
74154	1916	attendance	308	Person Entered	27-08-2026 11:08:44	102498	0.85	unrecognized	2026-08-27 19:21:44.903903	\N	Person #308	0	unrecognized	2026-08-27 19:25:00.13079
74133	1916	attendance	280	Person Entered	27-08-2026 11:06:23	99390	0.85	unrecognized	2026-08-27 19:17:21.406379	\N	Person #280	0	unrecognized	2026-08-27 19:17:50.008794
74151	1916	attendance	304	Person Entered	27-08-2026 11:08:22	102353	0.85	unrecognized	2026-08-27 19:20:53.366383	\N	Person #304	0	unrecognized	2026-08-27 19:22:17.757279
74136	1916	attendance	284	Person Entered	27-08-2026 11:06:48	100104	0.85	unrecognized	2026-08-27 19:18:00.722562	\N	Person #284	0	unrecognized	2026-08-27 19:18:24.681892
74142	1916	attendance	294	Person Entered	27-08-2026 11:07:39	101472	0.85	pending	2026-08-27 19:19:22.937403	\N	Person #294	0	unrecognized	\N
74145	1916	attendance	296	Person Entered	27-08-2026 11:08:09	101959	0.85	unrecognized	2026-08-27 19:19:44.27921	\N	Person #296	0	unrecognized	2026-08-27 19:20:30.168247
74152	1916	attendance	305	Person Entered	27-08-2026 11:08:16	102378	0.85	pending	2026-08-27 19:21:02.521172	\N	Person #305	0	unrecognized	\N
74169	1916	attendance	330	Person Entered	27-08-2026 11:10:03	105073	0.85	pending	2026-08-27 19:26:24.742113	\N	Person #330	0	unrecognized	\N
74162	1916	attendance	320	Person Entered	27-08-2026 11:08:51	103255	0.85	pending	2026-08-27 19:25:05.76125	\N	Person #320	0	unrecognized	\N
74161	1916	attendance	306	Person Entered	27-08-2026 11:08:55	103028	0.85	unrecognized	2026-08-27 19:24:54.987203	\N	Person #306	0	unrecognized	2026-08-27 19:25:26.143442
74172	1916	attendance	336	Person Entered	27-08-2026 11:10:39	105273	0.85	unrecognized	2026-08-27 19:26:56.893115	\N	Person #336	0	unrecognized	2026-08-27 19:27:30.961731
74178	1916	attendance	346	Person Entered	27-08-2026 11:12:10	108235	0.85	pending	2026-08-27 19:29:08.320214	\N	Person #346	0	unrecognized	\N
74094	1916	attendance	231	Person Entered	27-08-2026 10:59:40	89479	0.85	pending	2026-08-27 19:07:53.726337	\N	Person #231	0	unrecognized	\N
74052	1916	checkin	176	check_in	27-08-2026 10:50:46	75525	0.85	normal	2026-08-27 18:57:45.537039	STF-029	Abdul Rehman Sultan	0.4693	recognized	2026-08-27 18:57:47.411869
74134	1916	attendance	281	Person Entered	27-08-2026 11:06:30	99749	0.85	pending	2026-08-27 19:17:50.814283	\N	Person #281	0	unrecognized	\N
74064	1916	attendance	192	Person Entered	27-08-2026 10:54:00	79961	0.85	unrecognized	2026-08-27 19:00:05.266643	\N	Person #192	0	unrecognized	2026-08-27 19:01:12.838987
74067	1916	attendance	199	Person Entered	27-08-2026 10:55:47	83670	0.85	pending	2026-08-27 19:01:35.351783	\N	Person #199	0	unrecognized	\N
74098	1916	attendance	237	Person Entered	27-08-2026 11:00:00	89997	0.85	unrecognized	2026-08-27 19:08:50.535335	\N	Person #237	0	unrecognized	2026-08-27 19:08:51.023182
74122	1916	attendance	267	Person Entered	27-08-2026 11:03:46	95474	0.85	unrecognized	2026-08-27 19:13:44.667513	\N	Person #267	0	unrecognized	2026-08-27 19:14:10.969976
74126	1916	attendance	273	Person Entered	27-08-2026 11:04:44	96924	0.85	unrecognized	2026-08-27 19:14:36.883947	\N	Person #273	0	unrecognized	2026-08-27 19:15:18.97894
74071	1916	attendance	203	Person Entered	27-08-2026 10:56:09	84103	0.85	unrecognized	2026-08-27 19:02:38.002023	\N	Person #203	0	unrecognized	2026-08-27 19:03:06.813214
74056	1916	attendance	179	Person Entered	27-08-2026 10:51:38	77445	0.85	pending	2026-08-27 18:58:28.913639	\N	Person #179	\N	pending	\N
74074	1916	attendance	206	Person Entered	27-08-2026 10:56:19	84462	0.85	pending	2026-08-27 19:03:07.443132	\N	Person #206	\N	pending	\N
74075	1916	attendance	206	Person Entered	27-08-2026 10:56:59	85456	0.85	pending	2026-08-27 19:03:08.538329	\N	Person #206	\N	pending	\N
74076	1916	attendance	206	Person Entered	27-08-2026 10:57:33	85548	0.85	unrecognized	2026-08-27 19:03:08.705283	\N	Person #206	0	unrecognized	2026-08-27 19:03:22.448504
74080	1916	attendance	211	Person Entered	27-08-2026 10:57:19	85972	0.85	pending	2026-08-27 19:03:56.892662	\N	Person #211	0	unrecognized	\N
74112	1916	attendance	251	Person Entered	27-08-2026 11:02:15	93194	0.85	unrecognized	2026-08-27 19:11:25.192545	\N	Person #251	0	unrecognized	2026-08-27 19:11:50.432087
74108	1916	attendance	248	Person Entered	27-08-2026 11:01:28	92178	0.85	pending	2026-08-27 19:10:45.096764	\N	Person #248	0	unrecognized	\N
74047	1916	attendance	169	Person Entered	27-08-2026 10:50:19	74651	0.85	unrecognized	2026-08-27 18:56:12.857588	\N	Person #169	0	unrecognized	2026-08-27 18:57:01.922819
79502	1951	breakout	9	Break Out	25-08-2026 19:00:25	7999	0.85	normal	2026-08-28 14:35:25.912574	STF-011	Syed Shoaib Ahmad Alvi	0.5049	recognized	2026-08-28 14:35:28.047193
74089	1916	attendance	222	Person Entered	27-08-2026 10:59:33	88752	0.85	unrecognized	2026-08-27 19:07:24.288315	\N	Person #222	0	unrecognized	2026-08-27 19:07:35.797796
74086	1916	attendance	219	Person Entered	27-08-2026 10:58:23	87403	0.85	unrecognized	2026-08-27 19:05:52.094395	\N	Person #219	0	unrecognized	2026-08-27 19:06:17.613862
74083	1916	attendance	215	Person Entered	27-08-2026 10:57:38	86388	0.85	unrecognized	2026-08-27 19:05:07.896162	\N	Person #215	0	unrecognized	2026-08-27 19:05:17.91602
74102	1916	attendance	240	Person Entered	27-08-2026 11:01:03	91268	0.85	unrecognized	2026-08-27 19:09:17.49289	\N	Person #240	0	unrecognized	2026-08-27 19:10:28.352915
74092	1916	attendance	227	Person Entered	27-08-2026 10:59:39	89458	0.85	unrecognized	2026-08-27 19:07:50.095187	\N	Person #227	0	unrecognized	2026-08-27 19:07:51.535017
74143	1916	attendance	295	Person Entered	27-08-2026 11:07:46	101635	0.85	pending	2026-08-27 19:19:28.358826	\N	Person #295	0	unrecognized	\N
74118	1916	attendance	259	Person Entered	27-08-2026 11:03:03	94486	0.85	unrecognized	2026-08-27 19:12:34.422986	\N	Person #259	0	unrecognized	2026-08-27 19:12:49.81365
74147	1916	attendance	300	Person Entered	27-08-2026 11:08:07	102166	0.85	pending	2026-08-27 19:20:20.534755	\N	Person #300	0	unrecognized	\N
74120	1916	attendance	262	Person Entered	27-08-2026 11:03:31	95053	0.85	unrecognized	2026-08-27 19:12:55.754874	\N	Person #262	0	unrecognized	2026-08-27 19:13:43.725654
74155	1916	attendance	309	Person Entered	27-08-2026 11:08:24	102568	0.85	unrecognized	2026-08-27 19:22:26.41432	\N	Person #309	0	unrecognized	2026-08-27 19:22:34.656897
74131	1916	attendance	278	Person Entered	27-08-2026 11:05:16	97715	0.85	unrecognized	2026-08-27 19:16:29.229865	\N	Person #278	0	unrecognized	2026-08-27 19:17:02.63569
74141	1916	attendance	293	Person Entered	27-08-2026 11:07:37	101414	0.85	pending	2026-08-27 19:19:18.520127	\N	Person #293	0	unrecognized	\N
74158	1916	attendance	314	Person Entered	27-08-2026 11:08:28	102660	0.85	unrecognized	2026-08-27 19:23:10.755557	\N	Person #314	0	unrecognized	2026-08-27 19:23:23.568367
74150	1916	attendance	303	Person Entered	27-08-2026 11:08:14	102325	0.85	unrecognized	2026-08-27 19:20:42.249815	\N	Person #303	0	unrecognized	2026-08-27 19:20:52.246958
74168	1916	attendance	330	Person Entered	27-08-2026 11:09:21	104015	0.85	pending	2026-08-27 19:26:19.182014	\N	Person #330	0	unrecognized	\N
74163	1916	attendance	321	Person Entered	27-08-2026 11:09:06	103527	0.85	unrecognized	2026-08-27 19:25:27.683427	\N	Person #321	0	unrecognized	2026-08-27 19:25:48.891967
74170	1916	attendance	331	Person Entered	27-08-2026 11:10:42	105154	0.85	unrecognized	2026-08-27 19:26:27.982662	\N	Person #331	0	unrecognized	2026-08-27 19:27:53.0813
74174	1916	attendance	339	Person Entered	27-08-2026 11:11:04	106389	0.85	unrecognized	2026-08-27 19:27:54.28839	\N	Person #339	0	unrecognized	2026-08-27 19:28:21.068487
74176	1916	attendance	344	Person Entered	27-08-2026 11:11:20	106826	0.85	unrecognized	2026-08-27 19:28:30.490892	\N	Person #344	0	unrecognized	2026-08-27 19:29:00.191278
79503	1951	breakout	10	Break Out	25-08-2026 19:00:29	8020	0.85	normal	2026-08-28 14:35:28.811422	STF-025	Farhan Virk	0.4635	recognized	2026-08-28 14:35:36.876435
77750	1918	breakout	6	Break Out	27-08-2026 14:03:50	4725	0.85	unrecognized	2026-08-28 09:47:43.5434	\N	Person #6	0	unrecognized	2026-08-28 09:47:44.504171
74835	1916	attendance	37	Person Entered	27-08-2026 17:53:00	710067	0.85	unrecognized	2026-08-28 06:08:55.940579	\N	Person #37	0	unrecognized	2026-08-28 06:09:07.487212
77752	1918	breakout	7	Break Out	27-08-2026 14:04:08	5083	0.85	unrecognized	2026-08-28 09:47:46.539443	\N	Person #7	0	unrecognized	2026-08-28 09:47:53.280124
74007	1916	checkin	116	check_in	27-08-2026 10:35:48	53663	0.85	normal	2026-08-27 18:50:44.947066	STF-009	Tariq Ghulam Hussain	0.474	recognized	2026-08-27 18:50:57.355737
77740	1918	breakout	1	Break Out	27-08-2026 14:01:18	899	0.85	normal	2026-08-28 09:46:52.714993	STF-002	Abdur Rehman	0.4537	recognized	2026-08-28 09:46:59.211369
74869	1917	breakin	12	Break In	27-08-2026 14:00:37	2955	0.85	unrecognized	2026-08-28 06:10:56.810669	\N	Person #12	0	unrecognized	2026-08-28 06:11:14.084148
73982	1916	checkin	87	check_in	27-08-2026 10:34:18	50780	0.85	normal	2026-08-27 18:46:37.495221	STF-037	Muhammad Fahad	0.4677	recognized	2026-08-27 18:46:50.760843
74053	1916	checkin	177	check_in	27-08-2026 10:51:00	76063	0.85	normal	2026-08-27 18:57:58.605892	STF-033	Raza Abbas	0.4493	recognized	2026-08-27 18:58:08.900231
74925	1916	attendance	67	Person Entered	27-08-2026 18:02:00	723307	0.85	unrecognized	2026-08-28 06:14:16.658705	\N	Person #67	0	unrecognized	2026-08-28 06:14:33.840064
77746	1918	breakout	4	Break Out	27-08-2026 14:02:26	2565	0.85	normal	2026-08-28 09:47:10.710836	STF-033	Raza Abbas	0.4489	recognized	2026-08-28 09:47:20.20649
74830	1916	attendance	35	Person Entered	27-08-2026 17:51:59	707928	0.85	unrecognized	2026-08-28 06:08:33.967789	\N	Person #35	0	unrecognized	2026-08-28 06:08:50.752416
74820	1916	attendance	30	Person Entered	27-08-2026 17:51:00	706628	0.85	unrecognized	2026-08-28 06:08:13.111467	\N	Person #30	0	unrecognized	2026-08-28 06:08:20.44295
75104	1917	breakin	54	Break In	27-08-2026 14:05:00	10836	0.85	unrecognized	2026-08-28 06:27:11.058258	\N	Person #54	0	unrecognized	2026-08-28 06:27:11.945825
77760	1918	breakout	9	Break Out	27-08-2026 14:05:21	7000	0.85	normal	2026-08-28 09:48:09.802162	STF-025	Farhan Virk	0.4546	recognized	2026-08-28 09:48:12.733302
74858	1917	breakin	9	Break In	27-08-2026 14:00:12	2401	0.85	unrecognized	2026-08-28 06:10:26.207493	\N	Person #9	0	unrecognized	2026-08-28 06:10:31.077964
77748	1918	breakout	6	Break Out	27-08-2026 14:03:17	3804	0.85	unrecognized	2026-08-28 09:47:32.455426	\N	Person #6	0	unrecognized	2026-08-28 09:47:43.004182
74090	1916	checkin	224	check_in	27-08-2026 10:59:37	89372	0.85	normal	2026-08-27 19:07:36.754613	STF-070	Amanat Ali	0.4806	recognized	2026-08-27 19:07:43.564406
74061	1916	checkin	188	check_in	27-08-2026 10:52:00	78356	0.85	normal	2026-08-27 18:59:06.533494	STF-048	Abdullah Sultan	0.4781	recognized	2026-08-27 18:59:11.645455
77747	1918	breakout	5	Break Out	27-08-2026 14:03:03	3472	0.85	unrecognized	2026-08-28 09:47:21.498819	\N	Person #5	0	unrecognized	2026-08-28 09:47:31.930709
77755	1918	breakout	7	Break Out	27-08-2026 14:04:42	5994	0.85	unrecognized	2026-08-28 09:47:53.7867	\N	Person #7	0	unrecognized	2026-08-28 09:47:55.41973
75049	1916	attendance	124	Person Entered	27-08-2026 18:24:19	756407	0.85	unrecognized	2026-08-28 06:23:41.294186	\N	Person #124	0	unrecognized	2026-08-28 06:23:58.17474
74129	1916	checkin	276	check_in	27-08-2026 11:05:00	97453	0.85	normal	2026-08-27 19:15:41.012808	STF-084	Naseer Ahmed	0.4459	recognized	2026-08-27 19:15:54.674112
78114	1918	breakout	101	Break Out	27-08-2026 11:22:35	118746	0.85	unrecognized	2026-08-28 10:08:32.487443	\N	Person #101	0	unrecognized	2026-08-28 10:09:08.56668
77751	1918	breakout	6	Break Out	27-08-2026 14:03:56	4855	0.85	unrecognized	2026-08-28 09:47:44.780942	\N	Person #6	0	unrecognized	2026-08-28 09:47:45.959711
77756	1918	breakout	7	Break Out	27-08-2026 14:04:49	6167	0.85	unrecognized	2026-08-28 09:47:55.672684	\N	Person #7	0	unrecognized	2026-08-28 09:47:56.92036
74084	1916	checkin	216	check_in	27-08-2026 10:57:46	86641	0.85	normal	2026-08-27 19:05:19.262569	STF-024	Arsalan Khan	0.4407	recognized	2026-08-27 19:05:19.529401
74113	1916	checkin	254	check_in	27-08-2026 11:02:18	93400	0.85	normal	2026-08-27 19:11:51.07346	STF-071	Muhammad Daniyal Abid	0.4908	recognized	2026-08-27 19:11:57.077507
74862	1917	breakin	10	Break In	27-08-2026 14:00:18	2561	0.85	unrecognized	2026-08-28 06:10:31.925893	\N	Person #10	0	unrecognized	2026-08-28 06:10:53.877645
75034	1917	breakin	39	Break In	27-08-2026 18:03:54	10837	0.85	normal	2026-08-28 06:22:52.212184	STF-010	Faraz Younas	0.4753	recognized	2026-08-28 06:22:57.777436
75165	1917	breakin	76	Break In	27-08-2026 18:11:57	22910	0.85	unrecognized	2026-08-28 06:34:02.69095	\N	Person #76	0	unrecognized	2026-08-28 06:34:13.839649
74164	1916	checkin	325	check_in	27-08-2026 11:09:35	103724	0.85	normal	2026-08-27 19:25:50.102839	STF-017	Mohammad Zahid	0.5371	recognized	2026-08-27 19:26:00.215762
74970	1916	attendance	96	Person Entered	27-08-2026 18:12:04	738043	0.85	unrecognized	2026-08-28 06:18:20.60551	\N	Person #96	0	unrecognized	2026-08-28 06:18:36.593797
74167	1916	checkin	329	check_in	27-08-2026 11:09:44	103978	0.85	normal	2026-08-27 19:26:12.538851	STF-017	Mohammad Zahid	0.46	recognized	2026-08-27 19:26:14.274484
74955	1917	breakin	24	Break In	27-08-2026 14:03:17	7122	0.85	normal	2026-08-28 06:16:57.770643	STF-046	Usman Babar	0.5059	recognized	2026-08-28 06:16:59.614704
75078	1916	attendance	131	Person Entered	27-08-2026 18:33:53	770764	0.85	unrecognized	2026-08-28 06:25:45.069389	\N	Person #131	0	unrecognized	2026-08-28 06:26:03.525238
78121	1918	breakout	103	Break Out	27-08-2026 11:22:51	119156	0.85	unrecognized	2026-08-28 10:09:12.56896	\N	Person #103	0	unrecognized	2026-08-28 10:09:26.078169
75341	1916	attendance	278	Person Entered	27-08-2026 20:06:49	910212	0.85	unrecognized	2026-08-28 06:47:19.988404	\N	Person #278	0	unrecognized	2026-08-28 06:47:21.598463
75136	1917	breakin	132	Break In	27-08-2026 11:08:59	102841	0.85	normal	2026-08-28 06:31:06.351881	STF-022	Mubashir Ishaq	0.4613	recognized	2026-08-28 06:31:11.49272
75126	1916	attendance	156	Person Entered	27-08-2026 18:47:58	791891	0.85	unrecognized	2026-08-28 06:29:13.122288	\N	Person #156	0	unrecognized	2026-08-28 06:29:33.3426
75129	1916	attendance	158	Person Entered	27-08-2026 18:58:47	808169	0.85	pending	2026-08-28 06:30:06.181432	\N	Person #158	0	unrecognized	\N
75343	1916	attendance	280	Person Entered	27-08-2026 20:08:09	912217	0.85	pending	2026-08-28 06:47:25.675522	\N	Person #280	\N	pending	\N
75151	1916	attendance	192	Person Entered	27-08-2026 19:13:00	830548	0.85	unrecognized	2026-08-28 06:32:20.004318	\N	Person #192	0	unrecognized	2026-08-28 06:32:40.9228
75349	1916	attendance	286	Person Entered	27-08-2026 20:10:38	915921	0.85	unrecognized	2026-08-28 06:47:33.435826	\N	Person #286	0	unrecognized	2026-08-28 06:47:38.586208
75187	1917	breakin	83	Break In	27-08-2026 18:13:23	25057	0.85	normal	2026-08-28 06:35:44.865507	STF-036	Shahzad Ali	0.4533	recognized	2026-08-28 06:35:49.37486
75379	1916	attendance	300	Person Entered	27-08-2026 20:14:15	921328	0.85	unrecognized	2026-08-28 06:49:31.473023	\N	Person #300	0	unrecognized	2026-08-28 06:49:47.516886
74186	1916	attendance	357	Person Entered	27-08-2026 11:15:12	112621	0.85	unrecognized	2026-08-27 19:30:38.186741	\N	Person #357	0	unrecognized	2026-08-27 19:31:06.149674
74198	1916	attendance	374	Person Entered	27-08-2026 11:23:38	124682	0.85	unrecognized	2026-08-27 19:34:57.357494	\N	Person #374	0	unrecognized	2026-08-27 19:35:25.154489
74182	1916	attendance	352	Person Entered	27-08-2026 11:13:03	109311	0.85	unrecognized	2026-08-27 19:29:27.003038	\N	Person #352	0	unrecognized	2026-08-27 19:30:14.935697
74205	1916	attendance	383	Person Entered	27-08-2026 11:27:17	130230	0.85	unrecognized	2026-08-27 19:37:01.328839	\N	Person #383	0	unrecognized	2026-08-27 19:37:15.022826
74184	1916	attendance	354	Person Entered	27-08-2026 11:14:04	111036	0.85	unrecognized	2026-08-27 19:30:17.196868	\N	Person #354	0	unrecognized	2026-08-27 19:30:26.942047
74201	1916	attendance	378	Person Entered	27-08-2026 11:25:31	128254	0.85	pending	2026-08-27 19:36:06.961857	\N	Person #378	0	unrecognized	\N
74196	1916	attendance	371	Person Entered	27-08-2026 11:22:37	123140	0.85	unrecognized	2026-08-27 19:34:11.586361	\N	Person #371	0	unrecognized	2026-08-27 19:34:49.878962
78113	1918	breakout	117	Break Out	27-08-2026 14:39:54	58867	0.85	pending	2026-08-28 10:08:29.884766	\N	Person #117	0	unrecognized	\N
74194	1916	attendance	368	Person Entered	27-08-2026 11:21:00	120676	0.85	unrecognized	2026-08-27 19:32:55.137396	\N	Person #368	0	unrecognized	2026-08-27 19:33:31.033898
74190	1916	attendance	361	Person Entered	27-08-2026 11:16:31	114450	0.85	unrecognized	2026-08-27 19:31:47.586739	\N	Person #361	0	unrecognized	2026-08-27 19:32:28.163576
74187	1916	attendance	357	Person Entered	27-08-2026 11:15:21	112939	0.85	unrecognized	2026-08-27 19:31:06.829402	\N	Person #357	0	unrecognized	2026-08-27 19:31:17.359401
74185	1916	attendance	355	Person Entered	27-08-2026 11:15:18	112285	0.85	unrecognized	2026-08-27 19:30:28.274787	\N	Person #355	0	unrecognized	2026-08-27 19:30:37.155111
74191	1916	attendance	363	Person Entered	27-08-2026 11:16:46	115135	0.85	pending	2026-08-27 19:32:29.348391	\N	Person #363	0	unrecognized	\N
74180	1916	attendance	349	Person Entered	27-08-2026 11:13:12	109151	0.85	unrecognized	2026-08-27 19:29:16.975319	\N	Person #349	0	unrecognized	2026-08-27 19:29:23.079547
74192	1916	attendance	364	Person Entered	27-08-2026 11:19:22	118329	0.85	unrecognized	2026-08-27 19:32:34.241825	\N	Person #364	0	unrecognized	2026-08-27 19:32:48.001639
74183	1916	attendance	353	Person Entered	27-08-2026 11:12:56	109362	0.85	unrecognized	2026-08-27 19:29:37.009364	\N	Person #353	0	unrecognized	2026-08-27 19:29:45.993233
74195	1916	attendance	370	Person Entered	27-08-2026 11:20:55	121181	0.85	unrecognized	2026-08-27 19:33:32.637422	\N	Person #370	0	unrecognized	2026-08-27 19:34:08.422369
74189	1916	attendance	359	Person Entered	27-08-2026 11:16:16	114292	0.85	unrecognized	2026-08-27 19:31:32.098622	\N	Person #359	0	unrecognized	2026-08-27 19:31:47.060946
74203	1916	attendance	381	Person Entered	27-08-2026 11:26:25	129403	0.85	unrecognized	2026-08-27 19:36:17.05828	\N	Person #381	0	unrecognized	2026-08-27 19:36:52.828928
74199	1916	attendance	375	Person Entered	27-08-2026 11:24:48	127046	0.85	unrecognized	2026-08-27 19:35:27.265593	\N	Person #375	0	unrecognized	2026-08-27 19:35:54.377903
74211	1916	attendance	389	Person Entered	27-08-2026 11:32:03	137869	0.85	unrecognized	2026-08-27 19:38:20.056664	\N	Person #389	0	unrecognized	2026-08-27 19:39:11.209304
74212	1916	attendance	390	Person Entered	27-08-2026 11:33:23	138006	0.85	unrecognized	2026-08-27 19:38:44.130472	\N	Person #390	0	unrecognized	2026-08-27 19:39:46.767607
74209	1916	attendance	387	Person Entered	27-08-2026 11:30:17	135362	0.85	unrecognized	2026-08-27 19:37:54.221335	\N	Person #387	0	unrecognized	2026-08-27 19:38:04.172838
74214	1916	attendance	392	Person Entered	27-08-2026 11:32:04	138100	0.85	pending	2026-08-27 19:39:24.017463	\N	Person #392	0	unrecognized	\N
74215	1916	attendance	395	Person Entered	27-08-2026 11:32:17	138411	0.85	pending	2026-08-27 19:39:50.629071	\N	Person #395	0	unrecognized	\N
74206	1916	attendance	384	Person Entered	27-08-2026 11:28:39	132864	0.85	unrecognized	2026-08-27 19:37:18.049404	\N	Person #384	0	unrecognized	2026-08-27 19:37:33.850629
74210	1916	attendance	388	Person Entered	27-08-2026 11:31:05	136525	0.85	unrecognized	2026-08-27 19:38:05.816823	\N	Person #388	0	unrecognized	2026-08-27 19:38:18.431172
74216	1916	attendance	396	Person Entered	27-08-2026 11:32:25	138617	0.85	pending	2026-08-27 19:39:54.644571	\N	Person #396	0	unrecognized	\N
74217	1916	attendance	397	Person Entered	27-08-2026 11:32:34	138804	0.85	unrecognized	2026-08-27 19:39:57.418616	\N	Person #397	0	unrecognized	2026-08-27 19:40:05.913945
74213	1916	attendance	391	Person Entered	27-08-2026 11:32:06	138067	0.85	unrecognized	2026-08-27 19:39:10.699558	\N	Person #391	0	unrecognized	2026-08-27 19:39:34.632027
74219	1916	attendance	400	Person Entered	27-08-2026 11:33:11	139174	0.85	unrecognized	2026-08-27 19:40:09.672545	\N	Person #400	0	unrecognized	2026-08-27 19:40:09.803147
74218	1916	attendance	399	Person Entered	27-08-2026 11:32:46	139128	0.85	pending	2026-08-27 19:40:07.869571	\N	Person #399	0	unrecognized	\N
74220	1916	attendance	402	Person Entered	27-08-2026 11:33:18	139772	0.85	unrecognized	2026-08-27 19:40:11.355218	\N	Person #402	0	unrecognized	2026-08-27 19:40:39.972377
74221	1916	attendance	404	Person Entered	27-08-2026 11:34:13	140473	0.85	unrecognized	2026-08-27 19:40:41.236943	\N	Person #404	0	unrecognized	2026-08-27 19:41:22.658927
74223	1916	attendance	405	Person Entered	27-08-2026 11:34:21	141249	0.85	unrecognized	2026-08-27 19:41:28.438332	\N	Person #405	0	unrecognized	2026-08-27 19:42:30.860525
74256	1916	attendance	451	Person Entered	27-08-2026 11:47:58	161934	0.85	pending	2026-08-27 19:48:15.831461	\N	Person #451	0	unrecognized	\N
74245	1916	attendance	432	Person Entered	27-08-2026 11:43:19	154249	0.85	unrecognized	2026-08-27 19:46:47.43767	\N	Person #432	0	unrecognized	2026-08-27 19:47:02.268903
74225	1916	attendance	408	Person Entered	27-08-2026 11:34:20	141456	0.85	unrecognized	2026-08-27 19:42:13.915528	\N	Person #408	0	unrecognized	2026-08-27 19:42:27.630235
74239	1916	attendance	425	Person Entered	27-08-2026 11:38:56	148392	0.85	pending	2026-08-27 19:45:44.909858	\N	Person #425	0	unrecognized	\N
74117	1916	checkin	259	check_in	27-08-2026 11:02:44	94075	0.85	normal	2026-08-27 19:12:24.124623	STF-015	Liaqat Ali	0.4789	recognized	2026-08-27 19:12:28.151785
74259	1916	attendance	453	Person Entered	27-08-2026 11:50:00	164582	0.85	unrecognized	2026-08-27 19:48:37.607542	\N	Person #453	0	unrecognized	2026-08-27 19:48:46.005139
74226	1916	attendance	409	Person Entered	27-08-2026 11:34:27	141604	0.85	unrecognized	2026-08-27 19:42:31.632171	\N	Person #409	0	unrecognized	2026-08-27 19:42:43.219427
74224	1916	attendance	407	Person Entered	27-08-2026 11:34:18	141425	0.85	unrecognized	2026-08-27 19:42:01.786526	\N	Person #407	0	unrecognized	2026-08-27 19:42:11.468888
74260	1916	attendance	456	Person Entered	27-08-2026 11:49:46	164629	0.85	pending	2026-08-27 19:48:46.347669	\N	Person #456	\N	pending	\N
74250	1916	attendance	444	Person Entered	27-08-2026 11:47:51	160941	0.85	unrecognized	2026-08-27 19:47:48.903021	\N	Person #444	0	unrecognized	2026-08-27 19:48:03.185711
74241	1916	attendance	428	Person Entered	27-08-2026 11:39:26	149062	0.85	unrecognized	2026-08-27 19:46:03.834001	\N	Person #428	0	unrecognized	2026-08-27 19:46:18.664678
74244	1916	attendance	431	Person Entered	27-08-2026 11:42:47	154108	0.85	unrecognized	2026-08-27 19:46:34.196479	\N	Person #431	0	unrecognized	2026-08-27 19:46:46.639153
74251	1916	attendance	444	Person Entered	27-08-2026 11:47:34	161342	0.85	pending	2026-08-27 19:48:03.521325	\N	Person #444	0	unrecognized	\N
74252	1916	attendance	448	Person Entered	27-08-2026 11:47:36	161380	0.85	pending	2026-08-27 19:48:04.063954	\N	Person #448	0	unrecognized	\N
74233	1916	attendance	416	Person Entered	27-08-2026 11:37:50	146275	0.85	unrecognized	2026-08-27 19:43:55.044211	\N	Person #416	0	unrecognized	2026-08-27 19:45:20.475492
74248	1916	attendance	437	Person Entered	27-08-2026 11:45:42	158490	0.85	unrecognized	2026-08-27 19:47:27.627287	\N	Person #437	0	unrecognized	2026-08-27 19:47:39.320962
74253	1916	attendance	449	Person Entered	27-08-2026 11:47:38	161426	0.85	pending	2026-08-27 19:48:05.796362	\N	Person #449	\N	pending	\N
74246	1916	attendance	433	Person Entered	27-08-2026 11:43:16	154836	0.85	unrecognized	2026-08-27 19:47:03.056837	\N	Person #433	0	unrecognized	2026-08-27 19:47:13.422228
74254	1916	attendance	450	Person Entered	27-08-2026 11:47:48	161689	0.85	pending	2026-08-27 19:48:07.588556	\N	Person #450	0	unrecognized	\N
74258	1916	attendance	452	Person Entered	27-08-2026 11:49:51	164078	0.85	unrecognized	2026-08-27 19:48:24.915488	\N	Person #452	0	unrecognized	2026-08-27 19:48:36.33881
74255	1916	attendance	450	Person Entered	27-08-2026 11:48:23	161904	0.85	unrecognized	2026-08-27 19:48:11.801986	\N	Person #450	0	unrecognized	2026-08-27 19:48:22.162823
74257	1916	attendance	451	Person Entered	27-08-2026 11:48:08	162180	0.85	pending	2026-08-27 19:48:22.904782	\N	Person #451	\N	pending	\N
74261	1916	attendance	457	Person Entered	27-08-2026 11:51:31	167224	0.85	unrecognized	2026-08-27 19:48:49.185814	\N	Person #457	0	unrecognized	2026-08-27 19:48:58.421946
74264	1916	attendance	461	Person Entered	27-08-2026 11:52:58	169386	0.85	unrecognized	2026-08-27 19:49:10.250742	\N	Person #461	0	unrecognized	2026-08-27 19:49:21.234376
74265	1916	attendance	462	Person Entered	27-08-2026 11:54:00	170980	0.85	unrecognized	2026-08-27 19:49:23.182625	\N	Person #462	0	unrecognized	2026-08-27 19:49:37.006947
74266	1916	attendance	463	Person Entered	27-08-2026 11:56:00	174486	0.85	unrecognized	2026-08-27 19:49:39.820247	\N	Person #463	0	unrecognized	2026-08-27 19:50:00.288458
74267	1916	attendance	465	Person Entered	27-08-2026 11:57:17	175171	0.85	unrecognized	2026-08-27 19:50:01.77523	\N	Person #465	0	unrecognized	2026-08-27 19:50:27.207443
74405	1916	attendance	645	Person Entered	27-08-2026 13:26:58	310429	0.85	pending	2026-08-27 20:16:06.709886	\N	Person #645	0	unrecognized	\N
74303	1916	attendance	510	Person Entered	27-08-2026 12:08:02	192036	0.85	pending	2026-08-27 19:56:30.484401	\N	Person #510	0	unrecognized	\N
74304	1916	attendance	510	Person Entered	27-08-2026 12:08:40	192998	0.85	pending	2026-08-27 19:56:32.405629	\N	Person #510	\N	pending	\N
74274	1916	attendance	482	Person Entered	27-08-2026 12:00:13	179379	0.85	unrecognized	2026-08-27 19:51:11.983076	\N	Person #482	0	unrecognized	2026-08-27 19:52:20.860127
74277	1916	attendance	489	Person Entered	27-08-2026 11:59:59	179971	0.85	pending	2026-08-27 19:52:21.604773	\N	Person #489	0	unrecognized	\N
74278	1916	attendance	491	Person Entered	27-08-2026 12:00:13	180323	0.85	pending	2026-08-27 19:52:23.729179	\N	Person #491	\N	pending	\N
74282	1916	attendance	498	Person Entered	27-08-2026 12:02:11	183256	0.85	pending	2026-08-27 19:53:19.287765	\N	Person #498	\N	pending	\N
74306	1916	attendance	513	Person Entered	27-08-2026 12:08:52	193088	0.85	unrecognized	2026-08-27 19:56:36.156107	\N	Person #513	0	unrecognized	2026-08-27 19:56:59.947706
74296	1916	attendance	509	Person Entered	27-08-2026 12:05:36	188355	0.85	unrecognized	2026-08-27 19:55:42.508257	\N	Person #509	0	unrecognized	2026-08-27 19:55:43.866767
74271	1916	attendance	472	Person Entered	27-08-2026 11:58:19	177396	0.85	unrecognized	2026-08-27 19:50:42.746165	\N	Person #472	0	unrecognized	2026-08-27 19:50:54.289033
74275	1916	attendance	485	Person Entered	27-08-2026 11:59:42	179531	0.85	pending	2026-08-27 19:51:41.663456	\N	Person #485	\N	pending	\N
74276	1916	attendance	487	Person Entered	27-08-2026 11:59:44	179554	0.85	unrecognized	2026-08-27 19:51:46.697153	\N	Person #487	0	unrecognized	2026-08-27 19:51:57.693605
74291	1916	attendance	506	Person Entered	27-08-2026 12:04:59	187336	0.85	unrecognized	2026-08-27 19:55:11.447175	\N	Person #506	0	unrecognized	2026-08-27 19:55:22.95952
74292	1916	attendance	506	Person Entered	27-08-2026 12:05:12	187672	0.85	unrecognized	2026-08-27 19:55:23.331995	\N	Person #506	0	unrecognized	2026-08-27 19:55:27.582395
74284	1916	attendance	499	Person Entered	27-08-2026 12:02:30	183744	0.85	pending	2026-08-27 19:53:54.011979	\N	Person #499	0	unrecognized	\N
74293	1916	attendance	506	Person Entered	27-08-2026 12:05:16	187889	0.85	unrecognized	2026-08-27 19:55:27.858675	\N	Person #506	0	unrecognized	2026-08-27 19:55:27.874296
74280	1916	attendance	496	Person Entered	27-08-2026 12:01:38	182336	0.85	unrecognized	2026-08-27 19:52:50.864372	\N	Person #496	0	unrecognized	2026-08-27 19:53:09.897162
74066	1916	checkin	198	check_in	27-08-2026 10:54:00	81405	0.85	normal	2026-08-27 19:01:26.831052	STF-072	Fahad Ali	0.5095	recognized	2026-08-27 19:01:27.581739
74279	1916	attendance	493	Person Entered	27-08-2026 12:01:35	181944	0.85	unrecognized	2026-08-27 19:52:25.766631	\N	Person #493	0	unrecognized	2026-08-27 19:52:49.673391
74294	1916	attendance	506	Person Entered	27-08-2026 12:05:20	187989	0.85	pending	2026-08-27 19:55:28.161828	\N	Person #506	0	unrecognized	\N
74273	1916	attendance	478	Person Entered	27-08-2026 11:59:12	178735	0.85	unrecognized	2026-08-27 19:50:58.580161	\N	Person #478	0	unrecognized	2026-08-27 19:51:10.489725
74272	1916	attendance	474	Person Entered	27-08-2026 11:58:17	177418	0.85	pending	2026-08-27 19:50:47.726417	\N	Person #474	0	unrecognized	\N
74268	1916	attendance	467	Person Entered	27-08-2026 11:57:00	176232	0.85	unrecognized	2026-08-27 19:50:28.709595	\N	Person #467	0	unrecognized	2026-08-27 19:50:37.99771
74269	1916	attendance	470	Person Entered	27-08-2026 11:58:09	177218	0.85	pending	2026-08-27 19:50:40.119292	\N	Person #470	0	unrecognized	\N
74270	1916	attendance	471	Person Entered	27-08-2026 11:58:11	177251	0.85	pending	2026-08-27 19:50:41.519934	\N	Person #471	\N	pending	\N
74286	1916	attendance	504	Person Entered	27-08-2026 12:02:49	183930	0.85	unrecognized	2026-08-27 19:54:01.723981	\N	Person #504	0	unrecognized	2026-08-27 19:54:54.158966
74287	1916	attendance	505	Person Entered	27-08-2026 12:02:51	184270	0.85	pending	2026-08-27 19:54:54.869231	\N	Person #505	0	unrecognized	\N
74283	1916	attendance	498	Person Entered	27-08-2026 12:02:31	183450	0.85	unrecognized	2026-08-27 19:53:20.153714	\N	Person #498	0	unrecognized	2026-08-27 19:53:59.36396
74285	1916	attendance	501	Person Entered	27-08-2026 12:02:32	183778	0.85	pending	2026-08-27 19:53:59.743262	\N	Person #501	\N	pending	\N
74288	1916	attendance	506	Person Entered	27-08-2026 12:04:18	186442	0.85	pending	2026-08-27 19:55:07.141147	\N	Person #506	0	unrecognized	\N
74289	1916	attendance	507	Person Entered	27-08-2026 12:04:21	186513	0.85	pending	2026-08-27 19:55:10.156579	\N	Person #507	\N	pending	\N
74290	1916	attendance	506	Person Entered	27-08-2026 12:04:47	187158	0.85	pending	2026-08-27 19:55:11.08496	\N	Person #506	\N	pending	\N
74308	1916	attendance	515	Person Entered	27-08-2026 12:10:41	196002	0.85	pending	2026-08-27 19:57:10.751574	\N	Person #515	0	unrecognized	\N
74300	1916	attendance	510	Person Entered	27-08-2026 12:07:38	191270	0.85	unrecognized	2026-08-27 19:55:59.714872	\N	Person #510	0	unrecognized	2026-08-27 19:56:29.084841
74301	1916	attendance	510	Person Entered	27-08-2026 12:07:40	191497	0.85	pending	2026-08-27 19:56:29.522126	\N	Person #510	\N	pending	\N
74295	1916	attendance	509	Person Entered	27-08-2026 12:05:31	188128	0.85	unrecognized	2026-08-27 19:55:31.068573	\N	Person #509	0	unrecognized	2026-08-27 19:55:42.233973
74302	1916	attendance	510	Person Entered	27-08-2026 12:07:50	191741	0.85	pending	2026-08-27 19:56:30.133615	\N	Person #510	\N	pending	\N
74298	1916	attendance	510	Person Entered	27-08-2026 12:07:33	190702	0.85	unrecognized	2026-08-27 19:55:46.382397	\N	Person #510	0	unrecognized	2026-08-27 19:55:55.861879
74297	1916	attendance	509	Person Entered	27-08-2026 12:07:09	190688	0.85	unrecognized	2026-08-27 19:55:46.076686	\N	Person #509	0	unrecognized	2026-08-27 19:55:50.447551
74299	1916	attendance	510	Person Entered	27-08-2026 12:07:15	190856	0.85	pending	2026-08-27 19:55:56.39918	\N	Person #510	0	unrecognized	\N
74307	1916	attendance	514	Person Entered	27-08-2026 12:09:21	193977	0.85	unrecognized	2026-08-27 19:57:01.677773	\N	Person #514	0	unrecognized	2026-08-27 19:57:08.092411
74305	1916	attendance	511	Person Entered	27-08-2026 12:08:42	193020	0.85	unrecognized	2026-08-27 19:56:32.749951	\N	Person #511	0	unrecognized	2026-08-27 19:56:34.970164
74309	1916	attendance	515	Person Entered	27-08-2026 12:11:39	197452	0.85	pending	2026-08-27 19:57:19.679247	\N	Person #515	0	unrecognized	\N
74310	1916	attendance	516	Person Entered	27-08-2026 12:11:44	197585	0.85	pending	2026-08-27 19:57:24.396142	\N	Person #516	0	unrecognized	\N
74313	1916	attendance	526	Person Entered	27-08-2026 12:14:33	201230	0.85	unrecognized	2026-08-27 19:58:22.706225	\N	Person #526	0	unrecognized	2026-08-27 19:59:13.914169
74312	1916	attendance	522	Person Entered	27-08-2026 12:13:24	199315	0.85	unrecognized	2026-08-27 19:57:43.187605	\N	Person #522	0	unrecognized	2026-08-27 19:58:20.692632
74349	1916	attendance	581	Person Entered	27-08-2026 12:39:38	239373	0.85	unrecognized	2026-08-27 20:06:13.891847	\N	Person #581	0	unrecognized	2026-08-27 20:06:16.882503
74333	1916	attendance	558	Person Entered	27-08-2026 12:30:34	225631	0.85	unrecognized	2026-08-27 20:02:58.675598	\N	Person #558	0	unrecognized	2026-08-27 20:03:35.868327
74330	1916	attendance	555	Person Entered	27-08-2026 12:27:46	221509	0.85	unrecognized	2026-08-27 20:02:33.360664	\N	Person #555	0	unrecognized	2026-08-27 20:02:41.083761
74331	1916	attendance	556	Person Entered	27-08-2026 12:29:51	224120	0.85	unrecognized	2026-08-27 20:02:43.478109	\N	Person #556	0	unrecognized	2026-08-27 20:02:54.006448
74332	1916	attendance	557	Person Entered	27-08-2026 12:30:09	225201	0.85	pending	2026-08-27 20:02:55.787712	\N	Person #557	0	unrecognized	\N
74317	1916	attendance	535	Person Entered	27-08-2026 12:18:27	207009	0.85	unrecognized	2026-08-27 19:59:42.526961	\N	Person #535	0	unrecognized	2026-08-27 19:59:49.852298
74314	1916	attendance	530	Person Entered	27-08-2026 12:17:23	205393	0.85	unrecognized	2026-08-27 19:59:17.267863	\N	Person #530	0	unrecognized	2026-08-27 19:59:30.185137
74322	1916	attendance	541	Person Entered	27-08-2026 12:24:59	217232	0.85	unrecognized	2026-08-27 20:01:09.988244	\N	Person #541	0	unrecognized	2026-08-27 20:01:51.870734
74316	1916	attendance	534	Person Entered	27-08-2026 12:17:33	205836	0.85	unrecognized	2026-08-27 19:59:33.778309	\N	Person #534	0	unrecognized	2026-08-27 19:59:40.67274
74323	1916	attendance	543	Person Entered	27-08-2026 12:25:21	218019	0.85	pending	2026-08-27 20:01:53.948756	\N	Person #543	0	unrecognized	\N
74324	1916	attendance	544	Person Entered	27-08-2026 12:25:51	218775	0.85	pending	2026-08-27 20:01:58.567425	\N	Person #544	0	unrecognized	\N
74315	1916	attendance	531	Person Entered	27-08-2026 12:17:37	205811	0.85	unrecognized	2026-08-27 19:59:31.187732	\N	Person #531	0	unrecognized	2026-08-27 19:59:33.29595
74325	1916	attendance	546	Person Entered	27-08-2026 12:26:07	219175	0.85	pending	2026-08-27 20:02:02.277191	\N	Person #546	0	unrecognized	\N
74334	1916	attendance	559	Person Entered	27-08-2026 12:30:34	225838	0.85	pending	2026-08-27 20:03:36.223464	\N	Person #559	0	unrecognized	\N
74343	1916	attendance	574	Person Entered	27-08-2026 12:36:05	234119	0.85	pending	2026-08-27 20:04:53.011788	\N	Person #574	0	unrecognized	\N
74318	1916	attendance	536	Person Entered	27-08-2026 12:18:10	207182	0.85	unrecognized	2026-08-27 19:59:50.731534	\N	Person #536	0	unrecognized	2026-08-27 20:00:01.737503
74319	1916	attendance	537	Person Entered	27-08-2026 12:19:35	209375	0.85	pending	2026-08-27 20:00:05.108477	\N	Person #537	0	unrecognized	\N
74348	1916	attendance	581	Person Entered	27-08-2026 12:39:57	238966	0.85	unrecognized	2026-08-27 20:06:00.686636	\N	Person #581	0	unrecognized	2026-08-27 20:06:13.342328
74335	1916	attendance	560	Person Entered	27-08-2026 12:32:33	228184	0.85	unrecognized	2026-08-27 20:03:42.180907	\N	Person #560	0	unrecognized	2026-08-27 20:03:51.115077
74320	1916	attendance	540	Person Entered	27-08-2026 12:20:00	210285	0.85	unrecognized	2026-08-27 20:00:23.682562	\N	Person #540	0	unrecognized	2026-08-27 20:00:40.053085
74345	1916	attendance	576	Person Entered	27-08-2026 12:36:45	235040	0.85	unrecognized	2026-08-27 20:05:03.805072	\N	Person #576	0	unrecognized	2026-08-27 20:05:23.900429
74329	1916	attendance	552	Person Entered	27-08-2026 12:27:21	220979	0.85	unrecognized	2026-08-27 20:02:20.632256	\N	Person #552	0	unrecognized	2026-08-27 20:02:30.516241
74321	1916	attendance	541	Person Entered	27-08-2026 12:24:33	216682	0.85	unrecognized	2026-08-27 20:00:45.44829	\N	Person #541	0	unrecognized	2026-08-27 20:01:09.249519
74344	1916	attendance	575	Person Entered	27-08-2026 12:36:44	235029	0.85	unrecognized	2026-08-27 20:05:01.195344	\N	Person #575	0	unrecognized	2026-08-27 20:05:17.94237
74336	1916	attendance	563	Person Entered	27-08-2026 12:32:45	228451	0.85	unrecognized	2026-08-27 20:03:52.189321	\N	Person #563	0	unrecognized	2026-08-27 20:04:06.017388
74326	1916	attendance	548	Person Entered	27-08-2026 12:26:33	219252	0.85	unrecognized	2026-08-27 20:02:05.639289	\N	Person #548	0	unrecognized	2026-08-27 20:02:15.234662
74327	1916	attendance	549	Person Entered	27-08-2026 12:26:12	219286	0.85	pending	2026-08-27 20:02:12.475057	\N	Person #549	0	unrecognized	\N
74822	1917	breakin	2	Break In	27-08-2026 10:45:16	67298	0.85	normal	2026-08-28 06:08:22.121801	STF-037	Muhammad Fahad	0.4753	recognized	2026-08-28 06:08:22.148729
74340	1916	attendance	569	Person Entered	27-08-2026 12:34:27	231625	0.85	unrecognized	2026-08-27 20:04:29.045252	\N	Person #569	0	unrecognized	2026-08-27 20:04:38.594115
74352	1916	attendance	584	Person Entered	27-08-2026 12:39:59	239873	0.85	unrecognized	2026-08-27 20:06:38.537524	\N	Person #584	0	unrecognized	2026-08-27 20:06:48.825743
74337	1916	attendance	564	Person Entered	27-08-2026 12:34:10	230614	0.85	unrecognized	2026-08-27 20:04:08.484793	\N	Person #564	0	unrecognized	2026-08-27 20:04:17.406655
74341	1916	attendance	571	Person Entered	27-08-2026 12:35:33	232796	0.85	unrecognized	2026-08-27 20:04:40.05599	\N	Person #571	0	unrecognized	2026-08-27 20:04:46.485692
74338	1916	attendance	567	Person Entered	27-08-2026 12:34:36	231304	0.85	unrecognized	2026-08-27 20:04:19.961143	\N	Person #567	0	unrecognized	2026-08-27 20:04:20.138918
74347	1916	attendance	580	Person Entered	27-08-2026 12:39:40	238696	0.85	unrecognized	2026-08-27 20:05:33.673178	\N	Person #580	0	unrecognized	2026-08-27 20:06:00.032855
74350	1916	attendance	582	Person Entered	27-08-2026 12:39:46	239527	0.85	unrecognized	2026-08-27 20:06:17.602833	\N	Person #582	0	unrecognized	2026-08-27 20:06:23.878054
74346	1916	attendance	579	Person Entered	27-08-2026 12:37:37	236367	0.85	unrecognized	2026-08-27 20:05:26.250487	\N	Person #579	0	unrecognized	2026-08-27 20:05:31.234464
74342	1916	attendance	573	Person Entered	27-08-2026 12:36:06	234098	0.85	unrecognized	2026-08-27 20:04:48.055551	\N	Person #573	0	unrecognized	2026-08-27 20:04:58.27734
74354	1916	attendance	588	Person Entered	27-08-2026 12:43:29	245213	0.85	pending	2026-08-27 20:07:05.254095	\N	Person #588	0	unrecognized	\N
74351	1916	attendance	583	Person Entered	27-08-2026 12:39:55	239770	0.85	unrecognized	2026-08-27 20:06:24.652273	\N	Person #583	0	unrecognized	2026-08-27 20:06:38.220947
74353	1916	attendance	586	Person Entered	27-08-2026 12:40:46	241071	0.85	unrecognized	2026-08-27 20:06:50.883753	\N	Person #586	0	unrecognized	2026-08-27 20:07:01.422453
74355	1916	attendance	589	Person Entered	27-08-2026 12:43:30	245249	0.85	pending	2026-08-27 20:07:06.911386	\N	Person #589	0	unrecognized	\N
74356	1916	attendance	591	Person Entered	27-08-2026 12:45:00	247489	0.85	pending	2026-08-27 20:07:10.754713	\N	Person #591	\N	pending	\N
74357	1916	attendance	592	Person Entered	27-08-2026 12:45:09	247706	0.85	pending	2026-08-27 20:07:11.815487	\N	Person #592	0	unrecognized	\N
74390	1916	attendance	626	Person Entered	27-08-2026 13:10:53	286262	0.85	unrecognized	2026-08-27 20:13:26.219927	\N	Person #626	0	unrecognized	2026-08-27 20:13:36.026714
74371	1916	attendance	608	Person Entered	27-08-2026 12:55:57	263320	0.85	unrecognized	2026-08-27 20:10:06.466713	\N	Person #608	0	unrecognized	2026-08-27 20:10:07.18896
74372	1916	attendance	609	Person Entered	27-08-2026 12:55:35	263352	0.85	unrecognized	2026-08-27 20:10:08.036731	\N	Person #609	0	unrecognized	2026-08-27 20:10:08.343549
74055	1916	checkin	178	check_in	27-08-2026 10:51:00	77346	0.85	normal	2026-08-27 18:58:25.406648	STF-004	Tanveer Hassan	0.5025	recognized	2026-08-27 18:58:25.836982
74362	1916	attendance	599	Person Entered	27-08-2026 12:51:15	256039	0.85	unrecognized	2026-08-27 20:07:54.429718	\N	Person #599	0	unrecognized	2026-08-27 20:08:34.067814
74378	1916	attendance	614	Person Entered	27-08-2026 12:58:00	266822	0.85	unrecognized	2026-08-27 20:10:47.178409	\N	Person #614	0	unrecognized	2026-08-27 20:11:12.366167
74379	1916	attendance	616	Person Entered	27-08-2026 12:58:12	267294	0.85	pending	2026-08-27 20:11:13.956312	\N	Person #616	0	unrecognized	\N
74358	1916	attendance	592	Person Entered	27-08-2026 12:45:59	248886	0.85	unrecognized	2026-08-27 20:07:15.790037	\N	Person #592	0	unrecognized	2026-08-27 20:07:29.304087
74369	1916	attendance	605	Person Entered	27-08-2026 12:55:28	263199	0.85	pending	2026-08-27 20:09:44.437751	\N	Person #605	0	unrecognized	\N
74374	1916	attendance	611	Person Entered	27-08-2026 12:57:30	266188	0.85	unrecognized	2026-08-27 20:10:21.656442	\N	Person #611	0	unrecognized	2026-08-27 20:10:29.350638
74375	1916	attendance	612	Person Entered	27-08-2026 12:57:33	266323	0.85	pending	2026-08-27 20:10:29.908736	\N	Person #612	0	unrecognized	\N
74363	1916	attendance	599	Person Entered	27-08-2026 12:51:30	256534	0.85	unrecognized	2026-08-27 20:08:34.476255	\N	Person #599	0	unrecognized	2026-08-27 20:08:52.550352
74361	1916	attendance	598	Person Entered	27-08-2026 12:49:46	254588	0.85	unrecognized	2026-08-27 20:07:44.589672	\N	Person #598	0	unrecognized	2026-08-27 20:07:53.078401
74360	1916	attendance	596	Person Entered	27-08-2026 12:46:41	250010	0.85	pending	2026-08-27 20:07:38.502725	\N	Person #596	0	unrecognized	\N
74370	1916	attendance	606	Person Entered	27-08-2026 12:55:30	263199	0.85	unrecognized	2026-08-27 20:09:44.453375	\N	Person #606	0	unrecognized	2026-08-27 20:09:56.829973
74364	1916	attendance	599	Person Entered	27-08-2026 12:51:56	257175	0.85	unrecognized	2026-08-27 20:08:53.525925	\N	Person #599	0	unrecognized	2026-08-27 20:09:18.422614
74395	1916	attendance	632	Person Entered	27-08-2026 13:13:45	290575	0.85	unrecognized	2026-08-27 20:14:00.519661	\N	Person #632	0	unrecognized	2026-08-27 20:14:09.601814
74385	1916	attendance	622	Person Entered	27-08-2026 13:03:14	274781	0.85	unrecognized	2026-08-27 20:12:00.34533	\N	Person #622	0	unrecognized	2026-08-27 20:12:09.070097
74386	1916	attendance	623	Person Entered	27-08-2026 13:03:27	275114	0.85	unrecognized	2026-08-27 20:12:09.951681	\N	Person #623	0	unrecognized	2026-08-27 20:12:20.645439
74365	1916	attendance	599	Person Entered	27-08-2026 12:51:40	257437	0.85	unrecognized	2026-08-27 20:09:18.881732	\N	Person #599	0	unrecognized	2026-08-27 20:09:28.035188
74384	1916	attendance	621	Person Entered	27-08-2026 13:00:04	270034	0.85	unrecognized	2026-08-27 20:11:46.210077	\N	Person #621	0	unrecognized	2026-08-27 20:11:55.79627
74383	1916	attendance	620	Person Entered	27-08-2026 12:59:42	268877	0.85	unrecognized	2026-08-27 20:11:31.34248	\N	Person #620	0	unrecognized	2026-08-27 20:11:44.103672
74367	1916	attendance	602	Person Entered	27-08-2026 12:55:28	263156	0.85	unrecognized	2026-08-27 20:09:34.466666	\N	Person #602	0	unrecognized	2026-08-27 20:09:40.451795
74368	1916	attendance	604	Person Entered	27-08-2026 12:55:57	263181	0.85	unrecognized	2026-08-27 20:09:39.835698	\N	Person #604	0	unrecognized	2026-08-27 20:10:06.237286
74376	1916	attendance	613	Person Entered	27-08-2026 12:57:43	266499	0.85	unrecognized	2026-08-27 20:10:33.152061	\N	Person #613	0	unrecognized	2026-08-27 20:10:45.180527
74377	1916	attendance	614	Person Entered	27-08-2026 12:57:42	266544	0.85	pending	2026-08-27 20:10:42.998341	\N	Person #614	0	unrecognized	\N
74389	1916	attendance	625	Person Entered	27-08-2026 13:11:00	286075	0.85	unrecognized	2026-08-27 20:13:13.31105	\N	Person #625	0	unrecognized	2026-08-27 20:13:25.166613
74380	1916	attendance	616	Person Entered	27-08-2026 12:58:27	267637	0.85	unrecognized	2026-08-27 20:11:16.288076	\N	Person #616	0	unrecognized	2026-08-27 20:11:23.256198
74381	1916	attendance	618	Person Entered	27-08-2026 12:58:28	267676	0.85	pending	2026-08-27 20:11:23.636939	\N	Person #618	\N	pending	\N
74388	1916	attendance	625	Person Entered	27-08-2026 13:09:09	283637	0.85	unrecognized	2026-08-27 20:12:57.174798	\N	Person #625	0	unrecognized	2026-08-27 20:13:11.318793
74382	1916	attendance	619	Person Entered	27-08-2026 12:59:08	268686	0.85	pending	2026-08-27 20:11:28.059843	\N	Person #619	0	unrecognized	\N
74387	1916	attendance	624	Person Entered	27-08-2026 13:05:43	278402	0.85	unrecognized	2026-08-27 20:12:23.322816	\N	Person #624	0	unrecognized	2026-08-27 20:12:50.744711
74391	1916	attendance	627	Person Entered	27-08-2026 13:12:00	287746	0.85	unrecognized	2026-08-27 20:13:38.301902	\N	Person #627	0	unrecognized	2026-08-27 20:13:47.976313
74392	1916	attendance	628	Person Entered	27-08-2026 13:11:51	287765	0.85	pending	2026-08-27 20:13:40.692726	\N	Person #628	0	unrecognized	\N
74396	1916	attendance	633	Person Entered	27-08-2026 13:16:15	294356	0.85	pending	2026-08-27 20:14:13.249849	\N	Person #633	0	unrecognized	\N
74393	1916	attendance	628	Person Entered	27-08-2026 13:13:00	289934	0.85	unrecognized	2026-08-27 20:13:50.417984	\N	Person #628	0	unrecognized	2026-08-27 20:13:58.984388
74394	1916	attendance	631	Person Entered	27-08-2026 13:13:20	289985	0.85	pending	2026-08-27 20:13:59.438372	\N	Person #631	\N	pending	\N
74397	1916	attendance	634	Person Entered	27-08-2026 13:16:19	294376	0.85	unrecognized	2026-08-27 20:14:14.206118	\N	Person #634	0	unrecognized	2026-08-27 20:14:25.49708
74398	1916	attendance	635	Person Entered	27-08-2026 13:16:00	294752	0.85	unrecognized	2026-08-27 20:14:27.321586	\N	Person #635	0	unrecognized	2026-08-27 20:14:47.637368
74401	1916	attendance	641	Person Entered	27-08-2026 13:23:07	304618	0.85	unrecognized	2026-08-27 20:15:16.38416	\N	Person #641	0	unrecognized	2026-08-27 20:15:25.51613
74399	1916	attendance	636	Person Entered	27-08-2026 13:20:03	300006	0.85	unrecognized	2026-08-27 20:14:52.744024	\N	Person #636	0	unrecognized	2026-08-27 20:15:03.01429
74400	1916	attendance	638	Person Entered	27-08-2026 13:20:20	300434	0.85	unrecognized	2026-08-27 20:15:04.100864	\N	Person #638	0	unrecognized	2026-08-27 20:15:12.029348
74433	1916	attendance	685	Person Entered	27-08-2026 14:05:43	368389	0.85	unrecognized	2026-08-27 20:21:52.01969	\N	Person #685	0	unrecognized	2026-08-27 20:22:17.815288
74439	1916	attendance	693	Person Entered	27-08-2026 14:08:12	372193	0.85	unrecognized	2026-08-27 20:23:58.461116	\N	Person #693	0	unrecognized	2026-08-27 20:24:16.633496
74431	1916	attendance	681	Person Entered	27-08-2026 14:02:40	363918	0.85	unrecognized	2026-08-27 20:21:25.477745	\N	Person #681	0	unrecognized	2026-08-27 20:21:36.213993
74428	1916	attendance	678	Person Entered	27-08-2026 13:57:26	356094	0.85	unrecognized	2026-08-27 20:20:48.329445	\N	Person #678	0	unrecognized	2026-08-27 20:20:58.485496
74425	1916	attendance	675	Person Entered	27-08-2026 13:44:00	336394	0.85	unrecognized	2026-08-27 20:20:01.071781	\N	Person #675	0	unrecognized	2026-08-27 20:20:12.550633
74415	1916	attendance	662	Person Entered	27-08-2026 13:33:53	320679	0.85	unrecognized	2026-08-27 20:17:52.475925	\N	Person #662	0	unrecognized	2026-08-27 20:18:14.048765
74416	1916	attendance	663	Person Entered	27-08-2026 13:34:35	321852	0.85	pending	2026-08-27 20:18:17.071588	\N	Person #663	0	unrecognized	\N
74403	1916	attendance	643	Person Entered	27-08-2026 13:26:30	309693	0.85	unrecognized	2026-08-27 20:15:44.01304	\N	Person #643	0	unrecognized	2026-08-27 20:15:52.438197
74422	1916	attendance	672	Person Entered	27-08-2026 13:43:46	334995	0.85	unrecognized	2026-08-27 20:19:23.013225	\N	Person #672	0	unrecognized	2026-08-27 20:19:34.976802
74406	1916	attendance	646	Person Entered	27-08-2026 13:27:04	310526	0.85	unrecognized	2026-08-27 20:16:08.912171	\N	Person #646	0	unrecognized	2026-08-27 20:16:22.746298
74402	1916	attendance	642	Person Entered	27-08-2026 13:23:31	305203	0.85	unrecognized	2026-08-27 20:15:26.303725	\N	Person #642	0	unrecognized	2026-08-27 20:15:39.700412
74427	1916	attendance	677	Person Entered	27-08-2026 13:49:56	344843	0.85	unrecognized	2026-08-27 20:20:29.808861	\N	Person #677	0	unrecognized	2026-08-27 20:20:38.705872
74411	1916	attendance	657	Person Entered	27-08-2026 13:30:42	315962	0.85	unrecognized	2026-08-27 20:17:16.033257	\N	Person #657	0	unrecognized	2026-08-27 20:17:34.958012
74424	1916	attendance	674	Person Entered	27-08-2026 13:44:10	335598	0.85	unrecognized	2026-08-27 20:19:47.899976	\N	Person #674	0	unrecognized	2026-08-27 20:19:59.983137
74417	1916	attendance	664	Person Entered	27-08-2026 13:36:02	323919	0.85	unrecognized	2026-08-27 20:18:22.454944	\N	Person #664	0	unrecognized	2026-08-27 20:18:41.899726
74418	1916	attendance	666	Person Entered	27-08-2026 13:37:23	326055	0.85	pending	2026-08-27 20:18:45.114599	\N	Person #666	0	unrecognized	\N
74404	1916	attendance	644	Person Entered	27-08-2026 13:26:42	309971	0.85	unrecognized	2026-08-27 20:15:53.437582	\N	Person #644	0	unrecognized	2026-08-27 20:16:05.168475
74410	1916	attendance	653	Person Entered	27-08-2026 13:30:06	315062	0.85	unrecognized	2026-08-27 20:16:59.661788	\N	Person #653	0	unrecognized	2026-08-27 20:17:12.980591
74408	1916	attendance	649	Person Entered	27-08-2026 13:30:14	314702	0.85	unrecognized	2026-08-27 20:16:39.836703	\N	Person #649	0	unrecognized	2026-08-27 20:16:55.204347
74412	1916	attendance	658	Person Entered	27-08-2026 13:30:44	316012	0.85	unrecognized	2026-08-27 20:17:26.692173	\N	Person #658	0	unrecognized	2026-08-27 20:17:43.775584
74058	1916	checkin	183	check_in	27-08-2026 10:52:00	77761	0.85	normal	2026-08-27 18:58:41.986688	STF-014	Muhammad Asif	0.5175	recognized	2026-08-27 18:58:42.629307
74407	1916	attendance	647	Person Entered	27-08-2026 13:27:00	310711	0.85	unrecognized	2026-08-27 20:16:23.366515	\N	Person #647	0	unrecognized	2026-08-27 20:16:35.252993
74429	1916	attendance	679	Person Entered	27-08-2026 14:01:36	362397	0.85	pending	2026-08-27 20:21:04.874048	\N	Person #679	0	unrecognized	\N
74419	1916	attendance	667	Person Entered	27-08-2026 13:42:00	332780	0.85	unrecognized	2026-08-27 20:18:52.964514	\N	Person #667	0	unrecognized	2026-08-27 20:19:09.319171
74409	1916	attendance	652	Person Entered	27-08-2026 13:30:03	315046	0.85	unrecognized	2026-08-27 20:16:57.843142	\N	Person #652	0	unrecognized	2026-08-27 20:16:59.198931
74414	1916	attendance	662	Person Entered	27-08-2026 13:33:46	320628	0.85	pending	2026-08-27 20:17:51.335907	\N	Person #662	\N	pending	\N
74423	1916	attendance	673	Person Entered	27-08-2026 13:43:00	335274	0.85	unrecognized	2026-08-27 20:19:35.895389	\N	Person #673	0	unrecognized	2026-08-27 20:19:46.587418
74421	1916	attendance	671	Person Entered	27-08-2026 13:42:00	333029	0.85	unrecognized	2026-08-27 20:19:10.255577	\N	Person #671	0	unrecognized	2026-08-27 20:19:20.876227
74420	1916	attendance	668	Person Entered	27-08-2026 13:41:53	332801	0.85	pending	2026-08-27 20:18:57.193541	\N	Person #668	0	unrecognized	\N
74430	1916	attendance	680	Person Entered	27-08-2026 14:01:53	362730	0.85	unrecognized	2026-08-27 20:21:08.906297	\N	Person #680	0	unrecognized	2026-08-27 20:21:23.552687
74434	1916	attendance	687	Person Entered	27-08-2026 14:06:10	369146	0.85	unrecognized	2026-08-27 20:22:19.851168	\N	Person #687	0	unrecognized	2026-08-27 20:22:49.830706
74426	1916	attendance	676	Person Entered	27-08-2026 13:44:47	336535	0.85	unrecognized	2026-08-27 20:20:13.377964	\N	Person #676	0	unrecognized	2026-08-27 20:20:22.801807
74437	1916	attendance	690	Person Entered	27-08-2026 14:08:08	372082	0.85	unrecognized	2026-08-27 20:23:32.701027	\N	Person #690	0	unrecognized	2026-08-27 20:23:54.865175
74435	1916	attendance	688	Person Entered	27-08-2026 14:06:12	369182	0.85	unrecognized	2026-08-27 20:22:28.065424	\N	Person #688	0	unrecognized	2026-08-27 20:22:55.765409
74432	1916	attendance	681	Person Entered	27-08-2026 14:03:53	365736	0.85	unrecognized	2026-08-27 20:21:37.792525	\N	Person #681	0	unrecognized	2026-08-27 20:21:49.042892
74436	1916	attendance	689	Person Entered	27-08-2026 14:07:34	371146	0.85	unrecognized	2026-08-27 20:22:57.565123	\N	Person #689	0	unrecognized	2026-08-27 20:23:31.329644
74438	1916	attendance	692	Person Entered	27-08-2026 14:08:09	372154	0.85	unrecognized	2026-08-27 20:23:46.821791	\N	Person #692	0	unrecognized	2026-08-27 20:24:05.384871
74441	1916	attendance	697	Person Entered	27-08-2026 14:09:07	373611	0.85	unrecognized	2026-08-27 20:24:28.825962	\N	Person #697	0	unrecognized	2026-08-27 20:24:38.547315
74442	1916	attendance	699	Person Entered	27-08-2026 14:12:17	378352	0.85	unrecognized	2026-08-27 20:24:44.145589	\N	Person #699	0	unrecognized	2026-08-27 20:24:54.879125
74443	1916	attendance	701	Person Entered	27-08-2026 14:16:00	384069	0.85	unrecognized	2026-08-27 20:24:59.437938	\N	Person #701	0	unrecognized	2026-08-27 20:25:14.347669
74446	1916	attendance	704	Person Entered	27-08-2026 14:20:06	390068	0.85	unrecognized	2026-08-27 20:25:45.227245	\N	Person #704	0	unrecognized	2026-08-27 20:25:56.573081
74444	1916	attendance	702	Person Entered	27-08-2026 14:16:00	384196	0.85	unrecognized	2026-08-27 20:25:15.110441	\N	Person #702	0	unrecognized	2026-08-27 20:25:25.850249
74445	1916	attendance	703	Person Entered	27-08-2026 14:17:00	386177	0.85	unrecognized	2026-08-27 20:25:28.301774	\N	Person #703	0	unrecognized	2026-08-27 20:25:41.406938
77741	1918	breakout	1	Break Out	27-08-2026 17:58:52	192	0.85	unrecognized	2026-08-28 09:46:56.704873	\N	Person #1	0	unrecognized	2026-08-28 09:47:35.463954
74101	1916	checkin	239	check_in	27-08-2026 11:00:50	91240	0.85	normal	2026-08-27 19:09:14.720189	STF-001	Ikram Hassan	0.4526	recognized	2026-08-27 19:09:16.61485
75145	1916	attendance	183	Person Entered	27-08-2026 19:12:51	829266	0.85	unrecognized	2026-08-28 06:31:41.795902	\N	Person #183	0	unrecognized	2026-08-28 06:31:47.602807
74099	1916	checkin	238	check_in	27-08-2026 11:00:01	90005	0.85	normal	2026-08-27 19:08:52.60962	STF-076	Abdul Hanan Khalid	0.44	recognized	2026-08-27 19:08:53.741333
74447	1916	attendance	705	Person Entered	27-08-2026 14:20:00	390689	0.85	unrecognized	2026-08-27 20:25:57.467839	\N	Person #705	0	unrecognized	2026-08-27 20:26:08.303884
74819	1917	breakin	6	Break In	27-08-2026 17:57:57	1532	0.85	unrecognized	2026-08-28 06:08:08.836982	\N	Person #6	0	unrecognized	2026-08-28 06:11:37.139316
75305	1917	breakin	105	Break In	27-08-2026 14:12:16	20605	0.85	normal	2026-08-28 06:43:20.066976	STF-007	Faisal Saleem	0.5196	recognized	2026-08-28 06:43:22.047046
74888	1917	breakin	36	Break In	27-08-2026 10:53:28	79586	0.85	normal	2026-08-28 06:12:20.274441	STF-045	Zohaib Ali Chaudhary	0.6768	recognized	2026-08-28 06:12:20.307998
75106	1917	breakin	62	Break In	27-08-2026 18:11:26	21971	0.85	unrecognized	2026-08-28 06:27:13.901407	\N	Person #62	0	unrecognized	2026-08-28 06:28:42.476635
78471	1918	breakout	240	Break Out	27-08-2026 19:55:45	175650	0.85	pending	2026-08-28 10:29:43.16906	\N	Person #240	0	unrecognized	\N
75138	1916	attendance	171	Person Entered	27-08-2026 19:06:18	819447	0.85	pending	2026-08-28 06:31:12.842982	\N	Person #171	\N	pending	\N
75306	1917	breakin	112	Break In	27-08-2026 14:12:23	20605	0.85	normal	2026-08-28 06:43:20.467473	STF-025	Farhan Virk	0.4626	recognized	2026-08-28 06:43:31.032352
77739	1918	breakout	1	Break Out	27-08-2026 17:58:43	1	0.85	unrecognized	2026-08-28 09:46:52.474958	\N	Person #1	0	unrecognized	2026-08-28 09:46:56.406
74896	1917	breakin	45	Break In	27-08-2026 10:54:10	80638	0.85	normal	2026-08-28 06:12:49.284334	STF-048	Abdullah Sultan	0.697	recognized	2026-08-28 06:12:49.325928
75955	1917	breakin	292	Break In	27-08-2026 19:12:56	114394	0.85	normal	2026-08-28 07:27:36.440826	STF-049	Nabi Ul Haq	0.5389	recognized	2026-08-28 07:27:45.589926
74834	1917	breakin	7	Break In	27-08-2026 17:57:00	1658	0.85	unrecognized	2026-08-28 06:08:47.935063	\N	Person #7	0	unrecognized	2026-08-28 06:09:08.296883
77754	1918	breakout	4	Break Out	27-08-2026 17:59:51	1617	0.85	unrecognized	2026-08-28 09:47:51.630349	\N	Person #4	0	unrecognized	2026-08-28 09:48:21.768125
74989	1917	breakin	27	Break In	27-08-2026 17:59:20	3916	0.85	unrecognized	2026-08-28 06:20:26.938167	\N	Person #27	0	unrecognized	2026-08-28 06:20:53.574913
74063	1916	checkin	190	check_in	27-08-2026 10:53:00	79852	0.85	normal	2026-08-27 18:59:56.910746	STF-016	Muhammad Asad Awan	0.4562	recognized	2026-08-27 19:00:02.750008
74106	1916	checkin	246	check_in	27-08-2026 11:01:04	91576	0.85	normal	2026-08-27 19:10:29.084954	STF-010	Faraz Younas	0.4493	recognized	2026-08-27 19:10:31.538378
74890	1917	breakin	39	Break In	27-08-2026 10:53:00	79917	0.85	normal	2026-08-28 06:12:33.190577	STF-033	Raza Abbas	0.7526	recognized	2026-08-28 06:12:33.583714
77749	1918	breakout	3	Break Out	27-08-2026 17:59:16	807	0.85	unrecognized	2026-08-28 09:47:38.367133	\N	Person #3	0	unrecognized	2026-08-28 09:47:47.88364
74097	1916	checkin	236	check_in	27-08-2026 11:00:02	89984	0.85	normal	2026-08-27 19:08:47.270754	STF-075	Muhammad Bilal Gujjar	0.4844	recognized	2026-08-27 19:09:03.374644
74165	1916	checkin	326	check_in	27-08-2026 11:09:34	103726	0.85	normal	2026-08-27 19:25:50.76642	STF-017	Mohammad Zahid	0.4831	recognized	2026-08-27 19:25:52.144615
74891	1917	breakin	40	Break In	27-08-2026 10:53:43	79959	0.85	normal	2026-08-28 06:12:34.882409	STF-033	Raza Abbas	0.726	recognized	2026-08-28 06:12:34.937779
75053	1916	attendance	126	Person Entered	27-08-2026 18:26:39	759921	0.85	unrecognized	2026-08-28 06:24:03.138271	\N	Person #126	0	unrecognized	2026-08-28 06:24:24.643163
75308	1917	breakin	112	Break In	27-08-2026 14:13:00	21606	0.85	normal	2026-08-28 06:43:37.457567	STF-025	Farhan Virk	0.4414	recognized	2026-08-28 06:43:39.455644
74146	1916	checkin	298	check_in	27-08-2026 11:08:06	102097	0.85	normal	2026-08-27 19:20:04.778807	STF-018	Muhammad Qaiser Shahzad	0.4449	recognized	2026-08-27 19:20:12.706649
74175	1916	checkin	341	check_in	27-08-2026 11:11:08	106674	0.85	normal	2026-08-27 19:28:21.81422	STF-067	Abdullah Abdullah	0.4498	recognized	2026-08-27 19:28:26.374992
74177	1916	checkin	345	check_in	27-08-2026 11:11:37	107413	0.85	normal	2026-08-27 19:29:01.074705	STF-073	Waqar Ashraf	0.4462	recognized	2026-08-27 19:29:02.212158
74946	1916	attendance	87	Person Entered	27-08-2026 18:03:45	725559	0.85	unrecognized	2026-08-28 06:16:14.572442	\N	Person #87	0	unrecognized	2026-08-28 06:16:29.763967
74861	1917	breakin	10	Break In	27-08-2026 17:58:06	1894	0.85	unrecognized	2026-08-28 06:10:30.576631	\N	Person #10	0	unrecognized	2026-08-28 06:13:11.815668
74899	1917	breakin	47	Break In	27-08-2026 10:54:20	80892	0.85	normal	2026-08-28 06:12:56.210088	STF-045	Zohaib Ali Chaudhary	0.56	recognized	2026-08-28 06:12:56.229037
74926	1917	breakin	61	Break In	27-08-2026 10:55:36	82803	0.85	normal	2026-08-28 06:14:20.758778	STF-023	Syed Zubair Zulfiqar	0.5907	recognized	2026-08-28 06:14:21.629008
78122	1918	breakout	135	Break Out	27-08-2026 19:00:18	92351	0.85	normal	2026-08-28 10:09:14.716003	STF-009	Tariq Ghulam Hussain	0.4904	recognized	2026-08-28 10:09:20.801241
74975	1917	breakin	24	Break In	27-08-2026 17:58:46	2902	0.85	unrecognized	2026-08-28 06:18:54.767358	\N	Person #24	0	unrecognized	2026-08-28 06:20:01.080657
74945	1916	attendance	84	Person Entered	27-08-2026 18:03:30	725227	0.85	pending	2026-08-28 06:16:11.32709	\N	Person #84	\N	pending	\N
75166	1916	attendance	201	Person Entered	27-08-2026 19:19:02	838532	0.85	pending	2026-08-28 06:34:16.797915	\N	Person #201	0	unrecognized	\N
78469	1918	breakout	239	Break Out	27-08-2026 19:54:50	174159	0.85	normal	2026-08-28 10:29:36.9444	STF-017	Mohammad Zahid	0.5412	recognized	2026-08-28 10:29:39.600337
74971	1917	breakin	23	Break In	27-08-2026 17:58:37	2864	0.85	unrecognized	2026-08-28 06:18:28.185575	\N	Person #23	0	unrecognized	2026-08-28 06:19:17.277808
74994	1917	breakin	29	Break In	27-08-2026 17:59:41	4453	0.85	unrecognized	2026-08-28 06:20:54.96745	\N	Person #29	0	unrecognized	2026-08-28 06:21:10.202014
75156	1917	breakin	140	Break In	27-08-2026 11:09:00	103972	0.85	normal	2026-08-28 06:33:06.334736	STF-002	Abdur Rehman	0.4561	recognized	2026-08-28 06:33:28.236694
75110	1917	breakin	64	Break In	27-08-2026 18:11:32	22097	0.85	unrecognized	2026-08-28 06:27:51.560065	\N	Person #64	0	unrecognized	2026-08-28 06:30:02.682587
78473	1918	breakout	241	Break Out	27-08-2026 19:56:25	176563	0.85	normal	2026-08-28 10:29:46.429124	STF-024	Arsalan Khan	0.4502	recognized	2026-08-28 10:29:52.728952
75139	1916	attendance	174	Person Entered	27-08-2026 19:06:19	819461	0.85	unrecognized	2026-08-28 06:31:13.858531	\N	Person #174	0	unrecognized	2026-08-28 06:31:17.110572
75152	1917	breakin	135	Break In	27-08-2026 11:09:18	103353	0.85	normal	2026-08-28 06:32:24.257627	STF-037	Muhammad Fahad	0.6969	recognized	2026-08-28 06:32:24.297213
75153	1917	breakin	139	Break In	27-08-2026 11:09:50	103419	0.85	unrecognized	2026-08-28 06:32:26.75809	\N	Person #139	0	unrecognized	2026-08-28 06:33:53.208382
74453	1916	attendance	712	Person Entered	27-08-2026 14:21:00	392022	0.85	unrecognized	2026-08-27 20:26:30.611642	\N	Person #712	0	unrecognized	2026-08-27 20:27:11.154379
74458	1916	attendance	715	Person Entered	27-08-2026 14:25:32	398281	0.85	pending	2026-08-27 20:27:48.169872	\N	Person #715	0	unrecognized	\N
74452	1916	attendance	711	Person Entered	27-08-2026 14:21:44	392005	0.85	unrecognized	2026-08-27 20:26:29.251073	\N	Person #711	0	unrecognized	2026-08-27 20:26:29.937075
74449	1916	attendance	708	Person Entered	27-08-2026 14:21:18	391946	0.85	pending	2026-08-27 20:26:19.330682	\N	Person #708	0	unrecognized	\N
74487	1916	attendance	760	Person Entered	27-08-2026 14:45:00	427663	0.85	unrecognized	2026-08-27 20:34:51.287697	\N	Person #760	0	unrecognized	2026-08-27 20:34:59.978111
74470	1916	attendance	732	Person Entered	27-08-2026 14:32:34	408691	0.85	unrecognized	2026-08-27 20:29:47.872137	\N	Person #732	0	unrecognized	2026-08-27 20:30:14.527339
74465	1916	attendance	725	Person Entered	27-08-2026 14:31:21	406331	0.85	unrecognized	2026-08-27 20:28:57.071709	\N	Person #725	0	unrecognized	2026-08-27 20:29:17.061459
74454	1916	attendance	712	Person Entered	27-08-2026 14:21:39	392433	0.85	unrecognized	2026-08-27 20:27:11.632774	\N	Person #712	0	unrecognized	2026-08-27 20:27:13.288568
74478	1916	attendance	747	Person Entered	27-08-2026 14:36:55	415320	0.85	unrecognized	2026-08-27 20:33:02.193652	\N	Person #747	0	unrecognized	2026-08-27 20:33:08.049931
74479	1916	attendance	748	Person Entered	27-08-2026 14:40:15	420357	0.85	pending	2026-08-27 20:33:12.732816	\N	Person #748	\N	pending	\N
74473	1916	attendance	736	Person Entered	27-08-2026 14:34:21	411453	0.85	unrecognized	2026-08-27 20:32:01.191741	\N	Person #736	0	unrecognized	2026-08-27 20:32:19.621848
74464	1916	attendance	722	Person Entered	27-08-2026 14:30:22	405464	0.85	unrecognized	2026-08-27 20:28:42.624694	\N	Person #722	0	unrecognized	2026-08-27 20:28:55.801631
74462	1916	attendance	720	Person Entered	27-08-2026 14:27:38	400800	0.85	unrecognized	2026-08-27 20:28:10.682451	\N	Person #720	0	unrecognized	2026-08-27 20:28:28.784117
74461	1916	attendance	719	Person Entered	27-08-2026 14:27:14	400782	0.85	unrecognized	2026-08-27 20:28:08.585174	\N	Person #719	0	unrecognized	2026-08-27 20:28:23.422369
74466	1916	attendance	728	Person Entered	27-08-2026 14:31:17	406849	0.85	unrecognized	2026-08-27 20:29:19.033631	\N	Person #728	0	unrecognized	2026-08-27 20:29:29.775139
74455	1916	attendance	712	Person Entered	27-08-2026 14:22:00	392533	0.85	unrecognized	2026-08-27 20:27:13.769695	\N	Person #712	0	unrecognized	2026-08-27 20:27:23.874938
74467	1916	attendance	729	Person Entered	27-08-2026 14:31:41	407503	0.85	pending	2026-08-27 20:29:30.858967	\N	Person #729	0	unrecognized	\N
74468	1916	attendance	730	Person Entered	27-08-2026 14:33:21	407635	0.85	unrecognized	2026-08-27 20:29:33.777306	\N	Person #730	0	unrecognized	2026-08-27 20:29:46.450301
74448	1916	attendance	707	Person Entered	27-08-2026 14:21:05	391564	0.85	unrecognized	2026-08-27 20:26:09.844876	\N	Person #707	0	unrecognized	2026-08-27 20:26:17.600353
74475	1916	attendance	740	Person Entered	27-08-2026 14:34:48	412189	0.85	unrecognized	2026-08-27 20:32:23.169075	\N	Person #740	0	unrecognized	2026-08-27 20:32:24.368806
74450	1916	attendance	709	Person Entered	27-08-2026 14:21:43	391950	0.85	unrecognized	2026-08-27 20:26:19.509243	\N	Person #709	0	unrecognized	2026-08-27 20:26:28.492569
74451	1916	attendance	710	Person Entered	27-08-2026 14:21:19	391975	0.85	pending	2026-08-27 20:26:25.453478	\N	Person #710	0	unrecognized	\N
74459	1916	attendance	716	Person Entered	27-08-2026 14:25:59	398331	0.85	unrecognized	2026-08-27 20:27:50.200394	\N	Person #716	0	unrecognized	2026-08-27 20:28:03.030046
74456	1916	attendance	713	Person Entered	27-08-2026 14:22:00	393013	0.85	unrecognized	2026-08-27 20:27:25.012477	\N	Person #713	0	unrecognized	2026-08-27 20:27:34.369284
74457	1916	attendance	714	Person Entered	27-08-2026 14:24:00	395943	0.85	unrecognized	2026-08-27 20:27:37.52092	\N	Person #714	0	unrecognized	2026-08-27 20:27:45.009024
74463	1916	attendance	721	Person Entered	27-08-2026 14:28:59	403403	0.85	unrecognized	2026-08-27 20:28:31.52888	\N	Person #721	0	unrecognized	2026-08-27 20:28:40.243871
74460	1916	attendance	717	Person Entered	27-08-2026 14:27:10	400743	0.85	pending	2026-08-27 20:28:06.842207	\N	Person #717	0	unrecognized	\N
74484	1916	attendance	755	Person Entered	27-08-2026 14:42:00	423016	0.85	unrecognized	2026-08-27 20:33:46.69135	\N	Person #755	0	unrecognized	2026-08-27 20:34:05.864931
74472	1916	attendance	734	Person Entered	27-08-2026 14:34:20	411426	0.85	unrecognized	2026-08-27 20:31:54.93496	\N	Person #734	0	unrecognized	2026-08-27 20:32:10.692846
74469	1916	attendance	732	Person Entered	27-08-2026 14:31:47	407650	0.85	unrecognized	2026-08-27 20:29:35.766637	\N	Person #732	0	unrecognized	2026-08-27 20:29:44.013573
74476	1916	attendance	743	Person Entered	27-08-2026 14:34:58	412264	0.85	unrecognized	2026-08-27 20:32:25.712857	\N	Person #743	0	unrecognized	2026-08-27 20:32:54.459621
74471	1916	attendance	733	Person Entered	27-08-2026 14:33:53	409579	0.85	unrecognized	2026-08-27 20:30:16.881667	\N	Person #733	0	unrecognized	2026-08-27 20:31:53.867543
74474	1916	attendance	739	Person Entered	27-08-2026 14:34:48	412178	0.85	unrecognized	2026-08-27 20:32:21.239045	\N	Person #739	0	unrecognized	2026-08-27 20:32:22.88297
74482	1916	attendance	752	Person Entered	27-08-2026 14:40:24	420593	0.85	pending	2026-08-27 20:33:33.931586	\N	Person #752	0	unrecognized	\N
74477	1916	attendance	745	Person Entered	27-08-2026 14:36:22	414493	0.85	unrecognized	2026-08-27 20:32:56.92261	\N	Person #745	0	unrecognized	2026-08-27 20:32:58.139402
74485	1916	attendance	756	Person Entered	27-08-2026 14:43:00	425234	0.85	unrecognized	2026-08-27 20:34:08.63943	\N	Person #756	0	unrecognized	2026-08-27 20:34:30.941387
74480	1916	attendance	750	Person Entered	27-08-2026 14:40:48	420539	0.85	unrecognized	2026-08-27 20:33:14.168382	\N	Person #750	0	unrecognized	2026-08-27 20:33:38.623121
74481	1916	attendance	751	Person Entered	27-08-2026 14:40:25	420552	0.85	unrecognized	2026-08-27 20:33:17.478036	\N	Person #751	0	unrecognized	2026-08-27 20:33:42.570557
74486	1916	attendance	756	Person Entered	27-08-2026 14:44:00	426038	0.85	unrecognized	2026-08-27 20:34:32.136946	\N	Person #756	0	unrecognized	2026-08-27 20:34:47.956881
74483	1916	attendance	754	Person Entered	27-08-2026 14:40:34	420845	0.85	pending	2026-08-27 20:33:44.745974	\N	Person #754	\N	pending	\N
74489	1916	attendance	762	Person Entered	27-08-2026 14:45:09	427688	0.85	unrecognized	2026-08-27 20:35:00.146787	\N	Person #762	0	unrecognized	2026-08-27 20:35:05.619964
74488	1916	attendance	761	Person Entered	27-08-2026 14:45:00	427669	0.85	unrecognized	2026-08-27 20:34:53.029461	\N	Person #761	0	unrecognized	2026-08-27 20:34:58.827364
74046	1916	checkin	168	check_in	27-08-2026 10:50:10	74608	0.85	normal	2026-08-27 18:56:08.476376	STF-032	Muhammad Yaseen	0.4458	recognized	2026-08-27 18:56:11.605535
74490	1916	attendance	763	Person Entered	27-08-2026 14:46:42	429974	0.85	unrecognized	2026-08-27 20:35:08.16596	\N	Person #763	0	unrecognized	2026-08-27 20:35:18.687577
74491	1916	attendance	763	Person Entered	27-08-2026 14:49:44	434539	0.85	unrecognized	2026-08-27 20:35:22.20455	\N	Person #763	0	unrecognized	2026-08-27 20:35:32.817185
74494	1916	attendance	767	Person Entered	27-08-2026 14:53:07	439620	0.85	unrecognized	2026-08-27 20:35:55.895354	\N	Person #767	0	unrecognized	2026-08-27 20:36:05.54256
74495	1916	attendance	768	Person Entered	27-08-2026 14:53:48	440687	0.85	pending	2026-08-27 20:36:07.720933	\N	Person #768	0	unrecognized	\N
74498	1916	attendance	772	Person Entered	27-08-2026 14:57:36	446343	0.85	unrecognized	2026-08-27 20:36:29.256436	\N	Person #772	0	unrecognized	2026-08-27 20:36:40.069483
74518	1916	attendance	798	Person Entered	27-08-2026 15:24:06	485961	0.85	unrecognized	2026-08-27 20:40:03.842458	\N	Person #798	0	unrecognized	2026-08-27 20:40:33.447887
74515	1916	attendance	795	Person Entered	27-08-2026 15:18:00	476490	0.85	unrecognized	2026-08-27 20:39:26.642707	\N	Person #795	0	unrecognized	2026-08-27 20:39:35.564932
74502	1916	attendance	779	Person Entered	27-08-2026 15:01:32	452233	0.85	unrecognized	2026-08-27 20:37:25.804677	\N	Person #779	0	unrecognized	2026-08-27 20:37:36.600083
74519	1916	attendance	799	Person Entered	27-08-2026 15:25:50	488693	0.85	unrecognized	2026-08-27 20:40:36.001723	\N	Person #799	0	unrecognized	2026-08-27 20:40:44.848192
74508	1916	attendance	787	Person Entered	27-08-2026 15:11:42	466914	0.85	unrecognized	2026-08-27 20:38:28.332453	\N	Person #787	0	unrecognized	2026-08-27 20:38:37.779305
74517	1916	attendance	797	Person Entered	27-08-2026 15:21:04	481552	0.85	unrecognized	2026-08-27 20:39:51.125871	\N	Person #797	0	unrecognized	2026-08-27 20:39:59.752837
74527	1916	attendance	808	Person Entered	27-08-2026 15:29:55	494811	0.85	unrecognized	2026-08-27 20:41:57.824571	\N	Person #808	0	unrecognized	2026-08-27 20:42:06.157239
74505	1916	attendance	783	Person Entered	27-08-2026 15:04:22	456473	0.85	unrecognized	2026-08-27 20:37:55.990295	\N	Person #783	0	unrecognized	2026-08-27 20:38:01.018946
74507	1916	attendance	787	Person Entered	27-08-2026 15:11:00	466419	0.85	unrecognized	2026-08-27 20:38:16.548537	\N	Person #787	0	unrecognized	2026-08-27 20:38:27.675139
74506	1916	attendance	784	Person Entered	27-08-2026 15:06:00	459365	0.85	unrecognized	2026-08-27 20:38:08.06921	\N	Person #784	0	unrecognized	2026-08-27 20:38:10.155865
74497	1916	attendance	771	Person Entered	27-08-2026 14:56:48	445153	0.85	unrecognized	2026-08-27 20:36:22.058343	\N	Person #771	0	unrecognized	2026-08-27 20:36:27.565569
74501	1916	attendance	778	Person Entered	27-08-2026 14:59:31	449223	0.85	unrecognized	2026-08-27 20:37:16.871602	\N	Person #778	0	unrecognized	2026-08-27 20:37:22.568336
74503	1916	attendance	780	Person Entered	27-08-2026 15:01:41	452473	0.85	unrecognized	2026-08-27 20:37:37.481702	\N	Person #780	0	unrecognized	2026-08-27 20:37:46.976496
74492	1916	attendance	764	Person Entered	27-08-2026 14:50:51	436227	0.85	unrecognized	2026-08-27 20:35:35.236003	\N	Person #764	0	unrecognized	2026-08-27 20:35:42.600768
74504	1916	attendance	782	Person Entered	27-08-2026 15:04:11	456260	0.85	pending	2026-08-27 20:37:50.303882	\N	Person #782	0	unrecognized	\N
74493	1916	attendance	766	Person Entered	27-08-2026 14:51:42	437482	0.85	unrecognized	2026-08-27 20:35:43.919518	\N	Person #766	0	unrecognized	2026-08-27 20:35:53.687756
74499	1916	attendance	775	Person Entered	27-08-2026 14:58:02	446842	0.85	unrecognized	2026-08-27 20:36:42.303889	\N	Person #775	0	unrecognized	2026-08-27 20:37:11.631876
74500	1916	attendance	775	Person Entered	27-08-2026 14:58:04	447078	0.85	pending	2026-08-27 20:37:12.777396	\N	Person #775	\N	pending	\N
74525	1916	attendance	806	Person Entered	27-08-2026 15:29:44	494515	0.85	unrecognized	2026-08-27 20:41:45.287635	\N	Person #806	0	unrecognized	2026-08-27 20:41:56.448516
74526	1916	attendance	806	Person Entered	27-08-2026 15:29:45	494625	0.85	pending	2026-08-27 20:41:56.886083	\N	Person #806	\N	pending	\N
74496	1916	attendance	769	Person Entered	27-08-2026 14:54:15	440729	0.85	unrecognized	2026-08-27 20:36:09.524697	\N	Person #769	0	unrecognized	2026-08-27 20:36:18.145219
74520	1916	attendance	800	Person Entered	27-08-2026 15:26:03	489013	0.85	unrecognized	2026-08-27 20:40:45.973411	\N	Person #800	0	unrecognized	2026-08-27 20:40:57.901402
74509	1916	attendance	789	Person Entered	27-08-2026 15:12:31	468596	0.85	unrecognized	2026-08-27 20:38:39.907549	\N	Person #789	0	unrecognized	2026-08-27 20:38:57.603773
74510	1916	attendance	791	Person Entered	27-08-2026 15:14:46	472150	0.85	pending	2026-08-27 20:39:01.421836	\N	Person #791	0	unrecognized	\N
74511	1916	attendance	791	Person Entered	27-08-2026 15:15:00	472986	0.85	unrecognized	2026-08-27 20:39:04.8402	\N	Person #791	0	unrecognized	2026-08-27 20:39:05.60056
74512	1916	attendance	792	Person Entered	27-08-2026 15:15:22	473031	0.85	pending	2026-08-27 20:39:06.94256	\N	Person #792	\N	pending	\N
74514	1916	attendance	793	Person Entered	27-08-2026 15:17:00	475042	0.85	unrecognized	2026-08-27 20:39:12.176198	\N	Person #793	0	unrecognized	2026-08-27 20:39:24.774993
74513	1916	attendance	793	Person Entered	27-08-2026 15:15:24	473098	0.85	pending	2026-08-27 20:39:08.17504	\N	Person #793	0	unrecognized	\N
74516	1916	attendance	797	Person Entered	27-08-2026 15:19:00	477997	0.85	unrecognized	2026-08-27 20:39:38.1355	\N	Person #797	0	unrecognized	2026-08-27 20:39:48.264666
74521	1916	attendance	801	Person Entered	27-08-2026 15:26:06	489138	0.85	pending	2026-08-27 20:40:58.729387	\N	Person #801	0	unrecognized	\N
74530	1916	attendance	814	Person Entered	27-08-2026 15:40:07	510163	0.85	pending	2026-08-27 20:42:55.659761	\N	Person #814	0	unrecognized	\N
74522	1916	attendance	803	Person Entered	27-08-2026 15:26:23	489278	0.85	unrecognized	2026-08-27 20:41:01.60312	\N	Person #803	0	unrecognized	2026-08-27 20:41:18.162356
74523	1916	attendance	804	Person Entered	27-08-2026 15:27:38	491384	0.85	unrecognized	2026-08-27 20:41:20.559437	\N	Person #804	0	unrecognized	2026-08-27 20:41:27.261332
74524	1916	attendance	805	Person Entered	27-08-2026 15:29:37	494338	0.85	unrecognized	2026-08-27 20:41:30.793649	\N	Person #805	0	unrecognized	2026-08-27 20:41:44.528326
74531	1916	attendance	815	Person Entered	27-08-2026 15:40:08	510194	0.85	pending	2026-08-27 20:42:57.124853	\N	Person #815	0	unrecognized	\N
74529	1916	attendance	811	Person Entered	27-08-2026 15:36:57	505295	0.85	unrecognized	2026-08-27 20:42:26.288837	\N	Person #811	0	unrecognized	2026-08-27 20:42:49.876519
74528	1916	attendance	810	Person Entered	27-08-2026 15:34:45	502063	0.85	unrecognized	2026-08-27 20:42:12.051858	\N	Person #810	0	unrecognized	2026-08-27 20:42:22.980739
74533	1916	attendance	817	Person Entered	27-08-2026 15:44:16	515753	0.85	unrecognized	2026-08-27 20:43:23.007594	\N	Person #817	0	unrecognized	2026-08-27 20:43:38.364182
74532	1916	attendance	816	Person Entered	27-08-2026 15:41:13	511174	0.85	unrecognized	2026-08-27 20:43:02.149395	\N	Person #816	0	unrecognized	2026-08-27 20:43:18.238548
74535	1916	attendance	819	Person Entered	27-08-2026 15:45:06	517646	0.85	pending	2026-08-27 20:43:58.422442	\N	Person #819	0	unrecognized	\N
74534	1916	attendance	818	Person Entered	27-08-2026 15:44:56	517315	0.85	unrecognized	2026-08-27 20:43:40.374558	\N	Person #818	0	unrecognized	2026-08-27 20:43:56.925349
74057	1916	checkin	180	check_in	27-08-2026 10:52:00	77493	0.85	normal	2026-08-27 18:58:29.460829	STF-031	Muhammad Hassan	0.5183	recognized	2026-08-27 18:58:37.445546
74536	1916	attendance	820	Person Entered	27-08-2026 15:45:11	517704	0.85	unrecognized	2026-08-27 20:44:00.719854	\N	Person #820	0	unrecognized	2026-08-27 20:44:18.900936
74054	1916	checkin	177	check_in	27-08-2026 10:51:00	76943	0.85	normal	2026-08-27 18:58:15.650746	STF-086	Muhammad Moaaz Khan	0.4417	recognized	2026-08-27 18:58:19.505077
77770	1918	breakout	15	Break Out	27-08-2026 14:05:38	7389	0.85	normal	2026-08-28 09:49:23.25807	STF-046	Usman Babar	0.5115	recognized	2026-08-28 09:49:40.904
74990	1916	attendance	107	Person Entered	27-08-2026 18:14:49	742198	0.85	unrecognized	2026-08-28 06:20:28.059421	\N	Person #107	0	unrecognized	2026-08-28 06:20:31.517616
74952	1917	breakin	21	Break In	27-08-2026 17:58:28	2686	0.85	unrecognized	2026-08-28 06:16:40.983229	\N	Person #21	0	unrecognized	2026-08-28 06:16:57.414568
74107	1916	checkin	247	check_in	27-08-2026 11:01:11	91749	0.85	normal	2026-08-27 19:10:37.422077	STF-027	Ahmed Hassan Bhatti	0.455	recognized	2026-08-27 19:10:40.186723
75062	1917	breakin	55	Break In	27-08-2026 18:10:10	20056	0.85	unrecognized	2026-08-28 06:24:34.890926	\N	Person #55	0	unrecognized	2026-08-28 06:24:52.994515
74138	1916	checkin	288	check_in	27-08-2026 11:07:14	100810	0.85	normal	2026-08-27 19:18:25.888861	STF-008	Muhammad Shoaib	0.4476	recognized	2026-08-27 19:18:30.174644
74927	1916	attendance	68	Person Entered	27-08-2026 18:02:16	723321	0.85	unrecognized	2026-08-28 06:14:22.095579	\N	Person #68	0	unrecognized	2026-08-28 06:15:01.117702
78119	1918	breakout	118	Break Out	27-08-2026 14:40:13	59203	0.85	unrecognized	2026-08-28 10:08:49.959748	\N	Person #118	0	unrecognized	2026-08-28 10:09:33.685394
75059	1917	breakin	53	Break In	27-08-2026 18:09:08	18704	0.85	normal	2026-08-28 06:24:29.138328	STF-044	Zaheer Hussain	0.4774	recognized	2026-08-28 06:24:30.730926
74537	1916	attendance	822	Person Entered	27-08-2026 15:45:12	517720	0.85	unrecognized	2026-08-27 20:44:03.510333	\N	Person #822	0	unrecognized	2026-08-27 20:44:22.414259
74115	1916	checkin	256	check_in	27-08-2026 11:02:23	93566	0.85	normal	2026-08-27 19:12:00.89033	STF-035	Hammad Shaukat	0.4727	recognized	2026-08-27 19:12:01.818253
74823	1916	attendance	34	Person Entered	27-08-2026 17:51:00	707761	0.85	unrecognized	2026-08-28 06:08:23.274959	\N	Person #34	0	unrecognized	2026-08-28 06:08:31.877763
74104	1916	checkin	243	check_in	27-08-2026 11:00:56	91363	0.85	normal	2026-08-27 19:09:37.991431	STF-011	Syed Shoaib Ahmad Alvi	0.5949	recognized	2026-08-27 19:09:51.250637
75112	1916	attendance	150	Person Entered	27-08-2026 18:44:00	786005	0.85	unrecognized	2026-08-28 06:28:03.19255	\N	Person #150	0	unrecognized	2026-08-28 06:28:28.173872
78819	1918	breakout	324	Break Out	27-08-2026 16:18:44	207069	0.85	normal	2026-08-28 10:46:53.245779	STF-044	Zaheer Hussain	0.4625	recognized	2026-08-28 10:47:01.600232
74863	1916	attendance	52	Person Entered	27-08-2026 17:55:45	713561	0.85	unrecognized	2026-08-28 06:10:32.387215	\N	Person #52	0	unrecognized	2026-08-28 06:10:51.131541
75068	1917	breakin	57	Break In	27-08-2026 18:10:44	21088	0.85	normal	2026-08-28 06:24:54.266372	STF-029	Abdul Rehman Sultan	0.4522	recognized	2026-08-28 06:24:56.595336
74140	1916	checkin	292	check_in	27-08-2026 11:07:38	101411	0.85	normal	2026-08-27 19:19:18.402117	STF-002	Abdur Rehman	0.445	recognized	2026-08-27 19:19:21.652323
75108	1916	attendance	141	Person Entered	27-08-2026 18:41:28	782140	0.85	unrecognized	2026-08-28 06:27:26.324569	\N	Person #141	0	unrecognized	2026-08-28 06:27:50.21784
78479	1918	breakout	234	Break Out	27-08-2026 15:24:52	126177	0.85	unrecognized	2026-08-28 10:30:13.586274	\N	Person #234	0	unrecognized	2026-08-28 10:30:30.086294
75383	1917	breakin	153	Break In	27-08-2026 11:17:30	115638	0.85	unrecognized	2026-08-28 06:49:49.69751	\N	Person #153	0	unrecognized	2026-08-28 06:49:49.733415
78470	1918	breakout	233	Break Out	27-08-2026 15:22:31	122572	0.85	unrecognized	2026-08-28 10:29:40.238878	\N	Person #233	0	unrecognized	2026-08-28 10:29:57.32162
75174	1917	breakin	80	Break In	27-08-2026 18:12:47	24125	0.85	unrecognized	2026-08-28 06:35:08.579992	\N	Person #80	0	unrecognized	2026-08-28 06:35:10.413366
74166	1916	checkin	328	check_in	27-08-2026 11:09:45	103932	0.85	normal	2026-08-27 19:26:02.763962	STF-017	Mohammad Zahid	0.4929	recognized	2026-08-27 19:26:18.761326
75027	1916	attendance	118	Person Entered	27-08-2026 18:16:32	744634	0.85	unrecognized	2026-08-28 06:22:15.462538	\N	Person #118	0	unrecognized	2026-08-28 06:22:48.531666
74179	1916	checkin	348	check_in	27-08-2026 11:12:45	109092	0.85	normal	2026-08-27 19:29:12.23425	STF-025	Farhan Virk	0.4486	recognized	2026-08-27 19:29:15.497919
74895	1916	attendance	60	Person Entered	27-08-2026 17:59:00	718905	0.85	unrecognized	2026-08-28 06:12:48.564035	\N	Person #60	0	unrecognized	2026-08-28 06:13:11.824643
75084	1916	attendance	133	Person Entered	27-08-2026 18:35:30	773207	0.85	unrecognized	2026-08-28 06:26:09.216593	\N	Person #133	0	unrecognized	2026-08-28 06:26:18.332932
75385	1917	breakin	153	Break In	27-08-2026 11:17:43	116180	0.85	pending	2026-08-28 06:49:50.639146	\N	Person #153	\N	pending	\N
74973	1916	attendance	100	Person Entered	27-08-2026 18:13:33	740428	0.85	unrecognized	2026-08-28 06:18:42.008716	\N	Person #100	0	unrecognized	2026-08-28 06:18:49.594549
75172	1917	breakin	79	Break In	27-08-2026 18:12:39	23955	0.85	unrecognized	2026-08-28 06:35:03.217627	\N	Person #79	0	unrecognized	2026-08-28 06:35:07.974469
75127	1916	attendance	157	Person Entered	27-08-2026 18:53:20	799948	0.85	unrecognized	2026-08-28 06:29:44.170612	\N	Person #157	0	unrecognized	2026-08-28 06:29:54.696152
75058	1917	breakin	52	Break In	27-08-2026 18:08:20	17493	0.85	normal	2026-08-28 06:24:25.924191	STF-022	Mubashir Ishaq	0.4812	recognized	2026-08-28 06:24:26.637731
74202	1916	checkin	379	check_in	27-08-2026 11:26:06	128528	0.85	normal	2026-08-27 19:36:10.485072	STF-053	Rehan Sarwar	0.4482	recognized	2026-08-27 19:36:13.677807
75154	1916	attendance	193	Person Entered	27-08-2026 19:14:29	831703	0.85	pending	2026-08-28 06:32:43.820076	\N	Person #193	\N	pending	\N
78476	1918	breakout	234	Break Out	27-08-2026 15:23:14	123712	0.85	unrecognized	2026-08-28 10:29:58.111472	\N	Person #234	0	unrecognized	2026-08-28 10:30:12.411879
75155	1916	attendance	195	Person Entered	27-08-2026 19:14:00	831726	0.85	unrecognized	2026-08-28 06:32:45.568081	\N	Person #195	0	unrecognized	2026-08-28 06:33:12.963141
74200	1916	checkin	377	check_in	27-08-2026 11:24:51	127222	0.85	normal	2026-08-27 19:35:54.968828	STF-085	Syed Talha Ali	0.4401	recognized	2026-08-27 19:36:02.499925
75169	1917	breakin	78	Break In	27-08-2026 18:12:07	23085	0.85	unrecognized	2026-08-28 06:34:45.299931	\N	Person #78	0	unrecognized	2026-08-28 06:35:02.130519
75193	1916	attendance	216	Person Entered	27-08-2026 19:31:47	857667	0.85	pending	2026-08-28 06:36:29.531272	\N	Person #216	\N	pending	\N
75458	1916	attendance	325	Person Entered	27-08-2026 20:26:05	939110	0.85	pending	2026-08-28 06:55:18.511261	\N	Person #325	0	unrecognized	\N
75422	1916	attendance	308	Person Entered	27-08-2026 20:21:48	932697	0.85	unrecognized	2026-08-28 06:52:31.872772	\N	Person #308	0	unrecognized	2026-08-28 06:52:32.390768
75486	1916	attendance	346	Person Entered	27-08-2026 20:37:15	955841	0.85	unrecognized	2026-08-28 06:57:32.344754	\N	Person #346	0	unrecognized	2026-08-28 06:57:35.064681
75507	1917	breakin	155	Break In	27-08-2026 18:31:56	52902	0.85	normal	2026-08-28 06:59:03.39759	STF-011	Syed Shoaib Ahmad Alvi	0.6599	recognized	2026-08-28 06:59:03.413547
74538	1916	attendance	823	Person Entered	27-08-2026 15:46:01	519010	0.85	pending	2026-08-27 20:44:24.35365	\N	Person #823	0	unrecognized	\N
74549	1916	attendance	840	Person Entered	27-08-2026 15:55:52	533722	0.85	unrecognized	2026-08-27 20:46:52.462703	\N	Person #840	0	unrecognized	2026-08-27 20:47:06.477658
74541	1916	attendance	829	Person Entered	27-08-2026 15:49:58	524381	0.85	unrecognized	2026-08-27 20:44:56.598141	\N	Person #829	0	unrecognized	2026-08-27 20:44:57.0506
74546	1916	attendance	835	Person Entered	27-08-2026 15:53:00	529294	0.85	unrecognized	2026-08-27 20:45:49.876138	\N	Person #835	0	unrecognized	2026-08-27 20:46:17.400065
74547	1916	attendance	836	Person Entered	27-08-2026 15:53:04	529555	0.85	unrecognized	2026-08-27 20:46:17.779834	\N	Person #836	0	unrecognized	2026-08-27 20:46:25.287839
74572	1916	attendance	873	Person Entered	27-08-2026 16:09:00	554377	0.85	unrecognized	2026-08-27 20:49:49.353723	\N	Person #873	0	unrecognized	2026-08-27 20:49:57.436178
74560	1916	attendance	856	Person Entered	27-08-2026 16:06:13	548724	0.85	unrecognized	2026-08-27 20:48:31.725079	\N	Person #856	0	unrecognized	2026-08-27 20:48:40.928814
74543	1916	attendance	831	Person Entered	27-08-2026 15:50:31	525698	0.85	unrecognized	2026-08-27 20:45:08.165611	\N	Person #831	0	unrecognized	2026-08-27 20:45:35.004412
74551	1916	attendance	842	Person Entered	27-08-2026 15:58:08	537040	0.85	unrecognized	2026-08-27 20:47:19.546109	\N	Person #842	0	unrecognized	2026-08-27 20:47:44.644586
74552	1916	attendance	842	Person Entered	27-08-2026 15:58:09	537219	0.85	pending	2026-08-27 20:47:45.76227	\N	Person #842	\N	pending	\N
74550	1916	attendance	841	Person Entered	27-08-2026 15:56:00	533959	0.85	unrecognized	2026-08-27 20:47:07.664868	\N	Person #841	0	unrecognized	2026-08-27 20:47:16.466482
74553	1916	attendance	844	Person Entered	27-08-2026 15:58:10	537231	0.85	pending	2026-08-27 20:47:46.250124	\N	Person #844	0	unrecognized	\N
74544	1916	attendance	833	Person Entered	27-08-2026 15:50:32	525729	0.85	unrecognized	2026-08-27 20:45:18.736435	\N	Person #833	0	unrecognized	2026-08-27 20:45:37.503663
74554	1916	attendance	847	Person Entered	27-08-2026 15:58:11	537260	0.85	pending	2026-08-27 20:47:47.405874	\N	Person #847	\N	pending	\N
74545	1916	attendance	834	Person Entered	27-08-2026 15:50:00	525769	0.85	unrecognized	2026-08-27 20:45:36.172923	\N	Person #834	0	unrecognized	2026-08-27 20:45:45.880254
74565	1916	attendance	862	Person Entered	27-08-2026 16:07:23	551014	0.85	unrecognized	2026-08-27 20:49:02.059347	\N	Person #862	0	unrecognized	2026-08-27 20:49:09.422798
74562	1916	attendance	859	Person Entered	27-08-2026 16:06:00	549628	0.85	unrecognized	2026-08-27 20:48:46.498019	\N	Person #859	0	unrecognized	2026-08-27 20:48:55.126419
74542	1916	attendance	830	Person Entered	27-08-2026 15:50:00	525654	0.85	unrecognized	2026-08-27 20:44:59.601205	\N	Person #830	0	unrecognized	2026-08-27 20:45:14.796846
74573	1916	attendance	874	Person Entered	27-08-2026 16:10:21	555469	0.85	unrecognized	2026-08-27 20:49:59.056302	\N	Person #874	0	unrecognized	2026-08-27 20:50:03.60834
74567	1916	attendance	865	Person Entered	27-08-2026 16:08:15	552330	0.85	unrecognized	2026-08-27 20:49:17.88422	\N	Person #865	0	unrecognized	2026-08-27 20:49:22.692745
74566	1916	attendance	863	Person Entered	27-08-2026 16:07:24	551048	0.85	unrecognized	2026-08-27 20:49:04.678681	\N	Person #863	0	unrecognized	2026-08-27 20:49:16.239519
74539	1916	attendance	826	Person Entered	27-08-2026 15:49:33	523662	0.85	unrecognized	2026-08-27 20:44:32.538991	\N	Person #826	0	unrecognized	2026-08-27 20:44:51.111724
74561	1916	attendance	857	Person Entered	27-08-2026 16:06:26	549607	0.85	unrecognized	2026-08-27 20:48:42.299258	\N	Person #857	0	unrecognized	2026-08-27 20:48:48.601225
74540	1916	attendance	827	Person Entered	27-08-2026 15:49:31	524269	0.85	pending	2026-08-27 20:44:52.894283	\N	Person #827	0	unrecognized	\N
74555	1916	attendance	848	Person Entered	27-08-2026 15:58:14	537319	0.85	unrecognized	2026-08-27 20:47:49.830356	\N	Person #848	0	unrecognized	2026-08-27 20:47:52.941166
74548	1916	attendance	838	Person Entered	27-08-2026 15:54:41	531349	0.85	unrecognized	2026-08-27 20:46:28.593965	\N	Person #838	0	unrecognized	2026-08-27 20:46:49.550725
74556	1916	attendance	851	Person Entered	27-08-2026 16:01:00	542148	0.85	unrecognized	2026-08-27 20:48:00.250416	\N	Person #851	0	unrecognized	2026-08-27 20:48:10.817558
74557	1916	attendance	852	Person Entered	27-08-2026 16:02:02	543050	0.85	pending	2026-08-27 20:48:12.809517	\N	Person #852	0	unrecognized	\N
74558	1916	attendance	853	Person Entered	27-08-2026 16:03:31	545265	0.85	pending	2026-08-27 20:48:16.608418	\N	Person #853	0	unrecognized	\N
74574	1916	attendance	876	Person Entered	27-08-2026 16:10:38	555910	0.85	unrecognized	2026-08-27 20:50:04.858202	\N	Person #876	0	unrecognized	2026-08-27 20:50:12.806265
74569	1916	attendance	867	Person Entered	27-08-2026 16:08:26	552633	0.85	unrecognized	2026-08-27 20:49:24.969332	\N	Person #867	0	unrecognized	2026-08-27 20:49:29.008403
74559	1916	attendance	855	Person Entered	27-08-2026 16:06:00	548519	0.85	unrecognized	2026-08-27 20:48:21.475549	\N	Person #855	0	unrecognized	2026-08-27 20:48:30.915113
74568	1916	attendance	865	Person Entered	27-08-2026 16:08:25	552612	0.85	unrecognized	2026-08-27 20:49:23.478744	\N	Person #865	0	unrecognized	2026-08-27 20:49:24.383549
74563	1916	attendance	860	Person Entered	27-08-2026 16:07:16	550868	0.85	unrecognized	2026-08-27 20:48:57.330384	\N	Person #860	0	unrecognized	2026-08-27 20:48:59.802562
74564	1916	attendance	861	Person Entered	27-08-2026 16:07:16	550892	0.85	pending	2026-08-27 20:49:00.466432	\N	Person #861	\N	pending	\N
74577	1916	attendance	878	Person Entered	27-08-2026 16:17:48	566621	0.85	unrecognized	2026-08-27 20:50:51.341435	\N	Person #878	0	unrecognized	2026-08-27 20:51:03.886494
74570	1916	attendance	870	Person Entered	27-08-2026 16:09:19	553358	0.85	unrecognized	2026-08-27 20:49:30.645481	\N	Person #870	0	unrecognized	2026-08-27 20:49:41.649343
74579	1916	attendance	881	Person Entered	27-08-2026 16:20:34	570796	0.85	unrecognized	2026-08-27 20:51:15.911442	\N	Person #881	0	unrecognized	2026-08-27 20:51:21.555824
74571	1916	attendance	872	Person Entered	27-08-2026 16:09:37	553831	0.85	unrecognized	2026-08-27 20:49:44.070209	\N	Person #872	0	unrecognized	2026-08-27 20:49:47.763532
74576	1916	attendance	877	Person Entered	27-08-2026 16:15:26	562519	0.85	unrecognized	2026-08-27 20:50:31.991742	\N	Person #877	0	unrecognized	2026-08-27 20:50:47.698629
74575	1916	attendance	876	Person Entered	27-08-2026 16:13:51	560708	0.85	unrecognized	2026-08-27 20:50:16.586162	\N	Person #876	0	unrecognized	2026-08-27 20:50:28.474745
74578	1916	attendance	879	Person Entered	27-08-2026 16:19:52	569206	0.85	unrecognized	2026-08-27 20:51:06.677691	\N	Person #879	0	unrecognized	2026-08-27 20:51:13.454089
74580	1916	attendance	882	Person Entered	27-08-2026 16:22:08	573136	0.85	unrecognized	2026-08-27 20:51:24.017259	\N	Person #882	0	unrecognized	2026-08-27 20:51:33.206948
74581	1916	attendance	883	Person Entered	27-08-2026 16:22:56	574356	0.85	unrecognized	2026-08-27 20:51:34.733973	\N	Person #883	0	unrecognized	2026-08-27 20:51:42.222359
74181	1916	checkin	351	check_in	27-08-2026 11:12:50	109232	0.85	normal	2026-08-27 19:29:24.471885	STF-069	Mehmood Ali	0.4651	recognized	2026-08-27 19:29:24.705921
74836	1917	breakin	2	Break In	27-08-2026 10:50:01	74427	0.85	normal	2026-08-28 06:08:57.369765	STF-037	Muhammad Fahad	0.4829	recognized	2026-08-28 06:08:57.410655
78824	1918	breakout	357	Break Out	27-08-2026 20:50:56	258335	0.85	unrecognized	2026-08-28 10:47:11.911871	\N	Person #357	0	unrecognized	2026-08-28 10:47:21.444972
74825	1917	breakin	2	Break In	27-08-2026 10:45:50	68095	0.85	unrecognized	2026-08-28 06:08:24.209383	\N	Person #2	0	unrecognized	2026-08-28 06:08:27.383868
74586	1916	attendance	890	Person Entered	27-08-2026 16:24:16	576343	0.85	unrecognized	2026-08-27 20:52:09.288172	\N	Person #890	0	unrecognized	2026-08-27 20:52:22.594511
74826	1917	breakin	2	Break In	27-08-2026 10:46:04	68506	0.85	unrecognized	2026-08-28 06:08:28.063347	\N	Person #2	0	unrecognized	2026-08-28 06:08:28.120194
75307	1916	attendance	261	Person Entered	27-08-2026 19:59:00	899874	0.85	unrecognized	2026-08-28 06:43:31.052298	\N	Person #261	0	unrecognized	2026-08-28 06:43:49.117858
77769	1918	breakout	9	Break Out	27-08-2026 18:02:12	5234	0.85	unrecognized	2026-08-28 09:49:20.659486	\N	Person #9	0	unrecognized	2026-08-28 09:49:26.779475
74188	1916	checkin	358	check_in	27-08-2026 11:16:33	114125	0.85	normal	2026-08-27 19:31:19.234464	STF-077	Jawad Ahmed	0.4433	recognized	2026-08-27 19:31:28.269534
74193	1916	checkin	367	check_in	27-08-2026 11:19:09	118699	0.85	normal	2026-08-27 19:32:49.086727	STF-006	Muhammad Abubakar	0.53	recognized	2026-08-27 19:32:49.514242
74197	1916	checkin	373	check_in	27-08-2026 11:23:03	123960	0.85	normal	2026-08-27 19:34:51.872725	STF-038	Kazi Abdul Manan	0.4498	recognized	2026-08-27 19:34:53.371328
77765	1918	breakout	6	Break Out	27-08-2026 18:00:34	2764	0.85	unrecognized	2026-08-28 09:48:37.215426	\N	Person #6	0	unrecognized	2026-08-28 09:48:48.91684
74583	1916	attendance	887	Person Entered	27-08-2026 16:23:39	575427	0.85	unrecognized	2026-08-27 20:51:46.916239	\N	Person #887	0	unrecognized	2026-08-27 20:51:57.511927
75310	1916	attendance	261	Person Entered	27-08-2026 20:00:15	900115	0.85	unrecognized	2026-08-28 06:43:50.672153	\N	Person #261	0	unrecognized	2026-08-28 06:45:22.85206
74829	1917	breakin	2	Break In	27-08-2026 10:47:35	70775	0.85	normal	2026-08-28 06:08:32.819788	STF-037	Muhammad Fahad	0.5105	recognized	2026-08-28 06:08:32.862663
74831	1917	breakin	2	Break In	27-08-2026 10:47:00	71117	0.85	normal	2026-08-28 06:08:33.968787	STF-037	Muhammad Fahad	0.5224	recognized	2026-08-28 06:08:34.011456
74587	1916	attendance	891	Person Entered	27-08-2026 16:24:41	576387	0.85	unrecognized	2026-08-27 20:52:19.227542	\N	Person #891	0	unrecognized	2026-08-27 20:52:36.694266
77766	1918	breakout	7	Break Out	27-08-2026 18:00:44	2995	0.85	unrecognized	2026-08-28 09:48:49.386766	\N	Person #7	0	unrecognized	2026-08-28 09:49:04.527313
74832	1917	breakin	2	Break In	27-08-2026 10:49:00	73894	0.85	normal	2026-08-28 06:08:36.484409	STF-037	Muhammad Fahad	0.4685	recognized	2026-08-28 06:08:36.506355
74207	1916	checkin	385	check_in	27-08-2026 11:29:13	133781	0.85	normal	2026-08-27 19:37:34.878826	STF-052	Syed Imran Shah	0.4879	recognized	2026-08-27 19:37:44.509635
74208	1916	checkin	386	check_in	27-08-2026 11:33:03	135187	0.85	normal	2026-08-27 19:37:50.810218	STF-078	Syed Shehryar Ahmed	0.5124	recognized	2026-08-27 19:37:50.860709
78820	1918	breakout	355	Break Out	27-08-2026 20:49:50	256716	0.85	unrecognized	2026-08-28 10:46:57.667132	\N	Person #355	0	unrecognized	2026-08-28 10:47:02.335129
74582	1916	attendance	886	Person Entered	27-08-2026 16:23:39	575418	0.85	unrecognized	2026-08-27 20:51:44.421921	\N	Person #886	0	unrecognized	2026-08-27 20:52:00.094603
74584	1916	attendance	888	Person Entered	27-08-2026 16:23:39	575468	0.85	pending	2026-08-27 20:52:00.397628	\N	Person #888	0	unrecognized	\N
74204	1916	checkin	382	check_in	27-08-2026 11:27:00	129885	0.85	normal	2026-08-27 19:36:53.740438	STF-056	Imran Waheed Butt	0.4597	recognized	2026-08-27 19:36:56.133575
74996	1916	attendance	108	Person Entered	27-08-2026 18:15:01	742443	0.85	unrecognized	2026-08-28 06:21:07.579488	\N	Person #108	0	unrecognized	2026-08-28 06:21:35.979169
74954	1916	attendance	91	Person Entered	27-08-2026 18:06:11	729231	0.85	unrecognized	2026-08-28 06:16:56.872975	\N	Person #91	0	unrecognized	2026-08-28 06:17:13.707361
78124	1918	breakout	105	Break Out	27-08-2026 11:23:06	119517	0.85	unrecognized	2026-08-28 10:09:27.021167	\N	Person #105	0	unrecognized	2026-08-28 10:09:35.086766
74974	1916	attendance	101	Person Entered	27-08-2026 18:13:57	740864	0.85	unrecognized	2026-08-28 06:18:51.087129	\N	Person #101	0	unrecognized	2026-08-28 06:19:01.33211
74950	1916	attendance	89	Person Entered	27-08-2026 18:06:05	729054	0.85	unrecognized	2026-08-28 06:16:35.098643	\N	Person #89	0	unrecognized	2026-08-28 06:16:55.237053
74222	1916	checkin	405	check_in	27-08-2026 11:33:51	140752	0.85	normal	2026-08-27 19:41:23.508915	STF-066	Hanan Ashraf	0.4846	recognized	2026-08-27 19:41:23.529095
74868	1916	attendance	53	Person Entered	27-08-2026 17:55:54	713785	0.85	unrecognized	2026-08-28 06:10:52.996026	\N	Person #53	0	unrecognized	2026-08-28 06:11:09.459516
74929	1916	attendance	69	Person Entered	27-08-2026 18:02:16	723350	0.85	unrecognized	2026-08-28 06:14:40.308015	\N	Person #69	0	unrecognized	2026-08-28 06:15:04.653097
78482	1918	breakout	210	Break Out	27-08-2026 12:17:20	200907	0.85	unrecognized	2026-08-28 10:30:24.417287	\N	Person #210	0	unrecognized	2026-08-28 10:30:36.057253
74931	1916	attendance	71	Person Entered	27-08-2026 18:02:20	723443	0.85	unrecognized	2026-08-28 06:15:06.091534	\N	Person #71	0	unrecognized	2026-08-28 06:15:29.29804
74263	1916	checkin	460	check_in	27-08-2026 11:53:00	168887	0.85	normal	2026-08-27 19:49:04.204407	STF-080	Muhammad Faisal	0.4407	recognized	2026-08-27 19:49:05.769094
75061	1917	breakin	98	Break In	27-08-2026 11:04:00	96524	0.85	normal	2026-08-28 06:24:31.352047	STF-007	Faisal Saleem	0.4642	recognized	2026-08-28 06:24:31.615874
78481	1918	breakout	209	Break Out	27-08-2026 12:16:20	199417	0.85	normal	2026-08-28 10:30:17.934965	STF-033	Raza Abbas	0.5048	recognized	2026-08-28 10:30:21.121136
75063	1917	breakin	99	Break In	27-08-2026 11:04:59	96880	0.85	normal	2026-08-28 06:24:36.660705	STF-013	Muhammad Faizan	0.5862	recognized	2026-08-28 06:24:36.736503
78828	1918	breakout	358	Break Out	27-08-2026 20:51:19	258985	0.85	unrecognized	2026-08-28 10:47:22.290972	\N	Person #358	0	unrecognized	2026-08-28 10:47:22.306772
78821	1918	breakout	355	Break Out	27-08-2026 20:50:03	257006	0.85	unrecognized	2026-08-28 10:47:02.878938	\N	Person #355	0	unrecognized	2026-08-28 10:47:10.746546
74234	1916	checkin	420	check_in	27-08-2026 11:37:35	146336	0.85	normal	2026-08-27 19:44:06.492465	STF-044	Zaheer Hussain	0.4745	recognized	2026-08-27 19:44:21.394652
74238	1916	checkin	424	check_in	27-08-2026 11:38:53	148263	0.85	normal	2026-08-27 19:45:32.805974	STF-064	Muhammad Arsalan	0.5272	recognized	2026-08-27 19:45:42.593693
75072	1917	breakin	105	Break In	27-08-2026 11:05:15	97266	0.85	normal	2026-08-28 06:25:06.652718	STF-016	Muhammad Asad Awan	0.4887	recognized	2026-08-28 06:25:06.70708
75085	1917	breakin	60	Break In	27-08-2026 18:11:17	21574	0.85	unrecognized	2026-08-28 06:26:09.706303	\N	Person #60	0	unrecognized	2026-08-28 06:27:07.037354
75130	1916	attendance	162	Person Entered	27-08-2026 19:00:26	810590	0.85	unrecognized	2026-08-28 06:30:12.502107	\N	Person #162	0	unrecognized	2026-08-28 06:30:23.344629
75142	1917	breakin	68	Break In	27-08-2026 18:11:51	22684	0.85	unrecognized	2026-08-28 06:31:32.48865	\N	Person #68	0	unrecognized	2026-08-28 06:33:08.196503
74618	1916	attendance	935	Person Entered	27-08-2026 17:03:44	635592	0.85	pending	2026-08-27 20:58:32.962249	\N	Person #935	0	unrecognized	\N
74600	1916	attendance	912	Person Entered	27-08-2026 16:40:00	599789	0.85	unrecognized	2026-08-27 20:55:47.965555	\N	Person #912	0	unrecognized	2026-08-27 20:55:58.552611
74620	1916	attendance	937	Person Entered	27-08-2026 17:09:33	644250	0.85	unrecognized	2026-08-27 20:58:59.234893	\N	Person #937	0	unrecognized	2026-08-27 20:59:13.460006
74604	1916	attendance	916	Person Entered	27-08-2026 16:43:00	605124	0.85	unrecognized	2026-08-27 20:56:31.995665	\N	Person #916	0	unrecognized	2026-08-27 20:56:39.269977
74595	1916	attendance	902	Person Entered	27-08-2026 16:33:50	590571	0.85	unrecognized	2026-08-27 20:54:30.036944	\N	Person #902	0	unrecognized	2026-08-27 20:54:59.524107
74594	1916	attendance	899	Person Entered	27-08-2026 16:33:37	590350	0.85	unrecognized	2026-08-27 20:54:17.447386	\N	Person #899	0	unrecognized	2026-08-27 20:54:28.304389
74592	1916	attendance	897	Person Entered	27-08-2026 16:31:18	586837	0.85	unrecognized	2026-08-27 20:53:19.741693	\N	Person #897	0	unrecognized	2026-08-27 20:54:08.613491
74597	1916	attendance	905	Person Entered	27-08-2026 16:36:49	595150	0.85	unrecognized	2026-08-27 20:55:08.125225	\N	Person #905	0	unrecognized	2026-08-27 20:55:20.321623
74602	1916	attendance	914	Person Entered	27-08-2026 16:42:34	603233	0.85	unrecognized	2026-08-27 20:56:13.26814	\N	Person #914	0	unrecognized	2026-08-27 20:56:23.706799
74610	1916	attendance	920	Person Entered	27-08-2026 16:54:41	621990	0.85	unrecognized	2026-08-27 20:57:35.980683	\N	Person #920	0	unrecognized	2026-08-27 20:57:47.910128
74591	1916	attendance	895	Person Entered	27-08-2026 16:31:33	586800	0.85	unrecognized	2026-08-27 20:53:11.986177	\N	Person #895	0	unrecognized	2026-08-27 20:53:55.731401
74616	1916	attendance	933	Person Entered	27-08-2026 17:01:10	631707	0.85	unrecognized	2026-08-27 20:58:16.717253	\N	Person #933	0	unrecognized	2026-08-27 20:58:23.422549
74601	1916	attendance	914	Person Entered	27-08-2026 16:40:00	600130	0.85	unrecognized	2026-08-27 20:56:02.258472	\N	Person #914	0	unrecognized	2026-08-27 20:56:10.528487
74585	1916	attendance	889	Person Entered	27-08-2026 16:24:37	576313	0.85	unrecognized	2026-08-27 20:52:04.667528	\N	Person #889	0	unrecognized	2026-08-27 20:52:14.001981
74599	1916	attendance	910	Person Entered	27-08-2026 16:38:25	597568	0.85	unrecognized	2026-08-27 20:55:35.010112	\N	Person #910	0	unrecognized	2026-08-27 20:55:45.287377
74596	1916	attendance	903	Person Entered	27-08-2026 16:33:52	590761	0.85	unrecognized	2026-08-27 20:55:00.071812	\N	Person #903	0	unrecognized	2026-08-27 20:55:02.582132
74590	1916	attendance	894	Person Entered	27-08-2026 16:31:19	586344	0.85	unrecognized	2026-08-27 20:53:02.112222	\N	Person #894	0	unrecognized	2026-08-27 20:53:11.189476
74589	1916	attendance	893	Person Entered	27-08-2026 16:28:22	581935	0.85	unrecognized	2026-08-27 20:52:49.07316	\N	Person #893	0	unrecognized	2026-08-27 20:52:57.753839
74588	1916	attendance	892	Person Entered	27-08-2026 16:24:20	576426	0.85	unrecognized	2026-08-27 20:52:29.701216	\N	Person #892	0	unrecognized	2026-08-27 20:52:44.631267
74607	1916	attendance	917	Person Entered	27-08-2026 16:50:00	615760	0.85	unrecognized	2026-08-27 20:57:03.829256	\N	Person #917	0	unrecognized	2026-08-27 20:57:17.048489
74609	1916	attendance	919	Person Entered	27-08-2026 16:54:41	621980	0.85	unrecognized	2026-08-27 20:57:35.413934	\N	Person #919	0	unrecognized	2026-08-27 20:57:41.554681
74593	1916	attendance	898	Person Entered	27-08-2026 16:31:41	586867	0.85	unrecognized	2026-08-27 20:53:32.745324	\N	Person #898	0	unrecognized	2026-08-27 20:54:13.255924
74605	1916	attendance	916	Person Entered	27-08-2026 16:44:33	606275	0.85	unrecognized	2026-08-27 20:56:40.493053	\N	Person #916	0	unrecognized	2026-08-27 20:56:53.123607
74606	1916	attendance	917	Person Entered	27-08-2026 16:48:12	612283	0.85	pending	2026-08-27 20:56:58.837143	\N	Person #917	0	unrecognized	\N
74613	1916	attendance	926	Person Entered	27-08-2026 16:57:12	625176	0.85	unrecognized	2026-08-27 20:57:54.8649	\N	Person #926	0	unrecognized	2026-08-27 20:57:59.952429
74598	1916	attendance	908	Person Entered	27-08-2026 16:36:55	595312	0.85	unrecognized	2026-08-27 20:55:20.753349	\N	Person #908	0	unrecognized	2026-08-27 20:55:32.367407
74611	1916	attendance	921	Person Entered	27-08-2026 16:54:41	622004	0.85	unrecognized	2026-08-27 20:57:41.10248	\N	Person #921	0	unrecognized	2026-08-27 20:57:45.795677
74603	1916	attendance	915	Person Entered	27-08-2026 16:42:41	603423	0.85	unrecognized	2026-08-27 20:56:25.108896	\N	Person #915	0	unrecognized	2026-08-27 20:56:29.585966
74625	1916	attendance	947	Person Entered	27-08-2026 17:15:46	653008	0.85	unrecognized	2026-08-27 20:59:50.796332	\N	Person #947	0	unrecognized	2026-08-27 20:59:54.818925
74623	1916	attendance	944	Person Entered	27-08-2026 17:13:00	650041	0.85	unrecognized	2026-08-27 20:59:38.988074	\N	Person #944	0	unrecognized	2026-08-27 20:59:45.543786
74619	1916	attendance	936	Person Entered	27-08-2026 17:04:32	636676	0.85	unrecognized	2026-08-27 20:58:35.933591	\N	Person #936	0	unrecognized	2026-08-27 20:58:52.848151
74608	1916	attendance	918	Person Entered	27-08-2026 16:51:21	616958	0.85	unrecognized	2026-08-27 20:57:19.10576	\N	Person #918	0	unrecognized	2026-08-27 20:57:30.43851
74614	1916	attendance	927	Person Entered	27-08-2026 16:57:17	625869	0.85	unrecognized	2026-08-27 20:58:01.836437	\N	Person #927	0	unrecognized	2026-08-27 20:58:08.89136
74612	1916	attendance	922	Person Entered	27-08-2026 16:55:00	622015	0.85	unrecognized	2026-08-27 20:57:46.234026	\N	Person #922	0	unrecognized	2026-08-27 20:57:50.535275
74615	1916	attendance	930	Person Entered	27-08-2026 16:59:00	628487	0.85	pending	2026-08-27 20:58:12.34746	\N	Person #930	\N	pending	\N
74621	1916	attendance	942	Person Entered	27-08-2026 17:10:46	645550	0.85	unrecognized	2026-08-27 20:59:16.488257	\N	Person #942	0	unrecognized	2026-08-27 20:59:20.531017
74617	1916	attendance	934	Person Entered	27-08-2026 17:03:14	634806	0.85	unrecognized	2026-08-27 20:58:27.052245	\N	Person #934	0	unrecognized	2026-08-27 20:58:31.249662
74622	1916	attendance	943	Person Entered	27-08-2026 17:11:44	647531	0.85	unrecognized	2026-08-27 20:59:23.549524	\N	Person #943	0	unrecognized	2026-08-27 20:59:36.163611
74624	1916	attendance	946	Person Entered	27-08-2026 17:14:51	652262	0.85	pending	2026-08-27 20:59:49.572114	\N	Person #946	\N	pending	\N
74626	1916	attendance	947	Person Entered	27-08-2026 17:15:27	653163	0.85	pending	2026-08-27 20:59:55.141838	\N	Person #947	0	unrecognized	\N
74629	1916	attendance	953	Person Entered	27-08-2026 17:18:26	657639	0.85	pending	2026-08-27 21:00:13.93491	\N	Person #953	0	unrecognized	\N
74627	1916	attendance	948	Person Entered	27-08-2026 17:18:00	657330	0.85	unrecognized	2026-08-27 21:00:00.704855	\N	Person #948	0	unrecognized	2026-08-27 21:00:10.771717
74628	1916	attendance	948	Person Entered	27-08-2026 17:18:19	657451	0.85	pending	2026-08-27 21:00:11.608728	\N	Person #948	\N	pending	\N
74630	1916	attendance	955	Person Entered	27-08-2026 17:19:00	657761	0.85	unrecognized	2026-08-27 21:00:18.1152	\N	Person #955	0	unrecognized	2026-08-27 21:00:42.400382
75956	1917	breakin	352	Break In	27-08-2026 12:34:25	231028	0.85	normal	2026-08-28 07:28:00.117418	STF-013	Muhammad Faizan	0.4827	recognized	2026-08-28 07:28:02.374538
74638	1916	attendance	967	Person Entered	27-08-2026 17:28:53	673272	0.85	unrecognized	2026-08-27 21:02:13.936962	\N	Person #967	0	unrecognized	2026-08-27 21:02:21.692424
74631	1916	attendance	957	Person Entered	27-08-2026 17:19:00	657996	0.85	unrecognized	2026-08-27 21:00:43.437888	\N	Person #957	0	unrecognized	2026-08-27 21:00:43.799128
74645	1916	attendance	979	Person Entered	27-08-2026 17:37:02	685519	0.85	unrecognized	2026-08-27 21:03:18.156325	\N	Person #979	0	unrecognized	2026-08-27 21:03:21.619045
74639	1916	attendance	969	Person Entered	27-08-2026 17:28:55	673308	0.85	unrecognized	2026-08-27 21:02:19.153369	\N	Person #969	0	unrecognized	2026-08-27 21:02:29.642111
74637	1916	attendance	965	Person Entered	27-08-2026 17:27:19	670949	0.85	unrecognized	2026-08-27 21:02:07.76968	\N	Person #965	0	unrecognized	2026-08-27 21:02:11.013742
74646	1916	attendance	980	Person Entered	27-08-2026 17:37:51	686752	0.85	pending	2026-08-27 21:03:23.852746	\N	Person #980	\N	pending	\N
74669	1916	attendance	1027	Person Entered	27-08-2026 17:51:37	707380	0.85	unrecognized	2026-08-27 21:06:20.311443	\N	Person #1027	0	unrecognized	2026-08-27 21:06:28.637138
74666	1916	attendance	1020	Person Entered	27-08-2026 17:49:19	703918	0.85	unrecognized	2026-08-27 21:05:55.223567	\N	Person #1020	0	unrecognized	2026-08-27 21:06:03.955321
74657	1916	attendance	1002	Person Entered	27-08-2026 17:43:00	695137	0.85	unrecognized	2026-08-27 21:04:44.193907	\N	Person #1002	0	unrecognized	2026-08-27 21:04:50.85852
74633	1916	attendance	959	Person Entered	27-08-2026 17:24:41	666948	0.85	unrecognized	2026-08-27 21:01:09.092067	\N	Person #959	0	unrecognized	2026-08-27 21:01:24.524029
74654	1916	attendance	994	Person Entered	27-08-2026 17:42:00	693021	0.85	unrecognized	2026-08-27 21:04:16.552727	\N	Person #994	0	unrecognized	2026-08-27 21:04:30.86331
74655	1916	attendance	996	Person Entered	27-08-2026 17:42:51	694275	0.85	pending	2026-08-27 21:04:34.538765	\N	Person #996	\N	pending	\N
74648	1916	attendance	982	Person Entered	27-08-2026 17:38:57	688364	0.85	unrecognized	2026-08-27 21:03:35.522162	\N	Person #982	0	unrecognized	2026-08-27 21:03:46.246428
74647	1916	attendance	982	Person Entered	27-08-2026 17:38:47	688107	0.85	unrecognized	2026-08-27 21:03:27.140299	\N	Person #982	0	unrecognized	2026-08-27 21:03:35.113273
74643	1916	attendance	976	Person Entered	27-08-2026 17:35:50	683716	0.85	unrecognized	2026-08-27 21:03:10.646617	\N	Person #976	0	unrecognized	2026-08-27 21:03:14.203398
74644	1916	attendance	977	Person Entered	27-08-2026 17:35:51	683755	0.85	pending	2026-08-27 21:03:15.195047	\N	Person #977	\N	pending	\N
74634	1916	attendance	960	Person Entered	27-08-2026 17:26:27	669550	0.85	unrecognized	2026-08-27 21:01:28.471749	\N	Person #960	0	unrecognized	2026-08-27 21:02:03.304631
74632	1916	attendance	958	Person Entered	27-08-2026 17:19:00	659243	0.85	unrecognized	2026-08-27 21:00:47.235027	\N	Person #958	0	unrecognized	2026-08-27 21:01:02.013389
74649	1916	attendance	982	Person Entered	27-08-2026 17:39:24	689081	0.85	pending	2026-08-27 21:03:47.656376	\N	Person #982	0	unrecognized	\N
74635	1916	attendance	961	Person Entered	27-08-2026 17:26:28	669609	0.85	unrecognized	2026-08-27 21:01:40.767822	\N	Person #961	0	unrecognized	2026-08-27 21:02:04.515508
74636	1916	attendance	962	Person Entered	27-08-2026 17:27:16	670900	0.85	pending	2026-08-27 21:02:06.20486	\N	Person #962	0	unrecognized	\N
74651	1916	attendance	987	Person Entered	27-08-2026 17:40:00	689780	0.85	unrecognized	2026-08-27 21:03:56.042238	\N	Person #987	0	unrecognized	2026-08-27 21:04:02.438332
74660	1916	attendance	1013	Person Entered	27-08-2026 17:45:00	697108	0.85	unrecognized	2026-08-27 21:05:00.466537	\N	Person #1013	0	unrecognized	2026-08-27 21:05:07.665531
74640	1916	attendance	974	Person Entered	27-08-2026 17:31:32	677160	0.85	unrecognized	2026-08-27 21:02:33.357783	\N	Person #974	0	unrecognized	2026-08-27 21:02:54.019006
74656	1916	attendance	1001	Person Entered	27-08-2026 17:43:46	695062	0.85	unrecognized	2026-08-27 21:04:38.89286	\N	Person #1001	0	unrecognized	2026-08-27 21:04:43.279508
74641	1916	attendance	975	Person Entered	27-08-2026 17:32:58	679395	0.85	unrecognized	2026-08-27 21:02:56.234044	\N	Person #975	0	unrecognized	2026-08-27 21:03:04.397341
74642	1916	attendance	976	Person Entered	27-08-2026 17:34:47	682169	0.85	pending	2026-08-27 21:03:07.967137	\N	Person #976	0	unrecognized	\N
74652	1916	attendance	991	Person Entered	27-08-2026 17:41:23	691476	0.85	unrecognized	2026-08-27 21:04:06.426447	\N	Person #991	0	unrecognized	2026-08-27 21:04:08.660297
74661	1916	attendance	1014	Person Entered	27-08-2026 17:44:50	697230	0.85	pending	2026-08-27 21:05:08.687898	\N	Person #1014	0	unrecognized	\N
74653	1916	attendance	992	Person Entered	27-08-2026 17:41:54	692232	0.85	unrecognized	2026-08-27 21:04:10.20752	\N	Person #992	0	unrecognized	2026-08-27 21:04:15.142487
74658	1916	attendance	1007	Person Entered	27-08-2026 17:43:00	695289	0.85	unrecognized	2026-08-27 21:04:52.595869	\N	Person #1007	0	unrecognized	2026-08-27 21:04:53.48302
74650	1916	attendance	985	Person Entered	27-08-2026 17:39:00	689164	0.85	unrecognized	2026-08-27 21:03:50.566742	\N	Person #985	0	unrecognized	2026-08-27 21:03:54.613798
74659	1916	attendance	1011	Person Entered	27-08-2026 17:43:41	695507	0.85	pending	2026-08-27 21:04:56.250455	\N	Person #1011	0	unrecognized	\N
74662	1916	attendance	1016	Person Entered	27-08-2026 17:45:57	698918	0.85	pending	2026-08-27 21:05:15.010984	\N	Person #1016	0	unrecognized	\N
74664	1916	attendance	1019	Person Entered	27-08-2026 17:48:00	702415	0.85	unrecognized	2026-08-27 21:05:39.044115	\N	Person #1019	0	unrecognized	2026-08-27 21:05:42.058845
74668	1916	attendance	1026	Person Entered	27-08-2026 17:51:00	707213	0.85	unrecognized	2026-08-27 21:06:14.941671	\N	Person #1026	0	unrecognized	2026-08-27 21:06:19.194479
74663	1916	attendance	1017	Person Entered	27-08-2026 17:48:00	701466	0.85	unrecognized	2026-08-27 21:05:21.488347	\N	Person #1017	0	unrecognized	2026-08-27 21:05:34.708347
74665	1916	attendance	1020	Person Entered	27-08-2026 17:49:00	703418	0.85	unrecognized	2026-08-27 21:05:44.718114	\N	Person #1020	0	unrecognized	2026-08-27 21:05:54.681861
74670	1916	attendance	1029	Person Entered	27-08-2026 17:53:00	709519	0.85	unrecognized	2026-08-27 21:06:32.013105	\N	Person #1029	0	unrecognized	2026-08-27 21:06:38.034273
74667	1916	attendance	1022	Person Entered	27-08-2026 17:51:00	706080	0.85	unrecognized	2026-08-27 21:06:08.834056	\N	Person #1022	0	unrecognized	2026-08-27 21:06:13.260919
74674	1916	attendance	1035	Person Entered	27-08-2026 17:54:00	711066	0.85	unrecognized	2026-08-27 21:06:48.957206	\N	Person #1035	0	unrecognized	2026-08-27 21:07:01.612879
74671	1916	attendance	1030	Person Entered	27-08-2026 17:53:41	709922	0.85	unrecognized	2026-08-27 21:06:39.326985	\N	Person #1030	0	unrecognized	2026-08-27 21:06:42.052752
74672	1916	attendance	1032	Person Entered	27-08-2026 17:53:42	709958	0.85	unrecognized	2026-08-27 21:06:42.82585	\N	Person #1032	0	unrecognized	2026-08-27 21:06:44.267551
74673	1916	attendance	1033	Person Entered	27-08-2026 17:54:00	710875	0.85	unrecognized	2026-08-27 21:06:46.280889	\N	Person #1033	0	unrecognized	2026-08-27 21:06:47.753278
74232	1916	checkin	416	check_in	27-08-2026 11:37:06	145570	0.85	normal	2026-08-27 19:43:32.604562	STF-060	Muhammad Ahmed Shehzad	0.4522	recognized	2026-08-27 19:43:46.925083
74675	1916	attendance	1036	Person Entered	27-08-2026 17:54:47	711550	0.85	unrecognized	2026-08-27 21:07:02.580776	\N	Person #1036	0	unrecognized	2026-08-27 21:07:12.059804
75000	1917	breakin	2	Break In	27-08-2026 11:00:17	89815	0.85	normal	2026-08-28 06:21:13.203353	STF-037	Muhammad Fahad	0.4886	recognized	2026-08-28 06:21:13.244244
74913	1916	attendance	65	Person Entered	27-08-2026 18:02:11	723156	0.85	unrecognized	2026-08-28 06:13:54.828438	\N	Person #65	0	unrecognized	2026-08-28 06:14:14.007941
74845	1916	attendance	44	Person Entered	27-08-2026 17:54:47	712098	0.85	unrecognized	2026-08-28 06:09:55.574058	\N	Person #44	0	unrecognized	2026-08-28 06:10:16.063238
78126	1918	breakout	137	Break Out	27-08-2026 19:01:07	93696	0.85	pending	2026-08-28 10:09:34.134016	\N	Person #137	0	unrecognized	\N
74882	1917	breakin	31	Break In	27-08-2026 10:53:04	78988	0.85	normal	2026-08-28 06:12:01.990389	STF-031	Muhammad Hassan	0.6637	recognized	2026-08-28 06:12:02.016937
77778	1918	breakout	13	Break Out	27-08-2026 18:03:54	7807	0.85	unrecognized	2026-08-28 09:50:04.521852	\N	Person #13	0	unrecognized	2026-08-28 09:50:06.781338
77777	1918	breakout	12	Break Out	27-08-2026 18:03:20	6941	0.85	normal	2026-08-28 09:49:57.006054	STF-044	Zaheer Hussain	0.5205	recognized	2026-08-28 09:50:01.827197
74839	1916	attendance	38	Person Entered	27-08-2026 17:53:41	710470	0.85	unrecognized	2026-08-28 06:09:09.689546	\N	Person #38	0	unrecognized	2026-08-28 06:09:14.817716
78477	1918	breakout	244	Break Out	27-08-2026 19:57:26	178157	0.85	pending	2026-08-28 10:30:07.77495	\N	Person #244	0	unrecognized	\N
77771	1918	breakout	11	Break Out	27-08-2026 18:02:29	5593	0.85	unrecognized	2026-08-28 09:49:27.386067	\N	Person #11	0	unrecognized	2026-08-28 09:49:41.204178
74231	1916	checkin	416	check_in	27-08-2026 11:36:37	144882	0.85	normal	2026-08-27 19:43:18.035697	STF-047	Arshad Irshad	0.4429	recognized	2026-08-27 19:43:22.177242
78128	1918	breakout	138	Break Out	27-08-2026 19:02:02	94944	0.85	unrecognized	2026-08-28 10:09:36.058978	\N	Person #138	0	unrecognized	2026-08-28 10:09:47.192483
74841	1916	attendance	40	Person Entered	27-08-2026 17:53:42	710506	0.85	unrecognized	2026-08-28 06:09:16.284585	\N	Person #40	0	unrecognized	2026-08-28 06:09:19.173988
74236	1916	checkin	416	check_in	27-08-2026 11:38:17	147394	0.85	normal	2026-08-27 19:45:21.367671	STF-050	Hafeez-Ur-Rehman	0.4503	recognized	2026-08-27 19:45:23.763597
75089	1917	breakin	106	Break In	27-08-2026 11:06:37	99259	0.85	normal	2026-08-28 06:26:22.415178	STF-016	Muhammad Asad Awan	0.4919	recognized	2026-08-28 06:26:35.853794
74875	1917	breakin	27	Break In	27-08-2026 10:52:58	78795	0.85	normal	2026-08-28 06:11:30.976096	STF-004	Tanveer Hassan	0.4406	recognized	2026-08-28 06:11:34.10311
74228	1916	checkin	411	check_in	27-08-2026 11:35:44	143565	0.85	normal	2026-08-27 19:42:51.888781	STF-041	Sharjeel Abass	0.4528	recognized	2026-08-27 19:42:58.307983
75021	1917	breakin	87	Break In	27-08-2026 11:02:00	93577	0.85	normal	2026-08-28 06:22:06.872971	STF-016	Muhammad Asad Awan	0.5266	recognized	2026-08-28 06:22:07.166625
74229	1916	checkin	414	check_in	27-08-2026 11:36:04	144083	0.85	normal	2026-08-27 19:43:06.048114	STF-061	Amna Saleem	0.4718	recognized	2026-08-27 19:43:06.109524
74237	1916	checkin	423	check_in	27-08-2026 11:38:46	148138	0.85	normal	2026-08-27 19:45:28.58204	STF-064	Muhammad Arsalan	0.4467	recognized	2026-08-27 19:45:29.498574
77785	1918	breakout	14	Break Out	27-08-2026 18:04:47	9102	0.85	unrecognized	2026-08-28 09:50:20.155509	\N	Person #14	0	unrecognized	2026-08-28 09:50:35.182557
77780	1918	breakout	14	Break Out	27-08-2026 18:04:38	8817	0.85	unrecognized	2026-08-28 09:50:07.760941	\N	Person #14	0	unrecognized	2026-08-28 09:50:19.782139
74904	1916	attendance	62	Person Entered	27-08-2026 18:00:56	721334	0.85	unrecognized	2026-08-28 06:13:15.584809	\N	Person #62	0	unrecognized	2026-08-28 06:13:31.445283
75006	1917	breakin	2	Break In	27-08-2026 11:01:57	92332	0.85	normal	2026-08-28 06:21:36.413434	STF-037	Muhammad Fahad	0.4576	recognized	2026-08-28 06:21:36.437879
74908	1916	attendance	63	Person Entered	27-08-2026 18:01:56	722859	0.85	unrecognized	2026-08-28 06:13:34.795844	\N	Person #63	0	unrecognized	2026-08-28 06:13:48.993625
74910	1916	attendance	64	Person Entered	27-08-2026 18:02:00	722989	0.85	pending	2026-08-28 06:13:51.603645	\N	Person #64	\N	pending	\N
74912	1916	attendance	65	Person Entered	27-08-2026 18:02:02	723030	0.85	pending	2026-08-28 06:13:53.86856	\N	Person #65	\N	pending	\N
74227	1916	checkin	410	check_in	27-08-2026 11:35:30	143234	0.85	normal	2026-08-27 19:42:45.075426	STF-054	Syed Ali Raza	0.5029	recognized	2026-08-27 19:42:46.552149
78132	1918	breakout	139	Break Out	27-08-2026 19:02:39	95948	0.85	normal	2026-08-28 10:09:47.931179	STF-018	Muhammad Qaiser Shahzad	0.4772	recognized	2026-08-28 10:09:50.493942
74844	1916	attendance	43	Person Entered	27-08-2026 17:54:00	711614	0.85	unrecognized	2026-08-28 06:09:27.250512	\N	Person #43	0	unrecognized	2026-08-28 06:09:53.58447
75007	1917	breakin	84	Break In	27-08-2026 11:01:57	92332	0.85	normal	2026-08-28 06:21:36.719379	STF-013	Muhammad Faizan	0.5319	recognized	2026-08-28 06:21:36.747302
74247	1916	checkin	435	check_in	27-08-2026 11:43:00	155188	0.85	normal	2026-08-27 19:47:14.514632	STF-042	Faraz Khan	0.4729	recognized	2026-08-27 19:47:20.269678
74230	1916	checkin	414	check_in	27-08-2026 11:36:19	144446	0.85	normal	2026-08-27 19:43:12.201958	STF-057	Zahid Ali	0.504	recognized	2026-08-27 19:43:14.505334
74976	1916	attendance	102	Person Entered	27-08-2026 18:13:59	740915	0.85	unrecognized	2026-08-28 06:19:02.261153	\N	Person #102	0	unrecognized	2026-08-28 06:19:19.833738
74953	1917	breakin	69	Break In	27-08-2026 10:56:09	83496	0.85	normal	2026-08-28 06:16:45.308217	STF-016	Muhammad Asad Awan	0.4415	recognized	2026-08-28 06:17:39.766129
78478	1918	breakout	245	Break Out	27-08-2026 19:58:04	179046	0.85	normal	2026-08-28 10:30:11.158518	STF-046	Usman Babar	0.4449	recognized	2026-08-28 10:30:14.989905
78831	1918	breakout	328	Break Out	27-08-2026 16:20:29	209720	0.85	normal	2026-08-28 10:47:34.491146	STF-011	Syed Shoaib Ahmad Alvi	0.4488	recognized	2026-08-28 10:47:37.676046
75033	1916	attendance	119	Person Entered	27-08-2026 18:16:00	745169	0.85	unrecognized	2026-08-28 06:22:50.251585	\N	Person #119	0	unrecognized	2026-08-28 06:23:08.91383
75066	1916	attendance	128	Person Entered	27-08-2026 18:32:19	768418	0.85	unrecognized	2026-08-28 06:24:47.014028	\N	Person #128	0	unrecognized	2026-08-28 06:25:06.987838
75094	1917	breakin	114	Break In	27-08-2026 11:06:38	99351	0.85	normal	2026-08-28 06:26:41.709346	STF-004	Tanveer Hassan	0.4583	recognized	2026-08-28 06:26:41.745251
75016	1917	breakin	87	Break In	27-08-2026 11:02:32	93153	0.85	normal	2026-08-28 06:21:57.114149	STF-033	Raza Abbas	0.5302	recognized	2026-08-28 06:22:01.508263
75060	1916	attendance	127	Person Entered	27-08-2026 18:29:32	764244	0.85	unrecognized	2026-08-28 06:24:30.751869	\N	Person #127	0	unrecognized	2026-08-28 06:24:40.270823
75115	1917	breakin	59	Break In	27-08-2026 14:06:24	11773	0.85	normal	2026-08-28 06:28:20.494165	STF-025	Farhan Virk	0.4405	recognized	2026-08-28 06:28:24.863157
75102	1917	breakin	121	Break In	27-08-2026 11:07:11	100162	0.85	normal	2026-08-28 06:27:03.194411	STF-016	Muhammad Asad Awan	0.4749	recognized	2026-08-28 06:27:13.912378
75101	1917	breakin	118	Break In	27-08-2026 11:07:15	100138	0.85	normal	2026-08-28 06:26:58.205698	STF-037	Muhammad Fahad	0.4741	recognized	2026-08-28 06:27:48.036971
74676	1916	attendance	1038	Person Entered	27-08-2026 17:54:53	712303	0.85	pending	2026-08-27 21:07:13.606935	\N	Person #1038	0	unrecognized	\N
74984	1917	breakin	73	Break In	27-08-2026 10:57:04	84998	0.85	normal	2026-08-28 06:20:01.820157	STF-045	Zohaib Ali Chaudhary	0.4655	recognized	2026-08-28 06:20:02.300303
74240	1916	checkin	427	check_in	27-08-2026 11:39:15	148839	0.85	normal	2026-08-27 19:45:51.00209	STF-059	Muhammad Rehan	0.4786	recognized	2026-08-27 19:45:58.689688
76203	1916	attendance	554	Person Entered	27-08-2026 21:06:01	999022	0.85	pending	2026-08-28 07:49:15.679392	\N	Person #554	\N	pending	\N
74242	1916	checkin	429	check_in	27-08-2026 11:41:06	151648	0.85	normal	2026-08-27 19:46:21.092789	STF-063	Muhammad Huzaifah	0.4463	recognized	2026-08-27 19:46:21.529365
74235	1916	checkin	421	check_in	27-08-2026 11:37:38	146436	0.85	normal	2026-08-27 19:44:31.805938	STF-062	Shahbaz Hussain	0.4539	recognized	2026-08-27 19:44:33.573797
77773	1918	breakout	4	Break Out	27-08-2026 10:37:00	55233	0.85	unrecognized	2026-08-28 09:49:34.309903	\N	Person #4	0	unrecognized	2026-08-28 09:49:49.2303
78146	1918	breakout	123	Break Out	27-08-2026 14:41:33	61304	0.85	normal	2026-08-28 10:10:17.186012	STF-010	Faraz Younas	0.4515	recognized	2026-08-28 10:10:18.882827
77781	1918	breakout	6	Break Out	27-08-2026 10:41:12	56710	0.85	normal	2026-08-28 09:50:09.754998	STF-013	Muhammad Faizan	0.4471	recognized	2026-08-28 09:50:12.649845
74905	1917	breakin	16	Break In	27-08-2026 14:01:18	4170	0.85	normal	2026-08-28 06:13:15.77606	STF-034	Muhammad Laeeq	0.4771	recognized	2026-08-28 06:13:15.793014
74677	1916	attendance	1041	Person Entered	27-08-2026 17:55:00	712339	0.85	unrecognized	2026-08-27 21:07:15.071505	\N	Person #1041	0	unrecognized	2026-08-27 21:07:18.054814
74966	1917	breakin	29	Break In	27-08-2026 14:04:08	8387	0.85	normal	2026-08-28 06:18:02.345992	STF-035	Hammad Shaukat	0.5267	recognized	2026-08-28 06:18:05.980945
74243	1916	checkin	430	check_in	27-08-2026 11:42:00	153806	0.85	normal	2026-08-27 19:46:27.852265	STF-055	Rizwan Butt	0.4649	recognized	2026-08-27 19:46:29.698713
74249	1916	checkin	440	check_in	27-08-2026 11:46:37	159919	0.85	normal	2026-08-27 19:47:41.288332	STF-040	Arslan Nadeem	0.4805	recognized	2026-08-27 19:47:42.095178
75046	1917	breakin	46	Break In	27-08-2026 18:06:05	14141	0.85	normal	2026-08-28 06:23:27.698327	STF-034	Muhammad Laeeq	0.5369	recognized	2026-08-28 06:23:27.748193
75067	1916	attendance	130	Person Entered	27-08-2026 18:32:20	768431	0.85	unrecognized	2026-08-28 06:24:52.589598	\N	Person #130	0	unrecognized	2026-08-28 06:25:14.740335
77772	1918	breakout	2	Break Out	27-08-2026 10:35:10	52588	0.85	unrecognized	2026-08-28 09:49:28.446813	\N	Person #2	0	unrecognized	2026-08-28 09:49:32.630693
77776	1918	breakout	5	Break Out	27-08-2026 10:40:38	55707	0.85	unrecognized	2026-08-28 09:49:50.415	\N	Person #5	0	unrecognized	2026-08-28 09:50:06.063948
74262	1916	checkin	459	check_in	27-08-2026 11:51:39	167438	0.85	normal	2026-08-27 19:48:58.955058	STF-079	Hafiz Sohail Afzal	0.4588	recognized	2026-08-27 19:49:00.370215
75002	1917	breakin	31	Break In	27-08-2026 18:00:39	5899	0.85	unrecognized	2026-08-28 06:21:15.074901	\N	Person #31	0	unrecognized	2026-08-28 06:21:37.45518
74281	1916	checkin	496	check_in	27-08-2026 12:02:15	182744	0.85	normal	2026-08-27 19:53:10.557014	STF-049	Nabi Ul Haq	0.4846	recognized	2026-08-27 19:53:13.616508
74998	1917	breakin	30	Break In	27-08-2026 18:00:30	5728	0.85	unrecognized	2026-08-28 06:21:11.672005	\N	Person #30	0	unrecognized	2026-08-28 06:21:14.177684
74311	1916	checkin	519	check_in	27-08-2026 12:12:42	198383	0.85	normal	2026-08-27 19:57:31.470812	STF-034	Muhammad Laeeq	0.4469	recognized	2026-08-27 19:57:38.073286
74328	1916	checkin	552	check_in	27-08-2026 12:26:18	219430	0.85	normal	2026-08-27 20:02:17.661535	STF-026	Syed Zeeshan Ali	0.4993	recognized	2026-08-27 20:02:17.677188
74339	1916	checkin	568	check_in	27-08-2026 12:34:41	231425	0.85	normal	2026-08-27 20:04:21.456461	STF-005	Muhammad Ayaz Hussain	0.443	recognized	2026-08-27 20:04:23.415252
74872	1916	attendance	54	Person Entered	27-08-2026 17:57:33	716293	0.85	unrecognized	2026-08-28 06:11:13.380534	\N	Person #54	0	unrecognized	2026-08-28 06:11:34.330744
74942	1917	breakin	67	Break In	27-08-2026 10:55:57	83317	0.85	normal	2026-08-28 06:15:59.210403	STF-013	Muhammad Faizan	0.6462	recognized	2026-08-28 06:15:59.240834
75012	1917	breakin	33	Break In	27-08-2026 18:02:31	8735	0.85	normal	2026-08-28 06:21:44.567818	STF-034	Muhammad Laeeq	0.5314	recognized	2026-08-28 06:21:48.037584
74366	1916	checkin	600	check_in	27-08-2026 12:55:26	263139	0.85	normal	2026-08-27 20:09:32.926715	STF-051	Shakir Khan	0.4551	recognized	2026-08-27 20:09:33.97645
74373	1916	checkin	610	check_in	27-08-2026 12:55:38	263401	0.85	normal	2026-08-27 20:10:09.747196	STF-074	Abdullah Abdul Razzaq	0.4419	recognized	2026-08-27 20:10:15.47234
78133	1918	breakout	120	Break Out	27-08-2026 14:40:57	60370	0.85	normal	2026-08-28 10:09:49.807137	STF-050	Hafeez-Ur-Rehman	0.4458	recognized	2026-08-28 10:09:52.698595
75047	1917	breakin	48	Break In	27-08-2026 18:07:09	15595	0.85	unrecognized	2026-08-28 06:23:35.042186	\N	Person #48	0	unrecognized	2026-08-28 06:23:52.102982
78147	1918	breakout	125	Break Out	27-08-2026 14:42:21	62437	0.85	unrecognized	2026-08-28 10:10:22.423839	\N	Person #125	0	unrecognized	2026-08-28 10:10:36.866383
78143	1918	breakout	122	Break Out	27-08-2026 14:41:23	60993	0.85	normal	2026-08-28 10:10:10.302684	STF-008	Muhammad Shoaib	0.4645	recognized	2026-08-28 10:10:14.752365
78483	1918	breakout	235	Break Out	27-08-2026 15:26:36	128893	0.85	normal	2026-08-28 10:30:32.118331	STF-034	Muhammad Laeeq	0.4511	recognized	2026-08-28 10:30:32.623573
78485	1918	breakout	236	Break Out	27-08-2026 15:27:05	129597	0.85	normal	2026-08-28 10:30:35.170474	STF-010	Faraz Younas	0.5536	recognized	2026-08-28 10:30:38.061073
74978	1917	breakin	55	Break In	27-08-2026 10:56:55	84392	0.85	normal	2026-08-28 06:19:17.1656	STF-004	Tanveer Hassan	0.463	recognized	2026-08-28 06:19:52.872786
75009	1917	breakin	32	Break In	27-08-2026 18:02:14	8324	0.85	normal	2026-08-28 06:21:39.063763	STF-022	Mubashir Ishaq	0.4716	recognized	2026-08-28 06:21:41.670103
75019	1917	breakin	35	Break In	27-08-2026 18:03:11	9778	0.85	normal	2026-08-28 06:22:03.412481	STF-044	Zaheer Hussain	0.5634	recognized	2026-08-28 06:22:03.434421
75037	1917	breakin	43	Break In	27-08-2026 18:04:22	11556	0.85	normal	2026-08-28 06:23:10.338	STF-022	Mubashir Ishaq	0.6073	recognized	2026-08-28 06:23:10.361938
75045	1917	breakin	45	Break In	27-08-2026 18:04:55	12337	0.85	unrecognized	2026-08-28 06:23:21.878189	\N	Person #45	0	unrecognized	2026-08-28 06:23:25.380688
75087	1916	attendance	134	Person Entered	27-08-2026 18:35:56	773880	0.85	unrecognized	2026-08-28 06:26:20.615539	\N	Person #134	0	unrecognized	2026-08-28 06:26:21.524628
75116	1916	attendance	152	Person Entered	27-08-2026 18:46:13	789249	0.85	unrecognized	2026-08-28 06:28:33.954438	\N	Person #152	0	unrecognized	2026-08-28 06:28:53.970771
75137	1916	attendance	170	Person Entered	27-08-2026 19:06:02	819030	0.85	unrecognized	2026-08-28 06:31:06.537941	\N	Person #170	0	unrecognized	2026-08-28 06:31:10.355434
75131	1916	attendance	163	Person Entered	27-08-2026 19:01:46	812587	0.85	unrecognized	2026-08-28 06:30:27.415908	\N	Person #163	0	unrecognized	2026-08-28 06:30:50.008447
75135	1916	attendance	168	Person Entered	27-08-2026 19:05:45	818616	0.85	pending	2026-08-28 06:31:03.782648	\N	Person #168	\N	pending	\N
75179	1916	attendance	211	Person Entered	27-08-2026 19:29:15	853871	0.85	pending	2026-08-28 06:35:17.384592	\N	Person #211	0	unrecognized	\N
74685	1916	attendance	1054	Person Entered	27-08-2026 18:00:34	720786	0.85	unrecognized	2026-08-27 21:08:38.568072	\N	Person #1054	0	unrecognized	2026-08-27 21:08:46.69849
74678	1916	attendance	1044	Person Entered	27-08-2026 17:55:45	713013	0.85	unrecognized	2026-08-27 21:07:20.349728	\N	Person #1044	0	unrecognized	2026-08-27 21:07:29.970655
74715	1916	attendance	1106	Person Entered	27-08-2026 18:15:10	742687	0.85	unrecognized	2026-08-27 21:12:52.868859	\N	Person #1106	0	unrecognized	2026-08-27 21:13:01.839147
74680	1916	attendance	1046	Person Entered	27-08-2026 17:57:33	715745	0.85	unrecognized	2026-08-27 21:07:41.547463	\N	Person #1046	0	unrecognized	2026-08-27 21:07:51.443924
74712	1916	attendance	1100	Person Entered	27-08-2026 18:14:39	741895	0.85	unrecognized	2026-08-27 21:12:36.234283	\N	Person #1100	0	unrecognized	2026-08-27 21:12:48.069387
74702	1916	attendance	1085	Person Entered	27-08-2026 18:05:50	728729	0.85	unrecognized	2026-08-27 21:10:39.67929	\N	Person #1085	0	unrecognized	2026-08-27 21:10:41.25036
74713	1916	attendance	1102	Person Entered	27-08-2026 18:14:59	742457	0.85	pending	2026-08-27 21:12:49.508209	\N	Person #1102	\N	pending	\N
74689	1916	attendance	1057	Person Entered	27-08-2026 18:01:49	722608	0.85	unrecognized	2026-08-27 21:08:59.07821	\N	Person #1057	0	unrecognized	2026-08-27 21:09:08.779291
74693	1916	attendance	1063	Person Entered	27-08-2026 18:01:58	722895	0.85	unrecognized	2026-08-27 21:09:34.34474	\N	Person #1063	0	unrecognized	2026-08-27 21:09:45.647528
74692	1916	attendance	1061	Person Entered	27-08-2026 18:01:54	722802	0.85	unrecognized	2026-08-27 21:09:21.743243	\N	Person #1061	0	unrecognized	2026-08-27 21:09:33.54861
74681	1916	attendance	1049	Person Entered	27-08-2026 17:57:39	716435	0.85	unrecognized	2026-08-27 21:07:53.477232	\N	Person #1049	0	unrecognized	2026-08-27 21:07:56.018306
74682	1916	attendance	1050	Person Entered	27-08-2026 17:58:00	716649	0.85	unrecognized	2026-08-27 21:07:57.170142	\N	Person #1050	0	unrecognized	2026-08-27 21:08:05.437558
74703	1916	attendance	1086	Person Entered	27-08-2026 18:06:40	729946	0.85	unrecognized	2026-08-27 21:10:43.728621	\N	Person #1086	0	unrecognized	2026-08-27 21:10:51.581817
74683	1916	attendance	1051	Person Entered	27-08-2026 17:58:00	717172	0.85	unrecognized	2026-08-27 21:08:06.704149	\N	Person #1051	0	unrecognized	2026-08-27 21:08:23.150687
74699	1916	attendance	1079	Person Entered	27-08-2026 18:03:45	725011	0.85	unrecognized	2026-08-27 21:10:09.515981	\N	Person #1079	0	unrecognized	2026-08-27 21:10:17.071291
74711	1916	attendance	1099	Person Entered	27-08-2026 18:14:27	741650	0.85	unrecognized	2026-08-27 21:12:17.001667	\N	Person #1099	0	unrecognized	2026-08-27 21:12:18.562688
74690	1916	attendance	1059	Person Entered	27-08-2026 18:02:00	722759	0.85	unrecognized	2026-08-27 21:09:10.234162	\N	Person #1059	0	unrecognized	2026-08-27 21:09:18.586875
74706	1916	attendance	1088	Person Entered	27-08-2026 18:11:42	737495	0.85	unrecognized	2026-08-27 21:11:15.147064	\N	Person #1088	0	unrecognized	2026-08-27 21:11:23.09009
74700	1916	attendance	1081	Person Entered	27-08-2026 18:05:43	728506	0.85	unrecognized	2026-08-27 21:10:20.549415	\N	Person #1081	0	unrecognized	2026-08-27 21:10:30.493352
74696	1916	attendance	1068	Person Entered	27-08-2026 18:02:36	723837	0.85	unrecognized	2026-08-27 21:09:57.303817	\N	Person #1068	0	unrecognized	2026-08-27 21:10:02.061625
74697	1916	attendance	1073	Person Entered	27-08-2026 18:02:59	724467	0.85	pending	2026-08-27 21:10:04.856286	\N	Person #1073	\N	pending	\N
74679	1916	attendance	1045	Person Entered	27-08-2026 17:55:54	713237	0.85	unrecognized	2026-08-27 21:07:30.879095	\N	Person #1045	0	unrecognized	2026-08-27 21:07:38.868563
74698	1916	attendance	1076	Person Entered	27-08-2026 18:03:08	724679	0.85	pending	2026-08-27 21:10:07.320669	\N	Person #1076	\N	pending	\N
74694	1916	attendance	1065	Person Entered	27-08-2026 18:02:31	723744	0.85	unrecognized	2026-08-27 21:09:47.334937	\N	Person #1065	0	unrecognized	2026-08-27 21:09:50.389523
74695	1916	attendance	1067	Person Entered	27-08-2026 18:02:33	723789	0.85	unrecognized	2026-08-27 21:09:51.331329	\N	Person #1067	0	unrecognized	2026-08-27 21:09:56.563048
74684	1916	attendance	1052	Person Entered	27-08-2026 17:59:00	718357	0.85	unrecognized	2026-08-27 21:08:24.862063	\N	Person #1052	0	unrecognized	2026-08-27 21:08:36.00211
74686	1916	attendance	1055	Person Entered	27-08-2026 18:01:35	722311	0.85	unrecognized	2026-08-27 21:08:48.725795	\N	Person #1055	0	unrecognized	2026-08-27 21:08:55.829028
74687	1916	attendance	1056	Person Entered	27-08-2026 18:01:38	722441	0.85	pending	2026-08-27 21:08:57.26805	\N	Person #1056	\N	pending	\N
74691	1916	attendance	1060	Person Entered	27-08-2026 18:01:54	722773	0.85	unrecognized	2026-08-27 21:09:13.005678	\N	Person #1060	0	unrecognized	2026-08-27 21:09:31.768014
74688	1916	attendance	1057	Person Entered	27-08-2026 18:01:40	722482	0.85	pending	2026-08-27 21:08:58.457605	\N	Person #1057	\N	pending	\N
74701	1916	attendance	1083	Person Entered	27-08-2026 18:05:49	728683	0.85	unrecognized	2026-08-27 21:10:31.294852	\N	Person #1083	0	unrecognized	2026-08-27 21:10:39.360785
74705	1916	attendance	1087	Person Entered	27-08-2026 18:10:40	735951	0.85	unrecognized	2026-08-27 21:11:06.234144	\N	Person #1087	0	unrecognized	2026-08-27 21:11:11.794962
74710	1916	attendance	1095	Person Entered	27-08-2026 18:14:52	741358	0.85	unrecognized	2026-08-27 21:11:47.388163	\N	Person #1095	0	unrecognized	2026-08-27 21:12:35.136842
74704	1916	attendance	1086	Person Entered	27-08-2026 18:07:22	730986	0.85	unrecognized	2026-08-27 21:10:53.209296	\N	Person #1086	0	unrecognized	2026-08-27 21:11:01.869612
74708	1916	attendance	1093	Person Entered	27-08-2026 18:13:35	740316	0.85	unrecognized	2026-08-27 21:11:31.770988	\N	Person #1093	0	unrecognized	2026-08-27 21:11:36.937018
74707	1916	attendance	1092	Person Entered	27-08-2026 18:13:33	739880	0.85	unrecognized	2026-08-27 21:11:26.756476	\N	Person #1092	0	unrecognized	2026-08-27 21:11:30.761106
74716	1916	attendance	1107	Person Entered	27-08-2026 18:15:16	742893	0.85	pending	2026-08-27 21:13:03.365716	\N	Person #1107	\N	pending	\N
74709	1916	attendance	1094	Person Entered	27-08-2026 18:13:37	740367	0.85	unrecognized	2026-08-27 21:11:37.421928	\N	Person #1094	0	unrecognized	2026-08-27 21:11:45.758005
74714	1916	attendance	1105	Person Entered	27-08-2026 18:15:00	742471	0.85	unrecognized	2026-08-27 21:12:50.011927	\N	Person #1105	0	unrecognized	2026-08-27 21:12:51.521734
74717	1916	attendance	1109	Person Entered	27-08-2026 18:15:18	742923	0.85	unrecognized	2026-08-27 21:13:04.437982	\N	Person #1109	0	unrecognized	2026-08-27 21:13:06.655778
74718	1916	attendance	1110	Person Entered	27-08-2026 18:16:10	744086	0.85	unrecognized	2026-08-27 21:13:08.566465	\N	Person #1110	0	unrecognized	2026-08-27 21:13:25.902329
74720	1916	attendance	1112	Person Entered	27-08-2026 18:22:22	753531	0.85	unrecognized	2026-08-27 21:13:44.161577	\N	Person #1112	0	unrecognized	2026-08-27 21:13:44.582726
74719	1916	attendance	1111	Person Entered	27-08-2026 18:16:00	744621	0.85	unrecognized	2026-08-27 21:13:26.9276	\N	Person #1111	0	unrecognized	2026-08-27 21:13:36.537054
74721	1916	attendance	1114	Person Entered	27-08-2026 18:22:24	753544	0.85	unrecognized	2026-08-27 21:13:45.161664	\N	Person #1114	0	unrecognized	2026-08-27 21:13:54.033275
74359	1916	checkin	594	check_in	27-08-2026 12:46:32	249773	0.85	normal	2026-08-27 20:07:30.474427	STF-020	Syed Jahazaib Ahmad Alvi	0.4788	recognized	2026-08-27 20:07:32.943855
74747	1916	attendance	1166	Person Entered	27-08-2026 19:05:57	818913	0.85	unrecognized	2026-08-27 21:18:07.972708	\N	Person #1166	0	unrecognized	2026-08-27 21:18:09.712663
74736	1916	attendance	1144	Person Entered	27-08-2026 18:46:13	788701	0.85	unrecognized	2026-08-27 21:16:34.158308	\N	Person #1144	0	unrecognized	2026-08-27 21:16:43.655344
74733	1916	attendance	1132	Person Entered	27-08-2026 18:38:27	777624	0.85	unrecognized	2026-08-27 21:15:50.060849	\N	Person #1132	0	unrecognized	2026-08-27 21:15:58.662057
74738	1916	attendance	1148	Person Entered	27-08-2026 18:47:36	791343	0.85	unrecognized	2026-08-27 21:16:54.107898	\N	Person #1148	0	unrecognized	2026-08-27 21:17:03.71375
74739	1916	attendance	1149	Person Entered	27-08-2026 18:52:58	799400	0.85	unrecognized	2026-08-27 21:17:12.343747	\N	Person #1149	0	unrecognized	2026-08-27 21:17:17.885403
74723	1916	attendance	1118	Person Entered	27-08-2026 18:26:18	759373	0.85	unrecognized	2026-08-27 21:14:09.883148	\N	Person #1118	0	unrecognized	2026-08-27 21:14:21.060987
74740	1916	attendance	1150	Person Entered	27-08-2026 18:58:25	807621	0.85	pending	2026-08-27 21:17:27.027713	\N	Person #1150	0	unrecognized	\N
74725	1916	attendance	1120	Person Entered	27-08-2026 18:31:57	767870	0.85	unrecognized	2026-08-27 21:14:36.127078	\N	Person #1120	0	unrecognized	2026-08-27 21:14:47.503238
74729	1916	attendance	1125	Person Entered	27-08-2026 18:35:08	772659	0.85	unrecognized	2026-08-27 21:15:20.677459	\N	Person #1125	0	unrecognized	2026-08-27 21:15:25.640757
74737	1916	attendance	1147	Person Entered	27-08-2026 18:47:18	790351	0.85	unrecognized	2026-08-27 21:16:46.082295	\N	Person #1147	0	unrecognized	2026-08-27 21:16:52.820386
74730	1916	attendance	1126	Person Entered	27-08-2026 18:35:34	773332	0.85	unrecognized	2026-08-27 21:15:26.985491	\N	Person #1126	0	unrecognized	2026-08-27 21:15:27.456867
74727	1916	attendance	1123	Person Entered	27-08-2026 18:32:36	768827	0.85	unrecognized	2026-08-27 21:14:53.72782	\N	Person #1123	0	unrecognized	2026-08-27 21:15:06.638934
74735	1916	attendance	1142	Person Entered	27-08-2026 18:44:00	785457	0.85	unrecognized	2026-08-27 21:16:19.523951	\N	Person #1142	0	unrecognized	2026-08-27 21:16:30.620224
74750	1916	attendance	1180	Person Entered	27-08-2026 19:13:00	829017	0.85	unrecognized	2026-08-27 21:18:38.997486	\N	Person #1180	0	unrecognized	2026-08-27 21:18:39.456478
74728	1916	attendance	1123	Person Entered	27-08-2026 18:33:31	770216	0.85	unrecognized	2026-08-27 21:15:08.243149	\N	Person #1123	0	unrecognized	2026-08-27 21:15:17.140898
74741	1916	attendance	1154	Person Entered	27-08-2026 19:00:04	810042	0.85	unrecognized	2026-08-27 21:17:31.935208	\N	Person #1154	0	unrecognized	2026-08-27 21:17:37.865251
74726	1916	attendance	1122	Person Entered	27-08-2026 18:31:58	767883	0.85	unrecognized	2026-08-27 21:14:39.119706	\N	Person #1122	0	unrecognized	2026-08-27 21:14:51.871984
74724	1916	attendance	1119	Person Entered	27-08-2026 18:29:10	763696	0.85	unrecognized	2026-08-27 21:14:25.2348	\N	Person #1119	0	unrecognized	2026-08-27 21:14:31.35074
74731	1916	attendance	1127	Person Entered	27-08-2026 18:35:36	773345	0.85	unrecognized	2026-08-27 21:15:28.001787	\N	Person #1127	0	unrecognized	2026-08-27 21:15:36.52442
74722	1916	attendance	1116	Person Entered	27-08-2026 18:23:57	755859	0.85	unrecognized	2026-08-27 21:13:57.296971	\N	Person #1116	0	unrecognized	2026-08-27 21:14:06.405173
74758	1916	attendance	1192	Person Entered	27-08-2026 19:18:28	837605	0.85	unrecognized	2026-08-27 21:19:36.252738	\N	Person #1192	0	unrecognized	2026-08-27 21:19:48.120391
74734	1916	attendance	1133	Person Entered	27-08-2026 18:41:06	781592	0.85	unrecognized	2026-08-27 21:16:02.42505	\N	Person #1133	0	unrecognized	2026-08-27 21:16:12.938576
74732	1916	attendance	1129	Person Entered	27-08-2026 18:37:16	775853	0.85	unrecognized	2026-08-27 21:15:39.287692	\N	Person #1129	0	unrecognized	2026-08-27 21:15:47.559441
74745	1916	attendance	1162	Person Entered	27-08-2026 19:05:40	818482	0.85	unrecognized	2026-08-27 21:18:03.895519	\N	Person #1162	0	unrecognized	2026-08-27 21:18:06.050754
74746	1916	attendance	1163	Person Entered	27-08-2026 19:05:56	818899	0.85	pending	2026-08-27 21:18:07.485187	\N	Person #1163	\N	pending	\N
74752	1916	attendance	1183	Person Entered	27-08-2026 19:13:17	829915	0.85	pending	2026-08-27 21:18:41.878885	\N	Person #1183	0	unrecognized	\N
74756	1916	attendance	1189	Person Entered	27-08-2026 19:14:45	832091	0.85	unrecognized	2026-08-27 21:19:17.2955	\N	Person #1189	0	unrecognized	2026-08-27 21:19:21.189664
74749	1916	attendance	1175	Person Entered	27-08-2026 19:12:30	828718	0.85	unrecognized	2026-08-27 21:18:28.169131	\N	Person #1175	0	unrecognized	2026-08-27 21:18:31.071776
74742	1916	attendance	1155	Person Entered	27-08-2026 19:01:24	812039	0.85	unrecognized	2026-08-27 21:17:40.616332	\N	Person #1155	0	unrecognized	2026-08-27 21:17:51.958846
74743	1916	attendance	1158	Person Entered	27-08-2026 19:04:45	817106	0.85	unrecognized	2026-08-27 21:17:58.959329	\N	Person #1158	0	unrecognized	2026-08-27 21:17:59.044236
74744	1916	attendance	1160	Person Entered	27-08-2026 19:05:23	818068	0.85	pending	2026-08-27 21:18:02.071126	\N	Person #1160	\N	pending	\N
74755	1916	attendance	1187	Person Entered	27-08-2026 19:14:00	831178	0.85	unrecognized	2026-08-27 21:19:01.071598	\N	Person #1187	0	unrecognized	2026-08-27 21:19:14.513444
74748	1916	attendance	1173	Person Entered	27-08-2026 19:12:31	828708	0.85	unrecognized	2026-08-27 21:18:26.502162	\N	Person #1173	0	unrecognized	2026-08-27 21:18:37.35728
74757	1916	attendance	1190	Person Entered	27-08-2026 19:18:00	836693	0.85	unrecognized	2026-08-27 21:19:26.467485	\N	Person #1190	0	unrecognized	2026-08-27 21:19:33.506874
74751	1916	attendance	1181	Person Entered	27-08-2026 19:13:00	829908	0.85	unrecognized	2026-08-27 21:18:41.53923	\N	Person #1181	0	unrecognized	2026-08-27 21:18:46.304316
74759	1916	attendance	1193	Person Entered	27-08-2026 19:18:40	837984	0.85	pending	2026-08-27 21:19:48.967586	\N	Person #1193	0	unrecognized	\N
74753	1916	attendance	1184	Person Entered	27-08-2026 19:13:00	830000	0.85	unrecognized	2026-08-27 21:18:47.819244	\N	Person #1184	0	unrecognized	2026-08-27 21:18:58.368898
74754	1916	attendance	1185	Person Entered	27-08-2026 19:14:07	831155	0.85	pending	2026-08-27 21:19:00.191198	\N	Person #1185	\N	pending	\N
74760	1916	attendance	1194	Person Entered	27-08-2026 19:18:43	838057	0.85	unrecognized	2026-08-27 21:19:50.756749	\N	Person #1194	0	unrecognized	2026-08-27 21:19:51.554911
74761	1916	attendance	1196	Person Entered	27-08-2026 19:22:44	844044	0.85	unrecognized	2026-08-27 21:19:59.779837	\N	Person #1196	0	unrecognized	2026-08-27 21:20:04.504957
74762	1916	attendance	1201	Person Entered	27-08-2026 19:28:39	852966	0.85	unrecognized	2026-08-27 21:20:16.135775	\N	Person #1201	0	unrecognized	2026-08-27 21:20:16.304062
75312	1917	breakin	114	Break In	27-08-2026 14:13:37	22636	0.85	normal	2026-08-28 06:44:12.783184	STF-024	Arsalan Khan	0.4703	recognized	2026-08-28 06:44:13.693908
74768	1916	attendance	2	Person Entered	27-08-2026 17:42:00	693569	0.85	unrecognized	2026-08-28 06:04:18.435352	\N	Person #2	0	unrecognized	2026-08-28 06:05:32.047482
74769	1916	attendance	4	Person Entered	27-08-2026 17:43:13	694823	0.85	pending	2026-08-28 06:05:35.900081	\N	Person #4	\N	pending	\N
74770	1916	attendance	9	Person Entered	27-08-2026 17:43:46	695610	0.85	unrecognized	2026-08-28 06:05:40.557148	\N	Person #9	0	unrecognized	2026-08-28 06:05:45.353573
74413	1916	checkin	660	check_in	27-08-2026 13:31:19	316367	0.85	normal	2026-08-27 20:17:44.938624	STF-083	Ibrahim Tariq	0.4437	recognized	2026-08-27 20:17:45.498981
74775	1916	attendance	19	Person Entered	27-08-2026 17:44:03	696055	0.85	pending	2026-08-28 06:06:04.879327	\N	Person #19	0	unrecognized	\N
78491	1918	breakout	250	Break Out	27-08-2026 20:02:44	186121	0.85	pending	2026-08-28 10:30:43.489904	\N	Person #250	0	unrecognized	\N
78127	1918	breakout	105	Break Out	27-08-2026 11:23:13	119787	0.85	unrecognized	2026-08-28 10:09:35.427421	\N	Person #105	0	unrecognized	2026-08-28 10:09:36.04302
74440	1916	checkin	695	check_in	27-08-2026 14:08:44	373056	0.85	normal	2026-08-27 20:24:18.706458	STF-030	Dildar Ahmed	0.4905	recognized	2026-08-27 20:24:24.287258
74843	1916	attendance	41	Person Entered	27-08-2026 17:54:00	711423	0.85	unrecognized	2026-08-28 06:09:22.487451	\N	Person #41	0	unrecognized	2026-08-28 06:09:24.966449
75313	1917	breakin	112	Break In	27-08-2026 14:13:38	22660	0.85	normal	2026-08-28 06:44:19.140155	STF-025	Farhan Virk	0.5012	recognized	2026-08-28 06:44:19.158107
74792	1917	breakin	3	Break In	27-08-2026 10:40:16	59788	0.85	normal	2026-08-28 06:06:53.572032	STF-013	Muhammad Faizan	0.4939	recognized	2026-08-28 06:06:55.560443
74782	1916	attendance	24	Person Entered	27-08-2026 17:46:19	699466	0.85	pending	2026-08-28 06:06:39.903019	\N	Person #24	0	unrecognized	\N
74776	1916	attendance	21	Person Entered	27-08-2026 17:45:00	697656	0.85	unrecognized	2026-08-28 06:06:13.88281	\N	Person #21	0	unrecognized	2026-08-28 06:06:27.705553
74798	1917	breakin	2	Break In	27-08-2026 10:41:38	61852	0.85	normal	2026-08-28 06:07:10.763121	STF-037	Muhammad Fahad	0.5916	recognized	2026-08-28 06:07:10.783068
74808	1917	breakin	7	Break In	27-08-2026 13:59:06	847	0.85	normal	2026-08-28 06:07:39.619123	STF-034	Muhammad Laeeq	0.46	recognized	2026-08-28 06:07:43.283586
78493	1918	breakout	251	Break Out	27-08-2026 20:03:05	186556	0.85	unrecognized	2026-08-28 10:30:46.911124	\N	Person #251	0	unrecognized	2026-08-28 10:30:56.973523
78136	1918	breakout	108	Break Out	27-08-2026 11:24:00	121962	0.85	normal	2026-08-28 10:09:55.098348	STF-013	Muhammad Faizan	0.4616	recognized	2026-08-28 10:09:57.984916
78134	1918	breakout	107	Break Out	27-08-2026 11:24:17	121359	0.85	normal	2026-08-28 10:09:50.469009	STF-035	Hammad Shaukat	0.5619	recognized	2026-08-28 10:09:51.949924
74771	1916	attendance	10	Person Entered	27-08-2026 17:43:00	695685	0.85	unrecognized	2026-08-28 06:05:46.666847	\N	Person #10	0	unrecognized	2026-08-28 06:05:54.453804
75957	1917	breakin	293	Break In	27-08-2026 19:13:01	114504	0.85	normal	2026-08-28 07:28:14.880997	STF-013	Muhammad Faizan	0.6534	recognized	2026-08-28 07:28:20.891845
74906	1917	breakin	53	Break In	27-08-2026 10:55:20	82357	0.85	normal	2026-08-28 06:13:20.931785	STF-016	Muhammad Asad Awan	0.541	recognized	2026-08-28 06:13:28.12333
74801	1917	breakin	2	Break In	27-08-2026 10:42:13	62611	0.85	normal	2026-08-28 06:07:18.574387	STF-037	Muhammad Fahad	0.5076	recognized	2026-08-28 06:07:28.068565
74774	1916	attendance	15	Person Entered	27-08-2026 17:43:00	695837	0.85	unrecognized	2026-08-28 06:05:56.351346	\N	Person #15	0	unrecognized	2026-08-28 06:05:57.833554
78138	1918	breakout	109	Break Out	27-08-2026 11:25:00	122428	0.85	unrecognized	2026-08-28 10:09:59.882292	\N	Person #109	0	unrecognized	2026-08-28 10:10:00.302324
78139	1918	breakout	110	Break Out	27-08-2026 11:22:44	123758	0.85	pending	2026-08-28 10:10:01.21567	\N	Person #110	0	unrecognized	\N
78142	1918	breakout	113	Break Out	27-08-2026 11:26:10	124160	0.85	unrecognized	2026-08-28 10:10:08.555028	\N	Person #113	0	unrecognized	2026-08-28 10:10:12.157297
74787	1916	attendance	25	Person Entered	27-08-2026 17:48:00	702014	0.85	unrecognized	2026-08-28 06:06:48.833911	\N	Person #25	0	unrecognized	2026-08-28 06:07:12.977183
74779	1916	attendance	22	Person Entered	27-08-2026 17:45:12	697778	0.85	pending	2026-08-28 06:06:29.589455	\N	Person #22	0	unrecognized	\N
74793	1917	breakin	6	Break In	27-08-2026 13:58:54	540	0.85	normal	2026-08-28 06:06:56.007748	STF-002	Abdur Rehman	0.4519	recognized	2026-08-28 06:07:05.744318
74788	1917	breakin	2	Break In	27-08-2026 10:39:00	59046	0.85	normal	2026-08-28 06:06:49.108733	STF-037	Muhammad Fahad	0.5935	recognized	2026-08-28 06:06:49.142641
74805	1917	breakin	8	Break In	27-08-2026 10:42:20	62892	0.85	normal	2026-08-28 06:07:30.888008	STF-013	Muhammad Faizan	0.488	recognized	2026-08-28 06:07:30.918926
78484	1918	breakout	248	Break Out	27-08-2026 20:02:08	185217	0.85	pending	2026-08-28 10:30:32.776801	\N	Person #248	0	unrecognized	\N
78503	1918	breakout	259	Break Out	27-08-2026 20:04:57	189444	0.85	normal	2026-08-28 10:31:15.224886	STF-037	Muhammad Fahad	0.531	recognized	2026-08-28 10:31:15.259791
78486	1918	breakout	249	Break Out	27-08-2026 20:02:25	185492	0.85	unrecognized	2026-08-28 10:30:35.171472	\N	Person #249	0	unrecognized	2026-08-28 10:30:42.665631
78498	1918	breakout	254	Break Out	27-08-2026 20:03:19	186970	0.85	unrecognized	2026-08-28 10:31:02.442358	\N	Person #254	0	unrecognized	2026-08-28 10:31:06.578306
74800	1917	breakin	4	Break In	27-08-2026 10:42:03	62439	0.85	normal	2026-08-28 06:07:13.934367	STF-023	Syed Zubair Zulfiqar	0.519	recognized	2026-08-28 06:07:16.332041
74810	1917	breakin	10	Break In	27-08-2026 10:42:56	63780	0.85	normal	2026-08-28 06:07:40.440754	STF-023	Syed Zubair Zulfiqar	0.4873	recognized	2026-08-28 06:07:42.817971
74802	1916	attendance	27	Person Entered	27-08-2026 17:48:00	702963	0.85	unrecognized	2026-08-28 06:07:19.70454	\N	Person #27	0	unrecognized	2026-08-28 06:07:25.113462
78507	1918	breakout	262	Break Out	27-08-2026 20:05:54	190568	0.85	normal	2026-08-28 10:31:24.031646	STF-033	Raza Abbas	0.4846	recognized	2026-08-28 10:32:04.808889
74795	1917	breakin	5	Break In	27-08-2026 17:57:24	886	0.85	unrecognized	2026-08-28 06:07:04.516094	\N	Person #5	0	unrecognized	2026-08-28 06:07:39.817524
74804	1916	attendance	28	Person Entered	27-08-2026 17:49:00	703966	0.85	unrecognized	2026-08-28 06:07:29.598704	\N	Person #28	0	unrecognized	2026-08-28 06:07:47.463683
75144	1916	attendance	181	Person Entered	27-08-2026 19:12:53	829256	0.85	unrecognized	2026-08-28 06:31:38.736463	\N	Person #181	0	unrecognized	2026-08-28 06:32:00.647352
75314	1917	breakin	156	Break In	27-08-2026 11:16:19	113872	0.85	normal	2026-08-28 06:44:19.782206	STF-037	Muhammad Fahad	0.6013	recognized	2026-08-28 06:44:19.829591
74940	1917	breakin	18	Break In	27-08-2026 14:02:18	5577	0.85	normal	2026-08-28 06:15:49.323769	STF-033	Raza Abbas	0.4641	recognized	2026-08-28 06:16:09.939315
74979	1916	attendance	103	Person Entered	27-08-2026 18:14:52	741906	0.85	unrecognized	2026-08-28 06:19:22.509946	\N	Person #103	0	unrecognized	2026-08-28 06:21:05.532365
74817	1917	breakin	2	Break In	27-08-2026 10:44:29	66059	0.85	normal	2026-08-28 06:08:00.112305	STF-037	Muhammad Fahad	0.4804	recognized	2026-08-28 06:08:11.276968
74814	1917	breakin	2	Break In	27-08-2026 10:43:49	65069	0.85	normal	2026-08-28 06:07:55.057567	STF-037	Muhammad Fahad	0.4916	recognized	2026-08-28 06:07:55.518303
75010	1916	attendance	110	Person Entered	27-08-2026 18:15:21	743005	0.85	pending	2026-08-28 06:21:39.324464	\N	Person #110	\N	pending	\N
78156	1918	breakout	117	Break Out	27-08-2026 11:27:33	126213	0.85	normal	2026-08-28 10:10:53.851717	STF-033	Raza Abbas	0.4672	recognized	2026-08-28 10:11:04.20776
75958	1916	attendance	510	Person Entered	27-08-2026 21:03:15	994846	0.85	unrecognized	2026-08-28 07:28:16.809915	\N	Person #510	0	unrecognized	2026-08-28 07:28:20.449424
75167	1916	attendance	202	Person Entered	27-08-2026 19:19:05	838605	0.85	unrecognized	2026-08-28 06:34:20.34486	\N	Person #202	0	unrecognized	2026-08-28 06:34:21.665943
78149	1918	breakout	115	Break Out	27-08-2026 11:26:20	124408	0.85	unrecognized	2026-08-28 10:10:28.037041	\N	Person #115	0	unrecognized	2026-08-28 10:10:31.139656
74907	1917	breakin	13	Break In	27-08-2026 17:58:14	2258	0.85	unrecognized	2026-08-28 06:13:28.936925	\N	Person #13	0	unrecognized	2026-08-28 06:13:48.804169
77799	1918	breakout	19	Break Out	27-08-2026 14:06:07	8109	0.85	normal	2026-08-28 09:51:18.805726	STF-025	Farhan Virk	0.4723	recognized	2026-08-28 09:51:20.99468
79329	1949	attendance	1	Person Entered	28-08-2026 19:20:50	113	0.85	unrecognized	2026-08-28 14:20:52.50447	\N	Person #1	0	unrecognized	2026-08-28 14:21:07.613309
75387	1916	attendance	301	Person Entered	27-08-2026 20:15:01	922480	0.85	unrecognized	2026-08-28 06:49:50.857562	\N	Person #301	0	unrecognized	2026-08-28 06:50:09.327131
74961	1916	attendance	93	Person Entered	27-08-2026 18:06:12	729277	0.85	unrecognized	2026-08-28 06:17:14.408507	\N	Person #93	0	unrecognized	2026-08-28 06:17:17.715573
78150	1918	breakout	116	Break Out	27-08-2026 11:26:38	124813	0.85	unrecognized	2026-08-28 10:10:31.862775	\N	Person #116	0	unrecognized	2026-08-28 10:10:45.085254
79497	1951	breakout	108	Break Out	25-08-2026 19:02:25	10986	0.85	normal	2026-08-28 14:35:13.500796	STF-018	Muhammad Qaiser Shahzad	0.4767	recognized	2026-08-28 14:35:14.939721
74818	1917	breakin	11	Break In	27-08-2026 10:44:28	66076	0.85	normal	2026-08-28 06:08:02.199766	STF-013	Muhammad Faizan	0.4917	recognized	2026-08-28 06:08:05.891701
75011	1916	attendance	113	Person Entered	27-08-2026 18:15:21	743019	0.85	unrecognized	2026-08-28 06:21:40.564843	\N	Person #113	0	unrecognized	2026-08-28 06:21:43.573229
79333	1949	attendance	8	Person Entered	28-08-2026 19:22:52	3152	0.85	unrecognized	2026-08-28 14:21:39.156109	\N	Person #8	0	unrecognized	2026-08-28 14:22:00.957136
75039	1916	attendance	120	Person Entered	27-08-2026 18:22:44	754079	0.85	unrecognized	2026-08-28 06:23:18.800675	\N	Person #120	0	unrecognized	2026-08-28 06:23:19.247185
74842	1917	breakin	8	Break In	27-08-2026 13:59:58	2059	0.85	unrecognized	2026-08-28 06:09:22.094808	\N	Person #8	0	unrecognized	2026-08-28 06:10:08.26649
75148	1916	attendance	189	Person Entered	27-08-2026 19:13:00	830456	0.85	unrecognized	2026-08-28 06:32:07.929058	\N	Person #189	0	unrecognized	2026-08-28 06:32:17.162717
74963	1916	attendance	94	Person Entered	27-08-2026 18:07:02	730494	0.85	unrecognized	2026-08-28 06:17:22.00219	\N	Person #94	0	unrecognized	2026-08-28 06:17:38.33276
75090	1916	attendance	135	Person Entered	27-08-2026 18:35:58	773893	0.85	unrecognized	2026-08-28 06:26:22.595276	\N	Person #135	0	unrecognized	2026-08-28 06:26:40.659348
78154	1918	breakout	117	Break Out	27-08-2026 11:26:55	125250	0.85	unrecognized	2026-08-28 10:10:45.899372	\N	Person #117	0	unrecognized	2026-08-28 10:10:53.2228
75183	1916	attendance	213	Person Entered	27-08-2026 19:30:30	855484	0.85	unrecognized	2026-08-28 06:35:33.936554	\N	Person #213	0	unrecognized	2026-08-28 06:36:24.043971
75317	1917	breakin	160	Break In	27-08-2026 11:16:22	113942	0.85	normal	2026-08-28 06:44:56.721204	STF-016	Muhammad Asad Awan	0.4702	recognized	2026-08-28 06:45:08.465384
75158	1916	attendance	197	Person Entered	27-08-2026 19:15:07	832639	0.85	unrecognized	2026-08-28 06:33:17.965921	\N	Person #197	0	unrecognized	2026-08-28 06:33:25.850908
75149	1916	attendance	191	Person Entered	27-08-2026 19:13:39	830463	0.85	pending	2026-08-28 06:32:08.517912	\N	Person #191	0	unrecognized	\N
75171	1916	attendance	209	Person Entered	27-08-2026 19:29:02	853514	0.85	unrecognized	2026-08-28 06:34:57.168808	\N	Person #209	0	unrecognized	2026-08-28 06:35:06.236959
75185	1916	attendance	214	Person Entered	27-08-2026 19:30:23	855513	0.85	unrecognized	2026-08-28 06:35:42.334264	\N	Person #214	0	unrecognized	2026-08-28 06:36:06.912828
75350	1917	breakin	166	Break In	27-08-2026 11:16:51	114424	0.85	normal	2026-08-28 06:47:40.182585	STF-013	Muhammad Faizan	0.5245	recognized	2026-08-28 06:49:23.798298
75426	1917	breakin	142	Break In	27-08-2026 14:16:12	26517	0.85	normal	2026-08-28 06:52:42.655868	STF-025	Farhan Virk	0.5308	recognized	2026-08-28 06:52:42.676812
75423	1917	breakin	141	Break In	27-08-2026 14:16:12	26489	0.85	normal	2026-08-28 06:52:35.922098	STF-028	Noman Imran	0.4484	recognized	2026-08-28 06:52:39.569635
76017	1917	breakin	279	Break In	27-08-2026 14:33:28	52385	0.85	normal	2026-08-28 07:34:12.983922	STF-015	Liaqat Ali	0.4483	recognized	2026-08-28 07:34:26.100863
75460	1917	breakin	144	Break In	27-08-2026 14:16:46	27371	0.85	normal	2026-08-28 06:55:22.959316	STF-025	Farhan Virk	0.5051	recognized	2026-08-28 06:55:22.989236
75013	1916	attendance	114	Person Entered	27-08-2026 18:15:32	743235	0.85	unrecognized	2026-08-28 06:21:46.477681	\N	Person #114	0	unrecognized	2026-08-28 06:22:04.576346
78488	1918	breakout	211	Break Out	27-08-2026 12:18:12	202212	0.85	unrecognized	2026-08-28 10:30:40.76776	\N	Person #211	0	unrecognized	2026-08-28 10:30:42.405095
79498	1951	breakout	109	Break Out	25-08-2026 19:02:26	11013	0.85	normal	2026-08-28 14:35:15.49041	STF-033	Raza Abbas	0.4612	recognized	2026-08-28 14:35:20.905994
78159	1918	breakout	128	Break Out	27-08-2026 14:43:41	64415	0.85	unrecognized	2026-08-28 10:11:04.450858	\N	Person #128	0	unrecognized	2026-08-28 10:11:27.116154
77794	1918	breakout	14	Break Out	27-08-2026 10:45:34	63164	0.85	unrecognized	2026-08-28 09:51:00.921482	\N	Person #14	0	unrecognized	2026-08-28 09:51:19.952659
77788	1918	breakout	10	Break Out	27-08-2026 10:42:26	58560	0.85	normal	2026-08-28 09:50:34.313894	STF-013	Muhammad Faizan	0.4888	recognized	2026-08-28 09:50:38.608879
78490	1918	breakout	211	Break Out	27-08-2026 12:18:24	202551	0.85	unrecognized	2026-08-28 10:30:42.75971	\N	Person #211	0	unrecognized	2026-08-28 10:30:43.304398
78487	1918	breakout	211	Break Out	27-08-2026 12:17:00	201461	0.85	unrecognized	2026-08-28 10:30:36.764521	\N	Person #211	0	unrecognized	2026-08-28 10:30:40.099313
77792	1918	breakout	13	Break Out	27-08-2026 10:44:28	61542	0.85	unrecognized	2026-08-28 09:50:46.375642	\N	Person #13	0	unrecognized	2026-08-28 09:50:59.959393
75022	1916	attendance	115	Person Entered	27-08-2026 18:15:38	743441	0.85	pending	2026-08-28 06:22:07.204523	\N	Person #115	\N	pending	\N
74877	1916	attendance	57	Person Entered	27-08-2026 17:58:00	716983	0.85	unrecognized	2026-08-28 06:11:39.621046	\N	Person #57	0	unrecognized	2026-08-28 06:11:45.655499
77801	1918	breakout	15	Break Out	27-08-2026 10:49:41	69363	0.85	unrecognized	2026-08-28 09:51:22.835952	\N	Person #15	0	unrecognized	2026-08-28 09:51:34.81723
74919	1917	breakin	59	Break In	27-08-2026 10:55:35	82778	0.85	normal	2026-08-28 06:14:06.469929	STF-032	Muhammad Yaseen	0.5133	recognized	2026-08-28 06:14:06.538784
74853	1917	breakin	2	Break In	27-08-2026 10:51:00	76843	0.85	normal	2026-08-28 06:10:15.779398	STF-037	Muhammad Fahad	0.5124	recognized	2026-08-28 06:10:18.101116
78492	1918	breakout	211	Break Out	27-08-2026 12:18:38	202718	0.85	unrecognized	2026-08-28 10:30:43.569568	\N	Person #211	0	unrecognized	2026-08-28 10:30:45.795511
74866	1917	breakin	19	Break In	27-08-2026 10:52:00	78416	0.85	normal	2026-08-28 06:10:44.114323	STF-004	Tanveer Hassan	0.4527	recognized	2026-08-28 06:10:48.281126
74854	1917	breakin	2	Break In	27-08-2026 10:51:57	77296	0.85	normal	2026-08-28 06:10:18.795145	STF-037	Muhammad Fahad	0.5168	recognized	2026-08-28 06:10:19.149686
78495	1918	breakout	211	Break Out	27-08-2026 12:20:34	205704	0.85	normal	2026-08-28 10:30:50.495474	STF-034	Muhammad Laeeq	0.4473	recognized	2026-08-28 10:31:03.646502
75040	1917	breakin	93	Break In	27-08-2026 11:03:37	94824	0.85	normal	2026-08-28 06:23:19.158903	STF-033	Raza Abbas	0.4946	recognized	2026-08-28 06:23:19.184355
78500	1918	breakout	213	Break Out	27-08-2026 12:21:26	206999	0.85	unrecognized	2026-08-28 10:31:05.502001	\N	Person #213	0	unrecognized	2026-08-28 10:31:20.554249
78845	1918	breakout	366	Break Out	27-08-2026 20:52:18	260442	0.85	normal	2026-08-28 10:47:54.501768	STF-024	Arsalan Khan	0.4402	recognized	2026-08-28 10:48:08.231751
74865	1917	breakin	18	Break In	27-08-2026 10:52:23	77977	0.85	normal	2026-08-28 06:10:34.656692	STF-029	Abdul Rehman Sultan	0.534	recognized	2026-08-28 06:10:34.699577
74937	1916	attendance	73	Person Entered	27-08-2026 18:02:53	724292	0.85	unrecognized	2026-08-28 06:15:32.02953	\N	Person #73	0	unrecognized	2026-08-28 06:15:38.457091
78838	1918	breakout	363	Break Out	27-08-2026 20:52:17	260402	0.85	normal	2026-08-28 10:47:46.504462	STF-025	Farhan Virk	0.4505	recognized	2026-08-28 10:47:50.84985
78506	1918	breakout	213	Break Out	27-08-2026 12:22:00	207835	0.85	unrecognized	2026-08-28 10:31:21.102346	\N	Person #213	0	unrecognized	2026-08-28 10:31:37.239173
74870	1917	breakin	22	Break In	27-08-2026 10:52:00	78544	0.85	normal	2026-08-28 06:10:57.402381	STF-033	Raza Abbas	0.4527	recognized	2026-08-28 06:11:07.063233
79061	1918	breakout	436	Break Out	27-08-2026 21:10:19	287492	0.85	pending	2026-08-28 11:00:35.954631	\N	Person #436	0	unrecognized	\N
74943	1916	attendance	81	Person Entered	27-08-2026 18:03:21	725015	0.85	pending	2026-08-28 06:16:07.121799	\N	Person #81	\N	pending	\N
74965	1916	attendance	94	Person Entered	27-08-2026 18:07:44	731534	0.85	unrecognized	2026-08-28 06:17:41.059107	\N	Person #94	0	unrecognized	2026-08-28 06:17:58.97195
75048	1917	breakin	96	Break In	27-08-2026 11:03:41	94925	0.85	normal	2026-08-28 06:23:38.955403	STF-045	Zohaib Ali Chaudhary	0.458	recognized	2026-08-28 06:23:40.363073
74983	1917	breakin	26	Break In	27-08-2026 17:58:57	3352	0.85	unrecognized	2026-08-28 06:20:01.684519	\N	Person #26	0	unrecognized	2026-08-28 06:20:26.012365
79066	1918	breakout	439	Break Out	27-08-2026 21:10:35	287876	0.85	unrecognized	2026-08-28 11:00:41.875927	\N	Person #439	0	unrecognized	2026-08-28 11:00:41.89388
79065	1918	breakout	439	Break Out	27-08-2026 21:10:27	287609	0.85	unrecognized	2026-08-28 11:00:40.386796	\N	Person #439	0	unrecognized	2026-08-28 11:00:41.523396
75052	1917	breakin	96	Break In	27-08-2026 11:04:20	95809	0.85	normal	2026-08-28 06:24:01.829926	STF-013	Muhammad Faizan	0.5893	recognized	2026-08-28 06:24:16.866614
75095	1917	breakin	52	Break In	27-08-2026 14:05:37	10634	0.85	normal	2026-08-28 06:26:43.153651	STF-058	Muhammad Iqbal Butt	0.5644	recognized	2026-08-28 06:26:45.29314
75122	1917	breakin	126	Break In	27-08-2026 11:07:55	101268	0.85	normal	2026-08-28 06:29:00.403857	STF-037	Muhammad Fahad	0.6547	recognized	2026-08-28 06:29:00.467687
75321	1916	attendance	264	Person Entered	27-08-2026 20:01:09	901708	0.85	pending	2026-08-28 06:45:28.694591	\N	Person #264	\N	pending	\N
75147	1916	attendance	188	Person Entered	27-08-2026 19:13:00	829565	0.85	unrecognized	2026-08-28 06:32:03.613262	\N	Person #188	0	unrecognized	2026-08-28 06:32:04.584191
75346	1917	breakin	105	Break In	27-08-2026 14:14:30	23841	0.85	normal	2026-08-28 06:47:29.280197	STF-007	Faisal Saleem	0.4422	recognized	2026-08-28 06:48:37.272937
78152	1918	breakout	144	Break Out	27-08-2026 19:04:56	99410	0.85	pending	2026-08-28 10:10:37.710015	\N	Person #144	0	unrecognized	\N
75322	1916	attendance	269	Person Entered	27-08-2026 20:01:49	902707	0.85	unrecognized	2026-08-28 06:45:33.524624	\N	Person #269	0	unrecognized	2026-08-28 06:45:34.735685
77793	1918	breakout	16	Break Out	27-08-2026 18:06:17	11337	0.85	unrecognized	2026-08-28 09:50:53.592523	\N	Person #16	0	unrecognized	2026-08-28 09:51:07.242395
75159	1916	attendance	198	Person Entered	27-08-2026 19:18:00	837241	0.85	unrecognized	2026-08-28 06:33:32.961787	\N	Person #198	0	unrecognized	2026-08-28 06:33:46.723327
75390	1916	attendance	302	Person Entered	27-08-2026 20:17:15	925864	0.85	pending	2026-08-28 06:50:13.968655	\N	Person #302	0	unrecognized	\N
75168	1916	attendance	204	Person Entered	27-08-2026 19:23:05	844592	0.85	unrecognized	2026-08-28 06:34:33.046758	\N	Person #204	0	unrecognized	2026-08-28 06:34:41.898119
75074	1916	attendance	131	Person Entered	27-08-2026 18:32:58	769375	0.85	unrecognized	2026-08-28 06:25:17.742908	\N	Person #131	0	unrecognized	2026-08-28 06:25:42.782715
75042	1916	attendance	122	Person Entered	27-08-2026 18:22:46	754092	0.85	unrecognized	2026-08-28 06:23:20.063145	\N	Person #122	0	unrecognized	2026-08-28 06:23:36.417495
74967	1916	attendance	95	Person Entered	27-08-2026 18:11:02	736499	0.85	unrecognized	2026-08-28 06:18:05.054228	\N	Person #95	0	unrecognized	2026-08-28 06:18:15.113984
74855	1916	attendance	46	Person Entered	27-08-2026 17:55:15	712851	0.85	pending	2026-08-28 06:10:19.318247	\N	Person #46	0	unrecognized	\N
75431	1916	attendance	314	Person Entered	27-08-2026 20:24:20	936480	0.85	pending	2026-08-28 06:53:08.921955	\N	Person #314	0	unrecognized	\N
75160	1916	attendance	200	Person Entered	27-08-2026 19:18:50	838153	0.85	unrecognized	2026-08-28 06:33:51.357273	\N	Person #200	0	unrecognized	2026-08-28 06:34:15.24863
78163	1918	breakout	148	Break Out	27-08-2026 19:08:45	105054	0.85	unrecognized	2026-08-28 10:11:09.619739	\N	Person #148	0	unrecognized	2026-08-28 10:11:24.211786
75173	1916	attendance	210	Person Entered	27-08-2026 19:29:17	853819	0.85	unrecognized	2026-08-28 06:35:08.371003	\N	Person #210	0	unrecognized	2026-08-28 06:35:30.640896
74880	1916	attendance	58	Person Entered	27-08-2026 17:58:00	717197	0.85	unrecognized	2026-08-28 06:11:48.476197	\N	Person #58	0	unrecognized	2026-08-28 06:12:07.992906
77795	1918	breakout	17	Break Out	27-08-2026 18:06:46	12032	0.85	unrecognized	2026-08-28 09:51:08.405228	\N	Person #17	0	unrecognized	2026-08-28 09:51:14.385553
78166	1918	breakout	150	Break Out	27-08-2026 19:09:07	105690	0.85	pending	2026-08-28 10:11:26.321875	\N	Person #150	\N	pending	\N
77789	1918	breakout	15	Break Out	27-08-2026 18:05:15	9803	0.85	unrecognized	2026-08-28 09:50:36.141041	\N	Person #15	0	unrecognized	2026-08-28 09:50:52.539847
75324	1916	attendance	270	Person Entered	27-08-2026 20:02:40	903911	0.85	unrecognized	2026-08-28 06:45:37.712216	\N	Person #270	0	unrecognized	2026-08-28 06:46:05.43477
75096	1916	attendance	137	Person Entered	27-08-2026 18:37:38	776401	0.85	unrecognized	2026-08-28 06:26:44.80159	\N	Person #137	0	unrecognized	2026-08-28 06:26:59.711222
74938	1916	attendance	75	Person Entered	27-08-2026 18:02:55	724337	0.85	unrecognized	2026-08-28 06:15:40.32787	\N	Person #75	0	unrecognized	2026-08-28 06:15:51.426966
78157	1918	breakout	147	Break Out	27-08-2026 19:06:14	101297	0.85	unrecognized	2026-08-28 10:10:55.728876	\N	Person #147	0	unrecognized	2026-08-28 10:10:58.064377
77796	1918	breakout	18	Break Out	27-08-2026 18:07:03	12488	0.85	unrecognized	2026-08-28 09:51:14.979389	\N	Person #18	0	unrecognized	2026-08-28 09:51:27.222173
75121	1916	attendance	155	Person Entered	27-08-2026 18:47:18	790899	0.85	unrecognized	2026-08-28 06:28:57.757783	\N	Person #155	0	unrecognized	2026-08-28 06:29:11.10412
75134	1916	attendance	166	Person Entered	27-08-2026 19:05:07	817654	0.85	unrecognized	2026-08-28 06:30:59.369365	\N	Person #166	0	unrecognized	2026-08-28 06:30:59.415243
78158	1918	breakout	147	Break Out	27-08-2026 19:06:55	102275	0.85	unrecognized	2026-08-28 10:10:58.705851	\N	Person #147	0	unrecognized	2026-08-28 10:11:07.973794
78153	1918	breakout	146	Break Out	27-08-2026 19:05:04	99551	0.85	unrecognized	2026-08-28 10:10:41.041792	\N	Person #146	0	unrecognized	2026-08-28 10:10:54.493441
78489	1918	breakout	238	Break Out	27-08-2026 15:28:55	132259	0.85	unrecognized	2026-08-28 10:30:41.535349	\N	Person #238	0	unrecognized	2026-08-28 10:30:54.56935
75487	1917	breakin	144	Break In	27-08-2026 14:17:17	28079	0.85	normal	2026-08-28 06:57:33.836612	STF-025	Farhan Virk	0.4642	recognized	2026-08-28 06:57:41.004197
75464	1917	breakin	207	Break In	27-08-2026 11:22:17	122477	0.85	normal	2026-08-28 06:55:31.849278	STF-006	Muhammad Abubakar	0.4845	recognized	2026-08-28 06:55:49.447215
75182	1917	breakin	135	Break In	27-08-2026 11:11:09	106090	0.85	normal	2026-08-28 06:35:31.621051	STF-022	Mubashir Ishaq	0.4933	recognized	2026-08-28 06:35:44.610338
75518	1917	breakin	231	Break In	27-08-2026 11:25:01	126897	0.85	normal	2026-08-28 06:59:43.061372	STF-011	Syed Shoaib Ahmad Alvi	0.544	recognized	2026-08-28 06:59:45.488368
78496	1918	breakout	238	Break Out	27-08-2026 15:29:10	132550	0.85	unrecognized	2026-08-28 10:30:54.98557	\N	Person #238	0	unrecognized	2026-08-28 10:31:02.122219
79331	1949	attendance	3	Person Entered	28-08-2026 19:21:03	427	0.85	unrecognized	2026-08-28 14:21:06.205195	\N	Person #3	0	unrecognized	2026-08-28 14:21:27.099729
78502	1918	breakout	241	Break Out	27-08-2026 15:30:29	134726	0.85	normal	2026-08-28 10:31:10.07681	STF-044	Zaheer Hussain	0.5136	recognized	2026-08-28 10:31:10.10274
79499	1951	breakout	110	Break Out	25-08-2026 19:02:45	11480	0.85	normal	2026-08-28 14:35:22.857647	STF-008	Muhammad Shoaib	0.4427	recognized	2026-08-28 14:35:23.510232
78833	1918	breakout	306	Break Out	27-08-2026 13:04:45	276346	0.85	pending	2026-08-28 10:47:40.013403	\N	Person #306	\N	pending	\N
75515	1917	breakin	229	Break In	27-08-2026 11:24:14	125750	0.85	normal	2026-08-28 06:59:33.774187	STF-013	Muhammad Faizan	0.5108	recognized	2026-08-28 06:59:33.824608
75523	1917	breakin	235	Break In	27-08-2026 11:26:03	128470	0.85	normal	2026-08-28 06:59:55.708558	STF-022	Mubashir Ishaq	0.4499	recognized	2026-08-28 06:59:55.735016
75521	1917	breakin	234	Break In	27-08-2026 11:25:57	128309	0.85	normal	2026-08-28 06:59:49.125013	STF-029	Abdul Rehman Sultan	0.4907	recognized	2026-08-28 06:59:51.031546
75527	1917	breakin	234	Break In	27-08-2026 11:26:39	129332	0.85	normal	2026-08-28 07:00:05.404732	STF-033	Raza Abbas	0.5382	recognized	2026-08-28 07:00:11.3444
75547	1917	breakin	246	Break In	27-08-2026 11:30:38	135240	0.85	unrecognized	2026-08-28 07:01:27.507079	\N	Person #246	0	unrecognized	2026-08-28 07:01:46.502181
74987	1917	breakin	55	Break In	27-08-2026 10:57:56	86105	0.85	normal	2026-08-28 06:20:15.936703	STF-004	Tanveer Hassan	0.443	recognized	2026-08-28 06:20:17.630067
77808	1918	breakout	23	Break Out	27-08-2026 18:09:08	15587	0.85	unrecognized	2026-08-28 09:51:51.359893	\N	Person #23	0	unrecognized	2026-08-28 09:52:05.369203
74885	1916	attendance	59	Person Entered	27-08-2026 17:58:00	717720	0.85	unrecognized	2026-08-28 06:12:10.936624	\N	Person #59	0	unrecognized	2026-08-28 06:12:45.986982
78519	1918	breakout	245	Break Out	27-08-2026 15:32:00	136949	0.85	normal	2026-08-28 10:32:21.849232	STF-010	Faraz Younas	0.465	recognized	2026-08-28 10:32:26.001513
77802	1918	breakout	19	Break Out	27-08-2026 18:07:39	13394	0.85	unrecognized	2026-08-28 09:51:27.918281	\N	Person #19	0	unrecognized	2026-08-28 09:51:35.570712
74857	1916	attendance	49	Person Entered	27-08-2026 17:55:00	712887	0.85	unrecognized	2026-08-28 06:10:22.827297	\N	Person #49	0	unrecognized	2026-08-28 06:10:28.040532
75325	1917	breakin	119	Break In	27-08-2026 14:14:04	23281	0.85	normal	2026-08-28 06:45:44.559409	STF-001	Ikram Hassan	0.4781	recognized	2026-08-28 06:45:58.877579
74988	1917	breakin	76	Break In	27-08-2026 10:58:16	86794	0.85	normal	2026-08-28 06:20:20.19286	STF-023	Syed Zubair Zulfiqar	0.455	recognized	2026-08-28 06:20:20.258683
74992	1917	breakin	80	Break In	27-08-2026 10:59:08	88100	0.85	normal	2026-08-28 06:20:47.107528	STF-045	Zohaib Ali Chaudhary	0.4892	recognized	2026-08-28 06:20:47.125481
79332	1949	attendance	6	Person Entered	28-08-2026 19:21:16	778	0.85	unrecognized	2026-08-28 14:21:26.984038	\N	Person #6	0	unrecognized	2026-08-28 14:21:38.565652
77805	1918	breakout	22	Break Out	27-08-2026 18:08:03	13987	0.85	unrecognized	2026-08-28 09:51:36.824271	\N	Person #22	0	unrecognized	2026-08-28 09:51:49.913026
75391	1917	breakin	133	Break In	27-08-2026 14:15:33	25539	0.85	normal	2026-08-28 06:50:15.238743	STF-025	Farhan Virk	0.5033	recognized	2026-08-28 06:50:15.260683
75082	1917	breakin	105	Break In	27-08-2026 11:06:06	98529	0.85	normal	2026-08-28 06:26:07.813914	STF-016	Muhammad Asad Awan	0.4823	recognized	2026-08-28 06:26:09.019679
77813	1918	breakout	28	Break Out	27-08-2026 18:11:36	19192	0.85	unrecognized	2026-08-28 09:52:18.974846	\N	Person #28	0	unrecognized	2026-08-28 09:52:37.547862
74932	1917	breakin	16	Break In	27-08-2026 17:58:22	2565	0.85	pending	2026-08-28 06:15:07.25071	\N	Person #16	0	unrecognized	\N
77809	1918	breakout	25	Break Out	27-08-2026 18:10:43	17922	0.85	unrecognized	2026-08-28 09:52:06.967482	\N	Person #25	0	unrecognized	2026-08-28 09:52:15.120278
74941	1916	attendance	76	Person Entered	27-08-2026 18:02:57	724385	0.85	unrecognized	2026-08-28 06:15:52.844663	\N	Person #76	0	unrecognized	2026-08-28 06:16:02.389786
74813	1916	attendance	28	Person Entered	27-08-2026 17:49:41	704466	0.85	unrecognized	2026-08-28 06:07:48.393791	\N	Person #28	0	unrecognized	2026-08-28 06:08:05.399588
75024	1916	attendance	117	Person Entered	27-08-2026 18:15:40	743471	0.85	unrecognized	2026-08-28 06:22:09.201199	\N	Person #117	0	unrecognized	2026-08-28 06:22:12.670854
77812	1918	breakout	27	Break Out	27-08-2026 18:11:23	19096	0.85	pending	2026-08-28 09:52:16.433938	\N	Person #27	0	unrecognized	\N
78164	1918	breakout	120	Break Out	27-08-2026 11:28:53	128080	0.85	normal	2026-08-28 10:11:12.253516	STF-015	Liaqat Ali	0.4858	recognized	2026-08-28 10:11:32.747413
74969	1917	breakin	31	Break In	27-08-2026 14:04:39	9088	0.85	unrecognized	2026-08-28 06:18:14.409742	\N	Person #31	0	unrecognized	2026-08-28 06:18:36.864447
74993	1917	breakin	81	Break In	27-08-2026 10:59:18	88120	0.85	normal	2026-08-28 06:20:48.78953	STF-004	Tanveer Hassan	0.5074	recognized	2026-08-28 06:21:05.827574
78508	1918	breakout	242	Break Out	27-08-2026 15:31:07	135504	0.85	unrecognized	2026-08-28 10:31:30.132237	\N	Person #242	0	unrecognized	2026-08-28 10:31:38.5715
78834	1918	breakout	307	Break Out	27-08-2026 13:07:38	276364	0.85	normal	2026-08-28 10:47:40.243068	STF-002	Abdur Rehman	0.4415	recognized	2026-08-28 10:47:43.885941
78837	1918	breakout	308	Break Out	27-08-2026 13:07:00	276435	0.85	unrecognized	2026-08-28 10:47:44.903053	\N	Person #308	0	unrecognized	2026-08-28 10:47:51.398033
75964	1917	breakin	354	Break In	27-08-2026 12:34:00	231235	0.85	normal	2026-08-28 07:28:41.486855	STF-015	Liaqat Ali	0.4471	recognized	2026-08-28 07:29:21.997713
75103	1916	attendance	140	Person Entered	27-08-2026 18:38:49	778172	0.85	unrecognized	2026-08-28 06:27:03.720936	\N	Person #140	0	unrecognized	2026-08-28 06:27:20.812029
75162	1917	breakin	139	Break In	27-08-2026 11:10:37	104305	0.85	unrecognized	2026-08-28 06:33:55.028459	\N	Person #139	0	unrecognized	2026-08-28 06:35:12.841625
78843	1918	breakout	308	Break Out	27-08-2026 13:08:20	277464	0.85	unrecognized	2026-08-28 10:47:53.288814	\N	Person #308	0	unrecognized	2026-08-28 10:47:53.315742
78844	1918	breakout	308	Break Out	27-08-2026 13:08:33	277666	0.85	unrecognized	2026-08-28 10:47:53.637007	\N	Person #308	0	unrecognized	2026-08-28 10:48:10.653399
75351	1916	attendance	289	Person Entered	27-08-2026 20:10:52	916251	0.85	unrecognized	2026-08-28 06:47:40.767937	\N	Person #289	0	unrecognized	2026-08-28 06:47:54.055686
75394	1917	breakin	135	Break In	27-08-2026 14:15:37	25592	0.85	normal	2026-08-28 06:50:40.514896	STF-023	Syed Zubair Zulfiqar	0.5425	recognized	2026-08-28 06:51:11.677935
78851	1918	breakout	308	Break Out	27-08-2026 13:08:52	278242	0.85	unrecognized	2026-08-28 10:48:12.332554	\N	Person #308	0	unrecognized	2026-08-28 10:48:12.644392
78852	1918	breakout	308	Break Out	27-08-2026 13:08:59	278430	0.85	unrecognized	2026-08-28 10:48:12.942778	\N	Person #308	0	unrecognized	2026-08-28 10:48:13.857353
75199	1917	breakin	91	Break In	27-08-2026 18:14:03	26077	0.85	normal	2026-08-28 06:36:56.431289	STF-010	Faraz Younas	0.5293	recognized	2026-08-28 06:36:56.464708
78516	1918	breakout	218	Break Out	27-08-2026 12:25:09	217132	0.85	pending	2026-08-28 10:32:18.859907	\N	Person #218	0	unrecognized	\N
78858	1918	breakout	332	Break Out	27-08-2026 16:22:53	213269	0.85	unrecognized	2026-08-28 10:48:23.677587	\N	Person #332	0	unrecognized	2026-08-28 10:48:28.069636
79353	1949	attendance	31	Person Entered	25-08-2026 19:01:47	10126	0.85	pending	2026-08-28 14:23:28.509421	\N	Person #31	\N	pending	\N
75967	1917	breakin	299	Break In	27-08-2026 19:13:13	114844	0.85	normal	2026-08-28 07:29:12.883758	STF-024	Arsalan Khan	0.5532	recognized	2026-08-28 07:29:13.550042
78849	1918	breakout	329	Break Out	27-08-2026 16:21:00	210466	0.85	normal	2026-08-28 10:48:11.41158	STF-011	Syed Shoaib Ahmad Alvi	0.4544	recognized	2026-08-28 10:48:13.85934
78173	1918	breakout	152	Break Out	27-08-2026 19:09:30	106112	0.85	unrecognized	2026-08-28 10:11:37.257769	\N	Person #152	0	unrecognized	2026-08-28 10:12:05.490435
75668	1917	breakin	273	Break In	27-08-2026 12:02:16	182649	0.85	unrecognized	2026-08-28 07:10:15.47947	\N	Person #273	0	unrecognized	2026-08-28 07:10:41.986064
75526	1917	breakin	155	Break In	27-08-2026 14:18:01	29230	0.85	normal	2026-08-28 07:00:00.047159	STF-030	Dildar Ahmed	0.4522	recognized	2026-08-28 07:00:03.322579
78520	1918	breakout	219	Break Out	27-08-2026 12:28:54	218240	0.85	unrecognized	2026-08-28 10:32:22.571126	\N	Person #219	0	unrecognized	2026-08-28 10:32:24.150988
78168	1918	breakout	151	Break Out	27-08-2026 19:09:19	105838	0.85	unrecognized	2026-08-28 10:11:27.889196	\N	Person #151	0	unrecognized	2026-08-28 10:11:36.696311
75612	1916	attendance	387	Person Entered	27-08-2026 20:49:45	974598	0.85	unrecognized	2026-08-28 07:06:17.153215	\N	Person #387	0	unrecognized	2026-08-28 07:06:20.308897
75392	1916	attendance	303	Person Entered	27-08-2026 20:18:03	926860	0.85	unrecognized	2026-08-28 06:50:20.122541	\N	Person #303	0	unrecognized	2026-08-28 06:51:40.79385
78521	1918	breakout	219	Break Out	27-08-2026 12:29:06	218613	0.85	unrecognized	2026-08-28 10:32:24.527535	\N	Person #219	0	unrecognized	2026-08-28 10:32:24.576404
75433	1917	breakin	148	Break In	27-08-2026 18:29:39	49485	0.85	normal	2026-08-28 06:53:11.704592	STF-008	Muhammad Shoaib	0.5388	recognized	2026-08-28 06:53:11.747476
78509	1918	breakout	214	Break Out	27-08-2026 12:22:49	209070	0.85	unrecognized	2026-08-28 10:31:38.365485	\N	Person #214	0	unrecognized	2026-08-28 10:31:55.84062
75679	1917	breakin	273	Break In	27-08-2026 12:04:10	185572	0.85	unrecognized	2026-08-28 07:11:01.02415	\N	Person #273	0	unrecognized	2026-08-28 07:11:18.167805
75354	1916	attendance	292	Person Entered	27-08-2026 20:11:00	916507	0.85	unrecognized	2026-08-28 06:47:57.124705	\N	Person #292	0	unrecognized	2026-08-28 06:48:08.188407
75652	1917	breakin	197	Break In	27-08-2026 18:41:21	67014	0.85	normal	2026-08-28 07:08:29.212963	STF-025	Farhan Virk	0.5608	recognized	2026-08-28 07:08:31.559657
77803	1918	breakout	17	Break Out	27-08-2026 10:50:26	70496	0.85	unrecognized	2026-08-28 09:51:35.798346	\N	Person #17	0	unrecognized	2026-08-28 09:51:49.680899
78522	1918	breakout	220	Break Out	27-08-2026 12:26:10	218638	0.85	pending	2026-08-28 10:32:24.939223	\N	Person #220	\N	pending	\N
79355	1949	attendance	31	Person Entered	25-08-2026 19:02:11	10742	0.85	pending	2026-08-28 14:23:29.069315	\N	Person #31	\N	pending	\N
78855	1918	breakout	330	Break Out	27-08-2026 16:21:35	211387	0.85	pending	2026-08-28 10:48:16.957776	\N	Person #330	0	unrecognized	\N
78512	1918	breakout	215	Break Out	27-08-2026 12:23:56	210749	0.85	unrecognized	2026-08-28 10:31:56.872421	\N	Person #215	0	unrecognized	2026-08-28 10:32:11.03673
78857	1918	breakout	332	Break Out	27-08-2026 16:22:16	212412	0.85	pending	2026-08-28 10:48:20.568844	\N	Person #332	0	unrecognized	\N
78514	1918	breakout	216	Break Out	27-08-2026 12:21:12	211226	0.85	pending	2026-08-28 10:32:11.791786	\N	Person #216	0	unrecognized	\N
78523	1918	breakout	220	Break Out	27-08-2026 12:29:33	219181	0.85	unrecognized	2026-08-28 10:32:25.668968	\N	Person #220	0	unrecognized	2026-08-28 10:32:41.874753
79077	1918	breakout	401	Break Out	27-08-2026 16:59:12	267728	0.85	unrecognized	2026-08-28 11:01:09.012433	\N	Person #401	0	unrecognized	2026-08-28 11:01:10.859818
75598	1916	attendance	382	Person Entered	27-08-2026 20:49:00	974262	0.85	unrecognized	2026-08-28 07:05:04.709743	\N	Person #382	0	unrecognized	2026-08-28 07:06:05.610678
79064	1918	breakout	399	Break Out	27-08-2026 16:57:00	265421	0.85	unrecognized	2026-08-28 11:00:39.119571	\N	Person #399	0	unrecognized	2026-08-28 11:00:59.071736
76019	1917	breakin	376	Break In	27-08-2026 12:45:52	248173	0.85	normal	2026-08-28 07:34:18.203586	STF-046	Usman Babar	0.4526	recognized	2026-08-28 07:34:22.478718
79062	1918	breakout	398	Break Out	27-08-2026 16:57:14	264834	0.85	unrecognized	2026-08-28 11:00:37.962048	\N	Person #398	0	unrecognized	2026-08-28 11:00:38.424177
78859	1918	breakout	333	Break Out	27-08-2026 16:23:40	214393	0.85	unrecognized	2026-08-28 10:48:29.089677	\N	Person #333	0	unrecognized	2026-08-28 10:48:37.067015
79063	1918	breakout	399	Break Out	27-08-2026 16:57:23	265094	0.85	pending	2026-08-28 11:00:38.939042	\N	Person #399	\N	pending	\N
79072	1918	breakout	400	Break Out	27-08-2026 16:57:52	265692	0.85	unrecognized	2026-08-28 11:00:59.848755	\N	Person #400	0	unrecognized	2026-08-28 11:01:07.274086
75675	1917	breakin	273	Break In	27-08-2026 12:04:01	185342	0.85	unrecognized	2026-08-28 07:10:43.4372	\N	Person #273	0	unrecognized	2026-08-28 07:11:00.5393
79076	1918	breakout	401	Break Out	27-08-2026 16:58:26	266660	0.85	pending	2026-08-28 11:01:08.088969	\N	Person #401	\N	pending	\N
75692	1917	breakin	189	Break In	27-08-2026 14:24:19	38697	0.85	normal	2026-08-28 07:11:41.939592	STF-025	Farhan Virk	0.6219	recognized	2026-08-28 07:11:41.970509
78169	1918	breakout	130	Break Out	27-08-2026 14:43:53	64828	0.85	pending	2026-08-28 10:11:29.897957	\N	Person #130	0	unrecognized	\N
75613	1917	breakin	263	Break In	27-08-2026 11:52:07	167567	0.85	normal	2026-08-28 07:06:20.337024	STF-047	Arshad Irshad	0.4795	recognized	2026-08-28 07:06:20.381905
77804	1918	breakout	22	Break Out	27-08-2026 14:06:14	8283	0.85	normal	2026-08-28 09:51:35.941388	STF-018	Muhammad Qaiser Shahzad	0.4633	recognized	2026-08-28 09:51:48.451354
78177	1918	breakout	131	Break Out	27-08-2026 14:45:09	66643	0.85	unrecognized	2026-08-28 10:11:47.942626	\N	Person #131	0	unrecognized	2026-08-28 10:11:58.597427
78515	1918	breakout	265	Break Out	27-08-2026 20:07:16	192775	0.85	unrecognized	2026-08-28 10:32:17.076583	\N	Person #265	0	unrecognized	2026-08-28 10:32:39.073006
77815	1918	breakout	26	Break Out	27-08-2026 14:07:00	9522	0.85	unrecognized	2026-08-28 09:52:25.499228	\N	Person #26	0	unrecognized	2026-08-28 09:52:27.25413
75653	1917	breakin	105	Break In	27-08-2026 14:22:28	35771	0.85	unrecognized	2026-08-28 07:08:32.73424	\N	Person #105	0	unrecognized	2026-08-28 07:08:35.780887
75358	1916	attendance	295	Person Entered	27-08-2026 20:11:00	916963	0.85	unrecognized	2026-08-28 06:48:13.245251	\N	Person #295	0	unrecognized	2026-08-28 06:48:40.229844
75395	1917	breakin	168	Break In	27-08-2026 11:18:14	116737	0.85	normal	2026-08-28 06:50:43.741236	STF-037	Muhammad Fahad	0.4906	recognized	2026-08-28 06:50:43.793098
78854	1918	breakout	313	Break Out	27-08-2026 13:09:28	279083	0.85	unrecognized	2026-08-28 10:48:15.231107	\N	Person #313	0	unrecognized	2026-08-28 10:48:37.428193
78171	1918	breakout	130	Break Out	27-08-2026 14:44:34	65765	0.85	unrecognized	2026-08-28 10:11:32.862465	\N	Person #130	0	unrecognized	2026-08-28 10:11:45.591453
79335	1949	attendance	12	Person Entered	28-08-2026 19:23:17	3803	0.85	unrecognized	2026-08-28 14:22:12.823488	\N	Person #12	0	unrecognized	2026-08-28 14:22:21.212526
75674	1917	breakin	203	Break In	27-08-2026 18:45:37	73436	0.85	normal	2026-08-28 07:10:40.397486	STF-045	Zohaib Ali Chaudhary	0.555	recognized	2026-08-28 07:10:40.45983
75579	1917	breakin	256	Break In	27-08-2026 11:46:31	159089	0.85	unrecognized	2026-08-28 07:04:02.058371	\N	Person #256	0	unrecognized	2026-08-28 07:04:21.361051
75488	1916	attendance	347	Person Entered	27-08-2026 20:39:40	959429	0.85	unrecognized	2026-08-28 06:57:41.168004	\N	Person #347	0	unrecognized	2026-08-28 06:58:07.000847
75191	1917	breakin	74	Break In	27-08-2026 14:07:32	13273	0.85	unrecognized	2026-08-28 06:36:06.244737	\N	Person #74	0	unrecognized	2026-08-28 06:37:06.662485
75356	1916	attendance	294	Person Entered	27-08-2026 20:11:19	916951	0.85	pending	2026-08-28 06:48:12.065653	\N	Person #294	0	unrecognized	\N
78176	1918	breakout	131	Break Out	27-08-2026 14:44:59	66466	0.85	unrecognized	2026-08-28 10:11:46.438111	\N	Person #131	0	unrecognized	2026-08-28 10:11:47.605631
78182	1918	breakout	134	Break Out	27-08-2026 14:45:20	66871	0.85	unrecognized	2026-08-28 10:12:11.134085	\N	Person #134	0	unrecognized	2026-08-28 10:12:27.242445
79344	1949	attendance	20	check_in	28-08-2026 19:26:47	9065	0.85	normal	2026-08-28 14:22:48.928329	STF-011	Syed Shoaib Ahmad Alvi	0.4996	recognized	2026-08-28 14:22:57.60321
79073	1918	breakout	441	Break Out	27-08-2026 21:11:13	288834	0.85	pending	2026-08-28 11:00:59.948201	\N	Person #441	0	unrecognized	\N
79067	1918	breakout	440	Break Out	27-08-2026 21:10:41	287930	0.85	unrecognized	2026-08-28 11:00:42.280845	\N	Person #440	0	unrecognized	2026-08-28 11:00:59.033838
75467	1917	breakin	149	Break In	27-08-2026 18:31:02	51558	0.85	normal	2026-08-28 06:55:48.776245	STF-008	Muhammad Shoaib	0.4915	recognized	2026-08-28 06:55:48.817646
75627	1917	breakin	266	Break In	27-08-2026 11:54:14	170702	0.85	normal	2026-08-28 07:07:09.507369	STF-002	Abdur Rehman	0.4605	recognized	2026-08-28 07:07:13.735322
75629	1916	attendance	391	Person Entered	27-08-2026 20:51:26	977108	0.85	unrecognized	2026-08-28 07:07:17.694772	\N	Person #391	0	unrecognized	2026-08-28 07:07:32.18788
75513	1916	attendance	359	Person Entered	27-08-2026 20:44:16	966316	0.85	unrecognized	2026-08-28 06:59:17.843072	\N	Person #359	0	unrecognized	2026-08-28 06:59:49.317672
75551	1917	breakin	247	Break In	27-08-2026 11:32:41	138415	0.85	normal	2026-08-28 07:02:02.443018	STF-011	Syed Shoaib Ahmad Alvi	0.4699	recognized	2026-08-28 07:02:02.82561
75553	1917	breakin	248	Break In	27-08-2026 11:34:37	141259	0.85	unrecognized	2026-08-28 07:02:06.858405	\N	Person #248	0	unrecognized	2026-08-28 07:02:18.516886
75622	1917	breakin	264	Break In	27-08-2026 11:54:06	170513	0.85	normal	2026-08-28 07:07:02.041505	STF-029	Abdul Rehman Sultan	0.4835	recognized	2026-08-28 07:07:04.687202
75648	1916	attendance	396	Person Entered	27-08-2026 20:51:00	977858	0.85	unrecognized	2026-08-28 07:08:12.735164	\N	Person #396	0	unrecognized	2026-08-28 07:08:35.781884
75672	1917	breakin	202	Break In	27-08-2026 18:45:01	72538	0.85	normal	2026-08-28 07:10:33.583864	STF-017	Mohammad Zahid	0.4515	recognized	2026-08-28 07:10:34.282711
75657	1917	breakin	175	Break In	27-08-2026 14:23:13	36292	0.85	normal	2026-08-28 07:08:54.706931	STF-007	Faisal Saleem	0.4622	recognized	2026-08-28 07:10:20.236728
75676	1917	breakin	203	Break In	27-08-2026 18:46:10	74255	0.85	normal	2026-08-28 07:10:44.851407	STF-034	Muhammad Laeeq	0.476	recognized	2026-08-28 07:10:44.881055
75677	1917	breakin	204	Break In	27-08-2026 18:47:19	75903	0.85	unrecognized	2026-08-28 07:10:50.148467	\N	Person #204	0	unrecognized	2026-08-28 07:11:10.81714
75681	1917	breakin	205	Break In	27-08-2026 18:48:04	77024	0.85	unrecognized	2026-08-28 07:11:12.416328	\N	Person #205	0	unrecognized	2026-08-28 07:11:27.927
75699	1917	breakin	278	Break In	27-08-2026 12:06:00	189357	0.85	unrecognized	2026-08-28 07:12:17.860956	\N	Person #278	0	unrecognized	2026-08-28 07:12:35.602479
75329	1916	attendance	272	Person Entered	27-08-2026 20:03:23	905018	0.85	unrecognized	2026-08-28 06:46:08.85945	\N	Person #272	0	unrecognized	2026-08-28 06:46:27.151102
75525	1917	breakin	163	Break In	27-08-2026 18:32:54	54099	0.85	unrecognized	2026-08-28 06:59:58.759065	\N	Person #163	0	unrecognized	2026-08-28 07:00:54.168246
77825	1918	breakout	21	Break Out	27-08-2026 10:49:29	74022	0.85	pending	2026-08-28 09:53:01.720515	\N	Person #21	0	unrecognized	\N
79341	1949	attendance	18	Person Entered	28-08-2026 19:25:03	6448	0.85	unrecognized	2026-08-28 14:22:28.987554	\N	Person #18	0	unrecognized	2026-08-28 14:22:41.46536
78537	1918	breakout	249	Break Out	27-08-2026 15:37:29	145240	0.85	pending	2026-08-28 10:33:08.707698	\N	Person #249	0	unrecognized	\N
78528	1918	breakout	248	Break Out	27-08-2026 15:34:45	141039	0.85	unrecognized	2026-08-28 10:32:44.507807	\N	Person #248	0	unrecognized	2026-08-28 10:32:54.869947
78524	1918	breakout	246	Break Out	27-08-2026 15:33:33	139251	0.85	unrecognized	2026-08-28 10:32:29.575622	\N	Person #246	0	unrecognized	2026-08-28 10:32:43.156984
79336	1949	attendance	14	Person Entered	25-08-2026 18:57:51	4246	0.85	pending	2026-08-28 14:22:19.860708	\N	Person #14	0	unrecognized	\N
75405	1917	breakin	178	Break In	27-08-2026 11:18:58	117841	0.85	normal	2026-08-28 06:51:41.024717	STF-037	Muhammad Fahad	0.4633	recognized	2026-08-28 06:51:41.066382
78174	1918	breakout	125	Break Out	27-08-2026 11:29:18	128894	0.85	normal	2026-08-28 10:11:40.207491	STF-048	Abdullah Sultan	0.4833	recognized	2026-08-28 10:11:42.28911
75603	1917	breakin	259	Break In	27-08-2026 11:48:30	162114	0.85	unrecognized	2026-08-28 07:05:25.337437	\N	Person #259	0	unrecognized	2026-08-28 07:05:27.602688
79346	1949	attendance	23	Person Entered	25-08-2026 19:01:08	9155	0.85	pending	2026-08-28 14:22:58.737426	\N	Person #23	0	unrecognized	\N
77816	1918	breakout	18	Break Out	27-08-2026 10:52:29	73640	0.85	normal	2026-08-28 09:52:26.831144	STF-029	Abdul Rehman Sultan	0.4705	recognized	2026-08-28 09:52:30.81423
79337	1949	attendance	15	Person Entered	28-08-2026 19:23:34	4255	0.85	unrecognized	2026-08-28 14:22:20.429227	\N	Person #15	0	unrecognized	2026-08-28 14:22:24.258174
75357	1917	breakin	124	Break In	27-08-2026 14:14:29	23913	0.85	normal	2026-08-28 06:48:12.950164	STF-011	Syed Shoaib Ahmad Alvi	0.5815	recognized	2026-08-28 06:48:33.107889
79339	1949	attendance	14	Person Entered	25-08-2026 18:58:45	5598	0.85	pending	2026-08-28 14:22:26.299468	\N	Person #14	\N	pending	\N
75361	1917	breakin	121	Break In	27-08-2026 14:14:30	23957	0.85	normal	2026-08-28 06:48:37.84929	STF-025	Farhan Virk	0.5289	recognized	2026-08-28 06:48:37.887189
78170	1918	breakout	123	Break Out	27-08-2026 11:28:54	128287	0.85	normal	2026-08-28 10:11:32.4146	STF-006	Muhammad Abubakar	0.4939	recognized	2026-08-28 10:11:34.839594
79340	1949	attendance	14	Person Entered	25-08-2026 18:58:52	5753	0.85	pending	2026-08-28 14:22:26.759023	\N	Person #14	\N	pending	\N
78183	1918	breakout	127	Break Out	27-08-2026 11:32:22	133449	0.85	unrecognized	2026-08-28 10:12:20.072117	\N	Person #127	0	unrecognized	2026-08-28 10:12:32.528333
79349	1949	attendance	30	Person Entered	25-08-2026 19:01:18	9424	0.85	pending	2026-08-28 14:23:10.845219	\N	Person #30	0	unrecognized	\N
75601	1917	breakin	258	Break In	27-08-2026 11:47:51	161140	0.85	normal	2026-08-28 07:05:17.403978	STF-025	Farhan Virk	0.5538	recognized	2026-08-28 07:05:21.031054
78180	1918	breakout	126	Break Out	27-08-2026 11:30:43	130918	0.85	unrecognized	2026-08-28 10:12:01.416836	\N	Person #126	0	unrecognized	2026-08-28 10:12:18.621192
75568	1917	breakin	177	Break In	27-08-2026 18:36:39	59799	0.85	unrecognized	2026-08-28 07:03:02.53139	\N	Person #177	0	unrecognized	2026-08-28 07:03:30.753245
75413	1917	breakin	181	Break In	27-08-2026 11:19:18	118304	0.85	normal	2026-08-28 06:51:54.379449	STF-008	Muhammad Shoaib	0.4769	recognized	2026-08-28 06:51:59.597365
75435	1916	attendance	315	Person Entered	27-08-2026 20:25:03	937500	0.85	unrecognized	2026-08-28 06:53:14.59903	\N	Person #315	0	unrecognized	2026-08-28 06:53:39.866323
75468	1916	attendance	332	Person Entered	27-08-2026 20:27:52	941797	0.85	pending	2026-08-28 06:55:49.003346	\N	Person #332	\N	pending	\N
78538	1918	breakout	250	Break Out	27-08-2026 15:37:00	145559	0.85	unrecognized	2026-08-28 10:33:11.64367	\N	Person #250	0	unrecognized	2026-08-28 10:33:23.839037
78530	1918	breakout	248	Break Out	27-08-2026 15:34:57	141340	0.85	unrecognized	2026-08-28 10:32:55.19989	\N	Person #248	0	unrecognized	2026-08-28 10:33:06.625695
78548	1918	breakout	253	Break Out	27-08-2026 15:39:43	148498	0.85	normal	2026-08-28 10:33:27.944755	STF-045	Zohaib Ali Chaudhary	0.52	recognized	2026-08-28 10:33:32.711093
78547	1918	breakout	253	Break Out	27-08-2026 15:38:31	146783	0.85	pending	2026-08-28 10:33:25.050507	\N	Person #253	0	unrecognized	\N
75472	1916	attendance	337	Person Entered	27-08-2026 20:28:25	942580	0.85	unrecognized	2026-08-28 06:55:57.157182	\N	Person #337	0	unrecognized	2026-08-28 06:56:12.764654
75471	1916	attendance	335	Person Entered	27-08-2026 20:28:00	941992	0.85	unrecognized	2026-08-28 06:55:53.04456	\N	Person #335	0	unrecognized	2026-08-28 06:55:54.677389
79521	1951	breakout	122	Break Out	25-08-2026 19:03:27	12530	0.85	normal	2026-08-28 14:36:46.043098	STF-049	Nabi Ul Haq	0.4803	recognized	2026-08-28 14:36:49.826557
75491	1917	breakin	154	Break In	27-08-2026 18:31:38	52452	0.85	normal	2026-08-28 06:57:49.951751	STF-008	Muhammad Shoaib	0.4825	recognized	2026-08-28 06:57:50.004858
75516	1917	breakin	154	Break In	27-08-2026 18:32:22	53524	0.85	normal	2026-08-28 06:59:34.406307	STF-008	Muhammad Shoaib	0.5148	recognized	2026-08-28 06:59:39.055088
75566	1917	breakin	176	Break In	27-08-2026 18:36:31	59783	0.85	pending	2026-08-28 07:03:01.831186	\N	Person #176	\N	pending	\N
75590	1916	attendance	372	Person Entered	27-08-2026 20:47:33	971317	0.85	unrecognized	2026-08-28 07:04:49.614086	\N	Person #372	0	unrecognized	2026-08-28 07:04:51.672541
75581	1916	attendance	370	Person Entered	27-08-2026 20:46:00	969614	0.85	unrecognized	2026-08-28 07:04:13.093648	\N	Person #370	0	unrecognized	2026-08-28 07:04:37.072792
75624	1917	breakin	190	Break In	27-08-2026 18:40:39	65986	0.85	normal	2026-08-28 07:07:02.565031	STF-033	Raza Abbas	0.5898	recognized	2026-08-28 07:07:02.606428
75632	1917	breakin	105	Break In	27-08-2026 14:21:13	33844	0.85	normal	2026-08-28 07:07:21.792112	STF-007	Faisal Saleem	0.469	recognized	2026-08-28 07:07:25.2507
75195	1916	attendance	220	Person Entered	27-08-2026 19:36:22	864543	0.85	unrecognized	2026-08-28 06:36:43.079293	\N	Person #220	0	unrecognized	2026-08-28 06:36:43.117192
75203	1917	breakin	78	Break In	27-08-2026 14:07:00	13820	0.85	normal	2026-08-28 06:37:12.145596	STF-035	Hammad Shaukat	0.5176	recognized	2026-08-28 06:37:12.182398
75227	1916	attendance	230	Person Entered	27-08-2026 19:42:21	873447	0.85	unrecognized	2026-08-28 06:38:18.342914	\N	Person #230	0	unrecognized	2026-08-28 06:38:42.311708
75223	1917	breakin	84	Break In	27-08-2026 14:08:28	14634	0.85	unrecognized	2026-08-28 06:38:01.457935	\N	Person #84	0	unrecognized	2026-08-28 06:39:14.566552
75211	1916	attendance	227	Person Entered	27-08-2026 19:40:00	870687	0.85	unrecognized	2026-08-28 06:37:27.295848	\N	Person #227	0	unrecognized	2026-08-28 06:37:49.402379
75225	1917	breakin	98	Break In	27-08-2026 18:18:21	32440	0.85	unrecognized	2026-08-28 06:38:01.677883	\N	Person #98	0	unrecognized	2026-08-28 06:38:21.525776
75210	1917	breakin	85	Break In	27-08-2026 14:07:59	14043	0.85	unrecognized	2026-08-28 06:37:24.743415	\N	Person #85	0	unrecognized	2026-08-28 06:37:50.067463
78525	1918	breakout	265	Break Out	27-08-2026 20:07:27	193051	0.85	unrecognized	2026-08-28 10:32:39.423524	\N	Person #265	0	unrecognized	2026-08-28 10:32:55.157006
75242	1916	attendance	236	Person Entered	27-08-2026 19:45:45	878606	0.85	unrecognized	2026-08-28 06:39:16.654761	\N	Person #236	0	unrecognized	2026-08-28 06:39:18.036822
75198	1916	attendance	225	Person Entered	27-08-2026 19:39:12	868733	0.85	unrecognized	2026-08-28 06:36:53.559341	\N	Person #225	0	unrecognized	2026-08-28 06:37:15.543794
75206	1917	breakin	83	Break In	27-08-2026 14:07:53	14009	0.85	unrecognized	2026-08-28 06:37:19.141024	\N	Person #83	0	unrecognized	2026-08-28 06:37:24.301255
78186	1918	breakout	135	Break Out	27-08-2026 14:45:31	67207	0.85	unrecognized	2026-08-28 10:12:28.025548	\N	Person #135	0	unrecognized	2026-08-28 10:12:43.234735
75205	1916	attendance	226	Person Entered	27-08-2026 19:39:32	869262	0.85	unrecognized	2026-08-28 06:37:17.508927	\N	Person #226	0	unrecognized	2026-08-28 06:37:19.180404
78199	1918	breakout	138	Break Out	27-08-2026 14:46:03	67997	0.85	unrecognized	2026-08-28 10:13:13.844286	\N	Person #138	0	unrecognized	2026-08-28 10:13:16.801317
75330	1917	breakin	131	Break In	27-08-2026 18:25:54	43717	0.85	normal	2026-08-28 06:46:28.362153	STF-020	Syed Jahazaib Ahmad Alvi	0.4569	recognized	2026-08-28 06:46:33.315345
75216	1917	breakin	96	Break In	27-08-2026 18:17:06	30655	0.85	normal	2026-08-28 06:37:56.592248	STF-022	Mubashir Ishaq	0.4545	recognized	2026-08-28 06:37:56.61622
75214	1917	breakin	95	Break In	27-08-2026 18:16:55	30395	0.85	normal	2026-08-28 06:37:51.017092	STF-044	Zaheer Hussain	0.4866	recognized	2026-08-28 06:37:51.060072
77817	1918	breakout	26	Break Out	27-08-2026 14:07:15	9752	0.85	unrecognized	2026-08-28 09:52:27.561544	\N	Person #26	0	unrecognized	2026-08-28 09:52:54.360988
75229	1917	breakin	146	Break In	27-08-2026 11:12:02	107417	0.85	normal	2026-08-28 06:38:32.955803	STF-016	Muhammad Asad Awan	0.5175	recognized	2026-08-28 06:38:41.304694
75212	1917	breakin	94	Break In	27-08-2026 18:16:08	29121	0.85	unrecognized	2026-08-28 06:37:28.478373	\N	Person #94	0	unrecognized	2026-08-28 06:37:46.995951
75218	1916	attendance	229	Person Entered	27-08-2026 19:40:00	871376	0.85	unrecognized	2026-08-28 06:37:57.424036	\N	Person #229	0	unrecognized	2026-08-28 06:38:13.997012
75209	1916	attendance	227	Person Entered	27-08-2026 19:40:23	870521	0.85	unrecognized	2026-08-28 06:37:23.615766	\N	Person #227	0	unrecognized	2026-08-28 06:37:26.611989
75215	1916	attendance	228	Person Entered	27-08-2026 19:40:45	871101	0.85	pending	2026-08-28 06:37:51.837869	\N	Person #228	0	unrecognized	\N
75236	1917	breakin	105	Break In	27-08-2026 18:20:13	35300	0.85	normal	2026-08-28 06:39:05.59615	STF-020	Syed Jahazaib Ahmad Alvi	0.5301	recognized	2026-08-28 06:39:14.170853
76020	1917	breakin	377	Break In	27-08-2026 12:45:54	248247	0.85	normal	2026-08-28 07:34:24.398253	STF-005	Muhammad Ayaz Hussain	0.4998	recognized	2026-08-28 07:34:24.488025
77824	1918	breakout	28	Break Out	27-08-2026 14:07:25	10013	0.85	unrecognized	2026-08-28 09:53:01.685609	\N	Person #28	0	unrecognized	2026-08-28 09:53:19.53461
75207	1917	breakin	93	Break In	27-08-2026 18:14:55	27354	0.85	normal	2026-08-28 06:37:19.862777	STF-004	Tanveer Hassan	0.5226	recognized	2026-08-28 06:37:22.697146
75222	1917	breakin	97	Break In	27-08-2026 18:18:07	32179	0.85	pending	2026-08-28 06:38:00.848139	\N	Person #97	\N	pending	\N
75220	1917	breakin	84	Break In	27-08-2026 14:08:09	14379	0.85	unrecognized	2026-08-28 06:37:58.785978	\N	Person #84	0	unrecognized	2026-08-28 06:38:00.702528
78197	1918	breakout	138	Break Out	27-08-2026 14:45:48	67617	0.85	unrecognized	2026-08-28 10:13:05.656771	\N	Person #138	0	unrecognized	2026-08-28 10:13:13.479932
75234	1917	breakin	103	Break In	27-08-2026 18:20:07	35180	0.85	normal	2026-08-28 06:39:01.264749	STF-004	Tanveer Hassan	0.45	recognized	2026-08-28 06:39:01.292322
78190	1918	breakout	137	Break Out	27-08-2026 14:45:38	67302	0.85	unrecognized	2026-08-28 10:12:46.749855	\N	Person #137	0	unrecognized	2026-08-28 10:13:04.676166
75230	1916	attendance	231	Person Entered	27-08-2026 19:42:39	873945	0.85	unrecognized	2026-08-28 06:38:44.429782	\N	Person #231	0	unrecognized	2026-08-28 06:38:55.232804
75232	1917	breakin	101	Break In	27-08-2026 18:18:32	32786	0.85	unrecognized	2026-08-28 06:38:54.24753	\N	Person #101	0	unrecognized	2026-08-28 06:38:56.878695
75224	1917	breakin	83	Break In	27-08-2026 14:08:21	14634	0.85	unrecognized	2026-08-28 06:38:01.656938	\N	Person #83	0	unrecognized	2026-08-28 06:38:57.7613
79068	1918	breakout	384	Break Out	27-08-2026 13:40:55	330454	0.85	pending	2026-08-28 11:00:42.426423	\N	Person #384	\N	pending	\N
75235	1916	attendance	235	Person Entered	27-08-2026 19:44:00	877143	0.85	unrecognized	2026-08-28 06:39:05.519355	\N	Person #235	0	unrecognized	2026-08-28 06:39:13.110534
79069	1918	breakout	385	Break Out	27-08-2026 13:41:21	331091	0.85	pending	2026-08-28 11:00:42.924929	\N	Person #385	\N	pending	\N
75233	1917	breakin	147	Break In	27-08-2026 11:12:37	108293	0.85	unrecognized	2026-08-28 06:38:59.995478	\N	Person #147	0	unrecognized	2026-08-28 06:39:14.607441
75441	1917	breakin	199	Break In	27-08-2026 11:20:55	120764	0.85	normal	2026-08-28 06:53:31.73519	STF-013	Muhammad Faizan	0.5122	recognized	2026-08-28 06:53:31.790237
75524	1916	attendance	362	Person Entered	27-08-2026 20:45:00	968630	0.85	unrecognized	2026-08-28 06:59:56.121175	\N	Person #362	0	unrecognized	2026-08-28 07:03:37.738262
75261	1917	breakin	113	Break In	27-08-2026 18:21:22	37057	0.85	normal	2026-08-28 06:40:04.573402	STF-020	Syed Jahazaib Ahmad Alvi	0.5969	recognized	2026-08-28 06:40:04.606313
78535	1918	breakout	226	Break Out	27-08-2026 12:33:48	225546	0.85	unrecognized	2026-08-28 10:33:03.708352	\N	Person #226	0	unrecognized	2026-08-28 10:33:14.956922
75556	1917	breakin	248	Break In	27-08-2026 11:36:04	143503	0.85	unrecognized	2026-08-28 07:02:19.740635	\N	Person #248	0	unrecognized	2026-08-28 07:02:19.831392
78531	1918	breakout	223	Break Out	27-08-2026 12:31:52	222753	0.85	normal	2026-08-28 10:32:55.717599	STF-013	Muhammad Faizan	0.5379	recognized	2026-08-28 10:32:56.503275
77823	1918	breakout	32	Break Out	27-08-2026 18:12:01	19946	0.85	unrecognized	2026-08-28 09:52:44.267388	\N	Person #32	0	unrecognized	2026-08-28 09:53:45.538447
75331	1916	attendance	273	Person Entered	27-08-2026 20:03:26	905124	0.85	unrecognized	2026-08-28 06:46:30.268279	\N	Person #273	0	unrecognized	2026-08-28 06:46:35.614721
75411	1917	breakin	146	Break In	27-08-2026 18:29:01	48540	0.85	normal	2026-08-28 06:51:45.199131	STF-008	Muhammad Shoaib	0.6038	recognized	2026-08-28 06:51:45.234039
79356	1949	attendance	33	Person Entered	28-08-2026 19:27:57	10742	0.85	unrecognized	2026-08-28 14:23:29.094435	\N	Person #33	0	unrecognized	2026-08-28 14:23:36.079608
78192	1918	breakout	157	Break Out	27-08-2026 19:11:22	108970	0.85	normal	2026-08-28 10:12:53.161161	STF-011	Syed Shoaib Ahmad Alvi	0.4913	recognized	2026-08-28 10:13:12.548092
78529	1918	breakout	222	Break Out	27-08-2026 12:31:46	222586	0.85	normal	2026-08-28 10:32:48.164027	STF-010	Faraz Younas	0.453	recognized	2026-08-28 10:32:53.661086
78526	1918	breakout	221	Break Out	27-08-2026 12:31:28	222115	0.85	normal	2026-08-28 10:32:43.392507	STF-017	Mohammad Zahid	0.4472	recognized	2026-08-28 10:32:45.052433
75606	1917	breakin	188	Break In	27-08-2026 18:40:00	65015	0.85	normal	2026-08-28 07:05:39.660501	STF-008	Muhammad Shoaib	0.577	recognized	2026-08-28 07:05:39.713359
75493	1916	attendance	348	Person Entered	27-08-2026 20:39:44	959542	0.85	unrecognized	2026-08-28 06:58:08.642255	\N	Person #348	0	unrecognized	2026-08-28 06:58:21.694029
78205	1918	breakout	166	Break Out	27-08-2026 19:12:36	110712	0.85	unrecognized	2026-08-28 10:13:26.91067	\N	Person #166	0	unrecognized	2026-08-28 10:13:30.886533
78533	1918	breakout	224	Break Out	27-08-2026 12:29:24	223470	0.85	pending	2026-08-28 10:32:59.999317	\N	Person #224	0	unrecognized	\N
78534	1918	breakout	225	Break Out	27-08-2026 12:30:31	225157	0.85	pending	2026-08-28 10:33:03.169844	\N	Person #225	\N	pending	\N
78542	1918	breakout	227	Break Out	27-08-2026 12:34:01	225983	0.85	unrecognized	2026-08-28 10:33:16.898436	\N	Person #227	0	unrecognized	2026-08-28 10:33:17.5405
78539	1918	breakout	226	Break Out	27-08-2026 12:33:55	225755	0.85	unrecognized	2026-08-28 10:33:15.22993	\N	Person #226	0	unrecognized	2026-08-28 10:33:16.402403
75559	1917	breakin	251	Break In	27-08-2026 11:37:39	145799	0.85	unrecognized	2026-08-28 07:02:36.169476	\N	Person #251	0	unrecognized	2026-08-28 07:02:50.0045
75587	1917	breakin	257	Break In	27-08-2026 11:46:56	159683	0.85	unrecognized	2026-08-28 07:04:42.931105	\N	Person #257	0	unrecognized	2026-08-28 07:04:59.417718
75563	1917	breakin	251	Break In	27-08-2026 11:40:16	149763	0.85	normal	2026-08-28 07:02:52.050941	STF-047	Arshad Irshad	0.4921	recognized	2026-08-28 07:02:56.368182
75615	1916	attendance	388	Person Entered	27-08-2026 20:50:54	976290	0.85	unrecognized	2026-08-28 07:06:24.655713	\N	Person #388	0	unrecognized	2026-08-28 07:06:45.215024
75582	1917	breakin	256	Break In	27-08-2026 11:46:50	159555	0.85	unrecognized	2026-08-28 07:04:21.888386	\N	Person #256	0	unrecognized	2026-08-28 07:04:42.447616
75634	1916	attendance	393	Person Entered	27-08-2026 20:51:34	977298	0.85	unrecognized	2026-08-28 07:07:35.298095	\N	Person #393	0	unrecognized	2026-08-28 07:07:47.267477
75655	1916	attendance	398	Person Entered	27-08-2026 20:52:11	978123	0.85	unrecognized	2026-08-28 07:08:38.193352	\N	Person #398	0	unrecognized	2026-08-28 07:09:41.260418
75698	1917	breakin	208	Break In	27-08-2026 18:53:00	85495	0.85	normal	2026-08-28 07:12:12.70863	STF-018	Muhammad Qaiser Shahzad	0.4602	recognized	2026-08-28 07:12:16.005377
75688	1917	breakin	206	Break In	27-08-2026 18:50:40	80916	0.85	unrecognized	2026-08-28 07:11:30.321839	\N	Person #206	0	unrecognized	2026-08-28 07:11:47.280531
76463	1917	breakin	503	Break In	27-08-2026 13:41:55	332478	0.85	pending	2026-08-28 08:05:56.717128	\N	Person #503	\N	pending	\N
75697	1917	breakin	207	Break In	27-08-2026 18:53:18	84947	0.85	normal	2026-08-28 07:12:00.061394	STF-007	Faisal Saleem	0.4568	recognized	2026-08-28 07:12:03.718075
75695	1917	breakin	207	Break In	27-08-2026 18:51:57	82885	0.85	normal	2026-08-28 07:11:48.705427	STF-009	Tariq Ghulam Hussain	0.4678	recognized	2026-08-28 07:11:54.402715
75700	1917	breakin	191	Break In	27-08-2026 14:24:31	38976	0.85	normal	2026-08-28 07:12:21.030821	STF-007	Faisal Saleem	0.4535	recognized	2026-08-28 07:12:21.079927
75246	1916	attendance	240	Person Entered	27-08-2026 19:46:46	880145	0.85	pending	2026-08-28 06:39:25.755691	\N	Person #240	\N	pending	\N
75599	1917	breakin	185	Break In	27-08-2026 18:39:38	64450	0.85	normal	2026-08-28 07:05:09.953864	STF-033	Raza Abbas	0.6515	recognized	2026-08-28 07:05:09.996749
75680	1916	checkout	405	check_out	27-08-2026 20:53:26	979827	0.85	normal	2026-08-28 07:11:01.884366	STF-025	Farhan Virk	0.4561	recognized	2026-08-28 07:14:46.19941
77835	1918	breakout	32	Break Out	27-08-2026 14:09:10	12646	0.85	unrecognized	2026-08-28 09:53:55.577732	\N	Person #32	0	unrecognized	2026-08-28 09:54:05.672571
78868	1918	breakout	315	Break Out	27-08-2026 13:10:51	281139	0.85	unrecognized	2026-08-28 10:48:44.937659	\N	Person #315	0	unrecognized	2026-08-28 10:49:11.825835
75529	1916	attendance	363	Person Entered	27-08-2026 20:46:00	968669	0.85	unrecognized	2026-08-28 07:00:12.474866	\N	Person #363	0	unrecognized	2026-08-28 07:03:55.186063
78191	1918	breakout	131	Break Out	27-08-2026 11:34:44	137067	0.85	normal	2026-08-28 10:12:48.881166	STF-028	Noman Imran	0.5616	recognized	2026-08-28 10:12:50.263511
77837	1918	breakout	32	Break Out	27-08-2026 14:09:25	13008	0.85	unrecognized	2026-08-28 09:54:06.031031	\N	Person #32	0	unrecognized	2026-08-28 09:54:22.848479
77832	1918	breakout	31	Break Out	27-08-2026 14:08:26	11601	0.85	normal	2026-08-28 09:53:39.98761	STF-035	Hammad Shaukat	0.4592	recognized	2026-08-28 09:53:42.812659
78193	1918	breakout	132	Break Out	27-08-2026 11:32:34	138475	0.85	pending	2026-08-28 10:12:53.636161	\N	Person #132	0	unrecognized	\N
75560	1917	breakin	164	Break In	27-08-2026 14:19:10	30873	0.85	unrecognized	2026-08-28 07:02:36.223097	\N	Person #164	0	unrecognized	2026-08-28 07:03:18.109355
79345	1949	attendance	21	check_in	28-08-2026 19:26:48	9108	0.85	normal	2026-08-28 14:22:56.298195	STF-010	Faraz Younas	0.4457	recognized	2026-08-28 14:22:58.863651
79358	1949	attendance	23	Person Entered	25-08-2026 19:02:21	10993	0.85	pending	2026-08-28 14:23:33.446347	\N	Person #23	\N	pending	\N
75248	1916	attendance	243	Person Entered	27-08-2026 19:48:00	882692	0.85	unrecognized	2026-08-28 06:39:30.390923	\N	Person #243	0	unrecognized	2026-08-28 06:39:40.069048
78195	1918	breakout	133	Break Out	27-08-2026 11:36:05	138985	0.85	unrecognized	2026-08-28 10:12:57.786498	\N	Person #133	0	unrecognized	2026-08-28 10:13:10.079014
75442	1916	attendance	318	Person Entered	27-08-2026 20:26:02	938663	0.85	unrecognized	2026-08-28 06:53:43.714345	\N	Person #318	0	unrecognized	2026-08-28 06:55:13.021733
77841	1918	breakout	33	Break Out	27-08-2026 14:10:17	14325	0.85	unrecognized	2026-08-28 09:54:23.737447	\N	Person #33	0	unrecognized	2026-08-28 09:54:41.756609
79362	1949	attendance	33	Person Entered	25-08-2026 19:02:32	11270	0.85	pending	2026-08-28 14:23:35.341843	\N	Person #33	\N	pending	\N
78206	1918	breakout	134	Break Out	27-08-2026 11:40:15	145202	0.85	unrecognized	2026-08-28 10:13:27.292523	\N	Person #134	0	unrecognized	2026-08-28 10:13:45.766473
78198	1918	breakout	133	Break Out	27-08-2026 11:37:44	141459	0.85	unrecognized	2026-08-28 10:13:11.183504	\N	Person #133	0	unrecognized	2026-08-28 10:13:25.157406
75333	1916	attendance	274	Person Entered	27-08-2026 20:05:27	908134	0.85	unrecognized	2026-08-28 06:46:41.00796	\N	Person #274	0	unrecognized	2026-08-28 06:46:57.241618
78863	1918	breakout	308	Break Out	27-08-2026 13:09:55	279768	0.85	unrecognized	2026-08-28 10:48:39.622907	\N	Person #308	0	unrecognized	2026-08-28 10:48:39.977963
79364	1949	attendance	33	check_out	28-08-2026 19:28:30	11613	0.85	normal	2026-08-28 14:23:35.80235	STF-011	Syed Shoaib Ahmad Alvi	0.4527	recognized	2026-08-28 14:23:46.857442
75607	1917	breakin	261	Break In	27-08-2026 11:50:21	164895	0.85	normal	2026-08-28 07:05:50.381341	STF-004	Tanveer Hassan	0.5324	recognized	2026-08-28 07:05:53.399377
79524	1951	breakout	123	Break Out	25-08-2026 19:03:36	12782	0.85	normal	2026-08-28 14:36:52.300094	STF-011	Syed Shoaib Ahmad Alvi	0.483	recognized	2026-08-28 14:36:52.517743
75589	1917	breakin	182	Break In	27-08-2026 18:39:25	64100	0.85	normal	2026-08-28 07:04:44.564187	STF-007	Faisal Saleem	0.4549	recognized	2026-08-28 07:04:47.18347
75478	1917	breakin	105	Break In	27-08-2026 14:18:09	27676	0.85	normal	2026-08-28 06:56:23.183794	STF-007	Faisal Saleem	0.4941	recognized	2026-08-28 07:00:52.916399
78874	1918	breakout	316	Break Out	27-08-2026 13:11:02	281460	0.85	unrecognized	2026-08-28 10:49:13.362604	\N	Person #316	0	unrecognized	2026-08-28 10:49:13.704588
78875	1918	breakout	316	Break Out	27-08-2026 13:11:52	282747	0.85	unrecognized	2026-08-28 10:49:14.429455	\N	Person #316	0	unrecognized	2026-08-28 10:49:14.782549
75586	1917	breakin	180	Break In	27-08-2026 18:38:11	62298	0.85	normal	2026-08-28 07:04:40.850117	STF-045	Zohaib Ali Chaudhary	0.5424	recognized	2026-08-28 07:04:40.914944
75641	1917	breakin	171	Break In	27-08-2026 14:21:53	34875	0.85	normal	2026-08-28 07:07:49.551441	STF-025	Farhan Virk	0.4616	recognized	2026-08-28 07:08:22.417306
75621	1917	breakin	168	Break In	27-08-2026 14:20:43	33271	0.85	normal	2026-08-28 07:06:50.648262	STF-010	Faraz Younas	0.4496	recognized	2026-08-28 07:06:52.484682
75623	1917	breakin	169	Break In	27-08-2026 14:20:53	33533	0.85	normal	2026-08-28 07:07:02.283017	STF-025	Farhan Virk	0.4976	recognized	2026-08-28 07:07:02.31693
75660	1916	attendance	399	Person Entered	27-08-2026 20:52:00	978220	0.85	unrecognized	2026-08-28 07:09:15.0732	\N	Person #399	0	unrecognized	2026-08-28 07:10:19.220839
75670	1916	attendance	404	Person Entered	27-08-2026 20:52:40	978861	0.85	unrecognized	2026-08-28 07:10:23.051054	\N	Person #404	0	unrecognized	2026-08-28 07:10:59.294546
75701	1917	breakin	209	Break In	27-08-2026 18:54:09	86135	0.85	unrecognized	2026-08-28 07:12:22.975853	\N	Person #209	0	unrecognized	2026-08-28 07:12:51.508707
75717	1917	breakin	197	Break In	27-08-2026 14:25:58	40975	0.85	normal	2026-08-28 07:13:34.641525	STF-025	Farhan Virk	0.4463	recognized	2026-08-28 07:14:02.127369
79351	1949	attendance	31	Person Entered	25-08-2026 19:01:30	9713	0.85	pending	2026-08-28 14:23:26.623632	\N	Person #31	\N	pending	\N
78546	1918	breakout	228	Break Out	27-08-2026 12:34:33	226706	0.85	normal	2026-08-28 10:33:21.537614	STF-013	Muhammad Faizan	0.5347	recognized	2026-08-28 10:33:42.974474
75260	1917	breakin	149	Break In	27-08-2026 11:14:20	110411	0.85	unrecognized	2026-08-28 06:40:03.411988	\N	Person #149	0	unrecognized	2026-08-28 06:41:19.779337
75571	1917	breakin	176	Break In	27-08-2026 18:37:07	60671	0.85	unrecognized	2026-08-28 07:03:31.574759	\N	Person #176	0	unrecognized	2026-08-28 07:03:31.608668
75530	1917	breakin	236	Break In	27-08-2026 11:26:56	129772	0.85	normal	2026-08-28 07:00:15.694932	STF-028	Noman Imran	0.4652	recognized	2026-08-28 07:00:18.025599
79352	1949	attendance	33	Person Entered	28-08-2026 19:27:25	9911	0.85	unrecognized	2026-08-28 14:23:27.249313	\N	Person #33	0	unrecognized	2026-08-28 14:23:32.163834
75531	1917	breakin	237	Break In	27-08-2026 11:27:16	130289	0.85	normal	2026-08-28 07:00:23.054683	STF-006	Muhammad Abubakar	0.608	recognized	2026-08-28 07:00:23.072347
75532	1917	breakin	238	Break In	27-08-2026 11:27:26	130543	0.85	normal	2026-08-28 07:00:29.726311	STF-033	Raza Abbas	0.5572	recognized	2026-08-28 07:00:29.75398
78207	1918	breakout	141	Break Out	27-08-2026 14:46:38	68943	0.85	normal	2026-08-28 10:13:31.013196	STF-028	Noman Imran	0.4836	recognized	2026-08-28 10:13:33.184113
75572	1917	breakin	177	Break In	27-08-2026 18:37:15	60868	0.85	unrecognized	2026-08-28 07:03:31.965464	\N	Person #177	0	unrecognized	2026-08-28 07:03:35.785936
75251	1917	breakin	149	Break In	27-08-2026 11:13:00	110010	0.85	unrecognized	2026-08-28 06:39:36.829559	\N	Person #149	0	unrecognized	2026-08-28 06:40:02.62427
75533	1917	breakin	239	Break In	27-08-2026 11:28:14	131738	0.85	normal	2026-08-28 07:00:37.841887	STF-048	Abdullah Sultan	0.4494	recognized	2026-08-28 07:00:40.271787
75972	1917	breakin	357	Break In	27-08-2026 12:35:07	232031	0.85	normal	2026-08-28 07:29:30.632262	STF-015	Liaqat Ali	0.6367	recognized	2026-08-28 07:29:34.768577
75362	1916	attendance	297	Person Entered	27-08-2026 20:11:00	917036	0.85	unrecognized	2026-08-28 06:48:41.214039	\N	Person #297	0	unrecognized	2026-08-28 06:48:49.112175
75240	1917	breakin	148	Break In	27-08-2026 11:13:08	108773	0.85	unrecognized	2026-08-28 06:39:16.008807	\N	Person #148	0	unrecognized	2026-08-28 06:39:34.743671
75366	1916	attendance	297	Person Entered	27-08-2026 20:11:55	917870	0.85	pending	2026-08-28 06:48:50.654852	\N	Person #297	0	unrecognized	\N
78218	1918	breakout	144	Break Out	27-08-2026 14:47:30	70209	0.85	normal	2026-08-28 10:14:17.33044	STF-002	Abdur Rehman	0.5141	recognized	2026-08-28 10:14:24.466067
77838	1918	breakout	26	Break Out	27-08-2026 10:53:03	74452	0.85	normal	2026-08-28 09:54:14.082273	STF-023	Syed Zubair Zulfiqar	0.5697	recognized	2026-08-28 09:54:51.099262
75501	1917	breakin	219	Break In	27-08-2026 11:23:44	124884	0.85	normal	2026-08-28 06:58:41.239964	STF-035	Hammad Shaukat	0.4896	recognized	2026-08-28 06:58:55.232694
75477	1916	attendance	340	Person Entered	27-08-2026 20:32:38	948899	0.85	unrecognized	2026-08-28 06:56:20.647635	\N	Person #340	0	unrecognized	2026-08-28 06:56:40.014805
78862	1918	breakout	333	Break Out	27-08-2026 16:24:01	214923	0.85	unrecognized	2026-08-28 10:48:37.497567	\N	Person #333	0	unrecognized	2026-08-28 10:49:06.810494
75409	1916	attendance	304	Person Entered	27-08-2026 20:18:00	927574	0.85	unrecognized	2026-08-28 06:51:43.075855	\N	Person #304	0	unrecognized	2026-08-28 06:52:02.264662
78221	1918	breakout	146	Break Out	27-08-2026 14:48:06	71098	0.85	unrecognized	2026-08-28 10:14:27.880267	\N	Person #146	0	unrecognized	2026-08-28 10:14:30.876138
75973	1917	breakin	358	Break In	27-08-2026 12:35:10	232132	0.85	normal	2026-08-28 07:29:37.536662	STF-026	Syed Zeeshan Ali	0.6467	recognized	2026-08-28 07:29:37.551621
75498	1917	breakin	216	Break In	27-08-2026 11:23:35	124776	0.85	normal	2026-08-28 06:58:28.819188	STF-015	Liaqat Ali	0.5768	recognized	2026-08-28 06:58:28.864068
75448	1917	breakin	201	Break In	27-08-2026 11:21:14	121237	0.85	normal	2026-08-28 06:54:18.752967	STF-035	Hammad Shaukat	0.4559	recognized	2026-08-28 06:54:19.358704
75506	1917	breakin	222	Break In	27-08-2026 11:23:00	125095	0.85	normal	2026-08-28 06:58:57.168729	STF-013	Muhammad Faizan	0.5599	recognized	2026-08-28 06:58:57.246535
76021	1917	breakin	307	Break In	27-08-2026 19:14:31	116714	0.85	unrecognized	2026-08-28 07:34:29.203048	\N	Person #307	0	unrecognized	2026-08-28 07:34:29.61252
78873	1918	breakout	334	Break Out	27-08-2026 16:24:18	215314	0.85	unrecognized	2026-08-28 10:49:11.12146	\N	Person #334	0	unrecognized	2026-08-28 10:49:19.764564
75534	1917	breakin	240	Break In	27-08-2026 11:28:30	132148	0.85	normal	2026-08-28 07:00:45.2765	STF-006	Muhammad Abubakar	0.5309	recognized	2026-08-28 07:00:45.309567
75981	1917	breakin	362	Break In	27-08-2026 12:35:38	232844	0.85	normal	2026-08-28 07:30:09.373379	STF-005	Muhammad Ayaz Hussain	0.54	recognized	2026-08-28 07:30:13.739164
76022	1917	breakin	307	Break In	27-08-2026 19:14:39	116979	0.85	unrecognized	2026-08-28 07:34:29.958104	\N	Person #307	0	unrecognized	2026-08-28 07:34:30.019508
75536	1917	breakin	241	Break In	27-08-2026 11:28:39	132360	0.85	normal	2026-08-28 07:00:51.901033	STF-015	Liaqat Ali	0.6521	recognized	2026-08-28 07:00:51.917991
75537	1917	breakin	242	Break In	27-08-2026 11:28:39	132380	0.85	normal	2026-08-28 07:00:53.620615	STF-028	Noman Imran	0.5013	recognized	2026-08-28 07:00:53.646056
75542	1917	breakin	244	Break In	27-08-2026 11:29:13	133207	0.85	normal	2026-08-28 07:01:00.248309	STF-048	Abdullah Sultan	0.5829	recognized	2026-08-28 07:01:00.270883
78878	1918	breakout	336	Break Out	27-08-2026 16:26:02	217980	0.85	unrecognized	2026-08-28 10:49:21.437772	\N	Person #336	0	unrecognized	2026-08-28 10:49:29.832351
76023	1917	breakin	307	Break In	27-08-2026 19:14:00	117117	0.85	unrecognized	2026-08-28 07:34:30.502088	\N	Person #307	0	unrecognized	2026-08-28 07:34:30.901793
78880	1918	breakout	336	Break Out	27-08-2026 16:27:07	219662	0.85	unrecognized	2026-08-28 10:49:30.958171	\N	Person #336	0	unrecognized	2026-08-28 10:49:31.087825
79070	1918	breakout	386	Break Out	27-08-2026 13:44:13	331216	0.85	unrecognized	2026-08-28 11:00:43.565887	\N	Person #386	0	unrecognized	2026-08-28 11:00:53.463165
77840	1918	breakout	35	Break Out	27-08-2026 18:12:12	20191	0.85	unrecognized	2026-08-28 09:54:23.22719	\N	Person #35	0	unrecognized	2026-08-28 09:54:38.830672
78211	1918	breakout	169	Break Out	27-08-2026 19:12:55	111379	0.85	pending	2026-08-28 10:13:52.736826	\N	Person #169	0	unrecognized	\N
78861	1918	breakout	369	Break Out	27-08-2026 20:53:02	261409	0.85	unrecognized	2026-08-28 10:48:33.831431	\N	Person #369	0	unrecognized	2026-08-28 10:48:49.75987
78217	1918	breakout	171	Break Out	27-08-2026 19:13:52	112574	0.85	unrecognized	2026-08-28 10:14:15.063421	\N	Person #171	0	unrecognized	2026-08-28 10:14:33.852089
75269	1916	attendance	252	Person Entered	27-08-2026 19:55:00	892998	0.85	unrecognized	2026-08-28 06:40:44.354141	\N	Person #252	0	unrecognized	2026-08-28 06:40:55.085172
75247	1917	breakin	89	Break In	27-08-2026 14:09:06	15854	0.85	normal	2026-08-28 06:39:26.883401	STF-029	Abdul Rehman Sultan	0.4609	recognized	2026-08-28 06:39:29.877913
75335	1916	attendance	275	Person Entered	27-08-2026 20:05:39	908423	0.85	unrecognized	2026-08-28 06:46:59.218185	\N	Person #275	0	unrecognized	2026-08-28 06:47:14.838593
75263	1917	breakin	119	Break In	27-08-2026 18:21:54	37747	0.85	unrecognized	2026-08-28 06:40:15.62265	\N	Person #119	0	unrecognized	2026-08-28 06:40:24.745912
79532	1951	breakout	28	Break Out	25-08-2026 19:02:52	11670	0.85	normal	2026-08-28 14:37:18.841242	STF-010	Faraz Younas	0.5291	recognized	2026-08-28 14:37:18.882818
78216	1918	breakout	170	Break Out	27-08-2026 19:13:21	111987	0.85	unrecognized	2026-08-28 10:14:13.248347	\N	Person #170	0	unrecognized	2026-08-28 10:14:14.409754
75368	1916	attendance	298	Person Entered	27-08-2026 20:13:34	920287	0.85	unrecognized	2026-08-28 06:48:59.232253	\N	Person #298	0	unrecognized	2026-08-28 06:49:17.489875
79373	1950	breakin	42	Break In	25-08-2026 18:58:39	5417	0.85	unrecognized	2026-08-28 14:25:25.460727	\N	Person #42	0	unrecognized	2026-08-28 14:25:42.763277
75267	1916	attendance	251	Person Entered	27-08-2026 19:55:18	892835	0.85	unrecognized	2026-08-28 06:40:32.034362	\N	Person #251	0	unrecognized	2026-08-28 06:40:43.196635
75255	1916	attendance	247	Person Entered	27-08-2026 19:49:49	884706	0.85	unrecognized	2026-08-28 06:39:44.955061	\N	Person #247	0	unrecognized	2026-08-28 06:39:50.709346
78549	1918	breakout	269	Break Out	27-08-2026 20:09:00	196677	0.85	normal	2026-08-28 10:33:34.726446	STF-006	Muhammad Abubakar	0.4464	recognized	2026-08-28 10:33:37.696026
78551	1918	breakout	270	Break Out	27-08-2026 20:10:01	197046	0.85	pending	2026-08-28 10:33:38.861391	\N	Person #270	0	unrecognized	\N
75278	1917	breakin	149	Break In	27-08-2026 11:14:00	111041	0.85	unrecognized	2026-08-28 06:41:20.209001	\N	Person #149	0	unrecognized	2026-08-28 06:41:28.262604
75258	1916	attendance	248	Person Entered	27-08-2026 19:50:42	886005	0.85	unrecognized	2026-08-28 06:39:53.8724	\N	Person #248	0	unrecognized	2026-08-28 06:40:08.98009
75252	1917	breakin	91	Break In	27-08-2026 14:09:10	15951	0.85	normal	2026-08-28 06:39:38.992085	STF-007	Faisal Saleem	0.4708	recognized	2026-08-28 06:39:41.757743
75253	1917	breakin	92	Break In	27-08-2026 14:09:12	16004	0.85	normal	2026-08-28 06:39:42.790398	STF-025	Farhan Virk	0.5034	recognized	2026-08-28 06:39:42.814336
78552	1918	breakout	271	Break Out	27-08-2026 20:10:36	197901	0.85	pending	2026-08-28 10:33:42.120641	\N	Person #271	0	unrecognized	\N
75265	1916	attendance	251	Person Entered	27-08-2026 19:55:11	892688	0.85	unrecognized	2026-08-28 06:40:19.349316	\N	Person #251	0	unrecognized	2026-08-28 06:40:31.514123
75276	1917	breakin	122	Break In	27-08-2026 18:22:31	38678	0.85	unrecognized	2026-08-28 06:41:12.715606	\N	Person #122	0	unrecognized	2026-08-28 06:41:28.256621
78869	1918	breakout	370	Break Out	27-08-2026 20:54:02	263066	0.85	pending	2026-08-28 10:48:50.835276	\N	Person #370	0	unrecognized	\N
78871	1918	breakout	370	Break Out	27-08-2026 20:54:26	263484	0.85	unrecognized	2026-08-28 10:48:53.649056	\N	Person #370	0	unrecognized	2026-08-28 10:49:04.545074
75281	1917	breakin	103	Break In	27-08-2026 14:10:31	17996	0.85	normal	2026-08-28 06:41:29.873393	STF-007	Faisal Saleem	0.4726	recognized	2026-08-28 06:41:30.659792
75283	1917	breakin	151	Break In	27-08-2026 11:15:12	112190	0.85	normal	2026-08-28 06:41:36.69083	STF-037	Muhammad Fahad	0.6168	recognized	2026-08-28 06:41:36.722255
78872	1918	breakout	371	Break Out	27-08-2026 20:55:44	265494	0.85	unrecognized	2026-08-28 10:49:05.820997	\N	Person #371	0	unrecognized	2026-08-28 10:49:15.763527
75271	1916	attendance	254	Person Entered	27-08-2026 19:56:00	893912	0.85	unrecognized	2026-08-28 06:40:58.28078	\N	Person #254	0	unrecognized	2026-08-28 06:41:45.600038
75270	1917	breakin	121	Break In	27-08-2026 18:22:25	38481	0.85	unrecognized	2026-08-28 06:40:44.901419	\N	Person #121	0	unrecognized	2026-08-28 06:41:11.18825
78879	1918	breakout	374	Break Out	27-08-2026 20:56:01	265919	0.85	unrecognized	2026-08-28 10:49:27.082396	\N	Person #374	0	unrecognized	2026-08-28 10:49:31.309742
75289	1917	breakin	125	Break In	27-08-2026 18:23:57	40913	0.85	normal	2026-08-28 06:42:01.594403	STF-007	Faisal Saleem	0.4578	recognized	2026-08-28 06:42:12.126392
78877	1918	breakout	372	Break Out	27-08-2026 20:55:50	265716	0.85	unrecognized	2026-08-28 10:49:16.407235	\N	Person #372	0	unrecognized	2026-08-28 10:49:26.618208
75282	1917	breakin	104	Break In	27-08-2026 14:10:34	18020	0.85	normal	2026-08-28 06:41:31.624103	STF-025	Farhan Virk	0.4733	recognized	2026-08-28 06:41:39.153752
75286	1916	attendance	255	Person Entered	27-08-2026 19:57:00	896830	0.85	unrecognized	2026-08-28 06:41:50.456256	\N	Person #255	0	unrecognized	2026-08-28 06:42:10.778493
75291	1916	attendance	256	Person Entered	27-08-2026 19:58:00	897667	0.85	unrecognized	2026-08-28 06:42:13.532129	\N	Person #256	0	unrecognized	2026-08-28 06:42:37.530185
75297	1916	attendance	258	Person Entered	27-08-2026 19:59:00	899220	0.85	unrecognized	2026-08-28 06:42:41.734854	\N	Person #258	0	unrecognized	2026-08-28 06:42:43.205688
75300	1917	breakin	155	Break In	27-08-2026 11:16:00	113355	0.85	normal	2026-08-28 06:42:52.527957	STF-008	Muhammad Shoaib	0.4909	recognized	2026-08-28 06:43:03.913127
77842	1918	breakout	28	Break Out	27-08-2026 10:49:47	74488	0.85	pending	2026-08-28 09:54:34.375052	\N	Person #28	0	unrecognized	\N
79376	1950	breakin	43	Break In	25-08-2026 18:58:58	5816	0.85	unrecognized	2026-08-28 14:25:43.412536	\N	Person #43	0	unrecognized	2026-08-28 14:25:53.323354
79372	1950	breakin	41	Break In	25-08-2026 18:58:32	5289	0.85	unrecognized	2026-08-28 14:25:21.403445	\N	Person #41	0	unrecognized	2026-08-28 14:25:25.159328
76032	1917	breakin	311	Break In	27-08-2026 19:14:55	117158	0.85	unrecognized	2026-08-28 07:34:47.762355	\N	Person #311	0	unrecognized	2026-08-28 07:35:15.866862
75499	1916	attendance	350	Person Entered	27-08-2026 20:40:00	960725	0.85	unrecognized	2026-08-28 06:58:32.588093	\N	Person #350	0	unrecognized	2026-08-28 06:58:34.907181
79083	1918	breakout	389	Break Out	27-08-2026 13:44:00	331975	0.85	unrecognized	2026-08-28 11:01:17.32771	\N	Person #389	0	unrecognized	2026-08-28 11:01:18.79856
75417	1916	attendance	305	Person Entered	27-08-2026 20:20:30	930689	0.85	unrecognized	2026-08-28 06:52:07.927856	\N	Person #305	0	unrecognized	2026-08-28 06:52:25.526629
78550	1918	breakout	254	Break Out	27-08-2026 15:40:23	149436	0.85	unrecognized	2026-08-28 10:33:36.175174	\N	Person #254	0	unrecognized	2026-08-28 10:33:48.385992
75446	1917	breakin	148	Break In	27-08-2026 18:30:10	50266	0.85	normal	2026-08-28 06:54:17.702325	STF-008	Muhammad Shoaib	0.5447	recognized	2026-08-28 06:54:17.724266
78219	1918	breakout	137	Break Out	27-08-2026 11:42:08	148044	0.85	unrecognized	2026-08-28 10:14:21.305086	\N	Person #137	0	unrecognized	2026-08-28 10:14:37.541702
78557	1918	breakout	254	Break Out	27-08-2026 15:40:48	150119	0.85	unrecognized	2026-08-28 10:33:48.856143	\N	Person #254	0	unrecognized	2026-08-28 10:34:01.999188
78876	1918	breakout	316	Break Out	27-08-2026 13:12:19	283295	0.85	unrecognized	2026-08-28 10:49:15.261092	\N	Person #316	0	unrecognized	2026-08-28 10:49:29.69073
75980	1917	breakin	303	Break In	27-08-2026 19:14:08	115984	0.85	unrecognized	2026-08-28 07:30:05.086154	\N	Person #303	0	unrecognized	2026-08-28 07:31:18.245446
78210	1918	breakout	135	Break Out	27-08-2026 11:40:30	145644	0.85	unrecognized	2026-08-28 10:13:46.508198	\N	Person #135	0	unrecognized	2026-08-28 10:14:03.01482
78214	1918	breakout	137	Break Out	27-08-2026 11:40:43	145905	0.85	unrecognized	2026-08-28 10:14:03.862274	\N	Person #137	0	unrecognized	2026-08-28 10:14:20.333693
76256	1917	breakin	337	Break In	27-08-2026 14:41:13	64044	0.85	normal	2026-08-28 07:53:02.526616	STF-008	Muhammad Shoaib	0.7391	recognized	2026-08-28 07:53:02.57748
78559	1918	breakout	255	Break Out	27-08-2026 15:41:45	151514	0.85	unrecognized	2026-08-28 10:34:03.046588	\N	Person #255	0	unrecognized	2026-08-28 10:34:16.026508
75336	1917	breakin	134	Break In	27-08-2026 18:26:10	44224	0.85	normal	2026-08-28 06:47:03.278443	STF-011	Syed Shoaib Ahmad Alvi	0.4498	recognized	2026-08-28 06:47:07.050566
79529	1951	breakout	125	Break Out	25-08-2026 19:04:15	13718	0.85	normal	2026-08-28 14:37:03.138252	STF-011	Syed Shoaib Ahmad Alvi	0.4861	recognized	2026-08-28 14:37:11.186993
75374	1917	breakin	129	Break In	27-08-2026 14:15:22	25254	0.85	normal	2026-08-28 06:49:18.65278	STF-024	Arsalan Khan	0.4704	recognized	2026-08-28 06:49:18.6837
76076	1917	breakin	320	Break In	27-08-2026 19:20:37	125930	0.85	normal	2026-08-28 07:37:57.165763	STF-011	Syed Shoaib Ahmad Alvi	0.4631	recognized	2026-08-28 07:37:58.49804
79084	1918	breakout	389	Break Out	27-08-2026 13:44:52	332109	0.85	normal	2026-08-28 11:01:19.074438	STF-027	Ahmed Hassan Bhatti	0.5199	recognized	2026-08-28 11:01:22.49432
75541	1917	breakin	159	Break In	27-08-2026 14:18:36	30045	0.85	normal	2026-08-28 07:00:59.040762	STF-030	Dildar Ahmed	0.4854	recognized	2026-08-28 07:01:39.584186
76258	1917	breakin	338	Break In	27-08-2026 14:41:20	64186	0.85	normal	2026-08-28 07:53:08.454977	STF-028	Noman Imran	0.6531	recognized	2026-08-28 07:53:10.434265
75497	1916	attendance	349	Person Entered	27-08-2026 20:40:00	960475	0.85	unrecognized	2026-08-28 06:58:24.443999	\N	Person #349	0	unrecognized	2026-08-28 06:58:29.146413
75570	1917	breakin	253	Break In	27-08-2026 11:42:03	152374	0.85	unrecognized	2026-08-28 07:03:22.683146	\N	Person #253	0	unrecognized	2026-08-28 07:03:41.708659
75575	1917	breakin	255	Break In	27-08-2026 11:46:00	158318	0.85	unrecognized	2026-08-28 07:03:44.837495	\N	Person #255	0	unrecognized	2026-08-28 07:04:00.93073
76204	1916	attendance	555	Person Entered	27-08-2026 21:06:11	999073	0.85	unrecognized	2026-08-28 07:49:18.731883	\N	Person #555	0	unrecognized	2026-08-28 07:50:30.695658
76163	1916	attendance	548	Person Entered	27-08-2026 21:05:32	998013	0.85	unrecognized	2026-08-28 07:45:07.547973	\N	Person #548	0	unrecognized	2026-08-28 07:46:44.36917
76315	1916	attendance	584	Person Entered	27-08-2026 21:10:53	1006329	0.85	unrecognized	2026-08-28 07:56:00.662625	\N	Person #584	0	unrecognized	2026-08-28 07:56:01.804658
79216	1918	breakout	440	Break Out	27-08-2026 17:22:28	302631	0.85	normal	2026-08-28 11:07:47.460005	STF-027	Ahmed Hassan Bhatti	0.4477	recognized	2026-08-28 11:07:49.663007
76249	1917	breakin	334	Break In	27-08-2026 14:41:06	63835	0.85	normal	2026-08-28 07:52:37.376145	STF-026	Syed Zeeshan Ali	0.4621	recognized	2026-08-28 07:52:41.671663
76358	1916	attendance	613	Person Entered	27-08-2026 21:12:20	1008451	0.85	unrecognized	2026-08-28 07:58:10.732887	\N	Person #613	0	unrecognized	2026-08-28 07:58:45.322802
79222	1918	breakout	442	Break Out	27-08-2026 17:23:17	303873	0.85	unrecognized	2026-08-28 11:08:04.77011	\N	Person #442	0	unrecognized	2026-08-28 11:08:26.216397
76394	1916	attendance	634	Person Entered	27-08-2026 21:16:16	1014317	0.85	unrecognized	2026-08-28 08:01:06.913661	\N	Person #634	0	unrecognized	2026-08-28 08:01:45.731785
75585	1916	checkout	371	check_out	27-08-2026 20:47:28	971192	0.85	normal	2026-08-28 07:04:40.112044	STF-032	Muhammad Yaseen	0.5011	recognized	2026-08-28 07:04:40.602779
77845	1918	breakout	36	Break Out	27-08-2026 18:12:49	21056	0.85	normal	2026-08-28 09:54:46.027196	STF-035	Hammad Shaukat	0.5153	recognized	2026-08-28 09:54:51.317042
75545	1917	breakin	168	Break In	27-08-2026 18:34:51	57251	0.85	normal	2026-08-28 07:01:05.081401	STF-005	Muhammad Ayaz Hussain	0.5162	recognized	2026-08-28 07:01:08.000085
75667	1917	breakin	273	Break In	27-08-2026 12:01:11	181152	0.85	unrecognized	2026-08-28 07:10:05.854636	\N	Person #273	0	unrecognized	2026-08-28 07:10:13.738084
75375	1916	attendance	299	Person Entered	27-08-2026 20:13:41	920481	0.85	unrecognized	2026-08-28 06:49:19.029845	\N	Person #299	0	unrecognized	2026-08-28 06:49:29.067533
79368	1949	attendance	31	check_out	28-08-2026 19:29:07	12545	0.85	normal	2026-08-28 14:24:21.782074	STF-010	Faraz Younas	0.4489	recognized	2026-08-28 14:24:45.776994
75428	1917	breakin	191	Break In	27-08-2026 11:20:15	119771	0.85	normal	2026-08-28 06:52:48.367092	STF-008	Muhammad Shoaib	0.5499	recognized	2026-08-28 06:52:48.401667
75303	1917	breakin	129	Break In	27-08-2026 18:24:56	42258	0.85	unrecognized	2026-08-28 06:43:04.423206	\N	Person #129	0	unrecognized	2026-08-28 06:43:16.406404
78223	1918	breakout	147	Break Out	27-08-2026 14:49:07	72644	0.85	normal	2026-08-28 10:14:34.517231	STF-028	Noman Imran	0.4979	recognized	2026-08-28 10:14:36.24352
79371	1950	breakin	40	Break In	25-08-2026 18:58:22	5053	0.85	unrecognized	2026-08-28 14:25:13.892402	\N	Person #40	0	unrecognized	2026-08-28 14:25:21.094166
79370	1949	attendance	39	Person Entered	28-08-2026 19:30:41	14854	0.85	unrecognized	2026-08-28 14:25:00.43072	\N	Person #39	0	unrecognized	2026-08-28 14:25:15.779186
75419	1917	breakin	188	Break In	27-08-2026 11:19:37	118830	0.85	normal	2026-08-28 06:52:23.057355	STF-037	Muhammad Fahad	0.59	recognized	2026-08-28 06:52:23.110214
78238	1918	breakout	152	Break Out	27-08-2026 14:53:14	78771	0.85	unrecognized	2026-08-28 10:15:26.751755	\N	Person #152	0	unrecognized	2026-08-28 10:15:41.196879
75696	1917	breakin	277	Break In	27-08-2026 12:04:51	186556	0.85	unrecognized	2026-08-28 07:11:48.9377	\N	Person #277	0	unrecognized	2026-08-28 07:12:16.026874
75682	1917	breakin	275	Break In	27-08-2026 12:04:25	185925	0.85	unrecognized	2026-08-28 07:11:19.179755	\N	Person #275	0	unrecognized	2026-08-28 07:11:40.177655
78229	1918	breakout	149	Break Out	27-08-2026 14:50:37	74829	0.85	normal	2026-08-28 10:14:49.228389	STF-034	Muhammad Laeeq	0.4419	recognized	2026-08-28 10:15:00.328753
75502	1916	attendance	355	Person Entered	27-08-2026 20:42:00	963555	0.85	unrecognized	2026-08-28 06:58:42.55618	\N	Person #355	0	unrecognized	2026-08-28 06:58:48.763857
79531	1951	breakout	127	Break Out	25-08-2026 19:04:27	13742	0.85	normal	2026-08-28 14:37:10.294406	STF-049	Nabi Ul Haq	0.5045	recognized	2026-08-28 14:37:55.715325
75302	1917	breakin	128	Break In	27-08-2026 18:24:00	42191	0.85	normal	2026-08-28 06:43:00.547017	STF-029	Abdul Rehman Sultan	0.4997	recognized	2026-08-28 06:43:00.592895
75609	1917	breakin	167	Break In	27-08-2026 14:20:02	32272	0.85	normal	2026-08-28 07:06:00.071655	STF-029	Abdul Rehman Sultan	0.5874	recognized	2026-08-28 07:06:00.09655
75429	1917	breakin	193	Break In	27-08-2026 11:20:32	120134	0.85	normal	2026-08-28 06:52:52.98136	STF-006	Muhammad Abubakar	0.5362	recognized	2026-08-28 06:52:58.900609
78555	1918	breakout	229	Break Out	27-08-2026 12:35:15	227790	0.85	normal	2026-08-28 10:33:46.744213	STF-015	Liaqat Ali	0.595	recognized	2026-08-28 10:33:49.607048
78236	1918	breakout	151	Break Out	27-08-2026 14:52:32	77758	0.85	normal	2026-08-28 10:15:20.932787	STF-031	Muhammad Hassan	0.4598	recognized	2026-08-28 10:15:22.972883
75664	1917	breakin	271	Break In	27-08-2026 11:59:14	178165	0.85	unrecognized	2026-08-28 07:09:44.619379	\N	Person #271	0	unrecognized	2026-08-28 07:10:02.126514
75539	1917	breakin	165	Break In	27-08-2026 18:33:55	55869	0.85	normal	2026-08-28 07:00:56.1744	STF-030	Dildar Ahmed	0.4807	recognized	2026-08-28 07:00:57.604664
75573	1917	breakin	165	Break In	27-08-2026 14:19:28	31343	0.85	unrecognized	2026-08-28 07:03:34.727482	\N	Person #165	0	unrecognized	2026-08-28 07:03:58.879141
75483	1916	attendance	341	Person Entered	27-08-2026 20:33:19	949905	0.85	unrecognized	2026-08-28 06:56:41.809247	\N	Person #341	0	unrecognized	2026-08-28 06:57:03.88662
75661	1917	breakin	270	Break In	27-08-2026 11:58:42	177341	0.85	unrecognized	2026-08-28 07:09:15.984027	\N	Person #270	0	unrecognized	2026-08-28 07:09:43.544368
75642	1916	attendance	395	Person Entered	27-08-2026 20:51:33	977395	0.85	unrecognized	2026-08-28 07:07:49.868525	\N	Person #395	0	unrecognized	2026-08-28 07:08:09.756526
75707	1917	breakin	193	Break In	27-08-2026 14:25:13	40009	0.85	normal	2026-08-28 07:12:55.405285	STF-015	Liaqat Ali	0.4939	recognized	2026-08-28 07:13:00.083347
75620	1916	attendance	389	Person Entered	27-08-2026 20:51:23	976980	0.85	unrecognized	2026-08-28 07:06:47.850797	\N	Person #389	0	unrecognized	2026-08-28 07:07:15.230737
75709	1917	breakin	280	Break In	27-08-2026 12:09:18	193344	0.85	normal	2026-08-28 07:13:04.279145	STF-033	Raza Abbas	0.726	recognized	2026-08-28 07:13:04.304079
75691	1917	breakin	276	Break In	27-08-2026 12:04:35	186262	0.85	unrecognized	2026-08-28 07:11:40.87318	\N	Person #276	0	unrecognized	2026-08-28 07:11:46.068344
75708	1917	breakin	279	Break In	27-08-2026 12:08:13	191695	0.85	normal	2026-08-28 07:12:56.071187	STF-033	Raza Abbas	0.5311	recognized	2026-08-28 07:12:59.38689
78560	1918	breakout	230	Break Out	27-08-2026 12:35:48	228596	0.85	unrecognized	2026-08-28 10:34:08.053787	\N	Person #230	0	unrecognized	2026-08-28 10:34:11.265711
75702	1917	breakin	278	Break In	27-08-2026 12:07:14	190152	0.85	unrecognized	2026-08-28 07:12:36.525526	\N	Person #278	0	unrecognized	2026-08-28 07:12:54.273902
75710	1917	breakin	281	Break In	27-08-2026 12:09:24	193452	0.85	normal	2026-08-28 07:13:08.309782	STF-002	Abdur Rehman	0.5137	recognized	2026-08-28 07:13:13.647115
75686	1916	attendance	406	Person Entered	27-08-2026 20:53:00	979879	0.85	unrecognized	2026-08-28 07:11:29.314863	\N	Person #406	0	unrecognized	2026-08-28 07:13:42.656943
75457	1916	attendance	320	Person Entered	27-08-2026 20:26:02	939047	0.85	pending	2026-08-28 06:55:12.448372	\N	Person #320	0	unrecognized	\N
75643	1917	breakin	265	Break In	27-08-2026 11:55:16	172296	0.85	unrecognized	2026-08-28 07:07:50.690839	\N	Person #265	0	unrecognized	2026-08-28 07:07:50.725768
77844	1918	breakout	34	Break Out	27-08-2026 14:10:38	14887	0.85	unrecognized	2026-08-28 09:54:42.472633	\N	Person #34	0	unrecognized	2026-08-28 09:54:54.478692
77850	1918	breakout	36	Break Out	27-08-2026 14:11:37	16374	0.85	unrecognized	2026-08-28 09:55:02.273831	\N	Person #36	0	unrecognized	2026-08-28 09:55:05.367911
77847	1918	breakout	35	Break Out	27-08-2026 14:11:23	16003	0.85	unrecognized	2026-08-28 09:54:55.379251	\N	Person #35	0	unrecognized	2026-08-28 09:54:59.204483
75554	1917	breakin	173	Break In	27-08-2026 18:35:49	58714	0.85	normal	2026-08-28 07:02:10.594183	STF-001	Ikram Hassan	0.4809	recognized	2026-08-28 07:02:13.100235
75376	1917	breakin	142	Break In	27-08-2026 18:28:25	47422	0.85	normal	2026-08-28 06:49:21.243301	STF-008	Muhammad Shoaib	0.473	recognized	2026-08-28 06:50:38.405833
75576	1916	checkout	364	check_out	27-08-2026 20:46:02	969034	0.85	normal	2026-08-28 07:03:56.343718	STF-031	Muhammad Hassan	0.4497	recognized	2026-08-28 07:03:57.486516
75485	1916	attendance	344	Person Entered	27-08-2026 20:35:14	952807	0.85	unrecognized	2026-08-28 06:57:08.702604	\N	Person #344	0	unrecognized	2026-08-28 06:57:24.322739
77852	1918	breakout	35	Break Out	27-08-2026 14:11:00	16555	0.85	unrecognized	2026-08-28 09:55:05.955281	\N	Person #35	0	unrecognized	2026-08-28 09:55:05.97423
78224	1918	breakout	174	Break Out	27-08-2026 19:14:05	112949	0.85	unrecognized	2026-08-28 10:14:34.689724	\N	Person #174	0	unrecognized	2026-08-28 10:15:46.246018
77851	1918	breakout	36	Break Out	27-08-2026 14:11:47	16555	0.85	unrecognized	2026-08-28 09:55:05.674447	\N	Person #36	0	unrecognized	2026-08-28 09:55:26.33707
75577	1916	attendance	367	Person Entered	27-08-2026 20:46:00	969062	0.85	unrecognized	2026-08-28 07:04:00.048122	\N	Person #367	0	unrecognized	2026-08-28 07:04:01.456891
78561	1918	breakout	231	Break Out	27-08-2026 12:36:12	229179	0.85	unrecognized	2026-08-28 10:34:11.990675	\N	Person #231	0	unrecognized	2026-08-28 10:34:19.439756
75345	1917	breakin	138	Break In	27-08-2026 18:27:33	46342	0.85	normal	2026-08-28 06:47:28.207229	STF-045	Zohaib Ali Chaudhary	0.4553	recognized	2026-08-28 06:47:28.250116
75298	1916	attendance	259	Person Entered	27-08-2026 19:59:35	899227	0.85	unrecognized	2026-08-28 06:42:43.939298	\N	Person #259	0	unrecognized	2026-08-28 06:43:28.524084
75580	1916	attendance	368	Person Entered	27-08-2026 20:46:04	969100	0.85	pending	2026-08-28 07:04:04.579962	\N	Person #368	\N	pending	\N
78897	1918	breakout	321	Break Out	27-08-2026 13:13:23	289266	0.85	pending	2026-08-28 10:50:16.256203	\N	Person #321	0	unrecognized	\N
78563	1918	breakout	232	Break Out	27-08-2026 12:36:00	229954	0.85	unrecognized	2026-08-28 10:34:20.583774	\N	Person #232	0	unrecognized	2026-08-28 10:34:31.424397
75505	1916	attendance	358	Person Entered	27-08-2026 20:43:00	965709	0.85	unrecognized	2026-08-28 06:58:52.968193	\N	Person #358	0	unrecognized	2026-08-28 06:59:15.202852
78881	1918	breakout	317	Break Out	27-08-2026 13:13:11	284640	0.85	unrecognized	2026-08-28 10:49:31.130221	\N	Person #317	0	unrecognized	2026-08-28 10:49:43.507049
75355	1917	breakin	140	Break In	27-08-2026 18:27:51	46789	0.85	normal	2026-08-28 06:48:08.473027	STF-008	Muhammad Shoaib	0.486	recognized	2026-08-28 06:48:08.52312
75353	1917	breakin	139	Break In	27-08-2026 18:27:50	46756	0.85	normal	2026-08-28 06:47:54.852167	STF-007	Faisal Saleem	0.4767	recognized	2026-08-28 06:47:54.888072
75425	1916	attendance	313	Person Entered	27-08-2026 20:23:41	935459	0.85	unrecognized	2026-08-28 06:52:40.901125	\N	Person #313	0	unrecognized	2026-08-28 06:53:03.130368
75420	1916	attendance	306	Person Entered	27-08-2026 20:21:47	932659	0.85	unrecognized	2026-08-28 06:52:28.986794	\N	Person #306	0	unrecognized	2026-08-28 06:52:29.200695
75424	1916	attendance	312	Person Entered	27-08-2026 20:22:14	933350	0.85	pending	2026-08-28 06:52:36.882295	\N	Person #312	\N	pending	\N
78896	1918	breakout	320	Break Out	27-08-2026 13:15:57	288831	0.85	normal	2026-08-28 10:50:11.591513	STF-034	Muhammad Laeeq	0.4783	recognized	2026-08-28 10:50:14.678201
75459	1916	attendance	327	Person Entered	27-08-2026 20:26:36	939827	0.85	unrecognized	2026-08-28 06:55:22.631668	\N	Person #327	0	unrecognized	2026-08-28 06:55:43.733673
78891	1918	breakout	319	Break Out	27-08-2026 13:14:32	286678	0.85	unrecognized	2026-08-28 10:49:59.852266	\N	Person #319	0	unrecognized	2026-08-28 10:50:10.410361
78898	1918	breakout	322	Break Out	27-08-2026 13:14:26	290840	0.85	pending	2026-08-28 10:50:19.843556	\N	Person #322	\N	pending	\N
75611	1916	attendance	383	Person Entered	27-08-2026 20:49:42	974509	0.85	unrecognized	2026-08-28 07:06:06.771496	\N	Person #383	0	unrecognized	2026-08-28 07:06:13.53531
75644	1917	breakin	265	Break In	27-08-2026 11:55:27	172465	0.85	unrecognized	2026-08-28 07:07:51.184299	\N	Person #265	0	unrecognized	2026-08-28 07:07:56.684211
75631	1917	breakin	265	Break In	27-08-2026 11:54:53	171347	0.85	unrecognized	2026-08-28 07:07:18.361782	\N	Person #265	0	unrecognized	2026-08-28 07:07:39.360702
75636	1917	breakin	265	Break In	27-08-2026 11:54:46	171763	0.85	pending	2026-08-28 07:07:39.987807	\N	Person #265	\N	pending	\N
75649	1917	breakin	269	Break In	27-08-2026 11:56:26	174036	0.85	normal	2026-08-28 07:08:21.606621	STF-004	Tanveer Hassan	0.596	recognized	2026-08-28 07:08:22.038258
75651	1917	breakin	270	Break In	27-08-2026 11:57:36	175690	0.85	unrecognized	2026-08-28 07:08:26.594322	\N	Person #270	0	unrecognized	2026-08-28 07:08:50.048166
75663	1917	breakin	199	Break In	27-08-2026 18:43:00	70674	0.85	normal	2026-08-28 07:09:35.760875	STF-032	Muhammad Yaseen	0.4811	recognized	2026-08-28 07:09:42.737086
75662	1917	breakin	198	Break In	27-08-2026 18:43:00	70592	0.85	normal	2026-08-28 07:09:26.668462	STF-031	Muhammad Hassan	0.4848	recognized	2026-08-28 07:09:31.938511
75656	1917	breakin	270	Break In	27-08-2026 11:58:21	176819	0.85	unrecognized	2026-08-28 07:08:51.265903	\N	Person #270	0	unrecognized	2026-08-28 07:09:15.229332
75666	1917	breakin	201	Break In	27-08-2026 18:44:38	71962	0.85	normal	2026-08-28 07:10:02.277658	STF-005	Muhammad Ayaz Hussain	0.4468	recognized	2026-08-28 07:10:03.511763
75719	1917	breakin	212	Break In	27-08-2026 18:55:10	87765	0.85	normal	2026-08-28 07:13:39.884873	STF-032	Muhammad Yaseen	0.5825	recognized	2026-08-28 07:13:39.911707
76026	1917	breakin	379	Break In	27-08-2026 12:46:31	249150	0.85	unrecognized	2026-08-28 07:34:31.363002	\N	Person #379	0	unrecognized	2026-08-28 07:34:32.25399
77867	1918	breakout	42	Break Out	27-08-2026 14:14:33	20756	0.85	unrecognized	2026-08-28 09:55:41.257163	\N	Person #42	0	unrecognized	2026-08-28 09:55:45.409971
76027	1917	breakin	380	Break In	27-08-2026 12:46:25	249237	0.85	pending	2026-08-28 07:34:32.904187	\N	Person #380	\N	pending	\N
77863	1918	breakout	41	Break Out	27-08-2026 14:13:53	19807	0.85	unrecognized	2026-08-28 09:55:39.253355	\N	Person #41	0	unrecognized	2026-08-28 09:55:39.870798
76122	1917	breakin	333	Break In	27-08-2026 19:27:10	135739	0.85	normal	2026-08-28 07:41:43.427908	STF-044	Zaheer Hussain	0.4812	recognized	2026-08-28 07:41:44.322597
75725	1917	breakin	216	Break In	27-08-2026 18:55:26	87979	0.85	normal	2026-08-28 07:14:01.70843	STF-007	Faisal Saleem	0.4944	recognized	2026-08-28 07:14:26.958267
77866	1918	breakout	42	Break Out	27-08-2026 14:14:01	20033	0.85	pending	2026-08-28 09:55:40.431459	\N	Person #42	\N	pending	\N
76080	1916	attendance	531	Person Entered	27-08-2026 21:04:31	996320	0.85	unrecognized	2026-08-28 07:38:11.767646	\N	Person #531	0	unrecognized	2026-08-28 07:43:24.626009
76029	1917	breakin	381	Break In	27-08-2026 12:47:02	249934	0.85	normal	2026-08-28 07:34:34.357254	STF-046	Usman Babar	0.4761	recognized	2026-08-28 07:34:34.83391
76891	1917	breakin	546	Break In	27-08-2026 20:38:06	242146	0.85	normal	2026-08-28 08:34:46.34966	STF-001	Ikram Hassan	0.4582	recognized	2026-08-28 08:34:48.798377
77869	1918	breakout	42	Break Out	27-08-2026 14:14:40	20959	0.85	unrecognized	2026-08-28 09:55:46.032586	\N	Person #42	0	unrecognized	2026-08-28 09:55:46.658482
76164	1917	breakin	429	Break In	27-08-2026 13:13:12	289165	0.85	unrecognized	2026-08-28 07:45:24.456256	\N	Person #429	0	unrecognized	2026-08-28 07:45:25.474122
77872	1918	breakout	43	Break Out	27-08-2026 14:14:49	21117	0.85	unrecognized	2026-08-28 09:55:47.516905	\N	Person #43	0	unrecognized	2026-08-28 09:55:52.687779
76128	1917	breakin	335	Break In	27-08-2026 19:27:00	136603	0.85	normal	2026-08-28 07:42:12.653547	STF-011	Syed Shoaib Ahmad Alvi	0.5086	recognized	2026-08-28 07:42:14.064059
76172	1917	breakin	435	Break In	27-08-2026 13:16:17	293812	0.85	normal	2026-08-28 07:45:52.814811	STF-033	Raza Abbas	0.5046	recognized	2026-08-28 07:45:56.28113
76036	1917	breakin	385	Break In	27-08-2026 12:49:23	253434	0.85	unrecognized	2026-08-28 07:34:55.978132	\N	Person #385	0	unrecognized	2026-08-28 07:35:03.342649
76037	1917	breakin	385	Break In	27-08-2026 12:49:16	253502	0.85	pending	2026-08-28 07:35:04.406049	\N	Person #385	\N	pending	\N
76031	1917	breakin	381	Break In	27-08-2026 12:48:00	252290	0.85	normal	2026-08-28 07:34:40.295917	STF-026	Syed Zeeshan Ali	0.4895	recognized	2026-08-28 07:34:46.116095
75959	1916	attendance	511	Person Entered	27-08-2026 21:03:23	994872	0.85	unrecognized	2026-08-28 07:28:21.621015	\N	Person #511	0	unrecognized	2026-08-28 07:29:39.023766
77860	1918	breakout	39	Break Out	27-08-2026 14:12:27	17565	0.85	unrecognized	2026-08-28 09:55:31.926458	\N	Person #39	0	unrecognized	2026-08-28 09:55:37.449813
76165	1917	breakin	431	Break In	27-08-2026 13:13:21	289413	0.85	unrecognized	2026-08-28 07:45:26.19317	\N	Person #431	0	unrecognized	2026-08-28 07:45:27.021961
76033	1917	breakin	382	Break In	27-08-2026 12:48:54	252726	0.85	unrecognized	2026-08-28 07:34:51.436421	\N	Person #382	0	unrecognized	2026-08-28 07:34:52.448528
77862	1918	breakout	40	Break Out	27-08-2026 14:13:35	19376	0.85	pending	2026-08-28 09:55:38.586212	\N	Person #40	\N	pending	\N
76167	1917	breakin	432	Break In	27-08-2026 13:14:24	291219	0.85	pending	2026-08-28 07:45:28.347891	\N	Person #432	\N	pending	\N
75977	1916	attendance	516	Person Entered	27-08-2026 21:03:31	995199	0.85	unrecognized	2026-08-28 07:29:52.514902	\N	Person #516	0	unrecognized	2026-08-28 07:30:18.245048
76121	1917	breakin	332	Break In	27-08-2026 19:27:00	135509	0.85	normal	2026-08-28 07:41:40.610702	STF-028	Noman Imran	0.4937	recognized	2026-08-28 07:41:41.916449
76176	1917	breakin	438	Break In	27-08-2026 13:17:00	296042	0.85	normal	2026-08-28 07:46:03.66149	STF-033	Raza Abbas	0.6467	recognized	2026-08-28 07:46:03.682433
77875	1918	breakout	43	Break Out	27-08-2026 14:15:02	21458	0.85	unrecognized	2026-08-28 09:55:54.781473	\N	Person #43	0	unrecognized	2026-08-28 09:56:02.507113
77879	1918	breakout	42	Break Out	27-08-2026 14:15:23	21981	0.85	unrecognized	2026-08-28 09:56:03.525447	\N	Person #42	0	unrecognized	2026-08-28 09:56:06.791224
76178	1917	breakin	439	Break In	27-08-2026 13:17:48	296319	0.85	pending	2026-08-28 07:46:08.866384	\N	Person #439	\N	pending	\N
76179	1917	breakin	441	Break In	27-08-2026 13:18:03	296681	0.85	pending	2026-08-28 07:46:09.553325	\N	Person #441	\N	pending	\N
76181	1917	breakin	441	Break In	27-08-2026 13:19:53	299184	0.85	normal	2026-08-28 07:46:10.73683	STF-027	Ahmed Hassan Bhatti	0.4548	recognized	2026-08-28 07:46:14.343577
76207	1917	breakin	458	Break In	27-08-2026 13:28:30	312148	0.85	normal	2026-08-28 07:49:30.81557	STF-017	Mohammad Zahid	0.5135	recognized	2026-08-28 07:49:31.554313
76210	1917	breakin	459	Break In	27-08-2026 13:29:16	313301	0.85	normal	2026-08-28 07:49:58.854552	STF-024	Arsalan Khan	0.5103	recognized	2026-08-28 07:49:58.905415
76211	1917	breakin	460	Break In	27-08-2026 13:31:27	316478	0.85	unrecognized	2026-08-28 07:50:04.822209	\N	Person #460	0	unrecognized	2026-08-28 07:50:33.120608
76260	1917	breakin	469	Break In	27-08-2026 13:33:47	319926	0.85	unrecognized	2026-08-28 07:53:09.43715	\N	Person #469	0	unrecognized	2026-08-28 07:53:44.240691
76316	1916	attendance	586	Person Entered	27-08-2026 21:10:56	1006342	0.85	unrecognized	2026-08-28 07:56:03.020537	\N	Person #586	0	unrecognized	2026-08-28 07:56:28.85172
76362	1916	attendance	614	Person Entered	27-08-2026 21:13:00	1009483	0.85	unrecognized	2026-08-28 07:58:50.536701	\N	Person #614	0	unrecognized	2026-08-28 07:59:03.333352
76402	1917	breakin	493	Break In	27-08-2026 13:41:36	332005	0.85	unrecognized	2026-08-28 08:01:34.871267	\N	Person #493	0	unrecognized	2026-08-28 08:01:40.451189
75722	1917	breakin	285	Break In	27-08-2026 12:13:10	199141	0.85	normal	2026-08-28 07:13:48.27855	STF-028	Noman Imran	0.577	recognized	2026-08-28 07:13:48.337422
76409	1917	breakin	409	Break In	27-08-2026 19:58:00	183155	0.85	normal	2026-08-28 08:02:14.759585	STF-044	Zaheer Hussain	0.4994	recognized	2026-08-28 08:02:17.194533
75970	1916	checkout	514	check_out	27-08-2026 21:03:23	995048	0.85	normal	2026-08-28 07:29:26.094769	STF-040	Arslan Nadeem	0.4492	recognized	2026-08-28 07:29:37.173623
76087	1917	breakin	400	Break In	27-08-2026 13:00:00	270415	0.85	normal	2026-08-28 07:38:31.449313	STF-023	Syed Zubair Zulfiqar	0.4711	recognized	2026-08-28 07:38:49.649951
76173	1917	breakin	308	Break In	27-08-2026 14:37:00	58750	0.85	normal	2026-08-28 07:45:58.950951	STF-011	Syed Shoaib Ahmad Alvi	0.5263	recognized	2026-08-28 07:45:58.974886
76363	1916	attendance	615	Person Entered	27-08-2026 21:13:11	1009742	0.85	unrecognized	2026-08-28 07:59:04.727638	\N	Person #615	0	unrecognized	2026-08-28 07:59:18.581695
77885	1918	breakout	43	Break Out	27-08-2026 18:14:09	23181	0.85	unrecognized	2026-08-28 09:56:16.859154	\N	Person #43	0	unrecognized	2026-08-28 09:56:22.444576
78569	1918	breakout	257	Break Out	27-08-2026 15:43:46	154559	0.85	unrecognized	2026-08-28 10:34:35.871586	\N	Person #257	0	unrecognized	2026-08-28 10:34:49.546887
75723	1917	breakin	287	Break In	27-08-2026 12:13:33	199697	0.85	normal	2026-08-28 07:13:53.791092	STF-034	Muhammad Laeeq	0.4544	recognized	2026-08-28 07:13:58.173929
78583	1918	breakout	259	Break Out	27-08-2026 15:47:17	159820	0.85	unrecognized	2026-08-28 10:35:22.796212	\N	Person #259	0	unrecognized	2026-08-28 10:35:37.727102
78237	1918	breakout	142	Break Out	27-08-2026 11:46:49	155167	0.85	unrecognized	2026-08-28 10:15:21.212371	\N	Person #142	0	unrecognized	2026-08-28 10:15:27.494914
78565	1918	breakout	256	Break Out	27-08-2026 15:42:35	152838	0.85	normal	2026-08-28 10:34:30.388895	STF-044	Zaheer Hussain	0.4516	recognized	2026-08-28 10:34:32.314931
76090	1917	breakin	401	Break In	27-08-2026 13:00:58	270832	0.85	normal	2026-08-28 07:38:57.959083	STF-002	Abdur Rehman	0.4616	recognized	2026-08-28 07:39:02.1987
78230	1918	breakout	138	Break Out	27-08-2026 11:45:57	153811	0.85	unrecognized	2026-08-28 10:14:53.701478	\N	Person #138	0	unrecognized	2026-08-28 10:14:55.731001
76206	1917	breakin	317	Break In	27-08-2026 14:38:15	59580	0.85	normal	2026-08-28 07:49:29.280268	STF-029	Abdul Rehman Sultan	0.7216	recognized	2026-08-28 07:49:29.346626
76030	1916	attendance	527	Person Entered	27-08-2026 21:04:11	995956	0.85	unrecognized	2026-08-28 07:34:38.694069	\N	Person #527	0	unrecognized	2026-08-28 07:37:46.838062
79384	1950	breakin	46	Break In	25-08-2026 19:00:21	8101	0.85	normal	2026-08-28 14:26:34.015604	STF-025	Farhan Virk	0.5533	recognized	2026-08-28 14:26:34.04578
77876	1918	breakout	42	Break Out	27-08-2026 18:13:54	22642	0.85	unrecognized	2026-08-28 09:55:56.615748	\N	Person #42	0	unrecognized	2026-08-28 09:56:16.167653
75982	1916	attendance	517	Person Entered	27-08-2026 21:03:35	995240	0.85	unrecognized	2026-08-28 07:30:09.403051	\N	Person #517	0	unrecognized	2026-08-28 07:31:37.96861
78233	1918	breakout	140	Break Out	27-08-2026 11:46:26	154522	0.85	unrecognized	2026-08-28 10:15:09.890183	\N	Person #140	0	unrecognized	2026-08-28 10:15:16.43542
76261	1916	attendance	567	Person Entered	27-08-2026 21:09:12	1003616	0.85	unrecognized	2026-08-28 07:53:10.190214	\N	Person #567	0	unrecognized	2026-08-28 07:54:14.315331
76339	1917	breakin	386	Break In	27-08-2026 19:41:31	157290	0.85	normal	2026-08-28 07:56:57.496124	STF-045	Zohaib Ali Chaudhary	0.5161	recognized	2026-08-28 07:56:57.511084
78226	1918	breakout	138	Break Out	27-08-2026 11:45:47	153495	0.85	unrecognized	2026-08-28 10:14:40.309363	\N	Person #138	0	unrecognized	2026-08-28 10:14:53.348491
78231	1918	breakout	139	Break Out	27-08-2026 11:46:07	154017	0.85	unrecognized	2026-08-28 10:14:56.18907	\N	Person #139	0	unrecognized	2026-08-28 10:15:09.022409
76082	1917	breakin	398	Break In	27-08-2026 12:59:50	269079	0.85	normal	2026-08-28 07:38:16.260778	STF-007	Faisal Saleem	0.4493	recognized	2026-08-28 07:38:23.54437
78885	1918	breakout	337	Break Out	27-08-2026 16:27:39	220345	0.85	unrecognized	2026-08-28 10:49:32.758876	\N	Person #337	0	unrecognized	2026-08-28 10:49:48.069364
78573	1918	breakout	258	Break Out	27-08-2026 15:45:58	157850	0.85	unrecognized	2026-08-28 10:34:51.410106	\N	Person #258	0	unrecognized	2026-08-28 10:35:05.54799
76086	1917	breakin	399	Break In	27-08-2026 13:00:38	270348	0.85	normal	2026-08-28 07:38:29.014082	STF-024	Arsalan Khan	0.4438	recognized	2026-08-28 07:38:29.043008
76126	1916	attendance	538	Person Entered	27-08-2026 21:04:32	996658	0.85	unrecognized	2026-08-28 07:42:11.728012	\N	Person #538	0	unrecognized	2026-08-28 07:43:38.971555
78578	1918	breakout	258	Break Out	27-08-2026 15:46:22	158459	0.85	unrecognized	2026-08-28 10:35:09.521603	\N	Person #258	0	unrecognized	2026-08-28 10:35:21.929763
78576	1918	breakout	258	Break Out	27-08-2026 15:46:11	158163	0.85	unrecognized	2026-08-28 10:35:05.908507	\N	Person #258	0	unrecognized	2026-08-28 10:35:09.266092
76334	1917	breakin	384	Break In	27-08-2026 19:41:15	156895	0.85	normal	2026-08-28 07:56:52.483064	STF-044	Zaheer Hussain	0.498	recognized	2026-08-28 07:56:52.500382
78882	1918	breakout	336	Break Out	27-08-2026 16:27:26	220142	0.85	unrecognized	2026-08-28 10:49:31.54136	\N	Person #336	0	unrecognized	2026-08-28 10:49:32.128235
78890	1918	breakout	338	Break Out	27-08-2026 16:27:00	220615	0.85	unrecognized	2026-08-28 10:49:48.746926	\N	Person #338	0	unrecognized	2026-08-28 10:50:08.694285
79221	1918	breakout	482	Break Out	27-08-2026 21:26:56	312371	0.85	normal	2026-08-28 11:08:04.145515	STF-011	Syed Shoaib Ahmad Alvi	0.5947	recognized	2026-08-28 11:08:05.434502
76342	1917	breakin	387	Break In	27-08-2026 19:44:24	161588	0.85	normal	2026-08-28 07:57:04.733081	STF-049	Nabi Ul Haq	0.4547	recognized	2026-08-28 07:57:08.250025
79218	1918	breakout	480	Break Out	27-08-2026 21:26:30	311747	0.85	normal	2026-08-28 11:07:53.994628	STF-008	Muhammad Shoaib	0.4522	recognized	2026-08-28 11:07:55.482013
76452	1917	breakin	419	Break In	27-08-2026 14:49:18	76160	0.85	normal	2026-08-28 08:04:44.840783	STF-008	Muhammad Shoaib	0.4928	recognized	2026-08-28 08:04:44.876686
76346	1917	breakin	388	Break In	27-08-2026 19:44:54	162349	0.85	normal	2026-08-28 07:57:12.154324	STF-047	Arshad Irshad	0.5288	recognized	2026-08-28 07:57:14.199484
76456	1917	breakin	424	Break In	27-08-2026 14:49:54	77001	0.85	unrecognized	2026-08-28 08:05:02.40135	\N	Person #424	0	unrecognized	2026-08-28 08:05:05.768711
75724	1916	attendance	411	Person Entered	27-08-2026 20:53:23	980058	0.85	pending	2026-08-28 07:13:55.656644	\N	Person #411	0	unrecognized	\N
76170	1917	breakin	346	Break In	27-08-2026 19:28:21	137423	0.85	unrecognized	2026-08-28 07:45:39.405423	\N	Person #346	0	unrecognized	2026-08-28 07:46:05.709835
76365	1916	checkout	617	check_out	27-08-2026 21:15:44	1013575	0.85	normal	2026-08-28 07:59:25.499785	STF-007	Faisal Saleem	0.4579	recognized	2026-08-28 07:59:35.294636
76370	1916	attendance	626	Person Entered	27-08-2026 21:15:50	1013742	0.85	pending	2026-08-28 07:59:50.369329	\N	Person #626	0	unrecognized	\N
76135	1917	breakin	340	Break In	27-08-2026 19:29:07	137102	0.85	unrecognized	2026-08-28 07:42:58.828778	\N	Person #340	0	unrecognized	2026-08-28 07:50:33.061343
76450	1917	breakin	428	Break In	27-08-2026 20:03:24	190100	0.85	normal	2026-08-28 08:04:43.992722	STF-034	Muhammad Laeeq	0.6569	recognized	2026-08-28 08:04:44.013948
76132	1917	breakin	337	Break In	27-08-2026 19:28:02	137022	0.85	unrecognized	2026-08-28 07:42:20.916607	\N	Person #337	0	unrecognized	2026-08-28 07:42:33.62478
76408	1917	breakin	396	Break In	27-08-2026 14:47:31	73491	0.85	normal	2026-08-28 08:02:02.111978	STF-028	Noman Imran	0.4738	recognized	2026-08-28 08:02:02.578248
78239	1918	breakout	142	Break Out	27-08-2026 11:43:52	155378	0.85	pending	2026-08-28 10:15:28.739099	\N	Person #142	\N	pending	\N
76018	1916	attendance	526	Person Entered	27-08-2026 21:04:05	995884	0.85	unrecognized	2026-08-28 07:34:16.054534	\N	Person #526	0	unrecognized	2026-08-28 07:36:21.635564
75976	1916	attendance	515	Person Entered	27-08-2026 21:03:29	995182	0.85	unrecognized	2026-08-28 07:29:46.229492	\N	Person #515	0	unrecognized	2026-08-28 07:29:53.672681
76214	1917	breakin	322	Break In	27-08-2026 14:38:46	60246	0.85	unrecognized	2026-08-28 07:50:27.493513	\N	Person #322	0	unrecognized	2026-08-28 07:50:35.098043
76083	1917	breakin	284	Break In	27-08-2026 14:34:26	53856	0.85	unrecognized	2026-08-28 07:38:17.370828	\N	Person #284	0	unrecognized	2026-08-28 07:38:18.850263
77874	1918	breakout	35	Break Out	27-08-2026 10:54:32	76727	0.85	normal	2026-08-28 09:55:54.211942	STF-048	Abdullah Sultan	0.5618	recognized	2026-08-28 09:55:56.433546
76898	1917	breakin	657	Break In	27-08-2026 15:24:00	129289	0.85	normal	2026-08-28 08:34:58.853439	STF-033	Raza Abbas	0.6445	recognized	2026-08-28 08:34:58.874889
78242	1918	breakout	144	Break Out	27-08-2026 11:47:35	156233	0.85	unrecognized	2026-08-28 10:15:43.831781	\N	Person #144	0	unrecognized	2026-08-28 10:15:56.943194
76886	1917	breakin	654	Break In	27-08-2026 15:22:36	125981	0.85	unrecognized	2026-08-28 08:34:23.922151	\N	Person #654	0	unrecognized	2026-08-28 08:34:50.094277
76270	1917	breakin	343	Break In	27-08-2026 14:42:00	65198	0.85	normal	2026-08-28 07:53:36.600329	STF-028	Noman Imran	0.522	recognized	2026-08-28 07:53:36.634745
76092	1917	breakin	276	Break In	27-08-2026 14:35:13	54846	0.85	unrecognized	2026-08-28 07:39:08.304359	\N	Person #276	0	unrecognized	2026-08-28 07:39:11.208417
78240	1918	breakout	143	Break Out	27-08-2026 11:47:00	155393	0.85	unrecognized	2026-08-28 10:15:28.915205	\N	Person #143	0	unrecognized	2026-08-28 10:15:42.885791
77877	1918	breakout	36	Break Out	27-08-2026 10:54:00	76933	0.85	normal	2026-08-28 09:55:59.03656	STF-033	Raza Abbas	0.4736	recognized	2026-08-28 09:56:16.65869
77878	1918	breakout	37	Break Out	27-08-2026 10:54:00	76939	0.85	normal	2026-08-28 09:56:01.133583	STF-023	Syed Zubair Zulfiqar	0.4648	recognized	2026-08-28 09:56:29.195211
76893	1917	breakin	656	Break In	27-08-2026 15:23:15	127051	0.85	normal	2026-08-28 08:34:51.251297	STF-033	Raza Abbas	0.475	recognized	2026-08-28 08:34:53.31531
76271	1917	breakin	344	Break In	27-08-2026 14:42:00	65199	0.85	normal	2026-08-28 07:53:37.002883	STF-026	Syed Zeeshan Ali	0.4914	recognized	2026-08-28 07:53:37.48105
76229	1917	breakin	328	Break In	27-08-2026 14:39:53	62025	0.85	normal	2026-08-28 07:50:59.904894	STF-028	Noman Imran	0.4554	recognized	2026-08-28 07:51:04.248146
78248	1918	breakout	147	Break Out	27-08-2026 11:47:55	156821	0.85	unrecognized	2026-08-28 10:16:07.734439	\N	Person #147	0	unrecognized	2026-08-28 10:16:10.396255
76131	1917	breakin	336	Break In	27-08-2026 19:28:12	137004	0.85	unrecognized	2026-08-28 07:42:17.15803	\N	Person #336	0	unrecognized	2026-08-28 07:44:30.173122
76218	1917	breakin	323	Break In	27-08-2026 14:39:48	61887	0.85	normal	2026-08-28 07:50:37.406224	STF-029	Abdul Rehman Sultan	0.4501	recognized	2026-08-28 07:50:41.223408
78566	1918	breakout	232	Break Out	27-08-2026 12:37:07	230596	0.85	normal	2026-08-28 10:34:31.931416	STF-010	Faraz Younas	0.4592	recognized	2026-08-28 10:34:54.246153
76899	1917	breakin	658	Break In	27-08-2026 15:26:02	131258	0.85	normal	2026-08-28 08:35:04.385672	STF-034	Muhammad Laeeq	0.4742	recognized	2026-08-28 08:35:04.869463
76321	1917	breakin	477	Break In	27-08-2026 13:39:13	328050	0.85	unrecognized	2026-08-28 07:56:19.586726	\N	Person #477	0	unrecognized	2026-08-28 07:56:53.392495
76338	1917	breakin	479	Break In	27-08-2026 13:39:29	328544	0.85	unrecognized	2026-08-28 07:56:55.93216	\N	Person #479	0	unrecognized	2026-08-28 07:57:10.799989
76345	1917	breakin	480	Break In	27-08-2026 13:40:02	328648	0.85	unrecognized	2026-08-28 07:57:11.766288	\N	Person #480	0	unrecognized	2026-08-28 07:59:50.945208
76453	1917	breakin	429	Break In	27-08-2026 20:03:33	190273	0.85	normal	2026-08-28 08:04:48.1709	STF-007	Faisal Saleem	0.5601	recognized	2026-08-28 08:04:56.280588
75731	1917	breakin	217	Break In	27-08-2026 18:55:22	88065	0.85	normal	2026-08-28 07:14:20.030994	STF-008	Muhammad Shoaib	0.5041	recognized	2026-08-28 07:14:20.048946
77881	1918	breakout	46	Break Out	27-08-2026 14:15:33	22350	0.85	pending	2026-08-28 09:56:08.349408	\N	Person #46	\N	pending	\N
75738	1917	breakin	221	Break In	27-08-2026 18:55:41	88515	0.85	normal	2026-08-28 07:14:34.588065	STF-024	Arsalan Khan	0.462	recognized	2026-08-28 07:14:36.201926
75737	1917	breakin	294	Break In	27-08-2026 12:14:05	200431	0.85	unrecognized	2026-08-28 07:14:28.208583	\N	Person #294	0	unrecognized	2026-08-28 07:14:36.200929
75744	1917	breakin	297	Break In	27-08-2026 12:15:26	202531	0.85	normal	2026-08-28 07:14:48.640726	STF-034	Muhammad Laeeq	0.454	recognized	2026-08-28 07:14:55.835404
75736	1917	breakin	218	Break In	27-08-2026 18:55:30	88238	0.85	normal	2026-08-28 07:14:28.13027	STF-023	Syed Zubair Zulfiqar	0.4667	recognized	2026-08-28 07:14:30.886352
75984	1917	breakin	274	Break In	27-08-2026 14:32:30	50906	0.85	unrecognized	2026-08-28 07:30:24.458774	\N	Person #274	0	unrecognized	2026-08-28 07:30:54.174514
77884	1918	breakout	48	Break Out	27-08-2026 14:16:11	23190	0.85	unrecognized	2026-08-28 09:56:12.780198	\N	Person #48	0	unrecognized	2026-08-28 09:56:19.793678
78254	1918	breakout	160	Break Out	27-08-2026 14:57:32	85214	0.85	unrecognized	2026-08-28 10:16:22.930143	\N	Person #160	0	unrecognized	2026-08-28 10:16:30.761631
78245	1918	breakout	156	Break Out	27-08-2026 14:56:33	83759	0.85	unrecognized	2026-08-28 10:15:58.820663	\N	Person #156	0	unrecognized	2026-08-28 10:16:04.669573
77882	1918	breakout	46	Break Out	27-08-2026 14:15:42	22515	0.85	unrecognized	2026-08-28 09:56:08.687252	\N	Person #46	0	unrecognized	2026-08-28 09:56:10.21151
78251	1918	breakout	158	Break Out	27-08-2026 14:56:51	84210	0.85	unrecognized	2026-08-28 10:16:17.712224	\N	Person #158	0	unrecognized	2026-08-28 10:16:19.162291
77887	1918	breakout	49	Break Out	27-08-2026 14:16:24	23478	0.85	unrecognized	2026-08-28 09:56:20.40776	\N	Person #49	0	unrecognized	2026-08-28 09:56:34.783257
78252	1918	breakout	159	Break Out	27-08-2026 14:57:08	84716	0.85	pending	2026-08-28 10:16:19.814594	\N	Person #159	0	unrecognized	\N
77883	1918	breakout	47	Break Out	27-08-2026 14:16:03	23057	0.85	unrecognized	2026-08-28 09:56:10.937416	\N	Person #47	0	unrecognized	2026-08-28 09:56:12.085699
75749	1917	breakin	209	Break In	27-08-2026 14:26:45	42323	0.85	normal	2026-08-28 07:15:07.574463	STF-025	Farhan Virk	0.5746	recognized	2026-08-28 07:15:07.622843
78241	1918	breakout	155	Break Out	27-08-2026 14:56:19	83340	0.85	unrecognized	2026-08-28 10:15:43.657255	\N	Person #155	0	unrecognized	2026-08-28 10:15:58.11247
75755	1917	breakin	227	Break In	27-08-2026 18:56:19	89489	0.85	normal	2026-08-28 07:15:12.681117	STF-025	Farhan Virk	0.4437	recognized	2026-08-28 07:15:13.659666
75741	1917	breakin	216	Break In	27-08-2026 18:55:57	88809	0.85	normal	2026-08-28 07:14:40.467041	STF-007	Faisal Saleem	0.4494	recognized	2026-08-28 07:14:43.72714
75761	1917	breakin	300	Break In	27-08-2026 12:18:39	207338	0.85	normal	2026-08-28 07:15:35.472805	STF-010	Faraz Younas	0.4462	recognized	2026-08-28 07:15:40.574653
75747	1916	checkout	414	check_out	27-08-2026 20:53:27	980172	0.85	normal	2026-08-28 07:14:58.949568	STF-024	Arsalan Khan	0.7025	recognized	2026-08-28 07:14:58.992454
78571	1918	breakout	276	Break Out	27-08-2026 20:12:01	200033	0.85	normal	2026-08-28 10:34:48.124154	STF-005	Muhammad Ayaz Hussain	0.4655	recognized	2026-08-28 10:34:48.716504
75704	1916	checkout	408	check_out	27-08-2026 20:53:26	979963	0.85	normal	2026-08-28 07:12:40.071411	STF-024	Arsalan Khan	0.5632	recognized	2026-08-28 07:14:56.630183
75729	1917	breakin	200	Break In	27-08-2026 14:26:04	41307	0.85	normal	2026-08-28 07:14:17.769767	STF-029	Abdul Rehman Sultan	0.6384	recognized	2026-08-28 07:14:17.805857
75746	1916	checkout	413	check_out	27-08-2026 20:53:26	980140	0.85	normal	2026-08-28 07:14:52.99823	STF-024	Arsalan Khan	0.5843	recognized	2026-08-28 07:14:53.061357
78584	1918	breakout	284	Break Out	27-08-2026 20:16:49	207230	0.85	unrecognized	2026-08-28 10:35:24.681174	\N	Person #284	0	unrecognized	2026-08-28 10:35:24.706107
78574	1918	breakout	277	Break Out	27-08-2026 20:13:12	201796	0.85	unrecognized	2026-08-28 10:34:53.002477	\N	Person #277	0	unrecognized	2026-08-28 10:34:53.85002
78570	1918	breakout	275	Break Out	27-08-2026 20:11:28	199141	0.85	normal	2026-08-28 10:34:40.690232	STF-050	Hafeez-Ur-Rehman	0.4725	recognized	2026-08-28 10:34:45.086311
75763	1917	breakin	301	Break In	27-08-2026 12:18:00	207532	0.85	normal	2026-08-28 07:15:44.668382	STF-034	Muhammad Laeeq	0.4594	recognized	2026-08-28 07:15:44.685336
75758	1916	attendance	419	Person Entered	27-08-2026 20:54:16	981357	0.85	unrecognized	2026-08-28 07:15:29.057258	\N	Person #419	0	unrecognized	2026-08-28 07:15:44.675364
78575	1918	breakout	279	Break Out	27-08-2026 20:13:49	202646	0.85	unrecognized	2026-08-28 10:34:54.731167	\N	Person #279	0	unrecognized	2026-08-28 10:35:11.058759
75750	1917	breakin	298	Break In	27-08-2026 12:15:52	203200	0.85	normal	2026-08-28 07:15:08.428169	STF-033	Raza Abbas	0.5744	recognized	2026-08-28 07:15:08.463596
75739	1917	breakin	296	Break In	27-08-2026 12:14:50	201629	0.85	normal	2026-08-28 07:14:38.923501	STF-033	Raza Abbas	0.4583	recognized	2026-08-28 07:14:41.908202
78582	1918	breakout	282	Break Out	27-08-2026 20:14:29	203662	0.85	normal	2026-08-28 10:35:16.641261	STF-050	Hafeez-Ur-Rehman	0.5557	recognized	2026-08-28 10:35:20.412179
75753	1916	attendance	418	Person Entered	27-08-2026 20:53:57	980864	0.85	unrecognized	2026-08-28 07:15:12.222311	\N	Person #418	0	unrecognized	2026-08-28 07:15:26.139922
75762	1917	breakin	216	Break In	27-08-2026 14:27:18	43165	0.85	normal	2026-08-28 07:15:40.549718	STF-025	Farhan Virk	0.4978	recognized	2026-08-28 07:15:40.574653
75757	1917	breakin	211	Break In	27-08-2026 14:26:50	42457	0.85	normal	2026-08-28 07:15:25.119972	STF-029	Abdul Rehman Sultan	0.542	recognized	2026-08-28 07:15:25.171603
78886	1918	breakout	377	Break Out	27-08-2026 20:56:28	266613	0.85	unrecognized	2026-08-28 10:49:35.036128	\N	Person #377	0	unrecognized	2026-08-28 10:49:44.641439
75766	1916	attendance	420	Person Entered	27-08-2026 20:54:33	981903	0.85	unrecognized	2026-08-28 07:15:46.947831	\N	Person #420	0	unrecognized	2026-08-28 07:15:53.527668
78250	1918	breakout	178	Break Out	27-08-2026 19:15:29	115148	0.85	unrecognized	2026-08-28 10:16:15.866973	\N	Person #178	0	unrecognized	2026-08-28 10:16:28.096402
76216	1917	breakin	460	Break In	27-08-2026 13:32:11	317578	0.85	unrecognized	2026-08-28 07:50:34.456756	\N	Person #460	0	unrecognized	2026-08-28 07:50:38.360669
76219	1917	breakin	461	Break In	27-08-2026 13:32:02	317661	0.85	pending	2026-08-28 07:50:38.777556	\N	Person #461	\N	pending	\N
79085	1918	breakout	445	Break Out	27-08-2026 21:14:11	293170	0.85	unrecognized	2026-08-28 11:01:23.949007	\N	Person #445	0	unrecognized	2026-08-28 11:01:36.595142
75985	1916	attendance	518	Person Entered	27-08-2026 21:03:45	995267	0.85	unrecognized	2026-08-28 07:30:25.067415	\N	Person #518	0	unrecognized	2026-08-28 07:34:03.666989
77896	1918	breakout	40	Break Out	27-08-2026 10:55:40	78219	0.85	normal	2026-08-28 09:56:52.664172	STF-031	Muhammad Hassan	0.4425	recognized	2026-08-28 09:57:12.41735
78580	1918	breakout	236	Break Out	27-08-2026 12:39:21	233893	0.85	unrecognized	2026-08-28 10:35:13.063078	\N	Person #236	0	unrecognized	2026-08-28 10:35:28.197318
77901	1918	breakout	42	Break Out	27-08-2026 10:55:42	78526	0.85	normal	2026-08-28 09:57:14.496255	STF-032	Muhammad Yaseen	0.6591	recognized	2026-08-28 09:57:14.552104
77888	1918	breakout	37	Break Out	27-08-2026 10:55:01	77403	0.85	normal	2026-08-28 09:56:30.727962	STF-023	Syed Zubair Zulfiqar	0.4802	recognized	2026-08-28 09:56:34.491609
79082	1918	breakout	444	Break Out	27-08-2026 21:11:48	289650	0.85	normal	2026-08-28 11:01:17.292804	STF-013	Muhammad Faizan	0.4601	recognized	2026-08-28 11:01:20.223485
78894	1918	breakout	381	Break Out	27-08-2026 20:57:24	268030	0.85	normal	2026-08-28 10:50:07.584902	STF-033	Raza Abbas	0.5091	recognized	2026-08-28 10:50:22.281442
77907	1918	breakout	46	Break Out	27-08-2026 10:59:14	83785	0.85	normal	2026-08-28 09:57:23.272845	STF-045	Zohaib Ali Chaudhary	0.5084	recognized	2026-08-28 09:57:26.409453
78249	1918	breakout	177	Break Out	27-08-2026 19:14:52	114246	0.85	normal	2026-08-28 10:16:09.802073	STF-049	Nabi Ul Haq	0.4504	recognized	2026-08-28 10:16:12.704211
76085	1917	breakin	325	Break In	27-08-2026 19:25:05	132633	0.85	normal	2026-08-28 07:38:27.565308	STF-028	Noman Imran	0.6726	recognized	2026-08-28 07:38:27.587931
77904	1918	breakout	43	Break Out	27-08-2026 10:58:22	82464	0.85	unrecognized	2026-08-28 09:57:17.934017	\N	Person #43	0	unrecognized	2026-08-28 09:57:19.425375
78893	1918	breakout	380	Break Out	27-08-2026 20:57:19	267981	0.85	normal	2026-08-28 10:50:04.382323	STF-017	Mohammad Zahid	0.4987	recognized	2026-08-28 10:50:05.680484
76284	1917	breakin	362	Break In	27-08-2026 19:36:00	150081	0.85	normal	2026-08-28 07:54:09.866822	STF-045	Zohaib Ali Chaudhary	0.4739	recognized	2026-08-28 07:54:10.468138
76180	1916	attendance	549	Person Entered	27-08-2026 21:05:38	998255	0.85	unrecognized	2026-08-28 07:46:09.74836	\N	Person #549	0	unrecognized	2026-08-28 07:48:00.915837
76215	1917	breakin	460	Break In	27-08-2026 13:31:00	316919	0.85	unrecognized	2026-08-28 07:50:33.76045	\N	Person #460	0	unrecognized	2026-08-28 07:50:33.812311
78900	1918	breakout	382	Break Out	27-08-2026 20:57:56	268705	0.85	unrecognized	2026-08-28 10:50:25.281661	\N	Person #382	0	unrecognized	2026-08-28 10:51:12.147728
76223	1917	breakin	462	Break In	27-08-2026 13:32:50	318604	0.85	normal	2026-08-28 07:50:41.401229	STF-025	Farhan Virk	0.5065	recognized	2026-08-28 07:50:47.180622
76331	1917	breakin	368	Break In	27-08-2026 14:44:40	69162	0.85	normal	2026-08-28 07:56:47.559658	STF-026	Syed Zeeshan Ali	0.4702	recognized	2026-08-28 07:56:49.918725
76487	1917	breakin	439	Break In	27-08-2026 14:55:10	84961	0.85	normal	2026-08-28 08:07:29.625878	STF-008	Muhammad Shoaib	0.4453	recognized	2026-08-28 08:07:29.684224
76366	1917	breakin	379	Break In	27-08-2026 14:46:26	71823	0.85	normal	2026-08-28 07:59:29.192905	STF-020	Syed Jahazaib Ahmad Alvi	0.4417	recognized	2026-08-28 07:59:41.688231
76443	1916	attendance	647	Person Entered	27-08-2026 21:19:49	1019709	0.85	unrecognized	2026-08-28 08:04:30.942422	\N	Person #647	0	unrecognized	2026-08-28 08:04:35.711074
76489	1917	breakin	442	Break In	27-08-2026 14:56:19	86671	0.85	normal	2026-08-28 08:07:33.868239	STF-033	Raza Abbas	0.452	recognized	2026-08-28 08:07:38.29824
76506	1916	attendance	674	Person Entered	27-08-2026 21:28:02	1032028	0.85	unrecognized	2026-08-28 08:09:05.889949	\N	Person #674	0	unrecognized	2026-08-28 08:09:07.147624
76503	1916	attendance	672	Person Entered	27-08-2026 21:27:39	1031422	0.85	unrecognized	2026-08-28 08:08:47.553824	\N	Person #672	0	unrecognized	2026-08-28 08:09:03.076264
76524	1916	attendance	680	Person Entered	27-08-2026 21:30:15	1035247	0.85	unrecognized	2026-08-28 08:11:00.691969	\N	Person #680	0	unrecognized	2026-08-28 08:11:30.101881
75770	1917	breakin	226	Break In	27-08-2026 18:56:29	89704	0.85	normal	2026-08-28 07:15:52.557124	STF-007	Faisal Saleem	0.4442	recognized	2026-08-28 07:15:54.132879
79392	1950	breakin	49	Break In	25-08-2026 19:01:59	10550	0.85	normal	2026-08-28 14:27:28.93874	STF-018	Muhammad Qaiser Shahzad	0.5146	recognized	2026-08-28 14:27:28.958759
77889	1918	breakout	49	Break Out	27-08-2026 14:16:37	23807	0.85	unrecognized	2026-08-28 09:56:35.053871	\N	Person #49	0	unrecognized	2026-08-28 09:56:40.824764
75988	1917	breakin	305	Break In	27-08-2026 19:14:17	116139	0.85	unrecognized	2026-08-28 07:30:34.508018	\N	Person #305	0	unrecognized	2026-08-28 07:34:01.556579
78255	1918	breakout	179	Break Out	27-08-2026 19:16:00	115898	0.85	unrecognized	2026-08-28 10:16:28.908084	\N	Person #179	0	unrecognized	2026-08-28 10:16:44.318625
77902	1918	breakout	54	Break Out	27-08-2026 14:17:11	24742	0.85	normal	2026-08-28 09:57:14.949044	STF-010	Faraz Younas	0.578	recognized	2026-08-28 09:57:17.694628
76222	1916	attendance	558	Person Entered	27-08-2026 21:06:57	1000365	0.85	unrecognized	2026-08-28 07:50:40.377823	\N	Person #558	0	unrecognized	2026-08-28 07:50:59.054136
76143	1917	breakin	299	Break In	27-08-2026 14:36:35	57013	0.85	normal	2026-08-28 07:43:41.138928	STF-029	Abdul Rehman Sultan	0.5505	recognized	2026-08-28 07:44:19.717131
76323	1916	attendance	588	Person Entered	27-08-2026 21:11:00	1006487	0.85	pending	2026-08-28 07:56:31.827262	\N	Person #588	\N	pending	\N
75990	1917	breakin	307	Break In	27-08-2026 19:14:25	116198	0.85	unrecognized	2026-08-28 07:30:56.205972	\N	Person #307	0	unrecognized	2026-08-28 07:34:28.813006
76444	1917	breakin	500	Break In	27-08-2026 13:42:03	332390	0.85	unrecognized	2026-08-28 08:04:32.715243	\N	Person #500	0	unrecognized	2026-08-28 08:05:58.310737
76369	1916	attendance	625	Person Entered	27-08-2026 21:15:48	1013698	0.85	unrecognized	2026-08-28 07:59:42.609505	\N	Person #625	0	unrecognized	2026-08-28 07:59:47.855102
76280	1917	breakin	469	Break In	27-08-2026 13:34:31	321126	0.85	normal	2026-08-28 07:53:47.105287	STF-026	Syed Zeeshan Ali	0.5019	recognized	2026-08-28 07:53:51.43293
76042	1917	breakin	312	Break In	27-08-2026 19:15:25	118059	0.85	unrecognized	2026-08-28 07:35:17.810864	\N	Person #312	0	unrecognized	2026-08-28 07:35:36.530255
78895	1918	breakout	340	Break Out	27-08-2026 16:28:58	222338	0.85	unrecognized	2026-08-28 10:50:10.295783	\N	Person #340	0	unrecognized	2026-08-28 10:50:24.622446
76139	1917	breakin	301	Break In	27-08-2026 14:36:33	56988	0.85	normal	2026-08-28 07:43:31.259626	STF-031	Muhammad Hassan	0.4653	recognized	2026-08-28 07:43:45.498068
76217	1916	attendance	557	Person Entered	27-08-2026 21:06:55	1000350	0.85	unrecognized	2026-08-28 07:50:34.614729	\N	Person #557	0	unrecognized	2026-08-28 07:50:39.699011
76325	1916	attendance	589	Person Entered	27-08-2026 21:11:00	1006507	0.85	unrecognized	2026-08-28 07:56:33.150327	\N	Person #589	0	unrecognized	2026-08-28 07:56:51.653111
76230	1916	attendance	560	Person Entered	27-08-2026 21:07:30	1001232	0.85	unrecognized	2026-08-28 07:51:02.215393	\N	Person #560	0	unrecognized	2026-08-28 07:51:08.166943
76268	1917	breakin	470	Break In	27-08-2026 13:33:34	319971	0.85	pending	2026-08-28 07:53:27.024473	\N	Person #470	0	unrecognized	\N
76089	1916	attendance	533	Person Entered	27-08-2026 21:04:17	996348	0.85	unrecognized	2026-08-28 07:38:36.624489	\N	Person #533	0	unrecognized	2026-08-28 07:39:43.214351
76367	1916	attendance	618	Person Entered	27-08-2026 21:15:45	1013619	0.85	pending	2026-08-28 07:59:37.523065	\N	Person #618	\N	pending	\N
78602	1918	breakout	289	Break Out	27-08-2026 20:17:22	208010	0.85	normal	2026-08-28 10:36:16.475092	STF-048	Abdullah Sultan	0.4907	recognized	2026-08-28 10:36:27.422542
79087	1918	breakout	403	Break Out	27-08-2026 17:00:17	269355	0.85	unrecognized	2026-08-28 11:01:27.051474	\N	Person #403	0	unrecognized	2026-08-28 11:01:33.398719
76406	1916	attendance	638	Person Entered	27-08-2026 21:16:00	1014710	0.85	unrecognized	2026-08-28 08:01:49.719771	\N	Person #638	0	unrecognized	2026-08-28 08:02:47.441545
79224	1918	breakout	483	Break Out	27-08-2026 21:27:24	313076	0.85	normal	2026-08-28 11:08:22.141378	STF-008	Muhammad Shoaib	0.517	recognized	2026-08-28 11:08:24.643947
76499	1917	breakin	438	Break In	27-08-2026 20:06:02	193942	0.85	unrecognized	2026-08-28 08:08:14.316497	\N	Person #438	0	unrecognized	2026-08-28 08:08:34.972222
79226	1918	breakout	484	Break Out	27-08-2026 21:28:00	313478	0.85	unrecognized	2026-08-28 11:08:26.828651	\N	Person #484	0	unrecognized	2026-08-28 11:09:33.32202
76494	1917	breakin	436	Break In	27-08-2026 20:05:39	193479	0.85	unrecognized	2026-08-28 08:07:50.760971	\N	Person #436	0	unrecognized	2026-08-28 08:07:52.224823
76495	1917	breakin	437	Break In	27-08-2026 20:05:50	193493	0.85	unrecognized	2026-08-28 08:07:52.417182	\N	Person #437	0	unrecognized	2026-08-28 08:08:09.032368
75776	1917	breakin	303	Break In	27-08-2026 12:19:56	209259	0.85	normal	2026-08-28 07:16:08.836488	STF-034	Muhammad Laeeq	0.4817	recognized	2026-08-28 07:16:13.637371
75987	1916	attendance	519	Person Entered	27-08-2026 21:03:32	995277	0.85	pending	2026-08-28 07:30:33.563734	\N	Person #519	0	unrecognized	\N
77893	1918	breakout	46	Break Out	27-08-2026 18:14:45	24094	0.85	normal	2026-08-28 09:56:37.692223	STF-010	Faraz Younas	0.4798	recognized	2026-08-28 09:56:45.53775
78257	1918	breakout	161	Break Out	27-08-2026 14:58:03	86038	0.85	normal	2026-08-28 10:16:33.650083	STF-035	Hammad Shaukat	0.4448	recognized	2026-08-28 10:16:35.091009
75781	1916	attendance	434	Person Entered	27-08-2026 20:55:00	983183	0.85	unrecognized	2026-08-28 07:16:23.406692	\N	Person #434	0	unrecognized	2026-08-28 07:17:10.171227
76044	1917	breakin	389	Break In	27-08-2026 12:49:57	254305	0.85	normal	2026-08-28 07:35:30.261311	STF-020	Syed Jahazaib Ahmad Alvi	0.4536	recognized	2026-08-28 07:35:34.294453
75779	1917	breakin	232	Break In	27-08-2026 18:57:03	90552	0.85	normal	2026-08-28 07:16:22.50032	STF-007	Faisal Saleem	0.4579	recognized	2026-08-28 07:16:24.774302
75774	1916	attendance	428	Person Entered	27-08-2026 20:55:00	982480	0.85	unrecognized	2026-08-28 07:15:59.042382	\N	Person #428	0	unrecognized	2026-08-28 07:16:18.570033
77900	1918	breakout	49	Break Out	27-08-2026 18:17:06	27605	0.85	normal	2026-08-28 09:57:11.435686	STF-044	Zaheer Hussain	0.4641	recognized	2026-08-28 09:57:13.070667
77903	1918	breakout	50	Break Out	27-08-2026 18:18:06	29068	0.85	unrecognized	2026-08-28 09:57:16.280224	\N	Person #50	0	unrecognized	2026-08-28 09:57:26.426408
75785	1917	breakin	238	Break In	27-08-2026 18:57:09	90728	0.85	normal	2026-08-28 07:16:28.708898	STF-017	Mohammad Zahid	0.6463	recognized	2026-08-28 07:16:28.743804
78601	1918	breakout	264	Break Out	27-08-2026 15:54:35	170730	0.85	unrecognized	2026-08-28 10:36:12.327425	\N	Person #264	0	unrecognized	2026-08-28 10:36:39.885829
75786	1917	breakin	231	Break In	27-08-2026 14:27:32	43511	0.85	normal	2026-08-28 07:16:36.521298	STF-029	Abdul Rehman Sultan	0.6468	recognized	2026-08-28 07:16:36.549223
75778	1917	breakin	230	Break In	27-08-2026 18:56:58	90462	0.85	normal	2026-08-28 07:16:20.380906	STF-001	Ikram Hassan	0.5971	recognized	2026-08-28 07:16:20.39786
78902	1918	breakout	324	Break Out	27-08-2026 13:17:55	291743	0.85	unrecognized	2026-08-28 10:50:30.634656	\N	Person #324	0	unrecognized	2026-08-28 10:50:46.093394
77897	1918	breakout	49	Break Out	27-08-2026 18:16:04	25996	0.85	unrecognized	2026-08-28 09:56:58.406653	\N	Person #49	0	unrecognized	2026-08-28 09:57:10.638429
78593	1918	breakout	261	Break Out	27-08-2026 15:53:25	169099	0.85	normal	2026-08-28 10:35:46.74426	STF-013	Muhammad Faizan	0.4623	recognized	2026-08-28 10:35:47.694245
75800	1916	attendance	445	Person Entered	27-08-2026 20:56:00	984156	0.85	unrecognized	2026-08-28 07:17:20.792037	\N	Person #445	0	unrecognized	2026-08-28 07:17:24.684377
75797	1917	breakin	242	Break In	27-08-2026 18:58:55	93380	0.85	normal	2026-08-28 07:17:16.09294	STF-002	Abdur Rehman	0.4837	recognized	2026-08-28 07:17:18.074712
78589	1918	breakout	260	Break Out	27-08-2026 15:51:14	165866	0.85	pending	2026-08-28 10:35:40.449709	\N	Person #260	0	unrecognized	\N
75782	1917	breakin	303	Break In	27-08-2026 12:21:51	211534	0.85	unrecognized	2026-08-28 07:16:23.74644	\N	Person #303	0	unrecognized	2026-08-28 07:17:53.256622
78598	1918	breakout	264	Break Out	27-08-2026 15:54:20	170389	0.85	unrecognized	2026-08-28 10:36:05.739441	\N	Person #264	0	unrecognized	2026-08-28 10:36:12.063614
78596	1918	breakout	262	Break Out	27-08-2026 15:54:11	170269	0.85	unrecognized	2026-08-28 10:36:05.104799	\N	Person #262	0	unrecognized	2026-08-28 10:36:05.144341
75794	1916	attendance	440	Person Entered	27-08-2026 20:55:41	983520	0.85	pending	2026-08-28 07:17:11.335676	\N	Person #440	0	unrecognized	\N
75795	1916	attendance	440	Person Entered	27-08-2026 20:55:52	983790	0.85	pending	2026-08-28 07:17:13.586052	\N	Person #440	0	unrecognized	\N
75804	1917	breakin	237	Break In	27-08-2026 14:28:07	44266	0.85	normal	2026-08-28 07:17:39.205254	STF-029	Abdul Rehman Sultan	0.502	recognized	2026-08-28 07:17:53.268335
75798	1917	breakin	244	Break In	27-08-2026 18:58:56	93409	0.85	normal	2026-08-28 07:17:18.895233	STF-031	Muhammad Hassan	0.5113	recognized	2026-08-28 07:17:18.928162
75796	1916	attendance	443	Person Entered	27-08-2026 20:55:53	983806	0.85	pending	2026-08-28 07:17:13.847558	\N	Person #443	0	unrecognized	\N
75802	1916	attendance	448	Person Entered	27-08-2026 20:56:00	984426	0.85	unrecognized	2026-08-28 07:17:30.815337	\N	Person #448	0	unrecognized	2026-08-28 07:18:04.311269
75793	1917	breakin	241	Break In	27-08-2026 18:58:00	93029	0.85	normal	2026-08-28 07:17:05.434036	STF-002	Abdur Rehman	0.4707	recognized	2026-08-28 07:17:10.080485
79088	1918	breakout	404	Break Out	27-08-2026 17:01:00	270409	0.85	unrecognized	2026-08-28 11:01:34.487214	\N	Person #404	0	unrecognized	2026-08-28 11:01:40.710492
75801	1916	attendance	446	Person Entered	27-08-2026 20:56:17	984403	0.85	pending	2026-08-28 07:17:28.957325	\N	Person #446	0	unrecognized	\N
78899	1918	breakout	323	Break Out	27-08-2026 13:17:18	290844	0.85	unrecognized	2026-08-28 10:50:20.070153	\N	Person #323	0	unrecognized	2026-08-28 10:50:29.901021
75813	1917	breakin	306	Break In	27-08-2026 12:22:50	213623	0.85	normal	2026-08-28 07:18:07.560846	STF-022	Mubashir Ishaq	0.5536	recognized	2026-08-28 07:18:10.229294
79092	1918	breakout	405	Break Out	27-08-2026 17:01:36	271312	0.85	unrecognized	2026-08-28 11:01:41.498858	\N	Person #405	0	unrecognized	2026-08-28 11:01:48.005791
75820	1917	breakin	309	Break In	27-08-2026 12:23:36	214789	0.85	normal	2026-08-28 07:18:44.671771	STF-022	Mubashir Ishaq	0.5016	recognized	2026-08-28 07:18:44.701691
75989	1917	breakin	365	Break In	27-08-2026 12:36:04	233485	0.85	normal	2026-08-28 07:30:42.612902	STF-026	Syed Zeeshan Ali	0.4866	recognized	2026-08-28 07:30:42.666462
75992	1917	breakin	366	Break In	27-08-2026 12:36:40	234603	0.85	pending	2026-08-28 07:31:09.479492	\N	Person #366	\N	pending	\N
75817	1917	breakin	237	Break In	27-08-2026 14:28:58	45657	0.85	normal	2026-08-28 07:18:17.848948	STF-029	Abdul Rehman Sultan	0.651	recognized	2026-08-28 07:18:17.907791
77912	1918	breakout	53	Break Out	27-08-2026 18:22:34	35788	0.85	unrecognized	2026-08-28 09:57:37.17369	\N	Person #53	0	unrecognized	2026-08-28 09:57:49.60294
79395	1950	breakin	52	Break In	25-08-2026 19:02:13	10883	0.85	normal	2026-08-28 14:27:39.80669	STF-014	Muhammad Asif	0.4756	recognized	2026-08-28 14:27:39.819897
76186	1917	breakin	442	Break In	27-08-2026 13:23:00	303871	0.85	normal	2026-08-28 07:46:30.096187	STF-007	Faisal Saleem	0.4407	recognized	2026-08-28 07:46:40.182713
78604	1918	breakout	241	Break Out	27-08-2026 12:43:17	239849	0.85	normal	2026-08-28 10:36:17.120354	STF-034	Muhammad Laeeq	0.45	recognized	2026-08-28 10:36:20.134308
77911	1918	breakout	52	Break Out	27-08-2026 18:20:26	32557	0.85	unrecognized	2026-08-28 09:57:31.28259	\N	Person #52	0	unrecognized	2026-08-28 09:57:35.567274
78605	1918	breakout	242	Break Out	27-08-2026 12:43:31	240213	0.85	normal	2026-08-28 10:36:22.768457	STF-011	Syed Shoaib Ahmad Alvi	0.4566	recognized	2026-08-28 10:36:25.454956
77908	1918	breakout	52	Break Out	27-08-2026 18:20:12	32240	0.85	unrecognized	2026-08-28 09:57:28.089515	\N	Person #52	0	unrecognized	2026-08-28 09:57:30.883666
78594	1918	breakout	239	Break Out	27-08-2026 12:42:00	237869	0.85	unrecognized	2026-08-28 10:35:49.161597	\N	Person #239	0	unrecognized	2026-08-28 10:36:04.341485
76183	1917	breakin	442	Break In	27-08-2026 13:21:20	301369	0.85	normal	2026-08-28 07:46:18.982538	STF-004	Tanveer Hassan	0.4511	recognized	2026-08-28 07:46:23.371911
76290	1917	breakin	366	Break In	27-08-2026 19:37:02	150433	0.85	normal	2026-08-28 07:54:27.588073	STF-035	Hammad Shaukat	0.4737	recognized	2026-08-28 07:54:36.906699
79388	1950	breakin	48	Break In	25-08-2026 19:01:22	9577	0.85	unrecognized	2026-08-28 14:27:21.400751	\N	Person #48	0	unrecognized	2026-08-28 14:27:22.470565
78590	1918	breakout	237	Break Out	27-08-2026 12:39:58	234882	0.85	normal	2026-08-28 10:35:40.976476	STF-010	Faraz Younas	0.4671	recognized	2026-08-28 10:35:43.395123
76902	1917	breakin	549	Break In	27-08-2026 20:38:34	242867	0.85	normal	2026-08-28 08:35:09.142038	STF-010	Faraz Younas	0.4729	recognized	2026-08-28 08:35:09.171111
77917	1918	breakout	54	Break Out	27-08-2026 18:22:57	36348	0.85	unrecognized	2026-08-28 09:58:00.602934	\N	Person #54	0	unrecognized	2026-08-28 09:58:19.061954
78592	1918	breakout	238	Break Out	27-08-2026 12:37:59	236306	0.85	pending	2026-08-28 10:35:46.095853	\N	Person #238	0	unrecognized	\N
77922	1918	breakout	55	Break Out	27-08-2026 18:23:42	37361	0.85	unrecognized	2026-08-28 09:58:20.01786	\N	Person #55	0	unrecognized	2026-08-28 09:58:29.336365
75816	1916	attendance	449	Person Entered	27-08-2026 20:57:19	985820	0.85	unrecognized	2026-08-28 07:18:16.3456	\N	Person #449	0	unrecognized	2026-08-28 07:19:12.396045
76099	1917	breakin	292	Break In	27-08-2026 14:35:48	55877	0.85	normal	2026-08-28 07:39:37.146476	STF-033	Raza Abbas	0.6474	recognized	2026-08-28 07:39:46.964967
79094	1918	breakout	448	Break Out	27-08-2026 21:15:01	294479	0.85	normal	2026-08-28 11:01:44.863528	STF-007	Faisal Saleem	0.468	recognized	2026-08-28 11:01:57.684937
75993	1917	breakin	367	Break In	27-08-2026 12:37:16	235172	0.85	unrecognized	2026-08-28 07:31:10.317476	\N	Person #367	0	unrecognized	2026-08-28 07:31:43.988286
78910	1918	breakout	385	Break Out	27-08-2026 20:58:19	268873	0.85	unrecognized	2026-08-28 10:51:00.728588	\N	Person #385	0	unrecognized	2026-08-28 10:52:45.487921
76045	1917	breakin	390	Break In	27-08-2026 12:49:58	254351	0.85	normal	2026-08-28 07:35:36.055338	STF-026	Syed Zeeshan Ali	0.4954	recognized	2026-08-28 07:35:36.077989
76305	1917	breakin	367	Break In	27-08-2026 19:37:16	150855	0.85	normal	2026-08-28 07:54:41.711957	STF-008	Muhammad Shoaib	0.5328	recognized	2026-08-28 07:54:46.119582
76189	1917	breakin	446	Break In	27-08-2026 13:25:01	306879	0.85	normal	2026-08-28 07:47:14.413375	STF-026	Syed Zeeshan Ali	0.4654	recognized	2026-08-28 07:47:23.034645
76228	1917	breakin	346	Break In	27-08-2026 19:29:14	138755	0.85	unrecognized	2026-08-28 07:50:53.160659	\N	Person #346	0	unrecognized	2026-08-28 07:51:41.065296
76910	1917	breakin	553	Break In	27-08-2026 20:39:04	243558	0.85	normal	2026-08-28 08:35:18.161803	STF-008	Muhammad Shoaib	0.4619	recognized	2026-08-28 08:35:21.33933
76340	1916	attendance	595	Person Entered	27-08-2026 21:11:33	1007241	0.85	unrecognized	2026-08-28 07:56:58.003847	\N	Person #595	0	unrecognized	2026-08-28 07:57:04.572002
76988	1917	breakin	591	Break In	27-08-2026 20:49:25	259112	0.85	unrecognized	2026-08-28 08:40:27.455374	\N	Person #591	0	unrecognized	2026-08-28 08:40:29.593388
76989	1917	breakin	593	Break In	27-08-2026 20:49:00	259619	0.85	unrecognized	2026-08-28 08:40:30.58701	\N	Person #593	0	unrecognized	2026-08-28 08:40:44.17671
76344	1916	attendance	599	Person Entered	27-08-2026 21:11:33	1007355	0.85	unrecognized	2026-08-28 07:57:10.845868	\N	Person #599	0	unrecognized	2026-08-28 07:57:11.292948
76991	1917	breakin	596	Break In	27-08-2026 20:50:07	260090	0.85	normal	2026-08-28 08:40:46.192888	STF-025	Farhan Virk	0.454	recognized	2026-08-28 08:41:04.078828
75830	1916	checkout	457	check_out	27-08-2026 20:58:01	987023	0.85	normal	2026-08-28 07:19:29.807006	STF-017	Mohammad Zahid	0.4421	recognized	2026-08-28 07:19:29.85388
77914	1918	breakout	61	Break Out	27-08-2026 14:17:58	25905	0.85	unrecognized	2026-08-28 09:57:46.544714	\N	Person #61	0	unrecognized	2026-08-28 09:58:05.893617
75843	1917	breakin	318	Break In	27-08-2026 12:25:25	217526	0.85	unrecognized	2026-08-28 07:20:32.271657	\N	Person #318	0	unrecognized	2026-08-28 07:20:32.296591
78260	1918	breakout	149	Break Out	27-08-2026 11:45:18	157524	0.85	pending	2026-08-28 10:16:38.551526	\N	Person #149	0	unrecognized	\N
75838	1917	breakin	248	Break In	27-08-2026 19:01:22	96823	0.85	unrecognized	2026-08-28 07:20:04.407944	\N	Person #248	0	unrecognized	2026-08-28 07:20:54.908201
79393	1950	breakin	50	Break In	25-08-2026 19:02:03	10640	0.85	normal	2026-08-28 14:27:30.113443	STF-028	Noman Imran	0.4616	recognized	2026-08-28 14:27:30.36473
75847	1917	breakin	318	Break In	27-08-2026 12:26:00	218797	0.85	unrecognized	2026-08-28 07:20:46.421866	\N	Person #318	0	unrecognized	2026-08-28 07:21:02.229376
75995	1917	breakin	275	Break In	27-08-2026 14:32:52	51411	0.85	unrecognized	2026-08-28 07:31:11.443954	\N	Person #275	0	unrecognized	2026-08-28 07:31:21.229614
75827	1916	attendance	451	Person Entered	27-08-2026 20:57:51	986722	0.85	unrecognized	2026-08-28 07:19:14.829655	\N	Person #451	0	unrecognized	2026-08-28 07:19:26.781417
77920	1918	breakout	63	Break Out	27-08-2026 14:18:12	26257	0.85	unrecognized	2026-08-28 09:58:15.776282	\N	Person #63	0	unrecognized	2026-08-28 09:58:17.408752
78905	1918	breakout	342	Break Out	27-08-2026 16:30:21	224511	0.85	normal	2026-08-28 10:50:41.168391	STF-010	Faraz Younas	0.4582	recognized	2026-08-28 10:50:43.32076
75846	1917	breakin	318	Break In	27-08-2026 12:26:10	218505	0.85	unrecognized	2026-08-28 07:20:43.088378	\N	Person #318	0	unrecognized	2026-08-28 07:20:45.954269
75824	1917	breakin	314	Break In	27-08-2026 12:23:56	215292	0.85	normal	2026-08-28 07:19:00.685477	STF-017	Mohammad Zahid	0.4579	recognized	2026-08-28 07:19:01.611391
75825	1917	breakin	246	Break In	27-08-2026 19:00:07	95166	0.85	normal	2026-08-28 07:19:07.317258	STF-009	Tariq Ghulam Hussain	0.5238	recognized	2026-08-28 07:19:13.222717
75837	1917	breakin	317	Break In	27-08-2026 12:24:33	216129	0.85	normal	2026-08-28 07:19:54.70441	STF-013	Muhammad Faizan	0.4402	recognized	2026-08-28 07:20:05.048272
76046	1917	breakin	313	Break In	27-08-2026 19:15:55	118713	0.85	unrecognized	2026-08-28 07:35:37.5658	\N	Person #313	0	unrecognized	2026-08-28 07:36:10.358275
76048	1917	breakin	314	Break In	27-08-2026 19:17:00	121574	0.85	normal	2026-08-28 07:36:12.570845	STF-028	Noman Imran	0.4612	recognized	2026-08-28 07:36:14.931541
75836	1917	breakin	314	Break In	27-08-2026 12:24:28	216030	0.85	normal	2026-08-28 07:19:53.412918	STF-017	Mohammad Zahid	0.4712	recognized	2026-08-28 07:19:53.886174
76140	1917	breakin	419	Break In	27-08-2026 13:06:29	279096	0.85	unrecognized	2026-08-28 07:43:33.811693	\N	Person #419	0	unrecognized	2026-08-28 07:43:34.562688
75835	1917	breakin	251	Break In	27-08-2026 14:30:18	47664	0.85	normal	2026-08-28 07:19:50.83149	STF-029	Abdul Rehman Sultan	0.5146	recognized	2026-08-28 07:19:50.881356
78265	1918	breakout	150	Break Out	27-08-2026 11:48:36	157679	0.85	normal	2026-08-28 10:16:54.749925	STF-004	Tanveer Hassan	0.4559	recognized	2026-08-28 10:17:19.381049
78608	1918	breakout	245	Break Out	27-08-2026 12:44:20	241309	0.85	unrecognized	2026-08-28 10:36:40.566467	\N	Person #245	0	unrecognized	2026-08-28 10:37:04.189498
75859	1917	breakin	318	Break In	27-08-2026 12:27:00	220993	0.85	normal	2026-08-28 07:21:21.09472	STF-017	Mohammad Zahid	0.5097	recognized	2026-08-28 07:21:21.123642
78275	1918	breakout	150	Break Out	27-08-2026 11:49:26	159000	0.85	normal	2026-08-28 10:17:26.119699	STF-037	Muhammad Fahad	0.4814	recognized	2026-08-28 10:17:30.424439
75841	1917	breakin	318	Break In	27-08-2026 12:25:14	216976	0.85	unrecognized	2026-08-28 07:20:24.114833	\N	Person #318	0	unrecognized	2026-08-28 07:20:31.751336
78622	1918	breakout	248	Break Out	27-08-2026 12:45:36	243328	0.85	normal	2026-08-28 10:37:21.444991	STF-010	Faraz Younas	0.5271	recognized	2026-08-28 10:37:25.478537
75853	1917	breakin	250	Break In	27-08-2026 19:02:33	98836	0.85	normal	2026-08-28 07:21:08.551879	STF-018	Muhammad Qaiser Shahzad	0.4842	recognized	2026-08-28 07:21:10.173292
75851	1917	breakin	322	Break In	27-08-2026 12:27:03	219934	0.85	normal	2026-08-28 07:21:06.246887	STF-013	Muhammad Faizan	0.4764	recognized	2026-08-28 07:21:08.594306
75849	1916	attendance	463	Person Entered	27-08-2026 21:00:05	990080	0.85	unrecognized	2026-08-28 07:21:02.650123	\N	Person #463	0	unrecognized	2026-08-28 07:21:12.169906
75865	1917	breakin	324	Break In	27-08-2026 12:28:14	221708	0.85	normal	2026-08-28 07:21:34.038266	STF-026	Syed Zeeshan Ali	0.4535	recognized	2026-08-28 07:21:35.704962
78627	1918	breakout	249	Break Out	27-08-2026 12:45:00	243608	0.85	unrecognized	2026-08-28 10:37:27.49161	\N	Person #249	0	unrecognized	2026-08-28 10:37:50.817449
75832	1916	attendance	461	Person Entered	27-08-2026 21:00:03	989724	0.85	unrecognized	2026-08-28 07:19:39.41605	\N	Person #461	0	unrecognized	2026-08-28 07:21:01.904371
78911	1918	breakout	345	Break Out	27-08-2026 16:31:33	226185	0.85	unrecognized	2026-08-28 10:51:06.231807	\N	Person #345	0	unrecognized	2026-08-28 10:51:24.841281
78906	1918	breakout	343	Break Out	27-08-2026 16:31:17	225856	0.85	unrecognized	2026-08-28 10:50:46.36771	\N	Person #343	0	unrecognized	2026-08-28 10:50:47.227938
78908	1918	breakout	343	Break Out	27-08-2026 16:31:26	226049	0.85	unrecognized	2026-08-28 10:50:47.595854	\N	Person #343	0	unrecognized	2026-08-28 10:51:05.145386
75858	1916	attendance	469	Person Entered	27-08-2026 21:00:30	990720	0.85	unrecognized	2026-08-28 07:21:18.618384	\N	Person #469	0	unrecognized	2026-08-28 07:21:25.118242
75856	1916	attendance	464	Person Entered	27-08-2026 21:00:28	990680	0.85	pending	2026-08-28 07:21:15.105358	\N	Person #464	0	unrecognized	\N
75863	1916	attendance	470	Person Entered	27-08-2026 21:00:45	991033	0.85	unrecognized	2026-08-28 07:21:27.59526	\N	Person #470	0	unrecognized	2026-08-28 07:21:56.834353
75831	1917	breakin	226	Break In	27-08-2026 14:32:39	47470	0.85	unrecognized	2026-08-28 07:19:37.243173	\N	Person #226	0	unrecognized	2026-08-28 07:31:07.949385
75996	1916	checkout	520	check_out	27-08-2026 21:03:42	995350	0.85	normal	2026-08-28 07:31:19.14686	STF-009	Tariq Ghulam Hussain	0.4446	recognized	2026-08-28 07:33:26.276788
76448	1916	attendance	650	Person Entered	27-08-2026 21:20:53	1021186	0.85	unrecognized	2026-08-28 08:04:41.612168	\N	Person #650	0	unrecognized	2026-08-28 08:05:05.231757
76418	1917	breakin	417	Break In	27-08-2026 20:02:14	188330	0.85	normal	2026-08-28 08:02:37.007476	STF-005	Muhammad Ayaz Hussain	0.5206	recognized	2026-08-28 08:02:40.574952
76060	1917	breakin	393	Break In	27-08-2026 12:52:53	258678	0.85	normal	2026-08-28 07:36:35.581151	STF-028	Noman Imran	0.4588	recognized	2026-08-28 07:36:42.928085
78624	1918	breakout	269	Break Out	27-08-2026 15:58:32	176816	0.85	pending	2026-08-28 10:37:25.83154	\N	Person #269	0	unrecognized	\N
76383	1917	breakin	398	Break In	27-08-2026 19:51:31	172230	0.85	unrecognized	2026-08-28 08:00:11.285363	\N	Person #398	0	unrecognized	2026-08-28 08:00:23.748855
76287	1917	breakin	474	Break In	27-08-2026 13:39:00	327471	0.85	unrecognized	2026-08-28 07:54:19.723631	\N	Person #474	0	unrecognized	2026-08-28 07:56:02.679331
76343	1916	attendance	598	Person Entered	27-08-2026 21:11:33	1007322	0.85	pending	2026-08-28 07:57:08.539213	\N	Person #598	0	unrecognized	\N
75845	1917	breakin	257	Break In	27-08-2026 14:31:04	48504	0.85	normal	2026-08-28 07:20:40.170381	STF-011	Syed Shoaib Ahmad Alvi	0.5946	recognized	2026-08-28 07:22:51.292208
76049	1917	breakin	392	Break In	27-08-2026 12:51:00	257027	0.85	normal	2026-08-28 07:36:16.26983	STF-028	Noman Imran	0.4408	recognized	2026-08-28 07:36:19.748803
79394	1950	breakin	51	Break In	25-08-2026 19:02:08	10728	0.85	normal	2026-08-28 14:27:32.177923	STF-011	Syed Shoaib Ahmad Alvi	0.4463	recognized	2026-08-28 14:27:37.324531
76052	1917	breakin	393	Break In	27-08-2026 12:51:53	257232	0.85	normal	2026-08-28 07:36:24.967614	STF-028	Noman Imran	0.561	recognized	2026-08-28 07:36:24.995539
76064	1917	breakin	395	Break In	27-08-2026 12:53:04	258984	0.85	normal	2026-08-28 07:36:47.822923	STF-022	Mubashir Ishaq	0.4652	recognized	2026-08-28 07:36:51.148087
77919	1918	breakout	49	Break Out	27-08-2026 11:02:15	88285	0.85	unrecognized	2026-08-28 09:58:13.861905	\N	Person #49	0	unrecognized	2026-08-28 09:58:42.643637
78609	1918	breakout	266	Break Out	27-08-2026 15:55:29	172059	0.85	unrecognized	2026-08-28 10:36:41.487918	\N	Person #266	0	unrecognized	2026-08-28 10:37:03.689316
76059	1917	breakin	394	Break In	27-08-2026 12:52:51	258660	0.85	normal	2026-08-28 07:36:33.948085	STF-020	Syed Jahazaib Ahmad Alvi	0.5272	recognized	2026-08-28 07:36:34.040364
78613	1918	breakout	267	Break Out	27-08-2026 15:56:16	173412	0.85	pending	2026-08-28 10:37:04.626173	\N	Person #267	\N	pending	\N
78909	1918	breakout	326	Break Out	27-08-2026 13:18:17	292302	0.85	unrecognized	2026-08-28 10:50:59.278323	\N	Person #326	0	unrecognized	2026-08-28 10:51:14.735003
78907	1918	breakout	325	Break Out	27-08-2026 13:18:01	291921	0.85	unrecognized	2026-08-28 10:50:46.659821	\N	Person #325	0	unrecognized	2026-08-28 10:50:58.560165
78615	1918	breakout	267	Break Out	27-08-2026 15:57:52	175781	0.85	normal	2026-08-28 10:37:05.981664	STF-037	Muhammad Fahad	0.4658	recognized	2026-08-28 10:37:06.811434
76368	1917	breakin	395	Break In	27-08-2026 19:50:43	170962	0.85	unrecognized	2026-08-28 07:59:38.34673	\N	Person #395	0	unrecognized	2026-08-28 07:59:55.631208
78269	1918	breakout	166	Break Out	27-08-2026 14:58:38	86914	0.85	unrecognized	2026-08-28 10:17:12.514552	\N	Person #166	0	unrecognized	2026-08-28 10:17:16.869785
76145	1917	breakin	424	Break In	27-08-2026 13:07:30	280631	0.85	normal	2026-08-28 07:43:50.486456	STF-002	Abdur Rehman	0.4958	recognized	2026-08-28 07:43:55.076905
76148	1917	breakin	425	Break In	27-08-2026 13:08:25	282228	0.85	pending	2026-08-28 07:44:02.172536	\N	Person #425	\N	pending	\N
76231	1916	attendance	561	Person Entered	27-08-2026 21:07:33	1001270	0.85	unrecognized	2026-08-28 07:51:10.132999	\N	Person #561	0	unrecognized	2026-08-28 07:51:26.533637
76286	1917	breakin	474	Break In	27-08-2026 13:35:21	322639	0.85	pending	2026-08-28 07:54:17.389781	\N	Person #474	\N	pending	\N
78912	1918	breakout	327	Break Out	27-08-2026 13:19:37	294403	0.85	normal	2026-08-28 10:51:15.998532	STF-010	Faraz Younas	0.4584	recognized	2026-08-28 10:51:16.3097
76411	1917	breakin	416	Break In	27-08-2026 20:00:27	185615	0.85	unrecognized	2026-08-28 08:02:32.393153	\N	Person #416	0	unrecognized	2026-08-28 08:02:33.581236
79090	1918	breakout	390	Break Out	27-08-2026 13:46:01	333968	0.85	unrecognized	2026-08-28 11:01:38.616656	\N	Person #390	0	unrecognized	2026-08-28 11:01:40.045163
76413	1917	breakin	416	Break In	27-08-2026 20:00:35	185895	0.85	pending	2026-08-28 08:02:34.301619	\N	Person #416	\N	pending	\N
76377	1917	breakin	396	Break In	27-08-2026 19:51:25	172061	0.85	unrecognized	2026-08-28 07:59:57.04967	\N	Person #396	0	unrecognized	2026-08-28 08:00:10.450818
76414	1917	breakin	416	Break In	27-08-2026 20:00:43	186080	0.85	pending	2026-08-28 08:02:34.467238	\N	Person #416	\N	pending	\N
76415	1917	breakin	416	Break In	27-08-2026 20:00:51	186277	0.85	pending	2026-08-28 08:02:34.618757	\N	Person #416	\N	pending	\N
76410	1917	breakin	411	Break In	27-08-2026 19:58:58	183406	0.85	unrecognized	2026-08-28 08:02:20.065313	\N	Person #411	0	unrecognized	2026-08-28 08:02:26.693035
79091	1918	breakout	392	Break Out	27-08-2026 13:46:47	335038	0.85	unrecognized	2026-08-28 11:01:41.13947	\N	Person #392	0	unrecognized	2026-08-28 11:01:54.720488
76420	1917	breakin	419	Break In	27-08-2026 20:02:25	188607	0.85	normal	2026-08-28 08:02:45.242393	STF-007	Faisal Saleem	0.4632	recognized	2026-08-28 08:02:49.079662
76424	1917	breakin	421	Break In	27-08-2026 20:02:56	189263	0.85	normal	2026-08-28 08:02:56.841292	STF-007	Faisal Saleem	0.5288	recognized	2026-08-28 08:03:17.369715
75866	1917	breakin	253	Break In	27-08-2026 19:02:00	99233	0.85	normal	2026-08-28 07:21:41.950582	STF-007	Faisal Saleem	0.5129	recognized	2026-08-28 07:21:41.994465
77942	1918	breakout	63	Break Out	27-08-2026 18:29:28	46136	0.85	unrecognized	2026-08-28 09:59:21.952617	\N	Person #63	0	unrecognized	2026-08-28 09:59:23.099436
77932	1918	breakout	59	Break Out	27-08-2026 18:26:09	41185	0.85	unrecognized	2026-08-28 09:58:51.809166	\N	Person #59	0	unrecognized	2026-08-28 09:58:53.283821
78264	1918	breakout	181	Break Out	27-08-2026 19:18:10	119124	0.85	unrecognized	2026-08-28 10:16:53.282158	\N	Person #181	0	unrecognized	2026-08-28 10:17:04.512093
76050	1917	breakin	316	Break In	27-08-2026 19:18:11	122277	0.85	normal	2026-08-28 07:36:20.072921	STF-011	Syed Shoaib Ahmad Alvi	0.4434	recognized	2026-08-28 07:36:20.111619
76002	1917	breakin	277	Break In	27-08-2026 14:33:29	52035	0.85	normal	2026-08-28 07:32:10.284572	STF-029	Abdul Rehman Sultan	0.4847	recognized	2026-08-28 07:35:03.191092
75874	1917	breakin	259	Break In	27-08-2026 19:05:02	102525	0.85	normal	2026-08-28 07:22:04.282945	STF-027	Ahmed Hassan Bhatti	0.4726	recognized	2026-08-28 07:22:08.862777
77924	1918	breakout	57	Break Out	27-08-2026 18:23:56	37821	0.85	unrecognized	2026-08-28 09:58:33.319642	\N	Person #57	0	unrecognized	2026-08-28 09:58:40.722111
76068	1917	breakin	318	Break In	27-08-2026 19:19:18	123966	0.85	unrecognized	2026-08-28 07:37:07.365149	\N	Person #318	0	unrecognized	2026-08-28 07:37:07.413022
78610	1918	breakout	290	Break Out	27-08-2026 20:18:49	210172	0.85	normal	2026-08-28 10:36:43.958582	STF-033	Raza Abbas	0.4493	recognized	2026-08-28 10:36:47.65933
76150	1916	attendance	546	Person Entered	27-08-2026 21:04:50	997217	0.85	unrecognized	2026-08-28 07:44:04.731893	\N	Person #546	0	unrecognized	2026-08-28 07:44:17.907574
78272	1918	breakout	183	Break Out	27-08-2026 19:19:06	120651	0.85	normal	2026-08-28 10:17:20.781378	STF-011	Syed Shoaib Ahmad Alvi	0.4522	recognized	2026-08-28 10:17:21.081491
77934	1918	breakout	61	Break Out	27-08-2026 18:27:34	43229	0.85	unrecognized	2026-08-28 09:58:57.896989	\N	Person #61	0	unrecognized	2026-08-28 09:59:11.854146
76351	1917	breakin	393	Break In	27-08-2026 19:49:40	168183	0.85	unrecognized	2026-08-28 07:57:29.664444	\N	Person #393	0	unrecognized	2026-08-28 07:59:35.320711
78262	1918	breakout	180	Break Out	27-08-2026 19:17:00	118466	0.85	unrecognized	2026-08-28 10:16:45.945816	\N	Person #180	0	unrecognized	2026-08-28 10:16:52.428228
77937	1918	breakout	61	Break Out	27-08-2026 18:28:20	44373	0.85	unrecognized	2026-08-28 09:59:12.523181	\N	Person #61	0	unrecognized	2026-08-28 09:59:20.547734
77930	1918	breakout	58	Break Out	27-08-2026 18:26:01	40969	0.85	unrecognized	2026-08-28 09:58:47.485955	\N	Person #58	0	unrecognized	2026-08-28 09:58:51.212961
77941	1918	breakout	63	Break Out	27-08-2026 18:28:47	45180	0.85	pending	2026-08-28 09:59:21.56665	\N	Person #63	\N	pending	\N
76069	1917	breakin	319	Break In	27-08-2026 19:19:25	123978	0.85	unrecognized	2026-08-28 07:37:07.951659	\N	Person #319	0	unrecognized	2026-08-28 07:37:35.168739
76188	1916	attendance	550	Person Entered	27-08-2026 21:05:45	998333	0.85	unrecognized	2026-08-28 07:46:53.780552	\N	Person #550	0	unrecognized	2026-08-28 07:48:57.656002
77927	1918	breakout	57	Break Out	27-08-2026 18:24:57	39339	0.85	normal	2026-08-28 09:58:41.554505	STF-029	Abdul Rehman Sultan	0.5314	recognized	2026-08-28 09:58:44.361825
77933	1918	breakout	60	Break Out	27-08-2026 18:27:26	43065	0.85	unrecognized	2026-08-28 09:58:54.375111	\N	Person #60	0	unrecognized	2026-08-28 09:58:57.408096
75870	1917	breakin	255	Break In	27-08-2026 19:03:06	99658	0.85	pending	2026-08-28 07:21:58.396016	\N	Person #255	\N	pending	\N
75873	1917	breakin	257	Break In	27-08-2026 19:04:30	101763	0.85	normal	2026-08-28 07:22:01.690799	STF-007	Faisal Saleem	0.6357	recognized	2026-08-28 07:22:01.759614
78267	1918	breakout	183	Break Out	27-08-2026 19:18:17	119286	0.85	unrecognized	2026-08-28 10:17:05.105363	\N	Person #183	0	unrecognized	2026-08-28 10:17:17.722639
77943	1918	breakout	63	Break Out	27-08-2026 18:30:23	47503	0.85	unrecognized	2026-08-28 09:59:23.828523	\N	Person #63	0	unrecognized	2026-08-28 09:59:25.861272
76288	1916	attendance	581	Person Entered	27-08-2026 21:10:00	1004968	0.85	unrecognized	2026-08-28 07:54:21.864043	\N	Person #581	0	unrecognized	2026-08-28 07:55:44.403428
76101	1916	attendance	536	Person Entered	27-08-2026 21:04:32	996447	0.85	unrecognized	2026-08-28 07:40:03.686432	\N	Person #536	0	unrecognized	2026-08-28 07:43:34.357208
76142	1916	attendance	542	Person Entered	27-08-2026 21:04:33	996806	0.85	pending	2026-08-28 07:43:39.784195	\N	Person #542	0	unrecognized	\N
76347	1917	breakin	389	Break In	27-08-2026 19:46:14	164356	0.85	normal	2026-08-28 07:57:19.449893	STF-049	Nabi Ul Haq	0.5915	recognized	2026-08-28 07:57:19.475823
78271	1918	breakout	183	Break Out	27-08-2026 19:18:00	119891	0.85	unrecognized	2026-08-28 10:17:18.209917	\N	Person #183	0	unrecognized	2026-08-28 10:17:20.270992
76350	1917	breakin	391	Break In	27-08-2026 19:47:50	166756	0.85	normal	2026-08-28 07:57:25.700342	STF-047	Arshad Irshad	0.4887	recognized	2026-08-28 07:57:25.733623
78914	1918	breakout	345	Break Out	27-08-2026 16:31:57	226831	0.85	unrecognized	2026-08-28 10:51:25.277211	\N	Person #345	0	unrecognized	2026-08-28 10:51:39.969036
76381	1917	breakin	487	Break In	27-08-2026 13:41:02	330938	0.85	normal	2026-08-28 08:00:02.711026	STF-023	Syed Zubair Zulfiqar	0.5062	recognized	2026-08-28 08:00:04.352103
78611	1918	breakout	291	Break Out	27-08-2026 20:18:51	210237	0.85	normal	2026-08-28 10:36:48.092306	STF-044	Zaheer Hussain	0.4675	recognized	2026-08-28 10:36:59.661891
76458	1916	attendance	652	Person Entered	27-08-2026 21:21:28	1022151	0.85	unrecognized	2026-08-28 08:05:10.204592	\N	Person #652	0	unrecognized	2026-08-28 08:05:23.403844
79227	1918	breakout	444	Break Out	27-08-2026 17:23:57	304899	0.85	normal	2026-08-28 11:08:38.774469	STF-032	Muhammad Yaseen	0.448	recognized	2026-08-28 11:08:40.888316
76496	1916	attendance	664	Person Entered	27-08-2026 21:25:17	1027874	0.85	unrecognized	2026-08-28 08:08:01.664812	\N	Person #664	0	unrecognized	2026-08-28 08:08:11.127664
76485	1917	breakin	433	Break In	27-08-2026 20:04:55	192237	0.85	normal	2026-08-28 08:07:12.423852	STF-007	Faisal Saleem	0.546	recognized	2026-08-28 08:07:23.873519
75888	1916	checkout	476	check_out	27-08-2026 21:01:25	992117	0.85	normal	2026-08-28 07:23:00.839979	STF-023	Syed Zubair Zulfiqar	0.4755	recognized	2026-08-28 07:23:03.673515
75894	1916	checkout	481	check_out	27-08-2026 21:01:45	992614	0.85	normal	2026-08-28 07:23:16.807952	STF-086	Muhammad Moaaz Khan	0.56	recognized	2026-08-28 07:23:22.263195
78280	1918	breakout	154	Break Out	27-08-2026 11:50:20	160436	0.85	unrecognized	2026-08-28 10:17:45.265381	\N	Person #154	0	unrecognized	2026-08-28 10:17:46.085252
75999	1917	breakin	368	Break In	27-08-2026 12:37:56	236159	0.85	normal	2026-08-28 07:31:45.563254	STF-005	Muhammad Ayaz Hussain	0.4451	recognized	2026-08-28 07:32:22.355075
75903	1916	checkout	481	check_out	27-08-2026 21:02:04	993050	0.85	normal	2026-08-28 07:23:39.983992	STF-086	Muhammad Moaaz Khan	0.4582	recognized	2026-08-28 07:23:42.506314
77926	1918	breakout	66	Break Out	27-08-2026 14:18:44	27014	0.85	normal	2026-08-28 09:58:36.718975	STF-030	Dildar Ahmed	0.4486	recognized	2026-08-28 09:58:43.906458
75893	1916	checkout	480	check_out	27-08-2026 21:01:45	992613	0.85	normal	2026-08-28 07:23:15.878308	STF-027	Ahmed Hassan Bhatti	0.5094	recognized	2026-08-28 07:23:23.043935
75916	1916	checkout	489	check_out	27-08-2026 21:02:28	993681	0.85	normal	2026-08-28 07:24:11.471719	STF-050	Hafeez-Ur-Rehman	0.4666	recognized	2026-08-28 07:24:12.359601
75909	1916	checkout	484	check_out	27-08-2026 21:02:14	993331	0.85	normal	2026-08-28 07:23:52.565361	STF-086	Muhammad Moaaz Khan	0.4828	recognized	2026-08-28 07:23:54.018008
76055	1917	breakin	277	Break In	27-08-2026 14:34:11	52809	0.85	unrecognized	2026-08-28 07:36:30.175607	\N	Person #277	0	unrecognized	2026-08-28 07:37:34.7677
75867	1917	breakin	318	Break In	27-08-2026 12:28:00	222073	0.85	normal	2026-08-28 07:21:42.343367	STF-017	Mohammad Zahid	0.4827	recognized	2026-08-28 07:22:02.062117
78612	1918	breakout	292	Break Out	27-08-2026 20:19:51	211735	0.85	unrecognized	2026-08-28 10:37:03.473426	\N	Person #292	0	unrecognized	2026-08-28 10:37:06.020586
75872	1916	attendance	472	Person Entered	27-08-2026 21:01:08	991494	0.85	unrecognized	2026-08-28 07:22:00.096959	\N	Person #472	0	unrecognized	2026-08-28 07:22:57.229768
78282	1918	breakout	154	Break Out	27-08-2026 11:50:53	161208	0.85	unrecognized	2026-08-28 10:17:46.591664	\N	Person #154	0	unrecognized	2026-08-28 10:17:48.653373
75880	1917	breakin	327	Break In	27-08-2026 12:29:09	223096	0.85	normal	2026-08-28 07:22:25.147383	STF-026	Syed Zeeshan Ali	0.5376	recognized	2026-08-28 07:22:31.761422
78277	1918	breakout	153	Break Out	27-08-2026 11:50:14	160226	0.85	unrecognized	2026-08-28 10:17:31.913935	\N	Person #153	0	unrecognized	2026-08-28 10:17:44.749948
77938	1918	breakout	70	Break Out	27-08-2026 14:19:19	27881	0.85	unrecognized	2026-08-28 09:59:13.596788	\N	Person #70	0	unrecognized	2026-08-28 09:59:31.496072
76106	1917	breakin	408	Break In	27-08-2026 13:01:52	272202	0.85	normal	2026-08-28 07:40:16.263222	STF-017	Mohammad Zahid	0.5391	recognized	2026-08-28 07:40:16.302913
75892	1916	attendance	477	Person Entered	27-08-2026 21:01:29	992222	0.85	unrecognized	2026-08-28 07:23:09.846643	\N	Person #477	0	unrecognized	2026-08-28 07:23:11.386044
78284	1918	breakout	155	Break Out	27-08-2026 11:51:40	162381	0.85	unrecognized	2026-08-28 10:17:49.500169	\N	Person #155	0	unrecognized	2026-08-28 10:18:01.674142
78292	1918	breakout	157	Break Out	27-08-2026 11:52:15	163293	0.85	normal	2026-08-28 10:18:09.323527	STF-047	Arshad Irshad	0.4588	recognized	2026-08-28 10:18:19.804856
75876	1917	breakin	326	Break In	27-08-2026 12:28:00	222542	0.85	normal	2026-08-28 07:22:11.523553	STF-013	Muhammad Faizan	0.4931	recognized	2026-08-28 07:22:14.338766
76109	1917	breakin	410	Break In	27-08-2026 13:02:12	272672	0.85	normal	2026-08-28 07:40:23.233979	STF-001	Ikram Hassan	0.4542	recognized	2026-08-28 07:40:26.291697
75896	1917	breakin	331	Break In	27-08-2026 12:29:00	224040	0.85	normal	2026-08-28 07:23:23.642706	STF-013	Muhammad Faizan	0.4836	recognized	2026-08-28 07:23:23.664647
75898	1917	breakin	318	Break In	27-08-2026 12:30:23	224972	0.85	normal	2026-08-28 07:23:26.398851	STF-017	Mohammad Zahid	0.5295	recognized	2026-08-28 07:23:26.42179
78619	1918	breakout	294	Break Out	27-08-2026 20:20:36	212866	0.85	normal	2026-08-28 10:37:14.818884	STF-029	Abdul Rehman Sultan	0.4611	recognized	2026-08-28 10:37:16.246276
75904	1917	breakin	343	Break In	27-08-2026 12:31:17	226309	0.85	normal	2026-08-28 07:23:42.515291	STF-017	Mohammad Zahid	0.4475	recognized	2026-08-28 07:23:44.210821
75908	1917	breakin	345	Break In	27-08-2026 12:31:00	227001	0.85	normal	2026-08-28 07:23:51.716213	STF-013	Muhammad Faizan	0.6331	recognized	2026-08-28 07:23:51.755109
75901	1917	breakin	273	Break In	27-08-2026 19:06:00	105059	0.85	normal	2026-08-28 07:23:38.283002	STF-007	Faisal Saleem	0.4756	recognized	2026-08-28 07:23:39.145481
75902	1916	attendance	481	Person Entered	27-08-2026 21:02:00	992997	0.85	pending	2026-08-28 07:23:39.612645	\N	Person #481	\N	pending	\N
75906	1916	attendance	483	Person Entered	27-08-2026 21:02:16	993222	0.85	unrecognized	2026-08-28 07:23:45.301247	\N	Person #483	0	unrecognized	2026-08-28 07:24:00.007208
75907	1917	breakin	274	Break In	27-08-2026 19:08:00	107949	0.85	unrecognized	2026-08-28 07:23:48.071327	\N	Person #274	0	unrecognized	2026-08-28 07:24:06.610051
75910	1917	breakin	345	Break In	27-08-2026 12:32:24	227966	0.85	unrecognized	2026-08-28 07:23:57.236038	\N	Person #345	0	unrecognized	2026-08-28 07:24:01.82337
75912	1916	attendance	486	Person Entered	27-08-2026 21:02:26	993596	0.85	unrecognized	2026-08-28 07:24:03.396462	\N	Person #486	0	unrecognized	2026-08-28 07:24:08.30597
76292	1917	breakin	343	Break In	27-08-2026 14:42:49	66421	0.85	unrecognized	2026-08-28 07:54:30.053488	\N	Person #343	0	unrecognized	2026-08-28 07:54:30.585557
76237	1917	breakin	330	Break In	27-08-2026 14:40:14	62526	0.85	normal	2026-08-28 07:51:45.307707	STF-050	Hafeez-Ur-Rehman	0.5615	recognized	2026-08-28 07:51:55.038947
77400	1917	breakin	793	Break In	27-08-2026 21:39:44	334621	0.85	pending	2026-08-28 09:06:27.36108	\N	Person #793	\N	pending	\N
78623	1918	breakout	297	Break Out	27-08-2026 20:21:30	214181	0.85	unrecognized	2026-08-28 10:37:21.911858	\N	Person #297	0	unrecognized	2026-08-28 10:37:25.715849
75917	1916	checkout	490	check_out	27-08-2026 21:02:28	993685	0.85	normal	2026-08-28 07:24:12.876609	STF-049	Nabi Ul Haq	0.5199	recognized	2026-08-28 07:24:14.787676
76241	1917	breakin	331	Break In	27-08-2026 14:40:40	63206	0.85	normal	2026-08-28 07:52:12.681501	STF-028	Noman Imran	0.5975	recognized	2026-08-28 07:52:13.107071
76147	1916	checkout	544	check_out	27-08-2026 21:04:46	997129	0.85	normal	2026-08-28 07:43:53.181551	STF-018	Muhammad Qaiser Shahzad	0.4469	recognized	2026-08-28 07:43:59.708343
76233	1917	breakin	329	Break In	27-08-2026 14:40:00	62180	0.85	normal	2026-08-28 07:51:25.110538	STF-033	Raza Abbas	0.491	recognized	2026-08-28 07:51:34.976597
78626	1918	breakout	296	Break Out	27-08-2026 20:21:37	214435	0.85	unrecognized	2026-08-28 10:37:26.279948	\N	Person #296	0	unrecognized	2026-08-28 10:37:26.299895
78294	1918	breakout	191	Break Out	27-08-2026 19:26:07	131118	0.85	normal	2026-08-28 10:18:23.932097	STF-027	Ahmed Hassan Bhatti	0.4836	recognized	2026-08-28 10:18:26.285272
78283	1918	breakout	186	Break Out	27-08-2026 19:20:37	122846	0.85	unrecognized	2026-08-28 10:17:47.01924	\N	Person #186	0	unrecognized	2026-08-28 10:18:01.665658
78290	1918	breakout	189	Break Out	27-08-2026 19:22:19	125438	0.85	unrecognized	2026-08-28 10:18:07.409493	\N	Person #189	0	unrecognized	2026-08-28 10:18:13.87595
77935	1918	breakout	51	Break Out	27-08-2026 11:02:51	89114	0.85	unrecognized	2026-08-28 09:59:00.57254	\N	Person #51	0	unrecognized	2026-08-28 09:59:15.81211
77928	1918	breakout	50	Break Out	27-08-2026 11:02:31	88565	0.85	unrecognized	2026-08-28 09:58:44.61211	\N	Person #50	0	unrecognized	2026-08-28 09:58:59.922328
78289	1918	breakout	188	Break Out	27-08-2026 19:21:45	124626	0.85	unrecognized	2026-08-28 10:18:06.073844	\N	Person #188	0	unrecognized	2026-08-28 10:18:06.669749
78278	1918	breakout	184	Break Out	27-08-2026 19:20:18	122373	0.85	unrecognized	2026-08-28 10:17:32.546214	\N	Person #184	0	unrecognized	2026-08-28 10:17:46.374481
78293	1918	breakout	190	Break Out	27-08-2026 19:23:02	126495	0.85	unrecognized	2026-08-28 10:18:15.171843	\N	Person #190	0	unrecognized	2026-08-28 10:18:21.799229
76301	1917	breakin	343	Break In	27-08-2026 14:43:50	67685	0.85	normal	2026-08-28 07:54:38.451286	STF-028	Noman Imran	0.5002	recognized	2026-08-28 07:55:12.369222
76378	1916	attendance	629	Person Entered	27-08-2026 21:15:58	1013927	0.85	pending	2026-08-28 07:59:57.70135	\N	Person #629	\N	pending	\N
76061	1916	attendance	528	Person Entered	27-08-2026 21:04:08	996164	0.85	unrecognized	2026-08-28 07:36:36.534057	\N	Person #528	0	unrecognized	2026-08-28 07:36:48.125694
76107	1917	breakin	329	Break In	27-08-2026 19:25:58	133952	0.85	normal	2026-08-28 07:40:16.761433	STF-027	Ahmed Hassan Bhatti	0.5301	recognized	2026-08-28 07:40:16.791353
78915	1918	breakout	329	Break Out	27-08-2026 13:17:38	295627	0.85	pending	2026-08-28 10:51:33.217513	\N	Person #329	0	unrecognized	\N
78924	1918	breakout	333	Break Out	27-08-2026 13:24:48	302116	0.85	normal	2026-08-28 10:52:13.673316	STF-004	Tanveer Hassan	0.541	recognized	2026-08-28 10:52:16.527192
78923	1918	breakout	332	Break Out	27-08-2026 13:23:10	299614	0.85	unrecognized	2026-08-28 10:52:06.930335	\N	Person #332	0	unrecognized	2026-08-28 10:52:12.328851
78920	1918	breakout	331	Break Out	27-08-2026 13:21:41	297396	0.85	unrecognized	2026-08-28 10:51:53.738794	\N	Person #331	0	unrecognized	2026-08-28 10:52:05.793061
78916	1918	breakout	330	Break Out	27-08-2026 13:21:19	296834	0.85	unrecognized	2026-08-28 10:51:38.219886	\N	Person #330	0	unrecognized	2026-08-28 10:51:52.867836
76379	1916	attendance	632	Person Entered	27-08-2026 21:15:59	1013961	0.85	pending	2026-08-28 08:00:00.411916	\N	Person #632	\N	pending	\N
79099	1918	breakout	409	Break Out	27-08-2026 17:02:12	271989	0.85	unrecognized	2026-08-28 11:02:01.620417	\N	Person #409	0	unrecognized	2026-08-28 11:02:18.598028
76416	1917	breakin	400	Break In	27-08-2026 14:47:00	73709	0.85	normal	2026-08-28 08:02:35.601547	STF-020	Syed Jahazaib Ahmad Alvi	0.4967	recognized	2026-08-28 08:02:37.443011
76380	1916	attendance	633	Person Entered	27-08-2026 21:16:00	1013970	0.85	unrecognized	2026-08-28 08:00:01.123579	\N	Person #633	0	unrecognized	2026-08-28 08:01:36.831585
79104	1918	breakout	410	Break Out	27-08-2026 17:02:45	273110	0.85	normal	2026-08-28 11:02:19.465718	STF-035	Hammad Shaukat	0.4545	recognized	2026-08-28 11:02:20.675803
76419	1917	breakin	401	Break In	27-08-2026 14:47:00	73785	0.85	normal	2026-08-28 08:02:40.855111	STF-006	Muhammad Abubakar	0.4758	recognized	2026-08-28 08:02:43.254554
76425	1917	breakin	402	Break In	27-08-2026 14:48:07	74350	0.85	normal	2026-08-28 08:03:02.305462	STF-008	Muhammad Shoaib	0.446	recognized	2026-08-28 08:03:12.296184
76426	1917	breakin	403	Break In	27-08-2026 14:48:08	74375	0.85	normal	2026-08-28 08:03:07.729309	STF-006	Muhammad Abubakar	0.4559	recognized	2026-08-28 08:03:18.424639
76471	1917	breakin	429	Break In	27-08-2026 14:50:28	77923	0.85	normal	2026-08-28 08:06:33.159849	STF-034	Muhammad Laeeq	0.643	recognized	2026-08-28 08:06:33.195275
76475	1917	breakin	431	Break In	27-08-2026 14:50:32	78006	0.85	normal	2026-08-28 08:06:35.426363	STF-008	Muhammad Shoaib	0.4474	recognized	2026-08-28 08:06:36.074791
76478	1917	breakin	435	Break In	27-08-2026 14:52:25	80833	0.85	normal	2026-08-28 08:06:43.159955	STF-031	Muhammad Hassan	0.4779	recognized	2026-08-28 08:06:43.202364
77944	1918	breakout	63	Break Out	27-08-2026 18:31:32	49207	0.85	unrecognized	2026-08-28 09:59:26.707143	\N	Person #63	0	unrecognized	2026-08-28 09:59:40.592704
78291	1918	breakout	171	Break Out	27-08-2026 14:59:33	88212	0.85	unrecognized	2026-08-28 10:18:07.915233	\N	Person #171	0	unrecognized	2026-08-28 10:18:37.394632
75918	1916	attendance	493	Person Entered	27-08-2026 21:02:31	993732	0.85	unrecognized	2026-08-28 07:24:18.305113	\N	Person #493	0	unrecognized	2026-08-28 07:24:35.948863
78638	1918	breakout	300	Break Out	27-08-2026 20:29:12	225707	0.85	unrecognized	2026-08-28 10:38:22.268681	\N	Person #300	0	unrecognized	2026-08-28 10:38:35.438605
76317	1917	breakin	372	Break In	27-08-2026 19:40:06	155162	0.85	normal	2026-08-28 07:56:07.671265	STF-044	Zaheer Hussain	0.443	recognized	2026-08-28 07:56:08.193435
75915	1917	breakin	274	Break In	27-08-2026 19:09:32	109238	0.85	unrecognized	2026-08-28 07:24:07.654991	\N	Person #274	0	unrecognized	2026-08-28 07:24:23.534902
75925	1916	checkout	498	check_out	27-08-2026 21:02:33	993810	0.85	normal	2026-08-28 07:24:51.937554	STF-050	Hafeez-Ur-Rehman	0.4618	recognized	2026-08-28 07:24:58.766963
76191	1917	breakin	448	Break In	27-08-2026 13:25:02	306918	0.85	normal	2026-08-28 07:47:22.476285	STF-036	Shahzad Ali	0.4728	recognized	2026-08-28 07:47:31.050531
75942	1916	attendance	503	Person Entered	27-08-2026 21:02:41	993998	0.85	unrecognized	2026-08-28 07:26:35.698857	\N	Person #503	0	unrecognized	2026-08-28 07:26:40.001309
75927	1916	attendance	500	Person Entered	27-08-2026 21:02:34	993823	0.85	unrecognized	2026-08-28 07:24:59.194147	\N	Person #500	0	unrecognized	2026-08-28 07:25:00.881995
78631	1918	breakout	298	Break Out	27-08-2026 20:25:54	220765	0.85	unrecognized	2026-08-28 10:37:42.589192	\N	Person #298	0	unrecognized	2026-08-28 10:37:55.981709
78630	1918	breakout	297	Break Out	27-08-2026 20:24:19	218363	0.85	unrecognized	2026-08-28 10:37:30.706433	\N	Person #297	0	unrecognized	2026-08-28 10:37:41.080607
75921	1916	checkout	495	check_out	27-08-2026 21:02:32	993756	0.85	normal	2026-08-28 07:24:26.70844	STF-050	Hafeez-Ur-Rehman	0.4702	recognized	2026-08-28 07:24:47.941062
78922	1918	breakout	388	Break Out	27-08-2026 20:58:25	269349	0.85	unrecognized	2026-08-28 10:52:03.060833	\N	Person #388	0	unrecognized	2026-08-28 10:52:49.330627
78279	1918	breakout	168	Break Out	27-08-2026 14:59:11	87673	0.85	unrecognized	2026-08-28 10:17:33.406654	\N	Person #168	0	unrecognized	2026-08-28 10:17:45.274357
75943	1916	checkout	505	check_out	27-08-2026 21:02:42	994021	0.85	normal	2026-08-28 07:26:43.468582	STF-086	Muhammad Moaaz Khan	0.4554	recognized	2026-08-28 07:26:46.96399
76151	1916	attendance	547	Person Entered	27-08-2026 21:05:15	997744	0.85	unrecognized	2026-08-28 07:44:22.593309	\N	Person #547	0	unrecognized	2026-08-28 07:45:05.046204
75919	1916	attendance	494	Person Entered	27-08-2026 21:02:30	993740	0.85	pending	2026-08-28 07:24:19.374233	\N	Person #494	0	unrecognized	\N
75923	1916	attendance	496	Person Entered	27-08-2026 21:02:32	993790	0.85	unrecognized	2026-08-28 07:24:45.704629	\N	Person #496	0	unrecognized	2026-08-28 07:24:50.469817
75929	1916	checkout	501	check_out	27-08-2026 21:02:39	993839	0.85	normal	2026-08-28 07:25:02.116862	STF-058	Muhammad Iqbal Butt	0.4471	recognized	2026-08-28 07:26:18.931261
75924	1916	attendance	497	Person Entered	27-08-2026 21:02:33	993804	0.85	unrecognized	2026-08-28 07:24:51.303269	\N	Person #497	0	unrecognized	2026-08-28 07:24:58.434343
78634	1918	breakout	299	Break Out	27-08-2026 20:26:08	221113	0.85	unrecognized	2026-08-28 10:37:56.877129	\N	Person #299	0	unrecognized	2026-08-28 10:38:05.331851
78917	1918	breakout	387	Break Out	27-08-2026 20:58:11	269232	0.85	unrecognized	2026-08-28 10:51:40.374433	\N	Person #387	0	unrecognized	2026-08-28 10:51:50.557334
75920	1917	breakin	274	Break In	27-08-2026 19:11:02	111437	0.85	normal	2026-08-28 07:24:25.008062	STF-013	Muhammad Faizan	0.5252	recognized	2026-08-28 07:24:55.241503
78636	1918	breakout	299	Break Out	27-08-2026 20:27:04	222508	0.85	unrecognized	2026-08-28 10:38:06.105999	\N	Person #299	0	unrecognized	2026-08-28 10:38:20.434855
79103	1918	breakout	396	Break Out	27-08-2026 13:47:00	336606	0.85	unrecognized	2026-08-28 11:02:16.212449	\N	Person #396	0	unrecognized	2026-08-28 11:02:23.465963
76054	1917	breakin	276	Break In	27-08-2026 14:35:02	52809	0.85	unrecognized	2026-08-28 07:36:29.813443	\N	Person #276	0	unrecognized	2026-08-28 07:39:07.685977
76234	1916	attendance	563	Person Entered	27-08-2026 21:08:29	1002560	0.85	unrecognized	2026-08-28 07:51:29.846758	\N	Person #563	0	unrecognized	2026-08-28 07:52:16.554926
79106	1918	breakout	397	Break Out	27-08-2026 13:47:52	336729	0.85	normal	2026-08-28 11:02:24.002104	STF-015	Liaqat Ali	0.4752	recognized	2026-08-28 11:02:26.579721
79404	1950	breakin	56	Break In	25-08-2026 19:02:27	11202	0.85	normal	2026-08-28 14:28:01.599922	STF-010	Faraz Younas	0.4821	recognized	2026-08-28 14:28:07.569222
75933	1917	breakin	350	Break In	27-08-2026 12:33:00	230075	0.85	normal	2026-08-28 07:25:31.560316	STF-013	Muhammad Faizan	0.4851	recognized	2026-08-28 07:25:41.597704
75930	1916	attendance	502	Person Entered	27-08-2026 21:02:41	993853	0.85	unrecognized	2026-08-28 07:25:08.74218	\N	Person #502	0	unrecognized	2026-08-28 07:26:42.439925
76309	1917	breakin	369	Break In	27-08-2026 19:38:01	151945	0.85	normal	2026-08-28 07:55:30.808939	STF-008	Muhammad Shoaib	0.4518	recognized	2026-08-28 07:55:49.003925
76314	1917	breakin	372	Break In	27-08-2026 19:39:28	154124	0.85	unrecognized	2026-08-28 07:55:54.919254	\N	Person #372	0	unrecognized	2026-08-28 07:56:06.697765
76318	1917	breakin	373	Break In	27-08-2026 19:40:17	155431	0.85	normal	2026-08-28 07:56:13.738733	STF-045	Zohaib Ali Chaudhary	0.5779	recognized	2026-08-28 07:56:13.79957
76349	1916	attendance	607	Person Entered	27-08-2026 21:12:08	1008192	0.85	pending	2026-08-28 07:57:21.916417	\N	Person #607	0	unrecognized	\N
76356	1916	attendance	612	Person Entered	27-08-2026 21:12:18	1008437	0.85	unrecognized	2026-08-28 07:58:00.82787	\N	Person #612	0	unrecognized	2026-08-28 07:58:08.753693
76468	1916	checkout	656	check_out	27-08-2026 21:22:41	1023977	0.85	normal	2026-08-28 08:06:14.161891	STF-029	Abdul Rehman Sultan	0.4571	recognized	2026-08-28 08:06:29.599545
76156	1917	breakin	427	Break In	27-08-2026 13:09:00	282740	0.85	unrecognized	2026-08-28 07:44:41.427348	\N	Person #427	0	unrecognized	2026-08-28 07:45:01.441708
76008	1917	breakin	370	Break In	27-08-2026 12:42:52	243700	0.85	normal	2026-08-28 07:33:13.22411	STF-026	Syed Zeeshan Ali	0.4518	recognized	2026-08-28 07:33:13.697824
77954	1918	breakout	56	Break Out	27-08-2026 11:03:48	90587	0.85	normal	2026-08-28 10:00:02.311559	STF-045	Zohaib Ali Chaudhary	0.5362	recognized	2026-08-28 10:00:11.982062
75944	1917	breakin	267	Break In	27-08-2026 14:31:59	49838	0.85	normal	2026-08-28 07:26:47.890566	STF-029	Abdul Rehman Sultan	0.6652	recognized	2026-08-28 07:27:16.191916
76498	1916	attendance	668	Person Entered	27-08-2026 21:25:18	1027938	0.85	pending	2026-08-28 08:08:13.584699	\N	Person #668	\N	pending	\N
76480	1916	checkout	658	check_out	27-08-2026 21:23:10	1024742	0.85	normal	2026-08-28 08:06:45.32376	STF-048	Abdullah Sultan	0.5132	recognized	2026-08-28 08:06:45.363654
77949	1918	breakout	55	Break Out	27-08-2026 11:03:00	90499	0.85	unrecognized	2026-08-28 09:59:49.409354	\N	Person #55	0	unrecognized	2026-08-28 10:00:07.507335
76161	1917	breakin	429	Break In	27-08-2026 13:10:14	284724	0.85	normal	2026-08-28 07:45:03.125571	STF-034	Muhammad Laeeq	0.5297	recognized	2026-08-28 07:45:04.374659
76389	1917	breakin	401	Break In	27-08-2026 19:52:25	173632	0.85	normal	2026-08-28 08:00:34.606737	STF-029	Abdul Rehman Sultan	0.5641	recognized	2026-08-28 08:00:34.640646
76152	1917	breakin	426	Break In	27-08-2026 13:08:53	282676	0.85	unrecognized	2026-08-28 07:44:31.983994	\N	Person #426	0	unrecognized	2026-08-28 07:44:40.790772
78302	1918	breakout	194	Break Out	27-08-2026 19:27:09	132612	0.85	unrecognized	2026-08-28 10:18:47.302476	\N	Person #194	0	unrecognized	2026-08-28 10:19:01.937562
78295	1918	breakout	192	Break Out	27-08-2026 19:26:54	132255	0.85	unrecognized	2026-08-28 10:18:29.24943	\N	Person #192	0	unrecognized	2026-08-28 10:18:46.508331
76528	1916	checkout	684	check_out	27-08-2026 21:30:45	1036094	0.85	normal	2026-08-28 08:11:35.286308	STF-051	Shakir Khan	0.459	recognized	2026-08-28 08:11:39.96569
78309	1918	breakout	195	Break Out	27-08-2026 19:27:00	133570	0.85	unrecognized	2026-08-28 10:19:11.510401	\N	Person #195	0	unrecognized	2026-08-28 10:19:11.649519
76238	1917	breakin	353	Break In	27-08-2026 19:29:00	139559	0.85	unrecognized	2026-08-28 07:52:03.118669	\N	Person #353	0	unrecognized	2026-08-28 07:52:08.51124
78313	1918	breakout	195	Break Out	27-08-2026 19:28:43	135041	0.85	unrecognized	2026-08-28 10:19:13.180466	\N	Person #195	0	unrecognized	2026-08-28 10:19:13.437825
76006	1917	breakin	369	Break In	27-08-2026 12:39:16	238198	0.85	unrecognized	2026-08-28 07:32:37.860896	\N	Person #369	0	unrecognized	2026-08-28 07:33:02.46362
76112	1917	breakin	411	Break In	27-08-2026 13:03:32	274608	0.85	normal	2026-08-28 07:40:44.173388	STF-025	Farhan Virk	0.4484	recognized	2026-08-28 07:40:50.19463
76067	1916	attendance	529	Person Entered	27-08-2026 21:04:16	996213	0.85	unrecognized	2026-08-28 07:37:06.558533	\N	Person #529	0	unrecognized	2026-08-28 07:39:34.696242
78305	1918	breakout	194	Break Out	27-08-2026 19:27:28	133084	0.85	unrecognized	2026-08-28 10:19:02.361425	\N	Person #194	0	unrecognized	2026-08-28 10:19:10.870275
76110	1917	breakin	411	Break In	27-08-2026 13:02:21	272913	0.85	normal	2026-08-28 07:40:31.48441	STF-022	Mubashir Ishaq	0.4655	recognized	2026-08-28 07:40:31.532837
78310	1918	breakout	195	Break Out	27-08-2026 19:28:09	134197	0.85	unrecognized	2026-08-28 10:19:12.084383	\N	Person #195	0	unrecognized	2026-08-28 10:19:12.599103
76114	1917	breakin	412	Break In	27-08-2026 13:04:21	275935	0.85	normal	2026-08-28 07:40:56.309353	STF-025	Farhan Virk	0.6254	recognized	2026-08-28 07:40:56.34526
76162	1917	breakin	429	Break In	27-08-2026 13:10:46	285442	0.85	unrecognized	2026-08-28 07:45:07.342007	\N	Person #429	0	unrecognized	2026-08-28 07:45:22.619967
76007	1917	breakin	369	Break In	27-08-2026 12:42:01	242395	0.85	normal	2026-08-28 07:33:04.768188	STF-034	Muhammad Laeeq	0.4837	recognized	2026-08-28 07:33:09.868183
78314	1918	breakout	196	Break Out	27-08-2026 19:29:39	136485	0.85	pending	2026-08-28 10:19:14.52181	\N	Person #196	0	unrecognized	\N
76240	1917	breakin	354	Break In	27-08-2026 19:30:03	140084	0.85	normal	2026-08-28 07:52:10.306903	STF-013	Muhammad Faizan	0.5432	recognized	2026-08-28 07:52:10.332783
76423	1916	attendance	641	Person Entered	27-08-2026 21:18:00	1017713	0.85	unrecognized	2026-08-28 08:02:52.883769	\N	Person #641	0	unrecognized	2026-08-28 08:03:07.754243
76352	1916	attendance	610	Person Entered	27-08-2026 21:12:19	1008362	0.85	unrecognized	2026-08-28 07:57:29.682396	\N	Person #610	0	unrecognized	2026-08-28 07:58:33.720273
78632	1918	breakout	271	Break Out	27-08-2026 15:59:27	178128	0.85	normal	2026-08-28 10:37:50.115632	STF-002	Abdur Rehman	0.446	recognized	2026-08-28 10:37:52.837841
76391	1917	breakin	402	Break In	27-08-2026 19:54:06	176149	0.85	normal	2026-08-28 08:00:44.093865	STF-017	Mohammad Zahid	0.4517	recognized	2026-08-28 08:00:44.63214
76242	1917	breakin	355	Break In	27-08-2026 19:30:07	140161	0.85	normal	2026-08-28 07:52:13.688445	STF-026	Syed Zeeshan Ali	0.4615	recognized	2026-08-28 07:52:16.977549
76460	1916	attendance	652	Person Entered	27-08-2026 21:22:10	1023198	0.85	unrecognized	2026-08-28 08:05:25.336077	\N	Person #652	0	unrecognized	2026-08-28 08:05:41.972791
76467	1916	attendance	655	Person Entered	27-08-2026 21:22:34	1023830	0.85	pending	2026-08-28 08:06:11.440931	\N	Person #655	\N	pending	\N
76500	1916	attendance	669	Person Entered	27-08-2026 21:25:19	1027950	0.85	unrecognized	2026-08-28 08:08:14.331458	\N	Person #669	0	unrecognized	2026-08-28 08:08:18.970686
76397	1917	breakin	407	Break In	27-08-2026 19:55:51	178771	0.85	normal	2026-08-28 08:01:12.861536	STF-046	Usman Babar	0.4523	recognized	2026-08-28 08:01:15.342884
76427	1916	attendance	643	Person Entered	27-08-2026 21:18:00	1018154	0.85	unrecognized	2026-08-28 08:03:10.775585	\N	Person #643	0	unrecognized	2026-08-28 08:04:21.448988
76509	1917	breakin	446	Break In	27-08-2026 14:57:00	88422	0.85	normal	2026-08-28 08:09:21.311519	STF-035	Hammad Shaukat	0.4597	recognized	2026-08-28 08:11:21.126067
76510	1917	breakin	448	Break In	27-08-2026 14:57:33	88505	0.85	normal	2026-08-28 08:09:42.138262	STF-035	Hammad Shaukat	0.4414	recognized	2026-08-28 08:10:09.351483
76501	1916	checkout	671	check_out	27-08-2026 21:25:32	1028270	0.85	normal	2026-08-28 08:08:23.544026	STF-047	Arshad Irshad	0.45	recognized	2026-08-28 08:08:33.266477
76012	1917	breakin	372	Break In	27-08-2026 12:44:11	245671	0.85	unrecognized	2026-08-28 07:33:46.021112	\N	Person #372	0	unrecognized	2026-08-28 07:33:46.92944
76014	1917	breakin	374	Break In	27-08-2026 12:45:00	247733	0.85	unrecognized	2026-08-28 07:33:54.246093	\N	Person #374	0	unrecognized	2026-08-28 07:34:17.302152
77953	1918	breakout	74	Break Out	27-08-2026 14:20:11	29181	0.85	normal	2026-08-28 09:59:59.102131	STF-029	Abdul Rehman Sultan	0.4498	recognized	2026-08-28 10:00:04.294258
78918	1918	breakout	346	Break Out	27-08-2026 16:32:37	227896	0.85	normal	2026-08-28 10:51:40.845863	STF-028	Noman Imran	0.5104	recognized	2026-08-28 10:51:42.042306
78311	1918	breakout	163	Break Out	27-08-2026 11:54:53	167207	0.85	unrecognized	2026-08-28 10:19:13.05979	\N	Person #163	0	unrecognized	2026-08-28 10:19:28.964107
76197	1917	breakin	452	Break In	27-08-2026 13:25:35	307783	0.85	normal	2026-08-28 07:48:23.636342	STF-008	Muhammad Shoaib	0.4496	recognized	2026-08-28 07:48:23.683216
77946	1918	breakout	72	Break Out	27-08-2026 14:19:32	28198	0.85	unrecognized	2026-08-28 09:59:32.25716	\N	Person #72	0	unrecognized	2026-08-28 09:59:48.261342
76074	1917	breakin	397	Break In	27-08-2026 12:54:51	261583	0.85	unrecognized	2026-08-28 07:37:47.421196	\N	Person #397	0	unrecognized	2026-08-28 07:38:08.573922
76198	1917	breakin	453	Break In	27-08-2026 13:27:23	310480	0.85	normal	2026-08-28 07:48:50.441783	STF-001	Ikram Hassan	0.7081	recognized	2026-08-28 07:48:50.46543
76158	1917	breakin	288	Break In	27-08-2026 14:37:10	57904	0.85	normal	2026-08-28 07:44:51.391231	STF-029	Abdul Rehman Sultan	0.5598	recognized	2026-08-28 07:44:54.857533
77961	1918	breakout	77	Break Out	27-08-2026 14:20:45	29934	0.85	unrecognized	2026-08-28 10:00:21.753075	\N	Person #77	0	unrecognized	2026-08-28 10:00:31.09289
76200	1917	breakin	454	Break In	27-08-2026 13:27:26	310550	0.85	normal	2026-08-28 07:48:55.223783	STF-036	Shahzad Ali	0.4446	recognized	2026-08-28 07:48:55.666188
76081	1917	breakin	398	Break In	27-08-2026 12:59:12	268184	0.85	unrecognized	2026-08-28 07:38:12.144891	\N	Person #398	0	unrecognized	2026-08-28 07:38:15.357791
75946	1917	breakin	288	Break In	27-08-2026 19:12:00	114067	0.85	normal	2026-08-28 07:26:48.878279	STF-013	Muhammad Faizan	0.5005	recognized	2026-08-28 07:26:54.101932
76115	1916	attendance	537	Person Entered	27-08-2026 21:04:22	996533	0.85	pending	2026-08-28 07:40:56.512961	\N	Person #537	0	unrecognized	\N
78303	1918	breakout	162	Break Out	27-08-2026 11:51:05	166169	0.85	pending	2026-08-28 10:18:48.724472	\N	Person #162	0	unrecognized	\N
78925	1918	breakout	350	Break Out	27-08-2026 16:35:49	232679	0.85	unrecognized	2026-08-28 10:52:14.722689	\N	Person #350	0	unrecognized	2026-08-28 10:52:15.954528
76070	1917	breakin	396	Break In	27-08-2026 12:54:30	261030	0.85	unrecognized	2026-08-28 07:37:20.851767	\N	Person #396	0	unrecognized	2026-08-28 07:37:46.298018
78301	1918	breakout	161	Break Out	27-08-2026 11:54:19	166162	0.85	normal	2026-08-28 10:18:47.046466	STF-004	Tanveer Hassan	0.534	recognized	2026-08-28 10:19:10.404272
76387	1917	breakin	385	Break In	27-08-2026 14:47:16	73121	0.85	normal	2026-08-28 08:00:25.770785	STF-002	Abdur Rehman	0.5625	recognized	2026-08-28 08:00:25.82863
76248	1916	attendance	565	Person Entered	27-08-2026 21:08:44	1003049	0.85	unrecognized	2026-08-28 07:52:36.008637	\N	Person #565	0	unrecognized	2026-08-28 07:52:52.335466
76010	1917	breakin	372	Break In	27-08-2026 12:43:12	244188	0.85	normal	2026-08-28 07:33:42.329162	STF-034	Muhammad Laeeq	0.4419	recognized	2026-08-28 07:33:42.369056
76011	1917	breakin	372	Break In	27-08-2026 12:43:53	245436	0.85	pending	2026-08-28 07:33:45.634824	\N	Person #372	\N	pending	\N
76153	1917	breakin	302	Break In	27-08-2026 14:36:00	57264	0.85	normal	2026-08-28 07:44:34.8458	STF-025	Farhan Virk	0.513	recognized	2026-08-28 07:44:38.283361
76154	1917	breakin	299	Break In	27-08-2026 14:36:00	57324	0.85	normal	2026-08-28 07:44:39.472118	STF-029	Abdul Rehman Sultan	0.4507	recognized	2026-08-28 07:44:39.606311
78926	1918	breakout	350	Break Out	27-08-2026 16:36:01	232894	0.85	unrecognized	2026-08-28 10:52:16.268762	\N	Person #350	0	unrecognized	2026-08-28 10:52:18.3105
76311	1917	breakin	361	Break In	27-08-2026 14:43:58	68137	0.85	normal	2026-08-28 07:55:40.135781	STF-002	Abdur Rehman	0.4792	recognized	2026-08-28 07:55:43.816062
78921	1918	breakout	349	Break Out	27-08-2026 16:35:42	232357	0.85	unrecognized	2026-08-28 10:51:59.405085	\N	Person #349	0	unrecognized	2026-08-28 10:52:14.325694
76353	1917	breakin	481	Break In	27-08-2026 13:39:38	328801	0.85	unrecognized	2026-08-28 07:57:30.320608	\N	Person #481	0	unrecognized	2026-08-28 07:57:41.85265
76254	1916	attendance	566	Person Entered	27-08-2026 21:08:47	1003137	0.85	unrecognized	2026-08-28 07:52:54.310902	\N	Person #566	0	unrecognized	2026-08-28 07:53:07.660376
76263	1916	attendance	570	Person Entered	27-08-2026 21:09:06	1003639	0.85	pending	2026-08-28 07:53:15.246312	\N	Person #570	\N	pending	\N
76245	1916	attendance	564	Person Entered	27-08-2026 21:08:34	1002800	0.85	unrecognized	2026-08-28 07:52:19.110527	\N	Person #564	0	unrecognized	2026-08-28 07:52:33.971664
78930	1918	breakout	354	Break Out	27-08-2026 16:36:37	233927	0.85	pending	2026-08-28 10:52:29.666181	\N	Person #354	\N	pending	\N
78931	1918	breakout	354	Break Out	27-08-2026 16:36:51	234278	0.85	unrecognized	2026-08-28 10:52:29.988723	\N	Person #354	0	unrecognized	2026-08-28 10:52:30.286872
76486	1917	breakin	438	Break In	27-08-2026 14:53:09	81875	0.85	unrecognized	2026-08-28 08:07:13.475528	\N	Person #438	0	unrecognized	2026-08-28 08:07:25.264961
76507	1916	attendance	676	Person Entered	27-08-2026 21:28:03	1032038	0.85	unrecognized	2026-08-28 08:09:07.807072	\N	Person #676	0	unrecognized	2026-08-28 08:09:19.05324
75945	1916	attendance	506	Person Entered	27-08-2026 21:02:42	994037	0.85	pending	2026-08-28 07:26:47.94841	\N	Person #506	0	unrecognized	\N
76482	1916	checkout	659	check_out	27-08-2026 21:23:25	1025094	0.85	normal	2026-08-28 08:06:56.854005	STF-044	Zaheer Hussain	0.4925	recognized	2026-08-28 08:07:00.304788
76432	1917	breakin	407	Break In	27-08-2026 14:48:37	75133	0.85	normal	2026-08-28 08:03:41.443287	STF-028	Noman Imran	0.6332	recognized	2026-08-28 08:03:41.475707
78297	1918	breakout	170	Break Out	27-08-2026 15:00:28	89725	0.85	pending	2026-08-28 10:18:38.235191	\N	Person #170	\N	pending	\N
76462	1916	checkout	654	check_out	27-08-2026 21:22:30	1023692	0.85	normal	2026-08-28 08:05:45.928944	STF-045	Zohaib Ali Chaudhary	0.5011	recognized	2026-08-28 08:06:03.300758
76312	1916	attendance	583	Person Entered	27-08-2026 21:10:53	1006299	0.85	unrecognized	2026-08-28 07:55:48.436216	\N	Person #583	0	unrecognized	2026-08-28 07:55:59.857156
76247	1917	breakin	356	Break In	27-08-2026 19:30:56	141298	0.85	unrecognized	2026-08-28 07:52:28.193447	\N	Person #356	0	unrecognized	2026-08-28 07:52:50.758424
76124	1917	breakin	416	Break In	27-08-2026 13:05:14	277228	0.85	normal	2026-08-28 07:41:55.693913	STF-029	Abdul Rehman Sultan	0.4873	recognized	2026-08-28 07:42:00.492395
76483	1916	checkout	661	check_out	27-08-2026 21:23:31	1025165	0.85	normal	2026-08-28 08:07:05.719256	STF-046	Usman Babar	0.4605	recognized	2026-08-28 08:07:48.329625
76130	1917	breakin	419	Break In	27-08-2026 13:05:47	277783	0.85	unrecognized	2026-08-28 07:42:14.554139	\N	Person #419	0	unrecognized	2026-08-28 07:43:32.971285
75950	1916	attendance	508	Person Entered	27-08-2026 21:03:12	994541	0.85	unrecognized	2026-08-28 07:26:55.867249	\N	Person #508	0	unrecognized	2026-08-28 07:28:14.404519
77950	1918	breakout	64	Break Out	27-08-2026 18:32:03	49972	0.85	normal	2026-08-28 09:59:50.067498	STF-010	Faraz Younas	0.5131	recognized	2026-08-28 09:59:57.670588
76073	1917	breakin	277	Break In	27-08-2026 14:34:33	53549	0.85	unrecognized	2026-08-28 07:37:39.548882	\N	Person #277	0	unrecognized	2026-08-28 07:38:41.417138
78299	1918	breakout	174	Break Out	27-08-2026 15:00:51	90192	0.85	unrecognized	2026-08-28 10:18:39.146258	\N	Person #174	0	unrecognized	2026-08-28 10:18:44.843807
77958	1918	breakout	71	Break Out	27-08-2026 18:33:54	52756	0.85	unrecognized	2026-08-28 10:00:18.278753	\N	Person #71	0	unrecognized	2026-08-28 10:00:30.058092
78635	1918	breakout	272	Break Out	27-08-2026 16:01:44	181513	0.85	unrecognized	2026-08-28 10:37:56.906052	\N	Person #272	0	unrecognized	2026-08-28 10:38:11.760662
78306	1918	breakout	177	Break Out	27-08-2026 15:01:12	90784	0.85	unrecognized	2026-08-28 10:19:04.982004	\N	Person #177	0	unrecognized	2026-08-28 10:19:05.849043
76118	1917	breakin	414	Break In	27-08-2026 13:04:00	276515	0.85	normal	2026-08-28 07:41:24.002556	STF-008	Muhammad Shoaib	0.5527	recognized	2026-08-28 07:41:29.181608
78312	1918	breakout	179	Break Out	27-08-2026 15:01:56	91860	0.85	unrecognized	2026-08-28 10:19:13.139574	\N	Person #179	0	unrecognized	2026-08-28 10:19:35.951078
77956	1918	breakout	69	Break Out	27-08-2026 18:32:57	51346	0.85	unrecognized	2026-08-28 10:00:13.758174	\N	Person #69	0	unrecognized	2026-08-28 10:00:17.06935
76201	1916	attendance	551	Person Entered	27-08-2026 21:05:47	998624	0.85	unrecognized	2026-08-28 07:48:59.04171	\N	Person #551	0	unrecognized	2026-08-28 07:49:11.2696
78300	1918	breakout	175	Break Out	27-08-2026 15:01:05	90511	0.85	unrecognized	2026-08-28 10:18:45.939929	\N	Person #175	0	unrecognized	2026-08-28 10:18:55.205728
76433	1917	breakin	408	Break In	27-08-2026 14:48:46	75350	0.85	normal	2026-08-28 08:03:45.225082	STF-034	Muhammad Laeeq	0.4849	recognized	2026-08-28 08:03:53.833437
78307	1918	breakout	177	Break Out	27-08-2026 15:01:18	90911	0.85	unrecognized	2026-08-28 10:19:06.144893	\N	Person #177	0	unrecognized	2026-08-28 10:19:07.844912
76253	1917	breakin	357	Break In	27-08-2026 19:31:16	141828	0.85	unrecognized	2026-08-28 07:52:51.670497	\N	Person #357	0	unrecognized	2026-08-28 07:53:04.85261
76071	1917	breakin	284	Break In	27-08-2026 14:34:17	53502	0.85	unrecognized	2026-08-28 07:37:36.081988	\N	Person #284	0	unrecognized	2026-08-28 07:37:59.188622
76257	1917	breakin	358	Break In	27-08-2026 19:32:59	144481	0.85	normal	2026-08-28 07:53:06.414635	STF-011	Syed Shoaib Ahmad Alvi	0.4991	recognized	2026-08-28 07:53:06.454527
76259	1917	breakin	359	Break In	27-08-2026 19:33:31	145295	0.85	normal	2026-08-28 07:53:09.301806	STF-044	Zaheer Hussain	0.6608	recognized	2026-08-28 07:53:09.32014
76246	1917	breakin	356	Break In	27-08-2026 19:30:49	141121	0.85	unrecognized	2026-08-28 07:52:21.75565	\N	Person #356	0	unrecognized	2026-08-28 07:52:27.52199
78637	1918	breakout	272	Break Out	27-08-2026 16:02:39	182866	0.85	unrecognized	2026-08-28 10:38:12.532574	\N	Person #272	0	unrecognized	2026-08-28 10:38:29.027491
76361	1917	breakin	377	Break In	27-08-2026 14:46:03	71283	0.85	normal	2026-08-28 07:58:45.577799	STF-028	Noman Imran	0.4609	recognized	2026-08-28 07:58:49.462094
76262	1917	breakin	359	Break In	27-08-2026 19:33:55	145877	0.85	normal	2026-08-28 07:53:13.176689	STF-035	Hammad Shaukat	0.4714	recognized	2026-08-28 07:53:14.541581
78639	1918	breakout	274	Break Out	27-08-2026 16:03:00	183421	0.85	unrecognized	2026-08-28 10:38:29.796829	\N	Person #274	0	unrecognized	2026-08-28 10:38:40.015705
76436	1917	breakin	409	Break In	27-08-2026 14:48:55	75562	0.85	normal	2026-08-28 08:04:03.683449	STF-006	Muhammad Abubakar	0.483	recognized	2026-08-28 08:04:10.733739
76512	1917	breakin	442	Break In	27-08-2026 20:07:15	195877	0.85	normal	2026-08-28 08:10:05.109556	STF-006	Muhammad Abubakar	0.522	recognized	2026-08-28 08:10:10.511924
76511	1917	breakin	441	Break In	27-08-2026 20:07:09	195721	0.85	normal	2026-08-28 08:09:43.916069	STF-034	Muhammad Laeeq	0.5182	recognized	2026-08-28 08:09:43.960949
76515	1917	breakin	445	Break In	27-08-2026 20:07:17	195925	0.85	normal	2026-08-28 08:10:13.74077	STF-002	Abdur Rehman	0.5107	recognized	2026-08-28 08:10:14.680269
76508	1916	attendance	678	Person Entered	27-08-2026 21:28:14	1032114	0.85	unrecognized	2026-08-28 08:09:21.145115	\N	Person #678	0	unrecognized	2026-08-28 08:10:53.856054
77280	1917	breakin	845	Break In	27-08-2026 16:12:00	201221	0.85	normal	2026-08-28 08:59:56.301194	STF-026	Syed Zeeshan Ali	0.4853	recognized	2026-08-28 08:59:56.317009
78328	1918	breakout	168	Break Out	27-08-2026 11:56:33	169719	0.85	normal	2026-08-28 10:20:22.249672	STF-004	Tanveer Hassan	0.4403	recognized	2026-08-28 10:20:35.650185
77118	1917	breakin	659	Break In	27-08-2026 21:00:44	275921	0.85	normal	2026-08-28 08:47:46.979759	STF-001	Ikram Hassan	0.5503	recognized	2026-08-28 08:48:04.600239
77356	1917	breakin	878	Break In	27-08-2026 16:18:52	210379	0.85	unrecognized	2026-08-28 09:04:15.507259	\N	Person #878	0	unrecognized	2026-08-28 09:04:27.035405
77211	1917	breakin	704	Break In	27-08-2026 21:11:34	292228	0.85	unrecognized	2026-08-28 08:53:48.938719	\N	Person #704	0	unrecognized	2026-08-28 08:53:55.24562
79415	1950	breakin	61	Break In	25-08-2026 19:02:47	11713	0.85	normal	2026-08-28 14:28:39.659767	STF-003	Syed Kamran Ali	0.4892	recognized	2026-08-28 14:28:46.9922
77976	1918	breakout	62	Break Out	27-08-2026 11:06:45	95042	0.85	normal	2026-08-28 10:01:07.383077	STF-004	Tanveer Hassan	0.4945	recognized	2026-08-28 10:01:10.685984
77965	1918	breakout	59	Break Out	27-08-2026 11:05:14	92738	0.85	unrecognized	2026-08-28 10:00:39.354249	\N	Person #59	0	unrecognized	2026-08-28 10:00:52.591096
77000	1917	breakin	601	Break In	27-08-2026 20:50:53	261226	0.85	unrecognized	2026-08-28 08:41:20.024565	\N	Person #601	0	unrecognized	2026-08-28 08:41:37.93572
76536	1917	breakin	453	Break In	27-08-2026 20:08:55	198189	0.85	unrecognized	2026-08-28 08:12:15.184496	\N	Person #453	0	unrecognized	2026-08-28 08:12:48.038486
78932	1918	breakout	354	Break Out	27-08-2026 16:38:00	237002	0.85	unrecognized	2026-08-28 10:52:31.526554	\N	Person #354	0	unrecognized	2026-08-28 10:52:32.407301
77963	1918	breakout	58	Break Out	27-08-2026 11:04:55	92205	0.85	unrecognized	2026-08-28 10:00:28.54368	\N	Person #58	0	unrecognized	2026-08-28 10:00:38.540445
76537	1917	breakin	454	Break In	27-08-2026 20:08:00	198191	0.85	normal	2026-08-28 08:12:16.724505	STF-005	Muhammad Ayaz Hussain	0.5003	recognized	2026-08-28 08:12:16.783355
77969	1918	breakout	60	Break Out	27-08-2026 11:05:57	93844	0.85	unrecognized	2026-08-28 10:00:53.487986	\N	Person #60	0	unrecognized	2026-08-28 10:00:54.792596
76534	1917	breakin	444	Break In	27-08-2026 20:08:00	198110	0.85	normal	2026-08-28 08:12:07.861697	STF-048	Abdullah Sultan	0.4401	recognized	2026-08-28 08:12:19.130266
78317	1918	breakout	164	Break Out	27-08-2026 11:56:01	168907	0.85	unrecognized	2026-08-28 10:19:30.095509	\N	Person #164	0	unrecognized	2026-08-28 10:20:00.571285
78652	1918	breakout	256	Break Out	27-08-2026 12:46:35	244685	0.85	unrecognized	2026-08-28 10:39:08.030518	\N	Person #256	0	unrecognized	2026-08-28 10:39:20.4791
77401	1917	breakin	794	Break In	27-08-2026 21:39:51	334723	0.85	unrecognized	2026-08-28 09:06:27.585038	\N	Person #794	0	unrecognized	2026-08-28 09:06:35.542382
77111	1917	breakin	655	Break In	27-08-2026 20:59:25	274132	0.85	normal	2026-08-28 08:47:40.12458	STF-034	Muhammad Laeeq	0.4838	recognized	2026-08-28 08:47:40.751238
76533	1917	breakin	444	Break In	27-08-2026 20:08:35	197765	0.85	unrecognized	2026-08-28 08:12:05.925135	\N	Person #444	0	unrecognized	2026-08-28 08:12:07.338561
77357	1917	breakin	881	Break In	27-08-2026 16:18:00	210392	0.85	normal	2026-08-28 09:04:15.660008	STF-044	Zaheer Hussain	0.4592	recognized	2026-08-28 09:04:17.513002
78640	1918	breakout	252	Break Out	27-08-2026 12:46:03	243981	0.85	normal	2026-08-28 10:38:34.991478	STF-005	Muhammad Ayaz Hussain	0.5873	recognized	2026-08-28 10:38:39.047659
77116	1917	breakin	658	Break In	27-08-2026 21:00:20	275510	0.85	normal	2026-08-28 08:47:45.013032	STF-023	Syed Zubair Zulfiqar	0.549	recognized	2026-08-28 08:47:45.0275
78935	1918	breakout	356	Break Out	27-08-2026 16:39:28	238057	0.85	normal	2026-08-28 10:52:50.573384	STF-034	Muhammad Laeeq	0.4732	recognized	2026-08-28 10:53:00.651519
77125	1917	breakin	662	Break In	27-08-2026 21:01:27	277154	0.85	normal	2026-08-28 08:48:17.50031	STF-029	Abdul Rehman Sultan	0.4543	recognized	2026-08-28 08:48:19.713708
77425	1917	breakin	911	Break In	27-08-2026 16:30:43	228283	0.85	normal	2026-08-28 09:08:28.684086	STF-047	Arshad Irshad	0.4563	recognized	2026-08-28 09:08:29.284119
77405	1917	breakin	797	Break In	27-08-2026 21:41:58	337953	0.85	normal	2026-08-28 09:06:49.9912	STF-020	Syed Jahazaib Ahmad Alvi	0.4842	recognized	2026-08-28 09:06:51.927603
78944	1918	breakout	357	Break Out	27-08-2026 16:40:05	238989	0.85	unrecognized	2026-08-28 10:53:05.430957	\N	Person #357	0	unrecognized	2026-08-28 10:53:15.329716
77441	1917	breakin	919	Break In	27-08-2026 16:31:21	229186	0.85	normal	2026-08-28 09:09:18.518546	STF-047	Arshad Irshad	0.4561	recognized	2026-08-28 09:09:21.070942
77413	1917	breakin	800	Break In	27-08-2026 21:44:37	340990	0.85	unrecognized	2026-08-28 09:07:14.613978	\N	Person #800	0	unrecognized	2026-08-28 09:08:07.523131
77410	1917	breakin	798	Break In	27-08-2026 21:43:07	339621	0.85	normal	2026-08-28 09:07:02.174485	STF-028	Noman Imran	0.4916	recognized	2026-08-28 09:07:03.390018
77460	1917	breakin	937	Break In	27-08-2026 16:34:15	233122	0.85	unrecognized	2026-08-28 09:10:24.62441	\N	Person #937	0	unrecognized	2026-08-28 09:10:27.678385
77461	1917	breakin	938	Break In	27-08-2026 16:34:38	234055	0.85	unrecognized	2026-08-28 09:10:28.238737	\N	Person #938	0	unrecognized	2026-08-28 09:10:29.108027
77541	1917	breakin	1025	Break In	27-08-2026 16:54:29	263930	0.85	normal	2026-08-28 09:19:27.872478	STF-029	Abdul Rehman Sultan	0.5851	recognized	2026-08-28 09:19:27.885443
77370	1917	breakin	885	Break In	27-08-2026 16:20:34	212992	0.85	unrecognized	2026-08-28 09:04:34.137108	\N	Person #885	0	unrecognized	2026-08-28 09:04:43.231039
78646	1918	breakout	301	Break Out	27-08-2026 20:31:55	229897	0.85	pending	2026-08-28 10:38:50.111054	\N	Person #301	0	unrecognized	\N
77012	1917	breakin	700	Break In	27-08-2026 15:53:03	171753	0.85	normal	2026-08-28 08:42:05.179814	STF-029	Abdul Rehman Sultan	0.4533	recognized	2026-08-28 08:42:07.00383
77002	1917	breakin	693	Break In	27-08-2026 15:51:32	169467	0.85	normal	2026-08-28 08:41:33.597065	STF-013	Muhammad Faizan	0.5595	recognized	2026-08-28 08:41:34.576725
77980	1918	breakout	79	Break Out	27-08-2026 18:36:31	56687	0.85	unrecognized	2026-08-28 10:01:20.232763	\N	Person #79	0	unrecognized	2026-08-28 10:01:22.741338
77974	1918	breakout	77	Break Out	27-08-2026 18:35:52	55751	0.85	normal	2026-08-28 10:00:59.98405	STF-030	Dildar Ahmed	0.4435	recognized	2026-08-28 10:01:02.921214
77964	1918	breakout	72	Break Out	27-08-2026 18:34:50	54125	0.85	unrecognized	2026-08-28 10:00:31.042952	\N	Person #72	0	unrecognized	2026-08-28 10:00:45.288149
77366	1917	breakin	884	Break In	27-08-2026 16:19:50	211859	0.85	normal	2026-08-28 09:04:31.047055	STF-028	Noman Imran	0.4712	recognized	2026-08-28 09:04:31.74052
77982	1918	breakout	80	Break Out	27-08-2026 18:38:37	59949	0.85	pending	2026-08-28 10:01:24.793172	\N	Person #80	0	unrecognized	\N
76529	1917	breakin	453	Break In	27-08-2026 14:58:11	89372	0.85	unrecognized	2026-08-28 08:11:42.366584	\N	Person #453	0	unrecognized	2026-08-28 08:11:49.299404
76531	1917	breakin	455	Break In	27-08-2026 14:58:27	89790	0.85	unrecognized	2026-08-28 08:11:50.905747	\N	Person #455	0	unrecognized	2026-08-28 08:12:29.411304
77007	1917	breakin	697	Break In	27-08-2026 15:52:17	170626	0.85	normal	2026-08-28 08:41:54.521157	STF-013	Muhammad Faizan	0.647	recognized	2026-08-28 08:41:54.541103
78655	1918	breakout	305	Break Out	27-08-2026 20:32:26	230614	0.85	normal	2026-08-28 10:39:19.567362	STF-010	Faraz Younas	0.4448	recognized	2026-08-28 10:39:23.361114
78641	1918	breakout	300	Break Out	27-08-2026 20:31:20	228906	0.85	unrecognized	2026-08-28 10:38:36.829535	\N	Person #300	0	unrecognized	2026-08-28 10:38:49.230305
77215	1917	breakin	809	Break In	27-08-2026 16:08:47	195377	0.85	normal	2026-08-28 08:54:12.969737	STF-005	Muhammad Ayaz Hussain	0.5245	recognized	2026-08-28 08:54:12.988682
77277	1917	breakin	744	Break In	27-08-2026 21:17:59	301873	0.85	unrecognized	2026-08-28 08:59:38.510995	\N	Person #744	0	unrecognized	2026-08-28 08:59:55.784771
77360	1917	breakin	878	Break In	27-08-2026 16:19:02	210654	0.85	unrecognized	2026-08-28 09:04:27.320103	\N	Person #878	0	unrecognized	2026-08-28 09:04:28.669614
78945	1918	breakout	394	Break Out	27-08-2026 20:59:07	270577	0.85	unrecognized	2026-08-28 10:53:06.89145	\N	Person #394	0	unrecognized	2026-08-28 10:53:28.30234
77365	1917	breakin	883	Break In	27-08-2026 16:19:38	211661	0.85	normal	2026-08-28 09:04:30.070052	STF-044	Zaheer Hussain	0.611	recognized	2026-08-28 09:04:30.110947
77282	1917	breakin	748	Break In	27-08-2026 21:18:32	302787	0.85	normal	2026-08-28 09:00:13.862422	STF-029	Abdul Rehman Sultan	0.4746	recognized	2026-08-28 09:00:17.457643
77372	1917	breakin	884	Break In	27-08-2026 16:20:40	213215	0.85	unrecognized	2026-08-28 09:04:43.594273	\N	Person #884	0	unrecognized	2026-08-28 09:04:43.611227
77376	1917	breakin	886	Break In	27-08-2026 16:22:54	216534	0.85	normal	2026-08-28 09:04:46.415166	STF-033	Raza Abbas	0.5374	recognized	2026-08-28 09:04:48.007672
77381	1917	breakin	887	Break In	27-08-2026 16:23:00	217711	0.85	normal	2026-08-28 09:04:50.267506	STF-007	Faisal Saleem	0.4504	recognized	2026-08-28 09:04:52.174751
77374	1917	breakin	884	Break In	27-08-2026 16:20:49	213408	0.85	unrecognized	2026-08-28 09:04:44.049172	\N	Person #884	0	unrecognized	2026-08-28 09:04:44.553048
77375	1917	breakin	884	Break In	27-08-2026 16:20:55	213588	0.85	pending	2026-08-28 09:04:45.125302	\N	Person #884	\N	pending	\N
77382	1917	breakin	887	Break In	27-08-2026 16:23:53	218043	0.85	normal	2026-08-28 09:04:56.438194	STF-033	Raza Abbas	0.4531	recognized	2026-08-28 09:04:56.731609
77384	1917	breakin	888	Break In	27-08-2026 16:23:59	218184	0.85	normal	2026-08-28 09:04:58.696116	STF-007	Faisal Saleem	0.627	recognized	2026-08-28 09:04:58.714071
76544	1917	breakin	458	Break In	27-08-2026 20:10:08	200173	0.85	normal	2026-08-28 08:13:04.464744	STF-050	Hafeez-Ur-Rehman	0.4527	recognized	2026-08-28 08:13:08.685224
76565	1917	breakin	473	Break In	27-08-2026 20:13:06	204550	0.85	unrecognized	2026-08-28 08:14:36.293443	\N	Person #473	0	unrecognized	2026-08-28 08:14:37.471193
76546	1917	breakin	460	Break In	27-08-2026 20:10:59	201486	0.85	unrecognized	2026-08-28 08:13:14.618346	\N	Person #460	0	unrecognized	2026-08-28 08:13:15.411111
76539	1916	attendance	690	Person Entered	27-08-2026 21:33:13	1037289	0.85	unrecognized	2026-08-28 08:12:31.255489	\N	Person #690	0	unrecognized	2026-08-28 08:12:52.558187
76502	1917	breakin	507	Break In	27-08-2026 13:43:22	332788	0.85	unrecognized	2026-08-28 08:08:24.197658	\N	Person #507	0	unrecognized	2026-08-28 08:17:47.94361
76545	1917	breakin	520	Break In	27-08-2026 13:42:47	333550	0.85	normal	2026-08-28 08:13:12.074094	STF-029	Abdul Rehman Sultan	0.487	recognized	2026-08-28 08:13:16.096327
76540	1916	attendance	691	Person Entered	27-08-2026 21:33:13	1037310	0.85	unrecognized	2026-08-28 08:12:38.022023	\N	Person #691	0	unrecognized	2026-08-28 08:13:16.060422
78321	1918	breakout	181	Break Out	27-08-2026 15:04:38	95931	0.85	normal	2026-08-28 10:19:46.508245	STF-010	Faraz Younas	0.5085	recognized	2026-08-28 10:19:49.696136
76542	1917	breakin	457	Break In	27-08-2026 20:09:42	199558	0.85	normal	2026-08-28 08:12:57.975197	STF-006	Muhammad Abubakar	0.4595	recognized	2026-08-28 08:12:59.204943
76532	1917	breakin	518	Break In	27-08-2026 13:42:41	333384	0.85	normal	2026-08-28 08:11:59.379353	STF-009	Tariq Ghulam Hussain	0.4693	recognized	2026-08-28 08:12:13.021626
76530	1916	attendance	688	Person Entered	27-08-2026 21:31:04	1036466	0.85	unrecognized	2026-08-28 08:11:50.008739	\N	Person #688	0	unrecognized	2026-08-28 08:12:28.213642
78649	1918	breakout	276	Break Out	27-08-2026 16:04:56	186300	0.85	unrecognized	2026-08-28 10:38:57.466329	\N	Person #276	0	unrecognized	2026-08-28 10:39:01.978309
76561	1917	breakin	459	Break In	27-08-2026 14:59:32	91495	0.85	normal	2026-08-28 08:14:17.525405	STF-010	Faraz Younas	0.5377	recognized	2026-08-28 08:14:21.432217
77966	1918	breakout	80	Break Out	27-08-2026 14:21:29	31110	0.85	unrecognized	2026-08-28 10:00:44.721961	\N	Person #80	0	unrecognized	2026-08-28 10:00:56.397728
76913	1917	breakin	555	Break In	27-08-2026 20:39:08	243678	0.85	normal	2026-08-28 08:35:24.796617	STF-025	Farhan Virk	0.4462	recognized	2026-08-28 08:35:35.120269
76547	1917	breakin	461	Break In	27-08-2026 20:11:25	202045	0.85	unrecognized	2026-08-28 08:13:16.918868	\N	Person #461	0	unrecognized	2026-08-28 08:13:41.388678
77971	1918	breakout	80	Break Out	27-08-2026 14:21:47	31650	0.85	unrecognized	2026-08-28 10:00:56.815172	\N	Person #80	0	unrecognized	2026-08-28 10:00:57.133213
77972	1918	breakout	80	Break Out	27-08-2026 14:21:55	31807	0.85	unrecognized	2026-08-28 10:00:57.516134	\N	Person #80	0	unrecognized	2026-08-28 10:01:09.854919
76562	1917	breakin	463	Break In	27-08-2026 14:59:34	91550	0.85	normal	2026-08-28 08:14:22.678841	STF-004	Tanveer Hassan	0.4623	recognized	2026-08-28 08:14:23.693931
77981	1918	breakout	83	Break Out	27-08-2026 14:23:34	34224	0.85	unrecognized	2026-08-28 10:01:24.543839	\N	Person #83	0	unrecognized	2026-08-28 10:01:36.208456
76541	1917	breakin	453	Break In	27-08-2026 20:09:06	198505	0.85	unrecognized	2026-08-28 08:12:48.487829	\N	Person #453	0	unrecognized	2026-08-28 08:12:55.716224
76548	1916	attendance	692	Person Entered	27-08-2026 21:33:21	1038410	0.85	unrecognized	2026-08-28 08:13:18.799296	\N	Person #692	0	unrecognized	2026-08-28 08:13:37.555522
77977	1918	breakout	81	Break Out	27-08-2026 14:22:01	31954	0.85	unrecognized	2026-08-28 10:01:10.606197	\N	Person #81	0	unrecognized	2026-08-28 10:01:22.355968
76555	1916	attendance	694	Person Entered	27-08-2026 21:39:57	1049887	0.85	unrecognized	2026-08-28 08:13:54.781106	\N	Person #694	0	unrecognized	2026-08-28 08:14:01.358079
78644	1918	breakout	275	Break Out	27-08-2026 16:03:53	184808	0.85	normal	2026-08-28 10:38:43.604127	STF-029	Abdul Rehman Sultan	0.5059	recognized	2026-08-28 10:38:46.031605
76563	1917	breakin	464	Break In	27-08-2026 14:59:00	91681	0.85	unrecognized	2026-08-28 08:14:28.262996	\N	Person #464	0	unrecognized	2026-08-28 08:14:33.691432
78650	1918	breakout	280	Break Out	27-08-2026 16:05:36	187273	0.85	unrecognized	2026-08-28 10:39:03.162266	\N	Person #280	0	unrecognized	2026-08-28 10:39:16.43135
78329	1918	breakout	183	Break Out	27-08-2026 15:06:32	98754	0.85	normal	2026-08-28 10:20:24.364107	STF-015	Liaqat Ali	0.4739	recognized	2026-08-28 10:20:27.657455
76553	1917	breakin	468	Break In	27-08-2026 20:12:30	203736	0.85	normal	2026-08-28 08:13:51.793323	STF-010	Faraz Younas	0.4565	recognized	2026-08-28 08:13:55.168257
76556	1916	attendance	695	Person Entered	27-08-2026 21:40:00	1050198	0.85	unrecognized	2026-08-28 08:14:03.621308	\N	Person #695	0	unrecognized	2026-08-28 08:14:12.476596
78657	1918	breakout	281	Break Out	27-08-2026 16:05:51	187602	0.85	unrecognized	2026-08-28 10:39:22.109384	\N	Person #281	0	unrecognized	2026-08-28 10:39:48.099775
78654	1918	breakout	280	Break Out	27-08-2026 16:05:45	187526	0.85	unrecognized	2026-08-28 10:39:16.743173	\N	Person #280	0	unrecognized	2026-08-28 10:39:38.485508
78940	1918	breakout	338	Break Out	27-08-2026 13:25:40	303427	0.85	unrecognized	2026-08-28 10:52:57.288752	\N	Person #338	0	unrecognized	2026-08-28 10:53:20.545348
76569	1917	breakin	475	Break In	27-08-2026 20:13:39	205420	0.85	unrecognized	2026-08-28 08:14:42.891493	\N	Person #475	0	unrecognized	2026-08-28 08:15:01.690801
76570	1917	breakin	469	Break In	27-08-2026 15:00:23	92759	0.85	unrecognized	2026-08-28 08:14:48.60901	\N	Person #469	0	unrecognized	2026-08-28 08:14:52.634789
78948	1918	breakout	339	Break Out	27-08-2026 13:25:50	303630	0.85	unrecognized	2026-08-28 10:53:21.129295	\N	Person #339	0	unrecognized	2026-08-28 10:53:25.353299
76572	1917	breakin	472	Break In	27-08-2026 15:01:06	93860	0.85	normal	2026-08-28 08:15:03.397383	STF-008	Muhammad Shoaib	0.4606	recognized	2026-08-28 08:15:03.726939
77303	1917	breakin	855	Break In	27-08-2026 16:13:37	202429	0.85	normal	2026-08-28 09:01:21.41707	STF-030	Dildar Ahmed	0.4716	recognized	2026-08-28 09:01:56.930149
77991	1918	breakout	67	Break Out	27-08-2026 11:07:23	95955	0.85	unrecognized	2026-08-28 10:01:48.360087	\N	Person #67	0	unrecognized	2026-08-28 10:02:09.86737
77014	1917	breakin	606	Break In	27-08-2026 20:52:12	263302	0.85	normal	2026-08-28 08:42:07.525734	STF-024	Arsalan Khan	0.5462	recognized	2026-08-28 08:42:08.483826
77997	1918	breakout	68	Break Out	27-08-2026 11:07:36	96286	0.85	unrecognized	2026-08-28 10:02:10.381497	\N	Person #68	0	unrecognized	2026-08-28 10:02:25.301846
76925	1917	breakin	663	Break In	27-08-2026 15:30:40	138216	0.85	normal	2026-08-28 08:36:10.371974	STF-045	Zohaib Ali Chaudhary	0.6857	recognized	2026-08-28 08:36:10.387931
78002	1918	breakout	69	Break Out	27-08-2026 11:07:55	96853	0.85	unrecognized	2026-08-28 10:02:26.018494	\N	Person #69	0	unrecognized	2026-08-28 10:02:26.049411
76576	1917	breakin	475	Break In	27-08-2026 15:01:13	93983	0.85	normal	2026-08-28 08:15:16.726815	STF-035	Hammad Shaukat	0.4486	recognized	2026-08-28 08:15:21.376075
78659	1918	breakout	258	Break Out	27-08-2026 12:47:09	245651	0.85	normal	2026-08-28 10:39:35.735171	STF-046	Usman Babar	0.5467	recognized	2026-08-28 10:39:37.970541
77221	1917	breakin	814	Break In	27-08-2026 16:09:01	195723	0.85	normal	2026-08-28 08:54:42.542723	STF-030	Dildar Ahmed	0.5148	recognized	2026-08-28 08:54:43.064375
77129	1917	breakin	761	Break In	27-08-2026 16:02:00	185470	0.85	normal	2026-08-28 08:48:23.1411	STF-037	Muhammad Fahad	0.5574	recognized	2026-08-28 08:48:45.811479
76917	1917	breakin	661	Break In	27-08-2026 15:30:37	138135	0.85	normal	2026-08-28 08:35:47.177341	STF-044	Zaheer Hussain	0.4412	recognized	2026-08-28 08:35:50.103567
77008	1917	breakin	603	Break In	27-08-2026 20:51:38	262456	0.85	normal	2026-08-28 08:42:02.403623	STF-023	Syed Zubair Zulfiqar	0.5711	recognized	2026-08-28 08:42:02.419581
78678	1918	breakout	261	Break Out	27-08-2026 12:48:31	247716	0.85	normal	2026-08-28 10:39:54.098913	STF-024	Arsalan Khan	0.4806	recognized	2026-08-28 10:40:01.0782
77285	1917	breakin	849	Break In	27-08-2026 16:12:53	201529	0.85	normal	2026-08-28 09:00:30.701243	STF-052	Syed Imran Shah	0.6548	recognized	2026-08-28 09:00:30.740133
77298	1917	breakin	853	Break In	27-08-2026 16:13:21	202149	0.85	normal	2026-08-28 09:01:03.094894	STF-037	Muhammad Fahad	0.4436	recognized	2026-08-28 09:01:09.145873
77380	1917	breakin	787	Break In	27-08-2026 21:31:35	322350	0.85	unrecognized	2026-08-28 09:04:50.157755	\N	Person #787	0	unrecognized	2026-08-28 09:04:56.247009
77383	1917	breakin	790	Break In	27-08-2026 21:32:09	322948	0.85	unrecognized	2026-08-28 09:04:57.774879	\N	Person #790	0	unrecognized	2026-08-28 09:05:43.178329
76598	1917	breakin	483	Break In	27-08-2026 20:14:13	206297	0.85	normal	2026-08-28 08:17:29.678016	STF-050	Hafeez-Ur-Rehman	0.4942	recognized	2026-08-28 08:17:42.713101
78000	1918	breakout	87	Break Out	27-08-2026 18:41:55	64781	0.85	unrecognized	2026-08-28 10:02:20.65849	\N	Person #87	0	unrecognized	2026-08-28 10:02:35.42085
78334	1918	breakout	185	Break Out	27-08-2026 15:07:36	100311	0.85	unrecognized	2026-08-28 10:20:45.116297	\N	Person #185	0	unrecognized	2026-08-28 10:20:59.35197
76590	1917	breakin	494	Break In	27-08-2026 15:02:00	96361	0.85	normal	2026-08-28 08:16:08.750444	STF-004	Tanveer Hassan	0.5216	recognized	2026-08-28 08:16:18.269357
78689	1918	breakout	311	Break Out	27-08-2026 20:35:18	234813	0.85	unrecognized	2026-08-28 10:40:29.287326	\N	Person #311	0	unrecognized	2026-08-28 10:41:00.850936
77984	1918	breakout	81	Break Out	27-08-2026 18:39:24	60960	0.85	unrecognized	2026-08-28 10:01:29.324328	\N	Person #81	0	unrecognized	2026-08-28 10:01:32.074121
76582	1917	breakin	482	Break In	27-08-2026 15:02:05	95280	0.85	normal	2026-08-28 08:15:46.705999	STF-026	Syed Zeeshan Ali	0.4603	recognized	2026-08-28 08:15:48.896725
77985	1918	breakout	82	Break Out	27-08-2026 18:39:32	61301	0.85	pending	2026-08-28 10:01:32.587849	\N	Person #82	0	unrecognized	\N
78660	1918	breakout	307	Break Out	27-08-2026 20:34:24	233575	0.85	normal	2026-08-28 10:39:36.489135	STF-007	Faisal Saleem	0.4481	recognized	2026-08-28 10:39:39.214817
78332	1918	breakout	184	Break Out	27-08-2026 15:07:21	99925	0.85	unrecognized	2026-08-28 10:20:31.031215	\N	Person #184	0	unrecognized	2026-08-28 10:20:44.576615
76926	1917	breakin	558	Break In	27-08-2026 20:39:53	244804	0.85	unrecognized	2026-08-28 08:36:10.724612	\N	Person #558	0	unrecognized	2026-08-28 08:36:12.675545
77998	1918	breakout	87	Break Out	27-08-2026 18:41:19	63877	0.85	unrecognized	2026-08-28 10:02:17.385779	\N	Person #87	0	unrecognized	2026-08-28 10:02:20.154337
76584	1917	breakin	486	Break In	27-08-2026 15:02:07	95379	0.85	normal	2026-08-28 08:15:50.160009	STF-035	Hammad Shaukat	0.7243	recognized	2026-08-28 08:15:50.21239
77994	1918	breakout	84	Break Out	27-08-2026 18:40:45	63060	0.85	normal	2026-08-28 10:01:55.996606	STF-033	Raza Abbas	0.4488	recognized	2026-08-28 10:02:01.172453
76581	1917	breakin	478	Break In	27-08-2026 15:01:00	94934	0.85	normal	2026-08-28 08:15:41.733407	STF-010	Faraz Younas	0.5025	recognized	2026-08-28 08:15:41.769295
78340	1918	breakout	186	Break Out	27-08-2026 15:08:08	101184	0.85	unrecognized	2026-08-28 10:21:14.246975	\N	Person #186	0	unrecognized	2026-08-28 10:21:24.231889
77987	1918	breakout	83	Break Out	27-08-2026 18:39:53	61766	0.85	unrecognized	2026-08-28 10:01:37.818659	\N	Person #83	0	unrecognized	2026-08-28 10:01:47.249943
78341	1918	breakout	187	Break Out	27-08-2026 15:08:14	101195	0.85	unrecognized	2026-08-28 10:21:16.843464	\N	Person #187	0	unrecognized	2026-08-28 10:21:36.319843
76599	1917	breakin	502	Break In	27-08-2026 15:03:45	97788	0.85	normal	2026-08-28 08:17:33.127473	STF-008	Muhammad Shoaib	0.4674	recognized	2026-08-28 08:17:43.533113
76606	1917	breakin	529	Break In	27-08-2026 13:43:35	334929	0.85	unrecognized	2026-08-28 08:18:10.820001	\N	Person #529	0	unrecognized	2026-08-28 08:18:20.553185
79229	1918	breakout	445	Break Out	27-08-2026 17:25:31	307201	0.85	unrecognized	2026-08-28 11:08:43.584995	\N	Person #445	0	unrecognized	2026-08-28 11:08:49.488423
78951	1918	breakout	341	Break Out	27-08-2026 13:28:24	307519	0.85	unrecognized	2026-08-28 10:53:29.645459	\N	Person #341	0	unrecognized	2026-08-28 10:53:36.067253
78335	1918	breakout	185	Break Out	27-08-2026 15:08:02	100974	0.85	unrecognized	2026-08-28 10:20:59.835956	\N	Person #185	0	unrecognized	2026-08-28 10:21:13.355971
78949	1918	breakout	340	Break Out	27-08-2026 13:27:31	306194	0.85	normal	2026-08-28 10:53:26.699749	STF-001	Ikram Hassan	0.4511	recognized	2026-08-28 10:53:28.155732
76597	1917	breakin	500	Break In	27-08-2026 15:03:33	97530	0.85	normal	2026-08-28 08:17:28.839939	STF-035	Hammad Shaukat	0.5351	recognized	2026-08-28 08:17:28.864872
79102	1918	breakout	451	Break Out	27-08-2026 21:15:12	294773	0.85	normal	2026-08-28 11:02:08.452119	STF-029	Abdul Rehman Sultan	0.4457	recognized	2026-08-28 11:02:26.246311
79233	1918	breakout	449	Break Out	27-08-2026 17:28:05	311086	0.85	normal	2026-08-28 11:09:25.162011	STF-017	Mohammad Zahid	0.4815	recognized	2026-08-28 11:09:25.991284
79231	1918	breakout	447	Break Out	27-08-2026 17:27:18	309856	0.85	unrecognized	2026-08-28 11:09:03.872577	\N	Person #447	0	unrecognized	2026-08-28 11:09:14.005895
79230	1918	breakout	446	Break Out	27-08-2026 17:27:01	309453	0.85	unrecognized	2026-08-28 11:08:50.756837	\N	Person #446	0	unrecognized	2026-08-28 11:09:03.253728
79235	1918	breakout	450	Break Out	27-08-2026 17:30:08	314046	0.85	unrecognized	2026-08-28 11:09:28.836734	\N	Person #450	0	unrecognized	2026-08-28 11:09:38.853579
79234	1918	breakout	449	Break Out	27-08-2026 17:30:01	314040	0.85	pending	2026-08-28 11:09:28.667611	\N	Person #449	\N	pending	\N
76614	1917	breakin	510	Break In	27-08-2026 15:04:06	98335	0.85	normal	2026-08-28 08:18:40.423584	STF-035	Hammad Shaukat	0.5083	recognized	2026-08-28 08:18:55.826194
76616	1917	breakin	530	Break In	27-08-2026 13:44:07	335570	0.85	normal	2026-08-28 08:18:52.983528	STF-005	Muhammad Ayaz Hussain	0.5509	recognized	2026-08-28 08:18:55.052166
77027	1917	breakin	612	Break In	27-08-2026 20:53:31	265267	0.85	unrecognized	2026-08-28 08:42:57.039138	\N	Person #612	0	unrecognized	2026-08-28 08:42:57.469457
77993	1918	breakout	86	Break Out	27-08-2026 14:24:41	35913	0.85	unrecognized	2026-08-28 10:01:55.619795	\N	Person #86	0	unrecognized	2026-08-28 10:02:19.364663
77133	1917	breakin	665	Break In	27-08-2026 21:02:08	278214	0.85	normal	2026-08-28 08:48:31.024509	STF-029	Abdul Rehman Sultan	0.6063	recognized	2026-08-28 08:48:31.041466
77999	1918	breakout	88	Break Out	27-08-2026 14:25:05	36620	0.85	unrecognized	2026-08-28 10:02:20.416686	\N	Person #88	0	unrecognized	2026-08-28 10:02:20.695391
76916	1917	breakin	632	Break In	27-08-2026 13:58:14	356556	0.85	normal	2026-08-28 08:35:42.985821	STF-033	Raza Abbas	0.5127	recognized	2026-08-28 08:35:45.931709
78683	1918	breakout	282	Break Out	27-08-2026 16:06:30	188643	0.85	unrecognized	2026-08-28 10:40:06.341576	\N	Person #282	0	unrecognized	2026-08-28 10:40:07.672325
76620	1917	breakin	488	Break In	27-08-2026 20:14:53	207215	0.85	unrecognized	2026-08-28 08:19:13.463865	\N	Person #488	0	unrecognized	2026-08-28 08:19:18.741032
77020	1917	breakin	608	Break In	27-08-2026 20:52:38	263951	0.85	normal	2026-08-28 08:42:29.724131	STF-023	Syed Zubair Zulfiqar	0.4743	recognized	2026-08-28 08:42:33.752703
79109	1918	breakout	413	Break Out	27-08-2026 17:04:11	275188	0.85	normal	2026-08-28 11:02:30.158765	STF-031	Muhammad Hassan	0.4834	recognized	2026-08-28 11:02:35.183958
78339	1918	breakout	203	Break Out	27-08-2026 19:30:10	137026	0.85	normal	2026-08-28 10:21:13.301117	STF-013	Muhammad Faizan	0.5476	recognized	2026-08-28 10:21:26.800858
78001	1918	breakout	89	Break Out	27-08-2026 14:25:12	36676	0.85	unrecognized	2026-08-28 10:02:21.344577	\N	Person #89	0	unrecognized	2026-08-28 10:02:28.923408
77986	1918	breakout	84	Break Out	27-08-2026 14:24:02	34987	0.85	unrecognized	2026-08-28 10:01:36.816602	\N	Person #84	0	unrecognized	2026-08-28 10:01:47.89621
78950	1918	breakout	395	Break Out	27-08-2026 20:59:38	271378	0.85	unrecognized	2026-08-28 10:53:28.986145	\N	Person #395	0	unrecognized	2026-08-28 10:53:36.005418
77232	1917	breakin	723	Break In	27-08-2026 21:15:26	298124	0.85	normal	2026-08-28 08:55:06.645899	STF-029	Abdul Rehman Sultan	0.4989	recognized	2026-08-28 08:55:11.47012
77230	1917	breakin	722	Break In	27-08-2026 21:15:16	297913	0.85	normal	2026-08-28 08:55:04.356962	STF-028	Noman Imran	0.4633	recognized	2026-08-28 08:55:04.567436
77226	1917	breakin	716	Break In	27-08-2026 21:14:12	296278	0.85	normal	2026-08-28 08:54:56.086478	STF-048	Abdullah Sultan	0.4659	recognized	2026-08-28 08:54:58.458872
79107	1918	breakout	412	Break Out	27-08-2026 17:03:49	274679	0.85	normal	2026-08-28 11:02:25.746725	STF-017	Mohammad Zahid	0.4642	recognized	2026-08-28 11:02:28.116543
78677	1918	breakout	282	Break Out	27-08-2026 16:06:00	187861	0.85	unrecognized	2026-08-28 10:39:48.841066	\N	Person #282	0	unrecognized	2026-08-28 10:40:05.855157
77220	1917	breakin	712	Break In	27-08-2026 21:13:06	294590	0.85	unrecognized	2026-08-28 08:54:36.924472	\N	Person #712	0	unrecognized	2026-08-28 08:54:51.254726
79237	1918	breakout	488	Break Out	27-08-2026 21:29:27	316110	0.85	unrecognized	2026-08-28 11:09:35.45653	\N	Person #488	0	unrecognized	2026-08-28 11:09:46.330215
79240	1918	breakout	489	Break Out	27-08-2026 21:29:36	316408	0.85	pending	2026-08-28 11:09:46.67443	\N	Person #489	\N	pending	\N
79241	1918	breakout	489	Break Out	27-08-2026 21:30:08	317208	0.85	pending	2026-08-28 11:09:46.976963	\N	Person #489	\N	pending	\N
77128	1917	breakin	663	Break In	27-08-2026 21:01:35	277390	0.85	normal	2026-08-28 08:48:22.977483	STF-037	Muhammad Fahad	0.4878	recognized	2026-08-28 08:48:23.139105
79236	1918	breakout	487	Break Out	27-08-2026 21:29:13	315802	0.85	unrecognized	2026-08-28 11:09:34.316787	\N	Person #487	0	unrecognized	2026-08-28 11:09:34.963778
79248	1918	breakout	494	Break Out	27-08-2026 21:32:14	320260	0.85	unrecognized	2026-08-28 11:10:04.907575	\N	Person #494	0	unrecognized	2026-08-28 11:10:09.983952
77134	1917	breakin	666	Break In	27-08-2026 21:02:34	278830	0.85	normal	2026-08-28 08:48:33.113831	STF-004	Tanveer Hassan	0.4757	recognized	2026-08-28 08:48:36.967533
77130	1917	breakin	664	Break In	27-08-2026 21:01:00	277602	0.85	normal	2026-08-28 08:48:25.475426	STF-013	Muhammad Faizan	0.4702	recognized	2026-08-28 08:48:26.039239
79247	1918	breakout	492	Break Out	27-08-2026 21:30:57	318302	0.85	normal	2026-08-28 11:09:58.10974	STF-037	Muhammad Fahad	0.4828	recognized	2026-08-28 11:10:01.903448
77235	1917	breakin	728	Break In	27-08-2026 21:15:44	298597	0.85	normal	2026-08-28 08:55:20.721224	STF-047	Arshad Irshad	0.6548	recognized	2026-08-28 08:55:20.74216
77287	1917	breakin	750	Break In	27-08-2026 21:19:27	304141	0.85	normal	2026-08-28 09:00:33.304044	STF-045	Zohaib Ali Chaudhary	0.4826	recognized	2026-08-28 09:00:36.126414
77289	1917	breakin	752	Break In	27-08-2026 21:19:29	304232	0.85	normal	2026-08-28 09:00:38.087598	STF-047	Arshad Irshad	0.4851	recognized	2026-08-28 09:00:38.675887
77297	1917	breakin	756	Break In	27-08-2026 21:20:27	305692	0.85	normal	2026-08-28 09:01:02.26788	STF-048	Abdullah Sultan	0.6405	recognized	2026-08-28 09:01:02.299808
77294	1917	breakin	755	Break In	27-08-2026 21:20:24	305593	0.85	normal	2026-08-28 09:00:53.129321	STF-047	Arshad Irshad	0.5473	recognized	2026-08-28 09:00:54.929069
78004	1918	breakout	89	Break Out	27-08-2026 14:25:19	36985	0.85	pending	2026-08-28 10:02:29.294613	\N	Person #89	\N	pending	\N
77152	1917	breakin	676	Break In	27-08-2026 21:03:47	280687	0.85	unrecognized	2026-08-28 08:49:48.29637	\N	Person #676	0	unrecognized	2026-08-28 08:49:48.325534
79114	1918	breakout	403	Break Out	27-08-2026 13:48:45	337858	0.85	unrecognized	2026-08-28 11:02:37.155452	\N	Person #403	0	unrecognized	2026-08-28 11:02:45.262359
78959	1918	breakout	344	Break Out	27-08-2026 13:29:22	308989	0.85	unrecognized	2026-08-28 10:53:51.340891	\N	Person #344	0	unrecognized	2026-08-28 10:53:52.326244
77153	1917	breakin	676	Break In	27-08-2026 21:03:58	280932	0.85	unrecognized	2026-08-28 08:49:48.572931	\N	Person #676	0	unrecognized	2026-08-28 08:49:49.194493
77031	1917	breakin	707	Break In	27-08-2026 15:54:20	173697	0.85	normal	2026-08-28 08:43:14.065005	STF-037	Muhammad Fahad	0.4609	recognized	2026-08-28 08:43:16.042356
78952	1918	breakout	342	Break Out	27-08-2026 13:28:37	307800	0.85	unrecognized	2026-08-28 10:53:36.793223	\N	Person #342	0	unrecognized	2026-08-28 10:53:44.423897
77147	1917	breakin	677	Break In	27-08-2026 21:03:05	279616	0.85	normal	2026-08-28 08:49:25.465918	STF-029	Abdul Rehman Sultan	0.4961	recognized	2026-08-28 08:49:27.298152
78353	1918	breakout	207	Break Out	27-08-2026 19:33:07	141594	0.85	unrecognized	2026-08-28 10:22:02.953392	\N	Person #207	0	unrecognized	2026-08-28 10:22:04.385283
77154	1917	breakin	679	Break In	27-08-2026 21:04:11	281009	0.85	unrecognized	2026-08-28 08:49:49.769408	\N	Person #679	0	unrecognized	2026-08-28 08:50:06.324595
78681	1918	breakout	262	Break Out	27-08-2026 12:48:00	247778	0.85	normal	2026-08-28 10:40:01.647829	STF-023	Syed Zubair Zulfiqar	0.5126	recognized	2026-08-28 10:40:18.117849
78967	1918	breakout	348	Break Out	27-08-2026 13:32:01	312883	0.85	unrecognized	2026-08-28 10:54:09.29876	\N	Person #348	0	unrecognized	2026-08-28 10:54:21.411892
78005	1918	breakout	91	Break Out	27-08-2026 14:25:47	37581	0.85	unrecognized	2026-08-28 10:02:30.018035	\N	Person #91	0	unrecognized	2026-08-28 10:02:40.597443
77415	1917	breakin	907	Break In	27-08-2026 16:29:29	226041	0.85	unrecognized	2026-08-28 09:07:18.306116	\N	Person #907	0	unrecognized	2026-08-28 09:07:28.455865
78008	1918	breakout	92	Break Out	27-08-2026 14:25:55	37889	0.85	pending	2026-08-28 10:02:41.246756	\N	Person #92	0	unrecognized	\N
78012	1918	breakout	94	Break Out	27-08-2026 14:26:35	38751	0.85	unrecognized	2026-08-28 10:03:00.020407	\N	Person #94	0	unrecognized	2026-08-28 10:03:22.43516
77242	1917	breakin	731	Break In	27-08-2026 21:16:12	299309	0.85	normal	2026-08-28 08:55:38.261012	STF-045	Zohaib Ali Chaudhary	0.4971	recognized	2026-08-28 08:55:38.279958
77157	1917	breakin	680	Break In	27-08-2026 21:04:51	282281	0.85	normal	2026-08-28 08:50:07.183452	STF-013	Muhammad Faizan	0.4994	recognized	2026-08-28 08:50:08.607734
76927	1917	breakin	559	Break In	27-08-2026 20:40:00	244835	0.85	unrecognized	2026-08-28 08:36:12.36337	\N	Person #559	0	unrecognized	2026-08-28 08:36:26.892569
78350	1918	breakout	206	Break Out	27-08-2026 19:31:19	138986	0.85	normal	2026-08-28 10:21:55.351967	STF-040	Arslan Nadeem	0.4542	recognized	2026-08-28 10:21:57.332107
77021	1917	breakin	704	Break In	27-08-2026 15:53:42	172751	0.85	normal	2026-08-28 08:42:34.734132	STF-013	Muhammad Faizan	0.4707	recognized	2026-08-28 08:42:35.129179
78355	1918	breakout	208	Break Out	27-08-2026 19:33:44	142567	0.85	normal	2026-08-28 10:22:05.078484	STF-044	Zaheer Hussain	0.4503	recognized	2026-08-28 10:22:06.222214
78019	1918	breakout	95	Break Out	27-08-2026 14:27:36	40332	0.85	unrecognized	2026-08-28 10:03:23.346209	\N	Person #95	0	unrecognized	2026-08-28 10:03:36.908367
78359	1918	breakout	209	Break Out	27-08-2026 19:35:54	145741	0.85	unrecognized	2026-08-28 10:22:19.1119	\N	Person #209	0	unrecognized	2026-08-28 10:22:28.577191
79113	1918	breakout	402	Break Out	27-08-2026 13:48:37	337669	0.85	unrecognized	2026-08-28 11:02:35.211066	\N	Person #402	0	unrecognized	2026-08-28 11:02:38.699655
78961	1918	breakout	345	Break Out	27-08-2026 13:30:36	310737	0.85	unrecognized	2026-08-28 10:53:53.46782	\N	Person #345	0	unrecognized	2026-08-28 10:54:04.559303
78966	1918	breakout	346	Break Out	27-08-2026 13:28:09	311343	0.85	pending	2026-08-28 10:54:05.326073	\N	Person #346	0	unrecognized	\N
77246	1917	breakin	735	Break In	27-08-2026 21:16:16	299404	0.85	normal	2026-08-28 08:55:42.176366	STF-048	Abdullah Sultan	0.7196	recognized	2026-08-28 08:55:42.19332
77407	1917	breakin	905	Break In	27-08-2026 16:28:54	225523	0.85	normal	2026-08-28 09:06:53.862975	STF-028	Noman Imran	0.4551	recognized	2026-08-28 09:07:05.625592
77445	1917	breakin	927	Break In	27-08-2026 16:32:11	230477	0.85	normal	2026-08-28 09:09:44.486734	STF-047	Arshad Irshad	0.5139	recognized	2026-08-28 09:09:45.215285
78015	1918	breakout	91	Break Out	27-08-2026 18:44:55	69253	0.85	unrecognized	2026-08-28 10:03:13.69299	\N	Person #91	0	unrecognized	2026-08-28 10:03:16.961148
78354	1918	breakout	190	Break Out	27-08-2026 15:08:42	102073	0.85	pending	2026-08-28 10:22:04.140495	\N	Person #190	0	unrecognized	\N
78011	1918	breakout	89	Break Out	27-08-2026 18:43:41	67548	0.85	pending	2026-08-28 10:02:49.615507	\N	Person #89	0	unrecognized	\N
78006	1918	breakout	88	Break Out	27-08-2026 18:43:00	67466	0.85	unrecognized	2026-08-28 10:02:37.152109	\N	Person #88	0	unrecognized	2026-08-28 10:03:01.628121
76631	1917	breakin	463	Break In	27-08-2026 15:04:51	99489	0.85	normal	2026-08-28 08:20:31.378407	STF-004	Tanveer Hassan	0.5208	recognized	2026-08-28 08:20:31.399351
76634	1917	breakin	518	Break In	27-08-2026 15:04:58	99642	0.85	normal	2026-08-28 08:20:39.546278	STF-015	Liaqat Ali	0.4816	recognized	2026-08-28 08:20:42.442714
76661	1917	breakin	548	Break In	27-08-2026 13:45:07	337064	0.85	normal	2026-08-28 08:22:48.97147	STF-032	Muhammad Yaseen	0.7398	recognized	2026-08-28 08:22:48.988425
76625	1917	breakin	489	Break In	27-08-2026 20:15:27	208101	0.85	normal	2026-08-28 08:19:39.249626	STF-048	Abdullah Sultan	0.4568	recognized	2026-08-28 08:19:58.201691
78014	1918	breakout	90	Break Out	27-08-2026 18:44:00	69234	0.85	unrecognized	2026-08-28 10:03:10.989875	\N	Person #90	0	unrecognized	2026-08-28 10:03:11.374795
76649	1917	breakin	530	Break In	27-08-2026 15:06:03	101257	0.85	normal	2026-08-28 08:21:51.46261	STF-035	Hammad Shaukat	0.4404	recognized	2026-08-28 08:22:10.649813
78016	1918	breakout	92	Break Out	27-08-2026 18:45:01	69477	0.85	unrecognized	2026-08-28 10:03:17.394802	\N	Person #92	0	unrecognized	2026-08-28 10:03:18.957409
78345	1918	breakout	187	Break Out	27-08-2026 15:08:22	101432	0.85	unrecognized	2026-08-28 10:21:36.628118	\N	Person #187	0	unrecognized	2026-08-28 10:21:54.663724
78356	1918	breakout	192	Break Out	27-08-2026 15:08:53	102161	0.85	unrecognized	2026-08-28 10:22:06.843899	\N	Person #192	0	unrecognized	2026-08-28 10:22:20.54146
76931	1917	breakin	664	Break In	27-08-2026 15:31:18	139165	0.85	normal	2026-08-28 08:36:21.192415	STF-007	Faisal Saleem	0.4911	recognized	2026-08-28 08:36:21.214355
78360	1918	breakout	193	Break Out	27-08-2026 15:09:29	103222	0.85	unrecognized	2026-08-28 10:22:21.328103	\N	Person #193	0	unrecognized	2026-08-28 10:22:21.450393
76643	1917	breakin	520	Break In	27-08-2026 15:05:30	100446	0.85	unrecognized	2026-08-28 08:21:20.401378	\N	Person #520	0	unrecognized	2026-08-28 08:21:22.441922
78017	1918	breakout	91	Break Out	27-08-2026 18:45:42	70513	0.85	normal	2026-08-28 10:03:19.567413	STF-045	Zohaib Ali Chaudhary	0.4515	recognized	2026-08-28 10:03:21.516192
76632	1917	breakin	516	Break In	27-08-2026 15:04:52	99489	0.85	normal	2026-08-28 08:20:31.70614	STF-035	Hammad Shaukat	0.4571	recognized	2026-08-28 08:20:32.960883
78361	1918	breakout	193	Break Out	27-08-2026 15:09:42	103554	0.85	pending	2026-08-28 10:22:21.801677	\N	Person #193	\N	pending	\N
78704	1918	breakout	269	Break Out	27-08-2026 12:50:14	250097	0.85	normal	2026-08-28 10:41:26.450012	STF-024	Arsalan Khan	0.449	recognized	2026-08-28 10:41:32.175253
78690	1918	breakout	259	Break Out	27-08-2026 12:49:13	248548	0.85	unrecognized	2026-08-28 10:40:30.512304	\N	Person #259	0	unrecognized	2026-08-28 10:40:37.977106
76654	1917	breakin	531	Break In	27-08-2026 15:06:19	101680	0.85	normal	2026-08-28 08:22:31.787907	STF-015	Liaqat Ali	0.5056	recognized	2026-08-28 08:22:31.802867
76645	1917	breakin	496	Break In	27-08-2026 20:16:09	209138	0.85	unrecognized	2026-08-28 08:21:33.615082	\N	Person #496	0	unrecognized	2026-08-28 08:21:54.040578
78960	1918	breakout	399	Break Out	27-08-2026 21:00:41	273017	0.85	normal	2026-08-28 10:53:53.04546	STF-023	Syed Zubair Zulfiqar	0.4598	recognized	2026-08-28 10:53:53.857927
78954	1918	breakout	397	Break Out	27-08-2026 21:00:06	272167	0.85	pending	2026-08-28 10:53:38.989459	\N	Person #397	0	unrecognized	\N
78963	1918	breakout	400	Break Out	27-08-2026 21:00:51	273230	0.85	normal	2026-08-28 10:53:55.585032	STF-010	Faraz Younas	0.4504	recognized	2026-08-28 10:54:00.465534
76657	1917	breakin	489	Break In	27-08-2026 20:16:41	210038	0.85	normal	2026-08-28 08:22:40.262232	STF-048	Abdullah Sultan	0.5134	recognized	2026-08-28 08:22:40.283684
76655	1917	breakin	532	Break In	27-08-2026 15:07:22	103240	0.85	normal	2026-08-28 08:22:38.55821	STF-015	Liaqat Ali	0.5195	recognized	2026-08-28 08:22:41.543654
76663	1917	breakin	536	Break In	27-08-2026 15:07:51	103989	0.85	normal	2026-08-28 08:22:51.585321	STF-016	Muhammad Asad Awan	0.486	recognized	2026-08-28 08:22:51.624217
77310	1917	breakin	762	Break In	27-08-2026 21:22:12	308217	0.85	unrecognized	2026-08-28 09:02:01.316851	\N	Person #762	0	unrecognized	2026-08-28 09:02:10.962814
77148	1917	breakin	769	Break In	27-08-2026 16:03:00	187820	0.85	normal	2026-08-28 08:49:27.357977	STF-037	Muhammad Fahad	0.4464	recognized	2026-08-28 08:49:46.615126
78346	1918	breakout	175	Break Out	27-08-2026 11:58:00	171797	0.85	unrecognized	2026-08-28 10:21:40.055943	\N	Person #175	0	unrecognized	2026-08-28 10:21:54.137389
78348	1918	breakout	175	Break Out	27-08-2026 11:55:04	172121	0.85	pending	2026-08-28 10:21:54.573232	\N	Person #175	0	unrecognized	\N
78007	1918	breakout	71	Break Out	27-08-2026 11:08:56	98264	0.85	unrecognized	2026-08-28 10:02:38.867975	\N	Person #71	0	unrecognized	2026-08-28 10:03:18.243092
78701	1918	breakout	288	Break Out	27-08-2026 16:07:12	189786	0.85	normal	2026-08-28 10:41:18.272102	STF-011	Syed Shoaib Ahmad Alvi	0.4483	recognized	2026-08-28 10:41:24.174087
77047	1917	breakin	707	Break In	27-08-2026 15:55:49	175931	0.85	normal	2026-08-28 08:44:04.248044	STF-037	Muhammad Fahad	0.7432	recognized	2026-08-28 08:44:04.263005
77039	1917	breakin	711	Break In	27-08-2026 15:55:16	175102	0.85	normal	2026-08-28 08:43:47.270936	STF-037	Muhammad Fahad	0.47	recognized	2026-08-28 08:43:48.054803
78957	1918	breakout	359	Break Out	27-08-2026 16:40:18	239463	0.85	pending	2026-08-28 10:53:50.410514	\N	Person #359	0	unrecognized	\N
77054	1917	breakin	717	Break In	27-08-2026 15:56:19	176655	0.85	normal	2026-08-28 08:44:09.340267	STF-002	Abdur Rehman	0.4566	recognized	2026-08-28 08:44:10.986725
78018	1918	breakout	73	Break Out	27-08-2026 11:09:44	99456	0.85	unrecognized	2026-08-28 10:03:20.76255	\N	Person #73	0	unrecognized	2026-08-28 10:03:33.530662
77156	1917	breakin	776	Break In	27-08-2026 16:04:51	189406	0.85	unrecognized	2026-08-28 08:50:05.642962	\N	Person #776	0	unrecognized	2026-08-28 08:50:22.938369
76670	1917	breakin	539	Break In	27-08-2026 15:08:15	104576	0.85	normal	2026-08-28 08:23:07.380438	STF-015	Liaqat Ali	0.7304	recognized	2026-08-28 08:23:07.414347
79115	1918	breakout	415	Break Out	27-08-2026 17:04:46	276117	0.85	normal	2026-08-28 11:02:38.782434	STF-025	Farhan Virk	0.4955	recognized	2026-08-28 11:02:40.008628
77155	1917	breakin	773	Break In	27-08-2026 16:04:04	188302	0.85	normal	2026-08-28 08:50:00.25556	STF-008	Muhammad Shoaib	0.444	recognized	2026-08-28 08:50:02.203996
78352	1918	breakout	175	Break Out	27-08-2026 11:58:47	173035	0.85	unrecognized	2026-08-28 10:21:55.885764	\N	Person #175	0	unrecognized	2026-08-28 10:22:09.43609
78964	1918	breakout	362	Break Out	27-08-2026 16:41:51	241659	0.85	unrecognized	2026-08-28 10:53:58.704227	\N	Person #362	0	unrecognized	2026-08-28 10:54:15.945637
78358	1918	breakout	176	Break Out	27-08-2026 11:59:50	173855	0.85	unrecognized	2026-08-28 10:22:10.122888	\N	Person #176	0	unrecognized	2026-08-28 10:23:36.169095
78968	1918	breakout	363	Break Out	27-08-2026 16:42:48	243205	0.85	pending	2026-08-28 10:54:17.141876	\N	Person #363	0	unrecognized	\N
78962	1918	breakout	361	Break Out	27-08-2026 16:41:19	240896	0.85	unrecognized	2026-08-28 10:53:54.451532	\N	Person #361	0	unrecognized	2026-08-28 10:53:57.912684
77239	1917	breakin	823	Break In	27-08-2026 16:10:08	197149	0.85	normal	2026-08-28 08:55:35.830702	STF-030	Dildar Ahmed	0.5127	recognized	2026-08-28 08:55:48.255134
78972	1918	breakout	364	Break Out	27-08-2026 16:43:35	244347	0.85	normal	2026-08-28 10:54:21.125123	STF-013	Muhammad Faizan	0.4668	recognized	2026-08-28 10:54:22.04849
77237	1917	breakin	822	Break In	27-08-2026 16:09:53	197026	0.85	normal	2026-08-28 08:55:32.214022	STF-052	Syed Imran Shah	0.4663	recognized	2026-08-28 08:55:32.912712
79120	1918	breakout	416	Break Out	27-08-2026 17:05:39	277336	0.85	unrecognized	2026-08-28 11:02:43.871955	\N	Person #416	0	unrecognized	2026-08-28 11:02:59.569178
79129	1918	breakout	417	Break Out	27-08-2026 17:07:27	280097	0.85	unrecognized	2026-08-28 11:03:01.045751	\N	Person #417	0	unrecognized	2026-08-28 11:03:44.701209
79119	1918	breakout	416	Break Out	27-08-2026 17:05:26	277146	0.85	unrecognized	2026-08-28 11:02:42.899481	\N	Person #416	0	unrecognized	2026-08-28 11:02:43.544648
77253	1917	breakin	829	Break In	27-08-2026 16:10:37	198066	0.85	normal	2026-08-28 08:56:02.296575	STF-037	Muhammad Fahad	0.4487	recognized	2026-08-28 08:56:22.268649
77308	1917	breakin	761	Break In	27-08-2026 21:21:24	307117	0.85	normal	2026-08-28 09:01:57.480262	STF-045	Zohaib Ali Chaudhary	0.4814	recognized	2026-08-28 09:01:57.497419
77312	1917	breakin	764	Break In	27-08-2026 21:22:32	308712	0.85	unrecognized	2026-08-28 09:02:11.896625	\N	Person #764	0	unrecognized	2026-08-28 09:02:24.246321
77389	1917	breakin	892	Break In	27-08-2026 16:26:21	221724	0.85	normal	2026-08-28 09:05:27.646984	STF-028	Noman Imran	0.5146	recognized	2026-08-28 09:05:27.898461
77393	1917	breakin	894	Break In	27-08-2026 16:27:08	222730	0.85	unrecognized	2026-08-28 09:05:29.840514	\N	Person #894	0	unrecognized	2026-08-28 09:05:45.577509
77038	1917	breakin	620	Break In	27-08-2026 20:55:37	268443	0.85	normal	2026-08-28 08:43:46.524256	STF-008	Muhammad Shoaib	0.5076	recognized	2026-08-28 08:43:46.541211
78372	1918	breakout	212	Break Out	27-08-2026 19:37:57	148840	0.85	unrecognized	2026-08-28 10:23:04.880346	\N	Person #212	0	unrecognized	2026-08-28 10:23:15.227481
76934	1917	breakin	664	Break In	27-08-2026 15:31:39	139667	0.85	normal	2026-08-28 08:36:24.132823	STF-010	Faraz Younas	0.4429	recognized	2026-08-28 08:36:25.387984
78033	1918	breakout	99	Break Out	27-08-2026 18:48:09	74125	0.85	unrecognized	2026-08-28 10:04:07.46982	\N	Person #99	0	unrecognized	2026-08-28 10:04:25.087519
78366	1918	breakout	211	Break Out	27-08-2026 19:37:14	147735	0.85	unrecognized	2026-08-28 10:22:44.430591	\N	Person #211	0	unrecognized	2026-08-28 10:22:53.578652
76937	1917	breakin	665	Break In	27-08-2026 15:31:00	139898	0.85	normal	2026-08-28 08:36:33.129395	STF-010	Faraz Younas	0.4535	recognized	2026-08-28 08:36:33.996618
76939	1917	breakin	666	Break In	27-08-2026 15:37:34	148560	0.85	pending	2026-08-28 08:36:44.780872	\N	Person #666	\N	pending	\N
76941	1917	breakin	668	Break In	27-08-2026 15:38:16	149564	0.85	unrecognized	2026-08-28 08:36:51.168546	\N	Person #668	0	unrecognized	2026-08-28 08:36:58.09194
78030	1918	breakout	98	Break Out	27-08-2026 18:47:27	73170	0.85	normal	2026-08-28 10:04:02.893856	STF-010	Faraz Younas	0.4498	recognized	2026-08-28 10:04:04.031148
76940	1917	breakin	667	Break In	27-08-2026 15:37:00	148868	0.85	normal	2026-08-28 08:36:45.299735	STF-005	Muhammad Ayaz Hussain	0.559	recognized	2026-08-28 08:36:47.215761
78374	1918	breakout	212	Break Out	27-08-2026 19:38:10	149142	0.85	unrecognized	2026-08-28 10:23:15.670943	\N	Person #212	0	unrecognized	2026-08-28 10:23:20.232783
78363	1918	breakout	210	Break Out	27-08-2026 19:36:00	146963	0.85	unrecognized	2026-08-28 10:22:29.781734	\N	Person #210	0	unrecognized	2026-08-28 10:22:43.486156
76943	1917	breakin	669	Break In	27-08-2026 15:38:23	149599	0.85	unrecognized	2026-08-28 08:36:55.720916	\N	Person #669	0	unrecognized	2026-08-28 08:37:18.445318
79239	1918	breakout	450	Break Out	27-08-2026 17:30:46	315114	0.85	normal	2026-08-28 11:09:43.454775	STF-018	Muhammad Qaiser Shahzad	0.4744	recognized	2026-08-28 11:09:45.580624
77313	1917	breakin	859	Break In	27-08-2026 16:14:06	203073	0.85	normal	2026-08-28 09:02:12.750406	STF-037	Muhammad Fahad	0.5176	recognized	2026-08-28 09:02:53.082774
79127	1918	breakout	454	Break Out	27-08-2026 21:16:12	296187	0.85	unrecognized	2026-08-28 11:02:51.288817	\N	Person #454	0	unrecognized	2026-08-28 11:03:04.876839
76949	1917	breakin	671	Break In	27-08-2026 15:38:39	150105	0.85	unrecognized	2026-08-28 08:37:18.969585	\N	Person #671	0	unrecognized	2026-08-28 08:37:27.99915
77034	1917	breakin	617	Break In	27-08-2026 20:54:14	266351	0.85	normal	2026-08-28 08:43:41.054907	STF-007	Faisal Saleem	0.5626	recognized	2026-08-28 08:43:41.069375
79243	1918	breakout	451	Break Out	27-08-2026 17:32:17	317301	0.85	unrecognized	2026-08-28 11:09:48.121428	\N	Person #451	0	unrecognized	2026-08-28 11:09:56.614526
77056	1917	breakin	626	Break In	27-08-2026 20:56:19	269482	0.85	normal	2026-08-28 08:44:13.855192	STF-033	Raza Abbas	0.6088	recognized	2026-08-28 08:44:13.875134
78368	1918	breakout	211	Break Out	27-08-2026 19:37:00	148388	0.85	unrecognized	2026-08-28 10:22:54.03067	\N	Person #211	0	unrecognized	2026-08-28 10:23:03.768655
78377	1918	breakout	213	Break Out	27-08-2026 19:39:32	151209	0.85	unrecognized	2026-08-28 10:23:21.470324	\N	Person #213	0	unrecognized	2026-08-28 10:23:34.516093
79252	1918	breakout	454	Break Out	27-08-2026 17:34:03	319969	0.85	unrecognized	2026-08-28 11:10:19.776224	\N	Person #454	0	unrecognized	2026-08-28 11:10:22.237426
79246	1918	breakout	452	Break Out	27-08-2026 17:32:23	317445	0.85	unrecognized	2026-08-28 11:09:56.8845	\N	Person #452	0	unrecognized	2026-08-28 11:10:08.316649
79249	1918	breakout	453	Break Out	27-08-2026 17:33:35	319287	0.85	unrecognized	2026-08-28 11:10:09.310149	\N	Person #453	0	unrecognized	2026-08-28 11:10:18.929321
77305	1917	breakin	856	Break In	27-08-2026 16:13:31	202467	0.85	normal	2026-08-28 09:01:31.324556	STF-029	Abdul Rehman Sultan	0.5216	recognized	2026-08-28 09:01:38.764199
79253	1918	breakout	455	Break Out	27-08-2026 17:34:15	320278	0.85	unrecognized	2026-08-28 11:10:22.87695	\N	Person #455	0	unrecognized	2026-08-28 11:10:31.982594
79251	1918	breakout	453	Break Out	27-08-2026 17:33:46	319654	0.85	pending	2026-08-28 11:10:19.270579	\N	Person #453	\N	pending	\N
77417	1917	breakin	908	Break In	27-08-2026 16:30:01	227212	0.85	normal	2026-08-28 09:07:41.208606	STF-034	Muhammad Laeeq	0.5199	recognized	2026-08-28 09:07:43.974777
78029	1918	breakout	75	Break Out	27-08-2026 11:11:50	102603	0.85	unrecognized	2026-08-28 10:04:01.654686	\N	Person #75	0	unrecognized	2026-08-28 10:04:20.385349
78023	1918	breakout	73	Break Out	27-08-2026 11:09:55	99736	0.85	unrecognized	2026-08-28 10:03:33.860028	\N	Person #73	0	unrecognized	2026-08-28 10:03:48.755575
76686	1917	breakin	547	Break In	27-08-2026 15:09:31	106313	0.85	normal	2026-08-28 08:24:20.715656	STF-015	Liaqat Ali	0.4978	recognized	2026-08-28 08:24:43.719738
76701	1917	breakin	505	Break In	27-08-2026 20:18:00	213088	0.85	normal	2026-08-28 08:25:34.785309	STF-033	Raza Abbas	0.557	recognized	2026-08-28 08:25:34.80725
76678	1917	breakin	545	Break In	27-08-2026 15:09:13	106013	0.85	normal	2026-08-28 08:23:45.078676	STF-034	Muhammad Laeeq	0.4525	recognized	2026-08-28 08:23:45.956077
76936	1917	breakin	561	Break In	27-08-2026 20:40:16	245188	0.85	unrecognized	2026-08-28 08:36:28.484742	\N	Person #561	0	unrecognized	2026-08-28 08:36:51.113175
78365	1918	breakout	194	Break Out	27-08-2026 15:10:22	104479	0.85	normal	2026-08-28 10:22:44.174352	STF-015	Liaqat Ali	0.5594	recognized	2026-08-28 10:22:47.809258
78026	1918	breakout	74	Break Out	27-08-2026 11:11:26	102041	0.85	unrecognized	2026-08-28 10:03:50.163372	\N	Person #74	0	unrecognized	2026-08-28 10:04:01.153053
76696	1917	breakin	504	Break In	27-08-2026 20:18:31	212502	0.85	unrecognized	2026-08-28 08:25:12.917206	\N	Person #504	0	unrecognized	2026-08-28 08:25:27.518766
76683	1917	breakin	555	Break In	27-08-2026 13:46:39	339565	0.85	normal	2026-08-28 08:24:03.511394	STF-018	Muhammad Qaiser Shahzad	0.4751	recognized	2026-08-28 08:24:06.770545
78036	1918	breakout	77	Break Out	27-08-2026 11:12:01	102831	0.85	unrecognized	2026-08-28 10:04:20.948318	\N	Person #77	0	unrecognized	2026-08-28 10:04:48.050053
76681	1917	breakin	493	Break In	27-08-2026 20:17:27	211085	0.85	unrecognized	2026-08-28 08:23:49.168345	\N	Person #493	0	unrecognized	2026-08-28 08:23:59.259549
78715	1918	breakout	293	Break Out	27-08-2026 16:07:57	190875	0.85	unrecognized	2026-08-28 10:42:02.047322	\N	Person #293	0	unrecognized	2026-08-28 10:42:02.567736
78714	1918	breakout	292	Break Out	27-08-2026 16:07:51	190785	0.85	pending	2026-08-28 10:41:58.095433	\N	Person #292	\N	pending	\N
78376	1918	breakout	200	Break Out	27-08-2026 15:10:57	105390	0.85	unrecognized	2026-08-28 10:23:18.06366	\N	Person #200	0	unrecognized	2026-08-28 10:23:25.662775
76679	1917	breakin	553	Break In	27-08-2026 13:45:40	337830	0.85	unrecognized	2026-08-28 08:23:45.549571	\N	Person #553	0	unrecognized	2026-08-28 08:23:52.641132
78716	1918	breakout	293	Break Out	27-08-2026 16:08:09	191048	0.85	unrecognized	2026-08-28 10:42:02.831192	\N	Person #293	0	unrecognized	2026-08-28 10:42:04.385779
76703	1917	breakin	554	Break In	27-08-2026 15:10:10	107453	0.85	normal	2026-08-28 08:25:36.603005	STF-006	Muhammad Abubakar	0.5939	recognized	2026-08-28 08:25:36.642897
76705	1917	breakin	506	Break In	27-08-2026 20:18:00	213121	0.85	normal	2026-08-28 08:25:42.719615	STF-044	Zaheer Hussain	0.4827	recognized	2026-08-28 08:25:43.264338
76702	1917	breakin	552	Break In	27-08-2026 15:10:09	107424	0.85	normal	2026-08-28 08:25:35.534972	STF-015	Liaqat Ali	0.4414	recognized	2026-08-28 08:25:35.568882
76716	1917	breakin	507	Break In	27-08-2026 20:18:55	213261	0.85	unrecognized	2026-08-28 08:26:05.227459	\N	Person #507	0	unrecognized	2026-08-28 08:26:20.700345
76708	1917	breakin	562	Break In	27-08-2026 13:47:31	340666	0.85	normal	2026-08-28 08:25:50.525247	STF-015	Liaqat Ali	0.4572	recognized	2026-08-28 08:25:53.589237
78976	1918	breakout	350	Break Out	27-08-2026 13:32:16	313250	0.85	unrecognized	2026-08-28 10:54:34.523072	\N	Person #350	0	unrecognized	2026-08-28 10:54:37.939814
78981	1918	breakout	350	Break Out	27-08-2026 13:32:23	313506	0.85	unrecognized	2026-08-28 10:54:38.280157	\N	Person #350	0	unrecognized	2026-08-28 10:54:40.920005
76698	1917	breakin	504	Break In	27-08-2026 20:19:27	212987	0.85	unrecognized	2026-08-28 08:25:27.859362	\N	Person #504	0	unrecognized	2026-08-28 08:27:16.314656
76718	1917	breakin	561	Break In	27-08-2026 15:10:27	107878	0.85	normal	2026-08-28 08:26:15.7526	STF-026	Syed Zeeshan Ali	0.4622	recognized	2026-08-28 08:26:15.774541
78980	1918	breakout	404	Break Out	27-08-2026 21:01:55	274803	0.85	normal	2026-08-28 10:54:37.071857	STF-013	Muhammad Faizan	0.4411	recognized	2026-08-28 10:54:47.217318
78713	1918	breakout	317	Break Out	27-08-2026 20:36:30	236692	0.85	unrecognized	2026-08-28 10:41:51.930233	\N	Person #317	0	unrecognized	2026-08-28 10:42:03.796425
78711	1918	breakout	315	Break Out	27-08-2026 20:35:53	235757	0.85	normal	2026-08-28 10:41:44.413604	STF-050	Hafeez-Ur-Rehman	0.4949	recognized	2026-08-28 10:41:48.777313
78031	1918	breakout	97	Break Out	27-08-2026 14:31:01	45422	0.85	unrecognized	2026-08-28 10:04:03.424724	\N	Person #97	0	unrecognized	2026-08-28 10:04:06.126749
78039	1918	breakout	98	Break Out	27-08-2026 14:32:27	47609	0.85	unrecognized	2026-08-28 10:04:26.503695	\N	Person #98	0	unrecognized	2026-08-28 10:04:36.399912
78032	1918	breakout	97	Break Out	27-08-2026 14:32:20	47388	0.85	unrecognized	2026-08-28 10:04:07.100364	\N	Person #97	0	unrecognized	2026-08-28 10:04:25.899571
78718	1918	breakout	318	Break Out	27-08-2026 20:36:47	237181	0.85	pending	2026-08-28 10:42:04.541146	\N	Person #318	0	unrecognized	\N
76738	1917	breakin	582	Break In	27-08-2026 13:51:16	346239	0.85	normal	2026-08-28 08:27:39.480641	STF-026	Syed Zeeshan Ali	0.5083	recognized	2026-08-28 08:27:43.713028
78024	1918	breakout	96	Break Out	27-08-2026 14:30:16	44310	0.85	unrecognized	2026-08-28 10:03:39.163455	\N	Person #96	0	unrecognized	2026-08-28 10:03:50.930874
79128	1918	breakout	407	Break Out	27-08-2026 13:49:19	338921	0.85	normal	2026-08-28 11:02:59.80222	STF-005	Muhammad Ayaz Hussain	0.4482	recognized	2026-08-28 11:03:08.568339
78721	1918	breakout	319	Break Out	27-08-2026 20:36:53	237249	0.85	unrecognized	2026-08-28 10:42:06.638159	\N	Person #319	0	unrecognized	2026-08-28 10:42:10.636246
78375	1918	breakout	177	Break Out	27-08-2026 12:00:00	174671	0.85	unrecognized	2026-08-28 10:23:17.140814	\N	Person #177	0	unrecognized	2026-08-28 10:23:52.667977
76728	1917	breakin	568	Break In	27-08-2026 13:48:59	342717	0.85	unrecognized	2026-08-28 08:27:06.112502	\N	Person #568	0	unrecognized	2026-08-28 08:27:19.727541
76726	1917	breakin	567	Break In	27-08-2026 13:48:38	342426	0.85	unrecognized	2026-08-28 08:26:48.874911	\N	Person #567	0	unrecognized	2026-08-28 08:27:05.035585
76743	1917	breakin	580	Break In	27-08-2026 15:11:27	109373	0.85	normal	2026-08-28 08:27:47.968349	STF-015	Liaqat Ali	0.4597	recognized	2026-08-28 08:27:47.999267
78726	1918	breakout	321	Break Out	27-08-2026 20:37:30	237990	0.85	unrecognized	2026-08-28 10:42:24.168723	\N	Person #321	0	unrecognized	2026-08-28 10:43:00.322582
78722	1918	breakout	320	Break Out	27-08-2026 20:37:01	237444	0.85	unrecognized	2026-08-28 10:42:11.198042	\N	Person #320	0	unrecognized	2026-08-28 10:42:23.576465
76946	1917	breakin	563	Break In	27-08-2026 20:40:37	245830	0.85	unrecognized	2026-08-28 08:37:00.360487	\N	Person #563	0	unrecognized	2026-08-28 08:37:25.667667
76947	1917	breakin	564	Break In	27-08-2026 20:40:44	245848	0.85	unrecognized	2026-08-28 08:37:02.60808	\N	Person #564	0	unrecognized	2026-08-28 08:37:29.913969
76721	1917	breakin	565	Break In	27-08-2026 13:48:15	341604	0.85	unrecognized	2026-08-28 08:26:30.160869	\N	Person #565	0	unrecognized	2026-08-28 08:26:47.639971
76753	1917	breakin	586	Break In	27-08-2026 15:11:00	109736	0.85	normal	2026-08-28 08:28:04.976728	STF-035	Hammad Shaukat	0.4732	recognized	2026-08-28 08:28:05.332147
76734	1917	breakin	571	Break In	27-08-2026 13:49:38	343832	0.85	normal	2026-08-28 08:27:21.274575	STF-032	Muhammad Yaseen	0.5912	recognized	2026-08-28 08:27:21.319738
76735	1917	breakin	572	Break In	27-08-2026 13:49:36	343986	0.85	normal	2026-08-28 08:27:26.305241	STF-005	Muhammad Ayaz Hussain	0.5297	recognized	2026-08-28 08:27:31.25358
76744	1917	breakin	585	Break In	27-08-2026 13:51:36	346768	0.85	normal	2026-08-28 08:27:48.542096	STF-033	Raza Abbas	0.4985	recognized	2026-08-28 08:27:50.062974
78988	1918	breakout	407	Break Out	27-08-2026 21:02:28	275705	0.85	pending	2026-08-28 10:55:10.398424	\N	Person #407	0	unrecognized	\N
76737	1917	breakin	578	Break In	27-08-2026 13:50:30	345139	0.85	unrecognized	2026-08-28 08:27:37.560476	\N	Person #578	0	unrecognized	2026-08-28 08:27:37.797351
76739	1917	breakin	579	Break In	27-08-2026 15:11:25	109340	0.85	normal	2026-08-28 08:27:39.490167	STF-016	Muhammad Asad Awan	0.5364	recognized	2026-08-28 08:27:39.529063
79135	1918	breakout	409	Break Out	27-08-2026 13:51:13	341714	0.85	unrecognized	2026-08-28 11:03:22.414313	\N	Person #409	0	unrecognized	2026-08-28 11:03:29.859341
76751	1917	breakin	585	Break In	27-08-2026 15:11:38	109653	0.85	normal	2026-08-28 08:28:03.710009	STF-034	Muhammad Laeeq	0.5038	recognized	2026-08-28 08:28:03.733945
79134	1918	breakout	407	Break Out	27-08-2026 13:49:53	339761	0.85	normal	2026-08-28 11:03:16.645935	STF-032	Muhammad Yaseen	0.46	recognized	2026-08-28 11:03:17.855215
76755	1917	breakin	587	Break In	27-08-2026 15:11:50	109963	0.85	normal	2026-08-28 08:28:09.915165	STF-004	Tanveer Hassan	0.4541	recognized	2026-08-28 08:28:09.93388
76748	1917	breakin	510	Break In	27-08-2026 20:20:25	215634	0.85	normal	2026-08-28 08:27:51.661242	STF-029	Abdul Rehman Sultan	0.4987	recognized	2026-08-28 08:27:52.98093
79254	1918	breakout	496	Break Out	27-08-2026 21:39:44	331523	0.85	unrecognized	2026-08-28 11:10:25.942967	\N	Person #496	0	unrecognized	2026-08-28 11:10:34.27854
79250	1918	breakout	495	Break Out	27-08-2026 21:33:27	322083	0.85	unrecognized	2026-08-28 11:10:11.103489	\N	Person #495	0	unrecognized	2026-08-28 11:10:22.461982
76756	1917	breakin	511	Break In	27-08-2026 20:20:59	216484	0.85	normal	2026-08-28 08:28:10.553938	STF-010	Faraz Younas	0.4614	recognized	2026-08-28 08:28:11.04891
78717	1918	breakout	272	Break Out	27-08-2026 12:51:46	252493	0.85	unrecognized	2026-08-28 10:42:03.810388	\N	Person #272	0	unrecognized	2026-08-28 10:42:15.65889
77061	1917	breakin	707	Break In	27-08-2026 15:56:49	177424	0.85	normal	2026-08-28 08:44:31.524326	STF-037	Muhammad Fahad	0.6901	recognized	2026-08-28 08:44:31.564219
77062	1917	breakin	721	Break In	27-08-2026 15:56:52	177518	0.85	normal	2026-08-28 08:44:32.207658	STF-013	Muhammad Faizan	0.5837	recognized	2026-08-28 08:44:32.22162
76953	1917	breakin	566	Break In	27-08-2026 20:42:08	248129	0.85	unrecognized	2026-08-28 08:37:31.423281	\N	Person #566	0	unrecognized	2026-08-28 08:37:39.14771
78983	1918	breakout	368	Break Out	27-08-2026 16:46:10	248156	0.85	unrecognized	2026-08-28 10:54:48.269698	\N	Person #368	0	unrecognized	2026-08-28 10:55:05.831536
76952	1917	breakin	564	Break In	27-08-2026 20:41:11	246794	0.85	unrecognized	2026-08-28 08:37:30.588517	\N	Person #564	0	unrecognized	2026-08-28 08:37:30.602368
78040	1918	breakout	101	Break Out	27-08-2026 18:49:08	75689	0.85	normal	2026-08-28 10:04:29.183451	STF-023	Syed Zubair Zulfiqar	0.4549	recognized	2026-08-28 10:04:30.684388
78055	1918	breakout	108	Break Out	27-08-2026 18:50:42	78010	0.85	normal	2026-08-28 10:05:17.353175	STF-034	Muhammad Laeeq	0.4547	recognized	2026-08-28 10:05:19.10507
76965	1917	breakin	573	Break In	27-08-2026 20:44:33	251734	0.85	unrecognized	2026-08-28 08:38:14.212137	\N	Person #573	0	unrecognized	2026-08-28 08:38:35.352228
78056	1918	breakout	109	Break Out	27-08-2026 18:51:49	79730	0.85	pending	2026-08-28 10:05:21.411035	\N	Person #109	0	unrecognized	\N
78058	1918	breakout	110	Break Out	27-08-2026 18:53:35	82383	0.85	pending	2026-08-28 10:05:26.224418	\N	Person #110	0	unrecognized	\N
78712	1918	breakout	271	Break Out	27-08-2026 12:51:03	251389	0.85	unrecognized	2026-08-28 10:41:50.8124	\N	Person #271	0	unrecognized	2026-08-28 10:41:56.444997
77318	1917	breakin	769	Break In	27-08-2026 21:26:44	315089	0.85	normal	2026-08-28 09:02:47.22218	STF-026	Syed Zeeshan Ali	0.4473	recognized	2026-08-28 09:02:48.997036
76955	1917	breakin	568	Break In	27-08-2026 20:42:16	248342	0.85	unrecognized	2026-08-28 08:37:39.58918	\N	Person #568	0	unrecognized	2026-08-28 08:37:42.63822
77258	1917	breakin	739	Break In	27-08-2026 21:17:19	300944	0.85	normal	2026-08-28 08:56:30.910452	STF-002	Abdur Rehman	0.4926	recognized	2026-08-28 08:56:43.02424
78391	1918	breakout	216	Break Out	27-08-2026 19:42:51	156251	0.85	normal	2026-08-28 10:24:14.72365	STF-010	Faraz Younas	0.5693	recognized	2026-08-28 10:24:17.297321
77070	1917	breakin	731	Break In	27-08-2026 15:58:39	180139	0.85	normal	2026-08-28 08:45:06.505907	STF-030	Dildar Ahmed	0.5679	recognized	2026-08-28 08:45:09.379398
78385	1918	breakout	214	Break Out	27-08-2026 19:41:39	154391	0.85	normal	2026-08-28 10:23:49.94484	STF-045	Zohaib Ali Chaudhary	0.5155	recognized	2026-08-28 10:23:52.488094
79447	1950	breakin	37	Break In	25-08-2026 19:03:17	12485	0.85	normal	2026-08-28 14:32:35.785289	STF-015	Liaqat Ali	0.5815	recognized	2026-08-28 14:32:35.803619
76957	1917	breakin	570	Break In	27-08-2026 20:43:34	250336	0.85	unrecognized	2026-08-28 08:37:43.774809	\N	Person #570	0	unrecognized	2026-08-28 08:37:45.030863
78379	1918	breakout	214	Break Out	27-08-2026 19:40:06	152067	0.85	unrecognized	2026-08-28 10:23:35.503356	\N	Person #214	0	unrecognized	2026-08-28 10:23:48.910328
77173	1917	breakin	693	Break In	27-08-2026 21:07:59	286719	0.85	unrecognized	2026-08-28 08:51:18.301071	\N	Person #693	0	unrecognized	2026-08-28 08:51:39.81715
77066	1917	breakin	726	Break In	27-08-2026 15:57:36	178598	0.85	normal	2026-08-28 08:44:41.121434	STF-013	Muhammad Faizan	0.5492	recognized	2026-08-28 08:44:41.149359
77172	1917	breakin	690	Break In	27-08-2026 21:06:34	284791	0.85	normal	2026-08-28 08:51:04.528685	STF-013	Muhammad Faizan	0.4465	recognized	2026-08-28 08:51:12.331529
78710	1918	breakout	270	Break Out	27-08-2026 12:50:52	251128	0.85	unrecognized	2026-08-28 10:41:39.802759	\N	Person #270	0	unrecognized	2026-08-28 10:41:49.939061
77068	1917	breakin	728	Break In	27-08-2026 15:58:10	179455	0.85	normal	2026-08-28 08:45:01.702905	STF-037	Muhammad Fahad	0.4899	recognized	2026-08-28 08:45:03.8661
78978	1918	breakout	367	Break Out	27-08-2026 16:44:53	246276	0.85	normal	2026-08-28 10:54:35.288134	STF-047	Arshad Irshad	0.4719	recognized	2026-08-28 10:54:43.290341
77257	1917	breakin	739	Break In	27-08-2026 21:16:53	300325	0.85	normal	2026-08-28 08:56:24.716771	STF-045	Zohaib Ali Chaudhary	0.6049	recognized	2026-08-28 08:56:26.767439
77323	1917	breakin	770	Break In	27-08-2026 21:29:04	318534	0.85	normal	2026-08-28 09:03:00.097746	STF-011	Syed Shoaib Ahmad Alvi	0.48	recognized	2026-08-28 09:03:06.675812
77320	1917	breakin	770	Break In	27-08-2026 21:27:52	316738	0.85	unrecognized	2026-08-28 09:02:51.463593	\N	Person #770	0	unrecognized	2026-08-28 09:02:59.315664
77315	1917	breakin	764	Break In	27-08-2026 21:25:41	313513	0.85	normal	2026-08-28 09:02:26.195348	STF-036	Shahzad Ali	0.4878	recognized	2026-08-28 09:02:28.989693
76784	1917	breakin	599	Break In	27-08-2026 15:12:52	111487	0.85	normal	2026-08-28 08:29:56.066433	STF-016	Muhammad Asad Awan	0.4821	recognized	2026-08-28 08:30:00.708371
79442	1950	breakin	77	Break In	25-08-2026 19:03:36	12946	0.85	normal	2026-08-28 14:32:15.807631	STF-049	Nabi Ul Haq	0.4658	recognized	2026-08-28 14:32:17.407554
76777	1917	breakin	513	Break In	27-08-2026 20:22:21	218473	0.85	unrecognized	2026-08-28 08:29:46.911033	\N	Person #513	0	unrecognized	2026-08-28 08:29:48.237462
78984	1918	breakout	352	Break Out	27-08-2026 13:33:21	314896	0.85	unrecognized	2026-08-28 10:54:49.381517	\N	Person #352	0	unrecognized	2026-08-28 10:55:06.373956
78043	1918	breakout	101	Break Out	27-08-2026 14:33:07	48621	0.85	unrecognized	2026-08-28 10:04:38.189109	\N	Person #101	0	unrecognized	2026-08-28 10:04:51.504853
76792	1917	breakin	604	Break In	27-08-2026 13:53:17	349328	0.85	normal	2026-08-28 08:30:07.4446	STF-011	Syed Shoaib Ahmad Alvi	0.5056	recognized	2026-08-28 08:30:07.460558
76785	1917	breakin	513	Break In	27-08-2026 20:23:05	219613	0.85	unrecognized	2026-08-28 08:29:56.65103	\N	Person #513	0	unrecognized	2026-08-28 08:29:58.251626
76776	1917	breakin	513	Break In	27-08-2026 20:22:09	218220	0.85	unrecognized	2026-08-28 08:29:45.467098	\N	Person #513	0	unrecognized	2026-08-28 08:29:46.54927
76779	1917	breakin	513	Break In	27-08-2026 20:22:37	218895	0.85	unrecognized	2026-08-28 08:29:49.883743	\N	Person #513	0	unrecognized	2026-08-28 08:29:50.748453
76763	1917	breakin	593	Break In	27-08-2026 13:52:18	347847	0.85	normal	2026-08-28 08:28:40.183439	STF-011	Syed Shoaib Ahmad Alvi	0.4459	recognized	2026-08-28 08:28:40.206378
78381	1918	breakout	201	Break Out	27-08-2026 15:11:42	106486	0.85	normal	2026-08-28 10:23:41.507866	STF-015	Liaqat Ali	0.5415	recognized	2026-08-28 10:23:50.273961
78048	1918	breakout	102	Break Out	27-08-2026 14:33:27	49107	0.85	unrecognized	2026-08-28 10:04:52.181661	\N	Person #102	0	unrecognized	2026-08-28 10:04:54.813556
76780	1917	breakin	513	Break In	27-08-2026 20:22:51	219098	0.85	unrecognized	2026-08-28 08:29:51.061212	\N	Person #513	0	unrecognized	2026-08-28 08:29:55.300137
76769	1917	breakin	595	Break In	27-08-2026 15:12:15	110589	0.85	normal	2026-08-28 08:29:04.22286	STF-035	Hammad Shaukat	0.5674	recognized	2026-08-28 08:29:04.252778
78382	1918	breakout	202	Break Out	27-08-2026 15:11:42	106520	0.85	normal	2026-08-28 10:23:42.843792	STF-016	Muhammad Asad Awan	0.4663	recognized	2026-08-28 10:23:46.740875
78053	1918	breakout	106	Break Out	27-08-2026 14:35:47	52536	0.85	unrecognized	2026-08-28 10:05:13.430833	\N	Person #106	0	unrecognized	2026-08-28 10:05:25.868627
78050	1918	breakout	102	Break Out	27-08-2026 14:33:42	49445	0.85	unrecognized	2026-08-28 10:04:55.245961	\N	Person #102	0	unrecognized	2026-08-28 10:05:11.667037
78394	1918	breakout	207	Break Out	27-08-2026 15:12:35	107795	0.85	unrecognized	2026-08-28 10:24:24.892832	\N	Person #207	0	unrecognized	2026-08-28 10:24:26.759174
78732	1918	breakout	324	Break Out	27-08-2026 20:37:36	238312	0.85	unrecognized	2026-08-28 10:43:01.551498	\N	Person #324	0	unrecognized	2026-08-28 10:43:12.804023
78389	1918	breakout	206	Break Out	27-08-2026 15:11:58	106710	0.85	normal	2026-08-28 10:23:54.804479	STF-004	Tanveer Hassan	0.5221	recognized	2026-08-28 10:24:22.159397
76778	1917	breakin	513	Break In	27-08-2026 20:22:28	218631	0.85	unrecognized	2026-08-28 08:29:48.505571	\N	Person #513	0	unrecognized	2026-08-28 08:29:49.46307
78395	1918	breakout	207	Break Out	27-08-2026 15:12:47	108043	0.85	unrecognized	2026-08-28 10:24:27.092844	\N	Person #207	0	unrecognized	2026-08-28 10:24:56.565446
76770	1917	breakin	513	Break In	27-08-2026 20:21:56	217202	0.85	unrecognized	2026-08-28 08:29:05.017064	\N	Person #513	0	unrecognized	2026-08-28 08:29:42.739726
78737	1918	breakout	325	Break Out	27-08-2026 20:37:54	238857	0.85	pending	2026-08-28 10:43:13.457856	\N	Person #325	0	unrecognized	\N
76782	1917	breakin	600	Break In	27-08-2026 15:12:50	111460	0.85	normal	2026-08-28 08:29:55.604385	STF-034	Muhammad Laeeq	0.6765	recognized	2026-08-28 08:29:55.6757
76791	1917	breakin	513	Break In	27-08-2026 20:24:18	220619	0.85	unrecognized	2026-08-28 08:30:07.392739	\N	Person #513	0	unrecognized	2026-08-28 08:30:30.940476
78982	1918	breakout	351	Break Out	27-08-2026 13:32:49	314085	0.85	unrecognized	2026-08-28 10:54:41.905776	\N	Person #351	0	unrecognized	2026-08-28 10:54:48.598205
78739	1918	breakout	326	Break Out	27-08-2026 20:38:01	238914	0.85	unrecognized	2026-08-28 10:43:14.6864	\N	Person #326	0	unrecognized	2026-08-28 10:43:44.271102
76789	1917	breakin	602	Break In	27-08-2026 13:53:11	349154	0.85	normal	2026-08-28 08:30:03.530051	STF-010	Faraz Younas	0.4594	recognized	2026-08-28 08:30:04.692602
76786	1917	breakin	513	Break In	27-08-2026 20:23:20	219738	0.85	unrecognized	2026-08-28 08:29:58.543294	\N	Person #513	0	unrecognized	2026-08-28 08:30:02.041656
76783	1917	breakin	513	Break In	27-08-2026 20:22:59	219475	0.85	unrecognized	2026-08-28 08:29:55.634305	\N	Person #513	0	unrecognized	2026-08-28 08:29:56.288559
76787	1917	breakin	513	Break In	27-08-2026 20:23:34	220228	0.85	unrecognized	2026-08-28 08:30:02.382046	\N	Person #513	0	unrecognized	2026-08-28 08:30:06.899106
76800	1917	breakin	608	Break In	27-08-2026 13:53:00	350010	0.85	normal	2026-08-28 08:30:24.316736	STF-033	Raza Abbas	0.6276	recognized	2026-08-28 08:30:24.332693
76806	1917	breakin	607	Break In	27-08-2026 15:13:50	112967	0.85	normal	2026-08-28 08:30:48.953071	STF-035	Hammad Shaukat	0.5325	recognized	2026-08-28 08:30:48.980996
76807	1917	breakin	608	Break In	27-08-2026 15:14:26	113871	0.85	normal	2026-08-28 08:30:52.603252	STF-035	Hammad Shaukat	0.4935	recognized	2026-08-28 08:30:52.638159
76963	1917	breakin	674	Break In	27-08-2026 15:40:35	152663	0.85	unrecognized	2026-08-28 08:37:53.535508	\N	Person #674	0	unrecognized	2026-08-28 08:38:39.300548
77179	1917	breakin	782	Break In	27-08-2026 16:06:28	191683	0.85	normal	2026-08-28 08:51:43.106271	STF-037	Muhammad Fahad	0.4937	recognized	2026-08-28 08:51:45.496421
78045	1918	breakout	77	Break Out	27-08-2026 11:12:10	103192	0.85	unrecognized	2026-08-28 10:04:48.587236	\N	Person #77	0	unrecognized	2026-08-28 10:04:48.887004
78046	1918	breakout	77	Break Out	27-08-2026 11:12:26	103545	0.85	unrecognized	2026-08-28 10:04:49.252909	\N	Person #77	0	unrecognized	2026-08-28 10:04:49.830482
78994	1918	breakout	358	Break Out	27-08-2026 13:33:59	315938	0.85	normal	2026-08-28 10:55:36.743035	STF-011	Syed Shoaib Ahmad Alvi	0.4444	recognized	2026-08-28 10:55:39.92759
78047	1918	breakout	77	Break Out	27-08-2026 11:12:48	104043	0.85	unrecognized	2026-08-28 10:04:50.244709	\N	Person #77	0	unrecognized	2026-08-28 10:04:57.673608
77398	1917	breakin	793	Break In	27-08-2026 21:33:23	325005	0.85	unrecognized	2026-08-28 09:06:13.280177	\N	Person #793	0	unrecognized	2026-08-28 09:06:23.807908
76956	1917	breakin	675	Break In	27-08-2026 15:39:36	151610	0.85	normal	2026-08-28 08:37:40.961974	STF-045	Zohaib Ali Chaudhary	0.552	recognized	2026-08-28 08:37:40.978928
77266	1917	breakin	835	Break In	27-08-2026 16:11:19	199139	0.85	normal	2026-08-28 08:57:40.936382	STF-052	Syed Imran Shah	0.6631	recognized	2026-08-28 08:57:48.140121
78387	1918	breakout	182	Break Out	27-08-2026 12:02:15	178356	0.85	unrecognized	2026-08-28 10:23:54.301123	\N	Person #182	0	unrecognized	2026-08-28 10:23:54.334034
77174	1917	breakin	782	Break In	27-08-2026 16:05:52	190948	0.85	normal	2026-08-28 08:51:40.573398	STF-037	Muhammad Fahad	0.578	recognized	2026-08-28 08:51:41.397127
78051	1918	breakout	79	Break Out	27-08-2026 11:13:44	105455	0.85	unrecognized	2026-08-28 10:04:58.7518	\N	Person #79	0	unrecognized	2026-08-28 10:05:14.408048
76961	1917	breakin	674	Break In	27-08-2026 15:40:07	152396	0.85	unrecognized	2026-08-28 08:37:52.489338	\N	Person #674	0	unrecognized	2026-08-28 08:37:52.508793
76962	1917	breakin	674	Break In	27-08-2026 15:40:14	152513	0.85	unrecognized	2026-08-28 08:37:52.770715	\N	Person #674	0	unrecognized	2026-08-28 08:37:53.274536
78738	1918	breakout	300	Break Out	27-08-2026 16:10:11	194233	0.85	normal	2026-08-28 10:43:14.268411	STF-024	Arsalan Khan	0.4458	recognized	2026-08-28 10:43:15.653431
78393	1918	breakout	183	Break Out	27-08-2026 12:02:57	178829	0.85	unrecognized	2026-08-28 10:24:22.695419	\N	Person #183	0	unrecognized	2026-08-28 10:24:38.148889
78054	1918	breakout	79	Break Out	27-08-2026 11:14:52	107185	0.85	unrecognized	2026-08-28 10:05:15.268008	\N	Person #79	0	unrecognized	2026-08-28 10:05:29.293266
78388	1918	breakout	182	Break Out	27-08-2026 12:02:33	178570	0.85	unrecognized	2026-08-28 10:23:54.631152	\N	Person #182	0	unrecognized	2026-08-28 10:24:21.972895
78728	1918	breakout	299	Break Out	27-08-2026 16:08:51	192269	0.85	normal	2026-08-28 10:42:40.374691	STF-005	Muhammad Ayaz Hussain	0.4475	recognized	2026-08-28 10:42:40.714028
79004	1918	breakout	359	Break Out	27-08-2026 13:34:50	317146	0.85	normal	2026-08-28 10:56:15.552475	STF-026	Syed Zeeshan Ali	0.4823	recognized	2026-08-28 10:56:19.458791
77322	1917	breakin	864	Break In	27-08-2026 16:14:12	203521	0.85	normal	2026-08-28 09:02:58.126491	STF-028	Noman Imran	0.4654	recognized	2026-08-28 09:02:58.382342
77180	1917	breakin	787	Break In	27-08-2026 16:06:31	191949	0.85	normal	2026-08-28 08:51:45.811046	STF-052	Syed Imran Shah	0.5235	recognized	2026-08-28 08:51:49.221466
79148	1918	breakout	460	Break Out	27-08-2026 21:17:15	297878	0.85	normal	2026-08-28 11:04:01.986476	STF-045	Zohaib Ali Chaudhary	0.4797	recognized	2026-08-28 11:04:04.919844
77328	1917	breakin	869	Break In	27-08-2026 16:15:25	205279	0.85	normal	2026-08-28 09:03:10.815889	STF-037	Muhammad Fahad	0.4758	recognized	2026-08-28 09:03:15.715014
77394	1917	breakin	793	Break In	27-08-2026 21:32:25	323449	0.85	unrecognized	2026-08-28 09:05:45.991554	\N	Person #793	0	unrecognized	2026-08-28 09:06:12.53239
77326	1917	breakin	865	Break In	27-08-2026 16:14:48	204419	0.85	pending	2026-08-28 09:03:08.390454	\N	Person #865	\N	pending	\N
79137	1918	breakout	412	Break Out	27-08-2026 13:51:54	342716	0.85	unrecognized	2026-08-28 11:03:34.711983	\N	Person #412	0	unrecognized	2026-08-28 11:03:46.178376
78068	1918	breakout	115	Break Out	27-08-2026 18:54:38	83807	0.85	unrecognized	2026-08-28 10:05:55.36463	\N	Person #115	0	unrecognized	2026-08-28 10:06:14.539042
77175	1917	breakin	695	Break In	27-08-2026 21:08:12	287195	0.85	unrecognized	2026-08-28 08:51:40.603827	\N	Person #695	0	unrecognized	2026-08-28 08:51:51.530324
78399	1918	breakout	218	Break Out	27-08-2026 19:44:23	158468	0.85	unrecognized	2026-08-28 10:24:46.593503	\N	Person #218	0	unrecognized	2026-08-28 10:25:02.313574
78403	1918	breakout	219	Break Out	27-08-2026 19:44:47	159193	0.85	pending	2026-08-28 10:25:03.096489	\N	Person #219	0	unrecognized	\N
78059	1918	breakout	112	Break Out	27-08-2026 18:53:58	82860	0.85	unrecognized	2026-08-28 10:05:29.493991	\N	Person #112	0	unrecognized	2026-08-28 10:05:39.033125
77264	1917	breakin	744	Break In	27-08-2026 21:17:50	301153	0.85	unrecognized	2026-08-28 08:57:28.035412	\N	Person #744	0	unrecognized	2026-08-28 08:59:38.216466
78406	1918	breakout	221	Break Out	27-08-2026 19:45:22	159942	0.85	unrecognized	2026-08-28 10:25:08.509028	\N	Person #221	0	unrecognized	2026-08-28 10:25:29.073818
76814	1917	breakin	613	Break In	27-08-2026 13:53:56	350247	0.85	normal	2026-08-28 08:31:11.497541	STF-033	Raza Abbas	0.4596	recognized	2026-08-28 08:31:27.23979
77330	1917	breakin	772	Break In	27-08-2026 21:29:37	319338	0.85	unrecognized	2026-08-28 09:03:16.079747	\N	Person #772	0	unrecognized	2026-08-28 09:03:23.685216
78065	1918	breakout	113	Break Out	27-08-2026 18:54:14	83246	0.85	unrecognized	2026-08-28 10:05:39.590772	\N	Person #113	0	unrecognized	2026-08-28 10:05:46.952271
78077	1918	breakout	118	Break Out	27-08-2026 18:55:17	84933	0.85	normal	2026-08-28 10:06:26.808872	STF-032	Muhammad Yaseen	0.4809	recognized	2026-08-28 10:06:27.719426
78067	1918	breakout	114	Break Out	27-08-2026 18:54:24	83529	0.85	unrecognized	2026-08-28 10:05:47.83781	\N	Person #114	0	unrecognized	2026-08-28 10:05:54.803059
78733	1918	breakout	274	Break Out	27-08-2026 12:52:28	253669	0.85	normal	2026-08-28 10:43:04.332228	STF-024	Arsalan Khan	0.4922	recognized	2026-08-28 10:43:05.124807
77079	1917	breakin	644	Break In	27-08-2026 20:57:17	270949	0.85	normal	2026-08-28 08:45:54.515398	STF-033	Raza Abbas	0.6185	recognized	2026-08-28 08:45:54.53432
78735	1918	breakout	275	Break Out	27-08-2026 12:49:40	253791	0.85	pending	2026-08-28 10:43:09.739715	\N	Person #275	0	unrecognized	\N
76967	1917	breakin	576	Break In	27-08-2026 20:45:04	252598	0.85	normal	2026-08-28 08:38:46.214535	STF-032	Muhammad Yaseen	0.4415	recognized	2026-08-28 08:38:47.355006
77081	1917	breakin	646	Break In	27-08-2026 20:57:25	271090	0.85	normal	2026-08-28 08:46:02.730469	STF-034	Muhammad Laeeq	0.555	recognized	2026-08-28 08:46:06.327864
78997	1918	breakout	412	Break Out	27-08-2026 21:04:51	279163	0.85	unrecognized	2026-08-28 10:55:47.026209	\N	Person #412	0	unrecognized	2026-08-28 10:56:07.367718
77182	1917	breakin	695	Break In	27-08-2026 21:09:13	288798	0.85	normal	2026-08-28 08:51:52.415273	STF-028	Noman Imran	0.4857	recognized	2026-08-28 08:51:54.723076
78995	1918	breakout	410	Break Out	27-08-2026 21:03:17	276842	0.85	normal	2026-08-28 10:55:38.371345	STF-029	Abdul Rehman Sultan	0.4411	recognized	2026-08-28 10:55:43.472369
77184	1917	breakin	696	Break In	27-08-2026 21:09:32	289148	0.85	normal	2026-08-28 08:51:57.266113	STF-013	Muhammad Faizan	0.5178	recognized	2026-08-28 08:52:21.445967
77396	1917	breakin	899	Break In	27-08-2026 16:27:39	223693	0.85	normal	2026-08-28 09:05:59.132467	STF-047	Arshad Irshad	0.4703	recognized	2026-08-28 09:05:59.818308
77429	1917	breakin	806	Break In	27-08-2026 21:54:03	356059	0.85	normal	2026-08-28 09:08:39.36317	STF-028	Noman Imran	0.5638	recognized	2026-08-28 09:08:41.756679
77423	1917	breakin	803	Break In	27-08-2026 21:45:18	342951	0.85	normal	2026-08-28 09:08:26.097689	STF-020	Syed Jahazaib Ahmad Alvi	0.4972	recognized	2026-08-28 09:08:26.114644
77427	1917	breakin	805	Break In	27-08-2026 21:47:54	346843	0.85	normal	2026-08-28 09:08:32.121611	STF-036	Shahzad Ali	0.5627	recognized	2026-08-28 09:08:33.582301
77428	1917	breakin	805	Break In	27-08-2026 21:51:05	351650	0.85	pending	2026-08-28 09:08:37.521977	\N	Person #805	\N	pending	\N
77432	1917	breakin	810	Break In	27-08-2026 21:54:39	356963	0.85	normal	2026-08-28 09:08:47.26582	STF-034	Muhammad Laeeq	0.4435	recognized	2026-08-28 09:08:48.210154
77439	1917	breakin	813	Break In	27-08-2026 21:54:50	357232	0.85	normal	2026-08-28 09:09:11.879188	STF-028	Noman Imran	0.4654	recognized	2026-08-28 09:09:13.046075
77458	1917	breakin	937	Break In	27-08-2026 16:33:27	232400	0.85	normal	2026-08-28 09:10:23.461586	STF-047	Arshad Irshad	0.5176	recognized	2026-08-28 09:10:23.474551
79003	1918	breakout	373	Break Out	27-08-2026 16:48:13	251280	0.85	normal	2026-08-28 10:56:12.904944	STF-049	Nabi Ul Haq	0.4664	recognized	2026-08-28 10:56:17.460176
78071	1918	breakout	84	Break Out	27-08-2026 11:17:28	111060	0.85	unrecognized	2026-08-28 10:06:13.327337	\N	Person #84	0	unrecognized	2026-08-28 10:06:28.008108
78064	1918	breakout	80	Break Out	27-08-2026 11:16:10	109135	0.85	normal	2026-08-28 10:05:35.067554	STF-008	Muhammad Shoaib	0.5221	recognized	2026-08-28 10:05:38.87744
79255	1918	breakout	455	Break Out	27-08-2026 17:35:48	322601	0.85	unrecognized	2026-08-28 11:10:32.943912	\N	Person #455	0	unrecognized	2026-08-28 11:10:43.791663
78745	1918	breakout	280	Break Out	27-08-2026 12:53:20	254939	0.85	normal	2026-08-28 10:43:36.136436	STF-028	Noman Imran	0.4442	recognized	2026-08-28 10:43:37.624943
78749	1918	breakout	281	Break Out	27-08-2026 12:54:26	256524	0.85	unrecognized	2026-08-28 10:43:40.29357	\N	Person #281	0	unrecognized	2026-08-28 10:43:53.103068
76970	1917	breakin	678	Break In	27-08-2026 15:41:08	153207	0.85	unrecognized	2026-08-28 08:38:52.52997	\N	Person #678	0	unrecognized	2026-08-28 08:39:41.025987
76819	1917	breakin	520	Break In	27-08-2026 20:26:09	224220	0.85	normal	2026-08-28 08:31:20.254978	STF-026	Syed Zeeshan Ali	0.4717	recognized	2026-08-28 08:31:24.043151
76811	1917	breakin	613	Break In	27-08-2026 15:15:06	114841	0.85	normal	2026-08-28 08:31:00.087201	STF-035	Hammad Shaukat	0.4837	recognized	2026-08-28 08:31:01.105453
79005	1918	breakout	374	Break Out	27-08-2026 16:49:02	252500	0.85	unrecognized	2026-08-28 10:56:20.358894	\N	Person #374	0	unrecognized	2026-08-28 10:56:22.762536
77188	1917	breakin	696	Break In	27-08-2026 21:10:19	290357	0.85	normal	2026-08-28 08:52:22.469144	STF-013	Muhammad Faizan	0.5919	recognized	2026-08-28 08:52:36.776486
76817	1917	breakin	619	Break In	27-08-2026 15:15:56	116118	0.85	normal	2026-08-28 08:31:17.072075	STF-034	Muhammad Laeeq	0.4909	recognized	2026-08-28 08:31:17.105984
76968	1917	breakin	677	Break In	27-08-2026 15:40:45	153128	0.85	unrecognized	2026-08-28 08:38:46.390297	\N	Person #677	0	unrecognized	2026-08-28 08:39:17.968862
78760	1918	breakout	283	Break Out	27-08-2026 12:57:58	261744	0.85	unrecognized	2026-08-28 10:44:10.51603	\N	Person #283	0	unrecognized	2026-08-28 10:44:35.701079
76818	1917	breakin	620	Break In	27-08-2026 15:16:01	116233	0.85	normal	2026-08-28 08:31:18.260782	STF-035	Hammad Shaukat	0.5941	recognized	2026-08-28 08:31:18.924937
78755	1918	breakout	281	Break Out	27-08-2026 12:54:55	257244	0.85	unrecognized	2026-08-28 10:43:53.619653	\N	Person #281	0	unrecognized	2026-08-28 10:44:08.129189
78996	1918	breakout	370	Break Out	27-08-2026 16:47:11	249720	0.85	normal	2026-08-28 10:55:39.659428	STF-044	Zaheer Hussain	0.4526	recognized	2026-08-28 10:55:46.380639
76829	1917	breakin	627	Break In	27-08-2026 15:16:53	117534	0.85	normal	2026-08-28 08:31:59.414389	STF-036	Shahzad Ali	0.4857	recognized	2026-08-28 08:32:01.18689
78407	1918	breakout	209	Break Out	27-08-2026 15:13:17	108842	0.85	unrecognized	2026-08-28 10:25:15.005821	\N	Person #209	0	unrecognized	2026-08-28 10:25:30.486708
76833	1917	breakin	629	Break In	27-08-2026 15:17:01	117732	0.85	normal	2026-08-28 08:32:07.926216	STF-034	Muhammad Laeeq	0.5958	recognized	2026-08-28 08:32:07.985059
76841	1917	breakin	532	Break In	27-08-2026 20:26:51	225164	0.85	unrecognized	2026-08-28 08:32:19.761921	\N	Person #532	0	unrecognized	2026-08-28 08:32:29.159502
79009	1918	breakout	376	Break Out	27-08-2026 16:50:51	255183	0.85	unrecognized	2026-08-28 10:56:30.415541	\N	Person #376	0	unrecognized	2026-08-28 10:56:38.111871
79008	1918	breakout	375	Break Out	27-08-2026 16:50:30	254569	0.85	unrecognized	2026-08-28 10:56:24.080713	\N	Person #375	0	unrecognized	2026-08-28 10:56:29.656666
79161	1918	breakout	425	Break Out	27-08-2026 17:12:03	287040	0.85	normal	2026-08-28 11:04:27.564408	STF-002	Abdur Rehman	0.4596	recognized	2026-08-28 11:04:30.466381
79143	1918	breakout	420	Break Out	27-08-2026 17:08:18	281351	0.85	unrecognized	2026-08-28 11:03:52.218017	\N	Person #420	0	unrecognized	2026-08-28 11:04:03.794195
79149	1918	breakout	423	Break Out	27-08-2026 17:08:35	281898	0.85	pending	2026-08-28 11:04:04.87995	\N	Person #423	0	unrecognized	\N
79259	1918	breakout	456	Break Out	27-08-2026 17:36:36	323789	0.85	unrecognized	2026-08-28 11:10:44.532943	\N	Person #456	0	unrecognized	2026-08-28 11:10:55.747762
76845	1917	breakin	531	Break In	27-08-2026 20:26:57	225433	0.85	unrecognized	2026-08-28 08:32:30.473234	\N	Person #531	0	unrecognized	2026-08-28 08:32:30.49221
79152	1918	breakout	424	Break Out	27-08-2026 17:10:24	284506	0.85	unrecognized	2026-08-28 11:04:09.463712	\N	Person #424	0	unrecognized	2026-08-28 11:04:26.296951
76830	1917	breakin	618	Break In	27-08-2026 13:54:15	350730	0.85	normal	2026-08-28 08:32:00.434318	STF-002	Abdur Rehman	0.5333	recognized	2026-08-28 08:32:18.126117
76840	1917	breakin	633	Break In	27-08-2026 15:17:34	118557	0.85	normal	2026-08-28 08:32:19.343919	STF-036	Shahzad Ali	0.5039	recognized	2026-08-28 08:32:19.658198
76838	1917	breakin	632	Break In	27-08-2026 15:17:31	118495	0.85	normal	2026-08-28 08:32:18.307411	STF-035	Hammad Shaukat	0.4672	recognized	2026-08-28 08:32:18.328783
79265	1918	breakout	458	Break Out	27-08-2026 17:38:45	327018	0.85	unrecognized	2026-08-28 11:11:15.243614	\N	Person #458	0	unrecognized	2026-08-28 11:11:26.877568
79262	1918	breakout	457	Break Out	27-08-2026 17:37:27	324997	0.85	unrecognized	2026-08-28 11:10:56.465372	\N	Person #457	0	unrecognized	2026-08-28 11:11:14.249845
76842	1917	breakin	634	Break In	27-08-2026 15:17:35	118596	0.85	normal	2026-08-28 08:32:20.942595	STF-034	Muhammad Laeeq	0.5827	recognized	2026-08-28 08:32:20.991464
79268	1918	breakout	458	Break Out	27-08-2026 17:40:00	328995	0.85	unrecognized	2026-08-28 11:11:27.677802	\N	Person #458	0	unrecognized	2026-08-28 11:11:28.134493
79270	1918	breakout	459	Break Out	27-08-2026 17:40:33	329814	0.85	unrecognized	2026-08-28 11:11:28.928911	\N	Person #459	0	unrecognized	2026-08-28 11:11:29.362158
79269	1918	breakout	459	Break Out	27-08-2026 17:40:21	329540	0.85	pending	2026-08-28 11:11:28.679745	\N	Person #459	\N	pending	\N
78761	1918	breakout	307	Break Out	27-08-2026 16:12:00	196884	0.85	unrecognized	2026-08-28 10:44:14.721018	\N	Person #307	0	unrecognized	2026-08-28 10:44:29.508407
78398	1918	breakout	184	Break Out	27-08-2026 12:03:11	179603	0.85	unrecognized	2026-08-28 10:24:38.782936	\N	Person #184	0	unrecognized	2026-08-28 10:24:52.490651
79448	1950	breakin	83	Break In	25-08-2026 19:04:25	14187	0.85	normal	2026-08-28 14:32:39.330934	STF-031	Muhammad Hassan	0.5554	recognized	2026-08-28 14:32:39.349993
77098	1917	breakin	652	Break In	27-08-2026 20:58:00	272901	0.85	unrecognized	2026-08-28 08:46:52.893891	\N	Person #652	0	unrecognized	2026-08-28 08:47:24.784121
76974	1917	breakin	582	Break In	27-08-2026 20:46:51	255290	0.85	normal	2026-08-28 08:39:22.167654	STF-037	Muhammad Fahad	0.4702	recognized	2026-08-28 08:39:23.293107
76851	1917	breakin	532	Break In	27-08-2026 20:29:16	228813	0.85	unrecognized	2026-08-28 08:32:41.706376	\N	Person #532	0	unrecognized	2026-08-28 08:32:55.925217
76855	1917	breakin	533	Break In	27-08-2026 20:31:16	231838	0.85	unrecognized	2026-08-28 08:32:57.405838	\N	Person #533	0	unrecognized	2026-08-28 08:33:10.021113
78072	1918	breakout	108	Break Out	27-08-2026 14:37:50	55681	0.85	unrecognized	2026-08-28 10:06:14.735463	\N	Person #108	0	unrecognized	2026-08-28 10:06:15.504097
78400	1918	breakout	184	Break Out	27-08-2026 12:03:30	180221	0.85	unrecognized	2026-08-28 10:24:52.899723	\N	Person #184	0	unrecognized	2026-08-28 10:24:52.92366
78401	1918	breakout	185	Break Out	27-08-2026 12:03:58	180826	0.85	unrecognized	2026-08-28 10:24:53.928875	\N	Person #185	0	unrecognized	2026-08-28 10:25:04.339303
78062	1918	breakout	106	Break Out	27-08-2026 14:36:27	53638	0.85	normal	2026-08-28 10:05:31.883031	STF-033	Raza Abbas	0.479	recognized	2026-08-28 10:05:38.919328
78408	1918	breakout	186	Break Out	27-08-2026 12:04:29	181610	0.85	normal	2026-08-28 10:25:20.002581	STF-029	Abdul Rehman Sultan	0.4698	recognized	2026-08-28 10:25:25.687323
78074	1918	breakout	109	Break Out	27-08-2026 14:38:27	56643	0.85	normal	2026-08-28 10:06:16.229319	STF-029	Abdul Rehman Sultan	0.475	recognized	2026-08-28 10:06:18.242434
76857	1917	breakin	533	Break In	27-08-2026 20:32:01	233010	0.85	normal	2026-08-28 08:33:10.666074	STF-050	Hafeez-Ur-Rehman	0.4806	recognized	2026-08-28 08:33:14.939074
77100	1917	breakin	653	Break In	27-08-2026 20:58:42	272985	0.85	unrecognized	2026-08-28 08:46:54.021722	\N	Person #653	0	unrecognized	2026-08-28 08:47:08.594043
76861	1917	breakin	533	Break In	27-08-2026 20:34:02	236064	0.85	normal	2026-08-28 08:33:18.941497	STF-026	Syed Zeeshan Ali	0.4816	recognized	2026-08-28 08:33:19.562318
77092	1917	breakin	652	Break In	27-08-2026 20:58:10	272104	0.85	unrecognized	2026-08-28 08:46:36.692196	\N	Person #652	0	unrecognized	2026-08-28 08:46:51.816397
77095	1917	breakin	652	Break In	27-08-2026 20:58:18	272464	0.85	pending	2026-08-28 08:46:52.113844	\N	Person #652	\N	pending	\N
77096	1917	breakin	652	Break In	27-08-2026 20:58:24	272581	0.85	unrecognized	2026-08-28 08:46:52.252241	\N	Person #652	0	unrecognized	2026-08-28 08:46:52.458464
76980	1917	breakin	587	Break In	27-08-2026 20:48:17	257332	0.85	unrecognized	2026-08-28 08:39:48.380304	\N	Person #587	0	unrecognized	2026-08-28 08:40:05.092865
78070	1918	breakout	107	Break Out	27-08-2026 14:37:18	54874	0.85	unrecognized	2026-08-28 10:06:04.508841	\N	Person #107	0	unrecognized	2026-08-28 10:06:13.770435
77197	1917	breakin	798	Break In	27-08-2026 16:08:17	194634	0.85	normal	2026-08-28 08:52:40.018545	STF-037	Muhammad Fahad	0.5205	recognized	2026-08-28 08:52:40.498786
76986	1917	breakin	590	Break In	27-08-2026 20:49:06	258560	0.85	unrecognized	2026-08-28 08:40:16.781822	\N	Person #590	0	unrecognized	2026-08-28 08:40:26.859923
78758	1918	breakout	301	Break Out	27-08-2026 16:11:00	196445	0.85	unrecognized	2026-08-28 10:44:00.440232	\N	Person #301	0	unrecognized	2026-08-28 10:44:13.983794
77199	1917	breakin	801	Break In	27-08-2026 16:08:28	194887	0.85	normal	2026-08-28 08:52:41.879471	STF-028	Noman Imran	0.4791	recognized	2026-08-28 08:52:43.873552
77191	1917	breakin	794	Break In	27-08-2026 16:07:24	193291	0.85	normal	2026-08-28 08:52:25.739136	STF-026	Syed Zeeshan Ali	0.5352	recognized	2026-08-28 08:52:31.107598
78757	1918	breakout	301	Break Out	27-08-2026 16:10:44	195106	0.85	pending	2026-08-28 10:43:59.473917	\N	Person #301	\N	pending	\N
77274	1917	breakin	839	Break In	27-08-2026 16:12:00	200214	0.85	normal	2026-08-28 08:58:43.728196	STF-028	Noman Imran	0.4939	recognized	2026-08-28 08:58:43.747146
79024	1918	breakout	420	Break Out	27-08-2026 21:05:55	280839	0.85	normal	2026-08-28 10:57:23.732891	STF-013	Muhammad Faizan	0.4823	recognized	2026-08-28 10:57:26.340568
77275	1917	breakin	840	Break In	27-08-2026 16:12:16	200611	0.85	normal	2026-08-28 08:59:09.500273	STF-037	Muhammad Fahad	0.5398	recognized	2026-08-28 08:59:09.520218
77331	1917	breakin	773	Break In	27-08-2026 21:29:48	319625	0.85	unrecognized	2026-08-28 09:03:24.206178	\N	Person #773	0	unrecognized	2026-08-28 09:03:34.35137
79146	1918	breakout	417	Break Out	27-08-2026 13:52:35	343833	0.85	normal	2026-08-28 11:03:55.835343	STF-023	Syed Zubair Zulfiqar	0.4476	recognized	2026-08-28 11:03:58.4688
77359	1917	breakin	781	Break In	27-08-2026 21:30:27	320682	0.85	normal	2026-08-28 09:04:20.897911	STF-037	Muhammad Fahad	0.7109	recognized	2026-08-28 09:04:20.921846
76976	1917	breakin	678	Break In	27-08-2026 15:41:23	154279	0.85	pending	2026-08-28 08:39:41.355376	\N	Person #678	\N	pending	\N
78759	1918	breakout	333	Break Out	27-08-2026 20:38:34	239830	0.85	unrecognized	2026-08-28 10:44:02.758553	\N	Person #333	0	unrecognized	2026-08-28 10:44:18.689944
78423	1918	breakout	189	Break Out	27-08-2026 12:07:19	185831	0.85	unrecognized	2026-08-28 10:26:03.958961	\N	Person #189	0	unrecognized	2026-08-28 10:26:18.174363
77099	1917	breakin	745	Break In	27-08-2026 15:59:31	181491	0.85	normal	2026-08-28 08:46:53.729003	STF-037	Muhammad Fahad	0.5978	recognized	2026-08-28 08:46:53.768896
78093	1918	breakout	94	Break Out	27-08-2026 11:20:23	115514	0.85	normal	2026-08-28 10:07:13.838671	STF-010	Faraz Younas	0.4499	recognized	2026-08-28 10:07:31.502352
78419	1918	breakout	189	Break Out	27-08-2026 12:06:38	184814	0.85	unrecognized	2026-08-28 10:25:49.634423	\N	Person #189	0	unrecognized	2026-08-28 10:26:03.336722
77089	1917	breakin	740	Break In	27-08-2026 15:59:08	180888	0.85	normal	2026-08-28 08:46:23.595328	STF-002	Abdur Rehman	0.5317	recognized	2026-08-28 08:46:34.153775
78754	1918	breakout	331	Break Out	27-08-2026 20:38:26	239582	0.85	unrecognized	2026-08-28 10:43:50.871002	\N	Person #331	0	unrecognized	2026-08-28 10:43:54.626507
77088	1917	breakin	739	Break In	27-08-2026 15:59:10	180886	0.85	normal	2026-08-28 08:46:22.99109	STF-030	Dildar Ahmed	0.4502	recognized	2026-08-28 08:46:41.030159
78083	1918	breakout	86	Break Out	27-08-2026 11:18:57	113350	0.85	normal	2026-08-28 10:06:47.483218	STF-010	Faraz Younas	0.5043	recognized	2026-08-28 10:06:53.261206
78078	1918	breakout	85	Break Out	27-08-2026 11:18:21	112338	0.85	unrecognized	2026-08-28 10:06:28.819314	\N	Person #85	0	unrecognized	2026-08-28 10:06:46.666626
76977	1917	breakin	678	Break In	27-08-2026 15:41:39	154389	0.85	unrecognized	2026-08-28 08:39:41.440149	\N	Person #678	0	unrecognized	2026-08-28 08:39:52.833187
78751	1918	breakout	329	Break Out	27-08-2026 20:38:18	239411	0.85	unrecognized	2026-08-28 10:43:46.3718	\N	Person #329	0	unrecognized	2026-08-28 10:43:47.538329
78416	1918	breakout	188	Break Out	27-08-2026 12:04:53	182246	0.85	normal	2026-08-28 10:25:42.998638	STF-002	Abdur Rehman	0.4945	recognized	2026-08-28 10:25:46.018903
76853	1917	breakin	628	Break In	27-08-2026 13:54:55	351695	0.85	unrecognized	2026-08-28 08:32:47.095873	\N	Person #628	0	unrecognized	2026-08-28 08:33:02.724138
78090	1918	breakout	90	Break Out	27-08-2026 11:19:44	114555	0.85	normal	2026-08-28 10:07:04.814979	STF-037	Muhammad Fahad	0.4629	recognized	2026-08-28 10:07:06.011404
76982	1917	breakin	680	Break In	27-08-2026 15:41:56	154836	0.85	unrecognized	2026-08-28 08:39:53.379544	\N	Person #680	0	unrecognized	2026-08-28 08:40:11.978455
78091	1918	breakout	92	Break Out	27-08-2026 11:17:03	115268	0.85	pending	2026-08-28 10:07:08.849486	\N	Person #92	0	unrecognized	\N
78427	1918	breakout	190	Break Out	27-08-2026 12:08:12	187115	0.85	unrecognized	2026-08-28 10:26:19.192135	\N	Person #190	0	unrecognized	2026-08-28 10:26:33.509173
78092	1918	breakout	93	Break Out	27-08-2026 11:20:22	115474	0.85	normal	2026-08-28 10:07:11.79881	STF-008	Muhammad Shoaib	0.4409	recognized	2026-08-28 10:07:16.812585
76856	1917	breakin	629	Break In	27-08-2026 13:55:43	352508	0.85	normal	2026-08-28 08:33:04.18714	STF-033	Raza Abbas	0.4417	recognized	2026-08-28 08:33:19.382394
78764	1918	breakout	335	Break Out	27-08-2026 20:39:07	240595	0.85	unrecognized	2026-08-28 10:44:25.662149	\N	Person #335	0	unrecognized	2026-08-28 10:44:33.666796
77102	1917	breakin	749	Break In	27-08-2026 15:59:52	182006	0.85	normal	2026-08-28 08:47:05.272452	STF-030	Dildar Ahmed	0.5265	recognized	2026-08-28 08:47:05.290404
78762	1918	breakout	333	Break Out	27-08-2026 20:39:00	240454	0.85	unrecognized	2026-08-28 10:44:19.19896	\N	Person #333	0	unrecognized	2026-08-28 10:44:24.597211
77209	1917	breakin	701	Break In	27-08-2026 21:11:18	291952	0.85	unrecognized	2026-08-28 08:53:08.757122	\N	Person #701	0	unrecognized	2026-08-28 08:53:08.79901
77210	1917	breakin	703	Break In	27-08-2026 21:11:25	292011	0.85	unrecognized	2026-08-28 08:53:11.069262	\N	Person #703	0	unrecognized	2026-08-28 08:53:42.990219
77206	1917	breakin	700	Break In	27-08-2026 21:11:46	291762	0.85	unrecognized	2026-08-28 08:52:50.774688	\N	Person #700	0	unrecognized	2026-08-28 08:54:35.69757
79019	1918	breakout	363	Break Out	27-08-2026 13:38:39	322892	0.85	normal	2026-08-28 10:57:10.578554	STF-023	Syed Zubair Zulfiqar	0.4506	recognized	2026-08-28 10:57:28.796271
77334	1917	breakin	877	Break In	27-08-2026 16:16:17	206635	0.85	normal	2026-08-28 09:03:31.169414	STF-037	Muhammad Fahad	0.5522	recognized	2026-08-28 09:03:31.185366
79016	1918	breakout	362	Break Out	27-08-2026 13:35:35	318243	0.85	unrecognized	2026-08-28 10:56:51.9876	\N	Person #362	0	unrecognized	2026-08-28 10:57:08.517906
77343	1917	breakin	879	Break In	27-08-2026 16:17:18	208160	0.85	normal	2026-08-28 09:03:56.394325	STF-013	Muhammad Faizan	0.5311	recognized	2026-08-28 09:03:56.430997
77355	1917	breakin	878	Break In	27-08-2026 16:18:36	210119	0.85	pending	2026-08-28 09:04:15.245125	\N	Person #878	\N	pending	\N
76849	1917	breakin	636	Break In	27-08-2026 15:18:06	119359	0.85	normal	2026-08-28 08:32:40.438892	STF-034	Muhammad Laeeq	0.5991	recognized	2026-08-28 08:32:40.456847
78096	1918	breakout	126	Break Out	27-08-2026 18:57:19	87977	0.85	normal	2026-08-28 10:07:19.397238	STF-017	Mohammad Zahid	0.4488	recognized	2026-08-28 10:07:19.413196
76879	1917	breakin	653	Break In	27-08-2026 15:21:34	124336	0.85	unrecognized	2026-08-28 08:34:06.565486	\N	Person #653	0	unrecognized	2026-08-28 08:34:22.618746
78430	1918	breakout	229	Break Out	27-08-2026 19:47:56	163875	0.85	normal	2026-08-28 10:26:27.974317	STF-047	Arshad Irshad	0.4428	recognized	2026-08-28 10:26:28.59245
77105	1917	breakin	750	Break In	27-08-2026 16:00:23	182799	0.85	normal	2026-08-28 08:47:24.377128	STF-030	Dildar Ahmed	0.7143	recognized	2026-08-28 08:47:24.392088
76865	1917	breakin	535	Break In	27-08-2026 20:35:31	238268	0.85	normal	2026-08-28 08:33:23.925091	STF-023	Syed Zubair Zulfiqar	0.5907	recognized	2026-08-28 08:33:24.446233
78086	1918	breakout	123	Break Out	27-08-2026 18:56:30	86661	0.85	unrecognized	2026-08-28 10:06:53.414197	\N	Person #123	0	unrecognized	2026-08-28 10:07:03.486956
76858	1917	breakin	641	Break In	27-08-2026 15:19:04	120805	0.85	normal	2026-08-28 08:33:14.687435	STF-034	Muhammad Laeeq	0.7106	recognized	2026-08-28 08:33:14.740293
78089	1918	breakout	124	Break Out	27-08-2026 18:56:37	86832	0.85	unrecognized	2026-08-28 10:07:03.981218	\N	Person #124	0	unrecognized	2026-08-28 10:07:16.197228
76863	1917	breakin	631	Break In	27-08-2026 13:56:20	353794	0.85	unrecognized	2026-08-28 08:33:21.373747	\N	Person #631	0	unrecognized	2026-08-28 08:33:35.284446
78420	1918	breakout	227	Break Out	27-08-2026 19:46:21	161467	0.85	normal	2026-08-28 10:25:57.303312	STF-049	Nabi Ul Haq	0.554	recognized	2026-08-28 10:26:04.152443
78411	1918	breakout	223	Break Out	27-08-2026 19:45:44	160583	0.85	unrecognized	2026-08-28 10:25:30.299746	\N	Person #223	0	unrecognized	2026-08-28 10:25:30.882668
76866	1917	breakin	536	Break In	27-08-2026 20:35:36	238372	0.85	normal	2026-08-28 08:33:26.51931	STF-007	Faisal Saleem	0.4618	recognized	2026-08-28 08:33:31.733877
78082	1918	breakout	122	Break Out	27-08-2026 18:55:59	85884	0.85	unrecognized	2026-08-28 10:06:38.976432	\N	Person #122	0	unrecognized	2026-08-28 10:06:47.081322
76997	1917	breakin	689	Break In	27-08-2026 15:46:12	161476	0.85	normal	2026-08-28 08:41:09.455862	STF-033	Raza Abbas	0.4801	recognized	2026-08-28 08:41:11.619275
79456	1951	breakout	88	Break Out	25-08-2026 18:58:53	5703	0.85	unrecognized	2026-08-28 14:33:09.545225	\N	Person #88	0	unrecognized	2026-08-28 14:33:09.975295
76883	1917	breakin	542	Break In	27-08-2026 20:37:11	240779	0.85	normal	2026-08-28 08:34:13.30872	STF-008	Muhammad Shoaib	0.599	recognized	2026-08-28 08:34:13.334159
78094	1918	breakout	125	Break Out	27-08-2026 18:57:17	87904	0.85	normal	2026-08-28 10:07:16.976654	STF-001	Ikram Hassan	0.4569	recognized	2026-08-28 10:07:18.768212
76881	1917	breakin	634	Break In	27-08-2026 13:57:19	355377	0.85	normal	2026-08-28 08:34:09.769281	STF-026	Syed Zeeshan Ali	0.5675	recognized	2026-08-28 08:34:09.816156
78767	1918	breakout	336	Break Out	27-08-2026 20:39:42	241569	0.85	pending	2026-08-28 10:44:35.605344	\N	Person #336	0	unrecognized	\N
78766	1918	breakout	335	Break Out	27-08-2026 20:39:27	241169	0.85	unrecognized	2026-08-28 10:44:34.14287	\N	Person #335	0	unrecognized	2026-08-28 10:44:34.988715
76874	1917	breakin	632	Break In	27-08-2026 13:57:12	354992	0.85	normal	2026-08-28 08:33:50.384507	STF-033	Raza Abbas	0.4619	recognized	2026-08-28 08:34:08.143654
78770	1918	breakout	336	Break Out	27-08-2026 20:39:57	241931	0.85	unrecognized	2026-08-28 10:44:38.601422	\N	Person #336	0	unrecognized	2026-08-28 10:44:38.708013
76869	1917	breakin	632	Break In	27-08-2026 13:56:39	354001	0.85	unrecognized	2026-08-28 08:33:35.892996	\N	Person #632	0	unrecognized	2026-08-28 08:33:46.763318
78771	1918	breakout	336	Break Out	27-08-2026 20:40:07	242186	0.85	pending	2026-08-28 10:44:39.12647	\N	Person #336	\N	pending	\N
78772	1918	breakout	338	Break Out	27-08-2026 20:40:16	242296	0.85	unrecognized	2026-08-28 10:44:39.63121	\N	Person #338	0	unrecognized	2026-08-28 10:44:52.876782
76994	1917	breakin	683	Break In	27-08-2026 15:42:29	155923	0.85	normal	2026-08-28 08:40:50.221908	STF-044	Zaheer Hussain	0.5265	recognized	2026-08-28 08:40:50.421941
78775	1918	breakout	339	Break Out	27-08-2026 20:40:33	242824	0.85	unrecognized	2026-08-28 10:44:53.476232	\N	Person #339	0	unrecognized	2026-08-28 10:44:53.63732
76876	1917	breakin	651	Break In	27-08-2026 15:20:41	123243	0.85	normal	2026-08-28 08:33:59.06304	STF-011	Syed Shoaib Ahmad Alvi	0.447	recognized	2026-08-28 08:33:59.081989
76995	1917	breakin	687	Break In	27-08-2026 15:43:41	157661	0.85	unrecognized	2026-08-28 08:41:00.044144	\N	Person #687	0	unrecognized	2026-08-28 08:41:06.673592
76999	1917	breakin	691	Break In	27-08-2026 15:47:12	162903	0.85	unrecognized	2026-08-28 08:41:16.163758	\N	Person #691	0	unrecognized	2026-08-28 08:41:25.71356
77112	1917	breakin	755	Break In	27-08-2026 16:01:17	184135	0.85	normal	2026-08-28 08:47:41.116505	STF-030	Dildar Ahmed	0.6066	recognized	2026-08-28 08:47:41.132462
77110	1917	breakin	754	Break In	27-08-2026 16:01:10	183955	0.85	normal	2026-08-28 08:47:36.155848	STF-005	Muhammad Ayaz Hussain	0.4424	recognized	2026-08-28 08:47:38.050356
77113	1917	breakin	757	Break In	27-08-2026 16:01:22	184248	0.85	normal	2026-08-28 08:47:42.780808	STF-013	Muhammad Faizan	0.6512	recognized	2026-08-28 08:47:42.79477
77115	1917	breakin	758	Break In	27-08-2026 16:01:24	184318	0.85	normal	2026-08-28 08:47:44.757272	STF-037	Muhammad Fahad	0.6047	recognized	2026-08-28 08:47:44.773229
78097	1918	breakout	112	Break Out	27-08-2026 14:39:23	58024	0.85	unrecognized	2026-08-28 10:07:19.642947	\N	Person #112	0	unrecognized	2026-08-28 10:07:36.979124
78415	1918	breakout	211	Break Out	27-08-2026 15:15:01	111437	0.85	unrecognized	2026-08-28 10:25:34.667817	\N	Person #211	0	unrecognized	2026-08-28 10:25:44.431587
78413	1918	breakout	210	Break Out	27-08-2026 15:13:00	109681	0.85	unrecognized	2026-08-28 10:25:31.279524	\N	Person #210	0	unrecognized	2026-08-28 10:25:33.530259
77469	1917	breakin	947	Break In	27-08-2026 16:37:02	237704	0.85	normal	2026-08-28 09:11:17.232837	STF-047	Arshad Irshad	0.4658	recognized	2026-08-28 09:11:17.448053
78422	1918	breakout	214	Break Out	27-08-2026 15:15:59	112885	0.85	unrecognized	2026-08-28 10:25:59.166356	\N	Person #214	0	unrecognized	2026-08-28 10:26:14.251872
78080	1918	breakout	111	Break Out	27-08-2026 14:39:05	57056	0.85	unrecognized	2026-08-28 10:06:34.111487	\N	Person #111	0	unrecognized	2026-08-28 10:07:18.8745
78768	1918	breakout	309	Break Out	27-08-2026 16:12:44	198090	0.85	normal	2026-08-28 10:44:35.640252	STF-023	Syed Zubair Zulfiqar	0.4619	recognized	2026-08-28 10:44:37.757667
79454	1951	breakout	88	Break Out	25-08-2026 18:58:33	5083	0.85	unrecognized	2026-08-28 14:32:58.957486	\N	Person #88	0	unrecognized	2026-08-28 14:33:09.125772
79151	1918	breakout	419	Break Out	27-08-2026 13:53:04	344266	0.85	normal	2026-08-28 11:04:06.608068	STF-024	Arsalan Khan	0.494	recognized	2026-08-28 11:04:13.470641
78417	1918	breakout	212	Break Out	27-08-2026 15:15:19	111869	0.85	unrecognized	2026-08-28 10:25:45.133575	\N	Person #212	0	unrecognized	2026-08-28 10:25:57.916759
78421	1918	breakout	213	Break Out	27-08-2026 15:15:42	112571	0.85	pending	2026-08-28 10:25:58.731961	\N	Person #213	\N	pending	\N
77464	1917	breakin	944	Break In	27-08-2026 16:36:07	236393	0.85	normal	2026-08-28 09:10:36.806606	STF-047	Arshad Irshad	0.5317	recognized	2026-08-28 09:10:36.820568
79012	1918	breakout	377	Break Out	27-08-2026 16:52:19	257427	0.85	unrecognized	2026-08-28 10:56:39.347741	\N	Person #377	0	unrecognized	2026-08-28 10:56:42.249585
78782	1918	breakout	311	Break Out	27-08-2026 16:13:04	198531	0.85	normal	2026-08-28 10:45:08.667276	STF-052	Syed Imran Shah	0.5092	recognized	2026-08-28 10:45:11.227188
77475	1917	breakin	950	Break In	27-08-2026 16:37:52	239010	0.85	normal	2026-08-28 09:11:21.827268	STF-047	Arshad Irshad	0.5044	recognized	2026-08-28 09:11:21.840233
79258	1918	breakout	499	Break Out	27-08-2026 21:41:29	334136	0.85	normal	2026-08-28 11:10:41.058187	STF-010	Faraz Younas	0.4441	recognized	2026-08-28 11:10:44.779315
79020	1918	breakout	382	Break Out	27-08-2026 16:54:19	260432	0.85	unrecognized	2026-08-28 10:57:11.430929	\N	Person #382	0	unrecognized	2026-08-28 10:57:15.811697
79013	1918	breakout	378	Break Out	27-08-2026 16:52:39	257737	0.85	unrecognized	2026-08-28 10:56:42.997714	\N	Person #378	0	unrecognized	2026-08-28 10:56:50.36145
79015	1918	breakout	379	Break Out	27-08-2026 16:53:55	259728	0.85	unrecognized	2026-08-28 10:56:51.491538	\N	Person #379	0	unrecognized	2026-08-28 10:57:07.649693
79153	1918	breakout	420	Break Out	27-08-2026 13:53:06	344533	0.85	normal	2026-08-28 11:04:11.194934	STF-001	Ikram Hassan	0.4755	recognized	2026-08-28 11:04:31.934676
79257	1918	breakout	498	Break Out	27-08-2026 21:40:48	333160	0.85	unrecognized	2026-08-28 11:10:35.442015	\N	Person #498	0	unrecognized	2026-08-28 11:10:40.36614
79266	1918	breakout	505	Break Out	27-08-2026 21:43:11	336751	0.85	unrecognized	2026-08-28 11:11:15.857469	\N	Person #505	0	unrecognized	2026-08-28 11:11:18.179721
79263	1918	breakout	502	Break Out	27-08-2026 21:42:09	335124	0.85	unrecognized	2026-08-28 11:10:57.529957	\N	Person #502	0	unrecognized	2026-08-28 11:11:09.273968
79264	1918	breakout	503	Break Out	27-08-2026 21:42:47	335996	0.85	unrecognized	2026-08-28 11:11:10.090674	\N	Person #503	0	unrecognized	2026-08-28 11:11:15.331377
79267	1918	breakout	506	Break Out	27-08-2026 21:43:25	336973	0.85	unrecognized	2026-08-28 11:11:18.598478	\N	Person #506	0	unrecognized	2026-08-28 11:11:34.578357
79453	1951	breakout	86	Break Out	25-08-2026 18:58:23	4953	0.85	unrecognized	2026-08-28 14:32:58.577956	\N	Person #86	0	unrecognized	2026-08-28 14:32:58.592191
78774	1918	breakout	285	Break Out	27-08-2026 12:59:48	264560	0.85	unrecognized	2026-08-28 10:44:51.671489	\N	Person #285	0	unrecognized	2026-08-28 10:44:59.887907
78778	1918	breakout	286	Break Out	27-08-2026 12:57:45	265886	0.85	pending	2026-08-28 10:45:00.844905	\N	Person #286	\N	pending	\N
78099	1918	breakout	128	Break Out	27-08-2026 18:57:58	88925	0.85	normal	2026-08-28 10:07:33.619472	STF-010	Faraz Younas	0.5016	recognized	2026-08-28 10:07:35.656432
79178	1918	breakout	427	Break Out	27-08-2026 13:53:53	345721	0.85	unrecognized	2026-08-28 11:05:14.804861	\N	Person #427	0	unrecognized	2026-08-28 11:05:16.828656
79172	1918	breakout	425	Break Out	27-08-2026 13:50:31	344807	0.85	pending	2026-08-28 11:05:02.914711	\N	Person #425	\N	pending	\N
78783	1918	breakout	290	Break Out	27-08-2026 13:01:13	266693	0.85	unrecognized	2026-08-28 10:45:13.714768	\N	Person #290	0	unrecognized	2026-08-28 10:45:24.686375
78101	1918	breakout	129	Break Out	27-08-2026 18:58:13	89322	0.85	normal	2026-08-28 10:07:38.317715	STF-017	Mohammad Zahid	0.4937	recognized	2026-08-28 10:07:40.309663
78779	1918	breakout	287	Break Out	27-08-2026 13:00:41	265936	0.85	unrecognized	2026-08-28 10:45:01.390265	\N	Person #287	0	unrecognized	2026-08-28 10:45:03.746001
78112	1918	breakout	132	Break Out	27-08-2026 18:59:29	91133	0.85	normal	2026-08-28 10:08:27.168797	STF-002	Abdur Rehman	0.4643	recognized	2026-08-28 10:08:31.731911
79466	1951	breakout	90	Break Out	25-08-2026 19:00:06	7233	0.85	normal	2026-08-28 14:33:31.717106	STF-010	Faraz Younas	0.492	recognized	2026-08-28 14:33:38.392821
77478	1917	breakin	952	Break In	27-08-2026 16:38:31	239991	0.85	normal	2026-08-28 09:11:28.874957	STF-044	Zaheer Hussain	0.5509	recognized	2026-08-28 09:11:28.887951
78106	1918	breakout	130	Break Out	27-08-2026 18:59:03	90501	0.85	normal	2026-08-28 10:07:59.283902	STF-031	Muhammad Hassan	0.472	recognized	2026-08-28 10:08:04.228629
78439	1918	breakout	231	Break Out	27-08-2026 19:50:57	168089	0.85	unrecognized	2026-08-28 10:27:03.061311	\N	Person #231	0	unrecognized	2026-08-28 10:27:54.167013
77477	1917	breakin	951	Break In	27-08-2026 16:38:32	239915	0.85	normal	2026-08-28 09:11:26.449245	STF-047	Arshad Irshad	0.4523	recognized	2026-08-28 09:11:30.010739
78769	1918	breakout	284	Break Out	27-08-2026 12:59:16	263788	0.85	unrecognized	2026-08-28 10:44:36.769482	\N	Person #284	0	unrecognized	2026-08-28 10:44:50.727493
78781	1918	breakout	289	Break Out	27-08-2026 13:01:07	266507	0.85	unrecognized	2026-08-28 10:45:07.72134	\N	Person #289	0	unrecognized	2026-08-28 10:45:13.334244
77481	1917	breakin	955	Break In	27-08-2026 16:39:16	240230	0.85	normal	2026-08-28 09:11:37.381382	STF-044	Zaheer Hussain	0.4621	recognized	2026-08-28 09:12:45.598824
78435	1918	breakout	231	Break Out	27-08-2026 19:48:47	165081	0.85	unrecognized	2026-08-28 10:26:51.86712	\N	Person #231	0	unrecognized	2026-08-28 10:27:01.726768
79179	1918	breakout	428	Break Out	27-08-2026 13:54:13	346200	0.85	unrecognized	2026-08-28 11:05:17.61383	\N	Person #428	0	unrecognized	2026-08-28 11:05:31.348001
77496	1917	breakin	970	Break In	27-08-2026 16:39:36	241612	0.85	normal	2026-08-28 09:12:52.150276	STF-010	Faraz Younas	0.5752	recognized	2026-08-28 09:12:52.163805
78788	1918	breakout	291	Break Out	27-08-2026 13:01:33	267227	0.85	unrecognized	2026-08-28 10:45:25.353402	\N	Person #291	0	unrecognized	2026-08-28 10:45:38.553429
77492	1917	breakin	966	Break In	27-08-2026 16:39:11	240989	0.85	normal	2026-08-28 09:12:32.031217	STF-034	Muhammad Laeeq	0.4601	recognized	2026-08-28 09:12:32.046402
79272	1918	breakout	460	Break Out	27-08-2026 17:42:21	332376	0.85	normal	2026-08-28 11:11:32.34892	STF-029	Abdul Rehman Sultan	0.4468	recognized	2026-08-28 11:11:47.92392
77500	1917	breakin	979	Break In	27-08-2026 16:40:27	242446	0.85	normal	2026-08-28 09:13:15.927603	STF-020	Syed Jahazaib Ahmad Alvi	0.5012	recognized	2026-08-28 09:13:45.550596
79181	1918	breakout	428	Break Out	27-08-2026 13:54:23	346440	0.85	unrecognized	2026-08-28 11:05:31.695488	\N	Person #428	0	unrecognized	2026-08-28 11:05:46.380796
77505	1917	breakin	984	Break In	27-08-2026 16:42:52	246504	0.85	normal	2026-08-28 09:14:20.687049	STF-013	Muhammad Faizan	0.5281	recognized	2026-08-28 09:14:21.896782
78436	1918	breakout	193	Break Out	27-08-2026 12:09:29	189088	0.85	unrecognized	2026-08-28 10:26:52.987911	\N	Person #193	0	unrecognized	2026-08-28 10:27:10.013814
77509	1917	breakin	989	Break In	27-08-2026 16:44:37	249120	0.85	normal	2026-08-28 09:14:45.725996	STF-024	Arsalan Khan	0.5045	recognized	2026-08-28 09:14:46.060418
77510	1917	breakin	990	Break In	27-08-2026 16:44:00	249384	0.85	normal	2026-08-28 09:14:47.859629	STF-047	Arshad Irshad	0.5874	recognized	2026-08-28 09:14:47.872563
79168	1918	breakout	429	Break Out	27-08-2026 17:17:01	294414	0.85	unrecognized	2026-08-28 11:04:53.886413	\N	Person #429	0	unrecognized	2026-08-28 11:05:01.161475
77506	1917	breakin	985	Break In	27-08-2026 16:43:18	247127	0.85	normal	2026-08-28 09:14:23.456441	STF-023	Syed Zubair Zulfiqar	0.4459	recognized	2026-08-28 09:14:24.441515
78776	1918	breakout	339	Break Out	27-08-2026 20:40:40	242913	0.85	unrecognized	2026-08-28 10:44:54.073595	\N	Person #339	0	unrecognized	2026-08-28 10:45:16.475904
79033	1918	breakout	367	Break Out	27-08-2026 13:37:43	325671	0.85	pending	2026-08-28 10:58:11.981821	\N	Person #367	0	unrecognized	\N
77502	1917	breakin	981	Break In	27-08-2026 16:41:06	243327	0.85	unrecognized	2026-08-28 09:13:48.704141	\N	Person #981	0	unrecognized	2026-08-28 09:14:14.717507
77518	1917	breakin	997	Break In	27-08-2026 16:47:03	252784	0.85	normal	2026-08-28 09:15:18.220371	STF-044	Zaheer Hussain	0.448	recognized	2026-08-28 09:15:18.889112
78442	1918	breakout	196	Break Out	27-08-2026 12:11:57	192812	0.85	unrecognized	2026-08-28 10:27:24.607196	\N	Person #196	0	unrecognized	2026-08-28 10:27:39.268555
77513	1917	breakin	994	Break In	27-08-2026 16:46:27	251696	0.85	unrecognized	2026-08-28 09:15:06.324216	\N	Person #994	0	unrecognized	2026-08-28 09:15:07.539046
79468	1950	breakin	45	Break In	25-08-2026 19:04:27	14230	0.85	normal	2026-08-28 14:33:40.096056	STF-032	Muhammad Yaseen	0.6103	recognized	2026-08-28 14:33:40.112741
78100	1918	breakout	114	Break Out	27-08-2026 14:39:47	58569	0.85	unrecognized	2026-08-28 10:07:37.772358	\N	Person #114	0	unrecognized	2026-08-28 10:08:10.390049
78785	1918	breakout	341	Break Out	27-08-2026 20:42:01	245030	0.85	pending	2026-08-28 10:45:18.382555	\N	Person #341	0	unrecognized	\N
78432	1918	breakout	191	Break Out	27-08-2026 12:08:41	187942	0.85	unrecognized	2026-08-28 10:26:34.333891	\N	Person #191	0	unrecognized	2026-08-28 10:26:48.977284
77515	1917	breakin	994	Break In	27-08-2026 16:46:00	252196	0.85	unrecognized	2026-08-28 09:15:08.469029	\N	Person #994	0	unrecognized	2026-08-28 09:15:08.966218
78109	1918	breakout	116	Break Out	27-08-2026 14:40:01	58689	0.85	unrecognized	2026-08-28 10:08:13.391104	\N	Person #116	0	unrecognized	2026-08-28 10:08:47.595959
77503	1917	breakin	981	Break In	27-08-2026 16:41:13	243957	0.85	unrecognized	2026-08-28 09:14:15.222364	\N	Person #981	0	unrecognized	2026-08-28 09:14:18.629489
77504	1917	breakin	983	Break In	27-08-2026 16:41:00	244816	0.85	unrecognized	2026-08-28 09:14:19.72842	\N	Person #983	0	unrecognized	2026-08-28 09:14:19.899519
78434	1918	breakout	192	Break Out	27-08-2026 12:06:18	188922	0.85	pending	2026-08-28 10:26:50.194023	\N	Person #192	0	unrecognized	\N
79163	1918	breakout	426	Break Out	27-08-2026 17:13:38	289355	0.85	unrecognized	2026-08-28 11:04:34.472244	\N	Person #426	0	unrecognized	2026-08-28 11:04:50.459227
77512	1917	breakin	994	Break In	27-08-2026 16:46:14	251421	0.85	unrecognized	2026-08-28 09:15:00.940022	\N	Person #994	0	unrecognized	2026-08-28 09:15:06.079743
78787	1918	breakout	341	Break Out	27-08-2026 20:42:20	245410	0.85	unrecognized	2026-08-28 10:45:20.83102	\N	Person #341	0	unrecognized	2026-08-28 10:45:33.250019
78441	1918	breakout	196	Break Out	27-08-2026 12:11:05	191487	0.85	unrecognized	2026-08-28 10:27:11.832552	\N	Person #196	0	unrecognized	2026-08-28 10:27:23.860799
79166	1918	breakout	427	Break Out	27-08-2026 17:14:19	290487	0.85	unrecognized	2026-08-28 11:04:51.451886	\N	Person #427	0	unrecognized	2026-08-28 11:04:51.474825
79034	1918	breakout	367	Break Out	27-08-2026 13:41:08	326599	0.85	unrecognized	2026-08-28 10:58:14.749342	\N	Person #367	0	unrecognized	2026-08-28 10:58:16.988822
79167	1918	breakout	427	Break Out	27-08-2026 17:14:35	290889	0.85	unrecognized	2026-08-28 11:04:51.914355	\N	Person #427	0	unrecognized	2026-08-28 11:04:51.936296
79176	1918	breakout	431	Break Out	27-08-2026 17:17:11	294667	0.85	unrecognized	2026-08-28 11:05:12.59081	\N	Person #431	0	unrecognized	2026-08-28 11:05:34.560945
79283	1918	breakout	462	Break Out	27-08-2026 17:43:16	333813	0.85	unrecognized	2026-08-28 11:12:08.389362	\N	Person #462	0	unrecognized	2026-08-28 11:12:10.074781
79285	1918	breakout	462	Break Out	27-08-2026 17:45:44	337503	0.85	normal	2026-08-28 11:12:11.601235	STF-052	Syed Imran Shah	0.4793	recognized	2026-08-28 11:12:17.9849
79291	1918	breakout	464	Break Out	27-08-2026 17:46:05	338002	0.85	normal	2026-08-28 11:12:30.086807	STF-024	Arsalan Khan	0.444	recognized	2026-08-28 11:12:32.363128
79031	1918	breakout	424	Break Out	27-08-2026 21:06:45	281900	0.85	unrecognized	2026-08-28 10:57:46.724667	\N	Person #424	0	unrecognized	2026-08-28 10:58:20.425385
78803	1918	breakout	320	Break Out	27-08-2026 16:15:35	202290	0.85	unrecognized	2026-08-28 10:46:03.942931	\N	Person #320	0	unrecognized	2026-08-28 10:46:13.02598
79180	1918	breakout	467	Break Out	27-08-2026 21:18:37	299684	0.85	normal	2026-08-28 11:05:24.767538	STF-002	Abdur Rehman	0.4666	recognized	2026-08-28 11:05:49.039271
77522	1917	breakin	1002	Break In	27-08-2026 16:47:51	253974	0.85	normal	2026-08-28 09:16:08.378089	STF-049	Nabi Ul Haq	0.5053	recognized	2026-08-28 09:16:14.654439
79036	1918	breakout	426	Break Out	27-08-2026 21:07:00	282987	0.85	unrecognized	2026-08-28 10:58:22.044103	\N	Person #426	0	unrecognized	2026-08-28 10:59:16.095829
78812	1918	breakout	321	Break Out	27-08-2026 16:16:27	203657	0.85	normal	2026-08-28 10:46:27.431685	STF-037	Muhammad Fahad	0.5061	recognized	2026-08-28 10:46:28.594201
78107	1918	breakout	99	Break Out	27-08-2026 11:21:17	116814	0.85	unrecognized	2026-08-28 10:08:06.158548	\N	Person #99	0	unrecognized	2026-08-28 10:08:14.009439
79028	1918	breakout	422	Break Out	27-08-2026 21:06:27	281680	0.85	pending	2026-08-28 10:57:42.114412	\N	Person #422	0	unrecognized	\N
78110	1918	breakout	100	Break Out	27-08-2026 11:21:41	117406	0.85	unrecognized	2026-08-28 10:08:14.826201	\N	Person #100	0	unrecognized	2026-08-28 10:08:31.623223
78790	1918	breakout	316	Break Out	27-08-2026 16:13:45	199430	0.85	normal	2026-08-28 10:45:32.016389	STF-029	Abdul Rehman Sultan	0.532	recognized	2026-08-28 10:45:48.572182
78802	1918	breakout	319	Break Out	27-08-2026 16:15:28	202194	0.85	unrecognized	2026-08-28 10:46:02.72602	\N	Person #319	0	unrecognized	2026-08-28 10:46:03.327062
79289	1918	breakout	513	Break Out	27-08-2026 21:49:14	345757	0.85	unrecognized	2026-08-28 11:12:19.359967	\N	Person #513	0	unrecognized	2026-08-28 11:12:28.897493
79274	1918	breakout	506	Break Out	27-08-2026 21:43:34	337259	0.85	unrecognized	2026-08-28 11:11:34.820505	\N	Person #506	0	unrecognized	2026-08-28 11:11:35.12901
78440	1918	breakout	219	Break Out	27-08-2026 15:16:35	113831	0.85	normal	2026-08-28 10:27:09.127378	STF-010	Faraz Younas	0.4805	recognized	2026-08-28 10:27:19.728849
79278	1918	breakout	509	Break Out	27-08-2026 21:45:52	340720	0.85	normal	2026-08-28 11:11:49.514557	STF-028	Noman Imran	0.4608	recognized	2026-08-28 11:11:51.393673
78794	1918	breakout	317	Break Out	27-08-2026 16:14:18	200409	0.85	normal	2026-08-28 10:45:52.477445	STF-030	Dildar Ahmed	0.4538	recognized	2026-08-28 10:45:56.275305
79276	1918	breakout	507	Break Out	27-08-2026 21:44:55	339294	0.85	unrecognized	2026-08-28 11:11:44.541189	\N	Person #507	0	unrecognized	2026-08-28 11:11:46.11327
79029	1918	breakout	423	Break Out	27-08-2026 21:06:38	281877	0.85	unrecognized	2026-08-28 10:57:45.223241	\N	Person #423	0	unrecognized	2026-08-28 10:58:06.511919
79164	1918	breakout	461	Break Out	27-08-2026 21:18:11	299208	0.85	normal	2026-08-28 11:04:38.903995	STF-029	Abdul Rehman Sultan	0.4437	recognized	2026-08-28 11:04:46.990006
79275	1918	breakout	506	Break Out	27-08-2026 21:43:41	337455	0.85	unrecognized	2026-08-28 11:11:35.365808	\N	Person #506	0	unrecognized	2026-08-28 11:11:43.54282
79282	1918	breakout	511	Break Out	27-08-2026 21:47:23	343085	0.85	normal	2026-08-28 11:12:06.886123	STF-028	Noman Imran	0.4489	recognized	2026-08-28 11:12:06.904103
79290	1918	breakout	513	Break Out	27-08-2026 21:50:41	347988	0.85	normal	2026-08-28 11:12:29.901522	STF-001	Ikram Hassan	0.4805	recognized	2026-08-28 11:12:32.903248
79287	1918	breakout	512	Break Out	27-08-2026 21:48:03	343991	0.85	normal	2026-08-28 11:12:14.185103	STF-036	Shahzad Ali	0.5314	recognized	2026-08-28 11:12:16.775938
78793	1918	breakout	343	Break Out	27-08-2026 20:44:24	248515	0.85	unrecognized	2026-08-28 10:45:51.400213	\N	Person #343	0	unrecognized	2026-08-28 10:45:54.91983
78449	1918	breakout	221	Break Out	27-08-2026 15:18:12	116192	0.85	unrecognized	2026-08-28 10:28:08.978597	\N	Person #221	0	unrecognized	2026-08-28 10:28:20.602496
78811	1918	breakout	352	Break Out	27-08-2026 20:48:13	254229	0.85	unrecognized	2026-08-28 10:46:19.213682	\N	Person #352	0	unrecognized	2026-08-28 10:46:29.602796
77525	1917	breakin	1005	Break In	27-08-2026 16:49:04	255771	0.85	normal	2026-08-28 09:18:18.555484	STF-008	Muhammad Shoaib	0.5137	recognized	2026-08-28 09:18:20.803802
78801	1918	breakout	347	Break Out	27-08-2026 20:45:16	249889	0.85	normal	2026-08-28 10:46:01.90672	STF-032	Muhammad Yaseen	0.4469	recognized	2026-08-28 10:46:02.968042
78805	1918	breakout	348	Break Out	27-08-2026 20:46:29	251731	0.85	pending	2026-08-28 10:46:09.689622	\N	Person #348	0	unrecognized	\N
78809	1918	breakout	350	Break Out	27-08-2026 20:46:47	252176	0.85	pending	2026-08-28 10:46:15.86124	\N	Person #350	0	unrecognized	\N
78791	1918	breakout	342	Break Out	27-08-2026 20:43:38	247369	0.85	unrecognized	2026-08-28 10:45:34.459623	\N	Person #342	0	unrecognized	2026-08-28 10:45:50.60721
77532	1917	breakin	1012	Break In	27-08-2026 16:52:20	260690	0.85	normal	2026-08-28 09:18:49.794662	STF-001	Ikram Hassan	0.5183	recognized	2026-08-28 09:18:51.236566
78457	1918	breakout	223	Break Out	27-08-2026 15:18:38	116871	0.85	unrecognized	2026-08-28 10:28:28.692555	\N	Person #223	0	unrecognized	2026-08-28 10:28:42.981047
79302	1918	breakout	473	Break Out	27-08-2026 17:51:21	346004	0.85	normal	2026-08-28 11:13:13.794053	STF-030	Dildar Ahmed	0.4797	recognized	2026-08-28 11:13:14.265003
79189	1918	breakout	433	Break Out	27-08-2026 17:17:53	295694	0.85	unrecognized	2026-08-28 11:06:08.295822	\N	Person #433	0	unrecognized	2026-08-28 11:06:24.663545
79192	1918	breakout	434	Break Out	27-08-2026 17:19:00	298551	0.85	normal	2026-08-28 11:06:26.146253	STF-025	Farhan Virk	0.517	recognized	2026-08-28 11:06:26.759221
77530	1917	breakin	1009	Break In	27-08-2026 16:50:53	258492	0.85	normal	2026-08-28 09:18:42.199458	STF-026	Syed Zeeshan Ali	0.5128	recognized	2026-08-28 09:18:44.578651
79296	1918	breakout	469	Break Out	27-08-2026 17:49:31	343217	0.85	unrecognized	2026-08-28 11:12:53.098616	\N	Person #469	0	unrecognized	2026-08-28 11:12:54.150563
79182	1918	breakout	431	Break Out	27-08-2026 17:17:23	294956	0.85	unrecognized	2026-08-28 11:05:34.949088	\N	Person #431	0	unrecognized	2026-08-28 11:05:49.941015
77529	1917	breakin	1008	Break In	27-08-2026 16:50:30	257956	0.85	normal	2026-08-28 09:18:26.903887	STF-017	Mohammad Zahid	0.45	recognized	2026-08-28 09:18:27.516711
77537	1917	breakin	1014	Break In	27-08-2026 16:53:58	263079	0.85	normal	2026-08-28 09:18:58.516051	STF-029	Abdul Rehman Sultan	0.5849	recognized	2026-08-28 09:19:06.925071
79184	1918	breakout	432	Break Out	27-08-2026 17:17:39	295393	0.85	unrecognized	2026-08-28 11:05:50.41258	\N	Person #432	0	unrecognized	2026-08-28 11:06:06.511098
77533	1917	breakin	1013	Break In	27-08-2026 16:52:00	261164	0.85	normal	2026-08-28 09:18:52.83649	STF-025	Farhan Virk	0.5051	recognized	2026-08-28 09:18:55.248576
79197	1918	breakout	435	Break Out	27-08-2026 17:20:09	299121	0.85	unrecognized	2026-08-28 11:06:29.333819	\N	Person #435	0	unrecognized	2026-08-28 11:06:41.765317
77535	1917	breakin	1014	Break In	27-08-2026 16:53:17	262142	0.85	pending	2026-08-28 09:18:57.320003	\N	Person #1014	\N	pending	\N
79030	1918	breakout	386	Break Out	27-08-2026 16:55:35	262338	0.85	normal	2026-08-28 10:57:45.496036	STF-010	Faraz Younas	0.4685	recognized	2026-08-28 10:57:56.31959
79303	1918	breakout	474	Break Out	27-08-2026 17:52:50	348140	0.85	unrecognized	2026-08-28 11:13:16.168707	\N	Person #474	0	unrecognized	2026-08-28 11:13:26.058262
79294	1918	breakout	468	Break Out	27-08-2026 17:46:36	338789	0.85	unrecognized	2026-08-28 11:12:38.441072	\N	Person #468	0	unrecognized	2026-08-28 11:12:51.321231
79306	1918	breakout	475	Break Out	27-08-2026 17:53:34	349204	0.85	unrecognized	2026-08-28 11:13:26.77352	\N	Person #475	0	unrecognized	2026-08-28 11:13:55.935987
78806	1918	breakout	298	Break Out	27-08-2026 13:02:07	272417	0.85	pending	2026-08-28 10:46:13.20949	\N	Person #298	0	unrecognized	\N
78444	1918	breakout	197	Break Out	27-08-2026 12:12:08	193003	0.85	unrecognized	2026-08-28 10:27:40.045832	\N	Person #197	0	unrecognized	2026-08-28 10:27:47.629271
77555	1917	breakin	1039	Break In	27-08-2026 16:56:30	266954	0.85	normal	2026-08-28 09:20:38.174999	STF-032	Muhammad Yaseen	0.4612	recognized	2026-08-28 09:20:38.188961
78797	1918	breakout	294	Break Out	27-08-2026 13:02:27	268604	0.85	unrecognized	2026-08-28 10:45:56.943667	\N	Person #294	0	unrecognized	2026-08-28 10:45:59.053341
78800	1918	breakout	295	Break Out	27-08-2026 13:03:20	269829	0.85	unrecognized	2026-08-28 10:46:00.028586	\N	Person #295	0	unrecognized	2026-08-28 10:46:08.097647
77550	1917	breakin	1032	Break In	27-08-2026 16:56:11	266453	0.85	normal	2026-08-28 09:20:03.855962	STF-002	Abdur Rehman	0.4715	recognized	2026-08-28 09:20:05.568692
78808	1918	breakout	299	Break Out	27-08-2026 13:02:16	272651	0.85	pending	2026-08-28 10:46:15.377764	\N	Person #299	0	unrecognized	\N
79183	1918	breakout	430	Break Out	27-08-2026 13:54:52	347178	0.85	unrecognized	2026-08-28 11:05:47.183405	\N	Person #430	0	unrecognized	2026-08-28 11:05:58.180281
78445	1918	breakout	198	Break Out	27-08-2026 12:12:16	193296	0.85	unrecognized	2026-08-28 10:27:48.293893	\N	Person #198	0	unrecognized	2026-08-28 10:27:58.281446
77544	1917	breakin	1026	Break In	27-08-2026 16:55:13	265029	0.85	normal	2026-08-28 09:19:33.910126	STF-029	Abdul Rehman Sultan	0.6706	recognized	2026-08-28 09:19:33.925096
78810	1918	breakout	299	Break Out	27-08-2026 13:05:53	273635	0.85	normal	2026-08-28 10:46:18.304176	STF-029	Abdul Rehman Sultan	0.4518	recognized	2026-08-28 10:46:31.095417
79198	1918	breakout	434	Break Out	27-08-2026 13:57:29	351138	0.85	unrecognized	2026-08-28 11:06:31.171398	\N	Person #434	0	unrecognized	2026-08-28 11:06:37.509146
77561	1917	breakin	1046	Break In	27-08-2026 16:57:09	267930	0.85	normal	2026-08-28 09:22:12.269586	STF-023	Syed Zubair Zulfiqar	0.5699	recognized	2026-08-28 09:22:12.282703
78447	1918	breakout	199	Break Out	27-08-2026 12:13:32	195154	0.85	unrecognized	2026-08-28 10:27:59.492547	\N	Person #199	0	unrecognized	2026-08-28 10:28:15.170927
79191	1918	breakout	432	Break Out	27-08-2026 13:56:22	349478	0.85	unrecognized	2026-08-28 11:06:25.108016	\N	Person #432	0	unrecognized	2026-08-28 11:06:26.548771
77546	1917	breakin	1029	Break In	27-08-2026 16:55:23	265246	0.85	normal	2026-08-28 09:19:40.124331	STF-007	Faisal Saleem	0.4509	recognized	2026-08-28 09:19:41.408486
79186	1918	breakout	431	Break Out	27-08-2026 13:55:14	347579	0.85	unrecognized	2026-08-28 11:05:58.708381	\N	Person #431	0	unrecognized	2026-08-28 11:06:24.072791
77552	1917	breakin	1035	Break In	27-08-2026 16:56:29	266877	0.85	normal	2026-08-28 09:20:20.009938	STF-031	Muhammad Hassan	0.4479	recognized	2026-08-28 09:20:32.487027
78792	1918	breakout	292	Break Out	27-08-2026 13:01:52	267395	0.85	unrecognized	2026-08-28 10:45:39.093396	\N	Person #292	0	unrecognized	2026-08-28 10:45:53.676579
79039	1918	breakout	388	Break Out	27-08-2026 16:56:06	263077	0.85	normal	2026-08-28 10:58:50.605919	STF-029	Abdul Rehman Sultan	0.456	recognized	2026-08-28 10:59:09.373188
77576	1917	breakin	1067	Break In	27-08-2026 16:59:36	271194	0.85	unrecognized	2026-08-28 09:24:53.23899	\N	Person #1067	0	unrecognized	2026-08-28 09:25:07.279156
79195	1918	breakout	433	Break Out	27-08-2026 13:54:34	350865	0.85	pending	2026-08-28 11:06:28.118062	\N	Person #433	0	unrecognized	\N
77568	1917	breakin	1061	Break In	27-08-2026 16:57:52	268999	0.85	normal	2026-08-28 09:23:31.492361	STF-035	Hammad Shaukat	0.4545	recognized	2026-08-28 09:23:33.193501
79295	1918	breakout	515	Break Out	27-08-2026 21:51:42	349507	0.85	unrecognized	2026-08-28 11:12:44.009446	\N	Person #515	0	unrecognized	2026-08-28 11:12:53.610372
77571	1917	breakin	1066	Break In	27-08-2026 16:59:05	270831	0.85	normal	2026-08-28 09:24:28.659873	STF-024	Arsalan Khan	0.5181	recognized	2026-08-28 09:24:28.680817
79297	1918	breakout	516	Break Out	27-08-2026 21:53:58	352917	0.85	normal	2026-08-28 11:12:55.679105	STF-010	Faraz Younas	0.467	recognized	2026-08-28 11:13:01.965398
79304	1918	breakout	520	Break Out	27-08-2026 21:54:34	353850	0.85	normal	2026-08-28 11:13:21.677959	STF-034	Muhammad Laeeq	0.4409	recognized	2026-08-28 11:13:23.936383
77579	1917	breakin	1071	Break In	27-08-2026 16:59:51	271943	0.85	unrecognized	2026-08-28 09:25:25.92774	\N	Person #1071	0	unrecognized	2026-08-28 09:25:28.41026
77580	1917	breakin	1072	Break In	27-08-2026 17:00:00	272134	0.85	unrecognized	2026-08-28 09:25:34.830807	\N	Person #1072	0	unrecognized	2026-08-28 09:25:41.423815
77582	1917	breakin	1074	Break In	27-08-2026 17:00:13	272419	0.85	unrecognized	2026-08-28 09:25:51.080998	\N	Person #1074	0	unrecognized	2026-08-28 09:26:18.771527
77587	1917	breakin	1077	Break In	27-08-2026 17:00:51	273486	0.85	normal	2026-08-28 09:27:37.379589	STF-007	Faisal Saleem	0.5183	recognized	2026-08-28 09:27:37.399535
79194	1918	breakout	469	Break Out	27-08-2026 21:20:38	302913	0.85	normal	2026-08-28 11:06:27.247921	STF-048	Abdullah Sultan	0.4633	recognized	2026-08-28 11:06:27.769241
78446	1918	breakout	232	Break Out	27-08-2026 19:51:22	168948	0.85	unrecognized	2026-08-28 10:27:54.890081	\N	Person #232	0	unrecognized	2026-08-28 10:28:06.545056
78813	1918	breakout	322	Break Out	27-08-2026 16:17:26	205093	0.85	normal	2026-08-28 10:46:30.729323	STF-013	Muhammad Faizan	0.4686	recognized	2026-08-28 10:46:33.633974
77612	1917	breakin	1101	Break In	27-08-2026 17:06:14	281460	0.85	unrecognized	2026-08-28 09:31:49.950439	\N	Person #1101	0	unrecognized	2026-08-28 09:31:53.428335
78455	1918	breakout	233	Break Out	27-08-2026 19:52:49	171073	0.85	normal	2026-08-28 10:28:25.420491	STF-029	Abdul Rehman Sultan	0.5139	recognized	2026-08-28 10:29:02.026687
77598	1917	breakin	1086	Break In	27-08-2026 17:02:05	275302	0.85	normal	2026-08-28 09:30:09.490909	STF-027	Ahmed Hassan Bhatti	0.4623	recognized	2026-08-28 09:30:18.200542
78448	1918	breakout	232	Break Out	27-08-2026 19:51:35	169292	0.85	unrecognized	2026-08-28 10:28:06.891182	\N	Person #232	0	unrecognized	2026-08-28 10:28:20.119784
77593	1917	breakin	1081	Break In	27-08-2026 17:01:27	274394	0.85	normal	2026-08-28 09:29:07.203508	STF-001	Ikram Hassan	0.6686	recognized	2026-08-28 09:29:07.223424
77599	1917	breakin	1088	Break In	27-08-2026 17:02:27	275825	0.85	normal	2026-08-28 09:30:20.129262	STF-035	Hammad Shaukat	0.5912	recognized	2026-08-28 09:30:20.626689
78452	1918	breakout	233	Break Out	27-08-2026 19:52:12	170313	0.85	pending	2026-08-28 10:28:21.022629	\N	Person #233	0	unrecognized	\N
77600	1917	breakin	1091	Break In	27-08-2026 17:03:00	277754	0.85	normal	2026-08-28 09:30:26.661564	STF-017	Mohammad Zahid	0.5418	recognized	2026-08-28 09:30:26.728385
77601	1917	breakin	1092	Break In	27-08-2026 17:04:01	278233	0.85	normal	2026-08-28 09:30:28.69396	STF-031	Muhammad Hassan	0.5417	recognized	2026-08-28 09:30:28.708948
79042	1918	breakout	373	Break Out	27-08-2026 13:41:43	327413	0.85	unrecognized	2026-08-28 10:58:55.909475	\N	Person #373	0	unrecognized	2026-08-28 10:59:13.797869
77609	1917	breakin	1100	Break In	27-08-2026 17:05:33	280516	0.85	unrecognized	2026-08-28 09:31:44.208949	\N	Person #1100	0	unrecognized	2026-08-28 09:31:45.094704
77602	1917	breakin	1094	Break In	27-08-2026 17:05:08	279189	0.85	unrecognized	2026-08-28 09:30:32.434145	\N	Person #1094	0	unrecognized	2026-08-28 09:31:24.256713
77605	1917	breakin	1097	Break In	27-08-2026 17:04:52	279298	0.85	unrecognized	2026-08-28 09:30:47.808071	\N	Person #1097	0	unrecognized	2026-08-28 09:31:07.515306
79188	1918	breakout	468	Break Out	27-08-2026 21:19:36	301356	0.85	normal	2026-08-28 11:06:06.932095	STF-047	Arshad Irshad	0.4939	recognized	2026-08-28 11:06:08.08016
77607	1917	breakin	1099	Break In	27-08-2026 17:05:27	280256	0.85	unrecognized	2026-08-28 09:31:29.067065	\N	Person #1099	0	unrecognized	2026-08-28 09:31:39.512296
79044	1918	breakout	376	Break Out	27-08-2026 13:41:58	327727	0.85	unrecognized	2026-08-28 10:59:14.423788	\N	Person #376	0	unrecognized	2026-08-28 10:59:38.669489
77597	1917	breakin	1085	Break In	27-08-2026 17:02:01	275247	0.85	normal	2026-08-28 09:30:00.13142	STF-008	Muhammad Shoaib	0.5692	recognized	2026-08-28 09:30:00.145795
77614	1917	breakin	1108	Break In	27-08-2026 17:07:23	283189	0.85	unrecognized	2026-08-28 09:31:56.509091	\N	Person #1108	0	unrecognized	2026-08-28 09:32:05.683705
79196	1918	breakout	470	Break Out	27-08-2026 21:20:43	303013	0.85	normal	2026-08-28 11:06:28.581414	STF-047	Arshad Irshad	0.4919	recognized	2026-08-28 11:06:38.56961
77613	1917	breakin	1106	Break In	27-08-2026 17:06:32	281953	0.85	unrecognized	2026-08-28 09:31:54.274447	\N	Person #1106	0	unrecognized	2026-08-28 09:31:55.089601
77611	1917	breakin	1101	Break In	27-08-2026 17:06:05	281242	0.85	unrecognized	2026-08-28 09:31:47.512267	\N	Person #1101	0	unrecognized	2026-08-28 09:31:49.440877
77610	1917	breakin	1101	Break In	27-08-2026 17:05:49	280892	0.85	unrecognized	2026-08-28 09:31:45.833061	\N	Person #1101	0	unrecognized	2026-08-28 09:31:47.100169
77615	1917	breakin	1111	Break In	27-08-2026 17:08:25	284750	0.85	unrecognized	2026-08-28 09:32:06.481861	\N	Person #1111	0	unrecognized	2026-08-28 09:32:13.191013
79312	1918	breakout	478	Break Out	27-08-2026 17:54:44	351018	0.85	unrecognized	2026-08-28 11:13:58.099369	\N	Person #478	0	unrecognized	2026-08-28 11:14:19.997974
77616	1917	breakin	1112	Break In	27-08-2026 17:08:56	285519	0.85	unrecognized	2026-08-28 09:32:13.886927	\N	Person #1112	0	unrecognized	2026-08-28 09:32:24.200046
77617	1917	breakin	1113	Break In	27-08-2026 17:09:44	286800	0.85	normal	2026-08-28 09:32:25.678774	STF-032	Muhammad Yaseen	0.4626	recognized	2026-08-28 09:32:25.718667
79317	1918	breakout	479	Break Out	27-08-2026 17:54:55	351339	0.85	unrecognized	2026-08-28 11:14:21.900878	\N	Person #479	0	unrecognized	2026-08-28 11:14:31.011744
77626	1917	breakin	1113	Break In	27-08-2026 17:11:04	288822	0.85	normal	2026-08-28 09:32:51.493222	STF-032	Muhammad Yaseen	0.7124	recognized	2026-08-28 09:32:51.521084
77628	1917	breakin	1123	Break In	27-08-2026 17:11:53	290026	0.85	normal	2026-08-28 09:33:00.919769	STF-002	Abdur Rehman	0.4758	recognized	2026-08-28 09:33:02.677628
77630	1917	breakin	1113	Break In	27-08-2026 17:12:34	290980	0.85	normal	2026-08-28 09:33:17.299353	STF-032	Muhammad Yaseen	0.5136	recognized	2026-08-28 09:33:20.642479
79202	1918	breakout	437	Break Out	27-08-2026 13:58:44	352947	0.85	unrecognized	2026-08-28 11:06:42.487208	\N	Person #437	0	unrecognized	2026-08-28 11:06:54.112654
79048	1918	breakout	431	Break Out	27-08-2026 21:08:12	284284	0.85	unrecognized	2026-08-28 10:59:27.896244	\N	Person #431	0	unrecognized	2026-08-28 10:59:35.252049
77641	1917	breakin	1133	Break In	27-08-2026 17:14:39	294076	0.85	unrecognized	2026-08-28 09:34:10.636141	\N	Person #1133	0	unrecognized	2026-08-28 09:34:18.195221
79316	1918	breakout	530	Break Out	27-08-2026 21:56:14	356260	0.85	unrecognized	2026-08-28 11:14:17.765958	\N	Person #530	0	unrecognized	2026-08-28 11:14:31.78822
78458	1918	breakout	204	Break Out	27-08-2026 12:14:09	196104	0.85	normal	2026-08-28 10:28:37.12046	STF-028	Noman Imran	0.4642	recognized	2026-08-28 10:29:07.265977
79311	1918	breakout	527	Break Out	27-08-2026 21:55:21	354881	0.85	unrecognized	2026-08-28 11:13:56.270771	\N	Person #527	0	unrecognized	2026-08-28 11:14:05.765127
79318	1918	breakout	531	Break Out	27-08-2026 21:56:31	356798	0.85	pending	2026-08-28 11:14:32.449159	\N	Person #531	\N	pending	\N
79200	1918	breakout	436	Break Out	27-08-2026 13:55:01	351533	0.85	pending	2026-08-28 11:06:41.339387	\N	Person #436	\N	pending	\N
78465	1918	breakout	206	Break Out	27-08-2026 12:14:50	197088	0.85	unrecognized	2026-08-28 10:29:16.997262	\N	Person #206	0	unrecognized	2026-08-28 10:29:40.309687
77643	1917	breakin	1135	Break In	27-08-2026 17:15:15	295059	0.85	normal	2026-08-28 09:34:25.512278	STF-027	Ahmed Hassan Bhatti	0.4546	recognized	2026-08-28 09:34:26.528321
77639	1917	breakin	1113	Break In	27-08-2026 17:14:07	293225	0.85	normal	2026-08-28 09:34:00.247492	STF-032	Muhammad Yaseen	0.4791	recognized	2026-08-28 09:34:01.495608
77634	1917	breakin	1129	Break In	27-08-2026 17:13:14	291729	0.85	unrecognized	2026-08-28 09:33:34.583812	\N	Person #1129	0	unrecognized	2026-08-28 09:33:42.776803
79211	1918	breakout	439	Break Out	27-08-2026 14:00:01	354939	0.85	normal	2026-08-28 11:07:28.823406	STF-005	Muhammad Ayaz Hussain	0.5039	recognized	2026-08-28 11:07:31.708607
77644	1917	breakin	1113	Break In	27-08-2026 17:17:00	297720	0.85	normal	2026-08-28 09:34:35.715292	STF-032	Muhammad Yaseen	0.4401	recognized	2026-08-28 09:34:35.780119
77664	1917	breakin	1145	Break In	27-08-2026 17:19:39	301143	0.85	normal	2026-08-28 09:35:49.21949	STF-025	Farhan Virk	0.4445	recognized	2026-08-28 09:36:01.574316
79310	1918	breakout	526	Break Out	27-08-2026 21:54:45	354105	0.85	normal	2026-08-28 11:13:52.320427	STF-065	Muhammad Junaid Aqeel	0.4474	recognized	2026-08-28 11:13:54.251981
77653	1917	breakin	1113	Break In	27-08-2026 17:17:57	299002	0.85	normal	2026-08-28 09:35:22.811875	STF-032	Muhammad Yaseen	0.468	recognized	2026-08-28 09:35:25.435657
78817	1918	breakout	354	Break Out	27-08-2026 20:49:11	255662	0.85	unrecognized	2026-08-28 10:46:37.198588	\N	Person #354	0	unrecognized	2026-08-28 10:46:56.537213
79314	1918	breakout	528	Break Out	27-08-2026 21:55:51	355657	0.85	unrecognized	2026-08-28 11:14:06.266358	\N	Person #528	0	unrecognized	2026-08-28 11:14:12.00151
79207	1918	breakout	437	Break Out	27-08-2026 13:59:05	353345	0.85	unrecognized	2026-08-28 11:06:54.456271	\N	Person #437	0	unrecognized	2026-08-28 11:07:27.761769
77666	1917	breakin	1146	Break In	27-08-2026 17:20:09	302438	0.85	normal	2026-08-28 09:36:03.472726	STF-028	Noman Imran	0.4556	recognized	2026-08-28 09:36:03.964343
77663	1917	breakin	1113	Break In	27-08-2026 17:19:24	301143	0.85	normal	2026-08-28 09:35:49.073845	STF-032	Muhammad Yaseen	0.5671	recognized	2026-08-28 09:35:55.737985
77677	1917	breakin	1152	Break In	27-08-2026 17:23:13	306925	0.85	unrecognized	2026-08-28 09:36:53.904976	\N	Person #1152	0	unrecognized	2026-08-28 09:37:03.752214
77672	1917	breakin	1113	Break In	27-08-2026 17:21:00	304947	0.85	normal	2026-08-28 09:36:17.579765	STF-032	Muhammad Yaseen	0.5073	recognized	2026-08-28 09:36:17.593757
77673	1917	breakin	1147	Break In	27-08-2026 17:22:00	305181	0.85	normal	2026-08-28 09:36:18.393212	STF-018	Muhammad Qaiser Shahzad	0.4486	recognized	2026-08-28 09:36:19.882314
77676	1917	breakin	1150	Break In	27-08-2026 17:22:49	306373	0.85	unrecognized	2026-08-28 09:36:40.292636	\N	Person #1150	0	unrecognized	2026-08-28 09:36:45.180273
77678	1917	breakin	1153	Break In	27-08-2026 17:23:52	308006	0.85	normal	2026-08-28 09:37:04.34143	STF-032	Muhammad Yaseen	0.5617	recognized	2026-08-28 09:37:04.35542
77703	1917	breakin	1178	Break In	27-08-2026 17:41:57	335091	0.85	normal	2026-08-28 09:39:11.684063	STF-029	Abdul Rehman Sultan	0.4712	recognized	2026-08-28 09:39:12.282983
78467	1918	breakout	232	Break Out	27-08-2026 15:22:20	122392	0.85	unrecognized	2026-08-28 10:29:27.382477	\N	Person #232	0	unrecognized	2026-08-28 10:29:39.806985
77684	1917	breakin	1156	Break In	27-08-2026 17:30:28	317868	0.85	normal	2026-08-28 09:37:35.175583	STF-018	Muhammad Qaiser Shahzad	0.4929	recognized	2026-08-28 09:37:37.536069
78459	1918	breakout	224	Break Out	27-08-2026 15:20:30	119740	0.85	normal	2026-08-28 10:28:44.524835	STF-035	Hammad Shaukat	0.4755	recognized	2026-08-28 10:28:45.130264
77681	1917	breakin	1155	Break In	27-08-2026 17:28:02	314181	0.85	unrecognized	2026-08-28 09:37:21.582685	\N	Person #1155	0	unrecognized	2026-08-28 09:37:29.668987
79060	1918	breakout	382	Break Out	27-08-2026 13:43:15	329579	0.85	unrecognized	2026-08-28 11:00:28.614219	\N	Person #382	0	unrecognized	2026-08-28 11:00:41.575258
78815	1918	breakout	300	Break Out	27-08-2026 13:06:26	274521	0.85	unrecognized	2026-08-28 10:46:32.78583	\N	Person #300	0	unrecognized	2026-08-28 10:47:07.331227
77712	1917	breakin	1179	Break In	27-08-2026 17:46:30	341357	0.85	unrecognized	2026-08-28 09:39:51.179181	\N	Person #1179	0	unrecognized	2026-08-28 09:40:04.573169
77688	1917	breakin	1158	Break In	27-08-2026 17:34:04	323298	0.85	normal	2026-08-28 09:37:52.812945	STF-029	Abdul Rehman Sultan	0.4799	recognized	2026-08-28 09:37:54.058158
77685	1917	breakin	1156	Break In	27-08-2026 17:32:24	320776	0.85	normal	2026-08-28 09:37:39.912641	STF-052	Syed Imran Shah	0.5156	recognized	2026-08-28 09:37:41.963991
79050	1918	breakout	379	Break Out	27-08-2026 13:42:15	328225	0.85	unrecognized	2026-08-28 10:59:39.289822	\N	Person #379	0	unrecognized	2026-08-28 10:59:51.598644
78461	1918	breakout	226	Break Out	27-08-2026 15:21:14	120548	0.85	unrecognized	2026-08-28 10:28:48.097771	\N	Person #226	0	unrecognized	2026-08-28 10:29:07.935081
77706	1917	breakin	1176	Break In	27-08-2026 17:43:19	337112	0.85	unrecognized	2026-08-28 09:39:26.636594	\N	Person #1176	0	unrecognized	2026-08-28 09:39:33.869295
77683	1917	breakin	1156	Break In	27-08-2026 17:30:09	317400	0.85	normal	2026-08-28 09:37:30.930721	STF-009	Tariq Ghulam Hussain	0.4771	recognized	2026-08-28 09:37:33.393369
79206	1918	breakout	474	Break Out	27-08-2026 21:25:40	310430	0.85	unrecognized	2026-08-28 11:06:53.001596	\N	Person #474	0	unrecognized	2026-08-28 11:07:00.51717
77689	1917	breakin	1159	Break In	27-08-2026 17:34:16	323594	0.85	normal	2026-08-28 09:37:55.535945	STF-046	Usman Babar	0.5232	recognized	2026-08-28 09:37:56.542232
77679	1917	breakin	1154	Break In	27-08-2026 17:25:27	310249	0.85	unrecognized	2026-08-28 09:37:06.476267	\N	Person #1154	0	unrecognized	2026-08-28 09:37:18.391243
79201	1918	breakout	471	Break Out	27-08-2026 21:21:03	303519	0.85	normal	2026-08-28 11:06:41.782272	STF-029	Abdul Rehman Sultan	0.4969	recognized	2026-08-28 11:06:43.76712
77690	1917	breakin	1161	Break In	27-08-2026 17:35:14	325060	0.85	normal	2026-08-28 09:37:58.929014	STF-052	Syed Imran Shah	0.4438	recognized	2026-08-28 09:37:58.951953
79055	1918	breakout	380	Break Out	27-08-2026 13:42:40	328822	0.85	unrecognized	2026-08-28 10:59:52.235554	\N	Person #380	0	unrecognized	2026-08-28 11:00:18.918828
77680	1917	breakin	1154	Break In	27-08-2026 17:27:18	313161	0.85	normal	2026-08-28 09:37:19.310004	STF-017	Mohammad Zahid	0.4929	recognized	2026-08-28 09:37:19.79193
79205	1918	breakout	472	Break Out	27-08-2026 21:21:37	304419	0.85	normal	2026-08-28 11:06:47.232108	STF-045	Zohaib Ali Chaudhary	0.4614	recognized	2026-08-28 11:06:47.256044
77692	1917	breakin	1163	Break In	27-08-2026 17:36:31	326891	0.85	unrecognized	2026-08-28 09:38:07.90799	\N	Person #1163	0	unrecognized	2026-08-28 09:38:14.819876
79208	1918	breakout	476	Break Out	27-08-2026 21:25:59	310825	0.85	unrecognized	2026-08-28 11:07:01.292435	\N	Person #476	0	unrecognized	2026-08-28 11:07:21.327571
77696	1917	breakin	1168	Break In	27-08-2026 17:40:23	332772	0.85	normal	2026-08-28 09:38:39.130212	STF-011	Syed Shoaib Ahmad Alvi	0.4565	recognized	2026-08-28 09:38:39.778405
77702	1917	breakin	1178	Break In	27-08-2026 17:41:00	334844	0.85	normal	2026-08-28 09:39:04.972977	STF-029	Abdul Rehman Sultan	0.549	recognized	2026-08-28 09:39:04.98598
79320	1918	breakout	480	Break Out	27-08-2026 17:57:08	354654	0.85	normal	2026-08-28 11:14:32.60752	STF-002	Abdur Rehman	0.4443	recognized	2026-08-28 11:14:34.281292
77693	1917	breakin	1164	Break In	27-08-2026 17:37:12	327955	0.85	normal	2026-08-28 09:38:15.406346	STF-009	Tariq Ghulam Hussain	0.5125	recognized	2026-08-28 09:38:16.602723
77694	1917	breakin	1166	Break In	27-08-2026 17:38:52	330343	0.85	unrecognized	2026-08-28 09:38:19.533325	\N	Person #1166	0	unrecognized	2026-08-28 09:38:27.930619
77710	1917	breakin	1180	Break In	27-08-2026 17:45:36	340602	0.85	normal	2026-08-28 09:39:39.526756	STF-052	Syed Imran Shah	0.7265	recognized	2026-08-28 09:39:39.54673
77713	1917	breakin	1181	Break In	27-08-2026 17:49:23	346290	0.85	normal	2026-08-28 09:40:06.039482	STF-011	Syed Shoaib Ahmad Alvi	0.6664	recognized	2026-08-28 09:40:06.052985
77714	1917	breakin	1181	Break In	27-08-2026 17:51:00	348688	0.85	normal	2026-08-28 09:40:07.722368	STF-030	Dildar Ahmed	0.5384	recognized	2026-08-28 09:40:08.594069
77718	1917	breakin	1184	Break In	27-08-2026 17:53:10	351648	0.85	unrecognized	2026-08-28 09:40:38.806759	\N	Person #1184	0	unrecognized	2026-08-28 09:40:57.436974
77717	1917	breakin	1184	Break In	27-08-2026 17:52:54	351462	0.85	unrecognized	2026-08-28 09:40:28.348571	\N	Person #1184	0	unrecognized	2026-08-28 09:40:38.511845
77721	1917	breakin	1188	Break In	27-08-2026 17:53:00	352636	0.85	unrecognized	2026-08-28 09:41:03.727516	\N	Person #1188	0	unrecognized	2026-08-28 09:41:19.200413
79059	1918	breakout	434	Break Out	27-08-2026 21:09:12	285697	0.85	unrecognized	2026-08-28 11:00:28.171265	\N	Person #434	0	unrecognized	2026-08-28 11:00:34.777573
79054	1918	breakout	433	Break Out	27-08-2026 21:08:24	284410	0.85	unrecognized	2026-08-28 10:59:50.758253	\N	Person #433	0	unrecognized	2026-08-28 11:00:27.068238
78462	1918	breakout	235	Break Out	27-08-2026 19:54:06	173106	0.85	unrecognized	2026-08-28 10:29:05.761857	\N	Person #235	0	unrecognized	2026-08-28 10:29:06.933603
77728	1917	breakin	1189	Break In	27-08-2026 17:54:38	354122	0.85	unrecognized	2026-08-28 09:41:21.426633	\N	Person #1189	0	unrecognized	2026-08-28 09:41:21.5902
77732	1917	breakin	1191	Break In	27-08-2026 17:55:42	355707	0.85	unrecognized	2026-08-28 09:41:35.872335	\N	Person #1191	0	unrecognized	2026-08-28 09:41:36.709883
79321	1918	breakout	481	Break Out	27-08-2026 17:57:41	355442	0.85	unrecognized	2026-08-28 11:14:36.027372	\N	Person #481	0	unrecognized	2026-08-28 11:14:43.336504
77738	1917	breakin	1198	Break In	27-08-2026 17:57:16	358088	0.85	unrecognized	2026-08-28 09:43:02.988751	\N	Person #1198	0	unrecognized	2026-08-28 09:43:05.263748
77733	1917	breakin	1191	Break In	27-08-2026 17:56:05	355858	0.85	unrecognized	2026-08-28 09:41:36.883037	\N	Person #1191	0	unrecognized	2026-08-28 09:41:56.234091
79204	1918	breakout	438	Break Out	27-08-2026 17:21:49	301614	0.85	unrecognized	2026-08-28 11:06:44.210424	\N	Person #438	0	unrecognized	2026-08-28 11:07:29.986753
79322	1918	breakout	482	Break Out	27-08-2026 17:57:56	355539	0.85	unrecognized	2026-08-28 11:14:43.493635	\N	Person #482	0	unrecognized	2026-08-28 11:14:53.683368
77730	1917	breakin	1191	Break In	27-08-2026 17:54:00	354317	0.85	normal	2026-08-28 09:41:22.398849	STF-002	Abdur Rehman	0.5058	recognized	2026-08-28 09:41:24.800053
78826	1918	breakout	306	Break Out	27-08-2026 13:04:27	275905	0.85	pending	2026-08-28 10:47:19.076652	\N	Person #306	0	unrecognized	\N
79323	1918	breakout	483	Break Out	27-08-2026 17:58:04	356112	0.85	pending	2026-08-28 11:14:54.009114	\N	Person #483	0	unrecognized	\N
77729	1917	breakin	1189	Break In	27-08-2026 17:54:59	354305	0.85	unrecognized	2026-08-28 09:41:21.765731	\N	Person #1189	0	unrecognized	2026-08-28 09:41:35.289327
77735	1917	breakin	1194	Break In	27-08-2026 17:56:30	356967	0.85	pending	2026-08-28 09:42:16.126845	\N	Person #1194	\N	pending	\N
79324	1918	breakout	484	Break Out	27-08-2026 17:58:22	356473	0.85	unrecognized	2026-08-28 11:14:55.827309	\N	Person #484	0	unrecognized	2026-08-28 11:15:02.661169
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.permissions (id, name, description, "group") FROM stdin;
1	add_staff	Add new employee records	Staff Management
2	view_staff	View employee profiles and records	Staff Management
3	update_staff	Edit employee profile details	Staff Management
4	remove_staff	Remove or deactivate employee records	Staff Management
5	status_staff	Activate or deactivate employee records	Staff Management
6	change_staff_password	Change staff access password	Staff Management
7	add_branch	Add new branch/office locations	Branch Management
8	view_branch	View branch details and performance metrics	Branch Management
9	update_branch	Modify branch details	Branch Management
10	remove_branch	Deactivate or delete branch locations	Branch Management
11	status_branch	Activate or deactivate branch locations	Branch Management
12	add_department	Add new departments	Department Management
13	view_department	View department configurations	Department Management
14	update_department	Edit department descriptions or names	Department Management
15	remove_department	Remove departments	Department Management
16	status_department	Activate or deactivate departments	Department Management
17	add_user	Add new backend dashboard users	User Management
18	view_user	View list of registered system users	User Management
19	update_user	Edit roles and statuses of system users	User Management
20	remove_user	Deactivate dashboard users	User Management
21	status_user	Activate or deactivate system users	User Management
22	view_reports	Analyze attendance summaries and timelines	Reports
23	export_reports	Download processed Excel reports	Reports
24	view_events	Access dashboard recognition events logs	Reports
25	view_logs	View system execution stdout/stderr logs	Reports
26	control_pipeline	Start, stop, or configure the offline video AI pipeline	Reports
27	manage_roles	Create, modify, or delete roles and permission mappings	Roles & Permissions Admin
\.


--
-- Data for Name: person_track_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.person_track_logs (id, video_log_id, video_name, track_id, master_track_id, status, person_name, person_id, confidence, first_seen_time, last_seen_time, total_hits, created_at) FROM stdin;
\.


--
-- Data for Name: review_queue; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.review_queue (id, event_id, suggested_staff_id, confidence, status, face_crop_path, created_at) FROM stdin;
\.


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role_permissions (role_id, permission_id) FROM stdin;
1	11
1	4
1	26
1	17
1	3
1	18
1	5
1	6
1	25
1	27
1	19
1	1
1	13
1	14
1	7
1	22
1	8
1	15
1	20
1	10
1	9
1	2
1	21
1	23
1	12
1	24
1	16
2	22
2	25
2	24
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, name, is_active, created_at, updated_at) FROM stdin;
1	Admin	t	2026-08-12 14:08:29.420692	2026-08-12 14:08:29.420692
2	Viewer	t	2026-08-12 14:08:29.436479	2026-08-12 14:08:29.436479
\.


--
-- Data for Name: staff; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.staff (id, staff_id, name, email, phone, role, is_active, has_face_encoding, profile_picture, branch_id, department_id, shift_start_time, shift_end_time, is_visitor, visitor_expiry, created_at, updated_at, registration_video) FROM stdin;
842	STF-015	Liaqat Ali	liaqat.ali@accounts.epic.com	\N	Auditor	t	t	/data/profile_pictures/STF-015.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:23:37.066308	2026-08-27 12:27:21.376277	/data/registration_videos/STF-015.mp4
843	STF-016	Muhammad Asad Awan	muhammad.asad.awan@accounts.epic.com	\N	Auditor	t	t	/data/profile_pictures/STF-016.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:23:38.378637	2026-08-27 12:27:22.661846	/data/registration_videos/STF-016.mp4
828	STF-002	Abdur Rehman	faraz.younas@epic.com	456789	Asst. CFO	t	t	/data/profile_pictures/STF-002.jpg	7	95	11:00	20:45	f	\N	2026-08-25 13:47:07.399143	2026-08-27 12:26:36.511323	/data/registration_videos/STF-002.mp4
829	STF-003	Syed Kamran Ali	zubair@epic.com	345678	Inventory Audit Manager	t	t	/data/profile_pictures/STF-003.jpg	7	95	11:00	20:45	f	\N	2026-08-25 13:48:08.858145	2026-08-27 12:26:41.618523	/data/registration_videos/STF-003.mp4
844	STF-017	Mohammad Zahid	mohammad.zahid@accounts.epic.com	\N	Auditor	t	t	/data/profile_pictures/STF-017.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:23:39.698506	2026-08-27 12:27:27.736976	/data/registration_videos/STF-017.mp4
830	STF-004	Tanveer Hassan	shoaib.ahmed@epic.com	23456789	Order Coordinator	t	t	/data/profile_pictures/STF-004.jpg	7	95	11:00	20:45	f	\N	2026-08-25 13:49:07.086808	2026-08-27 12:26:46.485806	/data/registration_videos/STF-004.mp4
832	STF-005	Muhammad Ayaz Hussain	muhammad.ayaz.hussain@accounts.epic.com	\N	Majesty Accountant	t	t	/data/profile_pictures/STF-005.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:22:07.347577	2026-08-27 12:26:51.228706	/data/registration_videos/STF-005.mp4
833	STF-006	Muhammad Abubakar	muhammad.abubakar@accounts.epic.com	\N	Diamond Accountant	t	t	/data/profile_pictures/STF-006.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:22:12.15568	2026-08-27 12:26:56.006401	/data/registration_videos/STF-006.mp4
835	STF-008	Muhammad Shoaib	muhammad.shoaib@accounts.epic.com	\N	Software Developer (Accounts Division)	t	t	/data/profile_pictures/STF-008.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:22:21.520473	2026-08-27 12:27:06.311719	/data/registration_videos/STF-008.mp4
836	STF-009	Tariq Ghulam Hussain	tariq.ghulam.hussain@accounts.epic.com	\N	Senior Accountant	t	t	/data/profile_pictures/STF-009.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:22:26.15851	2026-08-27 12:27:07.466404	/data/registration_videos/STF-009.mp4
837	STF-010	Faraz Younas	faraz.younas@accounts.epic.com	\N	Bank Cor and Tax Accountant	t	t	/data/profile_pictures/STF-010.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:22:27.463658	2026-08-27 12:27:12.658608	/data/registration_videos/STF-010.mp4
838	STF-011	Syed Shoaib Ahmad Alvi	syed.shoaib.ahmad.alvi@accounts.epic.com	\N	Asst. Bank Cor and Tax Accountant	t	t	/data/profile_pictures/STF-011.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:23:29.362426	2026-08-27 12:27:13.902568	/data/registration_videos/STF-011.mp4
840	STF-013	Muhammad Faizan	muhammad.faizan@accounts.epic.com	\N	Assistant Order Coordinator	t	t	/data/profile_pictures/STF-013.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:23:30.669101	2026-08-27 12:27:15.292441	/data/registration_videos/STF-013.mp4
845	STF-018	Muhammad Qaiser Shahzad	muhammad.qaiser.shahzad@accounts.epic.com	\N	Auditor	t	t	/data/profile_pictures/STF-018.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:23:44.85415	2026-08-27 12:27:29.016237	/data/registration_videos/STF-018.mp4
839	STF-012	Muhammad Shozab Latif	muhammad.shozab.latif@accounts.epic.com	\N	Office Executive	t	f	\N	9	95	11:00	20:45	f	\N	2026-08-27 12:23:30.669101	2026-08-27 12:23:30.669101	\N
847	STF-020	Syed Jahazaib Ahmad Alvi	syed.jahazaib.ahmad.alvi@accounts.epic.com	\N	Tagger	t	t	/data/profile_pictures/STF-020.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:23:47.398166	2026-08-27 12:27:35.292041	/data/registration_videos/STF-020.mp4
849	STF-022	Mubashir Ishaq	mubashir.ishaq@accounts.epic.com	\N	Tagger	t	t	/data/profile_pictures/STF-022.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:23:52.04321	2026-08-27 12:27:40.013776	/data/registration_videos/STF-022.mp4
850	STF-023	Syed Zubair Zulfiqar	syed.zubair.zulfiqar@accounts.epic.com	\N	Taxation Trainee	t	t	/data/profile_pictures/STF-023.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:23:56.685598	2026-08-27 12:27:44.852629	/data/registration_videos/STF-023.mp4
851	STF-024	Arsalan Khan	arsalan.khan@accounts.epic.com	\N	Taxation Trainee	t	t	/data/profile_pictures/STF-024.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:24:01.42984	2026-08-27 12:27:49.614734	/data/registration_videos/STF-024.mp4
852	STF-025	Farhan Virk	farhan.virk@accounts.epic.com	\N	Asst. Software Developer	t	t	/data/profile_pictures/STF-025.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:24:06.166105	2026-08-27 12:27:54.348337	/data/registration_videos/STF-025.mp4
848	STF-021	Safeer Ahmed	safeer.ahmed@accounts.epic.com	\N	Tagger	t	f	\N	9	95	11:00	20:45	f	\N	2026-08-27 12:23:52.04321	2026-08-27 12:23:52.04321	\N
854	STF-027	Ahmed Hassan Bhatti	ahmed.hassan.bhatti@accounts.epic.com	\N	Data Entry Operator	t	t	/data/profile_pictures/STF-027.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:24:15.632762	2026-08-27 12:28:00.276862	/data/registration_videos/STF-027.mp4
855	STF-028	Noman Imran	noman.imran@accounts.epic.com	\N	Accounts Trainee	t	t	/data/profile_pictures/STF-028.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:24:16.834727	2026-08-27 12:28:04.861553	/data/registration_videos/STF-028.mp4
856	STF-029	Abdul Rehman Sultan	abdul.rehman.sultan@accounts.epic.com	\N	Accounts Trainee	t	t	/data/profile_pictures/STF-029.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:24:21.545997	2026-08-27 12:28:09.456102	/data/registration_videos/STF-029.mp4
857	STF-030	Dildar Ahmed	dildar.ahmed@accounts.epic.com	\N	Goldsmith	t	t	/data/profile_pictures/STF-030.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:24:26.170868	2026-08-27 12:28:10.727243	/data/registration_videos/STF-030.mp4
858	STF-031	Muhammad Hassan	muhammad.hassan@accounts.epic.com	\N	Trainee	t	t	/data/profile_pictures/STF-031.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:24:27.453011	2026-08-27 12:28:11.877711	/data/registration_videos/STF-031.mp4
860	STF-033	Raza Abbas	raza.abbas@finance.epic.com	\N	Logistics Coordinator	t	t	/data/profile_pictures/STF-033.jpg	9	99	11:00	20:45	f	\N	2026-08-27 12:24:29.857752	2026-08-27 12:28:17.93545	/data/registration_videos/STF-033.mp4
861	STF-034	Muhammad Laeeq	muhammad.laeeq@finance.epic.com	\N	Finance Data Entry Coordinator	t	t	/data/profile_pictures/STF-034.jpg	9	99	11:00	20:45	f	\N	2026-08-27 12:24:34.64559	2026-08-27 12:28:22.870065	/data/registration_videos/STF-034.mp4
862	STF-035	Hammad Shaukat	hammad.shaukat@finance.epic.com	\N	Finance Cashier	t	t	/data/profile_pictures/STF-035.jpg	9	99	11:00	20:45	f	\N	2026-08-27 12:24:39.621903	2026-08-27 12:28:27.709824	/data/registration_videos/STF-035.mp4
863	STF-036	Shahzad Ali	shahzad.ali@finance.epic.com	\N	Finance Cashier	t	t	/data/profile_pictures/STF-036.jpg	9	99	11:00	20:45	f	\N	2026-08-27 12:24:44.386283	2026-08-27 12:28:32.506069	/data/registration_videos/STF-036.mp4
864	STF-037	Muhammad Fahad	muhammad.fahad@finance.epic.com	\N	Finance Cashier	t	t	/data/profile_pictures/STF-037.jpg	9	99	11:00	20:45	f	\N	2026-08-27 12:24:49.11929	2026-08-27 12:28:33.725681	/data/registration_videos/STF-037.mp4
866	STF-039	Muhammad Hussnain	muhammad.hussnain@finance.epic.com	\N	Sales Cashier	t	f	\N	9	99	11:00	20:45	f	\N	2026-08-27 12:24:51.605072	2026-08-27 12:24:51.605072	\N
831	STF-001	Ikram Hassan	ikram.hassan@accounts.epic.com	\N	Head of Accounts	t	t	/data/profile_pictures/STF-001.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:21:45.350177	2026-08-27 12:26:31.05948	/data/registration_videos/STF-001.mp4
871	STF-044	Zaheer Hussain	zaheer.hussain@retailwatches.epic.com	\N	Floor Manager	t	t	/data/profile_pictures/STF-044.jpg	9	100	11:45	21:00	f	\N	2026-08-27 12:24:55.348207	2026-08-27 12:28:39.93112	/data/registration_videos/STF-044.mp4
872	STF-045	Zohaib Ali Chaudhary	zohaib.ali.chaudhary@retailwatches.epic.com	\N	Sale Assistant	t	t	/data/profile_pictures/STF-045.jpg	9	100	11:45	21:00	f	\N	2026-08-27 12:24:56.556479	2026-08-27 12:28:41.13422	/data/registration_videos/STF-045.mp4
870	STF-043	Mirza Arif Baig	mirza.arif.baig@retailwatches.epic.com	\N	Retail Specialist	t	f	\N	9	100	11:45	21:00	f	\N	2026-08-27 12:24:55.347201	2026-08-27 12:24:55.347201	\N
873	STF-046	Usman Babar	usman.babar@retailwatches.epic.com	\N	Inventory In-charge	t	t	/data/profile_pictures/STF-046.jpg	9	100	11:45	21:00	f	\N	2026-08-27 12:24:57.882201	2026-08-27 12:28:42.332295	/data/registration_videos/STF-046.mp4
874	STF-047	Arshad Irshad	arshad.irshad@retailwatches.epic.com	\N	Sale Trainee	t	t	/data/profile_pictures/STF-047.jpg	9	100	11:45	21:00	f	\N	2026-08-27 12:24:59.115335	2026-08-27 12:28:43.538211	/data/registration_videos/STF-047.mp4
875	STF-048	Abdullah Sultan	abdullah.sultan@retailwatches.epic.com	\N	Wingamn	t	t	/data/profile_pictures/STF-048.jpg	9	100	11:45	21:00	f	\N	2026-08-27 12:25:00.357713	2026-08-27 12:28:44.718745	/data/registration_videos/STF-048.mp4
877	STF-050	Hafeez-Ur-Rehman	hafeezurrehman@retailwatches.epic.com	\N	Watch Maker	t	t	/data/profile_pictures/STF-050.jpg	9	100	11:45	21:00	f	\N	2026-08-27 12:25:02.842021	2026-08-27 12:28:47.208025	/data/registration_videos/STF-050.mp4
878	STF-051	Shakir Khan	shakir.khan@jewellerygold.epic.com	\N	Senior Sales Executive (Gold Division)	t	t	/data/profile_pictures/STF-051.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:25:04.088606	2026-08-27 12:28:51.532412	/data/registration_videos/STF-051.mp4
879	STF-052	Syed Imran Shah	syed.imran.shah@jewellerygold.epic.com	\N	Bank Coordinator	t	t	/data/profile_pictures/STF-052.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:25:08.57621	2026-08-27 12:28:52.722089	/data/registration_videos/STF-052.mp4
880	STF-053	Rehan Sarwar	rehan.sarwar@jewellerygold.epic.com	\N	Sales Executive (Gold Division)	t	t	/data/profile_pictures/STF-053.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:25:09.755826	2026-08-27 12:28:57.099647	/data/registration_videos/STF-053.mp4
882	STF-055	Rizwan Butt	rizwan.butt@jewellerygold.epic.com	\N	Sales Executive (Gold Division)	t	t	/data/profile_pictures/STF-055.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:25:18.943182	2026-08-27 12:29:06.098143	/data/registration_videos/STF-055.mp4
883	STF-056	Imran Waheed Butt	imran.waheed.butt@jewellerygold.epic.com	\N	Sales Executive (Gold Division)	t	t	/data/profile_pictures/STF-056.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:25:23.51293	2026-08-27 12:29:07.645713	/data/registration_videos/STF-056.mp4
884	STF-057	Zahid Ali	zahid.ali@jewellerygold.epic.com	\N	Sales Executive (Gold Division)	t	t	/data/profile_pictures/STF-057.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:25:24.754068	2026-08-27 12:29:08.838669	/data/registration_videos/STF-057.mp4
885	STF-058	Muhammad Iqbal Butt	muhammad.iqbal.butt@jewellerygold.epic.com	\N	Sales Assistant (Gold Division)	t	t	/data/profile_pictures/STF-058.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:25:25.98512	2026-08-27 12:29:10.098837	/data/registration_videos/STF-058.mp4
886	STF-059	Muhammad Rehan	muhammad.rehan@jewellerygold.epic.com	\N	Sales Assistant (Gold Division)	t	t	/data/profile_pictures/STF-059.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:25:27.176733	2026-08-27 12:29:11.325732	/data/registration_videos/STF-059.mp4
888	STF-061	Amna Saleem	amna.saleem@jewellerygold.epic.com	\N	CRO	t	t	/data/profile_pictures/STF-061.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:25:32.914106	2026-08-27 12:29:20.329874	/data/registration_videos/STF-061.mp4
889	STF-062	Shahbaz Hussain	shahbaz.hussain@jewellerygold.epic.com	\N	Sales Trainee	t	t	/data/profile_pictures/STF-062.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:25:37.589154	2026-08-27 12:29:21.550027	/data/registration_videos/STF-062.mp4
890	STF-063	Muhammad Huzaifah	muhammad.huzaifah@jewellerygold.epic.com	\N	Sales Trainee	t	t	/data/profile_pictures/STF-063.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:25:38.953186	2026-08-27 12:29:25.982722	/data/registration_videos/STF-063.mp4
891	STF-064	Muhammad Arsalan	muhammad.arsalan@jewellerygold.epic.com	\N	Sales Trainee	t	t	/data/profile_pictures/STF-064.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:25:43.574061	2026-08-27 12:29:27.430635	/data/registration_videos/STF-064.mp4
892	STF-065	Muhammad Junaid Aqeel	muhammad.junaid.aqeel@jewellerygold.epic.com	\N	Sales Trainee	t	t	/data/profile_pictures/STF-065.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:25:44.837441	2026-08-27 12:29:28.561277	/data/registration_videos/STF-065.mp4
893	STF-066	Hanan Ashraf	hanan.ashraf@jewellerygold.epic.com	\N	Sales Trainee	t	t	/data/profile_pictures/STF-066.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:25:46.005254	2026-08-27 12:29:29.864335	/data/registration_videos/STF-066.mp4
895	STF-068	Muhammad Kashif	muhammad.kashif@jewellerygold.epic.com	\N	Wing man	t	t	/data/profile_pictures/STF-068.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:25:51.714233	2026-08-27 12:29:35.834106	/data/registration_videos/STF-068.mp4
896	STF-069	Mehmood Ali	mehmood.ali@jewellerygold.epic.com	\N	Wing man	t	t	/data/profile_pictures/STF-069.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:25:52.945884	2026-08-27 12:29:40.166361	/data/registration_videos/STF-069.mp4
897	STF-070	Amanat Ali	amanat.ali@jewellerygold.epic.com	\N	Wing man	t	t	/data/profile_pictures/STF-070.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:25:57.449842	2026-08-27 12:29:41.564524	/data/registration_videos/STF-070.mp4
898	STF-071	Muhammad Daniyal Abid	muhammad.daniyal.abid@jewellerygold.epic.com	\N	Wing man	t	t	/data/profile_pictures/STF-071.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:25:58.657804	2026-08-27 12:29:46.035035	/data/registration_videos/STF-071.mp4
899	STF-072	Fahad Ali	fahad.ali@jewellerygold.epic.com	\N	Wing man	t	t	/data/profile_pictures/STF-072.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:26:03.143401	2026-08-27 12:29:47.32926	/data/registration_videos/STF-072.mp4
901	STF-074	Abdullah Abdul Razzaq	abdullah.abdul.razzaq@jewellerygold.epic.com	\N	Wingman	t	t	/data/profile_pictures/STF-074.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:26:05.590227	2026-08-27 12:29:49.779591	/data/registration_videos/STF-074.mp4
902	STF-075	Muhammad Bilal Gujjar	muhammad.bilal.gujjar@jewellerygold.epic.com	\N	Wingman	t	t	/data/profile_pictures/STF-075.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:26:06.871896	2026-08-27 12:29:53.593895	/data/registration_videos/STF-075.mp4
903	STF-076	Abdul Hanan Khalid	abdul.hanan.khalid@jewellerygold.epic.com	\N	Wingman	t	t	/data/profile_pictures/STF-076.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:26:10.778998	2026-08-27 12:29:54.850079	/data/registration_videos/STF-076.mp4
904	STF-077	Jawad Ahmed	jawad.ahmed@jewellerygold.epic.com	\N	SKU	t	t	/data/profile_pictures/STF-077.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:26:12.157005	2026-08-27 12:29:56.415042	/data/registration_videos/STF-077.mp4
867	STF-040	Arslan Nadeem	arslan.nadeem@finance.epic.com	\N	Sales Cashier	t	t	/data/profile_pictures/STF-040.jpg	9	99	11:00	20:45	f	\N	2026-08-27 12:24:51.620693	2026-08-27 12:28:36.14982	/data/registration_videos/STF-040.mp4
868	STF-041	Sharjeel Abass	sharjeel.abass@finance.epic.com	\N	Sales Cashier	t	t	/data/profile_pictures/STF-041.jpg	9	99	11:00	20:45	f	\N	2026-08-27 12:24:52.902598	2026-08-27 12:28:37.340358	/data/registration_videos/STF-041.mp4
908	STF-081	Rizwan-ul-Mehdi	rizwanulmehdi@jewellerydiamond.epic.com	\N	Sales Executive	t	f	\N	9	102	11:45	21:00	f	\N	2026-08-27 12:26:20.899879	2026-08-27 12:26:20.899879	\N
909	STF-082	Zubair Safdar Butt	zubair.safdar.butt@jewellerydiamond.epic.com	\N	Manager (Diamond Division)	t	f	\N	9	102	11:45	21:00	f	\N	2026-08-27 12:26:20.899879	2026-08-27 12:26:20.899879	\N
834	STF-007	Faisal Saleem	faisal.saleem@accounts.epic.com	\N	Software Developer (Accounts Division)	t	t	/data/profile_pictures/STF-007.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:22:16.844934	2026-08-27 12:27:01.441057	/data/registration_videos/STF-007.mp4
841	STF-014	Muhammad Asif	muhammad.asif@accounts.epic.com	\N	Auditor	t	t	/data/profile_pictures/STF-014.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:23:32.129142	2026-08-27 12:27:20.000963	/data/registration_videos/STF-014.mp4
853	STF-026	Syed Zeeshan Ali	syed.zeeshan.ali@accounts.epic.com	\N	Accounts Photographer	t	t	/data/profile_pictures/STF-026.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:24:10.765753	2026-08-27 12:27:59.079861	/data/registration_videos/STF-026.mp4
859	STF-032	Muhammad Yaseen	muhammad.yaseen@accounts.epic.com	\N	Trainee	t	t	/data/profile_pictures/STF-032.jpg	9	95	11:00	20:45	f	\N	2026-08-27 12:24:28.613506	2026-08-27 12:28:13.068909	/data/registration_videos/STF-032.mp4
865	STF-038	Kazi Abdul Manan	kazi.abdul.manan@finance.epic.com	\N	Finance Cashier	t	t	/data/profile_pictures/STF-038.jpg	9	99	11:00	20:45	f	\N	2026-08-27 12:24:50.351674	2026-08-27 12:28:34.911679	/data/registration_videos/STF-038.mp4
869	STF-042	Faraz Khan	faraz.khan@finance.epic.com	\N	Sales Cashier	t	t	/data/profile_pictures/STF-042.jpg	9	99	11:00	20:45	f	\N	2026-08-27 12:24:54.161764	2026-08-27 12:28:38.766675	/data/registration_videos/STF-042.mp4
876	STF-049	Nabi Ul Haq	nabi.ul.haq@retailwatches.epic.com	\N	Senior Watch Maker	t	t	/data/profile_pictures/STF-049.jpg	9	100	11:45	21:00	f	\N	2026-08-27 12:25:01.605073	2026-08-27 12:28:45.924875	/data/registration_videos/STF-049.mp4
881	STF-054	Syed Ali Raza	syed.ali.raza@jewellerygold.epic.com	\N	Sales Executive (Gold Division)	t	t	/data/profile_pictures/STF-054.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:25:14.398092	2026-08-27 12:29:01.543955	/data/registration_videos/STF-054.mp4
887	STF-060	Muhammad Ahmed Shehzad	muhammad.ahmed.shehzad@jewellerygold.epic.com	\N	Sales Assistant (Gold Division)	t	t	/data/profile_pictures/STF-060.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:25:28.462919	2026-08-27 12:29:15.704575	/data/registration_videos/STF-060.mp4
894	STF-067	Abdullah Abdullah	abdullah.abdullah@jewellerygold.epic.com	\N	Wing man	t	t	/data/profile_pictures/STF-067.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:25:47.226712	2026-08-27 12:29:34.506175	/data/registration_videos/STF-067.mp4
900	STF-073	Waqar Ashraf	waqar.ashraf@jewellerygold.epic.com	\N	Wingman	t	t	/data/profile_pictures/STF-073.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:26:04.378483	2026-08-27 12:29:48.470015	/data/registration_videos/STF-073.mp4
905	STF-078	Syed Shehryar Ahmed	syed.shehryar.ahmed@jewellerygold.epic.com	\N	SKU	t	t	/data/profile_pictures/STF-078.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:26:13.393255	2026-08-27 12:29:57.661459	/data/registration_videos/STF-078.mp4
906	STF-079	Hafiz Sohail Afzal	hafiz.sohail.afzal@jewellerygold.epic.com	\N	SKU	t	t	/data/profile_pictures/STF-079.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:26:14.67516	2026-08-27 12:30:02.489694	/data/registration_videos/STF-079.mp4
907	STF-080	Muhammad Faisal	muhammad.faisal@jewellerygold.epic.com	\N	SKU	t	t	/data/profile_pictures/STF-080.jpg	9	101	11:45	21:00	f	\N	2026-08-27 12:26:19.483733	2026-08-27 12:30:03.746107	/data/registration_videos/STF-080.mp4
910	STF-083	Ibrahim Tariq	ibrahim.tariq@jewellerydiamond.epic.com	\N	Sales Trainee	t	t	/data/profile_pictures/STF-083.jpg	9	102	11:45	21:00	f	\N	2026-08-27 12:26:20.899879	2026-08-27 12:30:08.13713	/data/registration_videos/STF-083.mp4
911	STF-084	Naseer Ahmed	naseer.ahmed@jewellerydiamond.epic.com	\N	Wing man	t	t	/data/profile_pictures/STF-084.jpg	9	102	11:45	21:00	f	\N	2026-08-27 12:26:25.927141	2026-08-27 12:30:12.716798	/data/registration_videos/STF-084.mp4
912	STF-085	Syed Talha Ali	syed.talha.ali@jewellerydiamond.epic.com	\N	Wing man	t	t	/data/profile_pictures/STF-085.jpg	9	102	11:45	21:00	f	\N	2026-08-27 12:26:31.347647	2026-08-27 12:30:17.036435	/data/registration_videos/STF-085.mp4
913	STF-086	Muhammad Moaaz Khan	admin@epic.com	12345678912	STAFF	t	t	/uploads/photos/STF-086_cropped_avatar.jpg	7	95	11:00 AM	08:45 PM	f	\N	2026-08-27 16:22:21.256588	2026-08-27 16:22:47.883794	/uploads/videos/STF-086_registration.mp4
\.


--
-- Data for Name: system_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.system_logs (id, "timestamp", level, module, message) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, email, hashed_password, full_name, role, role_id, department_id, is_active, is_super_admin, is_first_login, created_at, last_login, reset_token) FROM stdin;
1	admin	admin@epic.com	$2b$12$okDd9lqJ7J0ihJYNhNGxDOaliSHrs0Z4X6IA8rRgibeaS1ichM./e	EPIC Administrator	admin	1	\N	t	t	f	2026-08-12 14:08:29.715094	2026-08-31 14:47:30.63512	\N
\.


--
-- Data for Name: video_processing_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.video_processing_logs (id, video_name, video_start_timestamp, total_frames_processed, total_unique_tracks, authorized_count, unauthorized_count, authorized_persons, processed_at) FROM stdin;
\.


--
-- Data for Name: videos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.videos (id, filename, folder_type, file_path, file_size_mb, duration_seconds, resolution, fps, video_start_time, camera_name, status, created_at) FROM stdin;
1890	200.0.0.25_ch5_20260810100001_20260810220000.mp4	Attendance	D:\\EEpic\\web-admin-backend\\data\\raw\\attendance\\200.0.0.25_ch5_20260810100001_20260810220000.mp4	\N	\N	\N	\N	10-08-2026 10:00:01	Attendance	completed	2026-08-20 21:02:08.666253
1893	200.0.0.25_ch5_20260811110000_20260811225919.mp4	Attendance	D:\\EEpic\\web-admin-backend\\data\\raw\\attendance\\200.0.0.25_ch5_20260811110000_20260811225919.mp4	\N	\N	\N	\N	11-08-2026 11:00:00	Attendance	completed	2026-08-20 21:02:08.673233
1891	200.0.0.25_ch1_20260810110001_20260810235915.mp4	breakin	D:\\EEpic\\web-admin-backend\\data\\raw\\breakin\\200.0.0.25_ch1_20260810110001_20260810235915.mp4	\N	\N	\N	\N	10-08-2026 11:00:01	Breakin	completed	2026-08-20 21:02:08.670242
1894	200.0.0.25_ch1_20260811105825_20260811230105.mp4	breakin	D:\\EEpic\\web-admin-backend\\data\\raw\\breakin\\200.0.0.25_ch1_20260811105825_20260811230105.mp4	\N	\N	\N	\N	11-08-2026 10:58:25	Breakin	completed	2026-08-20 21:02:08.675229
1892	200.0.0.25_ch2_20260810110003_20260810235959.mp4	breakout	D:\\EEpic\\web-admin-backend\\data\\raw\\breakout\\200.0.0.25_ch2_20260810110003_20260810235959.mp4	\N	\N	\N	\N	10-08-2026 11:00:03	Breakout	completed	2026-08-20 21:02:08.67124
1949	200.0.0.25_ch5_20260825185502_20260825190459.mp4	attendance	D:\\EEpic\\web-admin-backend\\data\\raw\\attendance\\200.0.0.25_ch5_20260825185502_20260825190459.mp4	22.54	598.04	1920x1080	25	25-08-2026 18:55:02	Focus Building	completed	2026-08-28 14:20:03.18393
1950	200.0.0.25_ch1_20260825185500_20260825190459.mp4	breakin	D:\\EEpic\\web-admin-backend\\data\\raw\\Breakin\\200.0.0.25_ch1_20260825185500_20260825190459.mp4	105.79	600	1280x720	25	25-08-2026 18:55:00	21257	completed	2026-08-28 14:20:11.673183
1951	200.0.0.25_ch2_20260825185503_20260825190459.mp4	breakout	D:\\EEpic\\web-admin-backend\\data\\raw\\Breakout\\200.0.0.25_ch2_20260825185503_20260825190459.mp4	74.86	592	1280x720	25	25-08-2026 18:55:03	Qutdoor Main Ent cam2	completed	2026-08-28 14:20:21.102692
1897	200.0.0.25_ch1_20260812100144_20260812215934.mp4	breakin	D:\\EEpic\\web-admin-backend\\data\\raw\\breakin\\200.0.0.25_ch1_20260812100144_20260812215934.mp4	\N	\N	\N	\N	12-08-2026 10:01:44	Breakin	completed	2026-08-20 21:02:08.681213
1900	200.0.0.25_ch1_20260813100051_20260813215934.mp4	breakin	D:\\EEpic\\web-admin-backend\\data\\raw\\breakin\\200.0.0.25_ch1_20260813100051_20260813215934.mp4	\N	\N	\N	\N	13-08-2026 10:00:51	Breakin	completed	2026-08-20 21:02:08.685202
1905	200.0.0.25_ch1_20260818100001_20260818215919.mp4	breakin	D:\\EEpic\\web-admin-backend\\data\\raw\\breakin\\200.0.0.25_ch1_20260818100001_20260818215919.mp4	\N	\N	\N	\N	18-08-2026 10:00:01	Breakin	completed	2026-08-22 14:38:45.657585
1898	200.0.0.25_ch2_20260812100144_20260812215816.mp4	breakout	D:\\EEpic\\web-admin-backend\\data\\raw\\breakout\\200.0.0.25_ch2_20260812100144_20260812215816.mp4	\N	\N	\N	\N	12-08-2026 10:01:44	Breakout	completed	2026-08-20 21:02:08.68221
1901	200.0.0.25_ch2_20260813100001_20260813215606.mp4	breakout	D:\\EEpic\\web-admin-backend\\data\\raw\\breakout\\200.0.0.25_ch2_20260813100001_20260813215606.mp4	\N	\N	\N	\N	13-08-2026 10:00:01	Breakout	completed	2026-08-20 21:02:08.687197
1903	200.0.0.25_ch2_20260817100019_20260817215908.mp4	breakout	D:\\EEpic\\web-admin-backend\\data\\raw\\breakout\\200.0.0.25_ch2_20260817100019_20260817215908.mp4	\N	\N	\N	\N	17-08-2026 10:00:19	Breakout	completed	2026-08-20 21:02:08.690189
1906	200.0.0.25_ch2_20260818100200_20260818220000.mp4	breakout	D:\\EEpic\\web-admin-backend\\data\\raw\\breakout\\200.0.0.25_ch2_20260818100200_20260818220000.mp4	\N	\N	\N	\N	18-08-2026 10:02:00	Breakout	completed	2026-08-22 14:38:45.65958
1896	200.0.0.25_ch5_20260812100003_20260812215842.mp4	Attendance	D:\\EEpic\\web-admin-backend\\data\\raw\\attendance\\200.0.0.25_ch5_20260812100003_20260812215842.mp4	\N	\N	\N	\N	12-08-2026 10:00:03	Attendance	completed	2026-08-20 21:02:08.679218
1899	200.0.0.25_ch5_20260813100051_20260813220000.mp4	Attendance	D:\\EEpic\\web-admin-backend\\data\\raw\\attendance\\200.0.0.25_ch5_20260813100051_20260813220000.mp4	\N	\N	\N	\N	13-08-2026 10:00:51	Attendance	completed	2026-08-20 21:02:08.684205
1902	200.0.0.25_ch5_20260817100000_20260817215934.mp4	Attendance	D:\\EEpic\\web-admin-backend\\data\\raw\\attendance\\200.0.0.25_ch5_20260817100000_20260817215934.mp4	\N	\N	\N	\N	17-08-2026 10:00:00	Attendance	completed	2026-08-20 21:02:08.689191
1904	200.0.0.25_ch5_20260818100200_20260818215839.mp4	Attendance	D:\\EEpic\\web-admin-backend\\data\\raw\\attendance\\200.0.0.25_ch5_20260818100200_20260818215839.mp4	\N	\N	\N	\N	18-08-2026 10:02:00	Attendance	completed	2026-08-22 14:38:45.646614
1907	200.0.0.25_ch5_20260819100001_20260819215759.mp4	Attendance	D:\\EEpic\\web-admin-backend\\data\\raw\\attendance\\200.0.0.25_ch5_20260819100001_20260819215759.mp4	\N	\N	\N	\N	19-08-2026 10:00:01	Attendance	completed	2026-08-22 14:38:45.660577
1916	200.0.0.25_ch5_20260827100025_20260827220000.mp4	Attendance	D:\\EEpic\\web-admin-backend\\data\\raw\\attendance\\200.0.0.25_ch5_20260827100025_20260827220000.mp4	\N	\N	\N	\N	27-08-2026 10:00:25	Attendance	completed	2026-08-27 18:22:39.593369
1908	200.0.0.25_ch1_20260819100002_20260819215919.mp4	breakin	D:\\EEpic\\web-admin-backend\\data\\raw\\breakin\\200.0.0.25_ch1_20260819100002_20260819215919.mp4	\N	\N	\N	\N	19-08-2026 10:00:02	Breakin	completed	2026-08-22 14:38:45.662572
1917	200.0.0.25_ch1_20260827100017_20260827220000.mp4	breakin	D:\\EEpic\\web-admin-backend\\data\\raw\\breakin\\200.0.0.25_ch1_20260827100017_20260827220000.mp4	\N	\N	\N	\N	27-08-2026 10:00:17	Breakin	completed	2026-08-27 18:22:39.593369
1895	200.0.0.25_ch2_20260811105825_20260811231148.mp4	breakout	D:\\EEpic\\web-admin-backend\\data\\raw\\breakout\\200.0.0.25_ch2_20260811105825_20260811231148.mp4	\N	\N	\N	\N	11-08-2026 10:58:25	Breakout	completed	2026-08-20 21:02:08.677223
1909	200.0.0.25_ch2_20260819100001_20260819215839.mp4	breakout	D:\\EEpic\\web-admin-backend\\data\\raw\\breakout\\200.0.0.25_ch2_20260819100001_20260819215839.mp4	\N	\N	\N	\N	19-08-2026 10:00:01	Breakout	completed	2026-08-22 14:38:45.664566
1918	200.0.0.25_ch2_20260827100000_20260827220000.mp4	breakout	D:\\EEpic\\web-admin-backend\\data\\raw\\breakout\\200.0.0.25_ch2_20260827100000_20260827220000.mp4	\N	\N	\N	\N	27-08-2026 10:00:00	Breakout	completed	2026-08-27 18:22:39.593369
\.


--
-- Name: activities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.activities_id_seq', 2, true);


--
-- Name: branch_activities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.branch_activities_id_seq', 2, true);


--
-- Name: branches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.branches_id_seq', 9, true);


--
-- Name: cameras_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cameras_id_seq', 2, true);


--
-- Name: department_shifts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.department_shifts_id_seq', 77, true);


--
-- Name: departments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.departments_id_seq', 102, true);


--
-- Name: events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.events_id_seq', 79578, true);


--
-- Name: permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.permissions_id_seq', 27, true);


--
-- Name: person_track_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.person_track_logs_id_seq', 2574, true);


--
-- Name: review_queue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.review_queue_id_seq', 1, false);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_id_seq', 2, true);


--
-- Name: staff_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.staff_id_seq', 913, true);


--
-- Name: system_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.system_logs_id_seq', 620665, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 1, true);


--
-- Name: video_processing_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.video_processing_logs_id_seq', 3, true);


--
-- Name: videos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.videos_id_seq', 1951, true);


--
-- Name: activities activities_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_name_key UNIQUE (name);


--
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: branch_activities branch_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branch_activities
    ADD CONSTRAINT branch_activities_pkey PRIMARY KEY (id);


--
-- Name: branches branches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_pkey PRIMARY KEY (id);


--
-- Name: cameras cameras_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cameras
    ADD CONSTRAINT cameras_pkey PRIMARY KEY (id);


--
-- Name: department_shifts department_shifts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department_shifts
    ADD CONSTRAINT department_shifts_pkey PRIMARY KEY (id);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: person_track_logs person_track_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person_track_logs
    ADD CONSTRAINT person_track_logs_pkey PRIMARY KEY (id);


--
-- Name: review_queue review_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.review_queue
    ADD CONSTRAINT review_queue_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (role_id, permission_id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: staff staff_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (id);


--
-- Name: system_logs system_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_logs
    ADD CONSTRAINT system_logs_pkey PRIMARY KEY (id);


--
-- Name: events uq_events_video_track_frame; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT uq_events_video_track_frame UNIQUE (video_id, track_id, frame_number);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: video_processing_logs video_processing_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video_processing_logs
    ADD CONSTRAINT video_processing_logs_pkey PRIMARY KEY (id);


--
-- Name: videos videos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.videos
    ADD CONSTRAINT videos_pkey PRIMARY KEY (id);


--
-- Name: ix_activities_activity_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_activities_activity_id ON public.activities USING btree (activity_id);


--
-- Name: ix_activities_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_activities_id ON public.activities USING btree (id);


--
-- Name: ix_branch_activities_activity_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_branch_activities_activity_id ON public.branch_activities USING btree (activity_id);


--
-- Name: ix_branch_activities_branch_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_branch_activities_branch_id ON public.branch_activities USING btree (branch_id);


--
-- Name: ix_branch_activities_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_branch_activities_id ON public.branch_activities USING btree (id);


--
-- Name: ix_branches_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_branches_id ON public.branches USING btree (id);


--
-- Name: ix_branches_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_branches_name ON public.branches USING btree (name);


--
-- Name: ix_cameras_branch_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_cameras_branch_id ON public.cameras USING btree (branch_id);


--
-- Name: ix_cameras_camera_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_cameras_camera_id ON public.cameras USING btree (camera_id);


--
-- Name: ix_cameras_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_cameras_id ON public.cameras USING btree (id);


--
-- Name: ix_department_shifts_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_department_shifts_id ON public.department_shifts USING btree (id);


--
-- Name: ix_departments_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_departments_id ON public.departments USING btree (id);


--
-- Name: ix_departments_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_departments_name ON public.departments USING btree (name);


--
-- Name: ix_events_camera_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_events_camera_role ON public.events USING btree (camera_role);


--
-- Name: ix_events_employee_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_events_employee_id ON public.events USING btree (employee_id);


--
-- Name: ix_events_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_events_id ON public.events USING btree (id);


--
-- Name: ix_events_video_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_events_video_id ON public.events USING btree (video_id);


--
-- Name: ix_permissions_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_permissions_id ON public.permissions USING btree (id);


--
-- Name: ix_permissions_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_permissions_name ON public.permissions USING btree (name);


--
-- Name: ix_person_track_logs_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_person_track_logs_id ON public.person_track_logs USING btree (id);


--
-- Name: ix_review_queue_event_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_review_queue_event_id ON public.review_queue USING btree (event_id);


--
-- Name: ix_review_queue_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_review_queue_id ON public.review_queue USING btree (id);


--
-- Name: ix_roles_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_roles_id ON public.roles USING btree (id);


--
-- Name: ix_roles_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_roles_name ON public.roles USING btree (name);


--
-- Name: ix_staff_branch_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_staff_branch_id ON public.staff USING btree (branch_id);


--
-- Name: ix_staff_department_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_staff_department_id ON public.staff USING btree (department_id);


--
-- Name: ix_staff_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_staff_email ON public.staff USING btree (email);


--
-- Name: ix_staff_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_staff_id ON public.staff USING btree (id);


--
-- Name: ix_staff_staff_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_staff_staff_id ON public.staff USING btree (staff_id);


--
-- Name: ix_system_logs_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_system_logs_id ON public.system_logs USING btree (id);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: ix_users_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_users_id ON public.users USING btree (id);


--
-- Name: ix_users_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_users_username ON public.users USING btree (username);


--
-- Name: ix_video_processing_logs_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_video_processing_logs_id ON public.video_processing_logs USING btree (id);


--
-- Name: ix_video_processing_logs_video_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_video_processing_logs_video_name ON public.video_processing_logs USING btree (video_name);


--
-- Name: ix_videos_filename; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_videos_filename ON public.videos USING btree (filename);


--
-- Name: ix_videos_folder_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_videos_folder_type ON public.videos USING btree (folder_type);


--
-- Name: ix_videos_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_videos_id ON public.videos USING btree (id);


--
-- Name: branch_activities branch_activities_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branch_activities
    ADD CONSTRAINT branch_activities_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id) ON DELETE CASCADE;


--
-- Name: cameras cameras_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cameras
    ADD CONSTRAINT cameras_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: department_shifts department_shifts_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department_shifts
    ADD CONSTRAINT department_shifts_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id) ON DELETE CASCADE;


--
-- Name: events events_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.videos(id);


--
-- Name: person_track_logs person_track_logs_video_log_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person_track_logs
    ADD CONSTRAINT person_track_logs_video_log_id_fkey FOREIGN KEY (video_log_id) REFERENCES public.video_processing_logs(id) ON DELETE CASCADE;


--
-- Name: review_queue review_queue_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.review_queue
    ADD CONSTRAINT review_queue_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: staff staff_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: staff staff_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: users users_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- PostgreSQL database dump complete
--

\unrestrict Ims2cupM0I1wiNduvyNIDLju3JLW0Dv8mGJu0uSoBtB7qnJpKQLY3k2nVRQXxW4

