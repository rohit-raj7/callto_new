 


import 'package:flutter/material.dart';
import 'language_selection_page.dart';
import '../../services/storage_service.dart';

class FemaleProfilePage extends StatefulWidget {
  const FemaleProfilePage({super.key});

  @override
  State<FemaleProfilePage> createState() => _FemaleProfilePageState();
}

class _FemaleProfilePageState extends State<FemaleProfilePage> {
  final TextEditingController originalNameController = TextEditingController();
  final TextEditingController dummyNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  int? selectedAvatarIndex;

  final List<String> avatarImages = [
    'assets/images/female_profile/avatar2.jpg',
    'assets/images/female_profile/avatar3.jpg',
    'assets/images/female_profile/avatar4.jpg',
    'assets/images/female_profile/avatar5.jpg',
    'assets/images/female_profile/avatar6.jpg',
    'assets/images/female_profile/avatar7.jpg',
    'assets/images/female_profile/avatar8.jpg',
    'assets/images/female_profile/avatar9.jpg',
    'assets/images/female_profile/avatar10.jpg',
    'assets/images/female_profile/avatar11.jpg',
    'assets/images/female_profile/avatar12.jpg',
    'assets/images/female_profile/avatar13.jpg',
    'assets/images/female_profile/avatar14.jpg',
    'assets/images/female_profile/avatar15.jpg',
  ];

  Future<void> _submitProfile() async {
    if (originalNameController.text.isEmpty ||
        dummyNameController.text.isEmpty ||
        ageController.text.isEmpty ||
        cityController.text.isEmpty ||
        selectedAvatarIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields and select an avatar'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final age = int.tryParse(ageController.text.trim());
    if (age == null || age < 18 || age > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid age between 18 and 100'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final storageService = StorageService();
    final professionalName = dummyNameController.text.trim();
    final originalName = originalNameController.text.trim();
    final city = cityController.text.trim();
    final avatarUrl = avatarImages[selectedAvatarIndex!];

    // Save all data to localStorage first
    try {
      await storageService.saveListenerProfessionalName(professionalName);
      await storageService.saveListenerOriginalName(originalName);
      await storageService.saveListenerAge(age);
      await storageService.saveListenerCity(city);
      await storageService.saveListenerAvatarUrl(avatarUrl);
      await storageService.saveListenerSpecialties(['Confidence']);
      await storageService.saveListenerRatePerMinute(1.0);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LanguageSelectionPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  @override
  void dispose() {
    originalNameController.dispose();
    dummyNameController.dispose();
    ageController.dispose();
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final bool isMobile = screenWidth < 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Complete Your Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF4081), Color(0xFFFCE4EC)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.03),

                /// Selected Avatar Preview
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: selectedAvatarIndex == null
                        ? const Icon(Icons.person, size: 60, color: Colors.white)
                        : Image.asset(
                            avatarImages[selectedAvatarIndex!],
                            fit: BoxFit.cover,
                          ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                /// Form Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.transparent,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Details',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildTextField(
                        label: 'Original Name',
                        hint: 'Your real name (private)',
                        icon: Icons.person_outline,
                        controller: originalNameController,
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        label: 'Display Name',
                        hint: 'How others will see you',
                        icon: Icons.badge_outlined,
                        controller: dummyNameController,
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        label: 'Age',
                        hint: 'Your age in years',
                        icon: Icons.calendar_today,
                        controller: ageController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        label: 'City',
                        hint: 'Where you live',
                        icon: Icons.location_on_outlined,
                        controller: cityController,
                      ),

                      const SizedBox(height: 32),

                      const Text(
                        'Choose Your Avatar',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// Avatar Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isMobile ? 3 : 4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: avatarImages.length,
                        itemBuilder: (context, index) {
                          return _buildAvatarOption(
                            imageUrl: avatarImages[index],
                            isSelected: selectedAvatarIndex == index,
                            onTap: () =>
                                setState(() => selectedAvatarIndex = index),
                          );
                        },
                      ),

                      const SizedBox(height: 36),

                      /// Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _submitProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF4081),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Text Field Widget
  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFFFF4081)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  /// Avatar Widget
  Widget _buildAvatarOption({
    required String imageUrl,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  isSelected ? const Color(0xFFFF4081) : Colors.transparent,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 8,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(imageUrl, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
