import 'package:flutter/material.dart';
import 'package:taxi4hire/constants.dart';

class PayRequestDialog extends StatefulWidget {
  final String paymentAmount;
  const PayRequestDialog({Key? key, required this.paymentAmount})
      : super(key: key);

  @override
  State<PayRequestDialog> createState() => _PayRequestDialogState();
}

class _PayRequestDialogState extends State<PayRequestDialog> {
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
            const Text(
              "Cost of Ride",
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
                "Payment to be made to the driver, Please pay the taxi driver",
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
                      Navigator.pop(context, "cashPayment");
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
                        "Pay Cash",
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
