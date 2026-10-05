import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/pages/subscription/choose_plan_screen.dart';

class PlanDetailsScreen extends StatefulWidget {
  const PlanDetailsScreen({super.key});

  @override
  State<PlanDetailsScreen> createState() => _PlanDetailsScreenState();
}

class _PlanDetailsScreenState extends State<PlanDetailsScreen> {

  int? selectedReason;

  final List<String> reasons = [
    "Lorem Ipsum dummy text",
    "Lorem Ipsum dummy text",
    "Lorem Ipsum dummy text",
    "Others",
  ];

  // ================= CANCEL REASON BOTTOM SHEET =================

  void showCancelReasonSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 10),

                  const Text(
                    "Why do you want to cancel plan?",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    "Please provide the reason for cancellation",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 25),

                  ...List.generate(
                    reasons.length,
                    (index) {
                      return Column(
                        children: [

                          Row(
                            children: [

                              Expanded(
                                child: Text(
                                  reasons[index],
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),

                              Radio<int>(
                                value: index,
                                groupValue: selectedReason,
                                activeColor: const Color(0xff08A045),
                                onChanged: (value) {
                                  setModalState(() {
                                    selectedReason = value;
                                  });
                                },
                              ),
                            ],
                          ),

                          Divider(
                            color: Colors.grey.shade300,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: selectedReason == null
                          ? null
                          : () {
                              Navigator.pop(context);
                              showFinalCancelDialog();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        disabledBackgroundColor: Colors.grey.shade300,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Cancel Plan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ================= FINAL CANCEL DIALOG =================

  void showFinalCancelDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "Cancel Plan ?",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "Are you sure you want to Cancel your subscription plan",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 17,
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  children: [

                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "No",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Plan Cancelled"),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          minimumSize: const Size(0, 52),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Yes",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= SERVICE ITEM =================

  Widget serviceItem({
    required String title,
    required String used,
    required String left,
  }) {
    return Column(
      children: [

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Icon(
              Icons.settings,
              color: Colors.grey,
              size: 18,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [

                      const CircleAvatar(
                        radius: 4,
                        backgroundColor: Colors.red,
                      ),

                      const SizedBox(width: 6),

                      Text("$used Used"),

                      const SizedBox(width: 20),

                      const CircleAvatar(
                        radius: 4,
                        backgroundColor: Colors.green,
                      ),

                      const SizedBox(width: 6),

                      Text("$left Left"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        Divider(
          color: Colors.grey.shade300,
        ),

        const SizedBox(height: 18),
      ],
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F4F3),

      body: Column(
        children: [

          // ================= HEADER =================

          Container(
            height: 115,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: const Color(0xff08A045),

            child: SafeArea(
              child: Row(
                children: [

                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.15),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  const Expanded(
                    child: Center(
                      child: Text(
                        "Plan Details",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 50),
                ],
              ),
            ),
          ),

          // ================= BODY =================

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const Expanded(
                              child: Text(
                                "Repair",
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff3156D3),
                                ),
                              ),
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [

                                const Text(
                                  "Valid till 10 Nov, 2025",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff7CF29A),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    "ACTIVE",
                                    style: TextStyle(
                                      color: Color(0xff008A2E),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: const [

                            Text(
                              "₹ 3499",
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(width: 6),

                            Text(
                              "/6 Months",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Divider(
                          color: Colors.grey.shade300,
                        ),

                        const SizedBox(height: 18),

                        serviceItem(
                          title: "Prevent Package Services",
                          used: "0",
                          left: "0",
                        ),

                        serviceItem(
                          title:
                              "5 AC Services up to 500/- Value\n( Jet servicing + Gas pressure check )",
                          used: "2",
                          left: "3",
                        ),

                        serviceItem(
                          title:
                              "5 Electrical services up to 500/- Value",
                          used: "1",
                          left: "4",
                        ),

                        serviceItem(
                          title:
                              "5 Plumbing Services up to 500/- Value",
                          used: "0",
                          left: "5",
                        ),

                        serviceItem(
                          title:
                              "5 Plumbing Services up to 500/- Value",
                          used: "0",
                          left: "5",
                        ),

                        const SizedBox(height: 10),

                        OutlinedButton(
                          onPressed: showCancelReasonSheet,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(160, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Cancel plan",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ChoosePlanScreen(userData: {},)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffE9BE39),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Upgrade Plan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}