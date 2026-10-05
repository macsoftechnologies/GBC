import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/models/send_feedback_model.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';

class SendFeedbackScreen extends StatefulWidget {
  const SendFeedbackScreen({super.key});

  @override
  State<SendFeedbackScreen> createState() => _SendFeedbackScreenState();
}

class _SendFeedbackScreenState extends State<SendFeedbackScreen> {
  int rating = 0;
  final TextEditingController reviewController = TextEditingController();

  String? userId;
  String? userName;

  GetFeedbackModel? getFeedbackModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      userId = args['user_id'];
      userName = args['user_name'];
    }
  }

  Future<void> sendUserFeedback() async {
    bool internet = await UtilClass.checkInternet();

    if (!internet) {
      UtilClass.showAlertDialog(
          context: context, message: "No Internet Connection");
      return;
    }

    final response = await Repository.postApiService(
      EndPoints.sendfeedbackUser,
      {
        'rating': rating,
        'feedback': reviewController.text.trim(),
        'user_id': userId ?? ""
      },
    );

    Map<String, dynamic> jsonResponse;

    if (response is String) {
      jsonResponse = jsonDecode(response);
    } else {
      jsonResponse = Map<String, dynamic>.from(response);
    }

    getFeedbackModel = GetFeedbackModel.fromJson(jsonResponse);

    if (getFeedbackModel?.status == "valid") {
      UtilClass.showAlertDialog(
        context: context,
        message: getFeedbackModel?.message ?? "Feedback Sent",
      );
    }
  }

  Widget buildStar(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          rating = index;
        });
      },
      child: Icon(
        Icons.star,
        size: 34,
        color: index <= rating ? Colors.orange : Colors.grey.shade300,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xff1FA739),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Feedback",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            /// HELLO TEXT
            Center(
              child: Text(
                "Hello ${userName ?? ''}!",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "Your review will help us to give you a better experience",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              "Rate your experience",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            Row(
              children: List.generate(5, (index) => buildStar(index + 1)),
            ),

            const SizedBox(height: 10),

            Divider(color: Colors.grey.shade300),

            const SizedBox(height: 10),

            const Text(
              "Write a review",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xffE6ECE8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: reviewController,
                minLines: 4,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Write a review",
                ),
              ),
            ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff119B39),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: sendUserFeedback,
                  child: const Text(
                    "Send Feedback",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
    );
  }
}