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
    ledger_entry {
        bigint entry_id PK
        bigint account_id FK
        numeric amount
        text entry_type
        timestamptz occurred_at
        text reference "Optional"
    }
    customer ||--o{ account : "customer_id"
    account ||--o{ ledger_entry : "account_id"
```

PK identifies a record; FK links to another table; UK marks a single-field unique value. The relationship ends show exactly one, zero or one, or zero or many records. Composite unique keys and conditional rules are listed in the schema and design.

[Diagram image](../images/Okpala_Ginikachukwu_301922331_ERDiagram.png)
