import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/text_fields.dart';

class ReviewsScreen extends StatefulWidget {
  final String productId;
  const ReviewsScreen({super.key, required this.productId});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  int _rating = 5;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    setState(() {
      _isLoading = true;
    });

    // Mock review delay
    await Future.delayed(const Duration(milliseconds: 1000));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully! Thank you.')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Write a Review'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(OBSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rate the Product',
              style: OBTypography.subtitle.copyWith(
                color: isDark ? Colors.white : OBColors.neutral800,
              ),
            ),
            const SizedBox(height: OBSpacing.space2),
            // Star selector
            Row(
              children: List.generate(5, (index) {
                final isSelected = index < _rating;
                return IconButton(
                  icon: Icon(
                    isSelected ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36.0,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: OBSpacing.space6),

            Text(
              'Your Comments',
              style: OBTypography.subtitle.copyWith(
                color: isDark ? Colors.white : OBColors.neutral800,
              ),
            ),
            const SizedBox(height: OBSpacing.space2),
            OBTextField(
              label: 'Comment',
              hintText: 'Share your feedback about the product quality and delivery.',
              controller: _commentController,
              keyboardType: TextInputType.multiline,
              isEnabled: !_isLoading,
            ),
            const SizedBox(height: OBSpacing.space8),

            OBButton(
              text: 'Submit Review',
              onPressed: _isLoading ? null : _handleSubmit,
              isLoading: _isLoading,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
