

import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:flutter/material.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ExpensesState();
  }
}

class _ExpensesState extends State<Expenses> {
  final List<Expense> _registeredExpenses = [
    Expense(
        title: 'Flutter Course',
        amount: 500,
        date: DateTime.now(),
        category: Category.work),
    Expense(
        title: 'Dining',
        amount: 300,
        date: DateTime.now(),
        category: Category.food),
    Expense(
        title: 'Movie',
        amount: 200,
        date: DateTime.now(),
        category: Category.leisure),
  ];

  void _openExpenseOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: MediaQuery.of(context).size.width > 600 ? true : false , //for allocating it fullScreen when in landScape
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          // for providing corner radius to the modal.
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) => NewExpense(
        onAddExpense: _addExpense,
      ),
    );
  }

  void _addExpense(Expense expense) {
    setState(() {
      _registeredExpenses.add(expense);
    });
  }

  void _removeExpense(Expense expense) {
    final expenseIndex = _registeredExpenses.indexOf(expense);
    setState(() {
      _registeredExpenses.remove(expense);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text("Expense Deleted"),
        action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                _registeredExpenses.insert(expenseIndex, expense);
              });
            }),
      ),
    );
  }
  void _editExpense(Expense oldExpense, Expense updatedExpense) {
    final index = _registeredExpenses.indexOf(oldExpense);
    if (index == -1) return;

    setState(() {
      _registeredExpenses[index] = updatedExpense;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // final height = MediaQuery.of(context).size.height; (no use)

    final mainContent = _registeredExpenses.isEmpty
        ? const Center(child: Text("No expenses found. Start adding some!"))
        : ExpensesList(
            expenses: _registeredExpenses,
            onRemoveExpense: _removeExpense,
            onEditExpense: (oldExpense) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),),
                builder: (context) => NewExpense(
                  onAddExpense: (updatedExpense) {
                    _editExpense(oldExpense, updatedExpense);
                  },
                  existingExpense: oldExpense,
                ),
              );
            },
          );
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.cyanAccent,
        title: const Text("Get Your Expenses In Track"),
        actions: [
          IconButton(
              onPressed: _openExpenseOverlay, icon: const Icon(Icons.add)),
        ],
      ),
      body: width < 600
          ? Column(
              children: [
                Chart(expenses: _registeredExpenses),
                Expanded(
                  // is you have a list inside a list or column use expanded.
                  child: mainContent,
                )
              ],
            )
          : Row(
              children: [
                Expanded(//the chart widget takes as much width as 
                //possible(check chart.dart) which will cause UI problem 
                //to avoid this use expanded.
                  child: Chart(expenses: _registeredExpenses),
                ),
                Expanded(
                  // is you have a list inside a list or row use expanded.
                  child: mainContent,
                )
              ],
            ),
    );
  }
}
