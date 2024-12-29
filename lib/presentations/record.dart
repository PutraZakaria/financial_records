import 'package:financial_records/database/database.dart';
import 'package:financial_records/database/fc_db.dart';
import 'package:financial_records/presentations/recordDetails.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:gap/gap.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  DatabaseService _databaseService = DatabaseService();
  late Database _database;
  final FRDB _frdb = FRDB();
  List<Map<String, dynamic>> _records = [];
  double _currentBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  // Initialize the database and fetch records
  Future<void> _initializeDatabase() async {
    _database = await _databaseService.database;
    _fetchRecords();
  }

  // Fetch records from the database
  Future<void> _fetchRecords() async {
    final records = await _frdb.getRecords(_database);
    setState(() {
      _records = records;
      _updateCurrentBalance();
    });
  }

  // Calculate the current balance based on income and outcome
  void _updateCurrentBalance() {
    double balance = 0.0;
    for (var record in _records) {
      if (record['isIncome'] == 1) {
        balance += record['amount'];
      } else {
        balance -= record['amount'];
      }
    }
    _currentBalance = balance;
  }

  // Delete a record by its ID
  void _deleteRecord(int id) async {
    await _frdb.deleteRecord(_database, id);
    _fetchRecords();
  }

  // Handle saving a record (create or update)
  void _handleSaveRecord(Map<String, dynamic> record) async {
    if (record['id'] == null) {
      // Create new record
      await _frdb.createRecord(
        _database,
        record['amount'],
        record['isIncome'],
        record['date'],
      );
    } else {
      // Update existing record
      await _frdb.updateRecord(
        _database,
        record['id'],
        record['amount'],
        record['isIncome'],
        record['date'],
      );
    }
    _fetchRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Financial Records App💸',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Popins',
                color: Colors.grey,
                fontSize: 20.0),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    // Current Balance
                    Gap(20),
                    Center(
                      child: Text(
                        'Current Balance\n \$${_currentBalance.toStringAsFixed(2)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Popins',
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    Gap(30),

                    // Financial Records Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Financial Records',
                            style: TextStyle(
                              fontFamily: 'Popins',
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 20,
                            )),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RecordDetails(onSave: _handleSaveRecord),
                              ),
                            );
                          },
                          child: const Text('Add Record',
                              style: TextStyle(
                                fontFamily: 'Popins',
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 20,
                              )),
                        ),
                      ],
                    ),

                    // Records
                    Gap(20),
                    _records.isEmpty
                        ? const Center(child: Text('No records found.'))
                        : ListView.builder(
                            shrinkWrap: true, // Ensures it doesn't take infinite space
                            itemCount: _records.length,
                            itemBuilder: (context, index) {
                              final record = _records[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 5.0),
                                child: ListTile(
                                  leading: Icon(
                                    record['isIncome'] == 1
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    color: record['isIncome'] == 1
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  title: Text(
                                    '\$${record['amount'].toString()}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text('Date: ${record['date']}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Edit Button
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RecordDetails(
                                                onSave: _handleSaveRecord,
                                                initialRecord: record,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      // Delete Button
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title:
                                                  const Text('Confirm Delete'),
                                              content: const Text(
                                                  'Are you sure you want to delete this record?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    _deleteRecord(record['id']);
                                                  },
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
