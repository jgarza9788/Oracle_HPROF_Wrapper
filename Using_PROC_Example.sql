


BEGIN
  OHPROF_WRAPPER('update_salary(101,5)', 'PROC');
  --^ call the procedure 
  --              ^pass in the procedure name and parameters as a string
  --                                       ^pass in the call kind (PROC or FUNC)
END;                
/


--here is another example
BEGIN
  OHPROF_WRAPPER('hire_person(''Dave'',1,100)', 'PROC');
END;
/
