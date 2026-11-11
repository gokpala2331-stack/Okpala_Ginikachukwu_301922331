# Portfolio 3 — Transactions and Concurrency

## Transaction controls

The portfolio demonstrates BEGIN, COMMIT and ROLLBACK, plus READ COMMITTED isolation. The counter exercise is retained as a focused lost-update example. It uses a temporary helper column and is not presented as a banking ledger operation.

## Banking transfer implementation

The additional script `Okpala_Ginikachukwu_301922331_P3_BankingTransfer.sql` creates the PostgreSQL function `portfolio.transfer_funds`. It performs a real account-to-account transfer against the case-study tables.

The function:

1. Rejects a non-positive amount, a missing account, the same source and destination, and an insufficient balance.
2. Locks both account rows in ascending account-ID order to reduce deadlock risk.
3. Inserts a uniquely referenced transfer record.
4. Debits the source account and credits the destination account.
5. Inserts a debit and a credit ledger entry linked to the transfer.
6. Returns the transfer ID. Any error aborts the call/transaction; the caller rolls back to ensure no partial transfer is committed.

### Run the successful transfer

1. Create a fresh PostgreSQL database.
2. Run the Portfolio 1 schema and sample-data scripts.
3. Run `Okpala_Ginikachukwu_301922331_P3_BankingTransfer.sql` to create the function.
4. Execute the following once:

```sql
BEGIN;
SELECT portfolio.transfer_funds(4, 5, 20.00, 'DEMO-TRF-0001');
COMMIT;
```

The sample starts with account 4 at 120.50 and account 5 at 80.00. After a successful 20.00 transfer, the expected balances are 100.50 and 100.00. Verify them with:

```sql
SELECT account_id, account_number, balance
FROM portfolio.account
WHERE account_id IN (4, 5)
ORDER BY account_id;

SELECT transfer_id, account_id, entry_type, amount, reference
FROM portfolio.ledger_entry
WHERE reference = 'DEMO-TRF-0001'
ORDER BY entry_id;
```

These are expected values derived from the sample data. Capture the actual output from your own PostgreSQL run before submitting it as execution evidence.

### Test rollback

Run an insufficient-funds transfer in a separate transaction:

```sql
BEGIN;
SELECT portfolio.transfer_funds(4, 5, 999999.00, 'DEMO-TRF-FAIL-0001');
ROLLBACK;
```

The function should raise an insufficient-funds error. After rollback, verify that the failed reference does not exist in transfer or ledger_entry and that both balances are unchanged.

## Two-session concurrency test

Open two psql sessions connected to the same database. Follow the numbered steps in SessionA.sql and SessionB.sql. The unlocked example shows a lost update; the SELECT FOR UPDATE example serialises access to the counter row. The new transfer function also locks both account rows in a consistent order before checking and changing balances.

## Evidence to capture

- Successful transfer result and both updated balances.
- The two ledger postings showing debit and credit with the same transfer_id.
- Insufficient-funds error followed by verification that no partial posting remains.
- Two-session lost-update and row-locking output.

Do not use expected values in this README as a substitute for screenshots or output captured from an actual run.

## References

- [PostgreSQL — transaction isolation](https://www.postgresql.org/docs/17/transaction-iso.html)
- [PostgreSQL — explicit locking](https://www.postgresql.org/docs/17/explicit-locking.html)
- [PostgreSQL — PL/pgSQL errors and messages](https://www.postgresql.org/docs/17/plpgsql-errors-and-messages.html)
