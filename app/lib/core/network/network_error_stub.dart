/// Web/JS build: there is no `dart:io`, so socket failures surface as
/// `package:http` client errors (handled separately) or as generic errors.
bool isNetworkFailure(Object error) => false;
