/// Pure dotted-version helpers for force-update checks.
int compareAppVersions(String a, String b) {
  final aParts = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  final bParts = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  final maxLength = aParts.length > bParts.length
      ? aParts.length
      : bParts.length;
  for (var i = 0; i < maxLength; i++) {
    final partA = i < aParts.length ? aParts[i] : 0;
    final partB = i < bParts.length ? bParts[i] : 0;
    if (partA < partB) return -1;
    if (partA > partB) return 1;
  }
  return 0;
}

bool isAppUpdateRequired({
  required String currentVersion,
  required int currentBuild,
  required String minVersion,
  required int minBuild,
}) {
  final cmp = compareAppVersions(currentVersion, minVersion);
  if (cmp < 0) return true;
  if (cmp > 0) return false;
  return currentBuild < minBuild;
}
