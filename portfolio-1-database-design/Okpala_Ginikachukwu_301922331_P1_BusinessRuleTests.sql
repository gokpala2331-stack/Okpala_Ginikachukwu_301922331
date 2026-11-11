-- Positive business-rule test: one customer may hold multiple accounts,
-- while a customer may have only one primary account.
-- Run after P1 schema and sample data. All test data is rolled back.

BEGIN;

INSERT INTO portfolio.account
  (account_id, customer_id, account_number, opened_on, balance, status, is_primary)
VALUES
  (2000, 1, 'ACCT-TEST-2000', CURRENT_DATE, 25.00, 'active', FALSE);

DO $$
BEGIN
  IF (SELECT COUNT(*) FROM portfolio.account WHERE customer_id = 1) <> 2 THEN
    RAISE EXCEPTION 'Expected customer 1 to have two accounts during this test';
  END IF;

  IF (SELECT COUNT(*) FROM portfolio.account
      WHERE customer_id = 1 AND is_primary = TRUE) <> 1 THEN
    RAISE EXCEPTION 'Expected customer 1 to have exactly one primary account';
  END IF;
END;
$$;

-- This invalid second primary account must violate one_primary_account_per_customer.
-- Run separately (outside this transaction) to observe the unique-index error:
-- INSERT INTO portfolio.account
--   (account_id, customer_id, account_number, opened_on, balance, status, is_primary)
-- VALUES (2001, 1, 'ACCT-TEST-2001', CURRENT_DATE, 10.00, 'active', TRUE);

ROLLBACK;
