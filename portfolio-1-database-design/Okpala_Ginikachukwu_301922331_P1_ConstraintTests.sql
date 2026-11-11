-- Run these deliberately invalid statements one at a time, outside a transaction.
-- Each should fail at the named constraint; the sample rows should remain unchanged.

-- 1. customer pk. Expected: pk_customer, SQLSTATE 23505.
INSERT INTO portfolio."customer" ("customer_id", "full_name", "email", "created_on")
VALUES (1, 'Riley Stone', 'riley.pk@example.test', '2025-03-02');

-- 2. customer unique. Expected: uq_customer_email, SQLSTATE 23505.
INSERT INTO portfolio."customer" ("customer_id", "full_name", "email", "created_on")
VALUES (101, 'Riley Stone', 'avery.chen@example.test', '2025-03-03');

-- 3. customer nn id. Expected: customer_id, SQLSTATE 23502.
INSERT INTO portfolio."customer" ("customer_id", "full_name", "email", "created_on")
VALUES (NULL, 'Riley Stone', 'riley.id@example.test', '2025-03-04');

-- 4. customer nn name. Expected: full_name, SQLSTATE 23502.
INSERT INTO portfolio."customer" ("customer_id", "full_name", "email", "created_on")
VALUES (102, NULL, 'riley.name@example.test', '2025-03-05');

-- 5. customer nn email. Expected: email, SQLSTATE 23502.
INSERT INTO portfolio."customer" ("customer_id", "full_name", "email", "created_on")
VALUES (103, 'Riley Stone', NULL, '2025-03-06');

-- 6. customer nn created. Expected: created_on, SQLSTATE 23502.
INSERT INTO portfolio."customer" ("customer_id", "full_name", "email", "created_on")
VALUES (104, 'Riley Stone', 'riley.date@example.test', NULL);

-- 7. account pk. Expected: pk_account, SQLSTATE 23505.
INSERT INTO portfolio."account" ("account_id", "customer_id", "account_number", "opened_on", "balance", "status", "is_primary")
VALUES (4, 3, 'ACCT-2001', '2025-03-02', 10, 'active', FALSE);

-- 8. account unique. Expected: uq_account_number, SQLSTATE 23505.
INSERT INTO portfolio."account" ("account_id", "customer_id", "account_number", "opened_on", "balance", "status", "is_primary")
VALUES (105, 3, 'ACCT-1001', '2025-03-03', 10, 'active', FALSE);

-- 9. account fk. Expected: fk_account_customer, SQLSTATE 23503.
INSERT INTO portfolio."account" ("account_id", "customer_id", "account_number", "opened_on", "balance", "status", "is_primary")
VALUES (106, 90001, 'ACCT-2002', '2025-03-04', 10, 'active', FALSE);

-- 10. account nn id. Expected: account_id, SQLSTATE 23502.
INSERT INTO portfolio."account" ("account_id", "customer_id", "account_number", "opened_on", "balance", "status", "is_primary")
VALUES (NULL, 3, 'ACCT-2003', '2025-03-05', 10, 'active', FALSE);

-- 11. account nn customer. Expected: customer_id, SQLSTATE 23502.
INSERT INTO portfolio."account" ("account_id", "customer_id", "account_number", "opened_on", "balance", "status", "is_primary")
VALUES (107, NULL, 'ACCT-2004', '2025-03-06', 10, 'active', FALSE);

-- 12. account nn number. Expected: account_number, SQLSTATE 23502.
INSERT INTO portfolio."account" ("account_id", "customer_id", "account_number", "opened_on", "balance", "status", "is_primary")
VALUES (108, 3, NULL, '2025-03-07', 10, 'active', FALSE);

-- 13. account nn opened. Expected: opened_on, SQLSTATE 23502.
INSERT INTO portfolio."account" ("account_id", "customer_id", "account_number", "opened_on", "balance", "status", "is_primary")
VALUES (109, 3, 'ACCT-2005', NULL, 10, 'active', FALSE);

-- 14. account nn balance. Expected: balance, SQLSTATE 23502.
INSERT INTO portfolio."account" ("account_id", "customer_id", "account_number", "opened_on", "balance", "status", "is_primary")
VALUES (110, 3, 'ACCT-2006', '2025-03-08', NULL, 'active', FALSE);

-- 15. account nn status. Expected: status, SQLSTATE 23502.
INSERT INTO portfolio."account" ("account_id", "customer_id", "account_number", "opened_on", "balance", "status", "is_primary")
VALUES (111, 3, 'ACCT-2007', '2025-03-09', 10, NULL, FALSE);

-- 16. account nn primary. Expected: is_primary, SQLSTATE 23502.
INSERT INTO portfolio."account" ("account_id", "customer_id", "account_number", "opened_on", "balance", "status", "is_primary")
VALUES (112, 3, 'ACCT-2008', '2025-03-10', 10, 'active', NULL);

-- 17. account balance check. Expected: account_balance_nonnegative, SQLSTATE 23514.
INSERT INTO portfolio."account" ("account_id", "customer_id", "account_number", "opened_on", "balance", "status", "is_primary")
VALUES (113, 3, 'ACCT-2009', '2025-03-11', -1, 'active', FALSE);

-- 18. account partial unique. Expected: one_primary_account_per_customer, SQLSTATE 23505.
INSERT INTO portfolio."account" ("account_id", "customer_id", "account_number", "opened_on", "balance", "status", "is_primary")
VALUES (114, 1, 'ACCT-2010', '2025-03-12', 10, 'active', TRUE);

-- 19. ledger pk. Expected: pk_ledger_entry, SQLSTATE 23505.
INSERT INTO portfolio."ledger_entry" ("entry_id", "account_id", "amount", "entry_type", "occurred_at", "reference")
VALUES (6, 5, 1, 'credit', '2025-03-02T10:00:00Z', 'REF-2001');

-- 20. ledger fk. Expected: fk_ledger_entry_account, SQLSTATE 23503.
INSERT INTO portfolio."ledger_entry" ("entry_id", "account_id", "amount", "entry_type", "occurred_at", "reference")
VALUES (115, 90002, 1, 'credit', '2025-03-03T10:00:00Z', 'REF-2002');

-- 21. ledger nn id. Expected: entry_id, SQLSTATE 23502.
INSERT INTO portfolio."ledger_entry" ("entry_id", "account_id", "amount", "entry_type", "occurred_at", "reference")
VALUES (NULL, 4, 1, 'credit', '2025-03-04T10:00:00Z', NULL);

-- 22. ledger nn account. Expected: account_id, SQLSTATE 23502.
INSERT INTO portfolio."ledger_entry" ("entry_id", "account_id", "amount", "entry_type", "occurred_at", "reference")
VALUES (116, NULL, 1, 'credit', '2025-03-05T10:00:00Z', NULL);

-- 23. ledger nn amount. Expected: amount, SQLSTATE 23502.
INSERT INTO portfolio."ledger_entry" ("entry_id", "account_id", "amount", "entry_type", "occurred_at", "reference")
VALUES (117, 4, NULL, 'credit', '2025-03-06T10:00:00Z', NULL);

-- 24. ledger nn type. Expected: entry_type, SQLSTATE 23502.
INSERT INTO portfolio."ledger_entry" ("entry_id", "account_id", "amount", "entry_type", "occurred_at", "reference")
VALUES (118, 4, 1, NULL, '2025-03-07T10:00:00Z', NULL);

-- 25. ledger nn time. Expected: occurred_at, SQLSTATE 23502.
INSERT INTO portfolio."ledger_entry" ("entry_id", "account_id", "amount", "entry_type", "occurred_at", "reference")
VALUES (119, 4, 1, 'credit', NULL, NULL);

-- 26. ledger amount check. Expected: ledger_amount_positive, SQLSTATE 23514.
INSERT INTO portfolio."ledger_entry" ("entry_id", "account_id", "amount", "entry_type", "occurred_at", "reference")
VALUES (120, 4, 0, 'credit', '2025-03-08T10:00:00Z', 'REF-2003');
