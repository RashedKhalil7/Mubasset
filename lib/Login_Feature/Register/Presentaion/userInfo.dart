import 'package:flutter/material.dart';

import '../data/SignData.dart';
import 'PassScreen.dart';

class UserInfoScreen extends StatefulWidget {
  final SignUpData data;
  const UserInfoScreen({super.key, required this.data});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _nameController = TextEditingController();
  double progress=2/6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  resizeToAvoidBottomInset: false,
      appBar: AppBar(
          centerTitle: true,
          title: SizedBox(
          width: 150,
          child: LinearProgressIndicator(
            minHeight: 4,
            borderRadius: BorderRadius.circular(20),
            value: progress,backgroundColor: Colors.grey.shade300,color:  Color.fromARGB(255, 18, 162, 119),))),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Please enter your personal information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Text("Full name",style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: "",
                hintText: "Enter Your full name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color.fromARGB(255, 18, 162, 119)),
                ),

              ),
              onChanged: (v) {
                setState(() {
                widget.data.fullName = v;
              });},
            ),

            const SizedBox(height: 25),

            Text("Date of  Birth",style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),),

            const SizedBox(height: 12),

            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => widget.data.dateOfBirth = date);
                }
              },
              child: InputDecorator(
                decoration:  InputDecoration(
                  labelText: "",
                  hintText: "DD MM YY",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color.fromARGB(255, 18, 162, 119)),
                  ),
                  suffixIcon: Icon(Icons.date_range),
                ),
                child: Text(
                  widget.data.dateOfBirth == null
                      ? 'Select date'
                      : widget.data.dateOfBirth!.toLocal().toString().split(' ')[0],
                ),
              ),
            ),

            const Spacer(),

            Row(
              children: [
                Checkbox(
                  value: widget.data.acceptedTerms,
                  onChanged: (v) =>
                      setState(() => widget.data.acceptedTerms = v ?? false),
                ),
              //  const Icon(Icons.check_circle_outline, size: 20),
                const SizedBox(width: 8),
                Wrap(
                  children: const [
                    Text('I have read and accept '),
                    Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children:[
                Checkbox(
                value: widget.data.acceptedOffers,
                onChanged: (v) =>
                    setState(() => widget.data.acceptedOffers = v ?? false),
              ),
                const SizedBox(width: 8),
                Text('I want to receive offers and updates '),

        ]
            ),


            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.data.acceptedTerms
                       ?  Color.fromARGB(255, 18, 162, 119): Colors.grey,
                ),
                onPressed: widget.data.acceptedTerms && _nameController.text.isNotEmpty
                    ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PasswordScreen(data: widget.data),
                  ),
                )
                    : null,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}