# Portfolio 4 — NoSQL and Advanced Data Models

The MongoDB implementation stores banking event records in the `ledger_events` collection. It uses a document model for append-oriented event data while PostgreSQL remains the relational system of record for customers, accounts, transfers and ledger entries.

## Document model

| Field | Meaning |
| --- | --- |
| _id | Unique string event ID |
| schemaVersion | Version of the document structure |
| simulation | Identifies the data as fictional portfolio data |
| eventType | account_opened or ledger_entry_recorded |
| occurredAt | Native BSON Date |
| source | Originating entity, key and source-record snapshot |
| embedded | Account and customer snapshots useful for event reads |
| references | Optional references to separately stored records |
| details | Event-specific metadata that can vary between event types |

An `account_opened` event now identifies an account record as its source. A `ledger_entry_recorded` event identifies a ledger-entry record as its source. Both document types may include embedded account and customer snapshots to make the event self-contained for read operations. These snapshots are denormalised copies and do not automatically update when PostgreSQL data changes.

## Example account-opened document

```javascript
{
  _id: "event_000001",
  schemaVersion: 1,
  simulation: true,
  eventType: "account_opened",
  occurredAt: ISODate("2030-01-01T10:00:00Z"),
  source: {
    entity: "account",
    key: { account_id: 4 },
    snapshot: {
      account_id: 4,
      customer_id: 1,
      account_number: "ACCT-1001",
      opened_on: "2025-01-12",
      balance: 120.50,
      status: "active",
      is_primary: true
    }
  },
  embedded: {
    account: [{ key: { account_id: 4 }, snapshot: { account_number: "ACCT-1001" } }],
    customer: [{ key: { customer_id: 1 }, snapshot: { full_name: "Avery Chen" } }]
  },
  references: {},
  details: { channel: "web" }
}
```

## Queries

1. Find account-opening events:

```javascript
db.ledger_events.find({ eventType: "account_opened" }).sort({ _id: 1 }).limit(5);
```

2. Find events associated with account 4, whether the source is the account itself or a ledger entry for that account:

```javascript
db.ledger_events.find({
  $or: [
    { "source.key.account_id": 4 },
    { "source.snapshot.account_id": 4 }
  ]
}).sort({ _id: 1 }).limit(5);
```

3. Find events in a time range:

```javascript
db.ledger_events.find({
  occurredAt: {
    $gte: ISODate("2030-01-01T10:00:00Z"),
    $lt: ISODate("2030-01-01T11:00:00Z")
  }
}).sort({ _id: 1 }).limit(5);
```

4. Count documents by event type:

```javascript
db.ledger_events.aggregate([
  { $group: { _id: "$eventType", documentCount: { $sum: 1 } } },
  { $sort: { _id: 1 } }
]);
```

## Validation, indexing and suitability

The JavaScript implementation creates a collection validator for the common event structure and distinguishes the allowed source entity types (`account` and `ledger_entry`). It inserts four fictional event documents, creates a compound index on eventType and occurredAt, runs the example queries and attempts invalid-date and duplicate-ID inserts.

The document model is suitable for event history because event-specific details can vary while common fields remain validated. Embedded snapshots can reduce read-time lookups, but they introduce duplication and potential staleness. PostgreSQL remains authoritative for current account balances and financial integrity.

The script and previous evidence image are included for reproducibility. The revised source-model changes need to be executed in mongosh and the new output captured before replacing older screenshots or claiming that the corrected version has passed runtime validation.

## Run the script

Connect `mongosh` to a fresh exercise environment and run `Okpala_Ginikachukwu_301922331_P4_MongoDB.js`. The script selects the `portfolio_nosql` database, creates the collection, inserts the sample documents and prints query and validation results.

[Existing implementation screenshot](screenshots/Okpala_Ginikachukwu_301922331_P4_DocumentsAndQueries.png)

## Reference

- [MongoDB — data modelling](https://www.mongodb.com/docs/manual/data-modeling/)
