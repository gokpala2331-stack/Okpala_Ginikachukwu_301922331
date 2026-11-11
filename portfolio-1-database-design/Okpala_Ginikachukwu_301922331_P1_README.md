# Portfolio 1 — Database Design and Modelling

The Bank/FinTech Platform is modelled using four related tables: customer, account, transfer and ledger_entry. The ER diagram and design document describe the entities, keys, relationships and business rules. The normalisation document explains the decomposition to 3NF.

## Database checks

The schema defines primary keys, foreign keys, unique constraints, CHECK constraints and a partial unique index that permits multiple non-primary accounts while limiting each customer to one primary account.

- [Design and case study](Okpala_Ginikachukwu_301922331_P1_Design.md)
- [ER diagram (Mermaid)](Okpala_Ginikachukwu_301922331_P1_ERDiagram.md)\n- [ER diagram (SVG)](../images/Okpala_Ginikachukwu_301922331_ERDiagram.svg)
- [Normalisation](Okpala_Ginikachukwu_301922331_P1_Normalisation.md)
- [Schema](Okpala_Ginikachukwu_301922331_P1_Schema.sql)
- [Sample data](Okpala_Ginikachukwu_301922331_P1_SampleData.sql)
- [Negative constraint tests](Okpala_Ginikachukwu_301922331_P1_ConstraintTests.sql)
- [Positive business-rule test](Okpala_Ginikachukwu_301922331_P1_BusinessRuleTests.sql)

## Run order

1. Create a fresh PostgreSQL database.
2. Run the schema script.
3. Run the sample-data script.
4. Run positive business-rule tests.
5. Run negative constraint tests one statement at a time; each is expected to fail with its documented constraint.

The sample-data script advances the ledger identity sequence after inserting explicit sample IDs. The expected test failures are instructions for the student to reproduce; retain the actual terminal output as evidence.

## Main business rules

- A customer may own several accounts.
- A customer may have at most one account with is_primary = TRUE.
- An account balance cannot be negative.
- Ledger entries must have a positive amount and a debit or credit entry type.
- Every ledger entry refers to an existing account.
- Transfer amounts must be positive and source and destination accounts must differ.
- Transfer references are unique.

All data is fictional. No live financial or customer information is included.
