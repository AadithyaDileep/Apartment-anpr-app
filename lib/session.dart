import 'package:flutter/foundation.dart';

class AppUser {
  const AppUser(this.name, this.email, this.phone, this.address);
  final String name, email, phone, address;

  AppUser copy({String? name, String? phone, String? address}) =>
      AppUser(name ?? this.name, email, phone ?? this.phone, address ?? this.address);
}

class Account {
  const Account(this.password, this.user);
  final String password;
  final AppUser user;
}

const _demo = AppUser('Alex Morgan', 'alex@smartgate.com', '+91 98765 43210', 'Villa 12, Willow Estates');

/// In-memory accounts. Replace with your real backend.
final Map<String, Account> accounts = {
  'alex@smartgate.com': const Account('password', _demo),
};

final ValueNotifier<AppUser> currentUser = ValueNotifier<AppUser>(_demo);