-- Portfolio 3: atomic inter-account transfer for Bank/FinTech Platform.
-- Run P1 schema and sample data first.
-- This function records successful transfers only; errors abort the statement.
-- If called inside an explicit transaction, the caller must ROLLBACK after an error.

CREATE OR REPLACE FUNCTION portfolio.transfer_funds(
  p_source_account_id BIGINT,
  p_destination_account_id BIGINT,
  p_amount NUMERIC(18,2),
  p_transfer_reference TEXT
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
  v_source_balance NUMERIC(18,2);
  v_transfer_id BIGINT;
BEGIN
  IF p_source_account_id = p_destination_account_id THEN
    RAISE EXCEPTION 'Source and destination accounts must be different'
      USING ERRCODE = '22023';
  END IF;

  IF p_amount IS NULL OR p_amount <= 0 THEN
    RAISE EXCEPTION 'Transfer amount must be greater than zero'
      USING ERRCODE = '22023';
  END IF;

  IF p_transfer_reference IS NULL OR BTRIM(p_transfer_reference) = '' THEN
    RAISE EXCEPTION 'A non-empty transfer reference is required'
      USING ERRCODE = '22023';
  END IF;

  -- Lock the two account rows in deterministic ID order to reduce deadlock risk.
  PERFORM account_id
  FROM portfolio.account
  WHERE account_id IN (p_source_account_id, p_destination_account_id)
  ORDER BY account_id
  FOR UPDATE;

  SELECT balance INTO v_source_balance
  FROM portfolio.account
  WHERE account_id = p_source_account_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Source account % does not exist', p_source_account_id
      USING ERRCODE = 'P0002';
  END IF;

  PERFORM 1
  FROM portfolio.account
  WHERE account_id = p_destination_account_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Destination account % does not exist', p_destination_account_id
      USING ERRCODE = 'P0002';
  END IF;

  IF v_source_status <> 'active' THEN\n    RAISE EXCEPTION 'Source account % is not active', p_source_account_id\n      USING ERRCODE = '55000';\n  END IF;\n\n  IF v_destination_status <> 'active' THEN\n    RAISE EXCEPTION 'Destination account % is not active', p_destination_account_id\n      USING ERRCODE = '55000';\n  END IF;\n\n  IF v_source_balance < p_amount THEN
    RAISE EXCEPTION 'Insufficient funds in source account %', p_source_account_id
      USING ERRCODE = '23514';
  END IF;

  -- A unique reference provides basic duplicate-request protection.
  INSERT INTO portfolio.transfer
    (source_account_id, destination_account_id, amount, transfer_reference)
  VALUES
    (p_source_account_id, p_destination_account_id, p_amount, BTRIM(p_transfer_reference))
  RETURNING transfer_id INTO v_transfer_id;

  UPDATE portfolio.account
  SET balance = balance - p_amount
  WHERE account_id = p_source_account_id;

  UPDATE portfolio.account
  SET balance = balance + p_amount
  WHERE account_id = p_destination_account_id;

  -- Both ledger postings are committed with the transfer and both balance changes.
  INSERT INTO portfolio.ledger_entry
    (account_id, amount, entry_type, occurred_at, reference, transfer_id)
  VALUES
    (p_source_account_id, p_amount, 'debit', CURRENT_TIMESTAMP,
      BTRIM(p_transfer_reference), v_transfer_id),
    (p_destination_account_id, p_amount, 'credit', CURRENT_TIMESTAMP,
      BTRIM(p_transfer_reference), v_transfer_id);

  RETURN v_transfer_id;
END;
$$;

-- Successful transfer demonstration: run once on a fresh sample database.
-- BEGIN;
-- SELECT portfolio.transfer_funds(4, 5, 20.00, 'DEMO-TRF-0001');
-- COMMIT;
--
-- Expected balances from the supplied sample data:
-- account 4: 120.50 - 20.00 = 100.50
-- account 5:  80.00 + 20.00 = 100.00
--
-- Verify:
-- SELECT account_id, account_number, balance
-- FROM portfolio.account WHERE account_id IN (4, 5) ORDER BY account_id;
--
-- SELECT transfer_id, account_id, entry_type, amount, reference
-- FROM portfolio.ledger_entry
-- WHERE reference = 'DEMO-TRF-0001'
-- ORDER BY entry_id;
--
-- Insufficient-funds test: execute separately, then ROLLBACK the aborted transaction.
-- BEGIN;
-- SELECT portfolio.transfer_funds(4, 5, 999999.00, 'DEMO-TRF-FAIL-0001');
-- ROLLBACK;
-- Verify that the failed transfer reference has no transfer or ledger rows
-- and that the two account balances remain unchanged.
