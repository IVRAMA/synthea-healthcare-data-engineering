CREATE OR REPLACE TABLE TABLE_COLUMN_PREVIEW (
  TABLE_NAME      VARCHAR,
  COLUMN_NAME     VARCHAR,
  ORDINAL_POSITION INT,
  DATA1           VARCHAR,
  DATA2           VARCHAR,
  DATA3           VARCHAR
);

 CREATE OR REPLACE PROCEDURE BUILD_PREVIEW()
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
AS
$$
// Get context DYNAMICALLY
var db_stmt = snowflake.createStatement({sqlText: "SELECT CURRENT_DATABASE()"});
var db_rs = db_stmt.execute();
db_rs.next();
var db = db_rs.getColumnValue(1);

var sch_stmt = snowflake.createStatement({sqlText: "SELECT CURRENT_SCHEMA()"});
var sch_rs = sch_stmt.execute();
sch_rs.next();
var sch = sch_rs.getColumnValue(1);

// Your loop...
var rs = snowflake.createStatement({
  sqlText: `SELECT TABLE_NAME, COLUMN_NAME, ORDINAL_POSITION
            FROM ${db}.INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = 'STAGING'
            ORDER BY TABLE_NAME, ORDINAL_POSITION`
}).execute();

while (rs.next()) { var tbl = rs.getColumnValue(1);
  var col = rs.getColumnValue(2);
  var ord = rs.getColumnValue(3);

  // quote column name for reserved words or spaces
  var quoted_col = '"' + col.replace(/"/g, '""') + '"';

  // safely embed the raw column name as a string literal for insertion
  var col_literal = "'" + col.replace(/'/g, "''") + "'";

  var sql = `
    INSERT INTO ${db}.STAGING.TABLE_COLUMN_PREVIEW
    SELECT 
      '${tbl}' AS table_name,
      ${col_literal} AS column_name,
      ${ord} AS ordinal_position,
      MAX(IFF(rn = 1, TO_VARCHAR(${quoted_col}), NULL)) AS data1,
      MAX(IFF(rn = 2, TO_VARCHAR(${quoted_col}), NULL)) AS data2,
      MAX(IFF(rn = 3, TO_VARCHAR(${quoted_col}), NULL)) AS data3
    FROM (
      SELECT ${quoted_col}, ROW_NUMBER() OVER (ORDER BY 1) AS rn
      FROM ${db}.${sch}."${tbl}"
      QUALIFY rn <= 3
    );
  `;

  snowflake.execute({ sqlText: sql });}

return 'OK';
$$;




CALL BUILD_PREVIEW();