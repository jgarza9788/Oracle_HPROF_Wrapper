CREATE OR REPLACE PROCEDURE OHPROF_WRAPPER(
  p_call_text IN VARCHAR2,
  p_call_kind IN VARCHAR2  -- 'PROC' or 'FUNC'
 ) 
 --AUTHID CURRENT_USER
 AUTHID DEFINER  -- use DEFINER to run with schema's privileges
AS
  v_tag       VARCHAR2(64) := 'OHPROF_RUN_' || TO_CHAR(SYSTIMESTAMP,'YYYYMMDD_HH24MISSFF3');
  v_runid     NUMBER;
  v_kind      VARCHAR2(10);
  v_func_ret  VARCHAR2(32767);
  v_sid       NUMBER;
  v_serial    NUMBER;
BEGIN
  v_kind := UPPER(TRIM(p_call_kind));

  -- Tag the session so reports/ASH/trace are easy to correlate
  DBMS_APPLICATION_INFO.SET_MODULE('PLSQL_PROFILE', v_tag);

  -- -- Get SID and SERIAL# for current user session
  -- SELECT sid, serial#
  --   INTO v_sid, v_serial
  --   FROM v$session
  --  WHERE username = SYS_CONTEXT('USERENV','SESSION_USER')
  --    AND ROWNUM = 1;

  -- Start PL/SQL Hierarchical Profiler (writes a .trc in user_dump_dest)
  DBMS_HPROF.START_PROFILING(
    location => 'HPROF_DIR',
    filename => v_tag
  );

  -- Enable level-12 SQL trace (waits + binds) for this session explicitly
  DBMS_MONITOR.SESSION_TRACE_ENABLE(
    -- session_id => v_sid,
    -- serial_num => v_serial,
    waits      => TRUE,
    binds      => TRUE
  );

  -- run the target code ...
  IF p_call_text IS NULL OR v_kind IS NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'Provide p_call_text and p_call_kind (PROC|FUNC).');
  END IF;

  IF v_kind = 'PROC' THEN
    EXECUTE IMMEDIATE 'BEGIN '||p_call_text||'; END;';
  ELSIF v_kind = 'FUNC' THEN
    EXECUTE IMMEDIATE 'BEGIN :ret := '||p_call_text||'; END;' USING OUT v_func_ret;
    DBMS_OUTPUT.PUT_LINE('Function return: '||SUBSTR(v_func_ret,1,200));
  ELSE
    RAISE_APPLICATION_ERROR(-20001, 'Invalid p_call_kind. Use PROC or FUNC.');
  END IF;

  -- stop & analyze
  DBMS_MONITOR.SESSION_TRACE_DISABLE;
  DBMS_HPROF.STOP_PROFILING;

  v_runid := DBMS_HPROF.ANALYZE(
               location   => 'HPROF_DIR',
               filename   => v_tag,
               run_comment=> v_tag
             );

  DBMS_OUTPUT.PUT_LINE('HPROF RUN_ID = '||v_runid||'  TAG = '||v_tag);



EXCEPTION
  WHEN OTHERS THEN
    BEGIN DBMS_MONITOR.SESSION_TRACE_DISABLE; EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN DBMS_HPROF.STOP_PROFILING; EXCEPTION WHEN OTHERS THEN NULL; END;
    RAISE;
END;
/


-- grant the wrapper to user
GRANT EXECUTE ON OHPROF_WRAPPER TO USER;