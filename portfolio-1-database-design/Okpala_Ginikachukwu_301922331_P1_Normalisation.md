# Bank/FinTech Platform — normalisation

The example uses the saved sample records. The full set of fields is in the design and schema.

## Starting grouped records

| account_id | ledger_entry records (list) |
| --- | --- |
| 4 | [6] |
| 5 | [7] |


The record IDs are grouped in a list. In 1NF, each record has its own row and each cell holds one value.

## 1NF: one value per cell

| ledger_entry.entry_id | ledger_entry.account_id | ledger_entry.entry_type | account.account_id | account.customer_id | account.account_number | customer.customer_id | customer.full_name |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 6 | 4 | credit | 4 | 1 | ACCT-1001 | 1 | Avery Chen |
| 7 | 5 | debit | 5 | 2 | ACCT-1002 | 2 | Morgan Patel |

Key: entry_id.

## 2NF: depend on the whole key

The declared candidate keys do not introduce a partial dependency here, so the 1NF rows stay unchanged at this step.

## ledger_entry_example

| ledger_entry.entry_id | ledger_entry.account_id | ledger_entry.entry_type | account.account_id | account.customer_id | account.account_number | customer.customer_id | customer.full_name |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 6 | 4 | credit | 4 | 1 | ACCT-1001 | 1 | Avery Chen |
| 7 | 5 | debit | 5 | 2 | ACCT-1002 | 2 | Morgan Patel |

## 3NF: store each entity’s details once

The entity keys determine their own descriptions. Related records keep foreign keys rather than repeating those descriptions.

## customer

| customer_id | full_name | email | created_on |
| --- | --- | --- | --- |
| 1 | Avery Chen | avery.chen@example.test | 2025-01-10 |
| 2 | Morgan Patel | morgan.patel@example.test | 2025-02-14 |
| 3 | Jordan Lee | jordan.lee@example.test | 2025-03-01 |

## account

| account_id | customer_id | account_number | opened_on | balance | status | is_primary |
| --- | --- | --- | --- | --- | --- | --- |
| 4 | 1 | ACCT-1001 | 2025-01-12 | 120.5 | active | true |
| 5 | 2 | ACCT-1002 | 2025-02-16 | 80 | active | true |

## ledger_entry

| entry_id | account_id | amount | entry_type | occurred_at | reference |
| --- | --- | --- | --- | --- | --- |
| 6 | 4 | 20.5 | credit | 2025-01-13T10:15:00+00:00 | REF-1001 |
| 7 | 5 | 10 | debit | 2025-02-17T14:30:00+00:00 | NULL |

## Dependencies

- customer: (customer_id) → full_name, email, created_on
- account: (account_id) → customer_id, account_number, opened_on, balance, status, is_primary
- ledger_entry: (entry_id) → account_id, amount, entry_type, occurred_at, reference

Joining the decomposed sample tables reproduces the original 2 example rows. The design assumes the declared keys describe the relevant business dependencies.
