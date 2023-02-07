-- create target table
CREATE TABLE target_table (
  id INTEGER PRIMARY KEY,
  val TEXT );

 -- insert data into target table
INSERT INTO target_table VALUES 
(1, 'A'),
(2, 'A'),
(3, null),
(5, 'A'),
(8, 'A'),
(9, null),
(10, null);

SELECT * FROM target_table tt;

-- create source table
CREATE TABLE source_table (
  id INTEGER PRIMARY KEY,
  val TEXT );
 
 -- insert data into source table
INSERT INTO source_table VALUES (1, null),
(2, 'B'),
(4, 'B'),
(8, 'B'),
(9, 'B'),
(10, null),
(11, null);

SELECT * FROM source_table;

-- Update Table Questions
-- 1. update

-- Create a copy of target table
CREATE TABLE update_target AS SELECT * FROM target_table tt; 
-- Check copy of update_target table
SELECT * FROM update_target;

/* The target.id is kept, but the target.val is being updated with source.val */

UPDATE update_target
SET val = (SELECT val from source_table WHERE source_table.id = update_target.id)
WHERE update_target.id IN (SELECT id FROM source_table);

-- check update_target (FINAL RESULT for UPDATE)
SELECT * FROM update_target; 

-- 2. update_null_fill

-- Create a copy of target table
CREATE TABLE update_null_fill AS SELECT * FROM target_table tt;
-- Check copy of update_null_fill
SELECT * FROM update_null_fill;

/* The target.id is kept, but the target.val is being updated with source.val only
 * in locations where target.val is null */

UPDATE update_null_fill
SET val = (SELECT val FROM source_table WHERE source_table.id = update_null_fill.id)
WHERE update_null_fill.val IS NULL; 

-- check update_null_fill (FINAL RESULT for update_null_fill)
SELECT * FROM update_null_fill;

-- 3. update_override

-- Create a copy of target_table
CREATE TABLE update_override AS SELECT * FROM target_table tt; 
-- Check copy of update_override
SELECT * FROM update_override; 

/* The target.id is kept, 
 * but the target.val is replaced with source.val IF source.val is not null
 */

UPDATE update_override
SET val = IFNULL(
(SELECT val FROM source_table 
WHERE update_override.id = source_table.id)
,val)

-- Check copy of update_override
SELECT * FROM update_override; 

-- 4. merge_table
-- create copy of target table and rename as merge_table
CREATE TABLE merge_table (
  id INTEGER PRIMARY KEY,
  val TEXT );

INSERT INTO merge_table VALUES 
(1, 'A'),
(2, 'A'),
(3, null),
(5, 'A'),
(8, 'A'),
(9, null),
(10, null);

-- check merge_table
SELECT * FROM merge_table;

/* The target.id and source.id are both kept, 
 * but the target.val is only being updated with source.val */

REPLACE INTO merge_table (id,val)
SELECT id, val 
FROM source_table; 

-- check merge_table (FINAL RESULT)
SELECT * FROM merge_table;

-- 5. merge_null_fill
-- create copy of target table and rename as merge_null_fill
CREATE TABLE merge_null_fill (
  id INTEGER PRIMARY KEY,
  val TEXT );

INSERT INTO merge_null_fill VALUES 
(1, 'A'),
(2, 'A'),
(3, null),
(5, 'A'),
(8, 'A'),
(9, null),
(10, null);

-- check merge_null_fill
SELECT * FROM merge_null_fill;

/* The target.id and source.id is being merged, 
 * with target.val being updated with source.val if target.val is null or 
target.id does not exist */

-- this merges the id
REPLACE INTO merge_null_fill (id,val)
SELECT id, val 
FROM source_table; 

-- this fills in the A values
UPDATE merge_null_fill 
SET val = (SELECT val from target_table WHERE target_table.id = merge_null_fill.id)
WHERE merge_null_fill.id IN (SELECT id FROM target_table)

-- fills in the B values
UPDATE merge_null_fill
SET val = (SELECT val FROM source_table WHERE source_table.id = merge_null_fill.id)
WHERE merge_null_fill.val IS NULL;

-- check merge_null_fill (FINAL RESULT)
SELECT * FROM merge_null_fill;

-- 6. merge_override

-- create copy of target table and rename as merge_override
CREATE TABLE merge_override (
  id INTEGER PRIMARY KEY,
  val TEXT );

INSERT INTO merge_override VALUES 
(1, 'A'),
(2, 'A'),
(3, null),
(5, 'A'),
(8, 'A'),
(9, null),
(10, null);

-- check merge_override
SELECT * FROM merge_override; 

/* Target.id and source.id is merged with target.val being replaced if source.val is not null */

-- merge id
REPLACE INTO merge_override (id,val)
SELECT id, val 
FROM source_table; 

UPDATE merge_override
SET val = (SELECT val FROM target_table WHERE target_table.id = merge_override.id)
WHERE merge_override.val IS NULL; 

-- check merge_override (FINAL RESULT)
SELECT * FROM merge_override; 

-- 7. append

/* Target table and source table are stacked on top of each other */ 

CREATE TABLE append_table AS SELECT * FROM target_table tt 
UNION ALL
SELECT * FROM source_table

-- check append_table (FINAL RESULT)
SELECT * FROM append_table 