import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ad_provider.dart';
import '../../providers/material_provider.dart';
import '../../models/material_type.dart' as model;
import '../../utils/app_theme.dart';

class AddAdScreen extends StatefulWidget {
  const AddAdScreen({super.key});

  @override
  State<AddAdScreen> createState() => _AddAdScreenState();
}

class _AddAdScreenState extends State<AddAdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  
  model.MaterialType? _selectedMaterialType;
  String _selectedUnit = 'kg';
  
  final List<String> _units = ['kg', 'ton', 'piece', 'liter', 'meter'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submitAd() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedMaterialType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'يرجى اختيار نوع المادة',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final adProvider = Provider.of<AdProvider>(context, listen: false);
      
      final success = await adProvider.createAd(
        materialTypeId: _selectedMaterialType!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        quantity: double.parse(_quantityController.text),
        unit: _selectedUnit,
        pricePerUnit: double.parse(_priceController.text),
        location: _locationController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم إضافة الإعلان بنجاح',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        _clearForm();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              adProvider.errorMessage ?? 'فشل في إضافة الإعلان',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _quantityController.clear();
    _priceController.clear();
    _locationController.clear();
    setState(() {
      _selectedMaterialType = null;
      _selectedUnit = 'kg';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إضافة إعلان جديد',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 20),
            
            // Material type selection
            const Text(
              'نوع المادة *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 8),
            Consumer<MaterialProvider>(
              builder: (context, materialProvider, child) {
                final materialTypes = materialProvider.getActiveMaterialTypes();
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<model.MaterialType>(
                      value: _selectedMaterialType,
                      hint: const Text(
                        'اختر نوع المادة',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                      isExpanded: true,
                      items: materialTypes.map((materialType) {
                        return DropdownMenuItem<model.MaterialType>(
                          value: materialType,
                          child: Row(
                            children: [
                              Text(
                                materialType.icon ?? '📦',
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                materialType.getLocalizedName('ar'),
                                style: const TextStyle(fontFamily: 'Cairo'),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMaterialType = value;
                          _selectedUnit = value?.unit ?? 'kg';
                          _priceController.text = value?.averagePrice.toString() ?? '';
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'عنوان الإعلان *',
                hintText: 'مثال: قناني بلاستيكية نظيفة - 50 كيلو',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال عنوان الإعلان';
                }
                if (value.length < 10) {
                  return 'العنوان يجب أن يكون 10 أحرف على الأقل';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'وصف المادة *',
                hintText: 'اكتب وصفاً مفصلاً عن المادة وحالتها...',
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال وصف المادة';
                }
                if (value.length < 20) {
                  return 'الوصف يجب أن يكون 20 حرف على الأقل';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Quantity and Unit
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'الكمية *',
                      hintText: '0',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال الكمية';
                      }
                      final quantity = double.tryParse(value);
                      if (quantity == null || quantity <= 0) {
                        return 'يرجى إدخال كمية صحيحة';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedUnit,
                        isExpanded: true,
                        items: _units.map((unit) {
                          return DropdownMenuItem<String>(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedUnit = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Price per unit
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'السعر لكل $_selectedUnit (دولار) *',
                hintText: '0.00',
                prefixIcon: const Icon(Icons.attach_money),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال السعر';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return 'يرجى إدخال سعر صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'الموقع *',
                hintText: 'المدينة، المنطقة',
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال الموقع';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // Total price display
            if (_quantityController.text.isNotEmpty && _priceController.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'السعر الإجمالي:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Text(
                      '${(double.tryParse(_quantityController.text) ?? 0) * (double.tryParse(_priceController.text) ?? 0)} دولار',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Submit button
            Consumer<AdProvider>(
              builder: (context, adProvider, child) {
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: adProvider.isLoading ? null : _submitAd,
                    child: adProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'نشر الإعلان',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Clear form button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _clearForm,
                child: const Text(
                  'مسح النموذج',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
