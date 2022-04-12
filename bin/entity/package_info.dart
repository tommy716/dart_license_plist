import 'license_info.dart';

class PackageInfo {
  const PackageInfo({
    required String name,
    required LicenseInfo licenseInfo,
  })  : _name = name,
        _licenseInfo = licenseInfo;

  final String _name;
  String get name => _name;

  final LicenseInfo _licenseInfo;
  LicenseInfo get licenseInfo => _licenseInfo;
}
