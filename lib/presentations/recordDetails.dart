import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class RecordDetails extends StatefulWidget {
  final Function(Map<String, dynamic> record) onSave;
  final Map<String, dynamic>? initialRecord; // Record untuk update

  const RecordDetails({super.key, required this.onSave, this.initialRecord});

  @override
  State<RecordDetails> createState() => _RecordDetailsState();
}

class _RecordDetailsState extends State<RecordDetails> {
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  int? _isIncome;

  @override
  void initState() {
    super.initState();

    // If initialRecord is not null, populate with the initial data
    _amountController = TextEditingController(
      text: widget.initialRecord?['amount']?.toString() ?? '',
    );
    _dateController = TextEditingController(
      text: widget.initialRecord?['date'] ?? '',
    );
    _isIncome = widget.initialRecord?['isIncome'] ?? 1; // Default to 1 (Income)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.grey,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.initialRecord == null ? 'Add Record' : 'Update Record',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Popins',
                color: Colors.grey,
                fontSize: 20.0,
              ),
            ),
            TextButton(
              onPressed: _saveRecord,
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.blue, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Amount
              const Text(
                'Amount (USD)',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Popins',
                  fontSize: 15.0,
                ),
              ),
              Gap(10),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),

              Gap(20),

              // Income/Outcome
              const Text(
                'Income/Outcome',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Popins',
                  fontSize: 15.0,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<int>(
                      title: const Text('Income'),
                      value: 1, // 1 for Income
                      groupValue: _isIncome,
                      onChanged: (int? value) {
                        setState(() {
                          _isIncome = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<int>(
                      title: const Text('Outcome'),
                      value: 0, // 0 for Outcome
                      groupValue: _isIncome,
                      onChanged: (int? value) {
                        setState(() {
                          _isIncome = value;
                        });
                      },
                    ),
                  ),
                ],
              ),

              Gap(20),

              // Date
              const Text(
                'Date',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Popins',
                  fontSize: 15.0,
                ),
              ),
              Gap(10),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                readOnly: true,
                onTap: _selectDate,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (_picked != null) {
      setState(() {
        _dateController.text = _picked.toString().split(' ')[0];
      });
    }
  }

  void _saveRecord() {
    // Validate input
    final amount = double.tryParse(_amountController.text);
    if (amount == null || _isIncome == null || _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    // Pass data to the callback function
    widget.onSave({
      'id': widget.initialRecord?['id'], // ID if updating an existing record
      'amount': amount,
      'isIncome': _isIncome,
      'date': _dateController.text,
    });

    Navigator.of(context).pop();
  }
}
