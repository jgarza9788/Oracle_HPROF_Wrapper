# Oracle HPROF Wrapper

A lightweight PL/SQL utility for running, managing, and analyzing **Oracle PL/SQL Hierarchical Profiler (DBMS_HPROF)** output in a simplified way.  
This wrapper helps developers quickly profile stored procedures, functions, and packages without manually handling complex DBMS_HPROF commands.

---

## Features

- **Easy Setup** – Run a single call to start and stop profiling.
- **Human-Readable Results** – Automatically joins DBMS_HPROF tables for a single view.
- **Flexible Target** – Profile any PL/SQL block, procedure, or package.
- **Error Handling** – Detects missing directory objects, grants, and invalid states.
- **Optional Filtering** – Limit results to specific owners, modules, or namespaces.

---

## Requirements

- **Oracle Database 11gR1 or later**
- Access to:
  - `DBMS_HPROF`
  - `DBMS_HPROF.ANALYZE`
  - `DBMS_HPROF.DELETE`
  - Underlying profiler tables (`DBMSHP_*`)
- **Directory Object** for profiler output (must be granted to the profiling schema)

---

## Installation

Open and run the following ... see comments for details.
1. `Setup_and_Access.sql`
* this is about setting up access/privileges for the profiling schema and the profiler output directory
2. `OHPROF_WRAPPER.sql`
* this is the main script for HPROF
3. `Using_PROC_Example.sql`
* this is an example of using the wrapper to profile a procedure
4. `GetReport.sql`
* this is an example of getting a report from the profiler output directory


## output example

<!DOCTYPE html>
<html>

<head>
  <meta charset='UTF-8'>
  
  <title>Result Data</title>
  
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  
  <style>
  * { 
    margin: 0; 
    padding: 0; 
  }
  body { 
    font: 14px/1.4 Palatino, Serif; 
  }
  
  /* 
  Generic Styling, for Desktops/Laptops 
  */
  table { 
    width: 100%; 
    border-collapse: collapse; 
  }
  /* Zebra striping */
  /*
  tr:nth-of-type(odd) { 
    background: #eee; 
  }
  th { 
    background: #333; 
    color: white; 
    font-weight: bold; 
  }
  td, th { 
    padding: 6px; 
    border: 1px solid #9B9B9B; 
    text-align: left; 
  }
  */
  @media 
  only screen and (max-width: 760px),
  (min-device-width: 768px) and (max-device-width: 1024px)  {
    table, thead, tbody, th, td, tr { display: block; }
    thead tr { position: absolute;top: -9999px;left: -9999px;}
    tr { border: 1px solid #9B9B9B; }
    td { border: none;border-bottom: 1px solid #9B9B9B; position: relative;padding-left: 50%; }
    
    td:before { position: absolute;top: 6px;left: 6px;width: 45%; padding-right: 10px; white-space: nowrap;}
    
    /*
    Label the data
    */
td:nth-of-type(1):before { content: "DEPTH"; }
td:nth-of-type(2):before { content: "PARENTSYMID"; }
td:nth-of-type(3):before { content: "CHILDSYMID"; }
td:nth-of-type(4):before { content: "NODE"; }
td:nth-of-type(5):before { content: "OWNER"; }
td:nth-of-type(6):before { content: "MODULE"; }
td:nth-of-type(7):before { content: "TYPE"; }
td:nth-of-type(8):before { content: "FUNCTION"; }
td:nth-of-type(9):before { content: "LINE#"; }
td:nth-of-type(10):before { content: "SQL_ID"; }
td:nth-of-type(11):before { content: "SQL_TEXT"; }
td:nth-of-type(12):before { content: "FI_INCL_US"; }
td:nth-of-type(13):before { content: "FI_EXCL_US"; }
td:nth-of-type(14):before { content: "FI_CALLS"; }
  }
  
  /* Smartphones (portrait and landscape) ----------- */
  @media only screen
  and (min-device-width : 320px)
  and (max-device-width : 480px) {
    body { 
      padding: 0; 
      margin: 0; 
      width: 320px; }
    }
  
  /* iPads (portrait and landscape) ----------- */
  @media only screen and (min-device-width: 768px) and (max-device-width: 1024px) {
    body { 
      width: 495px; 
    }
  }
  
  </style>
  <!--<![endif]-->
<script type="text/javascript">

function search(){
  
  var s = document.getElementById('search').value;

  rows = document.getElementById('data').getElementsByTagName('TR');
  for(var i=0;i<rows.length;i++){
    if ( rows[i].textContent.indexOf(s)>0  || s.length==0 ) {
	  rows[i].style.display ='';
    } else {
      rows[i].style.display ='none';
    }
  }
}


var timer;
function delayedSearch() {
	clearTimeout(timer);
	console.log('delay-ing')
    timer = setTimeout(function () {
		console.log('delay-running')
		search();
    }, 500);
  }</script>
</head>

<body>
<!--
<div><input type="text" size="30" maxlength="1000" value="" id="search" onkeyup="delayedSearch();" /><input type="button" value="Go" onclick="lsearch();"/> </div>
-->
<table><thead><tr>	<th>DEPTH</th>
	<th>PARENTSYMID</th>
	<th>CHILDSYMID</th>
	<th>NODE</th>
	<th>OWNER</th>
	<th>MODULE</th>
	<th>TYPE</th>
	<th>FUNCTION</th>
	<th>LINE#</th>
	<th>SQL_ID</th>
	<th>SQL_TEXT</th>
	<th>FI_INCL_US</th>
	<th>FI_EXCL_US</th>
	<th>FI_CALLS</th>
</tr></thead>
<tbody id="data">
<td align="right">1</td>
<td align="right">1</td>
<td align="right">5</td>
<td>HR.UPDATE_SALARY.UPDATE_SALARY:1</td>
<td>HR</td>
<td>UPDATE_SALARY</td>
<td>PROCEDURE</td>
<td>UPDATE_SALARY</td>
<td align="right">1</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td align="right">862</td>
<td align="right">68</td>
<td align="right">1</td>
	</tr>
	<tr>
<td align="right">2</td>
<td align="right">5</td>
<td align="right">12</td>
<td>&emsp;SYS.DBMS_OUTPUT.PUT_LINE:109</td>
<td>SYS</td>
<td>DBMS_OUTPUT</td>
<td>PACKAGE BODY</td>
<td>PUT_LINE</td>
<td align="right">109</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td align="right">19</td>
<td align="right">2</td>
<td align="right">3</td>
	</tr>
	<tr>
<td align="right">3</td>
<td align="right">12</td>
<td align="right">11</td>
<td>&emsp;&emsp;SYS.DBMS_OUTPUT.PUT:77</td>
<td>SYS</td>
<td>DBMS_OUTPUT</td>
<td>PACKAGE BODY</td>
<td>PUT</td>
<td align="right">77</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td align="right">15</td>
<td align="right">15</td>
<td align="right">3</td>
	</tr>
	<tr>
<td align="right">3</td>
<td align="right">12</td>
<td align="right">10</td>
<td>&emsp;&emsp;SYS.DBMS_OUTPUT.NEW_LINE:117</td>
<td>SYS</td>
<td>DBMS_OUTPUT</td>
<td>PACKAGE BODY</td>
<td>NEW_LINE</td>
<td align="right">117</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td align="right">2</td>
<td align="right">2</td>
<td align="right">3</td>
	</tr>
	<tr>
<td align="right">2</td>
<td align="right">5</td>
<td align="right">18</td>
<td>&emsp;HR.UPDATE_SALARY.__static_sql_exec_line8:8</td>
<td>HR</td>
<td>UPDATE_SALARY</td>
<td>PROCEDURE</td>
<td>__static_sql_exec_line8</td>
<td align="right">8</td>
<td>gx0mwrab02p3g</td>
<td>SELECT * FROM EMPLOYEES WHERE EMP_ID = :B1 </td>
<td align="right">176</td>
<td align="right">176</td>
<td align="right">1</td>
	</tr>
	<tr>
<td align="right">2</td>
<td align="right">5</td>
<td align="right">15</td>
<td>&emsp;HR.UPDATE_SALARY.__static_sql_exec_line21:21</td>
<td>HR</td>
<td>UPDATE_SALARY</td>
<td>PROCEDURE</td>
<td>__static_sql_exec_line21</td>
<td align="right">21</td>
<td>czgj1xbux31qt</td>
<td>UPDATE EMPLOYEES SET SALARY = SALARY * ( (100 + :B</td>
<td align="right">453</td>
<td align="right">208</td>
<td align="right">1</td>
	</tr>
	<tr>
<td align="right">3</td>
<td align="right">15</td>
<td align="right">3</td>
<td>&emsp;&emsp;..__plsql_vm@1:0</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>__plsql_vm@1</td>
<td align="right">0</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td align="right">245</td>
<td align="right">1</td>
<td align="right">1</td>
	</tr>
	<tr>
<td align="right">4</td>
<td align="right">3</td>
<td align="right">4</td>
<td>&emsp;&emsp;&emsp;HR.TRG_SALARY_HISTORY.TRG_SALARY_HISTORY:0</td>
<td>HR</td>
<td>TRG_SALARY_HISTORY</td>
<td>TRIGGER</td>
<td>TRG_SALARY_HISTORY</td>
<td align="right">0</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td align="right">244</td>
<td align="right">33</td>
<td align="right">1</td>
	</tr>
	<tr>
<td align="right">5</td>
<td align="right">4</td>
<td align="right">12</td>
<td>&emsp;&emsp;&emsp;&emsp;SYS.DBMS_OUTPUT.PUT_LINE:109</td>
<td>SYS</td>
<td>DBMS_OUTPUT</td>
<td>PACKAGE BODY</td>
<td>PUT_LINE</td>
<td align="right">109</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td align="right">19</td>
<td align="right">2</td>
<td align="right">3</td>
	</tr>
	<tr>
<td align="right">6</td>
<td align="right">12</td>
<td align="right">11</td>
<td>&emsp;&emsp;&emsp;&emsp;&emsp;SYS.DBMS_OUTPUT.PUT:77</td>
<td>SYS</td>
<td>DBMS_OUTPUT</td>
<td>PACKAGE BODY</td>
<td>PUT</td>
<td align="right">77</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td align="right">15</td>
<td align="right">15</td>
<td align="right">3</td>
	</tr>
	<tr>
<td align="right">6</td>
<td align="right">12</td>
<td align="right">10</td>
<td>&emsp;&emsp;&emsp;&emsp;&emsp;SYS.DBMS_OUTPUT.NEW_LINE:117</td>
<td>SYS</td>
<td>DBMS_OUTPUT</td>
<td>PACKAGE BODY</td>
<td>NEW_LINE</td>
<td align="right">117</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td align="right">2</td>
<td align="right">2</td>
<td align="right">3</td>
	</tr>
	<tr>
<td align="right">5</td>
<td align="right">4</td>
<td align="right">14</td>
<td>&emsp;&emsp;&emsp;&emsp;HR.TRG_SALARY_HISTORY.__static_sql_exec_line5:5</td>
<td>HR</td>
<td>TRG_SALARY_HISTORY</td>
<td>TRIGGER</td>
<td>__static_sql_exec_line5</td>
<td align="right">5</td>
<td>fzsnvn0f1q3rj</td>
<td>INSERT INTO SALARY_HISTORY ( EMP_ID, SALARY, CHANG</td>
<td align="right">209</td>
<td align="right">209</td>
<td align="right">1</td>
	</tr>
	<tr>
<td align="right">2</td>
<td align="right">5</td>
<td align="right">16</td>
<td>&emsp;HR.UPDATE_SALARY.__static_sql_exec_line25:25</td>
<td>HR</td>
<td>UPDATE_SALARY</td>
<td>PROCEDURE</td>
<td>__static_sql_exec_line25</td>
<td align="right">25</td>
<td>8ggw94h7mvxd7</td>
<td>COMMIT</td>
<td align="right">87</td>
<td align="right">87</td>
<td align="right">1</td>
	</tr>
	<tr>
<td align="right">2</td>
<td align="right">5</td>
<td align="right">17</td>
<td>&emsp;HR.UPDATE_SALARY.__static_sql_exec_line27:27</td>
<td>HR</td>
<td>UPDATE_SALARY</td>
<td>PROCEDURE</td>
<td>__static_sql_exec_line27</td>
<td align="right">27</td>
<td>gx0mwrab02p3g</td>
<td>SELECT * FROM EMPLOYEES WHERE EMP_ID = :B1 </td>
<td align="right">61</td>
<td align="right">61</td>
<td align="right">1</td>
	</tr>
</tbody></table>
</body></html>

<!--
Also read the LICENSE and follow it.
-->