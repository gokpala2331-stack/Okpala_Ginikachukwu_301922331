# Portfolio 3 — Transactions and Concurrency

## Transaction controls

The portfolio demonstrates BEGIN, COMMIT and ROLLBACK, READ COMMITTED isolation, a lost-update scenario and SELECT FOR UPDATE across two sessions. The original counter exercise is retained as a focused example of concurrency anomalies; it is not represented as a banking ledger operation.

## Banking transfer implementation

The additional script `Okpala_Ginikachukwu_301922331_P3_BankingTransfer.sql` creates the PostgreSQL function `portfolio.transfer_funds`. It performs a transfer between two accounts in the case-study database.

The function:

1. Rejects non-positive amounts, identical source and destination accounts, missing accounts and non-active accounts.
2. Locks both account rows in ascending account-ID order to reduce deadlock risk.
3. Checks that the source account has sufficient funds.
4. Inserts a unique transfer record.
5. Debits the source and credits the destination.
6. Inserts matching debit and credit ledger entries linked to the transfer ID.

All changes are made within the same database transaction. If an operation fails, the statement is aborted; when using an explicit transaction, the caller must issue ROLLBACK.

## Repeatable transfer test

Run the P1 schema and sample-data scripts, then run the transfer function script. Next run `Okpala_Ginikachukwu_301922331_P3_BankingTransferTest.sql`. It executes a 20.00 test transfer, checks the balances and paired ledger postings, attempts an insufficient-funds transfer, checks that the failed attempt left no partial records or balance changes, and finally rolls the entire test transaction back.

The expected post-transfer balances during the test are:
- Account 4: 100.50 (starting balance 120.50 less 20.00).
- Account 5: 100.00 (starting balance 80.00 plus 20.00).

These are expected values calculated from the sample data. Capture the actual terminal output from your PostgreSQL environment before using it as assessment evidence.

## Two-session concurrency test

Open two psql sessions connected to the same database. Follow the numbered steps in SessionA.sql and SessionB.sql. The unlocked example demonstrates a lost update. The SELECT FOR UPDATE example serialises access to the shared counter row. The banking transfer routine also locks both account rows in a consistent order before validating and changing balances.

## Files

- [Banking transfer function](Okpala_Ginikachukwu_301922331_P3_BankingTransfer.sql)
- [Repeatable transfer test](Okpala_Ginikachukwu_301922331_P3_BankingTransferTest.sql)
- [Transaction controls](Okpala_Ginikachukwu_301922331_P3_Transactions.sql)
- [Session A](Okpala_Ginikachukwu_301922331_P3_SessionA.sql)
- [Session B](Okpala_Ginikachukwu_301922331_P3_SessionB.sql)
- [Commit and rollback screenshot](screenshots/Okpala_Ginikachukwu_301922331_P3_CommitRollback.png)
- [Concurrency screenshot](screenshots/Okpala_Ginikachukwu_301922331_P3_ConcurrencyResult.png)

## References

- [PostgreSQL — transaction isolation](https://www.postgresql.org/docs/17/transaction-iso.html)
- [PostgreSQL — explicit locking](https://www.postgresql.org/docs/17/explicit-locking.html)
- [PostgreSQL — PL/pgSQL errors and messages](https://www.postgresql.org/docs/17/plpgsql-errors-and-messages.html)
