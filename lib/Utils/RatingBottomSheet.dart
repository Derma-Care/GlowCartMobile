import 'package:flutter/material.dart';

class ProviderRatingBottomSheet extends StatefulWidget {
  final Function(int rating, String feedback) onSubmit;

  const ProviderRatingBottomSheet({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _ProviderRatingBottomSheetState createState() =>
      _ProviderRatingBottomSheetState();
}

class _ProviderRatingBottomSheetState extends State<ProviderRatingBottomSheet> {
  final TextEditingController feedbackController = TextEditingController();
  int selectedRating = 1;
  bool isLoading = false;

  void _submitFeedback() {
    if (isLoading) return;

    final feedback = feedbackController.text;

    setState(() {
      isLoading = true;
    });

    // Simulate a delay for the submission process
    Future.delayed(const Duration(seconds: 2), () {
      widget.onSubmit(selectedRating, feedback);
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context); // Close the bottom sheet
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Provider Rating',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 30.0,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedRating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Provider Feedback (optional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: feedbackController,
                maxLines: 4,
                maxLength: 250,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter Feedback',
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 12.0),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
