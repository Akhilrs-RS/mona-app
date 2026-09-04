class Contact {
  final String id;
  final String name;
  final String organizationName;
  final String phone;
  final String email;
  final String project;
  final String address;
  final String status;
  final String source;
  final List<String> tags;
  final String date;

  Contact({
    required this.id,
    required this.name,
    required this.organizationName,
    required this.phone,
    required this.email,
    required this.project,
    required this.address,
    required this.status,
    required this.source,
    required this.tags,
    required this.date,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      organizationName: json['organizationName'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      project: json['project'] ?? '',
      address: json['address'] ?? '',
      status: json['status'] ?? '',
      source: json['source'] ?? '',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'organizationName': organizationName,
      'phone': phone,
      'email': email,
      'project': project,
      'address': address,
      'status': status,
      'source': source,
      'tags': tags,
      'date': date,
    };
  }
}

class Deal {
  final String id;
  final String title;
  final double value;
  final String contactId;
  final String stage;
  final String closeDate;

  Deal({
    required this.id,
    required this.title,
    required this.value,
    required this.contactId,
    required this.stage,
    required this.closeDate,
  });

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      value: double.tryParse(json['value']?.toString() ?? '0') ?? 0,
      contactId: json['contact_id']?.toString() ?? '',
      stage: json['stage'] ?? 'LEAD',
      closeDate: json['close_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'title': title,
      'value': value,
      'contact_id': contactId,
      'stage': stage,
      'close_date': closeDate,
    };
  }
}

class Activity {
  final String id;
  final String type;
  final String date;
  final String client;
  final String status;

  Activity({
    required this.id,
    required this.type,
    required this.date,
    required this.client,
    required this.status,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      date: json['date'] ?? '',
      client: json['client']?.toString() ?? '',
      status: json['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'type': type,
      'date': date,
      'client': client,
      'status': status,
    };
  }
}

class Quotation {
  final String id;
  final String quoteNo;
  final String clientName;
  final String projectTitle;
  final double total;
  final String status;
  final String date;
  final List<dynamic> items;

  Quotation({
    required this.id,
    required this.quoteNo,
    required this.clientName,
    required this.projectTitle,
    required this.total,
    required this.status,
    required this.date,
    required this.items,
  });

  factory Quotation.fromJson(Map<String, dynamic> json) {
    return Quotation(
      id: json['id']?.toString() ?? '',
      quoteNo: json['quoteNo'] ?? '',
      clientName: json['clientName'] ?? '',
      projectTitle: json['projectTitle'] ?? '',
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? '',
      date: json['date'] ?? '',
      items: json['items'] is List ? json['items'] : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'quoteNo': quoteNo,
      'clientName': clientName,
      'projectTitle': projectTitle,
      'total': total,
      'status': status,
      'date': date,
      'items': items,
    };
  }
}
