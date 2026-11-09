# Bank/FinTech Platform — SQL queries

## 1. Show related customer, account, ledger_entry records (up to 20).

```sql
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
```

| customer_customer_id | customer_full_name | account_account_id | account_account_number | ledger_entry_entry_id | ledger_entry_amount |
| --- | --- | --- | --- | --- | --- |
| 1 | Avery Chen | 4 | ACCT-1001 | 6 | 20.5 |
| 2 | Morgan Patel | 5 | ACCT-1002 | 7 | 10 |

## 2. Find account records where customer_id matches 1 (up to 20).

```sql
SELECT * FROM portfolio."account"
WHERE "customer_id" IS NOT DISTINCT FROM 1
ORDER BY "account_id"
LIMIT 20;
```

| account_id | customer_id | account_number | opened_on | balance | status | is_primary |
| --- | --- | --- | --- | --- | --- | --- |
| 4 | 1 | ACCT-1001 | 2025-01-12 | 120.5 | active | true |

## 3. Count account records for each customer_id (up to 20 groups).

```sql
SELECT "customer_id", count(*) AS record_count
FROM portfolio."account"
GROUP BY "customer_id"
ORDER BY record_count DESC, "customer_id" NULLS LAST
LIMIT 20;
```

| customer_id | record_count |
| --- | --- |
| 1 | 1 |
| 2 | 1 |

## 4. Find ledger_entry records where occurred_at matches "2025-01-13T10:15:00Z" (up to 20).

```sql
SELECT * FROM portfolio."ledger_entry"
WHERE "occurred_at" IS NOT DISTINCT FROM '2025-01-13T10:15:00Z'
ORDER BY "entry_id"
LIMIT 20;
```

| entry_id | account_id | amount | entry_type | occurred_at | reference |
| --- | --- | --- | --- | --- | --- |
| 6 | 4 | 20.5 | credit | 2025-01-13T10:15:00+00:00 | REF-1001 |


## Index comparison

| Phase | Median (ms) | Three runs (ms) | Plan nodes | Buffer hits |
| --- | --- | --- | --- | --- |
| Before index | 2.479 | 2.479, 2.473, 2.551 | Sort → Seq Scan | 274 |
| After index | 0.281 | 0.274, 0.299, 0.281 | Sort → Bitmap Heap Scan → Bitmap Index Scan | 55 |

The median execution time changed from 2.479 ms to 0.281 ms. The measured plan used p2_filter_idx. The results matched in both phases. An index adds storage and write-maintenance costs; timings depend on the selected lookup and environment.

## Execution plans

### Before index, run 1

```text
Sort (actual time=2.448..2.451 rows=50 loops=1)
  Seq Scan on ledger_entry (actual time=0.014..2.412 rows=50 loops=1)
Planning Time: 0.316 ms
Execution Time: 2.479 ms
```

### Before index, run 2

```text
Sort (actual time=2.441..2.444 rows=50 loops=1)
  Seq Scan on ledger_entry (actual time=0.014..2.402 rows=50 loops=1)
Planning Time: 0.341 ms
Execution Time: 2.473 ms
```

### Before index, run 3

```text
Sort (actual time=2.521..2.524 rows=50 loops=1)
  Seq Scan on ledger_entry (actual time=0.014..2.484 rows=50 loops=1)
Planning Time: 0.316 ms
Execution Time: 2.551 ms
```

### After index, run 1

```text
Sort (actual time=0.22..0.222 rows=50 loops=1)
  Bitmap Heap Scan on ledger_entry (actual time=0.029..0.183 rows=50 loops=1)
    Bitmap Index Scan using p2_filter_idx (actual time=0.014..0.015 rows=50 loops=1)
Planning Time: 0.555 ms
Execution Time: 0.274 ms
```

### After index, run 2

```text
Sort (actual time=0.244..0.247 rows=50 loops=1)
  Bitmap Heap Scan on ledger_entry (actual time=0.029..0.208 rows=50 loops=1)
    Bitmap Index Scan using p2_filter_idx (actual time=0.015..0.015 rows=50 loops=1)
Planning Time: 0.525 ms
Execution Time: 0.299 ms
```

### After index, run 3

```text
Sort (actual time=0.227..0.229 rows=50 loops=1)
  Bitmap Heap Scan on ledger_entry (actual time=0.03..0.19 rows=50 loops=1)
    Bitmap Index Scan using p2_filter_idx (actual time=0.015..0.015 rows=50 loops=1)
Planning Time: 0.527 ms
Execution Time: 0.281 ms
```

## Reproduce

Use a fresh database with the Portfolio 1 schema and sample data. Run Okpala_Ginikachukwu_301922331_P2_Queries.sql, then Okpala_Ginikachukwu_301922331_P2_Optimisation.sql. The optimisation script creates a separate performance table and runs EXPLAIN (ANALYZE, BUFFERS).

[Query screenshot](screenshots/Okpala_Ginikachukwu_301922331_P2_QueryResults.png) · [Index comparison](screenshots/Okpala_Ginikachukwu_301922331_P2_IndexComparison.png)

## References

- [PostgreSQL — EXPLAIN](https://www.postgresql.org/docs/17/using-explain.html)

