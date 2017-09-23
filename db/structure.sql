SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: payment_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE payment_status AS ENUM (
    'pending',
    'approved',
    'failed',
    'cancelled',
    'refunded'
);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: activities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE activities (
    id integer NOT NULL,
    type character varying,
    festival_id integer,
    name character varying,
    slug character varying,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    image_file_name character varying,
    image_content_type character varying,
    image_file_size integer,
    image_updated_at timestamp without time zone,
    grade character varying(16) DEFAULT 'unknown'::character varying
);


--
-- Name: activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE activities_id_seq OWNED BY activities.id;


--
-- Name: allocations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE allocations (
    id integer NOT NULL,
    package_id integer,
    activity_type_name character varying(32),
    maximum integer DEFAULT 0
);


--
-- Name: allocations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE allocations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: allocations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE allocations_id_seq OWNED BY allocations.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: facilitators; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE facilitators (
    id integer NOT NULL,
    participant_id integer,
    activity_id integer,
    "position" integer DEFAULT 0
);


--
-- Name: facilitators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE facilitators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: facilitators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE facilitators_id_seq OWNED BY facilitators.id;


--
-- Name: festivals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE festivals (
    id integer NOT NULL,
    year integer,
    start_date date,
    end_date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: festivals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE festivals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: festivals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE festivals_id_seq OWNED BY festivals.id;


--
-- Name: incidents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE incidents (
    id bigint NOT NULL,
    festival_id bigint,
    participant_id bigint,
    description text,
    status character varying(32) DEFAULT 'open'::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: incidents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE incidents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: incidents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE incidents_id_seq OWNED BY incidents.id;


--
-- Name: package_prices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE package_prices (
    id integer NOT NULL,
    package_id integer,
    expires_at timestamp without time zone,
    amount_cents integer DEFAULT 0 NOT NULL,
    amount_currency character varying DEFAULT 'NZD'::character varying NOT NULL,
    deposit_cents integer DEFAULT 0 NOT NULL,
    deposit_currency character varying DEFAULT 'NZD'::character varying NOT NULL
);


--
-- Name: package_prices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE package_prices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: package_prices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE package_prices_id_seq OWNED BY package_prices.id;


--
-- Name: packages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE packages (
    id integer NOT NULL,
    festival_id integer,
    name character varying,
    slug character varying(128),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "position" integer DEFAULT 0
);


--
-- Name: packages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE packages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: packages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE packages_id_seq OWNED BY packages.id;


--
-- Name: participants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE participants (
    id integer NOT NULL,
    user_id integer,
    name character varying,
    email character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    avatar_file_name character varying,
    avatar_content_type character varying,
    avatar_file_size integer,
    avatar_updated_at timestamp without time zone,
    bio text,
    origin character varying(128),
    company character varying(128),
    facilitators_count integer DEFAULT 0
);


--
-- Name: participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE participants_id_seq OWNED BY participants.id;


--
-- Name: payment_method_configurations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE payment_method_configurations (
    id integer NOT NULL,
    festival_id integer,
    type character varying(64),
    configuration text DEFAULT '{}'::text
);


--
-- Name: payment_method_configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payment_method_configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_method_configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payment_method_configurations_id_seq OWNED BY payment_method_configurations.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE payments (
    id integer NOT NULL,
    registration_id integer,
    status payment_status DEFAULT 'pending'::payment_status,
    payment_type character varying,
    amount_cents integer DEFAULT 0 NOT NULL,
    amount_currency character varying DEFAULT 'NZD'::character varying NOT NULL,
    reference character varying(32),
    failure_message character varying(128),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    token character varying(64),
    transaction_reference character varying(32),
    transaction_data text DEFAULT '{}'::text,
    fee_cents integer DEFAULT 0 NOT NULL,
    fee_currency character varying DEFAULT 'NZD'::character varying NOT NULL
);


--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payments_id_seq OWNED BY payments.id;


--
-- Name: registrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE registrations (
    id integer NOT NULL,
    participant_id integer NOT NULL,
    festival_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    package_id integer,
    code_of_conduct_accepted_at timestamp without time zone,
    completed_at timestamp without time zone
);


--
-- Name: registrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE registrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: registrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE registrations_id_seq OWNED BY registrations.id;


--
-- Name: related_activities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE related_activities (
    id integer NOT NULL,
    parent_id integer,
    child_id integer
);


--
-- Name: related_activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE related_activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: related_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE related_activities_id_seq OWNED BY related_activities.id;


--
-- Name: schedules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schedules (
    id integer NOT NULL,
    activity_id integer,
    starts_at timestamp without time zone,
    ends_at timestamp without time zone,
    "position" integer DEFAULT 0,
    selections_count integer DEFAULT 0,
    maximum integer,
    venue_id integer
);


--
-- Name: schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE schedules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE schedules_id_seq OWNED BY schedules.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: selections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE selections (
    id integer NOT NULL,
    registration_id integer,
    schedule_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: selections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE selections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: selections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE selections_id_seq OWNED BY selections.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying,
    admin boolean DEFAULT false,
    box_office boolean DEFAULT false
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: venues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE venues (
    id integer NOT NULL,
    name character varying,
    address character varying,
    latitude numeric(9,6),
    longitude numeric(9,6),
    "position" integer
);


--
-- Name: venues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE venues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: venues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE venues_id_seq OWNED BY venues.id;


--
-- Name: vouchers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE vouchers (
    id integer NOT NULL,
    admin_id integer,
    participant_id integer,
    festival_id integer,
    amount_cents integer DEFAULT 0 NOT NULL,
    amount_currency character varying DEFAULT 'NZD'::character varying NOT NULL,
    reason character varying(128),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: vouchers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vouchers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vouchers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vouchers_id_seq OWNED BY vouchers.id;


--
-- Name: activities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY activities ALTER COLUMN id SET DEFAULT nextval('activities_id_seq'::regclass);


--
-- Name: allocations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY allocations ALTER COLUMN id SET DEFAULT nextval('allocations_id_seq'::regclass);


--
-- Name: facilitators id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY facilitators ALTER COLUMN id SET DEFAULT nextval('facilitators_id_seq'::regclass);


--
-- Name: festivals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY festivals ALTER COLUMN id SET DEFAULT nextval('festivals_id_seq'::regclass);


--
-- Name: incidents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY incidents ALTER COLUMN id SET DEFAULT nextval('incidents_id_seq'::regclass);


--
-- Name: package_prices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY package_prices ALTER COLUMN id SET DEFAULT nextval('package_prices_id_seq'::regclass);


--
-- Name: packages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY packages ALTER COLUMN id SET DEFAULT nextval('packages_id_seq'::regclass);


--
-- Name: participants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY participants ALTER COLUMN id SET DEFAULT nextval('participants_id_seq'::regclass);


--
-- Name: payment_method_configurations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_method_configurations ALTER COLUMN id SET DEFAULT nextval('payment_method_configurations_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY payments ALTER COLUMN id SET DEFAULT nextval('payments_id_seq'::regclass);


--
-- Name: registrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY registrations ALTER COLUMN id SET DEFAULT nextval('registrations_id_seq'::regclass);


--
-- Name: related_activities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY related_activities ALTER COLUMN id SET DEFAULT nextval('related_activities_id_seq'::regclass);


--
-- Name: schedules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY schedules ALTER COLUMN id SET DEFAULT nextval('schedules_id_seq'::regclass);


--
-- Name: selections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY selections ALTER COLUMN id SET DEFAULT nextval('selections_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: venues id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY venues ALTER COLUMN id SET DEFAULT nextval('venues_id_seq'::regclass);


--
-- Name: vouchers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vouchers ALTER COLUMN id SET DEFAULT nextval('vouchers_id_seq'::regclass);


--
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: allocations allocations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY allocations
    ADD CONSTRAINT allocations_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: facilitators facilitators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY facilitators
    ADD CONSTRAINT facilitators_pkey PRIMARY KEY (id);


--
-- Name: festivals festivals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY festivals
    ADD CONSTRAINT festivals_pkey PRIMARY KEY (id);


--
-- Name: incidents incidents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY incidents
    ADD CONSTRAINT incidents_pkey PRIMARY KEY (id);


--
-- Name: package_prices package_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY package_prices
    ADD CONSTRAINT package_prices_pkey PRIMARY KEY (id);


--
-- Name: packages packages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY packages
    ADD CONSTRAINT packages_pkey PRIMARY KEY (id);


--
-- Name: participants participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY participants
    ADD CONSTRAINT participants_pkey PRIMARY KEY (id);


--
-- Name: payment_method_configurations payment_method_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_method_configurations
    ADD CONSTRAINT payment_method_configurations_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: registrations registrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY registrations
    ADD CONSTRAINT registrations_pkey PRIMARY KEY (id);


--
-- Name: related_activities related_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY related_activities
    ADD CONSTRAINT related_activities_pkey PRIMARY KEY (id);


--
-- Name: schedules schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schedules
    ADD CONSTRAINT schedules_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: selections selections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY selections
    ADD CONSTRAINT selections_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: venues venues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY venues
    ADD CONSTRAINT venues_pkey PRIMARY KEY (id);


--
-- Name: vouchers vouchers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vouchers
    ADD CONSTRAINT vouchers_pkey PRIMARY KEY (id);


--
-- Name: index_activities_on_festival_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_festival_id ON activities USING btree (festival_id);


--
-- Name: index_allocations_on_package_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_allocations_on_package_id ON allocations USING btree (package_id);


--
-- Name: index_allocations_on_package_id_and_activity_type_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_allocations_on_package_id_and_activity_type_name ON allocations USING btree (package_id, activity_type_name);


--
-- Name: index_facilitators_on_activity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_facilitators_on_activity_id ON facilitators USING btree (activity_id);


--
-- Name: index_facilitators_on_participant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_facilitators_on_participant_id ON facilitators USING btree (participant_id);


--
-- Name: index_festivals_on_year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_festivals_on_year ON festivals USING btree (year);


--
-- Name: index_incidents_on_festival_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_incidents_on_festival_id ON incidents USING btree (festival_id);


--
-- Name: index_incidents_on_participant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_incidents_on_participant_id ON incidents USING btree (participant_id);


--
-- Name: index_package_prices_on_package_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_package_prices_on_package_id ON package_prices USING btree (package_id);


--
-- Name: index_package_prices_on_package_id_and_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_package_prices_on_package_id_and_expires_at ON package_prices USING btree (package_id, expires_at);


--
-- Name: index_packages_on_festival_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_packages_on_festival_id ON packages USING btree (festival_id);


--
-- Name: index_participants_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_participants_on_user_id ON participants USING btree (user_id);


--
-- Name: index_payment_method_configurations_on_festival_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment_method_configurations_on_festival_id ON payment_method_configurations USING btree (festival_id);


--
-- Name: index_payment_method_configurations_on_festival_id_and_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_payment_method_configurations_on_festival_id_and_type ON payment_method_configurations USING btree (festival_id, type);


--
-- Name: index_payments_on_payment_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payments_on_payment_type ON payments USING btree (payment_type);


--
-- Name: index_payments_on_registration_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payments_on_registration_id ON payments USING btree (registration_id);


--
-- Name: index_payments_on_registration_id_and_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payments_on_registration_id_and_status ON payments USING btree (registration_id, status);


--
-- Name: index_payments_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payments_on_status ON payments USING btree (status);


--
-- Name: index_payments_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_payments_on_token ON payments USING btree (token);


--
-- Name: index_registrations_on_festival_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_registrations_on_festival_id ON registrations USING btree (festival_id);


--
-- Name: index_registrations_on_festival_id_and_participant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_registrations_on_festival_id_and_participant_id ON registrations USING btree (festival_id, participant_id);


--
-- Name: index_registrations_on_package_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_registrations_on_package_id ON registrations USING btree (package_id);


--
-- Name: index_registrations_on_participant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_registrations_on_participant_id ON registrations USING btree (participant_id);


--
-- Name: index_registrations_on_participant_id_and_festival_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_registrations_on_participant_id_and_festival_id ON registrations USING btree (participant_id, festival_id);


--
-- Name: index_related_activities_on_child_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_related_activities_on_child_id ON related_activities USING btree (child_id);


--
-- Name: index_related_activities_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_related_activities_on_parent_id ON related_activities USING btree (parent_id);


--
-- Name: index_schedules_on_activity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schedules_on_activity_id ON schedules USING btree (activity_id);


--
-- Name: index_schedules_on_starts_at_and_ends_at_and_activity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_schedules_on_starts_at_and_ends_at_and_activity_id ON schedules USING btree (starts_at, ends_at, activity_id);


--
-- Name: index_schedules_on_venue_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schedules_on_venue_id ON schedules USING btree (venue_id);


--
-- Name: index_selections_on_registration_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_selections_on_registration_id ON selections USING btree (registration_id);


--
-- Name: index_selections_on_registration_id_and_schedule_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_selections_on_registration_id_and_schedule_id ON selections USING btree (registration_id, schedule_id);


--
-- Name: index_selections_on_schedule_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_selections_on_schedule_id ON selections USING btree (schedule_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_vouchers_on_admin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vouchers_on_admin_id ON vouchers USING btree (admin_id);


--
-- Name: index_vouchers_on_festival_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vouchers_on_festival_id ON vouchers USING btree (festival_id);


--
-- Name: index_vouchers_on_festival_id_and_participant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vouchers_on_festival_id_and_participant_id ON vouchers USING btree (festival_id, participant_id);


--
-- Name: index_vouchers_on_participant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vouchers_on_participant_id ON vouchers USING btree (participant_id);


--
-- Name: vouchers fk_rails_1003b0bc5a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vouchers
    ADD CONSTRAINT fk_rails_1003b0bc5a FOREIGN KEY (festival_id) REFERENCES festivals(id) ON DELETE CASCADE;


--
-- Name: payment_method_configurations fk_rails_1378d77cf6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_method_configurations
    ADD CONSTRAINT fk_rails_1378d77cf6 FOREIGN KEY (festival_id) REFERENCES festivals(id) ON DELETE CASCADE;


--
-- Name: incidents fk_rails_1886bdb964; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY incidents
    ADD CONSTRAINT fk_rails_1886bdb964 FOREIGN KEY (festival_id) REFERENCES festivals(id) ON DELETE CASCADE;


--
-- Name: schedules fk_rails_26cbb5018a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schedules
    ADD CONSTRAINT fk_rails_26cbb5018a FOREIGN KEY (activity_id) REFERENCES activities(id) ON DELETE CASCADE;


--
-- Name: selections fk_rails_2c18b93dc1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY selections
    ADD CONSTRAINT fk_rails_2c18b93dc1 FOREIGN KEY (schedule_id) REFERENCES schedules(id);


--
-- Name: facilitators fk_rails_320be5a168; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY facilitators
    ADD CONSTRAINT fk_rails_320be5a168 FOREIGN KEY (activity_id) REFERENCES activities(id);


--
-- Name: related_activities fk_rails_34ab5298cf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY related_activities
    ADD CONSTRAINT fk_rails_34ab5298cf FOREIGN KEY (parent_id) REFERENCES activities(id) ON DELETE CASCADE;


--
-- Name: selections fk_rails_41dbad5a49; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY selections
    ADD CONSTRAINT fk_rails_41dbad5a49 FOREIGN KEY (registration_id) REFERENCES registrations(id);


--
-- Name: registrations fk_rails_4604f69f81; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY registrations
    ADD CONSTRAINT fk_rails_4604f69f81 FOREIGN KEY (festival_id) REFERENCES festivals(id) ON DELETE CASCADE;


--
-- Name: registrations fk_rails_621cdb63fe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY registrations
    ADD CONSTRAINT fk_rails_621cdb63fe FOREIGN KEY (participant_id) REFERENCES participants(id) ON DELETE CASCADE;


--
-- Name: packages fk_rails_62b1a47e4a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY packages
    ADD CONSTRAINT fk_rails_62b1a47e4a FOREIGN KEY (festival_id) REFERENCES festivals(id);


--
-- Name: facilitators fk_rails_90a7a16517; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY facilitators
    ADD CONSTRAINT fk_rails_90a7a16517 FOREIGN KEY (participant_id) REFERENCES participants(id);


--
-- Name: vouchers fk_rails_988f169076; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vouchers
    ADD CONSTRAINT fk_rails_988f169076 FOREIGN KEY (participant_id) REFERENCES participants(id) ON DELETE CASCADE;


--
-- Name: related_activities fk_rails_9b577e3d90; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY related_activities
    ADD CONSTRAINT fk_rails_9b577e3d90 FOREIGN KEY (child_id) REFERENCES activities(id) ON DELETE CASCADE;


--
-- Name: allocations fk_rails_a78a630eaf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY allocations
    ADD CONSTRAINT fk_rails_a78a630eaf FOREIGN KEY (package_id) REFERENCES packages(id);


--
-- Name: participants fk_rails_b9a3c50f15; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY participants
    ADD CONSTRAINT fk_rails_b9a3c50f15 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: payments fk_rails_bb9133230f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT fk_rails_bb9133230f FOREIGN KEY (registration_id) REFERENCES registrations(id) ON DELETE CASCADE;


--
-- Name: schedules fk_rails_ce75c0542b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schedules
    ADD CONSTRAINT fk_rails_ce75c0542b FOREIGN KEY (venue_id) REFERENCES venues(id);


--
-- Name: vouchers fk_rails_d199bf6a26; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vouchers
    ADD CONSTRAINT fk_rails_d199bf6a26 FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: activities fk_rails_d55f2d8599; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY activities
    ADD CONSTRAINT fk_rails_d55f2d8599 FOREIGN KEY (festival_id) REFERENCES festivals(id);


--
-- Name: registrations fk_rails_efbc49fd36; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY registrations
    ADD CONSTRAINT fk_rails_efbc49fd36 FOREIGN KEY (package_id) REFERENCES packages(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20160515213613'),
('20160516143627'),
('20160516205314'),
('20160516221434'),
('20160527034133'),
('20160601200449'),
('20160601203051'),
('20160606102150'),
('20160608235807'),
('20160611030610'),
('20160611233554'),
('20160612050518'),
('20160614230425'),
('20160617213530'),
('20160618022829'),
('20160618031224'),
('20160618031424'),
('20160619002642'),
('20160619105435'),
('20160622235037'),
('20160625013819'),
('20160630031714'),
('20160630055040'),
('20160703202853'),
('20160717043606'),
('20160717065120'),
('20160717105154'),
('20160717223316'),
('20160723221958'),
('20160829091713'),
('20160829203009'),
('20160830092051'),
('20160901012943'),
('20160902061243'),
('20160903211632'),
('20160904004604'),
('20160910235529'),
('20160917002708'),
('20170923032134');


