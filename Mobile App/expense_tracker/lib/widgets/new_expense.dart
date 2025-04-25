import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/models/expense.dart';

final formatter = DateFormat('dd/MM/yyyy');

class NewExpense extends StatefulWidget {
  const NewExpense({
    super.key,
    required this.onAddExpense,
    this.existingExpense,
  });
final void Function(Expense expense) onAddExpense;
  final Expense? existingExpense;

  @override
  State<NewExpense> createState() => _NewExpenseState();
}
class _NewExpenseState extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category _selectedCategory = Category.leisure;
@override
  void initState() {
    super.initState();
    // If editing an existing expense, pre-fill the form fields
    if (widget.existingExpense != null) {
      _titleController.text = widget.existingExpense!.title;
      _amountController.text = widget.existingExpense!.amount.toString();
      _selectedDate = widget.existingExpense!.date;
      _selectedCategory = widget.existingExpense!.category;
    }
  }
void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() => _selectedDate = pickedDate);
  }
void _showInvalidInputDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text("Invalid Input"),
          content: const Text("Please make sure all fields are valid."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK"),
            ),
          ],
        ),
      );
} else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Invalid Input"),
          content: const Text("Please make sure all fields are valid."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }
void _submitExpenseData() {
    final enteredAmount = double.tryParse(_amountController.text);
    final isInvalid = _titleController.text.trim().isEmpty ||
        enteredAmount == null ||
        enteredAmount <= 0 ||
        _selectedDate == null;

    if (isInvalid) {
      _showInvalidInputDialog();
      return;
    }
final expense = Expense(
      title: _titleController.text.trim(),
      amount: enteredAmount,
      date: _selectedDate!,
      category: _selectedCategory,
    );

    widget.onAddExpense(expense);
    Navigator.pop(context);
  }
@override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }
@override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + keyboardSpace),
        child: Column(
          children: [
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              maxLength: 50,
              decoration: const InputDecoration(
label: Text("Title"),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    decoration: const InputDecoration(
                      prefixText: "₹ ",
label: Text("Amount"),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _selectedDate == null
                            ? "No Date Selected"
                            : formatter.format(_selectedDate!),
                      ),
IconButton(
                        onPressed: _presentDatePicker,
                        icon: const Icon(Icons.calendar_month),
                      ),
                    ],
                  ),
                ),
              ],
            ),
const SizedBox(height: 16),
				Row(
				  children: [
					DropdownButton<Category>(
					  value: _selectedCategory,
					  items: Category.values
						  .map((cat) => DropdownMenuItem(
								value: cat,
								child: Text(cat.name.toUpperCase()),
							  ))
						  .toList(),
onChanged: (newCat) {
						setState(() => _selectedCategory = newCat!);
					  },
					),
                const Spacer(),
TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CANCEL"),
                ),
ElevatedButton(
                  onPressed: _submitExpenseData,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(widget.existingExpense == null ? "SAVE" : "UPDATE"),
                ),
],
            ),
          ],
        ),
      ),
    );
  }
}