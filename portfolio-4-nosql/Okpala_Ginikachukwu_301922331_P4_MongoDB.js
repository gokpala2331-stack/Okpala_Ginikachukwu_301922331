// Run once in mongosh against a fresh exercise database.
// These records are fictional events for the case study.
(async function () {
  db = db.getSiblingDB('portfolio_nosql');
  if ((await db.getCollectionNames()).includes("ledger_events")) {
    throw new Error('The exercise collection already exists. Use a fresh database.');
  }

  // The validator checks the stable event fields while details can vary.
  await db.createCollection("ledger_events", {
    validator: {
    "$jsonSchema": {
        "bsonType": "object",
        "required": [
            "_id",
            "schemaVersion",
            "simulation",
            "eventType",
            "occurredAt",
            "source",
            "embedded",
            "references",
            "details"
        ],
        "properties": {
            "_id": {
                "bsonType": "string",
                "minLength": 1
            },
            "schemaVersion": {
                "enum": [
                    1
                ]
            },
            "simulation": {
                "enum": [
                    true
                ]
            },
            "eventType": {
                "bsonType": "string",
                "enum": [
                    "account_opened",
                    "ledger_entry_recorded"
                ]
            },
            "occurredAt": {
                "bsonType": "date"
            },
            "source": {
                "bsonType": "object",
                "required": [
                    "entity",
                    "key",
                    "snapshot"
                ],
                "properties": {
                    "entity": {
                        "enum": [
                            "ledger_entry"
                        ]
                    },
                    "key": {
                        "bsonType": "object",
                        "required": [
                            "entry_id"
                        ]
                    },
                    "snapshot": {
                        "bsonType": "object"
                    }
                }
            },
            "embedded": {
                "bsonType": "object"
            },
            "references": {
                "bsonType": "object"
            },
            "details": {
                "bsonType": "object"
            }
        }
    }
},
    validationLevel: 'strict', validationAction: 'error'
  });

  // Insert the four example events and show their IDs.
  printjson(await db.getCollection("ledger_events").insertMany([
    {
        "_id": "event_000001",
        "schemaVersion": 1,
        "simulation": true,
        "eventType": "account_opened",
        "occurredAt": ISODate("2030-01-01T10:00:00Z"),
        "source": {
            "entity": "account",
            "key": { "account_id": 4 },
            "snapshot": {
                "account_id": 4,
                "customer_id": 1,
                "account_number": "ACCT-1001",
                "opened_on": "2025-01-12",
                "balance": 120.5,
                "status": "active",
                "is_primary": true
            }
        },
        "embedded": {
            "account": [
                {
                    "key": {
                        "account_id": 4
                    },
                    "snapshot": {
                        "account_id": 4,
                        "customer_id": 1,
                        "account_number": "ACCT-1001",
                        "opened_on": "2025-01-12",
                        "balance": 120.5,
                        "status": "active",
                        "is_primary": true
                    },
                    "via": [
                        "ledger_entry.account_id → account"
                    ]
                }
            ],
            "customer": [
                {
                    "key": {
                        "customer_id": 1
                    },
                    "snapshot": {
                        "customer_id": 1,
                        "full_name": "Avery Chen",
                        "email": "avery.chen@example.test",
                        "created_on": "2025-01-10"
                    },
                    "via": [
                        "ledger_entry.account_id → account.customer_id → customer"
                    ]
                }
            ]
        },
        "references": {},
        "details": {
            "channel": "web"
        }
    },
    {
        "_id": "event_000002",
        "schemaVersion": 1,
        "simulation": true,
        "eventType": "ledger_entry_recorded",
        "occurredAt": ISODate("2030-01-01T10:01:00Z"),
        "source": {
            "entity": "ledger_entry",
            "key": {
                "entry_id": 6
            },
            "snapshot": {
                "entry_id": 6,
                "account_id": 4,
                "amount": 20.5,
                "entry_type": "credit",
                "occurred_at": "2025-01-13T10:15:00Z",
                "reference": "REF-1001"
            }
        },
        "embedded": {
            "account": [
                {
                    "key": {
                        "account_id": 4
                    },
                    "snapshot": {
                        "account_id": 4,
                        "customer_id": 1,
                        "account_number": "ACCT-1001",
                        "opened_on": "2025-01-12",
                        "balance": 120.5,
                        "status": "active",
                        "is_primary": true
                    },
                    "via": [
                        "ledger_entry.account_id → account"
                    ]
                }
            ],
            "customer": [
                {
                    "key": {
                        "customer_id": 1
                    },
                    "snapshot": {
                        "customer_id": 1,
                        "full_name": "Avery Chen",
                        "email": "avery.chen@example.test",
                        "created_on": "2025-01-10"
                    },
                    "via": [
                        "ledger_entry.account_id → account.customer_id → customer"
                    ]
                }
            ]
        },
        "references": {},
        "details": {
            "channel": "mobile",
            "note": "Illustrative event-specific metadata",
            "examples": {
                "channel": "illustrative channel",
                "client_reference": "illustrative client_reference",
                "device_id": "illustrative device_id"
            }
        }
    },
    {
        "_id": "event_000003",
        "schemaVersion": 1,
        "simulation": true,
        "eventType": "account_opened",
        "occurredAt": ISODate("2030-01-01T10:02:00Z"),
        "source": {
            "entity": "account",
            "key": { "account_id": 5 },
            "snapshot": {
                "account_id": 5,
                "customer_id": 2,
                "account_number": "ACCT-1002",
                "opened_on": "2025-02-16",
                "balance": 80,
                "status": "active",
                "is_primary": true
            }
        },
        "embedded": {
            "account": [
                {
                    "key": {
                        "account_id": 5
                    },
                    "snapshot": {
                        "account_id": 5,
                        "customer_id": 2,
                        "account_number": "ACCT-1002",
                        "opened_on": "2025-02-16",
                        "balance": 80,
                        "status": "active",
                        "is_primary": true
                    },
                    "via": [
                        "ledger_entry.account_id → account"
                    ]
                }
            ],
            "customer": [
                {
                    "key": {
                        "customer_id": 2
                    },
                    "snapshot": {
                        "customer_id": 2,
                        "full_name": "Morgan Patel",
                        "email": "morgan.patel@example.test",
                        "created_on": "2025-02-14"
                    },
                    "via": [
                        "ledger_entry.account_id → account.customer_id → customer"
                    ]
                }
            ]
        },
        "references": {},
        "details": {
            "channel": "web"
        }
    },
    {
        "_id": "event_000004",
        "schemaVersion": 1,
        "simulation": true,
        "eventType": "ledger_entry_recorded",
        "occurredAt": ISODate("2030-01-01T10:03:00Z"),
        "source": {
            "entity": "ledger_entry",
            "key": {
                "entry_id": 7
            },
            "snapshot": {
                "entry_id": 7,
                "account_id": 5,
                "amount": 10,
                "entry_type": "debit",
                "occurred_at": "2025-02-17T14:30:00+00:00",
                "reference": null
            }
        },
        "embedded": {
            "account": [
                {
                    "key": {
                        "account_id": 5
                    },
                    "snapshot": {
                        "account_id": 5,
                        "customer_id": 2,
                        "account_number": "ACCT-1002",
                        "opened_on": "2025-02-16",
                        "balance": 80,
                        "status": "active",
                        "is_primary": true
                    },
                    "via": [
                        "ledger_entry.account_id → account"
                    ]
                }
            ],
            "customer": [
                {
                    "key": {
                        "customer_id": 2
                    },
                    "snapshot": {
                        "customer_id": 2,
                        "full_name": "Morgan Patel",
                        "email": "morgan.patel@example.test",
                        "created_on": "2025-02-14"
                    },
                    "via": [
                        "ledger_entry.account_id → account.customer_id → customer"
                    ]
                }
            ]
        },
        "references": {},
        "details": {
            "channel": "mobile",
            "note": "Illustrative event-specific metadata",
            "examples": {
                "channel": "illustrative channel",
                "client_reference": "illustrative client_reference",
                "device_id": "illustrative device_id"
            }
        }
    }
]));
  await db.getCollection("ledger_events").createIndex({eventType: 1, occurredAt: -1}, {name: 'event_type_time'});

  // 1. Find the first sample event type (up to five documents).
  printjson(await db.getCollection("ledger_events").find({"eventType":"account_opened"}).sort({_id:1}).limit(5).toArray());

  // 2. Find events for the first source record using nested key fields (up to five).
  printjson(await db.getCollection("ledger_events").find({"source.key.entry_id":6}).sort({_id:1}).limit(5).toArray());

  // 3. Find events in the sample time range using a MongoDB Date filter (up to five).
  printjson(await db.getCollection("ledger_events").find({"occurredAt":{"$gte":ISODate("2030-01-01T10:00:00Z"), "$lt":ISODate("2030-01-01T11:00:00Z")}}).sort({_id:1}).limit(5).toArray());

  // 4. Count documents for each event type.
  printjson(await db.getCollection("ledger_events").aggregate([{"$group":{"_id":"$eventType", "documentCount":{"$sum":1}}}, {"$sort":{"_id":1}}]).toArray());

  // A date stored as text should be rejected by the validator.
  try {
    await db.getCollection("ledger_events").insertOne({...{
    "_id": "event_000001",
    "schemaVersion": 1,
    "simulation": true,
    "eventType": "account_opened",
    "occurredAt": ISODate("2030-01-01T10:00:00Z"),
    "source": {
        "entity": "ledger_entry",
        "key": {
            "entry_id": 6
        },
        "snapshot": {
            "entry_id": 6,
            "account_id": 4,
            "amount": 20.5,
            "entry_type": "credit",
            "occurred_at": "2025-01-13T10:15:00Z",
            "reference": "REF-1001"
        }
    },
    "embedded": {
        "account": [
            {
                "key": {
                    "account_id": 4
                },
                "snapshot": {
                    "account_id": 4,
                    "customer_id": 1,
                    "account_number": "ACCT-1001",
                    "opened_on": "2025-01-12",
                    "balance": 120.5,
                    "status": "active",
                    "is_primary": true
                },
                "via": [
                    "ledger_entry.account_id → account"
                ]
            }
        ],
        "customer": [
            {
                "key": {
                    "customer_id": 1
                },
                "snapshot": {
                    "customer_id": 1,
                    "full_name": "Avery Chen",
                    "email": "avery.chen@example.test",
                    "created_on": "2025-01-10"
                },
                "via": [
                    "ledger_entry.account_id → account.customer_id → customer"
                ]
            }
        ]
    },
    "references": {},
    "details": {
        "channel": "web"
    }
}, _id: 'invalid_date_example', occurredAt: 'not-a-date'});
  } catch (error) { print('Invalid date error: ' + error.code); }

  // Reusing an event ID should be rejected by the unique _id index.
  try { await db.getCollection("ledger_events").insertOne({
    "_id": "event_000001",
    "schemaVersion": 1,
    "simulation": true,
    "eventType": "account_opened",
    "occurredAt": ISODate("2030-01-01T10:00:00Z"),
    "source": {
        "entity": "ledger_entry",
        "key": {
            "entry_id": 6
        },
        "snapshot": {
            "entry_id": 6,
            "account_id": 4,
            "amount": 20.5,
            "entry_type": "credit",
            "occurred_at": "2025-01-13T10:15:00Z",
            "reference": "REF-1001"
        }
    },
    "embedded": {
        "account": [
            {
                "key": {
                    "account_id": 4
                },
                "snapshot": {
                    "account_id": 4,
                    "customer_id": 1,
                    "account_number": "ACCT-1001",
                    "opened_on": "2025-01-12",
                    "balance": 120.5,
                    "status": "active",
                    "is_primary": true
                },
                "via": [
                    "ledger_entry.account_id → account"
                ]
            }
        ],
        "customer": [
            {
                "key": {
                    "customer_id": 1
                },
                "snapshot": {
                    "customer_id": 1,
                    "full_name": "Avery Chen",
                    "email": "avery.chen@example.test",
                    "created_on": "2025-01-10"
                },
                "via": [
                    "ledger_entry.account_id → account.customer_id → customer"
                ]
            }
        ]
    },
    "references": {},
    "details": {
        "channel": "web"
    }
}); }
  catch (error) { print('Duplicate ID error: ' + error.code); }

  print('Document count: ' + await db.getCollection("ledger_events").countDocuments());
})().catch(error => { print(error.stack || String(error)); quit(1); });
