import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kermesse_flutter/services/kermesses/kermesses_bloc.dart';
import 'package:kermesse_flutter/services/kermesses/kermesses_state.dart';
import 'package:kermesse_flutter/services/user/user_bloc.dart';

import '../../models/stand.dart';
import '../../models/stock.dart';
import '../../models/user.dart';
import '../../services/kermesses/kermesses_event.dart';
import '../../services/stocks/stocks_bloc.dart';
import '../../services/stocks/stocks_event.dart';
import '../../services/stocks/stocks_state.dart';
import '../../services/user/user_event.dart';
import '../../services/user/user_state.dart';

class StandDetailPage extends StatefulWidget {
  final Stand stand;
  final User currentUser;
  final String token;

  const StandDetailPage({
    Key? key,
    required this.stand,
    required this.currentUser,
    required this.token,
  }) : super(key: key);

  @override
  _StandDetailPageState createState() => _StandDetailPageState();
}

class _StandDetailPageState extends State<StandDetailPage> {
  late Stand _currentStand;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentStand = widget.stand;
    _currentUser = widget.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<StockBloc, StockState>(
          listener: (context, state) {
            if (state is StockCreated || state is StockUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Stock item ${state is StockCreated ? 'created' : 'updated'} successfully')),
              );
              // Fetch updated kermesse details
              context.read<KermessesBloc>().add(
                FetchKermesses(widget.token),
              );
            } else if (state is StockError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Error creating stock item: ${state.message}')),
              );
            }
          },
        ),
        BlocListener<KermessesBloc, KermessesState>(
          listener: (context, state) {
            if (state is KermessesLoaded) {
              // Find the updated stand in the fetched kermesse data
              final updatedKermesse = state.kermesses.firstWhere(
                (kermesse) =>
                    kermesse.stands
                        ?.any((stand) => stand.id == _currentStand.id) ??
                    false,
                orElse: () => throw Exception('Kermesse not found'),
              );
              final updatedStand = updatedKermesse.stands!.firstWhere(
                (stand) => stand.id == _currentStand.id,
                orElse: () => throw Exception('Stand not found'),
              );
              setState(() {
                _currentStand = updatedStand;
              });
            }
          },
        ),
        BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserLoaded) {
              setState(() {
                _currentUser = state.user;
              });
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(_currentStand.name),
          backgroundColor: const Color.fromRGBO(13, 138, 182, 1.0),
          actions: [
            if (_currentUser.role == 'stand_holder' &&
                _currentUser.standId == _currentStand.id)
              IconButton(
                icon: Icon(Icons.add),
                tooltip: 'Add Stock Item',
                onPressed: () => _showCreateStockDialog(context),
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
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
                                    _currentStand.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  _currentStand.type,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _currentStand.description,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Stock:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _currentStand.stock?.length ?? 0,
                itemBuilder: (context, index) {
                  final item = _currentStand.stock?[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(item?.itemName ?? 'Unknown Item'),
                      subtitle: _currentStand.type != "activity"
                          ? Text('Quantity: ${item?.quantity ?? 'N/A'}')
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${item?.tokenCost ?? 'N/A'} tokens'),
                          if (_currentUser.role == 'stand_holder' &&
                              _currentUser.standId == _currentStand.id)
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: item != null ? () => _showUpdateStockDialog(context, item) : null,
                            )
                          else
                            IconButton(
                              icon: Icon(Icons.shopping_cart),
                              onPressed: item != null ? () => _showPurchaseDialog(context, item) : null,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpdateStockDialog(BuildContext context, Stock item) {
    String itemName = item.itemName;
    int quantity = item.quantity;
    int tokenCost = item.tokenCost;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Stock Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Item Name'),
                  onChanged: (value) => itemName = value,
                  controller: TextEditingController(text: itemName),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => quantity = int.tryParse(value) ?? quantity,
                  controller: TextEditingController(text: quantity.toString()),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Token Cost'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => tokenCost = int.tryParse(value) ?? tokenCost,
                  controller: TextEditingController(text: tokenCost.toString()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                if (itemName!.isNotEmpty && quantity! >= 0 && tokenCost! > 0) {
                  BlocProvider.of<StockBloc>(context).add(
                    UpdateStock(
                      token: widget.token,
                      standId: _currentStand.id,
                      stockId: item.id,
                      itemName: itemName,
                      quantity: quantity,
                      tokenCost: tokenCost,
                    ),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields correctly')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showCreateStockDialog(BuildContext context) {
    String itemName = '';
    int quantity = 0;
    int tokenCost = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create New Stock Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Item Name'),
                  onChanged: (value) => itemName = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => quantity = int.tryParse(value) ?? 0,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Token Cost'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => tokenCost = int.tryParse(value) ?? 0,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Create'),
              onPressed: () {
                if (itemName.isNotEmpty && quantity > 0 && tokenCost > 0) {
                  BlocProvider.of<StockBloc>(context).add(
                    CreateStock(
                      token: widget.token,
                      standId: _currentStand.id,
                      itemName: itemName,
                      quantity: quantity,
                      tokenCost: tokenCost,
                    ),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields correctly')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showPurchaseDialog(BuildContext context, Stock item) {
    int quantity = 1;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocListener<StockBloc, StockState>(
          listener: (context, state) {
            if (state is StockPurchased) {
              Navigator.of(context).pop(); // Close the dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              context.read<UserBloc>().add(
                  FetchUser(widget.token)
              );
              context.read<KermessesBloc>().add(
                FetchKermesses(widget.token),
              );
              // Refresh kermesse details to update stock
              context.read<KermessesBloc>().add(
                FetchKermesses(widget.token),
              );
            } else if (state is StockError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Purchase failed: ${state.message}')),
              );
            }
          },
          child: StatefulBuilder(
            builder: (context, setState) {
              bool canDecrease = quantity > 1;
              bool canIncrease = quantity < item.quantity;
              bool canPurchase = quantity > 0 &&
                  _currentUser.tokens != null &&
                  (quantity * item.tokenCost!) <= _currentUser.tokens!;

              return AlertDialog(
                title: Text('Purchase ${item.itemName ?? 'Item'}'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('How many would you like to purchase?'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: canDecrease
                              ? () {
                            setState(() => quantity--);
                          }
                              : null,
                        ),
                        Text('$quantity'),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: canIncrease
                              ? () {
                            setState(() => quantity++);
                          }
                              : null,
                        ),
                      ],
                    ),
                    Text('Total cost: ${quantity * (item.tokenCost ?? 0)} tokens'),
                    if (!canPurchase)
                      const Text(
                        'Not enough tokens',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    child: Text('Purchase'),
                    onPressed: canPurchase
                        ? () {
                      context.read<StockBloc>().add(
                        PurchaseStock(
                          token: widget.token,
                          kermesseId: _currentStand.kermesseId,
                          standId: _currentStand.id,
                          stockId: item.id,
                          quantity: quantity,
                        ),
                      );
                    }
                        : null,
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
