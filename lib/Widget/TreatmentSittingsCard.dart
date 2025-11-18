import 'package:cutomer_app/BottomNavigation/Appoinments/GetAppointmentModel.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SittingDetailsCard extends StatelessWidget {
  final Map<String, TreatmentData>? treatments;

  const SittingDetailsCard({
    super.key,
    this.treatments,
  });

  @override
  Widget build(BuildContext context) {
    if (treatments == null || treatments!.isEmpty) {
      return const Center(child: Text("No treatment data available"));
    }

    // Step 1: Show list of treatments first
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Treatments",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...treatments!.entries.map((entry) {
          final name = entry.key;
          final data = entry.value;

          return ListTile(
            leading: const Icon(Icons.healing, color: Colors.teal),
            title:
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              "Total: ${data.totalSittings ?? '-'} | Taken: ${data.takenSittings ?? '-'}",
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            onTap: () => _showTreatmentDetails(context, name, data),
          );
        }),
      ],
    );
  }

  void _showTreatmentDetails(
      BuildContext context, String name, TreatmentData data) {
    final total = data.totalSittings ?? 0;
    final taken = data.takenSittings ?? 0;
    final current = data.currentSitting ?? 0;
    final pending = data.pendingSittings ?? 0;
    double progress = total > 0 ? taken / total : 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // 🔹 Progress and Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _sideStat("Taken", taken.toString(), Colors.green),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 100,
                          width: 100,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey.shade300,
                            color: progress == 1
                                ? Colors.green
                                : Colors.orangeAccent,
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              "${(progress * 100).toInt()}%",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const Text("Completed",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                      ],
                    ),
                    _sideStat("Pending", pending.toString(), Colors.redAccent),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔹 Total / Current / Calendar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _miniInfo("Total", "$total"),
                    _miniInfo("Current", "$current"),
                    IconButton(
                      icon:
                          const Icon(Icons.calendar_month, color: Colors.blue),
                      onPressed: () => _showDateList(context, data),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔹 Step Progress (Horizontal Scroll)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(total, (index) {
                      bool isCompleted = index < taken;
                      bool isCurrent = index + 1 == current;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Column(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted
                                    ? Colors.green
                                    : isCurrent
                                        ? Colors.orange
                                        : Colors.grey.shade300,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "${index + 1}",
                                style: TextStyle(
                                  color: (isCompleted || isCurrent)
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isCompleted
                                  ? "Done"
                                  : isCurrent
                                      ? "Now"
                                      : "Next",
                              style: TextStyle(
                                fontSize: 11,
                                color: isCompleted
                                    ? Colors.green
                                    : isCurrent
                                        ? Colors.orange
                                        : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDateList(BuildContext context, TreatmentData data) {
    if (data.dates == null || data.dates!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No sitting dates available")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const Text("Sitting Dates",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              ...data.dates!.map((d) {
                return ListTile(
                  leading: Icon(
                    d.status == "Completed"
                        ? Icons.check_circle
                        : Icons.pending_actions,
                    color:
                        d.status == "Completed" ? Colors.green : Colors.orange,
                  ),
                  title: Text("Sitting ${d.sitting ?? '-'}"),
                  subtitle: Text(
                    d.date != null
                        ? DateFormat('dd MMM yyyy')
                            .format(DateTime.parse(d.date!))
                        : 'No date',
                  ),
                  trailing: Text(
                    d.status ?? '',
                    style: TextStyle(
                      color: d.status == "Completed"
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _sideStat(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(title,
            style: const TextStyle(fontSize: 13, color: Colors.black54)),
      ],
    );
  }

  Widget _miniInfo(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text("$title: ",
              style: const TextStyle(color: Colors.white, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
