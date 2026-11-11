# Bank/FinTech Platform — ER diagram

```mermaid
erDiagram
    direction LR
    customer {
        bigint customer_id PK
        text full_name
        text email UK
        date created_on
    }
    account {
        bigint account_id PK
        bigint customer_id FK
        text account_number UK
        date opened_on
        numeric balance
        text status
        boolean is_primary
    }
    transfer {
        bigint transfer_id PK
        bigint source_account_id FK
        bigint destination_account_id FK
        numeric amount
        text transfer_reference UK
        timestamptz created_at
    }
    ledger_entry {
        bigint entry_id PK
        bigint account_id FK
        numeric amount
        text entry_type
        timestamptz occurred_at
        text reference
        bigint transfer_id FK
    }
    customer ||--o{ account : owns
    account ||--o{ ledger_entry : records
    account ||--o{ transfer : source
    account ||--o{ transfer : destination
    transfer ||--o{ ledger_entry : posts
```

The diagram shows the four relational entities. PK identifies a row, FK links to another table, and UK indicates a unique value. The two account-to-transfer relationships distinguish the source account from the destination account. A completed transfer is linked to its debit and credit ledger entries using transfer_id.
