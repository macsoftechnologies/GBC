import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/models/bookings_overview_model.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/my_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/util_class.dart';

class RateProviderScreen extends StatefulWidget {
  const RateProviderScreen({super.key});

  @override
  State<RateProviderScreen> createState() => _RateProviderScreenState();
}

class _RateProviderScreenState extends State<RateProviderScreen> {
  int _selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitEnabled = false;
  List<Service> _servicesData = [];
  final ImagePicker _imagePicker = ImagePicker();
  List<XFile?> _selectedImages = [];
  Provider? provider;
  String? OrderId;
  String? customerUserId;
  bool _isLoading = false;


@override
void didChangeDependencies() {
  super.didChangeDependencies();
  final args = ModalRoute.of(context)?.settings.arguments as Map?;

  if (args != null) {
    final dynamic providerArg = args['provider'];
    final dynamic servicesArg = args['services'];
    OrderId = args['order_id'];
    customerUserId = args['user_id']?.toString();

    // ✅ handle provider object or map
    if (providerArg is Provider) {
      provider = providerArg;
    } else if (providerArg is Map<String, dynamic>) {
      provider = Provider.fromJson(providerArg);
    }

    // ✅ handle services list / single service / map
    if (servicesArg is List) {
      _servicesData = servicesArg
          .map((item) => item is Service
              ? item
              : Service.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (servicesArg is Service) {
      _servicesData = [servicesArg];
    } else if (servicesArg is Map<String, dynamic>) {
      _servicesData = [Service.fromJson(servicesArg)];
    } else {
      _servicesData = [];
    }
  }
}



  @override
  void initState() {
    super.initState();
    _reviewController.addListener(_updateSubmitButtonState);
  }



Future<void> _submitReviewWithImages() async {
  bool internet = await UtilClass.checkInternet();
  if (!internet) {
    UtilClass.showAlertDialog(context: context, message: "No Internet Connection!");
    return;
  }

  setState(() => _isLoading = true); // Show loader

  try {
    if (customerUserId == null || customerUserId!.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      customerUserId = prefs.getString('user_id');
    }

    // Submit review
    final reviewResponse = await Repository.NewPostApiService(
      EndPoints.RateProviderinBookings,
      {
        'user_id': customerUserId ?? "",
        'job_calender_id': OrderId ?? "",
        'rating': _selectedRating,
        'review': _reviewController.text.trim(),
      },
    );

    if (reviewResponse["status"] != "valid") {
      UtilClass.showAlertDialog(context: context, message: "Error submitting review");
      return;
    }

    // Upload images if selected
    if (_selectedImages.isNotEmpty) {
      final imageResponse = await Repository.NewPostApiService(
        EndPoints.ImageUploadingApiforReview,
        {
          'provider_id': provider?.id ?? "",
          'images': _selectedImages,
          'service_id': OrderId ?? ""
        },
      );

    }

    // Show success popup
    _showSuccessDialog(context);

  } catch (e) {
    UtilClass.showAlertDialog(context: context, message: "Something went wrong: $e");
  } finally {
    setState(() => _isLoading = false); // Hide loader
  }
}


  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to pick image'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _updateSubmitButtonState() {
    setState(() {
      _isSubmitEnabled =
          _selectedRating > 0 || _reviewController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    if (_servicesData.isEmpty) {
      return Scaffold(
        backgroundColor: MyColors.lightpeachColor,
        appBar: AppBar(
          backgroundColor: MyColors.lightpeachColor,
          elevation: 0,
          leading: Padding(
            padding: EdgeInsets.only(left: width * 0.04),
            child: _backButton(width),
          ),
          title: Text(
            "Rate Provider",
            style: TextStyle(
              color: const Color(0xFF1A1A1A),
              fontSize: width * 0.052,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final firstService = _servicesData.first;

    return Scaffold(
      backgroundColor: MyColors.lightpeachColor,
      appBar: AppBar(
        backgroundColor: MyColors.lightpeachColor,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: width * 0.04),
          child: _backButton(width),
        ),
        title: Text(
          "Rate Provider",
          style: TextStyle(
            color: const Color(0xFF1A1A1A),
            fontSize: width * 0.052,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Services List
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: height * 0.02),
                          Text(
                            "Services Provided",
                            style: TextStyle(
                              color: Colors.blueGrey[900],
                              fontSize: width * 0.05,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: height * 0.01),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              children: _servicesData.map((service) {
                                return Container(
                                  padding: EdgeInsets.all(width * 0.04),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: width * 0.1,
                                        height: width * 0.1,
                                        decoration: BoxDecoration(
                                          color: MyColors.darkpeachColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Colors.green[600],
                                          size: width * 0.05,
                                        ),
                                      ),
                                      SizedBox(width: width * 0.03),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              service.serviceName ??
                                                  "Service Name",
                                              style: TextStyle(
                                                color: Colors.blueGrey[900],
                                                fontSize: width * 0.04,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(height: height * 0.002),
                                            Text(
                                              service.serviceName ??
                                                  "Service Category",
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: width * 0.035,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.03),

                    // Provider Info (you can customize based on provider data)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                      child: Row(
                        children: [
                          CircleAvatar(
  radius: width * 0.07,
  backgroundColor: Colors.grey[200],
  backgroundImage: (provider?.providerProfile != null &&
          provider!.providerProfile!.isNotEmpty)
      ? NetworkImage(provider!.providerProfile!)
      : null,
  child: (provider?.providerProfile == null ||
          provider!.providerProfile!.isEmpty)
      ? Icon(
          Icons.person, // fallback icon
          color: Colors.grey[400],
          size: width * 0.07,
        )
      : null,
),

                          SizedBox(width: width * 0.04),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider?.name??"",
                                style: TextStyle(
                                  color: Colors.blueGrey[900],
                                  fontWeight: FontWeight.w600,
                                  fontSize: width * 0.048,
                                ),
                              ),
                              SizedBox(height: height * 0.004),
                              Text(
                              provider?.phone??"",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: width * 0.037,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.035),

                    // Rate Now
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                      child: Text(
                        "Rate now",
                        style: TextStyle(
                          color: Colors.blueGrey[900],
                          fontWeight: FontWeight.w600,
                          fontSize: width * 0.045,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.012),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                      child: Row(
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRating = index + 1;
                                _updateSubmitButtonState();
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: width * 0.02),
                              child: Icon(
                                _selectedRating > index
                                    ? Icons.star
                                    : Icons.star_border_rounded,
                                color: _selectedRating > index
                                    ? const Color(0xFFFFB800)
                                    : Colors.grey[300],
                                size: width * 0.1,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    SizedBox(height: height * 0.03),

                    // Review Field
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                      child: Text(
                        "Write a review",
                        style: TextStyle(
                          color: Colors.blueGrey[900],
                          fontWeight: FontWeight.w600,
                          fontSize: width * 0.045,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.012),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                      child: Container(
                        decoration: BoxDecoration(
                          color: MyColors.darkpeachColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextField(
                          controller: _reviewController,
                          maxLines: 6,
                          decoration: InputDecoration(
                            hintText: "Write a review",
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: width * 0.04,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(width * 0.04),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.03),

                    // Add Photos
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                      child: Text(
                        "Add photos and videos",
                        style: TextStyle(
                          color: Colors.blueGrey[900],
                          fontWeight: FontWeight.w600,
                          fontSize: width * 0.045,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.015),

                    // Image Picker
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                      child: SizedBox(
                        height: width * 0.35,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _selectedImages.length) {
                              return _addPhotoButton(width, height);
                            } else {
                              return _photoPreview(index, width, height);
                            }
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.05),

                    // Submit Button placeholder
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (){
                               _submitReviewWithImages();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSubmitEnabled
                                ? MyColors.appThemeLight
                                : const Color(0xFFEFEDEE),
                            padding:
                                EdgeInsets.symmetric(vertical: height * 0.022),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Submit",
                            style: TextStyle(
                              color: _isSubmitEnabled
                                  ? Colors.white
                                  : Colors.grey[400],
                              fontSize: width * 0.045,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                   
                   
                    SizedBox(height: height * 0.04),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _backButton(double width) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: width * 0.06,
        backgroundColor: Colors.white,
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.green[600],
            size: width * 0.06,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _addPhotoButton(double width, double height) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: width * 0.35,
        height: width * 0.35,
        margin: EdgeInsets.only(right: width * 0.03),
        decoration: BoxDecoration(
          color: MyColors.darkpeachColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: Colors.grey[400],
              size: width * 0.15,
            ),
            SizedBox(height: height * 0.01),
            Text(
              "Add Photo",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: width * 0.035,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoPreview(int index, double width, double height) {
    return Stack(
      children: [
        Container(
          width: width * 0.35,
          height: width * 0.35,
          margin: EdgeInsets.only(right: width * 0.03),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Image.file(
              File(_selectedImages[index]!.path),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: width * 0.04,
              ),
            ),
          ),
        ),
      ],
    );
  }

void _showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // user must tap OK
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Green tick
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green[100],
                ),
                padding: EdgeInsets.all(20),
                child: Icon(
                  Icons.check,
                  size: 50,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 20),
              // Review Submitted text
              Text(
                "Review Submitted",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              // OK button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                       Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    "OK",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

}
