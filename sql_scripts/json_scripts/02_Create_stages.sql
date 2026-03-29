
CREATE OR REPLACE FILE FORMAT json_format
  TYPE = JSON
  COMPRESSION = AUTO
  STRIP_OUTER_ARRAY = TRUE;


CREATE OR REPLACE STAGE stage_synthea_STREAM_100_PATS FILE_FORMAT = json_format;
CREATE OR REPLACE STAGE stage_synthea_batch_01 FILE_FORMAT = json_format;
CREATE OR REPLACE STAGE stage_synthea_batch_02 FILE_FORMAT = json_format;
CREATE OR REPLACE STAGE stage_synthea_batch_03 FILE_FORMAT = json_format;
CREATE OR REPLACE STAGE stage_synthea_batch_04 FILE_FORMAT = json_format;
CREATE OR REPLACE STAGE stage_synthea_batch_05 FILE_FORMAT = json_format;
CREATE OR REPLACE STAGE stage_synthea_batch_06 FILE_FORMAT = json_format;
CREATE OR REPLACE STAGE stage_synthea_batch_07 FILE_FORMAT = json_format;
CREATE OR REPLACE STAGE stage_synthea_batch_08 FILE_FORMAT = json_format;
CREATE OR REPLACE STAGE stage_synthea_batch_09 FILE_FORMAT = json_format;
CREATE OR REPLACE STAGE stage_synthea_batch_10 FILE_FORMAT = json_format;
