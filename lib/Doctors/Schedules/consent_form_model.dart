// consent_form_model.dart
class ConsentForm {
  final String id;
  final String hospitalId;
  final String subServiceId;
  final String subServiceName;
  final String consentFormType;
  final List<ConsentSection> sections;

  ConsentForm({
    required this.id,
    required this.hospitalId,
    required this.subServiceId,
    required this.subServiceName,
    required this.consentFormType,
    required this.sections,
  });

  factory ConsentForm.fromJson(Map<String, dynamic> json) {
    return ConsentForm(
      id: json['id'] ?? '',
      hospitalId: json['hospitalId'] ?? '',
      subServiceId: json['subServiceid'] ?? '',
      subServiceName: json['subServiceName'] ?? '',
      consentFormType: json['consentFormType'] ?? '',
      sections: (json['consentFormQuestions'] as List? ?? [])
          .map((e) => ConsentSection.fromJson(e))
          .toList(),
    );
  }
}

class ConsentSection {
  final String heading;
  final List<ConsentQuestion> questions;

  ConsentSection({required this.heading, required this.questions});

  factory ConsentSection.fromJson(Map<String, dynamic> json) {
    return ConsentSection(
      heading: json['heading'] ?? '',
      questions: (json['questionsAndAnswers'] as List? ?? [])
          .map((e) => ConsentQuestion.fromJson(e))
          .toList(),
    );
  }
}

class ConsentQuestion {
  final String question;
  final bool answer;

  ConsentQuestion({required this.question, required this.answer});

  factory ConsentQuestion.fromJson(Map<String, dynamic> json) {
    return ConsentQuestion(
      question: json['question'] ?? '',
      answer: json['answer'] == true,
    );
  }
}
