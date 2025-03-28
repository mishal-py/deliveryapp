import 'package:flutter/material.dart';
import 'package:newapp/components/custom_textfield.dart';
import 'package:newapp/pages/cart_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load initial user data
    _nameController.text = 'Mishal Shrestha';
    _addressController.text = 'Pokhara-25, Hemja';
    _phoneController.text = '+977 9846083294';
    _emailController.text = 'mishalstha2018@gmail.com';
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Save changes logic
      }
    });
  }

  void _handlePasswordChange() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OTPScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
       actions: [
        IconButton(
          onPressed: (){
            Navigator.push(context, 
    MaterialPageRoute(builder: (context)=> const CartScreen(),
    ),
    );
          },
          icon: Icon(Icons.shopping_cart))
      ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileImage(),
            const SizedBox(height: 30),
            _buildEditableField(
              hintText: 'Full Name',
              controller: _nameController,
              icon: Icons.person_2_outlined,
            ),
            _buildEditableField(
              hintText: 'Address',
              controller: _addressController,
              icon: Icons.location_history,
            ),
            _buildEditableField(
              hintText: 'Phone Number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              icon: Icons.phone
            ),
            _buildEditableField(
              hintText: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              icon: Icons.email_outlined
            ),
            _buildPasswordField(),
            const SizedBox(height: 20),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage('https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?q=80&w=1965&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
          ),
          if (_isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: () {
                    // Implement image picker
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CustomTextfield(
        controller: controller,
        hintText: hintText,
        obscureText: false,
        prefixIcon: icon,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: _isEditing ? _handlePasswordChange : null,
        child: AbsorbPointer(
          absorbing: true,
          child: CustomTextfield(
            controller: TextEditingController(text: '********'),
            hintText: 'Password',
            obscureText: true,
            prefixIcon: Icons.lock,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _toggleEdit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(_isEditing ? 'SAVE CHANGES' : 'EDIT PROFILE'),
        ),
      ),
    );
  }
}

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Enter OTP sent to your registered mobile number'),
            const SizedBox(height: 20),
            CustomTextfield(
              controller: TextEditingController(),
              hintText: 'OTP',
              obscureText: false,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Verify OTP logic
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('VERIFY OTP'),
            ),
          ],
        ),
      ),
    );
  }
}