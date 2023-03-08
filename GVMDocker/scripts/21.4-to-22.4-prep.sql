DROP EXTENSION IF EXISTS  pgcrypto CASCADE;
DROP EXTENSION IF EXISTS  "uuid-ossp" CASCADE;
DROP VIEW IF EXISTS  result_new_severities CASCADE;
DROP VIEW IF EXISTS  result_new_severities_dynamic CASCADE;
DROP VIEW IF EXISTS  result_new_severities_static CASCADE;
DROP VIEW IF EXISTS  result_overrides CASCADE;
DROP VIEW IF EXISTS  tls_certificate_source_origins CASCADE;
DROP VIEW IF EXISTS  vulns CASCADE;
DROP FUNCTION IF EXISTS certificate_iso_time(bigint)  CASCADE;
DROP FUNCTION IF EXISTS group_concat_pair(text,text,text)  CASCADE;
DROP FUNCTION IF EXISTS cpe_title(text)  CASCADE;
DROP FUNCTION IF EXISTS common_cve(text,text)  CASCADE;
DROP FUNCTION IF EXISTS create_index(text,text,text,text)  CASCADE;
DROP FUNCTION IF EXISTS gvmd_user()  CASCADE;
DROP FUNCTION IF EXISTS credential_value(integer,integer,text)  CASCADE;
DROP FUNCTION IF EXISTS hosts_contains(text,text)  CASCADE;
DROP FUNCTION IF EXISTS dynamic_severity()  CASCADE;
DROP FUNCTION IF EXISTS current_severity(real,text)  CASCADE;
DROP FUNCTION IF EXISTS create_index(text,text,text)  CASCADE;
DROP FUNCTION IF EXISTS order_inet(text)  CASCADE;
DROP FUNCTION IF EXISTS next_time_ical(text,text)  CASCADE;
DROP FUNCTION IF EXISTS iso_time(bigint)  CASCADE;
DROP FUNCTION IF EXISTS m_now()  CASCADE;
DROP FUNCTION IF EXISTS order_port(text)  CASCADE;
DROP FUNCTION IF EXISTS order_role(text)  CASCADE;
DROP FUNCTION IF EXISTS order_threat(text)  CASCADE;
DROP FUNCTION IF EXISTS make_uuid()  CASCADE;
DROP FUNCTION IF EXISTS next_time_ical(text,text,integer)  CASCADE;
DROP FUNCTION IF EXISTS regexp(text,text)  CASCADE;
DROP FUNCTION IF EXISTS quote_ident_split(text)  CASCADE;
DROP FUNCTION IF EXISTS max_hosts(text,text)  CASCADE;
DROP FUNCTION IF EXISTS lower(integer)  CASCADE;
DROP FUNCTION IF EXISTS quote_ident_list(text)  CASCADE;
DROP FUNCTION IF EXISTS level_min_severity(text,text)  CASCADE;
DROP FUNCTION IF EXISTS severity_matches_ov(double precision,double precision)  CASCADE;
DROP FUNCTION IF EXISTS resource_name(text,text,integer)  CASCADE;
DROP FUNCTION IF EXISTS report_active(integer)  CASCADE;
DROP FUNCTION IF EXISTS report_result_host_count(integer,integer)  CASCADE;
DROP FUNCTION IF EXISTS severity_class()  CASCADE;
DROP FUNCTION IF EXISTS run_status_name(integer)  CASCADE;
DROP FUNCTION IF EXISTS severity_in_level(double precision,text)  CASCADE;
DROP FUNCTION IF EXISTS report_progress(integer)  CASCADE;
DROP FUNCTION IF EXISTS severity_in_levels(double precision,text[])  CASCADE;
DROP FUNCTION IF EXISTS report_host_count(integer)  CASCADE;
DROP FUNCTION IF EXISTS severity_to_level(double precision,integer)  CASCADE;
DROP FUNCTION IF EXISTS trash_target_credential_location(integer,text)  CASCADE;
DROP FUNCTION IF EXISTS user_has_super_on_resource(text,integer)  CASCADE;
DROP FUNCTION IF EXISTS task_threat_level(integer,integer,integer)  CASCADE;
DROP FUNCTION IF EXISTS target_login_port(integer,integer,text)  CASCADE;
DROP FUNCTION IF EXISTS t()  CASCADE;
DROP FUNCTION IF EXISTS task_last_report(integer)  CASCADE;
DROP FUNCTION IF EXISTS target_credential(integer,integer,text)  CASCADE;
DROP FUNCTION IF EXISTS try_exclusive_lock(regclass)  CASCADE;
DROP FUNCTION IF EXISTS task_second_last_report(integer)  CASCADE;
DROP FUNCTION IF EXISTS severity_to_type(double precision)  CASCADE;
DROP FUNCTION IF EXISTS uniquify(text,text,integer,text)  CASCADE;
DROP FUNCTION IF EXISTS user_has_access_uuid(text,text,text,integer)  CASCADE;
DROP FUNCTION IF EXISTS user_can_everything(text)  CASCADE;
DROP FUNCTION IF EXISTS iso_time(bigint,text)  CASCADE;
DROP FUNCTION IF EXISTS vts_verification_str()  CASCADE;
DROP FUNCTION IF EXISTS days_from_now(bigint)  CASCADE;
DROP FUNCTION IF EXISTS vuln_results(text,bigint,bigint,text)  CASCADE;
DROP FUNCTION IF EXISTS vuln_results_exist(text,bigint,bigint,text)  CASCADE;
DROP FUNCTION IF EXISTS level_max_severity(text,text)  CASCADE;
DROP FUNCTION IF EXISTS task_trend(integer,integer,integer)  CASCADE;
DROP FUNCTION IF EXISTS severity_to_level(text,integer)  CASCADE;
DROP FUNCTION IF EXISTS report_severity(integer,integer,integer)  CASCADE;
DROP FUNCTION IF EXISTS report_severity_count(integer,integer,integer,text)  CASCADE;
DROP FUNCTION IF EXISTS user_owns(text,integer)  CASCADE;
DROP AGGREGATE IF EXISTS group_concat(text,text) CASCADE;
DROP FUNCTION IF EXISTS regexp(text,text) CASCADE; 
DROP FUNCTION IF EXISTS group_concat_pair(text,text,text)  CASCADE;
