import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taxi4hire/constants.dart';

class PaymentCollectionDialog extends StatefulWidget {
  final String paymentAmount;
  const PaymentCollectionDialog({Key? key, required this.paymentAmount})
      : super(key: key);

  @override
  State<PaymentCollectionDialog> createState() =>
      _PaymentCollectionDialogState();
}

class _PaymentCollectionDialogState extends State<PaymentCollectionDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      backgroundColor: kSecondaryColor,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 500,
        ),
        curve: Curves.easeOut,
        margin: const EdgeInsets.all(6),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              "Your Earnings Amount",
              style: TextStyle(
                fontSize: 22,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(
              thickness: 2,
              height: 2,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              "\$" + widget.paymentAmount.toString(),
              style: const TextStyle(
                fontSize: 22,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8),
              child: Text(
                "Total payment to be made by passenger, Please collect it from the passenger",
                style: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: ElevatedButton(
                  onPressed: () {
                    Future.delayed(const Duration(milliseconds: 2), () {
                      SystemNavigator.pop();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Collect Cash",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Icon(
                        Icons.attach_money_rounded,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
