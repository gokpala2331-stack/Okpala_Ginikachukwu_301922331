-- Bank/FinTech Platform: tables, keys and business constraints.
-- Run once in a fresh PostgreSQL database.
BEGIN;
SET LOCAL standard_conforming_strings = on;
CREATE SCHEMA portfolio;
CREATE TABLE portfolio."customer" (
  "customer_id" bigint NOT NULL,
  "full_name" text NOT NULL,
  "email" text NOT NULL,
  "created_on" date NOT NULL,
  CONSTRAINT "pk_customer" PRIMARY KEY ("customer_id"),
  CONSTRAINT "uq_customer_0" UNIQUE ("email")
);
CREATE TABLE portfolio."account" (
  "account_id" bigint NOT NULL,
  "customer_id" bigint NOT NULL,
  "account_number" text NOT NULL,
  "opened_on" date NOT NULL,
  "balance" numeric(18,2) NOT NULL,
  "status" text NOT NULL,
  "is_primary" boolean NOT NULL,
  CONSTRAINT "pk_account" PRIMARY KEY ("account_id"),
  CONSTRAINT "uq_account_0" UNIQUE ("account_number")
);
CREATE TABLE portfolio."ledger_entry" (
  "entry_id" bigint NOT NULL,
  "account_id" bigint NOT NULL,
  "amount" numeric(18,2) NOT NULL,
  "entry_type" text NOT NULL,
  "occurred_at" timestamptz NOT NULL,
  "reference" text,
  CONSTRAINT "pk_ledger_entry" PRIMARY KEY ("entry_id")
);
ALTER TABLE portfolio."account" ADD CONSTRAINT "fk_account_0" FOREIGN KEY ("customer_id") REFERENCES portfolio."customer" ("customer_id");
ALTER TABLE portfolio."ledger_entry" ADD CONSTRAINT "fk_ledger_entry_0" FOREIGN KEY ("account_id") REFERENCES portfolio."account" ("account_id");
ALTER TABLE portfolio."account" ADD CONSTRAINT "account_balance_nonnegative" CHECK ("balance" >= 0);
CREATE UNIQUE INDEX "one_primary_account_per_customer" ON portfolio."account" ("customer_id") WHERE ("is_primary" IS NOT NULL);
ALTER TABLE portfolio."ledger_entry" ADD CONSTRAINT "ledger_amount_positive" CHECK ("amount" > 0);
COMMIT;
