import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/models/supabase_company.dart';
import 'package:hodorak/core/services/service_locator.dart';
import 'package:hodorak/core/theming/styles.dart';
import 'package:hodorak/features/login/presentation/widgets/custom_text_field_auth.dart';
import 'package:hodorak/features/login/presentation/widgets/label_text_field.dart';

class CompanySelectionWidget extends ConsumerStatefulWidget {
  final Function(SupabaseCompany?) onCompanySelected;
  final Function(String) onNewCompanyCreated;

  const CompanySelectionWidget({
    super.key,
    required this.onCompanySelected,
    required this.onNewCompanyCreated,
  });

  @override
  ConsumerState<CompanySelectionWidget> createState() =>
      _CompanySelectionWidgetState();
}

class _CompanySelectionWidgetState
    extends ConsumerState<CompanySelectionWidget> {
  final _searchController = TextEditingController();
  final _newCompanyController = TextEditingController();
  final _newCompanyDescriptionController = TextEditingController();

  List<SupabaseCompany> _companies = [];
  List<SupabaseCompany> _filteredCompanies = [];
  SupabaseCompany? _selectedCompany;
  bool _isLoading = false;
  bool _showNewCompanyForm = false;
  bool _isCreatingCompany = false;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _newCompanyController.dispose();
    _newCompanyDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final companies = await supabaseCompanyService.getAllCompanies();
      setState(() {
        _companies = companies;
        _filteredCompanies = companies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading companies: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterCompanies(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCompanies = _companies;
      } else {
        _filteredCompanies = _companies
            .where(
              (company) =>
                  company.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _selectCompany(SupabaseCompany company) {
    setState(() {
      _selectedCompany = company;
      _showNewCompanyForm = false;
    });
    widget.onCompanySelected(company);
  }

  Future<void> _createNewCompany() async {
    if (_newCompanyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a company name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCreatingCompany = true;
    });

    try {
      // Check if company name already exists
      final exists = await supabaseCompanyService.companyNameExists(
        _newCompanyController.text.trim(),
      );

      if (exists) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A company with this name already exists'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isCreatingCompany = false;
        });
        return;
      }

      // Create the company
      final newCompany = await supabaseCompanyService.createCompany(
        name: _newCompanyController.text.trim(),
        adminUserId: null, // This will be updated after user creation
        description: _newCompanyDescriptionController.text.trim().isEmpty
            ? null
            : _newCompanyDescriptionController.text.trim(),
      );

      setState(() {
        _isCreatingCompany = false;
        _showNewCompanyForm = false;
        _selectedCompany = newCompany;
      });

      widget.onNewCompanyCreated(newCompany.id);
      widget.onCompanySelected(newCompany);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Company created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isCreatingCompany = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating company: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelTextField(title: 'Company'),
        verticalSpace(8),

        // Search existing companies
        CustomTextFieldAuth(
          controller: _searchController,
          hintText: 'Search for your company...',
          onChanged: _filterCompanies,
          suffixIcon: Icon(Icons.search),
          validator: (value) => null, // No validation needed for search
        ),

        verticalSpace(16),

        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_showNewCompanyForm)
          // New company form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Company',
                  style: Styles.textSize13Black600.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                verticalSpace(16),

                CustomTextFieldAuth(
                  controller: _newCompanyController,
                  hintText: 'Company Name *',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter company name';
                    }
                    return null;
                  },
                ),
                verticalSpace(12),

                CustomTextFieldAuth(
                  controller: _newCompanyDescriptionController,
                  hintText: 'Description (Optional)',
                  maxLines: 3,
                  validator: (value) => null, // Optional field
                ),
                verticalSpace(16),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isCreatingCompany
                            ? null
                            : _createNewCompany,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _isCreatingCompany
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Create Company'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _showNewCompanyForm = false;
                          });
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        else
          // Company list
          Container(
            constraints: BoxConstraints(maxHeight: 200.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _filteredCompanies.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'No companies found',
                          style: Styles.textSize13Black600,
                        ),
                        verticalSpace(8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showNewCompanyForm = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Create New Company'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredCompanies.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _filteredCompanies.length) {
                        return ListTile(
                          leading: const Icon(Icons.add, color: Colors.blue),
                          title: const Text(
                            'Create New Company',
                            style: TextStyle(color: Colors.blue),
                          ),
                          onTap: () {
                            setState(() {
                              _showNewCompanyForm = true;
                            });
                          },
                        );
                      }

                      final company = _filteredCompanies[index];
                      final isSelected = _selectedCompany?.id == company.id;

                      return ListTile(
                        leading: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : const Icon(Icons.business),
                        title: Text(company.name),
                        subtitle: company.description != null
                            ? Text(company.description!)
                            : null,
                        selected: isSelected,
                        onTap: () => _selectCompany(company),
                      );
                    },
                  ),
          ),
      ],
    );
  }
}
