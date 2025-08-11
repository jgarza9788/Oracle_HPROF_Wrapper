CREATE OR REPLACE PROCEDURE setup_hprof_env (
    p_schema   IN VARCHAR2,  -- Schema for profiler tables (e.g., 'HR')
    p_path     IN VARCHAR2,  -- OS path for DIRECTORY object
    p_user     IN VARCHAR2   -- App user to grant execute / inherit privileges
) AS
    v_dir_name  VARCHAR2(30) := 'HPROF_DIR';
    v_sql       VARCHAR2(1000);
BEGIN
    -- Set schema context for profiler table creation
    EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA = ' || p_schema;

    -- Create profiler tables (force overwrite if they exist)
    DBMS_HPROF.CREATE_TABLES(force_it => TRUE);

    -- Grant privileges on profiler tables to p_schema (self) -- redundant but explicit
    FOR t IN (SELECT table_name FROM user_tables WHERE table_name LIKE 'DBMSHP%')
    LOOP
        v_sql := 'GRANT SELECT, INSERT, UPDATE, DELETE ON ' || p_schema || '.' || t.table_name || ' TO ' || p_schema;
        EXECUTE IMMEDIATE v_sql;
    END LOOP;

    -- Core grants
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON DBMS_MONITOR TO ' || p_schema;
    -- EXECUTE IMMEDIATE 'GRANT SELECT_CATALOG_ROLE TO ' || p_schema;
    -- EXECUTE IMMEDIATE 'GRANT SELECT ON V$SESSION TO ' || p_schema;
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON DBMS_HPROF TO ' || p_schema;

    -- Create or replace DIRECTORY object for profiler output
    BEGIN
        EXECUTE IMMEDIATE 'CREATE OR REPLACE DIRECTORY ' || v_dir_name || ' AS ''' || p_path || '''';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Error creating directory object: ' || SQLERRM);
    END;

    -- Grant directory access to schema and app user
    EXECUTE IMMEDIATE 'GRANT READ, WRITE ON DIRECTORY ' || v_dir_name || ' TO ' || p_schema;
    EXECUTE IMMEDIATE 'GRANT READ, WRITE ON DIRECTORY ' || v_dir_name || ' TO ' || p_user;

    -- Grant inherit privileges for cross-schema calls
    EXECUTE IMMEDIATE 'GRANT INHERIT PRIVILEGES ON USER ' || p_user || ' TO ' || p_schema;

    -- Allow app user to execute the profile wrapper proc (assumes HR.APP_RUN_PROFILE exists)
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON ' || p_schema || '.APP_RUN_PROFILE TO ' || p_user;

    DBMS_OUTPUT.PUT_LINE('HPROF environment setup complete for schema "' || p_schema || '"');
END;
/

-- run the procedure above ...with your own parameters
BEGIN
    setup_hprof_env(
        p_schema => 'HR',
        p_path   => 'C:\USERS\...\GITHUB\ORACLE_PLSQL_GUIDE\ODB\diag\rdbms\orcl\orcl\trace',
        p_user   => 'USER'
    );
END;
/