import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/app_constants.dart';
import '../../components/app_snackbar.dart';

class DonateBottomSheet extends StatelessWidget {
  const DonateBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DonateBottomSheet(),
    );
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    // Root overlay: a ScaffoldMessenger snackbar would sit under this sheet.
    AppSnackbar.show('$label copied to clipboard');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade800.withValues(alpha: 0.3),
                            colorScheme.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.favorite_rounded,
                              color: Colors.amber.shade400,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            AppConstants.donateTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppConstants.donateMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colorScheme.onSecondary,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // YouTube Support
                    _buildSectionLabel(context, 'Support on YouTube'),
                    const SizedBox(height: 8),
                    _buildActionCard(
                      context,
                      icon: Icons.play_circle_filled_rounded,
                      iconColor: Colors.red,
                      title: AppConstants.donateButton,
                      subtitle: 'Join as a channel member',
                      onTap: () async {
                        final uri = Uri.parse(AppConstants.avventoJoinYtUrl);
                        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                          throw 'Could not launch ${AppConstants.avventoJoinYtUrl}';
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Mobile Money
                    _buildSectionLabel(context, 'Mobile Money'),
                    const SizedBox(height: 8),
                    _buildDonationCard(
                      context,
                      icon: CupertinoIcons.device_phone_portrait,
                      iconColor: Colors.redAccent,
                      title: 'Airtel Money',
                      label: 'Merchant Code',
                      value: '4397850',
                    ),
                    const SizedBox(height: 10),
                    _buildDonationCard(
                      context,
                      icon: CupertinoIcons.device_phone_portrait,
                      iconColor: Colors.amber.shade600,
                      title: 'MTN MoMo Pay',
                      label: 'Merchant Code',
                      value: '838983',
                    ),
                    const SizedBox(height: 24),

                    // Bank Transfer
                    _buildSectionLabel(context, 'Bank Transfer'),
                    const SizedBox(height: 8),
                    _buildBankCard(context),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionLabel(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.secondary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: colorScheme.onSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: colorScheme.onSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$label: ',
                      style: TextStyle(
                        color: colorScheme.onSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        color: Colors.amber.shade400,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _copyToClipboard(context, value, '$title $label'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                CupertinoIcons.doc_on_clipboard,
                color: Colors.amber.shade400,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: Colors.blueAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stanbic Bank Uganda',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'AvventoMedia',
                      style: TextStyle(
                        color: colorScheme.onSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBankDetailRow(
            context,
            label: 'Account Number',
            value: '9030024407402',
          ),
          const SizedBox(height: 10),
          _buildBankDetailRow(
            context,
            label: 'Swift Code',
            value: 'SBICUGKX',
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetailRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: Colors.amber.shade400,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => _copyToClipboard(context, value, label),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                CupertinoIcons.doc_on_clipboard,
                color: Colors.amber.shade400,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
