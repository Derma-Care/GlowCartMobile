// import 'package:get/get.dart';

// import '../Doctors/ListOfDoctors/DoctorModel.dart';

// class CommentController extends GetxController {
//   RxInt replyingIndex = (-1).obs; // -1 means no active reply
//   RxList<RatingComment> comments = <RatingComment>[].obs;

//   void toggleReplyField(int index) {
//     replyingIndex.value = replyingIndex.value == index ? -1 : index;
//     print("IndexINdex ${index}");
//   }

//   void sendReply(int index, Reply reply) {
//     print("repliesreplies ${index}");
//     print("repliesreplies ${reply.reply}");

//     if (index < 0 || index >= comments.length) {
//       print("❌ Invalid comment index: $index");
//       return;
//     }

//     comments[index].replies.add(reply);
//     comments.refresh();
//   }
// }

import 'dart:convert';

import 'package:get/get.dart';

import '../APIs/BaseUrl.dart';
import '../Doctors/ListOfDoctors/DoctorModel.dart';
import 'package:http/http.dart' as http;

class CommentController extends GetxController {
  RxInt replyingIndex = (-1).obs; // -1 means no active reply
  RxList<RatingComment> comments = <RatingComment>[].obs;

  void toggleReplyField(int index) {
    replyingIndex.value = replyingIndex.value == index ? -1 : index;
    print("IndexINdex ${index}");
  }

  void sendReply(int index, Reply reply) async {
    print("📝 Reply Index: $index");
    print("📝 Reply Text: ${reply.reply}");

    if (index < 0 || index >= comments.length) {
      print("❌ Invalid comment index: $index");
      return;
    }

    // Get the comment to update
    var comment = comments[index];

    // Optional: Update local UI first (optimistic update)
    comment.replies.add(reply);
    comments.refresh();

    try {
      final response = await http.post(
        Uri.parse(
            "http://$wifiUrl:3000/comments/${comment.userId}/reply"), // 👈 Use your actual backend API
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reply.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Reply posted to backend successfully.");
      } else {
        print("❌ Failed to post reply: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error sending reply: $e");
    }
  }
}

