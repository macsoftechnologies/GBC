class About {
  final String id;
  final String description;

  About({required this.id, required this.description});

  factory About.fromJson(Map<String, dynamic> json) {
    return About(
      id: json['id'] ?? '',
      description: json['about'] ?? '',
    );
  }
}

class GalleryItem {
  final String id;
  final String image;

  GalleryItem({required this.id, required this.image});

  factory GalleryItem.fromJson(Map<String, dynamic> json) {
    return GalleryItem(
      id: json['id'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class Review {
  final String name;
  final String profile;
  final String comments;

  Review({required this.name, required this.profile, required this.comments});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      name: json['name'] ?? '',
      profile: json['profile'] ?? '',
      comments: json['comments'] ?? '',
    );
  }
}

class ProviderDetails {
  final String name;
  final String profile;
  final String email;
  final String phoneNumber;
  final String address;
  final double latitude;
  final double longitude;
  final String landmark;
  final String location;
  final String workingCategory;
  final String companyName;
  final int rating;
  final String reviewCount;
  final String skills;
  final List<About> about;
  final List<GalleryItem> gallery;
  final List<Review> reviews;

  ProviderDetails({
    required this.name,
    required this.profile,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.landmark,
    required this.location,
    required this.workingCategory,
    required this.companyName,
    required this.rating,
    required this.reviewCount,
    required this.skills,
    required this.about,
    required this.gallery,
    required this.reviews,
  });

  factory ProviderDetails.fromJson(Map<String, dynamic> json) {
    return ProviderDetails(
      name: json['name'] ?? '',
      profile: json['profile'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      address: json['address'] ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0,
      landmark: json['landmark'] ?? '',
      location: json['location'] ?? '',
      workingCategory: json['working_category'] ?? '',
      companyName: json['company_name'] ?? '',
      rating: json['rating'] ?? 0,
      reviewCount: json['review_count'] ?? '0',
      skills: json['skills'] ?? '',
      about: (json['about'] as List<dynamic>?)
              ?.map((e) => About.fromJson(e))
              .toList() ??
          [],
      gallery: (json['gallery'] as List<dynamic>?)
              ?.map((e) => GalleryItem.fromJson(e))
              .toList() ??
          [],
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((e) => Review.fromJson(e))
              .toList() ??
          [],
    );
  }
}
