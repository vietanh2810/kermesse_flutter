import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kermesse_flutter/services/kermesses/kermesses_bloc.dart';
import 'package:kermesse_flutter/services/kermesses/kermesses_event.dart';

class TokenPurchaseDialog extends StatefulWidget {
  final String token;
  final String kermesseId;

  const TokenPurchaseDialog({
    Key? key,
    required this.token,
    required this.kermesseId,
  }) : super(key: key);

  @override
  _TokenPurchaseDialogState createState() => _TokenPurchaseDialogState();
}

class _TokenPurchaseDialogState extends State<TokenPurchaseDialog> {
  int _tokenAmount = 0;
  bool _isCardComplete = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Purchase Tokens'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Enter the number of tokens to purchase:'),
          TextFormField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _tokenAmount = int.tryParse(value) ?? 0;
              });
            },
          ),
          const SizedBox(height: 20),
          CardField(
            onCardChanged: (card) {
              setState(() {
                _isCardComplete = card!.complete;
              });
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Purchase'),
          onPressed: _tokenAmount > 0 && _isCardComplete
              ? () => _handlePayPress(context)
              : null,
        ),
      ],
    );
  }

  Future<void> _handlePayPress(BuildContext context) async {
    try {
      // Create a payment method
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      // Use the payment method ID as the Stripe token
      final stripeToken = paymentMethod.id;

      // Close the dialog
      Navigator.of(context).pop();

      // Dispatch the PurchaseTokens event
      BlocProvider.of<KermessesBloc>(context).add(
        PurchaseTokens(
          token: widget.token,
          kermesseId: widget.kermesseId,
          amount: _tokenAmount,
          paymentMethodId: paymentMethod.id,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}
