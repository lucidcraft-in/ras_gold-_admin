import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class WhatsAppService {
  static Future<void> sendTransactionAlert({
    required String phone,
    required String customerName,
    required String transactionType,
    required double amount,
    required double balance,
    required DateTime date,
  }) async {
    // Format phone number (ensure it has country code, default to 91 if not present)
    String formattedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (formattedPhone.length == 10) {
      formattedPhone = '91$formattedPhone';
    }

    final String dateStr = DateFormat('dd-MM-yyyy hh:mm a').format(date);
    
    final String message = 
        "*RAS GOLD TRANSACTION ALERT*\n\n"
        "Dear *$customerName*,\n"
        "Your transaction has been successfully processed.\n\n"
        "📅 *Date:* $dateStr\n"
        "📝 *Type:* $transactionType\n"
        "💰 *Amount:* ₹${amount.toStringAsFixed(2)}\n"
        "📊 *New Balance:* ₹${balance.toStringAsFixed(2)}\n\n"
        "Thank you for choosing RAS Gold!";

    final String url = "whatsapp://send?phone=$formattedPhone&text=${Uri.encodeComponent(message)}";
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback to web link if whatsapp scheme fails
      final String webUrl = "https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}";
      final Uri webUri = Uri.parse(webUrl);
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        print("Could not launch WhatsApp");
      }
    }
  }
}
