import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Details',
      home: UserPage(),
    );
  }
}

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            UserOption(
                icon: Icons.person,
                text: 'Personal Details',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PersonalDetailsPage()),
                  );
                }),
            UserOption(
                icon: Icons.directions_car,
                text: 'Vehicle Details',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VehicleDetailsPage()),
                  );
                }),
            UserOption(
              icon: Icons.local_hospital,
              text: 'Medical Details',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MedicalDetailsPage()),
                );
              },
            ),
            UserOption(
              icon: Icons.security,
              text: 'Insurance Details',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InsuranceDetailsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UserOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const UserOption({required this.icon, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(text, style: TextStyle(fontSize: 18)),
        onTap: onTap,
      ),
    );
  }
}

class VehicleDetailsPage extends StatefulWidget {
  @override
  _VehicleDetailsPageState createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
final TextEditingController rcNoController = TextEditingController();
final TextEditingController vehicleRegController = TextEditingController();
final TextEditingController modelController = TextEditingController();
final TextEditingController ownerNameController = TextEditingController();
final TextEditingController fuelTypeController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vehicle Details"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              _buildTextField("RC Number", rcNoController),
              _buildTextField("Vehicle Registration", vehicleRegController),
              _buildTextField("Model", modelController),
              _buildTextField("Owner Name", ownerNameController),
              _buildTextField("Fuel Type", fuelTypeController),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _submitVehicleDetails(context);
                  },
                  child: Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  void _submitVehicleDetails(BuildContext context) async {
    String rcNumber = rcNoController.text;
    String registration = vehicleRegController.text;
    String model = modelController.text;
    String owner = ownerNameController.text;
    String fuel = fuelTypeController.text;

    if (rcNumber.isEmpty ||
        registration.isEmpty ||
        model.isEmpty ||
        owner.isEmpty ||
        fuel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill out all fields")),
      );
      return;
    }

    try {
      // Save data to Firebase Firestore
      await FirebaseFirestore.instance.collection('vehicleDetails').add({
        'rcNumber': rcNumber,
        'registration': registration,
        'model': model,
        'owner': owner,
        'fuelType': fuel,
        'timestamp': FieldValue.serverTimestamp(), // Optional for sorting
      });

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Vehicle Details Submitted"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("RC Number: $rcNumber"),
              Text("Registration: $registration"),
              Text("Model: $model"),
              Text("Owner: $owner"),
              Text("Fuel Type: $fuel"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            )
          ],
        ),
      );

      // Clear the input fields after submission
      rcNoController.clear();
      vehicleRegController.clear();
      modelController.clear();
      ownerNameController.clear();
      fuelTypeController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save data: $e")),
      );
    }
  }
}


class PersonalDetailsPage extends StatefulWidget {
  @override
  _PersonalDetailsPageState createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Personal Details"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              _buildTextField("Name", nameController),
              _buildTextField("Date of Birth", dobController),
              _buildTextField("Email", emailController),
              _buildTextField("Phone", phoneController),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _submitPersonalDetails(context);
                  },
                  child: Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Future<void> _submitPersonalDetails(BuildContext context) async {
    String name = nameController.text;
    String dob = dobController.text;
    String email = emailController.text;
    String phone = phoneController.text;

    if (name.isEmpty || dob.isEmpty || email.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill out all fields")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('personalDetails').add({
        'name': name,
        'dob': dob,
        'email': email,
        'phone': phone,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Details submitted successfully!")),
      );

      nameController.clear();
      dobController.clear();
      emailController.clear();
      phoneController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting details: $e")),
      );
    }
  }
}


class MedicalDetailsPage extends StatefulWidget {
  @override
  _MedicalDetailsPageState createState() => _MedicalDetailsPageState();
}

class _MedicalDetailsPageState extends State<MedicalDetailsPage> {
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController allergiesController = TextEditingController();
  final TextEditingController medicalHistoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Medical Details"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              _buildTextField("Blood Group", bloodGroupController),
              _buildTextField("Allergies", allergiesController),
              _buildTextField("Medical History", medicalHistoryController),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _submitMedicalDetails(context);
                  },
                  child: Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Future<void> _submitMedicalDetails(BuildContext context) async {
    String bloodGroup = bloodGroupController.text;
    String allergies = allergiesController.text;
    String medicalHistory = medicalHistoryController.text;

    if (bloodGroup.isEmpty || allergies.isEmpty || medicalHistory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill out all fields")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('medicalDetails').add({
        'bloodGroup': bloodGroup,
        'allergies': allergies,
        'medicalHistory': medicalHistory,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Details submitted successfully!")),
      );

      bloodGroupController.clear();
      allergiesController.clear();
      medicalHistoryController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting details: $e")),
      );
    }
  }
}



class InsuranceDetailsPage extends StatefulWidget {
  @override
  _InsuranceDetailsPageState createState() => _InsuranceDetailsPageState();
}

class _InsuranceDetailsPageState extends State<InsuranceDetailsPage> {
  final TextEditingController insuranceProviderController =
      TextEditingController();
  final TextEditingController policyNumberController = TextEditingController();
  final TextEditingController coverageAmountController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Insurance Details"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              _buildTextField("Insurance Provider", insuranceProviderController),
              _buildTextField("Policy Number", policyNumberController),
              _buildTextField("Coverage Amount", coverageAmountController),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _submitInsuranceDetails(context);
                  },
                  child: Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  void _submitInsuranceDetails(BuildContext context) async {
    String insuranceProvider = insuranceProviderController.text;
    String policyNumber = policyNumberController.text;
    String coverageAmount = coverageAmountController.text;

    if (insuranceProvider.isEmpty ||
        policyNumber.isEmpty ||
        coverageAmount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill out all fields")),
      );
      return;
    }

    try {
      // Save data to Firebase Firestore
      await FirebaseFirestore.instance.collection('insuranceDetails').add({
        'insuranceProvider': insuranceProvider,
        'policyNumber': policyNumber,
        'coverageAmount': coverageAmount,
        'timestamp': FieldValue.serverTimestamp(), // Optional for sorting
      });

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Insurance Details Submitted"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Insurance Provider: $insuranceProvider"),
              Text("Policy Number: $policyNumber"),
              Text("Coverage Amount: $coverageAmount"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            )
          ],
        ),
      );

      // Clear the fields after submission
      insuranceProviderController.clear();
      policyNumberController.clear();
      coverageAmountController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save data: $e")),
      );
    }
  }

  @override
  void dispose() {
    insuranceProviderController.dispose();
    policyNumberController.dispose();
    coverageAmountController.dispose();
    super.dispose();
  }
}
