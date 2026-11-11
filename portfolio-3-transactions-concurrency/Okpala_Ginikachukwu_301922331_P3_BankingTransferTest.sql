-- Repeatable Portfolio 3 banking transfer verification.
-- Run after P1 schema/sample data and P3_BankingTransfer.sql have been applied.
-- The final ROLLBACK leaves the database unchanged so the test can be rerun.

BEGIN;

SELECT portfolio.transfer_funds(4, 5, 20.00, 'P3-TEST-TRANSFER-0001');

DO $$
DECLARE
  v_source_balance NUMERIC(18,2);
  v_destination_balance NUMERIC(18,2);
  v_transfer_id BIGINT;
  v_ledger_count INTEGER;
BEGIN
  SELECT balance INTO v_source_balance
  FROM portfolio.account WHERE account_id = 4;

  SELECT balance INTO v_destination_balance
  FROM portfolio.account WHERE account_id = 5;

  IF v_source_balance <> 100.50 OR v_destination_balance <> 100.00 THEN
    RAISE EXCEPTION 'Unexpected balances: source %, destination %',
      v_source_balance, v_destination_balance;
  END IF;

  SELECT transfer_id INTO v_transfer_id
  FROM portfolio.transfer
  WHERE transfer_reference = 'P3-TEST-TRANSFER-0001';

  SELECT COUNT(*) INTO v_ledger_count
  FROM portfolio.ledger_entry
  WHERE transfer_id = v_transfer_id;

  IF v_ledger_count <> 2 THEN
    RAISE EXCEPTION 'Expected two ledger postings, found %', v_ledger_count;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM portfolio.ledger_entry
    WHERE transfer_id = v_transfer_id
      AND account_id = 4 AND entry_type = 'debit' AND amount = 20.00
  ) THEN
    RAISE EXCEPTION 'The source debit posting is missing';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM portfolio.ledger_entry
    WHERE transfer_id = v_transfer_id
      AND account_id = 5 AND entry_type = 'credit' AND amount = 20.00
  ) THEN
    RAISE EXCEPTION 'The destination credit posting is missing';
  END IF;

  -- Catch only the expected insufficient-funds SQLSTATE. The nested block
  -- acts as a subtransaction, so writes from the failed call are rolled back.
  BEGIN
    PERFORM portfolio.transfer_funds(
      4, 5, 999999.00, 'P3-TEST-INSUFFICIENT-0001'
    );
    RAISE EXCEPTION 'Expected insufficient-funds error was not raised';
  EXCEPTION
    WHEN SQLSTATE '23514' THEN
      NULL;
  END;

  IF EXISTS (
    SELECT 1 FROM portfolio.transfer
    WHERE transfer_reference = 'P3-TEST-INSUFFICIENT-0001'
  ) THEN
    RAISE EXCEPTION 'Failed transfer row was unexpectedly retained';
  END IF;

  IF EXISTS (
    SELECT 1 FROM portfolio.ledger_entry
    WHERE reference = 'P3-TEST-INSUFFICIENT-0001'
  ) THEN
    RAISE EXCEPTION 'Failed transfer ledger postings were unexpectedly retained';
  END IF;

  IF (SELECT balance FROM portfolio.account WHERE account_id = 4) <> 100.50
     OR (SELECT balance FROM portfolio.account WHERE account_id = 5) <> 100.00 THEN
    RAISE EXCEPTION 'Balances changed after the failed transfer attempt';
  END IF;

  RAISE NOTICE 'Transfer, paired ledger entries and rollback checks passed';
END;
$$;

ROLLBACK;
