
-- Tree of calls with indentation + function (child) metrics + edge metrics + parent metadata
-- Replace :v_runid 
SELECT
  /* hierarchy */
  LEVEL AS depth,
  pc.parentsymid,
  pc.childsymid,
--   fi.symbolid                                   AS child_symbolid,

  /* pretty node label */
  LPAD(' ', 4*(LEVEL-1)) ||
    fi.owner || '.' || fi.module || '.' || NVL(fi."FUNCTION",'???') ||
    CASE WHEN fi."LINE#" IS NOT NULL THEN ':' || fi."LINE#" END     AS node,

  /* child function metadata */
--   fi.runid,
  fi.owner,
  fi.module,
  fi."TYPE",
  fi."FUNCTION",
  fi."LINE#",
--   fi.hash,
--   fi.namespace,
  fi.sql_id,
  fi.sql_text,

  /* child function totals (HPROF aggregates for that symbol across the run) */
  fi.subtree_elapsed_time   AS fi_incl_us,
  fi.function_elapsed_time  AS fi_excl_us,
  fi.calls                  AS fi_calls--,

  /* edge metrics: time/calls attributed on this specific parent→child edge */
--   pc.subtree_elapsed_time   AS edge_incl_us,
--   pc.function_elapsed_time  AS edge_excl_us,
--   pc.calls                  AS edge_calls,

  /* parent (caller) metadata, if any (NULL when parent = 0) */
--   pfi.owner                 AS parent_owner,
--   pfi.module                AS parent_module,
--   pfi."FUNCTION"            AS parent_function,
--   pfi."LINE#"               AS parent_line
FROM   DBMSHP_PARENT_CHILD_INFO pc
JOIN   DBMSHP_FUNCTION_INFO     fi
       ON fi.runid    = pc.runid
      AND fi.symbolid = pc.childsymid
LEFT JOIN DBMSHP_FUNCTION_INFO  pfi
       ON pfi.runid    = pc.runid
      AND pfi.symbolid = pc.parentsymid
WHERE  pc.runid = :v_runid
START WITH pc.parentsymid = 1 -- 0 for whole run, or a specific parent symbol
CONNECT BY PRIOR pc.childsymid = pc.parentsymid
           AND pc.runid = PRIOR pc.runid
ORDER SIBLINGS BY fi.module, fi."LINE#"; -- or: pc.subtree_elapsed_time DESC for “hottest-first”
