# Bank/FinTech Platform — database design

My case study records customer, account, ledger_entry.

## Users

- Customers reviewing account activity
- Operations staff reconciling ledger entries
- Analysts summarizing account activity

## Main operations

- Open an account for a customer
- Record a debit or credit while maintaining the account balance
- Review and summarize ledger activity

## Entities

| Entity | Information stored |
| --- | --- |
| customer | A person who holds one or more platform accounts. |
| account | An account owned by a customer, with a maintained nonnegative balance. |
| ledger_entry | A debit or credit recorded against one account. |

## customer

| Field | Type | Key | Required |
| --- | --- | --- | --- |
| customer_id | BIGINT | PK | Yes |
| full_name | TEXT |  | Yes |
| email | TEXT | Unique | Yes |
| created_on | DATE |  | Yes |
- Unique key: (email).

## account

| Field | Type | Key | Required |
| --- | --- | --- | --- |
| account_id | BIGINT | PK | Yes |
| customer_id | BIGINT | FK | Yes |
| account_number | TEXT | Unique | Yes |
| opened_on | DATE |  | Yes |
| balance | NUMERIC(18,2) |  | Yes |
| status | TEXT |  | Yes |
| is_primary | BOOLEAN |  | Yes |
- customer_id → customer.customer_id
- Unique key: (account_number).

## ledger_entry

| Field | Type | Key | Required |
| --- | --- | --- | --- |
| entry_id | BIGINT | PK | Yes |
| account_id | BIGINT | FK | Yes |
| amount | NUMERIC(18,2) |  | Yes |
| entry_type | TEXT |  | Yes |
| occurred_at | TIMESTAMPTZ |  | Yes |
| reference | TEXT |  | No |
- account_id → account.account_id

## Relationships and business rules

- Each customer email identifies at most one customer.
- Every account references an existing customer through customer_id.
- An account balance must be at least zero; a debit that would violate this rule is rejected.
- At most one account per customer may have is_primary set to true, enforced with a partial unique constraint on customer_id for primary accounts.
- Every ledger entry references an existing account through account_id.
- Every ledger entry amount must be greater than zero.

## Assumptions

- All amounts use one fictional currency, and each ledger entry affects exactly one account.
- Account balance is maintained atomically with each ledger entry; opening balance is nonnegative.
- Customer email and account number are unique within this synthetic dataset.
- For a normalization exercise, customer_id determines customer details; keep those details in customer and store only customer_id as the account foreign key.
- Student names and IDs are omitted; all example data, if added, must be synthetic.

