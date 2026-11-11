-- Fictional sample records for Bank/FinTech Platform.
BEGIN;
SET LOCAL standard_conforming_strings = on;
INSERT INTO portfolio."customer" ("customer_id", "full_name", "email", "created_on") VALUES (1, 'Avery Chen', 'avery.chen@example.test', '2025-01-10');
INSERT INTO portfolio."customer" ("customer_id", "full_name", "email", "created_on") VALUES (2, 'Morgan Patel', 'morgan.patel@example.test', '2025-02-14');
INSERT INTO portfolio."customer" ("customer_id", "full_name", "email", "created_on") VALUES (3, 'Jordan Lee', 'jordan.lee@example.test', '2025-03-01');
INSERT INTO portfolio."account" ("account_id", "customer_id", "account_number", "opened_on", "balance", "status", "is_primary") VALUES (4, 1, 'ACCT-1001', '2025-01-12', 120.5, 'active', TRUE);
INSERT INTO portfolio."account" ("account_id", "customer_id", "account_number", "opened_on", "balance", "status", "is_primary") VALUES (5, 2, 'ACCT-1002', '2025-02-16', 80, 'active', TRUE);
INSERT INTO portfolio."ledger_entry" ("entry_id", "account_id", "amount", "entry_type", "occurred_at", "reference") VALUES (6, 4, 20.5, 'credit', '2025-01-13T10:15:00Z', 'REF-1001');
INSERT INTO portfolio."ledger_entry" ("entry_id", "account_id", "amount", "entry_type", "occurred_at", "reference") VALUES (7, 5, 10, 'debit', '2025-02-17T14:30:00+00:00', NULL);
-- Keep the identity sequence ahead of the explicit sample entry IDs.
SELECT setval(pg_get_serial_sequence('portfolio.ledger_entry', 'entry_id'),
              (SELECT MAX(entry_id) FROM portfolio.ledger_entry));
COMMIT;
