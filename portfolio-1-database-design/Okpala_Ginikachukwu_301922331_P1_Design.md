# Bank/FinTech Platform — database design

## Case study and users

The selected case study is a simulated Bank/FinTech Platform. It supports customer account servicing and transaction processing. The database is used by customers viewing their accounts and activity, operations staff reconciling transactions, and analysts preparing account and transaction summaries. All records in this portfolio are synthetic.

## Main operations

- Register a customer and open one or more accounts.
- Maintain account balances and account status.
- Transfer funds between two accounts atomically.
- Record debit and credit ledger entries for each successful transfer.
- Review and summarise account and ledger activity.

## Entities and purpose

| Entity | Information stored |
| --- | --- |
| customer | Customer identity and contact information. |
| account | Account number, owner, opening date, balance, status and primary-account flag. |
| transfer | A successful movement from one account to another, with amount, unique reference and timestamp. |
| ledger_entry | The debit or credit posting associated with an account and, where applicable, a transfer. |

## Relational schema

### customer

| Attribute | Type | Key / rule |
| --- | --- | --- |
| customer_id | BIGINT | Primary key |
| full_name | TEXT | NOT NULL |
| email | TEXT | NOT NULL, UNIQUE |
| created_on | DATE | NOT NULL |

### account

| Attribute | Type | Key / rule |
| --- | --- | --- |
| account_id | BIGINT | Primary key |
| customer_id | BIGINT | Foreign key to customer |
| account_number | TEXT | NOT NULL, UNIQUE |
| opened_on | DATE | NOT NULL |
| balance | NUMERIC(18,2) | NOT NULL, CHECK balance >= 0 |
| status | TEXT | active, dormant, frozen or closed |
| is_primary | BOOLEAN | NOT NULL, defaults to FALSE |

A customer may own multiple accounts. A partial unique index applies only where is_primary = TRUE, which permits multiple non-primary accounts but no more than one primary account for the same customer.

### transfer

| Attribute | Type | Key / rule |
| --- | --- | --- |
| transfer_id | BIGINT | Identity primary key |
| source_account_id | BIGINT | Foreign key to account |
| destination_account_id | BIGINT | Foreign key to account |
| amount | NUMERIC(18,2) | CHECK amount > 0 |
| transfer_reference | TEXT | NOT NULL, UNIQUE |
| created_at | TIMESTAMPTZ | NOT NULL, defaults to current timestamp |

A transfer must have different source and destination accounts. A transfer row represents a successful transfer that is committed together with its two ledger entries and balance updates.

### ledger_entry

| Attribute | Type | Key / rule |
| --- | --- | --- |
| entry_id | BIGINT | Identity primary key |
| account_id | BIGINT | Foreign key to account |
| amount | NUMERIC(18,2) | CHECK amount > 0 |
| entry_type | TEXT | debit or credit |
| occurred_at | TIMESTAMPTZ | NOT NULL |
| reference | TEXT | Optional transfer reference |
| transfer_id | BIGINT | Nullable foreign key to transfer |

Each completed transfer creates a debit ledger entry for the source account and a credit ledger entry for the destination account. The two entries share the same transfer_id.

## Relationships

- One customer can own many accounts; each account belongs to one customer.
- One account can have many ledger entries; each ledger entry belongs to one account.
- One transfer identifies one source account and one destination account.
- One transfer can be linked to its two corresponding ledger entries.

## Integrity and implementation rules

Primary keys uniquely identify rows. Foreign keys prevent accounts, transfers and ledger entries from referring to missing parent records. CHECK constraints restrict balances, amounts, account statuses and ledger entry types. Unique constraints protect customer email, account number and transfer reference.

The transfer routine in Portfolio 3 obtains row locks in account-ID order, checks the sender's balance, updates both balances, writes the transfer row and inserts both ledger entries within one database transaction. If an operation fails, PostgreSQL rolls back the entire statement/transaction so a partial transfer is not committed.

## Assumptions

- The portfolio uses fictional records and one illustrative currency (NGN).
- Account balances are stored to two decimal places.
- A transfer is successful only when both account updates and both ledger postings commit.
- Deposits, withdrawals, fees, multi-currency conversion and external payment rails are outside this small case-study scope.
