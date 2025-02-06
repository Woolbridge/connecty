import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For image picking

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Whether the user is currently editing their profile.
  bool _isEditing = false;

  /// Mock user data (replace with real data from your backend or provider)
  String _avatarUrl =
      'https://via.placeholder.com/150'; // Placeholder avatar URL
  String _name = 'John Doe'; // Typically from the User model
  String _bio = 'Flutter Developer, Coffee Enthusiast, Traveler';
  String _instagram = '@john_doe';
  String _twitter = '@JohnDoeFlutter';
  String _linkedin = 'linkedin.com/in/johndoe';
  String _facebook = 'facebook.com/john.doe';
  String _musicAnthem = 'My Favorite Anthem - Unknown';

  /// Simulated posts list (in a real app, fetch these from your API)
  List<Map<String, String>> _posts = [
    {
      'title': 'My First Post',
      'content': 'Hello world! This is my first post.',
      'image_url': 'https://via.placeholder.com/400x200'
    },
    {
      'title': 'Vacation Time',
      'content': 'Enjoying the beach and the sunshine!',
      'image_url': 'https://via.placeholder.com/400x200'
    },
  ];

  // Controllers to manage text fields during editing
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _instagramController;
  late TextEditingController _twitterController;
  late TextEditingController _linkedinController;
  late TextEditingController _facebookController;
  late TextEditingController _musicAnthemController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current profile data
    _nameController = TextEditingController(text: _name);
    _bioController = TextEditingController(text: _bio);
    _instagramController = TextEditingController(text: _instagram);
    _twitterController = TextEditingController(text: _twitter);
    _linkedinController = TextEditingController(text: _linkedin);
    _facebookController = TextEditingController(text: _facebook);
    _musicAnthemController = TextEditingController(text: _musicAnthem);
  }

  @override
  void dispose() {
    // Dispose controllers
    _nameController.dispose();
    _bioController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _linkedinController.dispose();
    _facebookController.dispose();
    _musicAnthemController.dispose();
    super.dispose();
  }

  /// Toggles edit mode or saves changes.
  void _toggleEditSave() {
    if (_isEditing) {
      // Save the updated data (in a real app, call your backend API here)
      setState(() {
        _name = _nameController.text;
        _bio = _bioController.text;
        _instagram = _instagramController.text;
        _twitter = _twitterController.text;
        _linkedin = _linkedinController.text;
        _facebook = _facebookController.text;
        _musicAnthem = _musicAnthemController.text;
        _isEditing = false;
      });
      // TODO: Call ApiService.updateProfile({...}) to persist changes.
    } else {
      setState(() {
        _isEditing = true;
      });
    }
  }

  /// Let the user pick a custom avatar using image_picker.
  Future<void> _pickAvatar() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        // For now, we store the local file path.
        // In production, upload the file and update _avatarUrl with the remote URL.
        _avatarUrl = pickedFile.path;
      });
      // TODO: Upload the image to your server (e.g., via ApiService.uploadAvatar)
    }
  }

  /// Builds either a read-only or editable widget for profile fields.
  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    if (_isEditing) {
      return TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(controller.text.isEmpty ? '-' : controller.text),
          ],
        ),
      );
    }
  }

  /// A widget to display a single post.
  Widget _buildPostItem(Map<String, String> post) {
    final title = post['title'] ?? 'Untitled Post';
    final content = post['content'] ?? '';
    final imageUrl = post['image_url'] ?? '';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(content),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: _toggleEditSave,
            child: Text(
              _isEditing ? 'Save' : 'Edit',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
            top: topPadding, left: 16, right: 16, bottom: 16),
        child: Column(
          children: [
            // Avatar with edit overlay if editing
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _avatarUrl.startsWith('http')
                        ? NetworkImage(_avatarUrl)
                        : AssetImage('assets/placeholder_avatar.png')
                            as ImageProvider,
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickAvatar,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Name (read-only for now, or could be editable if desired)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Name',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(_name),
                ],
              ),
            ),

            // Music Anthem Field
            _buildProfileField(
              label: 'Music Anthem',
              controller: _musicAnthemController,
            ),

            // Bio Field
            _buildProfileField(
              label: 'Bio',
              controller: _bioController,
              maxLines: _isEditing ? 3 : 1,
            ),

            // Instagram Field
            _buildProfileField(
              label: 'Instagram',
              controller: _instagramController,
            ),

            // Twitter Field
            _buildProfileField(
              label: 'Twitter',
              controller: _twitterController,
            ),

            // LinkedIn Field
            _buildProfileField(
              label: 'LinkedIn',
              controller: _linkedinController,
            ),

            // Facebook Field
            _buildProfileField(
              label: 'Facebook',
              controller: _facebookController,
            ),

            const SizedBox(height: 20),

            // Posts Heading
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'User Posts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // Display user posts (replace _posts with your API data)
            Column(
              children: _posts.map((post) => _buildPostItem(post)).toList(),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
