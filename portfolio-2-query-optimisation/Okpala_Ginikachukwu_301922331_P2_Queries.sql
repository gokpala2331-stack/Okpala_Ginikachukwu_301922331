-- Show related customer, account, ledger_entry records (up to 20).
SELECT t0."customer_id" AS "customer_customer_id",
       t0."full_name" AS "customer_full_name",
       t1."account_id" AS "account_account_id",
       t1."account_number" AS "account_account_number",
       t2."entry_id" AS "ledger_entry_entry_id",
       t2."amount" AS "ledger_entry_amount"
FROM portfolio."customer" t0
JOIN portfolio."account" t1 ON t1."customer_id" = t0."customer_id"
JOIN portfolio."ledger_entry" t2 ON t2."account_id" = t1."account_id"
ORDER BY t0."customer_id", t1."account_id", t2."entry_id"
LIMIT 20;

EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT t0."customer_id" AS "customer_customer_id",
       t0."full_name" AS "customer_full_name",
       t1."account_id" AS "account_account_id",
       t1."account_number" AS "account_account_number",
       t2."entry_id" AS "ledger_entry_entry_id",
       t2."amount" AS "ledger_entry_amount"
FROM portfolio."customer" t0
JOIN portfolio."account" t1 ON t1."customer_id" = t0."customer_id"
JOIN portfolio."ledger_entry" t2 ON t2."account_id" = t1."account_id"
ORDER BY t0."customer_id", t1."account_id", t2."entry_id"
LIMIT 20;

-- Find account records where customer_id matches 1 (up to 20).
SELECT * FROM portfolio."account"
WHERE "customer_id" IS NOT DISTINCT FROM 1
ORDER BY "account_id"
LIMIT 20;

EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT * FROM portfolio."account"
WHERE "customer_id" IS NOT DISTINCT FROM 1
ORDER BY "account_id"
LIMIT 20;

-- Count account records for each customer_id (up to 20 groups).
SELECT "customer_id", count(*) AS record_count
FROM portfolio."account"
GROUP BY "customer_id"
ORDER BY record_count DESC, "customer_id" NULLS LAST
LIMIT 20;

EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT "customer_id", count(*) AS record_count
FROM portfolio."account"
GROUP BY "customer_id"
ORDER BY record_count DESC, "customer_id" NULLS LAST
LIMIT 20;

-- Find ledger_entry records where occurred_at matches "2025-01-13T10:15:00Z" (up to 20).
SELECT * FROM portfolio."ledger_entry"
WHERE "occurred_at" IS NOT DISTINCT FROM '2025-01-13T10:15:00Z'
ORDER BY "entry_id"
LIMIT 20;

EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT * FROM portfolio."ledger_entry"
WHERE "occurred_at" IS NOT DISTINCT FROM '2025-01-13T10:15:00Z'
ORDER BY "entry_id"
LIMIT 20;
