# Bank/FinTech Platform — normalisation to 3NF

## Starting point: unnormalised activity view

A first spreadsheet-style view might place customer, account and transaction details in one record and store several ledger postings in a repeating list. Repeating groups make searching, updating and validating individual postings difficult.

| account_number | customer_name | ledger_entries |
| --- | --- | --- |
| ACCT-1001 | Avery Chen | [credit 20.50; debit 5.00] |
| ACCT-1002 | Morgan Patel | [credit 10.00] |

This is an illustrative unnormalised representation, not the implemented database structure.

## 1NF — atomic values

Remove the repeating ledger-entry list so every posting occupies its own row and every cell contains one value.

| entry_id | account_number | customer_name | entry_type | amount |
| ---: | --- | --- | --- | ---: |
| 6 | ACCT-1001 | Avery Chen | credit | 20.50 |
| 8 | ACCT-1001 | Avery Chen | debit | 5.00 |
| 7 | ACCT-1002 | Morgan Patel | credit | 10.00 |

The illustrative relation has entry_id as its single-attribute key. All values are atomic, so it satisfies the 1NF requirement.

## 2NF — remove partial dependencies

A relation is in 2NF when it is in 1NF and every non-key attribute depends on the whole candidate key. Because entry_id is a single-attribute key, a partial dependency on only part of that key cannot occur. The illustrative relation therefore satisfies 2NF, although customer and account details still repeat across ledger rows.

## 3NF — remove transitive dependencies

The flattened activity relation contains dependencies such as:

- entry_id → account_id, entry_type, amount, occurred_at, transfer_id
- account_id → customer_id, account_number, opened_on, balance, status, is_primary
- customer_id → full_name, email, created_on
- transfer_id → source_account_id, destination_account_id, amount, transfer_reference, created_at

For example, entry_id determines account_id, and account_id determines customer_id. Therefore customer details depend on entry_id through account_id and customer_id. Keeping all these attributes in one table creates transitive dependencies and update anomalies.

The design decomposes the relation into:

- customer(customer_id, full_name, email, created_on)
- account(account_id, customer_id, account_number, opened_on, balance, status, is_primary)
- transfer(transfer_id, source_account_id, destination_account_id, amount, transfer_reference, created_at)
- ledger_entry(entry_id, account_id, amount, entry_type, occurred_at, reference, transfer_id)

Each non-key attribute in these relations depends on its table's key, the whole key, and nothing but the key, subject to the stated business rules. Foreign keys preserve the relationships and allow the original activity view to be reconstructed with joins.

## Result

The decomposition reduces repeated customer and account details, supports independent account and customer updates, and keeps a transfer's two ledger postings linked through transfer_id. The ER diagram and P1 schema implement this decomposition.
