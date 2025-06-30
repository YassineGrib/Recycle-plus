import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ad.dart';
import '../providers/material_provider.dart';
import '../providers/ad_provider.dart';
import '../utils/app_theme.dart';
import 'package:intl/intl.dart';

class AdCard extends StatelessWidget {
  final Ad ad;
  final bool showSellerActions;
  final VoidCallback? onTap;

  const AdCard({
    super.key,
    required this.ad,
    this.showSellerActions = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap ?? () => _showAdDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status and actions
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ad.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Material type and location
                Consumer<MaterialProvider>(
                  builder: (context, materialProvider, child) {
                    final materialType = materialProvider.getMaterialTypeById(ad.materialTypeId);
                    return Row(
                      children: [
                        if (materialType != null) ...[
                          Text(
                            materialType.icon ?? '📦',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            materialType.getLocalizedName('ar'),
                            style: const TextStyle(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                        const Spacer(),
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            ad.location,
                            style: const TextStyle(
                              color: AppTheme.textLight,
                              fontSize: 12,
                              fontFamily: 'Cairo',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Description
                Text(
                  ad.description,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 14,
                    fontFamily: 'Cairo',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 12),
                
                // Quantity and price
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGreen,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${ad.quantity} ${ad.unit}',
                        style: const TextStyle(
                          color: AppTheme.darkGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${ad.pricePerUnit.toStringAsFixed(2)} \$ / ${ad.unit}',
                          style: const TextStyle(
                            color: AppTheme.textLight,
                            fontSize: 12,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          '${ad.totalPrice.toStringAsFixed(2)} \$ إجمالي',
                          style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Footer with date and stats
                Row(
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy').format(ad.createdAt),
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 12,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.visibility,
                      size: 14,
                      color: AppTheme.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${ad.views}',
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.message,
                      size: 14,
                      color: AppTheme.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${ad.inquiries}',
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    if (showSellerActions) _buildSellerActions(context),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    String text;
    
    switch (ad.status) {
      case AdStatus.active:
        color = AppTheme.primaryGreen;
        text = 'نشط';
        break;
      case AdStatus.sold:
        color = AppTheme.accentGreen;
        text = 'مباع';
        break;
      case AdStatus.expired:
        color = AppTheme.textLight;
        text = 'منتهي';
        break;
      case AdStatus.pending:
        color = AppTheme.recycleOrange;
        text = 'معلق';
        break;
      case AdStatus.rejected:
        color = Colors.red;
        text = 'مرفوض';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  Widget _buildSellerActions(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      onSelected: (value) => _handleSellerAction(context, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('تعديل', style: TextStyle(fontFamily: 'Cairo')),
            ],
          ),
        ),
        if (ad.status == AdStatus.active)
          const PopupMenuItem(
            value: 'mark_sold',
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 18, color: AppTheme.primaryGreen),
                SizedBox(width: 8),
                Text('تحديد كمباع', style: TextStyle(fontFamily: 'Cairo')),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('حذف', style: TextStyle(color: Colors.red, fontFamily: 'Cairo')),
            ],
          ),
        ),
      ],
    );
  }

  void _handleSellerAction(BuildContext context, String action) {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    
    switch (action) {
      case 'edit':
        // TODO: Navigate to edit ad screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعديل الإعلان - قريباً', style: TextStyle(fontFamily: 'Cairo')),
          ),
        );
        break;
      case 'mark_sold':
        adProvider.updateAdStatus(ad.id, AdStatus.sold);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديد الإعلان كمباع', style: TextStyle(fontFamily: 'Cairo')),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الإعلان', style: TextStyle(fontFamily: 'Cairo')),
        content: const Text(
          'هل أنت متأكد من رغبتك في حذف هذا الإعلان؟',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حذف الإعلان', style: TextStyle(fontFamily: 'Cairo')),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: Colors.red, fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdDetails(BuildContext context) {
    // Increment views
    Provider.of<AdProvider>(context, listen: false).incrementAdViews(ad.id);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Ad details content
              Text(
                ad.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                ad.description,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 20),
              
              // Price and quantity info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'الكمية:',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        Text(
                          '${ad.quantity} ${ad.unit}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'السعر لكل وحدة:',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        Text(
                          '${ad.pricePerUnit.toStringAsFixed(2)} \$',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'السعر الإجمالي:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          '${ad.totalPrice.toStringAsFixed(2)} \$',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Contact button
              if (ad.status == AdStatus.active)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'التواصل مع البائع - قريباً',
                            style: TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.message),
                    label: const Text(
                      'التواصل مع البائع',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
