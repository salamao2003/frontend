import 'package:flutter/material.dart';

class QuickQuestion {
final String question;
final String answer;

QuickQuestion(this.question, this.answer);
}

class ChatBotLogic {

static final List<QuickQuestion> quickQuestions = [
QuickQuestion(
'What are the operating hours?',
'The metro operates daily from 5:00 AM to 12:30 AM. Hours may be extended on special occasions.',
),
QuickQuestion(
'Does the metro run on public holidays?',
'Yes, the metro operates every day, including public holidays.',
),
QuickQuestion(
'What are the ticket prices?',
'Ticket prices depend on the number of stations:\n- Up to 9 stations: 8 EGP\n- up to 16 stations: 10 EGP\n- up to 23 stations: 15 EGP',
),
QuickQuestion(
'Where can I buy a metro ticket?',
'You can buy tickets from the ticket office at the station or use the ticket vending machines (TVMs).',
),
QuickQuestion(
'Are there metro subscriptions?',
'Yes, there are monthly, quarterly, semi-annual, and annual subscriptions with discounts for students, seniors, and people with disabilities. But in our app we provide only monthly subscription!!',
),
QuickQuestion(
'How can I renew my subscription?',
'You can renew your subscription at designated subscription offices in major metro stations.',
),
QuickQuestion(
'How to find the nearest metro station?',
'Use the "Nearby Station" feature in the app to find the closest station to your location.',
),
QuickQuestion(
'What are the metro lines?',
'The metro consists of three main lines:\n- Line 1 (Red): El Marg El Gedida – Helwan\n- Line 2 (Blue): Shubra El Kheima – El Monib\n- Line 3 (Green): Adly Mansour – Kit Kat',
),
QuickQuestion(
'How to transfer between metro lines?',
'You can switch lines at these interchange stations:\n- Sadat (Line 1 & Line 2)\n- Shohadaa (Line 1 & Line 2)\n- Attaba (Line 2 & Line 3)\n- Gamal Abdel Nasser (Line 1 & Line 3)',
),
QuickQuestion(
'What to do if I lose something?',
'Visit the lost and found office at major stations or contact customer service on: 16048.',
),
QuickQuestion(
'Is there Wi-Fi in metro stations?',
'Some stations provide Wi-Fi service, and efforts are being made to expand this service.',
),
QuickQuestion(
'Can I bring my bicycle on the metro?',
'Bicycles are allowed in some cases, following the size and placement regulations inside the train.',
),
QuickQuestion(
'What to do in case of an emergency?',
'Use the emergency button inside the train or notify the nearest station staff member.',
),
QuickQuestion(
'Are there women-only carriages?',
'Yes, there are designated women-only carriages during peak hours, usually in the first and second cars.',
),
QuickQuestion(
'Can I pay for tickets using the app?',
'Yes, you can use digital payment through the app to buy tickets or recharge your metro wallet.',
),
QuickQuestion(
'How to top up my metro wallet?',
'You can recharge your balance using bank cards or at metro service counters.',
),
QuickQuestion(
'Can I get a refund for unused balance?',
'Yes, refunds are available according to the metro authority’s refund policy.',
),
QuickQuestion('How to report a problem?',
'You can report any issues or complaints through customer service in our stations or call us: 16048'
),
];


static String getWelcomeMessage() {
return 'Welcome to Metro Assistant! How can I help you today?';
}

static bool isQuestionAnswered(String question) {
return quickQuestions.any((q) => q.question == question);
}

static String getAnswer(String question) {
final questionObj = quickQuestions.firstWhere(
(q) => q.question == question,
orElse: () => QuickQuestion('', 'Sorry, I cannot find an answer to this question.'),
);
return questionObj.answer;
}
}