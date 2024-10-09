import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/user.dart';
import '../../services/token_transfer/token_transfer_bloc.dart';
import '../../services/token_transfer/token_transfer_event.dart';
import '../../services/token_transfer/token_transfer_state.dart';
import '../../services/transactions/transactions_bloc.dart';
import '../../services/transactions/transactions_event.dart';
import '../../services/transactions/transactions_state.dart';

class ParentProfilePage extends StatelessWidget {
  final User parent;
  final String token;

  const ParentProfilePage({
    Key? key,
    required this.parent,
    required this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Profile'),
        backgroundColor: const Color.fromRGBO(13, 138, 182, 1.0),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ParentInfoCard(parent: parent),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Your Children:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: parent.students?.length ?? 0,
              itemBuilder: (context, index) {
                final student = parent.students![index];
                return StudentCard(
                  student: student,
                  onTap: () => _navigateToStudentTransactions(context, student),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToStudentTransactions(BuildContext context, Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentTransactionsPage(
          student: student,
          token: token,
        ),
      ),
    );
  }
}


class ParentInfoCard extends StatelessWidget {
  final User parent;

  const ParentInfoCard({Key? key, required this.parent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromRGBO(13, 138, 182, 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    parent.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'Tokens: ${parent.tokens}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.email, color: Colors.white),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    parent.email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;

  const StudentCard({super.key, required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color.fromRGBO(52, 183, 222, 0.8),
      child: ListTile(
        title: Text(student.user?.name ?? 'Unknown'),
        subtitle: Text('Tokens: ${student.tokens}'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

class StudentTransactionsPage extends StatelessWidget {
  final Student student;
  final String token;

  const StudentTransactionsPage({
    Key? key,
    required this.student,
    required this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fetch transactions when the page is built
    context.read<TransactionBloc>().add(FetchChildrenTransactions(token));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(52, 183, 222, 0.8),
        title: Text('${student.user?.name}\'s Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showSendTokensModal(context),
          ),
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransactionLoaded) {
            return ListView.builder(
              itemCount: state.transactions.length,
              itemBuilder: (context, index) {
                final transaction = state.transactions[index];
                return ListTile(
                  title: Text('${transaction.type}: ${transaction.amount} tokens to ${transaction.toType} #${transaction.toID}' ),
                  subtitle: Text('Date: ${transaction.createdAt}'),
                );
              },
            );
          } else if (state is TransactionError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('No transactions available'));
        },
      ),
    );
  }

  void _showSendTokensModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        // return SendTokensModal(student: student);
        return SendTokensModal(student: student, token: token);
      },
    );
  }
}
class SendTokensModal extends StatefulWidget {
  final Student student;
  final String token;

  SendTokensModal({Key? key, required this.student, required this.token}) : super(key: key);

  @override
  _SendTokensModalState createState() => _SendTokensModalState();
}

class _SendTokensModalState extends State<SendTokensModal> {
  final _formKey = GlobalKey<FormState>();
  int _amount = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TokenTransferBloc(),
      child: BlocConsumer<TokenTransferBloc, TokenTransferState>(
        listener: (context, state) {
          if (state is TokenTransferSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tokens sent successfully!')),
            );
            Navigator.pop(context);
          } else if (state is TokenTransferFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to send tokens: ${state.error}')),
            );
          }
        },
        builder: (context, state) {
          return Container(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Send Tokens to ${widget.student.user?.name}',
                      style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Amount of Tokens'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _amount = int.parse(value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    child: state is TokenTransferLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Send Tokens'),
                    onPressed: state is TokenTransferLoading
                        ? null
                        : () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        context.read<TokenTransferBloc>().add(
                          SendTokensToChild(
                            studentId: widget.student.userId,
                            amount: _amount,
                            token: widget.token,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}