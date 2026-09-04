class Site {
  final int id;
  final String name;
  final String clientName;
  final String organizationName;
  final String assignedTeam;
  final String address;
  final String status;
  final String startDate;
  final double budget;
  final String description;
  final bool isNegotiated;
  final String negotiationDetails;
  final bool isArchived;
  final List<dynamic> workHistory;
  final Map<String, dynamic> maintenance;
  final List<dynamic> media;

  Site({
    required this.id,
    required this.name,
    required this.clientName,
    required this.organizationName,
    required this.assignedTeam,
    required this.address,
    required this.status,
    required this.startDate,
    required this.budget,
    required this.description,
    required this.isNegotiated,
    required this.negotiationDetails,
    required this.isArchived,
    required this.workHistory,
    required this.maintenance,
    required this.media,
  });

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      clientName: json['clientName'] ?? '',
      organizationName: json['organizationName'] ?? '',
      assignedTeam: json['assignedTeam'] ?? '',
      address: json['address'] ?? '',
      status: json['status'] ?? '',
      startDate: json['startDate'] ?? '',
      budget: double.tryParse(json['budget']?.toString() ?? '0') ?? 0.0,
      description: json['description'] ?? '',
      isNegotiated: json['isNegotiated'] ?? false,
      negotiationDetails: json['negotiationDetails'] ?? '',
      isArchived: json['isArchived'] ?? false,
      workHistory: json['workHistory'] is List ? json['workHistory'] : [],
      maintenance: json['maintenance'] is Map ? json['maintenance'] : {},
      media: json['media'] is List ? json['media'] : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != 0) 'id': id,
      'name': name,
      'clientName': clientName,
      'organizationName': organizationName,
      'assignedTeam': assignedTeam,
      'address': address,
      'status': status,
      'startDate': startDate,
      'budget': budget,
      'description': description,
      'isNegotiated': isNegotiated,
      'negotiationDetails': negotiationDetails,
      'isArchived': isArchived,
      'workHistory': workHistory,
      'maintenance': maintenance,
      'media': media,
    };
  }
}
